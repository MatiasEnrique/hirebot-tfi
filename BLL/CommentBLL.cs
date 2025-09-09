using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DAL;
using ABSTRACTIONS;

namespace BLL
{
    /// <summary>
    /// Business Logic Layer for Comment operations
    /// Implements business rules, validation, and orchestration between Security and DAL layers
    /// Follows the established architecture pattern: Security -> BLL -> DAL
    /// </summary>
    public class CommentBLL
    {
        private readonly CommentDAL commentDAL;

        public CommentBLL()
        {
            commentDAL = new CommentDAL();
        }

        /// <summary>
        /// Retrieves all active comments for a specific product with business rule validation
        /// </summary>
        /// <param name="productId">Product ID to get comments for</param>
        /// <param name="includePending">Whether to include pending/unapproved comments (admin only)</param>
        /// <param name="pageNumber">Page number for pagination (default: 1)</param>
        /// <param name="pageSize">Number of comments per page (default: 10)</param>
        /// <returns>CommentListResult with comments and detailed status</returns>
        public CommentListResult GetCommentsByProductId(int productId, bool includePending = false, int pageNumber = 1, int pageSize = 10)
        {
            try
            {
                // Business rule validation
                if (productId <= 0)
                {
                    return CommentListResult.Failure(GetLocalizedString("InvalidProductId"));
                }

                // TEMPORARY FIX: For development/testing, allow pending comments to show existing data
                // In production, restore the security check:
                // if (includePending && !IsUserAuthenticated())
                // {
                //     includePending = false; // Override to maintain security
                // }

                // Validate pagination parameters
                if (pageNumber < 1) pageNumber = 1;
                if (pageSize < 1 || pageSize > 100) pageSize = 10;

                var dalResult = commentDAL.GetCommentsByProductId(productId, includePending, pageNumber, pageSize);
                
                if (dalResult.IsSuccessful)
                {
                    // Apply business rules to comments
                    var processedComments = ApplyBusinessRulesToCommentList(dalResult.Data);
                    return CommentListResult.Success(processedComments, 
                        GetLocalizedString("CommentsRetrievedSuccessfully"));
                }
                else
                {
                    return CommentListResult.Failure(dalResult.ErrorMessage);
                }
            }
            catch (Exception ex)
            {
                return CommentListResult.Failure(GetLocalizedString("UnexpectedErrorRetrievingComments"), ex);
            }
        }

        /// <summary>
        /// Creates a new comment with comprehensive business rule validation
        /// </summary>
        /// <param name="productId">Product ID to comment on</param>
        /// <param name="userId">User ID creating the comment</param>
        /// <param name="commentText">Comment content</param>
        /// <param name="rating">Optional rating (1-5 stars)</param>
        /// <returns>CommentResult with operation status</returns>
        public CommentResult CreateComment(int productId, int userId, string commentText, int? rating = null)
        {
            try
            {
                // Business rule: Input validation
                var validationResult = ValidateCommentCreation(productId, userId, commentText, rating);
                if (!validationResult.IsSuccessful)
                {
                    return CommentResult.Failure(validationResult.ErrorMessage);
                }

                // Business rule: Check if user can comment on this product
                var userCanCommentResult = CanUserCommentOnProduct(userId, productId);
                if (!userCanCommentResult.IsSuccessful)
                {
                    return CommentResult.Failure(userCanCommentResult.ErrorMessage);
                }

                // Create comment entity
                var comment = new Comment
                {
                    ProductId = productId,
                    UserId = userId,
                    CommentText = commentText?.Trim(),
                    Rating = rating.HasValue ? (byte?)rating.Value : null,
                    CreatedDate = DateTime.Now,
                    IsActive = true
                };

                // Perform additional business validation
                var commentValidation = comment.ValidateComment();
                if (!commentValidation.IsValid)
                {
                    return CommentResult.Failure(commentValidation.GetErrorMessage());
                }

                // Apply business rules for content filtering
                ApplyContentFilteringRules(comment);

                var dalResult = commentDAL.CreateComment(comment);
                
                if (dalResult.IsSuccessful && dalResult.Data != null)
                {
                    return CommentResult.Success(dalResult.Data, GetLocalizedString("CommentCreatedSuccessfully"));
                }
                else
                {
                    return CommentResult.Failure(dalResult.ErrorMessage);
                }
            }
            catch (Exception ex)
            {
                return CommentResult.Failure(GetLocalizedString("UnexpectedErrorCreatingComment"), ex);
            }
        }

