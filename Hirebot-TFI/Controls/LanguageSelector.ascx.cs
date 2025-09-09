using System;
using System.Globalization;
using System.Threading;
using System.Web;
using System.Web.UI;

namespace UI.Controls
{
    public partial class LanguageSelector : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                UpdateCurrentLanguageDisplay();
            }
        }

        protected void btnSpanish_Click(object sender, EventArgs e)
        {
            SetLanguage("es");
        }

        protected void btnEnglish_Click(object sender, EventArgs e)
        {
            SetLanguage("en");
        }

        private void SetLanguage(string languageCode)
        {
            try
            {
                // Store the selected language in session
                Session["Language"] = languageCode;

                // Set the culture for the current thread
                CultureInfo culture = new CultureInfo(languageCode);
                Thread.CurrentThread.CurrentCulture = culture;
                Thread.CurrentThread.CurrentUICulture = culture;

                // Create a cookie to remember the language preference
                HttpCookie languageCookie = new HttpCookie("Language", languageCode)
                {
                    Expires = DateTime.Now.AddYears(1),
                    HttpOnly = true,
                    SameSite = SameSiteMode.Lax
                };
                Response.Cookies.Add(languageCookie);

                // Update the display
                UpdateCurrentLanguageDisplay();

                // Refresh the current page to apply the language change
                Response.Redirect(Request.RawUrl, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception)
            {
                // Silently handle any errors in language switching
            }
        }

        private void UpdateCurrentLanguageDisplay()
        {
            try
            {
                string currentLanguage = Session["Language"]?.ToString() ?? "es";
                
                switch (currentLanguage.ToLower())
                {
                    case "en":
                        litCurrentLanguage.Text = "English";
                        break;
                    case "es":
                    default:
                        litCurrentLanguage.Text = "Español";
                        break;
                }
            }
            catch
            {
                // Default to Spanish if there's any issue
                litCurrentLanguage.Text = "Español";
            }
        }

        /// <summary>
        /// Gets the current language code
        /// </summary>
        public string CurrentLanguage
        {
            get
            {
                return Session["Language"]?.ToString() ?? "es";
            }
        }

        /// <summary>
        /// Determines if the current language is Spanish
        /// </summary>
        public bool IsSpanish
        {
            get
            {
                return CurrentLanguage.Equals("es", StringComparison.OrdinalIgnoreCase);
            }
        }

        /// <summary>
        /// Determines if the current language is English
        /// </summary>
        public bool IsEnglish
        {
            get
            {
                return CurrentLanguage.Equals("en", StringComparison.OrdinalIgnoreCase);
            }
        }
    }
}