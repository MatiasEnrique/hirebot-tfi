using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;
using ABSTRACTIONS;
using SECURITY;

namespace Hirebot_TFI
{
    /// <summary>
    /// Comprehensive Chatbot Administration page
    /// Implements complete CRUD operations with security validation following UI → Security → BLL → DAL architecture
    /// Features: Real-time updates, Bootstrap styling, multilanguage support, responsive design
    /// </summary>
    public partial class ChatbotAdmin : BasePage
    {
        #region Private Fields

        private readonly ChatbotSecurity _chatbotSecurity;
        private readonly OrganizationSecurity _organizationSecurity;
        private const int DEFAULT_PAGE_SIZE = 10;

        #endregion

        #region Constructor

        public ChatbotAdmin()
        {
            _chatbotSecurity = new ChatbotSecurity();
            _organizationSecurity = new OrganizationSecurity();
        }

        #endregion

        #region Page Events

        /// <summary>
        /// Page initialization - Load data and configure controls
        /// </summary>
        /// <param name="sender">Page object</param>
        /// <param name="e">Event arguments</param>
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (!IsPostBack)
                {
                    // Initialize ViewState for first page load
                    ViewState["CurrentPage"] = 1;
                    
                    // Initialize page components
                    LoadOrganizations();
                    LoadChatbotData();
                    
                    // Configure validation groups
                    ConfigureValidationGroups();
                    
                    // Log page access
                    LogPageAccess();
                }

