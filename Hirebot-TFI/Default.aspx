<%@ Page Title="" Language="C#" MasterPageFile="~/Public.master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Hirebot_TFI.Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Inicio - Hirebot-TFI
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* High Contrast Mode Styles */
        body.high-contrast {
            background: #000 !important;
            color: #fff !important;
        }

        body.high-contrast * {
            background: transparent !important;
            color: #fff !important;
            border-color: #fff !important;
        }

        body.high-contrast .welcome-section {
            background: #000 !important;
            border: 3px solid #fff !important;
        }

        body.high-contrast .card,
        body.high-contrast .ad-card {
            background: #000 !important;
            border: 2px solid #ffff00 !important;
            box-shadow: none !important;
        }

        body.high-contrast .btn,
        body.high-contrast a.btn {
            background: #000 !important;
            color: #ffff00 !important;
            border: 2px solid #ffff00 !important;
            box-shadow: none !important;
        }

        body.high-contrast .btn:hover,
        body.high-contrast a.btn:hover {
            background: #ffff00 !important;
            color: #000 !important;
        }

        body.high-contrast .navbar-custom {
            background: #000 !important;
            border-bottom: 3px solid #fff !important;
        }

        body.high-contrast footer {
            background: #000 !important;
            border-top: 3px solid #fff !important;
        }

        body.high-contrast .homepage-ad-section {
            background: #000 !important;
        }

        body.high-contrast i {
            color: #ffff00 !important;
        }

        /* High Contrast Toggle Button */
        .high-contrast-toggle {
            position: fixed;
            bottom: 20px;
            right: 20px;
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            border: none;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
            cursor: pointer;
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            transition: all 0.3s ease;
        }

        .high-contrast-toggle:hover {
            transform: scale(1.1);
            box-shadow: 0 6px 16px rgba(0, 0, 0, 0.4);
        }

        .high-contrast-toggle:focus {
            outline: 3px solid #4b4e6d;
            outline-offset: 2px;
        }

        body.high-contrast .high-contrast-toggle {
            background: #ffff00 !important;
            color: #000 !important;
            border: 3px solid #fff !important;
        }

        .high-contrast-toggle .icon-normal {
            display: inline;
        }

        .high-contrast-toggle .icon-active {
            display: none;
        }

        body.high-contrast .high-contrast-toggle .icon-normal {
            display: none;
        }

        body.high-contrast .high-contrast-toggle .icon-active {
            display: inline;
        }

        .welcome-section {
            background: linear-gradient(135deg, var(--tiffany-blue), var(--ultra-violet));
            min-height: 60vh;
            display: flex;
            align-items: center;
            color: white;
        }

        .homepage-ad-section {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        }

        .ad-card {
            background: white;
            border-radius: 1rem;
            padding: 2.5rem;
            box-shadow: 0 0.5rem 2rem rgba(0, 0, 0, 0.08);
            position: relative;
            overflow: hidden;
            border: 2px solid transparent;
            transition: all 0.3s ease;
        }

        .ad-card:hover {
            border-color: var(--tiffany-blue);
            box-shadow: 0 1rem 3rem rgba(132, 220, 198, 0.2);
            transform: translateY(-4px);
        }

        .ad-content {
            position: relative;
            z-index: 2;
        }

        .ad-badge {
            display: inline-block;
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            padding: 0.35rem 0.85rem;
            border-radius: 2rem;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 1rem;
        }

        .ad-title {
            font-size: 2rem;
            font-weight: 700;
            color: var(--eerie-black);
            margin-bottom: 1rem;
            line-height: 1.2;
        }

        .ad-description {
            font-size: 1.125rem;
            color: var(--cadet-gray);
            margin-bottom: 1.5rem;
            line-height: 1.6;
        }

        .btn-ad-cta {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            padding: 0.875rem 2rem;
            border-radius: 2rem;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            transition: all 0.3s ease;
            border: none;
            box-shadow: 0 0.25rem 1rem rgba(75, 78, 109, 0.3);
        }

        .btn-ad-cta:hover {
            transform: translateY(-2px);
            box-shadow: 0 0.5rem 1.5rem rgba(75, 78, 109, 0.4);
            color: white;
            text-decoration: none;
        }

        .ad-decoration {
            position: absolute;
            right: -20px;
            bottom: -20px;
            font-size: 12rem;
            color: var(--tiffany-blue);
            opacity: 0.05;
            z-index: 1;
            transform: rotate(-15deg);
        }

        @media (max-width: 768px) {
            .ad-card {
                padding: 1.5rem;
            }

            .ad-title {
                font-size: 1.5rem;
            }

            .ad-description {
                font-size: 1rem;
            }

            .ad-decoration {
                font-size: 8rem;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
        <div class="welcome-section">
            <div class="container text-center">
                <div class="row justify-content-center">
                    <div class="col-lg-8">
                        <h1 class="display-4 fw-bold mb-4"><asp:Literal runat="server" Text="¡Bienvenido a Hirebot-TFI!" /></h1>
                        <p class="lead mb-4"><asp:Literal runat="server" Text="Tu asistente inteligente de contratación impulsado por tecnología de IA avanzada." /></p>
                        
                        <asp:Panel ID="pnlWelcomeMessage" runat="server" Visible="false" CssClass="alert alert-info">
                            <h4><asp:Literal runat="server" Text="Bienvenido" /> <asp:Label ID="lblWelcomeUser" runat="server"></asp:Label>!</h4>
                            <p class="mb-0"><asp:Literal runat="server" Text="Has iniciado sesión exitosamente en tu cuenta de Hirebot." /></p>
                        </asp:Panel>
                        
                        <asp:Panel ID="pnlGuestMessage" runat="server" Visible="true">
                            <div class="d-flex justify-content-center gap-3 mt-4">
                                <a href="SignUp.aspx" class="btn btn-light btn-lg px-4"><asp:Literal runat="server" Text="Comenzar" /></a>
                                <a href="SignIn.aspx" class="btn btn-outline-light btn-lg px-4"><asp:Literal runat="server" Text="Iniciar Sesión" /></a>
                            </div>
                        </asp:Panel>
                    </div>
                </div>
            </div>
        </div>

        <!-- Homepage Advertisement -->
        <asp:Panel ID="pnlHomepageAd" runat="server" Visible="false" CssClass="homepage-ad-section py-5">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-lg-10">
                        <div class="ad-card">
                            <div class="ad-content">
                                <span id="spanAdBadge" runat="server" class="ad-badge" visible="false"></span>
                                <h2 class="ad-title">
                                    <asp:Literal ID="litAdTitle" runat="server" />
                                </h2>
                                <p class="ad-description">
                                    <asp:Literal ID="litAdDescription" runat="server" Visible="false" />
                                </p>
                                <a id="lnkAdCta" runat="server" class="btn btn-ad-cta" visible="false" target="_blank">
                                    <i class="bi bi-arrow-right-circle me-2"></i>
                                    <span></span>
                                </a>
                            </div>
                            <div class="ad-decoration">
                                <i class="bi bi-megaphone-fill"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- Features Section -->
        <div class="container py-5">
            <div class="row">
                <div class="col-md-4 text-center mb-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body">
                            <div class="mb-3" style="color: var(--ultra-violet);">
                                <i class="fas fa-robot fa-3x"></i>
                            </div>
                            <h5 class="card-title"><asp:Literal runat="server" Text="Filtrado con IA" /></h5>
                            <p class="card-text"><asp:Literal runat="server" Text="Filtrado inteligente de candidatos usando algoritmos de IA avanzados." /></p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 text-center mb-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body">
                            <div class="mb-3" style="color: var(--tiffany-blue);">
                                <i class="fas fa-users fa-3x"></i>
                            </div>
                            <h5 class="card-title"><asp:Literal runat="server" Text="Gestión de Candidatos" /></h5>
                            <p class="card-text"><asp:Literal runat="server" Text="Sistema integral de seguimiento y gestión de candidatos." /></p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 text-center mb-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body">
                            <div class="mb-3" style="color: var(--cadet-gray);">
                                <i class="fas fa-chart-bar fa-3x"></i>
                            </div>
                            <h5 class="card-title"><asp:Literal runat="server" Text="Análisis e Insights" /></h5>
                            <p class="card-text"><asp:Literal runat="server" Text="Análisis detallados e insights para mejores decisiones de contratación." /></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- High Contrast Toggle Button -->
        <button type="button" 
                class="high-contrast-toggle" 
                id="highContrastToggle"
                aria-label="Activar o desactivar modo de alto contraste"
                title="Modo de Alto Contraste">
            <span class="icon-normal">
                <i class="bi bi-circle-half"></i>
            </span>
            <span class="icon-active">
                <i class="bi bi-brightness-high-fill"></i>
            </span>
        </button>

        <script>
            // High Contrast Mode functionality
            (function() {
                'use strict';
                
                console.log('\u2705 Inicializando modo de alto contraste');
                
                var toggleButton = document.getElementById('highContrastToggle');
                var STORAGE_KEY = 'highContrastMode';
                
                // Check if high contrast mode is enabled from localStorage
                function isHighContrastEnabled() {
                    try {
                        return localStorage.getItem(STORAGE_KEY) === 'true';
                    } catch (e) {
                        console.error('\u274c Error al leer localStorage:', e);
                        return false;
                    }
                }
                
                // Apply high contrast mode
                function applyHighContrast(enabled) {
                    if (enabled) {
                        document.body.classList.add('high-contrast');
                        console.log('\u2705 Modo de alto contraste activado');
                    } else {
                        document.body.classList.remove('high-contrast');
                        console.log('\u2705 Modo de alto contraste desactivado');
                    }
                }
                
                // Save preference to localStorage
                function savePreference(enabled) {
                    try {
                        localStorage.setItem(STORAGE_KEY, enabled.toString());
                        console.log('\u2705 Preferencia guardada:', enabled);
                    } catch (e) {
                        console.error('\u274c Error al guardar en localStorage:', e);
                    }
                }
                
                // Toggle high contrast mode
                function toggleHighContrast() {
                    var isEnabled = isHighContrastEnabled();
                    var newState = !isEnabled;
                    
                    applyHighContrast(newState);
                    savePreference(newState);
                    
                    // Update ARIA label
                    if (toggleButton) {
                        toggleButton.setAttribute('aria-pressed', newState.toString());
                    }
                    
                    // Visual feedback
                    console.log('\u{1F504} Alto contraste cambiado a:', newState ? 'ACTIVADO' : 'DESACTIVADO');
                }
                
                // Initialize on page load
                function initialize() {
                    var isEnabled = isHighContrastEnabled();
                    
                    // Apply saved preference
                    applyHighContrast(isEnabled);
                    
                    // Set initial ARIA state
                    if (toggleButton) {
                        toggleButton.setAttribute('aria-pressed', isEnabled.toString());
                        toggleButton.addEventListener('click', toggleHighContrast);
                        
                        // Keyboard accessibility
                        toggleButton.addEventListener('keydown', function(e) {
                            if (e.key === 'Enter' || e.key === ' ') {
                                e.preventDefault();
                                toggleHighContrast();
                            }
                        });
                    }
                    
                    console.log('\u2705 Modo de alto contraste inicializado. Estado actual:', isEnabled ? 'ACTIVADO' : 'DESACTIVADO');
                }
                
                // Run initialization when DOM is ready
                if (document.readyState === 'loading') {
                    document.addEventListener('DOMContentLoaded', initialize);
                } else {
                    initialize();
                }
            })();
        </script>

</asp:Content>