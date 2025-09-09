using System;
using System.Globalization;
using System.Threading;
using System.Web;
using System.Web.UI;

namespace Hirebot_TFI
{
    public class BasePage : Page
    {
        protected override void InitializeCulture()
        {
            string language = Session["Language"] as string ?? "es";
            
            CultureInfo culture = new CultureInfo(language);
            Thread.CurrentThread.CurrentCulture = culture;
            Thread.CurrentThread.CurrentUICulture = culture;
            
            base.InitializeCulture();
        }
    }
}