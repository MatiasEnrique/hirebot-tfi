<%@ Page Title="<%$ Resources:GlobalResources,AdminReportsTitle %>" Language="C#" MasterPageFile="~/Protected.master" AutoEventWireup="true" CodeBehind="AdminReports.aspx.cs" Inherits="Hirebot_TFI.AdminReports" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid">
        <div class="row mb-3">
            <div class="col-12 d-flex align-items-center justify-content-between flex-wrap">
                <h1 class="h3 mb-0 text-gray-800">
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsHeading %>" />
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
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsYearFilter %>" />
                        </label>
                        <asp:TextBox ID="txtYear" runat="server" CssClass="form-control" MaxLength="4" />
                        <small class="form-text text-muted">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsYearHint %>" />
                        </small>
                    </div>
                    <div class="col-sm-6 col-lg-3">
                        <label for="<%= ddlSortDirection.ClientID %>" class="form-label">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSortLabel %>" />
                        </label>
                        <asp:DropDownList ID="ddlSortDirection" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                    <div class="col-sm-6 col-lg-3">
                        <asp:Button ID="btnApplyFilters" runat="server" CssClass="btn btn-primary w-100" OnClick="btnApplyFilters_Click" Text="<%$ Resources:GlobalResources,AdminReportsApplyFilters %>" />
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <h2 class="h4 mb-3">
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingSummary %>" />
                </h2>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-primary shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-primary text-uppercase mb-1">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTotalDocuments %>" />
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
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingPaidDocuments %>" />
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
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingOutstandingDocuments %>" />
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
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingCancelledDocuments %>" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litCancelledBillingDocuments" runat="server" />
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
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTotalAmount %>" />
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
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingPaidAmount %>" />
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
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingOutstandingAmount %>" />
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
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingAverageAmount %>" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litAverageInvoiceAmount" runat="server" />
                        </div>
                        <div class="text-xs text-muted mt-2">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingLastUpdated %>" />
                            :
                            <asp:Literal ID="litBillingLastUpdated" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card shadow mb-4">
            <div class="card-header py-3">
                <h6 class="m-0 fw-bold text-primary">
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingChartTitle %>" />
                </h6>
            </div>
            <div class="card-body">
                <canvas id="billingTotalsChart" height="120"></canvas>
            </div>
        </div>

        <div class="card shadow mb-5">
            <div class="card-header py-3">
                <h6 class="m-0 fw-bold text-primary">
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTableTitle %>" />
                </h6>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <asp:Repeater ID="rptBillingMonthly" runat="server">
                        <HeaderTemplate>
                            <table class="table table-striped table-hover align-middle">
                                <thead class="table-dark">
                                    <tr>
                                        <th scope="col"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTableMonth %>" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTableTotalDocs %>" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTablePaidDocs %>" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTableOutstandingDocs %>" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTableCancelledDocs %>" /></th>
                                        <th scope="col" class="text-end"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTableTotalAmount %>" /></th>
                                        <th scope="col" class="text-end"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTablePaidAmount %>" /></th>
                                        <th scope="col" class="text-end"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsBillingTableOutstandingAmount %>" /></th>
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
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveySummary %>" />
                </h2>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-primary shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-primary text-uppercase mb-1">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTotal %>" />
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
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyActive %>" />
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
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyScheduled %>" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litScheduledSurveys" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-danger shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-danger text-uppercase mb-1">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyExpired %>" />
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
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTotalResponses %>" />
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
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyResponses30 %>" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litSurveyResponses30" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-warning shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-warning text-uppercase mb-1">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyAverageResponses %>" />
                        </div>
                        <div class="h5 mb-0 fw-bold text-gray-800">
                            <asp:Literal ID="litAverageResponses" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xl-3">
                <div class="card border-start-info shadow h-100 py-3">
                    <div class="card-body">
                        <div class="text-xs fw-bold text-info text-uppercase mb-1">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyLastResponse %>" />
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
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyChartTitle %>" />
                </h6>
            </div>
            <div class="card-body">
                <canvas id="surveyResponsesChart" height="120"></canvas>
            </div>
        </div>

        <div class="card shadow mb-5">
            <div class="card-header py-3">
                <h6 class="m-0 fw-bold text-primary">
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableTitle %>" />
                </h6>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <asp:Repeater ID="rptSurveyDetails" runat="server">
                        <HeaderTemplate>
                            <table class="table table-striped table-hover align-middle">
                                <thead class="table-dark">
                                    <tr>
                                        <th scope="col"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableTitleCol %>" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableStatus %>" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableQuestions %>" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableTotalResponses %>" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableRecentResponses %>" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableWindow %>" /></th>
                                        <th scope="col" class="text-center"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AdminReportsSurveyTableLastResponse %>" /></th>
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
    </div>

    <asp:HiddenField ID="hfBillingChartData" runat="server" />
    <asp:HiddenField ID="hfSurveyChartData" runat="server" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ScriptContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script type="text/javascript">
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
                                plugins: {
                                    tooltip: {
                                        callbacks: {
                                            label: context => {
                                                const label = context.dataset.label || '';
                                                const value = context.parsed.y || 0;
                                                return `${label}: ${formatCurrency(value)}`;
                                            }
                                        }
                                    }
                                },
                                scales: {
                                    y: {
                                        ticks: {
                                            callback: value => formatCurrency(value)
                                        }
                                    }
                                }
                            }
                        });
                    }
                } catch (err) {
                    console.error('Unable to render billing chart', err);
                }
            }

            const surveyField = document.getElementById('<%= hfSurveyChartData.ClientID %>');
            if (surveyField && surveyField.value) {
                try {
                    const surveyData = JSON.parse(surveyField.value);
                    const ctx = document.getElementById('surveyResponsesChart');
                    if (ctx && surveyData && surveyData.labels.length) {
                        new Chart(ctx, {
                            type: 'bar',
                            data: surveyData,
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                interaction: { intersect: false, mode: 'index' },
                                scales: {
                                    y: {
                                        beginAtZero: true,
                                        ticks: {
                                            precision: 0
                                        }
                                    }
                                }
                            }
                        });
                    }
                } catch (err) {
                    console.error('Unable to render survey chart', err);
                }
            }
        })();
    </script>
</asp:Content>
