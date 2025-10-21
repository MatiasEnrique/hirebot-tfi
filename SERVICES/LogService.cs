using System;

namespace SERVICES
{
    /// <summary>
    /// Utility service that defines log types and provides logging helper methods
    /// This service provides constants and utilities but does not access the database directly
    /// Actual database logging should be done through BLL->DAL layers
    /// </summary>
    public static class LogService
    {
        /// <summary>
        /// Defines standard log types for consistent logging across the application
        /// </summary>
        public static class LogTypes
        {
            public const string LOGIN = "LOGIN";
            public const string LOGOUT = "LOGOUT";
            public const string REGISTER = "REGISTER";
            public const string ERROR = "ERROR";
            public const string ACCESS = "ACCESS";
            public const string UPDATE = "UPDATE";
            public const string DELETE = "DELETE";
            public const string CREATE = "CREATE";
            public const string SYSTEM = "SYSTEM";
        }

        /// <summary>
        /// Validates log data for consistency
        /// </summary>
        /// <param name="logType">Type of log entry</param>
        /// <param name="description">Description of the event</param>
        /// <returns>True if valid, false otherwise</returns>
        public static bool IsValidLogData(string logType, string description)
        {
            if (string.IsNullOrWhiteSpace(logType) || string.IsNullOrWhiteSpace(description))
                return false;

            if (logType.Length > 20 || description.Length > 50)
                return false;

            return true;
        }

        /// <summary>
        /// Formats a log description for consistent formatting
        /// </summary>
        /// <param name="description">Raw description</param>
        /// <returns>Formatted description</returns>
        public static string FormatLogDescription(string description)
        {
            if (string.IsNullOrWhiteSpace(description))
                return string.Empty;

            return description.Trim();
        }

        /// <summary>
        /// Formats a log type for consistency
        /// </summary>
        /// <param name="logType">Raw log type</param>
        /// <returns>Formatted log type</returns>
        public static string FormatLogType(string logType)
        {
            if (string.IsNullOrWhiteSpace(logType))
                return string.Empty;

            return logType.Trim().ToUpper();
        }
    }
}