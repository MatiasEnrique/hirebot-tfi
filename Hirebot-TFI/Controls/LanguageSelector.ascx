<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="LanguageSelector.ascx.cs" Inherits="UI.Controls.LanguageSelector" %>
<%-- Ensure proper UTF-8 encoding for Spanish characters --%>

<li class="nav-item dropdown">
    <a class="nav-link dropdown-toggle" href="#" id="languageDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
        <i class="bi bi-translate"></i>
        <span class="ms-1 d-none d-md-inline" data-language-display="true"><asp:Literal ID="litCurrentLanguage" runat="server" /></span>
    </a>
    <ul class="dropdown-menu dropdown-menu-end">
        <li>
            <asp:HyperLink ID="lnkSpanish" runat="server" CssClass="dropdown-item lang" NavigateUrl="#" Text="Espa&#241;ol" />
        </li>
        <li>
            <asp:HyperLink ID="lnkEnglish" runat="server" CssClass="dropdown-item lang" NavigateUrl="#" Text="English" />
        </li>
    </ul>
</li>

