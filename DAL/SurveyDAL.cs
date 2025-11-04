using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using ABSTRACTIONS;

namespace DAL
{
    /// <summary>
    /// Data access layer for survey operations.
    /// Wraps stored procedures defined in Database/SurveyStoredProcedures.sql.
    /// </summary>
    public class SurveyDAL
    {
        public SurveyListResult GetAllSurveys()
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Survey_GetAll", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        var surveys = new List<Survey>();
                        while (reader.Read())
                        {
                            surveys.Add(MapSurvey(reader));
                        }

                        return SurveyListResult.Success(surveys, "Surveys retrieved successfully.");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return SurveyListResult.Failure(string.Format("Database error retrieving surveys: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return SurveyListResult.Failure(string.Format("Unexpected error retrieving surveys: {0}", ex.Message), ex);
            }
        }

        public SurveyResult GetSurveyById(int surveyId)
        {
            if (surveyId <= 0)
            {
                return SurveyResult.Failure("SurveyId must be positive.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Survey_GetById", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SurveyId", surveyId);

                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        Survey survey = null;
                        if (reader.Read())
                        {
                            survey = MapSurvey(reader);
                        }

                        if (survey == null)
                        {
                            return SurveyResult.Failure("Survey not found.");
                        }

                        if (reader.NextResult())
                        {
                            var questions = new List<SurveyQuestion>();
                            while (reader.Read())
                            {
                                questions.Add(MapQuestion(reader));
                            }
                            survey.Questions = questions;
                        }

                        if (reader.NextResult() && survey.Questions != null && survey.Questions.Count > 0)
                        {
                            var questionLookup = survey.Questions.ToDictionary(q => q.SurveyQuestionId, q => q);
                            while (reader.Read())
                            {
                                var option = MapOption(reader);
                                if (questionLookup.TryGetValue(option.SurveyQuestionId, out var question))
                                {
                                    question.Options.Add(option);
                                }
                            }
                        }

                        return SurveyResult.Success(survey, "Survey retrieved successfully.");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return SurveyResult.Failure(string.Format("Database error retrieving survey: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return SurveyResult.Failure(string.Format("Unexpected error retrieving survey: {0}", ex.Message), ex);
            }
        }

        public SurveyResult GetActiveSurveyForDisplay(string languageCode, DateTime utcNow, int? userId = null)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Survey_GetActiveForDisplay", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@CurrentUtc", utcNow);
                    command.Parameters.AddWithValue("@LanguageCode", (object)languageCode ?? DBNull.Value);
                    command.Parameters.AddWithValue("@UserId", userId.HasValue ? (object)userId.Value : DBNull.Value);

                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        Survey survey = null;
                        if (reader.Read())
                        {
                            survey = MapSurvey(reader);
                        }

                        if (survey == null)
                        {
                            return SurveyResult.Success(null, "No active survey available.");
                        }

                        if (reader.NextResult())
                        {
                            var questions = new List<SurveyQuestion>();
                            while (reader.Read())
                            {
                                questions.Add(MapQuestion(reader));
                            }
                            survey.Questions = questions;
                        }

                        if (reader.NextResult() && survey.Questions != null && survey.Questions.Count > 0)
                        {
                            var lookup = survey.Questions.ToDictionary(q => q.SurveyQuestionId, q => q);
                            while (reader.Read())
                            {
                                var option = MapOption(reader);
                                if (lookup.TryGetValue(option.SurveyQuestionId, out var question))
                                {
                                    question.Options.Add(option);
                                }
                            }
                        }

                        return SurveyResult.Success(survey, "Active survey retrieved successfully.");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return SurveyResult.Failure(string.Format("Database error retrieving active survey: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return SurveyResult.Failure(string.Format("Unexpected error retrieving active survey: {0}", ex.Message), ex);
            }
        }

        public SurveyResult CreateSurvey(Survey survey)
        {
            if (survey == null)
            {
                return SurveyResult.Failure("Survey payload cannot be null.");
            }

            var validation = survey.Validate();
            if (!validation.IsValid)
            {
                return SurveyResult.Failure(validation.GetErrorMessage());
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Survey_Create", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@Title", survey.Title ?? string.Empty);
                    command.Parameters.AddWithValue("@Description", ToDbValue(survey.Description));
                    command.Parameters.AddWithValue("@LanguageCode", survey.LanguageCode ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@StartDateUtc", ToDbValue(survey.StartDateUtc));
                    command.Parameters.AddWithValue("@EndDateUtc", ToDbValue(survey.EndDateUtc));
                    command.Parameters.AddWithValue("@IsActive", survey.IsActive);
                    command.Parameters.AddWithValue("@AllowMultipleResponses", survey.AllowMultipleResponses);
                    command.Parameters.AddWithValue("@CreatedBy", survey.CreatedBy);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255) { Direction = ParameterDirection.Output };
                    var newIdParam = new SqlParameter("@NewSurveyId", SqlDbType.Int) { Direction = ParameterDirection.Output };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);
                    command.Parameters.Add(newIdParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = ToInt(resultCodeParam.Value);
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;
                    int newSurveyId = ToInt(newIdParam.Value);

                    if (resultCode == 1 && newSurveyId > 0)
                    {
                        survey.SurveyId = newSurveyId;
                        return SurveyResult.Success(survey, string.IsNullOrWhiteSpace(resultMessage) ? "Survey created successfully." : resultMessage);
                    }

                    return SurveyResult.Failure(string.IsNullOrWhiteSpace(resultMessage) ? "Unable to create survey." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return SurveyResult.Failure(string.Format("Database error creating survey: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return SurveyResult.Failure(string.Format("Unexpected error creating survey: {0}", ex.Message), ex);
            }
        }

        public SurveyResult UpdateSurvey(Survey survey)
        {
            if (survey == null || survey.SurveyId <= 0)
            {
                return SurveyResult.Failure("Survey payload is invalid.");
            }

            var validation = survey.Validate();
            if (!validation.IsValid)
            {
                return SurveyResult.Failure(validation.GetErrorMessage());
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Survey_Update", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@SurveyId", survey.SurveyId);
                    command.Parameters.AddWithValue("@Title", survey.Title ?? string.Empty);
                    command.Parameters.AddWithValue("@Description", ToDbValue(survey.Description));
                    command.Parameters.AddWithValue("@LanguageCode", survey.LanguageCode ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@StartDateUtc", ToDbValue(survey.StartDateUtc));
                    command.Parameters.AddWithValue("@EndDateUtc", ToDbValue(survey.EndDateUtc));
                    command.Parameters.AddWithValue("@IsActive", survey.IsActive);
                    command.Parameters.AddWithValue("@AllowMultipleResponses", survey.AllowMultipleResponses);
                    command.Parameters.AddWithValue("@ModifiedBy", survey.LastModifiedBy ?? survey.CreatedBy);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255) { Direction = ParameterDirection.Output };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = ToInt(resultCodeParam.Value);
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;

                    if (resultCode == 1)
                    {
                        return SurveyResult.Success(survey, string.IsNullOrWhiteSpace(resultMessage) ? "Survey updated successfully." : resultMessage);
                    }

                    return SurveyResult.Failure(string.IsNullOrWhiteSpace(resultMessage) ? "Unable to update survey." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return SurveyResult.Failure(string.Format("Database error updating survey: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return SurveyResult.Failure(string.Format("Unexpected error updating survey: {0}", ex.Message), ex);
            }
        }

        public DatabaseResult DeleteSurvey(int surveyId)
        {
            if (surveyId <= 0)
            {
                return DatabaseResult.Failure(-1, "SurveyId must be positive.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Survey_Delete", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SurveyId", surveyId);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255) { Direction = ParameterDirection.Output };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = ToInt(resultCodeParam.Value);
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;

                    if (resultCode == 1)
                    {
                        return DatabaseResult.Success(string.IsNullOrWhiteSpace(resultMessage) ? "Survey deleted successfully." : resultMessage);
                    }

                    return DatabaseResult.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Unable to delete survey." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure(string.Format("Database error deleting survey: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure(string.Format("Unexpected error deleting survey: {0}", ex.Message), ex);
            }
        }

        public SurveyResult CreateQuestion(SurveyQuestion question)
        {
            if (question == null)
            {
                return SurveyResult.Failure("Question payload cannot be null.");
            }

            var validation = question.Validate();
            if (!validation.IsValid)
            {
                return SurveyResult.Failure(validation.GetErrorMessage());
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_SurveyQuestion_Create", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SurveyId", question.SurveyId);
                    command.Parameters.AddWithValue("@QuestionText", question.QuestionText ?? string.Empty);
                    command.Parameters.AddWithValue("@QuestionType", question.QuestionType ?? SurveyQuestion.QuestionTypeSingleChoice);
                    command.Parameters.AddWithValue("@IsRequired", question.IsRequired);
                    command.Parameters.AddWithValue("@SortOrder", question.SortOrder);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255) { Direction = ParameterDirection.Output };
                    var newIdParam = new SqlParameter("@NewSurveyQuestionId", SqlDbType.Int) { Direction = ParameterDirection.Output };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);
                    command.Parameters.Add(newIdParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = ToInt(resultCodeParam.Value);
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;
                    int newId = ToInt(newIdParam.Value);

                    if (resultCode == 1 && newId > 0)
                    {
                        question.SurveyQuestionId = newId;
                        return SurveyResult.Success(new Survey { SurveyId = question.SurveyId, Questions = new List<SurveyQuestion> { question } }, string.IsNullOrWhiteSpace(resultMessage) ? "Question created successfully." : resultMessage);
                    }

                    return SurveyResult.Failure(string.IsNullOrWhiteSpace(resultMessage) ? "Unable to create question." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return SurveyResult.Failure(string.Format("Database error creating survey question: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return SurveyResult.Failure(string.Format("Unexpected error creating survey question: {0}", ex.Message), ex);
            }
        }

        public SurveyResult UpdateQuestion(SurveyQuestion question)
        {
            if (question == null || question.SurveyQuestionId <= 0)
            {
                return SurveyResult.Failure("Question payload is invalid.");
            }

            var validation = question.Validate();
            if (!validation.IsValid)
            {
                return SurveyResult.Failure(validation.GetErrorMessage());
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_SurveyQuestion_Update", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SurveyQuestionId", question.SurveyQuestionId);
                    command.Parameters.AddWithValue("@QuestionText", question.QuestionText ?? string.Empty);
                    command.Parameters.AddWithValue("@QuestionType", question.QuestionType ?? SurveyQuestion.QuestionTypeSingleChoice);
                    command.Parameters.AddWithValue("@IsRequired", question.IsRequired);
                    command.Parameters.AddWithValue("@SortOrder", question.SortOrder);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255) { Direction = ParameterDirection.Output };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = ToInt(resultCodeParam.Value);
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;

                    if (resultCode == 1)
                    {
                        return SurveyResult.Success(new Survey { SurveyId = question.SurveyId, Questions = new List<SurveyQuestion> { question } }, string.IsNullOrWhiteSpace(resultMessage) ? "Question updated successfully." : resultMessage);
                    }

                    return SurveyResult.Failure(string.IsNullOrWhiteSpace(resultMessage) ? "Unable to update question." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return SurveyResult.Failure(string.Format("Database error updating survey question: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return SurveyResult.Failure(string.Format("Unexpected error updating survey question: {0}", ex.Message), ex);
            }
        }

        public DatabaseResult DeleteQuestion(int surveyQuestionId)
        {
            if (surveyQuestionId <= 0)
            {
                return DatabaseResult.Failure(-1, "SurveyQuestionId must be positive.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_SurveyQuestion_Delete", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SurveyQuestionId", surveyQuestionId);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255) { Direction = ParameterDirection.Output };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = ToInt(resultCodeParam.Value);
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;

                    if (resultCode == 1)
                    {
                        return DatabaseResult.Success(string.IsNullOrWhiteSpace(resultMessage) ? "Question deleted successfully." : resultMessage);
                    }

                    return DatabaseResult.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Unable to delete question." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure(string.Format("Database error deleting survey question: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure(string.Format("Unexpected error deleting survey question: {0}", ex.Message), ex);
            }
        }

        public SurveyResult CreateOption(SurveyOption option)
        {
            if (option == null)
            {
                return SurveyResult.Failure("Option payload cannot be null.");
            }

            var validation = option.Validate();
            if (!validation.IsValid)
            {
                return SurveyResult.Failure(validation.GetErrorMessage());
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_SurveyOption_Create", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SurveyQuestionId", option.SurveyQuestionId);
                    command.Parameters.AddWithValue("@OptionText", option.OptionText ?? string.Empty);
                    command.Parameters.AddWithValue("@OptionValue", ToDbValue(option.OptionValue));
                    command.Parameters.AddWithValue("@SortOrder", option.SortOrder);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255) { Direction = ParameterDirection.Output };
                    var newIdParam = new SqlParameter("@NewSurveyOptionId", SqlDbType.Int) { Direction = ParameterDirection.Output };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);
                    command.Parameters.Add(newIdParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = ToInt(resultCodeParam.Value);
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;
                    int newId = ToInt(newIdParam.Value);

                    if (resultCode == 1 && newId > 0)
                    {
                        option.SurveyOptionId = newId;
                        return SurveyResult.Success(new Survey
                        {
                            Questions = new List<SurveyQuestion>
                            {
                                new SurveyQuestion
                                {
                                    SurveyQuestionId = option.SurveyQuestionId,
                                    Options = new List<SurveyOption> { option }
                                }
                            }
                        }, string.IsNullOrWhiteSpace(resultMessage) ? "Option created successfully." : resultMessage);
                    }

                    return SurveyResult.Failure(string.IsNullOrWhiteSpace(resultMessage) ? "Unable to create option." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return SurveyResult.Failure(string.Format("Database error creating survey option: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return SurveyResult.Failure(string.Format("Unexpected error creating survey option: {0}", ex.Message), ex);
            }
        }

        public SurveyResult UpdateOption(SurveyOption option)
        {
            if (option == null || option.SurveyOptionId <= 0)
            {
                return SurveyResult.Failure("Option payload is invalid.");
            }

            var validation = option.Validate();
            if (!validation.IsValid)
            {
                return SurveyResult.Failure(validation.GetErrorMessage());
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_SurveyOption_Update", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SurveyOptionId", option.SurveyOptionId);
                    command.Parameters.AddWithValue("@OptionText", option.OptionText ?? string.Empty);
                    command.Parameters.AddWithValue("@OptionValue", ToDbValue(option.OptionValue));
                    command.Parameters.AddWithValue("@SortOrder", option.SortOrder);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255) { Direction = ParameterDirection.Output };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = ToInt(resultCodeParam.Value);
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;

                    if (resultCode == 1)
                    {
                        return SurveyResult.Success(new Survey
                        {
                            Questions = new List<SurveyQuestion>
                            {
                                new SurveyQuestion
                                {
                                    SurveyQuestionId = option.SurveyQuestionId,
                                    Options = new List<SurveyOption> { option }
                                }
                            }
                        }, string.IsNullOrWhiteSpace(resultMessage) ? "Option updated successfully." : resultMessage);
                    }

                    return SurveyResult.Failure(string.IsNullOrWhiteSpace(resultMessage) ? "Unable to update option." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return SurveyResult.Failure(string.Format("Database error updating survey option: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return SurveyResult.Failure(string.Format("Unexpected error updating survey option: {0}", ex.Message), ex);
            }
        }

        public DatabaseResult DeleteOption(int surveyOptionId)
        {
            if (surveyOptionId <= 0)
            {
                return DatabaseResult.Failure(-1, "SurveyOptionId must be positive.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_SurveyOption_Delete", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SurveyOptionId", surveyOptionId);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255) { Direction = ParameterDirection.Output };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = ToInt(resultCodeParam.Value);
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;

                    if (resultCode == 1)
                    {
                        return DatabaseResult.Success(string.IsNullOrWhiteSpace(resultMessage) ? "Option deleted successfully." : resultMessage);
                    }

                    return DatabaseResult.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Unable to delete option." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure(string.Format("Database error deleting survey option: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure(string.Format("Unexpected error deleting survey option: {0}", ex.Message), ex);
            }
        }

        public SurveyResponseResult SaveSurveyResponse(int surveyId, int userId, bool allowMultipleResponses, IEnumerable<SurveyAnswer> answers)
        {
            if (surveyId <= 0)
            {
                return SurveyResponseResult.Failure("SurveyId must be positive.");
            }

            if (userId <= 0)
            {
                return SurveyResponseResult.Failure("UserId must be positive.");
            }

            if (answers == null)
            {
                return SurveyResponseResult.Failure("Answers collection cannot be null.");
            }

            DataTable answersTable = BuildAnswersTable(answers);

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Survey_SaveResponse", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SurveyId", surveyId);
                    command.Parameters.AddWithValue("@UserId", userId);

                    var answersParam = new SqlParameter("@Answers", SqlDbType.Structured)
                    {
                        TypeName = "dbo.SurveyAnswerTableType",
                        Value = answersTable
                    };
                    command.Parameters.Add(answersParam);

                    command.Parameters.AddWithValue("@AllowMultipleResponses", allowMultipleResponses);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255) { Direction = ParameterDirection.Output };
                    var newIdParam = new SqlParameter("@NewSurveyResponseId", SqlDbType.Int) { Direction = ParameterDirection.Output };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);
                    command.Parameters.Add(newIdParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = ToInt(resultCodeParam.Value);
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;
                    int newResponseId = ToInt(newIdParam.Value);

                    if (resultCode == 1 && newResponseId > 0)
                    {
                        var response = new SurveyResponse
                        {
                            SurveyResponseId = newResponseId,
                            SurveyId = surveyId,
                            UserId = userId,
                            SubmittedDateUtc = DateTime.UtcNow,
                            Answers = answers.ToList()
                        };

                        return SurveyResponseResult.Success(response, string.IsNullOrWhiteSpace(resultMessage) ? "Survey response saved successfully." : resultMessage);
                    }

                    return SurveyResponseResult.Failure(string.IsNullOrWhiteSpace(resultMessage) ? "Unable to save survey response." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return SurveyResponseResult.Failure($"Database error saving survey response: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return SurveyResponseResult.Failure($"Unexpected error saving survey response: {ex.Message}", ex);
            }
        }

        public bool HasUserResponded(int surveyId, int userId)
        {
            if (surveyId <= 0 || userId <= 0)
            {
                return false;
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Survey_HasUserResponded", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SurveyId", surveyId);
                    command.Parameters.AddWithValue("@UserId", userId);

                    connection.Open();
                    var result = command.ExecuteScalar();
                    return result != null && result != DBNull.Value && Convert.ToInt32(result) == 1;
                }
            }
            catch
            {
                return false;
            }
        }

        public bool HasUserInteracted(int surveyId, int userId)
        {
            if (surveyId <= 0 || userId <= 0)
            {
                return false;
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Survey_HasUserInteracted", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SurveyId", surveyId);
                    command.Parameters.AddWithValue("@UserId", userId);

                    connection.Open();
                    var result = command.ExecuteScalar();
                    return result != null && result != DBNull.Value && Convert.ToInt32(result) == 1;
                }
            }
            catch
            {
                return false;
            }
        }

        public DatabaseResult RecordSurveyOmission(int surveyId, int userId)
        {
            if (surveyId <= 0)
            {
                return DatabaseResult.Failure(-1, "SurveyId must be positive.");
            }

            if (userId <= 0)
            {
                return DatabaseResult.Failure(-1, "UserId must be positive.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Survey_RecordOmission", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SurveyId", surveyId);
                    command.Parameters.AddWithValue("@UserId", userId);

                    var resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                    var resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255) { Direction = ParameterDirection.Output };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = ToInt(resultCodeParam.Value);
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;

                    if (resultCode == 1)
                    {
                        return DatabaseResult.Success(string.IsNullOrWhiteSpace(resultMessage) ? "Survey omission recorded successfully." : resultMessage);
                    }

                    return DatabaseResult.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Unable to record survey omission." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure(string.Format("Database error recording survey omission: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure(string.Format("Unexpected error recording survey omission: {0}", ex.Message), ex);
            }
        }

        public DatabaseResult<SurveyStatisticsResponse> GetSurveyStatistics()
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Survey_GetStatistics", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        var response = new SurveyStatisticsResponse();

                        if (reader.Read())
                        {
                            response.Summary.TotalSurveys = GetInt32(reader, "TotalSurveys");
                            response.Summary.ActiveSurveys = GetInt32(reader, "ActiveSurveys");
                            response.Summary.ScheduledSurveys = GetInt32(reader, "ScheduledSurveys");
                            response.Summary.ExpiredSurveys = GetInt32(reader, "ExpiredSurveys");
                            response.Summary.TotalResponses = GetInt32(reader, "TotalResponses");
                            response.Summary.ResponsesLast30Days = GetInt32(reader, "ResponsesLast30Days");
                            response.Summary.AverageResponsesPerSurvey = GetDecimal(reader, "AverageResponsesPerSurvey");
                            response.Summary.LastResponseDateUtc = GetNullableDate(reader, "LastResponseDateUtc");
                        }

                        if (reader.NextResult())
                        {
                            while (reader.Read())
                            {
                                response.Surveys.Add(new SurveyStatisticsDetail
                                {
                                    SurveyId = GetInt32(reader, "SurveyId"),
                                    Title = GetString(reader, "Title"),
                                    IsActive = GetBoolean(reader, "IsActive"),
                                    StartDateUtc = GetNullableDate(reader, "StartDateUtc"),
                                    EndDateUtc = GetNullableDate(reader, "EndDateUtc"),
                                    QuestionCount = GetInt32(reader, "QuestionCount"),
                                    TotalResponses = GetInt32(reader, "TotalResponses"),
                                    ResponsesLast30Days = GetInt32(reader, "ResponsesLast30Days"),
                                    LastResponseDateUtc = GetNullableDate(reader, "LastResponseDateUtc"),
                                    IsCurrentlyOpen = GetBoolean(reader, "IsCurrentlyOpen")
                                });
                            }
                        }

                        return SurveyStatisticsResult.Success(response, "Survey statistics retrieved successfully.");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return SurveyStatisticsResult.Failure(string.Format("Database error retrieving survey statistics: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return SurveyStatisticsResult.Failure(string.Format("Unexpected error retrieving survey statistics: {0}", ex.Message), ex);
            }
        }

        public SurveyResultDataResult GetSurveyResultsForDisplay(int surveyId)
        {
            if (surveyId <= 0)
            {
                return SurveyResultDataResult.Failure("SurveyId must be positive.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_Survey_GetResultsForDisplay", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SurveyId", surveyId);

                    connection.Open();
                    System.Diagnostics.Debug.WriteLine(string.Format("=== DAL: Executing sp_Survey_GetResultsForDisplay for SurveyId={0} ===", surveyId));
                    
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        var resultData = new SurveyResultData();

                        // First result set: Survey info
                        System.Diagnostics.Debug.WriteLine("Result Set 1: Survey Info");
                        if (reader.Read())
                        {
                            resultData.SurveyId = GetInt32(reader, "SurveyId");
                            resultData.SurveyTitle = GetString(reader, "Title");
                            System.Diagnostics.Debug.WriteLine(string.Format("  Survey: ID={0}, Title={1}", resultData.SurveyId, resultData.SurveyTitle));
                        }
                        else
                        {
                            System.Diagnostics.Debug.WriteLine("  ERROR: No survey data returned");
                        }

                        if (resultData.SurveyId == 0)
                        {
                            return SurveyResultDataResult.Failure("Survey not found.");
                        }

                        // Second result set: Questions with vote counts
                        System.Diagnostics.Debug.WriteLine("Result Set 2: Questions");
                        if (reader.NextResult())
                        {
                            int qCount = 0;
                            while (reader.Read())
                            {
                                var q = new SurveyQuestionResult
                                {
                                    SurveyQuestionId = GetInt32(reader, "SurveyQuestionId"),
                                    QuestionText = GetString(reader, "QuestionText"),
                                    QuestionType = GetString(reader, "QuestionType"),
                                    TotalVotes = GetInt32(reader, "TotalVotes")
                                };
                                resultData.Questions.Add(q);
                                qCount++;
                                System.Diagnostics.Debug.WriteLine(string.Format("  Q{0}: ID={1}, Type={2}, Votes={3}", qCount, q.SurveyQuestionId, q.QuestionType, q.TotalVotes));
                            }
                            System.Diagnostics.Debug.WriteLine(string.Format("  Total questions: {0}", qCount));
                        }
                        else
                        {
                            System.Diagnostics.Debug.WriteLine("  ERROR: No questions result set");
                        }

                        // Third result set: Options with vote counts and percentages
                        System.Diagnostics.Debug.WriteLine("Result Set 3: Options");
                        if (reader.NextResult())
                        {
                            var questionLookup = resultData.Questions.ToDictionary(q => q.SurveyQuestionId, q => q);
                            System.Diagnostics.Debug.WriteLine(string.Format("  Question lookup: {0} questions", questionLookup.Count));
                            
                            int optCount = 0;
                            while (reader.Read())
                            {
                                int questionId = GetInt32(reader, "SurveyQuestionId");
                                int optionId = GetInt32(reader, "SurveyOptionId");
                                string optionText = GetString(reader, "OptionText");
                                int voteCount = GetInt32(reader, "VoteCount");
                                decimal votePct = GetDecimal(reader, "VotePercentage");
                                
                                optCount++;
                                System.Diagnostics.Debug.WriteLine(string.Format("  Opt{0}: QID={1}, OptID={2}, Text={3}, Votes={4}", optCount, questionId, optionId, optionText, voteCount));
                                
                                if (questionLookup.TryGetValue(questionId, out var question))
                                {
                                    question.Options.Add(new SurveyOptionResult
                                    {
                                        SurveyOptionId = optionId,
                                        OptionText = optionText,
                                        VoteCount = voteCount,
                                        VotePercentage = votePct
                                    });
                                    System.Diagnostics.Debug.WriteLine(string.Format("    -> Added to Q{0} (now has {1} options)", questionId, question.Options.Count));
                                }
                                else
                                {
                                    System.Diagnostics.Debug.WriteLine(string.Format("    -> ERROR: Question {0} not in lookup!", questionId));
                                }
                            }
                            System.Diagnostics.Debug.WriteLine(string.Format("  Total options: {0}", optCount));
                        }
                        else
                        {
                            System.Diagnostics.Debug.WriteLine("  ERROR: No options result set");
                        }

                        // Fourth result set: Text answers for unique answer questions
                        if (reader.NextResult())
                        {
                            var questionLookup = resultData.Questions.ToDictionary(q => q.SurveyQuestionId, q => q);
                            while (reader.Read())
                            {
                                int questionId = GetInt32(reader, "SurveyQuestionId");
                                if (questionLookup.TryGetValue(questionId, out var question))
                                {
                                    question.TextAnswers.Add(new SurveyTextAnswer
                                    {
                                        SurveyAnswerId = GetInt32(reader, "SurveyAnswerId"),
                                        AnswerText = GetString(reader, "AnswerText"),
                                        SubmittedDateUtc = reader.GetDateTime(reader.GetOrdinal("SubmittedDateUtc"))
                                    });
                                }
                            }
                        }

                        return SurveyResultDataResult.Success(resultData, "Survey results retrieved successfully.");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return SurveyResultDataResult.Failure(string.Format("Database error retrieving survey results: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return SurveyResultDataResult.Failure(string.Format("Unexpected error retrieving survey results: {0}", ex.Message), ex);
            }
        }

        private static DataTable BuildAnswersTable(IEnumerable<SurveyAnswer> answers)
        {
            var table = new DataTable();
            table.Columns.Add("SurveyQuestionId", typeof(int));
            table.Columns.Add("SurveyOptionId", typeof(int));
            table.Columns.Add("AnswerText", typeof(string));

            foreach (var answer in answers)
            {
                var row = table.NewRow();
                row["SurveyQuestionId"] = answer.SurveyQuestionId;
                row["SurveyOptionId"] = (object)answer.SurveyOptionId ?? DBNull.Value;
                row["AnswerText"] = (object)answer.AnswerText ?? DBNull.Value;
                table.Rows.Add(row);
            }

            return table;
        }

        private static Survey MapSurvey(SqlDataReader reader)
        {
            return new Survey
            {
                SurveyId = reader.GetInt32(reader.GetOrdinal("SurveyId")),
                Title = reader["Title"] as string,
                Description = reader["Description"] as string,
                LanguageCode = reader["LanguageCode"] as string,
                StartDateUtc = reader["StartDateUtc"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["StartDateUtc"]),
                EndDateUtc = reader["EndDateUtc"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["EndDateUtc"]),
                IsActive = reader["IsActive"] != DBNull.Value && Convert.ToBoolean(reader["IsActive"]),
                AllowMultipleResponses = reader["AllowMultipleResponses"] != DBNull.Value && Convert.ToBoolean(reader["AllowMultipleResponses"]),
                CreatedBy = reader["CreatedBy"] != DBNull.Value ? Convert.ToInt32(reader["CreatedBy"]) : 0,
                CreatedDateUtc = reader["CreatedDateUtc"] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(reader["CreatedDateUtc"]),
                LastModifiedBy = reader["LastModifiedBy"] == DBNull.Value ? (int?)null : Convert.ToInt32(reader["LastModifiedBy"]),
                LastModifiedDateUtc = reader["LastModifiedDateUtc"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["LastModifiedDateUtc"]),
                Questions = new List<SurveyQuestion>()
            };
        }

        private static SurveyQuestion MapQuestion(SqlDataReader reader)
        {
            return new SurveyQuestion
            {
                SurveyQuestionId = reader.GetInt32(reader.GetOrdinal("SurveyQuestionId")),
                SurveyId = reader.GetInt32(reader.GetOrdinal("SurveyId")),
                QuestionText = reader["QuestionText"] as string,
                QuestionType = reader["QuestionType"] as string,
                IsRequired = reader["IsRequired"] != DBNull.Value && Convert.ToBoolean(reader["IsRequired"]),
                SortOrder = reader["SortOrder"] != DBNull.Value ? Convert.ToInt32(reader["SortOrder"]) : 0,
                Options = new List<SurveyOption>()
            };
        }

        private static SurveyOption MapOption(SqlDataReader reader)
        {
            return new SurveyOption
            {
                SurveyOptionId = reader.GetInt32(reader.GetOrdinal("SurveyOptionId")),
                SurveyQuestionId = reader.GetInt32(reader.GetOrdinal("SurveyQuestionId")),
                OptionText = reader["OptionText"] as string,
                OptionValue = reader["OptionValue"] as string,
                SortOrder = reader["SortOrder"] != DBNull.Value ? Convert.ToInt32(reader["SortOrder"]) : 0
            };
        }

        private static object ToDbValue(object value)
        {
            return value ?? DBNull.Value;
        }

        private static int ToInt(object value)
        {
            return value == null || value == DBNull.Value ? 0 : Convert.ToInt32(value);
        }

        private static int GetInt32(SqlDataReader reader, string columnName)
        {
            object value = reader[columnName];
            return value == DBNull.Value ? 0 : Convert.ToInt32(value);
        }

        private static decimal GetDecimal(SqlDataReader reader, string columnName)
        {
            object value = reader[columnName];
            return value == DBNull.Value ? 0m : Convert.ToDecimal(value);
        }

        private static string GetString(SqlDataReader reader, string columnName)
        {
            object value = reader[columnName];
            return value == DBNull.Value ? string.Empty : Convert.ToString(value);
        }

        private static bool GetBoolean(SqlDataReader reader, string columnName)
        {
            object value = reader[columnName];
            if (value == DBNull.Value)
            {
                return false;
            }

            if (value is bool boolValue)
            {
                return boolValue;
            }

            return Convert.ToInt32(value) == 1;
        }

        private static DateTime? GetNullableDate(SqlDataReader reader, string columnName)
        {
            object value = reader[columnName];
            return value == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(value);
        }
    }
}
