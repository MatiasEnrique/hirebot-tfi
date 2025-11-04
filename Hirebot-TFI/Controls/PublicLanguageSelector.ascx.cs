using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using SERVICES;

namespace UI.Controls
{
    public partial class PublicLanguageSelector : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ApplyActiveOption(LanguageService.EnsureLanguage(Context));
            }
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            lnkSpanish.Attributes["data-lang"] = "es";
            lnkEnglish.Attributes["data-lang"] = "en";

            ApplyActiveOption(LanguageService.EnsureLanguage(Context));
        }

        private void ApplyActiveOption(string languageCode)
        {
            var normalized = (languageCode ?? LanguageService.DefaultLanguage).ToLowerInvariant();
            if (normalized.StartsWith("en"))
            {
                lnkEnglish.CssClass = "dropdown-item lang active";
                lnkSpanish.CssClass = "dropdown-item lang";
            }
            else
            {
                lnkSpanish.CssClass = "dropdown-item lang active";
                lnkEnglish.CssClass = "dropdown-item lang";
            }
        }

        public string CurrentLanguage => LanguageService.EnsureLanguage(Context);

        public bool IsSpanish => (CurrentLanguage ?? LanguageService.DefaultLanguage).StartsWith("es", StringComparison.OrdinalIgnoreCase);

        public bool IsEnglish => (CurrentLanguage ?? LanguageService.DefaultLanguage).StartsWith("en", StringComparison.OrdinalIgnoreCase);
    }
}