using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ABSTRACTIONS;
using DAL;

namespace BLL
{
    /// <summary>
    /// Business logic layer for survey management.
    /// Applies validation, expiration checks, and normalization before delegating to DAL.
    /// </summary>
    public class SurveyBLL
    {
        private readonly SurveyDAL _surveyDal;

        public SurveyBLL()
        {
            _surveyDal = new SurveyDAL();
        }

        public SurveyListResult GetAllSurveys()
        {
            return _surveyDal.GetAllSurveys();
        }

        public SurveyStatisticsResult GetSurveyStatistics()
        {
            var dalResult = _surveyDal.GetSurveyStatistics();
            if (dalResult.IsSuccessful)
            {
                var message = string.IsNullOrWhiteSpace(dalResult.ErrorMessage)
                    ? "Survey statistics retrieved successfully."
                    : dalResult.ErrorMessage;
                return SurveyStatisticsResult.Success(dalResult.Data, message);
            }

            var failureMessage = string.IsNullOrWhiteSpace(dalResult.ErrorMessage)
                ? "Unable to retrieve survey statistics."
                : dalResult.ErrorMessage;

            return SurveyStatisticsResult.Failure(failureMessage, dalResult.Exception);
        }

        public SurveyResultDataResult GetSurveyResults(int surveyId)
        {
            if (surveyId <= 0)
            {
                return SurveyResultDataResult.Failure(GetLocalizedString("SurveyInvalidIdentifier"));
            }

            var dalResult = _surveyDal.GetSurveyResultsForDisplay(surveyId);
            if (!dalResult.IsSuccessful)
            {
                return SurveyResultDataResult.Failure(
                    dalResult.ErrorMessage ?? GetLocalizedString("SurveyResultsNotAvailable"), 
                    dalResult.Exception);
            }

            return SurveyResultDataResult.Success(dalResult.Data, dalResult.ErrorMessage);
        }

        public SurveyResult GetSurveyDetails(int surveyId)
        {
            if (surveyId <= 0)
            {
                return SurveyResult.Failure(GetLocalizedString("SurveyInvalidIdentifier"));
            }

            var dalResult = _surveyDal.GetSurveyById(surveyId);
            if (!dalResult.IsSuccessful)
            {
                return SurveyResult.Failure(dalResult.ErrorMessage ?? GetLocalizedString("SurveyNotFound"), dalResult.Exception);
            }

            return SurveyResult.Success(dalResult.Data, dalResult.ErrorMessage);
        }

        public SurveyResult CreateSurvey(Survey survey, int currentUserId)
        {
            if (survey == null)
            {
                return SurveyResult.Failure(GetLocalizedString("SurveyPayloadMissing"));
            }

            if (currentUserId <= 0)
            {
                return SurveyResult.Failure(GetLocalizedString("UserInvalidIdentifier"));
            }

            survey.CreatedBy = currentUserId;
            survey.LastModifiedBy = currentUserId;
            NormalizeSurveyDates(survey);

            var validation = survey.Validate();
            if (!validation.IsValid)
            {
                return SurveyResult.Failure(validation.GetErrorMessage());
            }

            var dalResult = _surveyDal.CreateSurvey(survey);
            if (!dalResult.IsSuccessful)
            {
                return SurveyResult.Failure(dalResult.ErrorMessage ?? GetLocalizedString("SurveyCreateFailed"), dalResult.Exception);
            }

            return SurveyResult.Success(dalResult.Data, dalResult.ErrorMessage);
        }

        public SurveyResult UpdateSurvey(Survey survey, int currentUserId)
        {
            if (survey == null || survey.SurveyId <= 0)
            {
                return SurveyResult.Failure(GetLocalizedString("SurveyInvalidIdentifier"));
            }

            if (currentUserId <= 0)
            {
                return SurveyResult.Failure(GetLocalizedString("UserInvalidIdentifier"));
            }

            survey.LastModifiedBy = currentUserId;
            NormalizeSurveyDates(survey);

            var validation = survey.Validate();
            if (!validation.IsValid)
            {
                return SurveyResult.Failure(validation.GetErrorMessage());
            }

            var dalResult = _surveyDal.UpdateSurvey(survey);
            if (!dalResult.IsSuccessful)
            {
                return SurveyResult.Failure(dalResult.ErrorMessage ?? GetLocalizedString("SurveyUpdateFailed"), dalResult.Exception);
            }

            return SurveyResult.Success(dalResult.Data, dalResult.ErrorMessage);
        }

