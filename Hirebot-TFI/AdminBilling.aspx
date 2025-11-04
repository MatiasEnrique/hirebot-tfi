<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminBilling.aspx.cs" Inherits="Hirebot_TFI.AdminBilling" MasterPageFile="~/Admin.master" %>

<asp:Content ID="AdminBillingTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Gestión de facturación" />
</asp:Content>

<asp:Content ID="AdminBillingHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-title {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
        }

        .admin-title .bi-receipt {
            font-size: 1.5rem;
            color: #4b4e6d;
        }

        .card-rounded {
            border-radius: 1rem;
            border: none;
            box-shadow: 0 0.5rem 1.5rem rgba(15, 23, 42, 0.08);
        }

        .card-rounded .card-header {
            border-bottom: 1px solid rgba(15, 23, 42, 0.08);
            background-color: #ffffff;
            border-radius: 1rem 1rem 0 0;
        }

        .badge-status {
            padding: 0.35rem 0.75rem;
            border-radius: 999px;
            font-size: 0.75rem;
        }

        .billing-totals {
            font-size: 0.9rem;
        }

        .billing-totals span {
            display: inline-block;
            margin-right: 1rem;
        }
    </style>
</asp:Content>

<asp:Content ID="AdminBillingMain" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlAlert" runat="server" CssClass="alert alert-dismissible fade show d-none" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <div class="admin-title">
        <i class="bi bi-receipt"></i>
        <div>
            <h2 class="mb-0"><asp:Literal runat="server" Text="Gestión de facturación" /></h2>
            <small class="text-muted"><asp:Literal runat="server" Text="Administra facturas, notas de débito y notas de crédito." /></small>
        </div>
    </div>

    <div class="card card-rounded mb-4">
        <div class="card-header d-flex flex-wrap justify-content-between align-items-center gap-2">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-funnel text-primary"></i>
                <strong><asp:Literal runat="server" Text="Buscar" /></strong>
            </div>
            <asp:Button ID="btnOpenCreateModal" runat="server" CssClass="btn btn-primary" Text="Crear documento de facturación" CausesValidation="false" OnClientClick="return openCreateBillingModal();" />
        </div>
        <div class="card-body">
            <div class="row g-3 align-items-end">
                <div class="col-md-3">
                    <label for="ddlFilterType" class="form-label text-secondary"><asp:Literal runat="server" Text="Tipo de documento" /></label>
                    <asp:DropDownList ID="ddlFilterType" runat="server" CssClass="form-select" />
                </div>
                <div class="col-md-3">
                    <label for="ddlFilterStatus" class="form-label text-secondary"><asp:Literal runat="server" Text="Estado" /></label>
                    <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-select" />
                </div>
                <div class="col-md-3">
                    <label for="txtFilterUser" class="form-label text-secondary"><asp:Literal runat="server" Text="Usuario" /></label>
                    <asp:TextBox ID="txtFilterUser" runat="server" CssClass="form-control" MaxLength="100" />
                </div>
                <div class="col-md-3">
                    <label for="txtFilterDocumentNumber" class="form-label text-secondary"><asp:Literal runat="server" Text="Número de documento" /></label>
                    <asp:TextBox ID="txtFilterDocumentNumber" runat="server" CssClass="form-control" MaxLength="50" />
                </div>
                <div class="col-md-3">
                    <label for="txtFilterFromDate" class="form-label text-secondary"><asp:Literal runat="server" Text="Fecha desde" /></label>
                    <asp:TextBox ID="txtFilterFromDate" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-md-3">
                    <label for="txtFilterToDate" class="form-label text-secondary"><asp:Literal runat="server" Text="Fecha hasta" /></label>
                    <asp:TextBox ID="txtFilterToDate" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-md-3 d-flex gap-2">
                    <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-outline-primary w-100" Text="Buscar" OnClick="btnSearch_Click" />
                    <asp:Button ID="btnClear" runat="server" CssClass="btn btn-outline-secondary w-100" Text="Restablecer" OnClick="btnClear_Click" CausesValidation="false" />
                </div>
            </div>
            <div class="d-flex justify-content-between align-items-center mt-4">
                <span class="text-muted small"><asp:Literal ID="litBillingCount" runat="server" /></span>
            </div>
        </div>
    </div>

    <div class="card card-rounded">
        <div class="card-body">
            <div class="table-responsive">
                <asp:GridView ID="gvBilling" runat="server" CssClass="table table-hover align-middle" AutoGenerateColumns="false" DataKeyNames="BillingDocumentId" OnRowDataBound="gvBilling_RowDataBound" OnRowCommand="gvBilling_RowCommand" EmptyDataText="No se encontraron documentos de facturación.">
                    <Columns>
                        <asp:TemplateField HeaderText="Número de documento" ItemStyle-Width="18%">
                            <ItemTemplate>
                                <div class="fw-semibold text-dark"><%#: Eval("DocumentNumber") %></div>
                                <div class="text-muted small"><%#: Eval("DocumentTypeDisplay") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Usuario" ItemStyle-Width="18%">
                            <ItemTemplate>
                                <div class="fw-semibold text-dark"><%#: Eval("UserDisplay") %></div>
                                <div class="text-muted small"><%#: Eval("UserEmail") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Fecha de emisión" ItemStyle-Width="14%">
                            <ItemTemplate>
                                <asp:Label ID="lblIssueDate" runat="server" CssClass="small text-secondary" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Fecha de vencimiento" ItemStyle-Width="14%">
                            <ItemTemplate>
                                <asp:Label ID="lblDueDate" runat="server" CssClass="small text-secondary" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="TotalAmount" HeaderText="Total" DataFormatString="{0:C2}" ItemStyle-Width="10%" />
                        <asp:TemplateField HeaderText="Estado" ItemStyle-Width="10%">
                            <ItemTemplate>
                                <span class="badge-status" runat="server" id="badgeStatus"></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Acciones" ItemStyle-CssClass="text-end" ItemStyle-Width="16%">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkView" runat="server" CssClass="btn btn-sm btn-outline-primary me-1" CommandName="ViewDocument" CommandArgument='<%# Eval("BillingDocumentId") %>' Text="Ver" />
                                <asp:LinkButton ID="lnkMarkIssued" runat="server" CssClass="btn btn-sm btn-outline-success me-1" CommandName="MarkIssued" CommandArgument='<%# Eval("BillingDocumentId") %>' Text="Marcar como emitido" />
                                <asp:LinkButton ID="lnkMarkPaid" runat="server" CssClass="btn btn-sm btn-outline-success me-1" CommandName="MarkPaid" CommandArgument='<%# Eval("BillingDocumentId") %>' Text="Marcar como pagado" />
                                <asp:LinkButton ID="lnkCancel" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="CancelDocument" CommandArgument='<%# Eval("BillingDocumentId") %>' Text="Cancelar" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hfOpenCreateModal" runat="server" />
    <asp:HiddenField ID="hfOpenViewModal" runat="server" />

    <div class="modal fade" id="billingCreateModal" tabindex="-1" aria-labelledby="billingCreateModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="billingCreateModalLabel"><asp:Literal runat="server" Text="Crear documento de facturación" /></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:ValidationSummary ID="vsCreateDocument" runat="server" CssClass="alert alert-danger" ValidationGroup="CreateDocument" Visible="false" />
                    <asp:Label ID="lblCreateError" runat="server" CssClass="text-danger small d-block" Visible="false" />

                    <div class="row g-3">
                        <div class="col-md-4">
                            <label for="ddlDocumentType" class="form-label"><asp:Literal runat="server" Text="Tipo de documento" /></label>
                            <asp:DropDownList ID="ddlDocumentType" runat="server" CssClass="form-select" />
                            <asp:RequiredFieldValidator ID="rfvDocumentType" runat="server" ControlToValidate="ddlDocumentType" InitialValue="" CssClass="text-danger small" ErrorMessage="Debes seleccionar un tipo de documento." ValidationGroup="CreateDocument" />
                        </div>
                        <div class="col-md-4">
                            <label for="ddlDocumentUser" class="form-label"><asp:Literal runat="server" Text="Seleccionar usuario" /></label>
                            <asp:DropDownList ID="ddlDocumentUser" runat="server" CssClass="form-select" DataTextField="FullName" DataValueField="UserId" />
                            <asp:RequiredFieldValidator ID="rfvDocumentUser" runat="server" ControlToValidate="ddlDocumentUser" InitialValue="" CssClass="text-danger small" ErrorMessage="Debes seleccionar un usuario." ValidationGroup="CreateDocument" />
                        </div>
                        <div class="col-md-4">
                            <label for="txtDocumentNumber" class="form-label"><asp:Literal runat="server" Text="Número de documento" /></label>
                            <asp:TextBox ID="txtDocumentNumber" runat="server" CssClass="form-control" MaxLength="50" />
                        </div>
                        <div class="col-md-4">
                            <label for="txtIssueDate" class="form-label"><asp:Literal runat="server" Text="Fecha de emisión" /></label>
                            <asp:TextBox ID="txtIssueDate" runat="server" CssClass="form-control" TextMode="Date" />
                        </div>
                        <div class="col-md-4">
                            <label for="txtDueDate" class="form-label"><asp:Literal runat="server" Text="Fecha de vencimiento" /></label>
                            <asp:TextBox ID="txtDueDate" runat="server" CssClass="form-control" TextMode="Date" />
                        </div>
                        <div class="col-md-4">
                            <label for="txtNotes" class="form-label"><asp:Literal runat="server" Text="Notas" /></label>
                            <asp:TextBox ID="txtNotes" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" />
                        </div>
                    </div>

                    <hr class="my-4" />

                    <h6><asp:Literal runat="server" Text="Ítems" /></h6>

                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label for="ddlItemProduct" class="form-label"><asp:Literal runat="server" Text="Producto" /></label>
                            <asp:DropDownList ID="ddlItemProduct" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlItemProduct_SelectedIndexChanged" />
                        </div>
                        <div class="col-md-6">
                            <label for="txtItemDescription" class="form-label"><asp:Literal runat="server" Text="Descripción" /></label>
                            <asp:TextBox ID="txtItemDescription" runat="server" CssClass="form-control" MaxLength="300" ReadOnly="true" />
                        </div>
                    </div>

                    <div class="row g-3 align-items-end mb-3">
                        <div class="col-md-4">
                            <label for="txtItemQuantity" class="form-label"><asp:Literal runat="server" Text="Cantidad" /></label>
                            <asp:TextBox ID="txtItemQuantity" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-4">
                            <label for="txtItemTax" class="form-label"><asp:Literal runat="server" Text="Tasa de impuesto (%)" /></label>
                            <asp:TextBox ID="txtItemTax" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-4">
                            <asp:Button ID="btnAddItem" runat="server" CssClass="btn btn-outline-primary w-100" Text="Agregar ítem" OnClick="btnAddItem_Click" CausesValidation="false" />
                        </div>
                    </div>

                    <asp:Repeater ID="rptItems" runat="server" OnItemCommand="rptItems_ItemCommand">
                        <HeaderTemplate>
                            <div class="table-responsive mb-3">
                                <table class="table table-sm table-striped align-middle">
                                    <thead>
                                        <tr>
                                            <th><asp:Literal runat="server" Text="Descripción" /></th>
                                            <th class="text-end"><asp:Literal runat="server" Text="Cantidad" /></th>
                                            <th class="text-end"><asp:Literal runat="server" Text="Precio unitario" /></th>
                                            <th class="text-end"><asp:Literal runat="server" Text="Tasa de impuesto (%)" /></th>
                                            <th class="text-end"><asp:Literal runat="server" Text="Total de línea" /></th>
                                            <th class="text-end"></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td><%#: Eval("Description") %></td>
                                <td class="text-end"><%#: string.Format(System.Globalization.CultureInfo.CurrentCulture, "{0:N2}", Eval("Quantity")) %></td>
                                <td class="text-end"><%#: string.Format(System.Globalization.CultureInfo.CurrentCulture, "{0:C2}", Eval("UnitPrice")) %></td>
                                <td class="text-end"><%#: string.Format(System.Globalization.CultureInfo.CurrentCulture, "{0:N2}%", Eval("TaxRate")) %></td>
                                <td class="text-end"><%#: string.Format(System.Globalization.CultureInfo.CurrentCulture, "{0:C2}", Eval("LineTotal")) %></td>
                                <td class="text-end">
                                    <asp:LinkButton ID="lnkRemoveItem" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="RemoveItem" CommandArgument='<%# Container.ItemIndex %>' Text="Quitar" />
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                    </tbody>
                                </table>
                            </div>
                        </FooterTemplate>
                    </asp:Repeater>

                    <div class="billing-totals">
                        <span><strong><asp:Literal runat="server" Text="Subtotal" />:</strong> <asp:Literal ID="litSubtotal" runat="server" Text="0" /></span>
                        <span><strong><asp:Literal runat="server" Text="Impuestos" />:</strong> <asp:Literal ID="litTax" runat="server" Text="0" /></span>
                        <span><strong><asp:Literal runat="server" Text="Total" />:</strong> <asp:Literal ID="litTotal" runat="server" Text="0" /></span>
                    </div>
                </div>
                <div class="modal-footer">
                    <asp:Button ID="btnCreateDocument" runat="server" CssClass="btn btn-primary" Text="Guardar" OnClick="btnCreateDocument_Click" ValidationGroup="CreateDocument" />
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"><asp:Literal runat="server" Text="Cancelar" /></button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="billingViewModal" tabindex="-1" aria-labelledby="billingViewModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="billingViewModalLabel"><asp:Literal runat="server" ID="litViewTitle" /></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:Literal ID="litViewHeader" runat="server" />
                    <asp:Repeater ID="rptViewItems" runat="server">
                        <HeaderTemplate>
                            <div class="table-responsive mt-3">
                                <table class="table table-sm table-striped align-middle">
                                    <thead>
                                        <tr>
                                            <th><asp:Literal runat="server" Text="Descripción" /></th>
                                            <th class="text-end"><asp:Literal runat="server" Text="Cantidad" /></th>
                                            <th class="text-end"><asp:Literal runat="server" Text="Precio unitario" /></th>
                                            <th class="text-end"><asp:Literal runat="server" Text="Tasa de impuesto (%)" /></th>
                                            <th class="text-end"><asp:Literal runat="server" Text="Total de línea" /></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td><%#: Eval("Description") %></td>
                                <td class="text-end"><%#: string.Format(System.Globalization.CultureInfo.CurrentCulture, "{0:N2}", Eval("Quantity")) %></td>
                                <td class="text-end"><%#: string.Format(System.Globalization.CultureInfo.CurrentCulture, "{0:C2}", Eval("UnitPrice")) %></td>
                                <td class="text-end"><%#: string.Format(System.Globalization.CultureInfo.CurrentCulture, "{0:N2}%", Eval("TaxRate")) %></td>
                                <td class="text-end"><%#: string.Format(System.Globalization.CultureInfo.CurrentCulture, "{0:C2}", Eval("LineTotal")) %></td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                    </tbody>
                                </table>
                            </div>
                        </FooterTemplate>
                    </asp:Repeater>
                    <div class="billing-totals mt-3">
                        <span><strong><asp:Literal runat="server" Text="Subtotal" />:</strong> <asp:Literal ID="litViewSubtotal" runat="server" /></span>
                        <span><strong><asp:Literal runat="server" Text="Impuestos" />:</strong> <asp:Literal ID="litViewTax" runat="server" /></span>
                        <span><strong><asp:Literal runat="server" Text="Total" />:</strong> <asp:Literal ID="litViewTotal" runat="server" /></span>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"><asp:Literal runat="server" Text="Cerrar" /></button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="AdminBillingScripts" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            handleBillingModals();

            if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                    handleBillingModals();
                });
            }
        });

        function handleBillingModals() {
            var createFlag = document.getElementById('<%= hfOpenCreateModal.ClientID %>');
            if (createFlag && createFlag.value === '1') {
                showCreateBillingModal();
                createFlag.value = '0';
            }

            var viewFlag = document.getElementById('<%= hfOpenViewModal.ClientID %>');
            if (viewFlag && viewFlag.value === '1') {
                showViewBillingModal();
                viewFlag.value = '0';
            }
        }

        function openCreateBillingModal() {
            var flag = document.getElementById('<%= hfOpenCreateModal.ClientID %>');
            if (flag) {
                flag.value = '1';
            }
            showCreateBillingModal();
            return false;
        }

        function showCreateBillingModal() {
            var modalEl = document.getElementById('billingCreateModal');
            if (!modalEl) {
                return;
            }
            var modal = bootstrap.Modal.getInstance(modalEl);
            if (!modal) {
                modal = new bootstrap.Modal(modalEl);
            }
            modal.show();
        }

        function showViewBillingModal() {
            var modalEl = document.getElementById('billingViewModal');
            if (!modalEl) {
                return;
            }
            var modal = bootstrap.Modal.getInstance(modalEl);
            if (!modal) {
                modal = new bootstrap.Modal(modalEl);
            }
            modal.show();
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
