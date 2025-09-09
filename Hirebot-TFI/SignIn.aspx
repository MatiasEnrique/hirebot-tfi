<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SignIn.aspx.cs" Inherits="Hirebot_TFI.SignIn" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Iniciar Sesión - Hirebot-TFI</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Content/site.css" rel="stylesheet" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <style>
        .auth-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            padding: 1rem;
        }
        .auth-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            padding: 3rem;
            width: 100%;
            max-width: 450px;
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


        /* Password Reset Mode Styles */
        .password-reset-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--tiffany-blue), var(--ultra-violet));
            padding: 1rem;
        }
        
        .success-message {
            background: var(--tiffany-blue);
            color: white;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            text-align: center;
        }
        
        .loading-spinner {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255,255,255,.3);
            border-radius: 50%;
            border-top-color: #fff;
            animation: spin 1s ease-in-out infinite;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Mobile Responsive Styles */
        @media (max-width: 768px) {
            .auth-container {
                padding: 0.5rem;
                min-height: 100vh;
            }
            .auth-card {
                padding: 2rem;
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
        }

        @media (max-width: 576px) {
            .auth-card {
                padding: 1.5rem;
                margin: 0.25rem;
            }
            .auth-card h2 {
                font-size: 1.3rem;
                margin-bottom: 0.5rem;
            }
            .auth-card p {
                font-size: 0.9rem;
                margin-bottom: 1.5rem;
            }
            .form-label {
                font-size: 0.9rem;
                margin-bottom: 0.5rem;
            }
            .btn-primary-custom {
                padding: 12px 16px;
                font-size: 15px;
            }
            .form-check-label {
                font-size: 0.9rem;
            }
        }

        @media (max-width: 480px) {
            .auth-container {
                padding: 0.25rem;
            }
            .auth-card {
                padding: 1rem;
                border-radius: 8px;
            }
            .auth-card h2 {
                font-size: 1.2rem;
            }
            .form-control {
                padding: 8px 10px;
            }
            .btn-primary-custom {
                padding: 10px 14px;
                font-size: 14px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
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
                        <a href="SignIn.aspx" class="btn btn-outline-light me-2 active"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SignIn %>" /></a>
                        <a href="SignUp.aspx" class="btn btn-light"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SignUp %>" /></a>
                    </div>
                </div>
            </div>
        </nav>
        
        <div class="auth-container" id="mainAuthContainer" runat="server">
            <div class="auth-card">
                <div class="text-center mb-4">
                    <h2 class="text-primary-custom fw-bold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,WelcomeBack %>" /></h2>
                    <p class="text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SignInToAccount %>" /></p>
                </div>

                <asp:Panel ID="pnlError" runat="server" CssClass="alert alert-danger" Visible="false">
                    <asp:Label ID="lblError" runat="server"></asp:Label>
                </asp:Panel>

                <asp:Panel ID="pnlSuccess" runat="server" CssClass="alert alert-success" Visible="false">
                    <asp:Label ID="lblSuccess" runat="server"></asp:Label>
                </asp:Panel>

                <!-- Normal Sign-In Form Panel -->
                <asp:Panel ID="pnlSignIn" runat="server">
                    <div class="mb-3">
                        <label for="txtUsernameOrEmail" class="form-label fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UsernameOrEmail %>" /></label>
                        <asp:TextBox ID="txtUsernameOrEmail" runat="server" CssClass="form-control"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvUsernameOrEmail" runat="server" ControlToValidate="txtUsernameOrEmail" 
                            ErrorMessage="<%$ Resources:GlobalResources,UsernameRequired %>" CssClass="text-danger small" Display="Dynamic" ValidationGroup="SignIn"></asp:RequiredFieldValidator>
                    </div>

                    <div class="mb-3">
                        <label for="txtPassword" class="form-label fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Password %>" /></label>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" 
                            ErrorMessage="<%$ Resources:GlobalResources,PasswordRequired %>" CssClass="text-danger small" Display="Dynamic" ValidationGroup="SignIn"></asp:RequiredFieldValidator>
                    </div>

                    <div class="mb-3 form-check">
                        <asp:CheckBox ID="chkRememberMe" runat="server" CssClass="form-check-input" />
                        <label class="form-check-label" for="chkRememberMe">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,RememberMe %>" />
                        </label>
                    </div>

                    <div class="d-grid mb-3">
                        <asp:Button ID="btnSignIn" runat="server" Text="<%$ Resources:GlobalResources,SignIn %>" CssClass="btn btn-primary-custom btn-lg" OnClick="btnSignIn_Click" ValidationGroup="SignIn" />
                    </div>

                    <div class="text-center mb-3">
                        <a href="ForgotPassword.aspx" class="btn btn-link link-custom p-0">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ForgotPassword %>" />
                        </a>
                    </div>

                    <div class="text-center">
                        <p class="mb-0"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,DontHaveAccount %>" /> <a href="SignUp.aspx" class="link-custom fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SignUpHere %>" /></a></p>
                    </div>
                </asp:Panel>

                <!-- Password Reset Form Panel (shown when token is present) -->
                <asp:Panel ID="pnlPasswordReset" runat="server" Visible="false">
                    <div class="text-center mb-4">
                        <h2 class="text-primary-custom fw-bold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,PasswordResetTitle %>" /></h2>
                        <p class="text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,EnterNewPassword %>" /></p>
                    </div>

                    <div class="mb-3">
                        <label for="txtNewPassword" class="form-label fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NewPassword %>" /></label>
                        <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" ControlToValidate="txtNewPassword" 
                            ErrorMessage="<%$ Resources:GlobalResources,NewPasswordRequired %>" CssClass="text-danger small" Display="Dynamic" ValidationGroup="PasswordReset"></asp:RequiredFieldValidator>
                        <asp:RegularExpressionValidator ID="revNewPassword" runat="server" ControlToValidate="txtNewPassword" 
                            ErrorMessage="<%$ Resources:GlobalResources,PasswordMinLength %>" ValidationExpression=".{6,}" CssClass="text-danger small" Display="Dynamic" ValidationGroup="PasswordReset"></asp:RegularExpressionValidator>
                    </div>

                    <div class="mb-3">
                        <label for="txtConfirmNewPassword" class="form-label fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ConfirmNewPassword %>" /></label>
                        <asp:TextBox ID="txtConfirmNewPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvConfirmNewPassword" runat="server" ControlToValidate="txtConfirmNewPassword" 
                            ErrorMessage="<%$ Resources:GlobalResources,ConfirmNewPasswordRequired %>" CssClass="text-danger small" Display="Dynamic" ValidationGroup="PasswordReset"></asp:RequiredFieldValidator>
                        <asp:CompareValidator ID="cvNewPassword" runat="server" ControlToValidate="txtConfirmNewPassword" ControlToCompare="txtNewPassword" 
                            ErrorMessage="<%$ Resources:GlobalResources,NewPasswordsDoNotMatch %>" CssClass="text-danger small" Display="Dynamic" ValidationGroup="PasswordReset"></asp:CompareValidator>
                    </div>

                    <div class="d-grid mb-3">
                        <asp:UpdatePanel ID="upPasswordReset" runat="server">
                            <ContentTemplate>
                                <asp:Button ID="btnResetPassword" runat="server" Text="<%$ Resources:GlobalResources,ResetPassword %>" CssClass="btn btn-primary-custom btn-lg" OnClick="btnResetPassword_Click" ValidationGroup="PasswordReset" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>

                    <div class="text-center">
                        <a href="SignIn.aspx" class="link-custom fw-semibold"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,BackToSignIn %>" /></a>
                    </div>
                </asp:Panel>
            </div>
        </div>

    </form>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="Scripts/bootstrap.bundle.min.js"></script>
    <script type="text/javascript">
        function pageLoad() {
            setPlaceholderText();
        }
        
        function setPlaceholderText() {
            setTimeout(function() {
                try {
                    var usernameField = document.getElementById('<%= txtUsernameOrEmail.ClientID %>');
                    var passwordField = document.getElementById('<%= txtPassword.ClientID %>');
                    var newPasswordField = document.getElementById('<%= txtNewPassword.ClientID %>');
                    var confirmPasswordField = document.getElementById('<%= txtConfirmNewPassword.ClientID %>');
                    
                    if (usernameField) usernameField.placeholder = '<%= GetLocalizedString("EnterUsername") %>';
                    if (passwordField) passwordField.placeholder = '<%= GetLocalizedString("EnterPassword") %>';
                    if (newPasswordField) newPasswordField.placeholder = '<%= GetLocalizedString("EnterNewPassword") %>';
                    if (confirmPasswordField) confirmPasswordField.placeholder = '<%= GetLocalizedString("ConfirmYourNewPassword") %>';
                    
                } catch (e) {
                }
            }, 100);
        }
        
        function showLoadingState(button) {
            try {
                if (button) {
                    var originalText = button.value;
                    button.setAttribute('data-original-text', originalText);
                    button.value = '\u23f3 ' + originalText;
                    button.disabled = true;
                    
                    // Re-enable after timeout as fallback
                    setTimeout(function() {
                        if (button.disabled) {
                            button.value = button.getAttribute('data-original-text') || originalText;
                            button.disabled = false;
                        }
                    }, 10000); // 10 second timeout
                }
            } catch (e) {
            }
        }
        
        function hideLoadingState(button) {
            try {
                if (button) {
                    var originalText = button.getAttribute('data-original-text');
                    if (originalText) {
                        button.value = originalText;
                    }
                    button.disabled = false;
                }
            } catch (e) {
            }
        }
        
        function handlePasswordResetSubmit() {
            var button = document.getElementById('<%= btnResetPassword.ClientID %>');
            showLoadingState(button);
            return true;
        }
        
        // Initialize when DOM is ready
        $(document).ready(function() {
            pageLoad();
            
            // Handle UpdatePanel postbacks
            if (typeof Sys !== 'undefined') {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function(sender, args) {
                    
                    setTimeout(function() {
                        setPlaceholderText();
                        
                        // Hide loading states
                        var resetButton = document.getElementById('<%= btnResetPassword.ClientID %>');
                        if (resetButton) hideLoadingState(resetButton);
                    }, 100);
                });
            }
        });
    </script>
</body>
</html>