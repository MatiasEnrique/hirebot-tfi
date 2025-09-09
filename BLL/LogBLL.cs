using System;
using System.Collections.Generic;
using ABSTRACTIONS;
using DAL;

namespace BLL
{
    public class LogBLL
    {
        private readonly LogDAL logDAL;

        public LogBLL()
        {
            logDAL = new LogDAL();
        }

        public List<Log> GetUserLogs(int userId)
        {
            return logDAL.GetUserLogs(userId);
        }

        public List<Log> GetLogsByType(string logType)
        {
            return logDAL.GetLogsByType(logType);
        }

        public List<Log> GetAllLogs()
        {
            return logDAL.GetAllLogs();
        }

        public List<Log> GetRecentLogs(int days = 7)
        {
            return logDAL.GetRecentLogs(days);
        }

        public List<Log> GetLogsByDateRange(DateTime startDate, DateTime endDate)
        {
            return logDAL.GetLogsByDateRange(startDate, endDate);
        }

        public List<Log> GetTodaysLogs()
        {
            return logDAL.GetTodaysLogs();
        }

        public ABSTRACTIONS.PaginatedResult<Log> GetAllLogsPaginated(int pageNumber, int pageSize)
        {
            return logDAL.GetAllLogsPaginated(pageNumber, pageSize);
        }

        public ABSTRACTIONS.PaginatedResult<Log> GetFilteredLogsPaginated(LogFilterCriteria filters, int pageNumber, int pageSize)
        {
            return logDAL.GetFilteredLogsPaginated(filters, pageNumber, pageSize);
        }

        public bool CreateLog(Log log)
        {
            if (log == null) return false;
            
            // Business logic validation
            if (string.IsNullOrWhiteSpace(log.LogType) || string.IsNullOrWhiteSpace(log.Description))
                return false;

            // Ensure CreatedAt is set
            if (log.CreatedAt == default(DateTime))
                log.CreatedAt = DateTime.Now;

            return logDAL.CreateLog(log);
        }
    }
}