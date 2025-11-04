using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Web;
using DAL;
using ABSTRACTIONS;
using SERVICES;
using ServiceEncryption = SERVICES.EncryptionService;

namespace BLL
{
    public class UserBLL
    {
        private readonly UserDALProduction userDAL;

        public UserBLL()
        {
            userDAL = new UserDALProduction();
        }

        #region User Account Module

        public UserAccountDashboardResult GetUserAccountDashboard(int userId)
        {
            if (userId <= 0)
            {
                return UserAccountDashboardResult.Failure(-1, GetLocalizedString("UserNotFound"));
            }

            var dashboardResult = userDAL.GetUserAccountDashboard(userId);

            if (dashboardResult != null && dashboardResult.IsSuccessful && dashboardResult.Data?.Subscriptions != null)
            {
                foreach (var subscription in dashboardResult.Data.Subscriptions)
                {
                    SanitizeSubscription(subscription);
                }
            }

            return dashboardResult;
        }

        public DatabaseResult UpdateUserProfile(int userId, string firstName, string lastName, string email)
        {
            var validation = ValidateProfileUpdate(userId, firstName, lastName, email);
            if (!validation.IsSuccessful)
            {
                return validation;
            }

            var result = userDAL.UpdateUserProfile(userId, firstName.Trim(), lastName.Trim(), email.Trim());
            if (result.IsSuccessful)
            {
                return DatabaseResult.Success(GetLocalizedString("ProfileUpdateSuccess"));
            }

            return DatabaseResult.Failure(result.ResultCode, string.IsNullOrWhiteSpace(result.ErrorMessage)
                ? GetLocalizedString("ProfileUpdateError")
                : result.ErrorMessage);
        }

        public DatabaseResult ChangePassword(int userId, string currentPassword, string newPassword, string confirmPassword)
        {
            var validation = ValidatePasswordChange(userId, currentPassword, newPassword, confirmPassword);
            if (!validation.IsSuccessful)
            {
                return validation;
            }

            string currentHash = SERVICES.EncryptionService.EncryptPassword(currentPassword);
            string newHash = SERVICES.EncryptionService.EncryptPassword(newPassword);

            if (string.Equals(currentHash, newHash, StringComparison.OrdinalIgnoreCase))
            {
                return DatabaseResult.Failure(-6, GetLocalizedString("PasswordMustDiffer"));
            }

            var result = userDAL.UpdateUserPassword(userId, currentHash, newHash);
            if (result.IsSuccessful)
            {
                TrySendPasswordChangeEmail(userId);
                return DatabaseResult.Success(GetLocalizedString("PasswordChangeSuccess"));
            }

            return DatabaseResult.Failure(result.ResultCode, string.IsNullOrWhiteSpace(result.ErrorMessage)
                ? GetLocalizedString("PasswordChangeError")
                : result.ErrorMessage);
        }

        public DatabaseResult CancelSubscription(int userId, int subscriptionId)
        {
            if (userId <= 0)
            {
                return DatabaseResult.Failure(-1, GetLocalizedString("UserNotFound"));
            }

            if (subscriptionId <= 0)
            {
                return DatabaseResult.Failure(-2, GetLocalizedString("SubscriptionInvalid"));
            }

            var result = userDAL.CancelUserSubscription(userId, subscriptionId);
            if (result.IsSuccessful)
            {
                return DatabaseResult.Success(GetLocalizedString("SubscriptionCancelSuccess"));
            }

            string messageKey = string.Empty;
            switch (result.ResultCode)
            {
                case -1:
                case -3:
                    messageKey = "UserNotFound";
                    break;
                case -2:
                    messageKey = "SubscriptionInvalid";
                    break;
                case -4:
                    messageKey = "SubscriptionNotFound";
                    break;
                case -5:
                    messageKey = "SubscriptionAlreadyCancelled";
                    break;
            }

            if (!string.IsNullOrWhiteSpace(messageKey))
            {
                return DatabaseResult.Failure(result.ResultCode, GetLocalizedString(messageKey));
            }

            return DatabaseResult.Failure(result.ResultCode,
                string.IsNullOrWhiteSpace(result.ErrorMessage)
                    ? GetLocalizedString("SubscriptionCancelError")
                    : result.ErrorMessage);
        }

