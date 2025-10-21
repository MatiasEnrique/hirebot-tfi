using System;
using System.Configuration;
using System.Net;
using System.Net.Mail;
using System.Globalization;
using System.Text;
using System.Web;

namespace SERVICES
{
    /// <summary>
    /// Email service for sending different types of emails with multilanguage support
    /// Follows the project's architectural patterns with proper error handling and configuration
    /// </summary>
    public static class EmailService
    {
        // Configuration cache to improve performance
        private static EmailConfiguration _config = null;
        private static readonly object _configLock = new object();

        /// <summary>
        /// Internal configuration class to cache email settings
        /// </summary>
        private class EmailConfiguration
        {
            public string SmtpServer { get; set; }
            public int SmtpPort { get; set; }
            public bool EnableSSL { get; set; }
            public string Username { get; set; }
            public string Password { get; set; }
            public string FromAddress { get; set; }
            public string FromName { get; set; }
            public int TimeoutSeconds { get; set; }
            public bool EnableEmailService { get; set; }
            public string SupportEmail { get; set; }
            public string CompanyName { get; set; }
            public string CompanyWebsite { get; set; }
        }

        /// <summary>
        /// Gets the email configuration from web.config with caching
        /// </summary>
        private static EmailConfiguration GetConfiguration()
        {
            if (_config == null)
            {
                lock (_configLock)
                {
                    if (_config == null)
                    {
                        _config = new EmailConfiguration
                        {
                            SmtpServer = ConfigurationManager.AppSettings["Email.SmtpServer"] ?? "smtp.gmail.com",
                            SmtpPort = int.Parse(ConfigurationManager.AppSettings["Email.SmtpPort"] ?? "587"),
                            EnableSSL = bool.Parse(ConfigurationManager.AppSettings["Email.EnableSSL"] ?? "true"),
                            Username = ConfigurationManager.AppSettings["Email.Username"] ?? "",
                            Password = ConfigurationManager.AppSettings["Email.Password"] ?? "",
                            FromAddress = ConfigurationManager.AppSettings["Email.FromAddress"] ?? "noreply@hirebot.com",
                            FromName = ConfigurationManager.AppSettings["Email.FromName"] ?? "Hirebot TFI",
                            TimeoutSeconds = int.Parse(ConfigurationManager.AppSettings["Email.TimeoutSeconds"] ?? "30"),
                            EnableEmailService = bool.Parse(ConfigurationManager.AppSettings["Email.EnableEmailService"] ?? "false"),
                            SupportEmail = ConfigurationManager.AppSettings["Email.SupportEmail"] ?? "support@hirebot.com",
                            CompanyName = ConfigurationManager.AppSettings["Email.CompanyName"] ?? "Hirebot TFI",
                            CompanyWebsite = ConfigurationManager.AppSettings["Email.CompanyWebsite"] ?? "https://localhost:44383"
                        };
                    }
                }
            }
            return _config;
        }

        /// <summary>
        /// Clears the configuration cache. Used for testing or when configuration changes
        /// </summary>
        public static void ClearConfigurationCache()
        {
            lock (_configLock)
            {
                _config = null;
            }
        }

        /// <summary>
        /// Gets a localized resource string
        /// </summary>
        private static string GetLocalizedString(string key)
        {
            try
            {
                var context = HttpContext.Current;
                if (context != null)
                {
                    var value = HttpContext.GetGlobalResourceObject("GlobalResources", key) as string;
                    return value ?? key;
                }
                return key;
            }
            catch (Exception)
            {
                return key;
            }
        }

        /// <summary>
        /// Creates and configures an SMTP client
        /// </summary>
        private static SmtpClient CreateSmtpClient()
        {
            var config = GetConfiguration();
            
            var client = new SmtpClient(config.SmtpServer, config.SmtpPort)
            {
                EnableSsl = config.EnableSSL,
                DeliveryMethod = SmtpDeliveryMethod.Network,
                UseDefaultCredentials = false,
                Timeout = config.TimeoutSeconds * 1000
            };

            if (!string.IsNullOrEmpty(config.Username) && !string.IsNullOrEmpty(config.Password))
            {
                client.Credentials = new NetworkCredential(config.Username, config.Password);
            }

            return client;
        }

