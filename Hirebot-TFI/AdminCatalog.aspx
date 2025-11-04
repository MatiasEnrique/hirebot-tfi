<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminCatalog.aspx.cs" Inherits="UI.AdminCatalog" MasterPageFile="~/Admin.master" %>

<asp:Content ID="CatalogTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Gestión de Catálogos" />
</asp:Content>

<asp:Content ID="CatalogHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-section { background-color: #ffffff; border: 1px solid #dee2e6; border-radius: 0.375rem; box-shadow: 0 0.125rem 0.25rem rgba(0,0,0,0.075); }
        .nav-tabs .nav-link { color: #4b4e6d; }
        .nav-tabs .nav-link.active { background-color: #4b4e6d; border-color: #4b4e6d; color: #fff; }
        .nav-tabs .nav-link:hover { color: #84dcc6; }
        .tab-pane { min-height: 400px; }
        .form-label { font-weight: 600; color: #222222; }
        .table thead th { background-color: #4b4e6d; color: #fff; }
        .table tbody tr:hover { background-color: rgba(132, 220, 198, 0.1); }
    </style>
</asp:Content>

<asp:Content ID="CatalogMain" ContentPlaceHolderID="MainContent" runat="server">
    <asp:HiddenField ID="hfDeleteMessage" runat="server" />
    <asp:HiddenField ID="hfSelectedProductId" runat="server" Value="0" />
    <asp:HiddenField ID="hfSelectedCatalogId" runat="server" Value="0" />

    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <h1 class="mb-4">
                    <i class="bi bi-gear-fill me-2"></i>
                    <asp:Literal runat="server" Text="Panel de Administración" />
                </h1>

                <div id="alertContainer" class="position-fixed" style="bottom: 20px; right: 20px; z-index: 1050; max-width: 400px;">
                    <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none alert-dismissible fade show" role="alert"></asp:Label>
                </div>
            </div>
        </div>
    </div>

    <!-- Navigation tabs -->
    <ul class="nav nav-tabs mb-4" id="adminTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="products-tab" data-bs-toggle="tab" data-bs-target="#products-pane" type="button" role="tab">
                <i class="bi bi-box-seam me-2"></i><asp:Literal runat="server" Text="Gestión de Productos" />
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="catalogs-tab" data-bs-toggle="tab" data-bs-target="#catalogs-pane" type="button" role="tab">
                <i class="bi bi-collection me-2"></i><asp:Literal runat="server" Text="Gestión de Catálogos" />
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="catalog-products-tab" data-bs-toggle="tab" data-bs-target="#catalog-products-pane" type="button" role="tab">
                <i class="bi bi-plus-circle me-2"></i><asp:Literal runat="server" Text="Agregar Producto al Catálogo" />
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="display-catalog-tab" data-bs-toggle="tab" data-bs-target="#display-catalog-pane" type="button" role="tab">
                <i class="bi bi-eye me-2"></i><asp:Literal runat="server" Text="Gestión de Catálogo Mostrado" />
            </button>
        </li>
    </ul>

    <div class="tab-content" id="adminTabContent">
        <!-- Products Tab -->
        <div class="tab-pane fade show active" id="products-pane" role="tabpanel">
            <div class="admin-section p-4 mb-4">
                <h3 class="mb-3"><i class="bi bi-box-seam me-2"></i><asp:Literal runat="server" Text="Gestión de Productos" /></h3>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label for="txtProductName" class="form-label"><asp:Literal runat="server" Text="Nombre del Producto" /></label>
                        <asp:TextBox ID="txtProductName" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="col-md-6">
                        <label for="ddlProductCategory" class="form-label"><asp:Literal runat="server" Text="Categoría" /></label>
                        <asp:DropDownList ID="ddlProductCategory" runat="server" CssClass="form-select">
                            <asp:ListItem Text="SaaS" Value="SaaS" />
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-md-4">
                        <label for="txtProductPrice" class="form-label"><asp:Literal runat="server" Text="Precio" /></label>
                        <asp:TextBox ID="txtProductPrice" runat="server" CssClass="form-control" TextMode="Number" Step="0.01"></asp:TextBox>
                    </div>
                    <div class="col-md-4">
                        <label for="ddlBillingCycle" class="form-label"><asp:Literal runat="server" Text="Ciclo de facturación" /></label>
                        <asp:DropDownList ID="ddlBillingCycle" runat="server" CssClass="form-select">
                            <asp:ListItem Text="Monthly" Value="Monthly" />
                            <asp:ListItem Text="Yearly" Value="Yearly" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-4">
                        <label for="txtMaxChatbots" class="form-label"><asp:Literal runat="server" Text="Chatbots máx." /></label>
                        <asp:TextBox ID="txtMaxChatbots" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label for="txtMaxMessages" class="form-label"><asp:Literal runat="server" Text="Mensajes/Mes máx." /></label>
                        <asp:TextBox ID="txtMaxMessages" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                    </div>
                    <div class="col-md-6 d-flex align-items-end">
                        <div class="form-check">
                            <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input me-2" />
                            <label for="chkIsActive" class="form-check-label"><asp:Literal runat="server" Text="Activo" /></label>
                        </div>
                    </div>
                </div>

                <div class="mb-3">
                    <asp:Button ID="btnCreateProduct" runat="server" CssClass="btn btn-success me-2" Text="Crear Producto" OnClick="btnCreateProduct_Click" />
                    <asp:Button ID="btnUpdateProduct" runat="server" CssClass="btn btn-primary me-2" Text="Actualizar Producto" OnClick="btnUpdateProduct_Click" />
                    <asp:Button ID="btnDeleteProduct" runat="server" CssClass="btn btn-danger me-2 delete-btn" Text="Eliminar Producto" />
                    <asp:Button ID="btnCancelEditProduct" runat="server" CssClass="btn btn-secondary" Text="Cancelar Edición" OnClick="btnCancelEditProduct_Click" Visible="false" />
                </div>

                <asp:GridView ID="gvProducts" runat="server" CssClass="table table-striped table-hover" AutoGenerateColumns="false" OnRowCommand="gvProducts_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="ProductId" HeaderText="ID" />
                        <asp:BoundField DataField="Name" HeaderText="Nombre del Producto" />
                        <asp:BoundField DataField="Category" HeaderText="Categoría" />
                        <asp:BoundField DataField="Price" HeaderText="Precio" DataFormatString="ARS {0:N2}" />
                        <asp:BoundField DataField="BillingCycle" HeaderText="Ciclo de facturación" />
                        <asp:BoundField DataField="MaxChatbots" HeaderText="Chatbots máx." />
                        <asp:BoundField DataField="MaxMessagesPerMonth" HeaderText="Mensajes/Mes máx." />
                        <asp:CheckBoxField DataField="IsActive" HeaderText="Activo" />
                        <asp:TemplateField HeaderText="Acciones">
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
                <h3 class="mb-3"><i class="bi bi-collection me-2"></i><asp:Literal runat="server" Text="Gestión de Catálogos" /></h3>

                <div class="mb-3">
                    <label for="txtCatalogName" class="form-label"><asp:Literal runat="server" Text="Nombre del Catálogo" /></label>
                    <asp:TextBox ID="txtCatalogName" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="mb-3">
                    <label for="txtCatalogDescription" class="form-label"><asp:Literal runat="server" Text="Descripción" /></label>
                    <asp:TextBox ID="txtCatalogDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                </div>
                <div class="mb-3">
                    <asp:CheckBox ID="chkCatalogIsActive" runat="server" CssClass="form-check-input me-2" />
                    <label for="chkCatalogIsActive" class="form-check-label"><asp:Literal runat="server" Text="Activo" /></label>
                </div>
                <div class="mb-3">
                    <asp:Button ID="btnCreateCatalog" runat="server" CssClass="btn btn-success me-2" Text="Crear Catálogo" OnClick="btnCreateCatalog_Click" />
                    <asp:Button ID="btnUpdateCatalog" runat="server" CssClass="btn btn-primary me-2" Text="Actualizar Catálogo" OnClick="btnUpdateCatalog_Click" />
                    <asp:Button ID="btnDeleteCatalog" runat="server" CssClass="btn btn-danger me-2" Text="Eliminar Catálogo" OnClick="btnDeleteCatalog_Click" />
                    <asp:Button ID="btnCancelEditCatalog" runat="server" CssClass="btn btn-secondary" Text="Cancelar Edición" OnClick="btnCancelEditCatalog_Click" Visible="false" />
                </div>
                <asp:GridView ID="gvCatalogs" runat="server" CssClass="table table-striped table-hover" AutoGenerateColumns="false" OnRowCommand="gvCatalogs_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="CatalogId" HeaderText="ID" />
                        <asp:BoundField DataField="Name" HeaderText="Nombre del Catálogo" />
                        <asp:CheckBoxField DataField="IsActive" HeaderText="Activo" />
                        <asp:TemplateField HeaderText="Acciones">
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

        <!-- Add Product to Catalog Tab -->
        <div class="tab-pane fade" id="catalog-products-pane" role="tabpanel">
            <div class="admin-section p-4 mb-4">
                <h3 class="mb-3"><i class="bi bi-plus-circle me-2"></i><asp:Literal runat="server" Text="Agregar Producto al Catálogo" /></h3>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label for="ddlCatalogSelect" class="form-label"><asp:Literal runat="server" Text="Seleccionar Catálogo" /></label>
                        <asp:DropDownList ID="ddlCatalogSelect" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlCatalogSelect_SelectedIndexChanged"></asp:DropDownList>
                    </div>
                    <div class="col-md-6">
                        <label for="ddlProductSelect" class="form-label"><asp:Literal runat="server" Text="Seleccionar Producto" /></label>
                        <asp:DropDownList ID="ddlProductSelect" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                </div>

                <div class="mb-4">
                    <asp:Button ID="btnAddProductToCatalog" runat="server" CssClass="btn btn-success" Text="Agregar Producto" OnClick="btnAddProductToCatalog_Click" />
                </div>

                <h4 class="mb-3"><i class="bi bi-list-ul me-2"></i><asp:Literal runat="server" Text="Productos en el Catálogo" /></h4>
                <asp:GridView ID="gvCatalogProducts" runat="server" CssClass="table table-striped table-hover" AutoGenerateColumns="false" OnRowCommand="gvCatalogProducts_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="CatalogName" HeaderText="Nombre del Catálogo" />
                        <asp:BoundField DataField="ProductName" HeaderText="Nombre del Producto" />
                        <asp:BoundField DataField="Category" HeaderText="Categoría" />
                        <asp:BoundField DataField="Price" HeaderText="Precio" DataFormatString="ARS {0:N2}" />
                        <asp:TemplateField HeaderText="Acciones">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnRemove" runat="server" CssClass="btn btn-sm btn-danger" CommandName="RemoveFromCatalog" CommandArgument='<%# Eval("CatalogId") + "," + Eval("ProductId") %>'>
                                    <i class="bi bi-trash me-1"></i><asp:Literal runat="server" Text="Quitar" />
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
                <h3 class="mb-3"><i class="bi bi-eye me-2"></i><asp:Literal runat="server" Text="Gestión de Catálogo Mostrado" /></h3>
                <div class="row align-items-end">
                    <div class="col-md-6">
                        <label for="ddlDisplayedCatalog" class="form-label"><asp:Literal runat="server" Text="Seleccionar catálogo a mostrar" /></label>
                        <asp:DropDownList ID="ddlDisplayedCatalog" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                    <div class="col-md-6">
                        <asp:Button ID="btnSaveDisplayedCatalog" runat="server" CssClass="btn btn-primary mt-3 mt-md-0" Text="Guardar" OnClick="btnSaveDisplayedCatalog_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteModal" tabindex="-1" role="dialog" aria-labelledby="deleteModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="deleteModalLabel"><i class="bi bi-exclamation-triangle text-warning me-2"></i><asp:Literal runat="server" Text="Confirmar Acción" /></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="d-flex align-items-center">
                        <i class="bi bi-trash text-danger me-3" style="font-size: 2rem;"></i>
                        <div>
                            <p class="mb-1" id="deleteMessage"></p>
                            <small class="text-muted"><asp:Literal runat="server" Text="Esta acción no se puede deshacer." /></small>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"><i class="bi bi-x-circle me-1"></i><asp:Literal runat="server" Text="Cancelar" /></button>
                    <button type="button" class="btn btn-danger" id="confirmDeleteBtn"><i class="bi bi-trash me-1"></i><asp:Literal runat="server" Text="Eliminar" /></button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="CatalogScripts" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        let pendingDeleteButton = null;
        let isDeleteConfirmed = false;

        document.addEventListener('click', function (e) {
            if (e.target.closest('.delete-btn')) {
                const deleteBtn = e.target.closest('.delete-btn');
                if (isDeleteConfirmed && pendingDeleteButton === deleteBtn) {
                    isDeleteConfirmed = false;
                    pendingDeleteButton = null;
                    return true;
                }
                e.preventDefault();
                e.stopPropagation();

                const productName = deleteBtn.getAttribute('data-product-name');
                const messageTemplate = document.getElementById('<%= hfDeleteMessage.ClientID %>').value;
                const message = messageTemplate.replace('{0}', productName);

                document.getElementById('deleteMessage').textContent = message;
                pendingDeleteButton = deleteBtn;
                const deleteModal = new bootstrap.Modal(document.getElementById('deleteModal'));
                deleteModal.show();
                return false;
            }
        });

        document.getElementById('confirmDeleteBtn')?.addEventListener('click', function () {
            if (pendingDeleteButton) {
                const deleteModal = bootstrap.Modal.getInstance(document.getElementById('deleteModal'));
                deleteModal.hide();
                isDeleteConfirmed = true;
                pendingDeleteButton.click();
            }
        });
    </script>
</asp:Content>

