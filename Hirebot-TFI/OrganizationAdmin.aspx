<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OrganizationAdmin.aspx.cs" Inherits="Hirebot_TFI.OrganizationAdmin" %>
<%@ Register Src="~/Controls/LanguageSelector.ascx" TagPrefix="uc" TagName="LanguageSelector" %>
<%@ Register Src="~/Controls/ToastNotification.ascx" TagPrefix="uc" TagName="ToastNotification" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationAdmin %>" /> - Hirebot</title>
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
        
        /* Button Styles */
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
        
        /* Organization Cards */
        .organization-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            margin-bottom: 1.5rem;
        }
        
        .organization-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 0.5rem 2rem 0 rgba(58, 59, 69, 0.25);
        }
        
        .organization-header {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            border-radius: 15px 15px 0 0;
            padding: 1.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .organization-body {
            padding: 1.5rem;
        }
        
        .organization-footer {
            padding: 1rem 1.5rem;
            border-top: 1px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 15px 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .organization-stats {
            display: flex;
            gap: 2rem;
            margin-top: 1rem;
        }
        
        .stat-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--cadet-gray);
        }
        
        .stat-item i {
            color: var(--ultra-violet);
        }
        
        .welcome-header {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            border-radius: 10px;
            padding: 2rem;
            margin-bottom: 2rem;
            text-align: center;
        }
        
        .search-filter-section {
            background: white;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
        }
        
        .pagination-wrapper {
            display: flex;
            justify-content: center;
            margin-top: 2rem;
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
        
        /* Modal Styles */
        .modal-header {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            border-bottom: none;
        }
        
        .modal-header .btn-close {
            filter: brightness(0) invert(1);
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
            
            .welcome-header {
                padding: 1.5rem;
            }
            
            .organization-stats {
                flex-direction: column;
                gap: 1rem;
            }
        }
        
        @media (max-width: 576px) {
            .main-content {
                padding: 4rem 0.75rem 1rem;
            }
            
            .organization-card {
                margin-bottom: 1rem;
            }
            
            .welcome-header {
                padding: 1.25rem;
                font-size: 0.9rem;
            }
            
            .organization-header {
                padding: 1rem;
            }
            
            .organization-body {
                padding: 1rem;
            }
            
            .organization-footer {
                padding: 0.75rem 1rem;
                flex-direction: column;
                gap: 1rem;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" />
        
        <!-- Mobile Header -->
        <div class="mobile-header">
            <button class="mobile-toggle-btn" id="sidebarToggle" type="button">
                <i class="bi bi-list"></i>
            </button>
            <h5 class="mobile-brand">
                <i class="bi bi-building me-2"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationAdmin %>" />
            </h5>
        </div>

        <!-- Sidebar Overlay for Mobile -->
        <div class="sidebar-overlay" id="sidebarOverlay"></div>

        <!-- Admin Sidebar -->
        <nav class="admin-sidebar" id="adminSidebar">
            <!-- Sidebar Brand -->
            <div class="sidebar-brand">
                <h4>
                    <i class="bi bi-building brand-icon"></i>
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationAdmin %>" />
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
                        <a href="OrganizationAdmin.aspx" class="sidebar-nav-link active">
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
            <asp:UpdatePanel ID="upMain" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <!-- Toast Notification Control -->
                    <uc:ToastNotification ID="ucToastNotification" runat="server" />

                    <!-- Welcome Header -->
                    <div class="welcome-header">
                        <h1 class="mb-3">
                            <i class="bi bi-building-gear me-3"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationAdmin %>" />
                        </h1>
                        <p class="mb-0 fs-5">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ManageAllOrganizations %>" />
                        </p>
                    </div>

                    <!-- Search and Filter Section -->
                    <div class="search-filter-section">
                        <div class="row g-3 align-items-end">
                            <div class="col-md-4">
                                <label for="txtSearch" class="form-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Search %>" />
                                </label>
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" 
                                    placeholder="<%$ Resources:GlobalResources,SearchOrganizations %>" />
                            </div>
                            <div class="col-md-2">
                                <label for="ddlPageSize" class="form-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PageSize %>" />
                                </label>
                                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
                                    <asp:ListItem Value="10">10</asp:ListItem>
                                    <asp:ListItem Value="25">25</asp:ListItem>
                                    <asp:ListItem Value="50">50</asp:ListItem>
                                    <asp:ListItem Value="100">100</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-3">
                                <label for="ddlSortBy" class="form-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SortBy %>" />
                                </label>
                                <asp:DropDownList ID="ddlSortBy" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSortBy_SelectedIndexChanged">
                                    <asp:ListItem Value="Name" Text="<%$ Resources:GlobalResources,OrganizationName %>"></asp:ListItem>
                                    <asp:ListItem Value="CreatedDate" Text="<%$ Resources:GlobalResources,CreatedDate %>"></asp:ListItem>
                                    <asp:ListItem Value="MemberCount" Text="<%$ Resources:GlobalResources,MemberCount %>"></asp:ListItem>
                                    <asp:ListItem Value="OwnerUsername" Text="<%$ Resources:GlobalResources,Owner %>"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-3">
                                <asp:Button ID="btnSearch" runat="server" Text="<%$ Resources:GlobalResources,Search %>" 
                                    CssClass="btn btn-primary me-2" OnClick="btnSearch_Click" />
                                <asp:Button ID="btnCreateNew" runat="server" Text="<%$ Resources:GlobalResources,CreateOrganization %>" 
                                    CssClass="btn btn-success" OnClick="btnCreateNew_Click" />
                            </div>
                        </div>
                    </div>

                    <!-- Organizations List -->
                    <asp:Repeater ID="rptOrganizations" runat="server" OnItemCommand="rptOrganizations_ItemCommand">
                        <ItemTemplate>
                            <div class="organization-card">
                                <div class="organization-header">
                                    <div>
                                        <h4 class="mb-1"><%# Eval("Name") %></h4>
                                        <small class="opacity-75">
                                            <i class="bi bi-link-45deg me-1"></i>
                                            <%# Eval("Slug") %>
                                        </small>
                                    </div>
                                    <div class="text-end">
                                        <span class="badge bg-light text-dark fs-6">
                                            <i class="bi bi-people me-1"></i>
                                            <%# Eval("MemberCount") ?? 0 %> <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Members %>" />
                                        </span>
                                    </div>
                                </div>
                                <div class="organization-body">
                                    <p class="text-muted mb-3">
                                        <%# !string.IsNullOrEmpty(Eval("Description")?.ToString()) ? Eval("Description") : HttpContext.GetGlobalResourceObject("GlobalResources", "NoDescription") %>
                                    </p>
                                    <div class="organization-stats">
                                        <div class="stat-item">
                                            <i class="bi bi-person-check"></i>
                                            <span><strong><%# Eval("OwnerUsername") %></strong></span>
                                        </div>
                                        <div class="stat-item">
                                            <i class="bi bi-calendar-plus"></i>
                                            <span><%# ((DateTime)Eval("CreatedDate")).ToString("MMM dd, yyyy") %></span>
                                        </div>
                                        <div class="stat-item">
                                            <i class="bi bi-circle-fill <%# (bool)Eval("IsActive") ? "text-success" : "text-danger" %>"></i>
                                            <span><%# (bool)Eval("IsActive") ? HttpContext.GetGlobalResourceObject("GlobalResources", "Active") : HttpContext.GetGlobalResourceObject("GlobalResources", "Inactive") %></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="organization-footer">
                                    <div class="btn-group" role="group">
                                        <asp:LinkButton ID="btnView" runat="server" CssClass="btn btn-outline-primary btn-sm" 
                                            CommandName="View" CommandArgument='<%# Eval("Id") %>'>
                                            <i class="bi bi-eye me-1"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,View %>" />
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-outline-secondary btn-sm" 
                                            CommandName="Edit" CommandArgument='<%# Eval("Id") %>'>
                                            <i class="bi bi-pencil me-1"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Edit %>" />
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn btn-outline-danger btn-sm" 
                                            CommandName="Delete" CommandArgument='<%# Eval("Id") %>' 
                                            OnClientClick='<%# "return confirm(\u0027" + HttpContext.GetGlobalResourceObject("GlobalResources", "ConfirmDeleteOrganization") + "\u0027);" %>'>
                                            <i class="bi bi-trash me-1"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Delete %>" />
                                        </asp:LinkButton>
                                    </div>
                                    <small class="text-muted">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ID %>" />: <%# Eval("Id") %>
                                    </small>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <!-- No Organizations Message -->
                    <asp:Panel ID="pnlNoOrganizations" runat="server" Visible="false" CssClass="text-center py-5">
                        <div class="mb-4">
                            <i class="bi bi-building display-1 text-muted"></i>
                        </div>
                        <h3 class="text-muted mb-3">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NoOrganizations %>" />
                        </h3>
                        <p class="text-muted mb-4">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CreateFirstOrganization %>" />
                        </p>
                        <asp:Button ID="btnCreateFirst" runat="server" Text="<%$ Resources:GlobalResources,CreateOrganization %>" 
                            CssClass="btn btn-success btn-lg" OnClick="btnCreateNew_Click" />
                    </asp:Panel>

                    <!-- Pagination -->
                    <div class="pagination-wrapper" id="divPagination" runat="server">
                        <nav>
                            <ul class="pagination pagination-lg">
                                <li class="page-item" id="liPrevious" runat="server">
                                    <asp:LinkButton ID="lnkPrevious" runat="server" CssClass="page-link" OnClick="lnkPrevious_Click">
                                        <i class="bi bi-chevron-left"></i>
                                    </asp:LinkButton>
                                </li>
                                <asp:Repeater ID="rptPagination" runat="server" OnItemCommand="rptPagination_ItemCommand">
                                    <ItemTemplate>
                                        <li class="page-item <%# (int)Eval("PageNumber") == Convert.ToInt32(ViewState["CurrentPage"] ?? 1) ? "active" : "" %>">
                                            <asp:LinkButton ID="lnkPage" runat="server" CssClass="page-link" 
                                                CommandName="Page" CommandArgument='<%# Eval("PageNumber") %>'>
                                                <%# Eval("PageNumber") %>
                                            </asp:LinkButton>
                                        </li>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <li class="page-item" id="liNext" runat="server">
                                    <asp:LinkButton ID="lnkNext" runat="server" CssClass="page-link" OnClick="lnkNext_Click">
                                        <i class="bi bi-chevron-right"></i>
                                    </asp:LinkButton>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>

        <!-- Create/Edit Organization Modal -->
        <div class="modal fade" id="organizationModal" tabindex="-1" aria-labelledby="organizationModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <asp:UpdatePanel ID="upModal" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div class="modal-header">
                                <h5 class="modal-title" id="organizationModalLabel">
                                    <i class="bi bi-building me-2"></i>
                                    <asp:Label ID="lblModalTitle" runat="server" Text="<%$ Resources:GlobalResources,CreateOrganization %>" />
                                </h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <asp:HiddenField ID="hfOrganizationId" runat="server" />
                                
                                <div class="row g-3">
                                    <div class="col-md-8">
                                        <label for="txtModalName" class="form-label">
                                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationName %>" /> *
                                        </label>
                                        <asp:TextBox ID="txtModalName" runat="server" CssClass="form-control" MaxLength="100" 
                                            placeholder="<%$ Resources:GlobalResources,EnterOrganizationName %>" />
                                        <asp:RequiredFieldValidator ID="rfvModalName" runat="server" ControlToValidate="txtModalName" 
                                            ErrorMessage="<%$ Resources:GlobalResources,OrganizationNameRequired %>" 
                                            CssClass="text-danger small" Display="Dynamic" ValidationGroup="OrganizationModal" />
                                    </div>
                                    <div class="col-md-4">
                                        <label for="chkModalActive" class="form-label">
                                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Status %>" />
                                        </label>
                                        <div class="form-check form-switch">
                                            <asp:CheckBox ID="chkModalActive" runat="server" CssClass="form-check-input" Checked="true" />
                                            <label class="form-check-label" for="chkModalActive">
                                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Active %>" />
                                            </label>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="row g-3 mt-1">
                                    <div class="col-md-6">
                                        <label for="txtModalSlug" class="form-label">
                                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationSlug %>" /> *
                                        </label>
                                        <asp:TextBox ID="txtModalSlug" runat="server" CssClass="form-control" MaxLength="50" 
                                            placeholder="<%$ Resources:GlobalResources,EnterOrganizationSlug %>" />
                                        <div class="form-text">
                                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SlugHelpText %>" />
                                        </div>
                                        <asp:RequiredFieldValidator ID="rfvModalSlug" runat="server" ControlToValidate="txtModalSlug" 
                                            ErrorMessage="<%$ Resources:GlobalResources,OrganizationSlugRequired %>" 
                                            CssClass="text-danger small" Display="Dynamic" ValidationGroup="OrganizationModal" />
                                        <asp:RegularExpressionValidator ID="revModalSlug" runat="server" ControlToValidate="txtModalSlug" 
                                            ValidationExpression="^[a-zA-Z0-9\-]+$" 
                                            ErrorMessage="<%$ Resources:GlobalResources,OrganizationSlugInvalid %>" 
                                            CssClass="text-danger small" Display="Dynamic" ValidationGroup="OrganizationModal" />
                                    </div>
                                    <div class="col-md-6">
                                        <label for="ddlModalOwner" class="form-label">
                                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Owner %>" /> *
                                        </label>
                                        <asp:DropDownList ID="ddlModalOwner" runat="server" CssClass="form-select" />
                                        <asp:RequiredFieldValidator ID="rfvModalOwner" runat="server" ControlToValidate="ddlModalOwner" 
                                            InitialValue="" ErrorMessage="<%$ Resources:GlobalResources,OwnerRequired %>" 
                                            CssClass="text-danger small" Display="Dynamic" ValidationGroup="OrganizationModal" />
                                    </div>
                                </div>
                                
                                <div class="mt-3">
                                    <label for="txtModalDescription" class="form-label">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationDescription %>" />
                                    </label>
                                    <asp:TextBox ID="txtModalDescription" runat="server" CssClass="form-control" 
                                        TextMode="MultiLine" Rows="4" MaxLength="500" 
                                        placeholder="<%$ Resources:GlobalResources,EnterOrganizationDescription %>" />
                                    <div class="form-text">
                                        <span id="charCount">0</span>/500 <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Characters %>" />
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Cancel %>" />
                                </button>
                                <asp:Button ID="btnModalSave" runat="server" CssClass="btn btn-primary" 
                                    Text="<%$ Resources:GlobalResources,Save %>" OnClick="btnModalSave_Click" 
                                    ValidationGroup="OrganizationModal" />
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>
    </form>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Sidebar toggle functionality
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
            
            // Character counter for description
            const descTextArea = document.getElementById('<%= txtModalDescription.ClientID %>');
            const charCountSpan = document.getElementById('charCount');
            
            if (descTextArea && charCountSpan) {
                function updateCharCount() {
                    const count = descTextArea.value.length;
                    charCountSpan.textContent = count;
                    
                    if (count > 450) {
                        charCountSpan.style.color = '#dc3545';
                    } else if (count > 400) {
                        charCountSpan.style.color = '#fd7e14';
                    } else {
                        charCountSpan.style.color = '#6c757d';
                    }
                }
                
                descTextArea.addEventListener('input', updateCharCount);
                updateCharCount(); // Initial count
            }
            
            // Slug auto-generation from name
            const nameTextBox = document.getElementById('<%= txtModalName.ClientID %>');
            const slugTextBox = document.getElementById('<%= txtModalSlug.ClientID %>');
            
            if (nameTextBox && slugTextBox) {
                nameTextBox.addEventListener('input', function() {
                    if (slugTextBox.value === '' || slugTextBox.dataset.autoGenerated === 'true') {
                        let slug = this.value.toLowerCase()
                            .replace(/[^a-z0-9\s-]/g, '')
                            .replace(/\s+/g, '-')
                            .replace(/-+/g, '-')
                            .replace(/^-|-$/g, '');
                        slugTextBox.value = slug;
                        slugTextBox.dataset.autoGenerated = 'true';
                    }
                });
                
                slugTextBox.addEventListener('input', function() {
                    this.dataset.autoGenerated = 'false';
                });
            }
        });
        
        // Show organization modal
        function showOrganizationModal() {
            const modal = new bootstrap.Modal(document.getElementById('organizationModal'));
            modal.show();
        }
        
        // Hide organization modal
        function hideOrganizationModal() {
            const modal = bootstrap.Modal.getInstance(document.getElementById('organizationModal'));
            if (modal) {
                modal.hide();
            }
        }
        
        // Legacy toast support - now handled by ToastNotification user control
        // Keep minimal compatibility functions
        window.showToast = function(message, type, duration) {
            if (typeof window.HirebotToast !== 'undefined') {
                window.HirebotToast.show(message, type, duration || 5000);
            }
        };
        
        window.showToastNotification = function(message, type, title) {
            if (typeof window.HirebotToast !== 'undefined') {
                window.HirebotToast.show(message, type, 5000);
            }
        };
        
        // UpdatePanel refresh handler
        function pageLoad(sender, args) {
            if (args.get_isPartialLoad()) {
                
                // Re-initialize components after partial postback
                const descTextArea = document.getElementById('<%= txtModalDescription.ClientID %>');
                const charCountSpan = document.getElementById('charCount');
                
                if (descTextArea && charCountSpan) {
                    function updateCharCount() {
                        const count = descTextArea.value.length;
                        charCountSpan.textContent = count;
                    }
                    
                    descTextArea.addEventListener('input', updateCharCount);
                    updateCharCount();
                }
                
                // Toast container is now managed by the ToastNotification user control
            }
        }
        
        // Add page load handler for partial postbacks
        if (typeof(Sys) !== 'undefined') {
            Sys.Application.add_load(pageLoad);
        }
    </script>
</body>
</html>