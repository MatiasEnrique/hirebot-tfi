<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminCatalog.aspx.cs" Inherits="UI.AdminCatalog" %>
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
        .nav-tabs .nav-link { color: var(--ultra-violet); }
        .nav-tabs .nav-link.active { background-color: var(--ultra-violet); border-color: var(--ultra-violet); color: white; }
        .nav-tabs .nav-link:hover { color: var(--tiffany-blue); }
        .tab-pane { min-height: 400px; }
        .form-label { font-weight: 600; color: var(--eerie-black); }
        .table thead th { background-color: var(--ultra-violet); color: white; }
        .table tbody tr:hover { background-color: rgba(132, 220, 198, 0.1); }
        
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
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfDeleteMessage" runat="server" />
        <asp:HiddenField ID="hfSelectedProductId" runat="server" Value="0" />
        <asp:HiddenField ID="hfSelectedCatalogId" runat="server" Value="0" />
        
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
                        <a href="AdminCatalog.aspx" class="sidebar-nav-link active">
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
                <asp:LinkButton ID="btnSignOut" runat="server" CssClass="sidebar-nav-link" OnClick="btnSignOut_Click">
                    <i class="bi bi-box-arrow-right"></i>
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SignOut %>" />
                </asp:LinkButton>
            </div>
        </nav>

        <div class="main-content">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-12">
                        <h1 class="mb-4">
                            <i class="bi bi-gear-fill me-2"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminPanel %>" />
                        </h1>
                    
                    <!-- Alert will be positioned in bottom right corner -->
                    <div id="alertContainer" class="position-fixed" style="bottom: 20px; right: 20px; z-index: 1050; max-width: 400px;">
                        <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none alert-dismissible fade show" role="alert"></asp:Label>
                    </div>
                </div>
            </div>

            <!-- Navigation tabs -->
            <ul class="nav nav-tabs mb-4" id="adminTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="products-tab" data-bs-toggle="tab" data-bs-target="#products-pane" type="button" role="tab">
                        <i class="bi bi-box-seam me-2"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ProductManagement %>" />
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="catalogs-tab" data-bs-toggle="tab" data-bs-target="#catalogs-pane" type="button" role="tab">
                        <i class="bi bi-collection me-2"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CatalogManagement %>" />
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="catalog-products-tab" data-bs-toggle="tab" data-bs-target="#catalog-products-pane" type="button" role="tab">
                        <i class="bi bi-plus-circle me-2"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AddProductToCatalog %>" />
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="display-catalog-tab" data-bs-toggle="tab" data-bs-target="#display-catalog-pane" type="button" role="tab">
                        <i class="bi bi-eye me-2"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,DisplayCatalogManagement %>" />
                    </button>
                </li>
            </ul>

            <div class="tab-content" id="adminTabContent">
                <!-- Products Tab -->
                <div class="tab-pane fade show active" id="products-pane" role="tabpanel">
                    <div class="admin-section p-4 mb-4">
                        <h3 class="mb-3">
                            <i class="bi bi-box-seam me-2"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ProductManagement %>" />
                        </h3>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="txtProductName" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ProductName %>" /></label>
                                <asp:TextBox ID="txtProductName" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <label for="ddlProductCategory" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Category %>" /></label>
                                <asp:DropDownList ID="ddlProductCategory" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="Basic">Basic</asp:ListItem>
                                    <asp:ListItem Value="Professional">Professional</asp:ListItem>
                                    <asp:ListItem Value="Enterprise">Enterprise</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="txtProductDescription" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Description %>" /></label>
                            <asp:TextBox ID="txtProductDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-4">
                                <label for="txtProductPrice" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Price %>" /></label>
                                <asp:TextBox ID="txtProductPrice" runat="server" CssClass="form-control" TextMode="Number" step="0.01"></asp:TextBox>
                            </div>
                            <div class="col-md-4">
                                <label for="ddlBillingCycle" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,BillingCycle %>" /></label>
                                <asp:DropDownList ID="ddlBillingCycle" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="Monthly">Monthly</asp:ListItem>
                                    <asp:ListItem Value="Yearly">Yearly</asp:ListItem>
                                    <asp:ListItem Value="One-time">One-time</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-4">
                                <label for="txtMaxChatbots" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,MaxChatbots %>" /></label>
                                <asp:TextBox ID="txtMaxChatbots" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="txtMaxMessages" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,MaxMessages %>" /></label>
                                <asp:TextBox ID="txtMaxMessages" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <label for="txtFeatures" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Features %>" /></label>
                                <asp:TextBox ID="txtFeatures" runat="server" CssClass="form-control" placeholder='{"ai_model": "GPT-4", "analytics": true}'></asp:TextBox>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <asp:CheckBox ID="chkProductIsActive" runat="server" CssClass="form-check-input me-2" />
                            <label for="chkProductIsActive" class="form-check-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,IsActive %>" /></label>
                        </div>
                        
                        <div class="mb-3">
                            <asp:Button ID="btnCreateProduct" runat="server" CssClass="btn btn-success me-2" Text="<%$ Resources:GlobalResources,CreateProduct %>" OnClick="btnCreateProduct_Click" />
                            <asp:Button ID="btnUpdateProduct" runat="server" CssClass="btn btn-primary me-2" Text="<%$ Resources:GlobalResources,UpdateProduct %>" OnClick="btnUpdateProduct_Click" />
                            <asp:Button ID="btnCancelEditProduct" runat="server" CssClass="btn btn-secondary" Text="<%$ Resources:GlobalResources,CancelEdit %>" OnClick="btnCancelEditProduct_Click" Visible="false" />
                        </div>
                        
                        <asp:GridView ID="gvProducts" runat="server" CssClass="table table-striped table-hover" AutoGenerateColumns="false" OnRowCommand="gvProducts_RowCommand">
                            <Columns>
                                <asp:BoundField DataField="ProductId" HeaderText="ID" />
                                <asp:BoundField DataField="Name" HeaderText="<%$ Resources:GlobalResources,ProductName %>" />
                                <asp:BoundField DataField="Category" HeaderText="<%$ Resources:GlobalResources,Category %>" />
                                <asp:BoundField DataField="Price" HeaderText="<%$ Resources:GlobalResources,Price %>" DataFormatString="ARS {0:N2}" />
                                <asp:BoundField DataField="BillingCycle" HeaderText="<%$ Resources:GlobalResources,BillingCycle %>" />
                                <asp:BoundField DataField="MaxChatbots" HeaderText="<%$ Resources:GlobalResources,MaxChatbots %>" />
                                <asp:BoundField DataField="MaxMessagesPerMonth" HeaderText="<%$ Resources:GlobalResources,MaxMessages %>" />
                                <asp:CheckBoxField DataField="IsActive" HeaderText="<%$ Resources:GlobalResources,IsActive %>" />
                                <asp:TemplateField HeaderText="<%$ Resources:GlobalResources,Actions %>">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-sm btn-outline-primary me-1" CommandName="EditProduct" CommandArgument='<%# Eval("ProductId") %>'>
                                            <i class="bi bi-pencil"></i>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn btn-sm btn-danger delete-btn" CommandName="DeleteProduct" CommandArgument='<%# Eval("ProductId") %>' data-product-name='<%# Eval("Name") %>'>
                                            <i class="bi bi-trash"></i>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>

                <!-- Catalogs Tab -->
                <div class="tab-pane fade" id="catalogs-pane" role="tabpanel">
                    <div class="admin-section p-4 mb-4">
                        <h3 class="mb-3">
                            <i class="bi bi-collection me-2"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CatalogManagement %>" />
                        </h3>
                        
                        <div class="mb-3">
                            <label for="txtCatalogName" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CatalogName %>" /></label>
                            <asp:TextBox ID="txtCatalogName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        
                        <div class="mb-3">
                            <label for="txtCatalogDescription" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Description %>" /></label>
                            <asp:TextBox ID="txtCatalogDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                        </div>
                        
                        <div class="mb-3">
                            <asp:CheckBox ID="chkCatalogIsActive" runat="server" CssClass="form-check-input me-2" />
                            <label for="chkCatalogIsActive" class="form-check-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,IsActive %>" /></label>
                        </div>
                        
                        <div class="mb-3">
                            <asp:Button ID="btnCreateCatalog" runat="server" CssClass="btn btn-success me-2" Text="<%$ Resources:GlobalResources,CreateCatalog %>" OnClick="btnCreateCatalog_Click" />
                            <asp:Button ID="btnUpdateCatalog" runat="server" CssClass="btn btn-primary me-2" Text="<%$ Resources:GlobalResources,UpdateCatalog %>" OnClick="btnUpdateCatalog_Click" />
                            <asp:Button ID="btnDeleteCatalog" runat="server" CssClass="btn btn-danger me-2" Text="<%$ Resources:GlobalResources,DeleteCatalog %>" OnClick="btnDeleteCatalog_Click" />
                            <asp:Button ID="btnCancelEditCatalog" runat="server" CssClass="btn btn-secondary" Text="<%$ Resources:GlobalResources,CancelEdit %>" OnClick="btnCancelEditCatalog_Click" Visible="false" />
                        </div>
                        
                        <asp:GridView ID="gvCatalogs" runat="server" CssClass="table table-striped table-hover" AutoGenerateColumns="false" OnRowCommand="gvCatalogs_RowCommand">
                            <Columns>
                                <asp:BoundField DataField="CatalogId" HeaderText="ID" />
                                <asp:BoundField DataField="Name" HeaderText="<%$ Resources:GlobalResources,CatalogName %>" />
                                <asp:CheckBoxField DataField="IsActive" HeaderText="<%$ Resources:GlobalResources,IsActive %>" />
                                <asp:TemplateField HeaderText="<%$ Resources:GlobalResources,Actions %>">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-sm btn-outline-primary me-1" CommandName="EditCatalog" CommandArgument='<%# Eval("CatalogId") %>'>
                                            <i class="bi bi-pencil"></i>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>

                <!-- Display Catalog Management Tab -->
                <div class="tab-pane fade" id="display-catalog-pane" role="tabpanel">
                    <div class="admin-section p-4 mb-4">
                        <h3 class="mb-3">
                            <i class="bi bi-eye me-2"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,DisplayCatalogManagement %>" />
                        </h3>
                        
                        <div class="row align-items-end">
                            <div class="col-md-6">
                                <label for="ddlDisplayedCatalog" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SelectCatalogToDisplay %>" /></label>
                                <asp:DropDownList ID="ddlDisplayedCatalog" runat="server" CssClass="form-select"></asp:DropDownList>
                                <small class="text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,DisplayedCatalogHint %>" /></small>
                            </div>
                            <div class="col-md-3">
                                <asp:Button ID="btnSetDisplayedCatalog" runat="server" CssClass="btn btn-success w-100" Text="<%$ Resources:GlobalResources,SetDisplayedCatalog %>" OnClick="btnSetDisplayedCatalog_Click" />
                            </div>
                            <div class="col-md-3">
                                <div class="card bg-light">
                                    <div class="card-body text-center p-2">
                                        <small class="text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CurrentlyDisplayed %>" /></small>
                                        <div class="fw-bold"><asp:Literal ID="litCurrentDisplayedCatalog" runat="server" Text="-"></asp:Literal></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Catalog Products Tab -->
                <div class="tab-pane fade" id="catalog-products-pane" role="tabpanel">
                    <div class="admin-section p-4 mb-4">
                        <h3 class="mb-3">
                            <i class="bi bi-plus-circle me-2"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AddProductToCatalog %>" />
                        </h3>
                        
                        <div class="row mb-3">
                            <div class="col-md-5">
                                <label for="ddlCatalogSelect" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SelectCatalog %>" /></label>
                                <asp:DropDownList ID="ddlCatalogSelect" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                            <div class="col-md-5">
                                <label for="ddlProductSelect" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SelectProduct %>" /></label>
                                <asp:DropDownList ID="ddlProductSelect" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                            <div class="col-md-2 d-flex align-items-end">
                                <asp:Button ID="btnAddProductToCatalog" runat="server" CssClass="btn btn-success w-100" Text="<%$ Resources:GlobalResources,Add %>" OnClick="btnAddProductToCatalog_Click" />
                            </div>
                        </div>
                        
                        <asp:GridView ID="gvCatalogProducts" runat="server" CssClass="table table-striped table-hover" AutoGenerateColumns="false" OnRowCommand="gvCatalogProducts_RowCommand">
                            <Columns>
                                <asp:BoundField DataField="CatalogName" HeaderText="<%$ Resources:GlobalResources,CatalogName %>" />
                                <asp:BoundField DataField="ProductName" HeaderText="<%$ Resources:GlobalResources,ProductName %>" />
                                <asp:BoundField DataField="Category" HeaderText="<%$ Resources:GlobalResources,Category %>" />
                                <asp:BoundField DataField="Price" HeaderText="<%$ Resources:GlobalResources,Price %>" DataFormatString="ARS {0:N2}" />
                                <asp:TemplateField HeaderText="<%$ Resources:GlobalResources,Actions %>">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnRemove" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="RemoveFromCatalog" CommandArgument='<%# Eval("CatalogId") + "," + Eval("ProductId") %>'>
                                            <i class="bi bi-trash"></i>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>

        <!-- Delete Confirmation Modal -->
        <div class="modal fade" id="deleteModal" tabindex="-1" role="dialog" aria-labelledby="deleteModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="deleteModalLabel">
                            <i class="bi bi-exclamation-triangle text-warning me-2"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ConfirmAction %>" />
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="d-flex align-items-center">
                            <i class="bi bi-trash text-danger me-3" style="font-size: 2rem;"></i>
                            <div>
                                <p class="mb-1" id="deleteMessage"></p>
                                <small class="text-muted">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ActionCannotBeUndone %>" />
                                </small>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle me-1"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Cancel %>" />
                        </button>
                        <button type="button" class="btn btn-danger" id="confirmDeleteBtn">
                            <i class="bi bi-trash me-1"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Delete %>" />
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            let pendingDeleteButton = null;
            let isDeleteConfirmed = false;
            
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
                
                // Handle delete button clicks
                document.addEventListener('click', function(e) {
                    if (e.target.closest('.delete-btn')) {
                        const deleteBtn = e.target.closest('.delete-btn');
                        
                        // If already confirmed, allow the postback
                        if (isDeleteConfirmed && pendingDeleteButton === deleteBtn) {
                            isDeleteConfirmed = false;
                            pendingDeleteButton = null;
                            return true;
                        }
                        
                        // Prevent the postback and show modal
                        e.preventDefault();
                        e.stopPropagation();
                        
                        const productName = deleteBtn.getAttribute('data-product-name');
                        const messageTemplate = document.getElementById('<%= hfDeleteMessage.ClientID %>').value;
                        const message = messageTemplate.replace('{0}', productName);
                        
                        // Set the message in the modal
                        document.getElementById('deleteMessage').textContent = message;
                        
                        // Store the button for later execution
                        pendingDeleteButton = deleteBtn;
                        
                        // Show the modal
                        const deleteModal = new bootstrap.Modal(document.getElementById('deleteModal'));
                        deleteModal.show();
                        
                        return false;
                    }
                });
                
                // Handle the confirm delete button click
                document.getElementById('confirmDeleteBtn').addEventListener('click', function() {
                    if (pendingDeleteButton) {
                        // Hide the modal
                        const deleteModal = bootstrap.Modal.getInstance(document.getElementById('deleteModal'));
                        deleteModal.hide();
                        
                        // Set flag to allow the next click
                        isDeleteConfirmed = true;
                        
                        // Trigger the delete button click again (this time it will be allowed)
                        pendingDeleteButton.click();
                    }
                });
            });
        </script>
    </form>
</body>
</html>