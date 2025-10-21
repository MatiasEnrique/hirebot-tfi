using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using ABSTRACTIONS;

namespace DAL
{
    public class ProductDAL
    {
        public ProductDAL()
        {
        }

        public bool CreateProduct(Product product)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_CreateProduct", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        command.Parameters.AddWithValue("@Name", product.Name);
                        command.Parameters.AddWithValue("@Description", product.Description ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@Price", product.Price);
                        command.Parameters.AddWithValue("@BillingCycle", product.BillingCycle ?? "Monthly");
                        command.Parameters.AddWithValue("@MaxChatbots", product.MaxChatbots);
                        command.Parameters.AddWithValue("@MaxMessagesPerMonth", product.MaxMessagesPerMonth);
                        command.Parameters.AddWithValue("@Features", product.Features ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@Category", product.Category ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@CreatedByUserId", product.CreatedByUserId);

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

        public bool UpdateProduct(Product product)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_UpdateProduct", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        command.Parameters.AddWithValue("@ProductId", product.ProductId);
                        command.Parameters.AddWithValue("@Name", product.Name);
                        command.Parameters.AddWithValue("@Description", product.Description ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@Price", product.Price);
                        command.Parameters.AddWithValue("@BillingCycle", product.BillingCycle ?? "Monthly");
                        command.Parameters.AddWithValue("@MaxChatbots", product.MaxChatbots);
                        command.Parameters.AddWithValue("@MaxMessagesPerMonth", product.MaxMessagesPerMonth);
                        command.Parameters.AddWithValue("@Features", product.Features ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@Category", product.Category ?? (object)DBNull.Value);
                        command.Parameters.AddWithValue("@IsActive", product.IsActive);

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

        public bool DeleteProduct(int productId)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_DeleteProduct", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
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

        public Product GetProductById(int productId)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetProductById", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@ProductId", productId);

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapReaderToProduct(reader);
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

        public List<Product> GetAllProducts()
        {
            List<Product> products = new List<Product>();
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetAllProducts", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

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

        public List<Product> GetActiveProducts()
        {
            List<Product> products = new List<Product>();
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetActiveProducts", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

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

        public List<Product> GetProductsByCategory(string category)
        {
            List<Product> products = new List<Product>();
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetProductsByCategory", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@Category", category);

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

        public ProductSubscriptionResult CreateProductSubscription(ProductSubscription subscription)
        {
            if (subscription == null)
            {
                return ProductSubscriptionResult.Failure("Subscription details are required.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ProductSubscription_Create", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@UserId", subscription.UserId);
                        command.Parameters.AddWithValue("@ProductId", subscription.ProductId);
                        command.Parameters.AddWithValue("@CardholderName", subscription.CardholderName ?? string.Empty);
                        command.Parameters.AddWithValue("@CardLast4", subscription.CardLast4 ?? string.Empty);
                        command.Parameters.AddWithValue("@CardBrand", string.IsNullOrWhiteSpace(subscription.CardBrand) ? (object)DBNull.Value : subscription.CardBrand);
                        command.Parameters.AddWithValue("@EncryptedCardNumber", subscription.EncryptedCardNumber ?? string.Empty);
                        command.Parameters.AddWithValue("@EncryptedCardholderName", subscription.EncryptedCardholderName ?? string.Empty);
                        command.Parameters.AddWithValue("@ExpirationMonth", subscription.ExpirationMonth);
                        command.Parameters.AddWithValue("@ExpirationYear", subscription.ExpirationYear);

                        SqlParameter resultCodeParam = command.Parameters.Add("@ResultCode", SqlDbType.Int);
                        resultCodeParam.Direction = ParameterDirection.Output;

                        SqlParameter resultMessageParam = command.Parameters.Add("@ResultMessage", SqlDbType.NVarChar, 255);
                        resultMessageParam.Direction = ParameterDirection.Output;

                        SqlParameter newIdParam = command.Parameters.Add("@NewSubscriptionId", SqlDbType.Int);
                        newIdParam.Direction = ParameterDirection.Output;

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = resultCodeParam.Value == DBNull.Value ? 0 : Convert.ToInt32(resultCodeParam.Value);
                        string resultMessage = resultMessageParam.Value == DBNull.Value ? string.Empty : resultMessageParam.Value.ToString();

                        if (resultCode == 1)
                        {
                            int newId = newIdParam.Value == DBNull.Value ? 0 : Convert.ToInt32(newIdParam.Value);
                            subscription.SubscriptionId = newId;
                            subscription.CreatedDateUtc = DateTime.UtcNow;
                            subscription.IsActive = true;
                            subscription.CancelledDateUtc = null;

                            return ProductSubscriptionResult.Success(subscription, string.IsNullOrWhiteSpace(resultMessage) ? "Success" : resultMessage);
                        }

                        return ProductSubscriptionResult.Failure(string.IsNullOrWhiteSpace(resultMessage) ? "Failed to create subscription." : resultMessage);
                    }
                }
            }
            catch (Exception ex)
            {
                return ProductSubscriptionResult.Failure("An error occurred while creating the subscription.", ex);
            }
        }

        public List<ProductSubscription> GetSubscriptionsByUser(int userId)
        {
            List<ProductSubscription> subscriptions = new List<ProductSubscription>();

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ProductSubscription_GetByUser", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@UserId", userId);

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                subscriptions.Add(MapReaderToProductSubscription(reader));
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {
            }

            return subscriptions;
        }

        public ProductSubscription GetActiveSubscription(int userId, int productId)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ProductSubscription_GetActiveByUserAndProduct", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@UserId", userId);
                        command.Parameters.AddWithValue("@ProductId", productId);

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapReaderToProductSubscription(reader);
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

        public ProductSubscription GetSubscriptionById(int subscriptionId)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ProductSubscription_GetById", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@SubscriptionId", subscriptionId);

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapReaderToProductSubscription(reader);
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

