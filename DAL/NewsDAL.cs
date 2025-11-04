using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using ABSTRACTIONS;

namespace DAL
{
    /// <summary>
    /// Data access layer for news article operations.
    /// Wraps stored procedure calls defined under Database/NewsAndNewsletterStoredProcedures.sql.
    /// </summary>
    public class NewsDAL
    {
        public DatabaseResult<NewsArticle> CreateNews(NewsArticle article)
        {
            if (article == null)
            {
                return DatabaseResult<NewsArticle>.Failure(-1, "News article payload cannot be null.");
            }

            article.Sanitize();
            article.EnsureSlug();
            var validation = article.Validate();
            if (!validation.IsValid)
            {
                return DatabaseResult<NewsArticle>.Failure(-2, validation.GetErrorMessage());
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_News_Insert", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@Title", article.Title ?? string.Empty);
                    command.Parameters.AddWithValue("@Slug", (object)article.Slug ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Summary", ToDbValue(article.Summary));
                    command.Parameters.AddWithValue("@Content", article.Content ?? string.Empty);
                    command.Parameters.AddWithValue("@LanguageCode", (object)article.LanguageCode ?? DBNull.Value);
                    command.Parameters.AddWithValue("@HeroImageUrl", ToDbValue(article.HeroImageUrl));
                    command.Parameters.AddWithValue("@PublishedDate", ToDbValue(article.PublishedDate));
                    command.Parameters.AddWithValue("@IsPublished", article.IsPublished);
                    command.Parameters.AddWithValue("@CreatedBy", article.CreatedBy);

                    SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };
                    SqlParameter newIdParam = new SqlParameter("@NewNewsId", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);
                    command.Parameters.Add(newIdParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = resultCodeParam.Value != DBNull.Value ? Convert.ToInt32(resultCodeParam.Value) : 0;
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;
                    int newNewsId = newIdParam.Value != DBNull.Value ? Convert.ToInt32(newIdParam.Value) : 0;

                    if (resultCode == 1 && newNewsId > 0)
                    {
                        var fetchResult = GetNewsById(newNewsId);
                        if (fetchResult.IsSuccessful && fetchResult.Data != null)
                        {
                            return DatabaseResult<NewsArticle>.Success(fetchResult.Data, string.IsNullOrWhiteSpace(resultMessage) ? "News article created successfully." : resultMessage);
                        }

                        article.NewsId = newNewsId;
                        return DatabaseResult<NewsArticle>.Success(article, string.IsNullOrWhiteSpace(resultMessage) ? "News article created successfully." : resultMessage);
                    }

                    return DatabaseResult<NewsArticle>.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Unable to create the news article." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<NewsArticle>.Failure(string.Format("Database error creating news article: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<NewsArticle>.Failure(string.Format("Unexpected error creating news article: {0}", ex.Message), ex);
            }
        }

        public DatabaseResult<NewsArticle> UpdateNews(NewsArticle article)
        {
            if (article == null)
            {
                return DatabaseResult<NewsArticle>.Failure(-1, "News article payload cannot be null.");
            }

            article.Sanitize();
            article.EnsureSlug();
            var validation = article.Validate();
            if (!validation.IsValid)
            {
                return DatabaseResult<NewsArticle>.Failure(-2, validation.GetErrorMessage());
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_News_Update", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@NewsId", article.NewsId);
                    command.Parameters.AddWithValue("@Title", article.Title ?? string.Empty);
                    command.Parameters.AddWithValue("@Slug", (object)article.Slug ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Summary", ToDbValue(article.Summary));
                    command.Parameters.AddWithValue("@Content", article.Content ?? string.Empty);
                    command.Parameters.AddWithValue("@LanguageCode", (object)article.LanguageCode ?? DBNull.Value);
                    command.Parameters.AddWithValue("@HeroImageUrl", ToDbValue(article.HeroImageUrl));
                    command.Parameters.AddWithValue("@PublishedDate", ToDbValue(article.PublishedDate));
                    command.Parameters.AddWithValue("@IsPublished", article.IsPublished);
                    command.Parameters.AddWithValue("@ModifiedBy", article.LastModifiedBy.HasValue ? article.LastModifiedBy.Value : article.CreatedBy);

                    SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = resultCodeParam.Value != DBNull.Value ? Convert.ToInt32(resultCodeParam.Value) : 0;
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;

                    if (resultCode == 1)
                    {
                        var fetchResult = GetNewsById(article.NewsId);
                        if (fetchResult.IsSuccessful && fetchResult.Data != null)
                        {
                            return DatabaseResult<NewsArticle>.Success(fetchResult.Data, string.IsNullOrWhiteSpace(resultMessage) ? "News article updated successfully." : resultMessage);
                        }

                        return DatabaseResult<NewsArticle>.Success(article, string.IsNullOrWhiteSpace(resultMessage) ? "News article updated successfully." : resultMessage);
                    }

                    return DatabaseResult<NewsArticle>.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Unable to update the news article." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<NewsArticle>.Failure(string.Format("Database error updating news article: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<NewsArticle>.Failure(string.Format("Unexpected error updating news article: {0}", ex.Message), ex);
            }
        }

