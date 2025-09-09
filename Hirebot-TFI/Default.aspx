<%@ Page Title="" Language="C#" MasterPageFile="~/Public.master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Hirebot_TFI.Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Inicio - Hirebot-TFI
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .welcome-section {
            background: linear-gradient(135deg, var(--tiffany-blue), var(--ultra-violet));
            min-height: 80vh;
            display: flex;
            align-items: center;
            color: white;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
        <div class="welcome-section">
            <div class="container text-center">
                <div class="row justify-content-center">
                    <div class="col-lg-8">
                        <h1 class="display-4 fw-bold mb-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,WelcomeToHirebot %>" /></h1>
                        <p class="lead mb-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,HirebotDescription %>" /></p>
                        
                        <asp:Panel ID="pnlWelcomeMessage" runat="server" Visible="false" CssClass="alert alert-info">
                            <h4><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Welcome %>" /> <asp:Label ID="lblWelcomeUser" runat="server"></asp:Label>!</h4>
                            <p class="mb-0"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SuccessfulSignIn %>" /></p>
                        </asp:Panel>
                        
                        <asp:Panel ID="pnlGuestMessage" runat="server" Visible="true">
                            <div class="d-flex justify-content-center gap-3 mt-4">
                                <a href="SignUp.aspx" class="btn btn-light btn-lg px-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,GetStarted %>" /></a>
                                <a href="SignIn.aspx" class="btn btn-outline-light btn-lg px-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SignIn %>" /></a>
                            </div>
                        </asp:Panel>
                    </div>
                </div>
            </div>
        </div>

        <!-- Features Section -->
        <div class="container py-5">
            <div class="row">
                <div class="col-md-4 text-center mb-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body">
                            <div class="mb-3" style="color: var(--ultra-violet);">
                                <i class="fas fa-robot fa-3x"></i>
                            </div>
                            <h5 class="card-title"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AIScreening %>" /></h5>
                            <p class="card-text"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AIScreeningDescription %>" /></p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 text-center mb-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body">
                            <div class="mb-3" style="color: var(--tiffany-blue);">
                                <i class="fas fa-users fa-3x"></i>
                            </div>
                            <h5 class="card-title"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CandidateManagement %>" /></h5>
                            <p class="card-text"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CandidateManagementDescription %>" /></p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 text-center mb-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body">
                            <div class="mb-3" style="color: var(--cadet-gray);">
                                <i class="fas fa-chart-bar fa-3x"></i>
                            </div>
                            <h5 class="card-title"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Analytics %>" /></h5>
                            <p class="card-text"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AnalyticsDescription %>" /></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

</asp:Content>