using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using ABSTRACTIONS;

namespace DAL
{
    public class BillingDAL
    {
        public DatabaseResult<BillingDocument> Create(BillingDocument document)
        {
            if (document == null)
            {
                return DatabaseResult<BillingDocument>.Failure(-1, "Billing document payload cannot be null.");
            }

            document.Items = document.Items ?? new List<BillingDocumentItem>();
            var validation = document.Validate();
            if (!validation.IsValid)
            {
                return DatabaseResult<BillingDocument>.Failure(-2, string.Join("; ", validation.Errors));
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    connection.Open();
                    var itemColumns = GetBillingDocumentItemTypeColumns(connection);

                    using (SqlCommand command = new SqlCommand("sp_BillingDocument_Create", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@UserId", document.UserId);
                        command.Parameters.AddWithValue("@DocumentType", document.DocumentType ?? BillingDocumentTypes.Invoice);
                        command.Parameters.AddWithValue("@DocumentNumber", document.DocumentNumber ?? string.Empty);
                        command.Parameters.AddWithValue("@ReferenceDocumentId", ToDbValue(document.ReferenceDocumentId));
                        command.Parameters.AddWithValue("@IssueDateUtc", ToDbValue(document.IssueDateUtc == default ? (DateTime?)null : document.IssueDateUtc));
                        command.Parameters.AddWithValue("@DueDateUtc", ToDbValue(document.DueDateUtc));
                        command.Parameters.AddWithValue("@CurrencyCode", document.CurrencyCode ?? "ARS");
                        command.Parameters.AddWithValue("@Status", document.Status ?? BillingDocumentStatuses.Draft);
                        command.Parameters.AddWithValue("@Notes", ToDbValue(document.Notes));
                        command.Parameters.AddWithValue("@CreatedBy", document.CreatedBy > 0 ? document.CreatedBy : document.UserId);

                        SqlParameter itemsParam = command.Parameters.Add("@Items", SqlDbType.Structured);
                        itemsParam.TypeName = "dbo.BillingDocumentItemTableType";
                        itemsParam.Value = ConvertItemsToDataTable(document.Items, itemColumns);

                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        SqlParameter newIdParam = new SqlParameter("@NewBillingDocumentId", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };

                        command.Parameters.Add(resultCodeParam);
                        command.Parameters.Add(resultMessageParam);
                        command.Parameters.Add(newIdParam);

                        command.ExecuteNonQuery();

                        int resultCode = resultCodeParam.Value != DBNull.Value ? Convert.ToInt32(resultCodeParam.Value) : 0;
                        string resultMessage = resultMessageParam.Value as string ?? string.Empty;
                        int newId = newIdParam.Value != DBNull.Value ? Convert.ToInt32(newIdParam.Value) : 0;

                        if (resultCode == 1 && newId > 0)
                        {
                            var fetchResult = GetById(newId);
                            if (fetchResult.IsSuccessful && fetchResult.Data != null)
                            {
                                return DatabaseResult<BillingDocument>.Success(fetchResult.Data, string.IsNullOrWhiteSpace(resultMessage) ? "Billing document created successfully." : resultMessage);
                            }

                            document.BillingDocumentId = newId;
                            return DatabaseResult<BillingDocument>.Success(document, string.IsNullOrWhiteSpace(resultMessage) ? "Billing document created successfully." : resultMessage);
                        }

                        return DatabaseResult<BillingDocument>.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Unable to create billing document." : resultMessage);
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<BillingDocument>.Failure($"Database error creating billing document: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<BillingDocument>.Failure($"Unexpected error creating billing document: {ex.Message}", ex);
            }
        }

        public DatabaseResult<BillingDocument> GetById(int billingDocumentId)
        {
            if (billingDocumentId <= 0)
            {
                return DatabaseResult<BillingDocument>.Failure(-1, "BillingDocumentId must be greater than zero.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_BillingDocument_GetById", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@BillingDocumentId", billingDocumentId);

                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        BillingDocument document = null;
                        if (reader.Read())
                        {
                            document = MapBillingDocument(reader);
                        }

                        if (document == null)
                        {
                            return DatabaseResult<BillingDocument>.Failure(-2, "Billing document not found.");
                        }

                        if (reader.NextResult())
                        {
                            document.Items = new List<BillingDocumentItem>();
                            while (reader.Read())
                            {
                                document.Items.Add(MapBillingDocumentItem(reader));
                            }
                        }

                        return DatabaseResult<BillingDocument>.Success(document, "Billing document retrieved successfully.");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<BillingDocument>.Failure($"Database error retrieving billing document: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<BillingDocument>.Failure($"Unexpected error retrieving billing document: {ex.Message}", ex);
            }
        }

        public DatabaseResult<List<BillingDocument>> Search(BillingDocumentSearchCriteria criteria)
        {
            criteria = criteria ?? new BillingDocumentSearchCriteria();
            criteria.Normalize();

            var documents = new List<BillingDocument>();

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_BillingDocument_Search", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@DocumentType", ToDbValue(criteria.DocumentType));
                    command.Parameters.AddWithValue("@Status", ToDbValue(criteria.Status));
                    command.Parameters.AddWithValue("@FromIssueDateUtc", ToDbValue(criteria.FromIssueDateUtc));
                    command.Parameters.AddWithValue("@ToIssueDateUtc", ToDbValue(criteria.ToIssueDateUtc));
                    command.Parameters.AddWithValue("@UserId", ToDbValue(criteria.UserId));
                    command.Parameters.AddWithValue("@DocumentNumber", ToDbValue(criteria.DocumentNumber));

                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            documents.Add(MapBillingDocument(reader));
                        }
                    }
                }

                return DatabaseResult<List<BillingDocument>>.Success(documents, $"Retrieved {documents.Count} document(s).");
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<List<BillingDocument>>.Failure($"Database error searching billing documents: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<List<BillingDocument>>.Failure($"Unexpected error searching billing documents: {ex.Message}", ex);
            }
        }

        public DatabaseResult UpdateStatus(int billingDocumentId, string newStatus, int modifiedBy)
        {
            if (billingDocumentId <= 0)
            {
                return DatabaseResult.Failure(-1, "BillingDocumentId must be greater than zero.");
            }

            if (string.IsNullOrWhiteSpace(newStatus) || !BillingDocumentStatuses.Allowed.Contains(newStatus))
            {
                return DatabaseResult.Failure(-2, "Invalid status value.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_BillingDocument_UpdateStatus", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@BillingDocumentId", billingDocumentId);
                    command.Parameters.AddWithValue("@NewStatus", newStatus);
                    command.Parameters.AddWithValue("@ModifiedBy", modifiedBy);

                    SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = resultCodeParam.Value != DBNull.Value ? Convert.ToInt32(resultCodeParam.Value) : 0;
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;

                    if (resultCode == 1)
                    {
                        return DatabaseResult.Success(string.IsNullOrWhiteSpace(resultMessage) ? "Status updated successfully." : resultMessage);
                    }

                    return DatabaseResult.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Unable to update billing document status." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error updating billing document status: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error updating billing document status: {ex.Message}", ex);
            }
        }

        public DatabaseResult AddItem(int billingDocumentId, BillingDocumentItem item, int modifiedBy)
        {
            if (item == null)
            {
                return DatabaseResult.Failure(-1, "Item payload cannot be null.");
            }

            var validation = item.Validate();
            if (!validation.IsValid)
            {
                return DatabaseResult.Failure(-2, string.Join("; ", validation.Errors));
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_BillingDocument_AddItem", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@BillingDocumentId", billingDocumentId);
                    command.Parameters.AddWithValue("@ProductId", item.ProductId);
                    command.Parameters.AddWithValue("@Description", item.Description ?? string.Empty);
                    command.Parameters.AddWithValue("@Quantity", item.Quantity);
                    command.Parameters.AddWithValue("@UnitPrice", item.UnitPrice);
                    command.Parameters.AddWithValue("@TaxRate", item.TaxRate);
                    command.Parameters.AddWithValue("@LineNotes", ToDbValue(item.LineNotes));
                    command.Parameters.AddWithValue("@ModifiedBy", modifiedBy);

                    SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = resultCodeParam.Value != DBNull.Value ? Convert.ToInt32(resultCodeParam.Value) : 0;
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;

                    if (resultCode == 1)
                    {
                        return DatabaseResult.Success(string.IsNullOrWhiteSpace(resultMessage) ? "Item added successfully." : resultMessage);
                    }

                    return DatabaseResult.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Unable to add item." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error adding billing document item: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error adding billing document item: {ex.Message}", ex);
            }
        }