        public DatabaseResult SetPublishStatus(int newsId, bool isPublished, int modifiedBy, DateTime? publishedDate)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_News_SetPublishStatus", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@NewsId", newsId);
                    command.Parameters.AddWithValue("@IsPublished", isPublished);
                    command.Parameters.AddWithValue("@ModifiedBy", modifiedBy);
                    command.Parameters.AddWithValue("@PublishedDate", ToDbValue(publishedDate));

                    SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = resultCodeParam.Value != DBNull.Value ? Convert.ToInt32(resultCodeParam.Value) : 0;
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;

                    if (resultCode == 1)
                    {
                        return DatabaseResult.Success(string.IsNullOrWhiteSpace(resultMessage) ? "Publish status updated." : resultMessage);
                    }

                    return DatabaseResult.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Unable to update publish status." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure(string.Format("Database error updating publish status: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure(string.Format("Unexpected error updating publish status: {0}", ex.Message), ex);
            }
        }

        public DatabaseResult DeleteNews(int newsId, int modifiedBy)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_News_Delete", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@NewsId", newsId);
                    command.Parameters.AddWithValue("@ModifiedBy", modifiedBy);

                    SqlParameter resultCodeParam = new SqlParameter("@ResultCode", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    SqlParameter resultMessageParam = new SqlParameter("@ResultMessage", SqlDbType.NVarChar, 255)
                    {
                        Direction = ParameterDirection.Output
                    };

                    command.Parameters.Add(resultCodeParam);
                    command.Parameters.Add(resultMessageParam);

                    connection.Open();
                    command.ExecuteNonQuery();

                    int resultCode = resultCodeParam.Value != DBNull.Value ? Convert.ToInt32(resultCodeParam.Value) : 0;
                    string resultMessage = resultMessageParam.Value as string ?? string.Empty;

                    if (resultCode == 1)
                    {
                        return DatabaseResult.Success(string.IsNullOrWhiteSpace(resultMessage) ? "News article archived successfully." : resultMessage);
                    }

                    return DatabaseResult.Failure(resultCode, string.IsNullOrWhiteSpace(resultMessage) ? "Unable to archive news article." : resultMessage);
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure(string.Format("Database error archiving news article: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure(string.Format("Unexpected error archiving news article: {0}", ex.Message), ex);
            }
        }

        public DatabaseResult<NewsArticle> GetNewsById(int newsId)
        {
            if (newsId <= 0)
            {
                return DatabaseResult<NewsArticle>.Failure(-1, "NewsId must be greater than zero.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_News_GetById", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@NewsId", newsId);

                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            var article = MapNewsArticle(reader);
                            return DatabaseResult<NewsArticle>.Success(article, "News article retrieved successfully.");
                        }
                    }
                }

                return DatabaseResult<NewsArticle>.Failure(-2, "News article not found.");
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<NewsArticle>.Failure(string.Format("Database error retrieving news article: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<NewsArticle>.Failure(string.Format("Unexpected error retrieving news article: {0}", ex.Message), ex);
            }
        }

        public DatabaseResult<List<NewsArticle>> SearchNews(NewsSearchCriteria criteria)
        {
            criteria = criteria ?? new NewsSearchCriteria();
            criteria.Normalize();

            List<NewsArticle> articles = new List<NewsArticle>();
            int totalRecords = 0;

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_News_Search", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SearchTerm", ToDbValue(criteria.SearchTerm));
                    command.Parameters.AddWithValue("@LanguageCode", ToDbValue(criteria.LanguageCode));
                    command.Parameters.AddWithValue("@IncludeUnpublished", criteria.IncludeUnpublished);
                    command.Parameters.AddWithValue("@IncludeArchived", criteria.IncludeArchived);
                    command.Parameters.AddWithValue("@PageNumber", criteria.PageNumber);
                    command.Parameters.AddWithValue("@PageSize", criteria.PageSize);
                    command.Parameters.AddWithValue("@SortColumn", criteria.SortColumn);
                    command.Parameters.AddWithValue("@SortDirection", criteria.SortDirection);
                    command.Parameters.AddWithValue("@StartDate", ToDbValue(criteria.StartDate));
                    command.Parameters.AddWithValue("@EndDate", ToDbValue(criteria.EndDate));
                    command.Parameters.AddWithValue("@StatusFilter", criteria.StatusFilter ?? "All");

                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var article = MapNewsArticle(reader);
                            if (article.TotalRecords.HasValue)
                            {
                                totalRecords = article.TotalRecords.Value;
                            }
                            articles.Add(article);
                        }
                    }
                }

                return DatabaseResult<List<NewsArticle>>.Success(articles, string.Format("Retrieved {0} news article(s).", articles.Count));
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<List<NewsArticle>>.Failure(string.Format("Database error searching news articles: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<List<NewsArticle>>.Failure(string.Format("Unexpected error searching news articles: {0}", ex.Message), ex);
            }
        }

        public DatabaseResult<List<NewsArticle>> GetLatestNews(int topCount, string languageCode = null)
        {
            if (topCount <= 0)
            {
                topCount = 5;
            }

            List<NewsArticle> articles = new List<NewsArticle>();

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_News_GetLatest", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TopCount", topCount);
                    command.Parameters.AddWithValue("@LanguageCode", ToDbValue(languageCode));

                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            articles.Add(MapNewsArticle(reader));
                        }
                    }
                }

                return DatabaseResult<List<NewsArticle>>.Success(articles, string.Format("Retrieved {0} latest news articles.", articles.Count));
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult<List<NewsArticle>>.Failure(string.Format("Database error retrieving latest news: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult<List<NewsArticle>>.Failure(string.Format("Unexpected error retrieving latest news: {0}", ex.Message), ex);
            }
        }

        public DatabaseResult IncrementViewCount(int newsId)
        {
            if (newsId <= 0)
            {
                return DatabaseResult.Failure(-1, "NewsId must be greater than zero.");
            }

            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                using (SqlCommand command = new SqlCommand("sp_News_IncrementViewCount", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@NewsId", newsId);

                    connection.Open();
                    int affected = command.ExecuteNonQuery();

                    if (affected > 0)
                    {
                        return DatabaseResult.Success("View count updated.");
                    }

                    return DatabaseResult.Failure(-2, "News article not found.");
                }
            }
            catch (SqlException sqlEx)
            {
                return DatabaseResult.Failure(string.Format("Database error updating view count: {0}", sqlEx.Message), sqlEx);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure(string.Format("Unexpected error updating view count: {0}", ex.Message), ex);
            }
        }

        private NewsArticle MapNewsArticle(SqlDataReader reader)
        {
            var article = new NewsArticle
            {
                NewsId = reader.GetInt32(reader.GetOrdinal("NewsId")),
                Title = reader["Title"] as string ?? string.Empty,
                Slug = reader["Slug"] as string ?? string.Empty,
                Summary = reader["Summary"] as string,
                Content = reader["Content"] as string ?? string.Empty,
                LanguageCode = reader["LanguageCode"] as string ?? "es",
                HeroImageUrl = reader["HeroImageUrl"] as string,
                CreatedBy = reader["CreatedBy"] != DBNull.Value ? Convert.ToInt32(reader["CreatedBy"]) : 0,
                CreatedDate = reader["CreatedDate"] != DBNull.Value ? Convert.ToDateTime(reader["CreatedDate"]) : DateTime.MinValue,
                LastModifiedBy = reader["LastModifiedBy"] != DBNull.Value ? (int?)Convert.ToInt32(reader["LastModifiedBy"]) : null,
                LastModifiedDate = reader["LastModifiedDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(reader["LastModifiedDate"]) : null,
                PublishedDate = reader["PublishedDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(reader["PublishedDate"]) : null,
                IsPublished = reader["IsPublished"] != DBNull.Value && Convert.ToBoolean(reader["IsPublished"]),
                IsArchived = reader["IsArchived"] != DBNull.Value && Convert.ToBoolean(reader["IsArchived"]),
                ViewCount = reader["ViewCount"] != DBNull.Value ? Convert.ToInt32(reader["ViewCount"]) : 0,
                CreatedByUsername = HasColumn(reader, "CreatedByUsername") ? reader["CreatedByUsername"] as string : null,
                CreatedByFullName = HasColumn(reader, "CreatedByFullName") ? reader["CreatedByFullName"] as string : null,
                ModifiedByUsername = HasColumn(reader, "ModifiedByUsername") ? reader["ModifiedByUsername"] as string : null,
                ModifiedByFullName = HasColumn(reader, "ModifiedByFullName") ? reader["ModifiedByFullName"] as string : null,
                TotalRecords = HasColumn(reader, "TotalRecords") && reader["TotalRecords"] != DBNull.Value ? (int?)Convert.ToInt32(reader["TotalRecords"]) : null
            };

            return article;
        }
        private static bool HasColumn(SqlDataReader reader, string columnName)
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

        private static object ToDbValue(object value)
        {
            return value ?? DBNull.Value;
        }
    }
}






