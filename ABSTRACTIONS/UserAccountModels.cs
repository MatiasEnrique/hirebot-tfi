using System;
using System.Collections.Generic;

namespace ABSTRACTIONS
{
    public class UserAccountProfile
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? LastLoginDate { get; set; }
        public bool IsActive { get; set; }

        public string FullName => string.Format("{0} {1}", FirstName ?? string.Empty, LastName ?? string.Empty).Trim();
    }

    public class BillingDocumentSummary
    {
        public int BillingDocumentId { get; set; }
        public string DocumentType { get; set; }
        public string DocumentNumber { get; set; }
        public DateTime IssueDateUtc { get; set; }
        public DateTime? DueDateUtc { get; set; }
        public decimal TotalAmount { get; set; }
        public string Status { get; set; }
        public string CurrencyCode { get; set; }
    }

    public class UserAccountDashboard
    {
        public UserAccountDashboard()
        {
            Subscriptions = new List<ProductSubscription>();
            BillingDocuments = new List<BillingDocumentSummary>();
        }

        public UserAccountProfile Profile { get; set; }
        public List<ProductSubscription> Subscriptions { get; set; }
        public List<BillingDocumentSummary> BillingDocuments { get; set; }
    }

    public class UserAccountDashboardResult : DatabaseResult<UserAccountDashboard>
    {
        public static UserAccountDashboardResult Success(UserAccountDashboard dashboard, string message = "Success")
        {
            return new UserAccountDashboardResult
            {
                IsSuccessful = true,
                ResultCode = 1,
                ErrorMessage = message,
                Data = dashboard
            };
        }

        public new static UserAccountDashboardResult Failure(int resultCode, string errorMessage)
        {
            return new UserAccountDashboardResult
            {
                IsSuccessful = false,
                ResultCode = resultCode,
                ErrorMessage = errorMessage,
                Data = null
            };
        }

        public new static UserAccountDashboardResult Failure(string errorMessage, Exception exception = null)
        {
            return new UserAccountDashboardResult
            {
                IsSuccessful = false,
                ResultCode = -999,
                ErrorMessage = errorMessage,
                Exception = exception,
                Data = null
            };
        }
    }
}
