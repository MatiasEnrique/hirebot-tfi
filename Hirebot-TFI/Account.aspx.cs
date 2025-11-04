using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
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

            if (!IsPostBack)
            {
                BindDashboard();
                InitializeChatHistory();
            }
            else
            {
                LoadChatHistory();
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
            else if (string.Equals(e.CommandName, "SaveFeedback", StringComparison.OrdinalIgnoreCase))
            {
                if (!int.TryParse(e.CommandArgument?.ToString(), out var subscriptionId))
                {
                    ShowAlert(GetLocalizedText("SubscriptionFeedbackSaveError"), false);
                    return;
                }

                var ddlRating = e.Item.FindControl("ddlRating") as DropDownList;
                var txtComment = e.Item.FindControl("txtFeedbackComment") as System.Web.UI.WebControls.TextBox;

                if (ddlRating == null)
                {
                    ShowAlert(GetLocalizedText("SubscriptionFeedbackSaveError"), false);
                    return;
                }

                if (!int.TryParse(ddlRating.SelectedValue, out var rating))
                {
                    ShowAlert(GetLocalizedText("SubscriptionFeedbackSaveError"), false);
                    return;
                }

                string comment = txtComment?.Text ?? string.Empty;
                var result = userSecurity.SaveCurrentUserSubscriptionFeedback(subscriptionId, rating, comment);
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

            // Populate feedback UI controls (rating dropdown and existing comment)
            var hidSubscriptionId = DataBinder.Eval(e.Item.DataItem, "SubscriptionId");
            int subscriptionId;
            if (hidSubscriptionId != null && int.TryParse(Convert.ToString(hidSubscriptionId, CultureInfo.InvariantCulture), out subscriptionId))
            {
                var ddlRating = e.Item.FindControl("ddlRating") as DropDownList;
                if (ddlRating != null)
                {
                    ddlRating.Items.Clear();
                    ddlRating.Items.Add(new ListItem("1", "1"));
                    ddlRating.Items.Add(new ListItem("2", "2"));
                    ddlRating.Items.Add(new ListItem("3", "3"));
                    ddlRating.Items.Add(new ListItem("4", "4"));
                    ddlRating.Items.Add(new ListItem("5", "5"));

                    try
                    {
                        var feedbackResult = userSecurity.GetCurrentUserSubscriptionFeedback(subscriptionId);
                        if (feedbackResult != null && feedbackResult.IsSuccessful && feedbackResult.Data != null)
                        {
                            var feedback = feedbackResult.Data;
                            var txtComment = e.Item.FindControl("txtFeedbackComment") as System.Web.UI.WebControls.TextBox;
                            if (txtComment != null)
                            {
                                txtComment.Text = feedback.Comment ?? string.Empty;
                            }

                            if (feedback.Rating >= 1 && feedback.Rating <= 5)
                            {
                                var item = ddlRating.Items.FindByValue(feedback.Rating.ToString(CultureInfo.InvariantCulture));
                                if (item != null)
                                {
                                    ddlRating.ClearSelection();
                                    item.Selected = true;
                                }
                            }
                        }
                        else
                        {
                            // Default rating selection
                            var defaultItem = ddlRating.Items.FindByValue("5");
                            if (defaultItem != null)
                            {
                                ddlRating.ClearSelection();
                                defaultItem.Selected = true;
                            }
                        }
                    }
                    catch
                    {
                        // Swallow feedback load errors to avoid breaking dashboard rendering
                    }
                }
            }
        }

        protected string GetLocalizedText(string key)
        {
            return key;
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

        private void InitializeChatHistory()
        {
            var chatHistory = new List<ChatMessage>();
            Session["ChatHistory"] = chatHistory;
            rptChatMessages.DataSource = chatHistory;
            rptChatMessages.DataBind();
        }

        private void LoadChatHistory()
        {
            var chatHistory = Session["ChatHistory"] as List<ChatMessage> ?? new List<ChatMessage>();
            rptChatMessages.DataSource = chatHistory;
            rptChatMessages.DataBind();
        }

        protected async void btnSendMessage_Click(object sender, EventArgs e)
        {
            string userMessage = txtChatInput.Text.Trim();
            if (string.IsNullOrWhiteSpace(userMessage))
            {
                return;
            }

            var chatHistory = Session["ChatHistory"] as List<ChatMessage> ?? new List<ChatMessage>();

            chatHistory.Add(new ChatMessage { Role = "user", Content = userMessage });

            txtChatInput.Text = string.Empty;

            try
            {
                string apiKey = System.Configuration.ConfigurationManager.AppSettings["OpenAI.ApiKey"];
                string assistantResponse = await CallOpenAI(apiKey, chatHistory);
                chatHistory.Add(new ChatMessage { Role = "assistant", Content = assistantResponse });
            }
            catch (Exception ex)
            {
                chatHistory.Add(new ChatMessage { Role = "assistant", Content = "Error: " + ex.Message });
            }

            Session["ChatHistory"] = chatHistory;
            rptChatMessages.DataSource = chatHistory;
            rptChatMessages.DataBind();
        }

        private async System.Threading.Tasks.Task<string> CallOpenAI(string apiKey, List<ChatMessage> messages)
        {
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Add("Authorization", "Bearer " + apiKey);

                var messagesList = new List<object>();
                foreach (var msg in messages)
                {
                    messagesList.Add(new { role = msg.Role, content = msg.Content });
                }

                var requestBody = new
                {
                    model = "gpt-3.5-turbo",
                    messages = messagesList
                };

                var serializer = new JavaScriptSerializer();
                string json = serializer.Serialize(requestBody);

                var content = new StringContent(json, Encoding.UTF8, "application/json");
                var response = await client.PostAsync("https://api.openai.com/v1/chat/completions", content);

                string responseBody = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    return "API Error: " + response.StatusCode + " - " + responseBody;
                }

                var result = serializer.Deserialize<Dictionary<string, object>>(responseBody);
                var choices = result["choices"] as System.Collections.ArrayList;
                if (choices != null && choices.Count > 0)
                {
                    var choice = choices[0] as Dictionary<string, object>;
                    var message = choice["message"] as Dictionary<string, object>;
                    return message["content"].ToString();
                }

                return "No response from AI";
            }
        }

        public class ChatMessage
        {
            public string Role { get; set; }
            public string Content { get; set; }
        }
    }
}
