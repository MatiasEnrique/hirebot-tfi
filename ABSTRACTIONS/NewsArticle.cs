using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;
using System.Text.RegularExpressions;

namespace ABSTRACTIONS
{
    /// <summary>
    /// Represents a news article published through the Hirebot platform.
    /// </summary>
    public class NewsArticle
    {
        public int NewsId { get; set; }

        [Required]
        [StringLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
        public string Title { get; set; }

        [StringLength(200, ErrorMessage = "Slug cannot exceed 200 characters")]
        public string Slug { get; set; }

        [StringLength(500, ErrorMessage = "Summary cannot exceed 500 characters")]
        public string Summary { get; set; }

        [Required]
        public string Content { get; set; }

        [StringLength(5, ErrorMessage = "Language code must be at most 5 characters")]
        public string LanguageCode { get; set; }

        [StringLength(512, ErrorMessage = "Hero image URL cannot exceed 512 characters")]
        public string HeroImageUrl { get; set; }

        public int CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public int? LastModifiedBy { get; set; }
        public DateTime? LastModifiedDate { get; set; }
        public DateTime? PublishedDate { get; set; }
        public bool IsPublished { get; set; }
        public bool IsArchived { get; set; }
        public int ViewCount { get; set; }

        // Metadata for UI display purposes
        public string CreatedByUsername { get; set; }
        public string CreatedByFullName { get; set; }
        public string ModifiedByUsername { get; set; }
        public string ModifiedByFullName { get; set; }

        // Pagination helper returned by stored procedures
        public int? TotalRecords { get; set; }

        public NewsArticle()
        {
            LanguageCode = "es";
            CreatedDate = DateTime.UtcNow;
            ViewCount = 0;
            IsPublished = false;
            IsArchived = false;
        }

        /// <summary>
        /// Performs basic sanitization before persisting the article.
        /// </summary>
        public void Sanitize()
        {
            Title = Title?.Trim();
            Slug = Slug?.Trim();
            Summary = Summary?.Trim();
            LanguageCode = string.IsNullOrWhiteSpace(LanguageCode) ? "es" : LanguageCode.Trim().ToLowerInvariant();
            HeroImageUrl = HeroImageUrl?.Trim();

            if (!string.IsNullOrWhiteSpace(Content))
            {
                Content = Content.Trim();
            }
        }

        /// <summary>
        /// Generates a slug based on the current title if one is not provided.
        /// </summary>
        public void EnsureSlug()
        {
            if (!string.IsNullOrWhiteSpace(Slug))
            {
                Slug = NormalizeSlug(Slug);
                return;
            }

            if (string.IsNullOrWhiteSpace(Title))
            {
                return;
            }

            Slug = NormalizeSlug(Title);
        }

        private static string NormalizeSlug(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return string.Empty;
            }

            string normalized = value.Trim().ToLowerInvariant();
            normalized = normalized.Normalize(NormalizationForm.FormD);

            // Remove diacritics
            normalized = Regex.Replace(normalized, "\\p{IsCombiningDiacriticalMarks}+", string.Empty);

            // Replace non-alphanumeric characters with dashes
            normalized = Regex.Replace(normalized, "[^a-z0-9]+", "-");
            normalized = Regex.Replace(normalized, "-+", "-");

            normalized = normalized.Trim('-');

            if (normalized.Length > 200)
            {
                normalized = normalized.Substring(0, 200).Trim('-');
            }

            if (string.IsNullOrEmpty(normalized))
            {
                normalized = $"news-{Guid.NewGuid():N}";
            }

            return normalized;
        }

        /// <summary>
        /// Validates that the article contains the minimum information required to be saved.
        /// </summary>
        public NewsArticleValidationResult Validate()
        {
            var result = new NewsArticleValidationResult();

            if (string.IsNullOrWhiteSpace(Title))
            {
                result.AddError("Title is required.");
            }
            else if (Title.Trim().Length > 200)
            {
                result.AddError("Title cannot exceed 200 characters.");
            }

            if (string.IsNullOrWhiteSpace(Content))
            {
                result.AddError("Content is required.");
            }

            if (!string.IsNullOrWhiteSpace(Summary) && Summary.Trim().Length > 500)
            {
                result.AddError("Summary cannot exceed 500 characters.");
            }

            if (!string.IsNullOrWhiteSpace(HeroImageUrl) && HeroImageUrl.Trim().Length > 512)
            {
                result.AddError("Hero image URL cannot exceed 512 characters.");
            }

            if (!string.IsNullOrWhiteSpace(LanguageCode) && LanguageCode.Trim().Length > 5)
            {
                result.AddError("Language code cannot exceed 5 characters.");
            }

            return result;
        }
    }

