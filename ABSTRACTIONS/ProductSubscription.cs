using System;

namespace ABSTRACTIONS
{
    public class ProductSubscription
    {
        public int SubscriptionId { get; set; }
        public int ProductId { get; set; }
        public int UserId { get; set; }
        public string ProductName { get; set; }
        public decimal ProductPrice { get; set; }
        public string BillingCycle { get; set; }
        public string CardholderName { get; set; }
        public string CardLast4 { get; set; }
        public string CardBrand { get; set; }
        public string EncryptedCardNumber { get; set; }
        public string EncryptedCardholderName { get; set; }
        public string DecryptedCardNumber { get; set; }
        public string DecryptedCardholderName { get; set; }
        public int ExpirationMonth { get; set; }
        public int ExpirationYear { get; set; }
        public DateTime CreatedDateUtc { get; set; }
        public bool IsActive { get; set; }
        public DateTime? CancelledDateUtc { get; set; }
    }

    public class ProductSubscriptionResult : DatabaseResult<ProductSubscription>
    {
        public ProductSubscriptionResult()
        {
        }

        public ProductSubscriptionResult(bool isSuccessful, ProductSubscription subscription, string message = "") : base(isSuccessful, subscription, isSuccessful ? 1 : 0, message)
        {
        }

        public static ProductSubscriptionResult Success(ProductSubscription subscription, string message = "Success")
        {
            return new ProductSubscriptionResult(true, subscription, message);
        }

        public static ProductSubscriptionResult Failure(string message, Exception exception = null)
        {
            return new ProductSubscriptionResult(false, null, message) { Exception = exception };
        }
    }

    public class ProductSubscriptionListResult : DatabaseResult<System.Collections.Generic.List<ProductSubscription>>
    {
        public ProductSubscriptionListResult()
        {
            Data = new System.Collections.Generic.List<ProductSubscription>();
        }

        public ProductSubscriptionListResult(bool isSuccessful, System.Collections.Generic.List<ProductSubscription> subscriptions, string message = "") : base(isSuccessful, subscriptions, isSuccessful ? 1 : 0, message)
        {
        }

        public static ProductSubscriptionListResult Success(System.Collections.Generic.List<ProductSubscription> subscriptions, string message = "Success")
        {
            return new ProductSubscriptionListResult(true, subscriptions, message);
        }

        public static ProductSubscriptionListResult Failure(string message, Exception exception = null)
        {
            return new ProductSubscriptionListResult(false, new System.Collections.Generic.List<ProductSubscription>(), message) { Exception = exception };
        }
    }
}
