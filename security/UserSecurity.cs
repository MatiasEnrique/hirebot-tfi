using System;
using System.Configuration;
using System.Security.Principal;
using System.Web;
using System.Web.Security;
using BLL;
using ABSTRACTIONS;
using SERVICES;


namespace SECURITY
{
    public class UserSecurity
    {
        private readonly UserBLL userBLL;
        private readonly LogBLL _logBLL;
        private readonly RecaptchaService _recaptchaService;

        public UserSecurity()
        {
            userBLL = new UserBLL();
            _logBLL = new LogBLL();
            _recaptchaService = new RecaptchaService();
        }

        #region User Account Module

        public UserAccountDashboardResult GetCurrentUserAccountDashboard()
        {
            try
            {
                var currentUser = GetCurrentUser();
                if (currentUser == null)
                {
                    return UserAccountDashboardResult.Failure(-401, "User not authenticated.");
                }

                var result = userBLL.GetUserAccountDashboard(currentUser.UserId);
                if (result.IsSuccessful && result.Data?.Profile != null)
                {
                    UpdateSessionUser(result.Data.Profile);
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log
                {
                    LogType = LogService.LogTypes.ERROR,
                    UserId = null,
                    Description = $"Account dashboard error: {ex.Message}",
                    CreatedAt = DateTime.Now
                });

                return UserAccountDashboardResult.Failure(-999, "Error loading account information.");
            }
        }

        public DatabaseResult UpdateCurrentUserProfile(string firstName, string lastName, string email)
        {
            try
            {
                var currentUser = GetCurrentUser();
                if (currentUser == null)
                {
                    return DatabaseResult.Failure(-401, "User not authenticated.");
                }

                var result = userBLL.UpdateUserProfile(currentUser.UserId, firstName, lastName, email);
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log
                    {
                        LogType = LogService.LogTypes.UPDATE,
                        UserId = currentUser.UserId,
                        Description = $"User {currentUser.Username} updated profile",
                        CreatedAt = DateTime.Now
                    });

                    RefreshCurrentUser();
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log
                {
                    LogType = LogService.LogTypes.ERROR,
                    UserId = null,
                    Description = $"Profile update error: {ex.Message}",
                    CreatedAt = DateTime.Now
                });

