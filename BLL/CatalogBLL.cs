using System;
using System.Collections.Generic;
using System.Web;
using DAL;
using ABSTRACTIONS;

namespace BLL
{
    public class CatalogBLL
    {
        private readonly CatalogDAL catalogDAL;

        public CatalogBLL()
        {
            catalogDAL = new CatalogDAL();
        }

        public AuthenticationResult CreateCatalog(string name, string description, int createdByUserId)
        {
            var validationResult = ValidateCatalog(name);
            if (!validationResult.IsSuccessful)
                return validationResult;

            var catalog = new Catalog
            {
                Name = name.Trim(),
                Description = string.IsNullOrWhiteSpace(description) ? null : description.Trim(),
                CreatedByUserId = createdByUserId
            };

            bool result = catalogDAL.CreateCatalog(catalog);
            if (result)
                return new AuthenticationResult(true, GetLocalizedString("CatalogCreatedSuccess"));
            else
                return new AuthenticationResult(false, GetLocalizedString("CatalogCreationError"));
        }

        public AuthenticationResult UpdateCatalog(int catalogId, string name, string description, bool isActive)
        {
            var validationResult = ValidateCatalog(name);
            if (!validationResult.IsSuccessful)
                return validationResult;

            var catalog = new Catalog
            {
                CatalogId = catalogId,
                Name = name.Trim(),
                Description = string.IsNullOrWhiteSpace(description) ? null : description.Trim(),
                IsActive = isActive
            };

            bool result = catalogDAL.UpdateCatalog(catalog);
            if (result)
                return new AuthenticationResult(true, GetLocalizedString("CatalogUpdatedSuccess"));
            else
                return new AuthenticationResult(false, GetLocalizedString("CatalogUpdateError"));
        }

        public AuthenticationResult DeleteCatalog(int catalogId)
        {
            bool result = catalogDAL.DeleteCatalog(catalogId);
            if (result)
                return new AuthenticationResult(true, GetLocalizedString("CatalogDeletedSuccess"));
            else
                return new AuthenticationResult(false, GetLocalizedString("CatalogDeleteError"));
        }

        public Catalog GetCatalogById(int catalogId)
        {
            return catalogDAL.GetCatalogById(catalogId);
        }

        public List<Catalog> GetAllCatalogs()
        {
            return catalogDAL.GetAllCatalogs();
        }

        public List<Catalog> GetActiveCatalogs()
        {
            return catalogDAL.GetActiveCatalogs();
        }

        public AuthenticationResult AddProductToCatalog(int catalogId, int productId, int addedByUserId)
        {
            bool result = catalogDAL.AddProductToCatalog(catalogId, productId, addedByUserId);
            if (result)
                return new AuthenticationResult(true, GetLocalizedString("ProductAddedToCatalogSuccess"));
            else
                return new AuthenticationResult(false, GetLocalizedString("ProductAddToCatalogError"));
        }

        public AuthenticationResult RemoveProductFromCatalog(int catalogId, int productId)
        {
            bool result = catalogDAL.RemoveProductFromCatalog(catalogId, productId);
            if (result)
                return new AuthenticationResult(true, GetLocalizedString("ProductRemovedFromCatalogSuccess"));
            else
                return new AuthenticationResult(false, GetLocalizedString("ProductRemoveFromCatalogError"));
        }

        public List<Product> GetProductsByCatalogId(int catalogId)
        {
            return catalogDAL.GetProductsByCatalogId(catalogId);
        }

        private AuthenticationResult ValidateCatalog(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
                return new AuthenticationResult(false, GetLocalizedString("CatalogNameRequired"));

            if (name.Trim().Length < 2)
                return new AuthenticationResult(false, GetLocalizedString("CatalogNameMinLength"));

            if (name.Trim().Length > 100)
                return new AuthenticationResult(false, GetLocalizedString("CatalogNameMaxLength"));

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