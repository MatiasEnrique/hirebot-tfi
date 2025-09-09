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
                CheckUserAuthentication();
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