<%@ Page Title="" Language="C#" MasterPageFile="~/Public.master" AutoEventWireup="true" CodeBehind="SecurityPolicy.aspx.cs" Inherits="Hirebot_TFI.SecurityPolicy" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityPolicy %>" /> - Hirebot-TFI
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
        .security-highlight {
            background: linear-gradient(45deg, #f8f9fa, #e9ecef);
            border: 2px solid var(--tiffany-blue);
            border-radius: 8px;
            padding: 1.5rem;
            margin: 1.5rem 0;
        }
        .security-feature {
            background: white;
            border-left: 4px solid var(--ultra-violet);
            padding: 1rem;
            margin: 1rem 0;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
        <!-- Hero Section -->
        <div class="hero-section">
            <div class="container text-center">
                <h1 class="display-4 fw-bold mb-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityPolicyTitle %>" /></h1>
                <p class="lead"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityPolicySubtitle %>" /></p>
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
                        <div class="security-highlight text-center">
                            <i class="fas fa-shield-alt fa-3x mb-3" style="color: var(--ultra-violet);"></i>
                            <h4><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityCommitment %>" /></h4>
                            <p class="mb-0"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityCommitmentText %>" /></p>
                        </div>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,DataProtection %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,DataProtectionText %>" /></p>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="security-feature">
                                    <h5><i class="fas fa-lock me-2" style="color: var(--ultra-violet);"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Encryption %>" /></h5>
                                    <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,EncryptionDescription %>" /></p>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="security-feature">
                                    <h5><i class="fas fa-server me-2" style="color: var(--tiffany-blue);"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecureServers %>" /></h5>
                                    <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecureServersDescription %>" /></p>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="security-feature">
                                    <h5><i class="fas fa-key me-2" style="color: var(--cadet-gray);"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccessControl %>" /></h5>
                                    <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AccessControlDescription %>" /></p>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="security-feature">
                                    <h5><i class="fas fa-eye me-2" style="color: var(--eerie-black);"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Monitoring %>" /></h5>
                                    <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,MonitoringDescription %>" /></p>
                                </div>
                            </div>
                        </div>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UserSecurity %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UserSecurityText %>" /></p>
                        
                        <h4><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityRecommendations %>" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityRec1 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityRec2 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityRec3 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityRec4 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityRec5 %>" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,IncidentResponse %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,IncidentResponseText1 %>" /></p>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,IncidentResponseText2 %>" /></p>
                        
                        <h4><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,IncidentProcedure %>" /></h4>
                        <ol>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,IncidentStep1 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,IncidentStep2 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,IncidentStep3 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,IncidentStep4 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,IncidentStep5 %>" /></li>
                        </ol>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ComplianceCertifications %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ComplianceCertificationsText %>" /></p>
                        
                        <div class="row text-center">
                            <div class="col-md-4 mb-3">
                                <div class="security-feature text-center">
                                    <i class="fas fa-certificate fa-2x mb-2" style="color: var(--ultra-violet);"></i>
                                    <h6>ISO 27001</h6>
                                    <small><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ISO27001Description %>" /></small>
                                </div>
                            </div>
                            <div class="col-md-4 mb-3">
                                <div class="security-feature text-center">
                                    <i class="fas fa-shield-alt fa-2x mb-2" style="color: var(--tiffany-blue);"></i>
                                    <h6>SOC 2 Type II</h6>
                                    <small><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SOC2Description %>" /></small>
                                </div>
                            </div>
                            <div class="col-md-4 mb-3">
                                <div class="security-feature text-center">
                                    <i class="fas fa-gavel fa-2x mb-2" style="color: var(--cadet-gray);"></i>
                                    <h6>GDPR</h6>
                                    <small><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,GDPRDescription %>" /></small>
                                </div>
                            </div>
                        </div>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,RegularAudits %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,RegularAuditsText %>" /></p>
                        
                        <h4><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AuditTypes %>" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AuditType1 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AuditType2 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AuditType3 %>" /></li>
                            <li><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AuditType4 %>" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ReportingSecurity %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ReportingSecurityText %>" /></p>
                        
                        <div class="security-highlight">
                            <h4><i class="fas fa-exclamation-triangle me-2" style="color: var(--tiffany-blue);"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityContact %>" /></h4>
                            <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityContactText %>" /></p>
                            <ul class="list-unstyled mb-0">
                                <li><strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Email %>" />:</strong> security@hirebot-tfi.com</li>
                                <li><strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,EmergencyPhone %>" />:</strong> +54 11 4555-9999 (24/7)</li>
                                <li><strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityPortal %>" />:</strong> security.hirebot-tfi.com</li>
                            </ul>
                        </div>
                        
                        <h3><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PolicyUpdates %>" /></h3>
                        <p><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PolicyUpdatesText %>" /></p>
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