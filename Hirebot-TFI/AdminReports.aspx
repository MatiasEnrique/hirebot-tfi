<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminReports.aspx.cs" Inherits="Hirebot_TFI.AdminReports" %>
<%@ Register Src="~/Controls/LanguageSelector.ascx" TagPrefix="uc" TagName="LanguageSelector" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsTitle %>" /> - Hirebot</title>
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

        .btn-success {
            background-color: var(--tiffany-blue);
            border-color: var(--tiffany-blue);
            color: var(--eerie-black);
        }

        .btn-success:hover {
            background-color: var(--cadet-gray);
            border-color: var(--cadet-gray);
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
                        <a href="AdminSurveys.aspx" class="sidebar-nav-link">
                            <i class="bi bi-clipboard-check"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SurveyManagement %>" />
                        </a>
                    </div>
                    <div class="sidebar-nav-item">
                        <a href="AdminReports.aspx" class="sidebar-nav-link active">
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
            <div class="container-fluid">
                <div class="row mb-3">
                    <div class="col-12 d-flex align-items-center justify-content-between flex-wrap">
                        <h1 class="h3 mb-0 text-gray-800">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsHeading %>" />
                        </h1>
                    </div>
                </div>

                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-danger" role="alert">
                    <asp:Literal ID="litError" runat="server" />
                </asp:Panel>

                <div class="card shadow mb-4">
                    <div class="card-body">
                        <div class="row g-3 align-items-end">
                            <div class="col-sm-6 col-lg-3">
                                <label for="<%= txtYear.ClientID %>" class="form-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsYearFilter %>" />
                                </label>
                                <asp:TextBox ID="txtYear" runat="server" CssClass="form-control" MaxLength="4" />
                                <small class="form-text text-muted">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsYearHint %>" />
                                </small>
                            </div>
                            <div class="col-sm-6 col-lg-3">
                                <label for="<%= ddlSortDirection.ClientID %>" class="form-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSortLabel %>" />
                                </label>
                                <asp:DropDownList ID="ddlSortDirection" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                            <div class="col-sm-6 col-lg-3">
                                <asp:Button ID="btnApplyFilters" runat="server" CssClass="btn btn-primary w-100" OnClick="btnApplyFilters_Click" Text="<%$ Resources:GlobalResources,AdminReportsApplyFilters %>" />
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-12">
                        <h2 class="h4 mb-3">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingSummary %>" />
                        </h2>
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-primary shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-primary text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTotalDocuments %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litTotalBillingDocuments" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-success shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-success text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingPaidDocuments %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litPaidBillingDocuments" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-warning shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-warning text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingOutstandingDocuments %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litOutstandingBillingDocuments" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-danger shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-danger text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingCancelledDocuments %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litCancelledBillingDocuments" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-primary shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-primary text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTotalAmount %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litTotalBillingAmount" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-success shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-success text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingPaidAmount %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litPaidBillingAmount" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-warning shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-warning text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingOutstandingAmount %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litOutstandingBillingAmount" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-info shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-info text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingAverageAmount %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litAverageInvoiceAmount" runat="server" />
                                </div>
                                <div class="text-xs text-muted mt-2">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingLastUpdated %>" />
                                    :
                                    <asp:Literal ID="litBillingLastUpdated" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 fw-bold text-primary">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingChartTitle %>" />
                        </h6>
                    </div>
                    <div class="card-body">
                        <canvas id="billingTotalsChart" height="120"></canvas>
                    </div>
                </div>

                <div class="card shadow mb-5">
                    <div class="card-header py-3">
                        <h6 class="m-0 fw-bold text-primary">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTableTitle %>" />
                        </h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <asp:Repeater ID="rptBillingMonthly" runat="server">
                                <HeaderTemplate>
                                    <table class="table table-striped table-hover align-middle">
                                        <thead class="table-dark">
                                            <tr>
                                                <th scope="col"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTableMonth %>" /></th>
                                                <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTableTotalDocs %>" /></th>
                                                <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTablePaidDocs %>" /></th>
                                                <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTableOutstandingDocs %>" /></th>
                                                <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTableCancelledDocs %>" /></th>
                                                <th scope="col" class="text-end"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTableTotalAmount %>" /></th>
                                                <th scope="col" class="text-end"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTablePaidAmount %>" /></th>
                                                <th scope="col" class="text-end"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTableOutstandingAmount %>" /></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                </HeaderTemplate>
                                <ItemTemplate>
                                            <tr>
                                                <td><%# string.Format("{0:00}/{1}", Eval("MonthNumber"), Eval("YearNumber")) %> - <%# Encode(Eval("MonthName")) %></td>
                                                <td class="text-center"><%# Eval("TotalDocuments") %></td>
                                                <td class="text-center"><%# Eval("PaidDocuments") %></td>
                                                <td class="text-center"><%# Convert.ToInt32(Eval("DraftDocuments")) + Convert.ToInt32(Eval("IssuedDocuments")) %></td>
                                                <td class="text-center"><%# Eval("CancelledDocuments") %></td>
                                                <td class="text-end"><%# string.Format(System.Globalization.CultureInfo.CurrentUICulture, "{0:C}", Eval("TotalAmount")) %></td>
                                                <td class="text-end"><%# string.Format(System.Globalization.CultureInfo.CurrentUICulture, "{0:C}", Eval("PaidAmount")) %></td>
                                                <td class="text-end"><%# string.Format(System.Globalization.CultureInfo.CurrentUICulture, "{0:C}", Eval("OutstandingAmount")) %></td>
                                            </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                        </tbody>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-12">
                        <h2 class="h4 mb-3">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveySummary %>" />
                        </h2>
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-primary shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-primary text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTotal %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litTotalSurveys" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-success shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-success text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyActive %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litActiveSurveys" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-info shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-info text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyScheduled %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litScheduledSurveys" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-danger shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-danger text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyExpired %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litExpiredSurveys" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-primary shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-primary text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTotalResponses %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litSurveyResponses" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-success shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-success text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyResponses30 %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litSurveyResponses30" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-warning shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-warning text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyAverageResponses %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litAverageResponses" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-start-info shadow h-100 py-3">
                            <div class="card-body">
                                <div class="text-xs fw-bold text-info text-uppercase mb-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyLastResponse %>" />
                                </div>
                                <div class="h5 mb-0 fw-bold text-gray-800">
                                    <asp:Literal ID="litSurveyLastResponse" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 fw-bold text-primary">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyChartTitle %>" />
                        </h6>
                    </div>
                    <div class="card-body">
                        <canvas id="surveyResponsesChart" height="120"></canvas>
                    </div>
                </div>

                <div class="card shadow mb-5">
                    <div class="card-header py-3">
                        <h6 class="m-0 fw-bold text-primary">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableTitle %>" />
                        </h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <asp:Repeater ID="rptSurveyDetails" runat="server">
                                <HeaderTemplate>
                                    <table class="table table-striped table-hover align-middle">
                                        <thead class="table-dark">
                                            <tr>
                                                <th scope="col"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableTitleCol %>" /></th>
                                                <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableStatus %>" /></th>
                                                <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableQuestions %>" /></th>
                                                <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableTotalResponses %>" /></th>
                                                <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableRecentResponses %>" /></th>
                                                <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableWindow %>" /></th>
                                                <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableLastResponse %>" /></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                </HeaderTemplate>
                                <ItemTemplate>
                                            <tr>
                                                <td>
                                                    <div class="fw-bold"><%# Encode(Eval("Title")) %></div>
                                                    <div class="text-muted small">
                                                        <%# GetDateRange(Container.DataItem) %>
                                                    </div>
                                                </td>
                                                <td class="text-center">
                                                    <span class="badge <%# ((bool)Eval("IsCurrentlyOpen")) ? "bg-success" : ((bool)Eval("IsActive")) ? "bg-info" : "bg-secondary" %>">
                                                        <%# GetSurveyStatus(Container.DataItem) %>
                                                    </span>
                                                </td>
                                                <td class="text-center"><%# Eval("QuestionCount") %></td>
                                                <td class="text-center"><%# Eval("TotalResponses") %></td>
                                                <td class="text-center"><%# Eval("ResponsesLast30Days") %></td>
                                                <td class="text-center"><%# GetSurveyWindow(Container.DataItem) %></td>
                                                <td class="text-center"><%# GetSurveyLastResponse(Container.DataItem) %></td>
                                            </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                        </tbody>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </div>

                <asp:HiddenField ID="hfBillingChartData" runat="server" />
                <asp:HiddenField ID="hfSurveyChartData" runat="server" />
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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

            (function () {
                const formatCurrency = value => {
                    if (typeof Intl !== 'undefined' && Intl.NumberFormat) {
                        return new Intl.NumberFormat(document.documentElement.lang || 'es', {
                            style: 'currency',
                            currency: 'ARS',
                            minimumFractionDigits: 2
                        }).format(value || 0);
                    }
                    return (value || 0).toFixed(2);
                };

                const billingField = document.getElementById('<%= hfBillingChartData.ClientID %>');
                if (billingField && billingField.value) {
                    try {
                        const billingData = JSON.parse(billingField.value);
                        const ctx = document.getElementById('billingTotalsChart');
                        if (ctx && billingData && billingData.labels.length) {
                            new Chart(ctx, {
                                type: 'line',
                                data: billingData,
                                options: {
                                    responsive: true,
                                    maintainAspectRatio: false,
                                    interaction: { intersect: false, mode: 'index' },
                                    plugins: {
                                        tooltip: {
                                            callbacks: {
                                                label: context => {
                                                    const label = context.dataset.label || '';
                                                    const value = context.parsed.y || 0;
                                                    return `${label}: ${formatCurrency(value)}`;
                                                }
                                            }
                                        }
                                    },
                                    scales: {
                                        y: {
                                            ticks: {
                                                callback: value => formatCurrency(value)
                                            }
                                        }
                                    }
                                }
                            });
                        }
                    } catch (err) {
                        console.error('Unable to render billing chart', err);
                    }
                }

                const surveyField = document.getElementById('<%= hfSurveyChartData.ClientID %>');
                if (surveyField && surveyField.value) {
                    try {
                        const surveyData = JSON.parse(surveyField.value);
                        const ctx = document.getElementById('surveyResponsesChart');
                        if (ctx && surveyData && surveyData.labels.length) {
                            new Chart(ctx, {
                                type: 'bar',
                                data: surveyData,
                                options: {
                                    responsive: true,
                                    maintainAspectRatio: false,
                                    interaction: { intersect: false, mode: 'index' },
                                    scales: {
                                        y: {
                                            beginAtZero: true,
                                            ticks: {
                                                precision: 0
                                            }
                                        }
                                    }
                                }
                            });
                        }
                    } catch (err) {
                        console.error('Unable to render survey chart', err);
                    }
                }
            })();
        });
    </script>
</body>
</html>
