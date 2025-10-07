using System;
using System.Collections.Generic;
using System.Linq;

namespace ABSTRACTIONS
{
    /// <summary>
    /// Represents a survey definition with questions and options.
    /// </summary>
    [Serializable]
    public class Survey
    {
        public int SurveyId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string LanguageCode { get; set; }
        public DateTime? StartDateUtc { get; set; }
        public DateTime? EndDateUtc { get; set; }
        public bool IsActive { get; set; }
        public bool AllowMultipleResponses { get; set; }
        public int CreatedBy { get; set; }
        public DateTime CreatedDateUtc { get; set; }
        public int? LastModifiedBy { get; set; }
        public DateTime? LastModifiedDateUtc { get; set; }

        public List<SurveyQuestion> Questions { get; set; }

        public Survey()
        {
            LanguageCode = "es";
            Questions = new List<SurveyQuestion>();
        }

        public bool IsCurrentlyAvailable(DateTime utcNow)
        {
            if (!IsActive)
            {
                return false;
            }

            if (StartDateUtc.HasValue && utcNow < StartDateUtc.Value)
            {
                return false;
            }

            if (EndDateUtc.HasValue && utcNow > EndDateUtc.Value)
            {
                return false;
            }

            return true;
        }

        public SurveyValidationResult Validate()
        {
            var result = new SurveyValidationResult();

            if (string.IsNullOrWhiteSpace(Title))
            {
                result.AddError("Survey title is required.");
            }

            if (Questions == null || Questions.Count == 0)
            {
                result.AddError("At least one question is required.");
                return result;
            }

            foreach (var question in Questions)
            {
                var questionResult = question.Validate();
                if (!questionResult.IsValid)
                {
                    foreach (var error in questionResult.ErrorMessages)
                    {
                        result.AddError(error);
                    }
                }
            }

            return result;
        }
    }

    /// <summary>
    /// Represents a survey question.
    /// </summary>
    [Serializable]
    public class SurveyQuestion
    {
        public const string QuestionTypeSingleChoice = "SingleChoice";
        public const string QuestionTypeMultipleChoice = "MultipleChoice";
        public const string QuestionTypeText = "Text";

        public int SurveyQuestionId { get; set; }
        public int SurveyId { get; set; }
        public string QuestionText { get; set; }
        public string QuestionType { get; set; }
        public bool IsRequired { get; set; }
        public int SortOrder { get; set; }

        public List<SurveyOption> Options { get; set; }

        public SurveyQuestion()
        {
            QuestionType = QuestionTypeSingleChoice;
            Options = new List<SurveyOption>();
        }

        public SurveyValidationResult Validate()
        {
            var result = new SurveyValidationResult();

            if (string.IsNullOrWhiteSpace(QuestionText))
            {
                result.AddError("Question text is required.");
            }

            if (string.IsNullOrWhiteSpace(QuestionType))
            {
                result.AddError("Question type is required.");
            }
            else
            {
                var allowedTypes = new[] { QuestionTypeSingleChoice, QuestionTypeMultipleChoice, QuestionTypeText };
                if (!allowedTypes.Contains(QuestionType))
                {
                    result.AddError($"Invalid question type: {QuestionType}.");
                }
            }

            if (Options != null && Options.Count > 0)
            {
                foreach (var option in Options)
                {
                    var optionResult = option.Validate();
                    if (!optionResult.IsValid)
                    {
                        foreach (var error in optionResult.ErrorMessages)
                        {
                            result.AddError(error);
                        }
                    }
                }
            }

            return result;
        }
    }

    /// <summary>
    /// Represents a survey option for choice questions.
    /// </summary>
    [Serializable]
    public class SurveyOption
    {
        public int SurveyOptionId { get; set; }
        public int SurveyQuestionId { get; set; }
        public string OptionText { get; set; }
        public string OptionValue { get; set; }
        public int SortOrder { get; set; }

