using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using ABSTRACTIONS;

namespace DAL
{
    /// <summary>
    /// Data access layer for newsletter subscription operations.
    /// </summary>
    public class NewsletterDAL
    {
        public DatabaseResult<NewsletterSubscription> Subscribe(string email, string languageCode)
        {
            if (string.IsNullOrWhiteSpace(email))
            {
                return DatabaseResult<NewsletterSubscription>.Failure(-1, "Email is required.");
            }

            languageCode = string.IsNullOrWhiteSpace(languageCode) ? "es" : languageCode.Trim().ToLowerInvariant();

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Newsletter_Subscribe", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Email", email.Trim());
                    command.Parameters.AddWithValue("@LanguageCode", languageCode);

                    SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };
                    SqlParameter subscriptionIdParam = new SqlParameter("@SubscriptionId", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);
                    command.Parameters.Add(subscriptionIdParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = resultCodeParam.Value != DBNull.Value ? Convert.ToInt32(resultCodeParam.Value) : 0;
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;
                    int subscriptionId = subscriptionIdParam.Value != DBNull.Value ? Convert.ToInt32(subscriptionIdParam.Value) : 0;

                    if (resultCode > 0)
                    {
                        var subscription = new NewsletterSubscription
                        {
                            SubscriptionId = subscriptionId,
                            Email = email.Trim(),
                            EmailNormalized = email.Trim().ToUpperInvariant(),
                            LanguageCode = languageCode,
                            IsActive = true,
                            IsConfirmed = true,
                            CreatedDate = DateTime.UtcNow,
                            LastUpdatedDate = DateTime.UtcNow
                        };

                        string message = string.IsNullOrWhiteSpace(resultMessage) ? "Subscription processed successfully." : resultMessage;
                        return DatabaseResult<NewsletterSubscription>.Success(subscription, message);
                    }

                    return DatabaseResult<NewsletterSubscription>.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Unable to subscribe to the newsletter." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<NewsletterSubscription>.Failure($"Database error processing subscription: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<NewsletterSubscription>.Failure($"Unexpected error processing subscription: {ex.Message}", ex);
            }
        }

        public DatabaseResult Unsubscribe(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
            {
                return DatabaseResult.Failure(-1, "Email is required.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Newsletter_Unsubscribe", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Email", email.Trim());

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
                        return DatabaseResult.Success(string.IsNullOrWhiteSpace(resultMessage) ? "Subscription removed successfully." : resultMessage);
                    }

                    return DatabaseResult.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Subscription not found." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error unsubscribing email: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error unsubscribing email: {ex.Message}", ex);
            }
        }

        public DatabaseResult<List<NewsletterSubscription>> GetSubscribers(bool? isActive, string searchTerm, int pageNumber, int pageSize)
        {
            if (pageNumber <= 0)
            {
                pageNumber = 1;
            }

            if (pageSize <= 0)
            {
                pageSize = 25;
            }
            else if (pageSize > 200)
            {
                pageSize = 200;
            }

            List<NewsletterSubscription> subscriptions = new List<NewsletterSubscription>();

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Newsletter_GetSubscribers", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@IsActive", isActive.HasValue ? (object)(isActive.Value ? 1 : 0) : DBNull.Value);
                    command.Parameters.AddWithValue("@SearchTerm", string.IsNullOrWhiteSpace(searchTerm) ? (object)DBNull.Value : searchTerm.Trim());
                    command.Parameters.AddWithValue("@PageNumber", pageNumber);
                    command.Parameters.AddWithValue("@PageSize", pageSize);

                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            subscriptions.Add(MapNewsletterSubscription(reader));
                        }
                    }
                }

                return DatabaseResult<List<NewsletterSubscription>>.Success(subscriptions, $"Retrieved {subscriptions.Count} subscription(s).");
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<List<NewsletterSubscription>>.Failure($"Database error retrieving subscriptions: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<List<NewsletterSubscription>>.Failure($"Unexpected error retrieving subscriptions: {ex.Message}", ex);
            }
        }

        public DatabaseResult<NewsletterSummary> GetSummary()
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Newsletter_GetSummary", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            var summary = new NewsletterSummary
                            {
                                TotalSubscribers = reader["TotalSubscribers"] != DBNull.Value ? Convert.ToInt32(reader["TotalSubscribers"]) : 0,
                                ActiveSubscribers = reader["ActiveSubscribers"] != DBNull.Value ? Convert.ToInt32(reader["ActiveSubscribers"]) : 0,
                                InactiveSubscribers = reader["InactiveSubscribers"] != DBNull.Value ? Convert.ToInt32(reader["InactiveSubscribers"]) : 0,
                                SubscribersLast30Days = reader["SubscribersLast30Days"] != DBNull.Value ? Convert.ToInt32(reader["SubscribersLast30Days"]) : 0
                            };

                            return DatabaseResult<NewsletterSummary>.Success(summary, "Newsletter summary retrieved successfully.");
                        }
                    }
                }

                return DatabaseResult<NewsletterSummary>.Failure(-1, "Unable to retrieve newsletter summary.");
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<NewsletterSummary>.Failure($"Database error retrieving summary: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<NewsletterSummary>.Failure($"Unexpected error retrieving summary: {ex.Message}", ex);
            }
        }

        private NewsletterSubscription MapNewsletterSubscription(SqlDataReader reader)
        {
            var subscription = new NewsletterSubscription
            {
                SubscriptionId = reader["SubscriptionId"] != DBNull.Value ? Convert.ToInt32(reader["SubscriptionId"]) : 0,
                Email = reader["Email"] as string ?? string.Empty,
                EmailNormalized = reader["EmailNormalized"] as string ?? string.Empty,
                LanguageCode = reader["LanguageCode"] as string ?? "es",
                IsActive = reader["IsActive"] != DBNull.Value && Convert.ToBoolean(reader["IsActive"]),
                IsConfirmed = reader["IsConfirmed"] != DBNull.Value && Convert.ToBoolean(reader["IsConfirmed"]),
                CreatedDate = reader["CreatedDate"] != DBNull.Value ? Convert.ToDateTime(reader["CreatedDate"]) : DateTime.MinValue,
                ConfirmedDate = reader["ConfirmedDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(reader["ConfirmedDate"]) : null,
                UnsubscribedDate = reader["UnsubscribedDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(reader["UnsubscribedDate"]) : null,
                LastUpdatedDate = reader["LastUpdatedDate"] != DBNull.Value ? Convert.ToDateTime(reader["LastUpdatedDate"]) : DateTime.MinValue,
                TotalRecords = reader["TotalRecords"] != DBNull.Value ? (int?)Convert.ToInt32(reader["TotalRecords"]) : null
            };

            return subscription;
        }
    }
}


