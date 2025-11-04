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
    public partial class AdminNews : BasePage
    {
        private const string AlertSuccess = "success";
        private const string AlertDanger = "danger";

        private readonly NewsSecurity _newsSecurity;

        public AdminNews()
        {
            _newsSecurity = new NewsSecurity();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Ensure only admin users access this page
                new AdminSecurity().RedirectIfNotAdmin();

                InitializeLanguageFilters();
                InitializePublishDateInput();
                BindNews();
                BindNewsletterSummary();
                BindSubscribers();

                hfOpenNewsModal.Value = "0";
                hfEditingNewsId.Value = "0";
            }
        }

        #region Initialization

        private void InitializeLanguageFilters()
        {
            ddlLanguageFilter.Items.Clear();
            ddlLanguageFilter.Items.Add(new ListItem(GetResource("AllLanguages", "All languages"), string.Empty));
            ddlLanguageFilter.Items.Add(new ListItem("Español (es)", "es"));
            ddlLanguageFilter.Items.Add(new ListItem("English (en)", "en"));
            ddlLanguageFilter.SelectedIndex = 0;

            ddlNewsLanguage.Items.Clear();
            ddlNewsLanguage.Items.Add(new ListItem("Español (es)", "es"));
            ddlNewsLanguage.Items.Add(new ListItem("English (en)", "en"));
        }

        private void InitializePublishDateInput()
        {
            txtPublishedDate.Attributes["type"] = "datetime-local";
        }

        #endregion

        #region Binding helpers

        private void BindNews()
        {
            HideAlert();

            var criteria = new NewsSearchCriteria
            {
                SearchTerm = txtSearch.Text?.Trim(),
                LanguageCode = string.IsNullOrWhiteSpace(ddlLanguageFilter.SelectedValue) ? null : ddlLanguageFilter.SelectedValue,
                StatusFilter = ddlStatusFilter.SelectedValue,
                PageNumber = 1,
                PageSize = 25
            };

            var result = _newsSecurity.SearchNewsForAdmin(criteria);

            if (result.IsSuccessful)
            {
                gvNews.DataSource = result.Data;
                gvNews.DataBind();

                var count = result.TotalRecords;
                litNewsCount.Text = string.Format(CultureInfo.CurrentUICulture,
                    GetResource("NewsCountSummary", "{0} news found"),
                    count);
            }
            else
            {
                gvNews.DataSource = null;
                gvNews.DataBind();
                ShowAlert(AlertDanger, result.ErrorMessage ?? GetResource("NewsLoadError", "Unable to load news."));
            }
        }

        private void BindNewsletterSummary()
        {
            var result = _newsSecurity.GetNewsletterSummary();
            if (result.IsSuccessful && result.Data != null)
            {
                litTotalSubscribers.Text = result.Data.TotalSubscribers.ToString("N0", CultureInfo.CurrentUICulture);
                litActiveSubscribers.Text = result.Data.ActiveSubscribers.ToString("N0", CultureInfo.CurrentUICulture);
                litInactiveSubscribers.Text = result.Data.InactiveSubscribers.ToString("N0", CultureInfo.CurrentUICulture);
                litRecentSubscribers.Text = result.Data.SubscribersLast30Days.ToString("N0", CultureInfo.CurrentUICulture);
            }
            else
            {
                litTotalSubscribers.Text = "0";
                litActiveSubscribers.Text = "0";
                litInactiveSubscribers.Text = "0";
                litRecentSubscribers.Text = "0";
            }
        }

        private void BindSubscribers()
        {
            bool? isActive = null;
            if (ddlSubscriberStatus.SelectedValue.Equals("Active", StringComparison.OrdinalIgnoreCase))
            {
                isActive = true;
            }
            else if (ddlSubscriberStatus.SelectedValue.Equals("Inactive", StringComparison.OrdinalIgnoreCase))
            {
                isActive = false;
            }

            var result = _newsSecurity.GetNewsletterSubscribers(isActive, txtSubscriberSearch.Text?.Trim(), 1, 50);
            if (result.IsSuccessful)
            {
                gvSubscribers.DataSource = result.Data;
                gvSubscribers.DataBind();
            }
            else
            {
                gvSubscribers.DataSource = null;
                gvSubscribers.DataBind();
                ShowAlert(AlertDanger, result.ErrorMessage ?? GetResource("SubscriberLoadError", "Unable to load subscribers."));
            }
        }

        #endregion

        #region Event handlers - Filters

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindNews();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            ddlStatusFilter.SelectedValue = "All";
            ddlLanguageFilter.SelectedIndex = 0;
            BindNews();
        }

        protected void btnRefreshSummary_Click(object sender, EventArgs e)
        {
            BindNewsletterSummary();
            BindSubscribers();
        }

        protected void btnSearchSubscribers_Click(object sender, EventArgs e)
        {
            BindSubscribers();
        }

        protected void btnClearSubscribers_Click(object sender, EventArgs e)
        {
            txtSubscriberSearch.Text = string.Empty;
            ddlSubscriberStatus.SelectedValue = "All";
            BindSubscribers();
        }

        #endregion

        #region Event handlers - News grid

        protected void gvNews_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!int.TryParse(Convert.ToString(e.CommandArgument).Split('|')[0], out int newsId))
            {
                return;
            }

            switch (e.CommandName)
            {
                case "EditNews":
                    LoadNewsForEdit(newsId);
                    break;
                case "TogglePublish":
                    HandlePublishToggle(e.CommandArgument.ToString());
                    break;
                case "ArchiveNews":
                    ArchiveNews(newsId);
                    break;
            }
        }

        protected void gvNews_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow)
            {
                return;
            }

            var data = (NewsArticle)e.Row.DataItem;

            var lblPublished = e.Row.FindControl("lblPublishedDate") as Label;
            if (lblPublished != null)
            {
                lblPublished.Text = data.PublishedDate.HasValue
                    ? data.PublishedDate.Value.ToLocalTime().ToString("g", CultureInfo.CurrentUICulture)
                    : GetResource("NotPublished", "Not published");
            }

            var lblUpdated = e.Row.FindControl("lblUpdatedDate") as Label;
            if (lblUpdated != null)
            {
                var referenceDate = data.LastModifiedDate ?? data.CreatedDate;
                lblUpdated.Text = referenceDate.ToLocalTime().ToString("g", CultureInfo.CurrentUICulture);
            }

            var badgeStatus = e.Row.FindControl("badgeStatus") as HtmlGenericControl;
            if (badgeStatus != null)
            {
                if (data.IsArchived)
                {
                    badgeStatus.Attributes["class"] = "badge-status bg-secondary-subtle text-secondary";
                    badgeStatus.InnerText = GetResource("StatusArchived", "Archived");
                }
                else if (data.IsPublished)
                {
                    badgeStatus.Attributes["class"] = "badge-status bg-success-subtle text-success";
                    badgeStatus.InnerText = GetResource("StatusPublished", "Published");
                }
                else
                {
                    badgeStatus.Attributes["class"] = "badge-status bg-warning-subtle text-warning";
                    badgeStatus.InnerText = GetResource("StatusUnpublished", "Unpublished");
                }
            }

            var lnkToggle = e.Row.FindControl("lnkTogglePublish") as LinkButton;
            if (lnkToggle != null)
            {
                if (data.IsArchived)
                {
                    lnkToggle.Enabled = false;
                    lnkToggle.CssClass = "btn btn-sm btn-outline-secondary me-2 disabled";
                    lnkToggle.Text = GetResource("Archived", "Archived");
                }
                else if (data.IsPublished)
                {
                    lnkToggle.Text = GetResource("Unpublish", "Unpublish");
                    lnkToggle.CssClass = "btn btn-sm btn-outline-warning me-2";
                }
                else
                {
                    lnkToggle.Text = GetResource("Publish", "Publish");
                    lnkToggle.CssClass = "btn btn-sm btn-outline-success me-2";
                }
            }

            var lnkArchive = e.Row.FindControl("lnkArchive") as LinkButton;
            if (lnkArchive != null && data.IsArchived)
            {
                lnkArchive.Enabled = false;
                lnkArchive.CssClass = "btn btn-sm btn-outline-secondary disabled";
            }
        }

        private void LoadNewsForEdit(int newsId)
        {
            var result = _newsSecurity.GetNewsById(newsId);
            if (!result.IsSuccessful || result.Data == null)
            {
                ShowAlert(AlertDanger, result.ErrorMessage ?? GetResource("NewsLoadError", "Unable to load news."));
                return;
            }

            var article = result.Data;
            hfEditingNewsId.Value = article.NewsId.ToString(CultureInfo.InvariantCulture);
            litNewsModalTitle.Text = GetResource("EditNews", "Edit news");
            txtNewsTitle.Text = article.Title;
            txtNewsSummary.Text = article.Summary;
            txtNewsContent.Text = article.Content;

            if (ddlNewsLanguage.Items.FindByValue(article.LanguageCode) == null)
            {
                ddlNewsLanguage.Items.Add(new ListItem(article.LanguageCode, article.LanguageCode));
            }
            ddlNewsLanguage.SelectedValue = article.LanguageCode;

            txtPublishedDate.Text = article.PublishedDate.HasValue
                ? article.PublishedDate.Value.ToLocalTime().ToString("yyyy-MM-ddTHH:mm")
                : string.Empty;

            chkNewsPublish.Checked = article.IsPublished && !article.IsArchived;
            lblModalError.Visible = false;
            lblModalError.Text = string.Empty;

            RequestNewsModalOpen();
        }

        private void HandlePublishToggle(string commandArgument)
        {
            var parts = commandArgument.Split('|');
            if (parts.Length < 3)
            {
                return;
            }

            if (!int.TryParse(parts[0], out int newsId))
            {
                return;
            }

            bool isPublished = Convert.ToBoolean(parts[1], CultureInfo.InvariantCulture);
            bool isArchived = Convert.ToBoolean(parts[2], CultureInfo.InvariantCulture);

            if (isArchived)
            {
                ShowAlert(AlertDanger, GetResource("CannotPublishArchived", "Archived news cannot be published."));
                return;
            }

            DatabaseResult result = isPublished
                ? _newsSecurity.UnpublishNews(newsId)
                : _newsSecurity.PublishNews(newsId);

            if (result.IsSuccessful)
            {
                ShowAlert(AlertSuccess, result.ErrorMessage ?? GetResource("PublishStatusUpdated", "Publish status updated."));
                BindNews();
            }
            else
            {
                ShowAlert(AlertDanger, result.ErrorMessage ?? GetResource("PublishStatusError", "Unable to update publish status."));
            }
        }

        private void ArchiveNews(int newsId)
        {
            var result = _newsSecurity.ArchiveNews(newsId);
            if (result.IsSuccessful)
            {
                ShowAlert(AlertSuccess, result.ErrorMessage ?? GetResource("NewsArchived", "News archived."));
                BindNews();
            }
            else
            {
                ShowAlert(AlertDanger, result.ErrorMessage ?? GetResource("NewsArchiveError", "Unable to archive news."));
            }
        }

        #endregion

        #region Event handlers - Subscribers grid

        protected void gvSubscribers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!e.CommandName.Equals("Unsubscribe", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            var email = Convert.ToString(e.CommandArgument);
            if (string.IsNullOrWhiteSpace(email))
            {
                return;
            }

            var result = _newsSecurity.UnsubscribeFromNewsletter(email);
            if (result.IsSuccessful)
            {
                ShowAlert(AlertSuccess, result.ErrorMessage ?? GetResource("SubscriberRemoved", "Subscriber removed."));
                BindNewsletterSummary();
                BindSubscribers();
            }
            else
            {
                ShowAlert(AlertDanger, result.ErrorMessage ?? GetResource("SubscriberRemoveError", "Unable to remove subscriber."));
            }
        }

        protected void gvSubscribers_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow)
            {
                return;
            }

            var subscription = (NewsletterSubscription)e.Row.DataItem;
            var badge = e.Row.FindControl("badgeSubscriberStatus") as HtmlGenericControl;
            if (badge != null)
            {
                if (subscription.IsActive)
                {
                    badge.Attributes["class"] = "badge bg-success-subtle text-success";
                    badge.InnerText = GetResource("Active", "Active");
                }
                else
                {
                    badge.Attributes["class"] = "badge bg-secondary-subtle text-secondary";
                    badge.InnerText = GetResource("Inactive", "Inactive");
                }
            }

            var lblSubscribed = e.Row.FindControl("lblSubscribedOn") as Label;
            if (lblSubscribed != null)
            {
                lblSubscribed.Text = subscription.CreatedDate.ToLocalTime().ToString("g", CultureInfo.CurrentUICulture);
            }

            var lnkUnsubscribe = e.Row.FindControl("lnkUnsubscribe") as LinkButton;
            if (lnkUnsubscribe != null && !subscription.IsActive)
            {
                lnkUnsubscribe.Enabled = false;
                lnkUnsubscribe.CssClass = "btn btn-sm btn-outline-secondary disabled";
            }
        }

        #endregion

        #region Modal actions

        protected void btnSaveNews_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
            {
                lblModalError.Text = GetResource("ValidationError", "Please correct the highlighted errors.");
                lblModalError.Visible = true;
                RequestNewsModalOpen();
                return;
            }

            var article = new NewsArticle
            {
                Title = txtNewsTitle.Text?.Trim(),
                Summary = txtNewsSummary.Text?.Trim(),
                Content = txtNewsContent.Text?.Trim(),
                LanguageCode = ddlNewsLanguage.SelectedValue,
                IsPublished = chkNewsPublish.Checked,
                PublishedDate = ParseDateTimeLocal(txtPublishedDate.Text)
            };

            NewsArticleResult result;
            if (int.TryParse(hfEditingNewsId.Value, out int newsId) && newsId > 0)
            {
                article.NewsId = newsId;
                result = _newsSecurity.UpdateNews(article);
            }
            else
            {
                result = _newsSecurity.CreateNews(article);
            }

            if (result.IsSuccessful)
            {
                ShowAlert(AlertSuccess, result.ErrorMessage ?? GetResource("NewsSaved", "News saved successfully."));
                ScriptManager.RegisterStartupScript(this, GetType(), "HideNewsModal", "hideNewsModal();", true);
                BindNews();
                ClearNewsModal();
            }
            else
            {
                lblModalError.Text = result.ErrorMessage ?? GetResource("NewsSaveError", "Unable to save news.");
                lblModalError.Visible = true;
                RequestNewsModalOpen();
            }
        }

        private void ClearNewsModal()
        {
            txtNewsTitle.Text = string.Empty;
            txtNewsSummary.Text = string.Empty;
            txtNewsContent.Text = string.Empty;
            ddlNewsLanguage.SelectedIndex = 0;
            txtPublishedDate.Text = string.Empty;
            chkNewsPublish.Checked = false;
            lblModalError.Visible = false;
            lblModalError.Text = string.Empty;
            hfOpenNewsModal.Value = "0";
            hfEditingNewsId.Value = "0";
        }

        private DateTime? ParseDateTimeLocal(string input)
        {
            if (string.IsNullOrWhiteSpace(input))
            {
                return null;
            }

            if (DateTime.TryParseExact(input, "yyyy-MM-ddTHH:mm", CultureInfo.InvariantCulture, DateTimeStyles.AssumeLocal, out var parsed))
            {
                return parsed;
            }

            return null;
        }

        #endregion

        #region Alert helpers

        private void ShowAlert(string type, string message)
        {
            if (string.IsNullOrWhiteSpace(message))
            {
                return;
            }

            pnlAlert.Visible = true;
            pnlAlert.CssClass = $"alert alert-floating alert-{type}";
            lblAlert.Text = HttpUtility.HtmlEncode(message);
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowPageAlert", $"showAlert('{type}');", true);
        }

        private void RequestNewsModalOpen()
        {
            hfOpenNewsModal.Value = "1";

            if (!int.TryParse(hfEditingNewsId.Value, out var newsId) || newsId == 0)
            {
                litNewsModalTitle.Text = GetResource("CreateNews", "Create news");
            }
            else
            {
                litNewsModalTitle.Text = GetResource("EditNews", "Edit news");
            }
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

        #endregion
    }
}
