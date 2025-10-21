using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using ABSTRACTIONS;

namespace DAL
{
    public class CatalogDAL
    {
        public CatalogDAL()
        {
        }

        public bool CreateCatalog(Catalog catalog)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_CreateCatalog", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        command.Parameters.AddWithValue("@Name", catalog.Name);
                        command.Parameters.AddWithValue("@Description", catalog.Description ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@CreatedByUserId", catalog.CreatedByUserId);

                        connection.Open();
                        command.ExecuteNonQuery();
                        return true;
                    }
                }
            }
            catch (Exception)
            {
                return false;
            }
        }

        public bool UpdateCatalog(Catalog catalog)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_UpdateCatalog", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        command.Parameters.AddWithValue("@CatalogId", catalog.CatalogId);
                        command.Parameters.AddWithValue("@Name", catalog.Name);
                        command.Parameters.AddWithValue("@Description", catalog.Description ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@IsActive", catalog.IsActive);
                        command.Parameters.AddWithValue("@ModifiedDate", DateTime.Now);

                        connection.Open();
                        int result = command.ExecuteNonQuery();
                        return result > 0;
                    }
                }
            }
            catch (Exception)
            {
                return false;
            }
        }

        public bool DeleteCatalog(int catalogId)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_DeleteCatalog", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@CatalogId", catalogId);

                        connection.Open();
                        int result = command.ExecuteNonQuery();
                        return result > 0;
                    }
                }
            }
            catch (Exception)
            {
                return false;
            }
        }

        public Catalog GetCatalogById(int catalogId)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetCatalogById", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@CatalogId", catalogId);

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapReaderToCatalog(reader);
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {
            }
            return null;
        }

        public List<Catalog> GetAllCatalogs()
        {
            List<Catalog> catalogs = new List<Catalog>();
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetAllCatalogs", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                catalogs.Add(MapReaderToCatalog(reader));
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {
            }
            return catalogs;
        }

        public List<Catalog> GetActiveCatalogs()
        {
            List<Catalog> catalogs = new List<Catalog>();
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetActiveCatalogs", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                catalogs.Add(MapReaderToCatalog(reader));
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {
            }
            return catalogs;
        }

        public bool AddProductToCatalog(int catalogId, int productId, int addedByUserId)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_AddProductToCatalog", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        command.Parameters.AddWithValue("@CatalogId", catalogId);
                        command.Parameters.AddWithValue("@ProductId", productId);
                        command.Parameters.AddWithValue("@AddedByUserId", addedByUserId);

                        connection.Open();
                        int result = command.ExecuteNonQuery();
                        return true;
                    }
                }
            }
            catch (Exception)
            {
                return false;
            }
        }

        public bool RemoveProductFromCatalog(int catalogId, int productId)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_RemoveProductFromCatalog", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        command.Parameters.AddWithValue("@CatalogId", catalogId);
                        command.Parameters.AddWithValue("@ProductId", productId);

                        connection.Open();
                        int result = command.ExecuteNonQuery();
                        return result > 0;
                    }
                }
            }
            catch (Exception)
            {
                return false;
            }
        }

        public List<Product> GetProductsByCatalogId(int catalogId)
        {
            List<Product> products = new List<Product>();
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetProductsByCatalogId", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@CatalogId", catalogId);

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                products.Add(MapReaderToProduct(reader));
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {
            }
            return products;
        }

        private Catalog MapReaderToCatalog(SqlDataReader reader)
        {
            return new Catalog
            {
                CatalogId = (int)reader["CatalogId"],
                Name = reader["Name"].ToString(),
                Description = reader["Description"] == DBNull.Value ? null : reader["Description"].ToString(),
                IsActive = (bool)reader["IsActive"],
                CreatedDate = (DateTime)reader["CreatedDate"],
                ModifiedDate = reader["ModifiedDate"] == DBNull.Value ? null : (DateTime?)reader["ModifiedDate"],
                CreatedByUserId = (int)reader["CreatedByUserId"]
            };
        }

        private Product MapReaderToProduct(SqlDataReader reader)
        {
            return new Product
            {
                ProductId = (int)reader["ProductId"],
                Name = reader["Name"].ToString(),
                Description = reader["Description"] == DBNull.Value ? null : reader["Description"].ToString(),
                Price = (decimal)reader["Price"],
                BillingCycle = reader["BillingCycle"] == DBNull.Value ? "Monthly" : reader["BillingCycle"].ToString(),
                MaxChatbots = (int)reader["MaxChatbots"],
                MaxMessagesPerMonth = (int)reader["MaxMessagesPerMonth"],
                Features = reader["Features"] == DBNull.Value ? null : reader["Features"].ToString(),
                Category = reader["Category"] == DBNull.Value ? null : reader["Category"].ToString(),
                IsActive = (bool)reader["IsActive"],
                CreatedDate = (DateTime)reader["CreatedDate"],
                ModifiedDate = reader["ModifiedDate"] == DBNull.Value ? null : (DateTime?)reader["ModifiedDate"],
                CreatedByUserId = (int)reader["CreatedByUserId"]
            };
        }
    }
}