using System;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;

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

                SetActiveNavigationLink();
            }
            catch (Exception ex)
            {
                // Log error but don't break the page
                System.Diagnostics.Debug.WriteLine($"Error configuring navigation: {ex.Message}");
            }
        }

        private void SetActiveNavigationLink()
        {
            string currentPage = VirtualPathUtility.GetFileName(Request.AppRelativeCurrentExecutionFilePath);

            ApplyNavClass(lnkDashboard, "Dashboard.aspx", currentPage);
            ApplyNavClass(lnkAccount, "Account.aspx", currentPage);
            ApplyNavClass(lnkCatalog, "Catalog.aspx", currentPage);
            ApplyNavClass(lnkSubscriptions, "Subscriptions.aspx", currentPage);
            ApplyNavClass(lnkOrganizations, "MyOrganizations.aspx", currentPage);

            if (pnlAdminNavigation.Visible)
            {
                ApplyNavClass(lnkAdminOrganizations, "OrganizationAdmin.aspx", currentPage);
                ApplyNavClass(lnkAdminNews, "AdminNews.aspx", currentPage);
                ApplyNavClass(lnkAdminSurveys, "AdminSurveys.aspx", currentPage);
                ApplyNavClass(lnkAdminBilling, "AdminBilling.aspx", currentPage);
                ApplyNavClass(lnkAdminReports, "AdminReports.aspx", currentPage);
            }
        }

        private void ApplyNavClass(HtmlAnchor anchor, string targetPage, string currentPage)
        {
            if (anchor == null)
            {
                return;
            }

            string cssClass = "nav-link";
            if (string.Equals(targetPage, currentPage, StringComparison.OrdinalIgnoreCase))
            {
                cssClass += " active";
            }

            anchor.Attributes["class"] = cssClass;
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