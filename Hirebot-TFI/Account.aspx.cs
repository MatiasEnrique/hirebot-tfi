using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;
using ABSTRACTIONS;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class Account : BasePage
    {
        private UserSecurity userSecurity;

        protected void Page_Load(object sender, EventArgs e)
        {
            userSecurity = new UserSecurity();
            userSecurity.RequireAuthentication();

            pnlAlert.Visible = false;

            txtChatInputPlaceholder.Attributes["placeholder"] = GetLocalizedText("AccountChatInputPlaceholder");

            if (!IsPostBack)
            {
                BindDashboard();
            }
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            var result = userSecurity.UpdateCurrentUserProfile(txtFirstName.Text, txtLastName.Text, txtEmail.Text);
            ShowAlert(result.ErrorMessage, result.IsSuccessful);

            if (result.IsSuccessful)
            {
                BindDashboard();
            }
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            var result = userSecurity.ChangeCurrentUserPassword(txtCurrentPassword.Text, txtNewPassword.Text, txtConfirmPassword.Text);
            ShowAlert(result.ErrorMessage, result.IsSuccessful);

            if (result.IsSuccessful)
            {
                txtCurrentPassword.Text = string.Empty;
                txtNewPassword.Text = string.Empty;
                txtConfirmPassword.Text = string.Empty;
            }
        }

        protected void rptSubscriptions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (string.Equals(e.CommandName, "CancelSubscription", StringComparison.OrdinalIgnoreCase))
            {
                if (!int.TryParse(e.CommandArgument?.ToString(), out var subscriptionId))
                {
                    ShowAlert(GetLocalizedText("SubscriptionCancelError"), false);
                    return;
                }

                var result = userSecurity.CancelCurrentUserSubscription(subscriptionId);
                ShowAlert(result.ErrorMessage, result.IsSuccessful);

                if (result.IsSuccessful)
                {
                    BindDashboard();
                }
            }
        }

        protected void rptSubscriptions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            if (e.Item.FindControl("btnCancelSubscription") is LinkButton btnCancel && btnCancel.Visible)
            {
                string confirmText = GetLocalizedText("AccountSubscriptionCancelConfirm");
                string encoded = HttpUtility.JavaScriptStringEncode(confirmText ?? string.Empty);
                btnCancel.OnClientClick = string.IsNullOrWhiteSpace(encoded)
                    ? null
                    : $"return confirm('{encoded}');";
            }
        }

        protected string GetLocalizedText(string key)
        {
            return HttpContext.GetGlobalResourceObject("GlobalResources", key)?.ToString() ?? key;
        }

        protected string FormatDateTime(object value)
        {
            if (value == null || value == DBNull.Value)
            {
                return GetLocalizedText("AccountNotAvailable");
            }

            DateTime dateTime;
            if (value is DateTime dt)
            {
                dateTime = dt;
            }
            else if (!DateTime.TryParse(Convert.ToString(value, CultureInfo.InvariantCulture), CultureInfo.InvariantCulture, DateTimeStyles.AssumeUniversal, out dateTime))
            {
                return GetLocalizedText("AccountNotAvailable");
            }

            if (dateTime.Kind == DateTimeKind.Utc)
            {
                dateTime = dateTime.ToLocalTime();
            }

            return dateTime.ToString("g", CultureInfo.CurrentUICulture);
        }

        protected string FormatCurrency(object amount, object currencyCode)
        {
            if (amount == null || amount == DBNull.Value)
            {
                return string.Empty;
            }

            if (!decimal.TryParse(Convert.ToString(amount, CultureInfo.InvariantCulture), NumberStyles.Any, CultureInfo.InvariantCulture, out var total))
            {
                return string.Empty;
            }

            string code = Convert.ToString(currencyCode, CultureInfo.InvariantCulture) ?? string.Empty;

            if (string.IsNullOrWhiteSpace(code))
            {
                return HttpUtility.HtmlEncode(total.ToString("C2", CultureInfo.CurrentUICulture));
            }

            var formatted = string.Format(CultureInfo.CurrentUICulture, "{0} {1:N2}", code.Trim(), total);
            return HttpUtility.HtmlEncode(formatted);
        }

        protected string FormatSubscriptionPrice(object billingCycle, object productPrice)
        {
            string cycleText = HttpUtility.HtmlEncode(Convert.ToString(billingCycle, CultureInfo.InvariantCulture) ?? string.Empty);
            string priceText = FormatCurrency(productPrice, null);

            string format = GetLocalizedText("AccountSubscriptionPriceFormat");
            if (string.IsNullOrWhiteSpace(format) || format == "AccountSubscriptionPriceFormat")
            {
                format = "{0} - {1}";
            }

            return string.Format(CultureInfo.CurrentUICulture, format, cycleText, priceText);
        }

        protected string FormatSubscriptionCard(object cardBrand, object cardLast4)
        {
            string brandText = HttpUtility.HtmlEncode(Convert.ToString(cardBrand, CultureInfo.InvariantCulture) ?? string.Empty);
            string last4Text = HttpUtility.HtmlEncode(Convert.ToString(cardLast4, CultureInfo.InvariantCulture) ?? string.Empty);

            string mask = GetLocalizedText("AccountSubscriptionCardMask");
            if (string.IsNullOrWhiteSpace(mask) || mask == "AccountSubscriptionCardMask")
            {
                mask = "****";
            }

            string format = GetLocalizedText("AccountSubscriptionCardFormat");
            if (string.IsNullOrWhiteSpace(format) || format == "AccountSubscriptionCardFormat")
            {
                format = "{0} {1} {2}";
            }

            return string.Format(CultureInfo.CurrentUICulture, format, brandText, mask, last4Text);
        }

        private void BindDashboard()
        {
            var dashboardResult = userSecurity.GetCurrentUserAccountDashboard();
            if (!dashboardResult.IsSuccessful || dashboardResult.Data == null || dashboardResult.Data.Profile == null)
            {
                var message = string.IsNullOrWhiteSpace(dashboardResult.ErrorMessage)
                    ? GetLocalizedText("AccountLoadError")
                    : dashboardResult.ErrorMessage;
                ShowAlert(message, false);
                return;
            }

            var profile = dashboardResult.Data.Profile;
            litFullName.Text = HttpUtility.HtmlEncode(profile.FullName);
            litEmail.Text = HttpUtility.HtmlEncode(profile.Email);
            litUsername.Text = HttpUtility.HtmlEncode(profile.Username);
            litCreatedDate.Text = FormatDateTime(profile.CreatedDate);
            litLastLogin.Text = profile.LastLoginDate.HasValue
                ? FormatDateTime(profile.LastLoginDate.Value)
                : GetLocalizedText("AccountNeverLoggedIn");

            txtFirstName.Text = profile.FirstName;
            txtLastName.Text = profile.LastName;
            txtEmail.Text = profile.Email;

            var subscriptions = dashboardResult.Data.Subscriptions ?? new List<ProductSubscription>();
            rptSubscriptions.Visible = subscriptions.Count > 0;
            rptSubscriptions.DataSource = subscriptions;
            rptSubscriptions.DataBind();
            pnlNoSubscriptions.Visible = subscriptions.Count == 0;

            var billingDocuments = dashboardResult.Data.BillingDocuments ?? new List<BillingDocumentSummary>();
            rptBillingDocuments.Visible = billingDocuments.Count > 0;
            rptBillingDocuments.DataSource = billingDocuments;
            rptBillingDocuments.DataBind();
            pnlNoBillingDocuments.Visible = billingDocuments.Count == 0;

            UpdateBillingSummary(billingDocuments);
        }

        private void ShowAlert(string message, bool success)
        {
            pnlAlert.Visible = true;
            pnlAlert.CssClass = success ? "alert alert-success" : "alert alert-danger";

            string displayMessage = string.IsNullOrWhiteSpace(message)
                ? GetLocalizedText(success ? "AccountActionSuccess" : "AccountActionError")
                : message;

            litAlertText.Text = HttpUtility.HtmlEncode(displayMessage);
        }

        private void UpdateBillingSummary(List<BillingDocumentSummary> billingDocuments)
        {
            billingDocuments = billingDocuments ?? new List<BillingDocumentSummary>();

            decimal invoiceTotal = billingDocuments
                .Where(d => string.Equals(d.DocumentType, BillingDocumentTypes.Invoice, StringComparison.OrdinalIgnoreCase))
                .Sum(d => d.TotalAmount);

            decimal debitNoteTotal = billingDocuments
                .Where(d => string.Equals(d.DocumentType, BillingDocumentTypes.DebitNote, StringComparison.OrdinalIgnoreCase))
                .Sum(d => d.TotalAmount);

            decimal creditNoteTotal = billingDocuments
                .Where(d => string.Equals(d.DocumentType, BillingDocumentTypes.CreditNote, StringComparison.OrdinalIgnoreCase))
                .Sum(d => d.TotalAmount);

            decimal balance = invoiceTotal + debitNoteTotal - creditNoteTotal;

            string currencyCode = billingDocuments
                .FirstOrDefault(d => !string.IsNullOrWhiteSpace(d.CurrencyCode))?.CurrencyCode;

            litInvoiceTotal.Text = FormatCurrency(invoiceTotal, currencyCode);
            litDebitNoteTotal.Text = FormatCurrency(debitNoteTotal, currencyCode);
            litCreditNoteTotal.Text = creditNoteTotal > 0
                ? FormatCurrency(creditNoteTotal * -1m, currencyCode)
                : FormatCurrency(0m, currencyCode);
            litBillingBalance.Text = FormatCurrency(balance, currencyCode);
        }
    }
}
