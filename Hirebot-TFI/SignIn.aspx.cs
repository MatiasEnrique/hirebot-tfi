using System;
using System.Web;
using System.Web.UI;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class SignIn : BasePage
    {
        private UserSecurity userSecurity;
        private AdminSecurity adminSecurity;
        private string recoveryToken = string.Empty;
        
        public enum PageMode
        {
            SignIn,
            PasswordReset
        }
        
        private PageMode CurrentPageMode
        {
            get
            {
                if (!string.IsNullOrEmpty(recoveryToken))
                    return PageMode.PasswordReset;
                return PageMode.SignIn;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            userSecurity = new UserSecurity();
            adminSecurity = new AdminSecurity();
            
            // Get recovery token from query string
            recoveryToken = Request.QueryString["token"] ?? string.Empty;

            // Check authentication and redirect if already logged in
            if (userSecurity.IsUserAuthenticated())
            {
                // Check for ReturnUrl parameter
                string returnUrl = Request.QueryString["ReturnUrl"];

                // Prevent infinite redirect loops
                if (!string.IsNullOrEmpty(returnUrl) &&
                    !returnUrl.Contains("SignIn.aspx") &&
                    !returnUrl.Contains("SignUp.aspx") &&
                    returnUrl.StartsWith("/", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect(returnUrl, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                // Default redirect based on user role
                if (adminSecurity.IsUserAdmin())
                {
                    Response.Redirect("~/AdminDashboard.aspx", false);
                }
                else
                {
                    Response.Redirect("~/Dashboard.aspx", false);
                }
                Context.ApplicationInstance.CompleteRequest();
            }

            if (!IsPostBack)
            {
                InitializePage();
            }
        }
        
        private void InitializePage()
        {
            SetPlaceholders();
            
            if (CurrentPageMode == PageMode.PasswordReset)
            {
                // Show password reset form and validate token
                pnlSignIn.Visible = false;
                pnlPasswordReset.Visible = true;
                
                ValidateRecoveryToken();
                
                if (pnlPasswordReset.Visible) // Still visible after validation
                {
                    txtNewPassword.Focus();
                }
            }
            else
            {
                // Show normal sign-in form
                pnlSignIn.Visible = true;
                pnlPasswordReset.Visible = false;
                txtUsernameOrEmail.Focus();
            }
            
        }
        
        private void ValidateRecoveryToken()
        {
            try
            {
                if (string.IsNullOrEmpty(recoveryToken))
                {
                    ShowError(GetLocalizedString("TokenInvalid"));
                    pnlPasswordReset.Visible = false;
                    pnlSignIn.Visible = true;
                    return;
                }
                
                var result = userSecurity.ValidatePasswordRecoveryToken(recoveryToken);
                
                if (!result.IsSuccessful)
                {
                    string errorKey = "TokenInvalid";
                    
                    // Map specific error messages
                    if (result.ErrorMessage.Contains("expired") || result.ErrorMessage.Contains("expirado"))
                    {
                        errorKey = "TokenExpired";
                    }
                    else if (result.ErrorMessage.Contains("used") || result.ErrorMessage.Contains("usado"))
                    {
                        errorKey = "TokenAlreadyUsed";
                    }
                    
                    ShowError(GetLocalizedString(errorKey));
                    pnlPasswordReset.Visible = false;
                    pnlSignIn.Visible = true;
                }
            }
            catch (Exception ex)
            {
                ShowError(GetLocalizedString("TokenInvalid"));
                pnlPasswordReset.Visible = false;
                pnlSignIn.Visible = true;
            }
        }

        protected void btnSignIn_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            try
            {
                string usernameOrEmail = txtUsernameOrEmail.Text.Trim();
                string password = txtPassword.Text;
                bool rememberMe = chkRememberMe.Checked;

                var result = userSecurity.SignInUser(usernameOrEmail, password, rememberMe);

                if (result.IsSuccessful)
                {
                    // Check for ReturnUrl parameter
                    string returnUrl = Request.QueryString["ReturnUrl"];

                    // Prevent infinite redirect loops and validate ReturnUrl
                    if (!string.IsNullOrEmpty(returnUrl) &&
                        !returnUrl.Contains("SignIn.aspx") &&
                        !returnUrl.Contains("SignUp.aspx") &&
                        returnUrl.StartsWith("/", StringComparison.OrdinalIgnoreCase))
                    {
                        Response.Redirect(returnUrl, false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }

                    // Default redirect based on user role
                    if (adminSecurity.IsUserAdmin())
                    {
                        Response.Redirect("~/AdminDashboard.aspx", false);
                    }
                    else
                    {
                        Response.Redirect("~/Dashboard.aspx", false);
                    }
                    Context.ApplicationInstance.CompleteRequest();
                }
                else
                {
                    ShowError(result.ErrorMessage);
                }
            }
            catch (Exception ex)
            {
                ShowError(GetLocalizedString("SignInError"));
            }
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            pnlError.Visible = true;
        }


        private void SetPlaceholders()
        {
            txtUsernameOrEmail.Attributes["placeholder"] = GetLocalizedString("EnterUsername");
            txtPassword.Attributes["placeholder"] = GetLocalizedString("EnterPassword");
            txtNewPassword.Attributes["placeholder"] = GetLocalizedString("EnterNewPassword");
            txtConfirmNewPassword.Attributes["placeholder"] = GetLocalizedString("ConfirmYourNewPassword");
        }

        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;
                
            try
            {
                string newPassword = txtNewPassword.Text;
                string confirmPassword = txtConfirmNewPassword.Text;
                
                var result = userSecurity.ResetPasswordWithToken(recoveryToken, newPassword, confirmPassword);
                
                if (result.IsSuccessful)
                {
                    ShowSuccess(GetLocalizedString("PasswordResetSuccess"));
                    
                    // Clear form fields
                    txtNewPassword.Text = string.Empty;
                    txtConfirmNewPassword.Text = string.Empty;
                    
                    // Hide password reset form and show sign-in form after delay
                    ClientScript.RegisterStartupScript(this.GetType(), "redirect", 
                        "setTimeout(function() { window.location.href = 'SignIn.aspx'; }, 3000);", true);
                }
                else
                {
                    ShowError(result.ErrorMessage ?? GetLocalizedString("PasswordResetError"));
                }
            }
            catch (Exception ex)
            {
                ShowError(GetLocalizedString("PasswordResetError"));
            }
        }
        
        
        private void ShowSuccess(string message)
        {
            lblSuccess.Text = message;
            pnlSuccess.Visible = true;
            pnlError.Visible = false;
        }
        
        // Public method to be used in JavaScript placeholder setting
        public string GetLocalizedString(string key)
        {
            return key;
        }
    }
}