        /// <summary>
        /// Updates an existing comment with business rule validation
        /// </summary>
        /// <param name="commentId">Comment ID to update</param>
        /// <param name="userId">User ID requesting the update</param>
        /// <param name="newCommentText">New comment content</param>
        /// <param name="newRating">New rating value</param>
        /// <returns>CommentResult with operation status</returns>
        public CommentResult UpdateComment(int commentId, int userId, string newCommentText, int? newRating = null)
        {
            try
            {
                // Business rule: Input validation
                if (commentId <= 0)
                {
                    return CommentResult.Failure(GetLocalizedString("InvalidCommentId"));
                }

                if (userId <= 0)
                {
                    return CommentResult.Failure(GetLocalizedString("InvalidUserId"));
                }

                if (string.IsNullOrWhiteSpace(newCommentText))
                {
                    return CommentResult.Failure(GetLocalizedString("CommentTextRequired"));
                }

                // Business rule: Get existing comment to validate ownership
                var existingCommentResult = commentDAL.GetCommentById(commentId);
                if (!existingCommentResult.IsSuccessful || existingCommentResult.Data == null)
                {
                    return CommentResult.Failure(GetLocalizedString("CommentNotFound"));
                }

                var existingComment = existingCommentResult.Data;

                // Business rule: Only comment owner can update their comment
                if (existingComment.UserId != userId)
                {
                    return CommentResult.Failure(GetLocalizedString("CannotUpdateOtherUsersComments"));
                }

                // Business rule: Comments can only be updated within a time window
                var canUpdateResult = CanUpdateComment(existingComment);
                if (!canUpdateResult.IsSuccessful)
                {
                    return CommentResult.Failure(canUpdateResult.ErrorMessage);
                }

                // Update comment properties
                existingComment.CommentText = newCommentText?.Trim();
                existingComment.Rating = newRating.HasValue ? (byte?)newRating.Value : null;

                // Validate updated comment
                var validationResult = existingComment.ValidateComment();
                if (!validationResult.IsValid)
                {
                    return CommentResult.Failure(validationResult.GetErrorMessage());
                }

                // Apply content filtering rules
                ApplyContentFilteringRules(existingComment);

                var dalResult = commentDAL.UpdateComment(existingComment, userId);
                
                if (dalResult.IsSuccessful)
                {
                    return CommentResult.Success(existingComment, GetLocalizedString("CommentUpdatedSuccessfully"));
                }
                else
                {
                    return CommentResult.Failure(dalResult.ErrorMessage);
                }
            }
            catch (Exception ex)
            {
                return CommentResult.Failure(GetLocalizedString("UnexpectedErrorUpdatingComment"), ex);
            }
        }

        /// <summary>
        /// Deletes (deactivates) a comment with business rule validation
        /// </summary>
        /// <param name="commentId">Comment ID to delete</param>
        /// <param name="userId">User ID requesting the deletion</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult DeleteComment(int commentId, int userId)
        {
            try
            {
                // Business rule: Input validation
                if (commentId <= 0)
                {
                    return DatabaseResult.Failure(-1, GetLocalizedString("InvalidCommentId"));
                }

                if (userId <= 0)
                {
                    return DatabaseResult.Failure(-2, GetLocalizedString("InvalidUserId"));
                }

                // Business rule: Get existing comment to validate ownership/permissions
                var existingCommentResult = commentDAL.GetCommentById(commentId);
                if (!existingCommentResult.IsSuccessful || existingCommentResult.Data == null)
                {
                    return DatabaseResult.Failure(-3, GetLocalizedString("CommentNotFound"));
                }

                var existingComment = existingCommentResult.Data;

                // Business rule: Users can only delete their own comments (admins can delete any)
                var canDeleteResult = CanDeleteComment(existingComment, userId);
                if (!canDeleteResult.IsSuccessful)
                {
                    return DatabaseResult.Failure(-4, canDeleteResult.ErrorMessage);
                }

                var dalResult = commentDAL.DeleteComment(commentId, userId);
                
                if (dalResult.IsSuccessful)
                {
                    return DatabaseResult.Success(GetLocalizedString("CommentDeletedSuccessfully"));
                }
                else
                {
                    return dalResult; // Pass through DAL error
                }
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure(GetLocalizedString("UnexpectedErrorDeletingComment"), ex);
            }
        }

