<%@ Page Title="" Language="C#" MasterPageFile="~/Public.master" AutoEventWireup="true" CodeBehind="SignIn.aspx.cs" Inherits="Hirebot_TFI.SignIn" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Sign In - Hirebot-TFI
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
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <section class="welcome-section py-5" id="mainAuthContainer">
        <div class="container py-5">
            <div class="row align-items-center g-5">
                <div class="col-lg-5 text-center text-lg-start">
                    <h1 class="display-5 fw-bold mb-4">
                        <asp:Literal runat="server" Text="Bienvenido de nuevo" />
                    </h1>
                    <p class="lead mb-4">
                        <asp:Literal runat="server" Text="Inicia sesión en tu cuenta de Hirebot" />
                    </p>
                    <div class="d-flex flex-column flex-sm-row gap-3 justify-content-center justify-content-lg-start">
                        <a href="SignUp.aspx" class="btn btn-light btn-lg px-4">
                            <asp:Literal runat="server" Text="Crear Cuenta" />
                        </a>
                        <a href="ForgotPassword.aspx" class="btn btn-outline-light btn-lg px-4">
                            <asp:Literal runat="server" Text="¿Olvidaste tu contraseña?" />
                        </a>
                    </div>
                </div>
                <div class="col-lg-6 col-xl-5 ms-lg-auto">
                    <div class="card auth-card border-0 shadow-lg">
                        <div class="card-body">
                            <asp:Panel ID="pnlError" runat="server" CssClass="alert alert-danger mb-4" Visible="false">
                                <asp:Label ID="lblError" runat="server"></asp:Label>
                            </asp:Panel>

                            <asp:Panel ID="pnlSuccess" runat="server" CssClass="alert alert-soft-success mb-4" Visible="false">
                                <asp:Label ID="lblSuccess" runat="server"></asp:Label>
                            </asp:Panel>

                            <asp:Panel ID="pnlSignIn" runat="server">
                                <div class="mb-3">
                                    <label for="<%= txtUsernameOrEmail.ClientID %>" class="form-label fw-semibold text-dark">
                                        <asp:Literal runat="server" Text="Usuario o Correo" />
                                    </label>
                                    <asp:TextBox ID="txtUsernameOrEmail" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvUsernameOrEmail" runat="server" ControlToValidate="txtUsernameOrEmail"
                                        ErrorMessage="El nombre de usuario es obligatorio" CssClass="text-danger small" Display="Dynamic" ValidationGroup="SignIn"></asp:RequiredFieldValidator>
                                </div>

                                <div class="mb-3">
                                    <label for="<%= txtPassword.ClientID %>" class="form-label fw-semibold text-dark">
                                        <asp:Literal runat="server" Text="Contraseña" />
                                    </label>
                                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword"
                                        ErrorMessage="La contraseña es obligatoria" CssClass="text-danger small" Display="Dynamic" ValidationGroup="SignIn"></asp:RequiredFieldValidator>
                                </div>

                                <div class="mb-3 form-check">
                                    <asp:CheckBox ID="chkRememberMe" runat="server" CssClass="form-check-input" />
                                    <label class="form-check-label" for="<%= chkRememberMe.ClientID %>">
                                        <asp:Literal runat="server" Text="Recordarme" />
                                    </label>
                                </div>

                                <div class="d-grid mb-3">
                                    <asp:Button ID="btnSignIn" runat="server" Text="Iniciar Sesión" CssClass="btn btn-gradient btn-lg" OnClick="btnSignIn_Click" ValidationGroup="SignIn" />
                                </div>

                                <div class="text-center mb-3">
                                    <a href="ForgotPassword.aspx" class="auth-link">
                                        <asp:Literal runat="server" Text="¿Olvidaste tu contraseña?" />
                                    </a>
                                </div>

                                <div class="text-center">
                                    <span class="text-muted">
                                        <asp:Literal runat="server" Text="¿No tienes una cuenta?" />
                                    </span>
                                    <a href="SignUp.aspx" class="auth-link ms-1">
                                        <asp:Literal runat="server" Text="Registrarse" />
                                    </a>
                                </div>
                            </asp:Panel>

                            <asp:Panel ID="pnlPasswordReset" runat="server" Visible="false">
                                <div class="text-center mb-4">
                                    <h2 class="fw-bold text-dark">
                                        <asp:Literal runat="server" Text="Restablecer Contraseña" />
                                    </h2>
                                    <p class="text-muted mb-0">
                                        <asp:Literal runat="server" Text="Ingresa tu nueva contraseña" />
                                    </p>
                                </div>

                                <div class="mb-3">
                                    <label for="<%= txtNewPassword.ClientID %>" class="form-label fw-semibold text-dark">
                                        <asp:Literal runat="server" Text="Nueva contraseña" />
                                    </label>
                                    <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" ControlToValidate="txtNewPassword"
                                        ErrorMessage="La nueva contraseña es obligatoria" CssClass="text-danger small" Display="Dynamic" ValidationGroup="PasswordReset"></asp:RequiredFieldValidator>
                                    <asp:RegularExpressionValidator ID="revNewPassword" runat="server" ControlToValidate="txtNewPassword"
                                        ErrorMessage="La contraseña debe tener al menos 6 caracteres." ValidationExpression=".{6,}" CssClass="text-danger small" Display="Dynamic" ValidationGroup="PasswordReset"></asp:RegularExpressionValidator>
                                </div>

                                <div class="mb-3">
                                    <label for="<%= txtConfirmNewPassword.ClientID %>" class="form-label fw-semibold text-dark">
                                        <asp:Literal runat="server" Text="Confirmar nueva contraseña" />
                                    </label>
                                    <asp:TextBox ID="txtConfirmNewPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvConfirmNewPassword" runat="server" ControlToValidate="txtConfirmNewPassword"
                                        ErrorMessage="La confirmación de contraseña es obligatoria" CssClass="text-danger small" Display="Dynamic" ValidationGroup="PasswordReset"></asp:RequiredFieldValidator>
                                    <asp:CompareValidator ID="cvNewPassword" runat="server" ControlToValidate="txtConfirmNewPassword" ControlToCompare="txtNewPassword"
                                        ErrorMessage="Las contraseñas no coinciden" CssClass="text-danger small" Display="Dynamic" ValidationGroup="PasswordReset"></asp:CompareValidator>
                                </div>

                                <div class="d-grid mb-3">
                                    <asp:UpdatePanel ID="upPasswordReset" runat="server">
                                        <ContentTemplate>
                                            <asp:Button ID="btnResetPassword" runat="server" Text="Restablecer contraseña" CssClass="btn btn-gradient btn-lg"
                                                OnClick="btnResetPassword_Click" ValidationGroup="PasswordReset" OnClientClick="return handlePasswordResetSubmit();" />
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>

                                <div class="text-center">
                                    <a href="SignIn.aspx" class="auth-link">
                                        <asp:Literal runat="server" Text="Volver al inicio de sesión" />
                                    </a>
                                </div>
                            </asp:Panel>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script type="text/javascript">
        var hourglassGlyph = String.fromCharCode(0x23F3);

        function pageLoad() {
            setPlaceholderText();
        }

        function setPlaceholderText() {
            window.setTimeout(function () {
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
                    button.value = hourglassGlyph + ' ' + originalText;
                    button.disabled = true;

                    window.setTimeout(function () {
                        if (button.disabled) {
                            button.value = button.getAttribute('data-original-text') || originalText;
                            button.disabled = false;
                        }
                    }, 10000);
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

        (function initializeAuthPage() {
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', attachHandlers);
            } else {
                attachHandlers();
            }
        })();

        function attachHandlers() {
            pageLoad();

            if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                    setPlaceholderText();
                    var resetButton = document.getElementById('<%= btnResetPassword.ClientID %>');
                    if (resetButton) {
                        hideLoadingState(resetButton);
                    }
                });
            }
        }
    </script>
</asp:Content>
