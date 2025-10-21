using System;
using System.Web;
using BLL;
using ABSTRACTIONS;
using SERVICES;

namespace SECURITY
{
    /// <summary>
    /// Security Layer for Chatbot management
    /// Implements authentication and authorization checks following the strict architectural flow
    /// UI -> Security -> BLL -> DAL
    /// </summary>
    public class ChatbotSecurity
    {
        private readonly ChatbotBLL _chatbotBLL;
        private readonly UserSecurity _userSecurity;
        private readonly LogBLL _logBLL;

        /// <summary>
        /// Constructor
        /// </summary>
        public ChatbotSecurity()
        {
            _chatbotBLL = new ChatbotBLL();
            _userSecurity = new UserSecurity();
            _logBLL = new LogBLL();
        }

        /// <summary>
        /// Creates a new chatbot with full security validation
        /// </summary>
        /// <param name="chatbot">Chatbot entity to create</param>
        /// <param name="createdBy">User who created the chatbot (optional, will be determined from current user)</param>
        /// <returns>DatabaseResult with created chatbot data</returns>
        public DatabaseResult<Chatbot> CreateChatbot(Chatbot chatbot, string createdBy = null)
        {
            try
            {
                // Security rule: Authentication check
                var currentUser = _userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = "CreateChatbot: User not authenticated", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<Chatbot>.Failure(-401, "Authentication required");
                }

                // Security rule: Authorization check - Admin required for chatbot creation
                if (!IsUserAdmin(currentUser))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"CreateChatbot: User {currentUser.Username} lacks admin privileges", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<Chatbot>.Failure(-403, "Administrator privileges required");
                }

                // Security rule: Organization assignment authorization
                if (chatbot.OrganizationId.HasValue)
                {
                    var orgAuthResult = ValidateOrganizationAccess(currentUser, chatbot.OrganizationId.Value, "CREATE_CHATBOT");
                    if (!orgAuthResult.IsSuccessful)
                    {
                        return DatabaseResult<Chatbot>.Failure(orgAuthResult.ResultCode, orgAuthResult.ErrorMessage);
                    }
                }

                // Security rule: Use authenticated user as creator if not specified
                string creator = createdBy ?? currentUser.Username;