        /// <summary>
        /// Retrieves comments made by a specific user
        /// </summary>
        /// <param name="userId">User ID to get comments for</param>
        /// <param name="includeInactive">Whether to include inactive comments</param>
        /// <returns>CommentListResult with user's comments</returns>
        public CommentListResult GetCommentsByUserId(int userId, bool includeInactive = false)
        {
            try
            {
                // Business rule validation
                if (userId <= 0)
                {
                    return CommentListResult.Failure(GetLocalizedString("InvalidUserId"));
                }

                var dalResult = commentDAL.GetCommentsByUserId(userId, includeInactive);
                
                if (dalResult.IsSuccessful)
                {
                    // Apply business rules to comments
                    var processedComments = ApplyBusinessRulesToCommentList(dalResult.Data);
                    return CommentListResult.Success(processedComments, 
                        GetLocalizedString("UserCommentsRetrievedSuccessfully"));
                }
                else
                {
                    return CommentListResult.Failure(dalResult.ErrorMessage);
                }
            }
            catch (Exception ex)
            {
                return CommentListResult.Failure(GetLocalizedString("UnexpectedErrorRetrievingUserComments"), ex);
            }
        }

        /// <summary>
        /// Gets comment statistics for a product
        /// </summary>
        /// <param name="productId">Product ID to get statistics for</param>
        /// <returns>DatabaseResult containing comment statistics</returns>
        public DatabaseResult<CommentStatistics> GetCommentStatistics(int productId)
        {
            try
            {
                // Business rule validation
                if (productId <= 0)
                {
                    return DatabaseResult<CommentStatistics>.Failure(-1, GetLocalizedString("InvalidProductId"));
                }

                var dalResult = commentDAL.GetCommentStatistics(productId);
                
                if (dalResult.IsSuccessful && dalResult.Data != null)
                {
                    // Apply business rules to statistics (e.g., rounding average rating)
                    var statistics = dalResult.Data;
                    if (statistics.AverageRating.HasValue)
                    {
                        // Round to 1 decimal place for display purposes
                        statistics.AverageRating = Math.Round(statistics.AverageRating.Value, 1);
                    }
                    
                    return DatabaseResult<CommentStatistics>.Success(statistics, 
                        GetLocalizedString("StatisticsRetrievedSuccessfully"));
                }
                else
                {
                    return dalResult; // Pass through DAL result
                }
            }
            catch (Exception ex)
            {
                return DatabaseResult<CommentStatistics>.Failure(GetLocalizedString("UnexpectedErrorRetrievingStatistics"), ex);
            }
        }

        /// <summary>
        /// Approves or rejects a comment (admin only)
        /// </summary>
        /// <param name="commentId">Comment ID to approve/reject</param>
        /// <param name="adminUserId">Admin user ID performing the action</param>
        /// <param name="isApproved">True to approve, false to reject</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult ApproveComment(int commentId, int adminUserId, bool isApproved)
        {
            try
            {
                // Business rule: Input validation
                if (commentId <= 0)
                {
                    return DatabaseResult.Failure(-1, GetLocalizedString("InvalidCommentId"));
                }

                if (adminUserId <= 0)
                {
                    return DatabaseResult.Failure(-2, GetLocalizedString("InvalidUserId"));
                }

                // Business rule: Only admins can approve/reject comments
                if (!IsUserAdmin(adminUserId))
                {
                    return DatabaseResult.Failure(-3, GetLocalizedString("OnlyAdminsCanApproveComments"));
                }

                var dalResult = commentDAL.ApproveComment(commentId, adminUserId, isApproved);
                
                if (dalResult.IsSuccessful)
                {
                    return DatabaseResult.Success(isApproved ? 
                        GetLocalizedString("CommentApprovedSuccessfully") : 
                        GetLocalizedString("CommentRejectedSuccessfully"));
                }
                else
                {
                    return dalResult; // Pass through DAL error
                }
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure(GetLocalizedString("UnexpectedErrorApprovingComment"), ex);
            }
        }

