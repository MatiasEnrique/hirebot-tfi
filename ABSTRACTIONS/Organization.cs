using System;
using System.ComponentModel.DataAnnotations;

namespace ABSTRACTIONS
{
    /// <summary>
    /// Represents an organization entity with comprehensive validation
    /// Matches the Organizations table schema and stored procedure parameters
    /// </summary>
    public class Organization
    {
        public int Id { get; set; }
        
        [Required]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Organization name must be between 2 and 100 characters")]
        public string Name { get; set; }
        
        [Required]
        [StringLength(50, MinimumLength = 3, ErrorMessage = "Organization slug must be between 3 and 50 characters")]
        [RegularExpression(@"^[a-zA-Z0-9\-]+$", ErrorMessage = "Slug can only contain letters, numbers, and hyphens")]
        public string Slug { get; set; }
        
        [StringLength(500, ErrorMessage = "Description cannot exceed 500 characters")]
        public string Description { get; set; }
        
        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "OwnerId is required and must be positive")]
        public int OwnerId { get; set; }
        
        public DateTime CreatedDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public bool IsActive { get; set; }
        
        // Navigation properties for display purposes (populated from stored procedure joins)
        public string OwnerUsername { get; set; }
        public string OwnerFullName { get; set; }
        public int? MemberCount { get; set; }
        
        // Pagination properties for stored procedure results
        public int? TotalCount { get; set; }
        public int? TotalPages { get; set; }
        public int? RowNum { get; set; }

        public Organization()
        {
            CreatedDate = DateTime.Now;
            IsActive = true;
        }

        /// <summary>
        /// Validates the organization data
        /// </summary>
        /// <returns>Validation result with error messages</returns>
        public OrganizationValidationResult ValidateOrganization()
        {
            var result = new OrganizationValidationResult { IsValid = true };

            if (string.IsNullOrWhiteSpace(Name))
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Organization name is required.");
            }
            else if (Name.Trim().Length < 2)
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Organization name must be at least 2 characters long.");
            }
            else if (Name.Trim().Length > 100)
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Organization name cannot exceed 100 characters.");
            }

            if (string.IsNullOrWhiteSpace(Slug))
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Organization slug is required.");
            }
            else if (Slug.Trim().Length < 3)
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Organization slug must be at least 3 characters long.");
            }
            else if (Slug.Trim().Length > 50)
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Organization slug cannot exceed 50 characters.");
            }
            else if (!System.Text.RegularExpressions.Regex.IsMatch(Slug, @"^[a-zA-Z0-9\-]+$"))
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Slug can only contain letters, numbers, and hyphens.");
            }

            if (!string.IsNullOrWhiteSpace(Description) && Description.Trim().Length > 500)
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Description cannot exceed 500 characters.");
            }

            if (OwnerId <= 0)
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Owner ID is required and must be positive.");
            }

            return result;
        }

        /// <summary>
        /// Sanitizes the organization data by trimming whitespace and basic cleanup
        /// </summary>
        public void SanitizeOrganization()
        {
            if (!string.IsNullOrWhiteSpace(Name))
            {
                Name = Name.Trim();
                // Remove multiple consecutive whitespaces
                Name = System.Text.RegularExpressions.Regex.Replace(Name, @"\s+", " ");
            }

            if (!string.IsNullOrWhiteSpace(Slug))
            {
                Slug = Slug.Trim().ToLowerInvariant();
                // Ensure slug format consistency
                Slug = System.Text.RegularExpressions.Regex.Replace(Slug, @"[^a-zA-Z0-9\-]", "-");
                Slug = System.Text.RegularExpressions.Regex.Replace(Slug, @"-+", "-");
                Slug = Slug.Trim('-');
            }

            if (!string.IsNullOrWhiteSpace(Description))
            {
                Description = Description.Trim();
                // Remove multiple consecutive whitespaces
                Description = System.Text.RegularExpressions.Regex.Replace(Description, @"\s+", " ");
            }
        }
    }

    /// <summary>
    /// Represents the result of organization validation
    /// </summary>
    public class OrganizationValidationResult
    {
        public bool IsValid { get; set; }
        public System.Collections.Generic.List<string> ErrorMessages { get; set; }

        public OrganizationValidationResult()
        {
            ErrorMessages = new System.Collections.Generic.List<string>();
        }

        public string GetErrorMessage()
        {
            return ErrorMessages.Count > 0 ? string.Join("; ", ErrorMessages) : string.Empty;
        }
    }

    /// <summary>
    /// Represents the result of an organization operation with detailed error information
    /// </summary>
    public class OrganizationResult : DatabaseResult
    {
        public Organization Organization { get; set; }

        public OrganizationResult() : base()
        {
        }

        public OrganizationResult(bool isSuccessful, string errorMessage = "", Organization organization = null) : base(isSuccessful, 0, errorMessage)
        {
            Organization = organization;
        }

        public static OrganizationResult Success(Organization organization)
        {
            return new OrganizationResult(true, "Success", organization);
        }

        public static OrganizationResult Success(Organization organization, string message)
        {
            return new OrganizationResult(true, message, organization);
        }

        public static OrganizationResult Failure(string errorMessage)
        {
            return new OrganizationResult(false, errorMessage);
        }

        public static new OrganizationResult Failure(string errorMessage, Exception exception)
        {
            return new OrganizationResult(false, errorMessage) { Exception = exception };
        }
    }

    /// <summary>
    /// Represents the result of organization list operations
    /// </summary>
    public class OrganizationListResult : DatabaseResult<System.Collections.Generic.List<Organization>>
    {
        public OrganizationListResult() : base()
        {
            Data = new System.Collections.Generic.List<Organization>();
        }

        public OrganizationListResult(bool isSuccessful, System.Collections.Generic.List<Organization> organizations, string message = "") : base(isSuccessful, organizations, 0, message)
        {
        }

        public static new OrganizationListResult Success(System.Collections.Generic.List<Organization> organizations)
        {
            return new OrganizationListResult(true, organizations, "Success");
        }

        public static new OrganizationListResult Success(System.Collections.Generic.List<Organization> organizations, string message)
        {
            return new OrganizationListResult(true, organizations, message);
        }

        public static OrganizationListResult Failure(string errorMessage)
        {
            return new OrganizationListResult(false, new System.Collections.Generic.List<Organization>(), errorMessage);
        }

        public static new OrganizationListResult Failure(string errorMessage, Exception exception)
        {
            return new OrganizationListResult(false, new System.Collections.Generic.List<Organization>(), errorMessage) { Exception = exception };
        }
    }

    /// <summary>
    /// Statistics for organizations - matches sp_GetOrganizationStats result set
    /// </summary>
    public class OrganizationStatistics
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Slug { get; set; }
        public string Description { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public string OwnerUsername { get; set; }
        public string OwnerFullName { get; set; }
        public int TotalMembers { get; set; }
        public int AdminCount { get; set; }
        public int RegularMemberCount { get; set; }
        public DateTime? FirstMemberJoinDate { get; set; }
        public DateTime? LastMemberJoinDate { get; set; }
    }

    /// <summary>
    /// Represents the result of organization statistics operations
    /// </summary>
    public class OrganizationStatisticsResult : DatabaseResult<OrganizationStatistics>
    {
        public OrganizationStatisticsResult() : base()
        {
        }

        public OrganizationStatisticsResult(bool isSuccessful, OrganizationStatistics statistics, string message = "") : base(isSuccessful, statistics, 0, message)
        {
        }

        public static new OrganizationStatisticsResult Success(OrganizationStatistics statistics)
        {
            return new OrganizationStatisticsResult(true, statistics, "Success");
        }

        public static new OrganizationStatisticsResult Success(OrganizationStatistics statistics, string message)
        {
            return new OrganizationStatisticsResult(true, statistics, message);
        }

        public static OrganizationStatisticsResult Failure(string errorMessage)
        {
            return new OrganizationStatisticsResult(false, null, errorMessage);
        }

        public static new OrganizationStatisticsResult Failure(string errorMessage, Exception exception)
        {
            return new OrganizationStatisticsResult(false, null, errorMessage) { Exception = exception };
        }
    }
}