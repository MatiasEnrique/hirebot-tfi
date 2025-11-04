using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ABSTRACTIONS;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class AdminAds : BasePage
    {
        private readonly HomepageAdSecurity _homepageAdSecurity = new HomepageAdSecurity();

        private int SelectedAdId
        {
            get
            {
                if (int.TryParse(hdnSelectedAdId.Value, out var adId))
                {
                    return adId;
                }

                return 0;
            }
            set => hdnSelectedAdId.Value = value.ToString();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAds();
            }
        }

        protected void btnNewAd_Click(object sender, EventArgs e)
        {
            ClearAdForm();
            pnlAdDetail.Visible = true;
            litAdHeader.Text = GetGlobalString("CreateNewAd");
            btnDeleteAd.Visible = false;
            btnSetSelected.Visible = false;
            ShowMessage(GetGlobalString("ReadyToCreateAd"), true);
        }

        protected void rptAds_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!string.Equals(e.CommandName, "SelectAd", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            if (!int.TryParse(e.CommandArgument?.ToString(), out var adId))
            {
                return;
            }

            SelectedAdId = adId;
            LoadAdDetails(adId);
            LoadAds();
        }

        protected void btnSaveAd_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
            {
                return;
            }

            try
            {
                var ad = new HomepageAd
                {
                    AdId = SelectedAdId,
                    Title = txtTitle.Text?.Trim(),
                    BadgeText = string.IsNullOrWhiteSpace(txtBadgeText.Text) ? null : txtBadgeText.Text.Trim(),
                    Description = string.IsNullOrWhiteSpace(txtDescription.Text) ? null : txtDescription.Text.Trim(),
                    CtaText = string.IsNullOrWhiteSpace(txtCtaText.Text) ? null : txtCtaText.Text.Trim(),
                    TargetUrl = string.IsNullOrWhiteSpace(txtTargetUrl.Text) ? null : txtTargetUrl.Text.Trim(),
                    IsActive = chkIsActive.Checked
                };

                var userId = GetCurrentUserId();
                var result = _homepageAdSecurity.SaveAd(userId, ad);

                if (!result.IsSuccessful)
                {
                    ShowMessage(result.ErrorMessage ?? GetGlobalString("AdSaveError"), false);
                    return;
                }

                SelectedAdId = ad.AdId;
                ShowMessage(GetGlobalString("AdSavedSuccess"), true);
                LoadAds();

                if (ad.AdId > 0)
                {
                    LoadAdDetails(ad.AdId);
                }
                else
                {
                    pnlAdDetail.Visible = false;
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetGlobalString("AdSaveError") + ": " + ex.Message, false);
            }
        }

        protected void btnDeleteAd_Click(object sender, EventArgs e)
        {
            if (SelectedAdId <= 0)
            {
                ShowMessage(GetGlobalString("SelectAdWarning"), false);
                return;
            }

            var userId = GetCurrentUserId();
            var result = _homepageAdSecurity.DeleteAd(userId, SelectedAdId);

            if (!result.IsSuccessful)
            {
                ShowMessage(result.ErrorMessage ?? GetGlobalString("AdDeleteError"), false);
                return;
            }

            ShowMessage(GetGlobalString("AdDeletedSuccess"), true);
            SelectedAdId = 0;
            ClearAdForm();
            pnlAdDetail.Visible = false;
            LoadAds();
        }

        protected void btnSetSelected_Click(object sender, EventArgs e)
        {
            if (SelectedAdId <= 0)
            {
                ShowMessage(GetGlobalString("SelectAdWarning"), false);
                return;
            }

            var userId = GetCurrentUserId();
            var result = _homepageAdSecurity.SetSelectedAd(userId, SelectedAdId);

            if (!result.IsSuccessful)
            {
                ShowMessage(result.ErrorMessage ?? GetGlobalString("SetSelectedError"), false);
                return;
            }

            ShowMessage(GetGlobalString("AdSelectedSuccess"), true);
            LoadAds();
            LoadAdDetails(SelectedAdId);
        }

        private void LoadAds()
        {
            var userId = GetCurrentUserId();
            var result = _homepageAdSecurity.GetAllAds(userId);

            if (!result.IsSuccessful)
            {
                rptAds.DataSource = null;
                rptAds.DataBind();
                pnlNoAds.Visible = true;
                ShowMessage(result.ErrorMessage ?? GetGlobalString("AdLoadError"), false);
                return;
            }

            var ads = result.Data ?? new List<HomepageAd>();
            rptAds.DataSource = ads.OrderByDescending(a => a.IsSelected)
                                    .ThenByDescending(a => a.IsActive)
                                    .ThenByDescending(a => a.ModifiedDateUtc)
                                    .ToList();
            rptAds.DataBind();

            pnlNoAds.Visible = ads.Count == 0;
        }

        private void LoadAdDetails(int adId)
        {
            ClearMessage();

            if (adId <= 0)
            {
                ClearAdForm();
                pnlAdDetail.Visible = false;
                return;
            }

            var userId = GetCurrentUserId();
            var result = _homepageAdSecurity.GetAdById(userId, adId);

            if (!result.IsSuccessful || result.Data == null)
            {
                ShowMessage(result.ErrorMessage ?? GetGlobalString("AdLoadDetailError"), false);
                return;
            }

            BindAdDetail(result.Data);
        }

        private void BindAdDetail(HomepageAd ad)
        {
            if (ad == null)
            {
                return;
            }

            pnlAdDetail.Visible = true;

            SelectedAdId = ad.AdId;
            txtTitle.Text = ad.Title;
            txtBadgeText.Text = ad.BadgeText;
            txtDescription.Text = ad.Description;
            txtCtaText.Text = ad.CtaText;
            txtTargetUrl.Text = ad.TargetUrl;
            chkIsActive.Checked = ad.IsActive;

            litAdHeader.Text = string.IsNullOrWhiteSpace(ad.Title)
                ? GetGlobalString("CreateNewAd")
                : GetGlobalString("EditAd");

            btnDeleteAd.Visible = ad.AdId > 0;
            SetDeleteConfirmation();

            btnSetSelected.Visible = ad.IsActive && ad.AdId > 0;
            if (btnSetSelected.Visible)
            {
                var iconClass = ad.IsSelected ? "bi-star-fill" : "bi-star";
                var textKey = ad.IsSelected ? "CurrentlyDisplayed" : "SetAsSelected";
                btnSetSelected.Text = $"<i class='bi {iconClass} me-1'></i>{GetGlobalString(textKey)}";
            }
        }

        private void ClearAdForm()
        {
            SelectedAdId = 0;
            txtTitle.Text = string.Empty;
            txtBadgeText.Text = string.Empty;
            txtDescription.Text = string.Empty;
            txtCtaText.Text = string.Empty;
            txtTargetUrl.Text = string.Empty;
            chkIsActive.Checked = true;
            litAdHeader.Text = GetGlobalString("CreateNewAd");
            btnDeleteAd.Visible = false;
            btnSetSelected.Visible = false;
            SetDeleteConfirmation();
        }

        private void SetDeleteConfirmation()
        {
            var confirmText = HttpUtility.JavaScriptStringEncode(GetGlobalString("DeleteAdConfirm"));
            btnDeleteAd.OnClientClick = btnDeleteAd.Visible ? $"return confirm('{confirmText}');" : string.Empty;
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            if (string.IsNullOrWhiteSpace(message))
            {
                pnlMessage.Visible = false;
                return;
            }

            pnlMessage.Visible = true;
            pnlMessage.CssClass = isSuccess ? "alert alert-success" : "alert alert-danger";
            pnlMessage.Controls.Clear();
            pnlMessage.Controls.Add(new Literal { Text = HttpUtility.HtmlEncode(message) });
        }

        private void ClearMessage()
        {
            pnlMessage.Visible = false;
            pnlMessage.Controls.Clear();
        }

        protected string GetAdCardCss(object adIdObj)
        {
            var classes = "ad-card mb-3";

            if (adIdObj != null && int.TryParse(adIdObj.ToString(), out var adId) && adId == SelectedAdId)
            {
                classes += " active";
            }

            return classes;
        }

        protected string GetAdStatusBadges(object isActiveObj, object isSelectedObj)
        {
            var isActive = false;
            if (isActiveObj != null)
            {
                bool.TryParse(isActiveObj.ToString(), out isActive);
            }

            var isSelected = false;
            if (isSelectedObj != null)
            {
                bool.TryParse(isSelectedObj.ToString(), out isSelected);
            }

            var html = "";

            if (isSelected)
            {
                html += $"<span class='badge bg-primary me-1'><i class='bi bi-star-fill'></i> {GetGlobalString("CurrentlyDisplayed")}</span>";
            }

            html += isActive
                ? $"<span class='badge bg-success'>{GetGlobalString("Active")}</span>"
                : $"<span class='badge bg-secondary'>{GetGlobalString("Inactive")}</span>";

            return html;
        }

        protected string FormatDate(object dateObj)
        {
            if (dateObj == null || dateObj == DBNull.Value)
            {
                return "-";
            }

            try
            {
                var date = Convert.ToDateTime(dateObj);
                return date.ToLocalTime().ToString("g");
            }
            catch
            {
                return "-";
            }
        }

        private int GetCurrentUserId()
        {
            if (Session["UserId"] != null && int.TryParse(Session["UserId"].ToString(), out int userId))
            {
                return userId;
            }
            return 0;
        }

        private static string GetGlobalString(string key)
        {
            return key;
        }
    }
}