        public DatabaseResult RemoveItem(int billingDocumentItemId, int modifiedBy)
        {
            if (billingDocumentItemId <= 0)
            {
                return DatabaseResult.Failure(-1, "BillingDocumentItemId must be greater than zero.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_BillingDocument_RemoveItem", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@BillingDocumentItemId", billingDocumentItemId);
                    command.Parameters.AddWithValue("@ModifiedBy", modifiedBy);

                    SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = resultCodeParam.Value != DBNull.Value ? Convert.ToInt32(resultCodeParam.Value) : 0;
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;

                    if (resultCode == 1)
                    {
                        return DatabaseResult.Success(string.IsNullOrWhiteSpace(resultMessage) ? "Item removed successfully." : resultMessage);
                    }

                    return DatabaseResult.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Unable to remove item." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error removing billing document item: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error removing billing document item: {ex.Message}", ex);
            }
        }

        public DatabaseResult Delete(int billingDocumentId)
        {
            if (billingDocumentId <= 0)
            {
                return DatabaseResult.Failure(-1, "BillingDocumentId must be greater than zero.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_BillingDocument_Delete", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@BillingDocumentId", billingDocumentId);

                    SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = resultCodeParam.Value != DBNull.Value ? Convert.ToInt32(resultCodeParam.Value) : 0;
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;

                    if (resultCode == 1)
                    {
                        return DatabaseResult.Success(string.IsNullOrWhiteSpace(resultMessage) ? "Billing document deleted successfully." : resultMessage);
                    }

                    return DatabaseResult.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Unable to delete billing document." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error deleting billing document: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error deleting billing document: {ex.Message}", ex);
            }
        }

