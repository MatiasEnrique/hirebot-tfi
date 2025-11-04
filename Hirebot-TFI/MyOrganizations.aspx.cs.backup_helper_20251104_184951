using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ABSTRACTIONS;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class MyOrganizations : BasePage
    {
        private OrganizationSecurity organizationSecurity;
        
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                organizationSecurity = new OrganizationSecurity();
                
                // Check if user is authenticated
                if (!IsUserAuthenticated())
                {
                    Response.Redirect("SignIn.aspx");
                    return;
                }
                
                if (!IsPostBack)
                {
                    InitializePage();
                    LoadUserOrganizations();
                }
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "MyOrganizations Page_Load");
            }
        }
        
        private void InitializePage()
        {
            try
            {
                // Show admin navigation if user is admin
                if (IsCurrentUserAdmin())
                {
                    pnlAdminNavigation.Visible = true;
                    pnlAdminActions.Visible = true;
                }
                
                // Initialize alert panel as hidden
                pnlAlert.Visible = false;
            }
            catch (Exception ex)
            {
                LogError(ex, "MyOrganizations InitializePage");
                throw;
            }
        }
        
        private void LoadUserOrganizations()
        {
            try
            {
                // Get organizations where user is owner using existing method
                var ownedOrganizationsResult = organizationSecurity.GetMyOrganizations();
                
                // Get all organization memberships
                var membershipResult = organizationSecurity.GetMyOrganizationMemberships();
                
                // Process results and categorize by role
                ProcessOrganizationData(ownedOrganizationsResult, membershipResult);
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("ErrorLoadingData"), "danger");
                LogError(ex, "MyOrganizations LoadUserOrganizations");
            }
        }
        
        private void ProcessOrganizationData(OrganizationListResult ownedResult, OrganizationMemberListResult membershipResult)
        {
            try
            {
                var ownedOrganizations = new DataTable();
                var managedOrganizations = new DataTable();
                var memberOrganizations = new DataTable();
                
                // Create DataTable structure
                CreateOrganizationDataTableStructure(ownedOrganizations);
                CreateOrganizationDataTableStructure(managedOrganizations);
                CreateOrganizationDataTableStructure(memberOrganizations);
                
                // Process owned organizations
                if (ownedResult.IsSuccessful && ownedResult.Data != null)
                {
                    foreach (var org in ownedResult.Data)
                    {
                        var row = ownedOrganizations.NewRow();
                        PopulateOrganizationRow(row, org, "Owner");
                        ownedOrganizations.Rows.Add(row);
                    }
                }
                
                // Process memberships and categorize by role
                if (membershipResult.IsSuccessful && membershipResult.Data != null)
                {
                    foreach (var membership in membershipResult.Data)
                    {
                        if (membership.Role == "organization_admin")
                        {
                            var row = managedOrganizations.NewRow();
                            PopulateOrganizationMembershipRow(row, membership);
                            managedOrganizations.Rows.Add(row);
                        }
                        else if (membership.Role == "member")
                        {
                            var row = memberOrganizations.NewRow();
                            PopulateOrganizationMembershipRow(row, membership);
                            memberOrganizations.Rows.Add(row);
                        }
                    }
                }
                
                // Update statistics
                lblOwnedCount.Text = ownedOrganizations.Rows.Count.ToString();
                lblManagedCount.Text = managedOrganizations.Rows.Count.ToString();
                lblMemberCount.Text = memberOrganizations.Rows.Count.ToString();
                
                // Bind data to repeaters
                BindOwnedOrganizations(ownedOrganizations);
                BindManagedOrganizations(managedOrganizations);
                BindMemberOrganizations(memberOrganizations);
                
                // Show/hide sections based on data
                ShowAppropriateSection(ownedOrganizations, managedOrganizations, memberOrganizations);
            }
            catch (Exception ex)
            {
                LogError(ex, "MyOrganizations ProcessOrganizationData");
                throw;
            }
        }
        
        private void CreateOrganizationDataTableStructure(DataTable dt)
        {
            dt.Columns.Add("Id", typeof(int));
            dt.Columns.Add("Name", typeof(string));
            dt.Columns.Add("Slug", typeof(string));
            dt.Columns.Add("Description", typeof(string));
            dt.Columns.Add("MemberCount", typeof(int));
            dt.Columns.Add("CreatedDate", typeof(DateTime));
            dt.Columns.Add("IsActive", typeof(bool));
            dt.Columns.Add("OwnerUsername", typeof(string));
            dt.Columns.Add("JoinedDate", typeof(DateTime));
            dt.Columns.Add("Role", typeof(string));
        }
        
        private void PopulateOrganizationRow(DataRow row, Organization org, string role)
        {
            row["Id"] = org.Id;
            row["Name"] = org.Name ?? "";
            row["Slug"] = org.Slug ?? "";
            row["Description"] = org.Description ?? "";
            row["MemberCount"] = 0; // Will be populated if available
            row["CreatedDate"] = org.CreatedDate;
            row["IsActive"] = org.IsActive;
            row["OwnerUsername"] = ""; // Will be populated if available
            row["JoinedDate"] = org.CreatedDate;
            row["Role"] = role;
        }
        
        private void PopulateOrganizationMembershipRow(DataRow row, OrganizationMember membership)
        {
            row["Id"] = membership.OrganizationId;
            row["Name"] = membership.OrganizationName ?? "";
            row["Slug"] = membership.OrganizationSlug ?? "";
            row["Description"] = membership.OrganizationDescription ?? "";
            row["MemberCount"] = 0; // Will be populated if available
            row["CreatedDate"] = membership.JoinedDate;
            row["IsActive"] = true; // Assume active if user is member
            row["OwnerUsername"] = membership.OwnerUsername ?? "";
            row["JoinedDate"] = membership.JoinedDate;
            row["Role"] = membership.Role;
        }
        
        private void BindOwnedOrganizations(DataTable organizations)
        {
            try
            {
                if (organizations != null && organizations.Rows.Count > 0)
                {
                    rptOwnedOrganizations.DataSource = organizations;
                    rptOwnedOrganizations.DataBind();
                    pnlOwnedOrganizations.Visible = true;
                }
                else
                {
                    pnlOwnedOrganizations.Visible = false;
                }
            }
            catch (Exception ex)
            {
                LogError(ex, "MyOrganizations BindOwnedOrganizations");
                throw;
            }
        }
        
        private void BindManagedOrganizations(DataTable organizations)
        {
            try
            {
                if (organizations != null && organizations.Rows.Count > 0)
                {
                    rptManagedOrganizations.DataSource = organizations;
                    rptManagedOrganizations.DataBind();
                    pnlManagedOrganizations.Visible = true;
                }
                else
                {
                    pnlManagedOrganizations.Visible = false;
                }
            }
            catch (Exception ex)
            {
                LogError(ex, "MyOrganizations BindManagedOrganizations");
                throw;
            }
        }
        
        private void BindMemberOrganizations(DataTable organizations)
        {
            try
            {
                if (organizations != null && organizations.Rows.Count > 0)
                {
                    rptMemberOrganizations.DataSource = organizations;
                    rptMemberOrganizations.DataBind();
                    pnlMemberOrganizations.Visible = true;
                }
                else
                {
                    pnlMemberOrganizations.Visible = false;
                }
            }
            catch (Exception ex)
            {
                LogError(ex, "MyOrganizations BindMemberOrganizations");
                throw;
            }
        }
        
        private void ShowAppropriateSection(DataTable ownedOrgs, DataTable managedOrgs, DataTable memberOrgs)
        {
            try
            {
                bool hasAnyOrganizations = (ownedOrgs != null && ownedOrgs.Rows.Count > 0) ||
                                         (managedOrgs != null && managedOrgs.Rows.Count > 0) ||
                                         (memberOrgs != null && memberOrgs.Rows.Count > 0);
                
                if (!hasAnyOrganizations)
                {
                    // Show no organizations message
                    pnlNoOrganizations.Visible = true;
                    pnlOwnedOrganizations.Visible = false;
                    pnlManagedOrganizations.Visible = false;
                    pnlMemberOrganizations.Visible = false;
                }
                else
                {
                    pnlNoOrganizations.Visible = false;
                }
            }
            catch (Exception ex)
            {
                LogError(ex, "MyOrganizations ShowAppropriateSection");
                throw;
            }
        }
        
        protected void rptOrganizations_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                int organizationId = Convert.ToInt32(e.CommandArgument);
                string command = e.CommandName;
                
                switch (command)
                {
                    case "ViewDetails":
                        RedirectToOrganizationView(organizationId);
                        break;
                        
                    case "Manage":
                        RedirectToOrganizationDashboard(organizationId);
                        break;
                        
                    case "ManageMembers":
                        RedirectToOrganizationDashboard(organizationId, "members");
                        break;
                        
                    default:
                        LogError(new ArgumentException($"Unknown command: {command}"), 
                               "MyOrganizations rptOrganizations_ItemCommand");
                        break;
                }
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "MyOrganizations rptOrganizations_ItemCommand");
            }
        }
        
        protected void btnCreateOrganization_Click(object sender, EventArgs e)
        {
            try
            {
                // Redirect to organization admin page for creating new organization
                if (IsCurrentUserAdmin())
                {
                    Response.Redirect("OrganizationAdmin.aspx");
                }
                else
                {
                    // For regular users, we might implement a different flow
                    // or redirect to a request form
                    ShowAlert(GetResourceString("ContactAdminToCreateOrganization"), "info");
                }
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "MyOrganizations btnCreateOrganization_Click");
            }
        }
        
        protected void btnAdminPanel_Click(object sender, EventArgs e)
        {
            try
            {
                if (IsCurrentUserAdmin())
                {
                    Response.Redirect("OrganizationAdmin.aspx");
                }
                else
                {
                    ShowAlert(GetResourceString("InsufficientPermissions"), "danger");
                }
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "MyOrganizations btnAdminPanel_Click");
            }
        }
        
        private void RedirectToOrganizationView(int organizationId)
        {
            try
            {
                // Since this method is called from user's organization list,
                // we can assume they have access to view it
                Response.Redirect($"OrganizationView.aspx?id={organizationId}");
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "MyOrganizations RedirectToOrganizationView");
            }
        }
        
        private void RedirectToOrganizationDashboard(int organizationId, string section = null)
        {
            try
            {
                // Since this method is called from user's owned/managed organizations,
                // we can assume they have management access
                string url = $"OrganizationDashboard.aspx?id={organizationId}";
                if (!string.IsNullOrEmpty(section))
                {
                    url += $"&section={section}";
                }
                Response.Redirect(url);
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                LogError(ex, "MyOrganizations RedirectToOrganizationDashboard");
            }
        }
        
        private void ShowAlert(string message, string type)
        {
            try
            {
                lblAlert.Text = message;
                pnlAlert.CssClass = $"alert alert-{type} alert-dismissible fade show";
                pnlAlert.Visible = true;
                upMain.Update();
                
                // Log the alert for debugging
                System.Diagnostics.Debug.WriteLine($"Alert shown - Type: {type}, Message: {message}");
            }
            catch (Exception ex)
            {
                LogError(ex, "MyOrganizations ShowAlert");
            }
        }
        
        private void LogError(Exception ex, string method)
        {
            try
            {
                // Use the same logging pattern as other pages
                string errorMessage = $"Error in {method}: {ex.Message}";
                if (ex.InnerException != null)
                {
                    errorMessage += $" Inner Exception: {ex.InnerException.Message}";
                }
                
                System.Diagnostics.Debug.WriteLine(errorMessage);
                
                // Here you might want to log to database or file system
                // depending on your application's logging strategy
            }
            catch
            {
                // Fail silently for logging errors
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
                return key; // Return the key if resource lookup fails
            }
        }
        
        private int GetCurrentUserId()
        {
            try
            {
                // Get current user ID from session or authentication
                if (Session["UserId"] != null)
                {
                    return Convert.ToInt32(Session["UserId"]);
                }
                
                // If session doesn't contain user ID, redirect to login
                Response.Redirect("SignIn.aspx");
                return 0;
            }
            catch (Exception ex)
            {
                LogError(ex, "MyOrganizations GetCurrentUserId");
                Response.Redirect("SignIn.aspx");
                return 0;
            }
        }
        
        private bool IsUserAuthenticated()
        {
            try
            {
                return Session["UserId"] != null && Session["Username"] != null;
            }
            catch
            {
                return false;
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
    }
}