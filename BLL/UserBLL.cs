using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Web;
using DAL;
using ABSTRACTIONS;
using SERVICES;

namespace BLL
{
    public class UserBLL
    {
        private readonly UserDALProduction userDAL;

        public UserBLL()
        {
            userDAL = new UserDALProduction();
        }

        public AuthenticationResult RegisterUser(string username, string email, string password, string confirmPassword, string firstName, string lastName)
        {
            var validationResult = ValidateRegistration(username, email, password, confirmPassword, firstName, lastName);
            if (!validationResult.IsSuccessful)
                return validationResult;

            var existenceResult = userDAL.CheckUserExists(username, email);
            if (!existenceResult.IsSuccessful)
                return new AuthenticationResult(false, existenceResult.ErrorMessage);

            if (existenceResult.UserExists)
            {
                string conflictMessage = existenceResult.ConflictType == "Both" 
                    ? GetLocalizedString("UsernameAndEmailExist")
                    : existenceResult.ConflictType == "Username" 
                        ? GetLocalizedString("UsernameExists") 
                        : GetLocalizedString("EmailExists");
                return new AuthenticationResult(false, conflictMessage);
            }

            var user = new User
            {
                Username = username.Trim(),
                Email = email.Trim().ToLower(),
                PasswordHash = SERVICES.EncryptionService.EncryptPassword(password),
                FirstName = firstName.Trim(),
                LastName = lastName.Trim(),
                UserRole = "user",
                CreatedDate = DateTime.Now,
                IsActive = true
            };

            var createResult = userDAL.CreateUser(user);
            if (!createResult.IsSuccessful)
                return new AuthenticationResult(false, createResult.ErrorMessage);

            var getUserResult = userDAL.GetUserByUsername(username);
            if (getUserResult.IsSuccessful && getUserResult.Data != null)
            {
                return new AuthenticationResult(true) { User = getUserResult.Data };
            }

            return new AuthenticationResult(true) { User = user };
        }

        public AuthenticationResult AuthenticateUser(string usernameOrEmail, string password)
        {
            if (string.IsNullOrWhiteSpace(usernameOrEmail) || string.IsNullOrWhiteSpace(password))
                return new AuthenticationResult(false, GetLocalizedString("UsernameOrEmailRequired"));

            DatabaseResult<User> userResult = null;
            
            if (IsEmailFormat(usernameOrEmail))
                userResult = userDAL.GetUserByEmail(usernameOrEmail.Trim().ToLower());
            else
                userResult = userDAL.GetUserByUsername(usernameOrEmail.Trim());

            if (!userResult.IsSuccessful || userResult.Data == null)
                return new AuthenticationResult(false, GetLocalizedString("InvalidCredentials"));

            User user = userResult.Data;
            
            if (!user.IsActive)
                return new AuthenticationResult(false, GetLocalizedString("AccountInactive"));

            string encryptedPassword = SERVICES.EncryptionService.EncryptPassword(password);
            if (user.PasswordHash != encryptedPassword)
                return new AuthenticationResult(false, GetLocalizedString("InvalidCredentials"));

            var updateResult = userDAL.UpdateLastLoginDate(user.UserId);
            if (updateResult.IsSuccessful)
            {
                user.LastLoginDate = DateTime.Now;
            }

            return new AuthenticationResult(true) { User = user };
        }

        public User GetUserByUsername(string username)
        {
            if (string.IsNullOrWhiteSpace(username))
                return null;

            var result = userDAL.GetUserByUsername(username.Trim());
            return result.IsSuccessful ? result.Data : null;
        }

        public List<User> GetAllUsers()
        {
            var result = userDAL.GetAllUsers();
            return result.IsSuccessful ? result.Data : new List<User>();
        }

        private AuthenticationResult ValidateRegistration(string username, string email, string password, string confirmPassword, string firstName, string lastName)
        {
            if (string.IsNullOrWhiteSpace(username))
                return new AuthenticationResult(false, GetLocalizedString("UsernameRequired"));

            if (string.IsNullOrWhiteSpace(email))
                return new AuthenticationResult(false, GetLocalizedString("EmailRequired"));

            if (string.IsNullOrWhiteSpace(password))
                return new AuthenticationResult(false, GetLocalizedString("PasswordRequired"));

            if (string.IsNullOrWhiteSpace(firstName))
                return new AuthenticationResult(false, GetLocalizedString("FirstNameRequired"));

            if (string.IsNullOrWhiteSpace(lastName))
                return new AuthenticationResult(false, GetLocalizedString("LastNameRequired"));

            if (username.Trim().Length < 3)
                return new AuthenticationResult(false, GetLocalizedString("UsernameMinLength"));

            if (username.Trim().Length > 20)
                return new AuthenticationResult(false, GetLocalizedString("UsernameMaxLength"));

            if (!IsValidUsername(username.Trim()))
                return new AuthenticationResult(false, GetLocalizedString("UsernameInvalidChars"));

            if (!IsEmailFormat(email.Trim()))
                return new AuthenticationResult(false, GetLocalizedString("EmailInvalid"));

            if (password.Length < 6)
                return new AuthenticationResult(false, GetLocalizedString("PasswordMinLength"));

            if (password != confirmPassword)
                return new AuthenticationResult(false, GetLocalizedString("PasswordsDoNotMatch"));

            if (firstName.Trim().Length < 2)
                return new AuthenticationResult(false, GetLocalizedString("FirstNameMinLength"));

            if (lastName.Trim().Length < 2)
                return new AuthenticationResult(false, GetLocalizedString("LastNameMinLength"));

            return new AuthenticationResult(true);
        }