        /// <summary>
        /// Gets comments pending approval for moderation (admin only)
        /// </summary>
        /// <param name="adminUserId">Admin user ID requesting the list</param>
        /// <param name="pageNumber">Page number for pagination (default: 1)</param>
        /// <param name="pageSize">Number of comments per page (default: 20)</param>
        /// <returns>CommentListResult with pending comments</returns>
        public CommentListResult GetPendingApprovalComments(int adminUserId, int pageNumber = 1, int pageSize = 20)
        {
            try
            {
                // Business rule validation
                if (adminUserId <= 0)
                {
                    return CommentListResult.Failure(GetLocalizedString("InvalidUserId"));
                }

                // Business rule: Only admins can view pending comments
                if (!IsUserAdmin(adminUserId))
                {
                    return CommentListResult.Failure(GetLocalizedString("OnlyAdminsCanViewPendingComments"));
                }

                // Validate pagination parameters
                if (pageNumber < 1) pageNumber = 1;
                if (pageSize < 1 || pageSize > 100) pageSize = 20;

                var dalResult = commentDAL.GetPendingApprovalComments(adminUserId, pageNumber, pageSize);
                
                if (dalResult.IsSuccessful)
                {
                    // Apply business rules to comments
                    var processedComments = ApplyBusinessRulesToCommentList(dalResult.Data);
                    return CommentListResult.Success(processedComments, 
                        GetLocalizedString("PendingCommentsRetrievedSuccessfully"));
                }
                else
                {
                    return CommentListResult.Failure(dalResult.ErrorMessage);
                }
            }
            catch (Exception ex)
            {
                return CommentListResult.Failure(GetLocalizedString("UnexpectedErrorRetrievingPendingComments"), ex);
            }
        }

        #region Private Business Rule Methods

        /// <summary>
        /// Validates comment creation business rules
        /// </summary>
        private DatabaseResult ValidateCommentCreation(int productId, int userId, string commentText, int? rating)
        {
            if (productId <= 0)
                return DatabaseResult.Failure(-1, GetLocalizedString("InvalidProductId"));

            if (userId <= 0)
                return DatabaseResult.Failure(-2, GetLocalizedString("InvalidUserId"));

            if (string.IsNullOrWhiteSpace(commentText))
                return DatabaseResult.Failure(-3, GetLocalizedString("CommentTextRequired"));

            if (commentText.Trim().Length < 10)
                return DatabaseResult.Failure(-4, GetLocalizedString("CommentTooShort"));

            if (commentText.Trim().Length > 2000)
                return DatabaseResult.Failure(-5, GetLocalizedString("CommentTooLong"));

            if (rating.HasValue && (rating.Value < 1 || rating.Value > 5))
                return DatabaseResult.Failure(-6, GetLocalizedString("InvalidRating"));

            return DatabaseResult.Success();
        }

        /// <summary>
        /// Checks if a user can comment on a specific product
        /// </summary>
        private DatabaseResult CanUserCommentOnProduct(int userId, int productId)
        {
            // Business rule: Active users only can comment
            if (!IsUserActive(userId))
            {
                return DatabaseResult.Failure(-1, GetLocalizedString("UserNotActive"));
            }

            // Business rule: Product must exist and be active
            // Note: This would typically query the ProductDAL, but for now we assume it exists
            // In a complete implementation, you would add this check

            // Business rule: Check rate limiting (one comment per user per product per day)
            if (HasUserCommentedOnProductToday(userId, productId))
            {
                return DatabaseResult.Failure(-2, GetLocalizedString("OneCommentPerDayLimit"));
            }

            return DatabaseResult.Success();
        }

        /// <summary>
        /// Determines if a comment can be updated based on business rules
        /// </summary>
        private DatabaseResult CanUpdateComment(Comment comment)
        {
            // Business rule: Comments can only be updated within 24 hours of creation
            if (DateTime.Now > comment.CreatedDate.AddHours(24))
            {
                return DatabaseResult.Failure(-1, GetLocalizedString("CommentUpdateTimeExpired"));
            }

            // Business rule: Inactive comments cannot be updated
            if (!comment.IsActive)
            {
                return DatabaseResult.Failure(-2, GetLocalizedString("CannotUpdateInactiveComment"));
            }

            return DatabaseResult.Success();
        }