    /// <summary>
    /// Represents the outcome of validating a news article.
    /// </summary>
    public class NewsArticleValidationResult
    {
        public bool IsValid => Errors.Count == 0;
        public List<string> Errors { get; }

        public NewsArticleValidationResult()
        {
            Errors = new List<string>();
        }

        public void AddError(string message)
        {
            if (!string.IsNullOrWhiteSpace(message))
            {
                Errors.Add(message);
            }
        }

        public string GetErrorMessage()
        {
            return Errors.Count == 0 ? string.Empty : string.Join("; ", Errors);
        }
    }

    /// <summary>
    /// Encapsulates search criteria for retrieving news articles.
    /// </summary>
        public class NewsSearchCriteria
    {
        private static readonly HashSet<string> AllowedSortColumns = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "PublishedDate",
            "CreatedDate",
            "Title"
        };

        private static readonly HashSet<string> AllowedSortDirections = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "ASC",
            "DESC"
        };

        private static readonly HashSet<string> AllowedStatusFilters = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "All",
            "Published",
            "Unpublished",
            "Archived"
        };

        public string SearchTerm { get; set; }
        public string LanguageCode { get; set; }
        public bool IncludeUnpublished { get; set; }
        public bool IncludeArchived { get; set; }
        public int PageNumber { get; set; } = 1;
        public int PageSize { get; set; } = 10;
        public string SortColumn { get; set; } = "PublishedDate";
        public string SortDirection { get; set; } = "DESC";
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string StatusFilter { get; set; } = "All";

        public void Normalize()
        {
            if (PageNumber < 1)
            {
                PageNumber = 1;
            }

            if (PageSize < 1)
            {
                PageSize = 10;
            }
            else if (PageSize > 100)
            {
                PageSize = 100;
            }

            if (string.IsNullOrWhiteSpace(SortColumn) || !AllowedSortColumns.Contains(SortColumn))
            {
                SortColumn = "PublishedDate";
            }

            if (string.IsNullOrWhiteSpace(SortDirection) || !AllowedSortDirections.Contains(SortDirection))
            {
                SortDirection = "DESC";
            }

            LanguageCode = string.IsNullOrWhiteSpace(LanguageCode) ? null : LanguageCode.Trim().ToLowerInvariant();
            SearchTerm = string.IsNullOrWhiteSpace(SearchTerm) ? null : SearchTerm.Trim();

            if (string.IsNullOrWhiteSpace(StatusFilter) || !AllowedStatusFilters.Contains(StatusFilter))
            {
                StatusFilter = "All";
            }
            else
            {
                StatusFilter = StatusFilter.Trim();
            }
        }
    }

    /// <summary>
    /// Represents the result of operations returning a single news article.
    /// </summary>
    public class NewsArticleResult : DatabaseResult<NewsArticle>
    {
        public new static NewsArticleResult Success(NewsArticle article, string message = "Success")
        {
            return new NewsArticleResult
            {
                IsSuccessful = true,
                ResultCode = 1,
                ErrorMessage = message,
                Data = article
            };
        }

        public new static NewsArticleResult Failure(string errorMessage, Exception exception = null)
        {
            return new NewsArticleResult
            {
                IsSuccessful = false,
                ResultCode = -1,
                ErrorMessage = errorMessage,
                Exception = exception,
                Data = null
            };
        }
    }

    /// <summary>
    /// Represents the result of operations returning multiple news articles.
    /// </summary>
    public class NewsArticleListResult : DatabaseResult<List<NewsArticle>>
    {
        public int TotalRecords { get; set; }

        public NewsArticleListResult()
        {
            Data = new List<NewsArticle>();
            TotalRecords = 0;
        }

        public static NewsArticleListResult Success(List<NewsArticle> articles, int totalRecords, string message = "Success")
        {
            return new NewsArticleListResult
            {
                IsSuccessful = true,
                ResultCode = 1,
                ErrorMessage = message,
                Data = articles ?? new List<NewsArticle>(),
                TotalRecords = totalRecords
            };
        }

        public new static NewsArticleListResult Failure(string errorMessage, Exception exception = null)
        {
            return new NewsArticleListResult
            {
                IsSuccessful = false,
                ResultCode = -1,
                ErrorMessage = errorMessage,
                Exception = exception,
                Data = new List<NewsArticle>(),
                TotalRecords = 0
            };
        }
    }
}



