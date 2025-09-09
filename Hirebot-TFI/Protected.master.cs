using System;
using System.Web;
using System.Web.Security;
using System.Web.UI;

namespace Hirebot_TFI
{
    public partial class Protected : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Ensure user is authenticated
            if (!HttpContext.Current.User.Identity.IsAuthenticated)
            {
                FormsAuthentication.RedirectToLoginPage();
                return;
            }
            
            if (!IsPostBack)
            {
                ConfigureNavigation();
            }
        }
        
        private void ConfigureNavigation()
        {
            try
            {
                // Show admin navigation if user is admin
                if (IsCurrentUserAdmin())
                {
                    pnlAdminNavigation.Visible = true;
                }
            }
            catch (Exception ex)
            {
                // Log error but don't break the page
                System.Diagnostics.Debug.WriteLine($"Error configuring navigation: {ex.Message}");
            }
        }
        
        private bool IsCurrentUserAdmin()
        {
            try
            {
                return Session["UserRole"] != null && 
                       Session["UserRole"].ToString().Equals("Admin", StringComparison.OrdinalIgnoreCase);
            }
            catch
            {
                return false;
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            try
            {
                // Clear the authentication cookie
                FormsAuthentication.SignOut();
                
                // Clear the session
                Session.Clear();
                Session.Abandon();
                
                // Redirect to sign-in page
                Response.Redirect("SignIn.aspx", true);
            }
            catch (Exception ex)
            {
                // Log error if needed
                Response.Redirect("SignIn.aspx", true);
            }
        }

    }
}