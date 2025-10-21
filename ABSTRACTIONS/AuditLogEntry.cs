using System;

namespace ABSTRACTIONS
{
    /// <summary>
    /// Represents an audit log entry for tracking changes to chatbot entities
    /// </summary>
    public class AuditLogEntry
    {
        /// <summary>
        /// Unique identifier for the audit log entry
        /// </summary>
        public int AuditId { get; set; }

        /// <summary>
        /// ID of the chatbot that was modified
        /// </summary>
        public int ChatbotId { get; set; }

        /// <summary>
        /// Type of action performed (CREATE, UPDATE, DELETE, ASSIGN, UNASSIGN)
        /// </summary>
        public string ActionType { get; set; }

        /// <summary>
        /// JSON representation of the old values before the change
        /// </summary>
        public string OldValues { get; set; }

        /// <summary>
        /// JSON representation of the new values after the change
        /// </summary>
        public string NewValues { get; set; }

        /// <summary>
        /// Username or identifier of the user who made the change
        /// </summary>
        public string ModifiedBy { get; set; }

        /// <summary>
        /// Date and time when the modification was made
        /// </summary>
        public DateTime ModifiedDate { get; set; }

        /// <summary>
        /// Organization ID relevant to the change (if applicable)
        /// </summary>
        public int? OrganizationId { get; set; }

        /// <summary>
        /// Constructor with default values
        /// </summary>
        public AuditLogEntry()
        {
            AuditId = 0;
            ChatbotId = 0;
            ActionType = string.Empty;
            OldValues = string.Empty;
            NewValues = string.Empty;
            ModifiedBy = string.Empty;
            ModifiedDate = DateTime.UtcNow;
            OrganizationId = null;
        }

        /// <summary>
        /// Constructor for creating audit log entries
        /// </summary>
        /// <param name="chatbotId">ID of the modified chatbot</param>
        /// <param name="actionType">Type of action performed</param>
        /// <param name="oldValues">Previous values</param>
        /// <param name="newValues">New values</param>
        /// <param name="modifiedBy">User who made the change</param>
        /// <param name="organizationId">Related organization ID</param>
        public AuditLogEntry(int chatbotId, string actionType, string oldValues, string newValues, string modifiedBy, int? organizationId = null)
        {
            AuditId = 0;
            ChatbotId = chatbotId;
            ActionType = actionType ?? string.Empty;
            OldValues = oldValues ?? string.Empty;
            NewValues = newValues ?? string.Empty;
            ModifiedBy = modifiedBy ?? string.Empty;
            ModifiedDate = DateTime.UtcNow;
            OrganizationId = organizationId;
        }
    }

    /// <summary>
    /// Enumeration of audit action types for type-safe operations
    /// </summary>
    public static class AuditActionTypes
    {
        public const string Create = "CREATE";
        public const string Update = "UPDATE";
        public const string Delete = "DELETE";
        public const string Assign = "ASSIGN";
        public const string Unassign = "UNASSIGN";

        /// <summary>
        /// Gets all valid action types
        /// </summary>
        /// <returns>Array of valid action type strings</returns>
        public static string[] GetValidActionTypes()
        {
            return new[] { Create, Update, Delete, Assign, Unassign };
        }

        /// <summary>
        /// Validates if an action type is valid
        /// </summary>
        /// <param name="actionType">Action type to validate</param>
        /// <returns>True if valid, false otherwise</returns>
        public static bool IsValidActionType(string actionType)
        {
            if (string.IsNullOrWhiteSpace(actionType))
                return false;

            var validTypes = GetValidActionTypes();
            return Array.IndexOf(validTypes, actionType.ToUpper()) >= 0;
        }
    }
}