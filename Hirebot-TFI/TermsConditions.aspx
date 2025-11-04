<%@ Page Title="" Language="C#" MasterPageFile="~/Public.master" AutoEventWireup="true" CodeBehind="TermsConditions.aspx.cs" Inherits="Hirebot_TFI.TermsConditions" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Términos y Condiciones" /> - Hirebot-TFI
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
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
        <!-- Hero Section -->
        <div class="hero-section">
            <div class="container text-center">
                <h1 class="display-4 fw-bold mb-4"><asp:Literal runat="server" Text="Términos y Condiciones de Uso" /></h1>
                <p class="lead"><asp:Literal runat="server" Text="Por favor lee cuidadosamente nuestros términos y condiciones" /></p>
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
                        <h3><asp:Literal runat="server" Text="Introducción" /></h3>
                        <p><asp:Literal runat="server" Text="Estos términos y condiciones rigen el uso del sitio web y servicios de Hirebot-TFI. Al acceder o usar nuestros servicios, aceptas estar sujeto a estos términos." /></p>
                        
                        <h3><asp:Literal runat="server" Text="Aceptación de los Términos" /></h3>
                        <p><asp:Literal runat="server" Text="Al utilizar nuestros servicios, confirmas que has leído, entendido y aceptas estar sujeto a estos términos y condiciones." /></p>
                        
                        <h3><asp:Literal runat="server" Text="Descripción del Servicio" /></h3>
                        <p><asp:Literal runat="server" Text="Hirebot-TFI proporciona una plataforma de contratación impulsada por inteligencia artificial que ayuda a empresas y candidatos a conectarse de manera eficiente." /></p>
                        <p><asp:Literal runat="server" Text="Nuestros servicios incluyen filtrado de candidatos, gestión de procesos de selección, análisis de datos y herramientas de comunicación automatizadas." /></p>
                        
                        <h4><asp:Literal runat="server" Text="Nuestros servicios incluyen:" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="Filtrado inteligente de candidatos usando IA" /></li>
                            <li><asp:Literal runat="server" Text="Sistema de gestión de candidatos (ATS)" /></li>
                            <li><asp:Literal runat="server" Text="Análisis y reportes de datos de contratación" /></li>
                            <li><asp:Literal runat="server" Text="Automatización de procesos de selección" /></li>
                            <li><asp:Literal runat="server" Text="Herramientas de comunicación con candidatos" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="Responsabilidades del Usuario" /></h3>
                        <p><asp:Literal runat="server" Text="Como usuario de nuestros servicios, te comprometes a cumplir con ciertas obligaciones y responsabilidades." /></p>
                        
                        <h4><asp:Literal runat="server" Text="Te comprometes a:" /></h4>
                        <ul>
                            <li><asp:Literal runat="server" Text="Proporcionar información precisa y actualizada" /></li>
                            <li><asp:Literal runat="server" Text="Usar los servicios de manera legal y ética" /></li>
                            <li><asp:Literal runat="server" Text="Mantener la confidencialidad de tus credenciales de acceso" /></li>
                            <li><asp:Literal runat="server" Text="No usar los servicios para actividades fraudulentas o ilegales" /></li>
                        </ul>
                        
                        <h3><asp:Literal runat="server" Text="Privacidad y Protección de Datos" /></h3>
                        <p><asp:Literal runat="server" Text="Nos tomamos muy en serio la privacidad y protección de tus datos. Para más información, consulta nuestra Política de Privacidad." /></p>
                        
                        <h3><asp:Literal runat="server" Text="Propiedad Intelectual" /></h3>
                        <p><asp:Literal runat="server" Text="Todos los derechos de propiedad intelectual relacionados con los servicios de Hirebot-TFI pertenecen a nuestra empresa." /></p>
                        <p><asp:Literal runat="server" Text="No puedes copiar, modificar, distribuir o crear trabajos derivados de nuestro contenido sin autorización expresa." /></p>
                        
                        <h3><asp:Literal runat="server" Text="Limitación de Responsabilidad" /></h3>
                        <p><asp:Literal runat="server" Text="Hirebot-TFI no será responsable de daños indirectos, incidentales, especiales o consecuenciales que puedan surgir del uso de nuestros servicios." /></p>
                        <p><asp:Literal runat="server" Text="Nuestra responsabilidad total se limita al monto pagado por los servicios en el período de doce meses previo al reclamo." /></p>
                        
                        <h3><asp:Literal runat="server" Text="Terminación del Servicio" /></h3>
                        <p><asp:Literal runat="server" Text="Puedes terminar tu cuenta en cualquier momento siguiendo el proceso indicado en la plataforma." /></p>
                        <p><asp:Literal runat="server" Text="Nos reservamos el derecho de suspender o terminar cuentas que violen estos términos y condiciones." /></p>
                        
                        <h3><asp:Literal runat="server" Text="Modificación de Términos" /></h3>
                        <p><asp:Literal runat="server" Text="Podemos actualizar estos términos ocasionalmente. Te notificaremos sobre cambios significativos y tu uso continuado constituye aceptación de los términos modificados." /></p>
                        
                        <h3><asp:Literal runat="server" Text="Ley Aplicable" /></h3>
                        <p><asp:Literal runat="server" Text="Estos términos se rigen por las leyes de la República Argentina. Cualquier disputa se resolverá en los tribunales competentes de Buenos Aires." /></p>
                        
                        <h3><asp:Literal runat="server" Text="Información de Contacto" /></h3>
                        <p><asp:Literal runat="server" Text="Si tienes preguntas sobre estos términos y condiciones, puedes contactarnos en:" /></p>
                        <ul class="list-unstyled">
                            <li><strong><asp:Literal runat="server" Text="Correo Electrónico" />:</strong> legal@hirebot-tfi.com</li>
                            <li><strong><asp:Literal runat="server" Text="Dirección" />:</strong> Av. Corrientes 1234, Piso 8, CABA, Argentina</li>
                            <li><strong><asp:Literal runat="server" Text="Teléfono" />:</strong> +54 11 4555-1234</li>
                        </ul>
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