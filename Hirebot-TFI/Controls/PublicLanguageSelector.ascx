<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PublicLanguageSelector.ascx.cs" Inherits="UI.Controls.PublicLanguageSelector" %>
<%-- Ensure proper UTF-8 encoding for Spanish characters --%>

<!-- Language Selector -->
<div class="dropdown me-3">
    <button class="btn btn-outline-light btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown">
        <i class="fas fa-globe me-1"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Language %>" />
    </button>
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
</div>