        public DatabaseResult DeleteSurvey(int surveyId)
        {
            if (surveyId <= 0)
            {
                return DatabaseResult.Failure(-1, GetLocalizedString("SurveyInvalidIdentifier"));
            }

            return _surveyDal.DeleteSurvey(surveyId);
        }

        public SurveyResult AddQuestion(SurveyQuestion question)
        {
            if (question == null)
            {
                return SurveyResult.Failure(GetLocalizedString("SurveyQuestionPayloadMissing"));
            }

            if (question.SurveyId <= 0)
            {
                return SurveyResult.Failure(GetLocalizedString("SurveyInvalidIdentifier"));
            }

            if (question.SortOrder <= 0)
            {
                question.SortOrder = 1;
            }

            var validation = question.Validate();
            if (!validation.IsValid)
            {
                return SurveyResult.Failure(validation.GetErrorMessage());
            }

            return _surveyDal.CreateQuestion(question);
        }

        public SurveyResult UpdateQuestion(SurveyQuestion question)
        {
            if (question == null || question.SurveyQuestionId <= 0)
            {
                return SurveyResult.Failure(GetLocalizedString("SurveyQuestionInvalidIdentifier"));
            }

            var validation = question.Validate();
            if (!validation.IsValid)
            {
                return SurveyResult.Failure(validation.GetErrorMessage());
            }

            return _surveyDal.UpdateQuestion(question);
        }

        public DatabaseResult DeleteQuestion(int surveyQuestionId)
        {
            return _surveyDal.DeleteQuestion(surveyQuestionId);
        }

        public SurveyResult AddOption(SurveyOption option)
        {
            if (option == null)
            {
                return SurveyResult.Failure(GetLocalizedString("SurveyOptionPayloadMissing"));
            }

            if (option.SurveyQuestionId <= 0)
            {
                return SurveyResult.Failure(GetLocalizedString("SurveyQuestionInvalidIdentifier"));
            }

            if (option.SortOrder <= 0)
            {
                option.SortOrder = 1;
            }

            var validation = option.Validate();
            if (!validation.IsValid)
            {
                return SurveyResult.Failure(validation.GetErrorMessage());
            }

            return _surveyDal.CreateOption(option);
        }

        public SurveyResult UpdateOption(SurveyOption option)
        {
            if (option == null || option.SurveyOptionId <= 0)
            {
                return SurveyResult.Failure(GetLocalizedString("SurveyOptionInvalidIdentifier"));
            }

            var validation = option.Validate();
            if (!validation.IsValid)
            {
                return SurveyResult.Failure(validation.GetErrorMessage());
            }

            return _surveyDal.UpdateOption(option);
        }

        public DatabaseResult DeleteOption(int surveyOptionId)
        {
            return _surveyDal.DeleteOption(surveyOptionId);
        }

        public SurveyResult GetActiveSurveyForUser(int userId, string languageCode)
        {
            var dalResult = _surveyDal.GetActiveSurveyForDisplay(languageCode, DateTime.UtcNow, userId > 0 ? userId : (int?)null);
            if (!dalResult.IsSuccessful)
            {
                return SurveyResult.Failure(dalResult.ErrorMessage ?? GetLocalizedString("SurveyRetrieveFailed"), dalResult.Exception);
            }

            var survey = dalResult.Data;
            if (survey == null)
            {
                return SurveyResult.Success(null, dalResult.ErrorMessage);
            }

            if (!survey.IsCurrentlyAvailable(DateTime.UtcNow))
            {
                return SurveyResult.Success(null, GetLocalizedString("SurveyNotAvailable"));
            }

            return SurveyResult.Success(survey, dalResult.ErrorMessage);
        }

