using System;
using System.Web;
using System.Web.Security;
using BLL;
using ABSTRACTIONS;
using SERVICES;

namespace SECURITY
{
    public class AdminSecurity
    {
        private readonly UserBLL userBLL;
        private readonly ProductBLL productBLL;
        private readonly CatalogBLL catalogBLL;
        private readonly LogBLL _logBLL;

        public AdminSecurity()
        {
            userBLL = new UserBLL();
            productBLL = new ProductBLL();
            catalogBLL = new CatalogBLL();
            _logBLL = new LogBLL();
        }

        public bool IsUserAdmin()
        {
            if (!IsUserAuthenticated())
                return false;

            try
            {
                // First, check if user data is already in session to avoid database call
                var sessionUser = HttpContext.Current.Session["CurrentUser"] as User;
                if (sessionUser != null)
                {
                    return sessionUser.UserRole.Equals("admin", StringComparison.OrdinalIgnoreCase);
                }

                // If not in session, get from database and cache it
                string username = HttpContext.Current.User.Identity.Name;
                var user = userBLL.GetUserByUsername(username);
                
                if (user != null)
                {
                    // Cache user in session for future calls
                    HttpContext.Current.Session["CurrentUser"] = user;
                    return user.UserRole.Equals("admin", StringComparison.OrdinalIgnoreCase);
                }
                
                return false;
            }
            catch
            {
                return false;
            }
        }

        public bool IsUserAuthenticated()
        {
            return HttpContext.Current.User?.Identity?.IsAuthenticated == true;
        }

        public void RedirectIfNotAdmin()
        {
            if (!IsUserAdmin())
            {
                if (!IsUserAuthenticated())
                {
                    HttpContext.Current.Response.Redirect("~/SignIn.aspx");
                }
                else
                {
                    HttpContext.Current.Response.Redirect("~/Default.aspx");
                }
            }
        }

        public AuthenticationResult CreateProduct(string name, string description, decimal price, string billingCycle, int maxChatbots, int maxMessages, string features, string category)
        {
            if (!IsUserAdmin())
                return new AuthenticationResult(false, "Access denied. Admin privileges required.");

            try
            {
                string username = HttpContext.Current.User.Identity.Name;
                var user = userBLL.GetUserByUsername(username);
                if (user == null)
                    return new AuthenticationResult(false, "User not found.");

                return productBLL.CreateProduct(name, description, price, billingCycle, maxChatbots, maxMessages, features, category, user.UserId);
            }
            catch (Exception)
            {
                return new AuthenticationResult(false, "An error occurred while creating the product.");
            }
        }

        public AuthenticationResult UpdateProduct(int productId, string name, string description, decimal price, string billingCycle, int maxChatbots, int maxMessages, string features, string category, bool isActive)
        {
            if (!IsUserAdmin())
                return new AuthenticationResult(false, "Access denied. Admin privileges required.");

            try
            {
                return productBLL.UpdateProduct(productId, name, description, price, billingCycle, maxChatbots, maxMessages, features, category, isActive);
            }
            catch (Exception)
            {
                return new AuthenticationResult(false, "An error occurred while updating the product.");
            }
        }

        public AuthenticationResult DeleteProduct(int productId)
        {
            if (!IsUserAdmin())
                return new AuthenticationResult(false, "Access denied. Admin privileges required.");

            try
            {
                return productBLL.DeleteProduct(productId);
            }
            catch (Exception)
            {
                return new AuthenticationResult(false, "An error occurred while deleting the product.");
            }
        }

        public AuthenticationResult CreateCatalog(string name, string description)
        {
            if (!IsUserAdmin())
                return new AuthenticationResult(false, "Access denied. Admin privileges required.");

            try
            {
                string username = HttpContext.Current.User.Identity.Name;
                var user = userBLL.GetUserByUsername(username);
                if (user == null)
                    return new AuthenticationResult(false, "User not found.");

                return catalogBLL.CreateCatalog(name, description, user.UserId);
            }
            catch (Exception)
            {
                return new AuthenticationResult(false, "An error occurred while creating the catalog.");
            }
        }

