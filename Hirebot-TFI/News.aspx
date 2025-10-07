<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="News.aspx.cs" Inherits="Hirebot_TFI.News" MasterPageFile="~/Public.master" %>

<asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .news-hero {
            background: linear-gradient(135deg, #4b4e6d, #222222);
            color: #fff;
            border-radius: 1.5rem;
            padding: 3rem 0;
            margin-bottom: 2.5rem;
        }

        .news-page-wrapper {
            padding-bottom: 4rem;
        }

        .news-list-section {
            padding-top: 1rem;
        }

        .news-card {
            border: none;
            border-radius: 1.2rem;
            box-shadow: 0 12px 30px rgba(15, 23, 42, 0.08);
            overflow: hidden;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .news-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.12);
        }

        .news-card .card-body {
            padding: 2rem;
        }

        .news-meta {
            font-size: 0.85rem;
            color: #64748b;
        }

        .news-content {
            color: #475569;
            line-height: 1.7;
        }

        .newsletter-section {
            background: #0f172a;
            color: #fff;
            border-radius: 1.5rem;
            padding: 2.5rem 0;
            margin-bottom: 3rem;
        }

        .newsletter-section .form-control,
        .newsletter-section .form-select {
            border-radius: 0.75rem;
            border: none;
            box-shadow: none;
        }

        .newsletter-section .btn {
            border-radius: 0.75rem;
        }

        .news-detail-content p {
            margin-bottom: 1rem;
        }

        .news-detail-content img {
            max-width: 100%;
            height: auto;
            border-radius: 0.5rem;
        }
    </style>
</asp:Content>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PublicNewsPageTitle %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlPublicAlert" runat="server" Visible="false" CssClass="alert alert-dismissible fade show" role="alert">
        <asp:Label ID="lblPublicAlert" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <section class="news-hero">
        <div class="container">
            <div class="row g-4 align-items-center">
                <div class="col-lg-7">
                    <h1 class="display-5 fw-bold mb-3"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NewsHeroTitle %>" /></h1>
                    <p class="fs-5 text-white-50 mb-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NewsHeroSubtitle %>" /></p>
                </div>
                <div class="col-lg-5">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body p-4">
                            <div class="mb-3">
                                <label for="txtPublicSearch" class="form-label text-secondary fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Keyword %>" /></label>
                                <asp:TextBox ID="txtPublicSearch" runat="server" CssClass="form-control" MaxLength="150" placeholder="<%$ Resources:GlobalResources,SearchPlaceholder %>" />
                            </div>
                            <div class="mb-3">
                                <label for="ddlPublicLanguage" class="form-label text-secondary fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Language %>" /></label>
                                <asp:DropDownList ID="ddlPublicLanguage" runat="server" CssClass="form-select">
                                </asp:DropDownList>
                            </div>
                            <div class="d-flex gap-2">
                                <asp:Button ID="btnSearchNews" runat="server" CssClass="btn btn-primary flex-fill" Text="<%$ Resources:GlobalResources,Search %>" OnClick="btnSearchNews_Click" />
                                <asp:Button ID="btnResetNewsSearch" runat="server" CssClass="btn btn-outline-light flex-fill" Text="<%$ Resources:GlobalResources,Reset %>" OnClick="btnResetNewsSearch_Click" CausesValidation="false" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <div class="container news-page-wrapper">
        <section class="news-list-section mb-5">
            <span class="text-muted small d-block mb-3"><asp:Literal ID="litNewsResultsCount" runat="server" /></span>
            <asp:Repeater ID="rptNews" runat="server" OnItemCommand="rptNews_ItemCommand">
            <ItemTemplate>
                <div class="card news-card mb-4">
                    <div class="card-body">
                        <div class="d-flex justify-content-between flex-wrap mb-2">
                            <div class="news-meta">
                                <i class="bi bi-calendar-event me-2"></i><%#: FormatPublishedDate(Eval("PublishedDate")) %>
                            </div>
                            <div>
                                <span class="badge bg-light text-dark"><%#: Eval("LanguageCode") %></span>
                            </div>
                        </div>
                        <h3 class="fw-semibold text-dark mb-3"><%#: Eval("Title") %></h3>
                        <p class="news-content mb-3"><%#: GetExcerpt(Eval("Content")) %></p>
                        <div class="d-flex justify-content-between align-items-center">
                            <div class="text-muted small">
                                <i class="bi bi-eye me-1"></i><%#: Eval("ViewCount") %> <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Reads %>" />
                            </div>
                            <asp:LinkButton ID="btnReadMore" runat="server" CssClass="btn btn-outline-primary btn-sm" CommandName="ReadMore" CommandArgument='<%# Eval("NewsId") %>' Text="<%$ Resources:GlobalResources,ReadMore %>" CausesValidation="false" />
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
        <asp:Panel ID="pnlNoNews" runat="server" Visible="false" CssClass="text-center py-5">
            <i class="bi bi-newspaper display-4 text-muted d-block mb-3"></i>
            <p class="text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NoNewsAvailable %>" /></p>
        </asp:Panel>
        </section>
    </div>

    <section class="newsletter-section">
        <div class="container">
            <div class="row g-4 align-items-center">
                <div class="col-lg-6">
                    <h2 class="fw-bold mb-3"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NewsletterTitle %>" /></h2>
                    <p class="text-white-50 mb-0"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NewsletterSubtitle %>" /></p>
                </div>
                <div class="col-lg-6">
                    <div class="row g-3">
                        <div class="col-sm-7">
                            <asp:TextBox ID="txtSubscribeEmail" runat="server" CssClass="form-control" MaxLength="150" placeholder="<%$ Resources:GlobalResources,EmailPlaceholder %>" />
                        </div>
                        <div class="col-sm-3">
                            <asp:DropDownList ID="ddlSubscribeLanguage" runat="server" CssClass="form-select" />
                        </div>
                        <div class="col-sm-2 d-grid">
                            <asp:Button ID="btnSubscribeNewsletter" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalResources,Subscribe %>" OnClick="btnSubscribeNewsletter_Click" />
                        </div>
                    </div>
                    <asp:Label ID="lblSubscribeFeedback" runat="server" CssClass="d-block mt-3 small" Visible="false" />
                </div>
            </div>
        </div>
    </section>

    <div class="modal fade" id="newsDetailModal" tabindex="-1" aria-labelledby="newsDetailModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="newsDetailModalLabel"><asp:Literal ID="litArticleModalTitle" runat="server" /></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="d-flex flex-wrap gap-3 align-items-center mb-3 text-muted small">
                        <div><i class="bi bi-calendar-event me-1"></i><asp:Literal ID="litArticleModalDate" runat="server" /></div>
                        <div><i class="bi bi-translate me-1"></i><asp:Literal ID="litArticleModalLanguage" runat="server" /></div>
                        <div><i class="bi bi-eye me-1"></i><asp:Literal ID="litArticleModalViews" runat="server" /></div>
                    </div>
                    <div class="news-detail-content">
                        <asp:Literal ID="litArticleModalContent" runat="server" Mode="PassThrough" />
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Close %>" /></button>
                </div>
            </div>
        </div>
    </div>

    <script>
        function showNewsDetailModal() {
            var modalEl = document.getElementById('newsDetailModal');
            if (!modalEl) {
                return;
            }

            var modal = bootstrap.Modal.getInstance(modalEl);
            if (!modal) {
                modal = new bootstrap.Modal(modalEl);
            }

            modal.show();
        }
    </script>
</asp:Content>
