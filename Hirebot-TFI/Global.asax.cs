using System;
using System.Security.Principal;
using System.Web;
using System.Web.Security;
using System.Web.UI;

namespace Hirebot_TFI
{
    public class Global : HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            // Register jQuery script mapping for WebForms validation
            ScriptManager.ScriptResourceMapping.AddDefinition("jquery",
                new ScriptResourceDefinition
                {
                    Path = "~/Scripts/jquery-3.6.0.min.js",
                    DebugPath = "~/Scripts/jquery-3.6.0.js",
                    CdnPath = "https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js",
                    CdnDebugPath = "https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.js"
                });
        }

        protected void Session_Start(object sender, EventArgs e)
        {

        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {

        }

        protected void Application_AuthenticateRequest(object sender, EventArgs e)
        {
            try
            {
                var authCookie = Request.Cookies[FormsAuthentication.FormsCookieName];
                if (authCookie != null && !string.IsNullOrEmpty(authCookie.Value))
                {
                    var authTicket = FormsAuthentication.Decrypt(authCookie.Value);
                    if (authTicket != null && !authTicket.Expired)
                    {
                        var identity = new FormsIdentity(authTicket);
                        var principal = new GenericPrincipal(identity, new string[] { });
                        Context.User = principal;
                        System.Threading.Thread.CurrentPrincipal = principal;
                    }
                }
            }
            catch (Exception)
            {
                // If there's an error with authentication, clear the cookie
                if (Response.Cookies[FormsAuthentication.FormsCookieName] != null)
                {
                    Response.Cookies[FormsAuthentication.FormsCookieName].Expires = DateTime.Now.AddDays(-1);
                }
            }
        }

        protected void Application_Error(object sender, EventArgs e)
        {

        }

        protected void Session_End(object sender, EventArgs e)
        {

        }

        protected void Application_End(object sender, EventArgs e)
        {

        }
    }
}