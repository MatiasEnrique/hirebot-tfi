<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminReports.aspx.cs" Inherits="Hirebot_TFI.AdminReports" MasterPageFile="~/Admin.master" %>

<asp:Content ID="ReportsTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Reportes de administración" />
</asp:Content>

<asp:Content ID="ReportsHead" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="ReportsMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid">
        <div class="row mb-3">
            <div class="col-12 d-flex align-items-center justify-content-between flex-wrap">
                <h1 class="h3 mb-0 text-gray-800">
                    <asp:Literal runat="server" Text="Reportes administrativos" />
                </h1>
            </div>
        </div>

        <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-danger" role="alert">
            <asp:Literal ID="litError" runat="server" />
        </asp:Panel>

        <div class="card shadow mb-4">
            <div class="card-body">
                <div class="row g-3 align-items-end">
                    <div class="col-sm-6 col-lg-3">
                        <label for="<%= txtYear.ClientID %>" class="form-label">
                            <asp:Literal runat="server" Text="Año" />
                        </label>
                        <asp:TextBox ID="txtYear" runat="server" CssClass="form-control" MaxLength="4" />
                        <small class="form-text text-muted">
                            <asp:Literal runat="server" Text="Ingresa un año entre 2000 y 2100." />
                        </small>
                    </div>
                    <div class="col-sm-6 col-lg-3">
                        <label for="<%= ddlSortDirection.ClientID %>" class="form-label">
                            <asp:Literal runat="server" Text="Orden mensual" />
                        </label>
                        <asp:DropDownList ID="ddlSortDirection" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                    <div class="col-sm-6 col-lg-3">
                        <asp:Button ID="btnApplyFilters" runat="server" CssClass="btn btn-primary w-100" OnClick="btnApplyFilters_Click" Text="Aplicar filtros" />
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <h2 class="h4 mb-3">
                    <asp:Literal runat="server" Text="Resumen de facturación" />
                </h2>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-primary shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-primary text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Documentos totales" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litTotalBillingDocuments" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-success shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-success text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Documentos pagados" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litPaidBillingDocuments" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-warning shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-warning text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Documentos pendientes" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litOutstandingBillingDocuments" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-danger shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-danger text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Documentos cancelados" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litCancelledBillingDocuments" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Billing amounts summary -->
        <div class="row g-3 mb-2">
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-primary shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-primary text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Monto total" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litTotalBillingAmount" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-success shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-success text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Monto cobrado" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litPaidBillingAmount" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-warning shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-warning text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Monto pendiente" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litOutstandingBillingAmount" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-info shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-info text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Monto promedio por factura" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litAverageInvoiceAmount" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mb-4">
            <div class="col-12 text-muted small">
                <asp:Literal runat="server" Text="Última actualización" />:
                <strong><asp:Literal ID="litBillingLastUpdated" runat="server" /></strong>
            </div>
        </div>

        <div class="card shadow mb-4">
            <div class="card-header py-3">
                <h6 class="m-0 fw-bold text-primary">
                    <asp:Literal runat="server" Text="Desempeño mensual de facturación" />
                </h6>
            </div>
            <div class="card-body">
                <canvas id="billingTotalsChart" height="120"></canvas>
            </div>
        </div>

        <div class="card shadow mb-5">
            <div class="card-header py-3">
                <h6 class="m-0 fw-bold text-primary">
                    <asp:Literal runat="server" Text="Detalle mensual de facturación" />
                </h6>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <asp:Repeater ID="rptBillingMonthly" runat="server">
                        <HeaderTemplate>
                            <table class="table table-striped table-hover align-middle">
                                <thead class="table-dark">
                                    <tr>
                                        <th scope="col"><asp:Literal runat="server" Text="Mes" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="Totales" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="Pagados" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="Pendientes" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="Cancelados" /></th>
                                        <th scope="col" class="text-end"><asp:Literal runat="server" Text="Monto total" /></th>
                                        <th scope="col" class="text-end"><asp:Literal runat="server" Text="Monto cobrado" /></th>
                                        <th scope="col" class="text-end"><asp:Literal runat="server" Text="Monto pendiente" /></th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                                    <tr>
                                        <td><%# string.Format("{0:00}/{1}", Eval("MonthNumber"), Eval("YearNumber")) %> - <%# Encode(Eval("MonthName")) %></td>
                                        <td class="text-center"><%# Eval("TotalDocuments") %></td>
                                        <td class="text-center"><%# Eval("PaidDocuments") %></td>
                                        <td class="text-center"><%# Convert.ToInt32(Eval("DraftDocuments")) + Convert.ToInt32(Eval("IssuedDocuments")) %></td>
                                        <td class="text-center"><%# Eval("CancelledDocuments") %></td>
                                        <td class="text-end"><%# string.Format(System.Globalization.CultureInfo.CurrentUICulture, "{0:C}", Eval("TotalAmount")) %></td>
                                        <td class="text-end"><%# string.Format(System.Globalization.CultureInfo.CurrentUICulture, "{0:C}", Eval("PaidAmount")) %></td>
                                        <td class="text-end"><%# string.Format(System.Globalization.CultureInfo.CurrentUICulture, "{0:C}", Eval("OutstandingAmount")) %></td>
                                    </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <h2 class="h4 mb-3">
                    <asp:Literal runat="server" Text="Resumen de encuestas" />
                </h2>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-primary shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-primary text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Encuestas totales" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litTotalSurveys" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-success shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-success text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Encuestas activas" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litActiveSurveys" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-info shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-info text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Encuestas programadas" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litScheduledSurveys" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-warning shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-warning text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Encuestas vencidas" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litExpiredSurveys" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-primary shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-primary text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Respuestas totales" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litSurveyResponses" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-success shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-success text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Respuestas (30 días)" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litSurveyResponses30" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-info shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-info text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Promedio por encuesta" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litAverageResponses" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-warning shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-warning text-uppercase mb-1">
                            <asp:Literal runat="server" Text="Última respuesta" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litSurveyLastResponse" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card shadow mb-4">
            <div class="card-header py-3">
                <h6 class="m-0 fw-bold text-primary">
                    <asp:Literal runat="server" Text="Respuestas por encuesta" />
                </h6>
            </div>
            <div class="card-body">
                <canvas id="surveyResponsesChart" height="120"></canvas>
            </div>
        </div>

        <div class="card shadow mb-5">
            <div class="card-header py-3">
                <h6 class="m-0 fw-bold text-primary">
                    <asp:Literal runat="server" Text="Detalle de encuestas" />
                </h6>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <asp:Repeater ID="rptSurveyDetails" runat="server">
                        <HeaderTemplate>
                            <table class="table table-striped table-hover align-middle">
                                <thead class="table-dark">
                                    <tr>
                                        <th scope="col"><asp:Literal runat="server" Text="Encuesta" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="Estado" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="Preguntas" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="Respuestas totales" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="Respuestas (30 días)" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="Vigencia" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="Última respuesta" /></th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                                    <tr>
                                        <td>
                                            <div class="fw-bold"><%# Encode(Eval("Title")) %></div>
                                            <div class="text-muted small">
                                                <%# GetDateRange(Container.DataItem) %>
                                            </div>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge <%# ((bool)Eval("IsCurrentlyOpen")) ? "bg-success" : ((bool)Eval("IsActive")) ? "bg-info" : "bg-secondary" %>">
                                                <%# GetSurveyStatus(Container.DataItem) %>
                                            </span>
                                        </td>
                                        <td class="text-center"><%# Eval("QuestionCount") %></td>
                                        <td class="text-center"><%# Eval("TotalResponses") %></td>
                                        <td class="text-center"><%# Eval("ResponsesLast30Days") %></td>
                                        <td class="text-center"><%# GetSurveyWindow(Container.DataItem) %></td>
                                        <td class="text-center"><%# GetSurveyLastResponse(Container.DataItem) %></td>
                                    </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>

        <asp:HiddenField ID="hfBillingChartData" runat="server" />
        <asp:HiddenField ID="hfSurveyChartData" runat="server" />
    </div>
