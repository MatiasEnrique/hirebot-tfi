using System;
using System.Web;
using System.Web.Security;
using System.Web.UI.HtmlControls;
using SECURITY;
using SERVICES;

namespace Hirebot_TFI
{
    public partial class AdminMaster : System.Web.UI.MasterPage
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
            ConfigureNavigation();
            SetActiveNavigationLink();
            SetSearchPlaceholder();
        }

        private void SetSearchPlaceholder()
        {
            navSearch.Attributes["placeholder"] = "Buscar páginas...";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();
            Response.Redirect("~/SignIn.aspx", true);
        }

        private void ConfigureNavigation()
        {
            ToggleNavItem(navAdminDashboard, lnkAdminDashboard, "~/AdminDashboard.aspx");
            ToggleNavItem(navAdminRoles, lnkAdminRoles, "~/AdminRoles.aspx");
            ToggleNavItem(navAdminUsers, lnkAdminUsers, "~/AdminUsers.aspx");
            ToggleNavItem(navOrganizationAdmin, lnkOrganizationAdmin, "~/OrganizationAdmin.aspx");
            ToggleNavItem(navChatbotAdmin, lnkChatbotAdmin, "~/ChatbotAdmin.aspx");
            ToggleNavItem(navAdminCatalog, lnkAdminCatalog, "~/AdminCatalog.aspx");
            ToggleNavItem(navAdminNews, lnkAdminNews, "~/AdminNews.aspx");
            ToggleNavItem(navAdminBilling, lnkAdminBilling, "~/AdminBilling.aspx");
            ToggleNavItem(navAdminSurveys, lnkAdminSurveys, "~/AdminSurveys.aspx");
            ToggleNavItem(navAdminReports, lnkAdminReports, "~/AdminReports.aspx");
            ToggleNavItem(navAdminLogs, lnkAdminLogs, "~/AdminLogs.aspx");
            ToggleNavItem(navAdminDatabase, lnkAdminDatabase, "~/AdminDatabase.aspx");
            ToggleNavItem(navAdminAds, lnkAdminAds, "~/AdminAds.aspx");
        }

        private void ToggleNavItem(HtmlGenericControl container, HtmlAnchor link, string permissionKey)
        {
            var isVisible = _authorizationSecurity.UserHasPermission(permissionKey);

            if (container != null)
            {
                container.Visible = isVisible;
            }

            if (link != null)
            {
                link.Visible = isVisible;
            }
        }

        private void SetActiveNavigationLink()
        {
            var currentPage = VirtualPathUtility.GetFileName(Request.AppRelativeCurrentExecutionFilePath);

            SetLinkActive(lnkAdminDashboard, currentPage, "AdminDashboard.aspx");
            SetLinkActive(lnkAdminRoles, currentPage, "AdminRoles.aspx");
            SetLinkActive(lnkAdminUsers, currentPage, "AdminUsers.aspx");
            SetLinkActive(lnkOrganizationAdmin, currentPage, "OrganizationAdmin.aspx");
            SetLinkActive(lnkChatbotAdmin, currentPage, "ChatbotAdmin.aspx");
            SetLinkActive(lnkAdminCatalog, currentPage, "AdminCatalog.aspx");
            SetLinkActive(lnkAdminNews, currentPage, "AdminNews.aspx");
            SetLinkActive(lnkAdminBilling, currentPage, "AdminBilling.aspx");
            SetLinkActive(lnkAdminSurveys, currentPage, "AdminSurveys.aspx");
            SetLinkActive(lnkAdminReports, currentPage, "AdminReports.aspx");
            SetLinkActive(lnkAdminLogs, currentPage, "AdminLogs.aspx");
            SetLinkActive(lnkAdminDatabase, currentPage, "AdminDatabase.aspx");
            SetLinkActive(lnkAdminAds, currentPage, "AdminAds.aspx");
        }

        private static void SetLinkActive(HtmlAnchor link, string currentPage, string targetPage)
        {
            if (link == null)
            {
                return;
            }

            var classes = "sidebar-nav-link";
            if (string.Equals(currentPage, targetPage, StringComparison.OrdinalIgnoreCase))
            {
                classes += " active";
            }

            link.Attributes["class"] = classes;
        }
    }
}