        /// <summary>
        /// Creates a mail message with common settings
        /// </summary>
        private static MailMessage CreateMailMessage(string toEmail, string toName, string subject)
        {
            var config = GetConfiguration();
            
            var message = new MailMessage
            {
                From = new MailAddress(config.FromAddress, config.FromName, Encoding.UTF8),
                Subject = subject,
                SubjectEncoding = Encoding.UTF8,
                BodyEncoding = Encoding.UTF8,
                IsBodyHtml = true,
                Priority = MailPriority.Normal
            };

            if (!string.IsNullOrEmpty(toName))
            {
                message.To.Add(new MailAddress(toEmail, toName, Encoding.UTF8));
            }
            else
            {
                message.To.Add(toEmail);
            }

            return message;
        }

        private static void AppendLineWithFormat(StringBuilder builder, string format, params object[] args)
        {
            builder.AppendLine(string.Format(CultureInfo.InvariantCulture, format, args));
        }

        /// <summary>
        /// Sends an email with proper error handling and logging
        /// </summary>
        private static bool SendEmail(string toEmail, string toName, string subject, string htmlBody)
        {
            try
            {
                var config = GetConfiguration();
                
                // Check if email service is enabled
                if (!config.EnableEmailService)
                {
                    // Email service disabled - email not sent to {toEmail}
                    return false;
                }

                // Validate required parameters
                if (string.IsNullOrWhiteSpace(toEmail) || string.IsNullOrWhiteSpace(subject) || string.IsNullOrWhiteSpace(htmlBody))
                {
                    // Email send failed: Missing required parameters
                    return false;
                }

                // Validate email format
                if (!IsValidEmail(toEmail))
                {
                    // Email send failed: Invalid email format - {toEmail}
                    return false;
                }

                using (var client = CreateSmtpClient())
                using (var message = CreateMailMessage(toEmail, toName, subject))
                {
                    message.Body = htmlBody;
                    
                    client.Send(message);
                    // Email sent successfully to {toEmail} - Subject: {subject}
                    return true;
                }
            }
            catch (SmtpException smtpEx)
            {
                // SMTP error sending email to {toEmail}: {smtpEx.Message}
                return false;
            }
            catch (ArgumentException argEx)
            {
                // Invalid argument sending email to {toEmail}: {argEx.Message}
                return false;
            }
            catch (InvalidOperationException invOpEx)
            {
                // Invalid operation sending email to {toEmail}: {invOpEx.Message}
                return false;
            }
            catch (Exception ex)
            {
                // Unexpected error sending email to {toEmail}: {ex.Message}
                return false;
            }
        }