        public DatabaseResult<BillingStatisticsResponse> GetMonthlyStatistics(int? year, int maxMonths, string sortDirection)
        {
            int normalizedMaxMonths = maxMonths <= 0 ? 12 : Math.Min(maxMonths, 120);
            string normalizedSort = string.IsNullOrWhiteSpace(sortDirection) ? "DESC" : sortDirection.Trim().ToUpperInvariant();
            if (!string.Equals(normalizedSort, "ASC", StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(normalizedSort, "DESC", StringComparison.OrdinalIgnoreCase))
            {
                normalizedSort = "DESC";
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_BillingDocument_GetMonthlyStatistics", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Year", year.HasValue ? (object)year.Value : DBNull.Value);
                    command.Parameters.AddWithValue("@MaxMonths", normalizedMaxMonths);
                    command.Parameters.AddWithValue("@SortDirection", normalizedSort);

                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        var response = new BillingStatisticsResponse();

                        if (reader.Read())
                        {
                            response.Summary.TotalDocuments = GetInt32(reader, "TotalDocuments");
                            response.Summary.PaidDocuments = GetInt32(reader, "PaidDocuments");
                            response.Summary.OutstandingDocuments = GetInt32(reader, "OutstandingDocuments");
                            response.Summary.CancelledDocuments = GetInt32(reader, "CancelledDocuments");
                            response.Summary.TotalAmount = GetDecimal(reader, "TotalAmount");
                            response.Summary.PaidAmount = GetDecimal(reader, "PaidAmount");
                            response.Summary.OutstandingAmount = GetDecimal(reader, "OutstandingAmount");
                            response.Summary.AverageInvoiceAmount = GetDecimal(reader, "AverageInvoiceAmount");
                            response.Summary.LastUpdatedDateUtc = GetNullableDate(reader, "LastUpdatedDateUtc");
                        }

                        if (reader.NextResult())
                        {
                            while (reader.Read())
                            {
                                response.MonthlyBreakdown.Add(new BillingMonthlyStatistic
                                {
                                    YearNumber = GetInt32(reader, "YearNumber"),
                                    MonthNumber = GetInt32(reader, "MonthNumber"),
                                    MonthName = GetString(reader, "MonthName"),
                                    TotalDocuments = GetInt32(reader, "TotalDocuments"),
                                    PaidDocuments = GetInt32(reader, "PaidDocuments"),
                                    CancelledDocuments = GetInt32(reader, "CancelledDocuments"),
                                    DraftDocuments = GetInt32(reader, "DraftDocuments"),
                                    IssuedDocuments = GetInt32(reader, "IssuedDocuments"),
                                    TotalAmount = GetDecimal(reader, "TotalAmount"),
                                    PaidAmount = GetDecimal(reader, "PaidAmount"),
                                    OutstandingAmount = GetDecimal(reader, "OutstandingAmount")
                                });
                            }
                        }

                        return BillingStatisticsResult.Success(response, "Billing statistics retrieved successfully.");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return BillingStatisticsResult.Failure($"Database error retrieving billing statistics: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return BillingStatisticsResult.Failure($"Unexpected error retrieving billing statistics: {ex.Message}", ex);
            }
        }

        private static readonly string[] DefaultBillingItemColumns =
        {
            "ProductId",
            "Description",
            "Quantity",
            "UnitPrice",
            "TaxRate",
            "LineNotes"
        };

        private static IReadOnlyList<string> GetBillingDocumentItemTypeColumns(SqlConnection connection)
        {
            var columns = new List<string>();
            const string query = @"
SELECT c.name
FROM sys.table_types tt
INNER JOIN sys.columns c ON c.object_id = tt.type_table_object_id
WHERE tt.name = @TypeName AND tt.schema_id = SCHEMA_ID('dbo')
ORDER BY c.column_id;";

            using (var command = new SqlCommand(query, connection))
            {
                command.Parameters.AddWithValue("@TypeName", "BillingDocumentItemTableType");

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        columns.Add(reader.GetString(0));
                    }
                }
            }

