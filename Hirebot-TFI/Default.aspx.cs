using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SECURITY;
using ABSTRACTIONS;

namespace Hirebot_TFI
{
    public partial class Default : BasePage
    {
        private UserSecurity userSecurity;

        protected void Page_Load(object sender, EventArgs e)
        {
            userSecurity = new UserSecurity();

            // Set culture from session or default to Spanish
            SetCulture();

            if (!IsPostBack)
            {
                LoadHomepageAd();
                CheckUserAuthentication();
            }
        }

        private void LoadHomepageAd()
        {
            try
            {
                var homepageAdSecurity = new HomepageAdSecurity();
                var result = homepageAdSecurity.GetSelectedAdForDisplay();

                if (result.IsSuccessful && result.Data != null && result.Data.IsActive)
                {
                    var ad = result.Data;
                    pnlHomepageAd.Visible = true;

                    if (!string.IsNullOrWhiteSpace(ad.BadgeText))
                    {
                        spanAdBadge.Visible = true;
                        spanAdBadge.InnerText = ad.BadgeText;
                    }
                    else
                    {
                        spanAdBadge.Visible = false;
                    }

                    litAdTitle.Text = Server.HtmlEncode(ad.Title);

                    if (!string.IsNullOrWhiteSpace(ad.Description))
                    {
                        litAdDescription.Visible = true;
                        litAdDescription.Text = Server.HtmlEncode(ad.Description);
                    }
                    else
                    {
                        litAdDescription.Visible = false;
                    }

                    if (!string.IsNullOrWhiteSpace(ad.CtaText) && !string.IsNullOrWhiteSpace(ad.TargetUrl))
                    {
                        lnkAdCta.Visible = true;
                        lnkAdCta.HRef = ad.TargetUrl;
                        lnkAdCta.InnerText = ad.CtaText;
                    }
                    else
                    {
                        lnkAdCta.Visible = false;
                    }
                }
                else
                {
                    pnlHomepageAd.Visible = false;
                }
            }
            catch (Exception)
            {
                // Silently hide ad section if there's an error
                pnlHomepageAd.Visible = false;
            }
        }

        private void CheckUserAuthentication()
        {
            if (userSecurity.IsUserAuthenticated())
            {
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser != null)
                {
                    // Show authenticated user interface
                    pnlWelcomeMessage.Visible = true;
                    pnlGuestMessage.Visible = false;

                    lblWelcomeUser.Text = currentUser.FirstName + " " + currentUser.LastName;
                }
            }
            else
            {
                // Show anonymous user interface
                pnlWelcomeMessage.Visible = false;
                pnlGuestMessage.Visible = true;
            }
        }


        private void SetCulture()
        {
            string language = Session["Language"] as string ?? "es";

            CultureInfo culture = new CultureInfo(language);
            Thread.CurrentThread.CurrentCulture = culture;
            Thread.CurrentThread.CurrentUICulture = culture;
        }
    }
}