        /// <summary>
        /// Validates email address format
        /// </summary>
        private static bool IsValidEmail(string email)
        {
            try
            {
                var addr = new MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Builds the common email HTML template
        /// </summary>
        private static string BuildEmailTemplate(string title, string content, string buttonText = "", string buttonUrl = "")
        {
            var config = GetConfiguration();
            var sb = new StringBuilder();
            
            sb.AppendLine("<!DOCTYPE html>");
            sb.AppendLine("<html>");
            sb.AppendLine("<head>");
            sb.AppendLine("    <meta charset=\"UTF-8\">");
            sb.AppendLine("    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">");
            AppendLineWithFormat(sb, "    <title>{0}</title>", title);
            sb.AppendLine("    <style>");
            sb.AppendLine("        body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 0; background-color: #f4f4f4; }");
            sb.AppendLine("        .container { max-width: 600px; margin: 0 auto; background-color: white; }");
            sb.AppendLine("        .header { background-color: #4b4e6d; color: white; padding: 20px; text-align: center; }");
            sb.AppendLine("        .content { padding: 30px 20px; }");
            sb.AppendLine("        .button { display: inline-block; padding: 12px 24px; background-color: #84dcc6; color: #222222; text-decoration: none; border-radius: 5px; margin: 20px 0; }");
            sb.AppendLine("        .footer { background-color: #95a3b3; color: white; padding: 20px; text-align: center; font-size: 12px; }");
            sb.AppendLine("        .footer a { color: white; }");
            sb.AppendLine("    </style>");
            sb.AppendLine("</head>");
            sb.AppendLine("<body>");
            sb.AppendLine("    <div class=\"container\">");
            sb.AppendLine("        <div class=\"header\">");
            AppendLineWithFormat(sb, "            <h1>{0}</h1>", config.CompanyName);
            sb.AppendLine("        </div>");
            sb.AppendLine("        <div class=\"content\">");
            AppendLineWithFormat(sb, "            <h2>{0}</h2>", title);
            sb.AppendLine(content);
            
            if (!string.IsNullOrEmpty(buttonText) && !string.IsNullOrEmpty(buttonUrl))
            {
                sb.AppendLine("            <div style=\"text-align: center;\">");
                AppendLineWithFormat(sb, "                <a href=\"{0}\" class=\"button\">{1}</a>", buttonUrl, buttonText);
                sb.AppendLine("            </div>");
            }
            
            sb.AppendLine("        </div>");
            sb.AppendLine("        <div class=\"footer\">");
            AppendLineWithFormat(sb, "            <p>&copy; 2024 {0}. {1}</p>", config.CompanyName, GetLocalizedString("AllRightsReserved"));
            AppendLineWithFormat(sb, "            <p><a href=\"mailto:{0}\">{0}</a> | <a href=\"{1}\">{2}</a></p>", config.SupportEmail, config.CompanyWebsite, GetLocalizedString("VisitWebsite"));
            sb.AppendLine("        </div>");
            sb.AppendLine("    </div>");
            sb.AppendLine("</body>");
            sb.AppendLine("</html>");
            
            return sb.ToString();
        }

        /// <summary>
        /// Sends a password recovery email to the specified user
        /// </summary>
        /// <param name="userEmail">User's email address</param>
        /// <param name="userName">User's name for personalization</param>
        /// <param name="resetToken">Password reset token</param>
        /// <param name="resetUrl">URL for password reset</param>
        /// <returns>True if email was sent successfully, false otherwise</returns>
        public static bool SendPasswordRecoveryEmail(string userEmail, string userName, string resetToken, string resetUrl)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(userEmail) || string.IsNullOrWhiteSpace(resetToken) || string.IsNullOrWhiteSpace(resetUrl))
                {
                    // Password recovery email failed: Missing required parameters
                    return false;
                }

                string subject = GetLocalizedString("PasswordRecoverySubject");
                string greeting = string.IsNullOrWhiteSpace(userName) 
                    ? GetLocalizedString("PasswordRecoveryGreetingGeneric")
                    : string.Format(GetLocalizedString("PasswordRecoveryGreeting"), userName);
                
                var content = new StringBuilder();
                AppendLineWithFormat(content, "<p>{0}</p>", greeting);
                AppendLineWithFormat(content, "<p>{0}</p>", GetLocalizedString("PasswordRecoveryMessage"));
                AppendLineWithFormat(content, "<p>{0}</p>", GetLocalizedString("PasswordRecoveryInstructions"));
                AppendLineWithFormat(content, "<p style=\"color: #666; font-size: 12px;\">{0}</p>", GetLocalizedString("PasswordRecoveryExpiration"));
                AppendLineWithFormat(content, "<p style=\"color: #666; font-size: 12px;\">{0}</p>", GetLocalizedString("PasswordRecoveryDisclaimer"));

                string htmlBody = BuildEmailTemplate(
                    GetLocalizedString("PasswordRecoveryTitle"),
                    content.ToString(),
                    GetLocalizedString("ResetPasswordButton"),
                    resetUrl // URL already includes token parameter from BLL layer
                );

                bool result = SendEmail(userEmail, userName, subject, htmlBody);
                
                if (result)
                {
                    // Password recovery email sent to {userEmail}
                }
                else
                {
                    // Failed to send password recovery email to {userEmail}
                }
                
                return result;
            }
            catch (Exception ex)
            {
                // Error sending password recovery email to {userEmail}: {ex.Message}
                return false;
            }
        }

