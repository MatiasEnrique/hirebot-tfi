<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChatbotAdmin.aspx.cs" Inherits="Hirebot_TFI.ChatbotAdmin" %>
<%@ Register Src="~/Controls/LanguageSelector.ascx" TagPrefix="uc" TagName="LanguageSelector" %>
<%@ Register Src="~/Controls/ToastNotification.ascx" TagPrefix="uc" TagName="ToastNotification" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ChatbotAdmin %>" /> - Hirebot</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    
    <!-- Color Picker CSS -->
    <style>
        :root {
            --eerie-black: #222222;
            --ultra-violet: #4b4e6d;
            --tiffany-blue: #84dcc6;
            --cadet-gray: #95a3b3;
            --sidebar-width: 280px;
        }

        /* Admin Sidebar Styles - Same as AdminDashboard */
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

        /* Chatbot Admin Specific Styles */
        .chatbot-admin-container {
            background: transparent;
            min-height: auto;
            padding: 0;
        }

        .admin-header {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            border-radius: 15px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 0.25rem 1rem rgba(0, 0, 0, 0.15);
        }

        .admin-header h1 {
            margin: 0;
            font-weight: 600;
            font-size: 2rem;
        }

        .admin-header p {
            margin: 0.5rem 0 0 0;
            opacity: 0.9;
            font-size: 1.1rem;
        }

        /* Filter Panel Styles */
        .filter-panel {
            background: white;
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 0.15rem 1rem rgba(0, 0, 0, 0.1);
        }

        .filter-panel h5 {
            color: var(--ultra-violet);
            font-weight: 600;
            margin-bottom: 1rem;
        }

        /* Chatbots Container Styles */
        .data-grid-container {
            background: transparent;
            border-radius: 0;
            padding: 0;
            box-shadow: none;
        }

        /* Chatbot Color Indicator */
        .chatbot-color-indicator {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 0.5rem;
            border: 2px solid white;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        /* Simple Button Overrides for Chatbot Cards */
        .chatbot-footer .btn-group .btn {
            border-radius: 6px;
            font-size: 0.85rem;
            padding: 0.375rem 0.75rem;
        }

        /* Modal Styles */
        .modal-content {
            border-radius: 15px;
            border: none;
            box-shadow: 0 0.5rem 2rem rgba(0, 0, 0, 0.3);
        }

        .modal-header {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            border-radius: 15px 15px 0 0;
            border: none;
        }

        .modal-header h5 {
            font-weight: 600;
        }

        .modal-header .btn-close {
            filter: brightness(0) invert(1);
        }

        .modal-body {
            padding: 2rem;
        }

        /* Form Styles */
        .form-label {
            color: var(--ultra-violet);
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .form-control, .form-select {
            border-radius: 10px;
            border: 2px solid rgba(132, 220, 198, 0.2);
            padding: 0.75rem;
            transition: all 0.3s ease;
        }

        .form-control:focus, .form-select:focus {
            border-color: var(--tiffany-blue);
            box-shadow: 0 0 0 0.2rem rgba(132, 220, 198, 0.25);
        }

        /* Color Picker Styles */
        .color-picker-container {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .color-preview {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            border: 2px solid #dee2e6;
            cursor: pointer;
            transition: transform 0.2s ease;
        }

        .color-preview:hover {
            transform: scale(1.1);
        }

        .color-input {
            width: 60px;
            height: 40px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
        }

        /* Chatbot Card Styles */
        .chatbot-card {
            background: white;
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 0.15rem 1rem rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }

        .chatbot-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 0.25rem 1.5rem rgba(0, 0, 0, 0.15);
        }

        .chatbot-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
        }

        .chatbot-header h4 {
            color: var(--ultra-violet);
            font-weight: 600;
            margin: 0;
        }

        .chatbot-body {
            margin-bottom: 1rem;
        }

        .chatbot-stats {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 1rem;
        }

        .stat-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--cadet-gray);
            font-size: 0.9rem;
        }

        .stat-item i {
            color: var(--ultra-violet);
            width: 16px;
        }

        .chatbot-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 1rem;
            border-top: 1px solid rgba(0, 0, 0, 0.1);
        }

        /* Status Badge Styles */
        .status-active {
            background: linear-gradient(135deg, var(--tiffany-blue), #5cb85c);
            color: white;
        }

        .status-inactive {
            background: linear-gradient(135deg, var(--cadet-gray), #6c757d);
            color: white;
        }

        .organization-badge {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            font-size: 0.8rem;
            padding: 0.25rem 0.75rem;
            border-radius: 12px;
        }

        .unassigned-badge {
            background: linear-gradient(135deg, var(--cadet-gray), #adb5bd);
            color: white;
            font-size: 0.8rem;
            padding: 0.25rem 0.75rem;
            border-radius: 12px;
        }

        /* Instructions Tooltip */
        .instructions-preview {
            max-width: 300px;
            cursor: pointer;
        }

        /* Loading Overlay */
        .loading-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(255, 255, 255, 0.8);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            border-radius: 15px;
        }

        .loading-spinner {
            width: 3rem;
            height: 3rem;
            border: 0.3rem solid var(--tiffany-blue);
            border-top: 0.3rem solid transparent;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
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

            .admin-header {
                padding: 1.5rem;
            }

            .admin-header h1 {
                font-size: 1.5rem;
            }

            .filter-panel {
                padding: 1rem;
                margin-bottom: 1rem;
            }

            .chatbot-card {
                padding: 1rem;
                margin-bottom: 1rem;
            }

            .chatbot-stats {
                flex-direction: column;
                gap: 0.5rem;
            }

            .chatbot-footer {
                flex-direction: column;
                gap: 1rem;
                align-items: flex-start;
            }

            .chatbot-footer .btn-group {
                width: 100%;
                display: flex;
                justify-content: space-between;
            }

            .chatbot-footer .btn-group .btn {
                flex: 1;
                margin: 0 0.125rem;
                font-size: 0.8rem;
                padding: 0.5rem;
            }

            .modal-body {
                padding: 1rem;
            }
        }

        @media (max-width: 576px) {
            .main-content {
                padding: 4rem 0.75rem 1rem;
            }

            .admin-header {
                padding: 1rem;
                margin-bottom: 1rem;
            }

            .admin-header h1 {
                font-size: 1.3rem;
            }

            .admin-header p {
                font-size: 1rem;
            }

            .color-picker-container {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.5rem;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" />
        
        <!-- Toast Notification Control -->
        <uc:ToastNotification ID="ucToastNotification" runat="server" />

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
                        <a href="ChatbotAdmin.aspx" class="sidebar-nav-link active">
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
                        <a href="AdminLogs.aspx" class="sidebar-nav-link">
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
                <asp:LinkButton ID="btnLogout" runat="server" CssClass="sidebar-nav-link" OnClick="btnLogout_Click">
                    <i class="bi bi-box-arrow-right"></i>
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SignOut %>" />
                </asp:LinkButton>
            </div>
        </nav>

        <!-- Main Content -->
        <div class="main-content">
            <div class="chatbot-admin-container">
                <div class="container-fluid">
            <!-- Admin Header -->
            <div class="admin-header">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h1>
                            <i class="bi bi-robot me-3"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ChatbotAdmin %>" />
                        </h1>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ChatbotManagementDescription %>" /></p>
                    </div>
                    <div>
                        <button type="button" class="btn btn-success btn-lg" data-bs-toggle="modal" data-bs-target="#chatbotModal" onclick="openCreateModal()">
                            <i class="bi bi-plus-circle me-2"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CreateChatbot %>" />
                        </button>
                    </div>
                </div>
            </div>

            <!-- Filter Panel -->
            <div class="filter-panel">
                <h5>
                    <i class="bi bi-funnel me-2"></i>
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Filters %>" />
                </h5>
                
                <asp:UpdatePanel ID="upFilters" runat="server">
                    <ContentTemplate>
                        <div class="row g-3 align-items-end">
                            <div class="col-md-4">
                                <label for="<%= ddlOrganizationFilter.ClientID %>" class="form-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Organization %>" />
                                </label>
                                <asp:DropDownList ID="ddlOrganizationFilter" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlOrganizationFilter_SelectedIndexChanged">
                                    <asp:ListItem Value="" Text="<%$ Resources:GlobalResources,AllOrganizations %>" />
                                    <asp:ListItem Value="-1" Text="<%$ Resources:GlobalResources,UnassignedChatbots %>" />
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-3">
                                <label for="<%= ddlStatusFilter.ClientID %>" class="form-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Status %>" />
                                </label>
                                <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                                    <asp:ListItem Value="" Text="<%$ Resources:GlobalResources,AllStatuses %>" />
                                    <asp:ListItem Value="true" Text="<%$ Resources:GlobalResources,Active %>" />
                                    <asp:ListItem Value="false" Text="<%$ Resources:GlobalResources,Inactive %>" />
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-4">
                                <label for="<%= txtSearchFilter.ClientID %>" class="form-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Search %>" />
                                </label>
                                <div class="input-group">
                                    <asp:TextBox ID="txtSearchFilter" runat="server" CssClass="form-control" placeholder="<%$ Resources:GlobalResources,SearchChatbots %>" onkeyup="handleSearchKeyUp(event);" />
                                    <asp:Button ID="btnSearch" runat="server" Text="<%$ Resources:GlobalResources,Search %>" CssClass="btn btn-primary" OnClick="btnSearch_Click" />
                                </div>
                            </div>
                            <div class="col-md-1">
                                <label class="form-label">&nbsp;</label>
                                <asp:Button ID="btnClearSearch" runat="server" Text="<%$ Resources:GlobalResources,Clear %>" CssClass="btn btn-secondary w-100" OnClick="btnClearSearch_Click" />
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>

            <!-- Chatbots List Container -->
            <div class="data-grid-container position-relative">
                <asp:UpdatePanel ID="upDataGrid" runat="server">
                    <ContentTemplate>
                        <!-- Loading Overlay -->
                        <div id="loadingOverlay" class="loading-overlay d-none">
                            <div class="loading-spinner"></div>
                        </div>

                        <!-- Chatbots List -->
                        <asp:Repeater ID="rptChatbots" runat="server" OnItemCommand="rptChatbots_ItemCommand" OnItemDataBound="rptChatbots_ItemDataBound">
                            <ItemTemplate>
                                <div class="chatbot-card">
                                    <div class="chatbot-header">
                                        <div class="d-flex align-items-center">
                                            <div class="chatbot-color-indicator me-2" style='background-color: <%# Eval("Color") %>;'></div>
                                            <div>
                                                <h4 class="mb-1"><%# HttpUtility.HtmlEncode(Convert.ToString(Eval("Name"))) %></h4>
                                                <small class="opacity-75">
                                                    <i class="bi bi-robot me-1"></i>
                                                    ID: <%# Eval("ChatbotId") %>
                                                </small>
                                            </div>
                                        </div>
                                        <div class="text-end">
                                            <asp:Label ID="lblStatus" runat="server" CssClass="badge fs-6" />
                                        </div>
                                    </div>
                                    <div class="chatbot-body">
                                        <p class="text-muted mb-3">
                                            <i class="bi bi-file-text me-2"></i>
                                            <%# TruncateText(Convert.ToString(Eval("Instructions")), 120) %>
                                        </p>
                                        <div class="chatbot-stats">
                                            <div class="stat-item">
                                                <i class="bi bi-building"></i>
                                                <asp:Label ID="lblOrganization" runat="server" />
                                            </div>
                                            <div class="stat-item">
                                                <i class="bi bi-calendar-plus"></i>
                                                <span><%# Convert.ToDateTime(Eval("CreatedDate")).ToString("MMM dd, yyyy") %></span>
                                            </div>
                                            <div class="stat-item">
                                                <i class="bi bi-palette"></i>
                                                <span><%# Eval("Color") %></span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="chatbot-footer">
                                        <div class="btn-group" role="group">
                                            <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-outline-secondary btn-sm" 
                                                CommandName="Edit" CommandArgument='<%# Eval("ChatbotId") %>'>
                                                <i class="bi bi-pencil me-1"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Edit %>" />
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn btn-outline-danger btn-sm" 
                                                CommandName="Delete" CommandArgument='<%# Eval("ChatbotId") %>' 
                                                OnClientClick='<%# "return confirm(\u0027" + HttpContext.GetGlobalResourceObject("GlobalResources", "ConfirmDeleteChatbot") + "\u0027);" %>'>
                                                <i class="bi bi-trash me-1"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Delete %>" />
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnAssignUnassign" runat="server" CssClass="btn btn-outline-primary btn-sm"
                                                CommandName="ToggleAssignment" CommandArgument='<%# Eval("ChatbotId") %>' />
                                        </div>
                                        <small class="text-muted">
                                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CreatedDate %>" />: <%# Convert.ToDateTime(Eval("CreatedDate")).ToString("dd/MM/yyyy HH:mm") %>
                                        </small>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <!-- No Chatbots Message -->
                        <asp:Panel ID="pnlNoChatbots" runat="server" Visible="false" CssClass="text-center py-5">
                            <div class="mb-4">
                                <i class="bi bi-robot display-1 text-muted"></i>
                            </div>
                            <h3 class="text-muted mb-3">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NoChatbotsFound %>" />
                            </h3>
                            <p class="text-muted mb-4">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CreateFirstChatbot %>" />
                            </p>
                            <button type="button" class="btn btn-success btn-lg" data-bs-toggle="modal" data-bs-target="#chatbotModal" onclick="openCreateModal()">
                                <i class="bi bi-plus-circle me-2"></i>
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CreateChatbot %>" />
                            </button>
                        </asp:Panel>

                        <!-- Pagination -->
                        <nav aria-label="Chatbot pagination" class="mt-4">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <asp:Label ID="lblPaginationInfo" runat="server" CssClass="text-muted" />
                                </div>
                                <ul class="pagination mb-0">
                                    <asp:Repeater ID="rptPagination" runat="server" OnItemCommand="rptPagination_ItemCommand">
                                        <ItemTemplate>
                                            <li class="page-item <%# GetPaginationItemClass(Container.DataItem) %>">
                                                <asp:LinkButton ID="lnkPage" runat="server" 
                                                    CssClass="page-link" 
                                                    CommandName="Page" 
                                                    CommandArgument='<%# GetPaginationValue(Container.DataItem) %>'
                                                    Text='<%# GetPaginationText(Container.DataItem) %>' />
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ul>
                            </div>
                        </nav>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>

    <!-- Chatbot Modal -->
    <div class="modal fade" id="chatbotModal" tabindex="-1" aria-labelledby="chatbotModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <asp:UpdatePanel ID="upModal" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div class="modal-header">
                            <h5 class="modal-title" id="chatbotModalLabel">
                                <i class="bi bi-robot me-2"></i>
                                <asp:Label ID="lblModalTitle" runat="server" Text="<%$ Resources:GlobalResources,CreateChatbot %>" />
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row">
                                <div class="col-12">
                                    <div class="mb-3">
                                        <label for="<%= txtChatbotName.ClientID %>" class="form-label">
                                            <i class="bi bi-robot me-1"></i>
                                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ChatbotName %>" />
                                            <span class="text-danger">*</span>
                                        </label>
                                        <asp:TextBox ID="txtChatbotName" runat="server" CssClass="form-control" MaxLength="100" />
                                        <asp:RequiredFieldValidator ID="rfvChatbotName" runat="server" 
                                            ControlToValidate="txtChatbotName"
                                            ErrorMessage="<%$ Resources:GlobalResources,ChatbotNameRequired %>"
                                            CssClass="text-danger small"
                                            Display="Dynamic" 
                                            ValidationGroup="ChatbotModal" />
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-12">
                                    <div class="mb-3">
                                        <label for="<%= txtInstructions.ClientID %>" class="form-label">
                                            <i class="bi bi-file-text me-1"></i>
                                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ChatbotInstructions %>" />
                                            <span class="text-danger">*</span>
                                        </label>
                                        <asp:TextBox ID="txtInstructions" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control" />
                                        <asp:RequiredFieldValidator ID="rfvInstructions" runat="server" 
                                            ControlToValidate="txtInstructions"
                                            ErrorMessage="<%$ Resources:GlobalResources,ChatbotInstructionsRequired %>"
                                            CssClass="text-danger small"
                                            Display="Dynamic" 
                                            ValidationGroup="ChatbotModal" />
                                        <div class="form-text">
                                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ChatbotInstructionsHelp %>" />
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="colorInput" class="form-label">
                                            <i class="bi bi-palette me-1"></i>
                                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ChatbotColor %>" />
                                        </label>
                                        <div class="color-picker-container">
                                            <div id="colorPreview" class="color-preview" onclick="document.getElementById('colorInput').click();" style="background-color: #222222;"></div>
                                            <input type="color" id="colorInput" class="color-input" value="#222222" onchange="updateColorPreview(this.value);" />
                                            <asp:HiddenField ID="hfSelectedColor" runat="server" Value="#222222" />
                                            <div class="flex-grow-1">
                                                <asp:TextBox ID="txtColorHex" runat="server" CssClass="form-control" placeholder="#222222" MaxLength="7" Text="#222222" />
                                                <div class="form-text">
                                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ColorHexFormat %>" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="<%= ddlOrganization.ClientID %>" class="form-label">
                                            <i class="bi bi-building me-1"></i>
                                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Organization %>" />
                                        </label>
                                        <asp:DropDownList ID="ddlOrganization" runat="server" CssClass="form-select">
                                            <asp:ListItem Value="" Text="<%$ Resources:GlobalResources,UnassignedChatbot %>" />
                                        </asp:DropDownList>
                                        <div class="form-text">
                                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationAssignmentHelp %>" />
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <asp:HiddenField ID="hfChatbotId" runat="server" Value="0" />
                            <asp:HiddenField ID="hfModalMode" runat="server" Value="create" />
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <i class="bi bi-x-circle me-1"></i>
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Cancel %>" />
                            </button>
                            <asp:Button ID="btnSaveChatbot" runat="server" 
                                Text="<%$ Resources:GlobalResources,Save %>" 
                                CssClass="btn btn-primary" 
                                OnClick="btnSaveChatbot_Click" 
                                ValidationGroup="ChatbotModal" />
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>

    <!-- Assign Organization Modal -->
    <div class="modal fade" id="assignModal" tabindex="-1" aria-labelledby="assignModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="assignModalLabel">
                        <i class="bi bi-building-gear me-2"></i>
                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AssignToOrganization %>" />
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:UpdatePanel ID="upAssignModal" runat="server">
                        <ContentTemplate>
                            <div class="mb-3">
                                <label for="<%= ddlAssignOrganization.ClientID %>" class="form-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SelectOrganization %>" />
                                </label>
                                <asp:DropDownList ID="ddlAssignOrganization" runat="server" CssClass="form-select" />
                            </div>
                            <asp:HiddenField ID="hfAssignChatbotId" runat="server" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>
                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Cancel %>" />
                    </button>
                    <asp:UpdatePanel ID="upAssignFooter" runat="server">
                        <ContentTemplate>
                            <asp:Button ID="btnConfirmAssign" runat="server" 
                                Text="<%$ Resources:GlobalResources,Assign %>" 
                                CssClass="btn btn-primary" 
                                OnClick="btnConfirmAssign_Click" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Page initialization
        document.addEventListener('DOMContentLoaded', function() {
            initializeTooltips();
            initializeColorPicker();
            initializeModals();
            initializeSearchHandlers();
        });

        // Initialize Bootstrap tooltips
        function initializeTooltips() {
            try {
                const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
                tooltipTriggerList.map(function (tooltipTriggerEl) {
                    return new bootstrap.Tooltip(tooltipTriggerEl);
                });
            } catch (error) {
            }
        }

        // Initialize color picker functionality
        function initializeColorPicker() {
            try {
                const colorInput = document.getElementById('colorInput');
                const txtColorHex = document.getElementById('<%= txtColorHex.ClientID %>');
                const hfSelectedColor = document.getElementById('<%= hfSelectedColor.ClientID %>');

                if (colorInput && txtColorHex) {
                    // Sync color input with text input
                    colorInput.addEventListener('change', function() {
                        updateColorPreview(this.value);
                        txtColorHex.value = this.value;
                        if (hfSelectedColor) hfSelectedColor.value = this.value;
                    });

                    // Sync text input with color input
                    txtColorHex.addEventListener('blur', function() {
                        const hexValue = validateHexColor(this.value);
                        if (hexValue) {
                            colorInput.value = hexValue;
                            updateColorPreview(hexValue);
                            if (hfSelectedColor) hfSelectedColor.value = hexValue;
                        }
                    });
                }
            } catch (error) {
            }
        }

        // Initialize modal functionality
        function initializeModals() {
            try {
                // Reset form when modal is closed
                const chatbotModal = document.getElementById('chatbotModal');
                if (chatbotModal) {
                    chatbotModal.addEventListener('hidden.bs.modal', function() {
                        resetChatbotForm();
                    });
                }
            } catch (error) {
            }
        }

        // Update color preview
        function updateColorPreview(color) {
            try {
                const colorPreview = document.getElementById('colorPreview');
                if (colorPreview) {
                    colorPreview.style.backgroundColor = color;
                }
            } catch (error) {
            }
        }

        // Validate hex color format
        function validateHexColor(hex) {
            const hexRegex = /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/;
            if (hexRegex.test(hex)) {
                // Expand 3-digit hex to 6-digit
                if (hex.length === 4) {
                    return '#' + hex[1] + hex[1] + hex[2] + hex[2] + hex[3] + hex[3];
                }
                return hex;
            }
            return null;
        }

        // Open create modal
        function openCreateModal() {
            try {
                resetChatbotForm();
                
                // Set modal title
                const modalTitle = document.getElementById('modalTitle');
                if (modalTitle) {
                    modalTitle.textContent = '<%= GetGlobalResourceObject("GlobalResources", "CreateChatbot") %>';
                }

                // Set hidden fields
                const hfChatbotId = document.getElementById('<%= hfChatbotId.ClientID %>');
                const hfModalMode = document.getElementById('<%= hfModalMode.ClientID %>');
                if (hfChatbotId) hfChatbotId.value = '0';
                if (hfModalMode) hfModalMode.value = 'create';

                // Update save button text
                executeAfterUpdate(function() {
                    const btnSave = document.getElementById('<%= btnSaveChatbot.ClientID %>');
                    if (btnSave) {
                        btnSave.innerText = '<%= GetGlobalResourceObject("GlobalResources", "Create") %>' || 'Create';
                    }
                }, 0);

            } catch (error) {
            }
        }

        // Show chatbot modal (matching OrganizationAdmin pattern)
        function showChatbotModal() {
            try {
                const modalElement = document.getElementById('chatbotModal');
                
                if (!modalElement) {
                    return;
                }
                
                const modal = new bootstrap.Modal(modalElement);
                modal.show();
            } catch (error) {
            }
        }
        
        // Hide chatbot modal (matching OrganizationAdmin pattern)
        function hideChatbotModal() {
            try {
                const modal = bootstrap.Modal.getInstance(document.getElementById('chatbotModal'));
                if (modal) {
                    modal.hide();
                }
            } catch (error) {
            }
        }

        // Open assign modal
        function openAssignModal(chatbotId) {
            try {

                const hfAssignChatbotId = document.getElementById('<%= hfAssignChatbotId.ClientID %>');
                if (hfAssignChatbotId) {
                    hfAssignChatbotId.value = chatbotId;
                }

                const modal = new bootstrap.Modal(document.getElementById('assignModal'));
                modal.show();

            } catch (error) {
            }
        }

        // Reset chatbot form
        function resetChatbotForm() {
            try {
                // Reset all form fields using delayed execution for UpdatePanel compatibility
                executeAfterUpdate(function() {
                    const txtChatbotName = document.getElementById('<%= txtChatbotName.ClientID %>');
                    const txtInstructions = document.getElementById('<%= txtInstructions.ClientID %>');
                    const colorInput = document.getElementById('colorInput');
                    const txtColorHex = document.getElementById('<%= txtColorHex.ClientID %>');
                    const ddlOrganization = document.getElementById('<%= ddlOrganization.ClientID %>');
                    const hfSelectedColor = document.getElementById('<%= hfSelectedColor.ClientID %>');

                    if (txtChatbotName) txtChatbotName.value = '';
                    if (txtInstructions) txtInstructions.value = '';
                    if (colorInput) colorInput.value = '#222222';
                    if (txtColorHex) txtColorHex.value = '#222222';
                    if (ddlOrganization) ddlOrganization.value = '';
                    if (hfSelectedColor) hfSelectedColor.value = '#222222';

                    updateColorPreview('#222222');
                }, 0);
            } catch (error) {
            }
        }

        // Confirm delete
        function confirmDelete() {
            try {
                return confirm('<%= GetGlobalResourceObject("GlobalResources", "ConfirmDeleteChatbot") %>');
            } catch (error) {
                return confirm('Are you sure you want to delete this chatbot?');
            }
        }

        // Confirm unassign
        function confirmUnassign() {
            try {
                return confirm('<%= GetGlobalResourceObject("GlobalResources", "ConfirmUnassignChatbot") %>');
            } catch (error) {
                return confirm('Are you sure you want to unassign this chatbot?');
            }
        }

        // Show loading overlay
        function showLoading() {
            try {
                const overlay = document.getElementById('loadingOverlay');
                if (overlay) {
                    overlay.classList.remove('d-none');
                }
            } catch (error) {
            }
        }

        // Hide loading overlay
        function hideLoading() {
            try {
                const overlay = document.getElementById('loadingOverlay');
                if (overlay) {
                    overlay.classList.add('d-none');
                }
            } catch (error) {
            }
        }

        // Delayed execution pattern for UpdatePanel compatibility
        function executeAfterUpdate(callback, attempts = 0) {
            const maxAttempts = 10;
            if (attempts < maxAttempts) {
                setTimeout(() => {
                    try {
                        callback();
                    } catch (error) {
                        if (attempts < maxAttempts - 1) {
                            executeAfterUpdate(callback, attempts + 1);
                        } else {
                        }
                    }
                }, 100);
            }
        }

        // Show toast notification
        function showChatbotToast(message, type, duration) {
            try {
                if (typeof HirebotToast !== 'undefined') {
                    HirebotToast.show(message, type, duration);
                } else if (typeof showToast !== 'undefined') {
                    showToast(message, type, duration);
                } else {
                    alert(message);
                }
            } catch (error) {
                alert(message);
            }
        }

        // UpdatePanel refresh handler (matching OrganizationAdmin pattern)
        function pageLoad(sender, args) {
            if (args && args.get_isPartialLoad()) {
                
                // Re-initialize components after partial postback
                executeAfterUpdate(function() {
                    initializeTooltips();
                    initializeColorPicker();
                    initializeSearchHandlers();
                }, 0);
            }
        }
        
        // Add page load handler for partial postbacks
        if (typeof(Sys) !== 'undefined') {
            Sys.Application.add_load(pageLoad);
        }

        // Handle UpdatePanel events
        Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(function() {
            showLoading();
        });

        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
            hideLoading();
        });

        // Handle search functionality
        function handleSearchKeyUp(event) {
            try {
                // Clear any existing timeout
                if (window.searchTimeout) {
                    clearTimeout(window.searchTimeout);
                }

                // Handle Enter key press
                if (event.keyCode === 13) {
                    triggerSearch();
                    return;
                }

                // Trigger search after user stops typing (500ms delay)
                window.searchTimeout = setTimeout(function() {
                    triggerSearch();
                }, 500);
            } catch (error) {
                // Error handling for search functionality
            }
        }

        // Trigger search functionality
        function triggerSearch() {
            try {
                const btnSearch = document.getElementById('<%= btnSearch.ClientID %>');
                if (btnSearch) {
                    btnSearch.click();
                }
            } catch (error) {
            }
        }

        // Initialize search event handlers
        function initializeSearchHandlers() {
            try {
                const txtSearch = document.getElementById('<%= txtSearchFilter.ClientID %>');
                if (txtSearch) {
                    // Remove any existing event listeners to avoid duplicates
                    txtSearch.onkeyup = function(event) { handleSearchKeyUp(event); };
                }
            } catch (error) {
            }
        }

        // Edit button is now handled directly by the ItemCommand pattern with simple modal display

        // Sidebar toggle functionality (same as AdminDashboard)
        document.addEventListener('DOMContentLoaded', function() {
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
        });
    </script>
                </div>
            </div>
        </div>
    </form>
</body>
</html>