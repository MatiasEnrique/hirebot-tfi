using System;

using System.Collections.Generic;

using System.Globalization;

using System.Linq;

using System.Web;
using System.Web.Security;

using System.Web.UI.WebControls;

using ABSTRACTIONS;

using SECURITY;



namespace Hirebot_TFI

{

    public partial class AdminSurveys : BasePage

    {

        private static readonly string[] SupportedLanguages = new[] { "es", "en" };

        private readonly SurveySecurity _surveySecurity = new SurveySecurity();

        private const string AlertSessionKey = "AdminSurveys.AlertState";

        private List<SurveyQuestion> TemporaryQuestions

        {
            get => ViewState["TemporaryQuestions"] as List<SurveyQuestion> ?? new List<SurveyQuestion>();

            set => ViewState["TemporaryQuestions"] = value;
        }

        private int? SelectedSurveyId

        {
            get => ViewState["SelectedSurveyId"] != null ? (int?)ViewState["SelectedSurveyId"] : null;

            set => ViewState["SelectedSurveyId"] = value;
        }



        private int? SelectedQuestionId

        {

            get => ViewState["SelectedQuestionId"] != null ? (int?)ViewState["SelectedQuestionId"] : null;

            set => ViewState["SelectedQuestionId"] = value;

        }



        private int? SelectedOptionId

        {

            get => ViewState["SelectedOptionId"] != null ? (int?)ViewState["SelectedOptionId"] : null;

            set => ViewState["SelectedOptionId"] = value;

        }



        protected void Page_Load(object sender, EventArgs e)

        {

            if (!IsPostBack)

            {

                var adminSecurity = new AdminSecurity();

                if (!adminSecurity.IsUserAdmin())

                {

                    Response.Redirect("~/Dashboard.aspx");

                    return;

                }



                PopulateLanguages();

                PopulateQuestionTypes();

                BindSurveys();

                RestoreQueuedAlert();



                if (Request.QueryString["action"] == "new")

                {

                    SelectedSurveyId = null;

                    SelectedQuestionId = null;

                    SelectedOptionId = null;

                    TemporaryQuestions = new List<SurveyQuestion>();

                    hfSelectedSurveyId.Value = string.Empty;

                    ClearSurveyEditor();

                    ShowSurveyEditor(GetLocalizedString("SurveyCreateTitle"));

                    pnlQuestionSection.Visible = true;

                    BindTemporaryQuestions();

                }

                else if (int.TryParse(Request.QueryString["surveyId"], out var surveyId) && surveyId > 0)

                {

                    SelectedSurveyId = surveyId;

                    hfSelectedSurveyId.Value = surveyId.ToString(CultureInfo.InvariantCulture);

                    LoadSurvey(surveyId);

                }

                else

                {

                    HideSurveyEditor();

                }

            }

            else

            {

                if (!SelectedSurveyId.HasValue && int.TryParse(hfSelectedSurveyId.Value, out var restoredSurveyId) && restoredSurveyId > 0)

                {

                    SelectedSurveyId = restoredSurveyId;

                }



                // Handle postback events

                if (Request["__EVENTTARGET"] == "AddQuestion")

                {

                    ShowQuestionEditor();

                }

                else if (Request["__EVENTTARGET"] == "SaveQuestion")

                {

                    SaveTemporaryQuestion();

                }

            }

        }



        protected void btnNewSurvey_Click(object sender, EventArgs e)

        {

            Response.Redirect("~/AdminSurveys.aspx?action=new", false);

            Context.ApplicationInstance.CompleteRequest();

        }



        protected void btnRefreshSurveys_Click(object sender, EventArgs e)

        {

            Response.Redirect("~/AdminSurveys.aspx", false);

            Context.ApplicationInstance.CompleteRequest();

        }



        protected void btnAddQuestion_Click(object sender, EventArgs e)

