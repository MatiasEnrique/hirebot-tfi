using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ABSTRACTIONS;
using DAL;
using SERVICES;

namespace BLL
{
    public class ProductSubscriptionBLL
    {
        private readonly ProductDAL productDAL;
        private readonly UserDALProduction userDAL;

        public ProductSubscriptionBLL()
        {
            productDAL = new ProductDAL();
            userDAL = new UserDALProduction();
        }

        public ProductSubscriptionResult CreateSubscription(int userId, int productId, string cardholderName, string cardNumber, int expirationMonth, int expirationYear)
        {
            if (userId <= 0)
            {
                return ProductSubscriptionResult.Failure(GetLocalizedString("SubscriptionUserRequired"));
            }

            if (productId <= 0)
            {
                return ProductSubscriptionResult.Failure(GetLocalizedString("SubscriptionProductRequired"));
            }

            string normalizedCardNumber;
            string validationError = ValidateSubscriptionInputs(cardholderName, cardNumber, expirationMonth, expirationYear, out normalizedCardNumber);
            if (!string.IsNullOrEmpty(validationError))
            {
                return ProductSubscriptionResult.Failure(validationError);
            }

            Product product = productDAL.GetProductById(productId);
            if (product == null)
            {
                return ProductSubscriptionResult.Failure(GetLocalizedString("SubscriptionProductNotFound"));
            }

            if (!product.IsActive)
            {
                return ProductSubscriptionResult.Failure(GetLocalizedString("SubscriptionProductInactive"));
            }

            ProductSubscription existingSubscription = productDAL.GetActiveSubscription(userId, productId);
            if (existingSubscription != null)
            {
                return ProductSubscriptionResult.Failure(GetLocalizedString("SubscriptionAlreadyExists"));
            }

            string cardBrand = DetermineCardBrand(normalizedCardNumber);

            var subscription = new ProductSubscription
            {
                UserId = userId,
                ProductId = productId,
                ProductName = product.Name,
                ProductPrice = product.Price,
                BillingCycle = string.IsNullOrWhiteSpace(product.BillingCycle) ? "Monthly" : product.BillingCycle,
                CardholderName = cardholderName.Trim(),
                CardLast4 = normalizedCardNumber.Substring(normalizedCardNumber.Length - 4),
                CardBrand = cardBrand,
                ExpirationMonth = expirationMonth,
                ExpirationYear = expirationYear,
                CreatedDateUtc = DateTime.UtcNow,
                IsActive = true
            };

            ProductSubscriptionResult dalResult = productDAL.CreateProductSubscription(subscription);
            if (!dalResult.IsSuccessful)
            {
                return ProductSubscriptionResult.Failure(string.IsNullOrWhiteSpace(dalResult.ErrorMessage) ? GetLocalizedString("SubscriptionCreationFailed") : dalResult.ErrorMessage);
            }

            ProductSubscription persistedSubscription = dalResult.Data ?? subscription;
            persistedSubscription.ProductName = subscription.ProductName;
            persistedSubscription.ProductPrice = subscription.ProductPrice;
            persistedSubscription.BillingCycle = subscription.BillingCycle;

            SendSubscriptionEmail(userId, persistedSubscription);

            return ProductSubscriptionResult.Success(persistedSubscription, GetLocalizedString("SubscriptionCreatedSuccess"));
        }

        public ProductSubscriptionListResult GetSubscriptionsByUser(int userId)
        {
            if (userId <= 0)
            {
                return ProductSubscriptionListResult.Failure(GetLocalizedString("SubscriptionUserRequired"));
            }

            try
            {
                List<ProductSubscription> subscriptions = productDAL.GetSubscriptionsByUser(userId) ?? new List<ProductSubscription>();
                return ProductSubscriptionListResult.Success(subscriptions, GetLocalizedString("SubscriptionListSuccess"));
            }
            catch (Exception ex)
            {
                return ProductSubscriptionListResult.Failure(GetLocalizedString("SubscriptionListError"), ex);
            }
        }

