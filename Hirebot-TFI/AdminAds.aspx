<%@ Page Title="" Language="C#" MasterPageFile="~/Admin.master" AutoEventWireup="true" CodeBehind="AdminAds.aspx.cs" Inherits="Hirebot_TFI.AdminAds" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .ad-card {
            border: 1px solid rgba(0, 0, 0, 0.08);
            border-radius: 0.75rem;
            padding: 1rem;
            transition: all 0.2s ease;
        }

        .ad-card:hover {
            border-color: rgba(132, 220, 198, 0.6);
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.05);
        }

        .ad-card.active {
            border-color: rgba(75, 78, 109, 0.6);
            background-color: rgba(132, 220, 198, 0.08);
        }

        .char-counter {
            font-size: 0.75rem;
            color: #6c757d;
            float: right;
        }

        .char-counter.warning {
            color: #fd7e14;
        }

        .char-counter.danger {
            color: #dc3545;
        }

        .badge-preview {
            display: inline-block;
            margin-top: 0.5rem;
            padding: 0.25rem 0.75rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 50rem;
            font-size: 0.875rem;
            font-weight: 500;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel ID="upAds" runat="server">
        <ContentTemplate>
            <asp:HiddenField ID="hdnSelectedAdId" runat="server" />

            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" Role="alert" />

            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center mb-4 gap-3">
                <h2 class="mb-0">
                    <asp:Literal runat="server" Text="Gestión de Anuncios de Inicio" />
                </h2>
                <asp:LinkButton ID="btnNewAd" runat="server" CssClass="btn btn-outline-primary" OnClick="btnNewAd_Click">
                    <i class="bi bi-plus-circle me-1"></i>
                    <asp:Literal runat="server" Text="Crear Nuevo Anuncio" />
                </asp:LinkButton>
            </div>

            <div class="row">
                <div class="col-lg-4">
                    <div class="card shadow-sm mb-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">
                                <asp:Literal runat="server" Text="Lista de Anuncios" />
                            </h5>
                        </div>
                        <div class="card-body">
                            <asp:Repeater ID="rptAds" runat="server" OnItemCommand="rptAds_ItemCommand">
                                <ItemTemplate>
                                    <div class='<%# GetAdCardCss(Eval("AdId")) %>'>
                                        <div class="mb-2">
                                            <h6 class="mb-1"><%# Eval("Title") %></h6>
                                            <%# !string.IsNullOrWhiteSpace(Eval("BadgeText")?.ToString()) ?
                                                "<span class='badge bg-primary bg-gradient'>" + Eval("BadgeText") + "</span>" : "" %>
                                        </div>
                                        <div class="mb-2">
                                            <%# GetAdStatusBadges(Eval("IsActive"), Eval("IsSelected")) %>
                                        </div>
                                        <div class="small text-muted">
                                            <div><strong><asp:Literal runat="server" Text="Creado" />:</strong> <%# FormatDate(Eval("CreatedDateUtc")) %></div>
                                            <div><strong><asp:Literal runat="server" Text="Modificado" />:</strong> <%# FormatDate(Eval("ModifiedDateUtc")) %></div>
                                        </div>
                                        <div class="mt-2">
                                            <asp:LinkButton ID="btnSelectAd" runat="server" CssClass="btn btn-sm btn-outline-primary w-100" CommandName="SelectAd" CommandArgument='<%# Eval("AdId") %>'>
                                                <i class="bi bi-eye me-1"></i>
                                                <asp:Literal runat="server" Text="Ver" />
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                            <asp:Panel ID="pnlNoAds" runat="server" Visible="false" CssClass="alert alert-info mt-3">
                                <i class="bi bi-info-circle me-1"></i>
                                <asp:Literal runat="server" Text="No hay anuncios disponibles" />
                            </asp:Panel>
                        </div>
                    </div>
                </div>

                <div class="col-lg-8">
                    <asp:Panel ID="pnlAdDetail" runat="server" CssClass="card shadow-sm" Visible="false">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">
                                <asp:Literal ID="litAdHeader" runat="server" />
                            </h5>
                        </div>
                        <div class="card-body">
                            <asp:ValidationSummary ID="vsAd" runat="server" CssClass="alert alert-danger" ValidationGroup="AdForm" EnableClientScript="false" />

                            <div class="mb-3">
                                <label class="form-label" for="txtTitle">
                                    <asp:Literal runat="server" Text="Título del Anuncio" />
                                    <span class="text-danger">*</span>
                                </label>
                                <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" MaxLength="200" onkeyup="updateCharCount('txtTitle', 200, 'charCountTitle')"></asp:TextBox>
                                <small class="char-counter" id="charCountTitle">0/200</small>
                                <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle" ValidationGroup="AdForm" CssClass="text-danger d-block" ErrorMessage="El título del anuncio es obligatorio" Display="Dynamic" />
                            </div>

                            <div class="mb-3">
                                <label class="form-label" for="txtBadgeText">
                                    <asp:Literal runat="server" Text="Texto de Etiqueta" />
                                </label>
                                <asp:TextBox ID="txtBadgeText" runat="server" CssClass="form-control" MaxLength="100" placeholder="Etiqueta opcional (ej: NUEVO)" onkeyup="updateCharCount('txtBadgeText', 100, 'charCountBadge'); updateBadgePreview()"></asp:TextBox>
                                <small class="char-counter" id="charCountBadge">0/100</small>
                                <div id="badgePreview" style="display: none;">
                                    <small class="text-muted"><asp:Literal runat="server" Text="Vista Previa" />:</small>
                                    <span class="badge-preview" id="badgePreviewText"></span>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label" for="txtDescription">
                                    <asp:Literal runat="server" Text="Descripción" />
                                </label>
                                <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" MaxLength="500" placeholder="Descripción del anuncio (opcional)" onkeyup="updateCharCount('txtDescription', 500, 'charCountDescription')"></asp:TextBox>
                                <small class="char-counter" id="charCountDescription">0/500</small>
                            </div>

                            <div class="mb-3">
                                <label class="form-label" for="txtCtaText">
                                    <asp:Literal runat="server" Text="Texto del Botón" />
                                </label>
                                <asp:TextBox ID="txtCtaText" runat="server" CssClass="form-control" MaxLength="100" placeholder="Texto del botón (opcional)" onkeyup="updateCharCount('txtCtaText', 100, 'charCountCta')"></asp:TextBox>
                                <small class="char-counter" id="charCountCta">0/100</small>
                            </div>

                            <div class="mb-3">
                                <label class="form-label" for="txtTargetUrl">
                                    <asp:Literal runat="server" Text="URL de Destino" />
                                </label>
                                <asp:TextBox ID="txtTargetUrl" runat="server" CssClass="form-control" MaxLength="500" placeholder="URL de destino (opcional)" onkeyup="updateCharCount('txtTargetUrl', 500, 'charCountUrl')"></asp:TextBox>
                                <small class="char-counter" id="charCountUrl">0/500</small>
                            </div>

                            <div class="form-check form-switch mb-4">
                                <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label" for="chkIsActive">
                                    <asp:Literal runat="server" Text="Activo" />
                                </label>
                            </div>
                        </div>
                        <div class="card-footer bg-white d-flex justify-content-between">
                            <asp:LinkButton ID="btnDeleteAd" runat="server" CssClass="btn btn-outline-danger" OnClick="btnDeleteAd_Click" Visible="false">
                                <i class="bi bi-trash me-1"></i>
                                <asp:Literal runat="server" Text="Eliminar Anuncio" />
                            </asp:LinkButton>
                            <div class="d-flex gap-2">
                                <asp:LinkButton ID="btnSetSelected" runat="server" CssClass="btn btn-outline-primary" OnClick="btnSetSelected_Click" Visible="false">
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnSaveAd" runat="server" CssClass="btn btn-primary" OnClick="btnSaveAd_Click" ValidationGroup="AdForm">
                                    <i class="bi bi-save me-1"></i>
                                    <asp:Literal runat="server" Text="Guardar Anuncio" />
                                </asp:LinkButton>
                            </div>
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <script type="text/javascript">
        function updateCharCount(fieldId, maxLength, counterId) {
            var field = document.getElementById('<%= txtTitle.ClientID %>'.replace('txtTitle', fieldId));
            var counter = document.getElementById(counterId);
            if (field && counter) {
                var length = field.value.length;
                counter.textContent = length + '/' + maxLength;

                counter.classList.remove('warning', 'danger');
                if (length > maxLength * 0.9) {
                    counter.classList.add('danger');
                } else if (length > maxLength * 0.75) {
                    counter.classList.add('warning');
                }
            }
        }

        function updateBadgePreview() {
            var badgeText = document.getElementById('<%= txtBadgeText.ClientID %>');
            var preview = document.getElementById('badgePreview');
            var previewText = document.getElementById('badgePreviewText');

            if (badgeText && preview && previewText) {
                if (badgeText.value.trim().length > 0) {
                    previewText.textContent = badgeText.value;
                    preview.style.display = 'block';
                } else {
                    preview.style.display = 'none';
                }
            }
        }

        function initializeCharCounters() {
            updateCharCount('txtTitle', 200, 'charCountTitle');
            updateCharCount('txtBadgeText', 100, 'charCountBadge');
            updateCharCount('txtDescription', 500, 'charCountDescription');
            updateCharCount('txtCtaText', 100, 'charCountCta');
            updateCharCount('txtTargetUrl', 500, 'charCountUrl');
            updateBadgePreview();
        }

        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
            initializeCharCounters();
        });

        window.addEventListener('load', function() {
            initializeCharCounters();
        });
    </script>
</asp:Content>
