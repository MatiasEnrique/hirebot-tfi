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
    public partial class OrganizationView : BasePage
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
        
        private string OrganizationSlug
        {
            get { return ViewState["OrganizationSlug"]?.ToString() ?? ""; }
            set { ViewState["OrganizationSlug"] = value; }
        }
        
        private string CurrentUserRole
        {
            get { return ViewState["CurrentUserRole"]?.ToString() ?? ""; }
            set { ViewState["CurrentUserRole"] = value; }
        }
        
        private bool IsCurrentUserMember
        {
            get { return ViewState["IsCurrentUserMember"] as bool? ?? false; }
            set { ViewState["IsCurrentUserMember"] = value; }
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
                
                // Get organization identifier from query string (ID or slug)
                if (!TryGetOrganizationIdentifier())
                {
                    ShowAlert(GetResourceString("InvalidOrganizationRequest"), "danger");
                    Response.Redirect("MyOrganizations.aspx");
                    return;
                }
                
                if (!IsPostBack)
                {
                    LoadOrganizationData();
                }
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "OrganizationView Page_Load");
            }
        }
        
        private bool TryGetOrganizationIdentifier()
        {
            try
            {
                // Try to get organization by ID first
                if (int.TryParse(Request.QueryString["id"], out int orgId) && orgId > 0)
                {
                    OrganizationId = orgId;
                    return true;
                }
                
                // Try to get organization by slug
                string slug = Request.QueryString["slug"];
                if (!string.IsNullOrEmpty(slug))
                {
                    OrganizationSlug = slug.Trim();
                    return true;
                }
                
                return false;
            }
            catch (Exception ex)
            {
                LogError(ex, "TryGetOrganizationIdentifier");
                return false;
            }
        }
        
        private void LoadOrganizationData()
        {
            try
            {
                Organization organization = null;
                OrganizationResult orgResult = null;
                
                // Get organization by ID or slug
                if (OrganizationId > 0)
                {
                    orgResult = organizationSecurity.GetOrganizationById(OrganizationId);
                }
                else if (!string.IsNullOrEmpty(OrganizationSlug))
                {
                    orgResult = organizationSecurity.GetOrganizationBySlug(OrganizationSlug);
                }
                
                if (!orgResult.IsSuccessful || orgResult.Organization == null)
                {
                    ShowAlert(orgResult?.ErrorMessage ?? GetResourceString("OrganizationNotFound"), "danger");
                    Response.Redirect("MyOrganizations.aspx");
                    return;
                }
                
                organization = orgResult.Organization;
                OrganizationId = organization.Id; // Ensure we have the ID for future operations
                OrganizationSlug = organization.Slug; // Ensure we have the slug
                
                // Check current user's membership status
                CheckCurrentUserMembership();
                
                // Load organization details
                LoadOrganizationDetails(organization);
                
                // Load organization statistics
                LoadOrganizationStatistics();
                
                // Load members (with privacy considerations)
                LoadOrganizationMembers();
                
                // Configure UI based on membership status
                ConfigureUIForMembershipStatus();
                
                // Update page title
                lblPageTitle.Text = organization.Name;
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "LoadOrganizationData");
            }
        }
        
        private void CheckCurrentUserMembership()
        {
            try
            {
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    IsCurrentUserMember = false;
                    CurrentUserRole = "";
                    return;
                }
                
                // Get organization members
                var memberResult = organizationSecurity.GetOrganizationMembers(OrganizationId);
                if (memberResult.IsSuccessful && memberResult.Data != null)
                {
                    var currentMember = memberResult.Data.FirstOrDefault(m => m.UserId == currentUser.UserId);
                    if (currentMember != null)
                    {
                        IsCurrentUserMember = true;
                        CurrentUserRole = currentMember.Role;
                        lblCurrentUserRole.Text = GetRoleDisplayName(currentMember.Role);
                    }
                    else
                    {
                        IsCurrentUserMember = false;
                        CurrentUserRole = "";
                    }
                }
                else
                {
                    IsCurrentUserMember = false;
                    CurrentUserRole = "";
                }
            }
            catch (Exception ex)
            {
                LogError(ex, "CheckCurrentUserMembership");
                IsCurrentUserMember = false;
                CurrentUserRole = "";
            }
        }
        
        private void LoadOrganizationDetails(Organization organization)
        {
            try
            {
                lblOrganizationName.Text = HttpUtility.HtmlEncode(organization.Name);
                lblOrganizationDescription.Text = !string.IsNullOrEmpty(organization.Description) 
                    ? HttpUtility.HtmlEncode(organization.Description)
                    : GetResourceString("NoDescription");
                lblOrganizationSlug.Text = HttpUtility.HtmlEncode(organization.Slug);
                lblOwnerName.Text = HttpUtility.HtmlEncode(organization.OwnerUsername ?? GetResourceString("Unknown"));
                lblCreatedDate.Text = organization.CreatedDate.ToString("MMMM dd, yyyy");
                lblEstablishedDate.Text = organization.CreatedDate.ToString("yyyy");
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
                    lblMemberCount.Text = stats.TotalMembers.ToString();
                    lblAdminCount.Text = stats.AdminCount.ToString();
                    lblStatTotalMembers.Text = stats.TotalMembers.ToString();
                    lblStatAdmins.Text = stats.AdminCount.ToString();
                }
                else
                {
                    lblMemberCount.Text = "0";
                    lblAdminCount.Text = "0";
                    lblStatTotalMembers.Text = "0";
                    lblStatAdmins.Text = "0";
                }
            }
            catch (Exception ex)
            {
                LogError(ex, "LoadOrganizationStatistics");
                lblMemberCount.Text = "0";
                lblAdminCount.Text = "0";
                lblStatTotalMembers.Text = "0";
                lblStatAdmins.Text = "0";
            }
        }
        
        private void LoadOrganizationMembers()
        {
            try
            {
                var memberResult = organizationSecurity.GetOrganizationMembers(OrganizationId);
                
                if (memberResult.IsSuccessful && memberResult.Data != null && memberResult.Data.Count > 0)
                {
                    // Check if members should be shown publicly or only to members
                    // For now, we'll show members to everyone (can be configured later)
                    bool showMembers = true; // This could be based on organization settings
                    
                    if (showMembers || IsCurrentUserMember)
                    {
                        // Sort members: owner first, then admins, then regular members
                        var sortedMembers = memberResult.Data.OrderBy(m => 
                            m.Role == "owner" ? 0 : 
                            m.Role == "organization_admin" ? 1 : 2)
                            .ThenBy(m => m.Username);
                            
                        rptMembers.DataSource = sortedMembers;
                        rptMembers.DataBind();
                        
                        pnlMembersPublic.Visible = true;
                        pnlMembersHidden.Visible = false;
                        pnlNoMembers.Visible = false;
                    }
                    else
                    {
                        // Hide member list from non-members
                        pnlMembersPublic.Visible = false;
                        pnlMembersHidden.Visible = true;
                        pnlNoMembers.Visible = false;
                    }
                }
                else
                {
                    // No members found
                    pnlMembersPublic.Visible = false;
                    pnlMembersHidden.Visible = false;
                    pnlNoMembers.Visible = true;
                }
            }
            catch (Exception ex)
            {
                LogError(ex, "LoadOrganizationMembers");
                pnlMembersPublic.Visible = false;
                pnlMembersHidden.Visible = false;
                pnlNoMembers.Visible = true;
            }
        }
        
        private void ConfigureUIForMembershipStatus()
        {
            try
            {
                if (IsCurrentUserMember)
                {
                    pnlNotMember.Visible = false;
                    pnlIsMember.Visible = true;
                    
                    // Configure management button based on role
                    btnManageOrganization.Visible = (CurrentUserRole == "owner" || CurrentUserRole == "organization_admin");
                    btnLeaveOrganization.Visible = (CurrentUserRole != "owner"); // Owner cannot leave their own organization
                }
                else
                {
                    pnlNotMember.Visible = true;
                    pnlIsMember.Visible = false;
                }
            }
            catch (Exception ex)
            {
                LogError(ex, "ConfigureUIForMembershipStatus");
            }
        }
        
        protected void btnJoinOrganization_Click(object sender, EventArgs e)
        {
            try
            {
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    Response.Redirect("SignIn.aspx");
                    return;
                }
                
                // Add user as a regular member
                var result = organizationSecurity.AddOrganizationMember(OrganizationId, currentUser.UserId, "member");
                
                if (result.IsSuccessful)
                {
                    ShowAlert(GetResourceString("JoinedOrganizationSuccess"), "success");
                    LoadOrganizationData(); // Reload to update UI
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
                LogError(ex, "btnJoinOrganization_Click");
            }
        }
        
        protected void btnLeaveOrganization_Click(object sender, EventArgs e)
        {
            try
            {
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser == null)
                {
                    Response.Redirect("SignIn.aspx");
                    return;
                }
                
                // Prevent owner from leaving their own organization
                if (CurrentUserRole == "owner")
                {
                    ShowAlert(GetResourceString("OwnerCannotLeave"), "warning");
                    upMain.Update();
                    return;
                }
                
                var result = organizationSecurity.RemoveOrganizationMember(OrganizationId, currentUser.UserId);
                
                if (result.IsSuccessful)
                {
                    ShowAlert(GetResourceString("LeftOrganizationSuccess"), "success");
                    LoadOrganizationData(); // Reload to update UI
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
                LogError(ex, "btnLeaveOrganization_Click");
            }
        }
        
        protected void btnManageOrganization_Click(object sender, EventArgs e)
        {
            try
            {
                // Redirect to organization dashboard for management
                Response.Redirect($"OrganizationDashboard.aspx?id={OrganizationId}");
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "btnManageOrganization_Click");
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
                System.Diagnostics.Debug.WriteLine($"Error in OrganizationView.{methodName}: {ex.Message}");
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