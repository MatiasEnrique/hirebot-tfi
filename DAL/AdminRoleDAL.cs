using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using ABSTRACTIONS;

namespace DAL
{
    public class AdminRoleDAL
    {
        public List<AdminPermission> GetActivePermissions()
        {
            var permissions = new List<AdminPermission>();

            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_AdminPermission_GetAll", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            permissions.Add(new AdminPermission
                            {
                                PermissionKey = reader["PermissionKey"]?.ToString(),
                                DisplayName = reader["DisplayName"]?.ToString(),
                                Category = reader["Category"]?.ToString(),
                                SortOrder = SafeGetInt(reader, "SortOrder"),
                                IsActive = SafeGetBool(reader, "IsActive")
                            });
                        }
                    }
                }
            }
            catch
            {
                return new List<AdminPermission>();
            }

            return permissions;
        }

        public List<AdminRoleSummary> GetAllRoles()
        {
            var roles = new List<AdminRoleSummary>();

            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_AdminRole_GetAll", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            roles.Add(new AdminRoleSummary
                            {
                                RoleId = SafeGetInt(reader, "RoleId"),
                                RoleName = reader["RoleName"]?.ToString(),
                                Description = reader["Description"]?.ToString(),
                                IsActive = SafeGetBool(reader, "IsActive"),
                                CreatedDateUtc = SafeGetDateTime(reader, "CreatedDateUtc"),
                                ModifiedDateUtc = SafeGetNullableDateTime(reader, "ModifiedDateUtc"),
                                AssignedUserCount = SafeGetInt(reader, "AssignedUserCount"),
                                PermissionCount = SafeGetInt(reader, "PermissionCount")
                            });
                        }
                    }
                }
            }
            catch
            {
                return new List<AdminRoleSummary>();
            }

            return roles;
        }

        public AdminRoleDetail GetRoleById(int roleId)
        {
            var detail = new AdminRoleDetail();

            if (roleId <= 0)
            {
                return detail;
            }

            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_AdminRole_GetById", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@RoleId", roleId);

                    connection.Open();
                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            detail.Role.RoleId = SafeGetInt(reader, "RoleId");
                            detail.Role.RoleName = reader["RoleName"]?.ToString();
                            detail.Role.Description = reader["Description"]?.ToString();
                            detail.Role.IsActive = SafeGetBool(reader, "IsActive");
                            detail.Role.CreatedDateUtc = SafeGetDateTime(reader, "CreatedDateUtc");
                            detail.Role.ModifiedDateUtc = SafeGetNullableDateTime(reader, "ModifiedDateUtc");
                        }

                        if (reader.NextResult())
                        {
                            while (reader.Read())
                            {
                                var key = reader["PermissionKey"]?.ToString();
                                if (!string.IsNullOrWhiteSpace(key))
                                {
                                    detail.PermissionKeys.Add(key);
                                }
                            }
                        }

                        if (reader.NextResult())
                        {
                            while (reader.Read())
                            {
                                detail.AssignedUsers.Add(new AdminUserRoleAssignment
                                {
                                    AdminUserRoleId = SafeGetInt(reader, "AdminUserRoleId"),
                                    UserId = SafeGetInt(reader, "UserId"),
                                    Username = reader["Username"]?.ToString(),
                                    Email = reader["Email"]?.ToString(),
                                    FirstName = reader["FirstName"]?.ToString(),
                                    LastName = reader["LastName"]?.ToString(),
                                    AssignedDateUtc = SafeGetDateTime(reader, "AssignedDateUtc")
                                });
                            }
                        }
                    }
                }
            }
            catch
            {
                return new AdminRoleDetail();
            }

            return detail;
        }

        public DatabaseResult SaveRole(AdminRole role, int auditUserId)
        {
            if (role == null)
            {
                return DatabaseResult.Failure(-1, "Role information is required.");
            }

            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_AdminRole_Save", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    var roleIdParam = new SqlParameter("@RoleId", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.InputOutput,
                        Value = role.RoleId
                    };
                    command.Parameters.Add(roleIdParam);

                    command.Parameters.AddWithValue("@RoleName", (object)role.RoleName ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Description", (object)role.Description ?? DBNull.Value);
                    command.Parameters.AddWithValue("@IsActive", role.IsActive);
                    command.Parameters.AddWithValue("@AuditUserId", auditUserId > 0 ? (object)auditUserId : DBNull.Value);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultCodeParam);

                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    role.RoleId = Convert.ToInt32(roleIdParam.Value ?? 0);
                    var resultCode = Convert.ToInt32(resultCodeParam.Value ?? 0);
                    var message = resultMessageParam.Value?.ToString() ?? string.Empty;

                    return new DatabaseResult(resultCode > 0, resultCode, string.IsNullOrWhiteSpace(message) ? (resultCode > 0 ? "Success" : "Unable to save role.") : message);
                }
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Error saving role.", ex);
            }
        }

        public DatabaseResult UpdateRolePermissions(int roleId, IEnumerable<string> permissionKeys, int modifiedBy)
        {
            if (roleId <= 0)
            {
                return DatabaseResult.Failure(-1, "Role identifier is required.");
            }

            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_AdminRole_UpdatePermissions", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@RoleId", roleId);

                    var keys = permissionKeys?.Where(k => !string.IsNullOrWhiteSpace(k)).Select(k => k.Trim()).Distinct().ToList();
                    var keysValue = keys != null && keys.Count > 0 ? string.Join(",", keys) : null;

                    command.Parameters.AddWithValue("@PermissionKeys", (object)keysValue ?? DBNull.Value);
                    command.Parameters.AddWithValue("@ModifiedBy", modifiedBy > 0 ? (object)modifiedBy : DBNull.Value);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultCodeParam);

                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    var resultCode = Convert.ToInt32(resultCodeParam.Value ?? 0);
                    var message = resultMessageParam.Value?.ToString() ?? string.Empty;

                    return new DatabaseResult(resultCode > 0, resultCode, string.IsNullOrWhiteSpace(message) ? (resultCode > 0 ? "Success" : "Unable to update permissions.") : message);
                }
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Error updating role permissions.", ex);
            }
        }

        public DatabaseResult DeleteRole(int roleId, int auditUserId)
        {
            if (roleId <= 0)
            {
                return DatabaseResult.Failure(-1, "Role identifier is required.");
            }

            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_AdminRole_Delete", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@RoleId", roleId);
                    command.Parameters.AddWithValue("@AuditUserId", auditUserId > 0 ? (object)auditUserId : DBNull.Value);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultCodeParam);

                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    var resultCode = Convert.ToInt32(resultCodeParam.Value ?? 0);
                    var message = resultMessageParam.Value?.ToString() ?? string.Empty;

                    return new DatabaseResult(resultCode > 0, resultCode, string.IsNullOrWhiteSpace(message) ? (resultCode > 0 ? "Success" : "Unable to deactivate role.") : message);
                }
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Error deleting role.", ex);
            }
        }

        public List<string> GetPermissionsByUser(int userId)
        {
            var permissions = new List<string>();

            if (userId <= 0)
            {
                return permissions;
            }

            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_AdminPermission_GetByUser", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserId", userId);

                    connection.Open();
                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var key = reader["PermissionKey"]?.ToString();
                            if (!string.IsNullOrWhiteSpace(key))
                            {
                                permissions.Add(key);
                            }
                        }
                    }
                }
            }
            catch
            {
                return new List<string>();
            }

            return permissions;
        }

        public List<AdminUserRoleAssignment> GetUserRoles(int userId)
        {
            var roles = new List<AdminUserRoleAssignment>();

            if (userId <= 0)
            {
                return roles;
            }

            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_AdminUserRole_GetByUser", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserId", userId);

                    connection.Open();
                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            roles.Add(new AdminUserRoleAssignment
                            {
                                AdminUserRoleId = SafeGetInt(reader, "AdminUserRoleId"),
                                UserId = SafeGetInt(reader, "UserId"),
                                Username = reader["Username"]?.ToString(),
                                Email = reader["Email"]?.ToString(),
                                FirstName = reader["FirstName"]?.ToString(),
                                LastName = reader["LastName"]?.ToString(),
                                AssignedDateUtc = SafeGetDateTime(reader, "AssignedDateUtc")
                            });
                        }
                    }
                }
            }
            catch
            {
                return new List<AdminUserRoleAssignment>();
            }

            return roles;
        }

        public DatabaseResult AssignUserRole(int userId, int roleId, int assignedBy)
        {
            if (userId <= 0 || roleId <= 0)
            {
                return DatabaseResult.Failure(-1, "User and role identifiers are required.");
            }

            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_AdminUserRole_Assign", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserId", userId);
                    command.Parameters.AddWithValue("@RoleId", roleId);
                    command.Parameters.AddWithValue("@AssignedBy", assignedBy > 0 ? (object)assignedBy : DBNull.Value);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultCodeParam);

                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    var resultCode = Convert.ToInt32(resultCodeParam.Value ?? 0);
                    var message = resultMessageParam.Value?.ToString() ?? string.Empty;

                    return new DatabaseResult(resultCode > 0, resultCode, string.IsNullOrWhiteSpace(message) ? (resultCode > 0 ? "Success" : "Unable to assign role.") : message);
                }
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Error assigning role to user.", ex);
            }
        }

        public DatabaseResult RemoveUserRole(int userId, int roleId)
        {
            if (userId <= 0 || roleId <= 0)
            {
                return DatabaseResult.Failure(-1, "User and role identifiers are required.");
            }

            try
            {
                using (var connection = DatabaseConnectionService.GetConnection())
                using (var command = new SqlCommand("sp_AdminUserRole_Remove", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserId", userId);
                    command.Parameters.AddWithValue("@RoleId", roleId);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultCodeParam);

                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    var resultCode = Convert.ToInt32(resultCodeParam.Value ?? 0);
                    var message = resultMessageParam.Value?.ToString() ?? string.Empty;

                    return new DatabaseResult(resultCode > 0, resultCode, string.IsNullOrWhiteSpace(message) ? (resultCode > 0 ? "Success" : "Unable to remove role.") : message);
                }
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Error removing role from user.", ex);
            }
        }

        private static int SafeGetInt(IDataRecord reader, string column)
        {
            return reader[column] == DBNull.Value ? 0 : Convert.ToInt32(reader[column]);
        }

        private static bool SafeGetBool(IDataRecord reader, string column)
        {
            try
            {
                return reader[column] != DBNull.Value && Convert.ToBoolean(reader[column]);
            }
            catch
            {
                return false;
            }
        }

        private static DateTime SafeGetDateTime(IDataRecord reader, string column)
        {
            return reader[column] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(reader[column]);
        }

        private static DateTime? SafeGetNullableDateTime(IDataRecord reader, string column)
        {
            return reader[column] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader[column]);
        }
    }
}
