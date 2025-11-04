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
        private readonly AuthorizationSecurity _authorizationSecurity;

        public AdminSecurity()
        {
            userBLL = new UserBLL();
            productBLL = new ProductBLL();
            catalogBLL = new CatalogBLL();
            _logBLL = new LogBLL();
            _authorizationSecurity = new AuthorizationSecurity();
        }

        public bool IsUserAdmin()
        {
            if (!IsUserAuthenticated())
                return false;

            if (_authorizationSecurity.UserHasAnyPermission("~/AdminDashboard.aspx", "~/AdminRoles.aspx"))
            {
                return true;
            }

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

        #region User Management Methods

        /// <summary>
        /// Gets all users for admin management
        /// </summary>
        /// <param name="includeInactive">Whether to include inactive users</param>
        /// <returns>List of users</returns>
        public System.Collections.Generic.List<User> GetAllUsers(bool includeInactive = true)
        {
            if (!IsUserAdmin())
                return new System.Collections.Generic.List<User>();

            try
            {
                return userBLL.GetAllUsersForAdmin(includeInactive);
            }
            catch (Exception ex)
            {
                LogError(null, $"Error getting all users: {ex.Message}");
                return new System.Collections.Generic.List<User>();
            }
        }

        /// <summary>
        /// Gets a user by ID for admin editing
        /// </summary>
        /// <param name="userId">User ID</param>
        /// <returns>User object or null</returns>
        public User GetUserById(int userId)
        {
            if (!IsUserAdmin())
                return null;

            try
            {
                return userBLL.GetUserById(userId);
            }
            catch (Exception ex)
            {
                LogError(null, $"Error getting user by ID {userId}: {ex.Message}");
                return null;
            }
        }

        /// <summary>
        /// Updates a user (admin operation)
        /// </summary>
        /// <param name="user">User object with updated information</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult UpdateUser(User user)
        {
            if (!IsUserAdmin())
                return DatabaseResult.Failure(-1, "Acceso denegado. Se requieren privilegios de administrador.");

            try
            {
                var currentUser = GetCurrentUser();
                if (currentUser == null)
                    return DatabaseResult.Failure(-2, "Usuario actual no encontrado.");

                var result = userBLL.UpdateUserAdmin(user, currentUser.UserId);

                if (result.IsSuccessful)
                {
                    LogAccess(currentUser.UserId, $"Actualizó usuario: {user.Username} (ID: {user.UserId})");
                }
                else
                {
                    LogError(currentUser.UserId, $"Error al actualizar usuario {user.Username}: {result.ErrorMessage}");
                }

                return result;
            }
            catch (Exception ex)
            {
                LogError(null, $"Excepción al actualizar usuario: {ex.Message}");
                return DatabaseResult.Failure(-999, "Ocurrió un error al actualizar el usuario.");
            }
        }

        /// <summary>
        /// Deletes (deactivates) a user (admin operation)
        /// </summary>
        /// <param name="userId">User ID to delete</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult DeleteUser(int userId)
        {
            if (!IsUserAdmin())
                return DatabaseResult.Failure(-1, "Acceso denegado. Se requieren privilegios de administrador.");

            try
            {
                var currentUser = GetCurrentUser();
                if (currentUser == null)
                    return DatabaseResult.Failure(-2, "Usuario actual no encontrado.");

                var result = userBLL.DeleteUserAdmin(userId, currentUser.UserId);

                if (result.IsSuccessful)
                {
                    LogAccess(currentUser.UserId, $"Eliminó usuario ID: {userId}");
                }
                else
                {
                    LogError(currentUser.UserId, $"Error al eliminar usuario ID {userId}: {result.ErrorMessage}");
                }

                return result;
            }
            catch (Exception ex)
            {
                LogError(null, $"Excepción al eliminar usuario: {ex.Message}");
                return DatabaseResult.Failure(-999, "Ocurrió un error al eliminar el usuario.");
            }
        }

        /// <summary>
        /// Activates a user (admin operation)
        /// </summary>
        /// <param name="userId">User ID to activate</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult ActivateUser(int userId)
        {
            if (!IsUserAdmin())
                return DatabaseResult.Failure(-1, "Acceso denegado. Se requieren privilegios de administrador.");

            try
            {
                var currentUser = GetCurrentUser();
                if (currentUser == null)
                    return DatabaseResult.Failure(-2, "Usuario actual no encontrado.");

                var result = userBLL.ActivateUserAdmin(userId, currentUser.UserId);

                if (result.IsSuccessful)
                {
                    LogAccess(currentUser.UserId, $"Activó usuario ID: {userId}");
                }
                else
                {
                    LogError(currentUser.UserId, $"Error al activar usuario ID {userId}: {result.ErrorMessage}");
                }

                return result;
            }
            catch (Exception ex)
            {
                LogError(null, $"Excepción al activar usuario: {ex.Message}");
                return DatabaseResult.Failure(-999, "Ocurrió un error al activar el usuario.");
            }
        }

        /// <summary>
        /// Creates a new user (admin operation)
        /// </summary>
        /// <param name="username">Username</param>
        /// <param name="email">Email address</param>
        /// <param name="password">Password</param>
        /// <param name="firstName">First name</param>
        /// <param name="lastName">Last name</param>
        /// <param name="userRole">User role (user or admin)</param>
        /// <param name="isActive">Whether user is active</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult CreateUser(string username, string email, string password, string firstName, string lastName, string userRole, bool isActive)
        {
            if (!IsUserAdmin())
                return DatabaseResult.Failure(-1, "Acceso denegado. Se requieren privilegios de administrador.");

            try
            {
                var currentUser = GetCurrentUser();
                if (currentUser == null)
                    return DatabaseResult.Failure(-2, "Usuario actual no encontrado.");

                var result = userBLL.CreateUserAdmin(username, email, password, firstName, lastName, userRole, isActive, currentUser.UserId);

                if (result.IsSuccessful)
                {
                    LogAccess(currentUser.UserId, $"Creó nuevo usuario: {username} (Rol: {userRole})");
                }
                else
                {
                    LogError(currentUser.UserId, $"Error al crear usuario {username}: {result.ErrorMessage}");
                }

                return result;
            }
            catch (Exception ex)
            {
                LogError(null, $"Excepción al crear usuario: {ex.Message}");
                return DatabaseResult.Failure(-999, "Ocurrió un error al crear el usuario.");
            }
        }

        /// <summary>
        /// Gets the current user from session or database
        /// </summary>
        /// <returns>Current user or null</returns>
        private User GetCurrentUser()
        {
            try
            {
                if (HttpContext.Current?.Session != null)
                {
                    var sessionUser = HttpContext.Current.Session["CurrentUser"] as User;
                    if (sessionUser != null)
                        return sessionUser;
                }

                if (HttpContext.Current?.User?.Identity?.Name != null)
                {
                    return userBLL.GetUserByUsername(HttpContext.Current.User.Identity.Name);
                }

                return null;
            }
            catch
            {
                return null;
            }
        }

        #endregion
    }
}