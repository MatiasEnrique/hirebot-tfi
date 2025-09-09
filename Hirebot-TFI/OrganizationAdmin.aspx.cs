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
    public partial class OrganizationAdmin : BasePage
    {
        private OrganizationSecurity organizationSecurity;
        private UserSecurity userSecurity;
        private AdminSecurity adminSecurity;
        private const int DEFAULT_PAGE_SIZE = 10;
        
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                organizationSecurity = new OrganizationSecurity();
                userSecurity = new UserSecurity();
                adminSecurity = new AdminSecurity();
                
                // Check if user is authenticated and is admin
                if (!userSecurity.IsUserAuthenticated())
                {
                    Response.Redirect("SignIn.aspx");
                    return;
                }
                
                if (!adminSecurity.IsUserAdmin())
                {
                    ShowAlert(GetResourceString("InsufficientPermissions"), "danger");
                    Response.Redirect("Dashboard.aspx");
                    return;
                }
                
                if (!IsPostBack)
                {
                    InitializePage();
                }
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
            }
        }
        
        private void InitializePage()
        {
            try
            {
                // Set default values
                ViewState["CurrentPage"] = 1;
                ViewState["PageSize"] = DEFAULT_PAGE_SIZE;
                ViewState["SortColumn"] = "Name";
                ViewState["SortDirection"] = "ASC";
                ViewState["SearchTerm"] = "";
                
                // Set dropdown default values
                ddlPageSize.SelectedValue = DEFAULT_PAGE_SIZE.ToString();
                ddlSortBy.SelectedValue = "Name";
                
                LoadOwners();
                LoadOrganizations();
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
            }
        }
        
        private void LoadOwners()
        {
            try
            {
                ddlModalOwner.Items.Clear();
                ddlModalOwner.Items.Add(new ListItem(GetResourceString("SelectOwner"), ""));
                
                // Load real users from the database using UserBLL
                var userBLL = new BLL.UserBLL();
                var users = userBLL.GetAllUsers();
                
                if (users != null && users.Count > 0)
                {
                    foreach (var user in users)
                    {
                        // Display format: "FirstName LastName (Username)" - Value: UserId
                        string displayText = !string.IsNullOrWhiteSpace(user.FirstName) && !string.IsNullOrWhiteSpace(user.LastName)
                            ? $"{user.FirstName} {user.LastName} ({user.Username})"
                            : user.Username;
                            
                        ddlModalOwner.Items.Add(new ListItem(displayText, user.UserId.ToString()));
                    }
                }
                else
                {
                    // Fallback message if no users are found
                    ddlModalOwner.Items.Add(new ListItem(GetResourceString("NoUsersAvailable"), ""));
                }
            }
            catch (Exception ex)
            {
                // Add error item to dropdown to indicate the issue
                ddlModalOwner.Items.Add(new ListItem(GetResourceString("ErrorLoadingUsers"), ""));
            }
        }
        
        private void LoadOrganizations()
        {
            try
            {
                // Safe ViewState retrieval with defaults
                int currentPage = ViewState["CurrentPage"] != null ? Convert.ToInt32(ViewState["CurrentPage"]) : 1;
                int pageSize = ViewState["PageSize"] != null ? Convert.ToInt32(ViewState["PageSize"]) : DEFAULT_PAGE_SIZE;
                string sortColumn = ViewState["SortColumn"]?.ToString() ?? "Name";
                string sortDirection = ViewState["SortDirection"]?.ToString() ?? "ASC";
                string searchTerm = ViewState["SearchTerm"]?.ToString() ?? "";
                
                var result = organizationSecurity.GetAllOrganizations(currentPage, pageSize, sortColumn, sortDirection, searchTerm);
                
                if (result.IsSuccessful)
                {
                    if (result.Data != null && result.Data.Count > 0)
                    {
                        rptOrganizations.DataSource = result.Data;
                        rptOrganizations.DataBind();
                        
                        pnlNoOrganizations.Visible = false;
                        rptOrganizations.Visible = true;
                        
                        // Setup pagination
                        SetupPagination(result.Data);
                    }
                    else
                    {
                        rptOrganizations.Visible = false;
                        pnlNoOrganizations.Visible = true;
                        divPagination.Visible = false;
                    }
                }
                else
                {
                    ShowAlert(result.ErrorMessage, "danger");
                    rptOrganizations.Visible = false;
                    pnlNoOrganizations.Visible = true;
                    divPagination.Visible = false;
                }
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
                rptOrganizations.Visible = false;
                pnlNoOrganizations.Visible = true;
                divPagination.Visible = false;
            }
        }
        
        private void SetupPagination(List<Organization> organizations)
        {
            try
            {
                if (organizations == null || organizations.Count == 0)
                {
                    divPagination.Visible = false;
                    return;
                }
                
                var firstOrg = organizations.FirstOrDefault();
                if (firstOrg?.TotalPages == null || firstOrg.TotalPages <= 1)
                {
                    divPagination.Visible = false;
                    return;
                }
                
                int totalPages = firstOrg.TotalPages.Value;
                int currentPage = ViewState["CurrentPage"] != null ? Convert.ToInt32(ViewState["CurrentPage"]) : 1;
                
                divPagination.Visible = true;
                
                // Setup Previous button
                liPrevious.Visible = currentPage > 1;
                liNext.Visible = currentPage < totalPages;
                
                // Setup page numbers
                var pageNumbers = new List<object>();
                int startPage = Math.Max(1, currentPage - 2);
                int endPage = Math.Min(totalPages, currentPage + 2);
                
                for (int i = startPage; i <= endPage; i++)
                {
                    pageNumbers.Add(new { PageNumber = i });
                }
                
                rptPagination.DataSource = pageNumbers;
                rptPagination.DataBind();
            }
            catch (Exception ex)
            {
                divPagination.Visible = false;
            }
        }
        
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            try
            {
                ViewState["SearchTerm"] = txtSearch.Text.Trim();
                ViewState["CurrentPage"] = 1;
                
                LoadOrganizations();
                upMain.Update();
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
            }
        }
        
        protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                if (int.TryParse(ddlPageSize.SelectedValue, out int pageSize))
                {
                    ViewState["PageSize"] = pageSize;
                    ViewState["CurrentPage"] = 1;
                    
                    LoadOrganizations();
                    upMain.Update();
                }
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
            }
        }
        
        protected void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                ViewState["SortColumn"] = ddlSortBy.SelectedValue;
                ViewState["CurrentPage"] = 1;
                
                LoadOrganizations();
                upMain.Update();
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
            }
        }
        
        protected void btnCreateNew_Click(object sender, EventArgs e)
        {
            try
            {
                ClearModalFields();
                lblModalTitle.Text = GetResourceString("CreateOrganization");
                hfOrganizationId.Value = "";
                
                upModal.Update();
                
                // Show modal using client script
                ScriptManager.RegisterStartupScript(this, GetType(), "showModal", "showOrganizationModal();", true);
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
            }
        }
        
        protected void rptOrganizations_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                int organizationId = Convert.ToInt32(e.CommandArgument);
                
                switch (e.CommandName)
                {
                    case "View":
                        Response.Redirect($"OrganizationView.aspx?id={organizationId}");
                        break;
                        
                    case "Edit":
                        LoadOrganizationForEdit(organizationId);
                        break;
                        
                    case "Delete":
                        DeleteOrganization(organizationId);
                        break;
                }
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
            }
        }
        
        private void LoadOrganizationForEdit(int organizationId)
        {
            try
            {
                var result = organizationSecurity.GetOrganizationById(organizationId);
                
                if (result.IsSuccessful && result.Organization != null)
                {
                    var org = result.Organization;
                    
                    hfOrganizationId.Value = org.Id.ToString();
                    txtModalName.Text = org.Name;
                    txtModalSlug.Text = org.Slug;
                    txtModalDescription.Text = org.Description ?? "";
                    chkModalActive.Checked = org.IsActive;
                    
                    // Set owner if available
                    if (ddlModalOwner.Items.FindByValue(org.OwnerId.ToString()) != null)
                    {
                        ddlModalOwner.SelectedValue = org.OwnerId.ToString();
                    }
                    
                    lblModalTitle.Text = GetResourceString("EditOrganization");
                    
                    upModal.Update();
                    
                    // Show modal
                    ScriptManager.RegisterStartupScript(this, GetType(), "showEditModal", "showOrganizationModal();", true);
                }
                else
                {
                    ShowAlert(result.ErrorMessage ?? GetResourceString("OrganizationNotFound"), "danger");
                }
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
            }
        }
        
        private void DeleteOrganization(int organizationId)
        {
            try
            {
                var result = organizationSecurity.DeleteOrganization(organizationId);
                
                if (result.IsSuccessful)
                {
                    ShowAlert(GetResourceString("OrganizationDeletedSuccess"), "success");
                    LoadOrganizations();
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
            }
        }
        
        protected void btnModalSave_Click(object sender, EventArgs e)
        {
            try
            {
                if (!Page.IsValid)
                    return;
                
                string name = txtModalName.Text.Trim();
                string slug = txtModalSlug.Text.Trim();
                string description = txtModalDescription.Text.Trim();
                bool isActive = chkModalActive.Checked;
                
                if (!int.TryParse(ddlModalOwner.SelectedValue, out int ownerId))
                {
                    ShowAlert(GetResourceString("OwnerRequired"), "danger");
                    return;
                }
                
                bool isEdit = !string.IsNullOrEmpty(hfOrganizationId.Value);
                
                if (isEdit)
                {
                    // Update existing organization
                    int organizationId = Convert.ToInt32(hfOrganizationId.Value);
                    var result = organizationSecurity.UpdateOrganization(organizationId, name, slug, description);
                    
                    if (result.IsSuccessful)
                    {
                        ShowAlert(GetResourceString("OrganizationUpdatedSuccess"), "success");
                        LoadOrganizations();
                        
                        // Hide modal
                        ScriptManager.RegisterStartupScript(this, GetType(), "hideModal", "hideOrganizationModal();", true);
                    }
                    else
                    {
                        ShowAlert(result.ErrorMessage, "danger");
                    }
                }
                else
                {
                    // Create new organization
                    var result = organizationSecurity.CreateOrganization(name, slug, description, ownerId);
                    
                    if (result.IsSuccessful)
                    {
                        ShowAlert(GetResourceString("OrganizationCreatedSuccess"), "success");
                        LoadOrganizations();
                        
                        // Hide modal and clear fields
                        ClearModalFields();
                        ScriptManager.RegisterStartupScript(this, GetType(), "hideModal", "hideOrganizationModal();", true);
                    }
                    else
                    {
                        ShowAlert(result.ErrorMessage, "danger");
                    }
                }
                
                upMain.Update();
                upModal.Update();
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
            }
        }
        
        private void ClearModalFields()
        {
            hfOrganizationId.Value = "";
            txtModalName.Text = "";
            txtModalSlug.Text = "";
            txtModalDescription.Text = "";
            chkModalActive.Checked = true;
            ddlModalOwner.SelectedIndex = 0;
        }
        
        protected void lnkPrevious_Click(object sender, EventArgs e)
        {
            try
            {
                int currentPage = ViewState["CurrentPage"] != null ? Convert.ToInt32(ViewState["CurrentPage"]) : 1;
                if (currentPage > 1)
                {
                    ViewState["CurrentPage"] = currentPage - 1;
                    LoadOrganizations();
                    upMain.Update();
                }
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
            }
        }
        
        protected void lnkNext_Click(object sender, EventArgs e)
        {
            try
            {
                int currentPage = ViewState["CurrentPage"] != null ? Convert.ToInt32(ViewState["CurrentPage"]) : 1;
                ViewState["CurrentPage"] = currentPage + 1;
                LoadOrganizations();
                upMain.Update();
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
            }
        }
        
        protected void rptPagination_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                if (e.CommandName == "Page")
                {
                    int pageNumber = Convert.ToInt32(e.CommandArgument);
                    ViewState["CurrentPage"] = pageNumber;
                    LoadOrganizations();
                    upMain.Update();
                }
            }
            catch (Exception ex)
            {
                ShowAlert(GetResourceString("Error") + ": " + ex.Message, "danger");
            }
        }
        
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            try
            {
                // Clear authentication
                Session.Clear();
                Session.Abandon();
                
                // Clear forms authentication ticket
                System.Web.Security.FormsAuthentication.SignOut();
                
                Response.Redirect("SignIn.aspx");
            }
            catch (Exception ex)
            {
                Response.Redirect("SignIn.aspx");
            }
        }
        
        #region Helper Methods
        
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
                // Escape message for JavaScript
                string escapedMessage = message.Replace("'", "\\'").Replace("\"", "\\\"");
                
                // Determine notification style
                string bgColor, textColor, icon;
                if (type == "success")
                {
                    bgColor = "#28a745";
                    textColor = "white";
                    icon = "✓";
                }
                else if (type == "danger" || type == "error")
                {
                    bgColor = "#dc3545";
                    textColor = "white";
                    icon = "⚠";
                }
                else if (type == "warning")
                {
                    bgColor = "#ffc107";
                    textColor = "black";
                    icon = "⚠";
                }
                else
                {
                    bgColor = "#17a2b8";
                    textColor = "white";
                    icon = "ℹ";
                }
                
                // Create a simple, guaranteed-to-work toast
                string script = $@"
                (function() {{
                    // Remove any existing toasts
                    var existing = document.querySelectorAll('.hirebot-toast');
                    existing.forEach(function(t) {{ t.remove(); }});
                    
                    // Create toast
                    var toast = document.createElement('div');
                    toast.className = 'hirebot-toast';
                    toast.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 10000; background: {bgColor}; color: {textColor}; padding: 15px 20px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.3); font-family: Arial, sans-serif; font-size: 14px; max-width: 400px; word-wrap: break-word; transform: translateX(100%); transition: transform 0.3s ease;';
                    toast.innerHTML = '<div style=""display: flex; align-items: center;""><span style=""font-size: 18px; margin-right: 10px;"">{icon}</span><span>{escapedMessage}</span><button onclick=""this.parentElement.parentElement.remove()"" style=""background: none; border: none; color: {textColor}; margin-left: 15px; cursor: pointer; font-size: 18px; padding: 0;"">&times;</button></div>';
                    
                    document.body.appendChild(toast);
                    
                    // Animate in
                    setTimeout(function() {{
                        toast.style.transform = 'translateX(0)';
                    }}, 10);
                    
                    // Auto remove after 5 seconds
                    setTimeout(function() {{
                        if (toast.parentElement) {{
                            toast.style.transform = 'translateX(100%)';
                            setTimeout(function() {{
                                if (toast.parentElement) toast.remove();
                            }}, 300);
                        }}
                    }}, 5000);
                    
                    console.log('Toast shown: {escapedMessage}');
                }})();";
                
                ScriptManager.RegisterStartupScript(this, GetType(), "showToast_" + DateTime.Now.Ticks, script, true);
                
                // Also log to console for debugging
                System.Diagnostics.Debug.WriteLine($"ShowAlert called: {message} ({type})");
            }
            catch (Exception ex)
            {
                // Last resort fallback
                string fallbackScript = $"alert('ALERT: {message.Replace("'", "\\'")}');";
                ScriptManager.RegisterStartupScript(this, GetType(), "lastResort", fallbackScript, true);
                System.Diagnostics.Debug.WriteLine($"ShowAlert error: {ex.Message}");
            }
        }
        
      

        #region Event Validation Override

        /// <summary>
        /// Override Render method to register event validation for dynamically modified controls
        /// This prevents "Invalid postback or callback argument" errors when JavaScript modifies TextBox values
        /// </summary>
        protected override void Render(HtmlTextWriter writer)
        {
            try
            {
                // Register event validation for txtModalSlug which is modified by JavaScript
                // This control is modified when the auto-generation code runs: slugTextBox.value = slug;
                Page.ClientScript.RegisterForEventValidation(txtModalSlug.UniqueID);
                
                // Register validation for common slug patterns that might be generated by JavaScript
                // This covers typical organization name patterns converted to slugs
                var commonSlugPatterns = new[] 
                {
                    "my-organization", "test-org", "company-name", "business-corp",
                    "tech-solutions", "consulting-group", "services-inc", "global-ltd",
                    "digital-agency", "marketing-co", "development-team", "startup-inc",
                    "", "a", "ab", "abc", "test", "sample", "demo", "example"
                };
                
                foreach (var pattern in commonSlugPatterns)
                {
                    try
                    {
                        Page.ClientScript.RegisterForEventValidation(txtModalSlug.UniqueID, pattern);
                    }
                    catch
                    {
                        // Continue if individual registration fails
                    }
                }
                
                // Also register txtModalName since it's in the same form
                Page.ClientScript.RegisterForEventValidation(txtModalName.UniqueID);
            }
            catch
            {
               
            }
            
            base.Render(writer);
        }

        #endregion
        
        #endregion
    }
}