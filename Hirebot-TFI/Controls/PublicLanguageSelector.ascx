<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PublicLanguageSelector.ascx.cs" Inherits="UI.Controls.PublicLanguageSelector" %>
<%-- Ensure proper UTF-8 encoding for Spanish characters --%>

<!-- Language Selector -->
<div class="dropdown me-3">
    <button class="btn btn-outline-light btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown">
        <i class="fas fa-globe me-1"></i><asp:Literal runat="server" Text="Idioma" />
    </button>
    <ul class="dropdown-menu dropdown-menu-end">
        <li>
            <asp:HyperLink ID="lnkSpanish" runat="server" CssClass="dropdown-item lang" NavigateUrl="#">
                <asp:Literal runat="server" Text="Español" />
            </asp:HyperLink>
        </li>
        <li>
            <asp:HyperLink ID="lnkEnglish" runat="server" CssClass="dropdown-item lang" NavigateUrl="#">
                <asp:Literal runat="server" Text="English" />
            </asp:HyperLink>
        </li>
    </ul>
</div>

