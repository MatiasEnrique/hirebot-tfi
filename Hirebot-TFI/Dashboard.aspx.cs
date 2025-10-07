using System;
using System.Web;
using System.Web.UI;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class Dashboard : BasePage
    {
        private UserSecurity userSecurity;

        protected void Page_Load(object sender, EventArgs e)
        {
            userSecurity = new UserSecurity();

            userSecurity.RequireAuthentication();

            if (!IsPostBack)
            {
                LoadUserData();
            }
        }

        private void LoadUserData()
        {
            try
            {
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser != null)
                {
                    lblUserName.Text = $"{currentUser.FirstName} {currentUser.LastName}";
                    lblUsernameInfo.Text = currentUser.Username;
                    lblEmail.Text = currentUser.Email;
                    lblFirstName.Text = currentUser.FirstName;
                    lblLastName.Text = currentUser.LastName;

                    // Survey control loads automatically through its own Page_Load
                    // The SurveyDisplay user control is already on the page and will:
                    // 1. Call SurveySecurity.GetActiveSurveyForCurrentUser() in its Page_Load
                    // 2. Automatically display the survey if one is available
                    // 3. Hide itself if no survey is available or user already responded
                    // No explicit initialization needed from Dashboard
                }
                else
                {
                    Response.Redirect("~/SignIn.aspx");
                }
            }
            catch (Exception ex)
            {
                Response.Redirect("~/SignIn.aspx");
            }
        }


        protected void btnProfile_Click(object sender, EventArgs e)
        {
            // TODO: Redirect to profile page when implemented
            ShowMessage("ProfileComingSoon");
        }

        protected void btnJobs_Click(object sender, EventArgs e)
        {
            // TODO: Redirect to jobs page when implemented
            ShowMessage("JobsComingSoon");
        }

        protected void btnChat_Click(object sender, EventArgs e)
        {
            ShowMessage("ChatComingSoon");
        }

        private void ShowMessage(string resourceKey)
        {
            var message = HttpContext.GetGlobalResourceObject("GlobalResources", resourceKey) as string ?? resourceKey;
            ClientScript.RegisterStartupScript(this.GetType(), "alert", $"alert('{HttpUtility.JavaScriptStringEncode(message)}');", true);
        }
    }
}