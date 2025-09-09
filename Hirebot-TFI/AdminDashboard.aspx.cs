using System;
using System.Web;
using System.Web.UI;
using SECURITY;
using BLL;

namespace Hirebot_TFI
{
    public partial class AdminDashboard : BasePage
    {
        private UserSecurity userSecurity;
        private AdminSecurity adminSecurity;
        private UserBLL userBLL;
        private ProductBLL productBLL;
        private LogBLL logBLL;

        protected void Page_Load(object sender, EventArgs e)
        {
            userSecurity = new UserSecurity();
            adminSecurity = new AdminSecurity();
            userBLL = new UserBLL();
            productBLL = new ProductBLL();
            logBLL = new LogBLL();

            if (!userSecurity.IsUserAuthenticated())
            {
                Response.Redirect("~/SignIn.aspx");
                return;
            }

            if (!adminSecurity.IsUserAdmin())
            {
                Response.Redirect("~/Dashboard.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadDashboardStats();
            }
        }

        private void LoadDashboardStats()
        {
            try
            {
                // Load total users
                var users = userBLL.GetAllUsers();
                lblTotalUsers.Text = users?.Count.ToString() ?? "0";

                // Load total products
                var products = productBLL.GetAllProducts();
                lblTotalProducts.Text = products?.Count.ToString() ?? "0";

                // Load total logs
                var logs = logBLL.GetAllLogs();
                lblTotalLogs.Text = logs?.Count.ToString() ?? "0";

                // Load last login (current user's login time)
                lblLastLogin.Text = DateTime.Now.ToString("dd/MM/yyyy HH:mm");
            }
            catch (Exception ex)
            {
                // Fallback values in case of error
                lblTotalUsers.Text = "N/A";
                lblTotalProducts.Text = "N/A";
                lblTotalLogs.Text = "N/A";
                lblLastLogin.Text = "N/A";
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
                Response.Redirect("~/Default.aspx");
            }
        }
    }
}