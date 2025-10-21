using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using ABSTRACTIONS;

namespace DAL
{
    /// <summary>
    /// Data Access Layer for Comment operations using stored procedures
    /// Follows the established production-ready patterns with comprehensive error handling
    /// </summary>
    public class CommentDAL
    {
        public CommentDAL()
        {
            // Use the existing DatabaseConnectionService
        }

        /// <summary>
        /// Retrieves all active comments for a specific product with user information
        /// Uses sp_ProductComment_GetByProductId stored procedure with pagination support
        /// </summary>
        /// <param name="productId">Product ID to get comments for</param>
        /// <param name="includePending">Whether to include pending/unapproved comments (admin feature)</param>
        /// <param name="pageNumber">Page number for pagination (default: 1)</param>
        /// <param name="pageSize">Number of comments per page (default: 10)</param>
        /// <returns>DatabaseResult containing list of comments</returns>
        public DatabaseResult<List<Comment>> GetCommentsByProductId(int productId, bool includePending = false, int pageNumber = 1, int pageSize = 10)
        {
            if (productId <= 0)
            {
                return DatabaseResult<List<Comment>>.Failure(-1, "Product ID must be positive");
            }

            try
            {
                List<Comment> comments = new List<Comment>();
                
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ProductComment_GetByProductId", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@ProductId", productId);
                        command.Parameters.AddWithValue("@IncludePending", includePending);
                        command.Parameters.AddWithValue("@PageNumber", pageNumber);
                        command.Parameters.AddWithValue("@PageSize", pageSize);

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                comments.Add(MapCommentFromReader(reader));
                            }
                        }
                    }
                }

                return DatabaseResult<List<Comment>>.Success(comments, $"Retrieved {comments.Count} comments for product {productId}");
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<List<Comment>>.Failure($"Database error retrieving comments: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<List<Comment>>.Failure($"Unexpected error retrieving comments: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Creates a new comment for a product
        /// </summary>
        /// <param name="comment">Comment object to create</param>
        /// <returns>DatabaseResult with operation status and created comment ID</returns>
        public DatabaseResult<Comment> CreateComment(Comment comment)
        {
            if (comment == null)
            {
                return DatabaseResult<Comment>.Failure(-1, "Comment object cannot be null");
            }

            var validationResult = comment.ValidateComment();
            if (!validationResult.IsValid)
            {
                return DatabaseResult<Comment>.Failure(-2, validationResult.GetErrorMessage());
            }

            try
            {
                comment.SanitizeComment();

                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ProductComment_Insert", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        // Input parameters - matches stored procedure signature exactly
                        command.Parameters.AddWithValue("@ProductId", comment.ProductId);
                        command.Parameters.AddWithValue("@UserId", comment.UserId);
                        command.Parameters.AddWithValue("@CommentText", comment.CommentText ?? string.Empty);
                        command.Parameters.AddWithValue("@Rating", (object)comment.Rating ?? DBNull.Value);

                        // Output parameters - matches stored procedure signature
                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);
                        
                        SqlParameter newCommentIdParam = new SqlParameter("@NewCommentId", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(newCommentIdParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";

                        if (resultCode > 0)
                        {
                            comment.CommentId = Convert.ToInt32(newCommentIdParam.Value);
                            return DatabaseResult<Comment>.Success(comment, resultMessage);
                        }
                        else
                        {
                            return DatabaseResult<Comment>.Failure(resultCode, resultMessage);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<Comment>.Failure($"Database error creating comment: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<Comment>.Failure($"Unexpected error creating comment: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Updates an existing comment (only the comment text and rating can be modified)
        /// </summary>
        /// <param name="comment">Comment object with updated information</param>
        /// <param name="modifiedBy">User ID making the modification</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult UpdateComment(Comment comment, int modifiedBy)
        {
            if (comment == null)
            {
                return DatabaseResult.Failure(-1, "Comment object cannot be null");
            }

            if (comment.CommentId <= 0)
            {
                return DatabaseResult.Failure(-2, "Comment ID must be positive");
            }

            if (modifiedBy <= 0)
            {
                return DatabaseResult.Failure(-3, "Modified by user ID must be positive");
            }

            var validationResult = comment.ValidateComment();
            if (!validationResult.IsValid)
            {
                return DatabaseResult.Failure(-4, validationResult.GetErrorMessage());
            }

            try
            {
                comment.SanitizeComment();

                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ProductComment_Update", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        // Input parameters - matches stored procedure signature exactly
                        command.Parameters.AddWithValue("@CommentId", comment.CommentId);
                        command.Parameters.AddWithValue("@UserId", modifiedBy);
                        command.Parameters.AddWithValue("@CommentText", comment.CommentText ?? string.Empty);
                        command.Parameters.AddWithValue("@Rating", (object)comment.Rating ?? DBNull.Value);

                        // Output parameters
                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";

                        if (resultCode > 0)
                        {
                            comment.ModifiedDate = DateTime.Now;
                            return DatabaseResult.Success(resultMessage);
                        }
                        else
                        {
                            return DatabaseResult.Failure(resultCode, resultMessage);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error updating comment: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error updating comment: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Soft deletes a comment by setting IsActive to false
        /// </summary>
        /// <param name="commentId">Comment ID to delete</param>
        /// <param name="deletedBy">User ID performing the deletion</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult DeleteComment(int commentId, int deletedBy)
        {
            if (commentId <= 0)
            {
                return DatabaseResult.Failure(-1, "Comment ID must be positive");
            }

            if (deletedBy <= 0)
            {
                return DatabaseResult.Failure(-2, "Deleted by user ID must be positive");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ProductComment_Delete", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        // Input parameters - matches stored procedure signature exactly
                        command.Parameters.AddWithValue("@CommentId", commentId);
                        command.Parameters.AddWithValue("@UserId", deletedBy);

                        // Output parameters
                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";

                        if (resultCode > 0)
                        {
                            return DatabaseResult.Success(resultMessage);
                        }
                        else
                        {
                            return DatabaseResult.Failure(resultCode, resultMessage);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error deleting comment: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error deleting comment: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Retrieves a specific comment by ID
        /// </summary>
        /// <param name="commentId">Comment ID to retrieve</param>
        /// <returns>DatabaseResult containing comment or error information</returns>
        public DatabaseResult<Comment> GetCommentById(int commentId)
        {
            if (commentId <= 0)
            {
                return DatabaseResult<Comment>.Failure(-1, "Comment ID must be positive");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ProductComment_GetById", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@CommentId", commentId);

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Comment comment = MapCommentFromReader(reader);
                                return DatabaseResult<Comment>.Success(comment, "Comment retrieved successfully");
                            }
                            else
                            {
                                return DatabaseResult<Comment>.Failure(0, "Comment not found");
                            }
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<Comment>.Failure($"Database error retrieving comment: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<Comment>.Failure($"Unexpected error retrieving comment: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Retrieves all comments made by a specific user
        /// </summary>
        /// <param name="userId">User ID to get comments for</param>
        /// <param name="includeInactive">Whether to include inactive comments</param>
        /// <returns>DatabaseResult containing list of comments</returns>
        public DatabaseResult<List<Comment>> GetCommentsByUserId(int userId, bool includeInactive = false)
        {
            if (userId <= 0)
            {
                return DatabaseResult<List<Comment>>.Failure(-1, "User ID must be positive");
            }

            try
            {
                List<Comment> comments = new List<Comment>();
                
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ProductComment_GetUserComments", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@UserId", userId);
                        command.Parameters.AddWithValue("@PageNumber", 1);
                        command.Parameters.AddWithValue("@PageSize", 100); // Get all by default

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                comments.Add(MapCommentFromReader(reader));
                            }
                        }
                    }
                }

                return DatabaseResult<List<Comment>>.Success(comments, $"Retrieved {comments.Count} comments for user {userId}");
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<List<Comment>>.Failure($"Database error retrieving user comments: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<List<Comment>>.Failure($"Unexpected error retrieving user comments: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets comment statistics for a product (total count, average rating)
        /// </summary>
        /// <param name="productId">Product ID to get statistics for</param>
        /// <returns>DatabaseResult containing comment statistics</returns>
        public DatabaseResult<CommentStatistics> GetCommentStatistics(int productId)
        {
            if (productId <= 0)
            {
                return DatabaseResult<CommentStatistics>.Failure(-1, "Product ID must be positive");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ProductComment_GetStatistics", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@ProductId", productId);

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                var statistics = new CommentStatistics
                                {
                                    ProductId = reader["ProductId"] == DBNull.Value ? null : (int?)Convert.ToInt32(reader["ProductId"]),
                                    TotalComments = Convert.ToInt32(reader["TotalComments"]),
                                    ApprovedComments = Convert.ToInt32(reader["ApprovedComments"]),
                                    PendingComments = Convert.ToInt32(reader["PendingComments"]),
                                    CommentsWithRating = Convert.ToInt32(reader["CommentsWithRating"]),
                                    AverageRating = reader["AverageRating"] == DBNull.Value ? null : (decimal?)Convert.ToDecimal(reader["AverageRating"]),
                                    OneStarCount = Convert.ToInt32(reader["OneStarCount"]),
                                    TwoStarCount = Convert.ToInt32(reader["TwoStarCount"]),
                                    ThreeStarCount = Convert.ToInt32(reader["ThreeStarCount"]),
                                    FourStarCount = Convert.ToInt32(reader["FourStarCount"]),
                                    FiveStarCount = Convert.ToInt32(reader["FiveStarCount"]),
                                    FirstCommentDate = reader["FirstCommentDate"] == DBNull.Value ? null : (DateTime?)Convert.ToDateTime(reader["FirstCommentDate"]),
                                    LastCommentDate = reader["LastCommentDate"] == DBNull.Value ? null : (DateTime?)Convert.ToDateTime(reader["LastCommentDate"])
                                };

                                return DatabaseResult<CommentStatistics>.Success(statistics, "Statistics retrieved successfully");
                            }
                            else
                            {
                                return DatabaseResult<CommentStatistics>.Failure(0, "No statistics found for product");
                            }
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<CommentStatistics>.Failure($"Database error retrieving statistics: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<CommentStatistics>.Failure($"Unexpected error retrieving statistics: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Approves or rejects a comment (admin only) - uses sp_ProductComment_Approve
        /// </summary>
        /// <param name="commentId">Comment ID to approve/reject</param>
        /// <param name="adminUserId">Admin user ID performing the action</param>
        /// <param name="isApproved">True to approve, false to reject</param>
        /// <returns>DatabaseResult with operation status</returns>
        public DatabaseResult ApproveComment(int commentId, int adminUserId, bool isApproved)
        {
            if (commentId <= 0)
            {
                return DatabaseResult.Failure(-1, "Comment ID must be positive");
            }

            if (adminUserId <= 0)
            {
                return DatabaseResult.Failure(-2, "Admin user ID must be positive");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ProductComment_Approve", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        // Input parameters - matches stored procedure signature exactly
                        command.Parameters.AddWithValue("@CommentId", commentId);
                        command.Parameters.AddWithValue("@AdminUserId", adminUserId);
                        command.Parameters.AddWithValue("@IsApproved", isApproved);

                        // Output parameters
                        SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultCodeParam);

                        SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(resultMessageParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        int resultCode = Convert.ToInt32(resultCodeParam.Value);
                        string resultMessage = resultMessageParam.Value?.ToString() ?? "Unknown result";

                        if (resultCode > 0)
                        {
                            return DatabaseResult.Success(resultMessage);
                        }
                        else
                        {
                            return DatabaseResult.Failure(resultCode, resultMessage);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure($"Database error approving comment: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error approving comment: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets comments pending approval for moderation (admin only) - uses sp_ProductComment_GetPendingApproval
        /// </summary>
        /// <param name="adminUserId">Admin user ID requesting the list</param>
        /// <param name="pageNumber">Page number for pagination (default: 1)</param>
        /// <param name="pageSize">Number of comments per page (default: 20)</param>
        /// <returns>DatabaseResult containing list of pending comments</returns>
        public DatabaseResult<List<Comment>> GetPendingApprovalComments(int adminUserId, int pageNumber = 1, int pageSize = 20)
        {
            if (adminUserId <= 0)
            {
                return DatabaseResult<List<Comment>>.Failure(-1, "Admin user ID must be positive");
            }

            try
            {
                List<Comment> comments = new List<Comment>();
                
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_ProductComment_GetPendingApproval", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@AdminUserId", adminUserId);
                        command.Parameters.AddWithValue("@PageNumber", pageNumber);
                        command.Parameters.AddWithValue("@PageSize", pageSize);

                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                comments.Add(MapCommentFromReader(reader));
                            }
                        }
                    }
                }

                return DatabaseResult<List<Comment>>.Success(comments, $"Retrieved {comments.Count} pending comments for moderation");
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<List<Comment>>.Failure($"Database error retrieving pending comments: {sqlEx.Message}", sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<List<Comment>>.Failure($"Unexpected error retrieving pending comments: {ex.Message}", ex);
            }
        }

        #region Private Helper Methods

        /// <summary>
        /// Maps a SqlDataReader row to a Comment object
        /// </summary>
        /// <param name="reader">SqlDataReader with comment data</param>
        /// <returns>Comment object</returns>
        private Comment MapCommentFromReader(SqlDataReader reader)
        {
            var comment = new Comment
            {
                CommentId = Convert.ToInt32(reader["CommentId"]),
                ProductId = Convert.ToInt32(reader["ProductId"]),
                UserId = Convert.ToInt32(reader["UserId"]),
                CommentText = reader["CommentText"]?.ToString() ?? string.Empty,
                Rating = reader["Rating"] == DBNull.Value ? null : (byte?)Convert.ToByte(reader["Rating"]),
                CreatedDate = Convert.ToDateTime(reader["CreatedDate"]),
                ModifiedDate = reader["ModifiedDate"] == DBNull.Value ? null : (DateTime?)Convert.ToDateTime(reader["ModifiedDate"]),
                IsActive = Convert.ToBoolean(reader["IsActive"]),
                IsApproved = HasColumn(reader, "IsApproved") ? Convert.ToBoolean(reader["IsApproved"]) : false
            };

            // Handle optional navigation properties
            if (HasColumn(reader, "Username"))
                comment.Username = reader["Username"]?.ToString() ?? string.Empty;

            if (HasColumn(reader, "UserFullName"))
                comment.UserFullName = reader["UserFullName"]?.ToString() ?? string.Empty;
                
            if (HasColumn(reader, "UserEmail"))
                comment.UserEmail = reader["UserEmail"]?.ToString() ?? string.Empty;

            if (HasColumn(reader, "ProductName"))
                comment.ProductName = reader["ProductName"]?.ToString() ?? string.Empty;
                
            if (HasColumn(reader, "ProductDescription"))
                comment.ProductDescription = reader["ProductDescription"]?.ToString() ?? string.Empty;
                
            // Handle pagination properties if available
            if (HasColumn(reader, "TotalComments"))
                comment.TotalComments = reader["TotalComments"] == DBNull.Value ? null : (int?)Convert.ToInt32(reader["TotalComments"]);
                
            if (HasColumn(reader, "TotalPages"))
                comment.TotalPages = reader["TotalPages"] == DBNull.Value ? null : (int?)Convert.ToInt32(reader["TotalPages"]);

            return comment;
        }

        /// <summary>
        /// Checks if a column exists in the SqlDataReader
        /// </summary>
        /// <param name="reader">SqlDataReader to check</param>
        /// <param name="columnName">Column name to look for</param>
        /// <returns>True if column exists</returns>
        private bool HasColumn(SqlDataReader reader, string columnName)
        {
            try
            {
                return reader.GetOrdinal(columnName) >= 0;
            }
            catch (IndexOutOfRangeException)
            {
                return false;
            }
        }

        #endregion
    }

}