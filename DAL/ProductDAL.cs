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