using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Script.Serialization;
using System.Net.Http;

namespace SERVICES
{
    public sealed class RecaptchaValidationResult
    {
        public bool IsValid { get; private set; }
        public string FailureReason { get; private set; }
        public IReadOnlyList<string> ErrorCodes { get; private set; }

        public RecaptchaValidationResult(bool isValid, string failureReason, IEnumerable<string> errorCodes)
        {
            IsValid = isValid;
            FailureReason = failureReason;
            ErrorCodes = (errorCodes ?? new string[0]).ToArray();
        }

        public RecaptchaValidationResult(bool isValid)
            : this(isValid, null, null)
        {
        }

        public RecaptchaValidationResult(bool isValid, string failureReason)
            : this(isValid, failureReason, null)
        {
        }
    }

    public class RecaptchaService
    {
        private const string VerificationEndpoint = "https://www.google.com/recaptcha/api/siteverify";

        public RecaptchaValidationResult ValidateToken(string responseToken, string secretKey, string remoteIp = null)
        {
            if (string.IsNullOrWhiteSpace(secretKey))
            {
                return new RecaptchaValidationResult(false, "missing-secret", new[] { "missing-secret" });
            }

            if (string.IsNullOrWhiteSpace(responseToken))
            {
                return new RecaptchaValidationResult(false, "missing-input-response", new[] { "missing-input-response" });
            }

            try
            {
                using (var client = new HttpClient())
                {
                    var payload = new List<KeyValuePair<string, string>>
                    {
                        new KeyValuePair<string, string>("secret", secretKey),
                        new KeyValuePair<string, string>("response", responseToken)
                    };

                    if (!string.IsNullOrWhiteSpace(remoteIp))
                    {
                        payload.Add(new KeyValuePair<string, string>("remoteip", remoteIp));
                    }

                    using (var content = new FormUrlEncodedContent(payload))
                    {
                        var httpResponse = client.PostAsync(VerificationEndpoint, content).Result;
                        httpResponse.EnsureSuccessStatusCode();

                        var json = httpResponse.Content.ReadAsStringAsync().Result;
                        var serializer = new JavaScriptSerializer();
                        var apiResult = serializer.Deserialize<RecaptchaApiResponse>(json);

                        if (apiResult == null)
                        {
                            return new RecaptchaValidationResult(false, "invalid-api-response");
                        }

                        return apiResult.Success
                            ? new RecaptchaValidationResult(true)
                            : new RecaptchaValidationResult(false, "verification-failed", apiResult.ErrorCodes);
                    }
                }
            }
            catch (Exception)
            {
                return new RecaptchaValidationResult(false, "verification-exception", new[] { "recaptcha-verification-error" });
            }
        }

        private sealed class RecaptchaApiResponse
        {
            public bool Success { get; set; }
            public string Challenge_ts { get; set; }
            public string Hostname { get; set; }
            public string[] ErrorCodes { get; set; }
        }
    }
}
