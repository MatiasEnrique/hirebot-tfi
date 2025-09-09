<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="LanguageSelector.ascx.cs" Inherits="UI.Controls.LanguageSelector" %>
<%-- Ensure proper UTF-8 encoding for Spanish characters --%>

<li class="nav-item dropdown">
    <a class="nav-link dropdown-toggle" href="#" id="languageDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
        <i class="bi bi-translate"></i>
        <span class="ms-1 d-none d-md-inline"><asp:Literal ID="litCurrentLanguage" runat="server" /></span>
    </a>
    <ul class="dropdown-menu dropdown-menu-end">
        <li>
            <asp:LinkButton ID="btnSpanish" runat="server" CssClass="dropdown-item" OnClick="btnSpanish_Click">
                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Spanish %>" />
            </asp:LinkButton>
        </li>
        <li>
            <asp:LinkButton ID="btnEnglish" runat="server" CssClass="dropdown-item" OnClick="btnEnglish_Click">
                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,English %>" />
            </asp:LinkButton>
        </li>
    </ul>
</li>

