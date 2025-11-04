using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using SERVICES;

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

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            lnkSpanish.Attributes["data-lang"] = "es";
            lnkEnglish.Attributes["data-lang"] = "en";

            UpdateCurrentLanguageDisplay();
        }

        private void UpdateCurrentLanguageDisplay()
        {
            string language;

            try
            {
                language = LanguageService.EnsureLanguage(Context);
            }
            catch
            {
                language = LanguageService.DefaultLanguage;
            }

            var normalized = (language ?? LanguageService.DefaultLanguage).ToLowerInvariant();
            var isEnglish = normalized.StartsWith("en");

            litCurrentLanguage.Text = isEnglish ? "English" : "Espa\u00f1ol";

            lnkSpanish.CssClass = isEnglish
                ? "dropdown-item lang"
                : "dropdown-item lang active";

            lnkEnglish.CssClass = isEnglish
                ? "dropdown-item lang active"
                : "dropdown-item lang";
        }

        public string CurrentLanguage
        {
            get
            {
                return LanguageService.EnsureLanguage(Context);
            }
        }

        public bool IsSpanish => (CurrentLanguage ?? LanguageService.DefaultLanguage).StartsWith("es", StringComparison.OrdinalIgnoreCase);

        public bool IsEnglish => (CurrentLanguage ?? LanguageService.DefaultLanguage).StartsWith("en", StringComparison.OrdinalIgnoreCase);
    }
}