using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using ABSTRACTIONS;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class AdminBilling : BasePage
    {
        private const string AlertSuccess = "success";
        private const string AlertDanger = "danger";

        private readonly BillingSecurity _billingSecurity;
        private readonly AdminSecurity _adminSecurity;

        private List<BillingItemState> BillingItemStates
        {
            get
            {
                if (!(ViewState[nameof(BillingItemStates)] is List<BillingItemState> items))
                {
                    items = new List<BillingItemState>();
                    ViewState[nameof(BillingItemStates)] = items;
                }
                return items;
            }
            set => ViewState[nameof(BillingItemStates)] = value;
        }

        private List<ProductOptionState> ProductOptions
        {
            get
            {
                if (!(ViewState[nameof(ProductOptions)] is List<ProductOptionState> products))
                {
                    products = new List<ProductOptionState>();
                    ViewState[nameof(ProductOptions)] = products;
                }

                return products;
            }
            set => ViewState[nameof(ProductOptions)] = value;
        }

        public AdminBilling()
        {
            _billingSecurity = new BillingSecurity();
            _adminSecurity = new AdminSecurity();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                _adminSecurity.RedirectIfNotAdmin();
                InitializeFilters();
                BindUsersDropdown();
                BindBillingDocuments();
                ResetCreateForm();

                hfOpenCreateModal.Value = "0";
                hfOpenViewModal.Value = "0";
            }
        }

        #region Initialization

        private void InitializeFilters()
        {
            ddlFilterType.Items.Clear();
            ddlFilterType.Items.Add(new ListItem(GetResource("AllTypes", "All types"), string.Empty));
            ddlFilterType.Items.Add(new ListItem(GetResource("DocumentTypeInvoice", "Invoice"), BillingDocumentTypes.Invoice));
            ddlFilterType.Items.Add(new ListItem(GetResource("DocumentTypeDebitNote", "Debit note"), BillingDocumentTypes.DebitNote));
            ddlFilterType.Items.Add(new ListItem(GetResource("DocumentTypeCreditNote", "Credit note"), BillingDocumentTypes.CreditNote));

            ddlFilterStatus.Items.Clear();
            ddlFilterStatus.Items.Add(new ListItem(GetResource("StatusAll", "All"), string.Empty));
            ddlFilterStatus.Items.Add(new ListItem(GetResource("StatusDraft", "Draft"), BillingDocumentStatuses.Draft));
            ddlFilterStatus.Items.Add(new ListItem(GetResource("StatusIssued", "Issued"), BillingDocumentStatuses.Issued));
            ddlFilterStatus.Items.Add(new ListItem(GetResource("StatusPaid", "Paid"), BillingDocumentStatuses.Paid));
            ddlFilterStatus.Items.Add(new ListItem(GetResource("StatusCancelled", "Cancelled"), BillingDocumentStatuses.Cancelled));

            ddlDocumentType.Items.Clear();
            ddlDocumentType.Items.Add(new ListItem(GetResource("SelectOption", "Select"), string.Empty));
            ddlDocumentType.Items.Add(new ListItem(GetResource("DocumentTypeInvoice", "Invoice"), BillingDocumentTypes.Invoice));
            ddlDocumentType.Items.Add(new ListItem(GetResource("DocumentTypeDebitNote", "Debit note"), BillingDocumentTypes.DebitNote));
            ddlDocumentType.Items.Add(new ListItem(GetResource("DocumentTypeCreditNote", "Credit note"), BillingDocumentTypes.CreditNote));

        }

        private void BindUsersDropdown()
        {
            var users = _billingSecurity.GetAssignableUsers() ?? new List<User>();
            ddlDocumentUser.Items.Clear();
            ddlDocumentUser.Items.Add(new ListItem(GetResource("SelectOption", "Select"), string.Empty));

            foreach (var user in users)
            {
                var fullName = string.Format(CultureInfo.CurrentUICulture, "{0} {1}", user.FirstName, user.LastName).Trim();
                if (string.IsNullOrWhiteSpace(fullName))
                {
                    fullName = user.Username;
                }

                ddlDocumentUser.Items.Add(new ListItem($"{fullName} ({user.Email})", user.UserId.ToString(CultureInfo.InvariantCulture)));
            }
        }

        private void BindProductOptions(bool forceReload = false)
        {
            var options = ProductOptions ?? new List<ProductOptionState>();

            if (forceReload || options.Count == 0)
            {
                var products = _billingSecurity.GetActiveProducts() ?? new List<Product>();

                options = products
                    .Where(p => p != null)
                    .Select(p => new ProductOptionState
                    {
                        ProductId = p.ProductId,
                        Name = string.IsNullOrWhiteSpace(p.Name) ? GetResource("UnknownProduct", "Unknown product") : p.Name.Trim(),
                        UnitPrice = p.Price < 0 ? 0 : p.Price,
                        Description = string.IsNullOrWhiteSpace(p.Description) ? null : p.Description.Trim()
                    })
                    .OrderBy(p => p.Name, StringComparer.CurrentCultureIgnoreCase)
                    .ToList();

                ProductOptions = options;
            }

            var previousValue = ddlItemProduct.SelectedValue;

            ddlItemProduct.Items.Clear();
            ddlItemProduct.Items.Add(new ListItem(GetResource("SelectProductOption", "Select a product"), string.Empty));

            foreach (var option in options)
            {
                var displayText = string.Format(CultureInfo.CurrentCulture, "{0} - {1}", option.Name, option.UnitPrice.ToString("C2", CultureInfo.CurrentCulture));
                ddlItemProduct.Items.Add(new ListItem(displayText, option.ProductId.ToString(CultureInfo.InvariantCulture)));
            }

            if (!string.IsNullOrWhiteSpace(previousValue))
            {
                var previousItem = ddlItemProduct.Items.FindByValue(previousValue);
                if (previousItem != null)
                {
                    ddlItemProduct.ClearSelection();
                    previousItem.Selected = true;
                }
            }
        }

        private ProductOptionState GetSelectedProductOption()
        {
            if (string.IsNullOrWhiteSpace(ddlItemProduct.SelectedValue))
            {
                return null;
            }

            if (int.TryParse(ddlItemProduct.SelectedValue, out var productId))
            {
                return ProductOptions.FirstOrDefault(p => p.ProductId == productId);
            }

            return null;
        }

        private void UpdateSelectedProductFields(ProductOptionState option)
        {
            txtItemDescription.Text = option != null ? option.Name : string.Empty;
        }

        #endregion

        #region Binding helpers

        private void BindBillingDocuments()
        {
            HideAlert();

            var criteria = new BillingDocumentSearchCriteria
            {
                DocumentType = string.IsNullOrWhiteSpace(ddlFilterType.SelectedValue) ? null : ddlFilterType.SelectedValue,
                Status = string.IsNullOrWhiteSpace(ddlFilterStatus.SelectedValue) ? null : ddlFilterStatus.SelectedValue,
                DocumentNumber = string.IsNullOrWhiteSpace(txtFilterDocumentNumber.Text) ? null : txtFilterDocumentNumber.Text.Trim()
            };

            if (DateTime.TryParse(txtFilterFromDate.Text, CultureInfo.CurrentCulture, DateTimeStyles.AssumeLocal, out var fromDate))
            {
                criteria.FromIssueDateUtc = fromDate;
            }

            if (DateTime.TryParse(txtFilterToDate.Text, CultureInfo.CurrentCulture, DateTimeStyles.AssumeLocal, out var toDate))
            {
                criteria.ToIssueDateUtc = toDate;
            }

            var assignableUsers = _billingSecurity.GetAssignableUsers() ?? new List<User>();

            int? filterUserId = null;
            var userFilter = txtFilterUser.Text?.Trim();
            if (!string.IsNullOrWhiteSpace(userFilter))
            {
                var match = assignableUsers.FirstOrDefault(u =>
                    u.Email.Equals(userFilter, StringComparison.OrdinalIgnoreCase) ||
                    u.Username.Equals(userFilter, StringComparison.OrdinalIgnoreCase) ||
                    ($"{u.FirstName} {u.LastName}".Trim()).Equals(userFilter, StringComparison.OrdinalIgnoreCase));

                if (match != null)
                {
                    filterUserId = match.UserId;
                    criteria.UserId = match.UserId;
                }
            }

            var result = _billingSecurity.SearchDocuments(criteria);

            if (result.IsSuccessful)
            {
                var userLookup = assignableUsers.ToDictionary(u => u.UserId, u => u);
                var unknownUserLabel = GetResource("UnknownUser", "Unknown user");

                var viewModels = (result.Data ?? new List<BillingDocument>())
                    .Where(doc => !filterUserId.HasValue || doc.UserId == filterUserId.Value)
                    .Select(doc => new BillingDocumentViewModel(doc, userLookup, unknownUserLabel, GetDocumentTypeDisplay))
                    .ToList();

                gvBilling.DataSource = viewModels;
                gvBilling.DataBind();

                litBillingCount.Text = string.Format(CultureInfo.CurrentUICulture,
                    GetResource("BillingCountSummary", "{0} documents found"),
                    viewModels.Count);
            }
            else
            {
                gvBilling.DataSource = null;
                gvBilling.DataBind();
                litBillingCount.Text = string.Format(CultureInfo.CurrentUICulture,
                    GetResource("BillingCountSummary", "{0} documents found"),
                    0);
                ShowAlert(AlertDanger, result.ErrorMessage ?? GetResource("BillingLoadError", "Unable to load billing documents."));
            }
        }

        #endregion

        #region Event handlers - Filters

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindBillingDocuments();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ddlFilterType.SelectedIndex = 0;
            ddlFilterStatus.SelectedIndex = 0;
            txtFilterUser.Text = string.Empty;
            txtFilterDocumentNumber.Text = string.Empty;
            txtFilterFromDate.Text = string.Empty;
            txtFilterToDate.Text = string.Empty;
            BindBillingDocuments();
        }

        #endregion

        #region Event handlers - Billing grid

        protected void gvBilling_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!int.TryParse(Convert.ToString(e.CommandArgument, CultureInfo.InvariantCulture), out int billingDocumentId))
            {
                return;
            }

            switch (e.CommandName)
            {
                case "ViewDocument":
                    ShowDocumentDetails(billingDocumentId);
                    break;
                case "MarkIssued":
                    UpdateDocumentStatus(billingDocumentId, BillingDocumentStatuses.Issued);
                    break;
                case "MarkPaid":
                    UpdateDocumentStatus(billingDocumentId, BillingDocumentStatuses.Paid);
                    break;
                case "CancelDocument":
                    UpdateDocumentStatus(billingDocumentId, BillingDocumentStatuses.Cancelled);
                    break;
            }
        }

        protected void gvBilling_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow)
            {
                return;
            }

            var data = (BillingDocumentViewModel)e.Row.DataItem;

            var lblIssue = e.Row.FindControl("lblIssueDate") as Label;
            if (lblIssue != null)
            {
                lblIssue.Text = data.IssueDateUtc.ToLocalTime().ToString("g", CultureInfo.CurrentUICulture);
            }

            var lblDue = e.Row.FindControl("lblDueDate") as Label;
            if (lblDue != null)
            {
                lblDue.Text = data.DueDateUtc.HasValue
                    ? data.DueDateUtc.Value.ToLocalTime().ToString("d", CultureInfo.CurrentUICulture)
                    : GetResource("NoDueDate", "No due date");
            }

            var badgeStatus = e.Row.FindControl("badgeStatus") as HtmlGenericControl;
            if (badgeStatus != null)
            {
                switch (data.Status)
                {
                    case BillingDocumentStatuses.Issued:
                        badgeStatus.Attributes["class"] = "badge-status bg-info-subtle text-info";
                        badgeStatus.InnerText = GetResource("StatusIssued", "Issued");
                        break;
                    case BillingDocumentStatuses.Paid:
                        badgeStatus.Attributes["class"] = "badge-status bg-success-subtle text-success";
                        badgeStatus.InnerText = GetResource("StatusPaid", "Paid");
                        break;
                    case BillingDocumentStatuses.Cancelled:
                        badgeStatus.Attributes["class"] = "badge-status bg-danger-subtle text-danger";
                        badgeStatus.InnerText = GetResource("StatusCancelled", "Cancelled");
                        break;
                    default:
                        badgeStatus.Attributes["class"] = "badge-status bg-warning-subtle text-warning";
                        badgeStatus.InnerText = GetResource("StatusDraft", "Draft");
                        break;
                }
            }

            var lnkMarkIssued = e.Row.FindControl("lnkMarkIssued") as LinkButton;
            var lnkMarkPaid = e.Row.FindControl("lnkMarkPaid") as LinkButton;
            var lnkCancel = e.Row.FindControl("lnkCancel") as LinkButton;

            if (lnkMarkIssued != null)
            {
                lnkMarkIssued.Enabled = !data.Status.Equals(BillingDocumentStatuses.Issued, StringComparison.OrdinalIgnoreCase) &&
                                        !data.Status.Equals(BillingDocumentStatuses.Paid, StringComparison.OrdinalIgnoreCase) &&
                                        !data.Status.Equals(BillingDocumentStatuses.Cancelled, StringComparison.OrdinalIgnoreCase);
                if (!lnkMarkIssued.Enabled)
                {
                    lnkMarkIssued.CssClass = "btn btn-sm btn-outline-secondary me-1 disabled";
                }
            }

            if (lnkMarkPaid != null)
            {
                lnkMarkPaid.Enabled = !data.Status.Equals(BillingDocumentStatuses.Paid, StringComparison.OrdinalIgnoreCase) &&
                                      !data.Status.Equals(BillingDocumentStatuses.Cancelled, StringComparison.OrdinalIgnoreCase);
                if (!lnkMarkPaid.Enabled)
                {
                    lnkMarkPaid.CssClass = "btn btn-sm btn-outline-secondary me-1 disabled";
                }
            }

            if (lnkCancel != null)
            {
                lnkCancel.Enabled = !data.Status.Equals(BillingDocumentStatuses.Cancelled, StringComparison.OrdinalIgnoreCase) &&
                                    !data.Status.Equals(BillingDocumentStatuses.Paid, StringComparison.OrdinalIgnoreCase);
                if (!lnkCancel.Enabled)
                {
                    lnkCancel.CssClass = "btn btn-sm btn-outline-secondary disabled";
                }
            }
        }

        private void UpdateDocumentStatus(int billingDocumentId, string newStatus)
        {
            var result = _billingSecurity.UpdateStatus(billingDocumentId, newStatus);
            if (result.IsSuccessful)
            {
                ShowAlert(AlertSuccess, result.ErrorMessage ?? GetResource("StatusUpdated", "Status updated."));
                BindBillingDocuments();
            }
            else
            {
                ShowAlert(AlertDanger, result.ErrorMessage ?? GetResource("StatusUpdateError", "Unable to update status."));
            }
        }

        private void ShowDocumentDetails(int billingDocumentId)
        {
            var result = _billingSecurity.GetDocumentById(billingDocumentId);
            if (!result.IsSuccessful || result.Data == null)
            {
                ShowAlert(AlertDanger, result.ErrorMessage ?? GetResource("DocumentLoadError", "Unable to load billing document."));
                return;
            }

            var document = result.Data;
            var users = _billingSecurity.GetAssignableUsers() ?? new List<User>();
            var user = users.FirstOrDefault(u => u.UserId == document.UserId);
            var userName = user != null
                ? string.Format(CultureInfo.CurrentUICulture, "{0} {1} ({2})", user.FirstName, user.LastName, user.Email).Trim()
                : GetResource("UnknownUser", "Unknown user");

            litViewTitle.Text = HttpUtility.HtmlEncode(string.Format(CultureInfo.CurrentUICulture, "{0} - {1}", document.DocumentNumber, GetDocumentTypeDisplay(document.DocumentType)));

            var issueDate = document.IssueDateUtc.ToLocalTime().ToString("f", CultureInfo.CurrentUICulture);
            var statusDisplay = GetStatusDisplay(document.Status);

            litViewHeader.Text = string.Format(CultureInfo.CurrentUICulture,
                "<div class='small text-muted'><strong>{0}</strong>: {1}<br/><strong>{2}</strong>: {3}<br/><strong>{4}</strong>: {5}</div>",
                HttpUtility.HtmlEncode(GetResource("User", "User")),
                HttpUtility.HtmlEncode(userName),
                HttpUtility.HtmlEncode(GetResource("IssueDate", "Issue date")),
                HttpUtility.HtmlEncode(issueDate),
                HttpUtility.HtmlEncode(GetResource("Status", "Status")),
                HttpUtility.HtmlEncode(statusDisplay));

            rptViewItems.DataSource = document.Items ?? new List<BillingDocumentItem>();
            rptViewItems.DataBind();

            litViewSubtotal.Text = document.SubtotalAmount.ToString("C2", CultureInfo.CurrentCulture);
            litViewTax.Text = document.TaxAmount.ToString("C2", CultureInfo.CurrentCulture);
            litViewTotal.Text = document.TotalAmount.ToString("C2", CultureInfo.CurrentCulture);

            hfOpenViewModal.Value = "1";
        }

        #endregion

        #region Event handlers - Create document modal

        protected void ddlItemProduct_SelectedIndexChanged(object sender, EventArgs e)
        {
            var selectedOption = GetSelectedProductOption();
            UpdateSelectedProductFields(selectedOption);
            hfOpenCreateModal.Value = "1";
        }

        protected void btnAddItem_Click(object sender, EventArgs e)
        {
            hfOpenCreateModal.Value = "1";
            lblCreateError.Visible = false;
            lblCreateError.Text = string.Empty;

            if (!TryParseItem(out var item, out string errorMessage))
            {
                lblCreateError.Visible = true;
                lblCreateError.Text = errorMessage;
                UpdateItemsDisplay();
                return;
            }

            var items = BillingItemStates;
            items.Add(item);
            BillingItemStates = items;

            ClearItemInputs();
            UpdateItemsDisplay();
        }

        protected void rptItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!e.CommandName.Equals("RemoveItem", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            if (int.TryParse(Convert.ToString(e.CommandArgument, CultureInfo.InvariantCulture), out int index))
            {
                var items = BillingItemStates;
                if (index >= 0 && index < items.Count)
                {
                    items.RemoveAt(index);
                    BillingItemStates = items;
                }
                UpdateItemsDisplay();
            }

            hfOpenCreateModal.Value = "1";
        }

        protected void btnCreateDocument_Click(object sender, EventArgs e)
        {
            var itemStates = BillingItemStates;
            if (itemStates == null || itemStates.Count == 0)
            {
                lblCreateError.Visible = true;
                lblCreateError.Text = GetResource("ValidationAtLeastOneItem", "You must add at least one line item.");
                hfOpenCreateModal.Value = "1";
                UpdateItemsDisplay();
                return;
            }

            if (!int.TryParse(ddlDocumentUser.SelectedValue, out int userId))
            {
                lblCreateError.Visible = true;
                lblCreateError.Text = GetResource("ValidationUserRequired", "A user must be selected.");
                hfOpenCreateModal.Value = "1";
                UpdateItemsDisplay();
                return;
            }

            var document = new BillingDocument
            {
                DocumentType = ddlDocumentType.SelectedValue,
                DocumentNumber = string.IsNullOrWhiteSpace(txtDocumentNumber.Text) ? null : txtDocumentNumber.Text.Trim(),
                UserId = userId,
                Notes = string.IsNullOrWhiteSpace(txtNotes.Text) ? null : txtNotes.Text.Trim(),
                Items = itemStates
                    .Where(state => state != null)
                    .Select(ConvertToBillingDocumentItem)
                    .Where(item => item != null)
                    .ToList()
            };

            if (DateTime.TryParse(txtIssueDate.Text, CultureInfo.CurrentCulture, DateTimeStyles.AssumeLocal, out var issueDate))
            {
                document.IssueDateUtc = issueDate.ToUniversalTime();
            }

            if (DateTime.TryParse(txtDueDate.Text, CultureInfo.CurrentCulture, DateTimeStyles.AssumeLocal, out var dueDate))
            {
                document.DueDateUtc = dueDate.ToUniversalTime();
            }

            var result = _billingSecurity.CreateDocument(document);
            if (result.IsSuccessful)
            {
                ShowAlert(AlertSuccess, result.ErrorMessage ?? GetResource("DocumentCreated", "Billing document created successfully."));
                ResetCreateForm();
                BindBillingDocuments();
                hfOpenCreateModal.Value = "0";
            }
            else
            {
                lblCreateError.Visible = true;
                lblCreateError.Text = result.ErrorMessage ?? GetResource("DocumentCreateError", "Unable to create billing document.");
                UpdateItemsDisplay();
                hfOpenCreateModal.Value = "1";
            }
        }

        #endregion

        #region Helpers

        private bool TryParseItem(out BillingItemState item, out string errorMessage)
        {
            item = null;
            errorMessage = string.Empty;

            BindProductOptions();

            var selectedProduct = GetSelectedProductOption();
            if (selectedProduct == null)
            {
                errorMessage = GetResource("ValidationItemProduct", "You must select a product.");
                return false;
            }

            if (!decimal.TryParse(txtItemQuantity.Text, NumberStyles.Number, CultureInfo.CurrentCulture, out var quantity) || quantity <= 0)
            {
                errorMessage = GetResource("ValidationItemQuantity", "Quantity must be greater than zero.");
                return false;
            }

            var unitPrice = selectedProduct.UnitPrice < 0 ? 0 : selectedProduct.UnitPrice;
            txtItemDescription.Text = selectedProduct.Name;

            if (!decimal.TryParse(txtItemTax.Text, NumberStyles.Number, CultureInfo.CurrentCulture, out var taxRate) || taxRate < 0)
            {
                errorMessage = GetResource("ValidationItemTaxRate", "Tax rate must be zero or positive.");
                return false;
            }

            var subtotal = Math.Round(quantity * unitPrice, 2, MidpointRounding.AwayFromZero);
            var taxAmount = Math.Round(subtotal * (taxRate / 100m), 2, MidpointRounding.AwayFromZero);
            var total = Math.Round(subtotal + taxAmount, 2, MidpointRounding.AwayFromZero);

            item = new BillingItemState
            {
                ProductId = selectedProduct.ProductId,
                ProductName = selectedProduct.Name,
                Description = selectedProduct.Name,
                Quantity = quantity,
                UnitPrice = unitPrice,
                TaxRate = taxRate,
                LineSubtotal = subtotal,
                LineTaxAmount = taxAmount,
                LineTotal = total
            };

            return true;
        }

        private void ClearItemInputs()
        {
            if (ddlItemProduct.Items.Count > 0)
            {
                ddlItemProduct.SelectedIndex = 0;
            }
            txtItemDescription.Text = string.Empty;
            txtItemQuantity.Text = string.Empty;
            txtItemTax.Text = string.Empty;
        }

        private void UpdateItemsDisplay()
        {
            var items = BillingItemStates ?? new List<BillingItemState>();
            rptItems.DataSource = items;
            rptItems.DataBind();

            var subtotal = items.Sum(i => i.LineSubtotal);
            var tax = items.Sum(i => i.LineTaxAmount);
            var total = items.Sum(i => i.LineTotal);

            litSubtotal.Text = subtotal.ToString("C2", CultureInfo.CurrentCulture);
            litTax.Text = tax.ToString("C2", CultureInfo.CurrentCulture);
            litTotal.Text = total.ToString("C2", CultureInfo.CurrentCulture);
        }

        private void ResetCreateForm()
        {
            BindProductOptions(forceReload: true);
            ddlDocumentType.SelectedIndex = 0;
            ddlDocumentUser.SelectedIndex = 0;
            txtDocumentNumber.Text = string.Empty;
            txtIssueDate.Text = DateTime.UtcNow.ToLocalTime().ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            txtDueDate.Text = string.Empty;
            txtNotes.Text = string.Empty;
            ClearItemInputs();
            lblCreateError.Visible = false;
            lblCreateError.Text = string.Empty;
            BillingItemStates = new List<BillingItemState>();
            UpdateItemsDisplay();
        }

        private static BillingDocumentItem ConvertToBillingDocumentItem(BillingItemState state)
        {
            if (state == null)
            {
                return null;
            }

            return new BillingDocumentItem
            {
                ProductId = state.ProductId,
                Description = state.Description,
                Quantity = state.Quantity,
                UnitPrice = state.UnitPrice,
                TaxRate = state.TaxRate,
                LineSubtotal = state.LineSubtotal,
                LineTaxAmount = state.LineTaxAmount,
                LineTotal = state.LineTotal
            };
        }

        private void ShowAlert(string alertType, string message)
        {
            pnlAlert.Visible = true;
            pnlAlert.CssClass = $"alert alert-{alertType} alert-dismissible fade show";
            lblAlert.Text = HttpUtility.HtmlEncode(message);
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowBillingAlert", $"showAlert('{alertType}');", true);
        }

        private void HideAlert()
        {
            pnlAlert.Visible = false;
            lblAlert.Text = string.Empty;
        }

        private string GetResource(string key, string fallback)
        {
            return fallback;
        }

        private string GetDocumentTypeDisplay(string documentType)
        {
            if (string.IsNullOrWhiteSpace(documentType))
            {
                return GetResource("DocumentTypeUnknown", "Unknown");
            }

            switch (documentType)
            {
                case BillingDocumentTypes.Invoice:
                    return GetResource("DocumentTypeInvoice", "Invoice");
                case BillingDocumentTypes.DebitNote:
                    return GetResource("DocumentTypeDebitNote", "Debit note");
                case BillingDocumentTypes.CreditNote:
                    return GetResource("DocumentTypeCreditNote", "Credit note");
                default:
                    return documentType;
            }
        }

        private string GetStatusDisplay(string status)
        {
            if (string.IsNullOrWhiteSpace(status))
            {
                return GetResource("StatusDraft", "Draft");
            }

            switch (status)
            {
                case BillingDocumentStatuses.Issued:
                    return GetResource("StatusIssued", "Issued");
                case BillingDocumentStatuses.Paid:
                    return GetResource("StatusPaid", "Paid");
                case BillingDocumentStatuses.Cancelled:
                    return GetResource("StatusCancelled", "Cancelled");
                default:
                    return GetResource("StatusDraft", "Draft");
            }
        }

        private class BillingDocumentViewModel
        {
            public BillingDocumentViewModel(BillingDocument document, Dictionary<int, User> userLookup, string unknownUserLabel, Func<string, string> documentTypeResolver)
            {
                BillingDocumentId = document.BillingDocumentId;
                DocumentNumber = document.DocumentNumber;
                DocumentType = document.DocumentType;
                DocumentTypeDisplay = documentTypeResolver != null ? documentTypeResolver(document.DocumentType) : document.DocumentType;
                IssueDateUtc = document.IssueDateUtc;
                DueDateUtc = document.DueDateUtc;
                Status = document.Status;
                SubtotalAmount = document.SubtotalAmount;
                TaxAmount = document.TaxAmount;
                TotalAmount = document.TotalAmount;

                if (userLookup != null && userLookup.TryGetValue(document.UserId, out var user))
                {
                    UserDisplay = string.Format(CultureInfo.CurrentUICulture, "{0} {1}", user.FirstName, user.LastName).Trim();
                    if (string.IsNullOrWhiteSpace(UserDisplay))
                    {
                        UserDisplay = user.Username;
                    }
                    UserEmail = user.Email;
                }
                else
                {
                    UserDisplay = unknownUserLabel;
                    UserEmail = string.Empty;
                }
            }

            public int BillingDocumentId { get; }
            public string DocumentNumber { get; }
            public string DocumentType { get; }
            public string DocumentTypeDisplay { get; }
            public DateTime IssueDateUtc { get; }
            public DateTime? DueDateUtc { get; }
            public string Status { get; }
            public decimal SubtotalAmount { get; }
            public decimal TaxAmount { get; }
            public decimal TotalAmount { get; }
            public string UserDisplay { get; }
            public string UserEmail { get; }
        }

        [Serializable]
        private class ProductOptionState
        {
            public int ProductId { get; set; }
            public string Name { get; set; }
            public decimal UnitPrice { get; set; }
            public string Description { get; set; }
        }

        [Serializable]
        private class BillingItemState
        {
            public int ProductId { get; set; }
            public string ProductName { get; set; }
            public string Description { get; set; }
            public decimal Quantity { get; set; }
            public decimal UnitPrice { get; set; }
            public decimal TaxRate { get; set; }
            public decimal LineSubtotal { get; set; }
            public decimal LineTaxAmount { get; set; }
            public decimal LineTotal { get; set; }
        }

        #endregion
    }
}
