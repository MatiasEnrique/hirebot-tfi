<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="Hirebot_TFI.AdminDashboard" MasterPageFile="~/Admin.master" %>

<asp:Content ID="DashboardTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Panel de Control" />
</asp:Content>

<asp:Content ID="DashboardHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .dashboard-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .dashboard-card:hover { transform: translateY(-5px); box-shadow: 0 0.5rem 2rem 0 rgba(58, 59, 69, 0.25); }
        .dashboard-icon { width: 64px; height: 64px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 2rem; color: white; margin: 0 auto 1rem; }
        .icon-catalog { background: linear-gradient(135deg, #4b4e6d, #84dcc6); }
        .icon-logs { background: linear-gradient(135deg, #95a3b3, #4b4e6d); }
        .icon-users { background: linear-gradient(135deg, #84dcc6, #95a3b3); }
        .icon-news { background: linear-gradient(135deg, #84dcc6, #4b4e6d); }
        .welcome-header { background: linear-gradient(135deg, #4b4e6d, #84dcc6); color: white; border-radius: 10px; padding: 2rem; margin-bottom: 2rem; text-align: center; }
    </style>
</asp:Content>

<asp:Content ID="DashboardMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="welcome-header">
        <h1 class="mb-3">
            <i class="bi bi-shield-check me-3"></i>
            <asp:Literal runat="server" Text="Bienvenido, Administrador" />
        </h1>
        <p class="mb-0 fs-5">
            <asp:Literal runat="server" Text="Panel de control administrativo para gestionar el sistema Hirebot-TFI" />
        </p>
    </div>

    <div class="row g-4">
        <div class="col-md-4">
            <div class="dashboard-card p-4 h-100 text-center">
                <div class="dashboard-icon icon-catalog"><i class="bi bi-box-seam"></i></div>
                <h4 class="mb-3"><asp:Literal runat="server" Text="Gestión de Catálogos" /></h4>
                <p class="text-muted mb-4"><asp:Literal runat="server" Text="Administra productos, categorías y contenido del catálogo" /></p>
                <a href="AdminCatalog.aspx" class="btn btn-primary">
                    <i class="bi bi-arrow-right me-1"></i>
                    <asp:Literal runat="server" Text="Gestionar Catálogo" />
                </a>
            </div>
        </div>

        <div class="col-md-4">
            <div class="dashboard-card p-4 h-100 text-center">
                <div class="dashboard-icon icon-logs"><i class="bi bi-journal-text"></i></div>
                <h4 class="mb-3"><asp:Literal runat="server" Text="Gestión de Logs" /></h4>
                <p class="text-muted mb-4"><asp:Literal runat="server" Text="Revisa registros del sistema y actividad de usuarios" /></p>
                <a href="AdminLogs.aspx" class="btn btn-primary">
                    <i class="bi bi-arrow-right me-1"></i>
                    <asp:Literal runat="server" Text="Ver Registros" />
                </a>
            </div>
        </div>

        <div class="col-md-4">
            <div class="dashboard-card p-4 h-100 text-center">
                <div class="dashboard-icon icon-news"><i class="bi bi-newspaper"></i></div>
                <h4 class="mb-3"><asp:Literal runat="server" Text="Gestión de noticias" /></h4>
                <p class="text-muted mb-4"><asp:Literal runat="server" Text="Crea, edita y publica novedades para todos los usuarios." /></p>
                <a href="AdminNews.aspx" class="btn btn-primary">
                    <i class="bi bi-arrow-right me-1"></i>
                    <asp:Literal runat="server" Text="Gestionar noticias" />
                </a>
            </div>
        </div>

        <div class="col-md-4">
            <div class="dashboard-card p-4 h-100 text-center">
                <div class="dashboard-icon icon-users"><i class="bi bi-people"></i></div>
                <h4 class="mb-3"><asp:Literal runat="server" Text="Resumen del Sistema" /></h4>
                <p class="text-muted mb-4"><asp:Literal runat="server" Text="Estadísticas generales y estado del sistema" /></p>
                <div class="row text-start">
                    <div class="col-6">
                        <div class="d-flex align-items-center mb-2">
                            <i class="bi bi-people-fill text-primary me-2"></i>
                            <span class="small">
                                <asp:Literal runat="server" Text="Total Usuarios" />:
                                <strong><asp:Label ID="lblTotalUsers" runat="server" /></strong>
                            </span>
                        </div>
                        <div class="d-flex align-items-center">
                            <i class="bi bi-box-seam text-success me-2"></i>
                            <span class="small">
                                <asp:Literal runat="server" Text="Total Productos" />:
                                <strong><asp:Label ID="lblTotalProducts" runat="server" /></strong>
                            </span>
                        </div>
                    </div>
                    <div class="col-6">
                        <div class="d-flex align-items-center mb-2">
                            <i class="bi bi-journal-text text-warning me-2"></i>
                            <span class="small">
                                <asp:Literal runat="server" Text="Total de Logs" />:
                                <strong><asp:Label ID="lblTotalLogs" runat="server" /></strong>
                            </span>
                        </div>
                        <div class="d-flex align-items-center">
                            <i class="bi bi-calendar text-info me-2"></i>
                            <span class="small">
                                <asp:Literal runat="server" Text="Último Acceso" />:
                                <strong><asp:Label ID="lblLastLogin" runat="server" /></strong>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="DashboardScripts" ContentPlaceHolderID="ScriptContent" runat="server">
</asp:Content>