                // Ensure script manager is properly configured
                ConfigureScriptManager();
            }
            catch (Exception ex)
            {
                LogError("Page_Load", ex);
                ShowErrorToast(GetLocalizedText("ErrorLoadingPage"));
            }
        }

        /// <summary>
        /// Page pre-render - Final setup before rendering
        /// </summary>
        /// <param name="sender">Page object</param>
        /// <param name="e">Event arguments</param>
        protected void Page_PreRender(object sender, EventArgs e)
        {
            try
            {
                // Register JavaScript for client-side functionality
                RegisterClientScripts();
                
                // Update pagination display
                UpdatePaginationDisplay();
            }
            catch (Exception ex)
            {
                LogError("Page_PreRender", ex);
            }
        }

        #endregion

        #region Data Loading Methods

        /// <summary>
        /// Load organization dropdown data from security layer
        /// </summary>
        private void LoadOrganizations()
        {
            try
            {
                // Call security layer for organization data
                var result = _organizationSecurity.GetAllOrganizations(1, 100, "Name", "ASC", "");

                if (result.IsSuccessful && result.Data != null)
                {
                    // Load filter dropdown
                    ddlOrganizationFilter.Items.Clear();
                    ddlOrganizationFilter.Items.Add(new ListItem(GetLocalizedText("AllOrganizations"), ""));
                    ddlOrganizationFilter.Items.Add(new ListItem(GetLocalizedText("UnassignedChatbots"), "-1"));

                    foreach (var org in result.Data)
                    {
                        ddlOrganizationFilter.Items.Add(new ListItem(org.Name, org.Id.ToString()));
                    }

                    // Load modal dropdowns
                    LoadModalOrganizations(result.Data);
                }
                else
                {
                    LogError("LoadOrganizations", $"Failed to load organizations: {result.ErrorMessage}");
                    ShowErrorToast(GetLocalizedText("ErrorLoadingOrganizations"));
                }
            }
            catch (Exception ex)
            {
                LogError("LoadOrganizations", ex);
                ShowErrorToast(GetLocalizedText("ErrorLoadingOrganizations"));
            }
        }

        /// <summary>
        /// Load organizations for modal dropdowns
        /// </summary>
        /// <param name="organizations">List of organizations</param>
        private void LoadModalOrganizations(List<Organization> organizations)
        {
            try
            {
                // Main chatbot modal
                ddlOrganization.Items.Clear();
                ddlOrganization.Items.Add(new ListItem(GetLocalizedText("UnassignedChatbot"), ""));

                // Assignment modal
                ddlAssignOrganization.Items.Clear();

                foreach (var org in organizations)
                {
                    ddlOrganization.Items.Add(new ListItem(org.Name, org.Id.ToString()));
                    ddlAssignOrganization.Items.Add(new ListItem(org.Name, org.Id.ToString()));
                }
            }
            catch (Exception ex)
            {
                LogError("LoadModalOrganizations", ex);
            }
        }

        /// <summary>
        /// Load chatbot data with current filters and pagination
        /// </summary>
        private void LoadChatbotData()
        {
            try
            {
                // Get current page number
                int currentPage = GetCurrentPage();

                // Build search criteria from filters
                var criteria = BuildSearchCriteria(currentPage);

                // Call security layer for chatbot data
                var result = _chatbotSecurity.GetAllChatbots(criteria);

                if (result.IsSuccessful && result.Data != null)
                {
                    if (result.Data.Data != null && result.Data.Data.Count > 0)
                    {
                        // Bind data to repeater
                        rptChatbots.DataSource = result.Data.Data;
                        rptChatbots.DataBind();
                        
                        rptChatbots.Visible = true;

                        // Setup pagination
                        SetupPagination(result.Data);
                    }
                    else
                    {
                        // Show empty state
                        rptChatbots.DataSource = new List<Chatbot>();
                        rptChatbots.DataBind();
                        rptChatbots.Visible = true;
                        ShowInfoToast(GetLocalizedText("NoChatbotsFound"));
                    }
                }
                else
                {
                    LogError("LoadChatbotData", $"Failed to load chatbots: {result.ErrorMessage}");
                    ShowErrorToast(GetLocalizedText("ErrorLoadingChatbots"));
                    
                    // Clear repeater on error
                    rptChatbots.DataSource = new List<Chatbot>();
                    rptChatbots.DataBind();
                    rptChatbots.Visible = true;
                }
            }
            catch (Exception ex)
            {
                LogError("LoadChatbotData", ex);
                ShowErrorToast(GetLocalizedText("ErrorLoadingChatbots"));
                
                // Clear repeater on error
                if (rptChatbots != null)
                {
                    rptChatbots.DataSource = new List<Chatbot>();
                    rptChatbots.DataBind();
                    rptChatbots.Visible = true;
                }
            }
        }

        /// <summary>
        /// Build search criteria from current filter settings
        /// </summary>
        /// <param name="pageNumber">Current page number</param>
        /// <returns>Configured search criteria</returns>
        private ChatbotSearchCriteria BuildSearchCriteria(int pageNumber)
        {
            var criteria = new ChatbotSearchCriteria
            {
                PageNumber = pageNumber,
                PageSize = DEFAULT_PAGE_SIZE
            };

            // Apply organization filter - with null check
            if (ddlOrganizationFilter != null && !string.IsNullOrEmpty(ddlOrganizationFilter.SelectedValue))
            {
                if (ddlOrganizationFilter.SelectedValue == "-1")
                {
                    // Unassigned chatbots - pass -1 to stored procedure to indicate unassigned filter
                    criteria.OrganizationId = -1;
                }
                else if (int.TryParse(ddlOrganizationFilter.SelectedValue, out int orgId))
                {
                    criteria.OrganizationId = orgId;
                }
            }
            // For first load or when "All Organizations" is selected (empty value), leave OrganizationId as NULL to show all

            // Apply status filter - with null check
            if (ddlStatusFilter != null && !string.IsNullOrEmpty(ddlStatusFilter.SelectedValue))
            {
                if (bool.TryParse(ddlStatusFilter.SelectedValue, out bool isActive))
                {
                    criteria.IncludeInactive = !isActive;
                }
            }
            // For first load or when no status is selected, IncludeInactive defaults to false (show only active)

            // Apply search filter (search by name only) - with null check
            if (txtSearchFilter != null && !string.IsNullOrEmpty(txtSearchFilter.Text?.Trim()))
            {
                string searchTerm = txtSearchFilter.Text.Trim();
                criteria.Name = searchTerm;
            }
            // For first load or when no search text, Name remains empty (show all names)

            return criteria;
        }

        #endregion

        #region Admin Navigation Events

        /// <summary>
        /// Handle logout button click
        /// </summary>
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            try
            {
                // Clear session and redirect to sign in
                Session.Clear();
                Session.Abandon();
                Response.Redirect("~/SignIn.aspx");
            }
            catch (Exception ex)
            {
                LogError("btnLogout_Click", ex);
                // Force redirect even on error
                Response.Redirect("~/SignIn.aspx");
            }
        }

        #endregion

        #region Event Handlers

        /// <summary>
        /// Handle organization filter change
        /// </summary>
        protected void ddlOrganizationFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                // Reset to first page and reload data
                ViewState["CurrentPage"] = 1;
                LoadChatbotData();
            }
            catch (Exception ex)
            {
                LogError("ddlOrganizationFilter_SelectedIndexChanged", ex);
                ShowErrorToast(GetLocalizedText("ErrorApplyingFilter"));
            }
        }

        /// <summary>
        /// Handle status filter change
        /// </summary>
        protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                // Reset to first page and reload data
                ViewState["CurrentPage"] = 1;
                LoadChatbotData();
            }
            catch (Exception ex)
            {
                LogError("ddlStatusFilter_SelectedIndexChanged", ex);
                ShowErrorToast(GetLocalizedText("ErrorApplyingFilter"));
            }
        }

        /// <summary>
        /// Handle search button click
        /// </summary>
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            try
            {
                // Reset to first page and reload data
                ViewState["CurrentPage"] = 1;
                LoadChatbotData();
                
                // Log search activity
                LogInfo("btnSearch_Click", $"Search performed with criteria: {txtSearchFilter.Text.Trim()}");
            }
            catch (Exception ex)
            {
                LogError("btnSearch_Click", ex);
                ShowErrorToast(GetLocalizedText("ErrorSearching"));
            }
        }

        /// <summary>
        /// Handle clear search button click
        /// </summary>
        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            try
            {
                // Clear search text
                txtSearchFilter.Text = "";
                
                // Reset filters to show all items
                ddlOrganizationFilter.SelectedIndex = 0;
                ddlStatusFilter.SelectedIndex = 0;
                
                // Reset to first page and reload data
                ViewState["CurrentPage"] = 1;
                LoadChatbotData();
                
                LogInfo("btnClearSearch_Click", "Search filters cleared");
            }
            catch (Exception ex)
            {
                LogError("btnClearSearch_Click", ex);
                ShowErrorToast(GetLocalizedText("ErrorClearingSearch"));
            }
        }

        /// <summary>
        /// Handle repeater item command (Edit, Delete, Assign/Unassign)
        /// </summary>
        protected void rptChatbots_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                if (!int.TryParse(e.CommandArgument.ToString(), out int chatbotId))
                {
                    ShowErrorToast(GetLocalizedText("InvalidChatbotId"));
                    return;
                }

                switch (e.CommandName)
                {
                    case "Edit":
                        System.Diagnostics.Debug.WriteLine($"Edit command received for chatbotId: {chatbotId}");
                        LoadChatbotForEdit(chatbotId);
                        break;

                    case "Delete":
                        DeleteChatbot(chatbotId);
                        break;

                    case "ToggleAssignment":
                        HandleToggleAssignment(chatbotId);
                        break;

                    default:
                        LogError("rptChatbots_ItemCommand", $"Unknown command: {e.CommandName}");
                        break;
                }
            }
            catch (Exception ex)
            {
                LogError("rptChatbots_ItemCommand", ex);
                ShowErrorToast(GetLocalizedText("ErrorProcessingCommand"));
            }
        }

        /// <summary>
        /// Handle repeater item data bound - Configure item-specific elements
        /// </summary>
        protected void rptChatbots_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            try
            {
                if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
                {
                    var chatbot = (Chatbot)e.Item.DataItem;
                    
                    // Note: The ASPX template handles display directly via inline expressions
                    // This method is kept for potential future enhancements
                }
            }
            catch (Exception ex)
            {
                LogError("rptChatbots_ItemDataBound", ex);
            }
        }

        /// <summary>
        /// Handle save chatbot button click (Create/Update)
        /// </summary>
        protected void btnSaveChatbot_Click(object sender, EventArgs e)
        {
            try
            {
                if (!Page.IsValid)
                    return;

                // Get form data
                var chatbot = GetChatbotFromForm();
                if (chatbot == null)
                {
                    ShowErrorToast(GetLocalizedText("ErrorValidatingChatbotData"));
                    return;
                }

                // Determine operation mode with additional validation
                bool isEdit = hfModalMode.Value == "edit" && 
                             !string.IsNullOrEmpty(hfChatbotId.Value) && 
                             hfChatbotId.Value != "0" && 
                             int.TryParse(hfChatbotId.Value, out int _);

                DatabaseResult<Chatbot> result;
                if (isEdit)
                {
                    // Update existing chatbot
                    chatbot.ChatbotId = int.Parse(hfChatbotId.Value);
                    result = _chatbotSecurity.UpdateChatbot(chatbot);
                }
                else
                {
                    // Create new chatbot
                    result = _chatbotSecurity.CreateChatbot(chatbot);
                }

                if (result.IsSuccessful)
                {
                    // Success - show toast and refresh data
                    if (isEdit)
                    {
                        ShowSuccessToast(GetLocalizedText("ChatbotUpdatedSuccess"));
                    }
                    else
                    {
                        ShowSuccessToast(GetLocalizedText("ChatbotCreatedSuccess"));
                    }
                    
                    // Reload data and hide modal
                    LoadChatbotData();
                    ScriptManager.RegisterStartupScript(this, GetType(), "hideModal", "hideChatbotModal();", true);
                }
                else
                {
                    // Error handling
                    string errorMessage = GetUserFriendlyErrorMessage(result.ErrorMessage, result.ResultCode);
                    ShowErrorToast(errorMessage);
                    LogError("btnSaveChatbot_Click", $"Operation failed: {result.ErrorMessage}");
                }
            }
            catch (Exception ex)
            {
                LogError("btnSaveChatbot_Click", ex);
                ShowErrorToast(GetLocalizedText("ErrorSavingChatbot"));
            }
        }

        /// <summary>
        /// Handle confirm assign button click
        /// </summary>
        protected void btnConfirmAssign_Click(object sender, EventArgs e)
        {
            try
            {
                if (!int.TryParse(hfAssignChatbotId.Value, out int chatbotId))
                {
                    ShowErrorToast(GetLocalizedText("InvalidChatbotId"));
                    return;
                }

                if (!int.TryParse(ddlAssignOrganization.SelectedValue, out int organizationId))
                {
                    ShowErrorToast(GetLocalizedText("PleaseSelectOrganization"));
                    return;
                }

                // Call security layer to assign chatbot
                var result = _chatbotSecurity.AssignChatbotToOrganization(chatbotId, organizationId);

                if (result.IsSuccessful)
                {
                    ShowSuccessToast(GetLocalizedText("ChatbotAssignedSuccess"));
                    CloseAssignModalAndRefresh();
                }
                else
                {
                    string errorMessage = GetUserFriendlyErrorMessage(result.ErrorMessage, result.ResultCode);
                    ShowErrorToast(errorMessage);
                    LogError("btnConfirmAssign_Click", $"Assignment failed: {result.ErrorMessage}");
                }
            }
            catch (Exception ex)
            {
                LogError("btnConfirmAssign_Click", ex);
                ShowErrorToast(GetLocalizedText("ErrorAssigningChatbot"));
            }
        }

        /// <summary>
        /// Handle pagination commands
        /// </summary>
        protected void rptPagination_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                if (e.CommandName == "Page" && int.TryParse(e.CommandArgument.ToString(), out int page))
                {
                    ViewState["CurrentPage"] = page;
                    LoadChatbotData();
                }
            }
            catch (Exception ex)
            {
                LogError("rptPagination_ItemCommand", ex);
                ShowErrorToast(GetLocalizedText("ErrorNavigatingPages"));
            }
        }

        #endregion

        #region Command Handlers

        /// <summary>
        /// Load chatbot for editing (following OrganizationAdmin pattern)
        /// </summary>
        /// <param name="chatbotId">Chatbot ID to edit</param>
        private void LoadChatbotForEdit(int chatbotId)
        {
            try
            {
                // Add debugging
                System.Diagnostics.Debug.WriteLine($"LoadChatbotForEdit called with chatbotId: {chatbotId}");
                
                var result = _chatbotSecurity.GetChatbotById(chatbotId);
                
                if (result.IsSuccessful && result.Data != null)
                {
                    var chatbot = result.Data;
                    
                    // Populate modal form fields
                    hfChatbotId.Value = chatbot.ChatbotId.ToString();
                    txtChatbotName.Text = chatbot.Name ?? "";
                    txtInstructions.Text = chatbot.Instructions ?? "";
                    txtColorHex.Text = chatbot.Color ?? "#222222";
                    hfSelectedColor.Value = chatbot.Color ?? "#222222";
                    
                    // Set organization if available
                    if (chatbot.OrganizationId.HasValue && ddlOrganization.Items.FindByValue(chatbot.OrganizationId.Value.ToString()) != null)
                    {
                        ddlOrganization.SelectedValue = chatbot.OrganizationId.Value.ToString();
                    }
                    else
                    {
                        ddlOrganization.SelectedValue = "";
                    }
                    
                    hfModalMode.Value = "edit";
                    
                    // Update save button text for edit mode
                    btnSaveChatbot.Text = GetLocalizedText("Save");
                    
                    // Update the modal UpdatePanel
                    upModal.Update();
                    
                    // Show modal using ScriptManager (OrganizationAdmin pattern)
                    System.Diagnostics.Debug.WriteLine("About to show modal with ScriptManager.RegisterStartupScript");
                    ScriptManager.RegisterStartupScript(this, GetType(), "showEditModal", "console.log('ScriptManager calling showChatbotModal'); showChatbotModal();", true);
                }
                else
                {
                    ShowErrorToast(result.ErrorMessage ?? GetLocalizedText("ChatbotNotFound"));
                }
            }
            catch (Exception ex)
            {
                LogError("LoadChatbotForEdit", ex);
                ShowErrorToast(GetLocalizedText("ErrorLoadingChatbotForEdit"));
            }
        }

        /// <summary>
        /// Delete chatbot (following OrganizationAdmin pattern)
        /// </summary>
        /// <param name="chatbotId">Chatbot ID to delete</param>
        private void DeleteChatbot(int chatbotId)
        {
            try
            {
                var result = _chatbotSecurity.DeleteChatbot(chatbotId);

                if (result.IsSuccessful)
                {
                    ShowSuccessToast(GetLocalizedText("ChatbotDeletedSuccess"));
                    LoadChatbotData();
                }
                else
                {
                    ShowErrorToast(result.ErrorMessage);
                }
            }
            catch (Exception ex)
            {
                LogError("DeleteChatbot", ex);
                ShowErrorToast(GetLocalizedText("ErrorDeletingChatbot"));
            }
        }

        /// <summary>
        /// Handle toggle assignment command (Assign/Unassign)
        /// </summary>
        /// <param name="chatbotId">Chatbot ID to toggle assignment for</param>
        private void HandleToggleAssignment(int chatbotId)
        {
            try
            {
                // Get current chatbot data to determine current assignment status
                var chatbotResult = _chatbotSecurity.GetChatbotById(chatbotId);
                
                if (!chatbotResult.IsSuccessful || chatbotResult.Data == null)
                {
                    ShowErrorToast(GetLocalizedText("ErrorLoadingChatbotData"));
                    return;
                }

                var chatbot = chatbotResult.Data;

                if (chatbot.OrganizationId.HasValue)
                {
                    // Currently assigned - unassign it
                    var result = _chatbotSecurity.UnassignChatbotFromOrganization(chatbotId);
                    
                    if (result.IsSuccessful)
                    {
                        ShowSuccessToast(GetLocalizedText("ChatbotUnassignedSuccess"));
                        LoadChatbotData(); // Refresh the grid
                    }
                    else
                    {
                        string errorMessage = GetUserFriendlyErrorMessage(result.ErrorMessage, result.ResultCode);
                        ShowErrorToast(errorMessage);
                        LogError("HandleToggleAssignment", $"Unassignment failed: {result.ErrorMessage}");
                    }
                }
                else
                {
                    // Currently unassigned - show assignment modal
                    hfAssignChatbotId.Value = chatbotId.ToString();
                    string script = $"openAssignModal({chatbotId});";
                    ClientScript.RegisterStartupScript(this.GetType(), "openAssignModal", script, true);
                }
            }
            catch (Exception ex)
            {
                LogError("HandleToggleAssignment", ex);
                ShowErrorToast(GetLocalizedText("ErrorProcessingAssignment"));
            }
        }

        #endregion

        #region Helper Methods

        /// <summary>
        /// Get chatbot object from form data
        /// </summary>
        /// <returns>Chatbot object or null if validation fails</returns>
        private Chatbot GetChatbotFromForm()
        {
            try
            {
                var chatbot = new Chatbot
                {
                    Name = txtChatbotName.Text.Trim(),
                    Instructions = txtInstructions.Text.Trim(),
                    Color = ValidateAndNormalizeColor(txtColorHex.Text.Trim())
                };

                // Handle organization assignment
                if (!string.IsNullOrEmpty(ddlOrganization.SelectedValue) && 
                    int.TryParse(ddlOrganization.SelectedValue, out int orgId))
                {
                    chatbot.OrganizationId = orgId;
                }

                // Additional validation
                if (string.IsNullOrEmpty(chatbot.Name))
                {
                    ShowErrorToast(GetLocalizedText("ChatbotNameRequired"));
                    return null;
                }

                if (string.IsNullOrEmpty(chatbot.Instructions))
                {
                    ShowErrorToast(GetLocalizedText("ChatbotInstructionsRequired"));
                    return null;
                }

                if (chatbot.Instructions.Length < 10)
                {
                    ShowErrorToast(GetLocalizedText("ChatbotInstructionsTooShort"));
                    return null;
                }

                return chatbot;
            }
            catch (Exception ex)
            {
                LogError("GetChatbotFromForm", ex);
                return null;
            }
        }

        /// <summary>
        /// Validate and normalize hex color
        /// </summary>
        /// <param name="color">Color string to validate</param>
        /// <returns>Normalized hex color or default color</returns>
        private string ValidateAndNormalizeColor(string color)
        {
            try
            {
                if (string.IsNullOrEmpty(color))
                    return "#222222";

                // Ensure color starts with #
                if (!color.StartsWith("#"))
                    color = "#" + color;

                // Validate hex format
                if (System.Text.RegularExpressions.Regex.IsMatch(color, @"^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"))
                {
                    // Expand 3-digit to 6-digit if needed
                    if (color.Length == 4)
                    {
                        color = $"#{color[1]}{color[1]}{color[2]}{color[2]}{color[3]}{color[3]}";
                    }
                    return color.ToUpperInvariant();
                }

                // Invalid format - return default
                return "#222222";
            }
            catch
            {
                return "#222222";
            }
        }

        /// <summary>
        /// Get current page number from ViewState
        /// </summary>
        /// <returns>Current page number</returns>
        private int GetCurrentPage()
        {
            if (ViewState["CurrentPage"] is int page && page > 0)
                return page;
            
            return 1;
        }

        /// <summary>
        /// Setup pagination controls
        /// </summary>
        /// <param name="paginatedResult">Paginated result data</param>
        private void SetupPagination(PaginatedResult<Chatbot> paginatedResult)
        {
            try
            {
                var paginationItems = new List<object>();

                // Previous button
                if (paginatedResult.CurrentPage > 1)
                {
                    paginationItems.Add(new { Type = "prev", PageNumber = paginatedResult.CurrentPage - 1, Text = "&laquo;", IsActive = false });
                }

                // Calculate page range
                int startPage = Math.Max(1, paginatedResult.CurrentPage - 2);
                int endPage = Math.Min(paginatedResult.TotalPages, paginatedResult.CurrentPage + 2);

                // Add page numbers
                for (int i = startPage; i <= endPage; i++)
                {
                    paginationItems.Add(new { Type = "page", PageNumber = i, Text = i.ToString(), IsActive = i == paginatedResult.CurrentPage });
                }

                // Next button
                if (paginatedResult.CurrentPage < paginatedResult.TotalPages)
                {
                    paginationItems.Add(new { Type = "next", PageNumber = paginatedResult.CurrentPage + 1, Text = "&raquo;", IsActive = false });
                }

                rptPagination.DataSource = paginationItems;
                rptPagination.DataBind();
            }
            catch (Exception ex)
            {
                LogError("SetupPagination", ex);
            }
        }

        /// <summary>
        /// Update pagination information display
        /// </summary>
        /// <param name="paginatedResult">Paginated result data</param>
        private void UpdatePaginationInfo(PaginatedResult<Chatbot> paginatedResult)
        {
            try
            {
                // Pagination info display is handled in the UI
                // This method is kept for potential future enhancements
                System.Diagnostics.Debug.WriteLine($"Pagination: Page {paginatedResult.CurrentPage} of {paginatedResult.TotalPages}, Total Records: {paginatedResult.TotalRecords}");
            }
            catch (Exception ex)
            {
                LogError("UpdatePaginationInfo", ex);
            }
        }

        /// <summary>
        /// Update pagination display after loading
        /// </summary>
        private void UpdatePaginationDisplay()
        {
            try
            {
                // This method can be used for additional pagination display logic
                // Currently handled in UpdatePaginationInfo
            }
            catch (Exception ex)
            {
                LogError("UpdatePaginationDisplay", ex);
            }
        }

        /// <summary>
        /// Close modal and refresh data
        /// </summary>
        private void CloseModalAndRefresh()
        {
            try
            {
                // Clear form
                ClearChatbotForm();
                
                // Refresh data
                LoadChatbotData();
                
                // Close modal via JavaScript
                string script = "hideChatbotModal();";
                ScriptManager.RegisterStartupScript(this, GetType(), "closeModal", script, true);
            }
            catch (Exception ex)
            {
                LogError("CloseModalAndRefresh", ex);
            }
        }

        /// <summary>
        /// Close assign modal and refresh data
        /// </summary>
        private void CloseAssignModalAndRefresh()
        {
            try
            {
                // Clear assignment form
                hfAssignChatbotId.Value = "";
                ddlAssignOrganization.SelectedIndex = -1;
                
                // Refresh data
                LoadChatbotData();
                
                // Close modal via JavaScript
                string script = "$('#assignModal').modal('hide');";
                ClientScript.RegisterStartupScript(this.GetType(), "closeAssignModal", script, true);
            }
            catch (Exception ex)
            {
                LogError("CloseAssignModalAndRefresh", ex);
            }
        }

        /// <summary>
        /// Clear chatbot form fields
        /// </summary>
        private void ClearChatbotForm()
        {
            try
            {
                txtChatbotName.Text = "";
                txtInstructions.Text = "";
                txtColorHex.Text = "#222222";
                hfSelectedColor.Value = "#222222";
                ddlOrganization.SelectedIndex = 0;
                hfChatbotId.Value = "0";
                hfModalMode.Value = "create";
                
                // Reset button text to Create
                btnSaveChatbot.Text = GetLocalizedText("Create");
            }
            catch (Exception ex)
            {
                LogError("ClearChatbotForm", ex);
            }
        }

        /// <summary>
        /// Configure script manager for UpdatePanel functionality
        /// </summary>
        private void ConfigureScriptManager()
        {
            try
            {
                // Check if ScriptManager exists (might be in master page or not present)
                if (ScriptManager1 != null)
                {
                    ScriptManager1.EnablePartialRendering = true;
                    ScriptManager1.AsyncPostBackTimeout = 120; // 2 minutes
                    ScriptManager1.EnableScriptGlobalization = true;
                    ScriptManager1.EnableScriptLocalization = true;
                }
                else
                {
                    // ScriptManager is managed by master page
                    var sm = ScriptManager.GetCurrent(Page);
                    if (sm != null)
                    {
                        sm.EnablePartialRendering = true;
                        sm.AsyncPostBackTimeout = 120; // 2 minutes
                        sm.EnableScriptGlobalization = true;
                        sm.EnableScriptLocalization = true;
                    }
                }
            }
            catch (Exception ex)
            {
                LogError("ConfigureScriptManager", ex);
            }
        }

        /// <summary>
        /// Configure validation groups
        /// </summary>
        private void ConfigureValidationGroups()
        {
            try
            {
                // Set validation group for modal form
                if (rfvChatbotName != null)
                {
                    rfvChatbotName.ValidationGroup = "ChatbotModal";
                }
                
                if (btnSaveChatbot != null)
                {
                    btnSaveChatbot.ValidationGroup = "ChatbotModal";
                }
            }
            catch (Exception ex)
            {
                LogError("ConfigureValidationGroups", ex);
            }
        }

        /// <summary>
        /// Register client-side JavaScript
        /// </summary>
        private void RegisterClientScripts()
        {
            try
            {
                // Register localized text for JavaScript
                var localizedTexts = new Dictionary<string, string>
                {
                    ["ConfirmDeleteChatbot"] = GetLocalizedText("ConfirmDeleteChatbot"),
                    ["ConfirmUnassignChatbot"] = GetLocalizedText("ConfirmUnassignChatbot"),
                    ["CreateChatbot"] = GetLocalizedText("CreateChatbot"),
                    ["EditChatbot"] = GetLocalizedText("EditChatbot"),
                    ["ErrorProcessingRequest"] = GetLocalizedText("ErrorProcessingRequest"),
                    ["PleaseWait"] = GetLocalizedText("PleaseWait")
                };

                var script = new StringBuilder();
                script.AppendLine("window.ChatbotAdmin = window.ChatbotAdmin || {};");
                script.AppendLine("window.ChatbotAdmin.LocalizedTexts = {");
                
                var pairs = localizedTexts.Select(kvp => $"    '{kvp.Key}': '{HttpUtility.JavaScriptStringEncode(kvp.Value)}'");
                script.AppendLine(string.Join(",\n", pairs));
                
                script.AppendLine("};");

                ClientScript.RegisterStartupScript(this.GetType(), "localizedTexts", script.ToString(), true);
            }
            catch (Exception ex)
            {
                LogError("RegisterClientScripts", ex);
            }
        }

        /// <summary>
        /// Log page access for auditing
        /// </summary>
        private void LogPageAccess()
        {
            try
            {
                LogInfo("Page Access", "ChatbotAdmin page accessed");
            }
            catch (Exception ex)
            {
                LogError("LogPageAccess", ex);
            }
        }

        #endregion

        #region Toast Notification Methods

        /// <summary>
        /// Show alert notification with guaranteed DOM manipulation (OrganizationAdmin pattern)
        /// </summary>
        /// <param name="message">Message to display</param>
        /// <param name="type">Type of alert (success, error, warning, info)</param>
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
                    
                    console.log('✅ ChatbotAdmin Toast shown: {escapedMessage}');
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

        /// <summary>
        /// Show success toast notification
        /// </summary>
        /// <param name="message">Success message</param>
        private void ShowSuccessToast(string message)
        {
            ShowAlert(message, "success");
        }

        /// <summary>
        /// Show error toast notification
        /// </summary>
        /// <param name="message">Error message</param>
        private void ShowErrorToast(string message)
        {
            ShowAlert(message, "error");
        }

        /// <summary>
        /// Show info toast notification
        /// </summary>
        /// <param name="message">Info message</param>
        private void ShowInfoToast(string message)
        {
            ShowAlert(message, "info");
        }

        /// <summary>
        /// Show warning toast notification
        /// </summary>
        /// <param name="message">Warning message</param>
        private void ShowWarningToast(string message)
        {
            ShowAlert(message, "warning");
        }

        #endregion

        #region Pagination Helper Methods

        /// <summary>
        /// Get CSS class for pagination item
        /// </summary>
        public string GetPaginationItemClass(object dataItem)
        {
            try
            {
                var item = dataItem as dynamic;
                if (item?.IsActive == true)
                    return "active";
                
                return "";
            }
            catch
            {
                return "";
            }
        }

        /// <summary>
        /// Get pagination value
        /// </summary>
        public string GetPaginationValue(object dataItem)
        {
            try
            {
                var item = dataItem as dynamic;
                return item?.PageNumber?.ToString() ?? "1";
            }
            catch
            {
                return "1";
            }
        }

        /// <summary>
        /// Get pagination text
        /// </summary>
        public string GetPaginationText(object dataItem)
        {
            try
            {
                var item = dataItem as dynamic;
                return item?.Text?.ToString() ?? "1";
            }
            catch
            {
                return "1";
            }
        }

        #endregion

        #region Utility Methods

        /// <summary>
        /// Truncate text for display
        /// </summary>
        /// <param name="text">Text to truncate</param>
        /// <param name="maxLength">Maximum length</param>
        /// <returns>Truncated text with ellipsis if needed</returns>
        public string TruncateText(string text, int maxLength)
        {
            if (string.IsNullOrEmpty(text) || text.Length <= maxLength)
                return HttpUtility.HtmlEncode(text);

            return HttpUtility.HtmlEncode(text.Substring(0, maxLength)) + "...";
        }

        /// <summary>
        /// Get user-friendly error message
        /// </summary>
        /// <param name="errorMessage">Original error message</param>
        /// <param name="resultCode">Result code</param>
        /// <returns>User-friendly error message</returns>
        private string GetUserFriendlyErrorMessage(string errorMessage, int resultCode)
        {
            // Map common error codes to user-friendly messages
            switch (resultCode)
            {
                case -401:
                    return GetLocalizedText("AuthenticationRequired");
                case -403:
                    return GetLocalizedText("InsufficientPermissions");
                case -404:
                    return GetLocalizedText("ChatbotNotFound");
                case -409:
                    return GetLocalizedText("ChatbotNameAlreadyExists");
                default:
                    // For other errors, return localized generic message
                    return GetLocalizedText("ErrorProcessingRequest");
            }
        }

        /// <summary>
        /// Get localized text
        /// </summary>
        /// <param name="key">Resource key</param>
        /// <returns>Localized text</returns>
        protected string GetLocalizedText(string key)
        {
            try
            {
                return key;
            }
            catch
            {
                return key;
            }
        }

        #endregion

        #region Logging Methods

        /// <summary>
        /// Log information message
        /// </summary>
        /// <param name="method">Method name</param>
        /// <param name="message">Log message</param>
        private void LogInfo(string method, string message)
        {
            try
            {
                // Implement your logging mechanism here
                System.Diagnostics.Debug.WriteLine($"[INFO] ChatbotAdmin.{method}: {message}");
            }
            catch
            {
                // Ignore logging errors
            }
        }

        /// <summary>
        /// Log error message
        /// </summary>
        /// <param name="method">Method name</param>
        /// <param name="ex">Exception</param>
        private void LogError(string method, Exception ex)
        {
            try
            {
                // Implement your logging mechanism here
                System.Diagnostics.Debug.WriteLine($"[ERROR] ChatbotAdmin.{method}: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack Trace: {ex.StackTrace}");
            }
            catch
            {
                // Ignore logging errors
            }
        }

        /// <summary>
        /// Log error message
        /// </summary>
        /// <param name="method">Method name</param>
        /// <param name="message">Error message</param>
        private void LogError(string method, string message)
        {
            try
            {
                // Implement your logging mechanism here
                System.Diagnostics.Debug.WriteLine($"[ERROR] ChatbotAdmin.{method}: {message}");
            }
            catch
            {
                // Ignore logging errors
            }
        }

        #endregion

        #region Event Validation Override

        /// <summary>
        /// Override Render method to register event validation for dynamically modified controls
        /// This prevents "Invalid postback or callback argument" errors when JavaScript modifies TextBox values
        /// </summary>
        protected override void Render(HtmlTextWriter writer)
        {
            try
            {
                // Register event validation for txtColorHex which is modified by JavaScript
                // This control is modified when:
                // 1. Color input synchronization: txtColorHex.value = this.value;
                // 2. Form reset function: txtColorHex.value = '#222222';
                Page.ClientScript.RegisterForEventValidation(txtColorHex.UniqueID);
                
                // Register validation for common hex color values that might be set by JavaScript
                var commonColors = new[] 
                {
                    "#222222", "#4b4e6d", "#84dcc6", "#95a3b3", "#ffffff",
                    "#000000", "#ff0000", "#00ff00", "#0000ff", "#ffff00",
                    "#ff00ff", "#00ffff", "#800000", "#008000", "#000080",
                    "#808000", "#800080", "#008080", "#c0c0c0", "#808080"
                };
                
                foreach (var color in commonColors)
                {
                    try
                    {
                        Page.ClientScript.RegisterForEventValidation(txtColorHex.UniqueID, color);
                    }
                    catch
                    {
                        // Continue if individual registration fails
                    }
                }
            }
            catch (Exception ex)
            {
                // Log error but continue with render
                LogError("Render", ex);
            }
            
            base.Render(writer);
        }

        #endregion
    }
}