        private bool IsEmailFormat(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return false;

            string emailPattern = @"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
            return Regex.IsMatch(email, emailPattern);
        }

        private bool IsValidUsername(string username)
        {
            if (string.IsNullOrWhiteSpace(username))
                return false;

            string usernamePattern = @"^[a-zA-Z0-9_]+$";
            return Regex.IsMatch(username, usernamePattern);
        }

        private string GetLocalizedString(string key)
        {
            try
            {
                if (HttpContext.Current != null)
                {
                    return HttpContext.GetGlobalResourceObject("GlobalResources", key)?.ToString() ?? key;
                }
                return key;
            }
            catch
            {
                return key;
            }
        }

        #region Password Recovery Methods

        /// <summary>
        /// Initiates password recovery process by email or username
        /// Includes business validation and email sending coordination
        /// </summary>
        /// <param name="emailOrUsername">Email address or username for recovery</param>
        /// <param name="requestIP">IP address of the requester</param>
        /// <param name="userAgent">User agent string of the requester</param>
        /// <returns>AuthenticationResult with recovery initiation status</returns>
        public AuthenticationResult InitiatePasswordRecovery(string emailOrUsername, string requestIP, string userAgent)
        {
            // Input validation
            if (string.IsNullOrWhiteSpace(emailOrUsername))
                return new AuthenticationResult(false, GetLocalizedString("EmailOrUsernameRequired"));

            if (string.IsNullOrWhiteSpace(requestIP))
                return new AuthenticationResult(false, "Invalid request information");

            // Determine if input is email or username and get user
            DatabaseResult<User> userResult = null;
            
            try
            {
                if (IsEmailFormat(emailOrUsername.Trim()))
                    userResult = userDAL.GetUserByEmail(emailOrUsername.Trim().ToLower());
                else
                    userResult = userDAL.GetUserByUsername(emailOrUsername.Trim());

                // Don't reveal if user exists or not for security reasons
                if (!userResult.IsSuccessful || userResult.Data == null)
                {
                    // Return success message even if user doesn't exist to prevent user enumeration
                    return new AuthenticationResult(true, GetLocalizedString("PasswordRecoveryEmailSent"));
                }

                User user = userResult.Data;
                
                // Check if user account is active
                if (!user.IsActive)
                {
                    // Don't reveal that account is inactive for security
                    return new AuthenticationResult(true, GetLocalizedString("PasswordRecoveryEmailSent"));
                }

                // Create password recovery request
                var createResult = userDAL.CreatePasswordRecoveryRequest(user.UserId, requestIP, userAgent);
                if (!createResult.IsSuccessful)
                {
                    return new AuthenticationResult(false, GetLocalizedString("PasswordRecoveryError"));
                }

                // Send password recovery email with proper token URL
                string baseResetUrl = GetPasswordResetUrl();
                string resetUrl = $"{baseResetUrl}?token={createResult.RecoveryToken}";
                bool emailSent = EmailService.SendPasswordRecoveryEmail(
                    user.Email, 
                    $"{user.FirstName} {user.LastName}".Trim(),
                    createResult.RecoveryToken.ToString(),
                    resetUrl
                );

                if (!emailSent)
                {
                    // Log the error but don't reveal email sending failure to user
                    return new AuthenticationResult(false, GetLocalizedString("PasswordRecoveryError"));
                }

                return new AuthenticationResult(true, GetLocalizedString("PasswordRecoveryEmailSent"));
            }
            catch (Exception)
            {
                // Log the error but return generic message
                return new AuthenticationResult(false, GetLocalizedString("PasswordRecoveryError"));
            }
        }

