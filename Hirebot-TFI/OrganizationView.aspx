<%@ Page Title="Organization - Hirebot-TFI" Language="C#" MasterPageFile="~/Protected.master" AutoEventWireup="true" CodeBehind="OrganizationView.aspx.cs" Inherits="Hirebot_TFI.OrganizationView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Label ID="lblPageTitle" runat="server" /> - Hirebot-TFI
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .organization-hero {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            border-radius: 15px;
            padding: 3rem;
            margin-bottom: 2rem;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .organization-hero::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 20"><defs><radialGradient id="a" cx="50%" cy="50%" r="50%"><stop offset="0%" stop-color="white" stop-opacity="0.1"/><stop offset="100%" stop-color="white" stop-opacity="0"/></radialGradient></defs><circle cx="50" cy="10" r="10" fill="url(%23a)"/></svg>') repeat;
            opacity: 0.1;
        }
        
        .organization-hero-content {
            position: relative;
            z-index: 1;
        }
        
        .organization-logo {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            margin: 0 auto 1.5rem;
            border: 3px solid rgba(255, 255, 255, 0.3);
        }
        
        .organization-stats {
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
        
        .member-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
            margin-top: 2rem;
        }
        
        .member-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            overflow: hidden;
            border: 1px solid #e9ecef;
        }
        
        .member-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 0.5rem 2rem 0 rgba(58, 59, 69, 0.25);
        }
        
        .member-header {
            background: linear-gradient(135deg, var(--cadet-gray), var(--ultra-violet));
            color: white;
            padding: 1rem;
            text-align: center;
        }
        
        .member-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 1.5rem;
            margin: 0 auto 1rem;
            border: 3px solid rgba(255, 255, 255, 0.3);
        }
        
        .member-body {
            padding: 1.5rem;
            text-align: center;
        }
        
        .role-badge {
            display: inline-block;
            padding: 0.375rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-top: 0.5rem;
        }
        
        .role-owner {
            background: linear-gradient(135deg, #ffd700, #ffed4e);
            color: #b8860b;
        }
        
        .role-admin {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
        }
        
        .role-member {
            background: linear-gradient(135deg, var(--cadet-gray), #adb5bd);
            color: white;
        }
        
        .join-section {
            background: white;
            border-radius: 15px;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            padding: 2rem;
            text-align: center;
            margin: 2rem 0;
        }
        
        .join-icon {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--tiffany-blue), var(--ultra-violet));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: white;
            margin: 0 auto 1rem;
        }
        
        .section-header {
            border-bottom: 2px solid var(--ultra-violet);
            padding-bottom: 0.75rem;
            margin-bottom: 1.5rem;
        }
        
        .info-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            padding: 1.5rem;
            margin-bottom: 1.5rem;
        }
        
        .info-item {
            display: flex;
            align-items: center;
            margin-bottom: 1rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid #e9ecef;
        }
        
        .info-item:last-child {
            margin-bottom: 0;
            padding-bottom: 0;
            border-bottom: none;
        }
        
        .info-icon {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            background: var(--ultra-violet);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1rem;
            flex-shrink: 0;
        }
        
        .info-content h6 {
            margin: 0 0 0.25rem;
            color: var(--ultra-violet);
            font-weight: 600;
        }
        
        .info-content p {
            margin: 0;
            color: var(--cadet-gray);
            font-size: 0.9rem;
        }
        
        .organization-actions {
            position: sticky;
            top: 20px;
            background: white;
            border-radius: 15px;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            padding: 1.5rem;
        }
        
        @media (max-width: 768px) {
            .organization-hero {
                padding: 2rem 1.5rem;
            }
            
            .organization-stats {
                flex-direction: column;
                gap: 1.5rem;
            }
            
            .member-grid {
                grid-template-columns: 1fr;
                gap: 1rem;
            }
            
            .organization-actions {
                position: relative;
                top: 0;
                margin-top: 2rem;
            }
        }
        
        @media (max-width: 576px) {
            .organization-hero {
                padding: 1.5rem 1rem;
            }
            
            .stat-number {
                font-size: 1.5rem;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="NavigationContent" runat="server">
    <li class="nav-item">
        <a class="nav-link" href="MyOrganizations.aspx">
            <i class="fas fa-building me-1"></i>
            <asp:Literal runat="server" Text="Mis Organizaciones" />
        </a>
    </li>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" />
    
    <div class="content-card">
        <asp:UpdatePanel ID="upMain" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <!-- Alert Messages -->
                <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert" role="alert">
                    <asp:Label ID="lblAlert" runat="server"></asp:Label>
                </asp:Panel>

                <!-- Organization Hero Section -->
                <div class="organization-hero">
                    <div class="organization-hero-content">
                        <div class="organization-logo">
                            <i class="fas fa-building"></i>
                        </div>
                        <h1 class="mb-3">
                            <asp:Label ID="lblOrganizationName" runat="server" />
                        </h1>
                        <p class="fs-5 mb-0">
                            <asp:Label ID="lblOrganizationDescription" runat="server" />
                        </p>
                        
                        <div class="organization-stats">
                            <div class="stat-item">
                                <span class="stat-number">
                                    <asp:Label ID="lblMemberCount" runat="server">0</asp:Label>
                                </span>
                                <span class="stat-label">
                                    <asp:Literal runat="server" Text="Miembros" />
                                </span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-number">
                                    <asp:Label ID="lblAdminCount" runat="server">0</asp:Label>
                                </span>
                                <span class="stat-label">
                                    <asp:Literal runat="server" Text="Administradores" />
                                </span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-number">
                                    <asp:Label ID="lblEstablishedDate" runat="server" />
                                </span>
                                <span class="stat-label">
                                    <asp:Literal runat="server" Text="Fundada" />
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-8">
                        <!-- Organization Information -->
                        <div class="section-header">
                            <h3>
                                <i class="fas fa-info-circle me-2"></i>
                                <asp:Literal runat="server" Text="Detalles de la Organización" />
                            </h3>
                        </div>
                        
                        <div class="info-card">
                            <div class="info-item">
                                <div class="info-icon">
                                    <i class="fas fa-link"></i>
                                </div>
                                <div class="info-content">
                                    <h6>
                                        <asp:Literal runat="server" Text="Slug de la Organización" />
                                    </h6>
                                    <p><asp:Label ID="lblOrganizationSlug" runat="server" /></p>
                                </div>
                            </div>
                            
                            <div class="info-item">
                                <div class="info-icon">
                                    <i class="fas fa-user-crown"></i>
                                </div>
                                <div class="info-content">
                                    <h6>
                                        <asp:Literal runat="server" Text="Propietario" />
                                    </h6>
                                    <p><asp:Label ID="lblOwnerName" runat="server" /></p>
                                </div>
                            </div>
                            
                            <div class="info-item">
                                <div class="info-icon">
                                    <i class="fas fa-calendar-plus"></i>
                                </div>
                                <div class="info-content">
                                    <h6>
                                        <asp:Literal runat="server" Text="Fecha de Creación" />
                                    </h6>
                                    <p><asp:Label ID="lblCreatedDate" runat="server" /></p>
                                </div>
                            </div>
                            
                            <div class="info-item">
                                <div class="info-icon">
                                    <i class="fas fa-circle text-success" id="statusIcon" runat="server"></i>
                                </div>
                                <div class="info-content">
                                    <h6>
                                        <asp:Literal runat="server" Text="Estado" />
                                    </h6>
                                    <p><asp:Label ID="lblStatus" runat="server" /></p>
                                </div>
                            </div>
                        </div>

                        <!-- Members Section -->
                        <div class="section-header">
                            <h3>
                                <i class="fas fa-users me-2"></i>
                                <asp:Literal runat="server" Text="Miembros de la organización" />
                            </h3>
                        </div>
                        
                        <asp:Panel ID="pnlMembersPublic" runat="server">
                            <div class="member-grid">
                                <asp:Repeater ID="rptMembers" runat="server">
                                    <ItemTemplate>
                                        <div class="member-card">
                                            <div class="member-header">
                                                <div class="member-avatar">
                                                    <%# GetUserInitials(Eval("Username")?.ToString()) %>
                                                </div>
                                                <h5 class="mb-0"><%# Eval("FirstName") %> <%# Eval("LastName") %></h5>
                                                <small class="opacity-75">@<%# Eval("Username") %></small>
                                            </div>
                                            <div class="member-body">
                                                <span class="role-badge role-<%# Eval("Role")?.ToString().ToLower().Replace("_", "-") %>">
                                                    <%# GetRoleDisplayName(Eval("Role")?.ToString()) %>
                                                </span>
                                                <p class="text-muted small mt-2 mb-0">
                                                    <i class="fas fa-calendar me-1"></i>
                                                    <asp:Literal runat="server" Text="Se unió el" />: 
                                                    <%# ((DateTime)Eval("JoinDate")).ToString("MMM yyyy") %>
                                                </p>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </asp:Panel>
                        
                        <!-- Members Hidden Message -->
                        <asp:Panel ID="pnlMembersHidden" runat="server" Visible="false" CssClass="info-card text-center">
                            <div class="mb-3">
                                <i class="fas fa-lock display-4 text-muted"></i>
                            </div>
                            <h5 class="text-muted mb-3">
                                <asp:Literal runat="server" Text="La lista de miembros es privada" />
                            </h5>
                            <p class="text-muted">
                                <asp:Literal runat="server" Text="Únete para ver los miembros" />
                            </p>
                        </asp:Panel>
                        
                        <!-- No Members Message -->
                        <asp:Panel ID="pnlNoMembers" runat="server" Visible="false" CssClass="info-card text-center">
                            <div class="mb-3">
                                <i class="fas fa-users display-4 text-muted"></i>
                            </div>
                            <h5 class="text-muted mb-3">
                                <asp:Literal runat="server" Text="No hay miembros en esta organización" />
                            </h5>
                            <p class="text-muted">
                                <asp:Literal runat="server" Text="Sé el primero en unirte" />
                            </p>
                        </asp:Panel>
                    </div>
                    
                    <div class="col-lg-4">
                        <!-- Join/Manage Actions -->
                        <div class="organization-actions">
                            <asp:Panel ID="pnlNotMember" runat="server">
                                <div class="join-section">
                                    <div class="join-icon">
                                        <i class="fas fa-user-plus"></i>
                                    </div>
                                    <h5 class="mb-3">
                                        <asp:Literal runat="server" Text="Unirse a esta organización" />
                                    </h5>
                                    <p class="text-muted mb-4">
                                        <asp:Literal runat="server" Text="Únete a esta organización para acceder a sus recursos y colaborar con otros miembros" />
                                    </p>
                                    <asp:Button ID="btnJoinOrganization" runat="server" CssClass="btn btn-success btn-lg w-100" 
                                        Text="Unirse a la Organización" OnClick="btnJoinOrganization_Click"
                                        OnClientClick="return confirm('Are you sure you want to join this organization?');" />
                                </div>
                            </asp:Panel>
                            
                            <asp:Panel ID="pnlIsMember" runat="server" Visible="false">
                                <div class="join-section">
                                    <div class="join-icon" style="background: linear-gradient(135deg, var(--cadet-gray), var(--ultra-violet));">
                                        <i class="fas fa-check-circle"></i>
                                    </div>
                                    <h5 class="mb-3">
                                        <asp:Literal runat="server" Text="Ya eres miembro" />
                                    </h5>
                                    <p class="text-muted mb-4">
                                        <asp:Literal runat="server" Text="Tu rol" />: 
                                        <strong><asp:Label ID="lblCurrentUserRole" runat="server" /></strong>
                                    </p>
                                    <div class="d-grid gap-2">
                                        <asp:Button ID="btnManageOrganization" runat="server" CssClass="btn btn-primary" 
                                            Text="Gestionar Organización" OnClick="btnManageOrganization_Click" />
                                        <asp:Button ID="btnLeaveOrganization" runat="server" CssClass="btn btn-outline-danger" 
                                            Text="Salir de la Organización" OnClick="btnLeaveOrganization_Click"
                                            OnClientClick='<%# "return confirm(\u0027" + HttpContext.GetGlobalResourceObject("GlobalResources", "ConfirmLeaveOrganization") + "\u0027);" %>' />
                                    </div>
                                </div>
                            </asp:Panel>
                            
                            <!-- Quick Stats -->
                            <div class="mt-4 pt-4 border-top">
                                <h6 class="mb-3">
                                    <i class="fas fa-chart-bar me-2"></i>
                                    <asp:Literal runat="server" Text="Estadísticas rápidas" />
                                </h6>
                                <div class="row text-center g-3">
                                    <div class="col-6">
                                        <div class="p-2">
                                            <div class="fs-4 fw-bold text-primary">
                                                <asp:Label ID="lblStatTotalMembers" runat="server">0</asp:Label>
                                            </div>
                                            <div class="small text-muted">
                                                <asp:Literal runat="server" Text="Total de miembros" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="p-2">
                                            <div class="fs-4 fw-bold text-success">
                                                <asp:Label ID="lblStatAdmins" runat="server">0</asp:Label>
                                            </div>
                                            <div class="small text-muted">
                                                <asp:Literal runat="server" Text="Admins" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>

<asp:Content ID="Content5" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        // Page initialization
        document.addEventListener('DOMContentLoaded', function() {
            // Smooth scrolling for internal links
            document.querySelectorAll('a[href^="#"]').forEach(anchor => {
                anchor.addEventListener('click', function (e) {
                    e.preventDefault();
                    const target = document.querySelector(this.getAttribute('href'));
                    if (target) {
                        target.scrollIntoView({
                            behavior: 'smooth',
                            block: 'start'
                        });
                    }
                });
            });
        });
        
        // Auto-hide alerts
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert-success');
            alerts.forEach(function(alert) {
                if (alert.style.display !== 'none') {
                    alert.style.display = 'none';
                }
            });
        }, 5000);
        
        // Animate stats on scroll
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate__animated', 'animate__fadeInUp');
                }
            });
        }, observerOptions);
        
        // Observe member cards
        document.querySelectorAll('.member-card').forEach(card => {
            observer.observe(card);
        });
    </script>
</asp:Content>