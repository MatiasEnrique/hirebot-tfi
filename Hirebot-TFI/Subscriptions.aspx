<%@ Page Title="Subscriptions" Language="C#" MasterPageFile="~/Protected.master" AutoEventWireup="true" CodeBehind="Subscriptions.aspx.cs" Inherits="Hirebot_TFI.Subscriptions" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Mis Suscripciones - Hirebot TFI" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .subscription-card {
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
            border: none;
        }

        .subscription-header {
            background: var(--ultra-violet);
            color: #fff;
            border-radius: 12px 12px 0 0;
            padding: 1.5rem;
        }

        .subscription-body {
            padding: 2rem;
        }

        .subscription-label {
            font-weight: 600;
            color: var(--eerie-black);
        }

        .subscription-divider {
            border-top: 1px solid rgba(0, 0, 0, 0.08);
            margin: 2rem 0;
        }

        .message-success {
            background-color: rgba(132, 220, 198, 0.15);
            color: #1d6d5c;
            border: 1px solid rgba(132, 220, 198, 0.35);
        }

        .message-error {
            background-color: rgba(255, 0, 0, 0.08);
            color: #8a1c1c;
            border: 1px solid rgba(255, 0, 0, 0.2);
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="content-card">
        <div class="subscription-card card mb-4">
            <div class="subscription-header">
                <h2 class="mb-1"><asp:Literal runat="server" Text="Administrar suscripciones" /></h2>
                <p class="mb-0"><asp:Literal runat="server" Text="Seleccione un producto y complete los datos de la tarjeta para activar su suscripción." /></p>
            </div>
            <div class="subscription-body">
                <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert d-block" />

                <asp:ValidationSummary ID="valSummary" runat="server" CssClass="alert alert-warning" ValidationGroup="Subscribe" DisplayMode="BulletList" HeaderText="Por favor revise los siguientes errores:" />

                <div class="row g-4">
                    <div class="col-md-6">
                        <label for="ddlProducts" class="form-label subscription-label">
                            <asp:Literal runat="server" Text="Producto" />
                        </label>
                        <asp:DropDownList ID="ddlProducts" runat="server" CssClass="form-select" ValidationGroup="Subscribe" AppendDataBoundItems="true" />
                        <asp:RequiredFieldValidator ID="rfvProduct" runat="server" ControlToValidate="ddlProducts" CssClass="text-danger" ValidationGroup="Subscribe" InitialValue="" ErrorMessage="Seleccione un producto." Display="Dynamic" />
                    </div>
                    <div class="col-md-6">
                        <label for="txtCardholderName" class="form-label subscription-label">
                            <asp:Literal runat="server" Text="Titular de la tarjeta" />
                        </label>
                        <asp:TextBox ID="txtCardholderName" runat="server" CssClass="form-control" MaxLength="100" ValidationGroup="Subscribe" />
                        <asp:RequiredFieldValidator ID="rfvCardholder" runat="server" ControlToValidate="txtCardholderName" CssClass="text-danger" ValidationGroup="Subscribe" ErrorMessage="Ingrese el titular de la tarjeta." Display="Dynamic" />
                    </div>
                </div>

                <div class="row g-4 mt-1">
                    <div class="col-md-6">
                        <label for="txtCardNumber" class="form-label subscription-label">
                            <asp:Literal runat="server" Text="Número de tarjeta" />
                        </label>
                        <asp:TextBox ID="txtCardNumber" runat="server" CssClass="form-control" MaxLength="23" ValidationGroup="Subscribe" />
                        <asp:RequiredFieldValidator ID="rfvCardNumber" runat="server" ControlToValidate="txtCardNumber" CssClass="text-danger" ValidationGroup="Subscribe" ErrorMessage="Ingrese el número de la tarjeta." Display="Dynamic" />
                        <asp:RegularExpressionValidator ID="revCardNumber" runat="server" ControlToValidate="txtCardNumber" CssClass="text-danger" ValidationGroup="Subscribe" ErrorMessage="El número de tarjeta no es válido." Display="Dynamic" ValidationExpression="^[0-9\s-]{12,23}$" />
                    </div>
                    <div class="col-md-3">
                        <label for="ddlExpirationMonth" class="form-label subscription-label">
                            <asp:Literal runat="server" Text="Mes de vencimiento" />
                        </label>
                        <asp:DropDownList ID="ddlExpirationMonth" runat="server" CssClass="form-select" ValidationGroup="Subscribe" AppendDataBoundItems="true" />
                        <asp:RequiredFieldValidator ID="rfvExpirationMonth" runat="server" ControlToValidate="ddlExpirationMonth" CssClass="text-danger" ValidationGroup="Subscribe" InitialValue="" ErrorMessage="Seleccione una fecha de vencimiento." Display="Dynamic" />
                    </div>
                    <div class="col-md-3">
                        <label for="ddlExpirationYear" class="form-label subscription-label">
                            <asp:Literal runat="server" Text="Año de vencimiento" />
                        </label>
                        <asp:DropDownList ID="ddlExpirationYear" runat="server" CssClass="form-select" ValidationGroup="Subscribe" AppendDataBoundItems="true" />
                        <asp:RequiredFieldValidator ID="rfvExpirationYear" runat="server" ControlToValidate="ddlExpirationYear" CssClass="text-danger" ValidationGroup="Subscribe" InitialValue="" ErrorMessage="Seleccione una fecha de vencimiento." Display="Dynamic" />
                    </div>
                </div>

                <div class="mt-4">
                    <asp:Button ID="btnSubscribe" runat="server" CssClass="btn btn-primary" ValidationGroup="Subscribe" Text="Confirmar suscripción" OnClick="btnSubscribe_Click" />
                </div>
            </div>
        </div>

        <div class="card subscription-card">
            <div class="subscription-header">
                <h3 class="mb-0"><asp:Literal runat="server" Text="Suscripciones actuales" /></h3>
            </div>
            <div class="subscription-body">
                <asp:Panel ID="pnlNoSubscriptions" runat="server" Visible="false" CssClass="alert alert-info">
                    <asp:Literal runat="server" Text="Aún no tiene suscripciones activas." />
                </asp:Panel>

                <asp:Repeater ID="rptSubscriptions" runat="server" OnItemDataBound="rptSubscriptions_ItemDataBound">
                    <HeaderTemplate>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th scope="col"><asp:Literal runat="server" Text="Producto" /></th>
                                        <th scope="col"><asp:Literal runat="server" Text="Plan" /></th>
                                        <th scope="col"><asp:Literal runat="server" Text="Precio" /></th>
                                        <th scope="col"><asp:Literal runat="server" Text="Pago" /></th>
                                        <th scope="col"><asp:Literal runat="server" Text="Estado" /></th>
                                    </tr>
                                </thead>
                                <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td>
                                <div class="fw-semibold"> <%# Eval("ProductName") %> </div>
                                <div class="text-muted small"> <%# GetCreatedDateText(Eval("CreatedDateUtc")) %> </div>
                            </td>
                            <td><%# Eval("BillingCycle") %></td>
                            <td><%# ((decimal)Eval("ProductPrice")).ToString("C") %></td>
                            <td>
                                <span class="d-block">**** **** **** <%# Eval("CardLast4") %></span>
                                <span class="text-muted small"><%# Eval("CardBrand") %></span>
                            </td>
                            <td>
                                <span class="badge" runat="server" id="lblStatus" ></span>
                                <asp:Literal ID="litStatusDetail" runat="server"></asp:Literal>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                                </tbody>
                            </table>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
</asp:Content>
