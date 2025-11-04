using System;
using System.Globalization;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ABSTRACTIONS;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class News : BasePage
    {
        private readonly NewsSecurity _newsSecurity;

        public News()
        {
            _newsSecurity = new NewsSecurity();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializeFilters();
                BindNews();
            }
        }

        private void InitializeFilters()
        {
            ddlPublicLanguage.Items.Clear();
            ddlPublicLanguage.Items.Add(new ListItem(GetResource("AllLanguages", "All languages"), string.Empty));
            ddlPublicLanguage.Items.Add(new ListItem("Español (es)", "es"));
            ddlPublicLanguage.Items.Add(new ListItem("English (en)", "en"));

            ddlSubscribeLanguage.Items.Clear();
            ddlSubscribeLanguage.Items.Add(new ListItem("Español (es)", "es"));
            ddlSubscribeLanguage.Items.Add(new ListItem("English (en)", "en"));
        }

        private void BindNews()
        {
            HidePublicAlert();

            var criteria = new NewsSearchCriteria
            {
                SearchTerm = txtPublicSearch.Text?.Trim(),
                LanguageCode = string.IsNullOrWhiteSpace(ddlPublicLanguage.SelectedValue) ? null : ddlPublicLanguage.SelectedValue,
                StatusFilter = "Published",
                PageNumber = 1,
                PageSize = 15
            };

            var result = _newsSecurity.SearchPublishedNews(criteria);

            if (result.IsSuccessful && result.Data != null && result.Data.Count > 0)
            {
                rptNews.Visible = true;
                rptNews.DataSource = result.Data;
                rptNews.DataBind();
                pnlNoNews.Visible = false;

                litNewsResultsCount.Text = string.Format(CultureInfo.CurrentUICulture,
                    GetResource("NewsResultsCount", "{0} articles found"),
                    result.Data.Count);
            }
            else
            {
                rptNews.DataSource = null;
                rptNews.DataBind();
                rptNews.Visible = false;
                pnlNoNews.Visible = true;
                litNewsResultsCount.Text = string.Empty;
            }
        }

        protected void btnSearchNews_Click(object sender, EventArgs e)
        {
            BindNews();
        }

        protected void btnResetNewsSearch_Click(object sender, EventArgs e)
        {
            txtPublicSearch.Text = string.Empty;
            ddlPublicLanguage.SelectedIndex = 0;
            BindNews();
        }

        protected void rptNews_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!string.Equals(e.CommandName, "ReadMore", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            if (!int.TryParse(Convert.ToString(e.CommandArgument, CultureInfo.InvariantCulture), out int newsId))
            {
                return;
            }

            var result = _newsSecurity.GetNewsById(newsId);
            if (!result.IsSuccessful || result.Data == null || !result.Data.IsPublished || result.Data.IsArchived)
            {
                ShowPublicAlert("warning", GetResource("NewsUnavailable", "This article is no longer available."));
                return;
            }

            var article = result.Data;

            litArticleModalTitle.Text = HttpUtility.HtmlEncode(article.Title);
            litArticleModalDate.Text = FormatModalPublishedDate(article.PublishedDate);

            var languageDisplay = string.IsNullOrWhiteSpace(article.LanguageCode)
                ? "N/A"
                : article.LanguageCode.ToUpperInvariant();

            litArticleModalLanguage.Text = HttpUtility.HtmlEncode(languageDisplay);
            litArticleModalViews.Text = article.ViewCount.ToString("N0", CultureInfo.CurrentUICulture);
            litArticleModalContent.Text = article.Content ?? string.Empty;

            ScriptManager.RegisterStartupScript(this, GetType(), "ShowNewsDetailModal", "showNewsDetailModal();", true);
        }

        protected void btnSubscribeNewsletter_Click(object sender, EventArgs e)
        {
            lblSubscribeFeedback.Visible = false;

            if (string.IsNullOrWhiteSpace(txtSubscribeEmail.Text))
            {
                SetSubscribeFeedback(false, GetResource("EmailRequired", "Please enter your email."));
                return;
            }

            var result = _newsSecurity.SubscribeToNewsletter(txtSubscribeEmail.Text.Trim(), ddlSubscribeLanguage.SelectedValue);
            if (result.IsSuccessful)
            {
                SetSubscribeFeedback(true, result.ErrorMessage ?? GetResource("SubscribedSuccess", "You are subscribed!"));
                txtSubscribeEmail.Text = string.Empty;
            }
            else
            {
                SetSubscribeFeedback(false, result.ErrorMessage ?? GetResource("SubscribedError", "Subscription failed."));
            }
        }

        private void SetSubscribeFeedback(bool success, string message)
        {
            lblSubscribeFeedback.Visible = true;
            lblSubscribeFeedback.CssClass = success ? "d-block mt-3 small text-success" : "d-block mt-3 small text-warning";
            lblSubscribeFeedback.Text = HttpUtility.HtmlEncode(message);
        }

        private void HidePublicAlert()
        {
            pnlPublicAlert.Visible = false;
            lblPublicAlert.Text = string.Empty;
        }

        private void ShowPublicAlert(string type, string message)
        {
            if (string.IsNullOrWhiteSpace(message))
            {
                return;
            }

            pnlPublicAlert.CssClass = $"alert alert-dismissible fade show alert-{type}";
            pnlPublicAlert.Visible = true;
            lblPublicAlert.Text = HttpUtility.HtmlEncode(message);
        }

        protected string FormatPublishedDate(object publishedDateObj)
        {
            if (publishedDateObj == null || publishedDateObj == DBNull.Value)
            {
                return GetResource("NotPublished", "Not published");
            }

            if (DateTime.TryParse(Convert.ToString(publishedDateObj, CultureInfo.InvariantCulture), out var publishedDate))
            {
                return publishedDate.ToLocalTime().ToString("D", CultureInfo.CurrentUICulture);
            }

            return GetResource("NotPublished", "Not published");
        }

        protected string GetExcerpt(object contentObj)
        {
            var content = Convert.ToString(contentObj);
            if (string.IsNullOrWhiteSpace(content))
            {
                return string.Empty;
            }

            var plainText = Regex.Replace(content, "<[^>]+>", string.Empty);
            plainText = HttpUtility.HtmlDecode(plainText);

            const int maxLength = 320;
            if (plainText.Length <= maxLength)
            {
                return plainText;
            }

            return plainText.Substring(0, maxLength).Trim() + "...";
        }

        private string GetResource(string key, string fallback)
        {
            return fallback;
        }

        private string FormatModalPublishedDate(DateTime? publishedDate)
        {
            if (!publishedDate.HasValue)
            {
                return GetResource("NotPublished", "Not published");
            }

            return publishedDate.Value.ToLocalTime().ToString("f", CultureInfo.CurrentUICulture);
        }
    }
}
