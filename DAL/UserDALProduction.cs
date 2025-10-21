using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using ABSTRACTIONS;

namespace DAL
{
    /// <summary>
    /// Production-ready User Data Access Layer with comprehensive error handling
    /// Aligns with production stored procedures and provides detailed result information
    /// </summary>
    public class UserDALProduction
    {
        public UserDALProduction()
        {
            // Use the existing connection service
        }

        #region User Account Module Methods

        /// <summary>
        /// Retrieves user account dashboard information including profile, subscriptions, and billing summary
        /// </summary>
        /// <param name="userId">Authenticated user identifier</param>
        /// <returns>UserAccountDashboardResult containing composite data</returns>
        public UserAccountDashboardResult GetUserAccountDashboard(int userId)
        {
            if (userId <= 0)
            {
                return UserAccountDashboardResult.Failure(-1, "Invalid user identifier.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_UserAccount_GetDashboardData", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@UserId", userId);

                        connection.Open();

                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            var dashboard = new UserAccountDashboard();

                            if (reader.Read())
                            {
                                dashboard.Profile = MapUserAccountProfile(reader);
                            }

                            if (dashboard.Profile == null)
                            {
                                return UserAccountDashboardResult.Failure(0, "User not found.");
                            }

                            if (reader.NextResult())
                            {
                                while (reader.Read())
                                {
                                    dashboard.Subscriptions.Add(MapSubscriptionFromReader(reader));
                                }
                            }

                            if (reader.NextResult())
                            {
                                while (reader.Read())
                                {
                                    dashboard.BillingDocuments.Add(MapBillingSummaryFromReader(reader));
                                }
                            }

                            return UserAccountDashboardResult.Success(dashboard, "Account dashboard retrieved successfully.");
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return UserAccountDashboardResult.Failure(-50010, $"Database error: {sqlEx.Message}");
            }
            catch (Exception ex)
            {
                return UserAccountDashboardResult.Failure("Unexpected error loading account dashboard.", ex);
            }
        }

        /// <summary>
        /// Updates personal information for the authenticated user
        /// </summary>
        /// <param name="userId">User identifier</param>
        /// <param name="firstName">First name</param>
        /// <param name="lastName">Last name</param>
        /// <param name="email">Email address</param>
        /// <returns>DatabaseResult indicating outcome</returns>
        public DatabaseResult UpdateUserProfile(int userId, string firstName, string lastName, string email)
        {
            if (userId <= 0)
            {
                return DatabaseResult.Failure(-1, "Invalid user identifier.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_UserAccount_UpdateProfile", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@UserId", userId);
                        command.Parameters.AddWithValue("@FirstName", firstName ?? string.Empty);
                        command.Parameters.AddWithValue("@LastName", lastName ?? string.Empty);
                        command.Parameters.AddWithValue("@Email", email ?? string.Empty);

                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value ?? -999);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";

                        if (resultCode > 0)
                        {
                            return DatabaseResult.Success(resultMessage);
                        }

                        return DatabaseResult.Failure(resultCode, resultMessage);
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error updating profile: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error updating profile: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Updates the password hash for a user after validating the current hash
        /// </summary>
        /// <param name="userId">User identifier</param>
        /// <param name="currentPasswordHash">Current password hash</param>
        /// <param name="newPasswordHash">New password hash</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult UpdateUserPassword(int userId, string currentPasswordHash, string newPasswordHash)
        {
            if (userId <= 0)
            {
                return DatabaseResult.Failure(-1, "Invalid user identifier.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_UserAccount_UpdatePassword", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@UserId", userId);
                        command.Parameters.AddWithValue("@CurrentPasswordHash", currentPasswordHash ?? string.Empty);
                        command.Parameters.AddWithValue("@NewPasswordHash", newPasswordHash ?? string.Empty);

                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value ?? -999);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";

                        if (resultCode > 0)
                        {
                            return DatabaseResult.Success(resultMessage);
                        }

                        return DatabaseResult.Failure(resultCode, resultMessage);
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error updating password: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error updating password: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Cancels an active subscription for a user
        /// </summary>
        /// <param name="userId">User identifier</param>
        /// <param name="subscriptionId">Subscription identifier</param>
        /// <returns>DatabaseResult indicating the outcome</returns>
        public DatabaseResult CancelUserSubscription(int userId, int subscriptionId)
        {
            if (userId <= 0)
            {
                return DatabaseResult.Failure(-1, "Invalid user identifier.");
            }

            if (subscriptionId <= 0)
            {
                return DatabaseResult.Failure(-2, "Invalid subscription identifier.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_UserAccount_CancelSubscription", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@UserId", userId);
                        command.Parameters.AddWithValue("@SubscriptionId", subscriptionId);

                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value ?? -999);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";

                        if (resultCode > 0)
                        {
                            return DatabaseResult.Success(resultMessage);
                        }

                        return DatabaseResult.Failure(resultCode, resultMessage);
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error cancelling subscription: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error cancelling subscription: {ex.Message}", ex);
            }
        }

        #endregion

        /// <summary>
        /// Creates a new user account with comprehensive validation and error reporting
        /// </summary>
        /// <param name="user">User object to create</param>
        /// <returns>DatabaseResult with detailed success/failure information</returns>
        public DatabaseResult CreateUser(User user)
        {
            if (user == null)
            {
                return DatabaseResult.Failure(-1, "User object cannot be null");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_CreateUser", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        // Input parameters
                        command.Parameters.AddWithValue("@Username", user.Username ?? string.Empty);
                        command.Parameters.AddWithValue("@Email", user.Email ?? string.Empty);
                        command.Parameters.AddWithValue("@PasswordHash", user.PasswordHash ?? string.Empty);
                        command.Parameters.AddWithValue("@FirstName", user.FirstName ?? string.Empty);
                        command.Parameters.AddWithValue("@LastName", user.LastName ?? string.Empty);
                        command.Parameters.AddWithValue("@UserRole", user.UserRole ?? "user");
                        command.Parameters.AddWithValue("@CreatedDate", user.CreatedDate);
                        command.Parameters.AddWithValue("@IsActive", user.IsActive);

                        // Output parameters
                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";

                        if (resultCode > 0)
                        {
                            return DatabaseResult.Success(resultMessage);
                        }
                        else
                        {
                            return DatabaseResult.Failure(resultCode, resultMessage);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Retrieves a user by username with error handling
        /// </summary>
        /// <param name="username">Username to search for</param>
        /// <returns>DatabaseResult containing User object or error information</returns>
        public DatabaseResult<User> GetUserByUsername(string username)
        {
            if (string.IsNullOrWhiteSpace(username))
            {
                return DatabaseResult<User>.Failure(-1, "Username cannot be null or empty");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetUserByUsername", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@Username", username.Trim());

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                User user = MapUserFromReader(reader);
                                return DatabaseResult<User>.Success(user, "User found successfully");
                            }
                            else
                            {
                                return DatabaseResult<User>.Failure(0, "User not found");
                            }
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<User>.Failure($"Database error: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<User>.Failure($"Unexpected error: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Retrieves a user by email with validation and error handling
        /// </summary>
        /// <param name="email">Email to search for</param>
        /// <returns>DatabaseResult containing User object or error information</returns>
        public DatabaseResult<User> GetUserByEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
            {
                return DatabaseResult<User>.Failure(-1, "Email cannot be null or empty");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetUserByEmail", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@Email", email.Trim().ToLower());

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                User user = MapUserFromReader(reader);
                                return DatabaseResult<User>.Success(user, "User found successfully");
                            }
                            else
                            {
                                return DatabaseResult<User>.Failure(0, "User not found");
                            }
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<User>.Failure($"Database error: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<User>.Failure($"Unexpected error: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Checks if a user exists by username or email with detailed conflict information
        /// </summary>
        /// <param name="username">Username to check</param>
        /// <param name="email">Email to check</param>
        /// <returns>UserExistenceResult with conflict details</returns>
        public UserExistenceResult CheckUserExists(string username, string email)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_CheckUserExists", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@Username", username ?? string.Empty);
                        command.Parameters.AddWithValue("@Email", email ?? string.Empty);

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                int userCount = Convert.ToInt32(reader["UserCount"]);
                                string message = reader["Message"]?.ToString() ?? "";

                                if (userCount > 0)
                                {
                                    // Additional check to determine conflict type
                                    string conflictType = DetermineConflictType(username, email);
                                    return new UserExistenceResult(true, true, conflictType, message);
                                }
                                else
                                {
                                    return new UserExistenceResult(true, false, "", message);
                                }
                            }
                            else
                            {
                                return new UserExistenceResult(false, false, "", "No result returned from database");
                            }
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return new UserExistenceResult(false, true, "Unknown", $"Database error: {sqlEx.Message}"); // Return true to be safe
            }
            catch (Exception ex)
            {
                return new UserExistenceResult(false, true, "Unknown", $"Unexpected error: {ex.Message}"); // Return true to be safe
            }
        }

        /// <summary>
        /// Backward compatibility method for UserExists
        /// </summary>
        /// <param name="username">Username to check</param>
        /// <param name="email">Email to check</param>
        /// <returns>UserExistenceResult with conflict details</returns>
        public UserExistenceResult UserExists(string username, string email)
        {
            return CheckUserExists(username, email);
        }

        /// <summary>
        /// Updates the last login date for a user with comprehensive error handling
        /// </summary>
        /// <param name="userId">User ID to update</param>
        /// <param name="loginDate">Login date (optional, defaults to current time)</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult UpdateLastLoginDate(int userId, DateTime? loginDate = null)
        {
            if (userId <= 0)
            {
                return DatabaseResult.Failure(-1, "Invalid user ID");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_UpdateLastLoginDate", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        // Input parameters
                        command.Parameters.AddWithValue("@UserId", userId);
                        command.Parameters.AddWithValue("@LastLoginDate", loginDate ?? DateTime.Now);

                        // Output parameters
                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";

                        if (resultCode > 0)
                        {
                            return DatabaseResult.Success(resultMessage);
                        }
                        else
                        {
                            return DatabaseResult.Failure(resultCode, resultMessage);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Retrieves all users with optional inactive user inclusion
        /// </summary>
        /// <param name="includeInactive">Whether to include inactive users</param>
        /// <returns>DatabaseResult containing list of users</returns>
        public DatabaseResult<List<User>> GetAllUsers(bool includeInactive = false)
        {
            try
            {
                List<User> users = new List<User>();
                
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetAllUsers", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@IncludeInactive", includeInactive);

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                users.Add(MapUserFromReader(reader, includeDisplayName: true));
                            }
                        }
                    }
                }

                return DatabaseResult<List<User>>.Success(users, $"Retrieved {users.Count} users successfully");
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<List<User>>.Failure($"Database error: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<List<User>>.Failure($"Unexpected error: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Retrieves users by specific role with validation
        /// </summary>
        /// <param name="userRole">Role to filter by</param>
        /// <param name="includeInactive">Whether to include inactive users</param>
        /// <returns>DatabaseResult containing list of users</returns>
        public DatabaseResult<List<User>> GetUsersByRole(string userRole, bool includeInactive = false)
        {
            if (string.IsNullOrWhiteSpace(userRole))
            {
                return DatabaseResult<List<User>>.Failure(-1, "User role cannot be null or empty");
            }

            try
            {
                List<User> users = new List<User>();
                
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetUsersByRole", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@UserRole", userRole.Trim());
                        command.Parameters.AddWithValue("@IncludeInactive", includeInactive);

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                users.Add(MapUserFromReader(reader));
                            }
                        }
                    }
                }

                return DatabaseResult<List<User>>.Success(users, $"Retrieved {users.Count} users with role '{userRole}' successfully");
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<List<User>>.Failure($"Database error: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<List<User>>.Failure($"Unexpected error: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Updates a user's role with comprehensive validation and security checks
        /// </summary>
        /// <param name="userId">Target user ID</param>
        /// <param name="newUserRole">New role to assign</param>
        /// <param name="modifiedBy">ID of user making the change (must be admin)</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult UpdateUserRole(int userId, string newUserRole, int modifiedBy)
        {
            if (userId <= 0)
            {
                return DatabaseResult.Failure(-1, "Invalid user ID");
            }

            if (modifiedBy <= 0)
            {
                return DatabaseResult.Failure(-2, "Invalid modifier user ID");
            }

            if (string.IsNullOrWhiteSpace(newUserRole))
            {
                return DatabaseResult.Failure(-3, "New user role cannot be null or empty");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_UpdateUserRole", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        // Input parameters
                        command.Parameters.AddWithValue("@UserId", userId);
                        command.Parameters.AddWithValue("@NewUserRole", newUserRole.Trim());
                        command.Parameters.AddWithValue("@ModifiedBy", modifiedBy);

                        // Output parameters
                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";

                        if (resultCode > 0)
                        {
                            return DatabaseResult.Success(resultMessage);
                        }
                        else
                        {
                            return DatabaseResult.Failure(resultCode, resultMessage);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Safely deactivates a user account with business rule validation
        /// </summary>
        /// <param name="userId">User ID to deactivate</param>
        /// <param name="deactivatedBy">ID of user performing the deactivation (must be admin)</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult DeactivateUser(int userId, int deactivatedBy)
        {
            if (userId <= 0)
            {
                return DatabaseResult.Failure(-1, "Invalid user ID");
            }

            if (deactivatedBy <= 0)
            {
                return DatabaseResult.Failure(-2, "Invalid deactivator user ID");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_DeactivateUser", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        // Input parameters
                        command.Parameters.AddWithValue("@UserId", userId);
                        command.Parameters.AddWithValue("@DeactivatedBy", deactivatedBy);

                        // Output parameters
                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";

                        if (resultCode > 0)
                        {
                            return DatabaseResult.Success(resultMessage);
                        }
                        else
                        {
                            return DatabaseResult.Failure(resultCode, resultMessage);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error: {ex.Message}", ex);
            }
        }

        #region Password Recovery Methods

        /// <summary>
        /// Creates a password recovery request with UUID token
        /// Calls sp_CreatePasswordRecoveryRequest stored procedure
        /// </summary>
        /// <param name="userId">User ID requesting password recovery</param>
        /// <param name="requestIP">IP address of the requester</param>
        /// <param name="userAgent">User agent string of the requester</param>
        /// <returns>PasswordRecoveryCreateResult containing the UUID token</returns>
        public PasswordRecoveryCreateResult CreatePasswordRecoveryRequest(int userId, string requestIP, string userAgent)
        {
            if (userId <= 0)
            {
                return PasswordRecoveryCreateResult.Failure(-1, "Invalid user ID");
            }

            if (string.IsNullOrWhiteSpace(requestIP))
            {
                return PasswordRecoveryCreateResult.Failure(-2, "Request IP cannot be null or empty");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_CreatePasswordRecoveryRequest", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        // Input parameters
                        command.Parameters.AddWithValue("@UserId", userId);
                        command.Parameters.AddWithValue("@RequestIP", requestIP.Trim());
                        command.Parameters.AddWithValue("@UserAgent", userAgent?.Trim() ?? string.Empty);

                        // Output parameters
                        SqlParameter recoveryTokenParam = new SqlParameter("@RecoveryToken", SqlDbType.UniqueIdentifier)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(recoveryTokenParam);

                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";
                        Guid recoveryToken = recoveryTokenParam.Value == DBNull.Value ? Guid.Empty : (Guid)recoveryTokenParam.Value;

                        if (resultCode > 0)
                        {
                            return PasswordRecoveryCreateResult.Success(recoveryToken, resultMessage);
                        }
                        else
                        {
                            return PasswordRecoveryCreateResult.Failure(resultCode, resultMessage);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return PasswordRecoveryCreateResult.Failure(-999, $"Database error: {sqlEx.Message}");
            }
            catch (Exception ex)
            {
                return PasswordRecoveryCreateResult.Failure(-999, $"Unexpected error: {ex.Message}");
            }
        }

        /// <summary>
        /// Validates a password recovery token and returns user information
        /// Calls sp_ValidatePasswordRecoveryToken stored procedure
        /// </summary>
        /// <param name="recoveryToken">UUID recovery token to validate</param>
        /// <returns>PasswordRecoveryValidationResult with validation details</returns>
        public PasswordRecoveryValidationResult ValidatePasswordRecoveryToken(Guid recoveryToken)
        {
            if (recoveryToken == Guid.Empty)
            {
                return PasswordRecoveryValidationResult.Failure(-1, "Invalid recovery token");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ValidatePasswordRecoveryToken", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        // Input parameters
                        command.Parameters.AddWithValue("@RecoveryToken", recoveryToken);

                        // Output parameters
                        SqlParameter userIdParam = new SqlParameter("@UserId", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(userIdParam);

                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";
                        int userId = userIdParam.Value == DBNull.Value ? 0 : Convert.ToInt32(userIdParam.Value);

                        if (resultCode == 1)
                        {
                            return PasswordRecoveryValidationResult.Success(userId, resultMessage);
                        }
                        else if (resultCode == 2)
                        {
                            return PasswordRecoveryValidationResult.Invalid(resultCode, resultMessage, isExpired: true);
                        }
                        else if (resultCode == 3)
                        {
                            return PasswordRecoveryValidationResult.Invalid(resultCode, resultMessage, isUsed: true);
                        }
                        else if (resultCode == 4)
                        {
                            return PasswordRecoveryValidationResult.Invalid(resultCode, resultMessage);
                        }
                        else if (resultCode == 5)
                        {
                            return PasswordRecoveryValidationResult.Invalid(resultCode, resultMessage);
                        }
                        else
                        {
                            return PasswordRecoveryValidationResult.Failure(resultCode, resultMessage);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return PasswordRecoveryValidationResult.Failure(-999, $"Database error: {sqlEx.Message}");
            }
            catch (Exception ex)
            {
                return PasswordRecoveryValidationResult.Failure(-999, $"Unexpected error: {ex.Message}");
            }
        }

        /// <summary>
        /// Uses a password recovery token to update user password and mark token as used
        /// Calls sp_UsePasswordRecoveryToken stored procedure
        /// </summary>
        /// <param name="recoveryToken">UUID recovery token</param>
        /// <param name="newPasswordHash">SHA256 hash of the new password</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult UsePasswordRecoveryToken(Guid recoveryToken, string newPasswordHash)
        {
            if (recoveryToken == Guid.Empty)
            {
                return DatabaseResult.Failure(-1, "Invalid recovery token");
            }

            if (string.IsNullOrWhiteSpace(newPasswordHash))
            {
                return DatabaseResult.Failure(-2, "New password hash cannot be null or empty");
            }

            if (newPasswordHash.Length != 64) // SHA256 produces 64 character hex string
            {
                return DatabaseResult.Failure(-3, "Invalid password hash format");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_UsePasswordRecoveryToken", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        // Input parameters
                        command.Parameters.AddWithValue("@RecoveryToken", recoveryToken);
                        command.Parameters.AddWithValue("@NewPasswordHash", newPasswordHash);

                        // Output parameters
                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";

                        if (resultCode > 0)
                        {
                            return DatabaseResult.Success(resultMessage);
                        }
                        else
                        {
                            return DatabaseResult.Failure(resultCode, resultMessage);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Cleans up expired password recovery tokens
        /// Calls sp_CleanupExpiredRecoveryTokens stored procedure
        /// </summary>
        /// <returns>DatabaseResult with cleanup status and count of removed tokens</returns>
        public DatabaseResult CleanupExpiredRecoveryTokens()
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_CleanupExpiredRecoveryTokens", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Output parameters
                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";

                        if (resultCode >= 0)
                        {
                            return DatabaseResult.Success(resultMessage);
                        }
                        else
                        {
                            return DatabaseResult.Failure(resultCode, resultMessage);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error: {ex.Message}", ex);
            }
        }

        #endregion

        #region Private Helper Methods

        /// <summary>
        /// Maps a SqlDataReader row to a User object
        /// </summary>
        /// <param name="reader">SqlDataReader with user data</param>
        /// <param name="includeDisplayName">Whether to include DisplayName property</param>
        /// <returns>User object</returns>
        private User MapUserFromReader(SqlDataReader reader, bool includeDisplayName = false)
        {
            var user = new User
            {
                UserId = Convert.ToInt32(reader["UserId"]),
                Username = reader["Username"]?.ToString() ?? string.Empty,
                Email = reader["Email"]?.ToString() ?? string.Empty,
                FirstName = reader["FirstName"]?.ToString() ?? string.Empty,
                LastName = reader["LastName"]?.ToString() ?? string.Empty,
                IsActive = Convert.ToBoolean(reader["IsActive"])
            };

            // Handle optional fields that might not be in all queries
            if (HasColumn(reader, "PasswordHash"))
                user.PasswordHash = reader["PasswordHash"]?.ToString() ?? string.Empty;

            if (HasColumn(reader, "UserRole"))
                user.UserRole = reader["UserRole"]?.ToString() ?? "user";

            if (HasColumn(reader, "CreatedDate"))
                user.CreatedDate = Convert.ToDateTime(reader["CreatedDate"]);

            if (HasColumn(reader, "LastLoginDate"))
                user.LastLoginDate = reader["LastLoginDate"] == DBNull.Value ? null : (DateTime?)Convert.ToDateTime(reader["LastLoginDate"]);

            return user;
        }

        private UserAccountProfile MapUserAccountProfile(SqlDataReader reader)
        {
            if (reader == null)
            {
                return null;
            }

            if (reader["UserId"] == DBNull.Value)
            {
                return null;
            }

            return new UserAccountProfile
            {
                UserId = Convert.ToInt32(reader["UserId"]),
                Username = reader["Username"]?.ToString() ?? string.Empty,
                Email = reader["Email"]?.ToString() ?? string.Empty,
                FirstName = reader["FirstName"]?.ToString() ?? string.Empty,
                LastName = reader["LastName"]?.ToString() ?? string.Empty,
                CreatedDate = reader["CreatedDate"] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(reader["CreatedDate"]),
                LastLoginDate = reader["LastLoginDate"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["LastLoginDate"]),
                IsActive = reader["IsActive"] != DBNull.Value && Convert.ToBoolean(reader["IsActive"])
            };
        }

        private ProductSubscription MapSubscriptionFromReader(SqlDataReader reader)
        {
            return new ProductSubscription
            {
                SubscriptionId = reader["SubscriptionId"] == DBNull.Value ? 0 : Convert.ToInt32(reader["SubscriptionId"]),
                ProductId = reader["ProductId"] == DBNull.Value ? 0 : Convert.ToInt32(reader["ProductId"]),
                UserId = reader["UserId"] == DBNull.Value ? 0 : Convert.ToInt32(reader["UserId"]),
                ProductName = reader["ProductName"]?.ToString() ?? string.Empty,
                ProductPrice = reader["ProductPrice"] == DBNull.Value ? 0 : Convert.ToDecimal(reader["ProductPrice"]),
                BillingCycle = reader["BillingCycle"]?.ToString() ?? string.Empty,
                CardholderName = reader["CardholderName"]?.ToString() ?? string.Empty,
                EncryptedCardNumber = reader["EncryptedCardNumber"] == DBNull.Value ? null : reader["EncryptedCardNumber"].ToString(),
                EncryptedCardholderName = reader["EncryptedCardholderName"] == DBNull.Value ? null : reader["EncryptedCardholderName"].ToString(),
                CardLast4 = reader["CardLast4"]?.ToString() ?? string.Empty,
                CardBrand = reader["CardBrand"]?.ToString() ?? string.Empty,
                ExpirationMonth = reader["ExpirationMonth"] == DBNull.Value ? 0 : Convert.ToInt32(reader["ExpirationMonth"]),
                ExpirationYear = reader["ExpirationYear"] == DBNull.Value ? 0 : Convert.ToInt32(reader["ExpirationYear"]),
                CreatedDateUtc = reader["CreatedDateUtc"] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(reader["CreatedDateUtc"]),
                IsActive = reader["IsActive"] != DBNull.Value && Convert.ToBoolean(reader["IsActive"]),
                CancelledDateUtc = reader["CancelledDateUtc"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["CancelledDateUtc"])
            };
        }

        private BillingDocumentSummary MapBillingSummaryFromReader(SqlDataReader reader)
        {
            return new BillingDocumentSummary
            {
                BillingDocumentId = reader["BillingDocumentId"] == DBNull.Value ? 0 : Convert.ToInt32(reader["BillingDocumentId"]),
                DocumentType = reader["DocumentType"]?.ToString() ?? string.Empty,
                DocumentNumber = reader["DocumentNumber"]?.ToString() ?? string.Empty,
                IssueDateUtc = reader["IssueDateUtc"] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(reader["IssueDateUtc"]),
                DueDateUtc = reader["DueDateUtc"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["DueDateUtc"]),
                TotalAmount = reader["TotalAmount"] == DBNull.Value ? 0 : Convert.ToDecimal(reader["TotalAmount"]),
                Status = reader["Status"]?.ToString() ?? string.Empty,
                CurrencyCode = reader["CurrencyCode"]?.ToString() ?? string.Empty
            };
        }

        /// <summary>
        /// Determines the type of conflict when checking user existence
        /// </summary>
        /// <param name="username">Username being checked</param>
        /// <param name="email">Email being checked</param>
        /// <returns>Conflict type description</returns>
        private string DetermineConflictType(string username, string email)
        {
            try
            {
                bool usernameExists = false;
                bool emailExists = false;

                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    // Check username separately
                    if (!string.IsNullOrWhiteSpace(username))
                    {
                        using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM [dbo].[Users] WHERE Username = @Username", connection))
                        {
                            command.Parameters.AddWithValue("@Username", username);
                            connection.Open();
                            usernameExists = Convert.ToInt32(command.ExecuteScalar()) > 0;
                        }
                    }

                    // Check email separately
                    if (!string.IsNullOrWhiteSpace(email))
                    {
                        using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM [dbo].[Users] WHERE Email = @Email", connection))
                        {
                            command.Parameters.AddWithValue("@Email", email);
                            if (connection.State != ConnectionState.Open)
                                connection.Open();
                            emailExists = Convert.ToInt32(command.ExecuteScalar()) > 0;
                        }
                    }
                }

                if (usernameExists && emailExists)
                    return "Both";
                else if (usernameExists)
                    return "Username";
                else if (emailExists)
                    return "Email";
                else
                    return "Unknown";
            }
            catch
            {
                return "Unknown";
            }
        }

        /// <summary>
        /// Checks if a column exists in the SqlDataReader
        /// </summary>
        /// <param name="reader">SqlDataReader to check</param>
        /// <param name="columnName">Column name to look for</param>
        /// <returns>True if column exists</returns>
        private bool HasColumn(SqlDataReader reader, string columnName)
        {
            try
            {
                return reader.GetOrdinal(columnName) >= 0;
            }
            catch (IndexOutOfRangeException)
            {
                return false;
            }
        }

        #endregion
    }
}