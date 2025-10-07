<%@ Page Title="<%$ Resources:GlobalResources,AccountTitle %>" Language="C#" MasterPageFile="~/Protected.master" AutoEventWireup="true" CodeBehind="Account.aspx.cs" Inherits="Hirebot_TFI.Account" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert" role="alert">
            <asp:Literal ID="litAlertText" runat="server"></asp:Literal>
        </asp:Panel>

        <div class="row g-4">
            <div class="col-lg-4">
                <div class="card shadow-sm h-100">
                    <div class="card-body">
                        <h2 class="h5 mb-3 text-uppercase"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountOverviewHeading %>" /></h2>
                        <div class="mb-3">
                            <p class="fw-bold mb-1"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountFullName %>" />:</p>
                            <p class="mb-2" id="lblFullName"><asp:Literal ID="litFullName" runat="server"></asp:Literal></p>
                            <p class="fw-bold mb-1"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountEmailLabel %>" />:</p>
                            <p class="mb-2"><asp:Literal ID="litEmail" runat="server"></asp:Literal></p>
                            <p class="fw-bold mb-1"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountUsernameLabel %>" />:</p>
                            <p class="mb-2"><asp:Literal ID="litUsername" runat="server"></asp:Literal></p>
                            <p class="fw-bold mb-1"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountCreatedDateLabel %>" />:</p>
                            <p class="mb-2"><asp:Literal ID="litCreatedDate" runat="server"></asp:Literal></p>
                            <p class="fw-bold mb-1"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountLastLoginLabel %>" />:</p>
                            <p class="mb-0"><asp:Literal ID="litLastLogin" runat="server"></asp:Literal></p>
                        </div>

                        <hr />

                        <h3 class="h6 text-uppercase mb-3"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountSubscriptionHeading %>" /></h3>
                        <asp:Repeater ID="rptSubscriptions" runat="server" OnItemCommand="rptSubscriptions_ItemCommand" OnItemDataBound="rptSubscriptions_ItemDataBound">
                            <ItemTemplate>
                                <div class="border rounded p-3 mb-3">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <h4 class="h6 mb-1"><%# System.Web.HttpUtility.HtmlEncode(Eval("ProductName") as string ?? string.Empty) %></h4>
                                            <p class="mb-1 text-muted small">
                                                <%# FormatSubscriptionPrice(Eval("BillingCycle"), Eval("ProductPrice")) %>
                                            </p>
                                        </div>
                                        <span class='<%# (Eval("IsActive") != null && (bool)Eval("IsActive")) ? "badge bg-success" : "badge bg-secondary" %>'>
                                            <%# GetLocalizedText((Eval("IsActive") != null && (bool)Eval("IsActive")) ? "AccountSubscriptionActive" : "AccountSubscriptionInactive") %>
                                        </span>
                                    </div>
                                    <div class="mt-3 small text-muted">
                                        <span class="d-block mb-1">
                                            <i class="fas fa-credit-card me-1"></i>
                                            <%# FormatSubscriptionCard(Eval("CardBrand"), Eval("CardLast4")) %>
                                        </span>
                                        <span class="d-block">
                                            <i class="fas fa-calendar-alt me-1"></i>
                                            <%# string.Format(System.Globalization.CultureInfo.CurrentUICulture, "{0:D2}/{1}", Eval("ExpirationMonth"), Eval("ExpirationYear")) %>
                                        </span>
                                        <span class="d-block">
                                            <i class="fas fa-clock me-1"></i>
                                            <%# FormatDateTime(Eval("CreatedDateUtc")) %>
                                        </span>
                                        <asp:PlaceHolder runat="server" Visible='<%# Eval("CancelledDateUtc") != DBNull.Value && Eval("CancelledDateUtc") != null %>'>
                                            <span class="d-block">
                                                <i class="fas fa-ban me-1"></i>
                                                <%# string.Format(System.Globalization.CultureInfo.CurrentUICulture, "{0}: {1}", GetLocalizedText("AccountSubscriptionCancelled"), FormatDateTime(Eval("CancelledDateUtc"))) %>
                                            </span>
                                        </asp:PlaceHolder>
                                    </div>
                                    <div class="mt-3 d-flex justify-content-end">
                                        <asp:LinkButton ID="btnCancelSubscription" runat="server" CssClass="btn btn-outline-danger btn-sm" CommandName="CancelSubscription" CommandArgument='<%# Eval("SubscriptionId") %>' Visible='<%# Eval("IsActive") != null && (bool)Eval("IsActive") %>'>
                                            <%# GetLocalizedText("AccountSubscriptionCancelButton") %>
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Panel ID="pnlNoSubscriptions" runat="server" Visible="false" CssClass="text-muted small">
                            <i class="fas fa-info-circle me-1"></i>
                            <asp:Literal ID="litNoSubscriptions" runat="server" Text="<%$ Resources:GlobalResources,AccountNoSubscriptions %>"></asp:Literal>
                        </asp:Panel>
                    </div>
                </div>
            </div>

            <div class="col-lg-8">
                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h2 class="h5 text-uppercase mb-0"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountBillingSummaryHeading %>" /></h2>
                        </div>
                        <div class="row g-3">
                            <div class="col-sm-6 col-xl-3">
                                <div class="border rounded p-3 h-100 bg-light">
                                    <p class="text-muted text-uppercase small mb-1"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountBillingSummaryInvoices %>" /></p>
                                    <p class="fs-5 fw-semibold text-dark mb-0"><asp:Literal ID="litInvoiceTotal" runat="server"></asp:Literal></p>
                                </div>
                            </div>
                            <div class="col-sm-6 col-xl-3">
                                <div class="border rounded p-3 h-100 bg-light">
                                    <p class="text-muted text-uppercase small mb-1"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountBillingSummaryDebitNotes %>" /></p>
                                    <p class="fs-5 fw-semibold text-dark mb-0"><asp:Literal ID="litDebitNoteTotal" runat="server"></asp:Literal></p>
                                </div>
                            </div>
                            <div class="col-sm-6 col-xl-3">
                                <div class="border rounded p-3 h-100 bg-light">
                                    <p class="text-muted text-uppercase small mb-1"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountBillingSummaryCreditNotes %>" /></p>
                                    <p class="fs-5 fw-semibold text-dark mb-0"><asp:Literal ID="litCreditNoteTotal" runat="server"></asp:Literal></p>
                                </div>
                            </div>
                            <div class="col-sm-6 col-xl-3">
                                <div class="border rounded p-3 h-100 bg-light">
                                    <p class="text-muted text-uppercase small mb-1"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountBillingSummaryBalance %>" /></p>
                                    <p class="fs-5 fw-semibold mb-0" id="lblAccountBalance"><asp:Literal ID="litBillingBalance" runat="server"></asp:Literal></p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h2 class="h5 text-uppercase mb-0"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountBillingHeading %>" /></h2>
                        </div>
                        <asp:Repeater ID="rptBillingDocuments" runat="server">
                            <HeaderTemplate>
                                <div class="table-responsive">
                                    <table class="table table-striped align-middle mb-0">
                                        <thead>
                                            <tr>
                                                <th scope="col"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountBillingDocumentNumber %>" /></th>
                                                <th scope="col"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountBillingIssueDate %>" /></th>
                                                <th scope="col"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountBillingDueDate %>" /></th>
                                                <th scope="col"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountBillingStatus %>" /></th>
                                                <th scope="col" class="text-end"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountBillingTotal %>" /></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <div class="fw-semibold"><%# System.Web.HttpUtility.HtmlEncode(Eval("DocumentNumber") as string ?? string.Empty) %></div>
                                        <div class="text-muted small"><%# System.Web.HttpUtility.HtmlEncode(Eval("DocumentType") as string ?? string.Empty) %></div>
                                    </td>
                                    <td><%# FormatDateTime(Eval("IssueDateUtc")) %></td>
                                    <td><%# FormatDateTime(Eval("DueDateUtc")) %></td>
                                    <td>
                                        <span class="badge bg-light text-dark border"><%# System.Web.HttpUtility.HtmlEncode(Eval("Status") as string ?? string.Empty) %></span>
                                    </td>
                                    <td class="text-end"><%# FormatCurrency(Eval("TotalAmount"), Eval("CurrencyCode")) %></td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                        </tbody>
                                    </table>
                                </div>
                            </FooterTemplate>
                        </asp:Repeater>
                        <asp:Panel ID="pnlNoBillingDocuments" runat="server" Visible="false" CssClass="text-muted small">
                            <i class="fas fa-file-invoice me-1"></i>
                            <asp:Literal ID="litNoBillingDocuments" runat="server" Text="<%$ Resources:GlobalResources,AccountNoBillingDocuments %>"></asp:Literal>
                        </asp:Panel>
                    </div>
                </div>

                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <h2 class="h5 text-uppercase mb-3"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountUpdateProfileHeading %>" /></h2>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label for="txtFirstName" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountFirstNameLabel %>" /></label>
                                <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control" MaxLength="100"></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <label for="txtLastName" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountLastNameLabel %>" /></label>
                                <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control" MaxLength="100"></asp:TextBox>
                            </div>
                            <div class="col-12">
                                <label for="txtEmail" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountEmailLabel %>" /></label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" MaxLength="255"></asp:TextBox>
                            </div>
                            <div class="col-12 d-flex justify-content-end">
                                <asp:Button ID="btnUpdateProfile" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalResources,AccountUpdateProfileButton %>" OnClick="btnUpdateProfile_Click" />
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <h2 class="h5 text-uppercase mb-3"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountChangePasswordHeading %>" /></h2>
                        <div class="row g-3">
                            <div class="col-12 col-md-6">
                                <label for="txtCurrentPassword" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountCurrentPasswordLabel %>" /></label>
                                <asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="100"></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label for="txtNewPassword" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountNewPasswordLabel %>" /></label>
                                <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="100"></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label for="txtConfirmPassword" class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountConfirmPasswordLabel %>" /></label>
                                <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="100"></asp:TextBox>
                            </div>
                            <div class="col-12 d-flex justify-content-end">
                                <asp:Button ID="btnChangePassword" runat="server" CssClass="btn btn-outline-primary" Text="<%$ Resources:GlobalResources,AccountChangePasswordButton %>" OnClick="btnChangePassword_Click" />
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card shadow-sm">
                    <div class="card-body">
                        <h2 class="h5 text-uppercase mb-3"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountChatHeading %>" /></h2>
                        <div class="border rounded p-3 bg-light">
                            <div class="chat-window mb-3" style="height: 220px; overflow-y: auto;">
                                <div class="text-muted text-center my-5">
                                    <i class="fas fa-comments fa-2x mb-2"></i>
                                    <p class="mb-0"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccountChatPlaceholder %>" /></p>
                                </div>
                            </div>
                            <div class="d-flex align-items-center gap-2">
                                <asp:TextBox ID="txtChatInputPlaceholder" runat="server" CssClass="form-control" Enabled="false"></asp:TextBox>
                                <button type="button" class="btn btn-secondary" disabled>
                                    <i class="fas fa-paper-plane"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
