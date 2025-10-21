using System;
using System.ComponentModel.DataAnnotations;

namespace ABSTRACTIONS
{
    /// <summary>
    /// Represents an organization member entity with comprehensive validation
    /// Matches the OrganizationMembers table schema and stored procedure parameters
    /// </summary>
    public class OrganizationMember
    {
        public int Id { get; set; }
        
        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "OrganizationId is required and must be positive")]
        public int OrganizationId { get; set; }
        
        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "UserId is required and must be positive")]
        public int UserId { get; set; }
        
        [Required]
        [StringLength(50, ErrorMessage = "Role cannot exceed 50 characters")]
        public string Role { get; set; }
        
        public DateTime JoinedDate { get; set; }
        public bool IsActive { get; set; }
        
        // Navigation properties for display purposes (populated from stored procedure joins)
        public string Username { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public bool IsOwner { get; set; }
        
        // Organization information for user organization listings
        public string OrganizationName { get; set; }
        public string OrganizationSlug { get; set; }
        public string OrganizationDescription { get; set; }
        public int OrganizationOwnerId { get; set; }
        public string OwnerUsername { get; set; }
        public string OwnerFullName { get; set; }
        public DateTime OrganizationCreatedDate { get; set; }
        public DateTime? OrganizationModifiedDate { get; set; }
        public int? MemberCount { get; set; }
        
        // User role context
        public string UserRole { get; set; }

        public OrganizationMember()
        {
            JoinedDate = DateTime.Now;
            IsActive = true;
            Role = "member"; // Default role
        }

        /// <summary>
        /// Validates the organization member data
        /// </summary>
        /// <returns>Validation result with error messages</returns>
        public OrganizationMemberValidationResult ValidateOrganizationMember()
        {
            var result = new OrganizationMemberValidationResult { IsValid = true };

            if (OrganizationId <= 0)
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Organization ID is required and must be positive.");
            }

            if (UserId <= 0)
            {
                result.IsValid = false;
                result.ErrorMessages.Add("User ID is required and must be positive.");
            }

            if (string.IsNullOrWhiteSpace(Role))
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Role is required.");
            }
            else if (Role != "organization_admin" && Role != "member")
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Role must be either 'organization_admin' or 'member'.");
            }

            return result;
        }

        /// <summary>
        /// Sanitizes the organization member data by trimming whitespace
        /// </summary>
        public void SanitizeOrganizationMember()
        {
            if (!string.IsNullOrWhiteSpace(Role))
            {
                Role = Role.Trim().ToLowerInvariant();
            }
        }

        /// <summary>
        /// Checks if the member has administrative privileges
        /// </summary>
        /// <returns>True if member is organization admin or owner</returns>
        public bool HasAdminPrivileges()
        {
            return IsOwner || Role == "organization_admin";
        }

        /// <summary>
        /// Gets the display name for the member's role
        /// </summary>
        /// <returns>Formatted role name</returns>
        public string GetDisplayRole()
        {
            if (IsOwner) return "Owner";
            
            switch (Role)
            {
                case "organization_admin":
                    return "Administrator";
                case "member":
                    return "Member";
                default:
                    return "Unknown";
            }
        }
    }

    /// <summary>
    /// Represents the result of organization member validation
    /// </summary>
    public class OrganizationMemberValidationResult
    {
        public bool IsValid { get; set; }
        public System.Collections.Generic.List<string> ErrorMessages { get; set; }

        public OrganizationMemberValidationResult()
        {
            ErrorMessages = new System.Collections.Generic.List<string>();
        }

        public string GetErrorMessage()
        {
            return ErrorMessages.Count > 0 ? string.Join("; ", ErrorMessages) : string.Empty;
        }
    }

    /// <summary>
    /// Represents the result of an organization member operation with detailed error information
    /// </summary>
    public class OrganizationMemberResult : DatabaseResult
    {
        public OrganizationMember OrganizationMember { get; set; }

        public OrganizationMemberResult() : base()
        {
        }

        public OrganizationMemberResult(bool isSuccessful, string errorMessage = "", OrganizationMember organizationMember = null) : base(isSuccessful, 0, errorMessage)
        {
            OrganizationMember = organizationMember;
        }

        public static OrganizationMemberResult Success(OrganizationMember organizationMember)
        {
            return new OrganizationMemberResult(true, "Success", organizationMember);
        }

        public static OrganizationMemberResult Success(OrganizationMember organizationMember, string message)
        {
            return new OrganizationMemberResult(true, message, organizationMember);
        }

        public static OrganizationMemberResult Failure(string errorMessage)
        {
            return new OrganizationMemberResult(false, errorMessage);
        }

        public static new OrganizationMemberResult Failure(string errorMessage, Exception exception)
        {
            return new OrganizationMemberResult(false, errorMessage) { Exception = exception };
        }
    }

    /// <summary>
    /// Represents the result of organization member list operations
    /// </summary>
    public class OrganizationMemberListResult : DatabaseResult<System.Collections.Generic.List<OrganizationMember>>
    {
        public OrganizationMemberListResult() : base()
        {
            Data = new System.Collections.Generic.List<OrganizationMember>();
        }

        public OrganizationMemberListResult(bool isSuccessful, System.Collections.Generic.List<OrganizationMember> members, string message = "") : base(isSuccessful, members, 0, message)
        {
        }

        public static new OrganizationMemberListResult Success(System.Collections.Generic.List<OrganizationMember> members)
        {
            return new OrganizationMemberListResult(true, members, "Success");
        }

        public static new OrganizationMemberListResult Success(System.Collections.Generic.List<OrganizationMember> members, string message)
        {
            return new OrganizationMemberListResult(true, members, message);
        }

        public static OrganizationMemberListResult Failure(string errorMessage)
        {
            return new OrganizationMemberListResult(false, new System.Collections.Generic.List<OrganizationMember>(), errorMessage);
        }

        public static new OrganizationMemberListResult Failure(string errorMessage, Exception exception)
        {
            return new OrganizationMemberListResult(false, new System.Collections.Generic.List<OrganizationMember>(), errorMessage) { Exception = exception };
        }
    }

    /// <summary>
    /// Represents the result of checking user's organization role
    /// Matches the sp_CheckUserOrganizationRole result set
    /// </summary>
    public class UserOrganizationRoleResult : DatabaseResult
    {
        public bool HasAccess { get; set; }
        public bool IsOwner { get; set; }
        public string Role { get; set; }
        public int UserId { get; set; }
        public int OrganizationId { get; set; }

        public UserOrganizationRoleResult() : base()
        {
            HasAccess = false;
            IsOwner = false;
            Role = string.Empty;
        }

        public UserOrganizationRoleResult(bool isSuccessful, bool hasAccess, bool isOwner, string role, int userId, int organizationId, string message = "") 
            : base(isSuccessful, 0, message)
        {
            HasAccess = hasAccess;
            IsOwner = isOwner;
            Role = role ?? string.Empty;
            UserId = userId;
            OrganizationId = organizationId;
        }

        public static UserOrganizationRoleResult Success(bool hasAccess, bool isOwner, string role, int userId, int organizationId)
        {
            return new UserOrganizationRoleResult(true, hasAccess, isOwner, role, userId, organizationId, "Success");
        }

        public static UserOrganizationRoleResult Failure(string errorMessage)
        {
            return new UserOrganizationRoleResult(false, false, false, string.Empty, 0, 0, errorMessage);
        }

        public static new UserOrganizationRoleResult Failure(string errorMessage, Exception exception)
        {
            var result = new UserOrganizationRoleResult(false, false, false, string.Empty, 0, 0, errorMessage);
            result.Exception = exception;
            return result;
        }

        /// <summary>
        /// Gets the display name for the user's role in the organization
        /// </summary>
        /// <returns>Formatted role name</returns>
        public string GetDisplayRole()
        {
            if (IsOwner) return "Owner";
            
            switch (Role)
            {
                case "organization_admin":
                    return "Administrator";
                case "member":
                    return "Member";
                case "owner":
                    return "Owner";
                default:
                    return "Not a Member";
            }
        }

        /// <summary>
        /// Checks if the user has administrative privileges in the organization
        /// </summary>
        /// <returns>True if user is owner or organization admin</returns>
        public bool HasAdminPrivileges()
        {
            return IsOwner || Role == "organization_admin" || Role == "owner";
        }
    }
}