        {

            SelectedQuestionId = null;

            SelectedOptionId = null;



            ShowQuestionEditor();

            ClearOptionEditor();



            var nextOrder = SelectedSurveyId.HasValue

                ? gvQuestions.Rows.Count + 1

                : TemporaryQuestions.Count + 1;



            txtQuestionOrder.Text = nextOrder.ToString(CultureInfo.InvariantCulture);

            pnlOptionEditor.Visible = false;

            pnlQuestionSection.Visible = true;



            if (!SelectedSurveyId.HasValue)

            {

                BindTemporaryQuestions();

            }

        }



        protected void btnCloseEditor_Click(object sender, EventArgs e)

        {

            Response.Redirect("~/AdminSurveys.aspx", false);

            Context.ApplicationInstance.CompleteRequest();

        }



        protected void btnLogout_Click(object sender, EventArgs e)

        {

            try

            {

                Session.Clear();

                Session.Abandon();

                FormsAuthentication.SignOut();

                Response.Redirect("~/SignIn.aspx", false);

                Context.ApplicationInstance.CompleteRequest();

            }

            catch

            {

                Response.Redirect("~/SignIn.aspx", false);

                Context.ApplicationInstance.CompleteRequest();

            }

        }



        protected void btnSaveSurvey_Click(object sender, EventArgs e)

        {

            if (!SelectedSurveyId.HasValue)

            {

                if (int.TryParse(hfSelectedSurveyId.Value, out var persistedSurveyId) && persistedSurveyId > 0)

                {

                    SelectedSurveyId = persistedSurveyId;

                }

                else if (int.TryParse(Request.QueryString["surveyId"], out var querySurveyId) && querySurveyId > 0)

                {

                    SelectedSurveyId = querySurveyId;

                }

            }



            if (!Page.IsValid)

            {

                return;

            }



            List<SurveyQuestion> questionsForValidation;



            if (SelectedSurveyId.HasValue)

            {

                var currentSurveyResult = _surveySecurity.GetSurveyDetails(SelectedSurveyId.Value);

                if (!currentSurveyResult.IsSuccessful || currentSurveyResult.Data == null)

                {

                    ShowAlertFromResource("SurveyNotFound", true, currentSurveyResult.ErrorMessage);

                    return;

                }



                questionsForValidation = currentSurveyResult.Data.Questions ?? new List<SurveyQuestion>();

            }

            else

            {

                questionsForValidation = TemporaryQuestions ?? new List<SurveyQuestion>();

            }



            var survey = new Survey

            {

                SurveyId = SelectedSurveyId ?? 0,

                Title = txtSurveyTitle.Text.Trim(),

                Description = string.IsNullOrWhiteSpace(txtSurveyDescription.Text) ? null : txtSurveyDescription.Text.Trim(),

                LanguageCode = ddlSurveyLanguage.SelectedValue,

                StartDateUtc = ParseNullableDate(txtSurveyStart.Text),

                EndDateUtc = ParseNullableDate(txtSurveyEnd.Text),

                IsActive = chkSurveyIsActive.Checked,

                AllowMultipleResponses = chkAllowMultipleResponses.Checked,

                Questions = questionsForValidation

            };



            var result = survey.SurveyId > 0

                ? _surveySecurity.UpdateSurvey(survey)

                : _surveySecurity.CreateSurvey(survey);



            if (result.IsSuccessful)

            {

                SelectedSurveyId = result.Data?.SurveyId ?? SelectedSurveyId;



                if (SelectedSurveyId.HasValue && TemporaryQuestions.Count > 0)

                {

                    AddQuestionsToSurvey(SelectedSurveyId.Value, TemporaryQuestions);

                    TemporaryQuestions = new List<SurveyQuestion>(); // Clear temporary questions

                }



                var savedSurveyId = SelectedSurveyId ?? result.Data?.SurveyId ?? survey.SurveyId;

                hfSelectedSurveyId.Value = savedSurveyId > 0

                    ? savedSurveyId.ToString(CultureInfo.InvariantCulture)

                    : string.Empty;



                QueueAlert("SurveySaved", false);



                var redirectUrl = savedSurveyId > 0

                    ? $"~/AdminSurveys.aspx?surveyId={savedSurveyId}"

                    : "~/AdminSurveys.aspx";



                Response.Redirect(redirectUrl, false);

                Context.ApplicationInstance.CompleteRequest();

                return;

            }



            ShowAlertFromResource("SurveySaveFailed", true, result.ErrorMessage);

        }



