<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="Hirebot_TFI.AdminDashboard" %>
<%@ Register Src="~/Controls/LanguageSelector.ascx" TagPrefix="uc" TagName="LanguageSelector" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminPanel %>" /> - Hirebot</title>
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
        
        /* Dashboard Cards */
        .dashboard-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 0.5rem 2rem 0 rgba(58, 59, 69, 0.25);
        }
        .dashboard-icon {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            color: white;
            margin: 0 auto 1rem;
        }
        .icon-catalog { background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue)); }
        .icon-logs { background: linear-gradient(135deg, var(--cadet-gray), var(--ultra-violet)); }
        .icon-users { background: linear-gradient(135deg, var(--tiffany-blue), var(--cadet-gray)); }
        
        .welcome-header {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            border-radius: 10px;
            padding: 2rem;
            margin-bottom: 2rem;
            text-align: center;
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
            
            .welcome-header {
                padding: 1.5rem;
            }
        }
        
        @media (max-width: 576px) {
            .main-content {
                padding: 4rem 0.75rem 1rem;
            }
            
            .dashboard-card {
                margin-bottom: 1rem;
            }
            
            .welcome-header {
                padding: 1.25rem;
                font-size: 0.9rem;
            }
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
                        <a href="AdminDashboard.aspx" class="sidebar-nav-link active">
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
            <!-- Welcome Header -->
            <div class="welcome-header">
                <h1 class="mb-3">
                    <i class="bi bi-shield-check me-3"></i>
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,WelcomeAdmin %>" />
                </h1>
                <p class="mb-0 fs-5">
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminDashboardDescription %>" />
                </p>
            </div>

            <!-- Dashboard Cards -->
            <div class="row g-4">
                <!-- Catalog Management Card -->
                <div class="col-md-4">
                    <div class="dashboard-card p-4 h-100 text-center">
                        <div class="dashboard-icon icon-catalog">
                            <i class="bi bi-box-seam"></i>
                        </div>
                        <h4 class="mb-3"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CatalogManagement %>" /></h4>
                        <p class="text-muted mb-4">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CatalogManagementDescription %>" />
                        </p>
                        <a href="AdminCatalog.aspx" class="btn btn-primary">
                            <i class="bi bi-arrow-right me-1"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ManageCatalog %>" />
                        </a>
                    </div>
                </div>

                <!-- Log Management Card -->
                <div class="col-md-4">
                    <div class="dashboard-card p-4 h-100 text-center">
                        <div class="dashboard-icon icon-logs">
                            <i class="bi bi-journal-text"></i>
                        </div>
                        <h4 class="mb-3"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LogManagement %>" /></h4>
                        <p class="text-muted mb-4">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LogManagementDescription %>" />
                        </p>
                        <a href="AdminLogs.aspx" class="btn btn-primary">
                            <i class="bi bi-arrow-right me-1"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ViewLogs %>" />
                        </a>
                    </div>
                </div>

                <!-- System Overview Card -->
                <div class="col-md-4">
                    <div class="dashboard-card p-4 h-100 text-center">
                        <div class="dashboard-icon icon-users">
                            <i class="bi bi-people"></i>
                        </div>
                        <h4 class="mb-3"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SystemOverview %>" /></h4>
                        <p class="text-muted mb-4">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SystemOverviewDescription %>" />
                        </p>
                        <div class="row text-start">
                            <div class="col-6">
                                <div class="d-flex align-items-center mb-2">
                                    <i class="bi bi-people-fill text-primary me-2"></i>
                                    <span class="small">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TotalUsers %>" />: 
                                        <strong><asp:Label ID="lblTotalUsers" runat="server" /></strong>
                                    </span>
                                </div>
                                <div class="d-flex align-items-center">
                                    <i class="bi bi-box-seam text-success me-2"></i>
                                    <span class="small">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TotalProducts %>" />: 
                                        <strong><asp:Label ID="lblTotalProducts" runat="server" /></strong>
                                    </span>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex align-items-center mb-2">
                                    <i class="bi bi-journal-text text-warning me-2"></i>
                                    <span class="small">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TotalLogs %>" />: 
                                        <strong><asp:Label ID="lblTotalLogs" runat="server" /></strong>
                                    </span>
                                </div>
                                <div class="d-flex align-items-center">
                                    <i class="bi bi-calendar text-info me-2"></i>
                                    <span class="small">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LastLogin %>" />: 
                                        <strong><asp:Label ID="lblLastLogin" runat="server" /></strong>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
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
</body>
</html>