using System;
using System.Collections.Generic;
using ABSTRACTIONS;
using DAL;

namespace BLL
{
    /// <summary>
    /// Business logic layer for news and newsletter operations.
    /// Applies validation rules before delegating to DAL stored procedure wrappers.
    /// </summary>
    public class NewsBLL
    {
        private readonly NewsDAL newsDal;
        private readonly NewsletterDAL newsletterDal;

        public NewsBLL()
        {
            newsDal = new NewsDAL();
            newsletterDal = new NewsletterDAL();
        }

        public NewsArticleResult CreateNews(NewsArticle article, int currentUserId)
        {
            if (article == null)
            {
                return NewsArticleResult.Failure("News article payload cannot be null.");
            }

            if (currentUserId <= 0)
            {
                return NewsArticleResult.Failure("A valid user must be provided to create news.");
            }

            article.CreatedBy = currentUserId;
            article.LastModifiedBy = currentUserId;
            article.Sanitize();
            article.EnsureSlug();

            var validation = article.Validate();
            if (!validation.IsValid)
            {
                return NewsArticleResult.Failure(validation.GetErrorMessage());
            }

            var dalResult = newsDal.CreateNews(article);
            if (dalResult.IsSuccessful)
            {
                return NewsArticleResult.Success(dalResult.Data, dalResult.ErrorMessage);
            }

            return NewsArticleResult.Failure(dalResult.ErrorMessage ?? "Failed to create news article.", dalResult.Exception);
        }

        public NewsArticleResult UpdateNews(NewsArticle article, int currentUserId)
        {
            if (article == null)
            {
                return NewsArticleResult.Failure("News article payload cannot be null.");
            }

            if (article.NewsId <= 0)
            {
                return NewsArticleResult.Failure("News article identifier is required.");
            }

            if (currentUserId <= 0)
            {
                return NewsArticleResult.Failure("A valid user must be provided to update news.");
            }

            article.LastModifiedBy = currentUserId;
            article.Sanitize();
            article.EnsureSlug();

            var validation = article.Validate();
            if (!validation.IsValid)
            {
                return NewsArticleResult.Failure(validation.GetErrorMessage());
            }

            var dalResult = newsDal.UpdateNews(article);
            if (dalResult.IsSuccessful)
            {
                return NewsArticleResult.Success(dalResult.Data, dalResult.ErrorMessage);
            }

            return NewsArticleResult.Failure(dalResult.ErrorMessage ?? "Failed to update news article.", dalResult.Exception);
        }

        public DatabaseResult PublishNews(int newsId, int currentUserId, DateTime? publishDate = null)
        {
            if (newsId <= 0)
            {
                return DatabaseResult.Failure(-1, "News article identifier is required.");
            }

            if (currentUserId <= 0)
            {
                return DatabaseResult.Failure(-2, "A valid user must be provided to publish news.");
            }

            return newsDal.SetPublishStatus(newsId, true, currentUserId, publishDate);
        }

        public DatabaseResult UnpublishNews(int newsId, int currentUserId)
        {
            if (newsId <= 0)
            {
                return DatabaseResult.Failure(-1, "News article identifier is required.");
            }

            if (currentUserId <= 0)
            {
                return DatabaseResult.Failure(-2, "A valid user must be provided to unpublish news.");
            }

            return newsDal.SetPublishStatus(newsId, false, currentUserId, null);
        }

        public DatabaseResult ArchiveNews(int newsId, int currentUserId)
        {
            if (newsId <= 0)
            {
                return DatabaseResult.Failure(-1, "News article identifier is required.");
            }

            if (currentUserId <= 0)
            {
                return DatabaseResult.Failure(-2, "A valid user must be provided to archive news.");
            }

            return newsDal.DeleteNews(newsId, currentUserId);
        }

        public NewsArticleResult GetNewsById(int newsId)
        {
            if (newsId <= 0)
            {
                return NewsArticleResult.Failure("News article identifier is required.");
            }

            var dalResult = newsDal.GetNewsById(newsId);
            if (dalResult.IsSuccessful)
            {
                return NewsArticleResult.Success(dalResult.Data, dalResult.ErrorMessage);
            }

            return NewsArticleResult.Failure(dalResult.ErrorMessage ?? "News article not found.", dalResult.Exception);
        }