            if (columns.Count > 0)
            {
                return columns;
            }

            return DefaultBillingItemColumns;
        }

        private static DataTable ConvertItemsToDataTable(IEnumerable<BillingDocumentItem> items, IReadOnlyList<string> columnOrder)
        {
            var table = new DataTable();

            foreach (var column in columnOrder)
            {
                var columnType = GetColumnType(column);
                table.Columns.Add(column, columnType);
            }

            foreach (var item in items ?? Enumerable.Empty<BillingDocumentItem>())
            {
                var rowValues = new object[columnOrder.Count];

                for (int i = 0; i < columnOrder.Count; i++)
                {
                    var columnName = columnOrder[i];
                    rowValues[i] = GetColumnValue(columnName, item);
                }

                table.Rows.Add(rowValues);
            }

            return table;
        }

        private static Type GetColumnType(string columnName)
        {
            if (string.Equals(columnName, "ProductId", StringComparison.OrdinalIgnoreCase))
            {
                return typeof(int);
            }

            if (string.Equals(columnName, "Description", StringComparison.OrdinalIgnoreCase))
            {
                return typeof(string);
            }

            if (string.Equals(columnName, "Quantity", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(columnName, "UnitPrice", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(columnName, "TaxRate", StringComparison.OrdinalIgnoreCase))
            {
                return typeof(decimal);
            }

            if (string.Equals(columnName, "LineNotes", StringComparison.OrdinalIgnoreCase))
            {
                return typeof(string);
            }

            return typeof(object);
        }

        private static object GetColumnValue(string columnName, BillingDocumentItem item)
        {
            if (string.Equals(columnName, "ProductId", StringComparison.OrdinalIgnoreCase))
            {
                return item.ProductId;
            }

            if (string.Equals(columnName, "Description", StringComparison.OrdinalIgnoreCase))
            {
                return item.Description ?? string.Empty;
            }

            if (string.Equals(columnName, "Quantity", StringComparison.OrdinalIgnoreCase))
            {
                return item.Quantity;
            }

            if (string.Equals(columnName, "UnitPrice", StringComparison.OrdinalIgnoreCase))
            {
                return item.UnitPrice;
            }

            if (string.Equals(columnName, "TaxRate", StringComparison.OrdinalIgnoreCase))
            {
                return item.TaxRate;
            }

            if (string.Equals(columnName, "LineNotes", StringComparison.OrdinalIgnoreCase))
            {
                return string.IsNullOrWhiteSpace(item.LineNotes) ? (object)DBNull.Value : item.LineNotes;
            }

            return DBNull.Value;
        }

        private static BillingDocument MapBillingDocument(SqlDataReader reader)
        {
            return new BillingDocument
            {
                BillingDocumentId = reader["BillingDocumentId"] != DBNull.Value ? Convert.ToInt32(reader["BillingDocumentId"]) : 0,
                UserId = reader["UserId"] != DBNull.Value ? Convert.ToInt32(reader["UserId"]) : 0,
                DocumentType = reader["DocumentType"] as string,
                DocumentNumber = reader["DocumentNumber"] as string,
                ReferenceDocumentId = reader["ReferenceDocumentId"] != DBNull.Value ? (int?)Convert.ToInt32(reader["ReferenceDocumentId"]) : null,
                IssueDateUtc = reader["IssueDateUtc"] != DBNull.Value ? Convert.ToDateTime(reader["IssueDateUtc"]) : DateTime.UtcNow,
                DueDateUtc = reader["DueDateUtc"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(reader["DueDateUtc"]) : null,
                CurrencyCode = reader["CurrencyCode"] as string ?? "ARS",
                SubtotalAmount = reader["SubtotalAmount"] != DBNull.Value ? Convert.ToDecimal(reader["SubtotalAmount"]) : 0,
                TaxAmount = reader["TaxAmount"] != DBNull.Value ? Convert.ToDecimal(reader["TaxAmount"]) : 0,
                TotalAmount = reader["TotalAmount"] != DBNull.Value ? Convert.ToDecimal(reader["TotalAmount"]) : 0,
                Status = reader["Status"] as string ?? BillingDocumentStatuses.Draft,
                Notes = reader["Notes"] as string,
                CreatedBy = reader["CreatedBy"] != DBNull.Value ? Convert.ToInt32(reader["CreatedBy"]) : 0,
                CreatedDateUtc = reader["CreatedDateUtc"] != DBNull.Value ? Convert.ToDateTime(reader["CreatedDateUtc"]) : DateTime.UtcNow,
                LastModifiedBy = reader["LastModifiedBy"] != DBNull.Value ? (int?)Convert.ToInt32(reader["LastModifiedBy"]) : null,
                LastModifiedDateUtc = reader["LastModifiedDateUtc"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(reader["LastModifiedDateUtc"]) : null,
                Items = new List<BillingDocumentItem>()
            };
        }

        private static BillingDocumentItem MapBillingDocumentItem(SqlDataReader reader)
        {
            return new BillingDocumentItem
            {
                BillingDocumentItemId = reader["BillingDocumentItemId"] != DBNull.Value ? Convert.ToInt32(reader["BillingDocumentItemId"]) : 0,
                BillingDocumentId = reader["BillingDocumentId"] != DBNull.Value ? Convert.ToInt32(reader["BillingDocumentId"]) : 0,
                Description = reader["Description"] as string,
                ProductId = reader["ProductId"] != DBNull.Value ? Convert.ToInt32(reader["ProductId"]) : 0,
                Quantity = reader["Quantity"] != DBNull.Value ? Convert.ToDecimal(reader["Quantity"]) : 0,
                UnitPrice = reader["UnitPrice"] != DBNull.Value ? Convert.ToDecimal(reader["UnitPrice"]) : 0,
                TaxRate = reader["TaxRate"] != DBNull.Value ? Convert.ToDecimal(reader["TaxRate"]) : 0,
                LineSubtotal = reader["LineSubtotal"] != DBNull.Value ? Convert.ToDecimal(reader["LineSubtotal"]) : 0,
                LineTaxAmount = reader["LineTaxAmount"] != DBNull.Value ? Convert.ToDecimal(reader["LineTaxAmount"]) : 0,
                LineTotal = reader["LineTotal"] != DBNull.Value ? Convert.ToDecimal(reader["LineTotal"]) : 0,
                LineNotes = reader["LineNotes"] as string
            };
        }

        private static object ToDbValue(object value)
        {
            return value ?? DBNull.Value;
        }

        private static int GetInt32(SqlDataReader reader, string columnName)
        {
            object value = reader[columnName];
            return value == DBNull.Value ? 0 : Convert.ToInt32(value);
        }

        private static decimal GetDecimal(SqlDataReader reader, string columnName)
        {
            object value = reader[columnName];
            return value == DBNull.Value ? 0m : Convert.ToDecimal(value);
        }

        private static string GetString(SqlDataReader reader, string columnName)
        {
            object value = reader[columnName];
            return value == DBNull.Value ? string.Empty : Convert.ToString(value);
        }

        private static DateTime? GetNullableDate(SqlDataReader reader, string columnName)
        {
            object value = reader[columnName];
            return value == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(value);
        }
    }
}
