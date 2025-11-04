<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChatbotAdmin.aspx.cs" Inherits="Hirebot_TFI.ChatbotAdmin" MasterPageFile="~/Admin.master" %>
<%@ Register Src="~/Controls/ToastNotification.ascx" TagPrefix="uc" TagName="ToastNotification" %>

<asp:Content ID="ChatbotTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Administración de Chatbots" />
</asp:Content>

<asp:Content ID="ChatbotHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-header { margin-bottom: 1rem; }
        .filter-panel { background: #fff; border-radius: .5rem; padding: 1rem; box-shadow: 0 0.15rem 1.75rem rgba(58,59,69,.15); margin-bottom: 1rem; }
        .data-grid-container .chatbot-card { border:1px solid #e5e7eb; border-radius:.75rem; padding:1rem; margin-bottom:1rem; background:#fff; }
        .loading-overlay { position:absolute; top:0; left:0; right:0; bottom:0; background:rgba(255,255,255,.6); display:flex; align-items:center; justify-content:center; }
        .loading-spinner { width:2rem; height:2rem; border:.25rem solid #dee2e6; border-top-color:#4b4e6d; border-radius:50%; animation:spin 1s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
    </style>
</asp:Content>

<asp:Content ID="ChatbotMain" ContentPlaceHolderID="MainContent" runat="server">
    <uc:ToastNotification ID="ucToastNotification" runat="server" />

    <div class="chatbot-admin-container">
        <div class="container-fluid">
            <div class="admin-header">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h1>
                            <i class="bi bi-robot me-3"></i>
                            <asp:Literal runat="server" Text="Administración de Chatbots" />
                        </h1>
                        <p><asp:Literal runat="server" Text="Gestiona todos los chatbots del sistema, incluyendo creación, edición, eliminación y asignación organizacional." /></p>
                    </div>
                    <div>
                        <button type="button" class="btn btn-success btn-lg" data-bs-toggle="modal" data-bs-target="#chatbotModal" onclick="openCreateModal()">
                            <i class="bi bi-plus-circle me-2"></i>
                            <asp:Literal runat="server" Text="Crear Chatbot" />
                        </button>
                    </div>
                </div>
            </div>

            <div class="filter-panel">
                <h5><i class="bi bi-funnel me-2"></i><asp:Literal runat="server" Text="Filtros" /></h5>
                <asp:UpdatePanel ID="upFilters" runat="server">
                    <ContentTemplate>
                        <div class="row g-3 align-items-end">
                            <div class="col-md-4">
                                <label for="<%= ddlOrganizationFilter.ClientID %>" class="form-label"><asp:Literal runat="server" Text="Organización" /></label>
                                <asp:DropDownList ID="ddlOrganizationFilter" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlOrganizationFilter_SelectedIndexChanged">
                                    <asp:ListItem Value="" Text="Todas las Organizaciones" />
                                    <asp:ListItem Value="-1" Text="Chatbots Sin Asignar" />
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-3">
                                <label for="<%= ddlStatusFilter.ClientID %>" class="form-label"><asp:Literal runat="server" Text="Estado" /></label>
                                <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                                    <asp:ListItem Value="" Text="Todos los Estados" />
                                    <asp:ListItem Value="true" Text="Activo" />
                                    <asp:ListItem Value="false" Text="Inactivo" />
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-4">
                                <label for="<%= txtSearchFilter.ClientID %>" class="form-label"><asp:Literal runat="server" Text="Buscar" /></label>
                                <div class="input-group">
                                    <asp:TextBox ID="txtSearchFilter" runat="server" CssClass="form-control" placeholder="Buscar por nombre..." onkeyup="handleSearchKeyUp(event);" />
                                    <asp:Button ID="btnSearch" runat="server" Text="Buscar" CssClass="btn btn-primary" OnClick="btnSearch_Click" />
                                </div>
                            </div>
                            <div class="col-md-1">
                                <label class="form-label">&nbsp;</label>
                                <asp:Button ID="btnClearSearch" runat="server" Text="Limpiar" CssClass="btn btn-secondary w-100" OnClick="btnClearSearch_Click" />
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>

            <div class="data-grid-container position-relative">
                <asp:UpdatePanel ID="upDataGrid" runat="server">
                    <ContentTemplate>
                        <div id="loadingOverlay" class="loading-overlay d-none"><div class="loading-spinner"></div></div>
                        <asp:Repeater ID="rptChatbots" runat="server" OnItemCommand="rptChatbots_ItemCommand" OnItemDataBound="rptChatbots_ItemDataBound">
                            <ItemTemplate>
                                <div class="chatbot-card">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="rounded-circle" style="width:36px;height:36px;background:<%# Eval("Color") ?? "#222222" %>"></div>
                                            <div>
                                                <div class="fw-bold"><%# Eval("Name") %></div>
                                                <div class="text-muted small"><%# Eval("OrganizationName") ?? HttpContext.GetGlobalResourceObject("GlobalResources","UnassignedChatbot") %></div>
                                            </div>
                                        </div>
                                        <div class="d-flex gap-2">
                                            <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-sm btn-outline-primary" CommandName="Edit" CommandArgument='<%# Eval("ChatbotId") %>'><i class="bi bi-pencil"></i></asp:LinkButton>
                                            <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="Delete" CommandArgument='<%# Eval("ChatbotId") %>'><i class="bi bi-trash"></i></asp:LinkButton>
                                            <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#assignModal" onclick="prepareAssign(<%# Eval("ChatbotId") %>)">
                                                <i class="bi bi-building-gear"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <nav aria-label="pagination">
                            <ul class="pagination">
                                <asp:Repeater ID="rptPagination" runat="server" OnItemCommand="rptPagination_ItemCommand">
                                    <ItemTemplate>
                                        <li class="page-item <%# (bool)Eval("IsActive") ? "active" : "" %>">
                                            <asp:LinkButton ID="btnPage" runat="server" CssClass="page-link" CommandName="Page" CommandArgument='<%# Eval("PageNumber") %>'><%# Eval("PageNumber") %></asp:LinkButton>
                                        </li>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </ul>
                        </nav>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>

    <!-- Create/Edit Chatbot Modal -->
    <div class="modal fade" id="chatbotModal" tabindex="-1" aria-labelledby="chatbotModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <asp:UpdatePanel ID="upModal" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div class="modal-header">
                            <h5 class="modal-title" id="chatbotModalLabel"><i class="bi bi-robot me-2"></i><asp:Literal runat="server" Text="Detalles del Chatbot" /></h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label for="txtChatbotName" class="form-label"><asp:Literal runat="server" Text="Nombre del Chatbot" /></label>
                                    <asp:TextBox ID="txtChatbotName" runat="server" CssClass="form-control" />
                                    <asp:RequiredFieldValidator ID="rfvChatbotName" runat="server" ControlToValidate="txtChatbotName" ErrorMessage="El nombre del chatbot es requerido." CssClass="text-danger small" Display="Dynamic" ValidationGroup="ChatbotModal" />
                                </div>
                                <div class="col-md-6">
                                    <label for="txtColorHex" class="form-label"><asp:Literal runat="server" Text="Color del Chatbot" /></label>
                                    <asp:TextBox ID="txtColorHex" runat="server" CssClass="form-control" MaxLength="7" />
                                </div>
                                <div class="col-12">
                                    <label for="txtInstructions" class="form-label"><asp:Literal runat="server" Text="Instrucciones del Chatbot" /></label>
                                    <asp:TextBox ID="txtInstructions" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control" />
                                </div>
                                <div class="col-md-6">
                                    <label for="<%= ddlOrganization.ClientID %>" class="form-label"><asp:Literal runat="server" Text="Organización" /></label>
                                    <asp:DropDownList ID="ddlOrganization" runat="server" CssClass="form-select">
                                        <asp:ListItem Value="" Text="Chatbot sin asignar" />
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <asp:HiddenField ID="hfSelectedColor" runat="server" Value="#222222" />
                            <asp:HiddenField ID="hfChatbotId" runat="server" Value="0" />
                            <asp:HiddenField ID="hfModalMode" runat="server" Value="create" />
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"><i class="bi bi-x-circle me-1"></i><asp:Literal runat="server" Text="Cancelar" /></button>
                            <asp:Button ID="btnSaveChatbot" runat="server" Text="Guardar" CssClass="btn btn-primary" OnClick="btnSaveChatbot_Click" ValidationGroup="ChatbotModal" />
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>

    <!-- Assign Organization Modal -->
    <div class="modal fade" id="assignModal" tabindex="-1" aria-labelledby="assignModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="assignModalLabel"><i class="bi bi-building-gear me-2"></i><asp:Literal runat="server" Text="Asignar a Organización" /></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:UpdatePanel ID="upAssignModal" runat="server">
                        <ContentTemplate>
                            <div class="mb-3">
                                <label for="<%= ddlAssignOrganization.ClientID %>" class="form-label"><asp:Literal runat="server" Text="Seleccionar Organización" /></label>
                                <asp:DropDownList ID="ddlAssignOrganization" runat="server" CssClass="form-select" />
                            </div>
                            <asp:HiddenField ID="hfAssignChatbotId" runat="server" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"><i class="bi bi-x-circle me-1"></i><asp:Literal runat="server" Text="Cancelar" /></button>
                    <asp:UpdatePanel ID="upAssignFooter" runat="server">
                        <ContentTemplate>
                            <asp:Button ID="btnConfirmAssign" runat="server" Text="Asignar" CssClass="btn btn-primary" OnClick="btnConfirmAssign_Click" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="ChatbotScripts" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        function handleSearchKeyUp(e){ if(e.key==='Enter'){ document.getElementById('<%= btnSearch.ClientID %>').click(); } }
        function openCreateModal(){
            try{
                var hfChatbotId=document.getElementById('<%= hfChatbotId.ClientID %>'); if(hfChatbotId) hfChatbotId.value='0';
                var btnSave=document.getElementById('<%= btnSaveChatbot.ClientID %>'); if(btnSave) btnSave.innerText='<%= GetGlobalResourceObject("GlobalResources","Create") %>';
                var modal=new bootstrap.Modal(document.getElementById('chatbotModal')); modal.show();
            }catch(err){ console.error(err); }
        }
        function showChatbotModal(){ try{ new bootstrap.Modal(document.getElementById('chatbotModal')).show(); }catch(e){} }
        function prepareAssign(id){ var hf=document.getElementById('<%= hfAssignChatbotId.ClientID %>'); if(hf) hf.value=id; }
    </script>
</asp:Content>

