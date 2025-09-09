<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SignUp.aspx.cs" Inherits="Hirebot_TFI.SignUp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Registrarse - Hirebot-TFI</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Content/site.css" rel="stylesheet" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <style>
        .auth-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--tiffany-blue), var(--ultra-violet));
            padding: 1rem;
        }
        .auth-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            padding: 2rem;
            width: 100%;
            max-width: 600px;
            margin: auto;
        }
        .btn-primary-custom {
            background: var(--ultra-violet);
            border: none;
            border-radius: 8px;
            padding: 12px 24px;
            font-weight: 500;
            color: white;
            transition: all 0.3s ease;
        }
        .btn-primary-custom:hover {
            background: var(--cadet-gray);
            transform: translateY(-1px);
        }
        .form-control {
            border-radius: 8px;
            border: 2px solid #e9ecef;
            padding: 12px 15px;
            transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
        }
        .form-control:focus {
            border-color: var(--ultra-violet);
            box-shadow: 0 0 0 0.2rem rgba(75, 78, 109, 0.25);
        }
        .text-primary-custom {
            color: var(--ultra-violet) !important;
        }
        .link-custom {
            color: var(--ultra-violet);
            text-decoration: none;
            transition: color 0.2s ease;
        }
        .link-custom:hover {
            color: var(--cadet-gray);
            text-decoration: underline;
        }
        .success-message {
            background-color: #d1edff;
            border: 1px solid var(--tiffany-blue);
            color: var(--ultra-violet);
        }

        /* Mobile Responsive Styles */
        @media (max-width: 768px) {
            .auth-container {
                padding: 0.5rem;
                min-height: 100vh;
            }
            .auth-card {
                padding: 1.5rem;
                margin: 0.5rem;
                border-radius: 10px;
                max-width: none;
            }
            .auth-card h2 {
                font-size: 1.5rem;
            }
            .form-control {
                padding: 10px 12px;
                font-size: 16px; 
            }
            .btn-primary-custom {
                padding: 14px 20px;
                font-size: 16px;
            }
            .col-md-6 {
                margin-bottom: 1rem !important;
            }
        }

        @media (max-width: 576px) {
            .auth-card {
                padding: 1rem;
                margin: 0.25rem;
            }
            .auth-card h2 {
                font-size: 1.3rem;
                margin-bottom: 0.5rem;
            }
            .auth-card p {
                font-size: 0.9rem;
                margin-bottom: 1rem;
            }
            .form-label {
                font-size: 0.9rem;
                margin-bottom: 0.5rem;
            }
            .form-text {
                font-size: 0.8rem;
            }
            .btn-primary-custom {
                padding: 12px 16px;
                font-size: 15px;
            }
        }

        @media (max-width: 480px) {
            .auth-container {
                padding: 0.25rem;
            }
            .auth-card {
                padding: 0.75rem;
                border-radius: 8px;
            }
            .row .col-md-6:first-child {
                padding-right: 7.5px;
            }
            .row .col-md-6:last-child {
                padding-left: 7.5px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Navigation Bar -->
        <nav class="navbar navbar-expand-lg navbar-dark" style="background: var(--ultra-violet);">
            <div class="container">
                <a class="navbar-brand fw-bold" href="Default.aspx">Hirebot-TFI</a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav me-auto">
                        <li class="nav-item">
                            <a class="nav-link" href="Default.aspx"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Home %>" /></a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="Catalog.aspx"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ProductCatalog %>" /></a>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="institutionalDropdown" role="button" data-bs-toggle="dropdown">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AboutCompany %>" />
                            </a>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" href="AboutUs.aspx"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AboutUs %>" /></a></li>
                                <li><a class="dropdown-item" href="ContactUs.aspx"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ContactUs %>" /></a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="TermsConditions.aspx"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TermsConditions %>" /></a></li>
                                <li><a class="dropdown-item" href="PrivacyPolicy.aspx"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PrivacyPolicy %>" /></a></li>
                                <li><a class="dropdown-item" href="SecurityPolicy.aspx"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SecurityPolicy %>" /></a></li>
                            </ul>
                        </li>
                    </ul>
                    <div class="navbar-nav ms-auto d-flex align-items-center">
                        <!-- Language Selector -->
                        <div class="dropdown me-3">
                            <button class="btn btn-outline-light btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown">
                                <i class="fas fa-globe me-1"></i><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Language %>" />
                            </button>
                            <ul class="dropdown-menu">
                                <li><asp:LinkButton ID="btnSpanish" runat="server" CssClass="dropdown-item" OnClick="btnSpanish_Click"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Spanish %>" /></asp:LinkButton></li>
                                <li><asp:LinkButton ID="btnEnglish" runat="server" CssClass="dropdown-item" OnClick="btnEnglish_Click"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,English %>" /></asp:LinkButton></li>
                            </ul>
                        </div>
                        <a href="SignIn.aspx" class="btn btn-outline-light me-2"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SignIn %>" /></a>
                        <a href="SignUp.aspx" class="btn btn-light active"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SignUp %>" /></a>
                    </div>
                </div>
            </div>
        </nav>
        
        <div class="auth-container">
            <div class="auth-card">
                <div class="text-center mb-4">
                    <h2 class="text-primary-custom fw-bold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CreateAccount %>" /></h2>
                    <p class="text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,JoinHirebot %>" /></p>
                </div>

                <asp:Panel ID="pnlError" runat="server" CssClass="alert alert-danger" Visible="false">
                    <asp:Label ID="lblError" runat="server"></asp:Label>
                </asp:Panel>

                <asp:Panel ID="pnlSuccess" runat="server" CssClass="alert success-message" Visible="false">
                    <asp:Label ID="lblSuccess" runat="server"></asp:Label>
                </asp:Panel>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="txtFirstName" class="form-label fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FirstName %>" /></label>
                        <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvFirstName" runat="server" ControlToValidate="txtFirstName" 
                            ErrorMessage="<%$ Resources:GlobalResources,FirstNameRequired %>" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="txtLastName" class="form-label fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LastName %>" /></label>
                        <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvLastName" runat="server" ControlToValidate="txtLastName" 
                            ErrorMessage="<%$ Resources:GlobalResources,LastNameRequired %>" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                    </div>
                </div>

                <div class="mb-3">
                    <label for="txtUsername" class="form-label fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Username %>" /></label>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control"></asp:TextBox>
                    <div class="form-text"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UsernameHelp %>" /></div>
                    <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ControlToValidate="txtUsername" 
                        ErrorMessage="<%$ Resources:GlobalResources,UsernameRequired %>" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                </div>

                <div class="mb-3">
                    <label for="txtEmail" class="form-label fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Email %>" /></label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="form-control"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" 
                        ErrorMessage="<%$ Resources:GlobalResources,EmailRequired %>" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" 
                        ValidationExpression="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
                        ErrorMessage="<%$ Resources:GlobalResources,ValidEmailRequired %>" CssClass="text-danger small" Display="Dynamic"></asp:RegularExpressionValidator>
                </div>

                <div class="mb-3">
                    <label for="txtPassword" class="form-label fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Password %>" /></label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                    <div class="form-text"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PasswordHelp %>" /></div>
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" 
                        ErrorMessage="<%$ Resources:GlobalResources,PasswordRequired %>" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                </div>

                <div class="mb-4">
                    <label for="txtConfirmPassword" class="form-label fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ConfirmPassword %>" /></label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" ControlToValidate="txtConfirmPassword" 
                        ErrorMessage="<%$ Resources:GlobalResources,ConfirmPasswordRequired %>" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                    <asp:CompareValidator ID="cvPassword" runat="server" ControlToValidate="txtConfirmPassword" ControlToCompare="txtPassword"
                        ErrorMessage="<%$ Resources:GlobalResources,PasswordsDoNotMatch %>" CssClass="text-danger small" Display="Dynamic"></asp:CompareValidator>
                </div>

                <div class="d-grid mb-3">
                    <asp:Button ID="btnSignUp" runat="server" Text="<%$ Resources:GlobalResources,CreateAccount %>" CssClass="btn btn-primary-custom btn-lg" OnClick="btnSignUp_Click" />
                </div>

                <div class="text-center">
                    <p class="mb-0"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AlreadyHaveAccount %>" /> <a href="SignIn.aspx" class="link-custom fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SignInHere %>" /></a></p>
                </div>
            </div>
        </div>
    </form>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="Scripts/bootstrap.bundle.min.js"></script>
</body>
</html>