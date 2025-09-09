<%@ Page Title="" Language="C#" MasterPageFile="~/Public.master" AutoEventWireup="true" CodeBehind="ContactUs.aspx.cs" Inherits="Hirebot_TFI.ContactUs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ContactUs %>" /> - Hirebot-TFI
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .hero-section {
            background: linear-gradient(135deg, var(--tiffany-blue), var(--ultra-violet));
            color: white;
            padding: 80px 0 60px 0;
        }
        .contact-info {
            background: var(--eerie-black);
            color: white;
            border-radius: 10px;
        }
        .contact-form {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
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
                <h1 class="display-4 fw-bold mb-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ContactUsTitle %>" /></h1>
                <p class="lead"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ContactUsSubtitle %>" /></p>
            </div>
        </div>

        <!-- Main Content -->
        <div class="container py-5">
            <div class="row">
                <!-- Contact Information -->
                <div class="col-lg-4 mb-4">
                    <div class="contact-info p-4 h-100">
                        <h3 class="mb-4" style="color: var(--tiffany-blue);"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ContactInformation %>" /></h3>
                        
                        <div class="mb-4">
                            <h5><i class="fas fa-map-marker-alt me-2" style="color: var(--tiffany-blue);"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Address %>" /></h5>
                            <p class="ms-4">Av. Corrientes 1234, Piso 8<br>Ciudad Autónoma de Buenos Aires<br>Argentina (C1043AAZ)</p>
                        </div>
                        
                        <div class="mb-4">
                            <h5><i class="fas fa-phone me-2" style="color: var(--tiffany-blue);"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Phone %>" /></h5>
                            <p class="ms-4">+54 11 4555-1234<br>+54 11 4555-5678</p>
                        </div>
                        
                        <div class="mb-4">
                            <h5><i class="fas fa-envelope me-2" style="color: var(--tiffany-blue);"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Email %>" /></h5>
                            <p class="ms-4">info@hirebot-tfi.com<br>support@hirebot-tfi.com</p>
                        </div>
                        
                        <div class="mb-4">
                            <h5><i class="fas fa-clock me-2" style="color: var(--tiffany-blue);"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,BusinessHours %>" /></h5>
                            <p class="ms-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,MondayToFriday %>" />: 9:00 - 18:00<br><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Saturday %>" />: 9:00 - 13:00</p>
                        </div>

                        <div>
                            <h5><i class="fas fa-share-alt me-2" style="color: var(--tiffany-blue);"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SocialMedia %>" /></h5>
                            <div class="ms-4 mt-2">
                                <a href="#" class="text-light me-3"><i class="fab fa-linkedin fa-lg"></i></a>
                                <a href="#" class="text-light me-3"><i class="fab fa-twitter fa-lg"></i></a>
                                <a href="#" class="text-light me-3"><i class="fab fa-facebook fa-lg"></i></a>
                                <a href="#" class="text-light"><i class="fab fa-instagram fa-lg"></i></a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Contact Form -->
                <div class="col-lg-8">
                    <div class="contact-form p-4">
                        <h3 class="section-title mb-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SendMessage %>" /></h3>
                        
                        <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="alert alert-success">
                            <i class="fas fa-check-circle me-2"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,MessageSentSuccess %>" />
                        </asp:Panel>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FirstName %>" /> *</label>
                                <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control" Required="true"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvFirstName" runat="server" ControlToValidate="txtFirstName" 
                                    ErrorMessage="<%$ Resources:GlobalResources,FirstNameRequired %>" CssClass="text-danger" Display="Dynamic"></asp:RequiredFieldValidator>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LastName %>" /> *</label>
                                <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control" Required="true"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvLastName" runat="server" ControlToValidate="txtLastName" 
                                    ErrorMessage="<%$ Resources:GlobalResources,LastNameRequired %>" CssClass="text-danger" Display="Dynamic"></asp:RequiredFieldValidator>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Email %>" /> *</label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" Required="true"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" 
                                    ErrorMessage="<%$ Resources:GlobalResources,EmailRequired %>" CssClass="text-danger" Display="Dynamic"></asp:RequiredFieldValidator>
                                <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                                    ValidationExpression="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
                                    ErrorMessage="<%$ Resources:GlobalResources,EmailInvalid %>" CssClass="text-danger" Display="Dynamic"></asp:RegularExpressionValidator>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Phone %>" /></label>
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Company %>" /></label>
                            <asp:TextBox ID="txtCompany" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Subject %>" /> *</label>
                            <asp:TextBox ID="txtSubject" runat="server" CssClass="form-control" Required="true"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvSubject" runat="server" ControlToValidate="txtSubject" 
                                ErrorMessage="<%$ Resources:GlobalResources,SubjectRequired %>" CssClass="text-danger" Display="Dynamic"></asp:RequiredFieldValidator>
                        </div>
                        
                        <div class="mb-4">
                            <label class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Message %>" /> *</label>
                            <asp:TextBox ID="txtMessage" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="6" Required="true"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvMessage" runat="server" ControlToValidate="txtMessage" 
                                ErrorMessage="<%$ Resources:GlobalResources,MessageRequired %>" CssClass="text-danger" Display="Dynamic"></asp:RequiredFieldValidator>
                        </div>
                        
                        <div class="text-end">
                            <asp:Button ID="btnSendMessage" runat="server" Text="<%$ Resources:GlobalResources,SendMessage %>" 
                                CssClass="btn btn-lg px-4" style="background: var(--ultra-violet); border-color: var(--ultra-violet); color: white;" 
                                OnClick="btnSendMessage_Click" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Map Section -->
            <div class="row mt-5">
                <div class="col-12">
                    <h3 class="section-title mb-4"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FindUs %>" /></h3>
                    <div class="bg-light p-4 rounded text-center">
                        <i class="fas fa-map-marked-alt fa-3x mb-3" style="color: var(--ultra-violet);"></i>
                        <h5><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,VisitOurOffice %>" /></h5>
                        <p class="mb-0">Av. Corrientes 1234, Piso 8 - Ciudad Autónoma de Buenos Aires, Argentina</p>
                        <small class="text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NearSubway %>" /></small>
                    </div>
                </div>
            </div>
        </div>

</asp:Content>