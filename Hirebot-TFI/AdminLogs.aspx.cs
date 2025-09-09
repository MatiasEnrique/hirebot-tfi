using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ABSTRACTIONS;
using Hirebot_TFI;
using SECURITY;
using BLL;

namespace UI
{
    public partial class AdminLogs : BasePage
    {
        private AdminSecurity adminSecurity;
        private LogBLL logBLL;
        private UserBLL userBLL;

        protected void Page_Load(object sender, EventArgs e)
        {
            adminSecurity = new AdminSecurity();
            logBLL = new LogBLL();
            userBLL = new UserBLL();
            
            // Ensure only admins can access this page
            adminSecurity.RedirectIfNotAdmin();

            if (!IsPostBack)
            {
                LoadUserDropdown();
                LoadStatistics();
                SetDefaultDateFilters();
                LoadLogs();
            }
        }


        protected void btnSignOut_Click(object sender, EventArgs e)
        {
            var userSecurity = new UserSecurity();
            userSecurity.SignOutUser();
            Response.Redirect("~/Default.aspx");
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            LoadLogs();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            ClearFilters();
            LoadLogs();
            LoadStatistics();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadLogs();
            LoadStatistics();
        }

        protected void btnExportCsv_Click(object sender, EventArgs e)
        {
            try
            {
                // Get all logs matching current filters (not paginated)
                var filters = GetFilterCriteria();
                var allLogsResult = logBLL.GetFilteredLogsPaginated(filters, 1, int.MaxValue);
                ExportToCsv(allLogsResult.Data);
            }
            catch (Exception ex)
            {
                adminSecurity.LogError(GetCurrentUserId(), "Export CSV error: " + ex.Message);
            }
        }

        protected void ddlDateRange_SelectedIndexChanged(object sender, EventArgs e)
        {
            SetDateRangeFromDropdown();
            LoadLogs();
        }

        protected void gvLogs_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvLogs.PageIndex = e.NewPageIndex;
            LoadLogs();
        }

