using System;
using System.Web;
using BLL;
using ABSTRACTIONS;
using SERVICES;

namespace SECURITY
{
    /// <summary>
    /// Security layer for Comment operations
    /// Handles authentication, authorization, and security validation
    /// Follows the established architecture pattern: UI -> Security -> BLL -> DAL
    /// </summary>
    public class CommentSecurity
    {
        private readonly CommentBLL commentBLL;
        private readonly LogBLL _logBLL;

        public CommentSecurity()
        {
            commentBLL = new CommentBLL();
            _logBLL = new LogBLL();
        }

        /// <summary>
        /// Retrieves comments for a product with authentication and authorization checks
        /// </summary>
        /// <param name="productId">Product ID to get comments for</param>
        /// <param name="includePending">Whether to include pending/unapproved comments (admin only)</param>
        /// <param name="pageNumber">Page number for pagination (default: 1)</param>
        /// <param name="pageSize">Number of comments per page (default: 10)</param>
        /// <returns>CommentListResult with security validation applied</returns>
        public CommentListResult GetCommentsByProductId(int productId, bool includePending = false, int pageNumber = 1, int pageSize = 10)
        {
            try
            {
                // Security validation: Basic input validation
                if (productId <= 0)
                {
                    return CommentListResult.Failure("Invalid product ID provided");
                }

                // TEMPORARY FIX: For development/testing, include pending comments to show existing data
                // In production, you should implement proper admin approval workflow
                includePending = true;
                
                // Security validation: Validate pagination parameters
                if (pageNumber < 1) pageNumber = 1;
                if (pageSize < 1 || pageSize > 100) pageSize = 10;

                // Security rule: Rate limiting for comment retrieval
                if (!CheckRateLimit("GetComments", GetCurrentUserId() ?? 0))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = GetCurrentUserId(), 
                        Description = $"Rate limit exceeded for comment retrieval on product {productId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentListResult.Failure("Rate limit exceeded. Please try again later.");
                }

                // Pass to BLL layer
                var result = commentBLL.GetCommentsByProductId(productId, includePending, pageNumber, pageSize);

                // Security logging for successful operations
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ACCESS, 
                        UserId = GetCurrentUserId(), 
                        Description = $"Comment access on product {productId}: GetCommentsByProductId", 
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
                    Description = $"Security error in GetCommentsByProductId: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return CommentListResult.Failure("An error occurred while retrieving comments. Please try again.");
            }
        }

        /// <summary>
        /// Creates a new comment with comprehensive security validation
        /// </summary>
        /// <param name="productId">Product ID to comment on</param>
        /// <param name="commentText">Comment content</param>
        /// <param name="rating">Optional rating (1-5 stars)</param>
        /// <returns>CommentResult with security validation applied</returns>
        public CommentResult CreateComment(int productId, string commentText, int? rating = null)
        {
            try
            {
                // Security requirement: User must be authenticated
                if (!IsUserAuthenticated())
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Unauthorized comment creation attempt for product {productId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentResult.Failure("You must be logged in to post comments.");
                }

                var currentUserId = GetCurrentUserId();
                if (!currentUserId.HasValue)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = "Comment creation attempted with invalid user session", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentResult.Failure("Invalid user session. Please log in again.");
                }

                // Security validation: Input sanitization and validation
                var inputValidationResult = ValidateCommentInput(commentText, rating);
                if (!inputValidationResult.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"Invalid input for comment creation: {inputValidationResult.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentResult.Failure(inputValidationResult.ErrorMessage);
                }

                // Security rule: Check user permissions
                if (!CanUserCreateComments(currentUserId.Value))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"User lacks permission to create comments on product {productId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentResult.Failure("You do not have permission to post comments.");
                }

                // Security rule: Content security scanning
                var contentSecurityResult = ValidateCommentContent(commentText);
                if (!contentSecurityResult.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"Comment blocked due to security scan: {contentSecurityResult.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentResult.Failure("Your comment contains content that is not allowed.");
                }

