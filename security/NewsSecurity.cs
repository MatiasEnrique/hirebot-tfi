using System;
using System.Web;
using BLL;
using ABSTRACTIONS;
using SERVICES;

namespace SECURITY
{
    /// <summary>
    /// Security layer for news and newsletter operations.
    /// Ensures proper authentication/authorization before delegating to business logic.
    /// </summary>
    public class NewsSecurity
    {
        private readonly NewsBLL newsBLL;
        private readonly LogBLL logBLL;
        private readonly AdminSecurity adminSecurity;
        private readonly UserBLL userBLL;

        public NewsSecurity()
        {
            newsBLL = new NewsBLL();
            logBLL = new LogBLL();
            adminSecurity = new AdminSecurity();
            userBLL = new UserBLL();
        }

        #region News Management

        public NewsArticleResult CreateNews(NewsArticle article)
        {
            if (!adminSecurity.IsUserAdmin())
            {
                return NewsArticleResult.Failure("Access denied. Admin privileges are required.");
            }

            var currentUserId = GetCurrentUserId();
            if (!currentUserId.HasValue)
            {
                return NewsArticleResult.Failure("Unable to determine the current user.");
            }

            try
            {
                var result = newsBLL.CreateNews(article, currentUserId.Value);
                if (result.IsSuccessful)
                {
                    LogAction(LogService.LogTypes.CREATE, $"News created: {result.Data?.Title}", currentUserId.Value);
                }
                else
                {
                    LogError($"Failed to create news: {result.ErrorMessage}", currentUserId.Value);
                }
                return result;
            }
            catch (Exception ex)
            {
                LogError($"Security error creating news: {ex.Message}", currentUserId.Value);
                return NewsArticleResult.Failure("An unexpected error occurred while creating the news article.");
            }
        }

        public NewsArticleResult UpdateNews(NewsArticle article)
        {
            if (!adminSecurity.IsUserAdmin())
            {
                return NewsArticleResult.Failure("Access denied. Admin privileges are required.");
            }

            var currentUserId = GetCurrentUserId();
            if (!currentUserId.HasValue)
            {
                return NewsArticleResult.Failure("Unable to determine the current user.");
            }

            try
            {
                var result = newsBLL.UpdateNews(article, currentUserId.Value);
                if (result.IsSuccessful)
                {
                    LogAction(LogService.LogTypes.UPDATE, $"News updated: {result.Data?.Title}", currentUserId.Value);
                }
                else
                {
                    LogError($"Failed to update news: {result.ErrorMessage}", currentUserId.Value);
                }
                return result;
            }
            catch (Exception ex)
            {
                LogError($"Security error updating news: {ex.Message}", currentUserId.Value);
                return NewsArticleResult.Failure("An unexpected error occurred while updating the news article.");
            }
        }

        public DatabaseResult PublishNews(int newsId, DateTime? publishDate = null)
        {
            if (!adminSecurity.IsUserAdmin())
            {
                return DatabaseResult.Failure(-1, "Access denied. Admin privileges are required.");
            }

            var currentUserId = GetCurrentUserId();
            if (!currentUserId.HasValue)
            {
                return DatabaseResult.Failure(-2, "Unable to determine the current user.");
            }

            var result = newsBLL.PublishNews(newsId, currentUserId.Value, publishDate);
            if (result.IsSuccessful)
            {
                LogAction(LogService.LogTypes.UPDATE, $"News published (ID {newsId})", currentUserId.Value);
            }
            else
            {
                LogError($"Failed to publish news ID {newsId}: {result.ErrorMessage}", currentUserId.Value);
            }
            return result;
        }

        public DatabaseResult UnpublishNews(int newsId)
        {
            if (!adminSecurity.IsUserAdmin())
            {
                return DatabaseResult.Failure(-1, "Access denied. Admin privileges are required.");
            }

            var currentUserId = GetCurrentUserId();
            if (!currentUserId.HasValue)
            {
                return DatabaseResult.Failure(-2, "Unable to determine the current user.");
            }

            var result = newsBLL.UnpublishNews(newsId, currentUserId.Value);
            if (result.IsSuccessful)
            {
                LogAction(LogService.LogTypes.UPDATE, $"News unpublished (ID {newsId})", currentUserId.Value);
            }
            else
            {
                LogError($"Failed to unpublish news ID {newsId}: {result.ErrorMessage}", currentUserId.Value);
            }
            return result;
        }

