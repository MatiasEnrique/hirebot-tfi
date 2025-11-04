<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminNews.aspx.cs" Inherits="Hirebot_TFI.AdminNews" MasterPageFile="~/Admin.master" %>

<asp:Content ID="AdminNewsTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Gestión de noticias" />
</asp:Content>

<asp:Content ID="AdminNewsHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-title {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
        }

        .admin-title .bi-newspaper {
            font-size: 1.5rem;
            color: #4b4e6d;
        }

        .filter-card,
        .summary-card,
        .table-card {
            border-radius: 1rem;
            box-shadow: 0 0.5rem 1.5rem rgba(15, 23, 42, 0.08);
            border: none;
        }

        .filter-card .card-header,
        .summary-card .card-header,
        .table-card .card-header {
            border-bottom: 1px solid rgba(15, 23, 42, 0.08);
            background-color: #ffffff;
            border-radius: 1rem 1rem 0 0;
        }

        .table-card .badge-status {
            padding: 0.35rem 0.75rem;
            border-radius: 999px;
            font-size: 0.75rem;
        }

        .summary-value {
            font-weight: 600;
            font-size: 1.75rem;
        }

        .newsletter-summary-badge {
            border-radius: 999px;
            padding: 0.35rem 0.75rem;
            font-size: 0.75rem;
        }

        .btn-primary {
            background-color: #4b4e6d;
            border-color: #4b4e6d;
        }

        .btn-primary:hover {
            background-color: #84dcc6;
            border-color: #84dcc6;
            color: #222222;
        }

        .btn-outline-primary {
            border-color: #4b4e6d;
            color: #4b4e6d;
        }

        .btn-outline-primary:hover {
            background-color: #4b4e6d;
            color: #ffffff;
        }
    </style>
</asp:Content>

