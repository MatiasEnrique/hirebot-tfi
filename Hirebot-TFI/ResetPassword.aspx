<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="Hirebot_TFI.ResetPassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title><asp:Literal runat="server" Text="Restablecer Contraseña" /> - Hirebot-TFI</title>
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
            padding: 3rem;
            width: 100%;
            max-width: 500px;
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
        .btn-primary-custom:disabled {
            background: var(--cadet-gray);
            transform: none;
            opacity: 0.7;
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
            background: var(--tiffany-blue);
            color: white;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            text-align: center;
        }
        
        .success-message h4 {
            margin-bottom: 0.5rem;
            font-size: 1.1rem;
        }
        
        .success-message p {
            margin-bottom: 0;
            font-size: 0.95rem;
            opacity: 0.9;
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

        .password-requirements {
            background-color: #f8f9fa;
            border-left: 4px solid var(--tiffany-blue);
            padding: 1rem;
            border-radius: 0 8px 8px 0;
            margin-bottom: 1.5rem;
        }

        .password-requirements h6 {
            color: var(--ultra-violet);
            margin-bottom: 0.5rem;
        }

        .password-requirements ul {
            margin-bottom: 0;
            padding-left: 1.2rem;
        }

        .password-requirements li {
            font-size: 0.9rem;
            color: #6c757d;
            margin-bottom: 0.25rem;
        }

        .token-info {
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            color: #856404;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
        }

        .countdown {
            font-weight: bold;
            color: var(--ultra-violet);
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
            .password-requirements {
                padding: 0.75rem;
            }
            .password-requirements h6 {
                font-size: 0.9rem;
            }
            .password-requirements li {
                font-size: 0.85rem;
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
        <asp:ScriptManager ID="ScriptManager1" runat="server" 
            EnablePartialRendering="true" 
            EnableScriptGlobalization="true" 
            EnableScriptLocalization="true"
            ScriptMode="Auto">
        </asp:ScriptManager>
        
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
                            <a class="nav-link" href="Default.aspx"><asp:Literal runat="server" Text="Inicio" /></a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="Catalog.aspx"><asp:Literal runat="server" Text="Catálogo" /></a>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="institutionalDropdown" role="button" data-bs-toggle="dropdown">
                                <asp:Literal runat="server" Text="Acerca de la Empresa" />
                            </a>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" href="AboutUs.aspx"><asp:Literal runat="server" Text="Quiénes Somos" /></a></li>
                                <li><a class="dropdown-item" href="ContactUs.aspx"><asp:Literal runat="server" Text="Contáctanos" /></a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="TermsConditions.aspx"><asp:Literal runat="server" Text="Términos y Condiciones" /></a></li>
                                <li><a class="dropdown-item" href="PrivacyPolicy.aspx"><asp:Literal runat="server" Text="Política de Privacidad" /></a></li>
                                <li><a class="dropdown-item" href="SecurityPolicy.aspx"><asp:Literal runat="server" Text="Política de Seguridad" /></a></li>
                            </ul>
                        </li>
                    </ul>
                    <div class="navbar-nav ms-auto d-flex align-items-center">
                        <!-- Language Selector -->
                        <div class="dropdown me-3">
                            <button class="btn btn-outline-light btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown">
                                <i class="fas fa-globe me-1"></i><asp:Literal runat="server" Text="Idioma" />
                            </button>
                            <ul class="dropdown-menu">
                                <li><asp:LinkButton ID="btnSpanish" runat="server" CssClass="dropdown-item" OnClick="btnSpanish_Click"><asp:Literal runat="server" Text="Español" /></asp:LinkButton></li>
                                <li><asp:LinkButton ID="btnEnglish" runat="server" CssClass="dropdown-item" OnClick="btnEnglish_Click"><asp:Literal runat="server" Text="English" /></asp:LinkButton></li>
                            </ul>
                        </div>
                        <a href="SignIn.aspx" class="btn btn-outline-light me-2"><asp:Literal runat="server" Text="Iniciar Sesión" /></a>
                        <a href="SignUp.aspx" class="btn btn-light"><asp:Literal runat="server" Text="Registrarse" /></a>
                    </div>
                </div>
            </div>
        </nav>
        
        <div class="auth-container">
            <div class="auth-card">
                <div class="text-center mb-4">
                    <h2 class="text-primary-custom fw-bold"><asp:Literal runat="server" Text="Restablecer Contraseña" /></h2>
                    <p class="text-muted"><asp:Literal runat="server" Text="Ingresa tu nueva contraseña" /></p>
                </div>

                <!-- Token Info -->
                <asp:Panel ID="pnlTokenInfo" runat="server" CssClass="token-info">
                    <asp:Literal runat="server" Text="Este enlace expira pronto por tu seguridad" />
                    <span class="countdown" id="countdownTimer"></span>
                </asp:Panel>

                <!-- Password Requirements Section -->
                <div class="password-requirements">
                    <h6><asp:Literal runat="server" Text="Requisitos de Contraseña" /></h6>
                    <ul>
                        <li><asp:Literal runat="server" Text="La contraseña debe tener al menos 6 caracteres." /></li>
                        <li><asp:Literal runat="server" Text="Debe contener letras y números" /></li>
                        <li><asp:Literal runat="server" Text="Se recomiendan caracteres especiales" /></li>
                    </ul>
                </div>

                <asp:Panel ID="pnlError" runat="server" CssClass="alert alert-danger" Visible="false">
                    <asp:Label ID="lblError" runat="server"></asp:Label>
                </asp:Panel>

                <asp:Panel ID="pnlSuccess" runat="server" CssClass="success-message" Visible="false">
                    <h4><asp:Literal runat="server" Text="Tu contraseña ha sido restablecida exitosamente. Ya puedes iniciar sesión con tu nueva contraseña." /></h4>
                    <p><asp:Label ID="lblSuccess" runat="server"></asp:Label></p>
                </asp:Panel>

                <asp:Panel ID="pnlForm" runat="server">
                    <asp:UpdatePanel ID="upResetPassword" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div class="mb-3">
                                <label for="txtNewPassword" class="form-label fw-semibold">
                                    <asp:Literal runat="server" Text="Nueva contraseña" />
                                </label>
                                <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" CssClass="form-control" MaxLength="100"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" 
                                    ControlToValidate="txtNewPassword" 
                                    ErrorMessage="La nueva contraseña es obligatoria" 
                                    CssClass="text-danger small" 
                                    Display="Dynamic" 
                                    ValidationGroup="ResetPassword">
                                </asp:RequiredFieldValidator>
                                <asp:RegularExpressionValidator ID="revNewPassword" runat="server" 
                                    ControlToValidate="txtNewPassword" 
                                    ErrorMessage="La contraseña debe tener al menos 6 caracteres." 
                                    ValidationExpression=".{6,}" 
                                    CssClass="text-danger small" 
                                    Display="Dynamic" 
                                    ValidationGroup="ResetPassword">
                                </asp:RegularExpressionValidator>
                            </div>

                            <div class="mb-3">
                                <label for="txtConfirmNewPassword" class="form-label fw-semibold">
                                    <asp:Literal runat="server" Text="Confirmar nueva contraseña" />
                                </label>
                                <asp:TextBox ID="txtConfirmNewPassword" runat="server" TextMode="Password" CssClass="form-control" MaxLength="100"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvConfirmNewPassword" runat="server" 
                                    ControlToValidate="txtConfirmNewPassword" 
                                    ErrorMessage="La confirmación de contraseña es obligatoria" 
                                    CssClass="text-danger small" 
                                    Display="Dynamic" 
                                    ValidationGroup="ResetPassword">
                                </asp:RequiredFieldValidator>
                                <asp:CompareValidator ID="cvNewPassword" runat="server" 
                                    ControlToValidate="txtConfirmNewPassword" 
                                    ControlToCompare="txtNewPassword" 
                                    ErrorMessage="Las contraseñas no coinciden" 
                                    CssClass="text-danger small" 
                                    Display="Dynamic" 
                                    ValidationGroup="ResetPassword">
                                </asp:CompareValidator>
                            </div>

                            <div class="d-grid mb-3">
                                <asp:Button ID="btnResetPassword" runat="server" 
                                    Text="Restablecer contraseña" 
                                    CssClass="btn btn-primary-custom btn-lg" 
                                    OnClick="btnResetPassword_Click" 
                                    ValidationGroup="ResetPassword" 
                                    UseSubmitBehavior="true"
                                    CausesValidation="true" />
                            </div>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="btnResetPassword" EventName="Click" />
                        </Triggers>
                    </asp:UpdatePanel>
                </asp:Panel>

                <div class="text-center">
                    <a href="SignIn.aspx" class="link-custom fw-semibold">
                        <asp:Literal runat="server" Text="Volver al inicio de sesión" />
                    </a>
                </div>

                <!-- Additional Help Section -->
                <div class="mt-4 pt-3 border-top">
                    <div class="text-center">
                        <p class="text-muted mb-2 small">
                            <asp:Literal runat="server" Text="Si tu enlace ha expirado o no funciona, puedes solicitar uno nuevo" />
                        </p>
                        <a href="ForgotPassword.aspx" class="link-custom small">
                            <asp:Literal runat="server" Text="Solicitar nuevo enlace" />
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </form>
    
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="Scripts/bootstrap.bundle.min.js"></script>
    <script type="text/javascript">
        var countdownInterval;
        
        function pageLoad() {
            setPlaceholderText();
            startCountdown();
        }
        
        function setPlaceholderText() {
            setTimeout(function() {
                try {
                    var newPasswordField = document.getElementById('<%= txtNewPassword.ClientID %>');
                    var confirmPasswordField = document.getElementById('<%= txtConfirmNewPassword.ClientID %>');
                    
                    if (newPasswordField) {
                        newPasswordField.placeholder = '<%= GetLocalizedString("EnterNewPassword") %>';
                    }
                    if (confirmPasswordField) {
                        confirmPasswordField.placeholder = '<%= GetLocalizedString("ConfirmYourNewPassword") %>';
                    }
                } catch (e) {
                    // Silently handle placeholder errors
                }
            }, 100);
        }
        
        function startCountdown() {
            var tokenExpiryMinutes = <%= TokenExpiryMinutes %>;
            if (tokenExpiryMinutes > 0) {
                var totalSeconds = tokenExpiryMinutes * 60;
                var countdownElement = document.getElementById('countdownTimer');
                
                if (countdownElement) {
                    countdownInterval = setInterval(function() {
                        var minutes = Math.floor(totalSeconds / 60);
                        var seconds = totalSeconds % 60;
                        
                        countdownElement.textContent = minutes + ':' + (seconds < 10 ? '0' : '') + seconds;
                        
                        totalSeconds--;
                        
                        if (totalSeconds < 0) {
                            clearInterval(countdownInterval);
                            countdownElement.textContent = '<%= GetLocalizedString("TokenExpired") %>';
                            countdownElement.style.color = '#dc3545';
                            
                            // Disable the form
                            var form = document.getElementById('<%= pnlForm.ClientID %>');
                            if (form) {
                                form.style.opacity = '0.6';
                                form.style.pointerEvents = 'none';
                            }
                        }
                    }, 1000);
                }
            }
        }
        
        // Initialize when DOM is ready
        $(document).ready(function() {
            pageLoad();
            
            // Handle UpdatePanel postbacks
            if (typeof Sys !== 'undefined') {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function(sender, args) {
                    // Reinitialize page elements after partial postback
                    setPlaceholderText();
                    
                    // Restart countdown if needed
                    if (countdownInterval) {
                        clearInterval(countdownInterval);
                    }
                    startCountdown();
                });
            }
        });
        
        // Clean up interval on page unload
        window.addEventListener('beforeunload', function() {
            if (countdownInterval) {
                clearInterval(countdownInterval);
            }
        });
    </script>
</body>
</html>