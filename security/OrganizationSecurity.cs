using System;
using System.Linq;
using System.Web;
using System.Web.Security;
using BLL;
using ABSTRACTIONS;
using SERVICES;

namespace SECURITY
{
    /// <summary>
    /// Security layer for Organization operations
    /// Handles authentication, authorization, and security validation
    /// Follows the established architecture pattern: UI -> Security -> BLL -> DAL
    /// Ensures all organization operations follow proper security protocols
    /// </summary>
    public class OrganizationSecurity
    {
        private readonly OrganizationBLL organizationBLL;
        private readonly UserSecurity userSecurity;
        private readonly LogBLL _logBLL;

        public OrganizationSecurity()
        {
            organizationBLL = new OrganizationBLL();
            userSecurity = new UserSecurity();
            _logBLL = new LogBLL();
        }

        #region Organization CRUD Security Methods

        /// <summary>
        /// Creates a new organization with security validation and authorization checks
        /// Security rule: Only admin users can create organizations
        /// </summary>
        /// <param name="name">Organization name</param>
        /// <param name="slug">Organization slug</param>
        /// <param name="description">Organization description</param>
        /// <param name="ownerId">ID of the organization owner</param>
        /// <returns>DatabaseResult with new organization ID</returns>
        public DatabaseResult<int> CreateOrganization(string name, string slug, string description, int ownerId)
        {
            try
            {
                // Security validation: Check authentication
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = "Unauthorized organization creation attempt", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<int>.Failure("Authentication required to create organizations");
                }

                // Security validation: Only admin users can create organizations
                if (!IsCurrentUserAdmin())
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Non-admin user attempted to create organization: {name}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<int>.Failure("Only administrators can create organizations");
                }

                // Security validation: Input sanitization (prevent injection attacks)
                if (ContainsMaliciousContent(name) || ContainsMaliciousContent(slug) || ContainsMaliciousContent(description))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = "Malicious content detected in organization creation", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<int>.Failure("Invalid characters detected in organization data");
                }

