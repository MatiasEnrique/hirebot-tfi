<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminSurveys.aspx.cs" Inherits="Hirebot_TFI.AdminSurveys" %>
<%@ Register Src="~/Controls/LanguageSelector.ascx" TagPrefix="uc" TagName="LanguageSelector" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SurveyManagement %>" /> - Hirebot</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --eerie-black: #222222;
            --ultra-violet: #4b4e6d;
            --tiffany-blue: #84dcc6;
            --cadet-gray: #95a3b3;
            --sidebar-width: 280px;
        }

        .admin-sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            width: var(--sidebar-width);
            background: linear-gradient(135deg, var(--eerie-black), var(--ultra-violet));
            padding: 0;
            z-index: 1000;
            transition: transform 0.3s ease;
            overflow-y: auto;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
        }

        .sidebar-brand {
            padding: 1.5rem 1.25rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            background: rgba(0, 0, 0, 0.2);
        }

        .sidebar-brand h4 {
            color: white;
            margin: 0;
            font-weight: 600;
            font-size: 1.2rem;
        }

        .sidebar-brand .brand-icon {
            color: var(--tiffany-blue);
            font-size: 1.5rem;
            margin-right: 0.75rem;
        }

        .sidebar-nav {
            padding: 1rem 0;
        }

        .nav-section {
            margin-bottom: 1.5rem;
        }

        .nav-section-title {
            padding: 0.5rem 1.25rem;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            color: var(--cadet-gray);
            letter-spacing: 0.1em;
        }

        .sidebar-nav-item {
            margin-bottom: 0.25rem;
        }

        .sidebar-nav-link {
            display: flex;
            align-items: center;
            padding: 0.875rem 1.25rem;
            color: rgba(255, 255, 255, 0.85);
            text-decoration: none;
            transition: all 0.2s ease;
            border-left: 3px solid transparent;
            position: relative;
        }

        .sidebar-nav-link:hover {
            background: rgba(132, 220, 198, 0.1);
            color: var(--tiffany-blue);
            border-left-color: var(--tiffany-blue);
            text-decoration: none;
        }

        .sidebar-nav-link.active {
            background: rgba(132, 220, 198, 0.15);
            color: var(--tiffany-blue);
            border-left-color: var(--tiffany-blue);
            font-weight: 500;
        }

        .sidebar-nav-link i {
            width: 20px;
            margin-right: 0.75rem;
            font-size: 1.1rem;
        }

        .sidebar-footer {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            padding: 1rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            background: rgba(0, 0, 0, 0.2);
        }

        .sidebar-user-info {
            display: flex;
            align-items: center;
            padding: 0.75rem;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 0.5rem;
            margin-bottom: 0.75rem;
        }

        .user-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: var(--tiffany-blue);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 0.75rem;
            font-weight: 600;
            color: var(--eerie-black);
        }

        .user-details h6 {
            color: white;
            margin: 0;
            font-size: 0.875rem;
            font-weight: 500;
        }

        .user-details small {
            color: var(--cadet-gray);
            font-size: 0.75rem;
        }

        .sidebar-language-selector {
            margin-bottom: 0.75rem;
        }

        .sidebar-language-selector .nav-link {
            color: white !important;
            padding: 0.5rem;
            border-radius: 0.25rem;
            transition: background-color 0.2s ease;
        }

        .sidebar-language-selector .nav-link:hover {
            background: rgba(255, 255, 255, 0.1);
            color: var(--tiffany-blue) !important;
        }

        .sidebar-language-selector .dropdown-menu {
            background: var(--eerie-black);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .sidebar-language-selector .dropdown-item {
            color: white !important;
            transition: all 0.2s ease;
        }

        .sidebar-language-selector .dropdown-item:hover {
            background: rgba(132, 220, 198, 0.1);
            color: var(--tiffany-blue) !important;
        }

        .sidebar-language-selector .bi-translate {
            color: white;
        }

        .sidebar-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(0, 0, 0, 0.5);
            z-index: 999;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }

        .sidebar-overlay.show {
            opacity: 1;
            visibility: visible;
        }

        .mobile-header {
            display: none;
            background: var(--eerie-black);
            padding: 1rem;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1001;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .mobile-toggle-btn {
            background: none;
            border: none;
            color: white;
            font-size: 1.25rem;
            cursor: pointer;
            padding: 0.5rem;
            border-radius: 0.25rem;
            transition: background-color 0.2s ease;
        }

        .mobile-toggle-btn:hover {
            background: rgba(255, 255, 255, 0.1);
        }

        .mobile-brand {
            color: white;
            font-weight: 600;
            font-size: 1.1rem;
            margin: 0;
        }

        .main-content {
            margin-left: var(--sidebar-width);
            padding: 2rem;
            min-height: 100vh;
            background: #f8f9fa;
            transition: margin-left 0.3s ease;
        }

        .btn-primary {
            background-color: var(--ultra-violet);
            border-color: var(--ultra-violet);
        }

        .btn-primary:hover {
            background-color: var(--tiffany-blue);
            border-color: var(--tiffany-blue);
            color: var(--eerie-black);
        }

        .btn-outline-secondary:hover {
            color: var(--eerie-black);
        }

        .admin-section-title {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 1.5rem;
        }

        .admin-section-title .bi-clipboard-check {
            font-size: 1.75rem;
            color: var(--ultra-violet);
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
            color: var(--ultra-violet);
        }

        .table-responsive {
            border-radius: 0.75rem;
        }

        @media (max-width: 768px) {
            .admin-sidebar {
                transform: translateX(-100%);
            }

            .admin-sidebar.show {
                transform: translateX(0);
            }

            .main-content {
                margin-left: 0;
                padding-top: 5rem;
                padding-left: 1rem;
                padding-right: 1rem;
            }

            .mobile-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
            }
        }

        @media (max-width: 576px) {
            .main-content {
                padding: 4rem 0.75rem 1rem;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="mobile-header">
            <button class="mobile-toggle-btn" id="sidebarToggle" type="button">
                <i class="bi bi-list"></i>
            </button>
            <h5 class="mobile-brand">
                <i class="bi bi-robot me-2"></i>Hirebot Admin
            </h5>
        </div>

        <div class="sidebar-overlay" id="sidebarOverlay"></div>

        <nav class="admin-sidebar" id="adminSidebar">
            <div class="sidebar-brand">
                <h4>
                    <i class="bi bi-robot brand-icon"></i>
                    Hirebot Admin
                </h4>
            </div>

            <div class="sidebar-nav">
                <div class="nav-section">
                    <div class="nav-section-title">
                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,MainNavigation %>" />
                    </div>
                    <div class="sidebar-nav-item">
                        <a href="AdminDashboard.aspx" class="sidebar-nav-link">
                            <i class="bi bi-speedometer2"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Dashboard %>" />
                        </a>
                    </div>
                    <div class="sidebar-nav-item">
                        <a href="OrganizationAdmin.aspx" class="sidebar-nav-link">
                            <i class="bi bi-building"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Organizations %>" />
                        </a>
                    </div>
                    <div class="sidebar-nav-item">
                        <a href="ChatbotAdmin.aspx" class="sidebar-nav-link">
                            <i class="bi bi-robot"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ChatbotManagement %>" />
                        </a>
                    </div>
                    <div class="sidebar-nav-item">
                        <a href="AdminCatalog.aspx" class="sidebar-nav-link">
                            <i class="bi bi-box-seam"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CatalogManagement %>" />
                        </a>
                    </div>
                    <div class="sidebar-nav-item">
                        <a href="AdminNews.aspx" class="sidebar-nav-link">
                            <i class="bi bi-newspaper"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NewsManagement %>" />
                        </a>
                    </div>
                    <div class="sidebar-nav-item">
                        <a href="AdminBilling.aspx" class="sidebar-nav-link">
                            <i class="bi bi-receipt"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,BillingManagement %>" />
                        </a>
                    </div>
                    <div class="sidebar-nav-item">
                        <a href="AdminSurveys.aspx" class="sidebar-nav-link active">
                            <i class="bi bi-clipboard-check"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SurveyManagement %>" />
                        </a>
                    </div>
                    <div class="sidebar-nav-item">
                        <a href="AdminReports.aspx" class="sidebar-nav-link">
                            <i class="bi bi-graph-up"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsNav %>" />
                        </a>
                    </div>
                    <div class="sidebar-nav-item">
                        <a href="AdminLogs.aspx" class="sidebar-nav-link">
                            <i class="bi bi-journal-text"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LogManagement %>" />
                        </a>
                    </div>
                </div>
            </div>

            <div class="sidebar-footer">
                <div class="sidebar-user-info">
                    <div class="user-avatar">
                        <i class="bi bi-person-fill"></i>
                    </div>
                    <div class="user-details">
                        <h6><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Administrator %>" /></h6>
                        <small><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SystemAdmin %>" /></small>
                    </div>
                </div>

                <div class="sidebar-language-selector">
                    <uc:LanguageSelector ID="ucLanguageSelector" runat="server" />
                </div>

                <asp:LinkButton ID="btnLogout" runat="server" CssClass="sidebar-nav-link" OnClick="btnLogout_Click">
                    <i class="bi bi-box-arrow-right"></i>
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SignOut %>" />
                </asp:LinkButton>
            </div>
        </nav>

        <div class="main-content">
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
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const sidebarToggle = document.getElementById('sidebarToggle');
            const adminSidebar = document.getElementById('adminSidebar');
            const sidebarOverlay = document.getElementById('sidebarOverlay');

            function toggleSidebar() {
                adminSidebar.classList.toggle('show');
                sidebarOverlay.classList.toggle('show');
            }

            function closeSidebar() {
                adminSidebar.classList.remove('show');
                sidebarOverlay.classList.remove('show');
            }

            if (sidebarToggle) {
                sidebarToggle.addEventListener('click', toggleSidebar);
            }

            if (sidebarOverlay) {
                sidebarOverlay.addEventListener('click', closeSidebar);
            }

            window.addEventListener('resize', function () {
                if (window.innerWidth > 768) {
                    closeSidebar();
                }
            });

            const currentPage = window.location.pathname.toLowerCase();
            const navLinks = document.querySelectorAll('.sidebar-nav-link');

            navLinks.forEach(function (link) {
                const href = link.getAttribute('href');
                if (href && currentPage.includes(href.toLowerCase())) {
                    navLinks.forEach(function (l) {
                        l.classList.remove('active');
                    });
                    link.classList.add('active');
                }
            });

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
        });
    </script>
</body>
</html>
