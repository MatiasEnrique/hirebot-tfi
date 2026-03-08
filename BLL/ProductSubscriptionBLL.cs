using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ABSTRACTIONS;
using DAL;
using SERVICES;
using ServiceEncryption = SERVICES.EncryptionService;

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

        public ProductSubscriptionResult CreateSubscription(
            int userId, int productId, string paymentMethod,
            string cardholderName, string cardNumber, int expirationMonth, int expirationYear,
            string transferReference,
            string secondPaymentMethod, string secondTransferReference)
        {
            if (userId <= 0)
            {
                return ProductSubscriptionResult.Failure(GetLocalizedString("SubscriptionUserRequired"));
            }

            if (productId <= 0)
            {
                return ProductSubscriptionResult.Failure(GetLocalizedString("SubscriptionProductRequired"));
            }

            if (string.IsNullOrWhiteSpace(paymentMethod))
            {
                paymentMethod = "Tarjeta";
            }

            paymentMethod = paymentMethod.Trim();
            secondPaymentMethod = (secondPaymentMethod ?? string.Empty).Trim();
            transferReference = (transferReference ?? string.Empty).Trim();
            secondTransferReference = (secondTransferReference ?? string.Empty).Trim();

            bool hasCardPayload = !string.IsNullOrWhiteSpace(cardholderName)
                || !string.IsNullOrWhiteSpace(cardNumber)
                || expirationMonth > 0
                || expirationYear > 0;

            bool involvesCard = paymentMethod == "Tarjeta"
                || (paymentMethod == "PagoCombinado" && (secondPaymentMethod == "Tarjeta" || hasCardPayload));
            bool firstMethodIsTransfer = paymentMethod == "Transferencia";

            string normalizedCardNumber = null;

            if (involvesCard)
            {
                string validationError = ValidateSubscriptionInputs(cardholderName, cardNumber, expirationMonth, expirationYear, out normalizedCardNumber);
                if (!string.IsNullOrEmpty(validationError))
                {
                    return ProductSubscriptionResult.Failure(validationError);
                }
            }

            if (firstMethodIsTransfer && string.IsNullOrWhiteSpace(transferReference))
            {
                return ProductSubscriptionResult.Failure(GetLocalizedString("SubscriptionTransferReferenceRequired"));
            }

            if (paymentMethod == "PagoCombinado")
            {
                if (string.IsNullOrWhiteSpace(secondPaymentMethod))
                {
                    return ProductSubscriptionResult.Failure(GetLocalizedString("SubscriptionSecondMethodRequired"));
                }

                if (secondPaymentMethod == "Transferencia" && string.IsNullOrWhiteSpace(secondTransferReference))
                {
                    return ProductSubscriptionResult.Failure(GetLocalizedString("SubscriptionTransferReferenceRequired"));
                }

                // Backward compatibility for older SQL validation that expects @TransferReference
                // when combined payments have bank transfer as second method.
                if (secondPaymentMethod == "Transferencia"
                    && string.IsNullOrWhiteSpace(transferReference)
                    && !string.IsNullOrWhiteSpace(secondTransferReference))
                {
                    transferReference = secondTransferReference;
                }
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

            var subscription = new ProductSubscription
            {
                UserId = userId,
                ProductId = productId,
                ProductName = product.Name,
                ProductPrice = product.Price,
                BillingCycle = string.IsNullOrWhiteSpace(product.BillingCycle) ? "Monthly" : product.BillingCycle,
                PaymentMethod = paymentMethod,
                TransferReference = transferReference,
                SecondPaymentMethod = secondPaymentMethod,
                SecondTransferReference = secondTransferReference,
                CreatedDateUtc = DateTime.UtcNow,
                IsActive = true
            };

            if (involvesCard)
            {
                string cardBrand = DetermineCardBrand(normalizedCardNumber);
                string trimmedCardholder = cardholderName.Trim();
                string encryptedCardNumber = ServiceEncryption.EncryptSymmetric(normalizedCardNumber);
                string encryptedCardholderName = ServiceEncryption.EncryptAsymmetric(trimmedCardholder);

                subscription.CardholderName = MaskCardholderName(trimmedCardholder);
                subscription.CardLast4 = normalizedCardNumber.Substring(normalizedCardNumber.Length - 4);
                subscription.CardBrand = cardBrand;
                subscription.EncryptedCardNumber = encryptedCardNumber;
                subscription.EncryptedCardholderName = encryptedCardholderName;
                subscription.ExpirationMonth = expirationMonth;
                subscription.ExpirationYear = expirationYear;
            }

            ProductSubscriptionResult dalResult = productDAL.CreateProductSubscription(subscription);
            if (!dalResult.IsSuccessful)
            {
                return ProductSubscriptionResult.Failure(string.IsNullOrWhiteSpace(dalResult.ErrorMessage) ? GetLocalizedString("SubscriptionCreationFailed") : dalResult.ErrorMessage);
            }

            ProductSubscription persistedSubscription = dalResult.Data ?? subscription;
            persistedSubscription.ProductName = subscription.ProductName;
            persistedSubscription.ProductPrice = subscription.ProductPrice;
            persistedSubscription.BillingCycle = subscription.BillingCycle;
            persistedSubscription.PaymentMethod = subscription.PaymentMethod;
            HydrateSensitiveData(persistedSubscription);

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
                foreach (var subscription in subscriptions)
                {
                    HydrateSensitiveData(subscription);
                }
                return ProductSubscriptionListResult.Success(subscriptions, GetLocalizedString("SubscriptionListSuccess"));
            }
            catch (Exception ex)
            {
                return ProductSubscriptionListResult.Failure(GetLocalizedString("SubscriptionListError"), ex);
            }
        }

        private void HydrateSensitiveData(ProductSubscription subscription)
        {
            if (subscription == null)
            {
                return;
            }

            try
            {
                if (!string.IsNullOrWhiteSpace(subscription.EncryptedCardholderName))
                {
                    string decryptedName = ServiceEncryption.DecryptAsymmetric(subscription.EncryptedCardholderName);
                    subscription.CardholderName = MaskCardholderName(decryptedName);
                }
            }
            catch
            {
                // Ignore decryption issues to avoid leaking sensitive information via errors
            }

            try
            {
                if (!string.IsNullOrWhiteSpace(subscription.EncryptedCardNumber))
                {
                    string decryptedNumber = ServiceEncryption.DecryptSymmetric(subscription.EncryptedCardNumber);
                    if (!string.IsNullOrEmpty(decryptedNumber) && decryptedNumber.Length >= 4)
                    {
                        subscription.CardLast4 = decryptedNumber.Substring(decryptedNumber.Length - 4);
                    }
                }
            }
            catch
            {
            }
        }

        private string MaskCardholderName(string cardholderName)
        {
            if (string.IsNullOrWhiteSpace(cardholderName))
            {
                return string.Empty;
            }

            string trimmed = cardholderName.Trim();
            if (trimmed.Length <= 2)
            {
                return new string('*', trimmed.Length);
            }

            return string.Concat(trimmed[0], new string('*', trimmed.Length - 2), trimmed[trimmed.Length - 1]);
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

                string fullName = string.Format("{0} {1}", user.FirstName, user.LastName).Trim();
                string paymentDescription = BuildPaymentDescription(subscription);

                EmailService.SendSubscriptionConfirmationEmail(
                    user.Email,
                    fullName,
                    subscription.ProductName,
                    subscription.BillingCycle,
                    subscription.ProductPrice,
                    paymentDescription
                );
            }
            catch
            {
                // Intentionally ignore email errors to avoid breaking subscription flow
            }
        }

        private string BuildPaymentDescription(ProductSubscription subscription)
        {
            string method = subscription.PaymentMethod ?? "Tarjeta";

            switch (method)
            {
                case "Tarjeta":
                    string cardInfo = string.Format("**** {0}", subscription.CardLast4);
                    if (!string.IsNullOrWhiteSpace(subscription.CardBrand))
                        cardInfo = string.Format("{0} ({1})", cardInfo, subscription.CardBrand);
                    return cardInfo;

                case "Transferencia":
                    return string.Format("Transferencia - Ref: {0}", subscription.TransferReference);

                case "CuentaCorriente":
                    return "Cuenta corriente";

                case "PagoCombinado":
                    string first = GetMethodShortDescription(method, subscription.CardLast4, subscription.CardBrand, subscription.TransferReference);
                    string second = GetMethodShortDescription(subscription.SecondPaymentMethod, subscription.CardLast4, subscription.CardBrand, subscription.SecondTransferReference);
                    return string.Format("50% {0} / 50% {1}", first, second);

                default:
                    return method;
            }
        }

        private string GetMethodShortDescription(string method, string cardLast4, string cardBrand, string transferRef)
        {
            switch (method)
            {
                case "Tarjeta":
                    string card = string.Format("**** {0}", cardLast4);
                    if (!string.IsNullOrWhiteSpace(cardBrand))
                        card = string.Format("{0} ({1})", card, cardBrand);
                    return card;
                case "Transferencia":
                    return string.Format("Transferencia (Ref: {0})", transferRef);
                case "CuentaCorriente":
                    return "Cuenta corriente";
                default:
                    return method ?? "";
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