        protected void gvSurveys_RowCommand(object sender, GridViewCommandEventArgs e)

        {

            if (string.Equals(e.CommandName, "EditSurvey", StringComparison.OrdinalIgnoreCase))

            {

                if (int.TryParse(e.CommandArgument?.ToString(), out var surveyId))

                {

                    Response.Redirect($"~/AdminSurveys.aspx?surveyId={surveyId}", false);

                    Context.ApplicationInstance.CompleteRequest();

                }

            }

            else if (string.Equals(e.CommandName, "DeleteSurvey", StringComparison.OrdinalIgnoreCase))

            {

                if (int.TryParse(e.CommandArgument?.ToString(), out var surveyId))

                {

                    var result = _surveySecurity.DeleteSurvey(surveyId);

                    if (result.IsSuccessful)

                    {

                        QueueAlert("SurveyDeleted", false, result.ErrorMessage);

                        Response.Redirect("~/AdminSurveys.aspx", false);

                        Context.ApplicationInstance.CompleteRequest();

                    }

                    else

                    {

                        ShowAlertFromResource("SurveyDeleteFailed", true, result.ErrorMessage);

                    }

                }

            }

        }



        protected void gvSurveys_RowDataBound(object sender, GridViewRowEventArgs e)

        {

            if (e.Row.RowType == DataControlRowType.DataRow)

            {

                if (e.Row.DataItem is Survey survey)

                {

                    var lblStart = e.Row.FindControl("lblStartDate") as Label;

                    if (lblStart != null)

                    {

                        lblStart.Text = FormatDate(survey.StartDateUtc);

                    }



                    var lblEnd = e.Row.FindControl("lblEndDate") as Label;

                    if (lblEnd != null)

                    {

                        lblEnd.Text = FormatDate(survey.EndDateUtc);

                    }

                }



                var deleteButton = e.Row.FindControl("lnkDeleteSurvey") as LinkButton;

                SetConfirmScript(deleteButton, "ConfirmDeleteSurveyMessage", "Are you sure you want to delete this survey?");

            }

        }



        protected void gvQuestions_RowCommand(object sender, GridViewCommandEventArgs e)

        {

            if (string.Equals(e.CommandName, "EditQuestion", StringComparison.OrdinalIgnoreCase))

            {

                if (int.TryParse(e.CommandArgument?.ToString(), out var questionId))

                {

                    SelectedQuestionId = questionId;

                    SelectedOptionId = null;



                    // Check if this is a temporary question

                    if (questionId < 0)

                    {

                        var tempQuestion = TemporaryQuestions.FirstOrDefault(q => q.SurveyQuestionId == questionId);

                        if (tempQuestion != null)

                        {

                            txtQuestionText.Text = tempQuestion.QuestionText;

                            ddlQuestionType.SelectedValue = tempQuestion.QuestionType;

                            chkQuestionRequired.Checked = tempQuestion.IsRequired;

                            txtQuestionOrder.Text = tempQuestion.SortOrder.ToString(CultureInfo.InvariantCulture);

                            pnlQuestionEditor.Visible = true;

                        }

                    }

                    else if (SelectedSurveyId.HasValue)

                    {

                        BindQuestionEditor(questionId);

                    }

                }

            }

            else if (string.Equals(e.CommandName, "DeleteQuestion", StringComparison.OrdinalIgnoreCase))

            {

                if (int.TryParse(e.CommandArgument?.ToString(), out var questionId))

                {

                    // Check if this is a temporary question

                    if (questionId < 0)

                    {

                        TemporaryQuestions.RemoveAll(q => q.SurveyQuestionId == questionId);

                        ShowAlertFromResource("QuestionDeleted", false);

                        BindTemporaryQuestions();

                    }

                    else if (SelectedSurveyId.HasValue)

                    {

                        var result = _surveySecurity.DeleteQuestion(questionId);

                        if (result.IsSuccessful)

                        {

                            QueueAlert("QuestionDeleted", false, result.ErrorMessage);

                            Response.Redirect($"~/AdminSurveys.aspx?surveyId={SelectedSurveyId.Value}", false);

                            Context.ApplicationInstance.CompleteRequest();

                        }

                        else

                        {

                            ShowAlertFromResource("QuestionDeleteFailed", true, result.ErrorMessage);

                        }

                    }

                }

            }

        }



