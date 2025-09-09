using System;
using System.Configuration;
using System.Data.SqlClient;

namespace DAL
{
    public static class DatabaseConnectionService
    {
        private static readonly string DefaultConnectionString = "Server=MATIAS\\SQLEXPRESS;Database=Hirebot;Integrated Security=true;";
        private static string _connectionString;

        static DatabaseConnectionService()
        {
            InitializeConnectionString();
        }

        private static void InitializeConnectionString()
        {
            try
            {
                var connectionStringSetting = ConfigurationManager.ConnectionStrings["Hirebot"];
                _connectionString = connectionStringSetting?.ConnectionString ?? DefaultConnectionString;
            }
            catch (Exception)
            {
                _connectionString = DefaultConnectionString;
            }
        }

        public static string GetConnectionString()
        {
            return _connectionString ?? DefaultConnectionString;
        }

        public static SqlConnection GetConnection()
        {
            return new SqlConnection(GetConnectionString());
        }

        public static SqlConnection GetOpenConnection()
        {
            var connection = new SqlConnection(GetConnectionString());
            try
            {
                connection.Open();
                return connection;
            }
            catch
            {
                connection?.Dispose();
                throw;
            }
        }

        public static bool TestConnection()
        {
            try
            {
                using (var connection = GetConnection())
                {
                    connection.Open();
                    return true;
                }
            }
            catch (Exception)
            {
                return false;
            }
        }

        public static void RefreshConnectionString()
        {
            InitializeConnectionString();
        }
    }
}