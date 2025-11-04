using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using ABSTRACTIONS;

namespace DAL
{
    /// <summary>
    /// Data Access Layer for Homepage Advertisement operations
    /// Handles all database interactions using stored procedures
    /// </summary>
    public class HomepageAdDAL
    {
        /// <summary>
        /// Retrieves all homepage ads ordered by IsSelected DESC, IsActive DESC
        /// </summary>
        public List<HomepageAd> GetAllAds()
        {
            var ads = new List<HomepageAd>();

            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_HomepageAd_GetAll", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ads.Add(new HomepageAd
                            {
                                AdId = SafeGetInt(reader, "AdId"),
                                BadgeText = reader["BadgeText"]?.ToString(),
                                Title = reader["Title"]?.ToString(),
                                Description = reader["Description"]?.ToString(),
                                CtaText = reader["CtaText"]?.ToString(),
                                TargetUrl = reader["TargetUrl"]?.ToString(),
                                IsActive = SafeGetBool(reader, "IsActive"),
                                IsSelected = SafeGetBool(reader, "IsSelected"),
                                CreatedDateUtc = SafeGetDateTime(reader, "CreatedDateUtc"),
                                ModifiedDateUtc = SafeGetNullableDateTime(reader, "ModifiedDateUtc"),
                                CreatedByUserId = SafeGetNullableInt(reader, "CreatedByUserId"),
                                ModifiedByUserId = SafeGetNullableInt(reader, "ModifiedByUserId")
                            });
                        }
                    }
                }
            }
            catch (SqlException)
            {
                return new List<HomepageAd>();
            }
            catch (Exception)
            {
                return new List<HomepageAd>();
            }

            return ads;
        }

        /// <summary>
        /// Retrieves a single homepage ad by ID
        /// </summary>
        public HomepageAd GetAdById(int adId)
        {
            if (adId <= 0)
            {
                return null;
            }

            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_HomepageAd_GetById", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@AdId", adId);

                    connection.Open();
                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return new HomepageAd
                            {
                                AdId = SafeGetInt(reader, "AdId"),
                                BadgeText = reader["BadgeText"]?.ToString(),
                                Title = reader["Title"]?.ToString(),
                                Description = reader["Description"]?.ToString(),
                                CtaText = reader["CtaText"]?.ToString(),
                                TargetUrl = reader["TargetUrl"]?.ToString(),
                                IsActive = SafeGetBool(reader, "IsActive"),
                                IsSelected = SafeGetBool(reader, "IsSelected"),
                                CreatedDateUtc = SafeGetDateTime(reader, "CreatedDateUtc"),
                                ModifiedDateUtc = SafeGetNullableDateTime(reader, "ModifiedDateUtc"),
                                CreatedByUserId = SafeGetNullableInt(reader, "CreatedByUserId"),
                                ModifiedByUserId = SafeGetNullableInt(reader, "ModifiedByUserId")
                            };
                        }
                    }
                }
            }
            catch (SqlException)
            {
                return null;
            }
            catch (Exception)
            {
                return null;
            }

            return null;
        }

        /// <summary>
        /// Retrieves the selected ad for display on the homepage
        /// Returns the selected ad or the most recent active ad if none selected
        /// </summary>
        public HomepageAd GetSelectedAdForDisplay()
        {
            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_HomepageAd_GetSelectedForDisplay", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return new HomepageAd
                            {
                                AdId = SafeGetInt(reader, "AdId"),
                                BadgeText = reader["BadgeText"]?.ToString(),
                                Title = reader["Title"]?.ToString(),
                                Description = reader["Description"]?.ToString(),
                                CtaText = reader["CtaText"]?.ToString(),
                                TargetUrl = reader["TargetUrl"]?.ToString(),
                                IsActive = SafeGetBool(reader, "IsActive"),
                                IsSelected = SafeGetBool(reader, "IsSelected"),
                                CreatedDateUtc = SafeGetDateTime(reader, "CreatedDateUtc"),
                                ModifiedDateUtc = SafeGetNullableDateTime(reader, "ModifiedDateUtc"),
                                CreatedByUserId = SafeGetNullableInt(reader, "CreatedByUserId"),
                                ModifiedByUserId = SafeGetNullableInt(reader, "ModifiedByUserId")
                            };
                        }
                    }
                }
            }
            catch (SqlException)
            {
                return null;
            }
            catch (Exception)
            {
                return null;
            }

            return null;
        }

        /// <summary>
        /// Creates or updates a homepage ad
        /// </summary>
        public DatabaseResult SaveAd(HomepageAd ad, int? auditUserId)
        {
            if (ad == null)
            {
                return DatabaseResult.Failure(-1, "Advertisement information is required.");
            }

            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_HomepageAd_Save", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    // AdId parameter (INPUT/OUTPUT)
                    var adIdParam = new SqlParameter("@AdId", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.InputOutput,
                        Value = ad.AdId
                    };
                    command.Parameters.Add(adIdParam);

                    // Ad fields
                    command.Parameters.AddWithValue("@BadgeText", (object)ad.BadgeText ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Title", (object)ad.Title ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Description", (object)ad.Description ?? DBNull.Value);
                    command.Parameters.AddWithValue("@CtaText", (object)ad.CtaText ?? DBNull.Value);
                    command.Parameters.AddWithValue("@TargetUrl", (object)ad.TargetUrl ?? DBNull.Value);
                    command.Parameters.AddWithValue("@IsActive", ad.IsActive);
                    command.Parameters.AddWithValue("@AuditUserId", auditUserId.HasValue && auditUserId.Value > 0 ? (object)auditUserId.Value : DBNull.Value);

                    // Output parameters
                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultCodeParam);

                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    // Update AdId in the object
                    ad.AdId = Convert.ToInt32(adIdParam.Value ?? 0);
                    var resultCode = Convert.ToInt32(resultCodeParam.Value ?? 0);
                    var message = resultMessageParam.Value?.ToString() ?? string.Empty;

                    return new DatabaseResult(
                        resultCode > 0,
                        resultCode,
                        string.IsNullOrWhiteSpace(message) ? (resultCode > 0 ? "Success" : "Unable to save advertisement.") : message
                    );
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure("Database error saving advertisement.", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Error saving advertisement.", ex);
            }
        }

        /// <summary>
        /// Soft deletes a homepage ad by setting IsActive=0 and IsSelected=0
        /// </summary>
        public DatabaseResult DeleteAd(int adId, int? auditUserId)
        {
            if (adId <= 0)
            {
                return DatabaseResult.Failure(-1, "Advertisement identifier is required.");
            }

            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_HomepageAd_Delete", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@AdId", adId);
                    command.Parameters.AddWithValue("@AuditUserId", auditUserId.HasValue && auditUserId.Value > 0 ? (object)auditUserId.Value : DBNull.Value);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultCodeParam);

                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    var resultCode = Convert.ToInt32(resultCodeParam.Value ?? 0);
                    var message = resultMessageParam.Value?.ToString() ?? string.Empty;

                    return new DatabaseResult(
                        resultCode > 0,
                        resultCode,
                        string.IsNullOrWhiteSpace(message) ? (resultCode > 0 ? "Success" : "Unable to delete advertisement.") : message
                    );
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure("Database error deleting advertisement.", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Error deleting advertisement.", ex);
            }
        }

        /// <summary>
        /// Sets the selected ad for display on the homepage
        /// Pass null to deselect all ads
        /// </summary>
        public DatabaseResult SetSelectedAd(int? adId, int? auditUserId)
        {
            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_HomepageAd_SetSelected", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@AdId", adId.HasValue && adId.Value > 0 ? (object)adId.Value : DBNull.Value);
                    command.Parameters.AddWithValue("@AuditUserId", auditUserId.HasValue && auditUserId.Value > 0 ? (object)auditUserId.Value : DBNull.Value);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultCodeParam);

                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    var resultCode = Convert.ToInt32(resultCodeParam.Value ?? 0);
                    var message = resultMessageParam.Value?.ToString() ?? string.Empty;

                    return new DatabaseResult(
                        resultCode > 0,
                        resultCode,
                        string.IsNullOrWhiteSpace(message) ? (resultCode > 0 ? "Success" : "Unable to set selected advertisement.") : message
                    );
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure("Database error setting selected advertisement.", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Error setting selected advertisement.", ex);
            }
        }

        #region Safe Data Reading Helpers

        private static int SafeGetInt(IDataRecord reader, string column)
        {
            return reader[column] == DBNull.Value ? 0 : Convert.ToInt32(reader[column]);
        }

        private static int? SafeGetNullableInt(IDataRecord reader, string column)
        {
            return reader[column] == DBNull.Value ? (int?)null : Convert.ToInt32(reader[column]);
        }

        private static bool SafeGetBool(IDataRecord reader, string column)
        {
            try
            {
                return reader[column] != DBNull.Value && Convert.ToBoolean(reader[column]);
            }
            catch
            {
                return false;
            }
        }

        private static DateTime SafeGetDateTime(IDataRecord reader, string column)
        {
            return reader[column] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(reader[column]);
        }

        private static DateTime? SafeGetNullableDateTime(IDataRecord reader, string column)
        {
            return reader[column] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader[column]);
        }

        #endregion
    }
}