        /// <summary>
        /// Retrieves a user's feedback for a specific subscription
        /// </summary>
        public ProductSubscriptionFeedbackResult GetSubscriptionFeedback(int userId, int subscriptionId)
        {
            if (userId <= 0)
                return ProductSubscriptionFeedbackResult.Failure(-1, GetLocalizedString("UserNotFound"));
            if (subscriptionId <= 0)
                return ProductSubscriptionFeedbackResult.Failure(-2, GetLocalizedString("SubscriptionInvalid"));

            var result = userDAL.GetProductSubscriptionFeedbackBySubscription(subscriptionId, userId);
            return result;
        }

        /// <summary>
        /// Saves (insert/update) a user's feedback for a subscription
        /// </summary>
        public DatabaseResult SaveSubscriptionFeedback(int userId, int subscriptionId, int rating, string comment)
        {
            if (userId <= 0)
                return DatabaseResult.Failure(-1, GetLocalizedString("UserNotFound"));
            if (subscriptionId <= 0)
                return DatabaseResult.Failure(-2, GetLocalizedString("SubscriptionInvalid"));

            if (rating < 1 || rating > 5)
                return DatabaseResult.Failure(-3, GetLocalizedString("RatingOutOfRange"));

            // Normalize comment to max 1000 characters (matches DB proc parameter)
            string safeComment = comment ?? string.Empty;
            safeComment = safeComment.Trim();
            if (safeComment.Length > 1000)
            {
                safeComment = safeComment.Substring(0, 1000);
            }

            var result = userDAL.SaveProductSubscriptionFeedback(subscriptionId, userId, (byte)rating, string.IsNullOrWhiteSpace(safeComment) ? null : safeComment);
            return result.IsSuccessful
                ? DatabaseResult.Success(GetLocalizedString("SubscriptionFeedbackSavedSuccess"))
                : DatabaseResult.Failure(result.ResultCode, string.IsNullOrWhiteSpace(result.ErrorMessage) ? GetLocalizedString("SubscriptionFeedbackSaveError") : result.ErrorMessage);
        }

        private DatabaseResult ValidateProfileUpdate(int userId, string firstName, string lastName, string email)
        {
            if (userId <= 0)
                return DatabaseResult.Failure(-1, GetLocalizedString("UserNotFound"));

            if (string.IsNullOrWhiteSpace(firstName))
                return DatabaseResult.Failure(-2, GetLocalizedString("FirstNameRequired"));

            if (firstName.Trim().Length < 2)
                return DatabaseResult.Failure(-3, GetLocalizedString("FirstNameMinLength"));

            if (firstName.Trim().Length > 100)
                return DatabaseResult.Failure(-4, GetLocalizedString("FirstNameMaxLength"));

            if (string.IsNullOrWhiteSpace(lastName))
                return DatabaseResult.Failure(-5, GetLocalizedString("LastNameRequired"));

            if (lastName.Trim().Length < 2)
                return DatabaseResult.Failure(-6, GetLocalizedString("LastNameMinLength"));

            if (lastName.Trim().Length > 100)
                return DatabaseResult.Failure(-7, GetLocalizedString("LastNameMaxLength"));

            if (string.IsNullOrWhiteSpace(email))
                return DatabaseResult.Failure(-8, GetLocalizedString("EmailRequired"));

            if (!IsEmailFormat(email.Trim()))
                return DatabaseResult.Failure(-9, GetLocalizedString("EmailInvalid"));

            return DatabaseResult.Success();
        }

        private DatabaseResult ValidatePasswordChange(int userId, string currentPassword, string newPassword, string confirmPassword)
        {
            if (userId <= 0)
                return DatabaseResult.Failure(-1, GetLocalizedString("UserNotFound"));

            if (string.IsNullOrWhiteSpace(currentPassword))
                return DatabaseResult.Failure(-2, GetLocalizedString("CurrentPasswordRequired"));

            if (string.IsNullOrWhiteSpace(newPassword))
                return DatabaseResult.Failure(-3, GetLocalizedString("PasswordRequired"));

            if (newPassword.Length < 6)
                return DatabaseResult.Failure(-4, GetLocalizedString("PasswordMinLength"));

            if (string.IsNullOrWhiteSpace(confirmPassword))
                return DatabaseResult.Failure(-5, GetLocalizedString("PasswordConfirmationRequired"));

            if (!string.Equals(newPassword, confirmPassword))
                return DatabaseResult.Failure(-6, GetLocalizedString("PasswordsDoNotMatch"));

            if (string.Equals(currentPassword, newPassword, StringComparison.Ordinal))
                return DatabaseResult.Failure(-7, GetLocalizedString("PasswordMustDiffer"));

            return DatabaseResult.Success();
        }

