using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using Hirebot_TFI.Abstractions;

namespace Hirebot_TFI.DAL
{
    /// <summary>
    /// Capa de acceso a datos para operaciones de backup y restore de la base de datos
    /// </summary>
    public class DatabaseBackupDAL
    {
        private readonly string _connectionString;
        private readonly string _masterConnectionString;

        public DatabaseBackupDAL()
        {
            var connString = ConfigurationManager.ConnectionStrings["HirebotDB"];
            if (connString == null)
            {
                throw new ConfigurationErrorsException("No se encontró la cadena de conexión 'HirebotDB' en web.config");
            }

            _connectionString = connString.ConnectionString;

            // Create connection string to master database - replace Database parameter
            // Original: Server=MATIAS\\SQLEXPRESS;Database=Hirebot;Integrated Security=true;
            // Target:   Server=MATIAS\\SQLEXPRESS;Database=master;Integrated Security=true;
            _masterConnectionString = _connectionString.Replace("Database=Hirebot", "Database=master")
                                                       .Replace("Initial Catalog=Hirebot", "Initial Catalog=master");

            // Debug logging
            System.Diagnostics.Debug.WriteLine("=== CONNECTION STRING INFO ===");
            System.Diagnostics.Debug.WriteLine($"Original: {_connectionString}");
            System.Diagnostics.Debug.WriteLine($"Master: {_masterConnectionString}");
        }

        /// <summary>
        /// Crea un backup completo de la base de datos
        /// </summary>
        public DatabaseOperationResult CreateBackup(string backupPath)
        {
            DatabaseOperationResult result = new DatabaseOperationResult();

            try
            {
                // HARDCODED - conexión directa a master
                string connectionString = "Server=MATIAS\\SQLEXPRESS;Database=master;Integrated Security=true;";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("sp_Hirebot_BackupDatabase", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandTimeout = 300;

                        // Input parameter
                        cmd.Parameters.AddWithValue("@BackupPath", backupPath);

                        // Output parameter for detailed error info
                        SqlParameter errorDetailsParam = new SqlParameter("@ErrorDetails", SqlDbType.NVarChar, -1);
                        errorDetailsParam.Direction = ParameterDirection.Output;
                        cmd.Parameters.Add(errorDetailsParam);

                        cmd.ExecuteNonQuery();

                        // Get output parameter value
                        string errorDetails = errorDetailsParam.Value != DBNull.Value
                            ? errorDetailsParam.Value.ToString()
                            : null;

                        if (!string.IsNullOrEmpty(errorDetails) && errorDetails.StartsWith("SUCCESS"))
                        {
                            result.Success = true;
                            result.Message = errorDetails;
                        }
                        else if (!string.IsNullOrEmpty(errorDetails))
                        {
                            result.Success = false;
                            result.Message = errorDetails;
                        }
                        else
                        {
                            result.Success = true;
                            result.Message = "Backup creado exitosamente";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.Message = "Error: " + ex.Message;
                result.Error = ex;
            }

            return result;
        }

        /// <summary>
        /// Restaura la base de datos desde un archivo de backup
        /// </summary>
        public DatabaseOperationResult RestoreDatabase(string backupPath, string dataPath = null, string logPath = null)
        {
            DatabaseOperationResult result = new DatabaseOperationResult();

            try
            {
                // HARDCODED - conexión directa a master
                string connectionString = "Server=MATIAS\\SQLEXPRESS;Database=master;Integrated Security=true;";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("sp_Hirebot_RestoreDatabase", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandTimeout = 600;
                        cmd.Parameters.AddWithValue("@BackupPath", backupPath);

                        if (!string.IsNullOrEmpty(dataPath))
                            cmd.Parameters.AddWithValue("@DataPath", dataPath);
                        else
                            cmd.Parameters.AddWithValue("@DataPath", DBNull.Value);

                        if (!string.IsNullOrEmpty(logPath))
                            cmd.Parameters.AddWithValue("@LogPath", logPath);
                        else
                            cmd.Parameters.AddWithValue("@LogPath", DBNull.Value);

                        cmd.ExecuteNonQuery();

                        result.Success = true;
                        result.Message = "Base de datos restaurada exitosamente";
                    }
                }
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.Message = "Error: " + ex.Message;
                result.Error = ex;
            }

            return result;
        }

        /// <summary>
        /// Lista los archivos de backup disponibles en el directorio especificado
        /// </summary>
        public List<DatabaseBackup> ListBackups(string backupDirectory)
        {
            List<DatabaseBackup> backups = new List<DatabaseBackup>();

            try
            {
                // HARDCODED - conexión directa a master (igual que los otros métodos)
                string connectionString = "Server=MATIAS\\SQLEXPRESS;Database=master;Integrated Security=true;";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("sp_Hirebot_ListBackups", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandTimeout = 60;
                        cmd.Parameters.AddWithValue("@BackupDirectory", backupDirectory);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                DatabaseBackup backup = new DatabaseBackup
                                {
                                    FileName = reader["FileName"].ToString(),
                                    FullPath = reader["FullPath"].ToString()
                                };

                                backups.Add(backup);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Log error but don't throw - return empty list
                System.Diagnostics.Debug.WriteLine("Error listing backups: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("Stack trace: " + ex.StackTrace);
            }

            return backups;
        }

        /// <summary>
        /// Obtiene información sobre un archivo de backup
        /// </summary>
        public DatabaseOperationResult GetBackupInfo(string backupPath)
        {
            DatabaseOperationResult result = new DatabaseOperationResult();

            try
            {
                using (SqlConnection conn = new SqlConnection(_masterConnectionString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_Hirebot_GetBackupInfo", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandTimeout = 60;
                        cmd.Parameters.AddWithValue("@BackupPath", backupPath);

                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                result.Success = true;
                                result.Message = "Información del backup obtenida exitosamente";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.Message = "Error al obtener información del backup: " + ex.Message;
                result.Error = ex;
            }

            return result;
        }
    }
}