        public SurveyValidationResult Validate()
        {
            var result = new SurveyValidationResult();

            if (string.IsNullOrWhiteSpace(OptionText))
            {
                result.AddError("Option text is required.");
            }

            return result;
        }
    }

    /// <summary>
    /// Represents a user response to a survey.
    /// </summary>
    [Serializable]
    public class SurveyResponse
    {
        public int SurveyResponseId { get; set; }
        public int SurveyId { get; set; }
        public int UserId { get; set; }
        public DateTime SubmittedDateUtc { get; set; }
        public List<SurveyAnswer> Answers { get; set; }

        public SurveyResponse()
        {
            Answers = new List<SurveyAnswer>();
        }
    }

    /// <summary>
    /// Represents an answer to a survey question.
    /// </summary>
    [Serializable]
    public class SurveyAnswer
    {
        public int SurveyAnswerId { get; set; }
        public int SurveyResponseId { get; set; }
        public int SurveyQuestionId { get; set; }
        public int? SurveyOptionId { get; set; }
        public string AnswerText { get; set; }
    }

    /// <summary>
    /// Validation result wrapper used across survey entities.
    /// </summary>
    public class SurveyValidationResult
    {
        public bool IsValid => ErrorMessages.Count == 0;
        public List<string> ErrorMessages { get; }

        public SurveyValidationResult()
        {
            ErrorMessages = new List<string>();
        }

        public void AddError(string message)
        {
            if (!string.IsNullOrWhiteSpace(message))
            {
                ErrorMessages.Add(message);
            }
        }

        public string GetErrorMessage()
        {
            return ErrorMessages.Count == 0 ? string.Empty : string.Join("; ", ErrorMessages);
        }
    }

    /// <summary>
    /// Result type for survey operations.
    /// </summary>
    public class SurveyResult : DatabaseResult<Survey>
    {
        public SurveyResult() : base()
        {
        }

        public SurveyResult(bool isSuccessful, Survey survey, string message = "") : base(isSuccessful, survey, isSuccessful ? 1 : 0, message)
        {
        }

        public static SurveyResult Success(Survey survey, string message = "Success")
        {
            return new SurveyResult(true, survey, message);
        }

        public static SurveyResult Failure(string message)
        {
            return new SurveyResult(false, null, message);
        }

        public static SurveyResult Failure(string message, Exception exception)
        {
            return new SurveyResult(false, null, message) { Exception = exception };
        }
    }

    /// <summary>
    /// Result type for survey collections.
    /// </summary>
    public class SurveyListResult : DatabaseResult<List<Survey>>
    {
        public SurveyListResult() : base()
        {
            Data = new List<Survey>();
        }

        public SurveyListResult(bool isSuccessful, List<Survey> surveys, string message = "") : base(isSuccessful, surveys, isSuccessful ? 1 : 0, message)
        {
        }

        public static SurveyListResult Success(List<Survey> surveys, string message = "Success")
        {
            return new SurveyListResult(true, surveys, message);
        }

        public static SurveyListResult Failure(string message)
        {
            return new SurveyListResult(false, new List<Survey>(), message);
        }

        public static SurveyListResult Failure(string message, Exception exception)
        {
            return new SurveyListResult(false, new List<Survey>(), message) { Exception = exception };
        }
    }

    /// <summary>
    /// Result type for survey response submissions.
    /// </summary>
    public class SurveyResponseResult : DatabaseResult<SurveyResponse>
    {
        public SurveyResponseResult() : base()
        {
        }

        public SurveyResponseResult(bool isSuccessful, SurveyResponse response, string message = "") : base(isSuccessful, response, isSuccessful ? 1 : 0, message)
        {
        }

        public static SurveyResponseResult Success(SurveyResponse response, string message = "Success")
        {
            return new SurveyResponseResult(true, response, message);
        }

        public static SurveyResponseResult Failure(string message)
        {
            return new SurveyResponseResult(false, null, message);
        }

        public static SurveyResponseResult Failure(string message, Exception exception)
        {
            return new SurveyResponseResult(false, null, message) { Exception = exception };
        }
    }
}