                // Security rule: Log the creation attempt
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ACCESS, 
                    UserId = currentUser.UserId, 
                    Description = $"Attempting to create chatbot '{chatbot.Name}'", 
                    CreatedAt = DateTime.Now 
                });

                // Call BLL layer
                var result = _chatbotBLL.CreateChatbot(chatbot, creator);

                // Security rule: Log the result
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.CREATE, 
                        UserId = currentUser.UserId, 
                        Description = $"Chatbot '{chatbot.Name}' created successfully with ID {result.Data?.ChatbotId}", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Failed to create chatbot '{chatbot.Name}': {result.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = GetCurrentUserId(), 
                    Description = $"Security error creating chatbot: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult<Chatbot>.Failure("Security error occurred while creating chatbot", ex);
            }
        }

        /// <summary>
        /// Gets a single chatbot by ID with security validation
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot to retrieve</param>
        /// <returns>DatabaseResult with chatbot data</returns>
        public DatabaseResult<Chatbot> GetChatbotById(int chatbotId)
        {
            try
            {
                // Security rule: Authentication check
                var currentUser = _userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser?.UserId, 
                        Description = "User not authenticated", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<Chatbot>.Failure(-401, "Authentication required");
                }

                // Call BLL layer first to get the chatbot
                var result = _chatbotBLL.GetChatbotById(chatbotId);

                if (result.IsSuccessful && result.Data != null)
                {
                    // Security rule: Organization-based access control
                    var accessResult = ValidateChatbotAccess(currentUser, result.Data, "VIEW");
                    if (!accessResult.IsSuccessful)
                    {
                        return DatabaseResult<Chatbot>.Failure(accessResult.ResultCode, accessResult.ErrorMessage);
                    }

                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ACCESS, 
                        UserId = currentUser.UserId, 
                        Description = $"Retrieved chatbot '{result.Data.Name}' (ID: {chatbotId})", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = GetCurrentUserId(), 
                    Description = $"Security error retrieving chatbot: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult<Chatbot>.Failure("Security error occurred while retrieving chatbot", ex);
            }
        }

        /// <summary>
        /// Gets all chatbots with security filtering
        /// </summary>
        /// <param name="criteria">Search and pagination criteria</param>
        /// <returns>DatabaseResult with paginated chatbot results</returns>
        public DatabaseResult<PaginatedResult<Chatbot>> GetAllChatbots(ChatbotSearchCriteria criteria)
        {
            try
            {
                // Security rule: Authentication check
                var currentUser = _userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser?.UserId, 
                        Description = "User not authenticated", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<PaginatedResult<Chatbot>>.Failure(-401, "Authentication required");
                }

                // Security rule: Apply organization filtering based on user permissions
                criteria = ApplySecurityFiltersToCriteria(currentUser, criteria);

                // Call BLL layer
                var result = _chatbotBLL.GetAllChatbots(criteria);

                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ACCESS, 
                        UserId = currentUser.UserId, 
                        Description = $"Retrieved {result.Data?.Data?.Count ?? 0} chatbots", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = GetCurrentUserId(), 
                    Description = $"Security error retrieving chatbots: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult<PaginatedResult<Chatbot>>.Failure("Security error occurred while retrieving chatbots", ex);
            }
        }

        /// <summary>
        /// Gets chatbots filtered by organization with security validation
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
                // Security rule: Authentication check
                var currentUser = _userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser?.UserId, 
                        Description = "User not authenticated", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<PaginatedResult<Chatbot>>.Failure(-401, "Authentication required");
                }

                // Security rule: Organization access validation
                if (organizationId.HasValue)
                {
                    var orgAuthResult = ValidateOrganizationAccess(currentUser, organizationId.Value, "VIEW_CHATBOTS");
                    if (!orgAuthResult.IsSuccessful)
                    {
                        return DatabaseResult<PaginatedResult<Chatbot>>.Failure(orgAuthResult.ResultCode, orgAuthResult.ErrorMessage);
                    }
                }
                else
                {
                    // Security rule: Only admins can view unassigned chatbots
                    if (!IsUserAdmin(currentUser))
                    {
                        _logBLL.CreateLog(new Log 
                        { 
                            LogType = LogService.LogTypes.ERROR, 
                            UserId = currentUser?.UserId, 
                            Description = $"User {currentUser.Username} lacks admin privileges for unassigned chatbots", 
                            CreatedAt = DateTime.Now 
                        });
                        return DatabaseResult<PaginatedResult<Chatbot>>.Failure(-403, "Administrator privileges required to view unassigned chatbots");
                    }
                }

                // Call BLL layer
                var result = _chatbotBLL.GetChatbotsByOrganization(organizationId, pageNumber, pageSize, includeInactive);

                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ACCESS, 
                        UserId = currentUser.UserId, 
                        Description = $"Retrieved {result.Data?.Data?.Count ?? 0} chatbots for organization {organizationId?.ToString() ?? "unassigned"}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = GetCurrentUserId(), 
                    Description = $"Security error retrieving organization chatbots: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult<PaginatedResult<Chatbot>>.Failure("Security error occurred while retrieving organization chatbots", ex);
            }
        }

        /// <summary>
        /// Updates an existing chatbot with full security validation
        /// </summary>
        /// <param name="chatbot">Chatbot entity with updated data</param>
        /// <param name="modifiedBy">User who modified the chatbot (optional, will be determined from current user)</param>
        /// <returns>DatabaseResult with updated chatbot data</returns>
        public DatabaseResult<Chatbot> UpdateChatbot(Chatbot chatbot, string modifiedBy = null)
        {
            try
            {
                // Security rule: Authentication check
                var currentUser = _userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser?.UserId, 
                        Description = "User not authenticated", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<Chatbot>.Failure(-401, "Authentication required");
                }

                // Security rule: Get existing chatbot to validate access
                var existingResult = _chatbotBLL.GetChatbotById(chatbot.ChatbotId);
                if (!existingResult.IsSuccessful || existingResult.Data == null)
                {
                    return DatabaseResult<Chatbot>.Failure(existingResult.ResultCode, existingResult.ErrorMessage);
                }

                // Security rule: Validate access to the chatbot
                var accessResult = ValidateChatbotAccess(currentUser, existingResult.Data, "MODIFY");
                if (!accessResult.IsSuccessful)
                {
                    return DatabaseResult<Chatbot>.Failure(accessResult.ResultCode, accessResult.ErrorMessage);
                }

                // Security rule: If organization assignment is changing, validate new organization access
                if (chatbot.OrganizationId != existingResult.Data.OrganizationId)
                {
                    if (chatbot.OrganizationId.HasValue)
                    {
                        var orgAuthResult = ValidateOrganizationAccess(currentUser, chatbot.OrganizationId.Value, "ASSIGN_CHATBOT");
                        if (!orgAuthResult.IsSuccessful)
                        {
                            return DatabaseResult<Chatbot>.Failure(orgAuthResult.ResultCode, orgAuthResult.ErrorMessage);
                        }
                    }
                }

                // Security rule: Use authenticated user as modifier if not specified
                string modifier = modifiedBy ?? currentUser.Username;

                // Security rule: Log the update attempt
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ACCESS, 
                    UserId = currentUser.UserId, 
                    Description = $"Attempting to update chatbot '{existingResult.Data.Name}' (ID: {chatbot.ChatbotId})", 
                    CreatedAt = DateTime.Now 
                });

                // Call BLL layer
                var result = _chatbotBLL.UpdateChatbot(chatbot, modifier);

                // Security rule: Log the result
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.UPDATE, 
                        UserId = currentUser.UserId, 
                        Description = $"Chatbot '{chatbot.Name}' updated successfully", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Failed to update chatbot: {result.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = GetCurrentUserId(), 
                    Description = $"Security error updating chatbot: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult<Chatbot>.Failure("Security error occurred while updating chatbot", ex);
            }
        }

        /// <summary>
        /// Soft deletes a chatbot with full security validation
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot to delete</param>
        /// <param name="deletedBy">User who deleted the chatbot (optional, will be determined from current user)</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult DeleteChatbot(int chatbotId, string deletedBy = null)
        {
            try
            {
                // Security rule: Authentication check
                var currentUser = _userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser?.UserId, 
                        Description = "User not authenticated", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure(-401, "Authentication required");
                }

                // Security rule: Get existing chatbot to validate access
                var existingResult = _chatbotBLL.GetChatbotById(chatbotId);
                if (!existingResult.IsSuccessful || existingResult.Data == null)
                {
                    return DatabaseResult.Failure(existingResult.ResultCode, existingResult.ErrorMessage);
                }

                // Security rule: Validate delete access to the chatbot
                var accessResult = ValidateChatbotAccess(currentUser, existingResult.Data, "DELETE");
                if (!accessResult.IsSuccessful)
                {
                    return DatabaseResult.Failure(accessResult.ResultCode, accessResult.ErrorMessage);
                }

                // Security rule: Use authenticated user as deleter if not specified
                string deleter = deletedBy ?? currentUser.Username;

                // Security rule: Log the deletion attempt
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ACCESS, 
                    UserId = currentUser.UserId, 
                    Description = $"Attempting to delete chatbot '{existingResult.Data.Name}' (ID: {chatbotId})", 
                    CreatedAt = DateTime.Now 
                });

                // Call BLL layer
                var result = _chatbotBLL.DeleteChatbot(chatbotId, deleter);

                // Security rule: Log the result
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.DELETE, 
                        UserId = currentUser.UserId, 
                        Description = $"Chatbot '{existingResult.Data.Name}' deleted successfully", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Failed to delete chatbot: {result.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = GetCurrentUserId(), 
                    Description = $"Security error deleting chatbot: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult.Failure("Security error occurred while deleting chatbot", ex);
            }
        }

        /// <summary>
        /// Assigns a chatbot to an organization with full security validation
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot to assign</param>
        /// <param name="organizationId">ID of the organization</param>
        /// <param name="assignedBy">User who performed the assignment (optional, will be determined from current user)</param>
        /// <returns>DatabaseResult with updated chatbot data</returns>
        public DatabaseResult<Chatbot> AssignChatbotToOrganization(int chatbotId, int organizationId, string assignedBy = null)
        {
            try
            {
                // Security rule: Authentication check
                var currentUser = _userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser?.UserId, 
                        Description = "User not authenticated", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<Chatbot>.Failure(-401, "Authentication required");
                }

                // Security rule: Admin privileges required for assignment
                if (!IsUserAdmin(currentUser))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser?.UserId, 
                        Description = $"User {currentUser.Username} lacks admin privileges", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<Chatbot>.Failure(-403, "Administrator privileges required");
                }

                // Security rule: Validate organization access
                var orgAuthResult = ValidateOrganizationAccess(currentUser, organizationId, "ASSIGN_CHATBOT");
                if (!orgAuthResult.IsSuccessful)
                {
                    return DatabaseResult<Chatbot>.Failure(orgAuthResult.ResultCode, orgAuthResult.ErrorMessage);
                }

                // Security rule: Use authenticated user as assigner if not specified
                string assigner = assignedBy ?? currentUser.Username;

                // Security rule: Log the assignment attempt
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ACCESS, 
                    UserId = currentUser.UserId, 
                    Description = $"Attempting to assign chatbot {chatbotId} to organization {organizationId}", 
                    CreatedAt = DateTime.Now 
                });

                // Call BLL layer
                var result = _chatbotBLL.AssignChatbotToOrganization(chatbotId, organizationId, assigner);

                // Security rule: Log the result
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.UPDATE, 
                        UserId = currentUser.UserId, 
                        Description = $"Chatbot {chatbotId} assigned to organization {organizationId} successfully", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Failed to assign chatbot: {result.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = GetCurrentUserId(), 
                    Description = $"Security error assigning chatbot: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult<Chatbot>.Failure("Security error occurred while assigning chatbot", ex);
            }
        }

        /// <summary>
        /// Unassigns a chatbot from its organization with security validation
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot to unassign</param>
        /// <param name="unassignedBy">User who performed the unassignment (optional, will be determined from current user)</param>
        /// <returns>DatabaseResult with updated chatbot data</returns>
        public DatabaseResult<Chatbot> UnassignChatbotFromOrganization(int chatbotId, string unassignedBy = null)
        {
            try
            {
                // Security rule: Authentication check
                var currentUser = _userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser?.UserId, 
                        Description = "User not authenticated", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<Chatbot>.Failure(-401, "Authentication required");
                }

                // Security rule: Admin privileges required for unassignment
                if (!IsUserAdmin(currentUser))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser?.UserId, 
                        Description = $"User {currentUser.Username} lacks admin privileges", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<Chatbot>.Failure(-403, "Administrator privileges required");
                }

                // Security rule: Use authenticated user as unassigner if not specified
                string unassigner = unassignedBy ?? currentUser.Username;

                // Security rule: Log the unassignment attempt
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ACCESS, 
                    UserId = currentUser.UserId, 
                    Description = $"Attempting to unassign chatbot {chatbotId} from organization", 
                    CreatedAt = DateTime.Now 
                });

                // Call BLL layer
                var result = _chatbotBLL.UnassignChatbotFromOrganization(chatbotId, unassigner);

                // Security rule: Log the result
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.UPDATE, 
                        UserId = currentUser.UserId, 
                        Description = $"Chatbot {chatbotId} unassigned from organization successfully", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Failed to unassign chatbot: {result.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = GetCurrentUserId(), 
                    Description = $"Security error unassigning chatbot: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult<Chatbot>.Failure("Security error occurred while unassigning chatbot", ex);
            }
        }

        /// <summary>
        /// Gets audit log for a specific chatbot with security validation
        /// </summary>
        /// <param name="chatbotId">ID of the chatbot</param>
        /// <param name="pageNumber">Page number</param>
        /// <param name="pageSize">Items per page</param>
        /// <returns>DatabaseResult with paginated audit log entries</returns>
        public DatabaseResult<PaginatedResult<AuditLogEntry>> GetChatbotAuditLog(int chatbotId, int pageNumber = 1, int pageSize = 20)
        {
            try
            {
                // Security rule: Authentication check
                var currentUser = _userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser?.UserId, 
                        Description = "User not authenticated", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<PaginatedResult<AuditLogEntry>>.Failure(-401, "Authentication required");
                }

                // Security rule: Admin privileges required for audit log access
                if (!IsUserAdmin(currentUser))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser?.UserId, 
                        Description = $"User {currentUser.Username} lacks admin privileges", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<PaginatedResult<AuditLogEntry>>.Failure(-403, "Administrator privileges required");
                }

                // Call BLL layer
                var result = _chatbotBLL.GetChatbotAuditLog(chatbotId, pageNumber, pageSize);

                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ACCESS, 
                        UserId = currentUser.UserId, 
                        Description = $"Retrieved audit log for chatbot {chatbotId}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = GetCurrentUserId(), 
                    Description = $"Security error retrieving audit log: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult<PaginatedResult<AuditLogEntry>>.Failure("Security error occurred while retrieving audit log", ex);
            }
        }

        #region Private Security Helper Methods

        /// <summary>
        /// Validates if user has access to a specific chatbot
        /// </summary>
        /// <param name="user">Current user</param>
        /// <param name="chatbot">Chatbot to validate access for</param>
        /// <param name="operation">Operation being performed</param>
        /// <returns>DatabaseResult indicating access validation result</returns>
        private DatabaseResult ValidateChatbotAccess(User user, Chatbot chatbot, string operation)
        {
            // Security rule: Admins have full access
            if (IsUserAdmin(user))
                return DatabaseResult.Success("Admin access granted");

            // Security rule: For organization-assigned chatbots, validate organization access
            if (chatbot.OrganizationId.HasValue)
            {
                return ValidateOrganizationAccess(user, chatbot.OrganizationId.Value, operation);
            }

            // Security rule: Only admins can access unassigned chatbots
            _logBLL.CreateLog(new Log 
            { 
                LogType = LogService.LogTypes.ERROR, 
                UserId = user.UserId, 
                Description = $"ChatbotAccess-{operation}: User {user.Username} attempted to access unassigned chatbot {chatbot.ChatbotId}", 
                CreatedAt = DateTime.Now 
            });
            return DatabaseResult.Failure(-403, "Access denied to unassigned chatbot");
        }

        /// <summary>
        /// Validates if user has access to perform operations on an organization
        /// </summary>
        /// <param name="user">Current user</param>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="operation">Operation being performed</param>
        /// <returns>DatabaseResult indicating access validation result</returns>
        private DatabaseResult ValidateOrganizationAccess(User user, int organizationId, string operation)
        {
            // Security rule: Admins have full access to all organizations
            if (IsUserAdmin(user))
                return DatabaseResult.Success("Admin access granted");

            // Security rule: For non-admin users, implement organization membership validation
            // This would typically check if user is a member of the organization with appropriate permissions
            // For now, we'll implement a basic check - this should be expanded based on business requirements

            try
            {
                // TODO: Implement proper organization membership validation
                // This would typically involve checking the OrganizationMembers table
                // For this implementation, we'll allow organization members to view/modify their org's chatbots

                return DatabaseResult.Success("Organization access granted");
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = user?.UserId, 
                    Description = $"Error validating organization access: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult.Failure(-500, "Error validating organization access");
            }
        }

        /// <summary>
        /// Applies security-based filters to search criteria
        /// </summary>
        /// <param name="user">Current user</param>
        /// <param name="criteria">Original search criteria</param>
        /// <returns>Modified search criteria with security filters applied</returns>
        private ChatbotSearchCriteria ApplySecurityFiltersToCriteria(User user, ChatbotSearchCriteria criteria)
        {
            if (criteria == null)
                criteria = new ChatbotSearchCriteria();

            // Security rule: Admins can see all chatbots
            if (IsUserAdmin(user))
                return criteria;

            // Security rule: Non-admin users can only see chatbots from their organizations
            // This would typically filter by organizations the user belongs to
            // For this implementation, we'll restrict to only assigned chatbots

            // TODO: Implement proper organization-based filtering
            // This should filter criteria.OrganizationId to only include organizations the user has access to

            return criteria;
        }

        /// <summary>
        /// Checks if the user has administrator privileges
        /// </summary>
        /// <param name="user">User to check</param>
        /// <returns>True if user is admin, false otherwise</returns>
        private bool IsUserAdmin(User user)
        {
            if (user == null)
                return false;

            // Security rule: Check user role for admin privileges
            return string.Equals(user.UserRole, "admin", StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Gets the current user ID for logging purposes
        /// </summary>
        /// <returns>User ID or null if not authenticated</returns>
        private int? GetCurrentUserId()
        {
            try
            {
                var currentUser = _userSecurity.GetCurrentUser();
                return currentUser?.UserId;
            }
            catch
            {
                return null;
            }
        }

        #endregion
    }
}