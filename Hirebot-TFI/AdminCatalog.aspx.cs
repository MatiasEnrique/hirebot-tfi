using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ABSTRACTIONS;
using Hirebot_TFI;
using SECURITY;

namespace UI
{
    public partial class AdminCatalog : BasePage
    {
        private AdminSecurity adminSecurity;
        
        private int SelectedProductId
        {
            get { return int.TryParse(hfSelectedProductId.Value, out int id) ? id : 0; }
            set { hfSelectedProductId.Value = value.ToString(); }
        }
        
        private int SelectedCatalogId
        {
            get { return int.TryParse(hfSelectedCatalogId.Value, out int id) ? id : 0; }
            set { hfSelectedCatalogId.Value = value.ToString(); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            adminSecurity = new AdminSecurity();
            adminSecurity.RedirectIfNotAdmin();

            if (!IsPostBack)
            {
                LoadProducts();
                LoadCatalogs();
                LoadDropDowns();
                LoadCatalogProducts();
                LoadDisplayedCatalogDropdown();
                LoadCurrentDisplayedCatalog();
                chkProductIsActive.Checked = true;
                chkCatalogIsActive.Checked = true;
                
                // Set the delete confirmation message template
                hfDeleteMessage.Value = GetLocalizedString("ConfirmDeleteProduct");
                
                // Display success message if available
                if (Session["SuccessMessage"] != null)
                {
                    ShowMessage(Session["SuccessMessage"].ToString(), "success");
                    Session.Remove("SuccessMessage");
                }
            }
        }

        protected void btnSpanish_Click(object sender, EventArgs e)
        {
            Session["Language"] = "es";
            Response.Redirect(Request.RawUrl);
        }

        protected void btnEnglish_Click(object sender, EventArgs e)
        {
            Session["Language"] = "en";
            Response.Redirect(Request.RawUrl);
        }

        protected void btnSignOut_Click(object sender, EventArgs e)
        {
            var userSecurity = new SECURITY.UserSecurity();
            userSecurity.SignOutUser();
            Response.Redirect("~/Default.aspx");
        }

        protected void btnCreateProduct_Click(object sender, EventArgs e)
        {
            try
            {
                string name = txtProductName.Text.Trim();
                string description = txtProductDescription.Text.Trim();
                decimal price = 0;
                string billingCycle = ddlBillingCycle.SelectedValue;
                int maxChatbots = 0;
                int maxMessages = 0;
                string category = ddlProductCategory.SelectedValue;
                string features = txtFeatures.Text.Trim();

                if (!decimal.TryParse(txtProductPrice.Text, out price))
                {
                    ShowMessage(GetLocalizedString("InvalidPrice"), "danger");
                    return;
                }

                if (!int.TryParse(txtMaxChatbots.Text, out maxChatbots))
                {
                    ShowMessage("Invalid Max Chatbots value", "danger");
                    return;
                }

                if (!int.TryParse(txtMaxMessages.Text, out maxMessages))
                {
                    ShowMessage("Invalid Max Messages value", "danger");
                    return;
                }

                var result = adminSecurity.CreateProduct(name, description, price, billingCycle, maxChatbots, maxMessages, features, category);
                
                if (result.IsSuccessful)
                {
                    Session["SuccessMessage"] = result.Message;
                    Response.Redirect(Request.RawUrl);
                }
                else
                {
                    ShowMessage(result.Message, "danger");
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        protected void btnUpdateProduct_Click(object sender, EventArgs e)
        {
            if (SelectedProductId == 0)
            {
                ShowMessage(GetLocalizedString("SelectProductFirst"), "warning");
                return;
            }

            try
            {
                string name = txtProductName.Text.Trim();
                string description = txtProductDescription.Text.Trim();
                decimal price = 0;
                string billingCycle = ddlBillingCycle.SelectedValue;
                int maxChatbots = 0;
                int maxMessages = 0;
                string category = ddlProductCategory.SelectedValue;
                string features = txtFeatures.Text.Trim();
                bool isActive = chkProductIsActive.Checked;

                if (!decimal.TryParse(txtProductPrice.Text, out price))
                {
                    ShowMessage(GetLocalizedString("InvalidPrice"), "danger");
                    return;
                }

                if (!int.TryParse(txtMaxChatbots.Text, out maxChatbots))
                {
                    ShowMessage("Invalid Max Chatbots value", "danger");
                    return;
                }

                if (!int.TryParse(txtMaxMessages.Text, out maxMessages))
                {
                    ShowMessage("Invalid Max Messages value", "danger");
                    return;
                }

                var result = adminSecurity.UpdateProduct(SelectedProductId, name, description, price, billingCycle, maxChatbots, maxMessages, features, category, isActive);
                
                if (result.IsSuccessful)
                {
                    Session["SuccessMessage"] = result.Message;
                    Response.Redirect(Request.RawUrl);
                }
                else
                {
                    ShowMessage(result.Message, "danger");
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        protected void btnDeleteProduct_Click(object sender, EventArgs e)
        {
            if (SelectedProductId == 0)
            {
                ShowMessage(GetLocalizedString("SelectProductFirst"), "warning");
                return;
            }

            try
            {
                var result = adminSecurity.DeleteProduct(SelectedProductId);
                
                if (result.IsSuccessful)
                {
                    ShowMessage(result.Message, "success");
                    ClearProductForm();
                    LoadProducts();
                    LoadDropDowns();
                    LoadCatalogProducts();
                    SelectedProductId = 0;
                }
                else
                {
                    ShowMessage(result.Message, "danger");
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        protected void btnCreateCatalog_Click(object sender, EventArgs e)
        {
            try
            {
                string name = txtCatalogName.Text.Trim();
                string description = txtCatalogDescription.Text.Trim();

                var result = adminSecurity.CreateCatalog(name, description);
                
                if (result.IsSuccessful)
                {
                    Session["SuccessMessage"] = result.Message;
                    Response.Redirect(Request.RawUrl);
                }
                else
                {
                    ShowMessage(result.Message, "danger");
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        protected void btnUpdateCatalog_Click(object sender, EventArgs e)
        {
            if (SelectedCatalogId == 0)
            {
                ShowMessage(GetLocalizedString("SelectCatalogFirst"), "warning");
                return;
            }

            try
            {
                string name = txtCatalogName.Text.Trim();
                string description = txtCatalogDescription.Text.Trim();
                bool isActive = chkCatalogIsActive.Checked;

                var result = adminSecurity.UpdateCatalog(SelectedCatalogId, name, description, isActive);
                
                if (result.IsSuccessful)
                {
                    Session["SuccessMessage"] = result.Message;
                    Response.Redirect(Request.RawUrl);
                }
                else
                {
                    ShowMessage(result.Message, "danger");
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        protected void btnDeleteCatalog_Click(object sender, EventArgs e)
        {
            if (SelectedCatalogId == 0)
            {
                ShowMessage(GetLocalizedString("SelectCatalogFirst"), "warning");
                return;
            }

            try
            {
                var result = adminSecurity.DeleteCatalog(SelectedCatalogId);
                
                if (result.IsSuccessful)
                {
                    Session["SuccessMessage"] = result.Message;
                    Response.Redirect(Request.RawUrl);
                }
                else
                {
                    ShowMessage(result.Message, "danger");
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        protected void btnAddProductToCatalog_Click(object sender, EventArgs e)
        {
            try
            {
                int catalogId = 0;
                int productId = 0;

                if (!int.TryParse(ddlCatalogSelect.SelectedValue, out catalogId) || catalogId == 0)
                {
                    ShowMessage(GetLocalizedString("SelectCatalogFirst"), "warning");
                    return;
                }

                if (!int.TryParse(ddlProductSelect.SelectedValue, out productId) || productId == 0)
                {
                    ShowMessage(GetLocalizedString("SelectProductFirst"), "warning");
                    return;
                }

                var result = adminSecurity.AddProductToCatalog(catalogId, productId);
                
                if (result.IsSuccessful)
                {
                    Session["SuccessMessage"] = result.Message;
                    Response.Redirect(Request.RawUrl);
                }
                else
                {
                    ShowMessage(result.Message, "danger");
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        protected void btnSetDisplayedCatalog_Click(object sender, EventArgs e)
        {
            try
            {
                int catalogId = 0;

                if (!int.TryParse(ddlDisplayedCatalog.SelectedValue, out catalogId) || catalogId == 0)
                {
                    ShowMessage(GetLocalizedString("SelectCatalogFirst"), "warning");
                    return;
                }

                // Set the displayed catalog in Application state
                Application["DisplayedCatalogId"] = catalogId;
                
                Session["SuccessMessage"] = GetLocalizedString("DisplayedCatalogUpdated");
                Response.Redirect(Request.RawUrl);
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        protected void gvProducts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditProduct")
            {
                int productId = Convert.ToInt32(e.CommandArgument);
                LoadProductForEdit(productId);
            }
            else if (e.CommandName == "DeleteProduct")
            {
                try
                {
                    int productId = Convert.ToInt32(e.CommandArgument);
                    var result = adminSecurity.DeleteProduct(productId);
                    
                    if (result.IsSuccessful)
                    {
                        Session["SuccessMessage"] = result.Message;
                        Response.Redirect(Request.RawUrl);
                    }
                    else
                    {
                        ShowMessage(result.Message, "danger");
                    }
                }
                catch (Exception ex)
                {
                    ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
                }
            }
        }

        protected void gvCatalogs_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditCatalog")
            {
                int catalogId = Convert.ToInt32(e.CommandArgument);
                LoadCatalogForEdit(catalogId);
            }
        }

        protected void gvCatalogProducts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "RemoveFromCatalog")
            {
                try
                {
                    string[] args = e.CommandArgument.ToString().Split(',');
                    int catalogId = Convert.ToInt32(args[0]);
                    int productId = Convert.ToInt32(args[1]);

                    var result = adminSecurity.RemoveProductFromCatalog(catalogId, productId);
                    
                    if (result.IsSuccessful)
                    {
                        Session["SuccessMessage"] = result.Message;
                        Response.Redirect(Request.RawUrl);
                    }
                    else
                    {
                        ShowMessage(result.Message, "danger");
                    }
                }
                catch (Exception ex)
                {
                    ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
                }
            }
        }

        private void LoadProducts()
        {
            try
            {
                var productBLL = adminSecurity.GetProductBLL();
                if (productBLL != null)
                {
                    var products = productBLL.GetAllProducts();
                    gvProducts.DataSource = products;
                    gvProducts.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        private void LoadCatalogs()
        {
            try
            {
                var catalogBLL = adminSecurity.GetCatalogBLL();
                if (catalogBLL != null)
                {
                    var catalogs = catalogBLL.GetAllCatalogs();
                    gvCatalogs.DataSource = catalogs;
                    gvCatalogs.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        private void LoadDropDowns()
        {
            try
            {
                var catalogBLL = adminSecurity.GetCatalogBLL();
                var productBLL = adminSecurity.GetProductBLL();

                if (catalogBLL != null)
                {
                    var catalogs = catalogBLL.GetActiveCatalogs();
                    ddlCatalogSelect.DataSource = catalogs;
                    ddlCatalogSelect.DataTextField = "Name";
                    ddlCatalogSelect.DataValueField = "CatalogId";
                    ddlCatalogSelect.DataBind();
                    ddlCatalogSelect.Items.Insert(0, new ListItem(GetLocalizedString("SelectCatalog"), "0"));
                }

                if (productBLL != null)
                {
                    var products = productBLL.GetActiveProducts();
                    ddlProductSelect.DataSource = products;
                    ddlProductSelect.DataTextField = "Name";
                    ddlProductSelect.DataValueField = "ProductId";
                    ddlProductSelect.DataBind();
                    ddlProductSelect.Items.Insert(0, new ListItem(GetLocalizedString("SelectProduct"), "0"));
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        private void LoadCatalogProducts()
        {
            try
            {
                var catalogBLL = adminSecurity.GetCatalogBLL();
                if (catalogBLL != null)
                {
                    var allCatalogs = catalogBLL.GetAllCatalogs();
                    var catalogProductsList = new List<dynamic>();

                    foreach (var catalog in allCatalogs)
                    {
                        var products = catalogBLL.GetProductsByCatalogId(catalog.CatalogId);
                        foreach (var product in products)
                        {
                            catalogProductsList.Add(new
                            {
                                CatalogId = catalog.CatalogId,
                                CatalogName = catalog.Name,
                                ProductId = product.ProductId,
                                ProductName = product.Name,
                                Category = product.Category,
                                Price = product.Price
                            });
                        }
                    }

                    gvCatalogProducts.DataSource = catalogProductsList;
                    gvCatalogProducts.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        private void LoadProductForEdit(int productId)
        {
            try
            {
                var productBLL = adminSecurity.GetProductBLL();
                if (productBLL != null)
                {
                    var product = productBLL.GetProductById(productId);
                    if (product != null)
                    {
                        SelectedProductId = productId;
                        txtProductName.Text = product.Name;
                        txtProductDescription.Text = product.Description;
                        txtProductPrice.Text = product.Price.ToString();
                        ddlBillingCycle.SelectedValue = product.BillingCycle ?? "Monthly";
                        txtMaxChatbots.Text = product.MaxChatbots.ToString();
                        txtMaxMessages.Text = product.MaxMessagesPerMonth.ToString();
                        ddlProductCategory.SelectedValue = product.Category ?? "Basic";
                        txtFeatures.Text = product.Features;
                        chkProductIsActive.Checked = product.IsActive;
                        
                        // Show cancel button when editing
                        btnCancelEditProduct.Visible = true;
                        
                        ShowMessage($"Editando producto: {product.Name}", "info");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        private void LoadCatalogForEdit(int catalogId)
        {
            try
            {
                var catalogBLL = adminSecurity.GetCatalogBLL();
                if (catalogBLL != null)
                {
                    var catalog = catalogBLL.GetCatalogById(catalogId);
                    if (catalog != null)
                    {
                        SelectedCatalogId = catalogId;
                        txtCatalogName.Text = catalog.Name;
                        txtCatalogDescription.Text = catalog.Description;
                        chkCatalogIsActive.Checked = catalog.IsActive;
                        
                        // Show cancel button when editing
                        btnCancelEditCatalog.Visible = true;
                        
                        ShowMessage($"Editando catálogo: {catalog.Name}", "info");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        private void ClearProductForm()
        {
            txtProductName.Text = "";
            txtProductDescription.Text = "";
            txtProductPrice.Text = "";
            ddlBillingCycle.SelectedIndex = 0;
            txtMaxChatbots.Text = "";
            txtMaxMessages.Text = "";
            ddlProductCategory.SelectedIndex = 0;
            txtFeatures.Text = "";
            chkProductIsActive.Checked = true;
            
            // Reset selection and hide cancel button
            SelectedProductId = 0;
            btnCancelEditProduct.Visible = false;
        }

        private void ClearCatalogForm()
        {
            txtCatalogName.Text = "";
            txtCatalogDescription.Text = "";
            chkCatalogIsActive.Checked = true;
            
            // Reset selection and hide cancel button
            SelectedCatalogId = 0;
            btnCancelEditCatalog.Visible = false;
        }

        private void LoadDisplayedCatalogDropdown()
        {
            try
            {
                var catalogBLL = adminSecurity.GetCatalogBLL();
                if (catalogBLL != null)
                {
                    var catalogs = catalogBLL.GetActiveCatalogs();
                    ddlDisplayedCatalog.DataSource = catalogs;
                    ddlDisplayedCatalog.DataTextField = "Name";
                    ddlDisplayedCatalog.DataValueField = "CatalogId";
                    ddlDisplayedCatalog.DataBind();
                    ddlDisplayedCatalog.Items.Insert(0, new ListItem(GetLocalizedString("SelectCatalog"), "0"));
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        private void LoadCurrentDisplayedCatalog()
        {
            try
            {
                if (Application["DisplayedCatalogId"] != null)
                {
                    if (int.TryParse(Application["DisplayedCatalogId"].ToString(), out int catalogId) && catalogId > 0)
                    {
                        var catalogBLL = adminSecurity.GetCatalogBLL();
                        if (catalogBLL != null)
                        {
                            var catalog = catalogBLL.GetCatalogById(catalogId);
                            if (catalog != null && catalog.IsActive)
                            {
                                litCurrentDisplayedCatalog.Text = catalog.Name;
                                return;
                            }
                        }
                    }
                }
                
                litCurrentDisplayedCatalog.Text = GetLocalizedString("NoCatalogDisplayed");
            }
            catch (Exception ex)
            {
                litCurrentDisplayedCatalog.Text = GetLocalizedString("NoCatalogDisplayed");
            }
        }

        protected void btnCancelEditProduct_Click(object sender, EventArgs e)
        {
            ClearProductForm();
            ShowMessage(GetLocalizedString("EditCancelled") ?? "Edit cancelled", "info");
        }

        protected void btnCancelEditCatalog_Click(object sender, EventArgs e)
        {
            ClearCatalogForm();
            ShowMessage(GetLocalizedString("EditCancelled") ?? "Edit cancelled", "info");
        }

        private void ShowMessage(string message, string type)
        {
            lblMessage.Text = $"{message}<button type=\"button\" class=\"btn-close\" data-bs-dismiss=\"alert\" aria-label=\"Close\"></button>";
            lblMessage.CssClass = $"alert alert-{type} alert-dismissible fade show";
        }

        private string GetLocalizedString(string key)
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
    }
}