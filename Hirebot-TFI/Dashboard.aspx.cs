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
            ShowMessage("Profile management coming soon!");
        }

        protected void btnJobs_Click(object sender, EventArgs e)
        {
            // TODO: Redirect to jobs page when implemented
            ShowMessage("Job browsing coming soon!");
        }

        protected void btnChat_Click(object sender, EventArgs e)
        {
            ShowMessage("Hirebot chat coming soon!");
        }

        private void ShowMessage(string message)
        {
            // Simple JavaScript alert for now
            ClientScript.RegisterStartupScript(this.GetType(), "alert", $"alert('{message}');", true);
        }
    }
}