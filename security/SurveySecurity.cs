using System;
using System.Collections.Generic;
using System.Linq;
using ABSTRACTIONS;
using BLL;
using SERVICES;

namespace SECURITY
{
    /// <summary>
    /// Security layer for survey operations.
    /// Enforces authentication/authorization and logs actions before delegating to BLL.
    /// </summary>
    public class SurveySecurity
    {
        private readonly SurveyBLL _surveyBLL;
        private readonly AdminSecurity _adminSecurity;
        private readonly UserSecurity _userSecurity;
        private readonly LogBLL _logBLL;

        public SurveySecurity()
        {
            _surveyBLL = new SurveyBLL();
            _adminSecurity = new AdminSecurity();
            _userSecurity = new UserSecurity();
            _logBLL = new LogBLL();
        }

        #region Admin Operations

        public SurveyListResult GetAllSurveysForAdmin()
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return SurveyListResult.Failure("Access denied. Admin privileges are required.");
            }

            return _surveyBLL.GetAllSurveys();
        }

        public SurveyResult CreateSurvey(Survey survey)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return SurveyResult.Failure("Access denied. Admin privileges are required.");
            }

            try
            {
                var result = _surveyBLL.CreateSurvey(survey, currentUserId.Value);
                LogSurveyResult(result, LogService.LogTypes.CREATE, currentUserId, "Survey created");
                return result;
            }
            catch (Exception ex)
            {
                LogError($"Security error creating survey: {ex.Message}", currentUserId);
                return SurveyResult.Failure("An unexpected error occurred while creating the survey.");
            }
        }

        public SurveyResult UpdateSurvey(Survey survey)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return SurveyResult.Failure("Access denied. Admin privileges are required.");
            }

            try
            {
                var result = _surveyBLL.UpdateSurvey(survey, currentUserId.Value);
                LogSurveyResult(result, LogService.LogTypes.UPDATE, currentUserId, "Survey updated");
                return result;
            }
            catch (Exception ex)
            {
                LogError($"Security error updating survey: {ex.Message}", currentUserId);
                return SurveyResult.Failure("An unexpected error occurred while updating the survey.");
            }
        }

        public DatabaseResult DeleteSurvey(int surveyId)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return DatabaseResult.Failure(-1, "Access denied. Admin privileges are required.");
            }

            var result = _surveyBLL.DeleteSurvey(surveyId);
            if (result.IsSuccessful)
            {
                LogAction(LogService.LogTypes.DELETE, $"Survey deleted (ID {surveyId})", currentUserId);
            }
            else
            {
                LogError($"Failed to delete survey ID {surveyId}: {result.ErrorMessage}", currentUserId);
            }

            return result;
        }

        public SurveyResult GetSurveyDetails(int surveyId)
        {
            if (!EnsureAdminAccess(out _))
            {
                return SurveyResult.Failure("Access denied. Admin privileges are required.");
            }

            return _surveyBLL.GetSurveyDetails(surveyId);
        }

        public SurveyStatisticsResult GetSurveyStatistics()
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return SurveyStatisticsResult.Failure("Access denied. Admin privileges are required.");
            }

            try
            {
                return _surveyBLL.GetSurveyStatistics();
            }
            catch (Exception ex)
            {
                LogError($"Security error retrieving survey statistics: {ex.Message}", currentUserId);
                return SurveyStatisticsResult.Failure("An unexpected error occurred while retrieving survey statistics.");
            }
        }

        public SurveyResult AddQuestion(SurveyQuestion question)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return SurveyResult.Failure("Access denied. Admin privileges are required.");
            }

            var result = _surveyBLL.AddQuestion(question);
            LogSurveyResult(result, LogService.LogTypes.CREATE, currentUserId, "Survey question added");
            return result;
        }

        public SurveyResult UpdateQuestion(SurveyQuestion question)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return SurveyResult.Failure("Access denied. Admin privileges are required.");
            }

            var result = _surveyBLL.UpdateQuestion(question);
            LogSurveyResult(result, LogService.LogTypes.UPDATE, currentUserId, "Survey question updated");
            return result;
        }

        public DatabaseResult DeleteQuestion(int surveyQuestionId)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return DatabaseResult.Failure(-1, "Access denied. Admin privileges are required.");
            }

            var result = _surveyBLL.DeleteQuestion(surveyQuestionId);
            if (result.IsSuccessful)
            {
                LogAction(LogService.LogTypes.DELETE, $"Survey question deleted (ID {surveyQuestionId})", currentUserId);
            }
            else
            {
                LogError($"Failed to delete survey question ID {surveyQuestionId}: {result.ErrorMessage}", currentUserId);
            }

            return result;
        }

        public SurveyResult AddOption(SurveyOption option)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return SurveyResult.Failure("Access denied. Admin privileges are required.");
            }

            var result = _surveyBLL.AddOption(option);
            LogSurveyResult(result, LogService.LogTypes.CREATE, currentUserId, "Survey option added");
            return result;
        }

        public SurveyResult UpdateOption(SurveyOption option)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return SurveyResult.Failure("Access denied. Admin privileges are required.");
            }

            var result = _surveyBLL.UpdateOption(option);
            LogSurveyResult(result, LogService.LogTypes.UPDATE, currentUserId, "Survey option updated");
            return result;
        }

        public DatabaseResult DeleteOption(int surveyOptionId)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return DatabaseResult.Failure(-1, "Access denied. Admin privileges are required.");
            }

            var result = _surveyBLL.DeleteOption(surveyOptionId);
            if (result.IsSuccessful)
            {
                LogAction(LogService.LogTypes.DELETE, $"Survey option deleted (ID {surveyOptionId})", currentUserId);
            }
            else
            {
                LogError($"Failed to delete survey option ID {surveyOptionId}: {result.ErrorMessage}", currentUserId);
            }

            return result;
        }

        #endregion

        #region User Operations

        public SurveyResult GetActiveSurveyForCurrentUser(string languageCode = null)
        {
            var currentUserId = GetCurrentUserId();
            return _surveyBLL.GetActiveSurveyForUser(currentUserId ?? 0, languageCode);
        }

        public SurveyResponseResult SubmitSurveyResponse(int surveyId, IEnumerable<SurveyAnswer> answers)
        {
            var currentUserId = GetCurrentUserId();
            if (!currentUserId.HasValue)
            {
                return SurveyResponseResult.Failure("You must be logged in to respond to surveys.");
            }

            try
            {
                var answerList = (answers ?? Enumerable.Empty<SurveyAnswer>()).ToList();
                var result = _surveyBLL.SubmitSurveyResponse(surveyId, currentUserId.Value, answerList);

                if (result.IsSuccessful)
                {
                    LogAction(LogService.LogTypes.CREATE, $"Survey response submitted (Survey {surveyId})", currentUserId);
                }
                else
                {
                    LogError($"Failed to submit survey response for survey {surveyId}: {result.ErrorMessage}", currentUserId);
                }

                return result;
            }
            catch (Exception ex)
            {
                LogError($"Security error submitting survey response for survey {surveyId}: {ex.Message}", currentUserId);
                return SurveyResponseResult.Failure("An unexpected error occurred while submitting the survey response.");
            }
        }

        public DatabaseResult OmitSurvey(int surveyId)
        {
            var currentUserId = GetCurrentUserId();
            if (!currentUserId.HasValue)
            {
                return DatabaseResult.Failure(-1, "You must be logged in to omit surveys.");
            }

            try
            {
                var result = _surveyBLL.OmitSurvey(surveyId, currentUserId.Value);

                if (result.IsSuccessful)
                {
                    LogAction(LogService.LogTypes.CREATE, $"Survey omitted (Survey {surveyId})", currentUserId);
                }
                else
                {
                    LogError($"Failed to omit survey {surveyId}: {result.ErrorMessage}", currentUserId);
                }

                return result;
            }
            catch (Exception ex)
            {
                LogError($"Security error omitting survey {surveyId}: {ex.Message}", currentUserId);
                return DatabaseResult.Failure(-1, "An unexpected error occurred while omitting the survey.");
            }
        }

        #endregion

        #region Helpers

        private bool EnsureAdminAccess(out int? currentUserId)
        {
            currentUserId = GetCurrentUserId();
            if (!currentUserId.HasValue)
            {
                return false;
            }

            return _adminSecurity.IsUserAdmin();
        }

        private int? GetCurrentUserId()
        {
            var user = _userSecurity.GetCurrentUser();
            return user?.UserId;
        }

        private void LogSurveyResult(SurveyResult result, string logType, int? userId, string actionDescription)
        {
            if (result == null)
            {
                return;
            }

            if (result.IsSuccessful)
            {
                LogAction(logType, actionDescription, userId);
            }
            else
            {
                LogError($"{actionDescription} failed: {result.ErrorMessage}", userId);
            }
        }

        private void LogAction(string logType, string description, int? userId)
        {
            _logBLL.CreateLog(new Log
            {
                LogType = logType,
                UserId = userId,
                Description = description,
                CreatedAt = DateTime.Now
            });
        }

        private void LogError(string message, int? userId)
        {
            _logBLL.CreateLog(new Log
            {
                LogType = LogService.LogTypes.ERROR,
                UserId = userId,
                Description = message,
                CreatedAt = DateTime.Now
            });
        }

        #endregion
    }
}