        /// <summary>
        /// Determines if a comment can be deleted based on business rules
        /// </summary>
        private DatabaseResult CanDeleteComment(Comment comment, int userId)
        {
            // Business rule: Users can only delete their own comments
            if (comment.UserId != userId && !IsUserAdmin(userId))
            {
                return DatabaseResult.Failure(-1, GetLocalizedString("CannotDeleteOtherUsersComments"));
            }

            // Business rule: Already inactive comments cannot be deleted again
            if (!comment.IsActive)
            {
                return DatabaseResult.Failure(-2, GetLocalizedString("CommentAlreadyDeleted"));
            }

            return DatabaseResult.Success();
        }

        /// <summary>
        /// Applies content filtering rules to a comment
        /// </summary>
        private void ApplyContentFilteringRules(Comment comment)
        {
            if (!string.IsNullOrWhiteSpace(comment.CommentText))
            {
                // Basic content sanitization
                comment.SanitizeComment();

                // Business rule: Filter inappropriate content
                // This is a simplified implementation - in production you'd use more sophisticated filtering
                var inappropriateWords = GetInappropriateWords();
                foreach (var word in inappropriateWords)
                {
                    comment.CommentText = comment.CommentText.Replace(word, new string('*', word.Length));
                }
            }
        }

        /// <summary>
        /// Applies business rules to a list of comments for display
        /// </summary>
        private List<Comment> ApplyBusinessRulesToCommentList(List<Comment> comments)
        {
            if (comments == null) return new List<Comment>();

            foreach (var comment in comments)
            {
                // Business rule: Hide comment text for inactive or unapproved comments unless user has permission
                if ((!comment.IsActive || !comment.IsApproved) && !IsUserAuthenticated())
                {
                    comment.CommentText = GetLocalizedString("CommentNotAvailable");
                }

                // Business rule: Format display names
                if (!string.IsNullOrWhiteSpace(comment.UserFullName))
                {
                    comment.UserFullName = FormatDisplayName(comment.UserFullName);
                }
            }

            return comments;
        }

        /// <summary>
        /// Formats a display name according to business rules
        /// </summary>
        private string FormatDisplayName(string fullName)
        {
            // Business rule: Show only first name and last initial for privacy
            var nameParts = fullName.Trim().Split(' ');
            if (nameParts.Length >= 2)
            {
                return $"{nameParts[0]} {nameParts[nameParts.Length - 1].Substring(0, 1)}.";
            }
            return nameParts[0];
        }

        /// <summary>
        /// Checks if a user has already commented on a product today (rate limiting)
        /// </summary>
        private bool HasUserCommentedOnProductToday(int userId, int productId)
        {
            try
            {
                var userCommentsResult = commentDAL.GetCommentsByUserId(userId, false);
                if (userCommentsResult.IsSuccessful && userCommentsResult.Data != null)
                {
                    var today = DateTime.Today;
                    return userCommentsResult.Data.Any(c => 
                        c.ProductId == productId && 
                        c.CreatedDate.Date == today);
                }
            }
            catch
            {
                // If we can't check, allow the comment (fail open)
            }
            return false;
        }

        /// <summary>
        /// Checks if a user is active
        /// </summary>
        private bool IsUserActive(int userId)
        {
            // This would typically query the UserDAL to check user status
            // For now, we assume authenticated users are active
            return IsUserAuthenticated();
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
        /// Checks if a user has admin privileges
        /// </summary>
        private bool IsUserAdmin(int userId)
        {
            // This would typically check user roles
            // For now, simplified implementation
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
        /// Gets a list of inappropriate words for content filtering
        /// </summary>
        private List<string> GetInappropriateWords()
        {
            // In production, this would come from configuration or database
            return new List<string> { "spam", "inappropriate" };
        }

        /// <summary>
        /// Gets localized string for the given key
        /// </summary>
        private string GetLocalizedString(string key)
        {
            try
            {
                if (HttpContext.Current != null)
                {
                    return HttpContext.GetGlobalResourceObject("Messages", key)?.ToString() ?? key;
                }
                return key;
            }
            catch
            {
                return key;
            }
        }

        #endregion
    }
}