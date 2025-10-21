<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminLogs.aspx.cs" Inherits="UI.AdminLogs" %>
<%@ Register Src="~/Controls/LanguageSelector.ascx" TagPrefix="uc" TagName="LanguageSelector" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LogManagement %>" /> - Hirebot</title>
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
        
        /* Sidebar Styles */
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
        
        /* Mobile Sidebar Toggle */
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
        
        /* Main Content Styles */
        .main-content {
            margin-left: var(--sidebar-width);
            padding: 2rem;
            min-height: 100vh;
            background: #f8f9fa;
            transition: margin-left 0.3s ease;
        }
        
        /* Language Selector in Sidebar */
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
        
        /* Button and Component Styles */
        .btn-primary { background-color: var(--ultra-violet); border-color: var(--ultra-violet); }
        .btn-primary:hover { background-color: var(--tiffany-blue); border-color: var(--tiffany-blue); color: var(--eerie-black); }
        .btn-success { background-color: var(--tiffany-blue); border-color: var(--tiffany-blue); color: var(--eerie-black); }
        .btn-success:hover { background-color: var(--cadet-gray); border-color: var(--cadet-gray); }
        .admin-section { background-color: #ffffff; border: 1px solid #dee2e6; border-radius: 0.375rem; box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075); }
        .form-label { font-weight: 600; color: var(--eerie-black); }
        .table thead th { background-color: var(--ultra-violet); color: white; }
        .table tbody tr:hover { background-color: rgba(132, 220, 198, 0.1); }
        .log-type-badge {
            font-size: 0.75rem;
            padding: 0.25rem 0.5rem;
        }
        
        /* Responsive Design */
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
        .log-login { background-color: #28a745; }
        .log-logout { background-color: #6c757d; }
        .log-register { background-color: #007bff; }
        .log-error { background-color: #dc3545; }
        .log-access { background-color: #17a2b8; }
        .log-update { background-color: #ffc107; color: #000; }
        .log-delete { background-color: #e83e8c; }
        .log-create { background-color: #20c997; }
        .log-system { background-color: #6f42c1; }
        .filter-section {
            background-color: white;
            border: 1px solid #e3e6f0;
            border-radius: 0.375rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
        }
        .stats-card {
            border: none;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            border-left: 0.25rem solid var(--ultra-violet);
        }
        
        /* Improved spacing and mobile responsiveness - integrated with sidebar */
        
        .section-spacing {
            margin-bottom: 2rem;
        }
        
        .card-spacing {
            margin-bottom: 1.5rem;
        }
        
        /* Custom Pagination Styles */
        .custom-pagination, .custom-pagination-template {
            background-color: #f8f9fa;
            border-top: 1px solid #dee2e6;
            padding: 1rem;
            text-align: center;
        }
        
        .custom-pagination td, .custom-pagination-template td {
            border: none !important;
            padding: 0 !important;
        }
        
        .custom-pagination table, .custom-pagination-template table {
            width: auto;
            margin: 0 auto;
            border-collapse: separate;
        }
        
        .custom-pagination a, .custom-pagination span,
        .custom-pagination-template a, .custom-pagination-template span {
            display: inline-block;
            padding: 8px 16px;
            margin: 0 4px;
            text-decoration: none;
            border: 1px solid var(--cadet-gray);
            border-radius: 6px;
            color: var(--ultra-violet);
            background-color: white;
            font-weight: 500;
            transition: all 0.2s ease;
            min-width: 40px;
            text-align: center;
        }
        
        .custom-pagination a:hover, .custom-pagination-template a:hover {
            background-color: var(--tiffany-blue);
            color: white;
            border-color: var(--tiffany-blue);
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .custom-pagination span, .custom-pagination-template span {
            background-color: var(--ultra-violet);
            color: white;
            border-color: var(--ultra-violet);
            cursor: default;
        }
        
        /* Disabled state for buttons */
        .custom-pagination a[disabled], .custom-pagination-template a[disabled],
        .custom-pagination span[disabled], .custom-pagination-template span[disabled] {
            opacity: 0.5;
            cursor: not-allowed;
            background-color: #e9ecef;
            color: #6c757d;
            border-color: #e9ecef;
        }
        
        .custom-pagination a[disabled]:hover, .custom-pagination-template a[disabled]:hover {
            background-color: #e9ecef;
            color: #6c757d;
            transform: none;
            box-shadow: none;
        }
        
        /* Make sure the pager row is properly styled */
        .custom-pagination-template tr, .custom-pagination tr {
            background: transparent !important;
        }
        
        .custom-pagination-template tr td, .custom-pagination tr td {
            background: transparent !important;
            vertical-align: middle;
        }
        
        /* Custom pager container styles */
        .custom-pager-container {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
            padding: 1rem;
        }
        
        .page-btn {
            display: inline-block;
            padding: 8px 16px;
            margin: 0;
            text-decoration: none;
            border: 1px solid var(--cadet-gray);
            border-radius: 6px;
            color: var(--ultra-violet);
            background-color: white;
            font-weight: 500;
            transition: all 0.2s ease;
            min-width: 40px;
            text-align: center;
            cursor: pointer;
        }
        
        .page-btn:hover {
            background-color: var(--tiffany-blue);
            color: white;
            border-color: var(--tiffany-blue);
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            text-decoration: none;
        }
        
        .page-btn.active {
            background-color: var(--ultra-violet);
            color: white;
            border-color: var(--ultra-violet);
            cursor: default;
        }
        
        .page-btn.disabled {
            opacity: 0.5;
            cursor: not-allowed;
            background-color: #e9ecef;
            color: #6c757d;
            border-color: #e9ecef;
        }
        
        .page-btn.disabled:hover {
            background-color: #e9ecef;
            color: #6c757d;
            transform: none;
            box-shadow: none;
        }
        
        .custom-pager-cell {
            background-color: #f8f9fa !important;
            border-top: 1px solid #dee2e6 !important;
            padding: 0 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Mobile Header -->
        <div class="mobile-header">
            <button class="mobile-toggle-btn" id="sidebarToggle" type="button">
                <i class="bi bi-list"></i>
            </button>
            <h5 class="mobile-brand">
                <i class="bi bi-robot me-2"></i>Hirebot Admin
            </h5>
        </div>

        <!-- Sidebar Overlay for Mobile -->
        <div class="sidebar-overlay" id="sidebarOverlay"></div>

        <!-- Admin Sidebar -->
        <nav class="admin-sidebar" id="adminSidebar">
            <!-- Sidebar Brand -->
            <div class="sidebar-brand">
                <h4>
                    <i class="bi bi-robot brand-icon"></i>
                    Hirebot Admin
                </h4>
            </div>

            <!-- Sidebar Navigation -->
            <div class="sidebar-nav">
                <!-- Main Navigation -->
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
                        <a href="AdminReports.aspx" class="sidebar-nav-link">
                            <i class="bi bi-graph-up"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsNav %>" />
                        </a>
                    </div>
                    <div class="sidebar-nav-item">
                        <a href="AdminLogs.aspx" class="sidebar-nav-link active">
                            <i class="bi bi-journal-text"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LogManagement %>" />
                        </a>
                    </div>
                </div>

            </div>

            <!-- Sidebar Footer -->
            <div class="sidebar-footer">
                <!-- User Info -->
                <div class="sidebar-user-info">
                    <div class="user-avatar">
                        <i class="bi bi-person-fill"></i>
                    </div>
                    <div class="user-details">
                        <h6><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Administrator %>" /></h6>
                        <small><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SystemAdmin %>" /></small>
                    </div>
                </div>

                <!-- Language Selector -->
                <div class="sidebar-language-selector">
                    <uc:LanguageSelector ID="ucLanguageSelector" runat="server" />
                </div>

                <!-- Sign Out Button -->
                <asp:LinkButton ID="btnSignOut" runat="server" CssClass="sidebar-nav-link" OnClick="btnSignOut_Click">
                    <i class="bi bi-box-arrow-right"></i>
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SignOut %>" />
                </asp:LinkButton>
            </div>
        </nav>

        <div class="main-content">
            <!-- Alert will be positioned in bottom right corner -->
            <div id="alertContainer" class="position-fixed" style="bottom: 20px; right: 20px; z-index: 1050; max-width: 400px;">
                <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none alert-dismissible fade show" role="alert"></asp:Label>
            </div>

            <div class="row mb-4">
                <div class="col-12">
                    <h1 class="mb-4">
                        <i class="bi bi-file-text-fill me-2"></i>
                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LogManagement %>" />
                    </h1>
                </div>
            </div>

            <!-- Statistics Cards -->
            <div class="row section-spacing">
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="card stats-card h-100 py-2">
                        <div class="card-body">
                            <div class="row no-gutters align-items-center">
                                <div class="col mr-2">
                                    <div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TotalLogs %>" /></div>
                                    <div class="h5 mb-0 font-weight-bold text-gray-800">
                                        <asp:Literal ID="litTotalLogs" runat="server" Text="0" />
                                    </div>
                                </div>
                                <div class="col-auto">
                                    <i class="bi bi-file-earmark-text fa-2x text-gray-300"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="card stats-card h-100 py-2">
                        <div class="card-body">
                            <div class="row no-gutters align-items-center">
                                <div class="col mr-2">
                                    <div class="text-xs font-weight-bold text-success text-uppercase mb-1"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TodaysLogs %>" /></div>
                                    <div class="h5 mb-0 font-weight-bold text-gray-800">
                                        <asp:Literal ID="litTodaysLogs" runat="server" Text="0" />
                                    </div>
                                </div>
                                <div class="col-auto">
                                    <i class="bi bi-calendar-day fa-2x text-gray-300"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="card stats-card h-100 py-2">
                        <div class="card-body">
                            <div class="row no-gutters align-items-center">
                                <div class="col mr-2">
                                    <div class="text-xs font-weight-bold text-warning text-uppercase mb-1"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ErrorLogs %>" /></div>
                                    <div class="h5 mb-0 font-weight-bold text-gray-800">
                                        <asp:Literal ID="litErrorLogs" runat="server" Text="0" />
                                    </div>
                                </div>
                                <div class="col-auto">
                                    <i class="bi bi-exclamation-triangle fa-2x text-gray-300"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="card stats-card h-100 py-2">
                        <div class="card-body">
                            <div class="row no-gutters align-items-center">
                                <div class="col mr-2">
                                    <div class="text-xs font-weight-bold text-info text-uppercase mb-1"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LoginLogs %>" /></div>
                                    <div class="h5 mb-0 font-weight-bold text-gray-800">
                                        <asp:Literal ID="litLoginLogs" runat="server" Text="0" />
                                    </div>
                                </div>
                                <div class="col-auto">
                                    <i class="bi bi-box-arrow-in-right fa-2x text-gray-300"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Filters Section -->
            <div class="row section-spacing">
                <div class="col-12">
                    <div class="filter-section p-4 shadow-sm">
                        <h5 class="mb-3">
                            <i class="bi bi-funnel me-2"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Filters %>" />
                        </h5>
                        
                        <div class="row">
                            <div class="col-md-3 mb-3">
                                <label for="ddlLogTypeFilter" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LogType %>" /></label>
                                <asp:DropDownList ID="ddlLogTypeFilter" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="" Text="<%$ Resources:GlobalResources,AllTypes %>" />
                                    <asp:ListItem Value="LOGIN" Text="<%$ Resources:GlobalResources,Login %>" />
                                    <asp:ListItem Value="LOGOUT" Text="<%$ Resources:GlobalResources,Logout %>" />
                                    <asp:ListItem Value="REGISTER" Text="<%$ Resources:GlobalResources,Register %>" />
                                    <asp:ListItem Value="ERROR" Text="<%$ Resources:GlobalResources,Error %>" />
                                    <asp:ListItem Value="ACCESS" Text="<%$ Resources:GlobalResources,Access %>" />
                                    <asp:ListItem Value="UPDATE" Text="<%$ Resources:GlobalResources,Update %>" />
                                    <asp:ListItem Value="DELETE" Text="<%$ Resources:GlobalResources,Delete %>" />
                                    <asp:ListItem Value="CREATE" Text="<%$ Resources:GlobalResources,Create %>" />
                                    <asp:ListItem Value="SYSTEM" Text="<%$ Resources:GlobalResources,System %>" />
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-3 mb-3">
                                <label for="ddlUserFilter" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,User %>" /></label>
                                <asp:DropDownList ID="ddlUserFilter" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="" Text="<%$ Resources:GlobalResources,AllUsers %>" />
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-3 mb-3">
                                <label for="txtStartDate" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,StartDate %>" /></label>
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            </div>

                            <div class="col-md-3 mb-3">
                                <label for="txtEndDate" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,EndDate %>" /></label>
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="txtDescriptionFilter" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Description %>" /></label>
                                <asp:TextBox ID="txtDescriptionFilter" runat="server" CssClass="form-control" placeholder="<%$ Resources:GlobalResources,SearchInDescription %>"></asp:TextBox>
                            </div>

                            <div class="col-md-3 mb-3">
                                <label for="ddlDateRange" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,QuickDateRange %>" /></label>
                                <asp:DropDownList ID="ddlDateRange" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlDateRange_SelectedIndexChanged">
                                    <asp:ListItem Value="" Text="<%$ Resources:GlobalResources,CustomRange %>" />
                                    <asp:ListItem Value="today" Text="<%$ Resources:GlobalResources,Today %>" />
                                    <asp:ListItem Value="yesterday" Text="<%$ Resources:GlobalResources,Yesterday %>" />
                                    <asp:ListItem Value="week" Text="<%$ Resources:GlobalResources,ThisWeek %>" />
                                    <asp:ListItem Value="month" Text="<%$ Resources:GlobalResources,ThisMonth %>" />
                                    <asp:ListItem Value="7days" Text="<%$ Resources:GlobalResources,Last7Days %>" />
                                    <asp:ListItem Value="30days" Text="<%$ Resources:GlobalResources,Last30Days %>" />
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-3 mb-3 d-flex align-items-end">
                                <div class="w-100">
                                    <asp:Button ID="btnApplyFilters" runat="server" CssClass="btn btn-primary me-2" Text="<%$ Resources:GlobalResources,ApplyFilters %>" OnClick="btnApplyFilters_Click" />
                                    <asp:Button ID="btnClearFilters" runat="server" CssClass="btn btn-secondary" Text="<%$ Resources:GlobalResources,Clear %>" OnClick="btnClearFilters_Click" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Export Section -->
            <div class="row section-spacing">
                <div class="col-12">
                    <div class="d-flex justify-content-between align-items-center">
                        <h5>
                            <i class="bi bi-table me-2"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LogRecords %>" />
                        </h5>
                        <div>
                            <asp:Button ID="btnExportCsv" runat="server" CssClass="btn btn-success me-2" Text="<%$ Resources:GlobalResources,ExportCSV %>" OnClick="btnExportCsv_Click" />
                            <asp:Button ID="btnRefresh" runat="server" CssClass="btn btn-outline-primary" Text="<%$ Resources:GlobalResources,Refresh %>" OnClick="btnRefresh_Click" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Logs Table -->
            <div class="row">
                <div class="col-12">
                    <div class="admin-section p-0 shadow-sm">
                        <asp:GridView ID="gvLogs" runat="server" CssClass="table table-striped table-hover mb-0" 
                                      AutoGenerateColumns="false" AllowPaging="true" PageSize="10" 
                                      OnPageIndexChanging="gvLogs_PageIndexChanging"
                                      OnRowCreated="gvLogs_RowCreated"
                                      PagerStyle-CssClass="custom-pagination-template"
                                      PagerSettings-Mode="NumericFirstLast" 
                                      PagerSettings-FirstPageText="&lsaquo; Previous"
                                      PagerSettings-LastPageText="Next &rsaquo;"
                                      PagerSettings-PageButtonCount="5"
                                      PagerSettings-Position="Bottom">
                            <Columns>
                                <asp:BoundField DataField="Id" HeaderText="<%$ Resources:GlobalResources,ID %>" ItemStyle-Width="80px" />
                                
                                <asp:TemplateField HeaderText="<%$ Resources:GlobalResources,LogType %>" ItemStyle-Width="120px">
                                    <ItemTemplate>
                                        <span class='badge log-type-badge log-<%# Eval("LogType").ToString().ToLower() %>'>
                                            <%# Eval("LogType") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                
                                <asp:TemplateField HeaderText="<%$ Resources:GlobalResources,User %>" ItemStyle-Width="180px">
                                    <ItemTemplate>
                                        <%# GetUserDisplayName(Eval("UserId")) %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                
                                <asp:BoundField DataField="Description" HeaderText="<%$ Resources:GlobalResources,Description %>" />
                                
                                <asp:TemplateField HeaderText="<%$ Resources:GlobalResources,CreatedAt %>" ItemStyle-Width="180px">
                                    <ItemTemplate>
                                        <span title='<%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm:ss}") %>'>
                                            <%# Eval("CreatedAt", "{0:MM/dd HH:mm}") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            
                            
                            <EmptyDataTemplate>
                                <div class="text-center p-4">
                                    <i class="bi bi-inbox display-1 text-muted"></i>
                                    <h5 class="mt-3 text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NoLogsFound %>" /></h5>
                                    <p class="text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NoLogsFoundMessage %>" /></p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                // Sidebar toggle functionality
                const sidebarToggle = document.getElementById('sidebarToggle');
                const adminSidebar = document.getElementById('adminSidebar');
                const sidebarOverlay = document.getElementById('sidebarOverlay');
                
                // Toggle sidebar on mobile
                function toggleSidebar() {
                    adminSidebar.classList.toggle('show');
                    sidebarOverlay.classList.toggle('show');
                }
                
                // Close sidebar when clicking overlay
                function closeSidebar() {
                    adminSidebar.classList.remove('show');
                    sidebarOverlay.classList.remove('show');
                }
                
                // Event listeners
                if (sidebarToggle) {
                    sidebarToggle.addEventListener('click', toggleSidebar);
                }
                
                if (sidebarOverlay) {
                    sidebarOverlay.addEventListener('click', closeSidebar);
                }
                
                // Close sidebar on window resize if desktop
                window.addEventListener('resize', function() {
                    if (window.innerWidth > 768) {
                        closeSidebar();
                    }
                });
                
                // Handle active navigation state
                const currentPage = window.location.pathname.toLowerCase();
                const navLinks = document.querySelectorAll('.sidebar-nav-link');
                
                navLinks.forEach(function(link) {
                    const href = link.getAttribute('href');
                    if (href && currentPage.includes(href.toLowerCase())) {
                        // Remove active class from all links
                        navLinks.forEach(function(l) {
                            l.classList.remove('active');
                        });
                        // Add active class to current link
                        link.classList.add('active');
                    }
                });
                
                // Auto-hide alerts after 5 seconds
                const alert = document.querySelector('.alert:not(.d-none)');
                if (alert) {
                    setTimeout(function() {
                        alert.classList.add('fade');
                        setTimeout(function() {
                            alert.style.display = 'none';
                        }, 150);
                    }, 5000);
                }
            });
        </script>
    </form>
</body>
</html>