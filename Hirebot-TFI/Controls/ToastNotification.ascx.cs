using System;
using System.Web;
using System.Web.UI;

namespace Hirebot_TFI.Controls
{
    /// <summary>
    /// Toast notification user control for displaying animated notifications
    /// </summary>
    public partial class ToastNotification : System.Web.UI.UserControl
    {
        #region Public Properties

        /// <summary>
        /// Default duration for toast notifications in milliseconds
        /// </summary>
        public int DefaultDuration { get; set; } = 5000;

        /// <summary>
        /// Whether toasts should auto-hide or stay visible until manually closed
        /// </summary>
        public bool AutoHide { get; set; } = true;

        #endregion

        #region Page Events

        /// <summary>
        /// Initializes the toast notification control
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            RegisterToastScript();
        }

        #endregion

        #region Public Methods

        /// <summary>
        /// Shows a toast notification with the specified message and type
        /// </summary>
        /// <param name="message">The message to display</param>
        /// <param name="type">The type of toast (success, error, info, warning)</param>
        /// <param name="duration">Duration in milliseconds (0 for no auto-hide)</param>
        public void ShowToast(string message, string type, int duration = -1)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(message))
                {
                    System.Diagnostics.Debug.WriteLine("Warning: Empty message provided to ShowToast");
                    return;
                }

                // Use default duration if not specified
                if (duration == -1)
                    duration = AutoHide ? DefaultDuration : 0;

                // Escape message for JavaScript
                string escapedMessage = EscapeJavaScriptString(message);
                
                // Normalize type
                type = NormalizeToastType(type);

                // Generate unique script key
                string scriptKey = "showToast_" + DateTime.Now.Ticks;

                // Create simple toast JavaScript
                string toastClass, icon, title;
                switch (type)
                {
                    case "success":
                        toastClass = "bg-success";
                        icon = "✓";
                        title = "Success";
                        break;
                    case "danger":
                    case "error":
                        toastClass = "bg-danger";
                        icon = "⚠";
                        title = "Error";
                        break;
                    case "warning":
                        toastClass = "bg-warning";
                        icon = "⚠";
                        title = "Warning";
                        break;
                    default:
                        toastClass = "bg-info";
                        icon = "ℹ";
                        title = "Information";
                        break;
                }

                string script = $@"
                console.log('🔔 Toast called: {escapedMessage}');
                (function() {{
                    try {{
                        var container = document.getElementById('toastContainer');
                        if (!container) {{
                            container = document.createElement('div');
                            container.id = 'toastContainer';
                            container.className = 'position-fixed top-0 end-0 p-3';
                            container.style.zIndex = '9999';
                            document.body.appendChild(container);
                        }}
                        
                        var toastId = 'toast_' + Date.now();
                        var toastHtml = '<div id=""' + toastId + '"" class=""toast {toastClass} text-white mb-2"" role=""alert"">' +
                            '<div class=""toast-header {toastClass} text-white border-0"">' +
                                '<span class=""me-2 fw-bold"">{icon}</span>' +
                                '<strong class=""me-auto"">{title}</strong>' +
                                '<small class=""text-white-50"">Now</small>' +
                                '<button type=""button"" class=""btn-close btn-close-white ms-2"" onclick=""this.parentElement.parentElement.remove();""></button>' +
                            '</div>' +
                            '<div class=""toast-body"">{escapedMessage}</div>' +
                        '</div>';
                        
                        container.insertAdjacentHTML('beforeend', toastHtml);
                        
                        setTimeout(function() {{
                            var toast = document.getElementById(toastId);
                            if (toast) toast.classList.add('showing');
                        }}, 50);
                        
                        if ({duration} > 0) {{
                            setTimeout(function() {{
                                var toast = document.getElementById(toastId);
                                if (toast) {{
                                    toast.classList.add('hiding');
                                    setTimeout(function() {{ toast.remove(); }}, 400);
                                }}
                            }}, {duration});
                        }}
                    }} catch (e) {{
                        console.error('Toast error:', e);
                        alert('{escapedMessage}');
                    }}
                }})();";

                // Register the script
                ScriptManager.RegisterStartupScript(this, GetType(), scriptKey, script, true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in ShowToast: {ex.Message}");
                
                // Fallback to simple alert
                try
                {
                    string fallbackScript = $"alert('Toast Error: {EscapeJavaScriptString(message)}');";
                    ScriptManager.RegisterStartupScript(this, GetType(), "fallbackToast", fallbackScript, true);
                }
                catch
                {
                    // Last resort
                    System.Diagnostics.Debug.WriteLine($"Complete toast failure for message: {message}");
                }
            }
        }

        /// <summary>
        /// Shows a success toast notification
        /// </summary>
        public void ShowSuccess(string message, int duration = -1)
        {
            ShowToast(message, "success", duration);
        }

        /// <summary>
        /// Shows an error toast notification
        /// </summary>
        public void ShowError(string message, int duration = -1)
        {
            ShowToast(message, "error", duration);
        }

        /// <summary>
        /// Shows an info toast notification
        /// </summary>
        public void ShowInfo(string message, int duration = -1)
        {
            ShowToast(message, "info", duration);
        }

        /// <summary>
        /// Shows a warning toast notification
        /// </summary>
        public void ShowWarning(string message, int duration = -1)
        {
            ShowToast(message, "warning", duration);
        }

        #endregion

        #region Localization Helper Methods

        /// <summary>
        /// Gets localized success text for JavaScript
        /// </summary>
        protected string GetSuccessText()
        {
            try
            {
                return HttpContext.GetGlobalResourceObject("GlobalResources", "Success")?.ToString() ?? "Success";
            }
            catch
            {
                return "Success";
            }
        }

        /// <summary>
        /// Gets localized error text for JavaScript
        /// </summary>
        protected string GetErrorText()
        {
            try
            {
                return HttpContext.GetGlobalResourceObject("GlobalResources", "Error")?.ToString() ?? "Error";
            }
            catch
            {
                return "Error";
            }
        }

        /// <summary>
        /// Gets localized information text for JavaScript
        /// </summary>
        protected string GetInformationText()
        {
            try
            {
                return HttpContext.GetGlobalResourceObject("GlobalResources", "Information")?.ToString() ?? "Information";
            }
            catch
            {
                return "Information";
            }
        }

        /// <summary>
        /// Gets localized warning text for JavaScript
        /// </summary>
        protected string GetWarningText()
        {
            try
            {
                return HttpContext.GetGlobalResourceObject("GlobalResources", "Warning")?.ToString() ?? "Warning";
            }
            catch
            {
                return "Warning";
            }
        }

        /// <summary>
        /// Gets localized now text for JavaScript
        /// </summary>
        protected string GetNowText()
        {
            try
            {
                return HttpContext.GetGlobalResourceObject("GlobalResources", "Now")?.ToString() ?? "Now";
            }
            catch
            {
                return "Now";
            }
        }

        /// <summary>
        /// Gets localized close text for JavaScript
        /// </summary>
        protected string GetCloseText()
        {
            try
            {
                return HttpContext.GetGlobalResourceObject("GlobalResources", "Close")?.ToString() ?? "Close";
            }
            catch
            {
                return "Close";
            }
        }

        #endregion

        #region Private Methods

        /// <summary>
        /// Registers the toast system initialization script
        /// </summary>
        private void RegisterToastScript()
        {
            const string scriptKey = "ToastNotificationInit";
            
            if (!Page.ClientScript.IsStartupScriptRegistered(GetType(), scriptKey))
            {
                string initScript = @"
                    console.log('🚀 ToastNotification control initialized');
                    
                    // Ensure toast container exists
                    if (typeof document !== 'undefined') {
                        setTimeout(function() {
                            if (!document.getElementById('toastContainer')) {
                                console.warn('⚠ Creating missing toast container');
                                var container = document.createElement('div');
                                container.id = 'toastContainer';
                                container.className = 'toast-container position-fixed top-0 end-0 p-3';
                                container.style.zIndex = '9999';
                                document.body.appendChild(container);
                            }
                        }, 100);
                    }
                ";
                
                Page.ClientScript.RegisterStartupScript(GetType(), scriptKey, initScript, true);
            }
        }

        /// <summary>
        /// Escapes a string for safe use in JavaScript
        /// </summary>
        private string EscapeJavaScriptString(string input)
        {
            if (string.IsNullOrEmpty(input))
                return string.Empty;
                
            return input
                .Replace("\\", "\\\\")
                .Replace("'", "\\'")
                .Replace("\"", "\\\"")
                .Replace("\r", "\\r")
                .Replace("\n", "\\n")
                .Replace("\t", "\\t");
        }

        /// <summary>
        /// Normalizes toast type to a standard set of values
        /// </summary>
        private string NormalizeToastType(string type)
        {
            if (string.IsNullOrWhiteSpace(type))
                return "info";
                
            type = type.ToLower().Trim();
            
            switch (type)
            {
                case "success":
                case "ok":
                case "good":
                    return "success";
                    
                case "error":
                case "danger":
                case "fail":
                case "failed":
                case "bad":
                    return "danger";
                    
                case "warning":
                case "warn":
                case "caution":
                    return "warning";
                    
                case "info":
                case "information":
                case "notice":
                case "notification":
                default:
                    return "info";
            }
        }

        #endregion
    }
}