        public NewsArticleListResult SearchNews(NewsSearchCriteria criteria)
        {
            criteria = criteria ?? new NewsSearchCriteria();
            criteria.Normalize();

            switch ((criteria.StatusFilter ?? "All").ToLowerInvariant())
            {
                case "published":
                    criteria.IncludeArchived = false;
                    criteria.IncludeUnpublished = false;
                    criteria.StatusFilter = "Published";
                    break;
                case "unpublished":
                    criteria.IncludeArchived = false;
                    criteria.IncludeUnpublished = true;
                    criteria.StatusFilter = "Unpublished";
                    break;
                case "archived":
                    criteria.IncludeArchived = true;
                    criteria.IncludeUnpublished = true;
                    criteria.StatusFilter = "Archived";
                    break;
                default:
                    criteria.IncludeArchived = true;
                    criteria.IncludeUnpublished = true;
                    criteria.StatusFilter = "All";
                    break;
            }

            var dalResult = newsDal.SearchNews(criteria);
            if (dalResult.IsSuccessful)
            {
                int totalRecords = 0;
                if (dalResult.Data != null && dalResult.Data.Count > 0 && dalResult.Data[0].TotalRecords.HasValue)
                {
                    totalRecords = dalResult.Data[0].TotalRecords.Value;
                }

                return NewsArticleListResult.Success(dalResult.Data ?? new List<NewsArticle>(), totalRecords, dalResult.ErrorMessage);
            }

            return NewsArticleListResult.Failure(dalResult.ErrorMessage ?? "Unable to retrieve news articles.", dalResult.Exception);
        }

        public NewsArticleListResult GetLatestNews(int topCount, string languageCode = null)
        {
            var dalResult = newsDal.GetLatestNews(topCount, languageCode);
            if (dalResult.IsSuccessful)
            {
                return NewsArticleListResult.Success(dalResult.Data ?? new List<NewsArticle>(), dalResult.Data?.Count ?? 0, dalResult.ErrorMessage);
            }

            return NewsArticleListResult.Failure(dalResult.ErrorMessage ?? "Unable to retrieve latest news.", dalResult.Exception);
        }

        public DatabaseResult IncrementViewCount(int newsId)
        {
            return newsDal.IncrementViewCount(newsId);
        }

        public NewsletterSubscriptionResult SubscribeToNewsletter(string email, string languageCode)
        {
            var dalResult = newsletterDal.Subscribe(email, languageCode);
            if (dalResult.IsSuccessful)
            {
                return NewsletterSubscriptionResult.Success(dalResult.Data, dalResult.ErrorMessage);
            }

            return NewsletterSubscriptionResult.Failure(dalResult.ErrorMessage ?? "Unable to subscribe to the newsletter.", dalResult.Exception);
        }

        public DatabaseResult UnsubscribeFromNewsletter(string email)
        {
            return newsletterDal.Unsubscribe(email);
        }

        public NewsletterSubscriptionListResult GetNewsletterSubscribers(bool? isActive, string searchTerm, int pageNumber, int pageSize)
        {
            var dalResult = newsletterDal.GetSubscribers(isActive, searchTerm, pageNumber, pageSize);
            if (dalResult.IsSuccessful)
            {
                int totalRecords = 0;
                if (dalResult.Data != null && dalResult.Data.Count > 0 && dalResult.Data[0].TotalRecords.HasValue)
                {
                    totalRecords = dalResult.Data[0].TotalRecords.Value;
                }

                return NewsletterSubscriptionListResult.Success(dalResult.Data ?? new List<NewsletterSubscription>(), totalRecords, dalResult.ErrorMessage);
            }

            return NewsletterSubscriptionListResult.Failure(dalResult.ErrorMessage ?? "Unable to retrieve newsletter subscribers.", dalResult.Exception);
        }

        public NewsletterSummaryResult GetNewsletterSummary()
        {
            var dalResult = newsletterDal.GetSummary();
            if (dalResult.IsSuccessful)
            {
                return NewsletterSummaryResult.Success(dalResult.Data, dalResult.ErrorMessage);
            }

            return NewsletterSummaryResult.Failure(dalResult.ErrorMessage ?? "Unable to retrieve newsletter summary.", dalResult.Exception);
        }
    }
}

