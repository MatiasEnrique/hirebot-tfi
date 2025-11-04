using System;
using System.Globalization;
using System.Web;

namespace SERVICES
{
    /// <summary>
    /// Service for managing language preferences using Google Translate cookie-based persistence.
    /// This service exclusively uses the 'googtrans' cookie (format: /auto/{lang}) for language storage,
    /// eliminating Session dependencies for a stateless, scalable architecture.
    /// </summary>
    public static class LanguageService
    {
        /// <summary>
        /// Default language code for the application (Spanish)
        /// </summary>
        public const string DefaultLanguage = "es";

        /// <summary>
        /// Ensures a valid language is available for the current request.
        /// Reads from the googtrans cookie, falling back to the default language if not found.
        /// Automatically sets the cookie if it's missing.
        /// </summary>
        /// <param name="context">The current HTTP context</param>
        /// <returns>A valid language code (e.g., "es", "en")</returns>
        public static string EnsureLanguage(HttpContext context)
        {
            if (context == null)
            {
                return DefaultLanguage;
            }

            // Try to get language from Google Translate cookie
            var googleLanguage = GetLanguageFromGoogleCookie(context.Request);
            if (!string.IsNullOrEmpty(googleLanguage))
            {
                var normalized = NormalizeLanguage(googleLanguage);
                if (!string.IsNullOrEmpty(normalized))
                {
                    return normalized;
                }
            }

            // If no cookie found, set default language
            SetLanguage(context, DefaultLanguage);
            return DefaultLanguage;
        }

        /// <summary>
        /// Sets the language preference by writing Google Translate cookies.
        /// This is the only method that writes language cookies.
        /// </summary>
        /// <param name="context">The current HTTP context</param>
        /// <param name="languageCode">The language code to set (e.g., "es", "en")</param>
        public static void SetLanguage(HttpContext context, string languageCode)
        {
            if (context == null)
            {
                return;
            }

            var normalized = NormalizeLanguage(languageCode) ?? DefaultLanguage;
            SetGoogleTranslateCookies(context, normalized);
        }

        /// <summary>
        /// Gets a CultureInfo object for the specified language code
        /// </summary>
        /// <param name="languageCode">The language code</param>
        /// <returns>A CultureInfo object</returns>
        public static CultureInfo GetCulture(string languageCode)
        {
            var normalized = NormalizeLanguage(languageCode) ?? DefaultLanguage;
            try
            {
                return CultureInfo.GetCultureInfo(normalized);
            }
            catch (CultureNotFoundException)
            {
                return CultureInfo.GetCultureInfo(DefaultLanguage);
            }
        }

        /// <summary>
        /// Applies the specified language code to the current thread's culture
        /// </summary>
        /// <param name="languageCode">The language code to apply</param>
        public static void ApplyCulture(string languageCode)
        {
            var culture = GetCulture(languageCode);
            ApplyCulture(culture);
        }

        /// <summary>
        /// Applies the specified culture to the current thread
        /// </summary>
        /// <param name="culture">The culture to apply</param>
        public static void ApplyCulture(CultureInfo culture)
        {
            if (culture == null)
            {
                culture = CultureInfo.GetCultureInfo(DefaultLanguage);
            }

            System.Threading.Thread.CurrentThread.CurrentCulture = culture;
            System.Threading.Thread.CurrentThread.CurrentUICulture = culture;
        }

        /// <summary>
        /// Normalizes a language code to a valid culture name
        /// </summary>
        /// <param name="languageCode">The language code to normalize</param>
        /// <returns>A normalized language code or null if invalid</returns>
        public static string NormalizeLanguage(string languageCode)
        {
            if (string.IsNullOrWhiteSpace(languageCode))
            {
                return null;
            }

            try
            {
                var culture = CultureInfo.GetCultureInfo(languageCode.Trim());
                return culture.TwoLetterISOLanguageName;
            }
            catch (CultureNotFoundException)
            {
                try
                {
                    var primary = languageCode.Split('-')[0].Trim();
                    if (string.IsNullOrEmpty(primary))
                    {
                        return null;
                    }

                    var primaryCulture = CultureInfo.GetCultureInfo(primary);
                    return primaryCulture.TwoLetterISOLanguageName;
                }
                catch (CultureNotFoundException)
                {
                    return null;
                }
            }
        }

        /// <summary>
        /// Extracts the language code from the Google Translate cookie.
        /// Cookie format: /auto/{lang} (e.g., /auto/en, /auto/es)
        /// </summary>
        /// <param name="request">The HTTP request</param>
        /// <returns>The language code or null if not found</returns>
        private static string GetLanguageFromGoogleCookie(HttpRequest request)
        {
            var raw = request?.Cookies["googtrans"]?.Value;
            if (string.IsNullOrWhiteSpace(raw))
            {
                return null;
            }

            var segments = raw.Split('/');
            if (segments.Length == 0)
            {
                return null;
            }

            return segments[segments.Length - 1];
        }

        /// <summary>
        /// Writes Google Translate cookies with proper domain scoping for cross-subdomain support.
        /// Sets both 'googtrans' and 'googtransopt' cookies as required by Google Translate widget.
        /// HttpOnly is set to false to allow client-side JavaScript access.
        /// </summary>
        /// <param name="context">The HTTP context</param>
        /// <param name="language">The language code (e.g., "es", "en")</param>
        private static void SetGoogleTranslateCookies(HttpContext context, string language)
        {
            if (context?.Response == null)
            {
                return;
            }

            var response = context.Response;
            var request = context.Request;
            var googleLanguage = (language ?? DefaultLanguage).ToLowerInvariant();

            // Ensure simple language code (e.g., "en" not "en-US")
            var dashIndex = googleLanguage.IndexOf('-');
            if (dashIndex > 0)
            {
                googleLanguage = googleLanguage.Substring(0, dashIndex);
            }

            var value = "/auto/" + googleLanguage;
            var expires = DateTime.UtcNow.AddYears(1);

            // Write path-based cookies (required by all browsers)
            WriteCookie(response, "googtrans", value, expires, null);
            WriteCookie(response, "googtransopt", "1", expires, null);

            // Write domain-scoped cookies for cross-subdomain support
            var host = request?.Url?.Host;
            if (!string.IsNullOrWhiteSpace(host) && host.Contains("."))
            {
                host = host.Split(':')[0]; // Remove port if present
                WriteCookie(response, "googtrans", value, expires, host);
                WriteCookie(response, "googtransopt", "1", expires, host);
            }
        }

        /// <summary>
        /// Helper method to write a cookie with consistent settings
        /// </summary>
        /// <param name="response">The HTTP response</param>
        /// <param name="name">Cookie name</param>
        /// <param name="value">Cookie value</param>
        /// <param name="expires">Expiration date</param>
        /// <param name="domain">Optional domain (null for path-based cookie)</param>
        private static void WriteCookie(HttpResponse response, string name, string value, DateTime expires, string domain)
        {
            if (response == null)
            {
                return;
            }

            var cookie = new HttpCookie(name, value)
            {
                Expires = expires,
                HttpOnly = false, // Must be false for Google Translate widget access
                SameSite = SameSiteMode.Lax,
                Path = "/"
            };

            if (!string.IsNullOrWhiteSpace(domain))
            {
                cookie.Domain = domain;
            }

            response.Cookies.Add(cookie);
        }
    }
}
