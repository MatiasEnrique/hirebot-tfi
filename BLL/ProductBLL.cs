using System;
using System.Collections.Generic;
using System.Web;
using DAL;
using ABSTRACTIONS;

namespace BLL
{
    public class ProductBLL
    {
        private readonly ProductDAL productDAL;

        public ProductBLL()
        {
            productDAL = new ProductDAL();
        }

        public AuthenticationResult CreateProduct(string name, string description, decimal price, string billingCycle, int maxChatbots, int maxMessages, string features, string category, int createdByUserId)
        {
            var validationResult = ValidateProduct(name, price, maxChatbots, maxMessages);
            if (!validationResult.IsSuccessful)
                return validationResult;

            var product = new Product
            {
                Name = name.Trim(),
                Description = string.IsNullOrWhiteSpace(description) ? null : description.Trim(),
                Price = price,
                BillingCycle = string.IsNullOrWhiteSpace(billingCycle) ? "Monthly" : billingCycle,
                MaxChatbots = maxChatbots,
                MaxMessagesPerMonth = maxMessages,
                Features = string.IsNullOrWhiteSpace(features) ? null : features.Trim(),
                Category = string.IsNullOrWhiteSpace(category) ? null : category.Trim(),
                CreatedByUserId = createdByUserId
            };

            bool result = productDAL.CreateProduct(product);
            if (result)
                return new AuthenticationResult(true, GetLocalizedString("ProductCreatedSuccess"));
            else
                return new AuthenticationResult(false, GetLocalizedString("ProductCreationError"));
        }

        public AuthenticationResult UpdateProduct(int productId, string name, string description, decimal price, string billingCycle, int maxChatbots, int maxMessages, string features, string category, bool isActive)
        {
            var validationResult = ValidateProduct(name, price, maxChatbots, maxMessages);
            if (!validationResult.IsSuccessful)
                return validationResult;

            var product = new Product
            {
                ProductId = productId,
                Name = name.Trim(),
                Description = string.IsNullOrWhiteSpace(description) ? null : description.Trim(),
                Price = price,
                BillingCycle = string.IsNullOrWhiteSpace(billingCycle) ? "Monthly" : billingCycle,
                MaxChatbots = maxChatbots,
                MaxMessagesPerMonth = maxMessages,
                Features = string.IsNullOrWhiteSpace(features) ? null : features.Trim(),
                Category = string.IsNullOrWhiteSpace(category) ? null : category.Trim(),
                IsActive = isActive
            };

            bool result = productDAL.UpdateProduct(product);
            if (result)
                return new AuthenticationResult(true, GetLocalizedString("ProductUpdatedSuccess"));
            else
                return new AuthenticationResult(false, GetLocalizedString("ProductUpdateError"));
        }

        public AuthenticationResult DeleteProduct(int productId)
        {
            bool result = productDAL.DeleteProduct(productId);
            if (result)
                return new AuthenticationResult(true, GetLocalizedString("ProductDeletedSuccess"));
            else
                return new AuthenticationResult(false, GetLocalizedString("ProductDeleteError"));
        }

        public Product GetProductById(int productId)
        {
            return productDAL.GetProductById(productId);
        }

        public List<Product> GetAllProducts()
        {
            return productDAL.GetAllProducts();
        }

        public List<Product> GetActiveProducts()
        {
            return productDAL.GetActiveProducts();
        }

        public List<Product> GetProductsByCategory(string category)
        {
            if (string.IsNullOrWhiteSpace(category))
                return new List<Product>();

            return productDAL.GetProductsByCategory(category.Trim());
        }

        private AuthenticationResult ValidateProduct(string name, decimal price, int maxChatbots, int maxMessages)
        {
            if (string.IsNullOrWhiteSpace(name))
                return new AuthenticationResult(false, GetLocalizedString("ProductNameRequired"));

            if (name.Trim().Length < 2)
                return new AuthenticationResult(false, GetLocalizedString("ProductNameMinLength"));

            if (name.Trim().Length > 100)
                return new AuthenticationResult(false, GetLocalizedString("ProductNameMaxLength"));

            if (price < 0)
                return new AuthenticationResult(false, GetLocalizedString("ProductPriceInvalid"));

            if (maxChatbots < 0)
                return new AuthenticationResult(false, "Max Chatbots must be a positive number");

            if (maxMessages < 0)
                return new AuthenticationResult(false, "Max Messages must be a positive number");

            return new AuthenticationResult(true, string.Empty);
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