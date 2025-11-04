using System;
using System.Collections.Generic;

namespace ABSTRACTIONS
{
    /// <summary>
    /// Represents survey results data for chart visualization.
    /// Contains vote counts per option for a specific survey.
    /// </summary>
    [Serializable]
    public class SurveyResultData
    {
        public int SurveyId { get; set; }
        public string SurveyTitle { get; set; }
        public List<SurveyQuestionResult> Questions { get; set; }

        public SurveyResultData()
        {
            Questions = new List<SurveyQuestionResult>();
        }
    }

    /// <summary>
    /// Represents vote count results for a specific survey question.
    /// </summary>
    [Serializable]
    public class SurveyQuestionResult
    {
        public int SurveyQuestionId { get; set; }
        public string QuestionText { get; set; }
        public string QuestionType { get; set; }
        public int TotalVotes { get; set; }
        public List<SurveyOptionResult> Options { get; set; }
        public List<SurveyTextAnswer> TextAnswers { get; set; }

        public SurveyQuestionResult()
        {
            Options = new List<SurveyOptionResult>();
            TextAnswers = new List<SurveyTextAnswer>();
        }
    }

    /// <summary>
    /// Represents vote count for a specific survey option.
    /// </summary>
    [Serializable]
    public class SurveyOptionResult
    {
        public int SurveyOptionId { get; set; }
        public string OptionText { get; set; }
        public int VoteCount { get; set; }
        public decimal VotePercentage { get; set; }
    }

    /// <summary>
    /// Represents a text answer for a unique answer survey question.
    /// </summary>
    [Serializable]
    public class SurveyTextAnswer
    {
        public int SurveyAnswerId { get; set; }
        public string AnswerText { get; set; }
        public DateTime SubmittedDateUtc { get; set; }
    }

    /// <summary>
    /// Result type for survey result data operations.
    /// </summary>
    public class SurveyResultDataResult : DatabaseResult<SurveyResultData>
    {
        public SurveyResultDataResult() : base()
        {
        }

        public SurveyResultDataResult(bool isSuccessful, SurveyResultData data, string message = "") 
            : base(isSuccessful, data, isSuccessful ? 1 : 0, message)
        {
        }

        public static SurveyResultDataResult Success(SurveyResultData data, string message = "Success")
        {
            return new SurveyResultDataResult(true, data, message);
        }

        public static SurveyResultDataResult Failure(string message)
        {
            return new SurveyResultDataResult(false, null, message);
        }

        public static SurveyResultDataResult Failure(string message, Exception exception)
        {
            return new SurveyResultDataResult(false, null, message) { Exception = exception };
        }
    }
}
