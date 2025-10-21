using System.Collections.Generic;

namespace ABSTRACTIONS
{
    /// <summary>
    /// Generic paginated result class for handling paginated data across all layers
    /// </summary>
    /// <typeparam name="T">The type of data being paginated</typeparam>
    public class PaginatedResult<T>
    {
        /// <summary>
        /// The data items for the current page
        /// </summary>
        public List<T> Data { get; set; }

        /// <summary>
        /// Total number of records available
        /// </summary>
        public int TotalRecords { get; set; }

        /// <summary>
        /// Current page number (1-based)
        /// </summary>
        public int CurrentPage { get; set; }

        /// <summary>
        /// Number of items per page
        /// </summary>
        public int PageSize { get; set; }

        /// <summary>
        /// Total number of pages available
        /// </summary>
        public int TotalPages
        {
            get
            {
                if (PageSize <= 0)
                {
                    return 0;
                }

                return (int)System.Math.Ceiling((double)TotalRecords / PageSize);
            }
        }

        /// <summary>
        /// Whether there is a previous page
        /// </summary>
        public bool HasPreviousPage
        {
            get { return CurrentPage > 1; }
        }

        /// <summary>
        /// Whether there is a next page
        /// </summary>
        public bool HasNextPage
        {
            get { return CurrentPage < TotalPages; }
        }

        /// <summary>
        /// Constructor
        /// </summary>
        public PaginatedResult()
        {
            Data = new List<T>();
        }
    }
}