        public SurveyResponseResult SubmitSurveyResponse(int surveyId, int userId, IEnumerable<SurveyAnswer> answers)
        {
            if (surveyId <= 0)
            {
                return SurveyResponseResult.Failure(GetLocalizedString("SurveyInvalidIdentifier"));
            }

            if (userId <= 0)
            {
                return SurveyResponseResult.Failure(GetLocalizedString("UserInvalidIdentifier"));
            }

            if (answers == null)
            {
                return SurveyResponseResult.Failure(GetLocalizedString("SurveyAnswersMissing"));
            }

            var surveyResult = _surveyDal.GetSurveyById(surveyId);
            if (!surveyResult.IsSuccessful || surveyResult.Data == null)
            {
                return SurveyResponseResult.Failure(surveyResult.ErrorMessage ?? GetLocalizedString("SurveyNotFound"), surveyResult.Exception);
            }

            var survey = surveyResult.Data;
            if (!survey.IsCurrentlyAvailable(DateTime.UtcNow))
            {
                return SurveyResponseResult.Failure(GetLocalizedString("SurveyNotAvailable"));
            }

            if (!survey.AllowMultipleResponses && _surveyDal.HasUserResponded(survey.SurveyId, userId))
            {
                return SurveyResponseResult.Failure(GetLocalizedString("SurveyAlreadyAnswered"));
            }

            var normalizedAnswersResult = NormalizeAnswers(survey, answers);
            if (!normalizedAnswersResult.IsValid)
            {
                return SurveyResponseResult.Failure(normalizedAnswersResult.GetErrorMessage());
            }

            var dalResult = _surveyDal.SaveSurveyResponse(survey.SurveyId, userId, survey.AllowMultipleResponses, normalizedAnswersResult.Data);
            if (!dalResult.IsSuccessful)
            {
                return SurveyResponseResult.Failure(dalResult.ErrorMessage ?? GetLocalizedString("SurveySubmitFailed"), dalResult.Exception);
            }

            return SurveyResponseResult.Success(dalResult.Data, dalResult.ErrorMessage);
        }

        public DatabaseResult OmitSurvey(int surveyId, int userId)
        {
            if (surveyId <= 0)
            {
                return DatabaseResult.Failure(-1, GetLocalizedString("SurveyInvalidIdentifier"));
            }

            if (userId <= 0)
            {
                return DatabaseResult.Failure(-1, GetLocalizedString("UserInvalidIdentifier"));
            }

            try
            {
                var dalResult = _surveyDal.RecordSurveyOmission(surveyId, userId);
                if (!dalResult.IsSuccessful)
                {
                    return DatabaseResult.Failure(dalResult.ResultCode, dalResult.ErrorMessage ?? GetLocalizedString("SurveyOmissionFailed"));
                }

                return DatabaseResult.Success(dalResult.ErrorMessage ?? GetLocalizedString("SurveyOmissionRecorded"));
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure(string.Format("Unexpected error recording survey omission: {0}", ex.Message), ex);
            }
        }

        private static void NormalizeSurveyDates(Survey survey)
        {
            if (survey.StartDateUtc.HasValue)
            {
                survey.StartDateUtc = DateTime.SpecifyKind(survey.StartDateUtc.Value, DateTimeKind.Utc);
            }

            if (survey.EndDateUtc.HasValue)
            {
                survey.EndDateUtc = DateTime.SpecifyKind(survey.EndDateUtc.Value, DateTimeKind.Utc);
            }

            if (survey.EndDateUtc.HasValue && survey.StartDateUtc.HasValue && survey.EndDateUtc.Value < survey.StartDateUtc.Value)
            {
                // Swap if incorrectly ordered
                var temp = survey.StartDateUtc;
                survey.StartDateUtc = survey.EndDateUtc;
                survey.EndDateUtc = temp;
            }
        }