<asp:Content ID="AdminNewsMain" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlAlert" runat="server" CssClass="alert alert-dismissible fade show" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <div class="admin-title">
        <i class="bi bi-newspaper"></i>
        <div>
            <h2 class="mb-0"><asp:Literal runat="server" Text="Gestión de noticias" /></h2>
            <small class="text-muted"><asp:Literal runat="server" Text="Gestiona las novedades del sitio y el newsletter oficial." /></small>
        </div>
    </div>

    <div class="card filter-card mb-4">
        <div class="card-header d-flex flex-wrap justify-content-between align-items-center gap-2">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-funnel text-primary"></i>
                <strong><asp:Literal runat="server" Text="Buscar" /></strong>
            </div>
            <asp:Button ID="btnCreateNews" runat="server" CssClass="btn btn-primary" Text="Crear noticia" UseSubmitBehavior="false" CausesValidation="false" OnClientClick="return openCreateNewsModal();" />
        </div>
        <div class="card-body">
            <div class="row g-3 align-items-end">
                <div class="col-md-4">
                    <label for="txtSearch" class="form-label text-secondary"><asp:Literal runat="server" Text="Palabra clave" /></label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="150" placeholder="Buscar por título o contenido" />
                </div>
                <div class="col-md-3">
                    <label for="ddlStatusFilter" class="form-label text-secondary"><asp:Literal runat="server" Text="Estado" /></label>
                    <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select">
                        <asp:ListItem Value="All" Text="Todos" />
                        <asp:ListItem Value="Published" Text="Publicadas" />
                        <asp:ListItem Value="Unpublished" Text="No publicadas" />
                        <asp:ListItem Value="Archived" Text="Archivadas" />
                    </asp:DropDownList>
                </div>
                <div class="col-md-3">
                    <label for="ddlLanguageFilter" class="form-label text-secondary"><asp:Literal runat="server" Text="Idioma" /></label>
                    <asp:DropDownList ID="ddlLanguageFilter" runat="server" CssClass="form-select" />
                </div>
                <div class="col-md-2 d-flex gap-2">
                    <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-outline-primary w-100" Text="Buscar" OnClick="btnSearch_Click" />
                    <asp:Button ID="btnClearFilters" runat="server" CssClass="btn btn-outline-secondary w-100" Text="Restablecer" OnClick="btnClearFilters_Click" CausesValidation="false" />
                </div>
            </div>
            <div class="d-flex justify-content-between align-items-center mt-4">
                <span class="text-muted small"><asp:Literal ID="litNewsCount" runat="server" /></span>
            </div>
        </div>
    </div>

    <div class="card table-card mb-4">
        <div class="card-body">
            <div class="table-responsive">
                <asp:GridView ID="gvNews" runat="server" CssClass="table table-hover align-middle" AutoGenerateColumns="false" DataKeyNames="NewsId" OnRowCommand="gvNews_RowCommand" OnRowDataBound="gvNews_RowDataBound" EmptyDataText="No se encontraron noticias con los filtros seleccionados.">
                    <Columns>
                        <asp:TemplateField HeaderText="Título" ItemStyle-Width="35%">
                            <ItemTemplate>
                                <div class="fw-semibold text-dark"><%#: Eval("Title") %></div>
                                <div class="text-muted small"><%#: Eval("Summary") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Idioma" ItemStyle-Width="10%">
                            <ItemTemplate>
                                <span class="badge bg-light text-dark"><%#: Eval("LanguageCode") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Fecha de publicación" ItemStyle-Width="15%">
                            <ItemTemplate>
                                <asp:Label ID="lblPublishedDate" runat="server" CssClass="small text-secondary" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Estado" ItemStyle-Width="15%">
                            <ItemTemplate>
                                <span class="badge-status" runat="server" id="badgeStatus"></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Última actualización" ItemStyle-Width="15%">
                            <ItemTemplate>
                                <asp:Label ID="lblUpdatedDate" runat="server" CssClass="small text-secondary" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Acciones" ItemStyle-CssClass="text-end" ItemStyle-Width="20%">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkEdit" runat="server" CssClass="btn btn-sm btn-outline-primary me-2" CommandName="EditNews" CommandArgument='<%# Eval("NewsId") %>' Text="Editar" />
                                <asp:LinkButton ID="lnkTogglePublish" runat="server" CssClass="btn btn-sm btn-outline-success me-2" CommandName="TogglePublish" CommandArgument='<%# string.Format("{0}|{1}|{2}", Eval("NewsId"), Eval("IsPublished"), Eval("IsArchived")) %>' Text="Publicar" />
                                <asp:LinkButton ID="lnkArchive" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="ArchiveNews" CommandArgument='<%# Eval("NewsId") %>' Text="Archivar" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <div class="row g-4 mb-5">
        <div class="col-12 col-lg-4">
            <div class="card summary-card h-100">
                <div class="card-header">
                    <h6 class="mb-0"><i class="bi bi-envelope-open me-2 text-primary"></i><asp:Literal runat="server" Text="Resumen del newsletter" /></h6>
                </div>
                <div class="card-body">
                    <div class="d-flex flex-column gap-3">
                        <div>
                            <span class="text-muted d-block"><asp:Literal runat="server" Text="Suscriptores totales" /></span>
                            <h4 class="mb-0 summary-value"><asp:Literal ID="litTotalSubscribers" runat="server" /></h4>
                        </div>
                        <div class="d-flex justify-content-between">
                            <div>
                                <span class="newsletter-summary-badge bg-success-subtle text-success"><asp:Literal runat="server" Text="Activo" /></span>
                                <h5 class="mt-1 mb-0"><asp:Literal ID="litActiveSubscribers" runat="server" /></h5>
                            </div>
                            <div>
                                <span class="newsletter-summary-badge bg-secondary-subtle text-secondary"><asp:Literal runat="server" Text="Inactivo" /></span>
                                <h5 class="mt-1 mb-0"><asp:Literal ID="litInactiveSubscribers" runat="server" /></h5>
                            </div>
                        </div>
                        <div>
                            <span class="text-muted d-block"><asp:Literal runat="server" Text="Suscriptores últimos 30 días" /></span>
                            <h5 class="mb-0 text-primary"><asp:Literal ID="litRecentSubscribers" runat="server" /></h5>
                        </div>
                        <asp:Button ID="btnRefreshSummary" runat="server" CssClass="btn btn-outline-secondary btn-sm" Text="Actualizar" OnClick="btnRefreshSummary_Click" />
                    </div>
                </div>
            </div>
        </div>
        <div class="col-12 col-lg-8">
            <div class="card table-card h-100">
                <div class="card-header d-flex flex-wrap align-items-center gap-2 justify-content-between">
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-people text-primary"></i>
                        <strong><asp:Literal runat="server" Text="Suscriptores" /></strong>
                    </div>
                    <div class="d-flex flex-wrap gap-2">
                        <asp:TextBox ID="txtSubscriberSearch" runat="server" CssClass="form-control form-control-sm" MaxLength="150" placeholder="Buscar por correo" />
                        <asp:DropDownList ID="ddlSubscriberStatus" runat="server" CssClass="form-select form-select-sm">
                            <asp:ListItem Value="All" Text="Todos" />
                            <asp:ListItem Value="Active" Text="Activo" />
                            <asp:ListItem Value="Inactive" Text="Inactivo" />
                        </asp:DropDownList>
                        <asp:Button ID="btnSearchSubscribers" runat="server" CssClass="btn btn-outline-primary btn-sm" Text="Buscar" OnClick="btnSearchSubscribers_Click" />
                        <asp:Button ID="btnClearSubscribers" runat="server" CssClass="btn btn-outline-secondary btn-sm" Text="Restablecer" OnClick="btnClearSubscribers_Click" CausesValidation="false" />
                    </div>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <asp:GridView ID="gvSubscribers" runat="server" CssClass="table table-sm table-striped align-middle" AutoGenerateColumns="false" DataKeyNames="SubscriptionId" OnRowCommand="gvSubscribers_RowCommand" EmptyDataText="No se encontraron suscriptores.">
                            <Columns>
                                <asp:BoundField DataField="Email" HeaderText="Correo Electrónico" />
                                <asp:TemplateField HeaderText="Idioma">
                                    <ItemTemplate>
                                        <span class="badge bg-light text-dark"><%#: Eval("LanguageCode") %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Estado">
                                    <ItemTemplate>
                                        <span class="badge" runat="server" id="badgeSubscriberStatus"></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Suscripto el">
                                    <ItemTemplate>
                                        <asp:Label ID="lblSubscribedOn" runat="server" CssClass="small text-secondary"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Acciones" ItemStyle-CssClass="text-end">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkUnsubscribe" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="Unsubscribe" CommandArgument='<%# Eval("Email") %>' Text="Eliminar" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="newsModal" tabindex="-1" aria-labelledby="newsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="newsModalLabel"><asp:Literal ID="litNewsModalTitle" runat="server" /></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfEditingNewsId" runat="server" />
                    <asp:HiddenField ID="hfOpenNewsModal" runat="server" Value="0" />
                    <asp:HiddenField ID="hfCreateModalTitle" runat="server" Value="Crear noticia" />
                    <div class="mb-3">
                        <label for="txtNewsTitle" class="form-label"><asp:Literal runat="server" Text="Título" /></label>
                        <asp:TextBox ID="txtNewsTitle" runat="server" CssClass="form-control" MaxLength="200" />
                        <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtNewsTitle" CssClass="text-danger small" Display="Dynamic" ErrorMessage="El título es obligatorio." ValidationGroup="NewsModal" />
                    </div>
                    <div class="mb-3">
                        <label for="txtNewsSummary" class="form-label"><asp:Literal runat="server" Text="Resumen" /></label>
                        <asp:TextBox ID="txtNewsSummary" runat="server" CssClass="form-control" MaxLength="500" TextMode="MultiLine" Rows="3" />
                    </div>
                    <div class="mb-3">
                        <label for="txtNewsContent" class="form-label"><asp:Literal runat="server" Text="Contenido" /></label>
                        <asp:TextBox ID="txtNewsContent" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="10" />
                        <asp:RequiredFieldValidator ID="rfvContent" runat="server" ControlToValidate="txtNewsContent" CssClass="text-danger small" Display="Dynamic" ErrorMessage="El contenido es obligatorio." ValidationGroup="NewsModal" />
                    </div>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label for="ddlNewsLanguage" class="form-label"><asp:Literal runat="server" Text="Idioma" /></label>
                            <asp:DropDownList ID="ddlNewsLanguage" runat="server" CssClass="form-select" />
                        </div>
                        <div class="col-md-4">
                            <label for="txtPublishedDate" class="form-label"><asp:Literal runat="server" Text="Fecha de publicación" /></label>
                            <asp:TextBox ID="txtPublishedDate" runat="server" CssClass="form-control" />
                            <small class="text-muted"><asp:Literal runat="server" Text="Opcional" /></small>
                        </div>
                        <div class="col-md-4 d-flex align-items-center">
                            <div class="form-check mt-3">
                                <asp:CheckBox ID="chkNewsPublish" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label" for="chkNewsPublish"><asp:Literal runat="server" Text="Publicar inmediatamente" /></label>
                            </div>
                        </div>
                    </div>
                    <asp:Label ID="lblModalError" runat="server" CssClass="text-danger small d-block mt-3" Visible="false" />
                </div>
                <div class="modal-footer">
                    <asp:Button ID="btnSaveNews" runat="server" CssClass="btn btn-primary" Text="Guardar" OnClick="btnSaveNews_Click" ValidationGroup="NewsModal" />
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"><asp:Literal runat="server" Text="Cancelar" /></button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="AdminNewsScripts" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            handleNewsModalAutoOpen();

            if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                    handleNewsModalAutoOpen();
                });
            }
        });

        function handleNewsModalAutoOpen() {
            var flagField = document.getElementById('<%= hfOpenNewsModal.ClientID %>');
            if (flagField && flagField.value === '1') {
                showNewsModal();
                flagField.value = '0';
            }
        }

        function resetNewsModalFields() {
            var titleInput = document.getElementById('<%= txtNewsTitle.ClientID %>');
            var summaryInput = document.getElementById('<%= txtNewsSummary.ClientID %>');
            var contentInput = document.getElementById('<%= txtNewsContent.ClientID %>');
            var languageSelect = document.getElementById('<%= ddlNewsLanguage.ClientID %>');
            var publishDateInput = document.getElementById('<%= txtPublishedDate.ClientID %>');
            var publishCheckbox = document.getElementById('<%= chkNewsPublish.ClientID %>');
            var errorLabel = document.getElementById('<%= lblModalError.ClientID %>');

            if (titleInput) { titleInput.value = ''; }
            if (summaryInput) { summaryInput.value = ''; }
            if (contentInput) { contentInput.value = ''; }
            if (languageSelect && languageSelect.options.length > 0) { languageSelect.selectedIndex = 0; }
            if (publishDateInput) { publishDateInput.value = ''; }
            if (publishCheckbox) { publishCheckbox.checked = false; }
            if (errorLabel) {
                errorLabel.textContent = '';
                errorLabel.style.display = 'none';
                errorLabel.classList.remove('d-block');
            }
        }

        function openCreateNewsModal() {
            resetNewsModalFields();

            var modalTitle = document.getElementById('<%= litNewsModalTitle.ClientID %>');
            var createTitle = document.getElementById('<%= hfCreateModalTitle.ClientID %>');
            var editIdField = document.getElementById('<%= hfEditingNewsId.ClientID %>');
            var flagField = document.getElementById('<%= hfOpenNewsModal.ClientID %>');

            if (modalTitle && createTitle) {
                modalTitle.textContent = createTitle.value;
            }
            if (editIdField) {
                editIdField.value = '0';
            }
            if (flagField) {
                flagField.value = '0';
            }

            showNewsModal();
            return false;
        }

        function showNewsModal() {
            var modalEl = document.getElementById('newsModal');
            if (!modalEl) {
                return;
            }
            var modal = bootstrap.Modal.getInstance(modalEl);
            if (!modal) {
                modal = new bootstrap.Modal(modalEl);
            }
            modal.show();
        }

        function hideNewsModal() {
            var modalEl = document.getElementById('newsModal');
            if (!modalEl) {
                return;
            }
            var modal = bootstrap.Modal.getInstance(modalEl);
            if (modal) {
                modal.hide();
            }
        }

        function showAlert(type) {
            const panel = document.getElementById('<%= pnlAlert.ClientID %>');
            if (!panel) {
                return;
            }
            panel.classList.remove('d-none');
            panel.classList.remove('alert-success', 'alert-danger', 'alert-info', 'alert-warning');
            panel.classList.add('alert-' + type);
            panel.classList.add('d-block');
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
    </script>
</asp:Content>
