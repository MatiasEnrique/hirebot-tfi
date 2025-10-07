using System;
using System.Collections.Generic;

namespace ABSTRACTIONS
{
    public class BillingStatisticsSummary
    {
        public int TotalDocuments { get; set; }
        public int PaidDocuments { get; set; }
        public int OutstandingDocuments { get; set; }
        public int CancelledDocuments { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal OutstandingAmount { get; set; }
        public decimal AverageInvoiceAmount { get; set; }
        public DateTime? LastUpdatedDateUtc { get; set; }
    }

    public class BillingMonthlyStatistic
    {
        public int YearNumber { get; set; }
        public int MonthNumber { get; set; }
        public string MonthName { get; set; }
        public int TotalDocuments { get; set; }
        public int PaidDocuments { get; set; }
        public int CancelledDocuments { get; set; }
        public int DraftDocuments { get; set; }
        public int IssuedDocuments { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal OutstandingAmount { get; set; }
    }

    public class BillingStatisticsResponse
    {
        public BillingStatisticsSummary Summary { get; set; }
        public List<BillingMonthlyStatistic> MonthlyBreakdown { get; set; }

        public BillingStatisticsResponse()
        {
            Summary = new BillingStatisticsSummary();
            MonthlyBreakdown = new List<BillingMonthlyStatistic>();
        }
    }

    public class BillingStatisticsResult : DatabaseResult<BillingStatisticsResponse>
    {
        public BillingStatisticsResult() : base()
        {
        }

        public BillingStatisticsResult(bool isSuccessful, BillingStatisticsResponse data, string message = "")
            : base(isSuccessful, data, isSuccessful ? 1 : 0, message)
        {
        }

        public static BillingStatisticsResult Success(BillingStatisticsResponse data, string message = "Success")
        {
            return new BillingStatisticsResult(true, data, message);
        }

        public static BillingStatisticsResult Failure(string message)
        {
            return new BillingStatisticsResult(false, new BillingStatisticsResponse(), message);
        }

        public static BillingStatisticsResult Failure(string message, Exception exception)
        {
            return new BillingStatisticsResult(false, new BillingStatisticsResponse(), message) { Exception = exception };
        }
    }

    public class SurveyStatisticsSummary
    {
        public int TotalSurveys { get; set; }
        public int ActiveSurveys { get; set; }
        public int ScheduledSurveys { get; set; }
        public int ExpiredSurveys { get; set; }
        public int TotalResponses { get; set; }
        public int ResponsesLast30Days { get; set; }
        public decimal AverageResponsesPerSurvey { get; set; }
        public DateTime? LastResponseDateUtc { get; set; }
    }

    public class SurveyStatisticsDetail
    {
        public int SurveyId { get; set; }
        public string Title { get; set; }
        public bool IsActive { get; set; }
        public DateTime? StartDateUtc { get; set; }
        public DateTime? EndDateUtc { get; set; }
        public int QuestionCount { get; set; }
        public int TotalResponses { get; set; }
        public int ResponsesLast30Days { get; set; }
        public DateTime? LastResponseDateUtc { get; set; }
        public bool IsCurrentlyOpen { get; set; }
    }

    public class SurveyStatisticsResponse
    {
        public SurveyStatisticsSummary Summary { get; set; }
        public List<SurveyStatisticsDetail> Surveys { get; set; }

        public SurveyStatisticsResponse()
        {
            Summary = new SurveyStatisticsSummary();
            Surveys = new List<SurveyStatisticsDetail>();
        }
    }

    public class SurveyStatisticsResult : DatabaseResult<SurveyStatisticsResponse>
    {
        public SurveyStatisticsResult() : base()
        {
        }

        public SurveyStatisticsResult(bool isSuccessful, SurveyStatisticsResponse data, string message = "")
            : base(isSuccessful, data, isSuccessful ? 1 : 0, message)
        {
        }

        public static SurveyStatisticsResult Success(SurveyStatisticsResponse data, string message = "Success")
        {
            return new SurveyStatisticsResult(true, data, message);
        }

        public static SurveyStatisticsResult Failure(string message)
        {
            return new SurveyStatisticsResult(false, new SurveyStatisticsResponse(), message);
        }

        public static SurveyStatisticsResult Failure(string message, Exception exception)
        {
            return new SurveyStatisticsResult(false, new SurveyStatisticsResponse(), message) { Exception = exception };
        }
    }
}
