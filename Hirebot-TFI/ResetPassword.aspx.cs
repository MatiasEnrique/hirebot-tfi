using System;
using System.Web;
using System.Web.UI;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class ResetPassword : BasePage
    {
        private UserSecurity userSecurity;
        private string resetToken = string.Empty;
        
        protected int TokenExpiryMinutes { get; private set; } = 15; // Default 15 minutes

        protected void Page_Load(object sender, EventArgs e)
        {
            // CRITICAL DEBUG: Log page lifecycle
            System.Diagnostics.Debug.WriteLine($"🚨 Page_Load called. IsPostBack: {IsPostBack}");
            
            userSecurity = new UserSecurity();

            // Redirect if user is already authenticated
            if (userSecurity.IsUserAuthenticated())
            {
                Response.Redirect("~/Dashboard.aspx");
                return;
            }

            // Get the reset token from query string
            resetToken = Request.QueryString["token"] ?? string.Empty;

            if (string.IsNullOrEmpty(resetToken))
            {
                // No token provided, redirect to forgot password page
                Response.Redirect("~/ForgotPassword.aspx");
                return;
            }

            if (!IsPostBack)
            {
                InitializePage();
            }
            else
            {
                // CRITICAL DEBUG: Log postback details
                System.Diagnostics.Debug.WriteLine("🚨 POSTBACK detected!");
                System.Diagnostics.Debug.WriteLine($"🚨 __EVENTTARGET: {Request.Form["__EVENTTARGET"]}");
                System.Diagnostics.Debug.WriteLine($"🚨 __EVENTARGUMENT: {Request.Form["__EVENTARGUMENT"]}");
                
                // Add JavaScript debug for postback
                string postbackScript = @"
                console.log('%c🚨 POSTBACK DETECTED ON SERVER', 'color: orange; font-weight: bold; font-size: 14px;');
                console.log('🚨 __EVENTTARGET: " + (Request.Form["__EVENTTARGET"] ?? "null") + @"');
                console.log('🚨 __EVENTARGUMENT: " + (Request.Form["__EVENTARGUMENT"] ?? "null") + @"');";
                ScriptManager.RegisterStartupScript(this, GetType(), "postbackDebug", postbackScript, true);
            }
        }

        private void InitializePage()
        {
            // Validate the reset token
            if (!ValidateResetToken())
            {
                return; // Error already shown, page redirected or form hidden
            }

            // Focus on the new password field
            txtNewPassword.Focus();

            // Set placeholder text (will also be handled by JavaScript)
            txtNewPassword.Attributes["placeholder"] = GetLocalizedString("EnterNewPassword");
            txtConfirmNewPassword.Attributes["placeholder"] = GetLocalizedString("ConfirmYourNewPassword");
        }

        private bool ValidateResetToken()
        {
            try
            {
                var result = userSecurity.ValidatePasswordRecoveryToken(resetToken);

                if (!result.IsSuccessful)
                {
                    string errorKey = "TokenInvalid";
                    
                    // Map specific error messages
                    if (result.ErrorMessage != null)
                    {
                        if (result.ErrorMessage.Contains("expired") || result.ErrorMessage.Contains("expirado"))
                        {
                            errorKey = "TokenExpired";
                        }
                        else if (result.ErrorMessage.Contains("used") || result.ErrorMessage.Contains("usado"))
                        {
                            errorKey = "TokenAlreadyUsed";
                        }
                    }
                    
                    ShowError(GetLocalizedString(errorKey));
                    pnlForm.Visible = false;
                    pnlTokenInfo.Visible = false;
                    return false;
                }

                // Token is valid, continue with the form
                return true;
            }
            catch (Exception ex)
            {
                ShowError(GetLocalizedString("TokenInvalid"));
                pnlForm.Visible = false;
                pnlTokenInfo.Visible = false;
                return false;
            }
        }


        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
            {
                ShowErrorToast(GetLocalizedString("ValidationErrors") ?? "Please correct the validation errors");
                return;
            }

            try
            {
                string newPassword = txtNewPassword.Text;
                string confirmPassword = txtConfirmNewPassword.Text;

                // Additional validation
                if (newPassword != confirmPassword)
                {
                    ShowError(GetLocalizedString("NewPasswordsDoNotMatch"));
                    return;
                }

                if (string.IsNullOrEmpty(newPassword) || newPassword.Length < 6)
                {
                    ShowError(GetLocalizedString("PasswordMinLength"));
                    return;
                }

                // Call the Security layer method following the architecture flow
                var result = userSecurity.ResetPasswordWithToken(resetToken, newPassword, confirmPassword);

                if (result.IsSuccessful)
                {
                    ShowSuccess();

                    // Clear form fields
                    txtNewPassword.Text = string.Empty;
                    txtConfirmNewPassword.Text = string.Empty;

                    // Hide the form after success
                    pnlForm.Visible = false;
                    pnlTokenInfo.Visible = false;

                    // Redirect to sign-in page after delay
                    string redirectScript = "setTimeout(function() { window.location.href = 'SignIn.aspx'; }, 4000);";
                    if (ScriptManager.GetCurrent(Page) != null)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "redirect", redirectScript, true);
                    }
                    else
                    {
                        ClientScript.RegisterStartupScript(this.GetType(), "redirect", redirectScript, true);
                    }
                }
                else
                {
                    ShowError(result.ErrorMessage ?? GetLocalizedString("PasswordResetError"));
                    
                    // If token is invalid/expired, hide the form
                    if (result.ErrorMessage != null && 
                        (result.ErrorMessage.Contains("token") || result.ErrorMessage.Contains("expired")))
                    {
                        pnlForm.Visible = false;
                        pnlTokenInfo.Visible = false;
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError(GetLocalizedString("PasswordResetError"));
            }
        }

        private void ShowError(string message)
        {
            try
            {
                // Show traditional panel error (keep existing functionality)
                lblError.Text = message;
                pnlError.Visible = true;
                pnlSuccess.Visible = false;
                
                // Show toast notification using proven ShowAlert pattern
                ShowErrorToast(message);
            }
            catch (Exception ex)
            {
                // Fallback error display - silently handle error
            }
        }

        private void ShowSuccess()
        {
            try
            {
                string successMessage = GetLocalizedString("PasswordResetSuccessRedirect");
                
                // Show traditional panel success (keep existing functionality)
                lblSuccess.Text = successMessage;
                pnlSuccess.Visible = true;
                pnlError.Visible = false;
                
                // Show toast notification using proven ShowAlert pattern
                ShowSuccessToast(successMessage);
            }
            catch (Exception ex)
            {
                // Fallback success display - silently handle error
            }
        }

        protected void btnSpanish_Click(object sender, EventArgs e)
        {
            try
            {
                Session["Language"] = "es";
                // Preserve the token in the redirect
                Response.Redirect("ResetPassword.aspx?token=" + resetToken);
            }
            catch (Exception ex)
            {
                // Fallback to current page reload
                Response.Redirect("ResetPassword.aspx");
            }
        }

        protected void btnEnglish_Click(object sender, EventArgs e)
        {
            try
            {
                Session["Language"] = "en";
                // Preserve the token in the redirect
                Response.Redirect("ResetPassword.aspx?token=" + resetToken);
            }
            catch (Exception ex)
            {
                // Fallback to current page reload
                Response.Redirect("ResetPassword.aspx");
            }
        }

        // Public method to be used in JavaScript for placeholder and message localization
        public string GetLocalizedString(string key)
        {
            try
            {
                return HttpContext.GetGlobalResourceObject("GlobalResources", key)?.ToString() ?? key;
            }
            catch
            {
                return key;
            }
        }

        #region Toast Notification Methods (Proven ShowAlert Pattern from ForgotPassword)

        /// <summary>
        /// Show alert notification with guaranteed DOM manipulation (proven pattern)
        /// </summary>
        /// <param name="message">Message to display</param>
        /// <param name="type">Type of alert (success, error, warning, info)</param>
        private void ShowAlert(string message, string type)
        {
            try
            {
                // Escape message for JavaScript - exactly like ForgotPassword
                string escapedMessage = message.Replace("'", "\\'").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", " ");
                
                // Determine notification style
                string bgColor, textColor, icon;
                if (type == "success")
                {
                    bgColor = "#28a745";
                    textColor = "white";
                    icon = "&#x2713;"; // HTML entity for checkmark
                }
                else if (type == "danger" || type == "error")
                {
                    bgColor = "#dc3545";
                    textColor = "white";
                    icon = "&#x26A0;"; // HTML entity for warning
                }
                else if (type == "warning")
                {
                    bgColor = "#ffc107";
                    textColor = "black";
                    icon = "&#x26A0;"; // HTML entity for warning
                }
                else
                {
                    bgColor = "#17a2b8";
                    textColor = "white";
                    icon = "&#x2139;"; // HTML entity for info
                }
                
                // Create a simple, guaranteed-to-work toast - exactly like ForgotPassword
                string script = @"
                (function() {
                    // Remove any existing toasts
                    var existing = document.querySelectorAll('.hirebot-toast');
                    existing.forEach(function(t) { t.remove(); });
                    
                    // Create toast
                    var toast = document.createElement('div');
                    toast.className = 'hirebot-toast';
                    toast.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 10000; background: " + bgColor + @"; color: " + textColor + @"; padding: 15px 20px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.3); font-family: Arial, sans-serif; font-size: 14px; max-width: 400px; word-wrap: break-word; transform: translateX(100%); transition: transform 0.3s ease;';
                    toast.innerHTML = '<div style=""display: flex; align-items: center;""><span style=""font-size: 18px; margin-right: 10px;"">" + icon + @"</span><span>" + escapedMessage + @"</span><button onclick=""this.parentElement.parentElement.remove()"" style=""background: none; border: none; color: " + textColor + @"; margin-left: 15px; cursor: pointer; font-size: 18px; padding: 0;"">&times;</button></div>';
                    
                    document.body.appendChild(toast);
                    
                    // Animate in
                    setTimeout(function() {
                        toast.style.transform = 'translateX(0)';
                    }, 10);
                    
                    // Auto remove with different timing for success vs errors
                    var autoHideDelay = ('" + type + @"' === 'success') ? 6000 : 8000;
                    setTimeout(function() {
                        if (toast.parentElement) {
                            toast.style.transform = 'translateX(100%)';
                            setTimeout(function() {
                                if (toast.parentElement) toast.remove();
                            }, 300);
                        }
                    }, autoHideDelay);
                })();";
                
                // Use ScriptManager for UpdatePanel compatibility
                if (ScriptManager.GetCurrent(Page) != null)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "showToast_" + DateTime.Now.Ticks, script, true);
                }
                else
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "showToast_" + DateTime.Now.Ticks, script, true);
                }
            }
            catch (Exception ex)
            {
                // Last resort fallback - exactly like ForgotPassword
                string fallbackScript = "alert('ALERT: " + message.Replace("'", "\\'") + "');";
                try
                {
                    if (ScriptManager.GetCurrent(Page) != null)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "lastResort", fallbackScript, true);
                    }
                    else
                    {
                        ClientScript.RegisterStartupScript(this.GetType(), "lastResort", fallbackScript, true);
                    }
                }
                catch
                {
                    // If all else fails, silently continue
                }
            }
        }

        /// <summary>
        /// Show success toast notification
        /// </summary>
        /// <param name="message">Success message</param>
        private void ShowSuccessToast(string message)
        {
            ShowAlert(message, "success");
        }

        /// <summary>
        /// Show error toast notification
        /// </summary>
        /// <param name="message">Error message</param>
        private void ShowErrorToast(string message)
        {
            ShowAlert(message, "error");
        }

        /// <summary>
        /// Show info toast notification
        /// </summary>
        /// <param name="message">Info message</param>
        private void ShowInfoToast(string message)
        {
            ShowAlert(message, "info");
        }

        /// <summary>
        /// Show warning toast notification
        /// </summary>
        /// <param name="message">Warning message</param>
        private void ShowWarningToast(string message)
        {
            ShowAlert(message, "warning");
        }

        #endregion
    }
}