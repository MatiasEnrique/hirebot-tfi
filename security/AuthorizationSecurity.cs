using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using ABSTRACTIONS;
using BLL;

namespace SECURITY
{
    public class AuthorizationSecurity
    {
        private const string SessionPermissionSetKey = "CurrentUserPermissionSet";
        private const string SessionAllPermissionSetKey = "AllPermissionKeys";
        private const string SessionAdminFlagKey = "IsAdminUser";

        private readonly AdminRoleBLL _adminRoleBll;
        private readonly UserSecurity _userSecurity;

        public AuthorizationSecurity()
        {
            _adminRoleBll = new AdminRoleBLL();
            _userSecurity = new UserSecurity();
        }

        public bool EnsurePageAccess(Page page)
        {
            var context = HttpContext.Current;
            if (context == null)
            {
                return true;
            }

            // Allow access to public pages without authentication
            if (IsPublicPage(context))
            {
                return true;
            }

            if (!IsUserAuthenticated(context))
            {
                FormsAuthentication.RedirectToLoginPage();
                return false;
            }

            var permissionKey = BuildPermissionKey(context);
            var baseKey = page?.AppRelativeVirtualPath ?? context.Request?.AppRelativeCurrentExecutionFilePath ?? string.Empty;

            var allPermissionKeys = GetAllPermissionKeys();
            if (!IsControlledResource(permissionKey, baseKey, allPermissionKeys))
            {
                return true;
            }

            var permissionSet = GetOrLoadPermissionSet();

            if (HasPermission(permissionKey, permissionSet) || (string.IsNullOrWhiteSpace(permissionKey) && HasPermission(baseKey, permissionSet)) || HasPermission(baseKey, permissionSet))
            {
                return true;
            }

            RedirectToAccessDenied(context);
            return false;
        }

        public bool UserHasPermission(string permissionKey)
        {
            if (string.IsNullOrWhiteSpace(permissionKey))
            {
                return false;
            }

            var permissionSet = GetOrLoadPermissionSet();
            return HasPermission(permissionKey, permissionSet);
        }

        public bool UserHasAnyPermission(params string[] permissionKeys)
        {
            if (permissionKeys == null || permissionKeys.Length == 0)
            {
                return false;
            }

            var permissionSet = GetOrLoadPermissionSet();
            return permissionKeys.Any(key => HasPermission(key, permissionSet));
        }

        public void RefreshCurrentUserPermissions()
        {
            var session = HttpContext.Current?.Session;
            if (session == null)
            {
                return;
            }

            session.Remove(SessionPermissionSetKey);
            var set = LoadPermissionsForCurrentUser();
            session[SessionPermissionSetKey] = set;

            UpdateAdminFlags(set);
        }

        private HashSet<string> GetOrLoadPermissionSet()
        {
            var session = HttpContext.Current?.Session;
            if (session == null)
            {
                return new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            }

            if (!(session[SessionPermissionSetKey] is HashSet<string> permissionSet))
            {
                permissionSet = LoadPermissionsForCurrentUser();
                session[SessionPermissionSetKey] = permissionSet;
                UpdateAdminFlags(permissionSet);
            }

            return permissionSet;
        }

        private HashSet<string> LoadPermissionsForCurrentUser()
        {
            var set = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            var user = _userSecurity.GetCurrentUser();

            if (user == null)
            {
                return set;
            }

            var result = _adminRoleBll.GetPermissionsByUser(user.UserId);
            if (result.IsSuccessful && result.Data != null)
            {
                foreach (var permission in result.Data)
                {
                    if (!string.IsNullOrWhiteSpace(permission))
                    {
                        set.Add(permission.Trim());
                    }
                }
            }

            return set;
        }

        private HashSet<string> GetAllPermissionKeys()
        {
            var session = HttpContext.Current?.Session;
            if (session == null)
            {
                return LoadAllPermissionKeys();
            }

            if (!(session[SessionAllPermissionSetKey] is HashSet<string> set))
            {
                set = LoadAllPermissionKeys();
                session[SessionAllPermissionSetKey] = set;
            }

            return set;
        }

        private HashSet<string> LoadAllPermissionKeys()
        {
            var set = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            var result = _adminRoleBll.GetActivePermissions();

            if (result.IsSuccessful && result.Data != null)
            {
                foreach (var permission in result.Data)
                {
                    if (!string.IsNullOrWhiteSpace(permission?.PermissionKey))
                    {
                        set.Add(permission.PermissionKey.Trim());
                    }
                }
            }

            return set;
        }

        private static bool HasPermission(string permissionKey, HashSet<string> permissionSet)
        {
            if (permissionSet == null || permissionSet.Count == 0)
            {
                return false;
            }

            if (string.IsNullOrWhiteSpace(permissionKey))
            {
                return false;
            }

            return permissionSet.Contains(permissionKey.Trim());
        }

        private static bool IsControlledResource(string permissionKey, string baseKey, HashSet<string> allPermissions)
        {
            if (allPermissions == null || allPermissions.Count == 0)
            {
                return false;
            }

            if (!string.IsNullOrWhiteSpace(permissionKey) && allPermissions.Contains(permissionKey.Trim()))
            {
                return true;
            }

            if (!string.IsNullOrWhiteSpace(baseKey) && allPermissions.Contains(baseKey.Trim()))
            {
                return true;
            }

            return false;
        }

        private static string BuildPermissionKey(HttpContext context)
        {
            var request = context?.Request;
            if (request == null)
            {
                return string.Empty;
            }

            var path = request.AppRelativeCurrentExecutionFilePath ?? string.Empty;
            var query = request.QueryString?.ToString();

            if (string.IsNullOrWhiteSpace(query))
            {
                return path;
            }

            return string.Concat(path, "?", query);
        }

        private static bool IsUserAuthenticated(HttpContext context)
        {
            return context?.User?.Identity?.IsAuthenticated == true;
        }

        private static bool IsPublicPage(HttpContext context)
        {
            var path = context?.Request?.AppRelativeCurrentExecutionFilePath ?? string.Empty;
            
            // List of public pages that don't require authentication
            var publicPages = new[]
            {
                "~/SignIn.aspx",
                "~/SignUp.aspx",
                "~/ForgotPassword.aspx",
                "~/ResetPassword.aspx",
                "~/Default.aspx",
                "~/AboutUs.aspx",
                "~/ContactUs.aspx",
                "~/FAQ.aspx",
                "~/PrivacyPolicy.aspx",
                "~/SecurityPolicy.aspx",
                "~/TermsConditions.aspx",
                "~/AccessDenied.aspx",
                "~/News.aspx",
                "~/Catalog.aspx",
                "~/Subscriptions.aspx"
            };

            return publicPages.Any(p => path.Equals(p, StringComparison.OrdinalIgnoreCase));
        }

        private static void RedirectToAccessDenied(HttpContext context)
        {
            if (context == null)
            {
                return;
            }

            var response = context.Response;
            if (response == null)
            {
                return;
            }

            response.Redirect("~/AccessDenied.aspx", true);
        }

        private void UpdateAdminFlags(HashSet<string> permissionSet)
        {
            var session = HttpContext.Current?.Session;
            if (session == null)
            {
                return;
            }

            var isAdmin = permissionSet != null && permissionSet.Any(p => p.StartsWith("~/Admin", StringComparison.OrdinalIgnoreCase));

            session[SessionAdminFlagKey] = isAdmin;
            session["UserRole"] = isAdmin ? "Admin" : "User";
        }
    }
}
