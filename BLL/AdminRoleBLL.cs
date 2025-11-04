using System;
using System.Collections.Generic;
using System.Linq;
using ABSTRACTIONS;
using DAL;

namespace BLL
{
    public class AdminRoleBLL
    {
        private readonly AdminRoleDAL _adminRoleDal;

        public AdminRoleBLL()
        {
            _adminRoleDal = new AdminRoleDAL();
        }

        public DatabaseResult<List<AdminPermission>> GetActivePermissions()
        {
            try
            {
                var permissions = _adminRoleDal.GetActivePermissions();
                return DatabaseResult<List<AdminPermission>>.Success(permissions);
            }
            catch (Exception ex)
            {
                return DatabaseResult<List<AdminPermission>>.Failure("Unable to load permissions.", ex);
            }
        }

        public DatabaseResult<List<AdminRoleSummary>> GetAllRoles()
        {
            try
            {
                var roles = _adminRoleDal.GetAllRoles();
                return DatabaseResult<List<AdminRoleSummary>>.Success(roles);
            }
            catch (Exception ex)
            {
                return DatabaseResult<List<AdminRoleSummary>>.Failure("Unable to load roles.", ex);
            }
        }

        public DatabaseResult<AdminRoleDetail> GetRoleById(int roleId)
        {
            if (roleId <= 0)
            {
                return DatabaseResult<AdminRoleDetail>.Failure(-1, "Role identifier is required.");
            }

            try
            {
                var detail = _adminRoleDal.GetRoleById(roleId);
                if (detail?.Role?.RoleId == 0)
                {
                    return DatabaseResult<AdminRoleDetail>.Failure(-2, "Role not found.");
                }

                return DatabaseResult<AdminRoleDetail>.Success(detail);
            }
            catch (Exception ex)
            {
                return DatabaseResult<AdminRoleDetail>.Failure("Unable to load role details.", ex);
            }
        }

        public DatabaseResult SaveRole(AdminRole role, int auditUserId)
        {
            if (role == null)
            {
                return DatabaseResult.Failure(-1, "Role information is required.");
            }

            if (string.IsNullOrWhiteSpace(role.RoleName))
            {
                return DatabaseResult.Failure(-2, "Role name is required.");
            }

            role.RoleName = role.RoleName.Trim();
            role.Description = string.IsNullOrWhiteSpace(role.Description) ? null : role.Description.Trim();

            try
            {
                return _adminRoleDal.SaveRole(role, auditUserId);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Unable to save role.", ex);
            }
        }

        public DatabaseResult UpdateRolePermissions(int roleId, IEnumerable<string> permissionKeys, int modifiedBy)
        {
            var keys = permissionKeys?.Where(k => !string.IsNullOrWhiteSpace(k)).Select(k => k.Trim()).Distinct().ToList() ?? new List<string>();

            try
            {
                return _adminRoleDal.UpdateRolePermissions(roleId, keys, modifiedBy);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Unable to update role permissions.", ex);
            }
        }

        public DatabaseResult DeleteRole(int roleId, int auditUserId)
        {
            try
            {
                return _adminRoleDal.DeleteRole(roleId, auditUserId);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Unable to delete role.", ex);
            }
        }

        public DatabaseResult<List<string>> GetPermissionsByUser(int userId)
        {
            if (userId <= 0)
            {
                return DatabaseResult<List<string>>.Failure(-1, "User identifier is required.");
            }

            try
            {
                var permissions = _adminRoleDal.GetPermissionsByUser(userId);
                return DatabaseResult<List<string>>.Success(permissions ?? new List<string>());
            }
            catch (Exception ex)
            {
                return DatabaseResult<List<string>>.Failure("Unable to load user permissions.", ex);
            }
        }

        public DatabaseResult<List<AdminUserRoleAssignment>> GetUserRoles(int userId)
        {
            if (userId <= 0)
            {
                return DatabaseResult<List<AdminUserRoleAssignment>>.Failure(-1, "User identifier is required.");
            }

            try
            {
                var roles = _adminRoleDal.GetUserRoles(userId) ?? new List<AdminUserRoleAssignment>();
                return DatabaseResult<List<AdminUserRoleAssignment>>.Success(roles);
            }
            catch (Exception ex)
            {
                return DatabaseResult<List<AdminUserRoleAssignment>>.Failure("Unable to load user roles.", ex);
            }
        }

        public DatabaseResult AssignUserRole(int userId, int roleId, int assignedBy)
        {
            try
            {
                return _adminRoleDal.AssignUserRole(userId, roleId, assignedBy);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Unable to assign role to user.", ex);
            }
        }

        public DatabaseResult RemoveUserRole(int userId, int roleId)
        {
            try
            {
                return _adminRoleDal.RemoveUserRole(userId, roleId);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Unable to remove role from user.", ex);
            }
        }
    }
}