        public AuthenticationResult UpdateCatalog(int catalogId, string name, string description, bool isActive)
        {
            if (!IsUserAdmin())
                return new AuthenticationResult(false, "Access denied. Admin privileges required.");

            try
            {
                return catalogBLL.UpdateCatalog(catalogId, name, description, isActive);
            }
            catch (Exception)
            {
                return new AuthenticationResult(false, "An error occurred while updating the catalog.");
            }
        }

        public AuthenticationResult DeleteCatalog(int catalogId)
        {
            if (!IsUserAdmin())
                return new AuthenticationResult(false, "Access denied. Admin privileges required.");

            try
            {
                return catalogBLL.DeleteCatalog(catalogId);
            }
            catch (Exception)
            {
                return new AuthenticationResult(false, "An error occurred while deleting the catalog.");
            }
        }

        public AuthenticationResult AddProductToCatalog(int catalogId, int productId)
        {
            if (!IsUserAdmin())
                return new AuthenticationResult(false, "Access denied. Admin privileges required.");

            try
            {
                string username = HttpContext.Current.User.Identity.Name;
                var user = userBLL.GetUserByUsername(username);
                if (user == null)
                    return new AuthenticationResult(false, "User not found.");

                return catalogBLL.AddProductToCatalog(catalogId, productId, user.UserId);
            }
            catch (Exception)
            {
                return new AuthenticationResult(false, "An error occurred while adding the product to the catalog.");
            }
        }

        public AuthenticationResult RemoveProductFromCatalog(int catalogId, int productId)
        {
            if (!IsUserAdmin())
                return new AuthenticationResult(false, "Access denied. Admin privileges required.");

            try
            {
                return catalogBLL.RemoveProductFromCatalog(catalogId, productId);
            }
            catch (Exception)
            {
                return new AuthenticationResult(false, "An error occurred while removing the product from the catalog.");
            }
        }

        public ProductBLL GetProductBLL()
        {
            if (!IsUserAdmin())
                return null;
            return productBLL;
        }

        public CatalogBLL GetCatalogBLL()
        {
            if (!IsUserAdmin())
                return null;
            return catalogBLL;
        }

        // Logging methods for UI layer to maintain architecture compliance
        public bool LogError(int? userId, string errorDescription)
        {
            return _logBLL.CreateLog(new Log
            {
                LogType = LogService.LogTypes.ERROR,
                UserId = userId,
                Description = errorDescription,
                CreatedAt = DateTime.Now
            });
        }

        public bool LogAccess(int userId, string resource)
        {
            return _logBLL.CreateLog(new Log
            {
                LogType = LogService.LogTypes.ACCESS,
                UserId = userId,
                Description = resource,
                CreatedAt = DateTime.Now
            });
        }

        public ABSTRACTIONS.PaginatedResult<Log> GetAllLogsPaginated(int pageNumber, int pageSize)
        {
            if (!IsUserAdmin())
            {
                return new ABSTRACTIONS.PaginatedResult<Log>
                {
                    Data = new System.Collections.Generic.List<Log>(),
                    TotalRecords = 0,
                    CurrentPage = pageNumber,
                    PageSize = pageSize
                };
            }

            return _logBLL.GetAllLogsPaginated(pageNumber, pageSize);
        }

        public ABSTRACTIONS.PaginatedResult<Log> GetFilteredLogsPaginated(LogFilterCriteria filters, int pageNumber, int pageSize)
        {
            if (!IsUserAdmin())
            {
                return new ABSTRACTIONS.PaginatedResult<Log>
                {
                    Data = new System.Collections.Generic.List<Log>(),
                    TotalRecords = 0,
                    CurrentPage = pageNumber,
                    PageSize = pageSize
                };
            }

            return _logBLL.GetFilteredLogsPaginated(filters, pageNumber, pageSize);
        }
    }
}