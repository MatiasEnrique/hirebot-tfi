using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ABSTRACTIONS;
using BLL;
using SERVICES;

namespace SECURITY
{
    public class ProductSubscriptionSecurity
    {
        private readonly ProductSubscriptionBLL _productSubscriptionBLL;
        private readonly UserSecurity _userSecurity;
        private readonly LogBLL _logBLL;
        private readonly ProductBLL _productBLL;

        public ProductSubscriptionSecurity()
        {
            _productSubscriptionBLL = new ProductSubscriptionBLL();
            _userSecurity = new UserSecurity();
            _logBLL = new LogBLL();
            _productBLL = new ProductBLL();
        }

        public ProductSubscriptionResult SubscribeToProduct(int productId, string cardholderName, string cardNumber, int expirationMonth, int expirationYear)
        {
            if (!_userSecurity.IsUserAuthenticated())
            {
                return ProductSubscriptionResult.Failure(GetLocalizedString("SubscriptionAuthRequired"));
            }

            var currentUser = _userSecurity.GetCurrentUser();
            if (currentUser == null)
            {
                return ProductSubscriptionResult.Failure(GetLocalizedString("SubscriptionAuthRequired"));
            }

            try
            {
                var result = _productSubscriptionBLL.CreateSubscription(currentUser.UserId, productId, cardholderName, cardNumber, expirationMonth, expirationYear);

                LogSubscriptionAttempt(result, currentUser, productId);

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log
                {
                    LogType = LogService.LogTypes.ERROR,
                    UserId = currentUser.UserId,
                    Description = $"Unexpected error subscribing user {currentUser.Username} to product {productId}: {ex.Message}",
                    CreatedAt = DateTime.Now
                });

                return ProductSubscriptionResult.Failure(GetLocalizedString("SubscriptionUnexpectedError"));
            }
        }

        public ProductSubscriptionListResult GetCurrentUserSubscriptions()
        {
            if (!_userSecurity.IsUserAuthenticated())
            {
                return ProductSubscriptionListResult.Failure(GetLocalizedString("SubscriptionAuthRequired"));
            }

            var currentUser = _userSecurity.GetCurrentUser();
            if (currentUser == null)
            {
                return ProductSubscriptionListResult.Failure(GetLocalizedString("SubscriptionAuthRequired"));
            }

            try
            {
                return _productSubscriptionBLL.GetSubscriptionsByUser(currentUser.UserId);
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log
                {
                    LogType = LogService.LogTypes.ERROR,
                    UserId = currentUser.UserId,
                    Description = $"Unexpected error retrieving subscriptions for user {currentUser.Username}: {ex.Message}",
                    CreatedAt = DateTime.Now
                });

                return ProductSubscriptionListResult.Failure(GetLocalizedString("SubscriptionListError"));
            }
        }

        public List<Product> GetActiveProductsForSubscription()
        {
            if (!_userSecurity.IsUserAuthenticated())
            {
                return new List<Product>();
            }

            try
            {
                var products = _productBLL.GetActiveProducts() ?? new List<Product>();
                return products.Where(p => p.IsActive).OrderBy(p => p.Name, StringComparer.CurrentCultureIgnoreCase).ToList();
            }
            catch
            {
                return new List<Product>();
            }
        }

        private void LogSubscriptionAttempt(ProductSubscriptionResult result, User currentUser, int productId)
        {
            if (result == null)
            {
                return;
            }

            var logType = result.IsSuccessful ? LogService.LogTypes.CREATE : LogService.LogTypes.ERROR;
            var description = result.IsSuccessful
                ? $"User {currentUser.Username} subscribed to product {productId}"
                : $"Subscription failed for user {currentUser.Username} and product {productId}: {result.ErrorMessage}";

            _logBLL.CreateLog(new Log
            {
                LogType = logType,
                UserId = currentUser.UserId,
                Description = description,
                CreatedAt = DateTime.Now
            });
        }

        private string GetLocalizedString(string key)
        {
            try
            {
                return HttpContext.GetGlobalResourceObject("GlobalResources", key)?.ToString() ?? key;
            }
            catch
            {
                return key;
            }
        }
    }
}
