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
                BindProducts();
                BindSubscriptions();
            }
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

            string cardholderName = txtCardholderName.Text.Trim();
            string cardNumber = txtCardNumber.Text.Trim();

            if (!int.TryParse(ddlExpirationMonth.SelectedValue, out int expirationMonth) || expirationMonth <= 0)
            {
                ShowMessage(GetLocalizedString("SubscriptionExpirationRequired"), false);
                return;
            }

            if (!int.TryParse(ddlExpirationYear.SelectedValue, out int expirationYear) || expirationYear <= 0)
            {
                ShowMessage(GetLocalizedString("SubscriptionExpirationRequired"), false);
                return;
            }

            var result = _subscriptionSecurity.SubscribeToProduct(productId, cardholderName, cardNumber, expirationMonth, expirationYear);

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
            ddlProducts.SelectedIndex = 0;
            ddlExpirationMonth.SelectedIndex = 0;
            ddlExpirationYear.SelectedIndex = 0;
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
