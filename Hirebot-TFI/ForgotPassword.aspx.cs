using System;
using System.Web;
using System.Web.UI;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class ForgotPassword : BasePage
    {
        private UserSecurity userSecurity;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Debug: Log page load
            ClientScript.RegisterStartupScript(this.GetType(), "page_load", 
                $"console.log('PAGE LOAD - IsPostBack: {IsPostBack}');", true);
            
            userSecurity = new UserSecurity();

            // Redirect if user is already authenticated
            if (userSecurity.IsUserAuthenticated())
            {
                Response.Redirect("~/Dashboard.aspx");
                return;
            }

            if (!IsPostBack)
            {
                InitializePage();
                
                // Add test buttons for debugging toast functionality
                #if DEBUG
                ClientScript.RegisterStartupScript(this.GetType(), "debug_toast_functions", @"
                    window.testSuccessToast = function() {
                        console.log('Testing success toast via postback...');
                        __doPostBack('testSuccess', '');
                    };
                    window.testErrorToast = function() {
                        console.log('Testing error toast via postback...');
                        __doPostBack('testError', '');
                    };
                ", true);
                #endif
            }
        }

        private void InitializePage()
        {
            // Focus on the email field
            txtEmailOrUsername.Focus();

            // Set placeholder text (will be handled by JavaScript as well)
            txtEmailOrUsername.Attributes["placeholder"] = GetLocalizedString("EnterEmailOrUsername");
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            
            #if DEBUG
            // Handle test postback events
            string eventTarget = Request.Form["__EVENTTARGET"];
            if (eventTarget == "testSuccess")
            {
                ShowSuccessToast("Test success message! This is a sample success notification to verify the ShowAlert method works correctly.");
            }
            else if (eventTarget == "testError")
            {
                ShowErrorToast("Test error message! This is a sample error notification to verify the ShowAlert method works correctly.");
            }
            #endif
        }

        protected void btnSendRecoveryEmail_Click(object sender, EventArgs e)
        {
            // Add comprehensive debugging
            try
            {
                // Debug logging to verify method is being called
                ClientScript.RegisterStartupScript(this.GetType(), "debug", 
                    "console.log('✓ btnSendRecoveryEmail_Click method called successfully');", true);

                if (!Page.IsValid)
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "validation", 
                        "console.log('❌ Page validation failed');", true);
                    return;
                }

                string emailOrUsername = txtEmailOrUsername.Text.Trim();
                ClientScript.RegisterStartupScript(this.GetType(), "input", 
                    $"console.log('⚙️ Email/Username input: {emailOrUsername}');", true);

                if (string.IsNullOrEmpty(emailOrUsername))
                {
                    ShowError(GetLocalizedString("EmailOrUsernameRequired"));
                    ClientScript.RegisterStartupScript(this.GetType(), "empty", 
                        "console.log('❌ Email/Username is empty');", true);
                    return;
                }

                ClientScript.RegisterStartupScript(this.GetType(), "calling_security", 
                    "console.log('⚙️ Calling Security layer for password recovery');", true);

                // Call the Security layer method following the architecture flow
                var result = userSecurity.InitiatePasswordRecovery(emailOrUsername);

                ClientScript.RegisterStartupScript(this.GetType(), "security_result", 
                    $"console.log('⚙️ Security layer result - Success: {result.IsSuccessful}');", true);

                if (result.IsSuccessful)
                {
                    // Show success message (always show success for security)
                    ShowSuccess();
                    
                    // DO NOT clear the form field - preserve user input for better UX
                    // This helps users verify what email address they used
                    
                    // Focus back to the input field for better UX
                    txtEmailOrUsername.Focus();
                    
                    // DO NOT hide pnlForm - keep it visible to prevent EventValidation errors
                    // This allows users to send another recovery email if needed
                    
                    ClientScript.RegisterStartupScript(this.GetType(), "success_complete", 
                        "console.log('✓ Password recovery process completed - form remains available');", true);
                }
                else
                {
                    // For debugging, show the actual error message temporarily
                    // In production, this should be generic
                    ShowError($"Error: {result.ErrorMessage}");
                    ClientScript.RegisterStartupScript(this.GetType(), "error_result", 
                        $"console.log('❌ Password recovery error: {result.ErrorMessage?.Replace("'", "\\'")}');", true);
                }
            }
            catch (Exception ex)
            {
                // For debugging, show the actual error message temporarily  
                // In production, this should be generic
                ShowError($"Exception: {ex.Message}");
                ClientScript.RegisterStartupScript(this.GetType(), "exception", 
                    $"console.log('❌ Password recovery exception: {ex.Message?.Replace("'", "\\'")}');", true);
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
                // Fallback error display
                ClientScript.RegisterStartupScript(this.GetType(), "error", 
                    $"console.log('❌ Error displaying message: {ex.Message}');", true);
            }
        }

        private void ShowSuccess()
        {
            try
            {
                string successMessage = GetLocalizedString("RecoveryEmailSent");
                
                // Show traditional panel success (keep existing functionality)
                lblSuccess.Text = successMessage;
                pnlSuccess.Visible = true;
                pnlError.Visible = false;
                
                // Show toast notification using proven ShowAlert pattern
                ShowSuccessToast(successMessage);
            }
            catch (Exception ex)
            {
                // Fallback success display
                ClientScript.RegisterStartupScript(this.GetType(), "success", 
                    "console.log('✓ Recovery email request processed');", true);
            }
        }

        protected void btnSpanish_Click(object sender, EventArgs e)
        {
            try
            {
                Session["Language"] = "es";
                Response.Redirect(Request.Url.ToString());
            }
            catch (Exception ex)
            {
                // Fallback to current page reload
                Response.Redirect("ForgotPassword.aspx");
            }
        }

        protected void btnEnglish_Click(object sender, EventArgs e)
        {
            try
            {
                Session["Language"] = "en";
                Response.Redirect(Request.Url.ToString());
            }
            catch (Exception ex)
            {
                // Fallback to current page reload
                Response.Redirect("ForgotPassword.aspx");
            }
        }

        // Public method to be used in JavaScript for placeholder and message localization
        public string GetLocalizedString(string key)
        {
            return key;
        }

        #region Toast Notification Methods (Proven ShowAlert Pattern from ChatbotAdmin)

        /// <summary>
        /// Show alert notification with guaranteed DOM manipulation (ChatbotAdmin pattern)
        /// </summary>
        /// <param name="message">Message to display</param>
        /// <param name="type">Type of alert (success, error, warning, info)</param>
        private void ShowAlert(string message, string type)
        {
            try
            {
                // Escape message for JavaScript - exactly like ChatbotAdmin
                string escapedMessage = message.Replace("'", "\\'").Replace("\"", "\\\"");
                
                // Determine notification style
                string bgColor, textColor, icon;
                if (type == "success")
                {
                    bgColor = "#28a745";
                    textColor = "white";
                    icon = "✓"; // Direct Unicode characters like ChatbotAdmin
                }
                else if (type == "danger" || type == "error")
                {
                    bgColor = "#dc3545";
                    textColor = "white";
                    icon = "⚠"; // Direct Unicode characters like ChatbotAdmin
                }
                else if (type == "warning")
                {
                    bgColor = "#ffc107";
                    textColor = "black";
                    icon = "⚠"; // Direct Unicode characters like ChatbotAdmin
                }
                else
                {
                    bgColor = "#17a2b8";
                    textColor = "white";
                    icon = "ℹ"; // Direct Unicode characters like ChatbotAdmin
                }
                
                // Create a simple, guaranteed-to-work toast - exactly like ChatbotAdmin
                string script = $@"
                (function() {{
                    console.log('🔔 ForgotPassword ShowAlert called: {type} - {escapedMessage}');
                    
                    // Remove any existing toasts
                    var existing = document.querySelectorAll('.hirebot-toast');
                    existing.forEach(function(t) {{ t.remove(); }});
                    
                    // Create toast
                    var toast = document.createElement('div');
                    toast.className = 'hirebot-toast';
                    toast.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 10000; background: {bgColor}; color: {textColor}; padding: 15px 20px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.3); font-family: Arial, sans-serif; font-size: 14px; max-width: 400px; word-wrap: break-word; transform: translateX(100%); transition: transform 0.3s ease;';
                    toast.innerHTML = '<div style=""display: flex; align-items: center;""><span style=""font-size: 18px; margin-right: 10px;"">{icon}</span><span>{escapedMessage}</span><button onclick=""this.parentElement.parentElement.remove()"" style=""background: none; border: none; color: {textColor}; margin-left: 15px; cursor: pointer; font-size: 18px; padding: 0;"">&times;</button></div>';
                    
                    document.body.appendChild(toast);
                    
                    // Animate in
                    setTimeout(function() {{
                        toast.style.transform = 'translateX(0)';
                    }}, 10);
                    
                    // Auto remove after 5 seconds - like ChatbotAdmin
                    setTimeout(function() {{
                        if (toast.parentElement) {{
                            toast.style.transform = 'translateX(100%)';
                            setTimeout(function() {{
                                if (toast.parentElement) toast.remove();
                            }}, 300);
                        }}
                    }}, 5000);
                    
                    console.log('✅ ForgotPassword Toast shown: {escapedMessage}');
                }})();";
                
                // Use ScriptManager if available, otherwise fall back to ClientScript
                if (ScriptManager.GetCurrent(Page) != null)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "showToast_" + DateTime.Now.Ticks, script, true);
                }
                else
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "showToast_" + DateTime.Now.Ticks, script, true);
                }
                
                // Also log to console for debugging
                System.Diagnostics.Debug.WriteLine($"ForgotPassword ShowAlert called: {message} ({type})");
            }
            catch (Exception ex)
            {
                // Last resort fallback - exactly like ChatbotAdmin
                string fallbackScript = $"alert('ALERT: {message.Replace("'", "\\'")}');";
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
                    // If all else fails, at least log it
                    System.Diagnostics.Debug.WriteLine($"Critical error in ShowAlert fallback: {ex.Message}");
                }
                System.Diagnostics.Debug.WriteLine($"ForgotPassword ShowAlert error: {ex.Message}");
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