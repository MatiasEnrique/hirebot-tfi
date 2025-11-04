<%@ Page Title="" Language="C#" MasterPageFile="~/Public.master" AutoEventWireup="true" CodeBehind="PrivacyPolicy.aspx.cs" Inherits="Hirebot_TFI.PrivacyPolicy" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Política de Privacidad" /> - Hirebot-TFI
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
        .highlight-box {
            background: #f8f9fa;
            border-left: 4px solid var(--tiffany-blue);
            padding: 1rem;
            margin: 1rem 0;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
        <!-- Hero Section -->
        <div class="hero-section">
            <div class="container text-center">
                <h1 class="display-4 fw-bold mb-4"><asp:Literal runat="server" Text="Política de Privacidad" /></h1>
                <p class="lead"><asp:Literal runat="server" Text="Tu privacidad es importante para nosotros" /></p>
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
                        <div class="highlight-box">
                            <h4><i class="fas fa-shield-alt me-2" style="color: var(--tiffany-blue);"></i><asp:Literal runat="server" Text="Nuestro Compromiso con la Privacidad" /></h4>
                            <p><asp:Literal runat="server" Text="En Hirebot-TFI, respetamos tu privacidad y nos comprometemos a proteger tu información personal con los más altos estándares de seguridad." /></p>
                        </div>
                        
                        <h3><asp:Literal runat="server" Text="Recopilación de Información" /></h3>
                        <p><asp:Literal runat="server" Text="Recopilamos información que nos proporcionas directamente y automáticamente cuando usas nuestros servicios." /></p>
                        
                        <h4><asp:Literal runat="server" Text="Información Personal que Recopilamos:" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="Nombre completo y información de contacto" /></li>
                            <li><asp:Literal runat="server" Text="Información profesional y laboral" /></li>
                            <li><asp:Literal runat="server" Text="Datos de empresas y organizaciones" /></li>
                            <li><asp:Literal runat="server" Text="Comunicaciones y correspondencia" /></li>
                            <li><asp:Literal runat="server" Text="Información de facturación y pagos" /></li>
                        </ul>
                        
                        <h4><asp:Literal runat="server" Text="Información Técnica:" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="Direcciones IP y datos de conexión" /></li>
                            <li><asp:Literal runat="server" Text="Información del navegador y dispositivo" /></li>
                            <li><asp:Literal runat="server" Text="Cookies y tecnologías similares" /></li>
                            <li><asp:Literal runat="server" Text="Registros de actividad en la plataforma" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="Uso de la Información" /></h3>
                        <p><asp:Literal runat="server" Text="Utilizamos tu información para proporcionar, mejorar y personalizar nuestros servicios." /></p>
                        
                        <h4><asp:Literal runat="server" Text="Propósitos principales:" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="Proporcionar y mantener nuestros servicios" /></li>
                            <li><asp:Literal runat="server" Text="Procesar transacciones y comunicaciones" /></li>
                            <li><asp:Literal runat="server" Text="Mejorar y personalizar la experiencia del usuario" /></li>
                            <li><asp:Literal runat="server" Text="Análisis y desarrollo de nuevas funcionalidades" /></li>
                            <li><asp:Literal runat="server" Text="Cumplimiento legal y prevención de fraudes" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="Compartir Información" /></h3>
                        <p><asp:Literal runat="server" Text="No vendemos, alquilamos ni compartimos tu información personal con terceros para fines comerciales sin tu consentimiento." /></p>
                        <p><asp:Literal runat="server" Text="Podemos compartir información en circunstancias específicas y limitadas:" /></p>
                        
                        <h4><asp:Literal runat="server" Text="Compartimos información solo cuando:" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="Tenemos tu consentimiento explícito" /></li>
                            <li><asp:Literal runat="server" Text="Es requerido por ley o autoridades competentes" /></li>
                            <li><asp:Literal runat="server" Text="Con proveedores de servicios que nos ayudan a operar" /></li>
                            <li><asp:Literal runat="server" Text="Para proteger derechos, seguridad o propiedad" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="Seguridad de Datos" /></h3>
                        <p><asp:Literal runat="server" Text="Implementamos medidas de seguridad técnicas y organizacionales para proteger tu información personal." /></p>
                        
                        <h4><asp:Literal runat="server" Text="Medidas de seguridad:" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="Cifrado de datos en tránsito y en reposo" /></li>
                            <li><asp:Literal runat="server" Text="Control de acceso y autenticación multifactor" /></li>
                            <li><asp:Literal runat="server" Text="Monitoreo continuo y auditorías de seguridad" /></li>
                            <li><asp:Literal runat="server" Text="Capacitación regular del personal en seguridad" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="Derechos del Usuario" /></h3>
                        <p><asp:Literal runat="server" Text="Tienes varios derechos respecto a tu información personal que respetamos y facilitamos." /></p>
                        
                        <h4><asp:Literal runat="server" Text="Tus derechos incluyen:" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="Acceder a tu información personal" /></li>
                            <li><asp:Literal runat="server" Text="Rectificar datos inexactos o incompletos" /></li>
                            <li><asp:Literal runat="server" Text="Solicitar la eliminación de tus datos" /></li>
                            <li><asp:Literal runat="server" Text="Restringir el procesamiento de tu información" /></li>
                            <li><asp:Literal runat="server" Text="Portabilidad de datos cuando sea aplicable" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="Cookies y Seguimiento" /></h3>
                        <p><asp:Literal runat="server" Text="Utilizamos cookies y tecnologías similares para mejorar tu experiencia y analizar el uso de nuestros servicios." /></p>
                        <p><asp:Literal runat="server" Text="Puedes controlar las cookies a través de la configuración de tu navegador, aunque esto puede afectar algunas funcionalidades." /></p>
                        
                        <h3><asp:Literal runat="server" Text="Retención de Datos" /></h3>
                        <p><asp:Literal runat="server" Text="Conservamos tu información personal solo durante el tiempo necesario para cumplir con los propósitos descritos en esta política." /></p>
                        <p><asp:Literal runat="server" Text="Cuando ya no sea necesaria, eliminamos o anonimizamos tu información de manera segura." /></p>
                        
                        <h3><asp:Literal runat="server" Text="Privacidad de Menores" /></h3>
                        <p><asp:Literal runat="server" Text="Nuestros servicios no están dirigidos a menores de 18 años. No recopilamos información personal de menores conscientemente." /></p>
                        
                        <h3><asp:Literal runat="server" Text="Cambios en la Política" /></h3>
                        <p><asp:Literal runat="server" Text="Podemos actualizar esta política ocasionalmente. Te notificaremos sobre cambios significativos por email o mediante avisos en nuestra plataforma." /></p>
                        
                        <div class="highlight-box">
                            <h4><i class="fas fa-envelope me-2" style="color: var(--tiffany-blue);"></i><asp:Literal runat="server" Text="Contáctanos" /></h4>
                            <p><asp:Literal runat="server" Text="Para consultas sobre privacidad o ejercer tus derechos, contáctanos en:" /></p>
                            <ul class="list-unstyled mb-0">
                                <li><strong><asp:Literal runat="server" Text="Correo Electrónico" />:</strong> privacy@hirebot-tfi.com</li>
                                <li><strong><asp:Literal runat="server" Text="Dirección" />:</strong> Av. Corrientes 1234, Piso 8, CABA, Argentina</li>
                                <li><strong><asp:Literal runat="server" Text="Teléfono" />:</strong> +54 11 4555-1234</li>
                            </ul>
                        </div>
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