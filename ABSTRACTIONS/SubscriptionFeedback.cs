using System;

namespace ABSTRACTIONS
{
    public class ProductSubscriptionFeedback
    {
        public int FeedbackId { get; set; }
        public int SubscriptionId { get; set; }
        public int UserId { get; set; }
        public byte Rating { get; set; }
        public string Comment { get; set; }
        public DateTime? CreatedDateUtc { get; set; }
        public DateTime? UpdatedDateUtc { get; set; }
    }

    public class ProductSubscriptionFeedbackResult : DatabaseResult<ProductSubscriptionFeedback>
    {
        public static ProductSubscriptionFeedbackResult Success(ProductSubscriptionFeedback feedback, string message = "Success")
        {
            return new ProductSubscriptionFeedbackResult
            {
                IsSuccessful = true,
                Data = feedback,
                ResultCode = 1,
                ErrorMessage = message
            };
        }

        public static ProductSubscriptionFeedbackResult Failure(int code, string message)
        {
            return new ProductSubscriptionFeedbackResult
            {
                IsSuccessful = false,
                Data = null,
                ResultCode = code,
                ErrorMessage = message
            };
        }

        public static ProductSubscriptionFeedbackResult Failure(string message, Exception ex = null)
        {
            return new ProductSubscriptionFeedbackResult
            {
                IsSuccessful = false,
                Data = null,
                ResultCode = -999,
                ErrorMessage = message,
                Exception = ex
            };
        }
    }
}

