using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ABSTRACTIONS;
using Newtonsoft.Json;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class Dashboard : BasePage
    {
        private UserSecurity userSecurity;
        private SurveySecurity surveySecurity;

        protected void Page_Load(object sender, EventArgs e)
        {
            userSecurity = new UserSecurity();
            surveySecurity = new SurveySecurity();

            userSecurity.RequireAuthentication();

            if (!IsPostBack)
            {
                LoadUserData();
                LoadSurveyResults();
            }
        }

        private void LoadUserData()
        {
            try
            {
                var currentUser = userSecurity.GetCurrentUser();
                if (currentUser != null)
                {
                    lblUserName.Text = $"{currentUser.FirstName} {currentUser.LastName}";
                    lblUsernameInfo.Text = currentUser.Username;
                    lblEmail.Text = currentUser.Email;
                    lblFirstName.Text = currentUser.FirstName;
                    lblLastName.Text = currentUser.LastName;

                    // Survey control loads automatically through its own Page_Load
                    // The SurveyDisplay user control is already on the page and will:
                    // 1. Call SurveySecurity.GetActiveSurveyForCurrentUser() in its Page_Load
                    // 2. Automatically display the survey if one is available
                    // 3. Hide itself if no survey is available or user already responded
                    // No explicit initialization needed from Dashboard
                }
                else
                {
                    Response.Redirect("~/SignIn.aspx");
                }
            }
            catch (Exception ex)
            {
                Response.Redirect("~/SignIn.aspx");
            }
        }


        protected void btnProfile_Click(object sender, EventArgs e)
        {
            // TODO: Redirect to profile page when implemented
            ShowMessage("ProfileComingSoon");
        }

        protected void btnJobs_Click(object sender, EventArgs e)
        {
            // TODO: Redirect to jobs page when implemented
            ShowMessage("JobsComingSoon");
        }

        protected void btnChat_Click(object sender, EventArgs e)
        {
            ShowMessage("ChatComingSoon");
        }

        private void ShowMessage(string resourceKey)
        {
            var message = resourceKey;
            ClientScript.RegisterStartupScript(this.GetType(), "alert", $"alert('{HttpUtility.JavaScriptStringEncode(message)}');", true);
        }

        private void LoadSurveyResults()
        {
            try
            {
                // Check if there's a survey ID in session (set after user submits a survey)
                if (Session["LastCompletedSurveyId"] != null && int.TryParse(Session["LastCompletedSurveyId"].ToString(), out int surveyId))
                {
                    System.Diagnostics.Debug.WriteLine($"=== LOADING SURVEY RESULTS FOR ID: {surveyId} ===");
                    
                    var result = surveySecurity.GetSurveyResults(surveyId);
                    
                    System.Diagnostics.Debug.WriteLine($"Result IsSuccessful: {result.IsSuccessful}");
                    System.Diagnostics.Debug.WriteLine($"Result Data is null: {result.Data == null}");
                    
                    if (result.IsSuccessful && result.Data != null)
                    {
                        System.Diagnostics.Debug.WriteLine($"Survey Title: {result.Data.SurveyTitle}");
                        System.Diagnostics.Debug.WriteLine($"Question Count: {result.Data.Questions?.Count ?? 0}");
                        
                        pnlSurveyResults.Visible = true;
                        lblSurveyResultsTitle.Text = $"- {result.Data.SurveyTitle}";
                        
                        var questions = result.Data.Questions.OrderBy(q => q.SurveyQuestionId).ToList();
                        System.Diagnostics.Debug.WriteLine($"Binding {questions.Count} questions to repeater");
                        
                        rptSurveyResults.DataSource = questions;
                        rptSurveyResults.DataBind();
                        
                        System.Diagnostics.Debug.WriteLine("Repeater DataBind completed");
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine($"Failed to load results: {result.ErrorMessage}");
                    }

                    // Clear session variable after displaying
                    Session.Remove("LastCompletedSurveyId");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("No LastCompletedSurveyId in session");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ERROR in LoadSurveyResults: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                // Log error but don't show to user - survey results are optional
                pnlSurveyResults.Visible = false;
            }
        }

        protected void rptSurveyResults_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
                return;

            if (e.Item.DataItem is SurveyQuestionResult question)
            {
                System.Diagnostics.Debug.WriteLine($"=== ItemDataBound for Question {question.SurveyQuestionId}: {question.QuestionText} ===");
                
                var hfQuestionId = e.Item.FindControl("hfQuestionId") as HiddenField;
                var hfChartData = e.Item.FindControl("hfChartData") as HiddenField;
                var pnlChart = e.Item.FindControl("pnlChart") as Panel;
                var pnlTextAnswers = e.Item.FindControl("pnlTextAnswers") as Panel;
                var rptTextAnswers = e.Item.FindControl("rptTextAnswers") as Repeater;

                System.Diagnostics.Debug.WriteLine($"Options count: {question.Options?.Count ?? 0}");
                System.Diagnostics.Debug.WriteLine($"TextAnswers count: {question.TextAnswers?.Count ?? 0}");

                // ALWAYS show chart with total votes for the question
                System.Diagnostics.Debug.WriteLine($"Creating chart for question - Total Votes: {question.TotalVotes}");
                
                if (pnlChart != null) pnlChart.Visible = true;
                if (pnlTextAnswers != null) pnlTextAnswers.Visible = false;

                if (hfChartData != null)
                {
                    // Simple chart showing just total votes for this question
                    var chartData = new
                    {
                        labels = new[] { question.QuestionText },
                        datasets = new[]
                        {
                            new
                            {
                                label = "Total Votos",
                                data = new[] { question.TotalVotes },
                                backgroundColor = new[] { "#4b4e6dff" }, // Ultra Violet
                                borderWidth = 1
                            }
                        }
                    };

                    var jsonData = JsonConvert.SerializeObject(chartData);
                    hfChartData.Value = jsonData;
                    
                    System.Diagnostics.Debug.WriteLine($"✅ Chart data created - Total Votes: {question.TotalVotes}");
                    System.Diagnostics.Debug.WriteLine($"JSON: {jsonData}");
                }
            }
        }

        private string GetLocalizedString(string key)
        {
            return key;
        }
    }
}