        public DatabaseResult ArchiveNews(int newsId)
        {
            if (!adminSecurity.IsUserAdmin())
            {
                return DatabaseResult.Failure(-1, "Access denied. Admin privileges are required.");
            }

            var currentUserId = GetCurrentUserId();
            if (!currentUserId.HasValue)
            {
                return DatabaseResult.Failure(-2, "Unable to determine the current user.");
            }

            var result = newsBLL.ArchiveNews(newsId, currentUserId.Value);
            if (result.IsSuccessful)
            {
                LogAction(LogService.LogTypes.DELETE, $"News archived (ID {newsId})", currentUserId.Value);
            }
            else
            {
                LogError($"Failed to archive news ID {newsId}: {result.ErrorMessage}", currentUserId.Value);
            }
            return result;
        }

        public NewsArticleResult GetNewsById(int newsId)
        {
            return newsBLL.GetNewsById(newsId);
        }

        public NewsArticleListResult SearchNewsForAdmin(NewsSearchCriteria criteria)
        {
            if (!adminSecurity.IsUserAdmin())
            {
                return NewsArticleListResult.Failure("Access denied. Admin privileges are required.");
            }

            criteria = criteria ?? new NewsSearchCriteria();
            criteria.IncludeArchived = true;
            criteria.IncludeUnpublished = true;

            return newsBLL.SearchNews(criteria);
        }

        public NewsArticleListResult SearchPublishedNews(NewsSearchCriteria criteria)
        {
            criteria = criteria ?? new NewsSearchCriteria();
            criteria.IncludeArchived = false;
            criteria.IncludeUnpublished = false;

            return newsBLL.SearchNews(criteria);
        }

        public NewsArticleListResult GetLatestNews(int topCount, string languageCode = null)
        {
            return newsBLL.GetLatestNews(topCount, languageCode);
        }

        public DatabaseResult IncrementViewCount(int newsId)
        {
            return newsBLL.IncrementViewCount(newsId);
        }

        #endregion

        #region Newsletter Management

        public NewsletterSubscriptionResult SubscribeToNewsletter(string email, string languageCode)
        {
            var result = newsBLL.SubscribeToNewsletter(email, languageCode);
            if (result.IsSuccessful)
            {
                LogAction(LogService.LogTypes.CREATE, $"Newsletter subscribed: {email}");
            }
            else
            {
                LogError($"Newsletter subscription failed for {email}: {result.ErrorMessage}");
            }
            return result;
        }

        public DatabaseResult UnsubscribeFromNewsletter(string email)
        {
            var result = newsBLL.UnsubscribeFromNewsletter(email);
            if (result.IsSuccessful)
            {
                LogAction(LogService.LogTypes.DELETE, $"Newsletter unsubscribed: {email}");
            }
            else
            {
                LogError($"Newsletter unsubscribe failed for {email}: {result.ErrorMessage}");
            }
            return result;
        }

        public NewsletterSubscriptionListResult GetNewsletterSubscribers(bool? isActive, string searchTerm, int pageNumber, int pageSize)
        {
            if (!adminSecurity.IsUserAdmin())
            {
                return NewsletterSubscriptionListResult.Failure("Access denied. Admin privileges are required.");
            }

            return newsBLL.GetNewsletterSubscribers(isActive, searchTerm, pageNumber, pageSize);
        }

        public NewsletterSummaryResult GetNewsletterSummary()
        {
            if (!adminSecurity.IsUserAdmin())
            {
                return NewsletterSummaryResult.Failure("Access denied. Admin privileges are required.");
            }

            return newsBLL.GetNewsletterSummary();
        }

        #endregion

        #region Helper Methods

        private int? GetCurrentUserId()
        {
            try
            {
                if (HttpContext.Current?.Session?["CurrentUser"] is User sessionUser)
                {
                    return sessionUser.UserId;
                }

                if (HttpContext.Current?.User?.Identity?.IsAuthenticated == true)
                {
                    var username = HttpContext.Current.User.Identity.Name;
                    var user = userBLL.GetUserByUsername(username);
                    if (user != null)
                    {
                        HttpContext.Current.Session["CurrentUser"] = user;
                        return user.UserId;
                    }
                }
            }
            catch
            {
                // Ignore failures and fall through
            }

            return null;
        }

        private void LogAction(string logType, string description, int? userId = null)
        {
            try
            {
                logBLL.CreateLog(new Log
                {
                    LogType = logType,
                    Description = description,
                    UserId = userId,
                    CreatedAt = DateTime.Now
                });
            }
            catch
            {
                // Logging should not block the main operation
            }
        }

        private void LogError(string description, int? userId = null)
        {
            LogAction(LogService.LogTypes.ERROR, description, userId);
        }

        #endregion
    }
}