        private string ValidateSubscriptionInputs(string cardholderName, string cardNumber, int expirationMonth, int expirationYear, out string normalizedCardNumber)
        {
            normalizedCardNumber = string.Empty;

            if (string.IsNullOrWhiteSpace(cardholderName))
            {
                return GetLocalizedString("SubscriptionCardholderRequired");
            }

            if (string.IsNullOrWhiteSpace(cardNumber))
            {
                return GetLocalizedString("SubscriptionCardNumberRequired");
            }

            string digitsOnly = new string(cardNumber.Where(char.IsDigit).ToArray());
            if (string.IsNullOrEmpty(digitsOnly))
            {
                return GetLocalizedString("SubscriptionCardNumberInvalid");
            }

            if (digitsOnly.Length < 12 || digitsOnly.Length > 19)
            {
                return GetLocalizedString("SubscriptionCardNumberLength");
            }

            if (!PassesLuhnCheck(digitsOnly))
            {
                return GetLocalizedString("SubscriptionCardNumberInvalid");
            }

            if (expirationMonth < 1 || expirationMonth > 12)
            {
                return GetLocalizedString("SubscriptionExpirationInvalid");
            }

            int currentYear = DateTime.UtcNow.Year;
            int currentMonth = DateTime.UtcNow.Month;

            if (expirationYear < currentYear)
            {
                return GetLocalizedString("SubscriptionExpirationExpired");
            }

            if (expirationYear == currentYear && expirationMonth < currentMonth)
            {
                return GetLocalizedString("SubscriptionExpirationExpired");
            }

            if (expirationYear > currentYear + 30)
            {
                return GetLocalizedString("SubscriptionExpirationInvalid");
            }

            normalizedCardNumber = digitsOnly;
            return null;
        }

        private bool PassesLuhnCheck(string cardNumber)
        {
            int sum = 0;
            bool doubleDigit = false;

            for (int i = cardNumber.Length - 1; i >= 0; i--)
            {
                if (!char.IsDigit(cardNumber[i]))
                {
                    return false;
                }

                int digit = cardNumber[i] - '0';

                if (doubleDigit)
                {
                    digit *= 2;
                    if (digit > 9)
                    {
                        digit -= 9;
                    }
                }

                sum += digit;
                doubleDigit = !doubleDigit;
            }

            return sum % 10 == 0;
        }

        private string DetermineCardBrand(string cardNumber)
        {
            if (string.IsNullOrEmpty(cardNumber))
            {
                return null;
            }

            if (cardNumber.StartsWith("4"))
            {
                return "Visa";
            }

            if (cardNumber.StartsWith("34") || cardNumber.StartsWith("37"))
            {
                return "American Express";
            }

            if (cardNumber.StartsWith("6011") || cardNumber.StartsWith("65"))
            {
                return "Discover";
            }

            if (cardNumber.StartsWith("36") || cardNumber.StartsWith("38"))
            {
                return "Diners Club";
            }

            if (cardNumber.Length >= 2)
            {
                int prefix = int.Parse(cardNumber.Substring(0, 2));
                if (prefix >= 51 && prefix <= 55)
                {
                    return "Mastercard";
                }
            }

            if (cardNumber.StartsWith("35"))
            {
                return "JCB";
            }

            return "Card";
        }

        private void SendSubscriptionEmail(int userId, ProductSubscription subscription)
        {
            try
            {
                User user = GetUserById(userId);
                if (user == null || string.IsNullOrWhiteSpace(user.Email))
                {
                    return;
                }

                string fullName = ($"{user.FirstName} {user.LastName}").Trim();
                EmailService.SendSubscriptionConfirmationEmail(
                    user.Email,
                    fullName,
                    subscription.ProductName,
                    subscription.BillingCycle,
                    subscription.ProductPrice,
                    subscription.CardLast4,
                    subscription.CardBrand
                );
            }
            catch
            {
                // Intentionally ignore email errors to avoid breaking subscription flow
            }
        }

        private User GetUserById(int userId)
        {
            try
            {
                var usersResult = userDAL.GetAllUsers(includeInactive: true);
                if (usersResult.IsSuccessful && usersResult.Data != null)
                {
                    return usersResult.Data.FirstOrDefault(u => u.UserId == userId);
                }
            }
            catch
            {
            }

            return null;
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