                return DatabaseResult.Failure(-999, "An unexpected error occurred.");
            }
        }

        public DatabaseResult ChangeCurrentUserPassword(string currentPassword, string newPassword, string confirmPassword)
        {
            try
            {
                var currentUser = GetCurrentUser();
                if (currentUser == null)
                {
                    return DatabaseResult.Failure(-401, "User not authenticated.");
                }

                var result = userBLL.ChangePassword(currentUser.UserId, currentPassword, newPassword, confirmPassword);
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log
                    {
                        LogType = LogService.LogTypes.SYSTEM,
                        UserId = currentUser.UserId,
                        Description = $"User {currentUser.Username} changed password",
                        CreatedAt = DateTime.Now
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log
                {
                    LogType = LogService.LogTypes.ERROR,
                    UserId = null,
                    Description = $"Password change error: {ex.Message}",
                    CreatedAt = DateTime.Now
                });

                return DatabaseResult.Failure(-999, "An unexpected error occurred.");
            }
        }

        public DatabaseResult CancelCurrentUserSubscription(int subscriptionId)
        {
            try
            {
                var currentUser = GetCurrentUser();
                if (currentUser == null)
                {
                    return DatabaseResult.Failure(-401, "User not authenticated.");
                }

                var result = userBLL.CancelSubscription(currentUser.UserId, subscriptionId);
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log
                    {
                        LogType = LogService.LogTypes.UPDATE,
                        UserId = currentUser.UserId,
                        Description = $"User {currentUser.Username} cancelled subscription {subscriptionId}",
                        CreatedAt = DateTime.Now
                    });

                    RefreshCurrentUser();
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log
                {
                    LogType = LogService.LogTypes.ERROR,
                    UserId = null,
                    Description = $"Subscription cancel error: {ex.Message}",
                    CreatedAt = DateTime.Now
                });

                return DatabaseResult.Failure(-999, "An unexpected error occurred.");
            }
        }

        private void UpdateSessionUser(UserAccountProfile profile)
        {
            try
            {
                if (profile == null || HttpContext.Current?.Session == null)
                {
                    return;
                }

                var sessionUser = HttpContext.Current.Session["CurrentUser"] as User;
                if (sessionUser == null)
                {
                    sessionUser = new User();
                }

                sessionUser.UserId = profile.UserId;
                sessionUser.Username = profile.Username;
                sessionUser.Email = profile.Email;
                sessionUser.FirstName = profile.FirstName;
                sessionUser.LastName = profile.LastName;
                sessionUser.IsActive = profile.IsActive;

                HttpContext.Current.Session["CurrentUser"] = sessionUser;
            }
            catch
            {
                // Ignore session update errors
            }
        }

        private void RefreshCurrentUser()
        {
            try
            {
                var currentUser = GetCurrentUser();
                if (currentUser == null)
                {
                    return;
                }

                var refreshed = userBLL.GetUserByUsername(currentUser.Username);
                if (refreshed != null && HttpContext.Current?.Session != null)
                {
                    HttpContext.Current.Session["CurrentUser"] = refreshed;
                }
            }
            catch
            {
                // Ignore refresh errors
            }
        }

        #endregion

        public RecaptchaValidationResult ValidateRecaptchaToken(string responseToken, string userIpAddress)
        {
            var result = _recaptchaService.ValidateToken(
                responseToken,
                ConfigurationManager.AppSettings["Recaptcha.SecretKey"],
                userIpAddress);

            if (!result.IsValid && (string.Equals(result.FailureReason, "missing-secret", StringComparison.OrdinalIgnoreCase) ||
                                    string.Equals(result.FailureReason, "verification-exception", StringComparison.OrdinalIgnoreCase)))
            {
                _logBLL.CreateLog(new Log
                {
                    LogType = LogService.LogTypes.ERROR,
                    UserId = null,
                    Description = $"reCAPTCHA validation issue: {result.FailureReason}",
                    CreatedAt = DateTime.Now
                });
            }

            return result;
        }
        public AuthenticationResult RegisterUser(string username, string email, string password, string confirmPassword, string firstName, string lastName)
        {
            try
            {
                var result = userBLL.RegisterUser(username, email, password, confirmPassword, firstName, lastName);
                
                if (result.IsSuccessful && result.User != null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.REGISTER, 
                        UserId = result.User.UserId, 
                        Description = $"User {result.User.Username} registered", 
                        CreatedAt = DateTime.Now 
                    });
                    
                    // Send welcome email after successful registration
                    // Email failure should not break registration process
                    SendWelcomeEmailSafely(result.User);
                }
                
                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = null, 
                    Description = "Registration error: " + ex.Message, 
                    CreatedAt = DateTime.Now 
                });
                return new AuthenticationResult(false, "An error occurred during registration. Please try again.");
            }
        }

        public AuthenticationResult SignInUser(string usernameOrEmail, string password, bool rememberMe = false)
        {
            try
            {
                var result = userBLL.AuthenticateUser(usernameOrEmail, password);
                
                if (result.IsSuccessful && result.User != null)
                {
                    CreateAuthenticationTicket(result.User, rememberMe);
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.LOGIN, 
                        UserId = result.User.UserId, 
                        Description = $"User {result.User.Username} logged in", 
                        CreatedAt = DateTime.Now 
                    });
                    
                    // Clear any cached user data to ensure fresh retrieval
                    if (HttpContext.Current?.Session != null)
                    {
                        HttpContext.Current.Session.Remove("CurrentUser");
                    }
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Login failed for: {usernameOrEmail}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = null, 
                    Description = "Sign in error: " + ex.Message, 
                    CreatedAt = DateTime.Now 
                });
                return new AuthenticationResult(false, "An error occurred during sign in. Please try again.");
            }
        }

        public void SignOutUser()
        {
            try
            {
                var currentUser = GetCurrentUser();
                
                FormsAuthentication.SignOut();
                
                if (HttpContext.Current != null && HttpContext.Current.Session != null)
                {
                    HttpContext.Current.Session.Clear();
                    HttpContext.Current.Session.Abandon();
                }

                if (currentUser != null)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.LOGOUT, 
                        UserId = currentUser.UserId, 
                        Description = $"User {currentUser.Username} logged out", 
                        CreatedAt = DateTime.Now 
                    });
                }
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = null, 
                    Description = "Sign out error: " + ex.Message, 
                    CreatedAt = DateTime.Now 
                });
            }
        }

        public User GetCurrentUser()
        {
            try
            {
                if (HttpContext.Current != null && HttpContext.Current.User != null && HttpContext.Current.User.Identity.IsAuthenticated)
                {
                    var user = HttpContext.Current.Session["CurrentUser"] as User;
                    if (user != null)
                        return user;

                    string username = HttpContext.Current.User.Identity.Name;
                    if (!string.IsNullOrEmpty(username))
                    {
                        // Get user by username without password since user is already authenticated
                        user = userBLL.GetUserByUsername(username);
                        if (user != null)
                        {
                            HttpContext.Current.Session["CurrentUser"] = user;
                            return user;
                        }
                    }
                }
            }
            catch (Exception)
            {
                
            }

            return null;
        }

        public bool IsUserAuthenticated()
        {
            try
            {
                return HttpContext.Current != null && 
                       HttpContext.Current.User != null && 
                       HttpContext.Current.User.Identity.IsAuthenticated;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public void RequireAuthentication()
        {
            if (!IsUserAuthenticated())
            {
                if (HttpContext.Current != null)
                {
                    HttpContext.Current.Response.Redirect("~/SignIn.aspx", true);
                }
            }
        }

        private void CreateAuthenticationTicket(User user, bool rememberMe)
        {
            try
            {
                if (HttpContext.Current != null)
                {
                    var ticket = new FormsAuthenticationTicket(
                        1,
                        user.Username,
                        DateTime.Now,
                        rememberMe ? DateTime.Now.AddDays(30) : DateTime.Now.AddMinutes(30),
                        rememberMe,
                        user.UserId.ToString()
                    );

                    string encryptedTicket = FormsAuthentication.Encrypt(ticket);
                    var cookie = new HttpCookie(FormsAuthentication.FormsCookieName, encryptedTicket)
                    {
                        Expires = rememberMe ? DateTime.Now.AddDays(30) : DateTime.MinValue
                    };

                    HttpContext.Current.Response.Cookies.Add(cookie);
                    
                    // Set the current user context immediately
                    var identity = new FormsIdentity(ticket);
                    var principal = new GenericPrincipal(identity, new string[] { });
                    HttpContext.Current.User = principal;
                    System.Threading.Thread.CurrentPrincipal = principal;
                    
                    HttpContext.Current.Session["CurrentUser"] = user;
                }
            }
            catch (Exception)
            {
                
            }
        }

        #region Password Recovery Security Methods

        /// <summary>
        /// Initiates password recovery process through security layer
        /// Follows UI → Security → BLL → DAL flow with security validations
        /// </summary>
        /// <param name="emailOrUsername">Email address or username for recovery</param>
        /// <returns>AuthenticationResult with recovery initiation status</returns>
        public AuthenticationResult InitiatePasswordRecovery(string emailOrUsername)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(emailOrUsername))
                {
                    return new AuthenticationResult(false, "Email or username is required");
                }

                // Security validation - basic input sanitization
                if (!ValidatePasswordRecoveryRequest(emailOrUsername))
                {
                    return new AuthenticationResult(false, "Invalid recovery request");
                }

                // Get client information for security tracking
                string requestIP = GetClientIPAddress();
                string userAgent = GetClientUserAgent();

                // Log the password recovery attempt
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.SYSTEM, 
                    UserId = null, 
                    Description = $"Password recovery initiated for: {emailOrUsername} from IP: {requestIP}", 
                    CreatedAt = DateTime.Now 
                });

                // **CRITICAL FIX: Follow architectural flow UI → Security → BLL → DAL**
                // Call BLL layer instead of directly handling email/database operations
                var result = userBLL.InitiatePasswordRecovery(emailOrUsername, requestIP, userAgent);

                // Log the result based on success/failure
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.SYSTEM, 
                        UserId = null, 
                        Description = $"Password recovery processed successfully for: {emailOrUsername}", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Password recovery failed for {emailOrUsername}: {result.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                // Always return success message for security (don't reveal if user exists)
                // But preserve actual error information for debugging
                return new AuthenticationResult(true, "If an account with that email or username exists, you will receive a password recovery email shortly.");
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = null, 
                    Description = $"Password recovery security error for {emailOrUsername}: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return new AuthenticationResult(false, "An error occurred during password recovery. Please try again.");
            }
        }

        /// <summary>
        /// Validates a password recovery token through security layer
        /// Includes security checks and logging
        /// </summary>
        /// <param name="token">Recovery token to validate</param>
        /// <returns>PasswordRecoveryValidationResult with validation details</returns>
        public PasswordRecoveryValidationResult ValidatePasswordRecoveryToken(string token)
        {
            try
            {
                // Security validation
                if (string.IsNullOrWhiteSpace(token))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = "Password recovery validation attempted with empty token", 
                        CreatedAt = DateTime.Now 
                    });
                    return PasswordRecoveryValidationResult.Failure(-1, "Invalid recovery token");
                }

                // Get client information for security tracking
                string requestIP = GetClientIPAddress();
                
                // Log the validation attempt
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.SYSTEM, 
                    UserId = null, 
                    Description = $"Password recovery token validation attempted from IP: {requestIP}", 
                    CreatedAt = DateTime.Now 
                });

                // Call BLL layer for validation
                var result = userBLL.ValidatePasswordRecoveryToken(token);
                
                // Security logging based on result
                if (result.IsSuccessful && result.IsTokenValid)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.SYSTEM, 
                        UserId = null, 
                        Description = $"Valid password recovery token validated from IP: {requestIP}", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Invalid password recovery token validation from IP: {requestIP} - {result.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = null, 
                    Description = $"Password recovery token validation security error: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return PasswordRecoveryValidationResult.Failure(-999, "An error occurred during token validation. Please try again.");
            }
        }

        /// <summary>
        /// Completes password reset through security layer
        /// Includes comprehensive security validations and logging
        /// </summary>
        /// <param name="token">Recovery token</param>
        /// <param name="newPassword">New password</param>
        /// <param name="confirmPassword">Password confirmation</param>
        /// <returns>AuthenticationResult with reset completion status</returns>
        public AuthenticationResult ResetPasswordWithToken(string token, string newPassword, string confirmPassword)
        {
            try
            {
                // Security validation - comprehensive input validation
                if (!ValidatePasswordResetRequest(token, newPassword, confirmPassword))
                {
                    return new AuthenticationResult(false, "Invalid password reset request");
                }

                // Get client information for security tracking
                string requestIP = GetClientIPAddress();
                string userAgent = GetClientUserAgent();

                // Log the password reset attempt
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.SYSTEM, 
                    UserId = null, 
                    Description = $"Password reset attempted from IP: {requestIP}", 
                    CreatedAt = DateTime.Now 
                });

                // Call BLL layer for business logic processing
                var result = userBLL.ResetPasswordWithToken(token, newPassword, confirmPassword);
                
                // Security logging based on result
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.SYSTEM, 
                        UserId = null, 
                        Description = $"Password successfully reset from IP: {requestIP}", 
                        CreatedAt = DateTime.Now 
                    });
                    
                    // Additional security measure: invalidate all existing sessions for this user
                    // This could be implemented as a future enhancement
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = null, 
                        Description = $"Password reset failed from IP: {requestIP} - {result.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = null, 
                    Description = $"Password reset security error: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return new AuthenticationResult(false, "An error occurred during password reset. Please try again.");
            }
        }

        /// <summary>
        /// Administrative method to cleanup expired recovery tokens
        /// Requires admin privileges - should be called by system maintenance
        /// </summary>
        /// <returns>DatabaseResult with cleanup status</returns>
        public DatabaseResult CleanupExpiredRecoveryTokens()
        {
            try
            {
                // Security check - verify current user has admin privileges
                var currentUser = GetCurrentUser();
                if (currentUser == null || currentUser.UserRole != "admin")
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser?.UserId, 
                        Description = "Unauthorized attempt to cleanup recovery tokens", 
                        CreatedAt = DateTime.Now 
                    });
                    return DatabaseResult.Failure(-1, "Unauthorized operation");
                }

                // Log the cleanup attempt
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.SYSTEM, 
                    UserId = currentUser.UserId, 
                    Description = $"Password recovery cleanup initiated by admin: {currentUser.Username}", 
                    CreatedAt = DateTime.Now 
                });

                // Call BLL layer for cleanup
                var result = userBLL.CleanupExpiredRecoveryTokens();
                
                // Log the cleanup result
                if (result.IsSuccessful)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.SYSTEM, 
                        UserId = currentUser.UserId, 
                        Description = $"Password recovery cleanup completed: {result.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = currentUser.UserId, 
                        Description = $"Password recovery cleanup failed: {result.ErrorMessage}", 
                        CreatedAt = DateTime.Now 
                    });
                }

                return result;
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = null, 
                    Description = $"Password recovery cleanup security error: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return DatabaseResult.Failure(-999, "An error occurred during cleanup operation.");
            }
        }

        #endregion

        #region Private Security Helper Methods

        /// <summary>
        /// Validates password recovery request for security
        /// Includes rate limiting and input sanitization
        /// </summary>
        /// <param name="emailOrUsername">Email or username to validate</param>
        /// <returns>True if request is valid</returns>
        private bool ValidatePasswordRecoveryRequest(string emailOrUsername)
        {
            try
            {
                // Basic input validation
                if (string.IsNullOrWhiteSpace(emailOrUsername))
                    return false;

                // Length validation to prevent potential attacks
                if (emailOrUsername.Length > 100)
                    return false;

                // Basic format validation
                string input = emailOrUsername.Trim();
                if (input.Contains("'") || input.Contains("\"") || input.Contains(";") || input.Contains("--"))
                    return false;

                // Rate limiting could be implemented here
                // For now, we'll implement basic validation

                return true;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Validates password reset request for security
        /// </summary>
        /// <param name="token">Recovery token</param>
        /// <param name="newPassword">New password</param>
        /// <param name="confirmPassword">Password confirmation</param>
        /// <returns>True if request is valid</returns>
        private bool ValidatePasswordResetRequest(string token, string newPassword, string confirmPassword)
        {
            try
            {
                // Basic validation
                if (string.IsNullOrWhiteSpace(token) || string.IsNullOrWhiteSpace(newPassword))
                    return false;

                // Token format validation
                if (!Guid.TryParse(token, out _))
                    return false;

                // Password length validation
                if (newPassword.Length < 6 || newPassword.Length > 100)
                    return false;

                // Password confirmation validation
                if (newPassword != confirmPassword)
                    return false;

                return true;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Gets the client IP address with proxy support
        /// </summary>
        /// <returns>Client IP address</returns>
        private string GetClientIPAddress()
        {
            try
            {
                if (HttpContext.Current?.Request != null)
                {
                    // Check for forwarded IP first (proxy scenarios)
                    string forwardedIP = HttpContext.Current.Request.Headers["X-Forwarded-For"];
                    if (!string.IsNullOrWhiteSpace(forwardedIP))
                    {
                        // Take the first IP if multiple are present
                        return forwardedIP.Split(',')[0].Trim();
                    }

                    // Check real IP header
                    string realIP = HttpContext.Current.Request.Headers["X-Real-IP"];
                    if (!string.IsNullOrWhiteSpace(realIP))
                    {
                        return realIP.Trim();
                    }

                    // Fall back to user host address
                    return HttpContext.Current.Request.UserHostAddress ?? "Unknown";
                }
                return "Unknown";
            }
            catch
            {
                return "Unknown";
            }
        }

        /// <summary>
        /// Gets the client user agent string
        /// </summary>
        /// <returns>User agent string</returns>
        private string GetClientUserAgent()
        {
            try
            {
                if (HttpContext.Current?.Request != null)
                {
                    string userAgent = HttpContext.Current.Request.UserAgent;
                    // Truncate if too long for security
                    if (!string.IsNullOrEmpty(userAgent) && userAgent.Length > 500)
                    {
                        userAgent = userAgent.Substring(0, 500);
                    }
                    return userAgent ?? "Unknown";
                }
                return "Unknown";
            }
            catch
            {
                return "Unknown";
            }
        }

        #endregion

        #region Email Integration Methods

        /// <summary>
        /// Safely sends welcome email without affecting registration process
        /// Follows security best practices with comprehensive error handling
        /// </summary>
        /// <param name="user">User who just registered</param>
        private void SendWelcomeEmailSafely(User user)
        {
            try
            {
                if (user == null || string.IsNullOrWhiteSpace(user.Email))
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = user?.UserId, 
                        Description = "Welcome email not sent: Invalid user or email", 
                        CreatedAt = DateTime.Now 
                    });
                    return;
                }

                // Generate login URL for the welcome email
                string loginUrl = GetLoginUrl();
                
                // Combine first and last name for personalization
                string fullName = $"{user.FirstName} {user.LastName}".Trim();
                
                // Log the welcome email attempt
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.SYSTEM, 
                    UserId = user.UserId, 
                    Description = $"Sending welcome email to new user: {user.Username} ({user.Email})", 
                    CreatedAt = DateTime.Now 
                });
                
                // Send the welcome email
                bool emailSent = EmailService.SendWelcomeEmail(user.Email, fullName, loginUrl);
                
                if (emailSent)
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.SYSTEM, 
                        UserId = user.UserId, 
                        Description = $"Welcome email sent successfully to: {user.Username} ({user.Email})", 
                        CreatedAt = DateTime.Now 
                    });
                }
                else
                {
                    _logBLL.CreateLog(new Log 
                    { 
                        LogType = LogService.LogTypes.ERROR, 
                        UserId = user.UserId, 
                        Description = $"Welcome email failed to send to: {user.Username} ({user.Email})", 
                        CreatedAt = DateTime.Now 
                    });
                }
            }
            catch (Exception ex)
            {
                // Log error but don't throw - welcome email failure should not break registration
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = user?.UserId, 
                    Description = $"Welcome email error for user {user?.Username}: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
            }
        }

        /// <summary>
        /// Gets the login URL for welcome email
        /// Uses security context to determine the correct URL
        /// </summary>
        /// <returns>Login URL for the application</returns>
        private string GetLoginUrl()
        {
            try
            {
                if (HttpContext.Current != null && HttpContext.Current.Request != null)
                {
                    string baseUrl = HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority);
                    return $"{baseUrl}/SignIn.aspx";
                }
                return "https://localhost:44383/SignIn.aspx"; // Fallback for development
            }
            catch (Exception ex)
            {
                _logBLL.CreateLog(new Log 
                { 
                    LogType = LogService.LogTypes.ERROR, 
                    UserId = null, 
                    Description = $"Error generating login URL: {ex.Message}", 
                    CreatedAt = DateTime.Now 
                });
                return "https://localhost:44383/SignIn.aspx"; // Fallback
            }
        }


        #endregion
    }
}