using System;
using System.Globalization;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SECURITY;
using ABSTRACTIONS;

namespace UI
{
    public partial class Public : MasterPage
    {
        private UserSecurity userSecurity;

        protected void Page_Load(object sender, EventArgs e)
        {
            userSecurity = new UserSecurity();
            
            // Set culture from session or default to Spanish
            SetCulture();
            
            if (!IsPostBack)
            {
                CheckUserAuthentication();
            }
        }

        private void CheckUserAuthentication()
        {
            try
            {
                if (userSecurity.IsUserAuthenticated())
                {
                    var currentUser = userSecurity.GetCurrentUser();
                    if (currentUser != null)
                    {
                        // Show authenticated user interface
                        pnlAuthenticated.Visible = true;
                        pnlAnonymous.Visible = false;
                        
                        lblUserName.Text = currentUser.FirstName + " " + currentUser.LastName;
                        
                        // Check if user is admin
                        if (currentUser.UserRole == "admin")
                        {
                            pnlAdminLink.Visible = true;
                        }
                    }
                }
                else
                {
                    // Show anonymous user interface
                    pnlAuthenticated.Visible = false;
                    pnlAnonymous.Visible = true;
                    pnlAdminLink.Visible = false;
                }
            }
            catch (Exception ex)
            {
                // Fallback to anonymous navigation
                pnlAuthenticated.Visible = false;
                pnlAnonymous.Visible = true;
                pnlAdminLink.Visible = false;
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            try
            {
                userSecurity.SignOutUser();
                Response.Redirect("~/Default.aspx");
            }
            catch (Exception ex)
            {
                // Handle logout error
                Response.Redirect("~/Default.aspx");
            }
        }


        private void SetCulture()
        {
            string language = Session["Language"] as string ?? "es";
            
            CultureInfo culture = new CultureInfo(language);
            Thread.CurrentThread.CurrentCulture = culture;
            Thread.CurrentThread.CurrentUICulture = culture;
        }
    }
}