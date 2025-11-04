<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SurveyDisplay.ascx.cs" Inherits="Hirebot_TFI.Controls.SurveyDisplay" %>

<asp:Panel ID="pnlSurveyContainer" runat="server" CssClass="card border-0 shadow-sm survey-widget">
    <div class="card-header bg-light d-flex align-items-center justify-content-between flex-wrap gap-2">
        <div class="d-flex align-items-center gap-2">
            <i class="bi bi-clipboard-check text-primary"></i>
            <strong><asp:Literal ID="litSurveyTitle" runat="server" /></strong>
        </div>
    </div>
    <asp:Panel ID="pnlSurveyContent" runat="server" CssClass="card-body">
        <asp:Repeater ID="rptQuestions" runat="server" OnItemDataBound="rptQuestions_ItemDataBound">
            <ItemTemplate>
                <asp:HiddenField ID="hfQuestionId" runat="server" Value='<%# Eval("SurveyQuestionId") %>' />
                <asp:HiddenField ID="hfQuestionType" runat="server" Value='<%# Eval("QuestionType") %>' />
                <asp:HiddenField ID="hfQuestionRequired" runat="server" Value='<%# Eval("IsRequired") %>' />
                <div class="survey-question mb-4">
                    <div class="d-flex align-items-start gap-2">
                        <span class="badge bg-primary-subtle text-primary">Q</span>
                        <div>
                            <h5 class="mb-1"><%# Eval("QuestionText") %></h5>
                            <small class="text-muted"><%# Container.DataItem is ABSTRACTIONS.SurveyQuestion question && question.IsRequired ? "(Requerido)" : string.Empty %></small>
                        </div>
                    </div>
                    <div class="mt-3">
                        <asp:PlaceHolder ID="phQuestionInput" runat="server" />
                        <asp:Label ID="lblValidation" runat="server" CssClass="text-danger small d-block mt-1" Visible="false"></asp:Label>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
        <div class="d-flex gap-2">
            <asp:Button ID="btnSubmitSurvey" runat="server" CssClass="btn btn-primary" Text="Enviar" OnClick="btnSubmitSurvey_Click" />
            <asp:Button ID="btnSkipSurvey" runat="server" CssClass="btn btn-outline-secondary" Text="Omitir" OnClick="btnSkipSurvey_Click" CausesValidation="false" />
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlSurveyMessage" runat="server" CssClass="card-body" Visible="false">
        <div class="alert" runat="server" id="alertSurveyMessage">
            <asp:Label ID="lblSurveyMessage" runat="server" />
        </div>
    </asp:Panel>
</asp:Panel>
