using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace UI.Controls
{
    public partial class PaginatedDataTable : UserControl
    {
        public delegate ABSTRACTIONS.PaginatedResult<T> DataSourceDelegate<T>(int pageNumber, int pageSize, object filters);
        
        public event EventHandler PageChanged;
        public event EventHandler PageSizeChanged;

        [Browsable(false)]
        public int CurrentPage
        {
            get { return ViewState["CurrentPage"] != null ? (int)ViewState["CurrentPage"] : 1; }
            set { ViewState["CurrentPage"] = value; }
        }

        [Browsable(false)]
        public int PageSize
        {
            get { return ViewState["PageSize"] != null ? (int)ViewState["PageSize"] : 10; }
            set 
            { 
                ViewState["PageSize"] = value;
                ddlPageSize.SelectedValue = value.ToString();
            }
        }

        [Browsable(false)]
        public int TotalRecords
        {
            get { return ViewState["TotalRecords"] != null ? (int)ViewState["TotalRecords"] : 0; }
            set { ViewState["TotalRecords"] = value; }
        }

        [Browsable(false)]
        public int TotalPages
        {
            get { return TotalRecords > 0 ? (int)Math.Ceiling((double)TotalRecords / PageSize) : 0; }
        }

        [Browsable(false)]
        public object CurrentFilters
        {
            get { return ViewState["CurrentFilters"]; }
            set { ViewState["CurrentFilters"] = value; }
        }

        public string EmptyDataTitle
        {
            get { return litEmptyTitle.Text; }
            set { litEmptyTitle.Text = value; }
        }

        public string EmptyDataMessage
        {
            get { return litEmptyMessage.Text; }
            set { litEmptyMessage.Text = value; }
        }

        public GridView DataGridView
        {
            get { return gvData; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ddlPageSize.SelectedValue = PageSize.ToString();
            }
        }

        public void SetDataSource<T>(ABSTRACTIONS.PaginatedResult<T> result)
        {
            if (result == null)
            {
                result = new ABSTRACTIONS.PaginatedResult<T>
                {
                    Data = new List<T>(),
                    TotalRecords = 0,
                    CurrentPage = 1,
                    PageSize = PageSize
                };
            }

            TotalRecords = result.TotalRecords;
            CurrentPage = result.CurrentPage;
            PageSize = result.PageSize;

            if (result.Data != null && result.Data.Any())
            {
                gvData.DataSource = result.Data;
                gvData.DataBind();
                gvData.Visible = true;
                pnlEmptyData.Visible = false;
            }
            else
            {
                gvData.Visible = false;
                pnlEmptyData.Visible = true;
            }

            UpdatePaginationControls();
        }

        public void SetColumns(List<BoundField> columns)
        {
            gvData.Columns.Clear();
            foreach (var column in columns)
            {
                gvData.Columns.Add(column);
            }
        }

        public void SetTemplateColumns(List<TemplateField> columns)
        {
            gvData.Columns.Clear();
            foreach (var column in columns)
            {
                gvData.Columns.Add(column);
            }
        }

        public void AddColumn(DataControlField column)
        {
            gvData.Columns.Add(column);
        }

        private void UpdatePaginationControls()
        {
            bool hasData = TotalRecords > 0;
            bool hasMultiplePages = TotalPages > 1;

            paginationContainer.Visible = hasData;

            if (!hasData)
                return;

            // Update record info
            int recordStart = ((CurrentPage - 1) * PageSize) + 1;
            int recordEnd = Math.Min(CurrentPage * PageSize, TotalRecords);
            
            litRecordStart.Text = recordStart.ToString();
            litRecordEnd.Text = recordEnd.ToString();
            litTotalRecords.Text = TotalRecords.ToString();

            // Update navigation buttons
            btnFirstPage.Enabled = CurrentPage > 1;
            btnPrevPage.Enabled = CurrentPage > 1;
            btnNextPage.Enabled = CurrentPage < TotalPages;
            btnLastPage.Enabled = CurrentPage < TotalPages;

            btnFirstPage.CssClass = $"page-link {(CurrentPage == 1 ? "disabled" : "")}";
            btnPrevPage.CssClass = $"page-link {(CurrentPage == 1 ? "disabled" : "")}";
            btnNextPage.CssClass = $"page-link {(CurrentPage == TotalPages ? "disabled" : "")}";
            btnLastPage.CssClass = $"page-link {(CurrentPage == TotalPages ? "disabled" : "")}";

            // Generate page numbers
            GeneratePageNumbers();
        }

        private void GeneratePageNumbers()
        {
            var pageNumbers = new List<PageNumber>();
            
            int startPage = Math.Max(1, CurrentPage - 2);
            int endPage = Math.Min(TotalPages, CurrentPage + 2);

            // Adjust range if we're near the beginning or end
            if (endPage - startPage < 4 && TotalPages > 5)
            {
                if (startPage == 1)
                    endPage = Math.Min(TotalPages, 5);
                else if (endPage == TotalPages)
                    startPage = Math.Max(1, TotalPages - 4);
            }

            for (int i = startPage; i <= endPage; i++)
            {
                pageNumbers.Add(new PageNumber { PageNum = i, IsActive = (i == CurrentPage) });
            }

            System.Diagnostics.Debug.WriteLine($"PaginatedDataTable: Generating page numbers from {startPage} to {endPage}, current page is {CurrentPage}");
            
            rptPageNumbers.DataSource = pageNumbers;
            rptPageNumbers.DataBind();
            
            // Add client-side script to highlight active page
            AddActivePageScript();
        }
        
        private void AddActivePageScript()
        {
            string script = $@"
                document.addEventListener('DOMContentLoaded', function() {{
                    // Remove active class from all page items
                    var pageItems = document.querySelectorAll('.page-item');
                    pageItems.forEach(function(item) {{
                        item.classList.remove('active');
                    }});
                    
                    // Add active class to current page
                    var currentPageItem = document.querySelector('#page-{CurrentPage}');
                    if (currentPageItem) {{
                        currentPageItem.classList.add('active');
                    }}
                }});
            ";
            
            Page.ClientScript.RegisterStartupScript(this.GetType(), "ActivePageHighlight", script, true);
        }

        protected void btnFirstPage_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1)
            {
                CurrentPage = 1;
                System.Diagnostics.Debug.WriteLine($"PaginatedDataTable: Moving to first page (1)");
                OnPageChanged();
            }
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1)
            {
                CurrentPage--;
                System.Diagnostics.Debug.WriteLine($"PaginatedDataTable: Moving to previous page ({CurrentPage})");
                OnPageChanged();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            if (CurrentPage < TotalPages)
            {
                CurrentPage++;
                System.Diagnostics.Debug.WriteLine($"PaginatedDataTable: Moving to next page ({CurrentPage})");
                OnPageChanged();
            }
        }

        protected void btnLastPage_Click(object sender, EventArgs e)
        {
            if (CurrentPage < TotalPages)
            {
                CurrentPage = TotalPages;
                System.Diagnostics.Debug.WriteLine($"PaginatedDataTable: Moving to last page ({CurrentPage})");
                OnPageChanged();
            }
        }

        protected void rptPageNumbers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "PageClick")
            {
                int pageNumber = Convert.ToInt32(e.CommandArgument);
                System.Diagnostics.Debug.WriteLine($"PaginatedDataTable: Page number {pageNumber} clicked, current page is {CurrentPage}");
                if (pageNumber != CurrentPage && pageNumber >= 1 && pageNumber <= TotalPages)
                {
                    CurrentPage = pageNumber;
                    System.Diagnostics.Debug.WriteLine($"PaginatedDataTable: Moving to page {pageNumber}");
                    OnPageChanged();
                }
            }
        }

        protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            int newPageSize = Convert.ToInt32(ddlPageSize.SelectedValue);
            System.Diagnostics.Debug.WriteLine($"PaginatedDataTable: Page size changed from {PageSize} to {newPageSize}");
            if (newPageSize != PageSize)
            {
                PageSize = newPageSize;
                CurrentPage = 1; // Reset to first page when changing page size
                System.Diagnostics.Debug.WriteLine($"PaginatedDataTable: Triggering page size change event");
                OnPageSizeChanged();
            }
        }

        protected virtual void OnPageChanged()
        {
            System.Diagnostics.Debug.WriteLine($"PaginatedDataTable: OnPageChanged called, current page is {CurrentPage}");
            UpdatePaginationControls(); // Update the UI immediately
            PageChanged?.Invoke(this, EventArgs.Empty);
        }

        protected virtual void OnPageSizeChanged()
        {
            System.Diagnostics.Debug.WriteLine($"PaginatedDataTable: OnPageSizeChanged called");
            UpdatePaginationControls(); // Update the UI immediately
            PageSizeChanged?.Invoke(this, EventArgs.Empty);
        }

        public class PageNumber
        {
            public int PageNum { get; set; }
            public bool IsActive { get; set; }
        }
    }

}