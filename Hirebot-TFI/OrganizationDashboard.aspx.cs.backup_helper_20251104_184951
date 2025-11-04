using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ABSTRACTIONS;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class OrganizationDashboard : BasePage
    {
        private UserSecurity userSecurity;
        private AdminSecurity adminSecurity;
        private OrganizationSecurity organizationSecurity;
        private int OrganizationId
        {
            get
            {
                if (ViewState["OrganizationId"] != null)
                    return (int)ViewState["OrganizationId"];
                return 0;
            }
            set { ViewState["OrganizationId"] = value; }
        }
        
        private string CurrentUserRole
        {
            get { return ViewState["CurrentUserRole"]?.ToString() ?? ""; }
            set { ViewState["CurrentUserRole"] = value; }
        }
        
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                userSecurity = new UserSecurity();
                adminSecurity = new AdminSecurity();
                organizationSecurity = new OrganizationSecurity();
                
                // Check if user is authenticated
                if (!userSecurity.IsUserAuthenticated())
                {
                    Response.Redirect("SignIn.aspx");
                    return;
                }
                
                // Get organization ID from query string
                if (!int.TryParse(Request.QueryString["id"], out int orgId) || orgId <= 0)
                {
                    ShowAlert(GetResourceString("InvalidOrganizationId"), "danger");
                    Response.Redirect("MyOrganizations.aspx");
                    return;
                }
                
                OrganizationId = orgId;
                
                if (!IsPostBack)
                {
                    LoadOrganizationData();
                }
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "OrganizationDashboard Page_Load");
            }
        }
        
        private void LoadOrganizationData()
        {
            try
            {
                // Get organization details
                var orgResult = organizationSecurity.GetOrganizationById(OrganizationId);
                
                if (!orgResult.IsSuccessful || orgResult.Organization == null)
                {
                    ShowAlert(orgResult.ErrorMessage ?? GetResourceString("OrganizationNotFound"), "danger");
                    Response.Redirect("MyOrganizations.aspx");
                    return;
                }
                
                var organization = orgResult.Organization;
                
                // Check if user has access to this organization
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    Response.Redirect("SignIn.aspx");
                    return;
                }
                
                // Verify user is a member of this organization
                var memberResult = organizationSecurity.GetOrganizationMembers(OrganizationId);
                if (!memberResult.IsSuccessful || memberResult.Data == null)
                {
                    ShowAlert(GetResourceString("OrganizationAccessDenied"), "danger");
                    Response.Redirect("MyOrganizations.aspx");
                    return;
                }
                
                var currentMember = memberResult.Data.FirstOrDefault(m => m.UserId == currentUser.UserId);
                if (currentMember == null)
                {
                    ShowAlert(GetResourceString("OrganizationAccessDenied"), "danger");
                    Response.Redirect("MyOrganizations.aspx");
                    return;
                }
                
                CurrentUserRole = currentMember.Role;
                
                // Load organization details
                LoadOrganizationDetails(organization);
                
                // Load organization statistics
                LoadOrganizationStatistics();
                
                // Load members
                LoadOrganizationMembers(memberResult.Data);
                
                // Load available users for adding members
                LoadAvailableUsers();
                
                // Configure UI based on user role
                ConfigureUIForUserRole();
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "LoadOrganizationData");
            }
        }
        
        private void LoadOrganizationDetails(Organization organization)
        {
            try
            {
                lblOrganizationName.Text = organization.Name;
                lblOrganizationDescription.Text = !string.IsNullOrEmpty(organization.Description) 
                    ? organization.Description 
                    : GetResourceString("NoDescription");
                lblOrganizationSlug.Text = organization.Slug;
                lblCreatedDate.Text = organization.CreatedDate.ToString("MMM yyyy");
                lblStatus.Text = organization.IsActive ? GetResourceString("Active") : GetResourceString("Inactive");
                
                // Set status icon
                if (organization.IsActive)
                {
                    statusIcon.Attributes["class"] = "fas fa-circle text-success";
                }
                else
                {
                    statusIcon.Attributes["class"] = "fas fa-circle text-danger";
                }
                
                // Show role badges
                if (CurrentUserRole == "owner")
                {
                    badgeOwner.Visible = true;
                    badgeAdmin.Visible = false;
                }
                else if (CurrentUserRole == "organization_admin")
                {
                    badgeOwner.Visible = false;
                    badgeAdmin.Visible = true;
                }
                
                // Populate settings modal
                txtSettingsName.Text = organization.Name;
                txtSettingsSlug.Text = organization.Slug;
                txtSettingsDescription.Text = organization.Description ?? "";
                chkSettingsActive.Checked = organization.IsActive;
                txtOwnerDisplay.Text = organization.OwnerUsername ?? "";
            }
            catch (Exception ex)
            {
                LogError(ex, "LoadOrganizationDetails");
            }
        }
        
        private void LoadOrganizationStatistics()
        {
            try
            {
                var statsResult = organizationSecurity.GetOrganizationStats(OrganizationId);
                
                if (statsResult.IsSuccessful && statsResult.Data != null)
                {
                    var stats = statsResult.Data;
                    lblTotalMembers.Text = stats.TotalMembers.ToString();
                    lblAdminCount.Text = stats.AdminCount.ToString();
                }
                else
                {
                    lblTotalMembers.Text = "0";
                    lblAdminCount.Text = "0";
                }
            }
            catch (Exception ex)
            {
                LogError(ex, "LoadOrganizationStatistics");
                lblTotalMembers.Text = "0";
                lblAdminCount.Text = "0";
            }
        }
        
        private void LoadOrganizationMembers(List<OrganizationMember> members)
        {
            try
            {
                if (members != null && members.Count > 0)
                {
                    rptMembers.DataSource = members.OrderBy(m => m.Role == "owner" ? 0 : 
                                                                m.Role == "organization_admin" ? 1 : 2)
                                                   .ThenBy(m => m.Username);
                    rptMembers.DataBind();
                    
                    rptMembers.Visible = true;
                    pnlNoMembers.Visible = false;
                }
                else
                {
                    rptMembers.Visible = false;
                    pnlNoMembers.Visible = true;
                }
            }
            catch (Exception ex)
            {
                LogError(ex, "LoadOrganizationMembers");
                rptMembers.Visible = false;
                pnlNoMembers.Visible = true;
            }
        }
        
        private void LoadAvailableUsers()
        {
            try
            {
                ddlAddUser.Items.Clear();
                ddlAddUser.Items.Add(new ListItem(GetResourceString("SelectUser"), ""));
                
                // In a complete implementation, you would load users from UserSecurity
                // excluding current organization members
                ddlAddUser.Items.Add(new ListItem("user1", "2"));
                ddlAddUser.Items.Add(new ListItem("user2", "3"));
                ddlAddUser.Items.Add(new ListItem("user3", "4"));
            }
            catch (Exception ex)
            {
                LogError(ex, "LoadAvailableUsers");
            }
        }
        
        private void ConfigureUIForUserRole()
        {
            try
            {
                bool canManageMembers = CurrentUserRole == "owner" || CurrentUserRole == "organization_admin";
                bool canManageSettings = CurrentUserRole == "owner" || CurrentUserRole == "organization_admin";
                
                // Show/hide member management actions
                memberActions.Visible = canManageMembers;
                
                // Show/hide settings card
                settingsCard.Visible = canManageSettings;
            }
            catch (Exception ex)
            {
                LogError(ex, "ConfigureUIForUserRole");
            }
        }
        
        protected void rptMembers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                int userId = Convert.ToInt32(e.CommandArgument);
                
                switch (e.CommandName)
                {
                    case "UpdateRole":
                        UpdateMemberRole(userId, e.Item);
                        break;
                        
                    case "RemoveMember":
                        RemoveMember(userId);
                        break;
                }
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "rptMembers_ItemCommand");
            }
        }
        
        private void UpdateMemberRole(int userId, RepeaterItem item)
        {
            try
            {
                var ddlRole = item.FindControl("ddlMemberRole") as DropDownList;
                if (ddlRole == null || string.IsNullOrEmpty(ddlRole.SelectedValue))
                {
                    ShowAlert(GetResourceString("RoleRequired"), "danger");
                    return;
                }
                
                string newRole = ddlRole.SelectedValue;
                
                var result = organizationSecurity.UpdateMemberRole(OrganizationId, userId, newRole);
                
                if (result.IsSuccessful)
                {
                    ShowAlert(GetResourceString("MemberRoleUpdatedSuccess"), "success");
                    LoadOrganizationData(); // Reload to refresh the data
                }
                else
                {
                    ShowAlert(result.ErrorMessage, "danger");
                }
                
                upMain.Update();
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "UpdateMemberRole");
            }
        }
        
        private void RemoveMember(int userId)
        {
            try
            {
                var result = organizationSecurity.RemoveOrganizationMember(OrganizationId, userId);
                
                if (result.IsSuccessful)
                {
                    ShowAlert(GetResourceString("MemberRemovedSuccess"), "success");
                    LoadOrganizationData(); // Reload to refresh the data
                }
                else
                {
                    ShowAlert(result.ErrorMessage, "danger");
                }
                
                upMain.Update();
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "RemoveMember");
            }
        }
        
        protected void btnAddMember_Click(object sender, EventArgs e)
        {
            try
            {
                if (!Page.IsValid)
                    return;
                
                if (!int.TryParse(ddlAddUser.SelectedValue, out int userId))
                {
                    ShowAlert(GetResourceString("UserRequired"), "danger");
                    return;
                }
                
                string role = ddlAddRole.SelectedValue;
                if (string.IsNullOrEmpty(role))
                {
                    ShowAlert(GetResourceString("RoleRequired"), "danger");
                    return;
                }
                
                var result = organizationSecurity.AddOrganizationMember(OrganizationId, userId, role);
                
                if (result.IsSuccessful)
                {
                    ShowAlert(GetResourceString("MemberAddedSuccess"), "success");
                    
                    // Clear form
                    ddlAddUser.SelectedIndex = 0;
                    ddlAddRole.SelectedIndex = 0;
                    
                    // Hide modal and reload data
                    ScriptManager.RegisterStartupScript(this, GetType(), "hideModal", "hideAddMemberModal();", true);
                    LoadOrganizationData();
                }
                else
                {
                    ShowAlert(result.ErrorMessage, "danger");
                }
                
                upMain.Update();
                upAddMember.Update();
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "btnAddMember_Click");
            }
        }
        
        protected void btnSaveSettings_Click(object sender, EventArgs e)
        {
            try
            {
                if (!Page.IsValid)
                    return;
                
                string name = txtSettingsName.Text.Trim();
                string slug = txtSettingsSlug.Text.Trim();
                string description = txtSettingsDescription.Text.Trim();
                
                var result = organizationSecurity.UpdateOrganization(OrganizationId, name, slug, description);
                
                if (result.IsSuccessful)
                {
                    ShowAlert(GetResourceString("OrganizationUpdatedSuccess"), "success");
                    
                    // Hide modal and reload data
                    ScriptManager.RegisterStartupScript(this, GetType(), "hideSettingsModal", "hideSettingsModal();", true);
                    LoadOrganizationData();
                }
                else
                {
                    ShowAlert(result.ErrorMessage, "danger");
                }
                
                upMain.Update();
                upSettings.Update();
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "btnSaveSettings_Click");
            }
        }
        
        #region Helper Methods
        
        
        protected string GetUserInitials(string username)
        {
            if (string.IsNullOrEmpty(username))
                return "?";
            
            return username.Length >= 2 ? username.Substring(0, 2).ToUpperInvariant() : username.ToUpperInvariant();
        }
        
        protected string GetRoleDisplayName(string role)
        {
            if (string.IsNullOrEmpty(role))
                return "";
            
            switch (role.ToLowerInvariant())
            {
                case "owner":
                    return GetResourceString("Owner");
                case "organization_admin":
                    return GetResourceString("OrganizationAdmin");
                case "member":
                    return GetResourceString("Member");
                default:
                    return role;
            }
        }
        
        protected bool CanManageMember(string memberRole, object memberUserId)
        {
            try
            {
                // Owner cannot be managed
                if (memberRole?.ToLowerInvariant() == "owner")
                    return false;
                
                // Current user must be owner or admin to manage members
                if (CurrentUserRole != "owner" && CurrentUserRole != "organization_admin")
                    return false;
                
                // Cannot manage yourself
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser != null && memberUserId != null && currentUser.UserId == Convert.ToInt32(memberUserId))
                    return false;
                
                return true;
            }
            catch
            {
                return false;
            }
        }
        
        protected bool CanUpdateRole(string memberRole)
        {
            return CanManageMember(memberRole, null) && memberRole?.ToLowerInvariant() != "owner";
        }
        
        protected bool CanRemoveMember(string memberRole)
        {
            return CanManageMember(memberRole, null) && memberRole?.ToLowerInvariant() != "owner";
        }
        
        private string GetResourceString(string key)
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
        
        private void ShowAlert(string message, string type)
        {
            try
            {
                pnlAlert.Visible = true;
                lblAlert.Text = message;
                
                pnlAlert.CssClass = $"alert alert-{type} alert-dismissible fade show";
                
                // Auto-hide success messages after 5 seconds
                if (type == "success")
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "hideAlert", 
                        "setTimeout(function() { var alert = document.querySelector('.alert-success'); if (alert) alert.style.display = 'none'; }, 5000);", true);
                }
            }
            catch (Exception ex)
            {
                LogError(ex, "ShowAlert");
            }
        }
        
        private void LogError(Exception ex, string methodName)
        {
            try
            {
                // In a complete implementation, this would use LogService
                System.Diagnostics.Debug.WriteLine($"Error in OrganizationDashboard.{methodName}: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
            }
            catch
            {
                // Ignore logging errors
            }
        }
        
        #endregion
    }
}