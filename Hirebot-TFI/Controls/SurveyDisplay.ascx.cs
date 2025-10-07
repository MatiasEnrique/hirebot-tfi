using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ABSTRACTIONS;
using SECURITY;

namespace Hirebot_TFI.Controls
{
    public partial class SurveyDisplay : UserControl
    {
        private readonly SurveySecurity _surveySecurity = new SurveySecurity();

        private int? ActiveSurveyId
        {
            get => ViewState["ActiveSurveyId"] != null ? (int?)ViewState["ActiveSurveyId"] : null;
            set => ViewState["ActiveSurveyId"] = value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadActiveSurvey();
            }
            else
            {
                RebindActiveSurvey();
            }
        }

        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            if (e.Item.DataItem is SurveyQuestion question)
            {
                var placeholder = (PlaceHolder)e.Item.FindControl("phQuestionInput");
                placeholder?.Controls.Clear();

                Control inputControl = null;
                switch (question.QuestionType)
                {
                    case SurveyQuestion.QuestionTypeSingleChoice:
                        var rbl = new RadioButtonList
                        {
                            ID = "rblOptions",
                            CssClass = "form-check",
                            RepeatDirection = RepeatDirection.Vertical
                        };
                        foreach (var option in question.Options ?? new List<SurveyOption>())
                        {
                            rbl.Items.Add(new ListItem(option.OptionText, option.SurveyOptionId.ToString(CultureInfo.InvariantCulture)));
                        }
                        inputControl = rbl;
                        break;

                    case SurveyQuestion.QuestionTypeMultipleChoice:
                        var cbl = new CheckBoxList
                        {
                            ID = "cblOptions",
                            CssClass = "form-check"
                        };
                        foreach (var option in question.Options ?? new List<SurveyOption>())
                        {
                            cbl.Items.Add(new ListItem(option.OptionText, option.SurveyOptionId.ToString(CultureInfo.InvariantCulture)));
                        }
                        inputControl = cbl;
                        break;

                    default:
                        var txt = new TextBox
                        {
                            ID = "txtAnswer",
                            CssClass = "form-control",
                            TextMode = TextBoxMode.MultiLine,
                            Rows = 3,
                            MaxLength = 1000
                        };
                        inputControl = txt;
                        break;
                }

                if (inputControl != null)
                {
                    placeholder?.Controls.Add(inputControl);
                }
            }
        }

        protected void btnSubmitSurvey_Click(object sender, EventArgs e)
        {
            if (!ActiveSurveyId.HasValue)
            {
                ShowMessage(GetLocalizedString("SurveyUnavailable"), true);
                return;
            }

            var surveyResult = _surveySecurity.GetActiveSurveyForCurrentUser();
            if (!surveyResult.IsSuccessful || surveyResult.Data == null)
            {
                ShowMessage(surveyResult.ErrorMessage ?? GetLocalizedString("SurveyUnavailable"), true);
                pnlSurveyContent.Visible = false;
                return;
            }

            var survey = surveyResult.Data;
            var answers = new List<SurveyAnswer>();
            var validationFailed = false;

            foreach (RepeaterItem item in rptQuestions.Items)
            {
                var hfQuestionId = item.FindControl("hfQuestionId") as HiddenField;
                var hfQuestionType = item.FindControl("hfQuestionType") as HiddenField;
                var hfRequired = item.FindControl("hfQuestionRequired") as HiddenField;
                var lblValidation = item.FindControl("lblValidation") as Label;
                lblValidation.Visible = false;

                if (hfQuestionId == null || hfQuestionType == null)
                {
                    continue;
                }

                if (!int.TryParse(hfQuestionId.Value, out var questionId))
                {
                    continue;
                }

                var question = survey.Questions?.FirstOrDefault(q => q.SurveyQuestionId == questionId);
                if (question == null)
                {
                    continue;
                }

                var isRequired = string.Equals(hfRequired?.Value, bool.TrueString, StringComparison.OrdinalIgnoreCase);
                var questionType = hfQuestionType.Value;

                switch (questionType)
                {
                    case SurveyQuestion.QuestionTypeSingleChoice:
                        var rbl = item.FindControl("rblOptions") as RadioButtonList;
                        var selectedValue = rbl?.SelectedValue;
                        if (string.IsNullOrEmpty(selectedValue))
                        {
                            if (isRequired)
                            {
                                validationFailed = true;
                                ShowAnswerValidation(lblValidation, GetLocalizedString("SurveyQuestionRequiredMessage"));
                            }
                        }
                        else if (int.TryParse(selectedValue, out var optionId))
                        {
                            answers.Add(new SurveyAnswer
                            {
                                SurveyQuestionId = questionId,
                                SurveyOptionId = optionId
                            });
                        }
                        break;

                    case SurveyQuestion.QuestionTypeMultipleChoice:
                        var cbl = item.FindControl("cblOptions") as CheckBoxList;
                        var selectedOptions = cbl?.Items.Cast<ListItem>().Where(li => li.Selected).Select(li => li.Value).ToList() ?? new List<string>();
                        if (!selectedOptions.Any())
                        {
                            if (isRequired)
                            {
                                validationFailed = true;
                                ShowAnswerValidation(lblValidation, GetLocalizedString("SurveyQuestionRequiredMessage"));
                            }
                        }
                        else
                        {
                            foreach (var value in selectedOptions)
                            {
                                if (int.TryParse(value, out var optionId))
                                {
                                    answers.Add(new SurveyAnswer
                                    {
                                        SurveyQuestionId = questionId,
                                        SurveyOptionId = optionId
                                    });
                                }
                            }
                        }
                        break;

                    default:
                        var txt = item.FindControl("txtAnswer") as TextBox;
                        var text = txt?.Text.Trim();
                        if (string.IsNullOrWhiteSpace(text))
                        {
                            if (isRequired)
                            {
                                validationFailed = true;
                                ShowAnswerValidation(lblValidation, GetLocalizedString("SurveyQuestionRequiredMessage"));
                            }
                        }
                        else
                        {
                            answers.Add(new SurveyAnswer
                            {
                                SurveyQuestionId = questionId,
                                SurveyOptionId = null,
                                AnswerText = text
                            });
                        }
                        break;
                }
            }

            if (validationFailed)
            {
                ShowMessage(GetLocalizedString("SurveyValidationError"), true);
                return;
            }

            var submitResult = _surveySecurity.SubmitSurveyResponse(survey.SurveyId, answers);
            if (submitResult.IsSuccessful)
            {
                ShowMessage(submitResult.ErrorMessage ?? GetLocalizedString("SurveySubmitted"), false);
                pnlSurveyContent.Visible = false;
                ActiveSurveyId = null;
            }
            else
            {
                ShowMessage(submitResult.ErrorMessage ?? GetLocalizedString("SurveySubmitFailed"), true);
            }
        }

        protected void btnSkipSurvey_Click(object sender, EventArgs e)
        {
            if (!ActiveSurveyId.HasValue)
            {
                ShowMessage(GetLocalizedString("SurveyUnavailable"), true);
                return;
            }

            var result = _surveySecurity.OmitSurvey(ActiveSurveyId.Value);

            if (result.IsSuccessful)
            {
                pnlSurveyContent.Visible = false;
                ShowMessage(result.ErrorMessage ?? GetLocalizedString("SurveySkipped"), false);
                ActiveSurveyId = null;
            }
            else
            {
                ShowMessage(result.ErrorMessage ?? GetLocalizedString("SurveyUnavailable"), true);
            }
        }

        private void LoadActiveSurvey()
        {
            string languageCode = GetCurrentLanguageCode();
            var result = _surveySecurity.GetActiveSurveyForCurrentUser(languageCode);
            if (!result.IsSuccessful)
            {
                // Don't show error message, just hide the survey
                pnlSurveyContent.Visible = false;
                pnlSurveyMessage.Visible = false;
                return;
            }

            if (result.Data == null)
            {
                // No survey available - hide without showing message
                pnlSurveyContent.Visible = false;
                pnlSurveyMessage.Visible = false;
                return;
            }

            ActiveSurveyId = result.Data.SurveyId;
            BindSurvey(result.Data);
        }

        private void RebindActiveSurvey()
        {
            if (!ActiveSurveyId.HasValue)
            {
                return;
            }

            string languageCode = GetCurrentLanguageCode();
            var result = _surveySecurity.GetActiveSurveyForCurrentUser(languageCode);
            if (result.IsSuccessful && result.Data != null && result.Data.SurveyId == ActiveSurveyId.Value)
            {
                BindSurvey(result.Data);
            }
        }

        private string GetCurrentLanguageCode()
        {
            string language = Session["Language"] as string ?? "es";
            return language;
        }

        private void BindSurvey(Survey survey)
        {
            pnlSurveyContent.Visible = true;
            pnlSurveyMessage.Visible = false;
            litSurveyTitle.Text = survey.Title;
            rptQuestions.DataSource = survey.Questions?.OrderBy(q => q.SortOrder).ThenBy(q => q.SurveyQuestionId).ToList();
            rptQuestions.DataBind();
        }

        private void ShowMessage(string message, bool isError)
        {
            pnlSurveyMessage.Visible = true;
            pnlSurveyContent.Visible = !isError;
            lblSurveyMessage.Text = message;
            alertSurveyMessage.Attributes["class"] = isError ? "alert alert-warning" : "alert alert-success";
        }

        private void ShowAnswerValidation(Label label, string message)
        {
            if (label == null)
            {
                return;
            }

            label.Text = message;
            label.Visible = true;
        }

        protected string GetLocalizedString(string key)
        {
            var value = (string)System.Web.HttpContext.GetGlobalResourceObject("GlobalResources", key);
            return string.IsNullOrWhiteSpace(value) ? key : value;
        }
    }
}
