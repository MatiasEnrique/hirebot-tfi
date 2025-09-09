using System;
using System.Text.RegularExpressions;
using ABSTRACTIONS;
using DAL;

namespace BLL
{
    /// <summary>
    /// Business Logic Layer for Chatbot management
    /// Implements business rules, validation, and orchestration logic
    /// Follows the strict architectural flow: UI -> Security -> BLL -> DAL
    /// </summary>
    public class ChatbotBLL
    {
        private readonly ChatbotDAL _chatbotDAL;

        /// <summary>
        /// Constructor
        /// </summary>
        public ChatbotBLL()
        {
            _chatbotDAL = new ChatbotDAL();
        }

        /// <summary>
        /// Creates a new chatbot with comprehensive business validation
        /// </summary>
        /// <param name="chatbot">Chatbot entity to create</param>
        /// <param name="createdBy">User who created the chatbot</param>
        /// <returns>DatabaseResult with created chatbot data</returns>
        public DatabaseResult<Chatbot> CreateChatbot(Chatbot chatbot, string createdBy = null)
        {
            try
            {
                // Input validation
                var validationResult = ValidateChatbotForCreation(chatbot);
                if (!validationResult.IsSuccessful)
                {
                    return DatabaseResult<Chatbot>.Failure(validationResult.ResultCode, validationResult.ErrorMessage);
                }

                // Business rule: Normalize and sanitize input
                NormalizeChatbotData(chatbot);

                // Business rule: Set creation timestamp
                chatbot.CreatedDate = DateTime.UtcNow;
                chatbot.UpdatedDate = DateTime.UtcNow;
                chatbot.IsActive = true;

                // Call DAL layer
                var result = _chatbotDAL.CreateChatbot(chatbot, createdBy);

                if (result.IsSuccessful)
                {
                    // Business rule: Log successful creation for audit purposes
                    LogBusinessEvent($"Chatbot '{chatbot.Name}' created successfully by {createdBy ?? "system"}", 
                                   result.Data?.ChatbotId ?? 0);
                }

                return result;
            }
            catch (Exception ex)
            {
                return DatabaseResult<Chatbot>.Failure($"Business logic error creating chatbot: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets a single chatbot by ID with business logic validation
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot to retrieve</param>
        /// <returns>DatabaseResult with chatbot data</returns>
        public DatabaseResult<Chatbot> GetChatbotById(int chatbotId)
        {
            try
            {
                // Business validation
                if (chatbotId <= 0)
                {
                    return DatabaseResult<Chatbot>.Failure(-1, "Valid chatbot ID is required");
                }

                // Call DAL layer
                var result = _chatbotDAL.GetChatbotById(chatbotId);

                if (result.IsSuccessful && result.Data != null)
                {
                    // Business rule: Apply any post-retrieval processing
                    ApplyBusinessRulesToChatbot(result.Data);
                }

                return result;
            }
            catch (Exception ex)
            {
                return DatabaseResult<Chatbot>.Failure($"Business logic error retrieving chatbot: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets all chatbots with business logic filtering and validation
        /// </summary>
        /// <param name="criteria">Search and pagination criteria</param>
        /// <returns>DatabaseResult with paginated chatbot results</returns>
        public DatabaseResult<PaginatedResult<Chatbot>> GetAllChatbots(ChatbotSearchCriteria criteria)
        {
            try
            {
                // Business validation
                if (criteria == null)
                {
                    criteria = new ChatbotSearchCriteria();
                }

                // Business rule: Normalize and validate criteria
                ValidateAndNormalizeCriteria(criteria);

                // Call DAL layer
                var result = _chatbotDAL.GetAllChatbots(criteria);

                if (result.IsSuccessful && result.Data?.Data != null)
                {
                    // Business rule: Apply post-processing to each chatbot
                    foreach (var chatbot in result.Data.Data)
                    {
                        ApplyBusinessRulesToChatbot(chatbot);
                    }
                }

                return result;
            }
            catch (Exception ex)
            {
                return DatabaseResult<PaginatedResult<Chatbot>>.Failure($"Business logic error retrieving chatbots: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets chatbots filtered by organization with business logic validation
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
                // Business validation
                if (pageNumber <= 0) pageNumber = 1;
                if (pageSize <= 0) pageSize = 10;
                if (pageSize > 100) pageSize = 100; // Business rule: Max page size limit

                // Call DAL layer
                var result = _chatbotDAL.GetChatbotsByOrganization(organizationId, pageNumber, pageSize, includeInactive);

                if (result.IsSuccessful && result.Data?.Data != null)
                {
                    // Business rule: Apply post-processing to each chatbot
                    foreach (var chatbot in result.Data.Data)
                    {
                        ApplyBusinessRulesToChatbot(chatbot);
                    }
                }

                return result;
            }
            catch (Exception ex)
            {
                return DatabaseResult<PaginatedResult<Chatbot>>.Failure($"Business logic error retrieving organization chatbots: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Updates an existing chatbot with comprehensive business validation
        /// </summary>
        /// <param name="chatbot">Chatbot entity with updated data</param>
        /// <param name="modifiedBy">User who modified the chatbot</param>
        /// <returns>DatabaseResult with updated chatbot data</returns>
        public DatabaseResult<Chatbot> UpdateChatbot(Chatbot chatbot, string modifiedBy = null)
        {
            try
            {
                // Input validation
                var validationResult = ValidateChatbotForUpdate(chatbot);
                if (!validationResult.IsSuccessful)
                {
                    return DatabaseResult<Chatbot>.Failure(validationResult.ResultCode, validationResult.ErrorMessage);
                }

                // Business rule: Normalize and sanitize input
                NormalizeChatbotData(chatbot);

                // Business rule: Set update timestamp
                chatbot.UpdatedDate = DateTime.UtcNow;

                // Call DAL layer
                var result = _chatbotDAL.UpdateChatbot(chatbot, modifiedBy);

                if (result.IsSuccessful)
                {
                    // Business rule: Log successful update for audit purposes
                    LogBusinessEvent($"Chatbot '{chatbot.Name}' updated successfully by {modifiedBy ?? "system"}", 
                                   chatbot.ChatbotId);
                }

                return result;
            }
            catch (Exception ex)
            {
                return DatabaseResult<Chatbot>.Failure($"Business logic error updating chatbot: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Soft deletes a chatbot with business rule validation
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot to delete</param>
        /// <param name="deletedBy">User who deleted the chatbot</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult DeleteChatbot(int chatbotId, string deletedBy = null)
        {
            try
            {
                // Business validation
                if (chatbotId <= 0)
                {
                    return DatabaseResult.Failure(-1, "Valid chatbot ID is required");
                }

                // Business rule: Check if chatbot exists before deletion
                var existingChatbot = _chatbotDAL.GetChatbotById(chatbotId);
                if (!existingChatbot.IsSuccessful || existingChatbot.Data == null)
                {
                    return DatabaseResult.Failure(-2, "Chatbot not found or already inactive");
                }

                // Business rule: Validate deletion constraints
                var deletionValidation = ValidateChatbotForDeletion(existingChatbot.Data);
                if (!deletionValidation.IsSuccessful)
                {
                    return deletionValidation;
                }

                // Call DAL layer
                var result = _chatbotDAL.DeleteChatbot(chatbotId, deletedBy);

                if (result.IsSuccessful)
                {
                    // Business rule: Log successful deletion for audit purposes
                    LogBusinessEvent($"Chatbot '{existingChatbot.Data.Name}' deleted successfully by {deletedBy ?? "system"}", 
                                   chatbotId);
                }

                return result;
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Business logic error deleting chatbot: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Assigns a chatbot to an organization with comprehensive business validation
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot to assign</param>
        /// <param name="organizationId">ID of the organization</param>
        /// <param name="assignedBy">User who performed the assignment</param>
        /// <returns>DatabaseResult with updated chatbot data</returns>
        public DatabaseResult<Chatbot> AssignChatbotToOrganization(int chatbotId, int organizationId, string assignedBy = null)
        {
            try
            {
                // Business validation
                if (chatbotId <= 0)
                {
                    return DatabaseResult<Chatbot>.Failure(-1, "Valid chatbot ID is required");
                }

                if (organizationId <= 0)
                {
                    return DatabaseResult<Chatbot>.Failure(-2, "Valid organization ID is required");
                }

                // Business rule: Validate assignment constraints
                var assignmentValidation = ValidateChatbotAssignment(chatbotId, organizationId);
                if (!assignmentValidation.IsSuccessful)
                {
                    return DatabaseResult<Chatbot>.Failure(assignmentValidation.ResultCode, assignmentValidation.ErrorMessage);
                }

                // Call DAL layer
                var result = _chatbotDAL.AssignChatbotToOrganization(chatbotId, organizationId, assignedBy);

                if (result.IsSuccessful)
                {
                    // Business rule: Log successful assignment for audit purposes
                    LogBusinessEvent($"Chatbot assigned to organization {organizationId} by {assignedBy ?? "system"}", 
                                   chatbotId);
                }

                return result;
            }
            catch (Exception ex)
            {
                return DatabaseResult<Chatbot>.Failure($"Business logic error assigning chatbot: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Unassigns a chatbot from its organization with business validation
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot to unassign</param>
        /// <param name="unassignedBy">User who performed the unassignment</param>
        /// <returns>DatabaseResult with updated chatbot data</returns>
        public DatabaseResult<Chatbot> UnassignChatbotFromOrganization(int chatbotId, string unassignedBy = null)
        {
            try
            {
                // Business validation
                if (chatbotId <= 0)
                {
                    return DatabaseResult<Chatbot>.Failure(-1, "Valid chatbot ID is required");
                }

                // Business rule: Validate unassignment constraints
                var unassignmentValidation = ValidateChatbotUnassignment(chatbotId);
                if (!unassignmentValidation.IsSuccessful)
                {
                    return DatabaseResult<Chatbot>.Failure(unassignmentValidation.ResultCode, unassignmentValidation.ErrorMessage);
                }

                // Call DAL layer
                var result = _chatbotDAL.UnassignChatbotFromOrganization(chatbotId, unassignedBy);

                if (result.IsSuccessful)
                {
                    // Business rule: Log successful unassignment for audit purposes
                    LogBusinessEvent($"Chatbot unassigned from organization by {unassignedBy ?? "system"}", 
                                   chatbotId);
                }

                return result;
            }
            catch (Exception ex)
            {
                return DatabaseResult<Chatbot>.Failure($"Business logic error unassigning chatbot: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets audit log for a specific chatbot with business logic validation
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot</param>
        /// <param name="pageNumber">Page number</param>
        /// <param name="pageSize">Items per page</param>
        /// <returns>DatabaseResult with paginated audit log entries</returns>
        public DatabaseResult<PaginatedResult<AuditLogEntry>> GetChatbotAuditLog(int chatbotId, int pageNumber = 1, int pageSize = 20)
        {
            try
            {
                // Business validation
                if (chatbotId <= 0)
                {
                    return DatabaseResult<PaginatedResult<AuditLogEntry>>.Failure(-1, "Valid chatbot ID is required");
                }

                if (pageNumber <= 0) pageNumber = 1;
                if (pageSize <= 0) pageSize = 20;
                if (pageSize > 100) pageSize = 100; // Business rule: Max page size limit

                // Call DAL layer
                var result = _chatbotDAL.GetChatbotAuditLog(chatbotId, pageNumber, pageSize);

                return result;
            }
            catch (Exception ex)
            {
                return DatabaseResult<PaginatedResult<AuditLogEntry>>.Failure($"Business logic error retrieving audit log: {ex.Message}", ex);
            }
        }

        #region Private Business Logic Methods

        /// <summary>
        /// Validates chatbot data for creation
        /// </summary>
        /// <param name="chatbot">Chatbot to validate</param>
        /// <returns>DatabaseResult indicating validation success or failure</returns>
        private DatabaseResult ValidateChatbotForCreation(Chatbot chatbot)
        {
            if (chatbot == null)
                return DatabaseResult.Failure(-1, "Chatbot data is required");

            // Validate name
            if (string.IsNullOrWhiteSpace(chatbot.Name))
                return DatabaseResult.Failure(-2, "Chatbot name is required");

            if (chatbot.Name.Trim().Length > 255)
                return DatabaseResult.Failure(-3, "Chatbot name cannot exceed 255 characters");

            // Validate instructions
            if (string.IsNullOrWhiteSpace(chatbot.Instructions))
                return DatabaseResult.Failure(-4, "Chatbot instructions are required");

            // Business rule: Instructions should be meaningful (minimum length)
            if (chatbot.Instructions.Trim().Length < 10)
                return DatabaseResult.Failure(-5, "Chatbot instructions must be at least 10 characters long");

            // Validate color
            if (string.IsNullOrWhiteSpace(chatbot.Color))
                return DatabaseResult.Failure(-6, "Chatbot color is required");

            if (!IsValidHexColor(chatbot.Color))
                return DatabaseResult.Failure(-7, "Color must be a valid hex code format (#RRGGBB)");

            return DatabaseResult.Success("Chatbot validation passed");
        }

        /// <summary>
        /// Validates chatbot data for update
        /// </summary>
        /// <param name="chatbot">Chatbot to validate</param>
        /// <returns>DatabaseResult indicating validation success or failure</returns>
        private DatabaseResult ValidateChatbotForUpdate(Chatbot chatbot)
        {
            if (chatbot == null)
                return DatabaseResult.Failure(-1, "Chatbot data is required");

            if (chatbot.ChatbotId <= 0)
                return DatabaseResult.Failure(-2, "Valid chatbot ID is required");

            // Use same validation rules as creation (except for required chatbot ID)
            return ValidateChatbotForCreation(chatbot);
        }

        /// <summary>
        /// Validates constraints for chatbot deletion
        /// </summary>
        /// <param name="chatbot">Chatbot to validate for deletion</param>
        /// <returns>DatabaseResult indicating validation success or failure</returns>
        private DatabaseResult ValidateChatbotForDeletion(Chatbot chatbot)
        {
            if (chatbot == null)
                return DatabaseResult.Failure(-1, "Chatbot not found");

            if (!chatbot.IsActive)
                return DatabaseResult.Failure(-2, "Chatbot is already inactive");

            // Business rule: Add any additional deletion constraints here
            // For example, check if chatbot is currently in use

            return DatabaseResult.Success("Chatbot deletion validation passed");
        }

        /// <summary>
        /// Validates chatbot assignment to organization
        /// </summary>
        /// <param name="chatbotId">Chatbot ID</param>
        /// <param name="organizationId">Organization ID</param>
        /// <returns>DatabaseResult indicating validation success or failure</returns>
        private DatabaseResult ValidateChatbotAssignment(int chatbotId, int organizationId)
        {
            // Business rule: Check if chatbot exists and is active
            var chatbotResult = _chatbotDAL.GetChatbotById(chatbotId);
            if (!chatbotResult.IsSuccessful || chatbotResult.Data == null)
                return DatabaseResult.Failure(-1, "Chatbot not found or inactive");

            if (!chatbotResult.Data.IsActive)
                return DatabaseResult.Failure(-2, "Cannot assign inactive chatbot");

            // Business rule: Check if already assigned to the same organization
            if (chatbotResult.Data.OrganizationId == organizationId)
                return DatabaseResult.Failure(-3, "Chatbot is already assigned to this organization");

            return DatabaseResult.Success("Chatbot assignment validation passed");
        }

        /// <summary>
        /// Validates chatbot unassignment from organization
        /// </summary>
        /// <param name="chatbotId">Chatbot ID</param>
        /// <returns>DatabaseResult indicating validation success or failure</returns>
        private DatabaseResult ValidateChatbotUnassignment(int chatbotId)
        {
            // Business rule: Check if chatbot exists and is active
            var chatbotResult = _chatbotDAL.GetChatbotById(chatbotId);
            if (!chatbotResult.IsSuccessful || chatbotResult.Data == null)
                return DatabaseResult.Failure(-1, "Chatbot not found or inactive");

            if (!chatbotResult.Data.IsActive)
                return DatabaseResult.Failure(-2, "Cannot unassign inactive chatbot");

            // Business rule: Check if chatbot is currently assigned
            if (!chatbotResult.Data.OrganizationId.HasValue)
                return DatabaseResult.Failure(-3, "Chatbot is not currently assigned to any organization");

            return DatabaseResult.Success("Chatbot unassignment validation passed");
        }

        /// <summary>
        /// Validates and normalizes search criteria
        /// </summary>
        /// <param name="criteria">Search criteria to validate</param>
        private void ValidateAndNormalizeCriteria(ChatbotSearchCriteria criteria)
        {
            criteria.Normalize();

            // Business rule: Additional criteria validation
            if (criteria.CreatedDateFrom.HasValue && criteria.CreatedDateFrom > DateTime.UtcNow)
                criteria.CreatedDateFrom = DateTime.UtcNow;

            if (criteria.CreatedDateTo.HasValue && criteria.CreatedDateTo > DateTime.UtcNow)
                criteria.CreatedDateTo = DateTime.UtcNow;
        }

        /// <summary>
        /// Normalizes and sanitizes chatbot data according to business rules
        /// </summary>
        /// <param name="chatbot">Chatbot to normalize</param>
        private void NormalizeChatbotData(Chatbot chatbot)
        {
            if (chatbot == null) return;

            // Business rule: Trim and normalize strings
            chatbot.Name = chatbot.Name?.Trim() ?? string.Empty;
            chatbot.Instructions = chatbot.Instructions?.Trim() ?? string.Empty;
            chatbot.Color = chatbot.Color?.Trim()?.ToUpper() ?? "#222222";

            // Business rule: Ensure color has proper format
            if (!chatbot.Color.StartsWith("#"))
                chatbot.Color = "#" + chatbot.Color;

            // Business rule: Sanitize instructions (remove potentially harmful content)
            chatbot.Instructions = SanitizeInstructions(chatbot.Instructions);
        }

        /// <summary>
        /// Applies business rules to a chatbot after retrieval
        /// </summary>
        /// <param name="chatbot">Chatbot to process</param>
        private void ApplyBusinessRulesToChatbot(Chatbot chatbot)
        {
            if (chatbot == null) return;

            // Business rule: Ensure organization name is properly formatted
            if (string.IsNullOrWhiteSpace(chatbot.OrganizationName))
                chatbot.OrganizationName = chatbot.OrganizationId.HasValue ? "Unknown Organization" : "Unassigned";

            // Business rule: Ensure color is properly formatted
            if (string.IsNullOrWhiteSpace(chatbot.Color) || !IsValidHexColor(chatbot.Color))
                chatbot.Color = "#222222";
        }

        /// <summary>
        /// Validates hex color format
        /// </summary>
        /// <param name="color">Color string to validate</param>
        /// <returns>True if valid hex color, false otherwise</returns>
        private bool IsValidHexColor(string color)
        {
            if (string.IsNullOrWhiteSpace(color))
                return false;

            // Business rule: Hex color must be in format #RRGGBB
            var hexColorPattern = @"^#[0-9A-Fa-f]{6}$";
            return Regex.IsMatch(color, hexColorPattern);
        }

        /// <summary>
        /// Sanitizes chatbot instructions to remove potentially harmful content
        /// </summary>
        /// <param name="instructions">Instructions to sanitize</param>
        /// <returns>Sanitized instructions</returns>
        private string SanitizeInstructions(string instructions)
        {
            if (string.IsNullOrWhiteSpace(instructions))
                return string.Empty;

            // Business rule: Remove potentially harmful script tags or SQL injection attempts
            var sanitized = instructions
                .Replace("<script", "&lt;script")
                .Replace("</script>", "&lt;/script&gt;")
                .Replace("javascript:", "javascript_");

            // Business rule: Limit instructions length
            if (sanitized.Length > 10000)
                sanitized = sanitized.Substring(0, 10000);

            return sanitized.Trim();
        }

        /// <summary>
        /// Logs business events for audit purposes
        /// </summary>
        /// <param name="message">Event message</param>
        /// <param name="chatbotId">Related chatbot ID</param>
        private void LogBusinessEvent(string message, int chatbotId)
        {
            try
            {
                // Business rule: Log important events for audit trail
                // This would typically integrate with the existing LogService
                Console.WriteLine($"[CHATBOT-BLL] {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} - ChatbotId: {chatbotId} - {message}");
            }
            catch
            {
                // Swallow logging exceptions to not interfere with main business flow
            }
        }

        #endregion
    }
}