        protected void gvQuestions_RowDataBound(object sender, GridViewRowEventArgs e)

        {

            if (e.Row.RowType == DataControlRowType.DataRow && e.Row.DataItem is SurveyQuestion question)

            {

                e.Row.Cells[1].Text = GetQuestionTypeDisplay(question.QuestionType);



                var deleteButton = e.Row.FindControl("lnkDeleteQuestion") as LinkButton;

                SetConfirmScript(deleteButton, "ConfirmDeleteQuestionMessage", "Delete this question?");

            }

        }



        protected void btnSaveQuestion_Click(object sender, EventArgs e)

        {

            if (!SelectedSurveyId.HasValue)

            {

                SaveTemporaryQuestion();

                return;

            }



            if (!Page.IsValid)

            {

                return;

            }



            var question = new SurveyQuestion

            {

                SurveyId = SelectedSurveyId.Value,

                SurveyQuestionId = SelectedQuestionId ?? 0,

                QuestionText = txtQuestionText.Text.Trim(),

                QuestionType = ddlQuestionType.SelectedValue,

                IsRequired = chkQuestionRequired.Checked,

                SortOrder = ParseInt(txtQuestionOrder.Text, 1)

            };



            SurveyResult result;

            if (question.SurveyQuestionId > 0)

            {

                result = _surveySecurity.UpdateQuestion(question);

            }

            else

            {

                result = _surveySecurity.AddQuestion(question);

            }



            if (result.IsSuccessful)

            {

                QueueAlert("QuestionSaved", false, result.ErrorMessage);

                Response.Redirect($"~/AdminSurveys.aspx?surveyId={SelectedSurveyId.Value}", false);

                Context.ApplicationInstance.CompleteRequest();

            }

            else

            {

                ShowAlertFromResource("QuestionSaveFailed", true, result.ErrorMessage);

            }

        }



        protected void btnCancelQuestion_Click(object sender, EventArgs e)

        {

            ClearQuestionEditor();

            pnlQuestionEditor.Visible = false;

            pnlOptionEditor.Visible = false;

            SelectedQuestionId = null;

            SelectedOptionId = null;

        }



        protected void gvOptions_RowCommand(object sender, GridViewCommandEventArgs e)

        {

            if (!SelectedQuestionId.HasValue)

            {

                ShowAlertFromResource("QuestionNotSelected", true);

                return;

            }



            if (string.Equals(e.CommandName, "EditOption", StringComparison.OrdinalIgnoreCase))

            {

                if (int.TryParse(e.CommandArgument?.ToString(), out var optionId))

                {

                    SelectedOptionId = optionId;

                    BindOptionEditor(optionId);

                }

            }

            else if (string.Equals(e.CommandName, "DeleteOption", StringComparison.OrdinalIgnoreCase))

            {

                if (int.TryParse(e.CommandArgument?.ToString(), out var optionId))

                {

                    var result = _surveySecurity.DeleteOption(optionId);

                    if (result.IsSuccessful)

                    {

                        QueueAlert("OptionDeleted", false, result.ErrorMessage);

                        Response.Redirect($"~/AdminSurveys.aspx?surveyId={SelectedSurveyId.Value}", false);

                        Context.ApplicationInstance.CompleteRequest();

                    }

                    else

                    {

                        ShowAlertFromResource("OptionDeleteFailed", true, result.ErrorMessage);

                    }

                }

            }

        }



        protected void btnSaveOption_Click(object sender, EventArgs e)