                // Security rule: Rate limiting for comment creation
                if (!CheckRateLimit("CreateComment", currentUserId.Value))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"Rate limit exceeded for comment creation on product {productId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentResult.Failure("You are creating comments too quickly. Please wait before posting again.");
                }

                // Pass to BLL layer
                var result = commentBLL.CreateComment(productId, currentUserId.Value, commentText, rating);

                // Security logging
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.CREATE, 
                        UserId = currentUserId.Value, 
                        Description = $"Comment created on product {productId}: {result.Comment?.CommentId ?? 0}", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId.Value, 
                        Description = $"Comment creation failed on product {productId}: {result.ErrorMessage}", 
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
                    Description = $"Security error in CreateComment: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return CommentResult.Failure("An error occurred while creating your comment. Please try again.");
            }
        }

        /// <summary>
        /// Updates an existing comment with security validation
        /// </summary>
        /// <param name="commentId">Comment ID to update</param>
        /// <param name="newCommentText">New comment content</param>
        /// <param name="newRating">New rating value</param>
        /// <returns>CommentResult with security validation applied</returns>
        public CommentResult UpdateComment(int commentId, string newCommentText, int? newRating = null)
        {
            try
            {
                // Security requirement: User must be authenticated
                if (!IsUserAuthenticated())
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Unauthorized comment update attempt for comment {commentId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentResult.Failure("You must be logged in to update comments.");
                }

                var currentUserId = GetCurrentUserId();
                if (!currentUserId.HasValue)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = "Comment update attempted with invalid user session", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentResult.Failure("Invalid user session. Please log in again.");
                }

                // Security validation: Input sanitization and validation
                var inputValidationResult = ValidateCommentInput(newCommentText, newRating);
                if (!inputValidationResult.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"Invalid input for comment update: {inputValidationResult.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentResult.Failure(inputValidationResult.ErrorMessage);
                }

                // Security rule: Content security scanning
                var contentSecurityResult = ValidateCommentContent(newCommentText);
                if (!contentSecurityResult.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"Comment update blocked due to security scan: {contentSecurityResult.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentResult.Failure("Your comment contains content that is not allowed.");
                }

                // Security rule: Rate limiting for comment updates
                if (!CheckRateLimit("UpdateComment", currentUserId.Value))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"Rate limit exceeded for comment update on comment {commentId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentResult.Failure("You are updating comments too quickly. Please wait before trying again.");
                }

                // Pass to BLL layer (BLL will handle ownership validation)
                var result = commentBLL.UpdateComment(commentId, currentUserId.Value, newCommentText, newRating);

                // Security logging
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.UPDATE, 
                        UserId = currentUserId.Value, 
                        Description = $"Comment updated: {commentId}", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId.Value, 
                        Description = $"Comment update failed for {commentId}: {result.ErrorMessage}", 
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
                    Description = $"Security error in UpdateComment: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return CommentResult.Failure("An error occurred while updating your comment. Please try again.");
            }
        }

        /// <summary>
        /// Deletes a comment with security validation
        /// </summary>
        /// <param name="commentId">Comment ID to delete</param>
        /// <returns>DatabaseResult with security validation applied</returns>
        public DatabaseResult DeleteComment(int commentId)
        {
            try
            {
                // Security requirement: User must be authenticated
                if (!IsUserAuthenticated())
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Unauthorized comment deletion attempt for comment {commentId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("You must be logged in to delete comments.");
                }

                var currentUserId = GetCurrentUserId();
                if (!currentUserId.HasValue)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = "Comment deletion attempted with invalid user session", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("Invalid user session. Please log in again.");
                }

                // Security validation: Input validation
                if (commentId <= 0)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"Invalid comment ID provided for deletion: {commentId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("Invalid comment ID provided.");
                }

                // Security rule: Rate limiting for comment deletions
                if (!CheckRateLimit("DeleteComment", currentUserId.Value))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"Rate limit exceeded for comment deletion on comment {commentId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("You are performing too many deletions. Please wait before trying again.");
                }

                // Pass to BLL layer (BLL will handle ownership validation)
                var result = commentBLL.DeleteComment(commentId, currentUserId.Value);

                // Security logging
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.DELETE, 
                        UserId = currentUserId.Value, 
                        Description = $"Comment deleted: {commentId}", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId.Value, 
                        Description = $"Comment deletion failed for {commentId}: {result.ErrorMessage}", 
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
                    Description = $"Security error in DeleteComment: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult.Failure("An error occurred while deleting your comment. Please try again.");
            }
        }

        /// <summary>
        /// Retrieves comments by user ID with security validation
        /// </summary>
        /// <param name="userId">User ID to get comments for</param>
        /// <param name="includeInactive">Whether to include inactive comments</param>
        /// <returns>CommentListResult with security validation applied</returns>
        public CommentListResult GetCommentsByUserId(int userId, bool includeInactive = false)
        {
            try
            {
                // Security rule: Users can only see their own comments unless they're admin
                var currentUserId = GetCurrentUserId();
                if (!IsUserAuthenticated())
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Unauthorized attempt to view user comments for user {userId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentListResult.Failure("You must be logged in to view comments.");
                }

                if (!currentUserId.HasValue)
                {
                    return CommentListResult.Failure("Invalid user session. Please log in again.");
                }

                // Security rule: Users can only view their own comments unless they're admin
                if (userId != currentUserId.Value && !IsUserAdmin(currentUserId.Value))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"Unauthorized attempt to view other user's comments: {userId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentListResult.Failure("You can only view your own comments.");
                }

                // Security rule: Only authenticated users can see inactive comments
                if (includeInactive && !IsUserAdmin(currentUserId.Value))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"Non-admin attempt to view inactive comments for user {userId}", 
                        CreatedAt = DateTime.Now 
                    });
                    includeInactive = false; // Override for security
                }

                // Security rule: Rate limiting
                if (!CheckRateLimit("GetUserComments", currentUserId.Value))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"Rate limit exceeded for user comments retrieval for user {userId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentListResult.Failure("Rate limit exceeded. Please try again later.");
                }

                // Pass to BLL layer
                var result = commentBLL.GetCommentsByUserId(userId, includeInactive);

                // Security logging for successful operations
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ACCESS, 
                        UserId = currentUserId, 
                        Description = $"Comment access for user {userId}: GetCommentsByUserId", 
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
                    Description = $"Security error in GetCommentsByUserId: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return CommentListResult.Failure("An error occurred while retrieving user comments. Please try again.");
            }
        }

        /// <summary>
        /// Gets comment statistics with security validation
        /// </summary>
        /// <param name="productId">Product ID to get statistics for</param>
        /// <returns>DatabaseResult containing comment statistics</returns>
        public DatabaseResult<CommentStatistics> GetCommentStatistics(int productId)
        {
            try
            {
                // Security validation: Input validation
                if (productId <= 0)
                {
                    return DatabaseResult<CommentStatistics>.Failure("Invalid product ID provided");
                }

                // Security rule: Rate limiting for statistics retrieval
                if (!CheckRateLimit("GetStatistics", GetCurrentUserId() ?? 0))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = GetCurrentUserId(), 
                        Description = $"Rate limit exceeded for statistics retrieval on product {productId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult<CommentStatistics>.Failure("Rate limit exceeded. Please try again later.");
                }

                // Pass to BLL layer (no authentication required for public statistics)
                var result = commentBLL.GetCommentStatistics(productId);

                // Security logging for successful operations
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ACCESS, 
                        UserId = GetCurrentUserId(), 
                        Description = $"Comment statistics access on product {productId}: GetCommentStatistics", 
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
                    Description = $"Security error in GetCommentStatistics: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult<CommentStatistics>.Failure("An error occurred while retrieving comment statistics. Please try again.");
            }
        }

        /// <summary>
        /// Approves or rejects a comment with security validation (admin only)
        /// </summary>
        /// <param name="commentId">Comment ID to approve/reject</param>
        /// <param name="isApproved">True to approve, false to reject</param>
        /// <returns>DatabaseResult with security validation applied</returns>
        public DatabaseResult ApproveComment(int commentId, bool isApproved)
        {
            try
            {
                // Security requirement: User must be authenticated
                if (!IsUserAuthenticated())
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Unauthorized comment approval attempt for comment {commentId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("You must be logged in to approve comments.");
                }

                var currentUserId = GetCurrentUserId();
                if (!currentUserId.HasValue)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = "Comment approval attempted with invalid user session", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("Invalid user session. Please log in again.");
                }

                // Security validation: Input validation
                if (commentId <= 0)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"Invalid comment ID provided for approval: {commentId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("Invalid comment ID provided.");
                }

                // Security rule: Only admins can approve comments
                if (!IsUserAdmin(currentUserId.Value))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"Non-admin attempt to approve comment {commentId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("Only administrators can approve or reject comments.");
                }

                // Security rule: Rate limiting for comment approvals
                if (!CheckRateLimit("ApproveComment", currentUserId.Value))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = $"Rate limit exceeded for comment approval on comment {commentId}", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure("You are performing approvals too quickly. Please wait before trying again.");
                }

                // Pass to BLL layer
                var result = commentBLL.ApproveComment(commentId, currentUserId.Value, isApproved);

                // Security logging
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.UPDATE, 
                        UserId = currentUserId.Value, 
                        Description = $"Comment approval changed for {commentId}: {(isApproved ? "approved" : "rejected")}", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId.Value, 
                        Description = $"Comment approval failed for comment ID {commentId}", 
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
                    Description = $"Security error in ApproveComment: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult.Failure("An error occurred while processing the approval. Please try again.");
            }
        }

        /// <summary>
        /// Gets comments pending approval for moderation with security validation (admin only)
        /// </summary>
        /// <param name="pageNumber">Page number for pagination (default: 1)</param>
        /// <param name="pageSize">Number of comments per page (default: 20)</param>
        /// <returns>CommentListResult with security validation applied</returns>
        public CommentListResult GetPendingApprovalComments(int pageNumber = 1, int pageSize = 20)
        {
            try
            {
                // Security requirement: User must be authenticated
                if (!IsUserAuthenticated())
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = "Unauthorized attempt to view pending comments", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentListResult.Failure("You must be logged in to view pending comments.");
                }

                var currentUserId = GetCurrentUserId();
                if (!currentUserId.HasValue)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = "Pending comments access attempted with invalid user session", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentListResult.Failure("Invalid user session. Please log in again.");
                }

                // Security rule: Only admins can view pending comments
                if (!IsUserAdmin(currentUserId.Value))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = "Non-admin attempt to view pending comments", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentListResult.Failure("Only administrators can view pending comments.");
                }

                // Security validation: Validate pagination parameters
                if (pageNumber < 1) pageNumber = 1;
                if (pageSize < 1 || pageSize > 100) pageSize = 20;

                // Security rule: Rate limiting for pending comments retrieval
                if (!CheckRateLimit("GetPendingComments", currentUserId.Value))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUserId, 
                        Description = "Rate limit exceeded for pending comments retrieval", 
                        CreatedAt = DateTime.Now 
                    });
                    return CommentListResult.Failure("Rate limit exceeded. Please try again later.");
                }

                // Pass to BLL layer
                var result = commentBLL.GetPendingApprovalComments(currentUserId.Value, pageNumber, pageSize);

                // Security logging for successful operations
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ACCESS, 
                        UserId = currentUserId, 
                        Description = "Pending comments access: GetPendingApprovalComments", 
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
                    Description = $"Security error in GetPendingApprovalComments: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return CommentListResult.Failure("An error occurred while retrieving pending comments. Please try again.");
            }
        }

        #region Private Security Methods

        /// <summary>
        /// Validates comment input for security issues
        /// </summary>
        private DatabaseResult ValidateCommentInput(string commentText, int? rating)
        {
            // Input validation
            if (string.IsNullOrWhiteSpace(commentText))
                return DatabaseResult.Failure("Comment text is required");

            if (commentText.Trim().Length > 2000)
                return DatabaseResult.Failure("Comment text exceeds maximum length");

            if (rating.HasValue && (rating.Value < 1 || rating.Value > 5))
                return DatabaseResult.Failure("Rating must be between 1 and 5 stars");

            // Security check: Prevent script injection
            if (ContainsSuspiciousContent(commentText))
                return DatabaseResult.Failure("Comment contains invalid characters");

            return DatabaseResult.Success();
        }

        /// <summary>
        /// Validates comment content for security threats
        /// </summary>
        private DatabaseResult ValidateCommentContent(string commentText)
        {
            if (string.IsNullOrWhiteSpace(commentText))
                return DatabaseResult.Success();

            // Security check: Script injection prevention
            if (ContainsScriptInjection(commentText))
                return DatabaseResult.Failure("Comment contains potentially dangerous content");

            // Security check: SQL injection prevention
            if (ContainsSqlInjection(commentText))
                return DatabaseResult.Failure("Comment contains potentially dangerous content");

            // Security check: Excessive HTML/markup
            if (ContainsExcessiveMarkup(commentText))
                return DatabaseResult.Failure("Comment contains excessive markup");

            return DatabaseResult.Success();
        }

        /// <summary>
        /// Checks for suspicious content that might indicate malicious intent
        /// </summary>
        private bool ContainsSuspiciousContent(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return false;

            var suspiciousPatterns = new[]
            {
                "<script", "</script>", "javascript:", "vbscript:",
                "onload=", "onclick=", "onerror=", "onmouseover="
            };

            var lowerText = text.ToLower();
            return Array.Exists(suspiciousPatterns, pattern => lowerText.Contains(pattern));
        }

        /// <summary>
        /// Checks for script injection attempts
        /// </summary>
        private bool ContainsScriptInjection(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return false;

            var scriptPatterns = new[]
            {
                "<script", "javascript:", "vbscript:", "data:text/html",
                "eval(", "setTimeout(", "setInterval(", "Function(",
                "document.write", "document.cookie", "window.location"
            };

            var lowerText = text.ToLower();
            return Array.Exists(scriptPatterns, pattern => lowerText.Contains(pattern));
        }

        /// <summary>
        /// Checks for SQL injection attempts
        /// </summary>
        private bool ContainsSqlInjection(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return false;

            var sqlPatterns = new[]
            {
                "'; drop", "union select", "insert into", "delete from",
                "update set", "exec ", "sp_", "xp_", "--", "/*", "*/"
            };

            var lowerText = text.ToLower();
            return Array.Exists(sqlPatterns, pattern => lowerText.Contains(pattern));
        }

        /// <summary>
        /// Checks for excessive HTML/markup that might cause rendering issues
        /// </summary>
        private bool ContainsExcessiveMarkup(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return false;

            // Count HTML-like tags
            int tagCount = 0;
            for (int i = 0; i < text.Length - 1; i++)
            {
                if (text[i] == '<' && text[i + 1] != ' ')
                    tagCount++;
            }

            // Allow some basic formatting but prevent excessive markup
            return tagCount > 5;
        }

        /// <summary>
        /// Checks if the current user is authenticated
        /// </summary>
        private bool IsUserAuthenticated()
        {
            try
            {
                return HttpContext.Current?.User?.Identity?.IsAuthenticated == true;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Gets the current user ID from session
        /// </summary>
        private int? GetCurrentUserId()
        {
            try
            {
                if (HttpContext.Current?.Session?["CurrentUser"] is User currentUser)
                {
                    return currentUser.UserId;
                }
            }
            catch
            {
                // If we can't determine current user, return null
            }
            return null;
        }

        /// <summary>
        /// Checks if a user has admin privileges
        /// </summary>
        private bool IsUserAdmin(int userId)
        {
            try
            {
                if (HttpContext.Current?.Session?["CurrentUser"] is User currentUser)
                {
                    return currentUser.UserId == userId && 
                           (currentUser.UserRole?.ToLower() == "admin" || currentUser.UserRole?.ToLower() == "administrator");
                }
            }
            catch
            {
                // If we can't determine, assume not admin
            }
            return false;
        }

        /// <summary>
        /// Checks if a user can create comments
        /// </summary>
        private bool CanUserCreateComments(int userId)
        {
            try
            {
                if (HttpContext.Current?.Session?["CurrentUser"] is User currentUser)
                {
                    // Users can create comments if they're active and authenticated
                    return currentUser.UserId == userId && currentUser.IsActive;
                }
            }
            catch
            {
                // If we can't determine, deny access
            }
            return false;
        }

        /// <summary>
        /// Implements basic rate limiting for security operations
        /// </summary>
        private bool CheckRateLimit(string operation, int userId)
        {
            try
            {
                var key = $"RateLimit_{operation}_{userId}";
                var sessionKey = $"LastAction_{operation}_{userId}";
                
                if (HttpContext.Current?.Session?[sessionKey] is DateTime lastAction)
                {
                    var timeSinceLastAction = DateTime.Now - lastAction;
                    
                    // Different rate limits for different operations
                    TimeSpan minInterval;
                    switch (operation)
                    {
                        case "CreateComment":
                            minInterval = TimeSpan.FromSeconds(30); // 30 seconds between comments
                            break;
                        case "UpdateComment":
                            minInterval = TimeSpan.FromSeconds(10); // 10 seconds between updates
                            break;
                        case "DeleteComment":
                            minInterval = TimeSpan.FromSeconds(5);  // 5 seconds between deletions
                            break;
                        case "GetComments":
                            minInterval = TimeSpan.FromSeconds(1);    // 1 second between retrievals
                            break;
                        case "GetUserComments":
                            minInterval = TimeSpan.FromSeconds(2); // 2 seconds for user comment retrieval
                            break;
                        case "GetStatistics":
                            minInterval = TimeSpan.FromSeconds(1);  // 1 second for statistics
                            break;
                        case "ApproveComment":
                            minInterval = TimeSpan.FromSeconds(2);  // 2 seconds between approvals
                            break;
                        case "GetPendingComments":
                            minInterval = TimeSpan.FromSeconds(3);  // 3 seconds for pending retrieval
                            break;
                        default:
                            minInterval = TimeSpan.FromSeconds(5); // Default 5 seconds
                            break;
                    }
                    
                    if (timeSinceLastAction < minInterval)
                    {
                        return false; // Rate limited
                    }
                }

                // Update last action time
                if (HttpContext.Current?.Session != null)
                {
                    HttpContext.Current.Session[sessionKey] = DateTime.Now;
                }

                return true; // Allowed
            }
            catch
            {
                // If rate limiting fails, allow the operation (fail open)
                return true;
            }
        }

        #endregion
    }
}