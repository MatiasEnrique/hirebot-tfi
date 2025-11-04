using System;
using System.Web;
using System.Web.UI;
using SECURITY;
using SERVICES;

namespace Hirebot_TFI
{
    public class BasePage : Page
    {
        private readonly AuthorizationSecurity _authorizationSecurity = new AuthorizationSecurity();

        protected override void InitializeCulture()
        {
            var context = HttpContext.Current ?? Context;
            var language = LanguageService.EnsureLanguage(context);
            LanguageService.ApplyCulture(language);

            base.InitializeCulture();
        }

        protected override void OnPreInit(EventArgs e)
        {
            base.OnPreInit(e);
            _authorizationSecurity.EnsurePageAccess(this);
        }
    }
}