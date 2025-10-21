<%@ Page Title="" Language="C#" MasterPageFile="~/Public.master" AutoEventWireup="true" CodeBehind="PrivacyPolicy.aspx.cs" Inherits="Hirebot_TFI.PrivacyPolicy" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PrivacyPolicy %>" /> - Hirebot-TFI
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
        .highlight-box {
            background: #f8f9fa;
            border-left: 4px solid var(--tiffany-blue);
            padding: 1rem;
            margin: 1rem 0;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
        <!-- Hero Section -->
        <div class="hero-section">
            <div class="container text-center">
                <h1 class="display-4 fw-bold mb-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PrivacyPolicyTitle %>" /></h1>
                <p class="lead"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PrivacyPolicySubtitle %>" /></p>
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
                        <div class="highlight-box">
                            <h4><i class="fas fa-shield-alt me-2" style="color: var(--tiffany-blue);"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PrivacyCommitment %>" /></h4>
                            <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PrivacyCommitmentText %>" /></p>
                        </div>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,InformationCollection %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,InformationCollectionText %>" /></p>
                        
                        <h4><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PersonalInformation %>" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PersonalInfo1 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PersonalInfo2 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PersonalInfo3 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PersonalInfo4 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PersonalInfo5 %>" /></li>
                        </ul>
                        
                        <h4><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TechnicalInformation %>" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TechnicalInfo1 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TechnicalInfo2 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TechnicalInfo3 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TechnicalInfo4 %>" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,InformationUse %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,InformationUseText %>" /></p>
                        
                        <h4><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,MainPurposes %>" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Purpose1 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Purpose2 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Purpose3 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Purpose4 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Purpose5 %>" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,InformationSharing %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,InformationSharingText1 %>" /></p>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,InformationSharingText2 %>" /></p>
                        
                        <h4><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SharingCircumstances %>" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SharingCircumstance1 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SharingCircumstance2 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SharingCircumstance3 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SharingCircumstance4 %>" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,DataSecurity %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,DataSecurityText1 %>" /></p>
                        
                        <h4><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityMeasures %>" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityMeasure1 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityMeasure2 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityMeasure3 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityMeasure4 %>" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UserRights %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UserRightsText %>" /></p>
                        
                        <h4><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,YourRights %>" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Right1 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Right2 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Right3 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Right4 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Right5 %>" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CookiesTracking %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CookiesTrackingText1 %>" /></p>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CookiesTrackingText2 %>" /></p>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,DataRetention %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,DataRetentionText1 %>" /></p>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,DataRetentionText2 %>" /></p>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ChildrenPrivacy %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ChildrenPrivacyText %>" /></p>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PolicyChanges %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PolicyChangesText %>" /></p>
                        
                        <div class="highlight-box">
                            <h4><i class="fas fa-envelope me-2" style="color: var(--tiffany-blue);"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ContactUs %>" /></h4>
                            <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PrivacyContactText %>" /></p>
                            <ul class="list-unstyled mb-0">
                                <li><strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Email %>" />:</strong> privacy@hirebot-tfi.com</li>
                                <li><strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Address %>" />:</strong> Av. Corrientes 1234, Piso 8, CABA, Argentina</li>
                                <li><strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Phone %>" />:</strong> +54 11 4555-1234</li>
                            </ul>
                        </div>
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