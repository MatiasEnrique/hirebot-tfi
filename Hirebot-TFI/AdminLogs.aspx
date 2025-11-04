<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminLogs.aspx.cs" Inherits="UI.AdminLogs" MasterPageFile="~/Admin.master" %>

<asp:Content ID="LogsTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Gestión de Logs" />
</asp:Content>

<asp:Content ID="LogsHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .stats-card { background: #fff; border-radius: 0.5rem; box-shadow: 0 0.15rem 1.75rem 0 rgba(58,59,69,.15); }
        .section-spacing { margin-bottom: 1.5rem; }
        .custom-pagination-template { padding: .75rem; }
    </style>
</asp:Content>

<asp:Content ID="LogsMain" ContentPlaceHolderID="MainContent" runat="server">
    <div id="alertContainer" class="position-fixed" style="bottom: 20px; right: 20px; z-index: 1050; max-width: 400px;">
        <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none alert-dismissible fade show" role="alert"></asp:Label>
    </div>

    <div class="row mb-4">
        <div class="col-12">
            <h1 class="mb-4"><i class="bi bi-file-text-fill me-2"></i><asp:Literal runat="server" Text="Gestión de Logs" /></h1>
        </div>
    </div>

    <!-- Statistics Cards -->
    <div class="row section-spacing">
        <div class="col-xl-3 col-md-6 mb-4"><div class="card stats-card h-100 py-2"><div class="card-body"><div class="row no-gutters align-items-center"><div class="col mr-2"><div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><asp:Literal runat="server" Text="Total de Logs" /></div><div class="h5 mb-0 font-weight-bold text-gray-800"><asp:Literal ID="litTotalLogs" runat="server" Text="0" /></div></div><div class="col-auto"><i class="bi bi-file-earmark-text fa-2x text-gray-300"></i></div></div></div></div></div>
        <div class="col-xl-3 col-md-6 mb-4"><div class="card stats-card h-100 py-2"><div class="card-body"><div class="row no-gutters align-items-center"><div class="col mr-2"><div class="text-xs font-weight-bold text-success text-uppercase mb-1"><asp:Literal runat="server" Text="Logs de Hoy" /></div><div class="h5 mb-0 font-weight-bold text-gray-800"><asp:Literal ID="litTodaysLogs" runat="server" Text="0" /></div></div><div class="col-auto"><i class="bi bi-calendar-day fa-2x text-gray-300"></i></div></div></div></div></div>
        <div class="col-xl-3 col-md-6 mb-4"><div class="card stats-card h-100 py-2"><div class="card-body"><div class="row no-gutters align-items-center"><div class="col mr-2"><div class="text-xs font-weight-bold text-warning text-uppercase mb-1"><asp:Literal runat="server" Text="Logs de Error" /></div><div class="h5 mb-0 font-weight-bold text-gray-800"><asp:Literal ID="litErrorLogs" runat="server" Text="0" /></div></div><div class="col-auto"><i class="bi bi-exclamation-triangle fa-2x text-gray-300"></i></div></div></div></div></div>
        <div class="col-xl-3 col-md-6 mb-4"><div class="card stats-card h-100 py-2"><div class="card-body"><div class="row no-gutters align-items-center"><div class="col mr-2"><div class="text-xs font-weight-bold text-info text-uppercase mb-1"><asp:Literal runat="server" Text="Logs de Inicio de Sesión" /></div><div class="h5 mb-0 font-weight-bold text-gray-800"><asp:Literal ID="litLoginLogs" runat="server" Text="0" /></div></div><div class="col-auto"><i class="bi bi-box-arrow-in-right fa-2x text-gray-300"></i></div></div></div></div></div>
    </div>

    <!-- Filters -->
    <div class="row section-spacing">
        <div class="col-12">
            <div class="admin-section p-4 mb-4">
                <h5 class="mb-3"><i class="bi bi-funnel me-2"></i><asp:Literal runat="server" Text="Filtros" /></h5>
                <div class="row">
                    <div class="col-md-3 mb-3">
                        <label for="ddlLogTypeFilter" class="form-label"><asp:Literal runat="server" Text="Tipo de Log" /></label>
                        <asp:DropDownList ID="ddlLogTypeFilter" runat="server" CssClass="form-select" />
                    </div>
                    <div class="col-md-3 mb-3">
                        <label for="ddlUserFilter" class="form-label"><asp:Literal runat="server" Text="Usuario" /></label>
                        <asp:DropDownList ID="ddlUserFilter" runat="server" CssClass="form-select">
                            <asp:ListItem Value="" Text="Todos los Usuarios" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-3 mb-3">
                        <label for="txtStartDate" class="form-label"><asp:Literal runat="server" Text="Fecha de Inicio" /></label>
                        <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                    </div>
                    <div class="col-md-3 mb-3">
                        <label for="txtEndDate" class="form-label"><asp:Literal runat="server" Text="Fecha de Fin" /></label>
                        <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="txtDescriptionFilter" class="form-label"><asp:Literal runat="server" Text="Descripción" /></label>
                        <asp:TextBox ID="txtDescriptionFilter" runat="server" CssClass="form-control" placeholder="Buscar en descripción..."></asp:TextBox>
                    </div>
                    <div class="col-md-3 mb-3">
                        <label for="ddlDateRange" class="form-label"><asp:Literal runat="server" Text="Rango de Fecha Rápido" /></label>
                        <asp:DropDownList ID="ddlDateRange" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlDateRange_SelectedIndexChanged">
                            <asp:ListItem Value="" Text="Rango Personalizado" />
                            <asp:ListItem Value="today" Text="Hoy" />
                            <asp:ListItem Value="yesterday" Text="Ayer" />
                            <asp:ListItem Value="week" Text="Esta Semana" />
                            <asp:ListItem Value="month" Text="Este Mes" />
                            <asp:ListItem Value="7days" Text="Últimos 7 Días" />
                            <asp:ListItem Value="30days" Text="Últimos 30 Días" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-3 mb-3 d-flex align-items-end">
                        <div class="w-100">
                            <asp:Button ID="btnApplyFilters" runat="server" CssClass="btn btn-primary me-2" Text="Aplicar Filtros" OnClick="btnApplyFilters_Click" />
                            <asp:Button ID="btnClearFilters" runat="server" CssClass="btn btn-secondary" Text="Limpiar" OnClick="btnClearFilters_Click" />
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
                <h5><i class="bi bi-table me-2"></i><asp:Literal runat="server" Text="Registros de Log" /></h5>
                <div>
                    <asp:Button ID="btnExportCsv" runat="server" CssClass="btn btn-success me-2" Text="Exportar CSV" OnClick="btnExportCsv_Click" />
                    <asp:Button ID="btnRefresh" runat="server" CssClass="btn btn-outline-primary" Text="Actualizar" OnClick="btnRefresh_Click" />
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
                        <asp:BoundField DataField="Id" HeaderText="ID" ItemStyle-Width="80px" />
                        <asp:TemplateField HeaderText="Tipo de Log" ItemStyle-Width="120px">
                            <ItemTemplate>
                                <span class='badge log-type-badge log-<%# Eval("LogType").ToString().ToLower() %>'>
                                    <%# Eval("LogType") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Usuario" ItemStyle-Width="180px">
                            <ItemTemplate>
                                <%# GetUserDisplayName(Eval("UserId")) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Description" HeaderText="Descripción" />
                        <asp:TemplateField HeaderText="Creado" ItemStyle-Width="180px">
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
                            <h5 class="mt-3 text-muted"><asp:Literal runat="server" Text="No se encontraron logs" /></h5>
                            <p class="text-muted"><asp:Literal runat="server" Text="Intenta ajustar tus filtros o vuelve más tarde." /></p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="LogsScripts" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        // Auto-hide alerts after 5 seconds
        (function () {
            const alert = document.querySelector('.alert:not(.d-none)');
            if (alert) {
                setTimeout(function () {
                    alert.classList.add('fade');
                    setTimeout(function () { alert.style.display = 'none'; }, 150);
                }, 5000);
            }
        })();
    </script>
</asp:Content>

