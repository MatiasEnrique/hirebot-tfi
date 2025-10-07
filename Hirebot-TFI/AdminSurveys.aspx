<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminSurveys.aspx.cs" Inherits="Hirebot_TFI.AdminSurveys" MasterPageFile="~/Protected.master" %>

<asp:Content ID="AdminSurveysHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-section-title {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 1.5rem;
        }

        .admin-section-title .bi-clipboard-check {
            font-size: 1.75rem;
            color: var(--ultra-violet, #4b4e6d);
        }

        .card-elevated {
            border-radius: 1rem;
            border: none;
            box-shadow: 0 0.5rem 1.5rem rgba(34, 34, 34, 0.08);
        }

        .card-elevated .card-header {
            border-bottom: 1px solid rgba(34, 34, 34, 0.06);
            background-color: #fff;
            border-radius: 1rem 1rem 0 0;
        }

        .form-section-heading {
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--ultra-violet, #4b4e6d);
        }

        .table-responsive {
            border-radius: 0.75rem;
        }
    </style>
</asp:Content>

<asp:Content ID="AdminSurveysMain" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="smAdminSurveys" runat="server" />
    <asp:HiddenField ID="hfSelectedSurveyId" runat="server" />

    <asp:Panel ID="pnlAlert" runat="server" CssClass="alert alert-dismissible fade show" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert">
            <span class="visually-hidden"><asp:Literal runat="server" ID="litAlertClose" Text="<%$ Resources:GlobalResources,Close %>" /></span>
        </button>
    </asp:Panel>

    <div class="admin-section-title">
        <i class="bi bi-clipboard-check"></i>
        <div>
            <h2 class="mb-0"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SurveyManagement %>" /></h2>
            <small class="text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SurveyManagementSubtitle %>" /></small>
        </div>
    </div>
    <div class="card card-elevated mb-4">
        <div class="card-header d-flex flex-wrap align-items-center justify-content-between gap-3">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-list-task text-primary"></i>
                <strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ExistingSurveys %>" /></strong>
            </div>
            <div class="d-flex flex-wrap gap-2">
                <asp:Button ID="btnRefreshSurveys" runat="server" CssClass="btn btn-outline-secondary" Text="<%$ Resources:GlobalResources,Refresh %>" OnClick="btnRefreshSurveys_Click" CausesValidation="false" />
                <asp:Button ID="btnNewSurvey" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalResources,CreateSurvey %>" OnClick="btnNewSurvey_Click" CausesValidation="false" />
            </div>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <asp:GridView ID="gvSurveys" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle" DataKeyNames="SurveyId" OnRowCommand="gvSurveys_RowCommand" OnRowDataBound="gvSurveys_RowDataBound" EmptyDataText="<%$ Resources:GlobalResources,NoSurveysFound %>">
                    <Columns>
                        <asp:BoundField DataField="Title" HeaderText="<%$ Resources:GlobalResources,Title %>" />
                        <asp:TemplateField HeaderText="<%$ Resources:GlobalResources,Status %>">
                            <ItemTemplate>
                                <span class='<%# (bool)Eval("IsActive") ? "badge bg-success" : "badge bg-secondary" %>'><%# (bool)Eval("IsActive") ? HttpContext.GetGlobalResourceObject("GlobalResources", "Active") : HttpContext.GetGlobalResourceObject("GlobalResources", "Inactive") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="LanguageCode" HeaderText="<%$ Resources:GlobalResources,Language %>" />
                        <asp:TemplateField HeaderText="<%$ Resources:GlobalResources,StartDate %>">
                            <ItemTemplate>
                                <asp:Label ID="lblStartDate" runat="server" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources:GlobalResources,EndDate %>">
                            <ItemTemplate>
                                <asp:Label ID="lblEndDate" runat="server" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources:GlobalResources,Actions %>" ItemStyle-CssClass="text-end">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkEditSurvey" runat="server" CssClass="btn btn-sm btn-outline-primary me-2" CommandName="EditSurvey" CommandArgument='<%# Eval("SurveyId") %>' Text="<%$ Resources:GlobalResources,Edit %>" />
                                <asp:LinkButton ID="lnkDeleteSurvey" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="DeleteSurvey" CommandArgument='<%# Eval("SurveyId") %>' Text="<%$ Resources:GlobalResources,Delete %>" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlSurveyEditor" runat="server" CssClass="card card-elevated mb-4" Visible="false">
        <div class="card-header d-flex flex-wrap align-items-center justify-content-between gap-3">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-pencil-square text-primary"></i>
                <strong><asp:Literal ID="litEditorTitle" runat="server" /></strong>
            </div>
            <asp:Button ID="btnCloseEditor" runat="server" CssClass="btn btn-outline-secondary" Text="<%$ Resources:GlobalResources,Close %>" OnClick="btnCloseEditor_Click" CausesValidation="false" />
        </div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-6">
                    <label for="txtSurveyTitle" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Title %>" /></label>
                    <asp:TextBox ID="txtSurveyTitle" runat="server" CssClass="form-control" MaxLength="200" />
                    <asp:RequiredFieldValidator ID="rfvSurveyTitle" runat="server" ControlToValidate="txtSurveyTitle" CssClass="text-danger small" Display="Dynamic" ErrorMessage="<%$ Resources:GlobalResources,SurveyTitleRequired %>" ValidationGroup="Survey" />
                </div>
                <div class="col-md-6">
                    <label for="ddlSurveyLanguage" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Language %>" /></label>
                    <asp:DropDownList ID="ddlSurveyLanguage" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12">
                    <label for="txtSurveyDescription" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Description %>" /></label>
                    <asp:TextBox ID="txtSurveyDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="2000" />
                </div>
                <div class="col-md-3">
                    <label for="txtSurveyStart" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,StartDate %>" /></label>
                    <asp:TextBox ID="txtSurveyStart" runat="server" CssClass="form-control" placeholder="yyyy-MM-dd" />
                </div>
                <div class="col-md-3">
                    <label for="txtSurveyEnd" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,EndDate %>" /></label>
                    <asp:TextBox ID="txtSurveyEnd" runat="server" CssClass="form-control" placeholder="yyyy-MM-dd" />
                </div>
                <div class="col-md-3 d-flex align-items-center">
                    <div class="form-check">
                        <asp:CheckBox ID="chkSurveyIsActive" runat="server" CssClass="form-check-input" />
                        <asp:Label ID="lblSurveyIsActive" runat="server" AssociatedControlID="chkSurveyIsActive" CssClass="form-check-label ms-2">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Active %>" />
                        </asp:Label>
                    </div>
                </div>
                <div class="col-md-3 d-flex align-items-center">
                    <div class="form-check">
                        <asp:CheckBox ID="chkAllowMultipleResponses" runat="server" CssClass="form-check-input" />
                        <asp:Label ID="lblAllowMultipleResponses" runat="server" AssociatedControlID="chkAllowMultipleResponses" CssClass="form-check-label ms-2">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AllowMultipleResponses %>" />
                        </asp:Label>
                    </div>
                </div>
            </div>

            <div class="mt-4 d-flex gap-2">
                <asp:Button ID="btnSaveSurvey" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalResources,Save %>" OnClick="btnSaveSurvey_Click" ValidationGroup="Survey" />
                <asp:Button ID="btnCancelSurvey" runat="server" CssClass="btn btn-outline-secondary" Text="<%$ Resources:GlobalResources,Cancel %>" OnClick="btnCancelSurvey_Click" CausesValidation="false" />
            </div>

            <asp:Panel ID="pnlQuestionSection" runat="server" CssClass="mt-5" Visible="false">
                <div class="form-section-heading d-flex justify-content-between align-items-center">
                    <div>
                        <i class="bi bi-chat-text"></i>
                        <span><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SurveyQuestions %>" /></span>
                    </div>
                    <asp:Button ID="btnAddQuestion" runat="server" CssClass="btn btn-sm btn-primary" Text="<%$ Resources:GlobalResources,AddQuestion %>" OnClick="btnAddQuestion_Click" CausesValidation="false" />
                </div>
                <div class="table-responsive mb-3">
                    <asp:GridView ID="gvQuestions" runat="server" AutoGenerateColumns="false" CssClass="table table-sm table-striped" DataKeyNames="SurveyQuestionId" OnRowCommand="gvQuestions_RowCommand" OnRowDataBound="gvQuestions_RowDataBound" EmptyDataText="<%$ Resources:GlobalResources,NoQuestionsFound %>">
                        <Columns>
                            <asp:BoundField DataField="QuestionText" HeaderText="<%$ Resources:GlobalResources,Question %>" />
                            <asp:BoundField DataField="QuestionType" HeaderText="<%$ Resources:GlobalResources,Type %>" />
                            <asp:CheckBoxField DataField="IsRequired" HeaderText="<%$ Resources:GlobalResources,Required %>" />
                            <asp:BoundField DataField="SortOrder" HeaderText="<%$ Resources:GlobalResources,Order %>" />
                            <asp:TemplateField HeaderText="<%$ Resources:GlobalResources,Actions %>" ItemStyle-CssClass="text-end">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkEditQuestion" runat="server" CssClass="btn btn-sm btn-outline-primary me-2" CommandName="EditQuestion" CommandArgument='<%# Eval("SurveyQuestionId") %>' Text="<%$ Resources:GlobalResources,Edit %>" />
                                    <asp:LinkButton ID="lnkDeleteQuestion" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="DeleteQuestion" CommandArgument='<%# Eval("SurveyQuestionId") %>' Text="<%$ Resources:GlobalResources,Delete %>" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

                <asp:Panel ID="pnlQuestionEditor" runat="server" CssClass="border rounded-3 p-3 bg-light" Visible="false">
                    <div class="row g-3 align-items-center">
                        <div class="col-md-6">
                            <label for="txtQuestionText" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Question %>" /></label>
                            <asp:TextBox ID="txtQuestionText" runat="server" CssClass="form-control" MaxLength="500" />
                            <asp:RequiredFieldValidator ID="rfvQuestionText" runat="server" ControlToValidate="txtQuestionText" CssClass="text-danger small" Display="Dynamic" ErrorMessage="<%$ Resources:GlobalResources,QuestionTextRequired %>" ValidationGroup="Question" />
                        </div>
                        <div class="col-md-3">
                            <label for="ddlQuestionType" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Type %>" /></label>
                            <asp:DropDownList ID="ddlQuestionType" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlQuestionType_SelectedIndexChanged" />
                        </div>
                        <div class="col-md-2">
                            <label for="txtQuestionOrder" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Order %>" /></label>
                            <asp:TextBox ID="txtQuestionOrder" runat="server" CssClass="form-control" Text="1" />
                        </div>
                        <div class="col-md-1 d-flex align-items-center">
                            <div class="form-check">
                                <asp:CheckBox ID="chkQuestionRequired" runat="server" CssClass="form-check-input" />
                                <asp:Label ID="lblQuestionRequired" runat="server" AssociatedControlID="chkQuestionRequired" CssClass="form-check-label ms-2">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Required %>" />
                                </asp:Label>
                            </div>
                        </div>
                    </div>
                    <div class="mt-3 d-flex gap-2">
                        <asp:Button ID="btnSaveQuestion" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalResources,Save %>" OnClick="btnSaveQuestion_Click" ValidationGroup="Question" />
                        <asp:Button ID="btnCancelQuestion" runat="server" CssClass="btn btn-outline-secondary" Text="<%$ Resources:GlobalResources,Cancel %>" OnClick="btnCancelQuestion_Click" CausesValidation="false" />
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlOptionEditor" runat="server" CssClass="border rounded-3 p-3 bg-light mt-4" Visible="false">
                    <div class="table-responsive mb-3">
                        <asp:GridView ID="gvOptions" runat="server" AutoGenerateColumns="false" CssClass="table table-sm" DataKeyNames="SurveyOptionId" OnRowCommand="gvOptions_RowCommand" OnRowDataBound="gvOptions_RowDataBound" EmptyDataText="<%$ Resources:GlobalResources,NoOptionsFound %>">
                            <Columns>
                                <asp:BoundField DataField="OptionText" HeaderText="<%$ Resources:GlobalResources,OptionText %>" />
                                <asp:BoundField DataField="OptionValue" HeaderText="<%$ Resources:GlobalResources,OptionValue %>" />
                                <asp:BoundField DataField="SortOrder" HeaderText="<%$ Resources:GlobalResources,Order %>" />
                                <asp:TemplateField HeaderText="<%$ Resources:GlobalResources,Actions %>" ItemStyle-CssClass="text-end">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkEditOption" runat="server" CssClass="btn btn-sm btn-outline-primary me-2" CommandName="EditOption" CommandArgument='<%# Eval("SurveyOptionId") %>' Text="<%$ Resources:GlobalResources,Edit %>" />
                                        <asp:LinkButton ID="lnkDeleteOption" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="DeleteOption" CommandArgument='<%# Eval("SurveyOptionId") %>' Text="<%$ Resources:GlobalResources,Delete %>" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                    <div class="row g-3 align-items-center">
                        <div class="col-md-6">
                            <label for="txtOptionText" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OptionText %>" /></label>
                            <asp:TextBox ID="txtOptionText" runat="server" CssClass="form-control" MaxLength="300" />
                            <asp:RequiredFieldValidator ID="rfvOptionText" runat="server" ControlToValidate="txtOptionText" CssClass="text-danger small" Display="Dynamic" ErrorMessage="<%$ Resources:GlobalResources,OptionTextRequired %>" ValidationGroup="Option" />
                        </div>
                        <div class="col-md-3">
                            <label for="txtOptionValue" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OptionValue %>" /></label>
                            <asp:TextBox ID="txtOptionValue" runat="server" CssClass="form-control" MaxLength="100" />
                        </div>
                        <div class="col-md-3">
                            <label for="txtOptionOrder" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Order %>" /></label>
                            <asp:TextBox ID="txtOptionOrder" runat="server" CssClass="form-control" Text="1" />
                        </div>
                    </div>
                    <div class="mt-3 d-flex gap-2">
                        <asp:Button ID="btnSaveOption" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalResources,Save %>" OnClick="btnSaveOption_Click" ValidationGroup="Option" />
                        <asp:Button ID="btnCancelOption" runat="server" CssClass="btn btn-outline-secondary" Text="<%$ Resources:GlobalResources,Cancel %>" OnClick="btnCancelOption_Click" CausesValidation="false" />
                    </div>
                </asp:Panel>
            </asp:Panel>
        </div>
    </asp:Panel>

    <script type="text/javascript">
        Sys.Application.add_load(function () {
            var surveyIdField = document.getElementById('<%= hfSelectedSurveyId.ClientID %>');
            var questionSection = document.getElementById('<%= pnlQuestionSection.ClientID %>');
            if (!questionSection) {
                return;
            }

            var isNewSurvey = !surveyIdField || surveyIdField.value === '' || surveyIdField.value === '0';
            if (isNewSurvey) {
                questionSection.style.display = 'block';
            }
        });
    </script>
</asp:Content>