        private static NormalizedAnswersResult NormalizeAnswers(Survey survey, IEnumerable<SurveyAnswer> rawAnswers)
        {
            var result = new NormalizedAnswersResult();

            var answersByQuestion = rawAnswers
                .GroupBy(a => a.SurveyQuestionId)
                .ToDictionary(g => g.Key, g => g.ToList());

            foreach (var question in survey.Questions)
            {
                answersByQuestion.TryGetValue(question.SurveyQuestionId, out var providedAnswers);
                var optionList = question.Options ?? new List<SurveyOption>();

                if (question.IsRequired && (providedAnswers == null || providedAnswers.Count == 0 || providedAnswers.TrueForAll(a => string.IsNullOrWhiteSpace(a.AnswerText) && !a.SurveyOptionId.HasValue)))
                {
                    result.AddError(string.Format(GetLocalizedString("SurveyQuestionRequired"), question.QuestionText));
                    continue;
                }

                var normalizedForQuestion = new List<SurveyAnswer>();

                switch (question.QuestionType)
                {
                    case SurveyQuestion.QuestionTypeText:
                        if (providedAnswers != null && providedAnswers.Count > 0)
                        {
                            var firstAnswer = providedAnswers.First();
                            var text = (firstAnswer.AnswerText ?? string.Empty).Trim();

                            if (question.IsRequired && string.IsNullOrWhiteSpace(text))
                            {
                                result.AddError(string.Format(GetLocalizedString("SurveyQuestionRequired"), question.QuestionText));
                                break;
                            }

                            if (!string.IsNullOrWhiteSpace(text))
                            {
                                normalizedForQuestion.Add(new SurveyAnswer
                                {
                                    SurveyQuestionId = question.SurveyQuestionId,
                                    SurveyOptionId = null,
                                    AnswerText = text
                                });
                            }
                        }
                        break;

                    case SurveyQuestion.QuestionTypeSingleChoice:
                        if (providedAnswers == null || providedAnswers.Count == 0)
                        {
                            if (question.IsRequired)
                            {
                                result.AddError(string.Format(GetLocalizedString("SurveyQuestionRequired"), question.QuestionText));
                            }
                            break;
                        }

                        var firstChoice = providedAnswers.FirstOrDefault(a => a.SurveyOptionId.HasValue);
                        if (firstChoice == null)
                        {
                            result.AddError(string.Format(GetLocalizedString("SurveyInvalidOption"), question.QuestionText));
                            break;
                        }

                        if (!optionList.Any(o => o.SurveyOptionId == firstChoice.SurveyOptionId))
                        {
                            result.AddError(string.Format(GetLocalizedString("SurveyInvalidOption"), question.QuestionText));
                            break;
                        }

                        normalizedForQuestion.Add(new SurveyAnswer
                        {
                            SurveyQuestionId = question.SurveyQuestionId,
                            SurveyOptionId = firstChoice.SurveyOptionId,
                            AnswerText = null
                        });
                        break;

                    case SurveyQuestion.QuestionTypeMultipleChoice:
                        if (providedAnswers == null || providedAnswers.Count == 0)
                        {
                            if (question.IsRequired)
                            {
                                result.AddError(string.Format(GetLocalizedString("SurveyQuestionRequired"), question.QuestionText));
                            }
                            break;
                        }

                        foreach (var answer in providedAnswers.Where(a => a.SurveyOptionId.HasValue))
                        {
                            if (!optionList.Any(o => o.SurveyOptionId == answer.SurveyOptionId))
                            {
                                result.AddError(string.Format(GetLocalizedString("SurveyInvalidOption"), question.QuestionText));
                                normalizedForQuestion.Clear();
                                break;
                            }

                            normalizedForQuestion.Add(new SurveyAnswer
                            {
                                SurveyQuestionId = question.SurveyQuestionId,
                                SurveyOptionId = answer.SurveyOptionId,
                                AnswerText = null
                            });
                        }

                        if (question.IsRequired && normalizedForQuestion.Count == 0)
                        {
                            result.AddError(string.Format(GetLocalizedString("SurveyQuestionRequired"), question.QuestionText));
                        }
                        break;
                }

                foreach (var normalized in normalizedForQuestion)
                {
                    result.Data.Add(normalized);
                }
            }

            return result;
        }

        private static string GetLocalizedString(string key)
        {
            try
            {
                var context = HttpContext.Current;
                if (context != null)
                {
                    var value = HttpContext.GetGlobalResourceObject("GlobalResources", key) as string;
                    if (!string.IsNullOrWhiteSpace(value))
                    {
                        return value;
                    }
                }
            }
            catch
            {
                // Ignore localization errors and fallback to key.
            }

            return key;
        }

        private class NormalizedAnswersResult : SurveyValidationResult
        {
            public List<SurveyAnswer> Data { get; }

            public NormalizedAnswersResult()
            {
                Data = new List<SurveyAnswer>();
            }
        }
    }
}
