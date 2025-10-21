using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace ABSTRACTIONS
{
    /// <summary>
    /// Represents a newsletter subscription entry for marketing communications.
    /// </summary>
    public class NewsletterSubscription
    {
        [Required]
        [EmailAddress]
        [StringLength(256, ErrorMessage = "Email cannot exceed 256 characters")]
        public string Email { get; set; }

        public string EmailNormalized { get; set; }

        [StringLength(5)]
        public string LanguageCode { get; set; }

        public bool IsActive { get; set; }
        public bool IsConfirmed { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? ConfirmedDate { get; set; }
        public DateTime? UnsubscribedDate { get; set; }
        public DateTime LastUpdatedDate { get; set; }
        public Guid ConfirmationToken { get; set; }

        public int? TotalRecords { get; set; }

        public int SubscriptionId { get; set; }

        public NewsletterSubscription()
        {
            LanguageCode = "es";
            IsActive = true;
            IsConfirmed = true;
            CreatedDate = DateTime.UtcNow;
            LastUpdatedDate = DateTime.UtcNow;
            ConfirmationToken = Guid.NewGuid();
        }

        public void Sanitize()
        {
            Email = Email?.Trim();
            EmailNormalized = EmailNormalized ?? Email?.Trim().ToUpperInvariant();
            LanguageCode = string.IsNullOrWhiteSpace(LanguageCode) ? "es" : LanguageCode.Trim().ToLowerInvariant();
        }

        public NewsletterSubscriptionValidationResult Validate()
        {
            var result = new NewsletterSubscriptionValidationResult();

            if (string.IsNullOrWhiteSpace(Email))
            {
                result.AddError("Email is required.");
            }
            else if (!new EmailAddressAttribute().IsValid(Email))
            {
                result.AddError("Email format is invalid.");
            }

            if (!string.IsNullOrWhiteSpace(LanguageCode) && LanguageCode.Trim().Length > 5)
            {
                result.AddError("Language code cannot exceed 5 characters.");
            }

            return result;
        }
    }

    /// <summary>
    /// Represents the outcome of validating a newsletter subscription.
    /// </summary>
    public class NewsletterSubscriptionValidationResult
    {
        public bool IsValid => Errors.Count == 0;
        public List<string> Errors { get; }

        public NewsletterSubscriptionValidationResult()
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
    /// Aggregated summary information for newsletter subscriptions.
    /// </summary>
    public class NewsletterSummary
    {
        public int TotalSubscribers { get; set; }
        public int ActiveSubscribers { get; set; }
        public int InactiveSubscribers { get; set; }
        public int SubscribersLast30Days { get; set; }
    }

    public class NewsletterSubscriptionResult : DatabaseResult<NewsletterSubscription>
    {
        public new static NewsletterSubscriptionResult Success(NewsletterSubscription subscription, string message = "Success")
        {
            return new NewsletterSubscriptionResult
            {
                IsSuccessful = true,
                ResultCode = 1,
                ErrorMessage = message,
                Data = subscription
            };
        }

        public new static NewsletterSubscriptionResult Failure(string errorMessage, Exception exception = null)
        {
            return new NewsletterSubscriptionResult
            {
                IsSuccessful = false,
                ResultCode = -1,
                ErrorMessage = errorMessage,
                Exception = exception,
                Data = null
            };
        }
    }

    public class NewsletterSubscriptionListResult : DatabaseResult<List<NewsletterSubscription>>
    {
        public int TotalRecords { get; set; }

        public NewsletterSubscriptionListResult()
        {
            Data = new List<NewsletterSubscription>();
        }

        public static NewsletterSubscriptionListResult Success(List<NewsletterSubscription> subscriptions, int totalRecords, string message = "Success")
        {
            return new NewsletterSubscriptionListResult
            {
                IsSuccessful = true,
                ResultCode = 1,
                ErrorMessage = message,
                Data = subscriptions ?? new List<NewsletterSubscription>(),
                TotalRecords = totalRecords
            };
        }

        public new static NewsletterSubscriptionListResult Failure(string errorMessage, Exception exception = null)
        {
            return new NewsletterSubscriptionListResult
            {
                IsSuccessful = false,
                ResultCode = -1,
                ErrorMessage = errorMessage,
                Exception = exception,
                Data = new List<NewsletterSubscription>(),
                TotalRecords = 0
            };
        }
    }

    public class NewsletterSummaryResult : DatabaseResult<NewsletterSummary>
    {
        public new static NewsletterSummaryResult Success(NewsletterSummary summary, string message = "Success")
        {
            return new NewsletterSummaryResult
            {
                IsSuccessful = true,
                ResultCode = 1,
                ErrorMessage = message,
                Data = summary
            };
        }

        public new static NewsletterSummaryResult Failure(string errorMessage, Exception exception = null)
        {
            return new NewsletterSummaryResult
            {
                IsSuccessful = false,
                ResultCode = -1,
                ErrorMessage = errorMessage,
                Exception = exception,
                Data = null
            };
        }
    }
}







