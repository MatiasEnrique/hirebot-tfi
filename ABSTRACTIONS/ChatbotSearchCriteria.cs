using System;

namespace ABSTRACTIONS
{
 
    public class ChatbotSearchCriteria
    {
    
        public string Name { get; set; }
        public int? OrganizationId { get; set; }
        public bool IncludeInactive { get; set; }
        public DateTime? CreatedDateFrom { get; set; }
        public DateTime? CreatedDateTo { get; set; }
        public string Color { get; set; }
        public int PageNumber { get; set; }
        public int PageSize { get; set; }
        public string SortColumn { get; set; }
        public string SortDirection { get; set; }
        public ChatbotSearchCriteria()
        {
            Name = string.Empty;
            OrganizationId = null;
            IncludeInactive = false;
            CreatedDateFrom = null;
            CreatedDateTo = null;
            Color = string.Empty;
            PageNumber = 1;
            PageSize = 10;
            SortColumn = "created_date";
            SortDirection = "DESC";
        }

        public ChatbotSearchCriteria(int pageNumber, int pageSize)
        {
            Name = string.Empty;
            OrganizationId = null;
            IncludeInactive = false;
            CreatedDateFrom = null;
            CreatedDateTo = null;
            Color = string.Empty;
            PageNumber = pageNumber > 0 ? pageNumber : 1;
            PageSize = pageSize > 0 ? Math.Min(pageSize, 100) : 10;
            SortColumn = "created_date";
            SortDirection = "DESC";
        }
        public ChatbotSearchCriteria(int? organizationId, int pageNumber, int pageSize)
        {
            Name = string.Empty;
            OrganizationId = organizationId;
            IncludeInactive = false;
            CreatedDateFrom = null;
            CreatedDateTo = null;
            Color = string.Empty;
            PageNumber = pageNumber > 0 ? pageNumber : 1;
            PageSize = pageSize > 0 ? Math.Min(pageSize, 100) : 10;
            SortColumn = "created_date";
            SortDirection = "DESC";
        }

 
        public void Normalize()
        {
            // Ensure valid pagination values
            if (PageNumber < 1) PageNumber = 1;
            if (PageSize < 1) PageSize = 10;
            if (PageSize > 100) PageSize = 100;

            // Normalize string values
            Name = Name?.Trim() ?? string.Empty;
            Color = Color?.Trim()?.ToUpper() ?? string.Empty;

            // Validate sort column
            var validSortColumns = new[] { "chatbot_id", "name", "created_date", "updated_date", "organization_name" };
            if (string.IsNullOrEmpty(SortColumn) || Array.IndexOf(validSortColumns, SortColumn.ToLower()) == -1)
            {
                SortColumn = "created_date";
            }

            // Validate sort direction
            SortDirection = SortDirection?.ToUpper();
            if (SortDirection != "ASC" && SortDirection != "DESC")
            {
                SortDirection = "DESC";
            }

            // Validate date range
            if (CreatedDateFrom.HasValue && CreatedDateTo.HasValue && CreatedDateFrom > CreatedDateTo)
            {
                var temp = CreatedDateFrom;
                CreatedDateFrom = CreatedDateTo;
                CreatedDateTo = temp;
            }
        }
    }
}