        public ProductSubscriptionResult CancelSubscription(int subscriptionId, int userId)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ProductSubscription_Cancel", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@SubscriptionId", subscriptionId);
                        command.Parameters.AddWithValue("@UserId", userId);

                        SqlParameter resultCodeParam = command.Parameters.Add("@ResultCode", SqlDbType.Int);
                        resultCodeParam.Direction = ParameterDirection.Output;

                        SqlParameter resultMessageParam = command.Parameters.Add("@ResultMessage", SqlDbType.NVarChar, 255);
                        resultMessageParam.Direction = ParameterDirection.Output;

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = resultCodeParam.Value == DBNull.Value ? 0 : Convert.ToInt32(resultCodeParam.Value);
                        string resultMessage = resultMessageParam.Value == DBNull.Value ? string.Empty : resultMessageParam.Value.ToString();

                        if (resultCode == 1)
                        {
                            ProductSubscription updatedSubscription = GetSubscriptionById(subscriptionId);
                            return ProductSubscriptionResult.Success(updatedSubscription, string.IsNullOrWhiteSpace(resultMessage) ? "Success" : resultMessage);
                        }

                        return ProductSubscriptionResult.Failure(string.IsNullOrWhiteSpace(resultMessage) ? "Failed to cancel subscription." : resultMessage);
                    }
                }
            }
            catch (Exception ex)
            {
                return ProductSubscriptionResult.Failure("An error occurred while cancelling the subscription.", ex);
            }
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

        private ProductSubscription MapReaderToProductSubscription(SqlDataReader reader)
        {
            return new ProductSubscription
            {
                SubscriptionId = reader["SubscriptionId"] == DBNull.Value ? 0 : (int)reader["SubscriptionId"],
                UserId = reader["UserId"] == DBNull.Value ? 0 : (int)reader["UserId"],
                ProductId = reader["ProductId"] == DBNull.Value ? 0 : (int)reader["ProductId"],
                ProductName = reader["ProductName"].ToString(),
                ProductPrice = reader["ProductPrice"] == DBNull.Value ? 0 : (decimal)reader["ProductPrice"],
                BillingCycle = reader["BillingCycle"].ToString(),
                CardholderName = reader["CardholderName"].ToString(),
                CardLast4 = reader["CardLast4"].ToString(),
                CardBrand = reader["CardBrand"] == DBNull.Value ? null : reader["CardBrand"].ToString(),
                EncryptedCardNumber = reader["EncryptedCardNumber"] == DBNull.Value ? null : reader["EncryptedCardNumber"].ToString(),
                EncryptedCardholderName = reader["EncryptedCardholderName"] == DBNull.Value ? null : reader["EncryptedCardholderName"].ToString(),
                ExpirationMonth = reader["ExpirationMonth"] == DBNull.Value ? 0 : Convert.ToInt32(reader["ExpirationMonth"]),
                ExpirationYear = reader["ExpirationYear"] == DBNull.Value ? 0 : Convert.ToInt32(reader["ExpirationYear"]),
                CreatedDateUtc = reader["CreatedDateUtc"] == DBNull.Value ? DateTime.MinValue : (DateTime)reader["CreatedDateUtc"],
                IsActive = reader["IsActive"] != DBNull.Value && (bool)reader["IsActive"],
                CancelledDateUtc = reader["CancelledDateUtc"] == DBNull.Value ? (DateTime?)null : (DateTime)reader["CancelledDateUtc"]
            };
        }
    }
}