        /// <summary>
        /// Sends a password change confirmation email to the specified user
        /// </summary>
        /// <param name="userEmail">User's email address</param>
        /// <param name="userName">User's name for personalization</param>
        /// <returns>True if email was sent successfully, false otherwise</returns>
        public static bool SendPasswordChangeConfirmationEmail(string userEmail, string userName)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(userEmail))
                {
                    // Password change confirmation email failed: Missing email address
                    return false;
                }

                string subject = GetLocalizedString("PasswordChangeConfirmationSubject");
                string greeting = string.IsNullOrWhiteSpace(userName)
                    ? GetLocalizedString("PasswordChangeConfirmationGreetingGeneric")
                    : string.Format(GetLocalizedString("PasswordChangeConfirmationGreeting"), userName);

                var content = new StringBuilder();
                AppendLineWithFormat(content, "<p>{0}</p>", greeting);
                AppendLineWithFormat(content, "<p>{0}</p>", GetLocalizedString("PasswordChangeConfirmationMessage"));
                AppendLineWithFormat(content, "<p>{0}</p>", GetLocalizedString("PasswordChangeConfirmationSecurity"));
                AppendLineWithFormat(content, "<p>{0}</p>", GetLocalizedString("PasswordChangeConfirmationContact"));

                string htmlBody = BuildEmailTemplate(
                    GetLocalizedString("PasswordChangeConfirmationTitle"),
                    content.ToString()
                );

                bool result = SendEmail(userEmail, userName, subject, htmlBody);
                
                if (result)
                {
                    // Password change confirmation email sent to {userEmail}
                }
                else
                {
                    // Failed to send password change confirmation email to {userEmail}
                }
                
