using System;
using System.Collections.Generic;
using System.Linq;
using ABSTRACTIONS;
using BLL;

namespace SECURITY
{
    public class AdminRoleSecurity
    {
        private const string RolesPermissionKey = "~/AdminRoles.aspx";

        private readonly AdminRoleBLL _adminRoleBll;
        private readonly UserBLL _userBll;
        private readonly UserSecurity _userSecurity;
        private readonly AuthorizationSecurity _authorizationSecurity;

        public AdminRoleSecurity()
        {
            _adminRoleBll = new AdminRoleBLL();
            _userBll = new UserBLL();
            _userSecurity = new UserSecurity();
            _authorizationSecurity = new AuthorizationSecurity();
        }

        public DatabaseResult<List<AdminRoleSummary>> GetAllRoles()
        {
            if (!HasRolesPermission())
            {
                return DatabaseResult<List<AdminRoleSummary>>.Failure(-401, "Unauthorized.");
            }

            return _adminRoleBll.GetAllRoles();
        }

        public DatabaseResult<AdminRoleDetail> GetRoleById(int roleId)
        {
            if (!HasRolesPermission())
            {
                return DatabaseResult<AdminRoleDetail>.Failure(-401, "Unauthorized.");
            }

            return _adminRoleBll.GetRoleById(roleId);
        }

        public DatabaseResult<List<AdminPermission>> GetActivePermissions()
        {
            if (!HasRolesPermission())
            {
                return DatabaseResult<List<AdminPermission>>.Failure(-401, "Unauthorized.");
            }

            return _adminRoleBll.GetActivePermissions();
        }

        public DatabaseResult SaveRole(AdminRole role)
        {
            if (!HasRolesPermission())
            {
                return DatabaseResult.Failure(-401, "Unauthorized.");
            }

            var currentUserId = GetCurrentUserId();
            var result = _adminRoleBll.SaveRole(role, currentUserId);
            _authorizationSecurity.RefreshCurrentUserPermissions();
            return result;
        }

        public DatabaseResult UpdateRolePermissions(int roleId, IEnumerable<string> permissionKeys)
        {
            if (!HasRolesPermission())
            {
                return DatabaseResult.Failure(-401, "Unauthorized.");
            }

            var currentUserId = GetCurrentUserId();
            var result = _adminRoleBll.UpdateRolePermissions(roleId, permissionKeys ?? Enumerable.Empty<string>(), currentUserId);
            _authorizationSecurity.RefreshCurrentUserPermissions();
            return result;
        }

        public DatabaseResult DeleteRole(int roleId)
        {
            if (!HasRolesPermission())
            {
                return DatabaseResult.Failure(-401, "Unauthorized.");
            }

            var currentUserId = GetCurrentUserId();
            var result = _adminRoleBll.DeleteRole(roleId, currentUserId);
            _authorizationSecurity.RefreshCurrentUserPermissions();
            return result;
        }

        public DatabaseResult AssignRoleToUser(string username, int roleId)
        {
            if (!HasRolesPermission())
            {
                return DatabaseResult.Failure(-401, "Unauthorized.");
            }

            if (string.IsNullOrWhiteSpace(username))
            {
                return DatabaseResult.Failure(-2, "Username is required.");
            }

            var user = _userBll.GetUserByUsername(username.Trim());
            if (user == null)
            {
                return DatabaseResult.Failure(-3, "User not found.");
            }

            var currentUserId = GetCurrentUserId();
            var result = _adminRoleBll.AssignUserRole(user.UserId, roleId, currentUserId);
            if (user.UserId == currentUserId)
            {
                _authorizationSecurity.RefreshCurrentUserPermissions();
            }

            return result;
        }

        public DatabaseResult RemoveRoleFromUser(int userId, int roleId)
        {
            if (!HasRolesPermission())
            {
                return DatabaseResult.Failure(-401, "Unauthorized.");
            }

            var currentUserId = GetCurrentUserId();
            var result = _adminRoleBll.RemoveUserRole(userId, roleId);
            if (userId == currentUserId)
            {
                _authorizationSecurity.RefreshCurrentUserPermissions();
            }

            return result;
        }

        private bool HasRolesPermission()
        {
            return _authorizationSecurity.UserHasPermission(RolesPermissionKey);
        }

        private int GetCurrentUserId()
        {
            var user = _userSecurity.GetCurrentUser();
            return user?.UserId ?? 0;
        }
    }
}