        private void TrySendPasswordChangeEmail(int userId)
        {
            try
            {
                var dashboard = userDAL.GetUserAccountDashboard(userId);
                if (!dashboard.IsSuccessful || dashboard.Data?.Profile == null)
                    return;

                var profile = dashboard.Data.Profile;
                EmailService.SendPasswordChangeConfirmationEmail(profile.Email, profile.FullName);
            }
            catch
            {
                // Swallow email errors to avoid breaking password change flow
            }
        }

        private void SanitizeSubscription(ProductSubscription subscription)
        {
            if (subscription == null)
            {
                return;
            }

            try
            {
                if (!string.IsNullOrWhiteSpace(subscription.EncryptedCardholderName))
                {
                    string decryptedName = ServiceEncryption.DecryptAsymmetric(subscription.EncryptedCardholderName);
                    subscription.CardholderName = MaskCardholderName(decryptedName);
                }
                else
                {
                    subscription.CardholderName = MaskCardholderName(subscription.CardholderName);
                }
            }
            catch
            {
                subscription.CardholderName = MaskCardholderName(subscription.CardholderName);
            }

            try
            {
                if (!string.IsNullOrWhiteSpace(subscription.EncryptedCardNumber))
                {
                    string decryptedNumber = ServiceEncryption.DecryptSymmetric(subscription.EncryptedCardNumber);
                    if (!string.IsNullOrEmpty(decryptedNumber) && decryptedNumber.Length >= 4)
                    {
                        subscription.CardLast4 = decryptedNumber.Substring(decryptedNumber.Length - 4);
                    }
                }
            }
            catch
            {
            }
        }

        private string MaskCardholderName(string cardholderName)
        {
            if (string.IsNullOrWhiteSpace(cardholderName))
            {
                return string.Empty;
            }

            string trimmed = cardholderName.Trim();
            if (trimmed.Length <= 2)
            {
                return new string('*', trimmed.Length);
            }

            return string.Concat(trimmed[0], new string('*', trimmed.Length - 2), trimmed[trimmed.Length - 1]);
        }

        #endregion

        #region Admin User Management Methods

        /// <summary>
        /// Gets all users (admin operation)
        /// </summary>
        /// <param name="includeInactive">Whether to include inactive users</param>
        /// <returns>List of users</returns>
        public List<User> GetAllUsersForAdmin(bool includeInactive = true)
        {
            var result = userDAL.GetAllUsers(includeInactive);
            return result.IsSuccessful ? result.Data : new List<User>();
        }

        /// <summary>
        /// Gets a user by ID (admin operation)
        /// </summary>
        /// <param name="userId">User ID</param>
        /// <returns>User object or null</returns>
        public User GetUserById(int userId)
        {
            if (userId <= 0)
                return null;

            var result = userDAL.GetUserById(userId);
            return result.IsSuccessful ? result.Data : null;
        }

        /// <summary>
        /// Updates a user (admin operation) with business validation
        /// </summary>
        /// <param name="user">User object with updated information</param>
        /// <param name="modifiedBy">ID of admin making the change</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult UpdateUserAdmin(User user, int modifiedBy)
        {
            if (user == null)
                return DatabaseResult.Failure(-1, "User object cannot be null");

            if (modifiedBy <= 0)
                return DatabaseResult.Failure(-2, "Invalid modifier user ID");

            // Validate user data
            var validation = ValidateUserData(user);
            if (!validation.IsSuccessful)
                return validation;

            // Perform the update
            return userDAL.UpdateUser(user, modifiedBy);
        }