                return result;
            }
            catch (Exception ex)
            {
                // Error sending password change confirmation email to {userEmail}: {ex.Message}
                return false;
            }
        }

        public static bool SendSubscriptionConfirmationEmail(string userEmail, string userName, string productName, string billingCycle, decimal productPrice, string cardLast4, string cardBrand)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(userEmail) || string.IsNullOrWhiteSpace(productName))
                {
                    return false;
                }

                string subject = GetLocalizedString("SubscriptionEmailSubject");
                string greeting = string.IsNullOrWhiteSpace(userName)
                    ? GetLocalizedString("SubscriptionEmailGreetingGeneric")
                    : string.Format(GetLocalizedString("SubscriptionEmailGreeting"), userName);

                var content = new StringBuilder();
                AppendLineWithFormat(content, "<p>{0}</p>", greeting);
                AppendLineWithFormat(content, "<p>{0}</p>", string.Format(GetLocalizedString("SubscriptionEmailIntro"), productName));
                AppendLineWithFormat(content, "<p><strong>{0}:</strong> {1}</p>", GetLocalizedString("SubscriptionEmailProduct"), productName);

                string cycleText = string.IsNullOrWhiteSpace(billingCycle)
                    ? GetLocalizedString("SubscriptionEmailDefaultCycle")
                    : billingCycle;
                AppendLineWithFormat(content, "<p><strong>{0}:</strong> {1}</p>", GetLocalizedString("SubscriptionEmailPlan"), cycleText);

                AppendLineWithFormat(
                    content,
                    "<p><strong>{0}:</strong> {1}</p>",
                    GetLocalizedString("SubscriptionEmailPrice"),
                    productPrice.ToString("C", CultureInfo.CurrentCulture));

                if (!string.IsNullOrWhiteSpace(cardLast4))
                {
                    string maskedCard = string.Format(CultureInfo.InvariantCulture, "**** **** **** {0}", cardLast4);
                    string paymentDetail = maskedCard;

                    if (!string.IsNullOrWhiteSpace(cardBrand))
                    {
                        paymentDetail = string.Format(CultureInfo.InvariantCulture, "{0} ({1})", maskedCard, cardBrand);
                    }

                    AppendLineWithFormat(content, "<p><strong>{0}:</strong> {1}</p>", GetLocalizedString("SubscriptionEmailPayment"), paymentDetail);
                }

                AppendLineWithFormat(content, "<p>{0}</p>", GetLocalizedString("SubscriptionEmailSupport"));

                var config = GetConfiguration();
                string htmlBody = BuildEmailTemplate(
                    GetLocalizedString("SubscriptionEmailTitle"),
                    content.ToString(),
                    GetLocalizedString("SubscriptionEmailButton"),
                    config.CompanyWebsite
                );

                return SendEmail(userEmail, userName, subject, htmlBody);
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Sends a welcome email to new users
        /// </summary>
        /// <param name="userEmail">User's email address</param>
        /// <param name="userName">User's name for personalization</param>
        /// <param name="loginUrl">URL for user to login</param>
        /// <returns>True if email was sent successfully, false otherwise</returns>
        public static bool SendWelcomeEmail(string userEmail, string userName, string loginUrl = "")
        {
            try
            {
                if (string.IsNullOrWhiteSpace(userEmail))
                {
                    // Welcome email failed: Missing email address
                    return false;
                }

                var config = GetConfiguration();
                string subject = GetLocalizedString("WelcomeEmailSubject");
                string greeting = string.IsNullOrWhiteSpace(userName)
                    ? GetLocalizedString("WelcomeEmailGreetingGeneric")
                    : string.Format(GetLocalizedString("WelcomeEmailGreeting"), userName);

                var content = new StringBuilder();
                AppendLineWithFormat(content, "<p>{0}</p>", greeting);
                AppendLineWithFormat(content, "<p>{0}</p>", string.Format(GetLocalizedString("WelcomeEmailMessage"), config.CompanyName));
                AppendLineWithFormat(content, "<p>{0}</p>", GetLocalizedString("WelcomeEmailFeatures"));
                content.AppendLine("<ul>");
                AppendLineWithFormat(content, "    <li>{0}</li>", GetLocalizedString("WelcomeEmailFeature1"));
                AppendLineWithFormat(content, "    <li>{0}</li>", GetLocalizedString("WelcomeEmailFeature2"));
                AppendLineWithFormat(content, "    <li>{0}</li>", GetLocalizedString("WelcomeEmailFeature3"));
                content.AppendLine("</ul>");
                AppendLineWithFormat(content, "<p>{0}</p>", GetLocalizedString("WelcomeEmailSupport"));

                string buttonText = "";
                string buttonUrl = "";
                
                if (!string.IsNullOrEmpty(loginUrl))
                {
                    buttonText = GetLocalizedString("GetStartedButton");
                    buttonUrl = loginUrl;
                }

                string htmlBody = BuildEmailTemplate(
                    GetLocalizedString("WelcomeEmailTitle"),
                    content.ToString(),
                    buttonText,
                    buttonUrl
                );

                bool result = SendEmail(userEmail, userName, subject, htmlBody);
                
                if (result)
                {
                    // Welcome email sent to {userEmail}
                }
                else
                {
                    // Failed to send welcome email to {userEmail}
                }
                
                return result;
            }
            catch (Exception ex)
            {
                // Error sending welcome email to {userEmail}: {ex.Message}
                return false;
            }
        }

        /// <summary>
        /// Sends a test email - useful for configuration testing
        /// </summary>
        /// <param name="testEmail">Email address to send test email to</param>
        /// <returns>True if email was sent successfully, false otherwise</returns>
        public static bool SendTestEmail(string testEmail)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(testEmail))
                {
                    return false;
                }

                var config = GetConfiguration();
                string subject = string.Format("{0} - Email Service Test", config.CompanyName);
                
                var content = new StringBuilder();
                content.AppendLine("<p>This is a test email to verify that the email service is working correctly.</p>");
                AppendLineWithFormat(content, "<p>Sent at: {0}</p>", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture));
                AppendLineWithFormat(content, "<p>SMTP Server: {0}:{1}</p>", config.SmtpServer, config.SmtpPort);
                AppendLineWithFormat(content, "<p>SSL Enabled: {0}</p>", config.EnableSSL);

                string htmlBody = BuildEmailTemplate("Email Service Test", content.ToString());

                bool result = SendEmail(testEmail, "", subject, htmlBody);
                
                if (result)
                {
                    // Test email sent successfully to {testEmail}
                }
                else
                {
                    // Failed to send test email to {testEmail}
                }
                
                return result;
            }
            catch (Exception ex)
            {
                // Error sending test email to {testEmail}: {ex.Message}
                return false;
            }
        }
    }
}