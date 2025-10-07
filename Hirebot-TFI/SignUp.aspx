<%@ Page Title="" Language="C#" MasterPageFile="~/Public.master" AutoEventWireup="true" CodeBehind="SignUp.aspx.cs" Inherits="Hirebot_TFI.SignUp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Sign Up - Hirebot-TFI
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
        .auth-card {
            border-radius: 1rem;
        }
        .auth-card .card-body {
            padding: 2.5rem;
        }
        .auth-card .form-control {
            border-radius: 0.75rem;
            border: 2px solid #e9ecef;
            padding: 0.75rem 1rem;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }
        .auth-card .form-control:focus {
            border-color: var(--ultra-violet);
            box-shadow: 0 0 0 0.2rem rgba(75, 78, 109, 0.2);
        }
        .auth-card .form-text {
            color: #6c757d;
        }
        .btn-gradient {
            background: var(--ultra-violet);
            border: none;
            border-radius: 0.75rem;
            padding: 0.75rem 1.5rem;
            color: #fff;
            font-weight: 600;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .btn-gradient:hover {
            background: var(--cadet-gray);
            color: #fff;
            transform: translateY(-2px);
        }
        .auth-link {
            color: var(--tiffany-blue);
            font-weight: 600;
            text-decoration: none;
        }
        .auth-link:hover {
            color: var(--cadet-gray);
            text-decoration: underline;
        }
        .alert-soft-success {
            background-color: rgba(132, 220, 198, 0.15);
            border: 1px solid rgba(132, 220, 198, 0.4);
            color: var(--ultra-violet);
        }
        .feature-list li {
            margin-bottom: 0.75rem;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <section class="welcome-section py-5">
        <div class="container py-5">
            <div class="row align-items-center g-5">
                <div class="col-lg-5 text-center text-lg-start">
                    <h1 class="display-5 fw-bold mb-4">
                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CreateAccount %>" />
                    </h1>
                    <p class="lead mb-4">
                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,JoinHirebot %>" />
                    </p>
                    <ul class="feature-list list-unstyled d-inline-block text-start">
                        <li>
                            <i class="bi bi-check-circle-fill me-2"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AIScreening %>" />
                        </li>
                        <li>
                            <i class="bi bi-check-circle-fill me-2"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CandidateManagement %>" />
                        </li>
                        <li>
                            <i class="bi bi-check-circle-fill me-2"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Analytics %>" />
                        </li>
                    </ul>
                </div>
                <div class="col-lg-7 col-xl-6 ms-lg-auto">
                    <div class="card auth-card border-0 shadow-lg">
                        <div class="card-body">
                            <asp:Panel ID="pnlError" runat="server" CssClass="alert alert-danger mb-4" Visible="false">
                                <asp:Label ID="lblError" runat="server"></asp:Label>
                            </asp:Panel>

                            <asp:Panel ID="pnlSuccess" runat="server" CssClass="alert alert-soft-success mb-4" Visible="false">
                                <asp:Label ID="lblSuccess" runat="server"></asp:Label>
                            </asp:Panel>

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label for="<%= txtFirstName.ClientID %>" class="form-label fw-semibold text-dark">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FirstName %>" />
                                    </label>
                                    <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvFirstName" runat="server" ControlToValidate="txtFirstName"
                                        ErrorMessage="<%$ Resources:GlobalResources,FirstNameRequired %>" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                                </div>
                                <div class="col-md-6">
                                    <label for="<%= txtLastName.ClientID %>" class="form-label fw-semibold text-dark">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LastName %>" />
                                    </label>
                                    <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvLastName" runat="server" ControlToValidate="txtLastName"
                                        ErrorMessage="<%$ Resources:GlobalResources,LastNameRequired %>" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                                </div>
                            </div>

                            <div class="mt-3">
                                <label for="<%= txtUsername.ClientID %>" class="form-label fw-semibold text-dark">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Username %>" />
                                </label>
                                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control"></asp:TextBox>
                                <div class="form-text">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UsernameHelp %>" />
                                </div>
                                <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ControlToValidate="txtUsername"
                                    ErrorMessage="<%$ Resources:GlobalResources,UsernameRequired %>" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                            </div>

                            <div class="mt-3">
                                <label for="<%= txtEmail.ClientID %>" class="form-label fw-semibold text-dark">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Email %>" />
                                </label>
                                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="form-control"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                                    ErrorMessage="<%$ Resources:GlobalResources,EmailRequired %>" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                                <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                                    ValidationExpression="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
                                    ErrorMessage="<%$ Resources:GlobalResources,ValidEmailRequired %>" CssClass="text-danger small" Display="Dynamic"></asp:RegularExpressionValidator>
                            </div>

                            <div class="mt-3">
                                <label for="<%= txtPassword.ClientID %>" class="form-label fw-semibold text-dark">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Password %>" />
                                </label>
                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                                <div class="form-text">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PasswordHelp %>" />
                                </div>
                                <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword"
                                    ErrorMessage="<%$ Resources:GlobalResources,PasswordRequired %>" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                            </div>

                            <div class="mt-3">
                                <label for="<%= txtConfirmPassword.ClientID %>" class="form-label fw-semibold text-dark">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ConfirmPassword %>" />
                                </label>
                                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" ControlToValidate="txtConfirmPassword"
                                    ErrorMessage="<%$ Resources:GlobalResources,ConfirmPasswordRequired %>" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                                <asp:CompareValidator ID="cvPassword" runat="server" ControlToValidate="txtConfirmPassword" ControlToCompare="txtPassword"
                                    ErrorMessage="<%$ Resources:GlobalResources,PasswordsDoNotMatch %>" CssClass="text-danger small" Display="Dynamic"></asp:CompareValidator>
                            </div>

                            <div class="mt-4">
                                <div id="recaptchaWidget" runat="server" class="g-recaptcha"></div>
                                <asp:CustomValidator ID="cvRecaptcha" runat="server" CssClass="text-danger small d-block mt-2" Display="Dynamic" ValidateEmptyText="true" OnServerValidate="cvRecaptcha_ServerValidate"></asp:CustomValidator>
                            </div>

                            <div class="d-grid mt-4">
                                <asp:Button ID="btnSignUp" runat="server" Text="<%$ Resources:GlobalResources,CreateAccount %>" CssClass="btn btn-gradient btn-lg" OnClick="btnSignUp_Click" />
                            </div>

                            <div class="text-center mt-4">
                                <span class="text-muted">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AlreadyHaveAccount %>" />
                                </span>
                                <a href="SignIn.aspx" class="auth-link ms-1">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SignInHere %>" />
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
</asp:Content>
