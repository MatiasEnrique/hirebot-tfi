<%@ Page Title="" Language="C#" MasterPageFile="~/Public.master" AutoEventWireup="true" CodeBehind="TermsConditions.aspx.cs" Inherits="Hirebot_TFI.TermsConditions" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TermsConditions %>" /> - Hirebot-TFI
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .hero-section {
            background: linear-gradient(135deg, var(--tiffany-blue), var(--ultra-violet));
            color: white;
            padding: 80px 0 60px 0;
        }
        .content-section {
            line-height: 1.8;
        }
        .content-section h3 {
            color: var(--ultra-violet);
            margin-top: 2rem;
            margin-bottom: 1rem;
        }
        .content-section h4 {
            color: var(--cadet-gray);
            margin-top: 1.5rem;
            margin-bottom: 0.75rem;
        }
        .last-updated {
            background: var(--tiffany-blue);
            color: white;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 2rem;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
        <!-- Hero Section -->
        <div class="hero-section">
            <div class="container text-center">
                <h1 class="display-4 fw-bold mb-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TermsConditionsTitle %>" /></h1>
                <p class="lead"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TermsConditionsSubtitle %>" /></p>
            </div>
        </div>

        <!-- Main Content -->
        <div class="container py-5">
            <div class="row">
                <div class="col-lg-8 mx-auto">
                    <div class="last-updated text-center">
                        <strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LastUpdated %>" />: <%= DateTime.Now.ToString("dd/MM/yyyy") %></strong>
                    </div>
                    
                    <div class="content-section">
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Introduction %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TermsIntroduction %>" /></p>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AcceptanceTerms %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AcceptanceTermsText %>" /></p>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ServiceDescription %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ServiceDescriptionText1 %>" /></p>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ServiceDescriptionText2 %>" /></p>
                        
                        <h4><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ServicesInclude %>" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ServiceItem1 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ServiceItem2 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ServiceItem3 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ServiceItem4 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ServiceItem5 %>" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UserResponsibilities %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UserResponsibilitiesText %>" /></p>
                        
                        <h4><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UserObligations %>" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UserObligation1 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UserObligation2 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UserObligation3 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UserObligation4 %>" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PrivacyDataProtection %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PrivacyDataProtectionText %>" /></p>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,IntellectualProperty %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,IntellectualPropertyText1 %>" /></p>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,IntellectualPropertyText2 %>" /></p>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LimitationLiability %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LimitationLiabilityText1 %>" /></p>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LimitationLiabilityText2 %>" /></p>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ServiceTermination %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ServiceTerminationText1 %>" /></p>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ServiceTerminationText2 %>" /></p>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TermsModification %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TermsModificationText %>" /></p>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ApplicableLaw %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ApplicableLawText %>" /></p>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ContactInformation %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ContactInformationText %>" /></p>
                        <ul class="list-unstyled">
                            <li><strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Email %>" />:</strong> legal@hirebot-tfi.com</li>
                            <li><strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Address %>" />:</strong> Av. Corrientes 1234, Piso 8, CABA, Argentina</li>
                            <li><strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Phone %>" />:</strong> +54 11 4555-1234</li>
                        </ul>
                    </div>
                    
                    <div class="text-center mt-5">
                        <a href="Default.aspx" class="btn btn-lg px-4" style="background: var(--ultra-violet); border-color: var(--ultra-violet); color: white;">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,BackToHome %>" />
                        </a>
                    </div>
                </div>
            </div>
        </div>

</asp:Content>