        /// <summary>
        /// Deletes (deactivates) a user (admin operation)
        /// </summary>
        /// <param name="userId">User ID to delete</param>
        /// <param name="deletedBy">ID of admin performing the deletion</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult DeleteUserAdmin(int userId, int deletedBy)
        {
            if (userId <= 0)
                return DatabaseResult.Failure(-1, "Invalid user ID");

            if (deletedBy <= 0)
                return DatabaseResult.Failure(-2, "Invalid deleter user ID");

            if (userId == deletedBy)
                return DatabaseResult.Failure(-3, "Cannot delete your own account");

            return userDAL.DeleteUser(userId, deletedBy);
        }

        /// <summary>
        /// Activates a user (admin operation)
        /// </summary>
        /// <param name="userId">User ID to activate</param>
        /// <param name="activatedBy">ID of admin performing the activation</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult ActivateUserAdmin(int userId, int activatedBy)
        {
            if (userId <= 0)
                return DatabaseResult.Failure(-1, "Invalid user ID");

            if (activatedBy <= 0)
                return DatabaseResult.Failure(-2, "Invalid activator user ID");

            return userDAL.ActivateUser(userId, activatedBy);
        }

        /// <summary>
        /// Validates user data for admin updates
        /// </summary>
        private DatabaseResult ValidateUserData(User user)
        {
            if (string.IsNullOrWhiteSpace(user.Username))
                return DatabaseResult.Failure(-1, "El nombre de usuario es requerido");

            if (user.Username.Trim().Length < 3)
                return DatabaseResult.Failure(-2, "El nombre de usuario debe tener al menos 3 caracteres");

            if (user.Username.Trim().Length > 50)
                return DatabaseResult.Failure(-3, "El nombre de usuario no puede exceder 50 caracteres");

            if (!IsValidUsername(user.Username.Trim()))
                return DatabaseResult.Failure(-4, "El nombre de usuario solo puede contener letras, números y guiones bajos");

            if (string.IsNullOrWhiteSpace(user.Email))
                return DatabaseResult.Failure(-5, "El correo electrónico es requerido");

            if (!IsEmailFormat(user.Email.Trim()))
                return DatabaseResult.Failure(-6, "Formato de correo electrónico inválido");

            if (string.IsNullOrWhiteSpace(user.FirstName))
                return DatabaseResult.Failure(-7, "El nombre es requerido");

            if (user.FirstName.Trim().Length < 2)
                return DatabaseResult.Failure(-8, "El nombre debe tener al menos 2 caracteres");

            if (string.IsNullOrWhiteSpace(user.LastName))
                return DatabaseResult.Failure(-9, "El apellido es requerido");

            if (user.LastName.Trim().Length < 2)
                return DatabaseResult.Failure(-10, "El apellido debe tener al menos 2 caracteres");

            if (string.IsNullOrWhiteSpace(user.UserRole))
                return DatabaseResult.Failure(-11, "El rol de usuario es requerido");

            if (user.UserRole != "user" && user.UserRole != "admin")
                return DatabaseResult.Failure(-12, "Rol de usuario inválido. Debe ser 'user' o 'admin'");

            return DatabaseResult.Success();
        }