        protected void gvLogs_RowCreated(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.Pager)
            {
                CreateCustomPager(e.Row);
            }
        }

        private void CreateCustomPager(GridViewRow pagerRow)
        {
            // Clear the existing pager
            pagerRow.Cells.Clear();
            
            // Create a new cell to hold our custom pager
            TableCell cell = new TableCell();
            cell.ColumnSpan = gvLogs.Columns.Count;
            cell.CssClass = "custom-pager-cell";
            
            // Create the pager container
            var pagerDiv = new System.Web.UI.HtmlControls.HtmlGenericControl("div");
            pagerDiv.Attributes["class"] = "custom-pager-container";
            
            int currentPage = gvLogs.PageIndex + 1;
            int totalPages = gvLogs.PageCount;
            
            // Previous button
            if (currentPage > 1)
            {
                var prevLink = new LinkButton();
                prevLink.Text = "‹ Previous";
                prevLink.CssClass = "page-btn";
                prevLink.CommandName = "Page";
                prevLink.CommandArgument = "Prev";
                pagerDiv.Controls.Add(prevLink);
            }
            else
            {
                var prevSpan = new System.Web.UI.WebControls.Label();
                prevSpan.Text = "‹ Previous";
                prevSpan.CssClass = "page-btn disabled";
                pagerDiv.Controls.Add(prevSpan);
            }
            
            // Page numbers (show 5 pages around current)
            int startPage = Math.Max(1, currentPage - 2);
            int endPage = Math.Min(totalPages, currentPage + 2);
            
            for (int i = startPage; i <= endPage; i++)
            {
                if (i == currentPage)
                {
                    var currentSpan = new System.Web.UI.WebControls.Label();
                    currentSpan.Text = i.ToString();
                    currentSpan.CssClass = "page-btn active";
                    pagerDiv.Controls.Add(currentSpan);
                }
                else
                {
                    var pageLink = new LinkButton();
                    pageLink.Text = i.ToString();
                    pageLink.CssClass = "page-btn";
                    pageLink.CommandName = "Page";
                    pageLink.CommandArgument = i.ToString();
                    pagerDiv.Controls.Add(pageLink);
                }
            }
            
            // Next button
            if (currentPage < totalPages)
            {
                var nextLink = new LinkButton();
                nextLink.Text = "Next ›";
                nextLink.CssClass = "page-btn";
                nextLink.CommandName = "Page";
                nextLink.CommandArgument = "Next";
                pagerDiv.Controls.Add(nextLink);
            }
            else
            {
                var nextSpan = new System.Web.UI.WebControls.Label();
                nextSpan.Text = "Next ›";
                nextSpan.CssClass = "page-btn disabled";
                pagerDiv.Controls.Add(nextSpan);
            }
            
            cell.Controls.Add(pagerDiv);
            pagerRow.Cells.Add(cell);
        }

        private void LoadStatistics()
        {
            try
            {
                // Total logs
                var allLogs = logBLL.GetAllLogs();
                litTotalLogs.Text = allLogs.Count.ToString();

                // Today's logs
                var todaysLogs = logBLL.GetTodaysLogs();
                litTodaysLogs.Text = todaysLogs.Count.ToString();

                // Error logs
                var errorLogs = logBLL.GetLogsByType("ERROR");
                litErrorLogs.Text = errorLogs.Count.ToString();

                // Login logs
                var loginLogs = logBLL.GetLogsByType("LOGIN");
                litLoginLogs.Text = loginLogs.Count.ToString();
            }
            catch
            {
                // Silent fail - no logging needed for loading statistics
            }
        }

        private void LoadUserDropdown()
        {
            try
            {
                var users = userBLL.GetAllUsers();
                ddlUserFilter.Items.Clear();
                ddlUserFilter.Items.Add(new ListItem(HttpContext.GetGlobalResourceObject("GlobalResources", "AllUsers").ToString(), ""));
                
                foreach (var user in users)
                {
                    string displayName = $"{user.FirstName} {user.LastName} ({user.Username})";
                    ddlUserFilter.Items.Add(new ListItem(displayName, user.UserId.ToString()));
                }
            }
            catch
            {
                // Silent fail - no logging needed for dropdown population
            }
        }

        private Dictionary<int, string> _userDisplayNames;
        
        public string GetUserDisplayName(object userIdObj)
        {
            if (userIdObj == null || userIdObj == DBNull.Value)
                return "System";

            if (!int.TryParse(userIdObj.ToString(), out int userId))
                return "Unknown";

            // Cache user names to avoid repeated database calls
            if (_userDisplayNames == null)
            {
                try
                {
                    var users = userBLL.GetAllUsers();
                    _userDisplayNames = users.ToDictionary(u => u.UserId, u => $"{u.FirstName} {u.LastName}");
                }
                catch
                {
                    _userDisplayNames = new Dictionary<int, string>();
                }
            }

            return _userDisplayNames.ContainsKey(userId) ? _userDisplayNames[userId] : $"User #{userId}";
        }


        private void LoadLogs()
        {
            try
            {
                var filters = GetFilterCriteria();
                var logs = GetLogsWithFallback(filters);
                
                gvLogs.DataSource = logs;
                gvLogs.DataBind();
            }
            catch (Exception ex)
            {
                adminSecurity.LogError(GetCurrentUserId(), "LoadLogs error: " + ex.Message);
                gvLogs.DataSource = new List<Log>();
                gvLogs.DataBind();
            }
        }

        private List<Log> GetLogsWithFallback(LogFilterCriteria filters)
        {
            try
            {
                // Start with all logs
                var logs = logBLL.GetAllLogs();

                // Apply filters
                if (!string.IsNullOrEmpty(filters.LogType))
                {
                    logs = logs.Where(l => l.LogType == filters.LogType).ToList();
                }

                if (filters.UserId.HasValue)
                {
                    logs = logs.Where(l => l.UserId == filters.UserId.Value).ToList();
                }

                if (!string.IsNullOrEmpty(filters.Description))
                {
                    logs = logs.Where(l => l.Description != null && 
                                          l.Description.IndexOf(filters.Description, StringComparison.OrdinalIgnoreCase) >= 0).ToList();
                }

                if (filters.StartDate.HasValue)
                {
                    logs = logs.Where(l => l.CreatedAt >= filters.StartDate.Value).ToList();
                }

                if (filters.EndDate.HasValue)
                {
                    logs = logs.Where(l => l.CreatedAt <= filters.EndDate.Value).ToList();
                }

                return logs.OrderByDescending(l => l.CreatedAt).ToList();
            }
            catch
            {
                return new List<Log>();
            }
        }

        private LogFilterCriteria GetFilterCriteria()
        {
            var filters = new LogFilterCriteria();
            
            // Log type filter
            if (!string.IsNullOrEmpty(ddlLogTypeFilter.SelectedValue))
            {
                filters.LogType = ddlLogTypeFilter.SelectedValue;
            }
            
            // User filter
            if (!string.IsNullOrEmpty(ddlUserFilter.SelectedValue) && int.TryParse(ddlUserFilter.SelectedValue, out int userId))
            {
                filters.UserId = userId;
            }
            
            // Description filter
            if (!string.IsNullOrEmpty(txtDescriptionFilter.Text.Trim()))
            {
                filters.Description = txtDescriptionFilter.Text.Trim();
            }
            
            // Date range filters
            if (!string.IsNullOrEmpty(txtStartDate.Text) && DateTime.TryParse(txtStartDate.Text, out DateTime startDate))
            {
                filters.StartDate = startDate.Date;
            }
            
            if (!string.IsNullOrEmpty(txtEndDate.Text) && DateTime.TryParse(txtEndDate.Text, out DateTime endDate))
            {
                filters.EndDate = endDate.Date.AddDays(1).AddSeconds(-1); // End of day
            }
            
            return filters;
        }


        private void SetDefaultDateFilters()
        {
            // Set default to last 7 days
            txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            txtStartDate.Text = DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd");
        }

        private void SetDateRangeFromDropdown()
        {
            string selectedRange = ddlDateRange.SelectedValue;
            DateTime now = DateTime.Now;

            switch (selectedRange)
            {
                case "today":
                    txtStartDate.Text = now.ToString("yyyy-MM-dd");
                    txtEndDate.Text = now.ToString("yyyy-MM-dd");
                    break;
                case "yesterday":
                    DateTime yesterday = now.AddDays(-1);
                    txtStartDate.Text = yesterday.ToString("yyyy-MM-dd");
                    txtEndDate.Text = yesterday.ToString("yyyy-MM-dd");
                    break;
                case "week":
                    DateTime startOfWeek = now.AddDays(-(int)now.DayOfWeek);
                    txtStartDate.Text = startOfWeek.ToString("yyyy-MM-dd");
                    txtEndDate.Text = now.ToString("yyyy-MM-dd");
                    break;
                case "month":
                    DateTime startOfMonth = new DateTime(now.Year, now.Month, 1);
                    txtStartDate.Text = startOfMonth.ToString("yyyy-MM-dd");
                    txtEndDate.Text = now.ToString("yyyy-MM-dd");
                    break;
                case "7days":
                    txtStartDate.Text = now.AddDays(-7).ToString("yyyy-MM-dd");
                    txtEndDate.Text = now.ToString("yyyy-MM-dd");
                    break;
                case "30days":
                    txtStartDate.Text = now.AddDays(-30).ToString("yyyy-MM-dd");
                    txtEndDate.Text = now.ToString("yyyy-MM-dd");
                    break;
                default:
                    // Custom range - don't change the date fields
                    break;
            }
        }

        private void ClearFilters()
        {
            ddlLogTypeFilter.SelectedIndex = 0;
            ddlUserFilter.SelectedIndex = 0;
            txtDescriptionFilter.Text = "";
            txtStartDate.Text = "";
            txtEndDate.Text = "";
            ddlDateRange.SelectedIndex = 0;
        }

        private void ExportToCsv(List<Log> logs)
        {
            try
            {
                StringBuilder csv = new StringBuilder();
                
                // Get all users for name lookup
                var allUsers = userBLL.GetAllUsers().ToDictionary(u => u.UserId, u => $"{u.FirstName} {u.LastName} ({u.Username})");
                
                // Add headers
                csv.AppendLine("ID,LogType,UserId,UserName,Description,CreatedAt");
                
                // Add data
                foreach (var log in logs)
                {
                    string userName = "";
                    if (log.UserId.HasValue && allUsers.ContainsKey(log.UserId.Value))
                    {
                        userName = allUsers[log.UserId.Value];
                    }
                    
                    csv.AppendLine($"{log.Id},{EscapeCsvField(log.LogType)},{log.UserId?.ToString() ?? ""},{EscapeCsvField(userName)},{EscapeCsvField(log.Description)},{log.CreatedAt:yyyy-MM-dd HH:mm:ss}");
                }

                // Set response headers for file download
                string fileName = $"logs_export_{DateTime.Now:yyyyMMdd_HHmmss}.csv";
                Response.Clear();
                Response.ContentType = "text/csv";
                Response.AddHeader("Content-Disposition", $"attachment; filename={fileName}");
                Response.Write(csv.ToString());
                Response.End();

                var userId = GetCurrentUserId();
                if (userId.HasValue)
                    adminSecurity.LogAccess(userId.Value, "Exported logs to CSV");
            }
            catch (Exception ex)
            {
                adminSecurity.LogError(GetCurrentUserId(), "CSV export error: " + ex.Message);
                throw;
            }
        }

        private string EscapeCsvField(string field)
        {
            if (string.IsNullOrEmpty(field))
                return "";

            if (field.Contains(",") || field.Contains("\"") || field.Contains("\n") || field.Contains("\r"))
            {
                return "\"" + field.Replace("\"", "\"\"") + "\"";
            }

            return field;
        }

        private int? GetCurrentUserId()
        {
            try
            {
                var userSecurity = new UserSecurity();
                var currentUser = userSecurity.GetCurrentUser();
                return currentUser?.UserId;
            }
            catch
            {
                return null;
            }
        }


        private string GetLocalizedString(string key)
        {
            try
            {
                return HttpContext.GetGlobalResourceObject("GlobalResources", key)?.ToString() ?? key;
            }
            catch
            {
                return key;
            }
        }
    }

    // Template classes for GridView columns
    public class LogTypeTemplate : ITemplate
    {
        public void InstantiateIn(Control container)
        {
            var literal = new Literal();
            literal.DataBinding += (sender, e) =>
            {
                var lit = (Literal)sender;
                var row = (GridViewRow)lit.NamingContainer;
                var log = (Log)row.DataItem;
                if (log != null)
                {
                    var logType = log.LogType?.ToLower() ?? "";
                    var displayLogType = log.LogType ?? "";
                    lit.Text = $"<span class='badge log-type-badge log-{logType}'>{displayLogType}</span>";
                }
            };
            container.Controls.Add(literal);
        }
    }

    public class UserTemplate : ITemplate
    {
        private readonly AdminLogs _page;

        public UserTemplate(AdminLogs page)
        {
            _page = page;
        }

        public void InstantiateIn(Control container)
        {
            var literal = new Literal();
            literal.DataBinding += (sender, e) =>
            {
                var lit = (Literal)sender;
                var row = (GridViewRow)lit.NamingContainer;
                var log = (Log)row.DataItem;
                if (log != null)
                {
                    lit.Text = _page.GetUserDisplayName(log.UserId);
                }
            };
            container.Controls.Add(literal);
        }
    }

    public class DateTimeTemplate : ITemplate
    {
        public void InstantiateIn(Control container)
        {
            var literal = new Literal();
            literal.DataBinding += (sender, e) =>
            {
                var lit = (Literal)sender;
                var row = (GridViewRow)lit.NamingContainer;
                var log = (Log)row.DataItem;
                if (log != null && log.CreatedAt != default)
                {
                    lit.Text = $"<span title='{log.CreatedAt:yyyy-MM-dd HH:mm:ss}'>{log.CreatedAt:MM/dd HH:mm}</span>";
                }
                else
                {
                    lit.Text = "";
                }
            };
            container.Controls.Add(literal);
        }
    }
}