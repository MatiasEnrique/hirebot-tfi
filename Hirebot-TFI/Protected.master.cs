using System;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using SECURITY;
using SERVICES;

namespace Hirebot_TFI
{
    public partial class Protected : System.Web.UI.MasterPage
    {
        private readonly AuthorizationSecurity _authorizationSecurity = new AuthorizationSecurity();

        protected void Page_PreInit(object sender, EventArgs e)
        {
            // Set culture from Google Translate cookie
            string language = LanguageService.EnsureLanguage(HttpContext.Current);
            LanguageService.ApplyCulture(language);
        }

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
                ConfigurePrimaryLinks();
                ConfigureAdminLinks();
                SetActiveNavigationLink();
            }
            catch (Exception ex)
            {
                // Log error but don't break the page
                System.Diagnostics.Debug.WriteLine($"Error configuring navigation: {ex.Message}");
            }
        }

        private void ConfigurePrimaryLinks()
        {
            ToggleLinkVisibility(lnkDashboard, "~/Dashboard.aspx");
            ToggleLinkVisibility(lnkAccount, "~/Account.aspx");
            ToggleLinkVisibility(lnkCatalog, "~/Catalog.aspx");
            ToggleLinkVisibility(lnkSubscriptions, "~/Subscriptions.aspx");
            ToggleLinkVisibility(lnkOrganizations, "~/MyOrganizations.aspx");
        }

        private void ConfigureAdminLinks()
        {
            ToggleLinkVisibility(lnkAdminOrganizations, "~/OrganizationAdmin.aspx");
            ToggleLinkVisibility(lnkAdminNews, "~/AdminNews.aspx");
            ToggleLinkVisibility(lnkAdminSurveys, "~/AdminSurveys.aspx");
            ToggleLinkVisibility(lnkAdminBilling, "~/AdminBilling.aspx");
            ToggleLinkVisibility(lnkAdminReports, "~/AdminReports.aspx");
        }

        private void ToggleLinkVisibility(HtmlAnchor anchor, string permissionKey)
        {
            if (anchor == null)
            {
                return;
            }

            var isVisible = _authorizationSecurity.UserHasPermission(permissionKey);
            anchor.Visible = isVisible;

            if (anchor.Parent is HtmlGenericControl container)
            {
                container.Visible = isVisible;
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
            ApplyNavClass(lnkAdminOrganizations, "OrganizationAdmin.aspx", currentPage);
            ApplyNavClass(lnkAdminNews, "AdminNews.aspx", currentPage);
            ApplyNavClass(lnkAdminSurveys, "AdminSurveys.aspx", currentPage);
            ApplyNavClass(lnkAdminBilling, "AdminBilling.aspx", currentPage);
            ApplyNavClass(lnkAdminReports, "AdminReports.aspx", currentPage);
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
            return _authorizationSecurity.UserHasAnyPermission("~/AdminDashboard.aspx", "~/AdminRoles.aspx");
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