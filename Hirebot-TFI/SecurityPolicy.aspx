<%@ Page Title="" Language="C#" MasterPageFile="~/Public.master" AutoEventWireup="true" CodeBehind="SecurityPolicy.aspx.cs" Inherits="Hirebot_TFI.SecurityPolicy" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Política de Seguridad" /> - Hirebot-TFI
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
                <h1 class="display-4 fw-bold mb-4"><asp:Literal runat="server" Text="Política de Seguridad" /></h1>
                <p class="lead"><asp:Literal runat="server" Text="Protegiendo tu información con los más altos estándares" /></p>
            </div>
        </div>

        <!-- Main Content -->
        <div class="container py-5">
            <div class="row">
                <div class="col-lg-8 mx-auto">
                    <div class="last-updated text-center">
                        <strong><asp:Literal runat="server" Text="Última actualización" />: <%= DateTime.Now.ToString("dd/MM/yyyy") %></strong>
                    </div>
                    
                    <div class="content-section">
                        <div class="security-highlight text-center">
                            <i class="fas fa-shield-alt fa-3x mb-3" style="color: var(--ultra-violet);"></i>
                            <h4><asp:Literal runat="server" Text="Compromiso con la Seguridad" /></h4>
                            <p class="mb-0"><asp:Literal runat="server" Text="La seguridad es fundamental en todo lo que hacemos. Implementamos medidas robustas para proteger tu información y nuestros sistemas." /></p>
                        </div>
                        
                        <h3><asp:Literal runat="server" Text="Protección de Datos" /></h3>
                        <p><asp:Literal runat="server" Text="Utilizamos múltiples capas de seguridad para proteger tu información sensible en todo momento." /></p>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="security-feature">
                                    <h5><i class="fas fa-lock me-2" style="color: var(--ultra-violet);"></i><asp:Literal runat="server" Text="Cifrado" /></h5>
                                    <p><asp:Literal runat="server" Text="Todos los datos se cifran usando algoritmos AES-256 tanto en tránsito como en reposo." /></p>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="security-feature">
                                    <h5><i class="fas fa-server me-2" style="color: var(--tiffany-blue);"></i><asp:Literal runat="server" Text="Servidores Seguros" /></h5>
                                    <p><asp:Literal runat="server" Text="Nuestros servidores están alojados en centros de datos certificados con seguridad física 24/7." /></p>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="security-feature">
                                    <h5><i class="fas fa-key me-2" style="color: var(--cadet-gray);"></i><asp:Literal runat="server" Text="Control de Acceso" /></h5>
                                    <p><asp:Literal runat="server" Text="Implementamos autenticación multifactor y principios de menor privilegio." /></p>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="security-feature">
                                    <h5><i class="fas fa-eye me-2" style="color: var(--eerie-black);"></i><asp:Literal runat="server" Text="Monitoreo" /></h5>
                                    <p><asp:Literal runat="server" Text="Supervisión continua 24/7 de todos nuestros sistemas y redes." /></p>
                                </div>
                            </div>
                        </div>
                        
                        <h3><asp:Literal runat="server" Text="Seguridad del Usuario" /></h3>
                        <p><asp:Literal runat="server" Text="Tu seguridad es una responsabilidad compartida. Te proporcionamos herramientas y recomendaciones para mantener tu cuenta segura." /></p>
                        
                        <h4><asp:Literal runat="server" Text="Recomendaciones de Seguridad:" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="Usa contraseñas fuertes y únicas" /></li>
                            <li><asp:Literal runat="server" Text="Habilita la autenticación de dos factores" /></li>
                            <li><asp:Literal runat="server" Text="Mantén actualizada tu información de contacto" /></li>
                            <li><asp:Literal runat="server" Text="No compartas tus credenciales de acceso" /></li>
                            <li><asp:Literal runat="server" Text="Reporta actividad sospechosa inmediatamente" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="Respuesta a Incidentes" /></h3>
                        <p><asp:Literal runat="server" Text="Tenemos un plan integral de respuesta a incidentes de seguridad que nos permite actuar rápidamente ante cualquier amenaza." /></p>
                        <p><asp:Literal runat="server" Text="Nuestro equipo de seguridad está disponible 24/7 para responder a emergencias de seguridad." /></p>
                        
                        <h4><asp:Literal runat="server" Text="Procedimiento ante Incidentes:" /></h4>
                        <ol>
                            <li><asp:Literal runat="server" Text="Detección y evaluación inmediata de la amenaza" /></li>
                            <li><asp:Literal runat="server" Text="Contención y mitigación del incidente" /></li>
                            <li><asp:Literal runat="server" Text="Investigación forense y análisis de causa raíz" /></li>
                            <li><asp:Literal runat="server" Text="Notificación a usuarios afectados si corresponde" /></li>
                            <li><asp:Literal runat="server" Text="Implementación de mejoras preventivas" /></li>
                        </ol>
                        
                        <h3><asp:Literal runat="server" Text="Cumplimiento y Certificaciones" /></h3>
                        <p><asp:Literal runat="server" Text="Mantenemos las certificaciones más importantes de la industria para garantizar los más altos estándares de seguridad." /></p>
                        
                        <div class="row text-center">
                            <div class="col-md-4 mb-3">
                                <div class="security-feature text-center">
                                    <i class="fas fa-certificate fa-2x mb-2" style="color: var(--ultra-violet);"></i>
                                    <h6>ISO 27001</h6>
                                    <small><asp:Literal runat="server" Text="Gestión de seguridad de la información" /></small>
                                </div>
                            </div>
                            <div class="col-md-4 mb-3">
                                <div class="security-feature text-center">
                                    <i class="fas fa-shield-alt fa-2x mb-2" style="color: var(--tiffany-blue);"></i>
                                    <h6>SOC 2 Type II</h6>
                                    <small><asp:Literal runat="server" Text="Controles de seguridad operacional" /></small>
                                </div>
                            </div>
                            <div class="col-md-4 mb-3">
                                <div class="security-feature text-center">
                                    <i class="fas fa-gavel fa-2x mb-2" style="color: var(--cadet-gray);"></i>
                                    <h6>GDPR</h6>
                                    <small><asp:Literal runat="server" Text="Protección de datos personales" /></small>
                                </div>
                            </div>
                        </div>
                        
                        <h3><asp:Literal runat="server" Text="Auditorías Regulares" /></h3>
                        <p><asp:Literal runat="server" Text="Realizamos auditorías de seguridad regulares tanto internas como por terceros independientes." /></p>
                        
                        <h4><asp:Literal runat="server" Text="Tipos de auditoría:" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="Pruebas de penetración trimestrales" /></li>
                            <li><asp:Literal runat="server" Text="Evaluaciones de vulnerabilidades mensuales" /></li>
                            <li><asp:Literal runat="server" Text="Revisiones de código de seguridad" /></li>
                            <li><asp:Literal runat="server" Text="Auditorías de cumplimiento anuales" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="Reporte de Problemas de Seguridad" /></h3>
                        <p><asp:Literal runat="server" Text="Si descubres una vulnerabilidad de seguridad, te alentamos a reportarla de manera responsable a través de nuestros canales seguros." /></p>
                        
                        <div class="security-highlight">
                            <h4><i class="fas fa-exclamation-triangle me-2" style="color: var(--tiffany-blue);"></i><asp:Literal runat="server" Text="Contacto de Seguridad" /></h4>
                            <p><asp:Literal runat="server" Text="Para reportar problemas de seguridad o emergencias, contáctanos inmediatamente:" /></p>
                            <ul class="list-unstyled mb-0">
                                <li><strong><asp:Literal runat="server" Text="Correo Electrónico" />:</strong> security@hirebot-tfi.com</li>
                                <li><strong><asp:Literal runat="server" Text="Teléfono de Emergencia" />:</strong> +54 11 4555-9999 (24/7)</li>
                                <li><strong><asp:Literal runat="server" Text="Portal de Seguridad" />:</strong> security.hirebot-tfi.com</li>
                            </ul>
                        </div>
                        
                        <h3><asp:Literal runat="server" Text="Actualizaciones de Política" /></h3>
                        <p><asp:Literal runat="server" Text="Esta política se revisa y actualiza regularmente para reflejar las mejores prácticas de seguridad y cambios en la legislación aplicable." /></p>
                    </div>
                    
                    <div class="text-center mt-5">
                        <a href="Default.aspx" class="btn btn-lg px-4" style="background: var(--ultra-violet); border-color: var(--ultra-violet); color: white;">
                            <asp:Literal runat="server" Text="Volver al Inicio" />
                        </a>
                    </div>
                </div>
            </div>
        </div>

</asp:Content>