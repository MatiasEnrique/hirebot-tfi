using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using ABSTRACTIONS;

namespace DAL
{
    public class LogDAL
    {
        public List<Log> GetUserLogs(int userId)
        {
            try
            {
                if (userId <= 0) return new List<Log>();

                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetLogsByUser", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@UserId", userId);

                        connection.Open();
                        return ReadLogsFromReader(command.ExecuteReader());
                    }
                }
            }
            catch (Exception)
            {
                return new List<Log>();
            }
        }

        public List<Log> GetLogsByType(string logType)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(logType)) return new List<Log>();

                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetLogsByType", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@LogType", logType.Trim());

                        connection.Open();
                        return ReadLogsFromReader(command.ExecuteReader());
                    }
                }
            }
            catch (Exception)
            {
                return new List<Log>();
            }
        }

        public List<Log> GetAllLogs()
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetAllLogs", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        connection.Open();
                        return ReadLogsFromReader(command.ExecuteReader());
                    }
                }
            }
            catch (Exception)
            {
                return new List<Log>();
            }
        }

        public List<Log> GetRecentLogs(int days = 7)
        {
            try
            {
                if (days <= 0) days = 7;

                DateTime startDate = DateTime.Today.AddDays(-days);
                DateTime endDate = DateTime.Now;
                
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetLogsByDateRange", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@StartDate", startDate);
                        command.Parameters.AddWithValue("@EndDate", endDate);

                        connection.Open();
                        return ReadLogsFromReader(command.ExecuteReader());
                    }
                }
            }
            catch (Exception)
            {
                return new List<Log>();
            }
        }

        public List<Log> GetLogsByDateRange(DateTime startDate, DateTime endDate)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetLogsByDateRange", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@StartDate", startDate);
                        command.Parameters.AddWithValue("@EndDate", endDate);

                        connection.Open();
                        return ReadLogsFromReader(command.ExecuteReader());
                    }
                }
            }
            catch (Exception)
            {
                return new List<Log>();
            }
        }

        public List<Log> GetTodaysLogs()
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetTodaysLogs", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        connection.Open();
                        return ReadLogsFromReader(command.ExecuteReader());
                    }
                }
            }
            catch (Exception)
            {
                return new List<Log>();
            }
        }

        public ABSTRACTIONS.PaginatedResult<Log> GetAllLogsPaginated(int pageNumber, int pageSize)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetAllLogsPaginated", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@PageNumber", pageNumber);
                        command.Parameters.AddWithValue("@PageSize", pageSize);

                        connection.Open();
                        
                        var result = new ABSTRACTIONS.PaginatedResult<Log>();
                        using (var reader = command.ExecuteReader())
                        {
                            // First result set: data
                            result.Data = ReadLogsFromReader(reader);
                            
                            // Second result set: total count
                            if (reader.NextResult() && reader.Read())
                            {
                                result.TotalRecords = Convert.ToInt32(reader["TotalCount"]);
                            }
                        }
                        
                        result.CurrentPage = pageNumber;
                        result.PageSize = pageSize;
                        return result;
                    }
                }
            }
            catch (Exception)
            {
                return new ABSTRACTIONS.PaginatedResult<Log>
                {
                    Data = new List<Log>(),
                    TotalRecords = 0,
                    CurrentPage = pageNumber,
                    PageSize = pageSize
                };
            }
        }

        public ABSTRACTIONS.PaginatedResult<Log> GetFilteredLogsPaginated(LogFilterCriteria filters, int pageNumber, int pageSize)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetFilteredLogsPaginated", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@PageNumber", pageNumber);
                        command.Parameters.AddWithValue("@PageSize", pageSize);
                        command.Parameters.AddWithValue("@LogType", string.IsNullOrEmpty(filters.LogType) ? (object)DBNull.Value : filters.LogType);
                        command.Parameters.AddWithValue("@UserId", filters.UserId.HasValue ? (object)filters.UserId.Value : DBNull.Value);
                        command.Parameters.AddWithValue("@Description", string.IsNullOrEmpty(filters.Description) ? (object)DBNull.Value : filters.Description);
                        command.Parameters.AddWithValue("@StartDate", filters.StartDate.HasValue ? (object)filters.StartDate.Value : DBNull.Value);
                        command.Parameters.AddWithValue("@EndDate", filters.EndDate.HasValue ? (object)filters.EndDate.Value : DBNull.Value);

                        connection.Open();
                        
                        var result = new ABSTRACTIONS.PaginatedResult<Log>();
                        using (var reader = command.ExecuteReader())
                        {
                            // First result set: data
                            result.Data = ReadLogsFromReader(reader);
                            
                            // Second result set: total count
                            if (reader.NextResult() && reader.Read())
                            {
                                result.TotalRecords = Convert.ToInt32(reader["TotalCount"]);
                            }
                        }
                        
                        result.CurrentPage = pageNumber;
                        result.PageSize = pageSize;
                        return result;
                    }
                }
            }
            catch (Exception)
            {
                return new ABSTRACTIONS.PaginatedResult<Log>
                {
                    Data = new List<Log>(),
                    TotalRecords = 0,
                    CurrentPage = pageNumber,
                    PageSize = pageSize
                };
            }
        }

        public bool CreateLog(Log log)
        {
            try
            {
                if (log == null) return false;
                if (string.IsNullOrWhiteSpace(log.LogType) || string.IsNullOrWhiteSpace(log.Description))
                    return false;

                if (log.LogType.Length > 20 || log.Description.Length > 50)
                    return false;

                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_CreateLog", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        command.Parameters.AddWithValue("@LogType", log.LogType.Trim());
                        command.Parameters.AddWithValue("@UserId", log.UserId.HasValue ? (object)log.UserId.Value : DBNull.Value);
                        command.Parameters.AddWithValue("@Description", log.Description.Trim());
                        command.Parameters.AddWithValue("@CreatedAt", log.CreatedAt);

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

        private List<Log> ReadLogsFromReader(SqlDataReader reader)
        {
            var logs = new List<Log>();
            try
            {
                while (reader.Read())
                {
                    logs.Add(new Log
                    {
                        Id = Convert.ToInt32(reader["Id"]),
                        LogType = reader["LogType"].ToString(),
                        UserId = reader["UserId"] == DBNull.Value ? null : (int?)Convert.ToInt32(reader["UserId"]),
                        Description = reader["Description"].ToString(),
                        CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                    });
                }
            }
            catch (Exception)
            {
                // Return partial results if error occurs
            }
            return logs;
        }
    }

}