        /// <summary>
        /// Creates a new user (admin operation) with specified role and business validation
        /// </summary>
        /// <param name="username">Username</param>
        /// <param name="email">Email address</param>
        /// <param name="password">Password</param>
        /// <param name="firstName">First name</param>
        /// <param name="lastName">Last name</param>
        /// <param name="userRole">User role (user or admin)</param>
        /// <param name="isActive">Whether user is active</param>
        /// <param name="createdBy">ID of admin creating the user</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult CreateUserAdmin(string username, string email, string password, string firstName, string lastName, string userRole, bool isActive, int createdBy)
        {
            if (createdBy <= 0)
                return DatabaseResult.Failure(-1, "ID del creador inválido");

            // Validate user data
            var validation = ValidateUserCreation(username, email, password, firstName, lastName, userRole);
            if (!validation.IsSuccessful)
                return validation;

            // Check if user already exists
            var existenceResult = userDAL.CheckUserExists(username, email);
            if (!existenceResult.IsSuccessful)
                return DatabaseResult.Failure(existenceResult.ResultCode, existenceResult.ErrorMessage);

            if (existenceResult.UserExists)
            {
                string conflictMessage = existenceResult.ConflictType == "Both" 
                    ? "El nombre de usuario y el correo electrónico ya existen"
                    : existenceResult.ConflictType == "Username" 
                        ? "El nombre de usuario ya existe" 
                        : "El correo electrónico ya existe";
                return DatabaseResult.Failure(-2, conflictMessage);
            }

            // Create user object
            var user = new User
            {
                Username = username.Trim(),
                Email = email.Trim().ToLower(),
                PasswordHash = SERVICES.EncryptionService.EncryptPassword(password),
                FirstName = firstName.Trim(),
                LastName = lastName.Trim(),
                UserRole = userRole,
                CreatedDate = DateTime.Now,
                IsActive = isActive
            };

            // Create the user
            var createResult = userDAL.CreateUser(user);
            if (!createResult.IsSuccessful)
                return DatabaseResult.Failure(createResult.ResultCode, 
                    string.IsNullOrWhiteSpace(createResult.ErrorMessage) 
                        ? "Error al crear el usuario" 
                        : createResult.ErrorMessage);

            return DatabaseResult.Success("Usuario creado exitosamente");
        }

        /// <summary>
        /// Validates user data for admin user creation
        /// </summary>
        private DatabaseResult ValidateUserCreation(string username, string email, string password, string firstName, string lastName, string userRole)
        {
            if (string.IsNullOrWhiteSpace(username))
                return DatabaseResult.Failure(-1, "El nombre de usuario es requerido");

            if (username.Trim().Length < 3)
                return DatabaseResult.Failure(-2, "El nombre de usuario debe tener al menos 3 caracteres");

            if (username.Trim().Length > 50)
                return DatabaseResult.Failure(-3, "El nombre de usuario no puede exceder 50 caracteres");

            if (!IsValidUsername(username.Trim()))
                return DatabaseResult.Failure(-4, "El nombre de usuario solo puede contener letras, números y guiones bajos");

            if (string.IsNullOrWhiteSpace(email))
                return DatabaseResult.Failure(-5, "El correo electrónico es requerido");

            if (!IsEmailFormat(email.Trim()))
                return DatabaseResult.Failure(-6, "Formato de correo electrónico inválido");

            if (string.IsNullOrWhiteSpace(password))
                return DatabaseResult.Failure(-7, "La contraseña es requerida");

            if (password.Length < 6)
                return DatabaseResult.Failure(-8, "La contraseña debe tener al menos 6 caracteres");

            if (string.IsNullOrWhiteSpace(firstName))
                return DatabaseResult.Failure(-9, "El nombre es requerido");

            if (firstName.Trim().Length < 2)
                return DatabaseResult.Failure(-10, "El nombre debe tener al menos 2 caracteres");

            if (string.IsNullOrWhiteSpace(lastName))
                return DatabaseResult.Failure(-11, "El apellido es requerido");

            if (lastName.Trim().Length < 2)
                return DatabaseResult.Failure(-12, "El apellido debe tener al menos 2 caracteres");

            if (string.IsNullOrWhiteSpace(userRole))
                return DatabaseResult.Failure(-13, "El rol de usuario es requerido");

            if (userRole != "user" && userRole != "admin")
                return DatabaseResult.Failure(-14, "Rol de usuario inválido. Debe ser 'user' o 'admin'");

            return DatabaseResult.Success();
        }

        #endregion

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
                string resetUrl = string.Format("{0}?token={1}", baseResetUrl, createResult.RecoveryToken);
                bool emailSent = EmailService.SendPasswordRecoveryEmail(
                    user.Email, 
                    string.Format("{0} {1}", user.FirstName, user.LastName).Trim(),
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
                        string.Format("{0} {1}", user.FirstName, user.LastName).Trim()
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
                return DatabaseResult.Failure(string.Format("Cleanup error: {0}", ex.Message));
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
                    return string.Format("{0}/ResetPassword.aspx", baseUrl); // FIXED: Correct URL
                }
                return "https://localhost:44383/ResetPassword.aspx"; // Fallback for development
            }
            catch
            {
                return "https://localhost:44383/ResetPassword.aspx"; // Fallback
            }
        }

        #endregion
    }
}
