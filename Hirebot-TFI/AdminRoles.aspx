<%@ Page Title="" Language="C#" MasterPageFile="~/Admin.master" AutoEventWireup="true" CodeBehind="AdminRoles.aspx.cs" Inherits="Hirebot_TFI.AdminRoles" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .role-card {
            border: 1px solid rgba(0, 0, 0, 0.08);
            border-radius: 0.75rem;
            padding: 1rem;
            transition: all 0.2s ease;
        }

        .role-card:hover {
            border-color: rgba(132, 220, 198, 0.6);
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.05);
        }

        .role-card.active {
            border-color: rgba(75, 78, 109, 0.6);
            background-color: rgba(132, 220, 198, 0.08);
        }

        .permissions-container {
            max-height: 300px;
            overflow-y: auto;
            border: 1px solid rgba(0, 0, 0, 0.08);
            border-radius: 0.5rem;
            padding: 1rem;
            background-color: #ffffff;
        }

        .permissions-container .form-check {
            margin-bottom: 0.5rem;
        }

        .assigned-user-card {
            border: 1px solid rgba(0, 0, 0, 0.08);
            border-radius: 0.5rem;
            padding: 0.75rem 1rem;
            margin-bottom: 0.75rem;
            background-color: #ffffff;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel ID="upRoles" runat="server">
        <ContentTemplate>
            <asp:HiddenField ID="hdnSelectedRoleId" runat="server" />

            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" Role="alert" />

            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center mb-4 gap-3">
                <h2 class="mb-0">
                    <asp:Literal runat="server" Text="Gestión de roles" />
                </h2>
                <asp:LinkButton ID="btnNewRole" runat="server" CssClass="btn btn-outline-primary" OnClick="btnNewRole_Click">
                    <i class="bi bi-plus-circle me-1"></i>
                    <asp:Literal runat="server" Text="Crear rol" />
                </asp:LinkButton>
            </div>

            <div class="row">
                <div class="col-lg-4">
                    <div class="card shadow-sm mb-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">
                                <asp:Literal runat="server" Text="Roles existentes" />
                            </h5>
                        </div>
                        <div class="card-body">
                            <asp:Repeater ID="rptRoles" runat="server" OnItemCommand="rptRoles_ItemCommand">
                                <ItemTemplate>
                                    <div class='<%# GetRoleCardCss(Eval("RoleId")) %>'>
                                        <div class="d-flex justify-content-between align-items-start">
                                            <div class="pe-2">
                                                <h6 class="mb-1 text-truncate"><%# Eval("RoleName") %></h6>
                                                <small class="text-muted d-block">
                                                    <%# GetRoleSummary(Eval("IsActive"), Eval("AssignedUserCount"), Eval("PermissionCount")) %>
                                                </small>
                                            </div>
                                            <asp:LinkButton ID="btnSelectRole" runat="server" CssClass="btn btn-sm btn-outline-primary" CommandName="SelectRole" CommandArgument='<%# Eval("RoleId") %>'>
                                                <i class="bi bi-eye"></i>
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                            <asp:Panel ID="pnlNoRoles" runat="server" Visible="false" CssClass="alert alert-info mt-3">
                                <i class="bi bi-info-circle me-1"></i>
                                <asp:Literal runat="server" Text="Aún no se crearon roles." />
                            </asp:Panel>
                        </div>
                    </div>
                </div>

                <div class="col-lg-8">
                    <asp:Panel ID="pnlRoleDetail" runat="server" CssClass="card shadow-sm" Visible="false">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">
                                <asp:Literal ID="litRoleHeader" runat="server" />
                            </h5>
                            <span class="badge" id="badgeRoleStatus" runat="server"></span>
                        </div>
                        <div class="card-body">
                            <asp:ValidationSummary ID="vsRole" runat="server" CssClass="alert alert-danger" ValidationGroup="RoleForm" EnableClientScript="false" />

                            <div class="mb-3">
                                <label class="form-label" for="txtRoleName">
                                    <asp:Literal runat="server" Text="Nombre del rol" />
                                </label>
                                <asp:TextBox ID="txtRoleName" runat="server" CssClass="form-control" MaxLength="100"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvRoleName" runat="server" ControlToValidate="txtRoleName" ValidationGroup="RoleForm" CssClass="text-danger" ErrorMessage="El nombre del rol es obligatorio." Display="Dynamic" />
                            </div>

                            <div class="mb-3">
                                <label class="form-label" for="txtRoleDescription">
                                    <asp:Literal runat="server" Text="Descripción" />
                                </label>
                                <asp:TextBox ID="txtRoleDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="255"></asp:TextBox>
                            </div>

                            <div class="form-check form-switch mb-4">
                                <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label" for="chkIsActive">
                                    <asp:Literal runat="server" Text="Activo" />
                                </label>
                            </div>

                            <div class="row g-4">
                                <div class="col-md-6">
                                    <label class="form-label">
                                        <asp:Literal runat="server" Text="Permisos disponibles" />
                                    </label>
                                    <div class="permissions-container" id="permissionContainer">
                                        <asp:CheckBoxList ID="cblPermissions" runat="server" CssClass="list-unstyled"></asp:CheckBoxList>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">
                                        <asp:Literal runat="server" Text="Usuarios asignados" />
                                    </label>
                                    <div class="input-group mb-3">
                                        <span class="input-group-text"><i class="bi bi-person-search"></i></span>
                                        <asp:TextBox ID="txtAssignUsername" runat="server" CssClass="form-control" MaxLength="100" placeholder="Usuario"></asp:TextBox>
                                        <asp:LinkButton ID="btnAssignRole" runat="server" CssClass="btn btn-outline-primary" OnClick="btnAssignRole_Click">
                                            <i class="bi bi-person-plus"></i>
                                            <asp:Literal runat="server" Text="Asignar" />
                                        </asp:LinkButton>
                                    </div>
                                    <asp:Repeater ID="rptAssignedUsers" runat="server" OnItemCommand="rptAssignedUsers_ItemCommand" OnItemDataBound="rptAssignedUsers_ItemDataBound">
                                        <ItemTemplate>
                                            <div class="assigned-user-card d-flex justify-content-between align-items-center">
                                                <div class="me-3">
                                                    <strong><%# Eval("FullName") %></strong>
                                                    <div class="small text-muted">
                                                        <%# Eval("Username") %> · <%# Eval("Email") %>
                                                    </div>
                                                </div>
                                                <asp:LinkButton ID="btnRemoveUser" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="RemoveUser" CommandArgument='<%# Eval("UserId") %>'>
                                                    <i class="bi bi-x-lg"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <asp:Panel ID="pnlNoAssignedUsers" runat="server" CssClass="text-muted fst-italic" Visible="false">
                                        <asp:Literal runat="server" Text="No hay usuarios asignados a este rol." />
                                    </asp:Panel>
                                </div>
                            </div>
                        </div>
                        <div class="card-footer bg-white d-flex justify-content-end gap-2">
                            <asp:LinkButton ID="btnDeleteRole" runat="server" CssClass="btn btn-outline-danger" OnClick="btnDeleteRole_Click" Visible="false">
                                <i class="bi bi-trash"></i>
                                <asp:Literal runat="server" Text="Eliminar" />
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnSaveRole" runat="server" CssClass="btn btn-primary" OnClick="btnSaveRole_Click" ValidationGroup="RoleForm">
                                <i class="bi bi-save"></i>
                                <asp:Literal runat="server" Text="Guardar cambios" />
                            </asp:LinkButton>
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
