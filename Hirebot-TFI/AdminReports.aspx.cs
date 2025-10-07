using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using ABSTRACTIONS;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class AdminReports : BasePage
    {
        private const int DefaultMaxMonths = 12;

        private readonly BillingSecurity _billingSecurity;
        private readonly SurveySecurity _surveySecurity;
        private readonly AdminSecurity _adminSecurity;
        private readonly JavaScriptSerializer _serializer;

        public AdminReports()
        {
            _billingSecurity = new BillingSecurity();
            _surveySecurity = new SurveySecurity();
            _adminSecurity = new AdminSecurity();
            _serializer = new JavaScriptSerializer();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                _adminSecurity.RedirectIfNotAdmin();
                InitializeFilters();
                LoadStatistics();
            }
        }

        private void InitializeFilters()
        {
            ddlSortDirection.Items.Clear();
            ddlSortDirection.Items.Add(new ListItem(GetResource("AdminReportsSortAscending", "Ascending"), "ASC"));
            ddlSortDirection.Items.Add(new ListItem(GetResource("AdminReportsSortDescending", "Descending"), "DESC"));
            ddlSortDirection.SelectedValue = "DESC";
            txtYear.Text = DateTime.UtcNow.ToLocalTime().Year.ToString(CultureInfo.InvariantCulture);
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            LoadStatistics();
        }

        private void LoadStatistics()
        {
            ClearError();

            int? yearFilter = ParseYear(txtYear.Text);
            string sortDirection = ddlSortDirection.SelectedValue;

            var billingResult = _billingSecurity.GetBillingStatistics(yearFilter, DefaultMaxMonths, sortDirection);
            if (!billingResult.IsSuccessful)
            {
                ShowError(billingResult.ErrorMessage);
                BindBilling(new BillingStatisticsResponse());
            }
            else
            {
                BindBilling(billingResult.Data ?? new BillingStatisticsResponse());
            }

            var surveyResult = _surveySecurity.GetSurveyStatistics();
            if (!surveyResult.IsSuccessful)
            {
                ShowError(surveyResult.ErrorMessage);
                BindSurveys(new SurveyStatisticsResponse());
            }
            else
            {
                BindSurveys(surveyResult.Data ?? new SurveyStatisticsResponse());
            }
        }

        private void BindBilling(BillingStatisticsResponse data)
        {
            if (data == null)
            {
                data = new BillingStatisticsResponse();
            }

            var summary = data.Summary ?? new BillingStatisticsSummary();
            var breakdown = data.MonthlyBreakdown ?? new List<BillingMonthlyStatistic>();
            var culture = CultureInfo.CurrentUICulture;

            litTotalBillingDocuments.Text = summary.TotalDocuments.ToString(culture);
            litPaidBillingDocuments.Text = summary.PaidDocuments.ToString(culture);
            litOutstandingBillingDocuments.Text = summary.OutstandingDocuments.ToString(culture);
            litCancelledBillingDocuments.Text = summary.CancelledDocuments.ToString(culture);

            litTotalBillingAmount.Text = summary.TotalAmount.ToString("C", culture);
            litPaidBillingAmount.Text = summary.PaidAmount.ToString("C", culture);
            litOutstandingBillingAmount.Text = summary.OutstandingAmount.ToString("C", culture);
            litAverageInvoiceAmount.Text = summary.AverageInvoiceAmount.ToString("C", culture);

            litBillingLastUpdated.Text = summary.LastUpdatedDateUtc.HasValue
                ? ToLocalDisplay(summary.LastUpdatedDateUtc.Value)
                : GetResource("AdminReportsNoData", "-");

            rptBillingMonthly.DataSource = breakdown;
            rptBillingMonthly.DataBind();

            var labels = breakdown
                .Select(m => string.Format(CultureInfo.InvariantCulture, "{0:00}/{1}", m.MonthNumber, m.YearNumber))
                .ToList();

            var chartData = new
            {
                labels,
                datasets = new List<object>
                {
                    new
                    {
                        label = GetResource("AdminReportsBillingDatasetTotal", "Total Amount"),
                        data = breakdown.Select(m => Math.Round(m.TotalAmount, 2)).ToList(),
                        borderColor = "rgba(75, 110, 160, 1)",
                        backgroundColor = "rgba(75, 110, 160, 0.2)",
                        tension = 0.3,
                        fill = true
                    },
                    new
                    {
                        label = GetResource("AdminReportsBillingDatasetPaid", "Paid Amount"),
                        data = breakdown.Select(m => Math.Round(m.PaidAmount, 2)).ToList(),
                        borderColor = "rgba(132, 220, 198, 1)",
                        backgroundColor = "rgba(132, 220, 198, 0.2)",
                        tension = 0.3,
                        fill = true
                    },
                    new
                    {
                        label = GetResource("AdminReportsBillingDatasetOutstanding", "Outstanding"),
                        data = breakdown.Select(m => Math.Round(m.OutstandingAmount, 2)).ToList(),
                        borderColor = "rgba(239, 132, 116, 1)",
                        backgroundColor = "rgba(239, 132, 116, 0.2)",
                        tension = 0.3,
                        fill = true
                    }
                }
            };

            hfBillingChartData.Value = _serializer.Serialize(chartData);
        }

        private void BindSurveys(SurveyStatisticsResponse data)
        {
            if (data == null)
            {
                data = new SurveyStatisticsResponse();
            }

            var summary = data.Summary ?? new SurveyStatisticsSummary();
            var surveys = data.Surveys ?? new List<SurveyStatisticsDetail>();
            var culture = CultureInfo.CurrentUICulture;

            litTotalSurveys.Text = summary.TotalSurveys.ToString(culture);
            litActiveSurveys.Text = summary.ActiveSurveys.ToString(culture);
            litScheduledSurveys.Text = summary.ScheduledSurveys.ToString(culture);
            litExpiredSurveys.Text = summary.ExpiredSurveys.ToString(culture);

            litSurveyResponses.Text = summary.TotalResponses.ToString(culture);
            litSurveyResponses30.Text = summary.ResponsesLast30Days.ToString(culture);
            litAverageResponses.Text = summary.AverageResponsesPerSurvey.ToString("N2", culture);
            litSurveyLastResponse.Text = summary.LastResponseDateUtc.HasValue
                ? ToLocalDisplay(summary.LastResponseDateUtc.Value)
                : GetResource("AdminReportsNoData", "-");

            rptSurveyDetails.DataSource = surveys;
            rptSurveyDetails.DataBind();

            var labels = surveys.Select(s => s.Title).ToList();
            var chartData = new
            {
                labels,
                datasets = new List<object>
                {
                    new
                    {
                        label = GetResource("AdminReportsSurveyDatasetTotal", "Total responses"),
                        data = surveys.Select(s => s.TotalResponses).ToList(),
                        backgroundColor = "rgba(75, 78, 109, 0.7)"
                    },
                    new
                    {
                        label = GetResource("AdminReportsSurveyDatasetRecent", "Last 30 days"),
                        data = surveys.Select(s => s.ResponsesLast30Days).ToList(),
                        backgroundColor = "rgba(132, 220, 198, 0.7)"
                    }
                }
            };

            hfSurveyChartData.Value = _serializer.Serialize(chartData);
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            litError.Text = HttpUtility.HtmlEncode(string.IsNullOrWhiteSpace(message) ? GetResource("AdminReportsGenericError", "An unexpected error occurred.") : message);
        }

        private void ClearError()
        {
            pnlError.Visible = false;
            litError.Text = string.Empty;
        }

        private static int? ParseYear(string input)
        {
            if (string.IsNullOrWhiteSpace(input))
            {
                return null;
            }

            if (int.TryParse(input, NumberStyles.Integer, CultureInfo.InvariantCulture, out int value) && value >= 2000 && value <= 2100)
            {
                return value;
            }

            return null;
        }

        private static string ToLocalDisplay(DateTime utcValue)
        {
            try
            {
                var localTime = TimeZoneInfo.ConvertTimeFromUtc(DateTime.SpecifyKind(utcValue, DateTimeKind.Utc), TimeZoneInfo.Local);
                return localTime.ToString("f", CultureInfo.CurrentUICulture);
            }
            catch
            {
                return utcValue.ToString("f", CultureInfo.InvariantCulture);
            }
        }

        private string GetResource(string key, string fallback)
        {
            var value = GetGlobalResourceObject("GlobalResources", key) as string;
            return string.IsNullOrWhiteSpace(value) ? fallback : value;
        }

        protected string Encode(object value)
        {
            return HttpUtility.HtmlEncode(value?.ToString() ?? string.Empty);
        }

        protected string GetDateRange(object dataItem)
        {
            if (dataItem is SurveyStatisticsDetail detail)
            {
                string start = detail.StartDateUtc.HasValue ? ToLocalDisplay(detail.StartDateUtc.Value) : GetResource("AdminReportsNoStart", "No start");
                string end = detail.EndDateUtc.HasValue ? ToLocalDisplay(detail.EndDateUtc.Value) : GetResource("AdminReportsNoEnd", "No end");

                if (!detail.StartDateUtc.HasValue && !detail.EndDateUtc.HasValue)
                {
                    return Encode(GetResource("AdminReportsNoSchedule", "No schedule defined"));
                }

                return string.Format(CultureInfo.CurrentUICulture, "{0} - {1}", HttpUtility.HtmlEncode(start), HttpUtility.HtmlEncode(end));
            }

            return string.Empty;
        }

        protected string GetSurveyStatus(object dataItem)
        {
            if (dataItem is SurveyStatisticsDetail detail)
            {
                if (detail.IsCurrentlyOpen)
                {
                    return Encode(GetResource("AdminReportsSurveyStatusOpen", "Open"));
                }

                if (detail.IsActive && detail.StartDateUtc.HasValue && detail.StartDateUtc.Value > DateTime.UtcNow)
                {
                    return Encode(GetResource("AdminReportsSurveyStatusScheduled", "Scheduled"));
                }

                if (detail.EndDateUtc.HasValue && detail.EndDateUtc.Value < DateTime.UtcNow)
                {
                    return Encode(GetResource("AdminReportsSurveyStatusExpired", "Expired"));
                }

                return detail.IsActive
                    ? Encode(GetResource("AdminReportsSurveyStatusActive", "Active"))
                    : Encode(GetResource("AdminReportsSurveyStatusInactive", "Inactive"));
            }

            return string.Empty;
        }

        protected string GetSurveyWindow(object dataItem)
        {
            if (dataItem is SurveyStatisticsDetail detail)
            {
                if (!detail.StartDateUtc.HasValue && !detail.EndDateUtc.HasValue)
                {
                    return Encode(GetResource("AdminReportsNoSchedule", "No schedule defined"));
                }

                string start = detail.StartDateUtc.HasValue ? HttpUtility.HtmlEncode(ToLocalDisplay(detail.StartDateUtc.Value)) : Encode(GetResource("AdminReportsNoStart", "No start"));
                string end = detail.EndDateUtc.HasValue ? HttpUtility.HtmlEncode(ToLocalDisplay(detail.EndDateUtc.Value)) : Encode(GetResource("AdminReportsNoEnd", "No end"));

                return string.Format(CultureInfo.CurrentUICulture, "{0}<br />{1}", start, end);
            }

            return string.Empty;
        }

        protected string GetSurveyLastResponse(object dataItem)
        {
            if (dataItem is SurveyStatisticsDetail detail)
            {
                return detail.LastResponseDateUtc.HasValue
                    ? Encode(ToLocalDisplay(detail.LastResponseDateUtc.Value))
                    : Encode(GetResource("AdminReportsNoData", "-"));
            }

            return string.Empty;
        }
    }
}