        {

            if (!SelectedQuestionId.HasValue)

            {

                ShowAlertFromResource("QuestionNotSelected", true);

                return;

            }



            if (!Page.IsValid)

            {

                return;

            }



            var option = new SurveyOption

            {

                SurveyOptionId = SelectedOptionId ?? 0,

                SurveyQuestionId = SelectedQuestionId.Value,

                OptionText = txtOptionText.Text.Trim(),

                OptionValue = string.IsNullOrWhiteSpace(txtOptionValue.Text) ? null : txtOptionValue.Text.Trim(),

                SortOrder = ParseInt(txtOptionOrder.Text, 1)

            };



            SurveyResult result = option.SurveyOptionId > 0

                ? _surveySecurity.UpdateOption(option)

                : _surveySecurity.AddOption(option);



            if (result.IsSuccessful)

            {

                QueueAlert("OptionSaved", false, result.ErrorMessage);

                Response.Redirect($"~/AdminSurveys.aspx?surveyId={SelectedSurveyId.Value}", false);

                Context.ApplicationInstance.CompleteRequest();

            }

            else

            {

                ShowAlertFromResource("OptionSaveFailed", true, result.ErrorMessage);

            }

        }



        protected void btnCancelOption_Click(object sender, EventArgs e)

        {

            SelectedOptionId = null;

            ClearOptionEditor();

            pnlOptionEditor.Visible = SelectedQuestionId.HasValue && !IsTextQuestion(ddlQuestionType.SelectedValue);

        }



        protected void gvOptions_RowDataBound(object sender, GridViewRowEventArgs e)

        {

            if (e.Row.RowType == DataControlRowType.DataRow)

            {

                var deleteButton = e.Row.FindControl("lnkDeleteOption") as LinkButton;

                SetConfirmScript(deleteButton, "ConfirmDeleteOptionMessage", "Delete this option?");

            }

        }



        protected void ddlQuestionType_SelectedIndexChanged(object sender, EventArgs e)

        {

            pnlOptionEditor.Visible = SelectedSurveyId.HasValue && SelectedQuestionId.HasValue && !IsTextQuestion(ddlQuestionType.SelectedValue);

        }



        protected void btnCancelSurvey_Click(object sender, EventArgs e)



        {

            Response.Redirect("~/AdminSurveys.aspx", false);

            Context.ApplicationInstance.CompleteRequest();

        }







        private void BindSurveys()

        {

            var result = _surveySecurity.GetAllSurveysForAdmin();

            if (result.IsSuccessful)

            {

                gvSurveys.DataSource = result.Data ?? new List<Survey>();

                gvSurveys.DataBind();

            }

            else

            {

                gvSurveys.DataSource = null;

                gvSurveys.DataBind();

                ShowAlertFromResource("SurveyRetrieveFailed", true, result.ErrorMessage);

            }

        }



        private void LoadSurvey(int surveyId)

        {

            var result = _surveySecurity.GetSurveyDetails(surveyId);

            if (!result.IsSuccessful || result.Data == null)

            {

                ShowAlertFromResource("SurveyNotFound", true, result.ErrorMessage);

                return;

            }



            SelectedSurveyId = result.Data.SurveyId;

            hfSelectedSurveyId.Value = result.Data.SurveyId.ToString(CultureInfo.InvariantCulture);

            BindSurveyEditor(result.Data);

            pnlSurveyEditor.Visible = true;

            pnlQuestionSection.Visible = true;

        }



        private void BindSurveyEditor(Survey survey)

        {

            litEditorTitle.Text = GetLocalizedString("SurveyEditTitle");

            txtSurveyTitle.Text = survey.Title;

            txtSurveyDescription.Text = survey.Description;

            ddlSurveyLanguage.SelectedValue = SupportedLanguages.Contains(survey.LanguageCode) ? survey.LanguageCode : SupportedLanguages[0];

            txtSurveyStart.Text = survey.StartDateUtc?.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) ?? string.Empty;

            txtSurveyEnd.Text = survey.EndDateUtc?.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) ?? string.Empty;

            chkSurveyIsActive.Checked = survey.IsActive;

            chkAllowMultipleResponses.Checked = survey.AllowMultipleResponses;



