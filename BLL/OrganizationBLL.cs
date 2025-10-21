using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using DAL;
using ABSTRACTIONS;

namespace BLL
{
    /// <summary>
    /// Business Logic Layer for Organization operations
    /// Implements comprehensive business rules, validation, and orchestration logic
    /// Follows the established architecture pattern: UI -> Security -> BLL -> DAL
    /// </summary>
    public class OrganizationBLL
    {
        private readonly OrganizationDAL organizationDAL;

        public OrganizationBLL()
        {
            organizationDAL = new OrganizationDAL();
        }

        #region Organization Management Methods

        /// <summary>
        /// Creates a new organization with comprehensive validation and business rules
        /// </summary>
        /// <param name="name">Organization name</param>
        /// <param name="slug">Organization slug (URL-friendly identifier)</param>
        /// <param name="description">Organization description</param>
        /// <param name="ownerId">ID of the organization owner</param>
        /// <param name="createdBy">ID of the user creating the organization</param>
        /// <returns>DatabaseResult with the new organization ID</returns>
        public DatabaseResult<int> CreateOrganization(string name, string slug, string description, int ownerId, int createdBy)
        {
            try
            {
                // Business rule: Validate input parameters
                var validationResult = ValidateOrganizationCreation(name, slug, description, ownerId, createdBy);
                if (!validationResult.IsSuccessful)
                    return DatabaseResult<int>.Failure(validationResult.ErrorMessage);

                // Business rule: Sanitize input data
                var organization = new Organization
                {
                    Name = name,
                    Slug = slug,
                    Description = description,
                    OwnerId = ownerId
                };
                organization.SanitizeOrganization();

                // Business rule: Additional validation after sanitization
                var entityValidation = organization.ValidateOrganization();
                if (!entityValidation.IsValid)
                    return DatabaseResult<int>.Failure(entityValidation.GetErrorMessage());

                // Business rule: Ensure slug uniqueness by checking existing organizations
                var existingBySlug = organizationDAL.GetOrganizationBySlug(organization.Slug);
                if (existingBySlug.IsSuccessful && existingBySlug.Organization != null)
                    return DatabaseResult<int>.Failure(GetLocalizedString("OrganizationSlugExists"));

                // Call DAL to create organization
                return organizationDAL.CreateOrganization(organization.Name, organization.Slug, organization.Description, organization.OwnerId, createdBy);
            }
            catch (Exception ex)
            {
                return DatabaseResult<int>.Failure($"Unexpected error in business logic: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Retrieves organization details by ID with business logic validation
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <returns>OrganizationResult with organization details</returns>
        public OrganizationResult GetOrganizationById(int organizationId)
        {
            try
            {
                // Business rule: Validate input
                if (organizationId <= 0)
                    return OrganizationResult.Failure(GetLocalizedString("InvalidOrganizationId"));

                // Call DAL
                return organizationDAL.GetOrganizationById(organizationId);
            }
            catch (Exception ex)
            {
                return OrganizationResult.Failure($"Unexpected error in business logic: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Retrieves organization details by slug with business logic validation
        /// </summary>
        /// <param name="slug">Organization slug</param>
        /// <returns>OrganizationResult with organization details</returns>
        public OrganizationResult GetOrganizationBySlug(string slug)
        {
            try
            {
                // Business rule: Validate input
                if (string.IsNullOrWhiteSpace(slug))
                    return OrganizationResult.Failure(GetLocalizedString("OrganizationSlugRequired"));

                // Business rule: Sanitize slug
                slug = slug.Trim().ToLowerInvariant();

                // Business rule: Validate slug format
                if (!IsValidSlugFormat(slug))
                    return OrganizationResult.Failure(GetLocalizedString("InvalidSlugFormat"));

                // Call DAL
                return organizationDAL.GetOrganizationBySlug(slug);
            }
            catch (Exception ex)
            {
                return OrganizationResult.Failure($"Unexpected error in business logic: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Retrieves all organizations with pagination and business logic validation
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
                // Business rule: Validate and sanitize pagination parameters
                if (pageNumber < 1) pageNumber = 1;
                if (pageSize < 1 || pageSize > 100) pageSize = 10;

                // Business rule: Validate sort parameters
                var validSortColumns = new[] { "Name", "CreatedDate", "MemberCount" };
                if (!validSortColumns.Contains(sortColumn))
                    sortColumn = "Name";

                var validSortDirections = new[] { "ASC", "DESC" };
                if (!validSortDirections.Contains(sortDirection?.ToUpperInvariant()))
                    sortDirection = "ASC";

                // Business rule: Sanitize search term
                if (!string.IsNullOrWhiteSpace(searchTerm))
                {
                    searchTerm = searchTerm.Trim();
                    // Business rule: Minimum search length
                    if (searchTerm.Length < 2)
                        searchTerm = null;
                    // Business rule: Maximum search length
                    else if (searchTerm.Length > 100)
                        searchTerm = searchTerm.Substring(0, 100);
                }

                // Call DAL
                return organizationDAL.GetAllOrganizations(pageNumber, pageSize, sortColumn, sortDirection, searchTerm);
            }
            catch (Exception ex)
            {
                return OrganizationListResult.Failure($"Unexpected error in business logic: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Updates organization with comprehensive validation and business rules
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="name">Organization name</param>
        /// <param name="slug">Organization slug</param>
        /// <param name="description">Organization description</param>
        /// <param name="modifiedBy">ID of user making the update</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult UpdateOrganization(int organizationId, string name, string slug, string description, int modifiedBy)
        {
            try
            {
                // Business rule: Validate input parameters
                var validationResult = ValidateOrganizationUpdate(organizationId, name, slug, description, modifiedBy);
                if (!validationResult.IsSuccessful)
                    return validationResult;

                // Business rule: Get existing organization for validation
                var existingResult = organizationDAL.GetOrganizationById(organizationId);
                if (!existingResult.IsSuccessful)
                    return DatabaseResult.Failure(GetLocalizedString("OrganizationNotFound"));

                // Business rule: Sanitize input data
                var organization = new Organization
                {
                    Id = organizationId,
                    Name = name,
                    Slug = slug,
                    Description = description,
                    OwnerId = existingResult.Organization.OwnerId
                };
                organization.SanitizeOrganization();

                // Business rule: Additional validation after sanitization
                var entityValidation = organization.ValidateOrganization();
                if (!entityValidation.IsValid)
                    return DatabaseResult.Failure(entityValidation.GetErrorMessage());

                // Business rule: Check slug uniqueness (excluding current organization)
                if (!string.Equals(existingResult.Organization.Slug, organization.Slug, StringComparison.OrdinalIgnoreCase))
                {
                    var existingBySlug = organizationDAL.GetOrganizationBySlug(organization.Slug);
                    if (existingBySlug.IsSuccessful && existingBySlug.Organization != null)
                        return DatabaseResult.Failure(GetLocalizedString("OrganizationSlugExists"));
                }

                // Call DAL
                return organizationDAL.UpdateOrganization(organizationId, organization.Name, organization.Slug, organization.Description, modifiedBy);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error in business logic: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Soft deletes an organization with business rule validation
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="deletedBy">ID of user performing deletion</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult DeleteOrganization(int organizationId, int deletedBy)
        {
            try
            {
                // Business rule: Validate input parameters
                if (organizationId <= 0)
                    return DatabaseResult.Failure(GetLocalizedString("InvalidOrganizationId"));

                if (deletedBy <= 0)
                    return DatabaseResult.Failure(GetLocalizedString("InvalidUserId"));

                // Business rule: Check if organization exists
                var existingResult = organizationDAL.GetOrganizationById(organizationId);
                if (!existingResult.IsSuccessful)
                    return DatabaseResult.Failure(GetLocalizedString("OrganizationNotFound"));

                // Business rule: Check if organization has active projects or dependencies
                // This would need additional implementation based on system requirements
                var hasActiveDependencies = CheckOrganizationDependencies(organizationId);
                if (hasActiveDependencies)
                    return DatabaseResult.Failure(GetLocalizedString("OrganizationHasDependencies"));

                // Call DAL
                return organizationDAL.DeleteOrganization(organizationId, deletedBy);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error in business logic: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets organizations owned by a specific user with business rule validation
        /// </summary>
        /// <param name="ownerId">Owner user ID</param>
        /// <returns>OrganizationListResult with owned organizations</returns>
        public OrganizationListResult GetOrganizationsByOwner(int ownerId)
        {
            try
            {
                // Business rule: Validate input
                if (ownerId <= 0)
                    return OrganizationListResult.Failure(GetLocalizedString("InvalidOwnerId"));

                // Call DAL
                return organizationDAL.GetOrganizationsByOwner(ownerId);
            }
            catch (Exception ex)
            {
                return OrganizationListResult.Failure($"Unexpected error in business logic: {ex.Message}", ex);
            }
        }

        #endregion

        #region Organization Member Management Methods

        /// <summary>
        /// Adds a member to an organization with business rule validation
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="userId">User ID to add</param>
        /// <param name="role">Member role</param>
        /// <param name="addedBy">ID of user adding the member</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult AddOrganizationMember(int organizationId, int userId, string role, int addedBy)
        {
            try
            {
                // Business rule: Validate input parameters
                var validationResult = ValidateMemberAddition(organizationId, userId, role, addedBy);
                if (!validationResult.IsSuccessful)
                    return validationResult;

                // Business rule: Sanitize role
                role = role?.Trim().ToLowerInvariant() ?? "member";

                // Business rule: Validate role
                if (!IsValidMemberRole(role))
                    return DatabaseResult.Failure(GetLocalizedString("InvalidMemberRole"));

                // Business rule: Check if user is trying to add themselves
                if (userId == addedBy && role == "organization_admin")
                {
                    // Allow self-promotion only if user is already a member
                    var currentRoleResult = organizationDAL.CheckUserOrganizationRole(userId, organizationId);
                    if (!currentRoleResult.IsSuccessful || !currentRoleResult.HasAccess)
                        return DatabaseResult.Failure(GetLocalizedString("CannotSelfPromoteNonMember"));
                }

                // Business rule: Check organization exists
                var orgResult = organizationDAL.GetOrganizationById(organizationId);
                if (!orgResult.IsSuccessful)
                    return DatabaseResult.Failure(GetLocalizedString("OrganizationNotFound"));

                // Call DAL
                return organizationDAL.AddOrganizationMember(organizationId, userId, role, addedBy);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error in business logic: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Removes a member from an organization with business rule validation
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="userId">User ID to remove</param>
        /// <param name="removedBy">ID of user removing the member</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult RemoveOrganizationMember(int organizationId, int userId, int removedBy)
        {
            try
            {
                // Business rule: Validate input parameters
                if (organizationId <= 0)
                    return DatabaseResult.Failure(GetLocalizedString("InvalidOrganizationId"));

                if (userId <= 0)
                    return DatabaseResult.Failure(GetLocalizedString("InvalidUserId"));

                if (removedBy <= 0)
                    return DatabaseResult.Failure(GetLocalizedString("InvalidRemoverUserId"));

                // Business rule: Check organization exists
                var orgResult = organizationDAL.GetOrganizationById(organizationId);
                if (!orgResult.IsSuccessful)
                    return DatabaseResult.Failure(GetLocalizedString("OrganizationNotFound"));

                // Business rule: Cannot remove organization owner
                if (userId == orgResult.Organization.OwnerId)
                    return DatabaseResult.Failure(GetLocalizedString("CannotRemoveOwner"));

                // Call DAL
                return organizationDAL.RemoveOrganizationMember(organizationId, userId, removedBy);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error in business logic: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets organization members with business rule validation
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="requestingUserId">ID of user requesting the data</param>
        /// <returns>OrganizationMemberListResult with member details</returns>
        public OrganizationMemberListResult GetOrganizationMembers(int organizationId, int? requestingUserId = null)
        {
            try
            {
                // Business rule: Validate input
                if (organizationId <= 0)
                    return OrganizationMemberListResult.Failure(GetLocalizedString("InvalidOrganizationId"));

                // Call DAL
                return organizationDAL.GetOrganizationMembers(organizationId, requestingUserId);
            }
            catch (Exception ex)
            {
                return OrganizationMemberListResult.Failure($"Unexpected error in business logic: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets user's organizations with business rule validation
        /// </summary>
        /// <param name="userId">User ID</param>
        /// <returns>OrganizationMemberListResult with user's organizations</returns>
        public OrganizationMemberListResult GetUserOrganizations(int userId)
        {
            try
            {
                // Business rule: Validate input
                if (userId <= 0)
                    return OrganizationMemberListResult.Failure(GetLocalizedString("InvalidUserId"));

                // Call DAL
                return organizationDAL.GetUserOrganizations(userId);
            }
            catch (Exception ex)
            {
                return OrganizationMemberListResult.Failure($"Unexpected error in business logic: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Updates member role with business rule validation
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="userId">User ID</param>
        /// <param name="newRole">New role for the member</param>
        /// <param name="updatedBy">ID of user making the update</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult UpdateMemberRole(int organizationId, int userId, string newRole, int updatedBy)
        {
            try
            {
                // Business rule: Validate input parameters
                if (organizationId <= 0)
                    return DatabaseResult.Failure(GetLocalizedString("InvalidOrganizationId"));

                if (userId <= 0)
                    return DatabaseResult.Failure(GetLocalizedString("InvalidUserId"));

                if (updatedBy <= 0)
                    return DatabaseResult.Failure(GetLocalizedString("InvalidUpdaterUserId"));

                // Business rule: Sanitize and validate role
                newRole = newRole?.Trim().ToLowerInvariant();
                if (!IsValidMemberRole(newRole))
                    return DatabaseResult.Failure(GetLocalizedString("InvalidMemberRole"));

                // Business rule: Check organization exists
                var orgResult = organizationDAL.GetOrganizationById(organizationId);
                if (!orgResult.IsSuccessful)
                    return DatabaseResult.Failure(GetLocalizedString("OrganizationNotFound"));

                // Business rule: Cannot change owner's role
                if (userId == orgResult.Organization.OwnerId)
                    return DatabaseResult.Failure(GetLocalizedString("CannotChangeOwnerRole"));

                // Call DAL
                return organizationDAL.UpdateMemberRole(organizationId, userId, newRole, updatedBy);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error in business logic: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Checks user's role in organization with business rule validation
        /// </summary>
        /// <param name="userId">User ID</param>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="requiredRole">Required role (optional)</param>
        /// <returns>UserOrganizationRoleResult with role information</returns>
        public UserOrganizationRoleResult CheckUserOrganizationRole(int userId, int organizationId, string requiredRole = null)
        {
            try
            {
                // Business rule: Validate input parameters
                if (userId <= 0)
                    return UserOrganizationRoleResult.Failure(GetLocalizedString("InvalidUserId"));

                if (organizationId <= 0)
                    return UserOrganizationRoleResult.Failure(GetLocalizedString("InvalidOrganizationId"));

                // Business rule: Sanitize required role
                if (!string.IsNullOrWhiteSpace(requiredRole))
                {
                    requiredRole = requiredRole.Trim().ToLowerInvariant();
                    var validRequiredRoles = new[] { "organization_admin", "member", "owner" };
                    if (!validRequiredRoles.Contains(requiredRole))
                        return UserOrganizationRoleResult.Failure(GetLocalizedString("InvalidRequiredRole"));
                }

                // Call DAL
                return organizationDAL.CheckUserOrganizationRole(userId, organizationId, requiredRole);
            }
            catch (Exception ex)
            {
                return UserOrganizationRoleResult.Failure($"Unexpected error in business logic: {ex.Message}", ex);
            }
        }

        #endregion

        #region Statistics Methods

        /// <summary>
        /// Gets organization statistics with business rule validation
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <returns>OrganizationStatisticsResult with detailed statistics</returns>
        public OrganizationStatisticsResult GetOrganizationStats(int organizationId)
        {
            try
            {
                // Business rule: Validate input
                if (organizationId <= 0)
                    return OrganizationStatisticsResult.Failure(GetLocalizedString("InvalidOrganizationId"));

                // Call DAL
                return organizationDAL.GetOrganizationStats(organizationId);
            }
            catch (Exception ex)
            {
                return OrganizationStatisticsResult.Failure($"Unexpected error in business logic: {ex.Message}", ex);
            }
        }

        #endregion

        #region Private Validation Methods

        /// <summary>
        /// Validates organization creation parameters
        /// </summary>
        private DatabaseResult ValidateOrganizationCreation(string name, string slug, string description, int ownerId, int createdBy)
        {
            if (string.IsNullOrWhiteSpace(name))
                return DatabaseResult.Failure(GetLocalizedString("OrganizationNameRequired"));

            if (name.Trim().Length < 2 || name.Trim().Length > 100)
                return DatabaseResult.Failure(GetLocalizedString("OrganizationNameLength"));

            if (string.IsNullOrWhiteSpace(slug))
                return DatabaseResult.Failure(GetLocalizedString("OrganizationSlugRequired"));

            if (slug.Trim().Length < 3 || slug.Trim().Length > 50)
                return DatabaseResult.Failure(GetLocalizedString("OrganizationSlugLength"));

            if (!IsValidSlugFormat(slug))
                return DatabaseResult.Failure(GetLocalizedString("InvalidSlugFormat"));

            if (!string.IsNullOrWhiteSpace(description) && description.Trim().Length > 500)
                return DatabaseResult.Failure(GetLocalizedString("OrganizationDescriptionLength"));

            if (ownerId <= 0)
                return DatabaseResult.Failure(GetLocalizedString("InvalidOwnerId"));

            if (createdBy <= 0)
                return DatabaseResult.Failure(GetLocalizedString("InvalidCreatorId"));

            return DatabaseResult.Success();
        }

        /// <summary>
        /// Validates organization update parameters
        /// </summary>
        private DatabaseResult ValidateOrganizationUpdate(int organizationId, string name, string slug, string description, int modifiedBy)
        {
            if (organizationId <= 0)
                return DatabaseResult.Failure(GetLocalizedString("InvalidOrganizationId"));

            if (string.IsNullOrWhiteSpace(name))
                return DatabaseResult.Failure(GetLocalizedString("OrganizationNameRequired"));

            if (name.Trim().Length < 2 || name.Trim().Length > 100)
                return DatabaseResult.Failure(GetLocalizedString("OrganizationNameLength"));

            if (string.IsNullOrWhiteSpace(slug))
                return DatabaseResult.Failure(GetLocalizedString("OrganizationSlugRequired"));

            if (slug.Trim().Length < 3 || slug.Trim().Length > 50)
                return DatabaseResult.Failure(GetLocalizedString("OrganizationSlugLength"));

            if (!IsValidSlugFormat(slug))
                return DatabaseResult.Failure(GetLocalizedString("InvalidSlugFormat"));

            if (!string.IsNullOrWhiteSpace(description) && description.Trim().Length > 500)
                return DatabaseResult.Failure(GetLocalizedString("OrganizationDescriptionLength"));

            if (modifiedBy <= 0)
                return DatabaseResult.Failure(GetLocalizedString("InvalidModifierId"));

            return DatabaseResult.Success();
        }

        /// <summary>
        /// Validates member addition parameters
        /// </summary>
        private DatabaseResult ValidateMemberAddition(int organizationId, int userId, string role, int addedBy)
        {
            if (organizationId <= 0)
                return DatabaseResult.Failure(GetLocalizedString("InvalidOrganizationId"));

            if (userId <= 0)
                return DatabaseResult.Failure(GetLocalizedString("InvalidUserId"));

            if (addedBy <= 0)
                return DatabaseResult.Failure(GetLocalizedString("InvalidAdderUserId"));

            return DatabaseResult.Success();
        }

        /// <summary>
        /// Validates if slug format is correct
        /// </summary>
        private bool IsValidSlugFormat(string slug)
        {
            if (string.IsNullOrWhiteSpace(slug))
                return false;

            // Business rule: Slug can only contain lowercase letters, numbers, and hyphens
            return Regex.IsMatch(slug, @"^[a-z0-9\-]+$");
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
        /// Checks if organization has active dependencies that prevent deletion
        /// </summary>
        private bool CheckOrganizationDependencies(int organizationId)
        {
            // Business rule: This would check for active projects, job postings, etc.
            // For now, we'll return false (no dependencies)
            // This should be implemented based on actual system requirements
            return false;
        }

        /// <summary>
        /// Gets localized string for error messages
        /// </summary>
        private string GetLocalizedString(string key)
        {
            try
            {
                var localizedString = HttpContext.GetGlobalResourceObject("GlobalResources", key) as string;
                return localizedString ?? key; // Return key as fallback
            }
            catch
            {
                return key; // Return key as fallback on any error
            }
        }

        #endregion

        #region Utility Methods

        /// <summary>
        /// Generates a unique slug from organization name
        /// </summary>
        /// <param name="name">Organization name</param>
        /// <returns>Generated slug</returns>
        public string GenerateSlugFromName(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
                return string.Empty;

            // Business rule: Convert name to URL-friendly slug
            string slug = name.Trim().ToLowerInvariant();
            
            // Replace spaces and special characters with hyphens
            slug = Regex.Replace(slug, @"[^a-z0-9\-]", "-");
            
            // Remove multiple consecutive hyphens
            slug = Regex.Replace(slug, @"-+", "-");
            
            // Remove leading and trailing hyphens
            slug = slug.Trim('-');

            // Business rule: Ensure slug length constraints
            if (slug.Length > 50)
                slug = slug.Substring(0, 50).TrimEnd('-');

            if (slug.Length < 3)
                slug = $"org-{Guid.NewGuid().ToString("N").Substring(0, 8)}";

            return slug;
        }

        /// <summary>
        /// Validates if a slug is available for use
        /// </summary>
        /// <param name="slug">Slug to check</param>
        /// <param name="excludeOrganizationId">Organization ID to exclude from check (for updates)</param>
        /// <returns>True if slug is available</returns>
        public bool IsSlugAvailable(string slug, int? excludeOrganizationId = null)
        {
            if (string.IsNullOrWhiteSpace(slug) || !IsValidSlugFormat(slug))
                return false;

            var existingResult = organizationDAL.GetOrganizationBySlug(slug);
            if (!existingResult.IsSuccessful || existingResult.Organization == null)
                return true;

            // If we're updating an organization, allow the current organization's slug
            return excludeOrganizationId.HasValue && existingResult.Organization.Id == excludeOrganizationId.Value;
        }

        #endregion
    }
}