</asp:Content>

<asp:Content ID="ReportsScripts" ContentPlaceHolderID="ScriptContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        (function () {
            const formatCurrency = value => {
                if (typeof Intl !== 'undefined' && Intl.NumberFormat) {
                    return new Intl.NumberFormat(document.documentElement.lang || 'es', {
                        style: 'currency',
                        currency: 'ARS',
                        minimumFractionDigits: 2
                    }).format(value || 0);
                }
                return (value || 0).toFixed(2);
            };

            const billingField = document.getElementById('<%= hfBillingChartData.ClientID %>');
            if (billingField && billingField.value) {
                try {
                    const billingData = JSON.parse(billingField.value);
                    const ctx = document.getElementById('billingTotalsChart');
                    if (ctx && billingData && billingData.labels.length) {
                        new Chart(ctx, {
                            type: 'line',
                            data: billingData,
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                interaction: { intersect: false, mode: 'index' },
                                plugins: { tooltip: { callbacks: { label: c => `${c.dataset.label || ''}: ${formatCurrency(c.parsed.y || 0)}` } } },
                                scales: { y: { ticks: { callback: v => formatCurrency(v) } } }
                            }
                        });
                    }
                } catch (err) { console.error('Unable to render billing chart', err); }
            }

            const surveyField = document.getElementById('<%= hfSurveyChartData.ClientID %>');
            if (surveyField && surveyField.value) {
                try {
                    const surveyData = JSON.parse(surveyField.value);
                    const ctx = document.getElementById('surveyResponsesChart');
                    if (ctx && surveyData && surveyData.labels.length) {
                        new Chart(ctx, { type: 'bar', data: surveyData, options: { responsive: true, maintainAspectRatio: false } });
                    }
                } catch (err) { console.error('Unable to render survey chart', err); }
            }
        })();
    </script>
</asp:Content>
