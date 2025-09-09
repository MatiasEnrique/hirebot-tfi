<%@ Page Title="" Language="C#" MasterPageFile="~/Public.master" AutoEventWireup="true" CodeBehind="AboutUs.aspx.cs" Inherits="Hirebot_TFI.AboutUs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AboutUs %>" /> - Hirebot-TFI
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .hero-section {
            background: linear-gradient(135deg, var(--tiffany-blue), var(--ultra-violet));
            color: white;
            padding: 80px 0 60px 0;
        }
        .team-card {
            transition: transform 0.3s ease;
        }
        .team-card:hover {
            transform: translateY(-10px);
        }
        .section-title {
            color: var(--ultra-violet);
            border-bottom: 3px solid var(--tiffany-blue);
            display: inline-block;
            padding-bottom: 10px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
        <!-- Hero Section -->
        <div class="hero-section">
            <div class="container text-center">
                <h1 class="display-4 fw-bold mb-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AboutUsTitle %>" /></h1>
                <p class="lead"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AboutUsSubtitle %>" /></p>
            </div>
        </div>

        <!-- Main Content -->
        <div class="container py-5">
            <!-- Company Mission -->
            <div class="row mb-5">
                <div class="col-12">
                    <h2 class="section-title mb-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OurMission %>" /></h2>
                    <p class="lead"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,MissionStatement %>" /></p>
                </div>
            </div>

            <!-- Company Story -->
            <div class="row mb-5">
                <div class="col-lg-6">
                    <h2 class="section-title mb-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OurStory %>" /></h2>
                    <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CompanyStory1 %>" /></p>
                    <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CompanyStory2 %>" /></p>
                </div>
                <div class="col-lg-6">
                    <div class="bg-light p-4 rounded">
                        <h4 style="color: var(--ultra-violet);"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,KeyNumbers %>" /></h4>
                        <div class="row text-center mt-4">
                            <div class="col-4">
                                <h3 style="color: var(--tiffany-blue);">500+</h3>
                                <small><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CompaniesServed %>" /></small>
                            </div>
                            <div class="col-4">
                                <h3 style="color: var(--tiffany-blue);">10K+</h3>
                                <small><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CandidatesProcessed %>" /></small>
                            </div>
                            <div class="col-4">
                                <h3 style="color: var(--tiffany-blue);">98%</h3>
                                <small><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SatisfactionRate %>" /></small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Team Section -->
            <div class="row mb-5">
                <div class="col-12">
                    <h2 class="section-title mb-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OurTeam %>" /></h2>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card team-card h-100 border-0 shadow">
                        <div class="card-body text-center">
                            <div class="rounded-circle bg-primary d-flex align-items-center justify-content-center mx-auto mb-3" style="width: 80px; height: 80px; background: var(--ultra-violet) !important;">
                                <i class="fas fa-user text-white fa-2x"></i>
                            </div>
                            <h5 class="card-title">María González</h5>
                            <p class="text-muted mb-2"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CEO %>" /></p>
                            <p class="card-text"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CEODescription %>" /></p>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card team-card h-100 border-0 shadow">
                        <div class="card-body text-center">
                            <div class="rounded-circle d-flex align-items-center justify-content-center mx-auto mb-3" style="width: 80px; height: 80px; background: var(--tiffany-blue);">
                                <i class="fas fa-user text-white fa-2x"></i>
                            </div>
                            <h5 class="card-title">Carlos Rodríguez</h5>
                            <p class="text-muted mb-2"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CTO %>" /></p>
                            <p class="card-text"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CTODescription %>" /></p>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card team-card h-100 border-0 shadow">
                        <div class="card-body text-center">
                            <div class="rounded-circle d-flex align-items-center justify-content-center mx-auto mb-3" style="width: 80px; height: 80px; background: var(--cadet-gray);">
                                <i class="fas fa-user text-white fa-2x"></i>
                            </div>
                            <h5 class="card-title">Ana López</h5>
                            <p class="text-muted mb-2"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CMO %>" /></p>
                            <p class="card-text"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CMODescription %>" /></p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Values Section -->
            <div class="row mt-5">
                <div class="col-12">
                    <h2 class="section-title mb-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OurValues %>" /></h2>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-3 col-md-6 mb-4">
                    <div class="text-center">
                        <div class="mb-3" style="color: var(--ultra-violet);">
                            <i class="fas fa-lightbulb fa-3x"></i>
                        </div>
                        <h5><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Innovation %>" /></h5>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,InnovationDescription %>" /></p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 mb-4">
                    <div class="text-center">
                        <div class="mb-3" style="color: var(--tiffany-blue);">
                            <i class="fas fa-handshake fa-3x"></i>
                        </div>
                        <h5><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Trust %>" /></h5>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TrustDescription %>" /></p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 mb-4">
                    <div class="text-center">
                        <div class="mb-3" style="color: var(--cadet-gray);">
                            <i class="fas fa-star fa-3x"></i>
                        </div>
                        <h5><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Excellence %>" /></h5>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ExcellenceDescription %>" /></p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 mb-4">
                    <div class="text-center">
                        <div class="mb-3" style="color: var(--eerie-black);">
                            <i class="fas fa-users fa-3x"></i>
                        </div>
                        <h5><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Collaboration %>" /></h5>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CollaborationDescription %>" /></p>
                    </div>
                </div>
            </div>
        </div>

</asp:Content>