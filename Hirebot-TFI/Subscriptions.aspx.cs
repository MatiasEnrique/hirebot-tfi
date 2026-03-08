using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using ABSTRACTIONS;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class Subscriptions : BasePage
    {
        private ProductSubscriptionSecurity _subscriptionSecurity;
        private UserSecurity _userSecurity;

        protected void Page_Load(object sender, EventArgs e)
        {
            _userSecurity = new UserSecurity();
            _userSecurity.RequireAuthentication();

            _subscriptionSecurity = new ProductSubscriptionSecurity();

            if (!IsPostBack)
            {
                PopulateExpirationFields();
                PopulateCombinedExpirationFields();
                BindProducts();
                BindSubscriptions();
                TogglePaymentPanels();
            }
        }

        protected void ddlPaymentMethod_Changed(object sender, EventArgs e)
        {
            TogglePaymentPanels();
        }

        protected void ddlMethod1_Changed(object sender, EventArgs e)
        {
            ToggleCombinedSubPanels();
        }

        protected void ddlMethod2_Changed(object sender, EventArgs e)
        {
            ToggleCombinedSubPanels();
        }

        private void TogglePaymentPanels()
        {
            string method = ddlPaymentMethod.SelectedValue;

            pnlCardFields.Visible = method == "Tarjeta";
            pnlTransferFields.Visible = method == "Transferencia";
            pnlCuentaCorriente.Visible = method == "CuentaCorriente";
            pnlCombinedFields.Visible = method == "PagoCombinado";

            // Card validators
            rfvCardholder.Enabled = method == "Tarjeta";
            rfvCardNumber.Enabled = method == "Tarjeta";
            revCardNumber.Enabled = method == "Tarjeta";
            rfvExpirationMonth.Enabled = method == "Tarjeta";
            rfvExpirationYear.Enabled = method == "Tarjeta";

            // Transfer validator
            rfvTransferReference.Enabled = method == "Transferencia";

            // Combined validators
            bool isCombined = method == "PagoCombinado";
            if (isCombined)
            {
                ToggleCombinedSubPanels();
            }
            else
            {
                rfvCombinedCardholder.Enabled = false;
                rfvCombinedCardNumber.Enabled = false;
                revCombinedCardNumber.Enabled = false;
                rfvCombinedExpirationMonth.Enabled = false;
                rfvCombinedExpirationYear.Enabled = false;
                rfvCombinedTransferRef1.Enabled = false;
                rfvCombinedTransferRef2.Enabled = false;
            }
        }

        private void ToggleCombinedSubPanels()
        {
            string m1 = ddlMethod1.SelectedValue;
            string m2 = ddlMethod2.SelectedValue;

            bool anyCard = m1 == "Tarjeta" || m2 == "Tarjeta";
            pnlCombinedCard.Visible = anyCard;
            rfvCombinedCardholder.Enabled = anyCard;
            rfvCombinedCardNumber.Enabled = anyCard;
            revCombinedCardNumber.Enabled = anyCard;
            rfvCombinedExpirationMonth.Enabled = anyCard;
            rfvCombinedExpirationYear.Enabled = anyCard;

            pnlCombinedTransfer1.Visible = m1 == "Transferencia";
            rfvCombinedTransferRef1.Enabled = m1 == "Transferencia";

            pnlCombinedTransfer2.Visible = m2 == "Transferencia";
            rfvCombinedTransferRef2.Enabled = m2 == "Transferencia";

            bool anyCuenta = (m1 == "CuentaCorriente" || m2 == "CuentaCorriente");
            pnlCombinedCuentaCorriente.Visible = anyCuenta;
        }

        protected void btnSubscribe_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
            {
                return;
            }

            if (!int.TryParse(ddlProducts.SelectedValue, out int productId) || productId <= 0)
            {
                ShowMessage(GetLocalizedString("SubscriptionProductRequired"), false);
                return;
            }

            string paymentMethod = ddlPaymentMethod.SelectedValue;
            string cardholderName = string.Empty;
            string cardNumber = string.Empty;
            int expirationMonth = 0;
            int expirationYear = 0;
            string transferReference = string.Empty;
            string secondPaymentMethod = string.Empty;
            string secondTransferReference = string.Empty;

            switch (paymentMethod)
            {
                case "Tarjeta":
                    cardholderName = txtCardholderName.Text.Trim();
                    cardNumber = txtCardNumber.Text.Trim();
                    int.TryParse(ddlExpirationMonth.SelectedValue, out expirationMonth);
                    int.TryParse(ddlExpirationYear.SelectedValue, out expirationYear);
                    break;

                case "Transferencia":
                    transferReference = txtTransferReference.Text.Trim();
                    break;

                case "CuentaCorriente":
                    break;

                case "PagoCombinado":
                    string m1 = ddlMethod1.SelectedValue;
                    string m2 = ddlMethod2.SelectedValue;
                    secondPaymentMethod = m2;

                    if (m1 == "Tarjeta" || m2 == "Tarjeta")
                    {
                        cardholderName = txtCombinedCardholderName.Text.Trim();
                        cardNumber = txtCombinedCardNumber.Text.Trim();
                        int.TryParse(ddlCombinedExpirationMonth.SelectedValue, out expirationMonth);
                        int.TryParse(ddlCombinedExpirationYear.SelectedValue, out expirationYear);

                        // If Tarjeta is the second method, swap so BLL sees Tarjeta as secondPaymentMethod
                        if (m2 == "Tarjeta")
                        {
                            secondPaymentMethod = m2;
                        }
                    }

                    if (m1 == "Transferencia")
                    {
                        transferReference = txtCombinedTransferRef1.Text.Trim();
                    }

                    if (m2 == "Transferencia")
                    {
                        secondTransferReference = txtCombinedTransferRef2.Text.Trim();
                    }

                    // If m1 is Transferencia and m2 is something else, transferReference is leg 1
                    // If m2 is Transferencia, secondTransferReference is leg 2
                    break;
            }

            var result = _subscriptionSecurity.SubscribeToProduct(
                productId, paymentMethod,
                cardholderName, cardNumber, expirationMonth, expirationYear,
                transferReference,
                secondPaymentMethod, secondTransferReference);

            if (result != null && result.IsSuccessful)
            {
                ShowMessage(result.ErrorMessage ?? GetLocalizedString("SubscriptionCreatedSuccess"), true);
                ClearForm();
                BindSubscriptions();
            }
            else
            {
                string errorMessage = result?.ErrorMessage ?? GetLocalizedString("SubscriptionCreationFailed");
                ShowMessage(errorMessage, false);
            }
        }

        protected string GetPaymentDisplay(ProductSubscription sub)
        {
            if (sub == null) return string.Empty;

            string method = sub.PaymentMethod ?? "Tarjeta";
            switch (method)
            {
                case "Tarjeta":
                    string cardDisplay = string.Format("**** **** **** {0}", HttpUtility.HtmlEncode(sub.CardLast4));
                    if (!string.IsNullOrWhiteSpace(sub.CardBrand))
                        cardDisplay += string.Format("<br/><span class='text-muted small'>{0}</span>", HttpUtility.HtmlEncode(sub.CardBrand));
                    return cardDisplay;

                case "Transferencia":
                    return string.Format("Transferencia<br/><span class='text-muted small'>Ref: {0}</span>", HttpUtility.HtmlEncode(sub.TransferReference));

                case "CuentaCorriente":
                    return "Cuenta corriente";

                case "PagoCombinado":
                    string first = GetMethodShortLabel(method, sub);
                    string second = GetMethodShortLabel(sub.SecondPaymentMethod, sub);
                    return string.Format("50% {0}<br/>50% {1}", first, second);

                default:
                    return HttpUtility.HtmlEncode(method);
            }
        }

        private string GetMethodShortLabel(string method, ProductSubscription sub)
        {
            switch (method)
            {
                case "Tarjeta":
                    string card = string.Format("**** {0}", HttpUtility.HtmlEncode(sub.CardLast4));
                    if (!string.IsNullOrWhiteSpace(sub.CardBrand))
                        card += string.Format(" ({0})", HttpUtility.HtmlEncode(sub.CardBrand));
                    return card;
                case "Transferencia":
                    return "Transferencia";
                case "CuentaCorriente":
                    return "Cuenta corriente";
                default:
                    return HttpUtility.HtmlEncode(method ?? "");
            }
        }

        protected void rptSubscriptions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            if (e.Item.DataItem is ProductSubscription subscription)
            {
                var statusBadge = e.Item.FindControl("lblStatus") as HtmlGenericControl;
                var statusDetail = e.Item.FindControl("litStatusDetail") as Literal;

                if (statusBadge != null)
                {
                    if (subscription.IsActive)
                    {
                        statusBadge.InnerText = GetLocalizedString("SubscriptionStatusActive");
                        statusBadge.Attributes["class"] = "badge bg-success-subtle text-success fw-semibold";
                    }
                    else
                    {
                        statusBadge.InnerText = GetLocalizedString("SubscriptionStatusCancelled");
                        statusBadge.Attributes["class"] = "badge bg-secondary-subtle text-secondary fw-semibold";
                    }
                }

                if (statusDetail != null)
                {
                    if (!subscription.IsActive && subscription.CancelledDateUtc.HasValue)
                    {
                        string cancelledText = string.Format(
                            CultureInfo.CurrentCulture,
                            GetLocalizedString("SubscriptionCancelledOn"),
                            subscription.CancelledDateUtc.Value.ToLocalTime().ToString("g", CultureInfo.CurrentCulture));
                        statusDetail.Text = $"<div class='text-muted small'>{HttpUtility.HtmlEncode(cancelledText)}</div>";
                    }
                    else
                    {
                        statusDetail.Text = string.Empty;
                    }
                }
            }
        }

        protected string GetCreatedDateText(object createdDate)
        {
            if (createdDate is DateTime date && date > DateTime.MinValue)
            {
                string formattedDate = date.ToLocalTime().ToString("g", CultureInfo.CurrentCulture);
                return HttpUtility.HtmlEncode(string.Format(CultureInfo.CurrentCulture, GetLocalizedString("SubscriptionCreatedOn"), formattedDate));
            }

            return string.Empty;
        }

        private void PopulateExpirationFields()
        {
            ddlExpirationMonth.Items.Clear();
            ddlExpirationMonth.Items.Add(new ListItem(GetLocalizedString("SubscriptionSelectMonth"), ""));

            var monthNames = CultureInfo.CurrentCulture.DateTimeFormat.MonthNames;
            for (int i = 1; i <= 12; i++)
            {
                string monthName = monthNames[i - 1];
                string displayText = string.Format(CultureInfo.CurrentCulture, "{0:00} - {1}", i, monthName);
                ddlExpirationMonth.Items.Add(new ListItem(displayText, i.ToString(CultureInfo.InvariantCulture)));
            }

            ddlExpirationYear.Items.Clear();
            ddlExpirationYear.Items.Add(new ListItem(GetLocalizedString("SubscriptionSelectYear"), ""));

            int currentYear = DateTime.UtcNow.Year;
            for (int offset = 0; offset <= 15; offset++)
            {
                int year = currentYear + offset;
                ddlExpirationYear.Items.Add(new ListItem(year.ToString(CultureInfo.InvariantCulture), year.ToString(CultureInfo.InvariantCulture)));
            }
        }

        private void PopulateCombinedExpirationFields()
        {
            ddlCombinedExpirationMonth.Items.Clear();
            ddlCombinedExpirationMonth.Items.Add(new ListItem(GetLocalizedString("SubscriptionSelectMonth"), ""));

            var monthNames = CultureInfo.CurrentCulture.DateTimeFormat.MonthNames;
            for (int i = 1; i <= 12; i++)
            {
                string monthName = monthNames[i - 1];
                string displayText = string.Format(CultureInfo.CurrentCulture, "{0:00} - {1}", i, monthName);
                ddlCombinedExpirationMonth.Items.Add(new ListItem(displayText, i.ToString(CultureInfo.InvariantCulture)));
            }

            ddlCombinedExpirationYear.Items.Clear();
            ddlCombinedExpirationYear.Items.Add(new ListItem(GetLocalizedString("SubscriptionSelectYear"), ""));

            int currentYear = DateTime.UtcNow.Year;
            for (int offset = 0; offset <= 15; offset++)
            {
                int year = currentYear + offset;
                ddlCombinedExpirationYear.Items.Add(new ListItem(year.ToString(CultureInfo.InvariantCulture), year.ToString(CultureInfo.InvariantCulture)));
            }
        }

        private void BindProducts()
        {
            ddlProducts.Items.Clear();
            ddlProducts.Items.Add(new ListItem(GetLocalizedString("SubscriptionSelectProduct"), string.Empty));

            List<Product> products = _subscriptionSecurity.GetActiveProductsForSubscription();

            if (products != null && products.Any())
            {
                foreach (var product in products)
                {
                    string display = string.Format(
                        CultureInfo.CurrentCulture,
                        "{0} — {1}",
                        product.Name,
                        product.Price.ToString("C", CultureInfo.CurrentCulture));

                    ddlProducts.Items.Add(new ListItem(display, product.ProductId.ToString(CultureInfo.InvariantCulture)));
                }

                ddlProducts.Enabled = true;
                btnSubscribe.Enabled = true;
            }
            else
            {
                ddlProducts.Enabled = false;
                btnSubscribe.Enabled = false;
                ShowMessage(GetLocalizedString("SubscriptionNoProductsAvailable"), false);
            }
        }

        private void BindSubscriptions()
        {
            var result = _subscriptionSecurity.GetCurrentUserSubscriptions();

            if (result != null && result.IsSuccessful && result.Data != null && result.Data.Any())
            {
                pnlNoSubscriptions.Visible = false;
                rptSubscriptions.DataSource = result.Data;
                rptSubscriptions.DataBind();
            }
            else
            {
                rptSubscriptions.DataSource = null;
                rptSubscriptions.DataBind();
                pnlNoSubscriptions.Visible = true;
            }
        }

        private void ClearForm()
        {
            txtCardholderName.Text = string.Empty;
            txtCardNumber.Text = string.Empty;
            txtTransferReference.Text = string.Empty;
            txtCombinedCardholderName.Text = string.Empty;
            txtCombinedCardNumber.Text = string.Empty;
            txtCombinedTransferRef1.Text = string.Empty;
            txtCombinedTransferRef2.Text = string.Empty;
            ddlProducts.SelectedIndex = 0;
            ddlExpirationMonth.SelectedIndex = 0;
            ddlExpirationYear.SelectedIndex = 0;
            ddlCombinedExpirationMonth.SelectedIndex = 0;
            ddlCombinedExpirationYear.SelectedIndex = 0;
            ddlPaymentMethod.SelectedIndex = 0;
            TogglePaymentPanels();
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            if (string.IsNullOrWhiteSpace(message))
            {
                lblMessage.Visible = false;
                return;
            }

            lblMessage.Text = HttpUtility.HtmlEncode(message);
            lblMessage.Visible = true;
            lblMessage.CssClass = isSuccess ? "alert d-block message-success" : "alert d-block message-error";
        }

        private string GetLocalizedString(string key)
        {
            if (string.IsNullOrWhiteSpace(key))
            {
                return string.Empty;
            }
        
            try
            {
                return System.Web.HttpContext.GetGlobalResourceObject("GlobalResources", key)?.ToString() ?? key;
            }
            catch
            {
                return key;
            }
        }
    }
}

