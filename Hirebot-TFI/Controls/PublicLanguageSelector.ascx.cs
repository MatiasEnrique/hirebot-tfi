using System;
using System.Globalization;
using System.Threading;
using System.Web;
using System.Web.UI;

namespace UI.Controls
{
    public partial class PublicLanguageSelector : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // No specific initialization needed for public pages
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

                // Refresh the current page to apply the language change
                Response.Redirect(Request.RawUrl, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception)
            {
                // Silently handle any errors in language switching
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