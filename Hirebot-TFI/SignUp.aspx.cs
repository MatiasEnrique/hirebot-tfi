using System;
using System.Web;
using System.Web.UI;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class SignUp : BasePage
    {
        private UserSecurity userSecurity;

        protected void Page_Load(object sender, EventArgs e)
        {
            userSecurity = new UserSecurity();

            if (userSecurity.IsUserAuthenticated())
            {
                Response.Redirect("~/Dashboard.aspx");
            }

            if (!IsPostBack)
            {
                SetPlaceholders();
                txtFirstName.Focus();
            }
        }

        protected void btnSignUp_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            try
            {
                string username = txtUsername.Text.Trim();
                string email = txtEmail.Text.Trim();
                string password = txtPassword.Text;
                string confirmPassword = txtConfirmPassword.Text;
                string firstName = txtFirstName.Text.Trim();
                string lastName = txtLastName.Text.Trim();

                var result = userSecurity.RegisterUser(username, email, password, confirmPassword, firstName, lastName);

                if (result.IsSuccessful)
                {
                    // Auto-login the user after successful registration
                    var loginResult = userSecurity.SignInUser(username, password);
                    
                    if (loginResult.IsSuccessful)
                    {
                        // Redirect to dashboard after successful registration and auto-login
                        Response.Redirect("~/Dashboard.aspx");
                    }
                    else
                    {
                        // Registration successful but auto-login failed, show success and redirect to sign in
                        ShowSuccess(GetLocalizedString("AccountCreatedSuccess") + " " + GetLocalizedString("PleaseSignIn"));
                        Response.AddHeader("REFRESH", "3;URL=SignIn.aspx");
                    }
                }
                else
                {
                    ShowError(result.ErrorMessage);
                }
            }
            catch (Exception ex)
            {
                ShowError(GetLocalizedString("RegistrationError"));
            }
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
        }

        private void ShowSuccess(string message)
        {
            lblSuccess.Text = message;
            pnlSuccess.Visible = true;
            pnlError.Visible = false;
        }

        private void ClearForm()
        {
            txtUsername.Text = "";
            txtEmail.Text = "";
            txtPassword.Text = "";
            txtConfirmPassword.Text = "";
            txtFirstName.Text = "";
            txtLastName.Text = "";
        }

        private string GetLocalizedString(string key)
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

        private void SetPlaceholders()
        {
            txtFirstName.Attributes["placeholder"] = GetLocalizedString("FirstName");
            txtLastName.Attributes["placeholder"] = GetLocalizedString("LastName");
            txtUsername.Attributes["placeholder"] = GetLocalizedString("ChooseUsername");
            txtEmail.Attributes["placeholder"] = GetLocalizedString("EnterEmail");
            txtPassword.Attributes["placeholder"] = GetLocalizedString("CreatePassword");
            txtConfirmPassword.Attributes["placeholder"] = GetLocalizedString("ConfirmYourPassword");
        }

        protected void btnSpanish_Click(object sender, EventArgs e)
        {
            Session["Language"] = "es";
            Response.Redirect(Request.Url.ToString());
        }

        protected void btnEnglish_Click(object sender, EventArgs e)
        {
            Session["Language"] = "en";
            Response.Redirect(Request.Url.ToString());
        }
    }
}