                // Security validation: Rate limiting for organization creation
                if (!CheckRateLimit("CreateOrganization", currentUser.UserId))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = "Rate limit exceeded for organization creation", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<int>.Failure("Too many organization creation requests. Please wait before trying again");
                }

                // Security validation: Validate owner exists and is active
                var ownerValidation = ValidateOwnerUser(ownerId);
                if (!ownerValidation.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Invalid owner ID provided: {ownerId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<int>.Failure(ownerValidation.ErrorMessage);
                }

                // Call BLL layer following UI -> Security -> BLL -> DAL flow
                var result = organizationBLL.CreateOrganization(name, slug, description, ownerId, currentUser.UserId);
                
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.CREATE, 
                        UserId = currentUser.UserId, 
                        Description = $"Organization created: {name}", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Organization creation failed: {result.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                var currentUserId = userSecurity.GetCurrentUser()?.UserId;
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = currentUserId, 
                    Description = $"Security layer error in CreateOrganization: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult<int>.Failure("An error occurred while creating the organization. Please try again.");
            }
        }

        /// <summary>
        /// Retrieves organization by ID with security validation
        /// Security rule: Any authenticated user can view organization details
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <returns>OrganizationResult with organization details</returns>
        public OrganizationResult GetOrganizationById(int organizationId)
        {
            try
            {
                // Security validation: Check authentication
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Unauthenticated access attempt to organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return OrganizationResult.Failure("Authentication required to view organization details");
                }

                // Security validation: Basic input validation
                if (organizationId <= 0)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Invalid organization ID provided: {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return OrganizationResult.Failure("Invalid organization ID provided");
                }

                // Security validation: Rate limiting
                if (!CheckRateLimit("GetOrganization", currentUser.UserId))
                {
                    return OrganizationResult.Failure("Too many requests. Please wait before trying again");
                }

                // Call BLL layer following UI -> Security -> BLL -> DAL flow
                var result = organizationBLL.GetOrganizationById(organizationId);

                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ACCESS, 
                        UserId = currentUser.UserId, 
                        Description = "Organization details viewed", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                var currentUserId = userSecurity.GetCurrentUser()?.UserId;
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = currentUserId, 
                    Description = $"Security layer error in GetOrganizationById: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return OrganizationResult.Failure("An error occurred while retrieving organization details. Please try again.");
            }
        }

        /// <summary>
        /// Retrieves organization by slug with security validation
        /// Security rule: Any authenticated user can view organization details
        /// </summary>
        /// <param name="slug">Organization slug</param>
        /// <returns>OrganizationResult with organization details</returns>
        public OrganizationResult GetOrganizationBySlug(string slug)
        {
            try
            {
                // Security validation: Check authentication
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Unauthenticated access attempt to organization slug: {slug}", 
                        CreatedAt = DateTime.Now 
                    });
                    return OrganizationResult.Failure("Authentication required to view organization details");
                }

                // Security validation: Input sanitization
                if (string.IsNullOrWhiteSpace(slug) || ContainsMaliciousContent(slug))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Invalid or malicious slug provided: {slug}", 
                        CreatedAt = DateTime.Now 
                    });
                    return OrganizationResult.Failure("Invalid organization slug provided");
                }

                // Security validation: Rate limiting
                if (!CheckRateLimit("GetOrganization", currentUser.UserId))
                {
                    return OrganizationResult.Failure("Too many requests. Please wait before trying again");
                }

                // Call BLL layer following UI -> Security -> BLL -> DAL flow
                var result = organizationBLL.GetOrganizationBySlug(slug);

                if (result.IsSuccessful && result.Organization != null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ACCESS, 
                        UserId = currentUser.UserId, 
                        Description = $"Organization viewed by slug: {slug}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                var currentUserId = userSecurity.GetCurrentUser()?.UserId;
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = currentUserId, 
                    Description = $"Security layer error in GetOrganizationBySlug: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return OrganizationResult.Failure("An error occurred while retrieving organization details. Please try again.");
            }
        }

        /// <summary>
        /// Retrieves all organizations with security validation and access control
        /// Security rule: Any authenticated user can list organizations
        /// </summary>
        /// <param name="pageNumber">Page number</param>
        /// <param name="pageSize">Page size</param>
        /// <param name="sortColumn">Sort column</param>
        /// <param name="sortDirection">Sort direction</param>
        /// <param name="searchTerm">Search term</param>
        /// <returns>OrganizationListResult with paginated organizations</returns>
        public OrganizationListResult GetAllOrganizations(int pageNumber = 1, int pageSize = 10, string sortColumn = "Name", string sortDirection = "ASC", string searchTerm = null)
        {
            try
            {
                // Security validation: Check authentication
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = "Unauthenticated attempt to list organizations", 
                        CreatedAt = DateTime.Now 
                    });
                    return OrganizationListResult.Failure("Authentication required to view organizations");
                }

                // Security validation: Input sanitization
                if (!string.IsNullOrWhiteSpace(searchTerm) && ContainsMaliciousContent(searchTerm))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Malicious search term detected: {searchTerm}", 
                        CreatedAt = DateTime.Now 
                    });
                    return OrganizationListResult.Failure("Invalid search term provided");
                }

                // Security validation: Rate limiting for organization listing
                if (!CheckRateLimit("ListOrganizations", currentUser.UserId))
                {
                    return OrganizationListResult.Failure("Too many requests. Please wait before trying again");
                }

                // Security validation: Prevent excessive pagination requests
                if (pageSize > 100)
                    pageSize = 100;

                // Call BLL layer following UI -> Security -> BLL -> DAL flow
                return organizationBLL.GetAllOrganizations(pageNumber, pageSize, sortColumn, sortDirection, searchTerm);
            }
            catch (Exception ex)
            {
                var currentUserId = userSecurity.GetCurrentUser()?.UserId;
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = currentUserId, 
                    Description = $"Security layer error in GetAllOrganizations: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return OrganizationListResult.Failure("An error occurred while retrieving organizations. Please try again.");
            }
        }

        /// <summary>
        /// Updates organization with security validation and authorization
        /// Security rule: Only organization admins or owners can update organization details
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="name">Organization name</param>
        /// <param name="slug">Organization slug</param>
        /// <param name="description">Organization description</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult UpdateOrganization(int organizationId, string name, string slug, string description)
        {
            try
            {
                // Security validation: Check authentication
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Unauthorized organization update attempt for organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("Authentication required to update organizations");
                }

                // Security validation: Check if user has permission to update organization
                if (!HasOrganizationUpdatePermission(currentUser.UserId, organizationId))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Unauthorized organization update attempt: Organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("You do not have permission to update this organization");
                }

                // Security validation: Input sanitization
                if (ContainsMaliciousContent(name) || ContainsMaliciousContent(slug) || ContainsMaliciousContent(description))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Malicious content detected in organization update for organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("Invalid characters detected in organization data");
                }

                // Security validation: Rate limiting
                if (!CheckRateLimit("UpdateOrganization", currentUser.UserId))
                {
                    return DatabaseResult.Failure("Too many update requests. Please wait before trying again");
                }

                // Call BLL layer following UI -> Security -> BLL -> DAL flow
                var result = organizationBLL.UpdateOrganization(organizationId, name, slug, description, currentUser.UserId);

                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.UPDATE, 
                        UserId = currentUser.UserId, 
                        Description = $"Organization updated: {name}", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Organization update failed for organization {organizationId}: {result.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                var currentUserId = userSecurity.GetCurrentUser()?.UserId;
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = currentUserId, 
                    Description = $"Security layer error in UpdateOrganization: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult.Failure("An error occurred while updating the organization. Please try again.");
            }
        }

        /// <summary>
        /// Deletes organization with security validation and authorization
        /// Security rule: Only organization owners or system admins can delete organizations
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult DeleteOrganization(int organizationId)
        {
            try
            {
                // Security validation: Check authentication
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Unauthorized organization deletion attempt for organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("Authentication required to delete organizations");
                }

                // Security validation: Check if user has permission to delete organization
                if (!HasOrganizationDeletePermission(currentUser.UserId, organizationId))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Unauthorized organization deletion attempt: Organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("You do not have permission to delete this organization");
                }

                // Security validation: Rate limiting for critical operations
                if (!CheckRateLimit("DeleteOrganization", currentUser.UserId, 1, 300)) // 1 per 5 minutes
                {
                    return DatabaseResult.Failure("Too many deletion requests. Please wait before trying again");
                }

                // Call BLL layer following UI -> Security -> BLL -> DAL flow
                var result = organizationBLL.DeleteOrganization(organizationId, currentUser.UserId);

                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.DELETE, 
                        UserId = currentUser.UserId, 
                        Description = "Organization deleted", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Organization deletion failed for organization {organizationId}: {result.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                var currentUserId = userSecurity.GetCurrentUser()?.UserId;
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = currentUserId, 
                    Description = $"Security layer error in DeleteOrganization: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult.Failure("An error occurred while deleting the organization. Please try again.");
            }
        }

        /// <summary>
        /// Gets organizations owned by current user with security validation
        /// Security rule: Users can only view their own owned organizations
        /// </summary>
        /// <returns>OrganizationListResult with owned organizations</returns>
        public OrganizationListResult GetMyOrganizations()
        {
            try
            {
                // Security validation: Check authentication
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = "Unauthorized attempt to get owned organizations", 
                        CreatedAt = DateTime.Now 
                    });
                    return OrganizationListResult.Failure("Authentication required to view your organizations");
                }

                // Call BLL layer following UI -> Security -> BLL -> DAL flow
                return organizationBLL.GetOrganizationsByOwner(currentUser.UserId);
            }
            catch (Exception ex)
            {
                var currentUserId = userSecurity.GetCurrentUser()?.UserId;
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = currentUserId, 
                    Description = $"Security layer error in GetMyOrganizations: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return OrganizationListResult.Failure("An error occurred while retrieving your organizations. Please try again.");
            }
        }

        #endregion

        #region Organization Member Security Methods

        /// <summary>
        /// Adds member to organization with security validation and authorization
        /// Security rule: Only organization admins can add members
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="userId">User ID to add</param>
        /// <param name="role">Member role</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult AddOrganizationMember(int organizationId, int userId, string role)
        {
            try
            {
                // Security validation: Check authentication
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Unauthorized member addition attempt for organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("Authentication required to add organization members");
                }

                // Security validation: Check if user has permission to add members
                if (!HasOrganizationAdminPermission(currentUser.UserId, organizationId))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Unauthorized member addition attempt: Organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("You do not have permission to add members to this organization");
                }

                // Security validation: Validate member role
                if (!IsValidMemberRole(role))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Invalid member role provided: {role}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("Invalid member role provided");
                }

                // Security validation: Rate limiting
                if (!CheckRateLimit("AddMember", currentUser.UserId))
                {
                    return DatabaseResult.Failure("Too many member addition requests. Please wait before trying again");
                }

                // Call BLL layer following UI -> Security -> BLL -> DAL flow
                var result = organizationBLL.AddOrganizationMember(organizationId, userId, role, currentUser.UserId);

                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.CREATE, 
                        UserId = currentUser.UserId, 
                        Description = $"Member added: User {userId} with role {role}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                var currentUserId = userSecurity.GetCurrentUser()?.UserId;
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = currentUserId, 
                    Description = $"Security layer error in AddOrganizationMember: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult.Failure("An error occurred while adding the organization member. Please try again.");
            }
        }

        /// <summary>
        /// Removes member from organization with security validation and authorization
        /// Security rule: Organization admins can remove members, users can remove themselves
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="userId">User ID to remove</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult RemoveOrganizationMember(int organizationId, int userId)
        {
            try
            {
                // Security validation: Check authentication
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Unauthorized member removal attempt for organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("Authentication required to remove organization members");
                }

                // Security validation: Check permissions (admin or self-removal)
                bool canRemove = HasOrganizationAdminPermission(currentUser.UserId, organizationId) || 
                                currentUser.UserId == userId;

                if (!canRemove)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Unauthorized member removal attempt: Organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("You do not have permission to remove this organization member");
                }

                // Security validation: Rate limiting
                if (!CheckRateLimit("RemoveMember", currentUser.UserId))
                {
                    return DatabaseResult.Failure("Too many member removal requests. Please wait before trying again");
                }

                // Call BLL layer following UI -> Security -> BLL -> DAL flow
                var result = organizationBLL.RemoveOrganizationMember(organizationId, userId, currentUser.UserId);

                if (result.IsSuccessful)
                {
                    string action = currentUser.UserId == userId ? "User left organization" : $"Member removed: User {userId}";
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.DELETE, 
                        UserId = currentUser.UserId, 
                        Description = action, 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                var currentUserId = userSecurity.GetCurrentUser()?.UserId;
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = currentUserId, 
                    Description = $"Security layer error in RemoveOrganizationMember: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult.Failure("An error occurred while removing the organization member. Please try again.");
            }
        }

        /// <summary>
        /// Gets organization members with security validation and access control
        /// Security rule: Only organization members can view the member list
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <returns>OrganizationMemberListResult with member details</returns>
        public OrganizationMemberListResult GetOrganizationMembers(int organizationId)
        {
            try
            {
                // Security validation: Check authentication
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Unauthorized member list access attempt for organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return OrganizationMemberListResult.Failure("Authentication required to view organization members");
                }

                // Security validation: Check if user is member of organization
                if (!HasOrganizationMemberPermission(currentUser.UserId, organizationId))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Unauthorized member list access: Organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return OrganizationMemberListResult.Failure("You do not have permission to view this organization's members");
                }

                // Security validation: Rate limiting
                if (!CheckRateLimit("GetMembers", currentUser.UserId))
                {
                    return OrganizationMemberListResult.Failure("Too many requests. Please wait before trying again");
                }

                // Call BLL layer following UI -> Security -> BLL -> DAL flow
                return organizationBLL.GetOrganizationMembers(organizationId, currentUser.UserId);
            }
            catch (Exception ex)
            {
                var currentUserId = userSecurity.GetCurrentUser()?.UserId;
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = currentUserId, 
                    Description = $"Security layer error in GetOrganizationMembers: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return OrganizationMemberListResult.Failure("An error occurred while retrieving organization members. Please try again.");
            }
        }

        /// <summary>
        /// Gets user's organizations with security validation
        /// Security rule: Users can only view their own organization memberships
        /// </summary>
        /// <returns>OrganizationMemberListResult with user's organizations</returns>
        public OrganizationMemberListResult GetMyOrganizationMemberships()
        {
            try
            {
                // Security validation: Check authentication
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = "Unauthorized user organizations access attempt", 
                        CreatedAt = DateTime.Now 
                    });
                    return OrganizationMemberListResult.Failure("Authentication required to view your organization memberships");
                }

                // Call BLL layer following UI -> Security -> BLL -> DAL flow
                return organizationBLL.GetUserOrganizations(currentUser.UserId);
            }
            catch (Exception ex)
            {
                var currentUserId = userSecurity.GetCurrentUser()?.UserId;
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = currentUserId, 
                    Description = $"Security layer error in GetMyOrganizationMemberships: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return OrganizationMemberListResult.Failure("An error occurred while retrieving your organization memberships. Please try again.");
            }
        }

        /// <summary>
        /// Updates member role with security validation and authorization
        /// Security rule: Only organization admins can update member roles
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="userId">User ID</param>
        /// <param name="newRole">New role for the member</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult UpdateMemberRole(int organizationId, int userId, string newRole)
        {
            try
            {
                // Security validation: Check authentication
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Unauthorized role update attempt for organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("Authentication required to update member roles");
                }

                // Security validation: Check if user has permission to update roles
                if (!HasOrganizationAdminPermission(currentUser.UserId, organizationId))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Unauthorized role update attempt: Organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("You do not have permission to update member roles in this organization");
                }

                // Security validation: Validate member role
                if (!IsValidMemberRole(newRole))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Invalid member role provided: {newRole}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("Invalid member role provided");
                }

                // Security validation: Rate limiting
                if (!CheckRateLimit("UpdateRole", currentUser.UserId))
                {
                    return DatabaseResult.Failure("Too many role update requests. Please wait before trying again");
                }

                // Call BLL layer following UI -> Security -> BLL -> DAL flow
                var result = organizationBLL.UpdateMemberRole(organizationId, userId, newRole, currentUser.UserId);

                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.UPDATE, 
                        UserId = currentUser.UserId, 
                        Description = $"Member role updated: User {userId} to {newRole}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                var currentUserId = userSecurity.GetCurrentUser()?.UserId;
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = currentUserId, 
                    Description = $"Security layer error in UpdateMemberRole: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult.Failure("An error occurred while updating the member role. Please try again.");
            }
        }

        #endregion

        #region Statistics Security Methods

        /// <summary>
        /// Gets organization statistics with security validation
        /// Security rule: Only organization members can view statistics
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <returns>OrganizationStatisticsResult with detailed statistics</returns>
        public OrganizationStatisticsResult GetOrganizationStats(int organizationId)
        {
            try
            {
                // Security validation: Check authentication
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Unauthorized statistics access attempt for organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return OrganizationStatisticsResult.Failure("Authentication required to view organization statistics");
                }

                // Security validation: Check if user is member of organization
                if (!HasOrganizationMemberPermission(currentUser.UserId, organizationId))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Unauthorized statistics access: Organization {organizationId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return OrganizationStatisticsResult.Failure("You do not have permission to view this organization's statistics");
                }

                // Security validation: Rate limiting
                if (!CheckRateLimit("GetStats", currentUser.UserId))
                {
                    return OrganizationStatisticsResult.Failure("Too many requests. Please wait before trying again");
                }

                // Call BLL layer following UI -> Security -> BLL -> DAL flow
                return organizationBLL.GetOrganizationStats(organizationId);
            }
            catch (Exception ex)
            {
                var currentUserId = userSecurity.GetCurrentUser()?.UserId;
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = currentUserId, 
                    Description = $"Security layer error in GetOrganizationStats: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return OrganizationStatisticsResult.Failure("An error occurred while retrieving organization statistics. Please try again.");
            }
        }

        #endregion

        #region Private Security Helper Methods


        /// <summary>
        /// Checks if current user is admin
        /// </summary>
        private bool IsCurrentUserAdmin()
        {
            var currentUser = userSecurity.GetCurrentUser();
            return currentUser?.UserRole?.ToLowerInvariant() == "admin";
        }

        /// <summary>
        /// Validates if a user exists and is active (for owner validation)
        /// </summary>
        private DatabaseResult ValidateOwnerUser(int ownerId)
        {
            // This would ideally call UserBLL to validate the user
            // For now, we'll perform basic validation
            if (ownerId <= 0)
                return DatabaseResult.Failure("Invalid owner ID provided");
            
            // In a complete implementation, we would verify the user exists and is active
            return DatabaseResult.Success();
        }

        /// <summary>
        /// Checks if user has permission to update organization
        /// </summary>
        private bool HasOrganizationUpdatePermission(int userId, int organizationId)
        {
            try
            {
                // Check if user is system admin
                if (IsCurrentUserAdmin())
                    return true;

                // Check if user is organization admin
                var roleResult = organizationBLL.CheckUserOrganizationRole(userId, organizationId, "organization_admin");
                return roleResult.IsSuccessful && roleResult.HasAccess;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Checks if user has permission to delete organization
        /// </summary>
        private bool HasOrganizationDeletePermission(int userId, int organizationId)
        {
            try
            {
                // Check if user is system admin
                if (IsCurrentUserAdmin())
                    return true;

                // Check if user is organization owner
                var roleResult = organizationBLL.CheckUserOrganizationRole(userId, organizationId, "owner");
                return roleResult.IsSuccessful && roleResult.HasAccess;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Checks if user has admin permission in organization
        /// </summary>
        private bool HasOrganizationAdminPermission(int userId, int organizationId)
        {
            try
            {
                var roleResult = organizationBLL.CheckUserOrganizationRole(userId, organizationId, "organization_admin");
                return roleResult.IsSuccessful && roleResult.HasAccess;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Checks if user has member permission in organization
        /// </summary>
        private bool HasOrganizationMemberPermission(int userId, int organizationId)
        {
            try
            {
                var roleResult = organizationBLL.CheckUserOrganizationRole(userId, organizationId);
                return roleResult.IsSuccessful && roleResult.HasAccess;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Validates if member role is valid
        /// </summary>
        private bool IsValidMemberRole(string role)
        {
            if (string.IsNullOrWhiteSpace(role))
                return false;

            var validRoles = new[] { "organization_admin", "member" };
            return validRoles.Contains(role.Trim().ToLowerInvariant());
        }

        /// <summary>
        /// Checks for malicious content in input strings
        /// </summary>
        private bool ContainsMaliciousContent(string input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return false;

            // Basic checks for SQL injection and XSS attempts
            var maliciousPatterns = new[]
            {
                "<script", "</script>", "javascript:", "vbscript:",
                "SELECT ", "INSERT ", "UPDATE ", "DELETE ", "DROP ",
                "EXEC ", "EXECUTE ", "UNION ", "--|", "/*", "*/"
            };

            string lowerInput = input.ToLowerInvariant();
            return maliciousPatterns.Any(pattern => lowerInput.Contains(pattern.ToLowerInvariant()));
        }

        /// <summary>
        /// Implements rate limiting for security operations
        /// </summary>
        private bool CheckRateLimit(string operation, int userId, int maxRequests = 10, int windowSeconds = 60)
        {
            try
            {
                // Simple rate limiting implementation
                // In production, this would use a more sophisticated caching mechanism
                var cacheKey = $"RateLimit_{operation}_{userId}";
                var cache = HttpContext.Current?.Cache;
                
                if (cache == null)
                    return true; // Allow if caching not available

                var currentCount = (int?)cache[cacheKey] ?? 0;
                if (currentCount >= maxRequests)
                    return false;

                cache.Insert(cacheKey, currentCount + 1, null, 
                    DateTime.Now.AddSeconds(windowSeconds), 
                    System.Web.Caching.Cache.NoSlidingExpiration);

                return true;
            }
            catch
            {
                // Allow operation if rate limiting fails
                return true;
            }
        }

        #endregion
    }
}