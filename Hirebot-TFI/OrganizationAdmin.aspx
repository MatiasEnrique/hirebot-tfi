<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OrganizationAdmin.aspx.cs" Inherits="Hirebot_TFI.OrganizationAdmin" MasterPageFile="~/Admin.master" %>
<%@ Register Src="~/Controls/ToastNotification.ascx" TagPrefix="uc" TagName="ToastNotification" %>

<asp:Content ID="OrgTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Administrador de Organización" />
</asp:Content>

<asp:Content ID="OrgHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .welcome-header { background: linear-gradient(135deg,#4b4e6d,#84dcc6); color:#fff; border-radius:.5rem; padding:1.5rem; margin-bottom:1rem; }
        .organization-card { background:#fff; border:1px solid #e5e7eb; border-radius:.75rem; padding:1rem; margin-bottom:1rem; box-shadow:0 0.15rem 1.75rem rgba(58,59,69,.15); }
        .search-filter-section { background:#fff; border-radius:.5rem; padding:1rem; box-shadow:0 0.15rem 1.75rem rgba(58,59,69,.15); margin-bottom:1rem; }
    </style>
</asp:Content>

<asp:Content ID="OrgMain" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel ID="upMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <uc:ToastNotification ID="ucToastNotification" runat="server" />

            <div class="welcome-header">
                <h1 class="mb-3"><i class="bi bi-building-gear me-3"></i><asp:Literal runat="server" Text="Administrador de Organización" /></h1>
                <p class="mb-0 fs-5"><asp:Literal runat="server" Text="Administra todas las organizaciones del sistema desde este panel. Puedes crear, editar y supervisar organizaciones y sus miembros." /></p>
            </div>

            <div class="search-filter-section">
                <div class="row g-3 align-items-end">
                    <div class="col-md-4">
                        <label for="txtSearch" class="form-label"><asp:Literal runat="server" Text="Buscar" /></label>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Buscar organizaciones..." />
                    </div>
                    <div class="col-md-2">
                        <label for="ddlPageSize" class="form-label"><asp:Literal runat="server" Text="Tamaño de página" /></label>
                        <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
                            <asp:ListItem Value="10">10</asp:ListItem>
                            <asp:ListItem Value="25">25</asp:ListItem>
                            <asp:ListItem Value="50">50</asp:ListItem>
                            <asp:ListItem Value="100">100</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-3">
                        <label for="ddlSortBy" class="form-label"><asp:Literal runat="server" Text="Ordenar por" /></label>
                        <asp:DropDownList ID="ddlSortBy" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSortBy_SelectedIndexChanged">
                            <asp:ListItem Value="Name" Text="Nombre de la Organización"></asp:ListItem>
                            <asp:ListItem Value="CreatedDate" Text="Fecha de Creación"></asp:ListItem>
                            <asp:ListItem Value="MemberCount" Text="Número de Miembros"></asp:ListItem>
                            <asp:ListItem Value="OwnerUsername" Text="Propietario"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-3">
                        <asp:Button ID="btnSearch" runat="server" Text="Buscar" CssClass="btn btn-primary me-2" OnClick="btnSearch_Click" />
                        <asp:Button ID="btnCreateNew" runat="server" Text="Crear Organización" CssClass="btn btn-success" OnClick="btnCreateNew_Click" />
                    </div>
                </div>
            </div>

            <asp:Repeater ID="rptOrganizations" runat="server" OnItemCommand="rptOrganizations_ItemCommand" OnItemDataBound="rptOrganizations_ItemDataBound">
                <ItemTemplate>
                    <div class="organization-card">
                        <div class="organization-header d-flex justify-content-between align-items-center">
                            <div>
                                <h4 class="mb-1"><%# Eval("Name") %></h4>
                                <small class="opacity-75"><i class="bi bi-link-45deg me-1"></i><%# Eval("Slug") %></small>
                            </div>
                            <div class="d-flex gap-2">
                                <asp:LinkButton ID="btnView" runat="server" CssClass="btn btn-sm btn-outline-secondary" CommandName="View" CommandArgument='<%# Eval("Id") %>'><i class="bi bi-eye me-1"></i><asp:Literal runat="server" Text="Ver" /></asp:LinkButton>
                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-sm btn-outline-primary" CommandName="Edit" CommandArgument='<%# Eval("Id") %>'><i class="bi bi-pencil me-1"></i><asp:Literal runat="server" Text="Editar" /></asp:LinkButton>
                                <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="Delete" CommandArgument='<%# Eval("Id") %>'><i class="bi bi-trash me-1"></i><asp:Literal runat="server" Text="Eliminar" /></asp:LinkButton>
                            </div>
                        </div>
                        <div class="mt-2 text-muted small">
                            <i class="bi bi-people me-1"></i><%# Eval("MemberCount") ?? 0 %> <asp:Literal runat="server" Text="Miembros" />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlNoOrganizations" runat="server" Visible="false" CssClass="text-center py-5">
                <i class="bi bi-building" style="font-size: 3rem; color: #95a3b3;"></i>
                <h4 class="mt-3"><asp:Literal runat="server" Text="No hay organizaciones disponibles" /></h4>
                <p class="text-muted"><asp:Literal runat="server" Text="Crea tu primera organización para comenzar" /></p>
            </asp:Panel>

            <div id="divPagination" runat="server">
                <nav aria-label="pagination">
                    <ul class="pagination">
                        <li class="page-item" id="liPrevious" runat="server">
                            <asp:LinkButton ID="lnkPrevious" runat="server" CssClass="page-link" OnClick="lnkPrevious_Click"><i class="bi bi-chevron-left"></i></asp:LinkButton>
                        </li>
                        <asp:Repeater ID="rptPagination" runat="server" OnItemCommand="rptPagination_ItemCommand">
                            <ItemTemplate>
                                <li class="page-item <%# (bool)Eval("IsActive") ? "active" : "" %>">
                                    <asp:LinkButton ID="lnkPage" runat="server" CssClass="page-link" CommandName="Page" CommandArgument='<%# Eval("PageNumber") %>'><%# Eval("PageNumber") %></asp:LinkButton>
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                        <li class="page-item" id="liNext" runat="server">
                            <asp:LinkButton ID="lnkNext" runat="server" CssClass="page-link" OnClick="lnkNext_Click"><i class="bi bi-chevron-right"></i></asp:LinkButton>
                        </li>
                    </ul>
                </nav>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <!-- Create/Edit Organization Modal -->
    <div class="modal fade" id="organizationModal" tabindex="-1" aria-labelledby="organizationModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <asp:UpdatePanel ID="upModal" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div class="modal-header">
                            <h5 class="modal-title" id="organizationModalLabel"><i class="bi bi-building me-2"></i><asp:Label ID="lblModalTitle" runat="server" Text="Crear Organización" /></h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <asp:HiddenField ID="hfOrganizationId" runat="server" />
                            <div class="row g-3">
                                <div class="col-md-8">
                                    <label for="txtModalName" class="form-label"><asp:Literal runat="server" Text="Nombre de la Organización" /> *</label>
                                    <asp:TextBox ID="txtModalName" runat="server" CssClass="form-control" MaxLength="100" placeholder="Ingresa el nombre de la organización" />
                                    <asp:RequiredFieldValidator ID="rfvModalName" runat="server" ControlToValidate="txtModalName" ErrorMessage="El nombre de la organización es obligatorio" CssClass="text-danger small" Display="Dynamic" ValidationGroup="OrganizationModal" />
                                </div>
                                <div class="col-md-4">
                                    <label for="chkModalActive" class="form-label"><asp:Literal runat="server" Text="Estado" /></label>
                                    <div class="form-check form-switch">
                                        <asp:CheckBox ID="chkModalActive" runat="server" CssClass="form-check-input" Checked="true" />
                                        <label class="form-check-label" for="chkModalActive"><asp:Literal runat="server" Text="Activo" /></label>
                                    </div>
                                </div>
                            </div>
                            <div class="row g-3 mt-1">
                                <div class="col-md-6">
                                    <label for="txtModalSlug" class="form-label"><asp:Literal runat="server" Text="Slug de la Organización" /> *</label>
                                    <asp:TextBox ID="txtModalSlug" runat="server" CssClass="form-control" MaxLength="50" placeholder="Ingresa el slug de la organización" />
                                    <div class="form-text"><asp:Literal runat="server" Text="Solo letras, números y guiones. Se usará en la URL de la organización." /></div>
                                    <asp:RequiredFieldValidator ID="rfvModalSlug" runat="server" ControlToValidate="txtModalSlug" ErrorMessage="El slug de la organización es obligatorio" CssClass="text-danger small" Display="Dynamic" ValidationGroup="OrganizationModal" />
                                </div>
                                <div class="col-md-6">
                                    <label for="ddlModalOwner" class="form-label"><asp:Literal runat="server" Text="Propietario" /> *</label>
                                    <asp:DropDownList ID="ddlModalOwner" runat="server" CssClass="form-select" />
                                </div>
                            </div>
                            <div class="row g-3 mt-1">
                                <div class="col-12">
                                    <label for="txtModalDescription" class="form-label"><asp:Literal runat="server" Text="Descripción de la Organización" /></label>
                                    <asp:TextBox ID="txtModalDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" MaxLength="500" placeholder="Ingresa la descripción de la organización (opcional)" />
                                    <small class="text-muted"><span id="charCount">0</span>/500 <asp:Literal runat="server" Text="caracteres" /></small>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"><asp:Literal runat="server" Text="Cancelar" /></button>
                            <asp:Button ID="btnModalSave" runat="server" CssClass="btn btn-primary" Text="Guardar" OnClick="btnModalSave_Click" ValidationGroup="OrganizationModal" />
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="OrgScripts" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        (function(){
            var desc=document.getElementById('<%= txtModalDescription.ClientID %>');
            var counter=document.getElementById('charCount');
            if(desc && counter){ desc.addEventListener('input', function(){ counter.textContent = (this.value||'').length; }); }
        })();

        function showOrganizationModal() {
            var modal = new bootstrap.Modal(document.getElementById('organizationModal'));
            modal.show();
        }

        function hideOrganizationModal() {
            var modalEl = document.getElementById('organizationModal');
            var modal = bootstrap.Modal.getInstance(modalEl);
            if (modal) {
                modal.hide();
            }
        }
    </script>
</asp:Content>

