using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using ABSTRACTIONS;

namespace DAL
{
    /// <summary>
    /// Data Access Layer for Chatbot management
    /// Handles all database operations using stored procedures exclusively
    /// </summary>
    public class ChatbotDAL
    {
        /// <summary>
        /// Creates a new chatbot in the database
        /// </summary>
        /// <param name="chatbot">Chatbot entity to create</param>
        /// <param name="createdBy">User who created the chatbot</param>
        /// <returns>DatabaseResult with created chatbot data</returns>
        public DatabaseResult<Chatbot> CreateChatbot(Chatbot chatbot, string createdBy = null)
        {
            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                {
                    using (var command = new SqlCommand("sp_CreateChatbot", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Add parameters
                        command.Parameters.AddWithValue("@Name", chatbot.Name ?? string.Empty);
                        command.Parameters.AddWithValue("@Instructions", chatbot.Instructions ?? string.Empty);
                        command.Parameters.AddWithValue("@Color", chatbot.Color ?? "#222222");
                        command.Parameters.AddWithValue("@OrganizationId", (object)chatbot.OrganizationId ?? DBNull.Value);
                        command.Parameters.AddWithValue("@CreatedBy", (object)createdBy ?? DBNull.Value);

                        // Add return value parameter
                        var returnParam = command.Parameters.Add("@ReturnValue", SqlDbType.Int);
                        returnParam.Direction = ParameterDirection.ReturnValue;

                        connection.Open();

                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                var createdChatbot = MapReaderToChatbot(reader);
                                return DatabaseResult<Chatbot>.Success(createdChatbot, "Chatbot created successfully");
                            }
                        }

                        // Check return value for errors
                        int returnValue = (int)returnParam.Value;
                        if (returnValue != 0)
                        {
                            string errorMessage = GetErrorMessageForReturnCode(returnValue);
                            return DatabaseResult<Chatbot>.Failure(returnValue, errorMessage);
                        }

                        return DatabaseResult<Chatbot>.Failure(-999, "Failed to create chatbot - no data returned");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<Chatbot>.Failure($"Database error creating chatbot: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<Chatbot>.Failure($"Error creating chatbot: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets a single chatbot by ID
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot to retrieve</param>
        /// <returns>DatabaseResult with chatbot data</returns>
        public DatabaseResult<Chatbot> GetChatbotById(int chatbotId)
        {
            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                {
                    using (var command = new SqlCommand("sp_GetChatbotById", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@ChatbotId", chatbotId);

                        var returnParam = command.Parameters.Add("@ReturnValue", SqlDbType.Int);
                        returnParam.Direction = ParameterDirection.ReturnValue;

                        connection.Open();

                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                var chatbot = MapReaderToChatbot(reader);
                                return DatabaseResult<Chatbot>.Success(chatbot, "Chatbot retrieved successfully");
                            }
                        }

                        int returnValue = (int)returnParam.Value;
                        if (returnValue != 0)
                        {
                            string errorMessage = GetErrorMessageForReturnCode(returnValue);
                            return DatabaseResult<Chatbot>.Failure(returnValue, errorMessage);
                        }

                        return DatabaseResult<Chatbot>.Failure(-2, "Chatbot not found");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<Chatbot>.Failure($"Database error retrieving chatbot: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<Chatbot>.Failure($"Error retrieving chatbot: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets all chatbots with search criteria and pagination
        /// </summary>
        /// <param name="criteria">Search and pagination criteria</param>
        /// <returns>DatabaseResult with paginated chatbot results</returns>
        public DatabaseResult<PaginatedResult<Chatbot>> GetAllChatbots(ChatbotSearchCriteria criteria)
        {
            try
            {
                criteria.Normalize(); // Ensure valid criteria

                using (var connection = DatabaseConnectionService.GetConnection())
                {
                    using (var command = new SqlCommand("sp_GetAllChatbots", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@PageNumber", criteria.PageNumber);
                        command.Parameters.AddWithValue("@PageSize", criteria.PageSize);
                        command.Parameters.AddWithValue("@SortColumn", criteria.SortColumn);
                        command.Parameters.AddWithValue("@SortDirection", criteria.SortDirection);
                        command.Parameters.AddWithValue("@IncludeInactive", criteria.IncludeInactive);
                        command.Parameters.AddWithValue("@NameFilter", (object)criteria.Name ?? DBNull.Value);
                        command.Parameters.AddWithValue("@OrganizationId", (object)criteria.OrganizationId ?? DBNull.Value);

                        var returnParam = command.Parameters.Add("@ReturnValue", SqlDbType.Int);
                        returnParam.Direction = ParameterDirection.ReturnValue;

                        connection.Open();

                        var result = new PaginatedResult<Chatbot>();

                        using (var reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var chatbot = MapReaderToChatbot(reader);
                                result.Data.Add(chatbot);

                                // Get pagination info from first row
                                if (result.TotalRecords == 0)
                                {
                                    result.TotalRecords = Convert.ToInt32(reader["total_records"]);
                                    result.CurrentPage = Convert.ToInt32(reader["current_page"]);
                                    result.PageSize = Convert.ToInt32(reader["page_size"]);
                                }
                            }
                        }

                        return DatabaseResult<PaginatedResult<Chatbot>>.Success(result, "Chatbots retrieved successfully");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<PaginatedResult<Chatbot>>.Failure($"Database error retrieving chatbots: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<PaginatedResult<Chatbot>>.Failure($"Error retrieving chatbots: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets chatbots filtered by organization
        /// </summary>
        /// <param name="organizationId">Organization ID (null for unassigned chatbots)</param>
        /// <param name="pageNumber">Page number</param>
        /// <param name="pageSize">Items per page</param>
        /// <param name="includeInactive">Include inactive chatbots</param>
        /// <returns>DatabaseResult with paginated chatbot results</returns>
        public DatabaseResult<PaginatedResult<Chatbot>> GetChatbotsByOrganization(int? organizationId, int pageNumber = 1, int pageSize = 10, bool includeInactive = false)
        {
            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                {
                    using (var command = new SqlCommand("sp_GetChatbotsByOrganization", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@OrganizationId", (object)organizationId ?? DBNull.Value);
                        command.Parameters.AddWithValue("@PageNumber", pageNumber);
                        command.Parameters.AddWithValue("@PageSize", pageSize);
                        command.Parameters.AddWithValue("@IncludeInactive", includeInactive);

                        var returnParam = command.Parameters.Add("@ReturnValue", SqlDbType.Int);
                        returnParam.Direction = ParameterDirection.ReturnValue;

                        connection.Open();

                        var result = new PaginatedResult<Chatbot>();

                        using (var reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var chatbot = MapReaderToChatbot(reader);
                                result.Data.Add(chatbot);

                                // Get pagination info from first row
                                if (result.TotalRecords == 0)
                                {
                                    result.TotalRecords = Convert.ToInt32(reader["total_records"]);
                                    result.CurrentPage = Convert.ToInt32(reader["current_page"]);
                                    result.PageSize = Convert.ToInt32(reader["page_size"]);
                                }
                            }
                        }

                        int returnValue = (int)returnParam.Value;
                        if (returnValue != 0)
                        {
                            string errorMessage = GetErrorMessageForReturnCode(returnValue);
                            return DatabaseResult<PaginatedResult<Chatbot>>.Failure(returnValue, errorMessage);
                        }

                        return DatabaseResult<PaginatedResult<Chatbot>>.Success(result, "Organization chatbots retrieved successfully");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<PaginatedResult<Chatbot>>.Failure($"Database error retrieving organization chatbots: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<PaginatedResult<Chatbot>>.Failure($"Error retrieving organization chatbots: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Updates an existing chatbot
        /// </summary>
        /// <param name="chatbot">Chatbot entity with updated data</param>
        /// <param name="modifiedBy">User who modified the chatbot</param>
        /// <returns>DatabaseResult with updated chatbot data</returns>
        public DatabaseResult<Chatbot> UpdateChatbot(Chatbot chatbot, string modifiedBy = null)
        {
            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                {
                    using (var command = new SqlCommand("sp_UpdateChatbot", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@ChatbotId", chatbot.ChatbotId);
                        command.Parameters.AddWithValue("@Name", chatbot.Name ?? string.Empty);
                        command.Parameters.AddWithValue("@Instructions", chatbot.Instructions ?? string.Empty);
                        command.Parameters.AddWithValue("@Color", chatbot.Color ?? "#222222");
                        command.Parameters.AddWithValue("@ModifiedBy", (object)modifiedBy ?? DBNull.Value);

                        var returnParam = command.Parameters.Add("@ReturnValue", SqlDbType.Int);
                        returnParam.Direction = ParameterDirection.ReturnValue;

                        connection.Open();

                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                var updatedChatbot = MapReaderToChatbot(reader);
                                return DatabaseResult<Chatbot>.Success(updatedChatbot, "Chatbot updated successfully");
                            }
                        }

                        int returnValue = (int)returnParam.Value;
                        if (returnValue != 0)
                        {
                            string errorMessage = GetErrorMessageForReturnCode(returnValue);
                            return DatabaseResult<Chatbot>.Failure(returnValue, errorMessage);
                        }

                        return DatabaseResult<Chatbot>.Failure(-999, "Failed to update chatbot - no data returned");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<Chatbot>.Failure($"Database error updating chatbot: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<Chatbot>.Failure($"Error updating chatbot: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Soft deletes a chatbot (sets is_active = 0)
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot to delete</param>
        /// <param name="deletedBy">User who deleted the chatbot</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult DeleteChatbot(int chatbotId, string deletedBy = null)
        {
            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                {
                    using (var command = new SqlCommand("sp_DeleteChatbot", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@ChatbotId", chatbotId);
                        command.Parameters.AddWithValue("@DeletedBy", (object)deletedBy ?? DBNull.Value);

                        var returnParam = command.Parameters.Add("@ReturnValue", SqlDbType.Int);
                        returnParam.Direction = ParameterDirection.ReturnValue;

                        connection.Open();

                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string message = reader["message"]?.ToString() ?? "Chatbot deleted successfully";
                                return DatabaseResult.Success(message);
                            }
                        }

                        int returnValue = (int)returnParam.Value;
                        if (returnValue != 0)
                        {
                            string errorMessage = GetErrorMessageForReturnCode(returnValue);
                            return DatabaseResult.Failure(returnValue, errorMessage);
                        }

                        return DatabaseResult.Success("Chatbot deleted successfully");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error deleting chatbot: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Error deleting chatbot: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Assigns a chatbot to an organization
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot to assign</param>
        /// <param name="organizationId">ID of the organization</param>
        /// <param name="assignedBy">User who performed the assignment</param>
        /// <returns>DatabaseResult with updated chatbot data</returns>
        public DatabaseResult<Chatbot> AssignChatbotToOrganization(int chatbotId, int organizationId, string assignedBy = null)
        {
            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                {
                    using (var command = new SqlCommand("sp_AssignChatbotToOrganization", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@ChatbotId", chatbotId);
                        command.Parameters.AddWithValue("@OrganizationId", organizationId);
                        command.Parameters.AddWithValue("@AssignedBy", (object)assignedBy ?? DBNull.Value);

                        var returnParam = command.Parameters.Add("@ReturnValue", SqlDbType.Int);
                        returnParam.Direction = ParameterDirection.ReturnValue;

                        connection.Open();

                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                var assignedChatbot = MapReaderToChatbot(reader);
                                string message = reader["message"]?.ToString() ?? "Chatbot assigned successfully";
                                return DatabaseResult<Chatbot>.Success(assignedChatbot, message);
                            }
                        }

                        int returnValue = (int)returnParam.Value;
                        if (returnValue != 0)
                        {
                            string errorMessage = GetErrorMessageForReturnCode(returnValue);
                            return DatabaseResult<Chatbot>.Failure(returnValue, errorMessage);
                        }

                        return DatabaseResult<Chatbot>.Failure(-999, "Failed to assign chatbot - no data returned");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<Chatbot>.Failure($"Database error assigning chatbot: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<Chatbot>.Failure($"Error assigning chatbot: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Unassigns a chatbot from its organization
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot to unassign</param>
        /// <param name="unassignedBy">User who performed the unassignment</param>
        /// <returns>DatabaseResult with updated chatbot data</returns>
        public DatabaseResult<Chatbot> UnassignChatbotFromOrganization(int chatbotId, string unassignedBy = null)
        {
            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                {
                    using (var command = new SqlCommand("sp_UnassignChatbotFromOrganization", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@ChatbotId", chatbotId);
                        command.Parameters.AddWithValue("@UnassignedBy", (object)unassignedBy ?? DBNull.Value);

                        var returnParam = command.Parameters.Add("@ReturnValue", SqlDbType.Int);
                        returnParam.Direction = ParameterDirection.ReturnValue;

                        connection.Open();

                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                var unassignedChatbot = MapReaderToChatbot(reader);
                                string message = reader["message"]?.ToString() ?? "Chatbot unassigned successfully";
                                return DatabaseResult<Chatbot>.Success(unassignedChatbot, message);
                            }
                        }

                        int returnValue = (int)returnParam.Value;
                        if (returnValue != 0)
                        {
                            string errorMessage = GetErrorMessageForReturnCode(returnValue);
                            return DatabaseResult<Chatbot>.Failure(returnValue, errorMessage);
                        }

                        return DatabaseResult<Chatbot>.Failure(-999, "Failed to unassign chatbot - no data returned");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<Chatbot>.Failure($"Database error unassigning chatbot: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<Chatbot>.Failure($"Error unassigning chatbot: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets audit log for a specific chatbot
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot</param>
        /// <param name="pageNumber">Page number</param>
        /// <param name="pageSize">Items per page</param>
        /// <returns>DatabaseResult with paginated audit log entries</returns>
        public DatabaseResult<PaginatedResult<AuditLogEntry>> GetChatbotAuditLog(int chatbotId, int pageNumber = 1, int pageSize = 20)
        {
            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                {
                    using (var command = new SqlCommand("sp_GetChatbotAuditLog", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@ChatbotId", chatbotId);
                        command.Parameters.AddWithValue("@PageNumber", pageNumber);
                        command.Parameters.AddWithValue("@PageSize", pageSize);

                        var returnParam = command.Parameters.Add("@ReturnValue", SqlDbType.Int);
                        returnParam.Direction = ParameterDirection.ReturnValue;

                        connection.Open();

                        var result = new PaginatedResult<AuditLogEntry>();

                        using (var reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var auditEntry = new AuditLogEntry
                                {
                                    AuditId = Convert.ToInt32(reader["audit_id"]),
                                    ChatbotId = Convert.ToInt32(reader["chatbot_id"]),
                                    ActionType = reader["action_type"]?.ToString() ?? string.Empty,
                                    OldValues = reader["old_values"]?.ToString() ?? string.Empty,
                                    NewValues = reader["new_values"]?.ToString() ?? string.Empty,
                                    ModifiedBy = reader["modified_by"]?.ToString() ?? string.Empty,
                                    ModifiedDate = Convert.ToDateTime(reader["modified_date"]),
                                    OrganizationId = reader["organization_id"] == DBNull.Value ? null : (int?)Convert.ToInt32(reader["organization_id"])
                                };

                                result.Data.Add(auditEntry);

                                // Get pagination info from first row
                                if (result.TotalRecords == 0)
                                {
                                    result.TotalRecords = Convert.ToInt32(reader["total_records"]);
                                    result.CurrentPage = Convert.ToInt32(reader["current_page"]);
                                    result.PageSize = Convert.ToInt32(reader["page_size"]);
                                }
                            }
                        }

                        return DatabaseResult<PaginatedResult<AuditLogEntry>>.Success(result, "Audit log retrieved successfully");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<PaginatedResult<AuditLogEntry>>.Failure($"Database error retrieving audit log: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<PaginatedResult<AuditLogEntry>>.Failure($"Error retrieving audit log: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Maps SqlDataReader to Chatbot object
        /// </summary>
        /// <param name="reader">SqlDataReader with chatbot data</param>
        /// <returns>Chatbot object</returns>
        private Chatbot MapReaderToChatbot(SqlDataReader reader)
        {
            return new Chatbot
            {
                ChatbotId = Convert.ToInt32(reader["chatbot_id"]),
                OrganizationId = reader["organization_id"] == DBNull.Value ? null : (int?)Convert.ToInt32(reader["organization_id"]),
                OrganizationName = reader["organization_name"]?.ToString() ?? string.Empty,
                Name = reader["name"]?.ToString() ?? string.Empty,
                Instructions = reader["instructions"]?.ToString() ?? string.Empty,
                Color = reader["color"]?.ToString() ?? "#222222",
                CreatedDate = Convert.ToDateTime(reader["created_date"]),
                UpdatedDate = Convert.ToDateTime(reader["updated_date"]),
                IsActive = Convert.ToBoolean(reader["is_active"])
            };
        }

        /// <summary>
        /// Gets user-friendly error message for stored procedure return codes
        /// </summary>
        /// <param name="returnCode">Return code from stored procedure</param>
        /// <returns>User-friendly error message</returns>
        private string GetErrorMessageForReturnCode(int returnCode)
        {
            switch (returnCode)
            {
                case -1: return "Valid chatbot ID or name is required";
                case -2: return "Chatbot name cannot exceed 255 characters";
                case -3: return "Chatbot instructions are required";
                case -4: return "Chatbot color is required";
                case -5: return "Color must be a valid hex code format (#RRGGBB)";
                case -6: return "Organization not found or inactive";
                case -7: return "A chatbot with this name already exists";
                case -8: return "Chatbot not found or inactive";
                case -99: return "Database operation failed";
                default: return $"Operation failed with code: {returnCode}";
            }
        }
    }
}