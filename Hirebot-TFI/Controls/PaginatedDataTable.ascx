<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PaginatedDataTable.ascx.cs" Inherits="UI.Controls.PaginatedDataTable" %>

<div class="paginated-datatable-container">
    <!-- Data Table -->
    <div class="admin-section p-0 shadow-sm">
        <asp:GridView ID="gvData" runat="server" CssClass="table table-striped table-hover mb-0" 
                      AutoGenerateColumns="false" AllowPaging="false">
        </asp:GridView>
        
        <!-- Empty Data Template -->
        <asp:Panel ID="pnlEmptyData" runat="server" Visible="false" CssClass="text-center p-4">
            <i class="bi bi-inbox display-1 text-muted"></i>
            <h5 class="mt-3 text-muted">
                <asp:Literal ID="litEmptyTitle" runat="server" Text="<%$ Resources:GlobalResources,NoRecordsFound %>" />
            </h5>
            <p class="text-muted">
                <asp:Literal ID="litEmptyMessage" runat="server" Text="<%$ Resources:GlobalResources,NoRecordsFoundMessage %>" />
            </p>
        </asp:Panel>
    </div>
    
    <!-- Pagination Controls -->
    <div class="d-flex justify-content-between align-items-center mt-3" id="paginationContainer" runat="server">
        <div class="pagination-info">
            <small class="text-muted">
                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Showing %>" />
                <strong><asp:Literal ID="litRecordStart" runat="server" Text="0" /></strong>
                -
                <strong><asp:Literal ID="litRecordEnd" runat="server" Text="0" /></strong>
                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Of %>" />
                <strong><asp:Literal ID="litTotalRecords" runat="server" Text="0" /></strong>
                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Records %>" />
            </small>
        </div>
        
        <div class="pagination-controls">
            <nav>
                <ul class="pagination pagination-sm mb-0">
                    <li class="page-item">
                        <asp:LinkButton ID="btnFirstPage" runat="server" CssClass="page-link" OnClick="btnFirstPage_Click" Text="<<" />
                    </li>
                    <li class="page-item">
                        <asp:LinkButton ID="btnPrevPage" runat="server" CssClass="page-link" OnClick="btnPrevPage_Click" Text="<" />
                    </li>
                    
                    <!-- Page Numbers -->
                    <asp:Repeater ID="rptPageNumbers" runat="server" OnItemCommand="rptPageNumbers_ItemCommand">
                        <ItemTemplate>
                            <li class='page-item <%# (bool)Eval("IsActive") ? "active" : "" %>' id='<%# "page-" + Eval("PageNum") %>'>
                                <asp:LinkButton ID="btnPage" runat="server" 
                                    CssClass="page-link" 
                                    CommandName="PageClick" 
                                    CommandArgument='<%# Eval("PageNum") %>'
                                    Text='<%# Eval("PageNum") %>' />
                            </li>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <li class="page-item">
                        <asp:LinkButton ID="btnNextPage" runat="server" CssClass="page-link" OnClick="btnNextPage_Click" Text=">" />
                    </li>
                    <li class="page-item">
                        <asp:LinkButton ID="btnLastPage" runat="server" CssClass="page-link" OnClick="btnLastPage_Click" Text=">>" />
                    </li>
                </ul>
            </nav>
        </div>
        
        <div class="page-size-selector">
            <small class="text-muted me-2">
                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,RecordsPerPage %>" />:
            </small>
            <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="form-select form-select-sm" 
                              AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged"
                              style="width: auto; display: inline-block;">
                <asp:ListItem Value="5" Text="5" />
                <asp:ListItem Value="10" Text="10" Selected="True" />
                <asp:ListItem Value="25" Text="25" />
                <asp:ListItem Value="50" Text="50" />
                <asp:ListItem Value="100" Text="100" />
            </asp:DropDownList>
        </div>
    </div>
</div>

<style>
    .pagination-wrapper {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 1rem;
        background-color: #f8f9fa;
        border-top: 1px solid #dee2e6;
    }
    
    .pagination-info {
        font-size: 0.875rem;
    }
    
    .page-size-selector .form-select {
        width: 80px;
    }
    
    @media (max-width: 768px) {
        .d-flex.justify-content-between.align-items-center {
            flex-direction: column;
            gap: 1rem;
        }
        
        .pagination-info,
        .page-size-selector {
            text-align: center;
        }
    }
</style>