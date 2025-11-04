<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminSurveys.aspx.cs" Inherits="Hirebot_TFI.AdminSurveys" MasterPageFile="~/Admin.master" %>

<asp:Content ID="SurveysTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Gestión de encuestas" />
</asp:Content>

<asp:Content ID="SurveysHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .card-elevated { box-shadow: 0 0.15rem 1.75rem rgba(58,59,69,.15); border-radius: .75rem; }
        .admin-section-title { display:flex; align-items:center; gap:.75rem; margin-bottom:1rem; }
        .admin-section-title i { font-size:1.5rem; color:#4b4e6d; }
    </style>
</asp:Content>

<asp:Content ID="SurveysMain" ContentPlaceHolderID="MainContent" runat="server">
    <asp:HiddenField ID="hfSelectedSurveyId" runat="server" />

    <asp:Panel ID="pnlAlert" runat="server" CssClass="alert alert-dismissible fade show" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert">
            <span class="visually-hidden"><asp:Literal runat="server" ID="litAlertClose" Text="Cerrar" /></span>
        </button>
    </asp:Panel>

    <div class="admin-section-title">
        <i class="bi bi-clipboard-check"></i>
        <div>
            <h2 class="mb-0"><asp:Literal runat="server" Text="Gestión de encuestas" /></h2>
            <small class="text-muted"><asp:Literal runat="server" Text="Crea y administra encuestas dinámicas para tus usuarios." /></small>
        </div>
    </div>

    <div class="card card-elevated mb-4">
        <div class="card-header d-flex flex-wrap align-items-center justify-content-between gap-3">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-list-task text-primary"></i>
                <strong><asp:Literal runat="server" Text="Encuestas existentes" /></strong>
            </div>
            <div class="d-flex flex-wrap gap-2">
                <asp:Button ID="btnRefreshSurveys" runat="server" CssClass="btn btn-outline-secondary" Text="Actualizar" OnClick="btnRefreshSurveys_Click" CausesValidation="false" />
                <asp:Button ID="btnNewSurvey" runat="server" CssClass="btn btn-primary" Text="Crear encuesta" OnClick="btnNewSurvey_Click" CausesValidation="false" />
            </div>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <asp:GridView ID="gvSurveys" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle" DataKeyNames="SurveyId" OnRowCommand="gvSurveys_RowCommand" OnRowDataBound="gvSurveys_RowDataBound" EmptyDataText="No se encontraron encuestas.">
                    <Columns>
                        <asp:BoundField DataField="Title" HeaderText="Título" />
                        <asp:TemplateField HeaderText="Estado">
                            <ItemTemplate>
                                <span class='<%# (bool)Eval("IsActive") ? "badge bg-success" : "badge bg-secondary" %>'><%# (bool)Eval("IsActive") ? HttpContext.GetGlobalResourceObject("GlobalResources", "Active") : HttpContext.GetGlobalResourceObject("GlobalResources", "Inactive") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="LanguageCode" HeaderText="Idioma" />
                        <asp:TemplateField HeaderText="Fecha de Inicio">
                            <ItemTemplate>
                                <asp:Label ID="lblStartDate" runat="server" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Fecha de Fin">
                            <ItemTemplate>
                                <asp:Label ID="lblEndDate" runat="server" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Acciones" ItemStyle-CssClass="text-end">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkEditSurvey" runat="server" CssClass="btn btn-sm btn-outline-primary me-2" CommandName="EditSurvey" CommandArgument='<%# Eval("SurveyId") %>' Text="Editar" />
                                <asp:LinkButton ID="lnkDeleteSurvey" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="DeleteSurvey" CommandArgument='<%# Eval("SurveyId") %>' Text="Eliminar" />
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
            <asp:Button ID="btnCloseEditor" runat="server" CssClass="btn btn-outline-secondary" Text="Cerrar" OnClick="btnCloseEditor_Click" CausesValidation="false" />
        </div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-6">
                    <label for="txtSurveyTitle" class="form-label"><asp:Literal runat="server" Text="Título" /></label>
                    <asp:TextBox ID="txtSurveyTitle" runat="server" CssClass="form-control" MaxLength="200" />
                    <asp:RequiredFieldValidator ID="rfvSurveyTitle" runat="server" ControlToValidate="txtSurveyTitle" CssClass="text-danger small" Display="Dynamic" ErrorMessage="El título de la encuesta es obligatorio." ValidationGroup="Survey" />
                </div>
                <div class="col-md-6">
                    <label for="ddlSurveyLanguage" class="form-label"><asp:Literal runat="server" Text="Idioma" /></label>
                    <asp:DropDownList ID="ddlSurveyLanguage" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12">
                    <label for="txtSurveyDescription" class="form-label"><asp:Literal runat="server" Text="Descripción" /></label>
                    <asp:TextBox ID="txtSurveyDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="2000" />
                </div>
                <div class="col-md-3">
                    <label for="txtSurveyStart" class="form-label"><asp:Literal runat="server" Text="Fecha de Inicio" /></label>
                    <asp:TextBox ID="txtSurveyStart" runat="server" CssClass="form-control" placeholder="yyyy-MM-dd" />
                </div>
                <div class="col-md-3">
                    <label for="txtSurveyEnd" class="form-label"><asp:Literal runat="server" Text="Fecha de Fin" /></label>
                    <asp:TextBox ID="txtSurveyEnd" runat="server" CssClass="form-control" placeholder="yyyy-MM-dd" />
                </div>
                <div class="col-md-3 d-flex align-items-center">
                    <div class="form-check">
                        <asp:CheckBox ID="chkSurveyIsActive" runat="server" CssClass="form-check-input" />
                        <asp:Label ID="lblSurveyIsActive" runat="server" AssociatedControlID="chkSurveyIsActive" CssClass="form-check-label ms-2">
                            <asp:Literal runat="server" Text="Activo" />
                        </asp:Label>
                    </div>
                </div>
                <div class="col-md-3 d-flex align-items-center">
                    <div class="form-check">
                        <asp:CheckBox ID="chkAllowMultipleResponses" runat="server" CssClass="form-check-input" />
                        <asp:Label ID="lblAllowMultipleResponses" runat="server" AssociatedControlID="chkAllowMultipleResponses" CssClass="form-check-label ms-2">
                            <asp:Literal runat="server" Text="Permitir múltiples respuestas" />
                        </asp:Label>
                    </div>
                </div>
                <div class="col-12">
                    <div class="d-flex gap-2">
                        <asp:Button ID="btnSaveSurvey" runat="server" CssClass="btn btn-primary" Text="Guardar" OnClick="btnSaveSurvey_Click" ValidationGroup="Survey" />
                        <asp:Button ID="btnCancelSurvey" runat="server" CssClass="btn btn-outline-secondary" Text="Cancelar" OnClick="btnCloseEditor_Click" CausesValidation="false" />
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlQuestionSection" runat="server" CssClass="card card-elevated mb-4" Visible="false">
        <div class="card-header d-flex flex-wrap align-items-center justify-content-between gap-3">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-question-circle text-primary"></i>
                <strong><asp:Literal runat="server" Text="Preguntas" /></strong>
            </div>
            <asp:Button ID="btnNewQuestion" runat="server" CssClass="btn btn-sm btn-primary" Text="Agregar pregunta" OnClick="btnNewQuestion_Click" CausesValidation="false" />
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <asp:GridView ID="gvQuestions" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle" DataKeyNames="SurveyQuestionId" OnRowCommand="gvQuestions_RowCommand" OnRowDataBound="gvQuestions_RowDataBound" EmptyDataText="No se registraron preguntas.">
                    <Columns>
                        <asp:BoundField DataField="SortOrder" HeaderText="Orden" ItemStyle-Width="80px" />
                        <asp:BoundField DataField="QuestionText" HeaderText="Pregunta" />
                        <asp:TemplateField HeaderText="Tipo">
                            <ItemTemplate>
                                <%# GetQuestionTypeDisplay(Eval("QuestionType")?.ToString()) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Obligatoria">
                            <ItemTemplate>
                                <span class='<%# (bool)Eval("IsRequired") ? "badge bg-warning" : "badge bg-secondary" %>'><%# (bool)Eval("IsRequired") ? HttpContext.GetGlobalResourceObject("GlobalResources", "Yes") : HttpContext.GetGlobalResourceObject("GlobalResources", "No") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Acciones" ItemStyle-CssClass="text-end">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkEditQuestion" runat="server" CssClass="btn btn-sm btn-outline-primary me-2" CommandName="EditQuestion" CommandArgument='<%# Eval("SurveyQuestionId") %>' Text="Editar" CausesValidation="false" />
                                <asp:LinkButton ID="lnkDeleteQuestion" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="DeleteQuestion" CommandArgument='<%# Eval("SurveyQuestionId") %>' Text="Eliminar" CausesValidation="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlQuestionEditor" runat="server" CssClass="card card-elevated mb-4" Visible="false">
        <div class="card-header">
            <strong><i class="bi bi-pencil-square text-primary"></i> <asp:Literal runat="server" Text="Editor de Preguntas" /></strong>
        </div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-12">
                    <label for="txtQuestionText" class="form-label"><asp:Literal runat="server" Text="Texto de la Pregunta" /></label>
                    <asp:TextBox ID="txtQuestionText" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" MaxLength="500" />
                    <asp:RequiredFieldValidator ID="rfvQuestionText" runat="server" ControlToValidate="txtQuestionText" CssClass="text-danger small" Display="Dynamic" ErrorMessage="El texto de la pregunta es obligatorio." ValidationGroup="Question" />
                </div>
                <div class="col-md-4">
                    <label for="ddlQuestionType" class="form-label"><asp:Literal runat="server" Text="Tipo de Pregunta" /></label>
                    <asp:DropDownList ID="ddlQuestionType" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlQuestionType_SelectedIndexChanged" />
                </div>
                <div class="col-md-4">
                    <label for="txtQuestionOrder" class="form-label"><asp:Literal runat="server" Text="Orden" /></label>
                    <asp:TextBox ID="txtQuestionOrder" runat="server" CssClass="form-control" TextMode="Number" />
                </div>
                <div class="col-md-4 d-flex align-items-end">
                    <div class="form-check">
                        <asp:CheckBox ID="chkQuestionRequired" runat="server" CssClass="form-check-input" />
                        <asp:Label runat="server" AssociatedControlID="chkQuestionRequired" CssClass="form-check-label">
                            <asp:Literal runat="server" Text="Obligatoria" />
                        </asp:Label>
                    </div>
                </div>
                <div class="col-12">
                    <div class="d-flex gap-2">
                        <asp:Button ID="btnSaveQuestion" runat="server" CssClass="btn btn-primary" Text="Guardar" OnClick="btnSaveQuestion_Click" ValidationGroup="Question" />
                        <asp:Button ID="btnCancelQuestion" runat="server" CssClass="btn btn-outline-secondary" Text="Cancelar" OnClick="btnCancelQuestion_Click" CausesValidation="false" />
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlOptionEditor" runat="server" CssClass="card card-elevated mb-4" Visible="false">
        <div class="card-header d-flex flex-wrap align-items-center justify-content-between gap-3">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-list-ul text-primary"></i>
                <strong><asp:Literal runat="server" Text="Opciones" /></strong>
            </div>
            <asp:Button ID="btnNewOption" runat="server" CssClass="btn btn-sm btn-primary" Text="Agregar Opción" OnClick="btnNewOption_Click" CausesValidation="false" />
        </div>
        <div class="card-body">
            <div class="table-responsive mb-3">
                <asp:GridView ID="gvOptions" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle" DataKeyNames="SurveyOptionId" OnRowCommand="gvOptions_RowCommand" OnRowDataBound="gvOptions_RowDataBound" EmptyDataText="No se registraron opciones.">
                    <Columns>
                        <asp:BoundField DataField="SortOrder" HeaderText="Orden" ItemStyle-Width="80px" />
                        <asp:BoundField DataField="OptionText" HeaderText="Texto" />
                        <asp:BoundField DataField="OptionValue" HeaderText="Valor" />
                        <asp:TemplateField HeaderText="Acciones" ItemStyle-CssClass="text-end">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkEditOption" runat="server" CssClass="btn btn-sm btn-outline-primary me-2" CommandName="EditOption" CommandArgument='<%# Eval("SurveyOptionId") %>' Text="Editar" CausesValidation="false" />
                                <asp:LinkButton ID="lnkDeleteOption" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="DeleteOption" CommandArgument='<%# Eval("SurveyOptionId") %>' Text="Eliminar" CausesValidation="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
            <div class="row g-3">
                <div class="col-md-5">
                    <label for="txtOptionText" class="form-label"><asp:Literal runat="server" Text="Texto de la opción" /></label>
                    <asp:TextBox ID="txtOptionText" runat="server" CssClass="form-control" MaxLength="200" />
                    <asp:RequiredFieldValidator ID="rfvOptionText" runat="server" ControlToValidate="txtOptionText" CssClass="text-danger small" Display="Dynamic" ErrorMessage="El texto de la opción es obligatorio." ValidationGroup="Option" />
                </div>
                <div class="col-md-4">
                    <label for="txtOptionValue" class="form-label"><asp:Literal runat="server" Text="Valor" /></label>
                    <asp:TextBox ID="txtOptionValue" runat="server" CssClass="form-control" MaxLength="50" />
                </div>
                <div class="col-md-3">
                    <label for="txtOptionOrder" class="form-label"><asp:Literal runat="server" Text="Orden" /></label>
                    <asp:TextBox ID="txtOptionOrder" runat="server" CssClass="form-control" TextMode="Number" />
                </div>
                <div class="col-12">
                    <div class="d-flex gap-2">
                        <asp:Button ID="btnSaveOption" runat="server" CssClass="btn btn-primary" Text="Guardar" OnClick="btnSaveOption_Click" ValidationGroup="Option" />
                        <asp:Button ID="btnCancelOption" runat="server" CssClass="btn btn-outline-secondary" Text="Cancelar" OnClick="btnCancelOption_Click" CausesValidation="false" />
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>
</asp:Content>

<asp:Content ID="SurveysScripts" ContentPlaceHolderID="ScriptContent" runat="server">
</asp:Content>