            gvQuestions.DataSource = (survey.Questions ?? new List<SurveyQuestion>()).OrderBy(q => q.SortOrder).ThenBy(q => q.SurveyQuestionId).ToList();

            gvQuestions.DataBind();



            pnlQuestionEditor.Visible = false;

            pnlOptionEditor.Visible = false;

        }



        private void BindQuestionEditor(int questionId)

        {

            if (!SelectedSurveyId.HasValue)

            {

                return;

            }



            var surveyResult = _surveySecurity.GetSurveyDetails(SelectedSurveyId.Value);

            if (!surveyResult.IsSuccessful || surveyResult.Data == null)

            {

                ShowAlertFromResource("SurveyNotFound", true, surveyResult.ErrorMessage);

                return;

            }



            var question = surveyResult.Data.Questions?.FirstOrDefault(q => q.SurveyQuestionId == questionId);

            if (question == null)

            {

                ShowAlertFromResource("QuestionNotFound", true);

                return;

            }



            txtQuestionText.Text = question.QuestionText;

            ddlQuestionType.SelectedValue = question.QuestionType;

            chkQuestionRequired.Checked = question.IsRequired;

            txtQuestionOrder.Text = question.SortOrder.ToString(CultureInfo.InvariantCulture);

            pnlQuestionEditor.Visible = true;



            gvQuestions.DataSource = (surveyResult.Data.Questions ?? new List<SurveyQuestion>()).OrderBy(q => q.SortOrder).ThenBy(q => q.SurveyQuestionId).ToList();

            gvQuestions.DataBind();



            BindOptions(question);

        }



        private void BindOptions(SurveyQuestion question)

        {

            var options = question.Options ?? new List<SurveyOption>();

            gvOptions.DataSource = options.OrderBy(o => o.SortOrder).ThenBy(o => o.SurveyOptionId).ToList();

            gvOptions.DataBind();



            pnlOptionEditor.Visible = !IsTextQuestion(question.QuestionType);

            ClearOptionEditor();

        }



        private void BindOptionEditor(int optionId)

        {

            if (!SelectedSurveyId.HasValue)

            {

                return;

            }



            var surveyResult = _surveySecurity.GetSurveyDetails(SelectedSurveyId.Value);

            if (!surveyResult.IsSuccessful || surveyResult.Data == null)

            {

                ShowAlertFromResource("SurveyNotFound", true, surveyResult.ErrorMessage);

                return;

            }



            var question = surveyResult.Data.Questions?.FirstOrDefault(q => q.SurveyQuestionId == SelectedQuestionId);

            if (question == null)

            {

                ShowAlertFromResource("QuestionNotFound", true);

                return;

            }



            var option = question.Options?.FirstOrDefault(o => o.SurveyOptionId == optionId);

            if (option == null)

            {

                ShowAlertFromResource("OptionNotFound", true);

                return;

            }



            txtOptionText.Text = option.OptionText;

            txtOptionValue.Text = option.OptionValue;

            txtOptionOrder.Text = option.SortOrder.ToString(CultureInfo.InvariantCulture);

            pnlOptionEditor.Visible = true;

        }



        private void PopulateLanguages()

        {

            ddlSurveyLanguage.Items.Clear();

            foreach (var code in SupportedLanguages)

            {

                ddlSurveyLanguage.Items.Add(new ListItem(GetLanguageDisplay(code), code));

            }

        }



        private void PopulateQuestionTypes()

        {

            ddlQuestionType.Items.Clear();

            ddlQuestionType.Items.Add(new ListItem(GetLocalizedString("QuestionTypeSingleChoice"), SurveyQuestion.QuestionTypeSingleChoice));

            ddlQuestionType.Items.Add(new ListItem(GetLocalizedString("QuestionTypeMultipleChoice"), SurveyQuestion.QuestionTypeMultipleChoice));

            ddlQuestionType.Items.Add(new ListItem(GetLocalizedString("QuestionTypeText"), SurveyQuestion.QuestionTypeText));

        }



        private void ShowSurveyEditor(string title)

        {

            litEditorTitle.Text = title;

            pnlSurveyEditor.Visible = true;

            // Show question section for both new and existing surveys

            pnlQuestionSection.Visible = true;

        }



        private void HideSurveyEditor()

        {

            pnlSurveyEditor.Visible = false;

            pnlQuestionSection.Visible = false;

            pnlQuestionEditor.Visible = false;

            pnlOptionEditor.Visible = false;

            hfSelectedSurveyId.Value = string.Empty;

        }



        private void ClearSurveyEditor()

        {

            txtSurveyTitle.Text = string.Empty;

            txtSurveyDescription.Text = string.Empty;

            txtSurveyStart.Text = string.Empty;

            txtSurveyEnd.Text = string.Empty;

            chkSurveyIsActive.Checked = false;

            chkAllowMultipleResponses.Checked = false;

            ddlSurveyLanguage.SelectedIndex = 0;

            gvQuestions.DataSource = null;

            gvQuestions.DataBind();

        }



        private void ClearQuestionEditor()

        {

            txtQuestionText.Text = string.Empty;

            ddlQuestionType.SelectedIndex = 0;

            chkQuestionRequired.Checked = false;

            txtQuestionOrder.Text = "1";

        }



        private void ClearOptionEditor()

        {

            txtOptionText.Text = string.Empty;

            txtOptionValue.Text = string.Empty;

            txtOptionOrder.Text = "1";

        }



        private void BindTemporaryQuestions()

        {

            gvQuestions.DataSource = TemporaryQuestions.OrderBy(q => q.SortOrder).ThenBy(q => q.SurveyQuestionId).ToList();

            gvQuestions.DataBind();

        }



        private void ShowQuestionEditor()

        {

            ClearQuestionEditor();

            pnlQuestionEditor.Visible = true;

            SelectedQuestionId = null;

        }



        private void SaveTemporaryQuestion()

        {

            if (!Page.IsValid)

            {

                return;

            }



            var question = new SurveyQuestion

            {

                SurveyQuestionId = -(TemporaryQuestions.Count + 1), // Negative ID for temporary questions

                SurveyId = 0, // Will be set when survey is saved

                QuestionText = txtQuestionText.Text.Trim(),

                QuestionType = ddlQuestionType.SelectedValue,

                IsRequired = chkQuestionRequired.Checked,

                SortOrder = ParseInt(txtQuestionOrder.Text, TemporaryQuestions.Count + 1),

                Options = new List<SurveyOption>()

            };



            // If editing an existing temporary question, replace it

            if (SelectedQuestionId.HasValue && SelectedQuestionId.Value < 0)

            {

                var existingIndex = TemporaryQuestions.FindIndex(q => q.SurveyQuestionId == SelectedQuestionId.Value);

                if (existingIndex >= 0)

                {

                    TemporaryQuestions[existingIndex] = question;

                }

            }

            else

            {

                TemporaryQuestions.Add(question);

            }



            SelectedQuestionId = null;

            ClearQuestionEditor();

            pnlQuestionEditor.Visible = false;

            BindTemporaryQuestions();

        }



        private void AddQuestionsToSurvey(int surveyId, List<SurveyQuestion> questions)

        {

            foreach (var question in questions)

            {

                question.SurveyId = surveyId;

                question.SurveyQuestionId = 0; // Reset ID for database generation

                var result = _surveySecurity.AddQuestion(question);

                if (result.IsSuccessful && result.Data != null)

                {

                    // Add options if any

                    if (question.Options != null && question.Options.Count > 0)

                    {

                        foreach (var option in question.Options)

                        {

                            option.SurveyQuestionId = question.SurveyQuestionId;

                            option.SurveyOptionId = 0; // Reset ID for database generation

                            _surveySecurity.AddOption(option);

                        }

                    }

                }

            }

        }



        private string FormatDate(DateTime? dateUtc)

        {

            return dateUtc.HasValue

                ? dateUtc.Value.ToLocalTime().ToString("yyyy-MM-dd", CultureInfo.InvariantCulture)

                : GetLocalizedString("DateNotSet");

        }



        private int ParseInt(string value, int defaultValue)

        {

            return int.TryParse(value, NumberStyles.Integer, CultureInfo.InvariantCulture, out var number) ? number : defaultValue;

        }



        private DateTime? ParseNullableDate(string value)

        {

            if (string.IsNullOrWhiteSpace(value))

            {

                return null;

            }



            if (DateTime.TryParseExact(value.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.AssumeLocal, out var parsed))

            {

                return DateTime.SpecifyKind(parsed, DateTimeKind.Local).ToUniversalTime();

            }



            return null;

        }



        private string GetLocalizedString(string key)

        {

            var value = (string)HttpContext.GetGlobalResourceObject("GlobalResources", key);

            return string.IsNullOrWhiteSpace(value) ? key : value;

        }



        private void SetConfirmScript(LinkButton button, string globalResourceKey, string fallbackMessage)

        {

            if (button == null)

            {

                return;

            }



            var message = GetLocalizedString(globalResourceKey);

            if (string.IsNullOrWhiteSpace(message))

            {

                message = fallbackMessage;

            }



            button.OnClientClick = $"return confirm('{HttpUtility.JavaScriptStringEncode(message)}');";

        }



        private string GetLanguageDisplay(string languageCode)

        {

            return languageCode?.Equals("en", StringComparison.OrdinalIgnoreCase) == true

                ? GetLocalizedString("LanguageEnglish")

                : GetLocalizedString("LanguageSpanish");

        }



        private string GetQuestionTypeDisplay(string questionType)

        {

            switch (questionType)

            {

                case SurveyQuestion.QuestionTypeMultipleChoice:

                    return GetLocalizedString("QuestionTypeMultipleChoice");

                case SurveyQuestion.QuestionTypeText:

                    return GetLocalizedString("QuestionTypeText");

                default:

                    return GetLocalizedString("QuestionTypeSingleChoice");

            }

        }



        private bool IsTextQuestion(string questionType)

        {

            return string.Equals(questionType, SurveyQuestion.QuestionTypeText, StringComparison.OrdinalIgnoreCase);

        }



        private void RestoreQueuedAlert()

        {

            if (Session[AlertSessionKey] is Tuple<string, string, bool> pendingAlert)

            {

                string message = null;



                if (!string.IsNullOrWhiteSpace(pendingAlert.Item1))

                {

                    var localized = HttpContext.GetGlobalResourceObject("GlobalResources", pendingAlert.Item1) as string;

                    if (!string.IsNullOrWhiteSpace(localized))

                    {

                        message = localized;

                    }

                }



                if (string.IsNullOrWhiteSpace(message) && !string.IsNullOrWhiteSpace(pendingAlert.Item2))

                {

                    message = pendingAlert.Item2;

                }



                if (string.IsNullOrWhiteSpace(message) && !string.IsNullOrWhiteSpace(pendingAlert.Item1))

                {

                    message = pendingAlert.Item1;

                }



                if (!string.IsNullOrWhiteSpace(message))

                {

                    ShowAlert(message, pendingAlert.Item3);

                }



                Session.Remove(AlertSessionKey);

            }

        }



        private void QueueAlert(string resourceKey, bool isError, string fallbackMessage = null)

        {

            Session[AlertSessionKey] = Tuple.Create(resourceKey, fallbackMessage, isError);

        }



        private void ShowAlertFromResource(string resourceKey, bool isError, string fallbackMessage = null)

        {

            var message = !string.IsNullOrWhiteSpace(fallbackMessage)

                ? fallbackMessage

                : GetLocalizedString(resourceKey);



            if (string.IsNullOrWhiteSpace(message))

            {

                message = resourceKey;

            }



            ShowAlert(message, isError);

        }



        private void ShowAlert(string message, bool isError)

        {

            if (string.IsNullOrWhiteSpace(message))

            {

                pnlAlert.Visible = false;

                return;

            }



            pnlAlert.Visible = true;

            lblAlert.Text = message;

            pnlAlert.CssClass = isError ? "alert alert-danger alert-dismissible fade show" : "alert alert-success alert-dismissible fade show";

        }

    }

}

