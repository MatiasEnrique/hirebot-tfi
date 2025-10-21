using System;
using System.ComponentModel.DataAnnotations;

namespace ABSTRACTIONS
{
    /// <summary>
    /// Represents a product comment/review entity with comprehensive validation
    /// </summary>
    public class Comment
    {
        public int CommentId { get; set; }
        
        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "ProductId is required and must be positive")]
        public int ProductId { get; set; }
        
        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "UserId is required and must be positive")]
        public int UserId { get; set; }
        
        [Required]
        [StringLength(2000, MinimumLength = 10, ErrorMessage = "Comment must be between 10 and 2000 characters")]
        public string CommentText { get; set; }
        
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
        public byte? Rating { get; set; }
        
        public DateTime CreatedDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public bool IsActive { get; set; }
        public bool IsApproved { get; set; }
        
        // Navigation properties for display purposes
        public string Username { get; set; }
        public string UserFullName { get; set; }
        public string UserEmail { get; set; }
        public string ProductName { get; set; }
        public string ProductDescription { get; set; }
        
        // Pagination properties for stored procedure results
        public int? TotalComments { get; set; }
        public int? TotalPages { get; set; }

        public Comment()
        {
            CreatedDate = DateTime.Now;
            IsActive = true;
            IsApproved = false; // Comments require approval by default
        }

        /// <summary>
        /// Validates the comment data
        /// </summary>
        /// <returns>Validation result with error messages</returns>
        public CommentValidationResult ValidateComment()
        {
            var result = new CommentValidationResult { IsValid = true };

            if (ProductId <= 0)
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Product ID is required and must be positive.");
            }

            if (UserId <= 0)
            {
                result.IsValid = false;
                result.ErrorMessages.Add("User ID is required and must be positive.");
            }

            if (string.IsNullOrWhiteSpace(CommentText))
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Comment text is required.");
            }
            else if (CommentText.Trim().Length < 10)
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Comment must be at least 10 characters long.");
            }
            else if (CommentText.Trim().Length > 2000)
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Comment cannot exceed 2000 characters.");
            }

            if (Rating.HasValue && (Rating.Value < 1 || Rating.Value > 5))
            {
                result.IsValid = false;
                result.ErrorMessages.Add("Rating must be between 1 and 5 stars.");
            }

            return result;
        }

        /// <summary>
        /// Sanitizes the comment text by trimming whitespace and basic cleanup
        /// </summary>
        public void SanitizeComment()
        {
            if (!string.IsNullOrWhiteSpace(CommentText))
            {
                CommentText = CommentText.Trim();
                // Remove multiple consecutive whitespaces
                CommentText = System.Text.RegularExpressions.Regex.Replace(CommentText, @"\s+", " ");
            }
        }
    }

    /// <summary>
    /// Represents the result of comment validation
    /// </summary>
    public class CommentValidationResult
    {
        public bool IsValid { get; set; }
        public System.Collections.Generic.List<string> ErrorMessages { get; set; }

        public CommentValidationResult()
        {
            ErrorMessages = new System.Collections.Generic.List<string>();
        }

        public string GetErrorMessage()
        {
            return ErrorMessages.Count > 0 ? string.Join("; ", ErrorMessages) : string.Empty;
        }
    }

    /// <summary>
    /// Represents the result of a comment operation with detailed error information
    /// </summary>
    public class CommentResult : DatabaseResult
    {
        public Comment Comment { get; set; }

        public CommentResult() : base()
        {
        }

        public CommentResult(bool isSuccessful, string errorMessage = "", Comment comment = null) : base(isSuccessful, 0, errorMessage)
        {
            Comment = comment;
        }

        public static CommentResult Success(Comment comment)
        {
            return new CommentResult(true, "Success", comment);
        }

        public static CommentResult Success(Comment comment, string message)
        {
            return new CommentResult(true, message, comment);
        }

        public static CommentResult Failure(string errorMessage)
        {
            return new CommentResult(false, errorMessage);
        }

        public static new CommentResult Failure(string errorMessage, Exception exception)
        {
            return new CommentResult(false, errorMessage) { Exception = exception };
        }
    }

    /// <summary>
    /// Represents the result of comment list operations
    /// </summary>
    public class CommentListResult : DatabaseResult<System.Collections.Generic.List<Comment>>
    {
        public CommentListResult() : base()
        {
            Data = new System.Collections.Generic.List<Comment>();
        }

        public CommentListResult(bool isSuccessful, System.Collections.Generic.List<Comment> comments, string message = "") : base(isSuccessful, comments, 0, message)
        {
        }

        public static new CommentListResult Success(System.Collections.Generic.List<Comment> comments)
        {
            return new CommentListResult(true, comments, "Success");
        }

        public static new CommentListResult Success(System.Collections.Generic.List<Comment> comments, string message)
        {
            return new CommentListResult(true, comments, message);
        }

        public static CommentListResult Failure(string errorMessage)
        {
            return new CommentListResult(false, new System.Collections.Generic.List<Comment>(), errorMessage);
        }

        public static new CommentListResult Failure(string errorMessage, Exception exception)
        {
            return new CommentListResult(false, new System.Collections.Generic.List<Comment>(), errorMessage) { Exception = exception };
        }
    }

    /// <summary>
    /// Statistics for comments on a product - matches sp_ProductComment_GetStatistics result set
    /// </summary>
    public class CommentStatistics
    {
        public int? ProductId { get; set; }
        public int TotalComments { get; set; }
        public int ApprovedComments { get; set; }
        public int PendingComments { get; set; }
        public int CommentsWithRating { get; set; }
        public decimal? AverageRating { get; set; }
        public int OneStarCount { get; set; }
        public int TwoStarCount { get; set; }
        public int ThreeStarCount { get; set; }
        public int FourStarCount { get; set; }
        public int FiveStarCount { get; set; }
        public DateTime? FirstCommentDate { get; set; }
        public DateTime? LastCommentDate { get; set; }
        
        // Legacy properties for backward compatibility
        public int TotalRatedComments
        {
            get { return CommentsWithRating; }
        }
    }
}
