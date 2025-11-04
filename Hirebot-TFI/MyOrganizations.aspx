<%@ Page Title="My Organizations - Hirebot-TFI" Language="C#" MasterPageFile="~/Protected.master" AutoEventWireup="true" CodeBehind="MyOrganizations.aspx.cs" Inherits="Hirebot_TFI.MyOrganizations" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Mis Organizaciones" /> - Hirebot-TFI
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .organizations-hero {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            border-radius: 15px;
            padding: 3rem;
            margin-bottom: 2rem;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .organizations-hero::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 20"><defs><radialGradient id="a" cx="50%" cy="50%" r="50%"><stop offset="0%" stop-color="white" stop-opacity="0.1"/><stop offset="100%" stop-color="white" stop-opacity="0"/></radialGradient></defs><circle cx="50" cy="10" r="10" fill="url(%23a)"/></svg>') repeat;
            opacity: 0.1;
        }
        
        .organizations-hero-content {
            position: relative;
            z-index: 1;
        }
        
        .organizations-stats {
            display: flex;
            justify-content: center;
            gap: 3rem;
            margin-top: 2rem;
            flex-wrap: wrap;
        }
        
        .stat-item {
            text-align: center;
        }
        
        .stat-number {
            display: block;
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }
        
        .stat-label {
            font-size: 0.9rem;
            opacity: 0.9;
        }
        
        .organization-section {
            margin-bottom: 3rem;
        }
        
        .section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.5rem;
            padding: 1rem 0;
            border-bottom: 2px solid var(--tiffany-blue);
        }
        
        .section-title {
            color: var(--ultra-violet);
            font-size: 1.5rem;
            font-weight: 600;
            margin: 0;
            display: flex;
            align-items: center;
        }
        
        .section-title i {
            margin-right: 0.75rem;
            color: var(--tiffany-blue);
        }
        
        .organization-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 1.5rem;
        }
        
        .organization-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            overflow: hidden;
            border: 1px solid #e9ecef;
        }
        
        .organization-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 0.75rem 2.5rem 0 rgba(58, 59, 69, 0.3);
        }
        
        .organization-card.owner {
            border-left: 5px solid var(--tiffany-blue);
        }
        
        .organization-card.admin {
            border-left: 5px solid var(--ultra-violet);
        }
        
        .organization-card.member {
            border-left: 5px solid var(--cadet-gray);
        }
        
        .organization-header {
            background: linear-gradient(135deg, var(--eerie-black), var(--ultra-violet));
            color: white;
            padding: 1.5rem;
            position: relative;
        }
        
        .organization-header.owner {
            background: linear-gradient(135deg, var(--tiffany-blue), var(--cadet-gray));
            color: var(--eerie-black);
        }
        
        .organization-header.admin {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
        }
        
        .organization-header.member {
            background: linear-gradient(135deg, var(--cadet-gray), var(--ultra-violet));
        }
        
        .role-badge {
            position: absolute;
            top: 1rem;
            right: 1rem;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 15px;
            font-size: 0.75rem;
            font-weight: 500;
            backdrop-filter: blur(10px);
        }
        
        .organization-header.owner .role-badge {
            background: rgba(34, 34, 34, 0.3);
        }
        
        .organization-title {
            font-size: 1.25rem;
            font-weight: 600;
            margin: 0 0 0.5rem 0;
            padding-right: 100px;
        }
        
        .organization-slug {
            font-size: 0.9rem;
            opacity: 0.8;
            font-family: 'Courier New', monospace;
        }
        
        .organization-body {
            padding: 1.5rem;
        }
        
        .organization-description {
            color: var(--cadet-gray);
            margin-bottom: 1rem;
            font-size: 0.95rem;
            line-height: 1.5;
        }
        
        .organization-stats {
            display: flex;
            justify-content: space-between;
            margin-bottom: 1.5rem;
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
        }
        
        .organization-footer {
            padding: 1rem 1.5rem;
            border-top: 1px solid #e9ecef;
            background: #f8f9fa;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .action-buttons {
            display: flex;
            gap: 0.5rem;
        }
        
        .btn-sm {
            padding: 0.375rem 0.75rem;
            font-size: 0.875rem;
            border-radius: 0.375rem;
        }
        
        .no-organizations {
            text-align: center;
            padding: 4rem 2rem;
            background: white;
            border-radius: 15px;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            margin: 2rem 0;
        }
        
        .no-organizations-icon {
            font-size: 4rem;
            color: var(--cadet-gray);
            margin-bottom: 1.5rem;
        }
        
        .no-organizations h3 {
            color: var(--ultra-violet);
            margin-bottom: 1rem;
        }
        
        .no-organizations p {
            color: var(--cadet-gray);
            margin-bottom: 2rem;
        }
        
        .quick-create-section {
            background: white;
            border-radius: 15px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
        }
        
        .quick-actions {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        /* Mobile Responsive */
        @media (max-width: 768px) {
            .organizations-hero {
                padding: 2rem 1.5rem;
            }
            
            .organizations-stats {
                gap: 2rem;
            }
            
            .organization-grid {
                grid-template-columns: 1fr;
                gap: 1rem;
            }
            
            .section-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
            }
            
            .organization-stats {
                flex-direction: column;
                gap: 0.5rem;
            }
            
            .organization-footer {
                flex-direction: column;
                gap: 1rem;
                align-items: stretch;
            }
            
            .action-buttons {
                justify-content: center;
            }
            
            .quick-actions {
                flex-direction: column;
            }
        }
        
        @media (max-width: 576px) {
            .organizations-hero {
                padding: 1.5rem 1rem;
            }
            
            .organization-header {
                padding: 1rem;
            }
            
            .organization-body {
                padding: 1rem;
            }
            
            .organization-title {
                font-size: 1.1rem;
                padding-right: 80px;
            }
            
            .role-badge {
                font-size: 0.7rem;
                padding: 0.2rem 0.5rem;
                right: 0.75rem;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="NavigationContent" runat="server">
    <li class="nav-item">
        <a class="nav-link" href="Catalog.aspx"><asp:Literal runat="server" Text="Catálogo" /></a>
    </li>
    <li class="nav-item">
        <a class="nav-link active" href="MyOrganizations.aspx"><asp:Literal runat="server" Text="Mis Organizaciones" /></a>
    </li>
    <asp:Panel ID="pnlAdminNavigation" runat="server" Visible="false">
        <li class="nav-item">
            <a class="nav-link" href="OrganizationAdmin.aspx"><asp:Literal runat="server" Text="Administrador de Organización" /></a>
        </li>
    </asp:Panel>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel ID="upMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <!-- Alert Messages -->
            <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert" role="alert">
                <asp:Label ID="lblAlert" runat="server"></asp:Label>
            </asp:Panel>

            <!-- Organizations Hero Section -->
            <div class="organizations-hero">
                <div class="organizations-hero-content">
                    <h1 class="mb-3">
                        <i class="bi bi-building-check me-3"></i>
                        <asp:Literal runat="server" Text="Panel de Mis Organizaciones" />
                    </h1>
                    <p class="mb-0 fs-5">
                        <asp:Literal runat="server" Text="Gestiona todas las organizaciones en las que participas" />
                    </p>
                    
                    <div class="organizations-stats">
                        <div class="stat-item">
                            <span class="stat-number"><asp:Label ID="lblOwnedCount" runat="server">0</asp:Label></span>
                            <span class="stat-label"><asp:Literal runat="server" Text="Organizaciones que Posees" /></span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-number"><asp:Label ID="lblManagedCount" runat="server">0</asp:Label></span>
                            <span class="stat-label"><asp:Literal runat="server" Text="Organizaciones que Administras" /></span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-number"><asp:Label ID="lblMemberCount" runat="server">0</asp:Label></span>
                            <span class="stat-label"><asp:Literal runat="server" Text="Organizaciones de las que Eres Miembro" /></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions Section -->
            <div class="quick-create-section">
                <h4 class="text-center mb-3">
                    <i class="bi bi-lightning-charge me-2"></i>
                    <asp:Literal runat="server" Text="Acciones Rápidas" />
                </h4>
                <div class="quick-actions">
                    <asp:Button ID="btnCreateOrganization" runat="server" CssClass="btn btn-success btn-lg" OnClick="btnCreateOrganization_Click">
                        <i class="bi bi-plus-circle me-2"></i><asp:Literal runat="server" Text="Crear Organización" />
                    </asp:Button>
                    <asp:Panel ID="pnlAdminActions" runat="server" Visible="false">
                        <asp:Button ID="btnAdminPanel" runat="server" CssClass="btn btn-primary btn-lg" OnClick="btnAdminPanel_Click">
                            <i class="bi bi-gear me-2"></i><asp:Literal runat="server" Text="Administrador de Organización" />
                        </asp:Button>
                    </asp:Panel>
                </div>
            </div>

            <!-- Organizations I Own -->
            <asp:Panel ID="pnlOwnedOrganizations" runat="server" Visible="false" CssClass="organization-section">
                <div class="section-header">
                    <h2 class="section-title">
                        <i class="bi bi-crown"></i>
                        <asp:Literal runat="server" Text="Organizaciones que Posees" />
                    </h2>
                    <small class="text-muted">
                        <asp:Literal runat="server" Text="Tienes acceso completo" />
                    </small>
                </div>
                
                <div class="organization-grid">
                    <asp:Repeater ID="rptOwnedOrganizations" runat="server" OnItemCommand="rptOrganizations_ItemCommand">
                        <ItemTemplate>
                            <div class="organization-card owner">
                                <div class="organization-header owner">
                                    <div class="role-badge">
                                        <i class="bi bi-crown me-1"></i>
                                        <asp:Literal runat="server" Text="Propietario" />
                                    </div>
                                    <h3 class="organization-title"><%# Eval("Name") %></h3>
                                    <div class="organization-slug">@<%# Eval("Slug") %></div>
                                </div>
                                <div class="organization-body">
                                    <p class="organization-description">
                                        <%# !string.IsNullOrEmpty(Eval("Description")?.ToString()) ? Eval("Description") : HttpContext.GetGlobalResourceObject("GlobalResources", "NoDescription") %>
                                    </p>
                                    <div class="organization-stats">
                                        <div class="stat-item">
                                            <i class="bi bi-people"></i>
                                            <span><%# Eval("MemberCount") ?? 0 %> <asp:Literal runat="server" Text="Miembros" /></span>
                                        </div>
                                        <div class="stat-item">
                                            <i class="bi bi-calendar-plus"></i>
                                            <span><%# ((DateTime)Eval("CreatedDate")).ToString("MMM yyyy") %></span>
                                        </div>
                                        <div class="stat-item">
                                            <i class="bi bi-circle-fill <%# (bool)Eval("IsActive") ? "text-success" : "text-danger" %>"></i>
                                            <span><%# (bool)Eval("IsActive") ? HttpContext.GetGlobalResourceObject("GlobalResources", "Active") : HttpContext.GetGlobalResourceObject("GlobalResources", "Inactive") %></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="organization-footer">
                                    <small class="text-muted">ID: <%# Eval("Id") %></small>
                                    <div class="action-buttons">
                                        <asp:LinkButton ID="btnViewDetails" runat="server" CssClass="btn btn-outline-info btn-sm" 
                                            CommandName="ViewDetails" CommandArgument='<%# Eval("Id") %>'>
                                            <i class="bi bi-eye me-1"></i><asp:Literal runat="server" Text="Ver Detalles" />
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnManage" runat="server" CssClass="btn btn-success btn-sm" 
                                            CommandName="Manage" CommandArgument='<%# Eval("Id") %>'>
                                            <i class="bi bi-gear me-1"></i><asp:Literal runat="server" Text="Gestionar" />
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>

            <!-- Organizations I Manage -->
            <asp:Panel ID="pnlManagedOrganizations" runat="server" Visible="false" CssClass="organization-section">
                <div class="section-header">
                    <h2 class="section-title">
                        <i class="bi bi-person-gear"></i>
                        <asp:Literal runat="server" Text="Organizaciones que Administras" />
                    </h2>
                    <small class="text-muted">
                        <asp:Literal runat="server" Text="Puedes gestionar miembros" />
                    </small>
                </div>
                
                <div class="organization-grid">
                    <asp:Repeater ID="rptManagedOrganizations" runat="server" OnItemCommand="rptOrganizations_ItemCommand">
                        <ItemTemplate>
                            <div class="organization-card admin">
                                <div class="organization-header admin">
                                    <div class="role-badge">
                                        <i class="bi bi-person-gear me-1"></i>
                                        <asp:Literal runat="server" Text="Administrador de Organización" />
                                    </div>
                                    <h3 class="organization-title"><%# Eval("Name") %></h3>
                                    <div class="organization-slug">@<%# Eval("Slug") %></div>
                                </div>
                                <div class="organization-body">
                                    <p class="organization-description">
                                        <%# !string.IsNullOrEmpty(Eval("Description")?.ToString()) ? Eval("Description") : HttpContext.GetGlobalResourceObject("GlobalResources", "NoDescription") %>
                                    </p>
                                    <div class="organization-stats">
                                        <div class="stat-item">
                                            <i class="bi bi-people"></i>
                                            <span><%# Eval("MemberCount") ?? 0 %> <asp:Literal runat="server" Text="Miembros" /></span>
                                        </div>
                                        <div class="stat-item">
                                            <i class="bi bi-person-check"></i>
                                            <span><%# Eval("OwnerUsername") %></span>
                                        </div>
                                        <div class="stat-item">
                                            <i class="bi bi-circle-fill <%# (bool)Eval("IsActive") ? "text-success" : "text-danger" %>"></i>
                                            <span><%# (bool)Eval("IsActive") ? HttpContext.GetGlobalResourceObject("GlobalResources", "Active") : HttpContext.GetGlobalResourceObject("GlobalResources", "Inactive") %></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="organization-footer">
                                    <small class="text-muted">ID: <%# Eval("Id") %></small>
                                    <div class="action-buttons">
                                        <asp:LinkButton ID="btnViewDetails" runat="server" CssClass="btn btn-outline-info btn-sm" 
                                            CommandName="ViewDetails" CommandArgument='<%# Eval("Id") %>'>
                                            <i class="bi bi-eye me-1"></i><asp:Literal runat="server" Text="Ver Detalles" />
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnManageMembers" runat="server" CssClass="btn btn-primary btn-sm" 
                                            CommandName="ManageMembers" CommandArgument='<%# Eval("Id") %>'>
                                            <i class="bi bi-people me-1"></i><asp:Literal runat="server" Text="Gestionar Miembros" />
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>

            <!-- Organizations I'm Member Of -->
            <asp:Panel ID="pnlMemberOrganizations" runat="server" Visible="false" CssClass="organization-section">
                <div class="section-header">
                    <h2 class="section-title">
                        <i class="bi bi-people"></i>
                        <asp:Literal runat="server" Text="Organizaciones de las que Eres Miembro" />
                    </h2>
                    <small class="text-muted">
                        <asp:Literal runat="server" Text="Eres un miembro" />
                    </small>
                </div>
                
                <div class="organization-grid">
                    <asp:Repeater ID="rptMemberOrganizations" runat="server" OnItemCommand="rptOrganizations_ItemCommand">
                        <ItemTemplate>
                            <div class="organization-card member">
                                <div class="organization-header member">
                                    <div class="role-badge">
                                        <i class="bi bi-person me-1"></i>
                                        <asp:Literal runat="server" Text="Miembro" />
                                    </div>
                                    <h3 class="organization-title"><%# Eval("Name") %></h3>
                                    <div class="organization-slug">@<%# Eval("Slug") %></div>
                                </div>
                                <div class="organization-body">
                                    <p class="organization-description">
                                        <%# !string.IsNullOrEmpty(Eval("Description")?.ToString()) ? Eval("Description") : HttpContext.GetGlobalResourceObject("GlobalResources", "NoDescription") %>
                                    </p>
                                    <div class="organization-stats">
                                        <div class="stat-item">
                                            <i class="bi bi-people"></i>
                                            <span><%# Eval("MemberCount") ?? 0 %> <asp:Literal runat="server" Text="Miembros" /></span>
                                        </div>
                                        <div class="stat-item">
                                            <i class="bi bi-person-check"></i>
                                            <span><%# Eval("OwnerUsername") %></span>
                                        </div>
                                        <div class="stat-item">
                                            <i class="bi bi-calendar-plus"></i>
                                            <span><%# ((DateTime)Eval("JoinedDate")).ToString("MMM yyyy") %></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="organization-footer">
                                    <small class="text-muted">ID: <%# Eval("Id") %></small>
                                    <div class="action-buttons">
                                        <asp:LinkButton ID="btnViewDetails" runat="server" CssClass="btn btn-outline-info btn-sm" 
                                            CommandName="ViewDetails" CommandArgument='<%# Eval("Id") %>'>
                                            <i class="bi bi-eye me-1"></i><asp:Literal runat="server" Text="Ver Detalles" />
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>

            <!-- No Organizations Message -->
            <asp:Panel ID="pnlNoOrganizations" runat="server" Visible="false">
                <div class="no-organizations">
                    <div class="no-organizations-icon">
                        <i class="bi bi-building"></i>
                    </div>
                    <h3>
                        <asp:Literal runat="server" Text="No perteneces a ninguna organización aún" />
                    </h3>
                    <p class="fs-5">
                        <asp:Literal runat="server" Text="Crea una nueva organización o únete a una existente para comenzar" />
                    </p>
                    <asp:Button ID="btnCreateFirstOrganization" runat="server" CssClass="btn btn-success btn-lg" OnClick="btnCreateOrganization_Click">
                        <i class="bi bi-plus-circle me-2"></i><asp:Literal runat="server" Text="Crear Organización" />
                    </asp:Button>
                </div>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

<asp:Content ID="Content5" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        // Page initialization
        document.addEventListener('DOMContentLoaded', function() {
            initializeOrganizationCards();
        });
        
        // Initialize organization card interactions
        function initializeOrganizationCards() {
            const cards = document.querySelectorAll('.organization-card');
            
            cards.forEach(card => {
                card.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-8px)';
                });
                
                card.addEventListener('mouseleave', function() {
                    this.style.transform = 'translateY(-5px)';
                });
            });
        }
        
        // Handle UpdatePanel refresh
        function pageLoad(sender, args) {
            if (args.get_isPartialLoad()) {
                initializeOrganizationCards();
            }
        }
        
        // Add page load handler for partial postbacks
        if (typeof(Sys) !== 'undefined') {
            Sys.Application.add_load(pageLoad);
        }
    </script>
</asp:Content>