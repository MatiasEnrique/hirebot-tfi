<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="Hirebot_TFI.ForgotPassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title><asp:Literal runat="server" Text="¿Olvidaste tu contraseña?" /> - Hirebot-TFI</title>
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

        .info-section {
            background-color: #f8f9fa;
            border-left: 4px solid var(--tiffany-blue);
            padding: 1rem;
            border-radius: 0 8px 8px 0;
            margin-bottom: 1.5rem;
        }

        .info-section h6 {
            color: var(--ultra-violet);
            margin-bottom: 0.5rem;
        }

        .info-section p {
            margin-bottom: 0;
            font-size: 0.9rem;
            color: #6c757d;
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
            .info-section {
                padding: 0.75rem;
            }
            .info-section h6 {
                font-size: 0.9rem;
            }
            .info-section p {
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
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        
        <!-- Toast notifications handled directly by ShowAlert method -->
        
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
                    <h2 class="text-primary-custom fw-bold"><asp:Literal runat="server" Text="¿Olvidaste tu contraseña?" /></h2>
                    <p class="text-muted"><asp:Literal runat="server" Text="Ingresa tu correo electrónico o nombre de usuario para recuperar tu contraseña" /></p>
                </div>

                <!-- Info Section -->
                <div class="info-section">
                    <h6><asp:Literal runat="server" Text="¿Cómo funciona?" /></h6>
                    <p><asp:Literal runat="server" Text="Para restablecer tu contraseña, haz clic en el botón de abajo. Este enlace es válido por 24 horas por razones de seguridad." /></p>
                </div>

                <asp:Panel ID="pnlError" runat="server" CssClass="alert alert-danger" Visible="false">
                    <asp:Label ID="lblError" runat="server"></asp:Label>
                </asp:Panel>

                <asp:Panel ID="pnlSuccess" runat="server" CssClass="success-message" Visible="false">
                    <h4><asp:Literal runat="server" Text="Correo enviado" /></h4>
                    <p><asp:Label ID="lblSuccess" runat="server"></asp:Label></p>
                </asp:Panel>

                <asp:Panel ID="pnlForm" runat="server">
                    <asp:UpdatePanel ID="upForgotPassword" runat="server">
                        <ContentTemplate>
                            <div class="mb-3">
                                <label for="txtEmailOrUsername" class="form-label fw-semibold">
                                    <asp:Literal runat="server" Text="Correo electrónico o nombre de usuario" />
                                </label>
                                <asp:TextBox ID="txtEmailOrUsername" runat="server" CssClass="form-control" MaxLength="100"></asp:TextBox>
                                <div class="form-text">
                                    <asp:Literal runat="server" Text="Ingresa tu correo electrónico o nombre de usuario para recuperar el acceso a tu cuenta" />
                                </div>
                                <asp:RequiredFieldValidator ID="rfvEmailOrUsername" runat="server" 
                                    ControlToValidate="txtEmailOrUsername" 
                                    ErrorMessage="El correo electrónico o nombre de usuario son obligatorios" 
                                    CssClass="text-danger small" 
                                    Display="Dynamic" 
                                    ValidationGroup="ForgotPassword">
                                </asp:RequiredFieldValidator>
                            </div>

                            <div class="d-grid mb-3">
                                <asp:Button ID="btnSendRecoveryEmail" runat="server" 
                                    Text="Enviar correo de recuperación" 
                                    CssClass="btn btn-primary-custom btn-lg" 
                                    OnClick="btnSendRecoveryEmail_Click" 
                                                    ValidationGroup="ForgotPassword" />
                            </div>
                        </ContentTemplate>
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
                            <asp:Literal runat="server" Text="¿Necesitas más ayuda?" />
                        </p>
                        <a href="ContactUs.aspx" class="link-custom small">
                            <asp:Literal runat="server" Text="Contactar Soporte" />
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </form>
    
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="Scripts/bootstrap.bundle.min.js"></script>
    <script type="text/javascript">
        function pageLoad() {
            setPlaceholderText();
            debugButtonSetup();
        }
        
        function debugButtonSetup() {
            setTimeout(function() {
                try {
                    var button = document.getElementById('<%= btnSendRecoveryEmail.ClientID %>');
                    if (button) {
                    }
                    
                    var form = document.getElementById('form1');
                    
                    var updatePanel = document.getElementById('<%= upForgotPassword.ClientID %>');
                } catch (e) {
                }
            }, 200);
        }
        
        function setPlaceholderText() {
            setTimeout(function() {
                try {
                    var emailField = document.getElementById('<%= txtEmailOrUsername.ClientID %>');
                    if (emailField) {
                        emailField.placeholder = '<%= GetLocalizedString("EnterEmailOrUsername") %>';
                    }
                } catch (e) {
                }
            }, 100);
        }
        
        function showLoadingState() {
            try {
                var button = document.getElementById('<%= btnSendRecoveryEmail.ClientID %>');
                if (button) {
                    var originalText = button.value;
                    button.setAttribute('data-original-text', originalText);
                    // Use value property for server button instead of innerHTML
                    button.value = '\u2699 ' + originalText; // Unicode gear icon for loading
                    button.disabled = true;
                    
                    // Re-enable after timeout as fallback
                    setTimeout(function() {
                        if (button.disabled) {
                            restoreButtonState(button);
                        }
                    }, 10000); // 10 second timeout
                }
                return true;
            } catch (e) {
                return true; // Still allow postback even if UI update fails
            }
        }
        
        function restoreButtonState(button) {
            try {
                if (button) {
                    var originalText = button.getAttribute('data-original-text');
                    if (originalText) {
                        button.value = originalText; // Use value property for server button
                    }
                    button.disabled = false;
                }
            } catch (e) {
            }
        }
        
        // Initialize when DOM is ready
        $(document).ready(function() {
            pageLoad();
            
            // Handle UpdatePanel postbacks
            if (typeof Sys !== 'undefined') {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function(sender, args) {
                    
                    setTimeout(function() {
                        setPlaceholderText();
                        
                        // Restore button state
                        var button = document.getElementById('<%= btnSendRecoveryEmail.ClientID %>');
                        if (button) {
                            restoreButtonState(button);
                        }
                        
                        // Re-run debug setup after postback
                        debugButtonSetup();
                    }, 100);
                });
                
                // Add request handler for debugging
                Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(function(sender, args) {
                    var postBackElement = args.get_postBackElement();
                    if (postBackElement) {
                    }
                });
            }
            
            // Add window test functions for debugging
            window.testButtonClick = function() {
                try {
                    var button = document.getElementById('<%= btnSendRecoveryEmail.ClientID %>');
                    if (button) {
                        var emailField = document.getElementById('<%= txtEmailOrUsername.ClientID %>');
                        if (emailField) {
                            emailField.value = 'test@example.com'; // Set test value
                        }
                        button.click();
                    } else {
                    }
                } catch (e) {
                }
            };
            
            // Test toast notifications directly via server postback
            window.testToast = function() {
                try {
                    
                    // Test success toast by triggering server method
                    if (typeof testSuccessToast !== 'undefined') {
                        testSuccessToast();
                    } else {
                    }
                    
                    // Test error toast after delay
                    setTimeout(function() {
                        if (typeof testErrorToast !== 'undefined') {
                            testErrorToast();
                        } else {
                        }
                    }, 3000);
                    
                } catch (e) {
                }
            };
            
            // Verify toast system works
            window.checkToastSystem = function() {
                return true;
            };
        });
    </script>
</body>
</html>