        /// <summary>
        /// Validates a password recovery token
        /// </summary>
        /// <param name="token">Recovery token to validate</param>
        /// <returns>PasswordRecoveryValidationResult with validation details</returns>
        public PasswordRecoveryValidationResult ValidatePasswordRecoveryToken(string token)
        {
            if (string.IsNullOrWhiteSpace(token))
            {
                return PasswordRecoveryValidationResult.Failure(-1, GetLocalizedString("InvalidRecoveryToken"));
            }

            if (!Guid.TryParse(token, out Guid recoveryToken))
            {
                return PasswordRecoveryValidationResult.Failure(-2, GetLocalizedString("InvalidRecoveryToken"));
            }

            try
            {
                var validationResult = userDAL.ValidatePasswordRecoveryToken(recoveryToken);
                
                if (!validationResult.IsSuccessful)
                {
                    return PasswordRecoveryValidationResult.Failure(validationResult.ResultCode, GetLocalizedString("PasswordRecoveryError"));
                }

                if (!validationResult.IsTokenValid)
                {
                    if (validationResult.IsExpired)
                        return PasswordRecoveryValidationResult.Invalid(validationResult.ResultCode, GetLocalizedString("RecoveryTokenExpired"), isExpired: true);
                    
                    if (validationResult.IsUsed)
                        return PasswordRecoveryValidationResult.Invalid(validationResult.ResultCode, GetLocalizedString("RecoveryTokenUsed"), isUsed: true);
                    
                    return PasswordRecoveryValidationResult.Invalid(validationResult.ResultCode, GetLocalizedString("InvalidRecoveryToken"));
                }

                return validationResult;
            }
            catch (Exception)
            {
                return PasswordRecoveryValidationResult.Failure(-999, GetLocalizedString("PasswordRecoveryError"));
            }
        }

        /// <summary>
        /// Completes password reset using recovery token
        /// Includes business validation for password strength and confirmation
        /// </summary>
        /// <param name="token">Recovery token</param>
        /// <param name="newPassword">New password</param>
        /// <param name="confirmPassword">Password confirmation</param>
        /// <returns>AuthenticationResult with reset completion status</returns>
        public AuthenticationResult ResetPasswordWithToken(string token, string newPassword, string confirmPassword)
        {
            // Input validation
            if (string.IsNullOrWhiteSpace(token))
                return new AuthenticationResult(false, GetLocalizedString("InvalidRecoveryToken"));

            if (string.IsNullOrWhiteSpace(newPassword))
                return new AuthenticationResult(false, GetLocalizedString("PasswordRequired"));

            if (newPassword.Length < 6)
                return new AuthenticationResult(false, GetLocalizedString("PasswordMinLength"));

            if (newPassword != confirmPassword)
                return new AuthenticationResult(false, GetLocalizedString("PasswordsDoNotMatch"));

            if (!Guid.TryParse(token, out Guid recoveryToken))
                return new AuthenticationResult(false, GetLocalizedString("InvalidRecoveryToken"));

            try
            {
                // First validate the token
                var validationResult = ValidatePasswordRecoveryToken(token);
                if (!validationResult.IsSuccessful || !validationResult.IsTokenValid)
                {
                    return new AuthenticationResult(false, validationResult.ErrorMessage);
                }

                // Hash the new password
                string newPasswordHash = SERVICES.EncryptionService.EncryptPassword(newPassword);

                // Use the recovery token to update password
                var resetResult = userDAL.UsePasswordRecoveryToken(recoveryToken, newPasswordHash);
                if (!resetResult.IsSuccessful)
                {
                    return new AuthenticationResult(false, GetLocalizedString("PasswordResetError"));
                }

                // Get user information for email confirmation
                var user = GetUserById(validationResult.UserId);
                if (user != null)
                {
                    // Send password change confirmation email
                    EmailService.SendPasswordChangeConfirmationEmail(
                        user.Email,
                        $"{user.FirstName} {user.LastName}".Trim()
                    );
                }

                return new AuthenticationResult(true, GetLocalizedString("PasswordResetSuccess"));
            }
            catch (Exception)
            {
                return new AuthenticationResult(false, GetLocalizedString("PasswordResetError"));
            }
        }

        /// <summary>
        /// Performs cleanup of expired recovery tokens (maintenance method)
        /// Should be called periodically by a background service
        /// </summary>
        /// <returns>DatabaseResult with cleanup status</returns>
        public DatabaseResult CleanupExpiredRecoveryTokens()
        {
            try
            {
                return userDAL.CleanupExpiredRecoveryTokens();
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Cleanup error: {ex.Message}");
            }
        }

        #endregion

        #region Private Helper Methods for Password Recovery

        /// <summary>
        /// Gets the base URL for password reset functionality
        /// This should be configurable in production
        /// </summary>
        /// <returns>Base URL for password reset</returns>
        private string GetPasswordResetUrl()
        {
            try
            {
                if (HttpContext.Current != null && HttpContext.Current.Request != null)
                {
                    string baseUrl = HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority);
                    return $"{baseUrl}/ResetPassword.aspx"; // FIXED: Correct URL
                }
                return "https://localhost:44383/ResetPassword.aspx"; // Fallback for development
            }
            catch
            {
                return "https://localhost:44383/ResetPassword.aspx"; // Fallback
            }
        }

        /// <summary>
        /// Helper method to get user by user ID
        /// Used for email confirmation after password reset
        /// </summary>
        /// <param name="userId">User ID</param>
        /// <returns>User object or null if not found</returns>
        private User GetUserById(int userId)
        {
            try
            {
                // Get all users and find by ID - this could be optimized with a specific method
                var users = userDAL.GetAllUsers(includeInactive: true);
                if (users.IsSuccessful && users.Data != null)
                {
                    var user = users.Data.Find(u => u.UserId == userId);
                    return user;
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