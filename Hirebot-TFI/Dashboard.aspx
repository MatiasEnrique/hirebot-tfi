<%@ Page Title="Dashboard - Hirebot-TFI" Language="C#" MasterPageFile="~/Protected.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Hirebot_TFI.Dashboard" %>
<%@ Register Src="~/Controls/SurveyDisplay.ascx" TagPrefix="uc" TagName="SurveyDisplay" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Dashboard - Hirebot-TFI
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        .welcome-header {
            background: var(--ultra-violet);
            color: white;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 2rem;
        }
        .survey-results-section {
            margin-bottom: 2rem;
        }
        .chart-container {
            position: relative;
            height: 400px;
            margin-bottom: 2rem;
        }

        /* High Contrast Button */
        #btnHighContrast {
            transition: all 0.3s ease;
        }

        #btnHighContrast:hover {
            transform: scale(1.05);
        }

        /* High Contrast Mode Styles */
        body.high-contrast {
            background: #000 !important;
            color: #fff !important;
        }

        body.high-contrast .content-card {
            background: #000 !important;
            border: 3px solid #fff !important;
        }

        body.high-contrast .card {
            background: #000 !important;
            border: 2px solid #ffff00 !important;
            color: #fff !important;
        }

        body.high-contrast .card-header {
            background: #000 !important;
            color: #ffff00 !important;
            border-bottom: 2px solid #ffff00 !important;
        }

        body.high-contrast .card-body {
            background: #000 !important;
            color: #fff !important;
        }

        body.high-contrast .welcome-header {
            background: #000 !important;
            border: 3px solid #ffff00 !important;
            color: #ffff00 !important;
        }

        body.high-contrast .btn {
            background: #ffff00 !important;
            color: #000 !important;
            border: 2px solid #fff !important;
            font-weight: bold !important;
        }

        body.high-contrast .btn:hover {
            background: #fff !important;
            color: #000 !important;
        }

        body.high-contrast h1,
        body.high-contrast h2,
        body.high-contrast h3,
        body.high-contrast h4,
        body.high-contrast h5,
        body.high-contrast h6 {
            color: #ffff00 !important;
        }

        body.high-contrast p,
        body.high-contrast label,
        body.high-contrast span {
            color: #fff !important;
        }

        body.high-contrast .text-muted {
            color: #ccc !important;
        }

        body.high-contrast a {
            color: #00ffff !important;
            text-decoration: underline !important;
        }

        body.high-contrast a:hover {
            color: #ffff00 !important;
        }

        body.high-contrast .fas,
        body.high-contrast .fa {
            color: #ffff00 !important;
        }

        body.high-contrast input,
        body.high-contrast select,
        body.high-contrast textarea {
            background: #000 !important;
            color: #fff !important;
            border: 2px solid #ffff00 !important;
        }

        body.high-contrast .list-group-item {
            background: #000 !important;
            border: 1px solid #ffff00 !important;
            color: #fff !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <!-- HIGH CONTRAST BUTTON - VERY VISIBLE -->
    <div class="mb-3">
        <button type="button" id="btnHighContrast" class="btn btn-warning btn-lg w-100"
                onclick="toggleHighContrast(); return false;">
            <i class="fas fa-adjust me-2"></i>
            <span id="contrastText">ALTO CONTRASTE - CLICK AQUÍ</span>
        </button>
    </div>

    <div class="content-card">
                    <div class="welcome-header text-center">
                        <h1><asp:Literal runat="server" Text="Bienvenido" /></h1>
                        <h3><asp:Label ID="lblUserName" runat="server"></asp:Label></h3>
                        <p class="mb-0"><asp:Literal runat="server" Text="Bienvenido a tu panel de control de Hirebot-TFI" /></p>
                    </div>

                    <div class="row mb-4">
                        <div class="col-12">
                            <uc:SurveyDisplay ID="SurveyDisplayControl" runat="server" />
                        </div>
                    </div>
                    <asp:Panel ID="pnlSurveyResults" runat="server" CssClass="survey-results-section" Visible="false">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-light">
                                <h5 class="mb-0">
                                    <i class="fas fa-chart-bar text-primary me-2"></i>
                                    <asp:Literal runat="server" Text="Resultados de la Encuesta" />
                                    <asp:Label ID="lblSurveyResultsTitle" runat="server" CssClass="text-muted ms-2"></asp:Label>
                                </h5>
                            </div>
                            <div class="card-body">
                                <asp:Repeater ID="rptSurveyResults" runat="server" OnItemDataBound="rptSurveyResults_ItemDataBound">
                                    <ItemTemplate>
                                        <div class="mb-4">
                                            <h6 class="fw-bold mb-3"><%# Eval("QuestionText") %></h6>
                                            <asp:Panel ID="pnlChart" runat="server" CssClass="chart-container">
                                                <canvas id='chartQuestion<%# Eval("SurveyQuestionId") %>'></canvas>
                                            </asp:Panel>
                                            <asp:Panel ID="pnlTextAnswers" runat="server" Visible="false">
                                                <asp:Repeater ID="rptTextAnswers" runat="server">
                                                    <HeaderTemplate>
                                                        <div class="list-group">
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <div class="list-group-item">
                                                            <div class="d-flex w-100 justify-content-between">
                                                                <p class="mb-1"><%# Eval("AnswerText") %></p>
                                                                <small class="text-muted"><%# ((DateTime)Eval("SubmittedDateUtc")).ToString("g") %></small>
                                                            </div>
                                                        </div>
                                                    </ItemTemplate>
                                                    <FooterTemplate>
                                                        </div>
                                                    </FooterTemplate>
                                                </asp:Repeater>
                                            </asp:Panel>
                                            <asp:HiddenField ID="hfQuestionId" runat="server" Value='<%# Eval("SurveyQuestionId") %>' />
                                            <asp:HiddenField ID="hfChartData" runat="server" />
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </asp:Panel>


                    <div class="row">
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 shadow-sm">
                                <div class="card-body text-center">
                                    <div class="text-primary mb-3">
                                        <i class="fas fa-user-plus fa-3x"></i>
                                    </div>
                                    <h5 class="card-title"><asp:Literal runat="server" Text="Perfil" /></h5>
                                    <p class="card-text"><asp:Literal runat="server" Text="Gestiona tu perfil y configuraciones" /></p>
                                    <asp:Button ID="btnProfile" runat="server" CssClass="btn btn-primary" 
                                        Text="Ver Perfil" OnClick="btnProfile_Click" />
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 shadow-sm">
                                <div class="card-body text-center">
                                    <div class="text-success mb-3">
                                        <i class="fas fa-briefcase fa-3x"></i>
                                    </div>
                                    <h5 class="card-title"><asp:Literal runat="server" Text="Empleos" /></h5>
                                    <p class="card-text"><asp:Literal runat="server" Text="Explora oportunidades laborales" /></p>
                                    <asp:Button ID="btnJobs" runat="server" CssClass="btn btn-success" 
                                        Text="Ver Empleos" OnClick="btnJobs_Click" />
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 shadow-sm">
                                <div class="card-body text-center">
                                    <div class="text-info mb-3">
                                        <i class="fas fa-robot fa-3x"></i>
                                    </div>
                                    <h5 class="card-title"><asp:Literal runat="server" Text="Chat con Hirebot" /></h5>
                                    <p class="card-text"><asp:Literal runat="server" Text="Conversa con nuestro asistente IA" /></p>
                                    <asp:Button ID="btnChat" runat="server" CssClass="btn btn-info" 
                                        Text="Iniciar Chat" OnClick="btnChat_Click" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row mt-4">
                        <div class="col-12">
                            <div class="card border-0 shadow-sm">
                                <div class="card-header bg-light">
                                    <h5 class="mb-0"><asp:Literal runat="server" Text="Información del Usuario" /></h5>
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <p><strong><asp:Literal runat="server" Text="Usuario" />:</strong> <asp:Label ID="lblUsernameInfo" runat="server"></asp:Label></p>
                                            <p><strong><asp:Literal runat="server" Text="Correo Electrónico" />:</strong> <asp:Label ID="lblEmail" runat="server"></asp:Label></p>
                                        </div>
                                        <div class="col-md-6">
                                            <p><strong><asp:Literal runat="server" Text="Nombre" />:</strong> <asp:Label ID="lblFirstName" runat="server"></asp:Label></p>
                                            <p><strong><asp:Literal runat="server" Text="Apellido" />:</strong> <asp:Label ID="lblLastName" runat="server"></asp:Label></p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
    </div>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        console.log('📊 Dashboard chart renderer loaded');
        
        function renderSurveyCharts() {
            console.log('🔍 Rendering survey charts...');
            
            // Find all hidden fields with chart data
            const chartFields = document.querySelectorAll('input[id*="hfChartData"]');
            console.log(`Found ${chartFields.length} chart data fields`);
            
            chartFields.forEach(field => {
                if (field.value) {
                    console.log(`✅ Chart data found: ${field.value}`);
                    
                    const container = field.closest('.mb-4');
                    if (container) {
                        const canvas = container.querySelector('canvas');
                        if (canvas) {
                            try {
                                const chartData = JSON.parse(field.value);
                                console.log('📊 Creating chart:', chartData);
                                
                                new Chart(canvas, {
                                    type: 'bar',
                                    data: chartData,
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        scales: {
                                            y: {
                                                beginAtZero: true,
                                                ticks: {
                                                    stepSize: 1,
                                                    precision: 0
                                                }
                                            }
                                        },
                                        plugins: {
                                            legend: {
                                                display: false
                                            }
                                        }
                                    }
                                });
                                
                                console.log('✅ Chart created!');
                            } catch (err) {
                                console.error('❌ Chart error:', err);
                            }
                        }
                    }
                }
            });
        }
        
        // Render on load
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', renderSurveyCharts);
        } else {
            renderSurveyCharts();
        }
        
        // Also try after delay
        setTimeout(renderSurveyCharts, 500);

        // High Contrast Toggle Functionality
        console.log('🎨 High contrast toggle loaded');

        // Toggle high contrast mode
        function toggleHighContrast() {
            const highContrastBtn = document.getElementById('btnHighContrast');
            const contrastText = document.getElementById('contrastText');

            if (!highContrastBtn || !contrastText) {
                console.log('❌ Button elements not found');
                return false;
            }

            const isCurrentlyHighContrast = document.body.classList.contains('high-contrast');
            console.log(`🔄 Toggling high contrast. Current state: ${isCurrentlyHighContrast}`);

            if (isCurrentlyHighContrast) {
                // Switch to normal mode
                document.body.classList.remove('high-contrast');
                contrastText.textContent = 'Alto Contraste';
                highContrastBtn.classList.remove('btn-warning');
                highContrastBtn.classList.add('btn-secondary');
                localStorage.setItem('highContrastMode', 'false');
                console.log('✅ Switched to normal mode');
            } else {
                // Switch to high contrast mode
                document.body.classList.add('high-contrast');
                contrastText.textContent = 'Modo Normal';
                highContrastBtn.classList.remove('btn-secondary');
                highContrastBtn.classList.add('btn-warning');
                localStorage.setItem('highContrastMode', 'true');
                console.log('✅ Switched to high contrast mode');
            }

            return false; // Prevent form submission
        }

        // Check if high contrast is already enabled from localStorage
        function loadHighContrastPreference() {
            const isHighContrast = localStorage.getItem('highContrastMode') === 'true';
            console.log(`📋 High contrast preference loaded: ${isHighContrast}`);

            const highContrastBtn = document.getElementById('btnHighContrast');
            const contrastText = document.getElementById('contrastText');

            if (!highContrastBtn || !contrastText) {
                console.log('❌ Button elements not found during load');
                return;
            }

            if (isHighContrast) {
                document.body.classList.add('high-contrast');
                contrastText.textContent = 'Modo Normal';
                highContrastBtn.classList.remove('btn-secondary');
                highContrastBtn.classList.add('btn-warning');
                console.log('✅ High contrast mode activated from preference');
            }
        }

        // Load preference on page load - multiple attempts for UpdatePanel compatibility
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', loadHighContrastPreference);
        } else {
            loadHighContrastPreference();
        }
        setTimeout(loadHighContrastPreference, 100);
        setTimeout(loadHighContrastPreference, 500);

        // Keyboard accessibility: Toggle with Ctrl+Alt+C
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey && e.altKey && e.key === 'c') {
                e.preventDefault();
                toggleHighContrast();
                console.log('⌨️ High contrast toggled via keyboard shortcut');
            }
        });
    </script>
</asp:Content>
