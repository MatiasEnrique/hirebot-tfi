<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminUsers.aspx.cs" Inherits="UI.AdminUsers" MasterPageFile="~/Admin.master" %>

<asp:Content ID="UsersTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Gestión de Usuarios" />
</asp:Content>

<asp:Content ID="UsersHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .stats-card { background: #fff; border-radius: 0.5rem; box-shadow: 0 0.15rem 1.75rem 0 rgba(58,59,69,.15); }
        .section-spacing { margin-bottom: 1.5rem; }
        .user-status-active { color: #28a745; font-weight: 600; }
        .user-status-inactive { color: #dc3545; font-weight: 600; }
        .user-role-badge { padding: 0.25rem 0.75rem; border-radius: 0.25rem; font-size: 0.875rem; font-weight: 600; }
        .user-role-admin { background-color: #4b4e6dff; color: white; }
        .user-role-user { background-color: #84dcc6ff; color: #222222ff; }
        .action-button { margin: 0 0.25rem; }
    </style>
</asp:Content>

<asp:Content ID="UsersMain" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Message Alert -->
    <div id="alertContainer" class="position-fixed" style="bottom: 20px; right: 20px; z-index: 1050; max-width: 400px;">
        <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none alert-dismissible fade show" role="alert"></asp:Label>
    </div>

    <!-- Header -->
    <div class="row mb-4">
        <div class="col-12">
            <h1 class="mb-4"><i class="bi bi-people-fill me-2"></i><asp:Literal runat="server" Text="Gestión de Usuarios" /></h1>
        </div>
    </div>

    <!-- Statistics Cards -->
    <div class="row section-spacing">
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card stats-card h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-1"><asp:Literal runat="server" Text="Total de Usuarios" /></div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><asp:Literal ID="litTotalUsers" runat="server" Text="0" /></div>
                        </div>
                        <div class="col-auto">
                            <i class="bi bi-people fa-2x text-gray-300"></i>
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
                            <div class="text-xs font-weight-bold text-success text-uppercase mb-1"><asp:Literal runat="server" Text="Usuarios Activos" /></div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><asp:Literal ID="litActiveUsers" runat="server" Text="0" /></div>
                        </div>
                        <div class="col-auto">
                            <i class="bi bi-person-check fa-2x text-gray-300"></i>
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
                            <div class="text-xs font-weight-bold text-warning text-uppercase mb-1"><asp:Literal runat="server" Text="Usuarios Inactivos" /></div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><asp:Literal ID="litInactiveUsers" runat="server" Text="0" /></div>
                        </div>
                        <div class="col-auto">
                            <i class="bi bi-person-x fa-2x text-gray-300"></i>
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
                            <div class="text-xs font-weight-bold text-info text-uppercase mb-1"><asp:Literal runat="server" Text="Administradores" /></div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><asp:Literal ID="litAdminUsers" runat="server" Text="0" /></div>
                        </div>
                        <div class="col-auto">
                            <i class="bi bi-shield-check fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Filters -->
    <div class="row section-spacing">
        <div class="col-12">
            <div class="admin-section p-4 mb-4">
                <h5 class="mb-3"><i class="bi bi-funnel me-2"></i><asp:Literal runat="server" Text="Filtros" /></h5>
                <div class="row">
                    <div class="col-md-3 mb-3">
                        <label for="ddlRoleFilter" class="form-label"><asp:Literal runat="server" Text="Rol" /></label>
                        <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="form-select">
                            <asp:ListItem Value="" Text="Todos los Roles" />
                            <asp:ListItem Value="admin" Text="Administradores" />
                            <asp:ListItem Value="user" Text="Usuarios" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-3 mb-3">
                        <label for="ddlStatusFilter" class="form-label"><asp:Literal runat="server" Text="Estado" /></label>
                        <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select">
                            <asp:ListItem Value="" Text="Todos los Estados" />
                            <asp:ListItem Value="active" Text="Activos" />
                            <asp:ListItem Value="inactive" Text="Inactivos" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-4 mb-3">
                        <label for="txtSearchFilter" class="form-label"><asp:Literal runat="server" Text="Buscar" /></label>
                        <asp:TextBox ID="txtSearchFilter" runat="server" CssClass="form-control" placeholder="Buscar por nombre, correo o usuario..."></asp:TextBox>
                    </div>
                    <div class="col-md-2 mb-3 d-flex align-items-end">
                        <div class="w-100">
                            <asp:Button ID="btnApplyFilters" runat="server" CssClass="btn btn-primary w-100" Text="Aplicar" OnClick="btnApplyFilters_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Users Table -->
    <div class="row">
        <div class="col-12">
            <div class="admin-section p-0 shadow-sm">
                <div class="p-3 d-flex justify-content-between align-items-center border-bottom">
                    <h5 class="mb-0"><i class="bi bi-table me-2"></i><asp:Literal runat="server" Text="Lista de Usuarios" /></h5>
                    <div>
                        <asp:Button ID="btnCreateUser" runat="server" CssClass="btn btn-success me-2" Text="Crear Nuevo Usuario" OnClick="btnCreateUser_Click" />
                        <asp:Button ID="btnRefresh" runat="server" CssClass="btn btn-outline-primary" Text="Actualizar" OnClick="btnRefresh_Click" />
                    </div>
                </div>
                <asp:GridView ID="gvUsers" runat="server" CssClass="table table-striped table-hover mb-0" 
                              AutoGenerateColumns="false" AllowPaging="true" PageSize="15" 
                              OnPageIndexChanging="gvUsers_PageIndexChanging"
                              DataKeyNames="UserId"
                              EmptyDataText="No se encontraron usuarios">
                    <Columns>
                        <asp:BoundField DataField="UserId" HeaderText="ID" ItemStyle-Width="60px" />
                        
                        <asp:TemplateField HeaderText="Usuario" ItemStyle-Width="150px">
                            <ItemTemplate>
                                <strong><%# Eval("Username") %></strong>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Nombre Completo">
                            <ItemTemplate>
                                <%# Eval("FirstName") %> <%# Eval("LastName") %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:BoundField DataField="Email" HeaderText="Correo Electrónico" />
                        
                        <asp:TemplateField HeaderText="Rol" ItemStyle-Width="100px">
                            <ItemTemplate>
                                <span class='<%# "user-role-badge user-role-" + Eval("UserRole").ToString().ToLower() %>'>
                                    <%# Eval("UserRole").ToString() == "admin" ? "Admin" : "Usuario" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Estado" ItemStyle-Width="100px">
                            <ItemTemplate>
                                <span class='<%# (bool)Eval("IsActive") ? "user-status-active" : "user-status-inactive" %>'>
                                    <%# (bool)Eval("IsActive") ? "Activo" : "Inactivo" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Acciones" ItemStyle-Width="200px">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-sm btn-primary action-button" 
                                                CommandName="EditUser" CommandArgument='<%# Eval("UserId") %>' 
                                                OnClick="btnEdit_Click" ToolTip="Editar">
                                    <i class="bi bi-pencil-fill"></i>
                                </asp:LinkButton>
                                
                                <asp:LinkButton ID="btnToggleStatus" runat="server" 
                                                CssClass='<%# "btn btn-sm action-button " + ((bool)Eval("IsActive") ? "btn-warning" : "btn-success") %>' 
                                                CommandName="ToggleStatus" CommandArgument='<%# Eval("UserId") %>' 
                                                OnClick="btnToggleStatus_Click"
                                                ToolTip='<%# (bool)Eval("IsActive") ? "Desactivar" : "Activar" %>'>
                                    <i class='<%# "bi " + ((bool)Eval("IsActive") ? "bi-person-x-fill" : "bi-person-check-fill") %>'></i>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>

                    <EmptyDataTemplate>
                        <div class="text-center p-4">
                            <i class="bi bi-inbox display-1 text-muted"></i>
                            <h5 class="mt-3 text-muted"><asp:Literal runat="server" Text="No se encontraron usuarios" /></h5>
                            <p class="text-muted"><asp:Literal runat="server" Text="Intenta ajustar tus filtros." /></p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>

    <!-- Create User Modal -->
    <div class="modal fade" id="createUserModal" tabindex="-1" role="dialog" aria-labelledby="createUserModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="createUserModalLabel">
                        <i class="bi bi-person-plus-fill me-2"></i><asp:Literal runat="server" Text="Crear Nuevo Usuario" />
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="txtCreateUsername" class="form-label">Nombre de Usuario <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtCreateUsername" runat="server" CssClass="form-control" placeholder="Nombre de usuario" />
                            <div class="form-text">Solo letras, números y guiones bajos (mínimo 3 caracteres)</div>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="txtCreateEmail" class="form-label">Correo Electrónico <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtCreateEmail" runat="server" CssClass="form-control" placeholder="correo@ejemplo.com" TextMode="Email" />
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="txtCreateFirstName" class="form-label">Nombre <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtCreateFirstName" runat="server" CssClass="form-control" placeholder="Nombre" />
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="txtCreateLastName" class="form-label">Apellido <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtCreateLastName" runat="server" CssClass="form-control" placeholder="Apellido" />
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="txtCreatePassword" class="form-label">Contraseña <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtCreatePassword" runat="server" CssClass="form-control" placeholder="Contraseña" TextMode="Password" />
                            <div class="form-text">Mínimo 6 caracteres</div>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="txtCreateConfirmPassword" class="form-label">Confirmar Contraseña <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtCreateConfirmPassword" runat="server" CssClass="form-control" placeholder="Confirmar contraseña" TextMode="Password" />
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="ddlCreateUserRole" class="form-label">Rol <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlCreateUserRole" runat="server" CssClass="form-select">
                                <asp:ListItem Value="user" Text="Usuario" Selected="True" />
                                <asp:ListItem Value="admin" Text="Administrador" />
                            </asp:DropDownList>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="chkCreateIsActive" class="form-label">Estado</label>
                            <div class="form-check">
                                <asp:CheckBox ID="chkCreateIsActive" runat="server" CssClass="form-check-input" Checked="true" />
                                <label class="form-check-label" for="chkCreateIsActive">
                                    Usuario Activo
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <asp:Button ID="btnSaveNewUser" runat="server" CssClass="btn btn-success" Text="Crear Usuario" OnClick="btnSaveNewUser_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- Edit User Modal -->
    <div class="modal fade" id="editUserModal" tabindex="-1" role="dialog" aria-labelledby="editUserModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editUserModalLabel">
                        <i class="bi bi-person-fill me-2"></i><asp:Literal runat="server" Text="Editar Usuario" />
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfEditUserId" runat="server" />
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="txtEditUsername" class="form-label">Nombre de Usuario <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEditUsername" runat="server" CssClass="form-control" placeholder="Nombre de usuario" />
                            <div class="form-text">Solo letras, números y guiones bajos</div>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="txtEditEmail" class="form-label">Correo Electrónico <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEditEmail" runat="server" CssClass="form-control" placeholder="correo@ejemplo.com" TextMode="Email" />
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="txtEditFirstName" class="form-label">Nombre <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEditFirstName" runat="server" CssClass="form-control" placeholder="Nombre" />
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="txtEditLastName" class="form-label">Apellido <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEditLastName" runat="server" CssClass="form-control" placeholder="Apellido" />
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="ddlEditUserRole" class="form-label">Rol <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlEditUserRole" runat="server" CssClass="form-select">
                                <asp:ListItem Value="user" Text="Usuario" />
                                <asp:ListItem Value="admin" Text="Administrador" />
                            </asp:DropDownList>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="chkEditIsActive" class="form-label">Estado</label>
                            <div class="form-check">
                                <asp:CheckBox ID="chkEditIsActive" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label" for="chkEditIsActive">
                                    Usuario Activo
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <asp:Button ID="btnSaveUser" runat="server" CssClass="btn btn-primary" Text="Guardar Cambios" OnClick="btnSaveUser_Click" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="UsersScripts" ContentPlaceHolderID="ScriptContent" runat="server">
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
        
        // Show create modal when needed
        function showCreateModal() {
            var modal = new bootstrap.Modal(document.getElementById('createUserModal'));
            modal.show();
        }
        
        // Show edit modal when needed
        function showEditModal() {
            var modal = new bootstrap.Modal(document.getElementById('editUserModal'));
            modal.show();
        }
        
        // Check if we should show the modal
        <asp:Literal ID="litShowModalScript" runat="server" />
    </script>
</asp:Content>
