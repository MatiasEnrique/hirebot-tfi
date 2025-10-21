-- =============================================
-- News and Newsletter Management - SQL Server Stored Procedures
-- Author: Codex (GPT-5)
-- Create date: 2025-09-21
-- Description: Table definitions and stored procedures for news publishing and newsletter subscriptions.
-- =============================================

-- =============================================
-- TABLE CREATION SCRIPTS
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'NewsArticles')
BEGIN
    CREATE TABLE [dbo].[NewsArticles]
    (
        [NewsId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Title] NVARCHAR(200) NOT NULL,
        [Slug] NVARCHAR(200) NOT NULL,
        [Summary] NVARCHAR(500) NULL,
        [Content] NVARCHAR(MAX) NOT NULL,
        [LanguageCode] NVARCHAR(5) NOT NULL DEFAULT 'es',
        [HeroImageUrl] NVARCHAR(512) NULL,
        [CreatedBy] INT NOT NULL,
        [CreatedDate] DATETIME NOT NULL DEFAULT GETUTCDATE(),
        [LastModifiedBy] INT NULL,
        [LastModifiedDate] DATETIME NULL,
        [PublishedDate] DATETIME NULL,
        [IsPublished] BIT NOT NULL DEFAULT 0,
        [IsArchived] BIT NOT NULL DEFAULT 0,
        [ViewCount] INT NOT NULL DEFAULT 0
    );

    ALTER TABLE [dbo].[NewsArticles]
        ADD CONSTRAINT [UQ_NewsArticles_Slug] UNIQUE ([Slug]);

    ALTER TABLE [dbo].[NewsArticles]
        ADD CONSTRAINT [FK_NewsArticles_Users_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users]([UserId]);

    ALTER TABLE [dbo].[NewsArticles]
        ADD CONSTRAINT [FK_NewsArticles_Users_LastModifiedBy] FOREIGN KEY ([LastModifiedBy]) REFERENCES [dbo].[Users]([UserId]);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_NewsArticles_IsPublished_PublishedDate')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_NewsArticles_IsPublished_PublishedDate]
        ON [dbo].[NewsArticles] ([IsPublished], [IsArchived], [PublishedDate] DESC);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_NewsArticles_PublishedDate')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_NewsArticles_PublishedDate]
        ON [dbo].[NewsArticles] ([PublishedDate] DESC);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_NewsArticles_Language')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_NewsArticles_Language]
        ON [dbo].[NewsArticles] ([LanguageCode], [IsPublished], [IsArchived]);
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'NewsletterSubscriptions')
BEGIN
    CREATE TABLE [dbo].[NewsletterSubscriptions]
    (
        [SubscriptionId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Email] NVARCHAR(256) NOT NULL,
        [EmailNormalized] NVARCHAR(256) NOT NULL,
        [LanguageCode] NVARCHAR(5) NOT NULL DEFAULT 'es',
        [IsActive] BIT NOT NULL DEFAULT 1,
        [IsConfirmed] BIT NOT NULL DEFAULT 1,
        [CreatedDate] DATETIME NOT NULL DEFAULT GETUTCDATE(),
        [ConfirmedDate] DATETIME NULL,
        [UnsubscribedDate] DATETIME NULL,
        [ConfirmationToken] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        [LastUpdatedDate] DATETIME NOT NULL DEFAULT GETUTCDATE()
    );

    CREATE UNIQUE INDEX [UX_NewsletterSubscriptions_EmailNormalized]
        ON [dbo].[NewsletterSubscriptions] ([EmailNormalized]);
END
GO

-- =============================================
-- NEWS STORED PROCEDURES
-- =============================================

IF OBJECT_ID(N'[dbo].[sp_News_Insert]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_News_Insert];
GO

CREATE PROCEDURE [dbo].[sp_News_Insert]
    @Title NVARCHAR(200),
    @Slug NVARCHAR(200) = NULL,
    @Summary NVARCHAR(500) = NULL,
    @Content NVARCHAR(MAX),
    @LanguageCode NVARCHAR(5) = 'es',
    @HeroImageUrl NVARCHAR(512) = NULL,
    @PublishedDate DATETIME = NULL,
    @IsPublished BIT = 0,
    @CreatedBy INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT,
    @NewNewsId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @ResultCode = 0;
    SET @ResultMessage = 'Success';
    SET @NewNewsId = 0;

    IF (@Title IS NULL OR LTRIM(RTRIM(@Title)) = '')
    BEGIN
        SET @ResultCode = -1;
        SET @ResultMessage = 'Title is required.';
        RETURN;
    END

    IF (@Content IS NULL OR LTRIM(RTRIM(@Content)) = '')
    BEGIN
        SET @ResultCode = -2;
        SET @ResultMessage = 'Content is required.';
        RETURN;
    END

    IF (@CreatedBy IS NULL OR @CreatedBy <= 0)
    BEGIN
        SET @ResultCode = -3;
        SET @ResultMessage = 'CreatedBy is required.';
        RETURN;
    END

    DECLARE @Now DATETIME = GETUTCDATE();
    DECLARE @SlugInput NVARCHAR(200) = COALESCE(NULLIF(LTRIM(RTRIM(@Slug)), ''), LTRIM(RTRIM(@Title)));
    DECLARE @SlugValue NVARCHAR(200) = LOWER(@SlugInput);
    DECLARE @SlugBase NVARCHAR(200);

    -- Basic slug normalization
    SET @SlugValue = REPLACE(@SlugValue, ' ', '-');
    SET @SlugValue = REPLACE(@SlugValue, '/', '-');
    SET @SlugValue = REPLACE(@SlugValue, '\\', '-');
    SET @SlugValue = REPLACE(@SlugValue, '--', '-');
    SET @SlugValue = REPLACE(@SlugValue, '--', '-');
    SET @SlugValue = REPLACE(@SlugValue, '''', '');
    SET @SlugValue = REPLACE(@SlugValue, '"', '');
    SET @SlugValue = REPLACE(@SlugValue, ',', '');
    SET @SlugValue = REPLACE(@SlugValue, '.', '');
    SET @SlugValue = REPLACE(@SlugValue, ';', '');
    SET @SlugBase = @SlugValue;

    IF (LEN(@SlugValue) = 0)
    BEGIN
        SET @SlugValue = CONCAT('news-', CONVERT(NVARCHAR(36), NEWID()));
        SET @SlugBase = @SlugValue;
    END

    DECLARE @Counter INT = 2;
    WHILE EXISTS (SELECT 1 FROM [dbo].[NewsArticles] WHERE Slug = @SlugValue)
    BEGIN
        SET @SlugValue = LEFT(@SlugBase + '-' + CAST(@Counter AS NVARCHAR(10)), 200);
        SET @Counter = @Counter + 1;
    END

    DECLARE @FinalPublishedDate DATETIME = NULL;
    IF (@IsPublished = 1)
    BEGIN
        SET @FinalPublishedDate = ISNULL(@PublishedDate, @Now);
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[NewsArticles]
        (
            [Title],
            [Slug],
            [Summary],
            [Content],
            [LanguageCode],
            [HeroImageUrl],
            [CreatedBy],
            [CreatedDate],
            [PublishedDate],
            [IsPublished],
            [IsArchived]
        )
        VALUES
        (
            @Title,
            @SlugValue,
            @Summary,
            @Content,
            @LanguageCode,
            @HeroImageUrl,
            @CreatedBy,
            @Now,
            @FinalPublishedDate,
            @IsPublished,
            0
        );

        SET @NewNewsId = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SET @ResultCode = 1;
        SET @ResultMessage = 'News article created successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ResultCode = -50001;
        SET @ResultMessage = CONCAT('Error inserting news: ', ERROR_MESSAGE());
    END CATCH
END
GO

IF OBJECT_ID(N'[dbo].[sp_News_Update]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_News_Update];
GO

CREATE PROCEDURE [dbo].[sp_News_Update]
    @NewsId INT,
    @Title NVARCHAR(200),
    @Slug NVARCHAR(200),
    @Summary NVARCHAR(500) = NULL,
    @Content NVARCHAR(MAX),
    @LanguageCode NVARCHAR(5) = 'es',
    @HeroImageUrl NVARCHAR(512) = NULL,
    @PublishedDate DATETIME = NULL,
    @IsPublished BIT = 0,
    @ModifiedBy INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @ResultCode = 0;
    SET @ResultMessage = 'Success';

    IF (@NewsId IS NULL OR @NewsId <= 0)
    BEGIN
        SET @ResultCode = -1;
        SET @ResultMessage = 'NewsId is required.';
        RETURN;
    END

    IF (@Title IS NULL OR LTRIM(RTRIM(@Title)) = '')
    BEGIN
        SET @ResultCode = -2;
        SET @ResultMessage = 'Title is required.';
        RETURN;
    END

    IF (@Content IS NULL OR LTRIM(RTRIM(@Content)) = '')
    BEGIN
        SET @ResultCode = -3;
        SET @ResultMessage = 'Content is required.';
        RETURN;
    END

    IF (@ModifiedBy IS NULL OR @ModifiedBy <= 0)
    BEGIN
        SET @ResultCode = -4;
        SET @ResultMessage = 'ModifiedBy is required.';
        RETURN;
    END

    DECLARE @Now DATETIME = GETUTCDATE();
    DECLARE @SlugInput NVARCHAR(200) = COALESCE(NULLIF(LTRIM(RTRIM(@Slug)), ''), LTRIM(RTRIM(@Title)));
    DECLARE @SlugValue NVARCHAR(200) = LOWER(@SlugInput);
    DECLARE @SlugBase NVARCHAR(200);

    SET @SlugValue = REPLACE(@SlugValue, ' ', '-');
    SET @SlugValue = REPLACE(@SlugValue, '/', '-');
    SET @SlugValue = REPLACE(@SlugValue, '\\', '-');
    SET @SlugValue = REPLACE(@SlugValue, '--', '-');
    SET @SlugValue = REPLACE(@SlugValue, '--', '-');
    SET @SlugValue = REPLACE(@SlugValue, '''', '');
    SET @SlugValue = REPLACE(@SlugValue, '"', '');
    SET @SlugValue = REPLACE(@SlugValue, ',', '');
    SET @SlugValue = REPLACE(@SlugValue, '.', '');
    SET @SlugValue = REPLACE(@SlugValue, ';', '');
    SET @SlugBase = @SlugValue;

    IF (LEN(@SlugValue) = 0)
    BEGIN
        SET @SlugValue = CONCAT('news-', CONVERT(NVARCHAR(36), NEWID()));
        SET @SlugBase = @SlugValue;
    END

    DECLARE @Counter INT = 2;
    WHILE EXISTS (SELECT 1 FROM [dbo].[NewsArticles] WHERE Slug = @SlugValue AND NewsId <> @NewsId)
    BEGIN
        SET @SlugValue = LEFT(@SlugBase + '-' + CAST(@Counter AS NVARCHAR(10)), 200);
        SET @Counter = @Counter + 1;
    END

    DECLARE @FinalPublishedDate DATETIME = NULL;
    IF (@IsPublished = 1)
    BEGIN
        SET @FinalPublishedDate = ISNULL(@PublishedDate, @Now);
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [dbo].[NewsArticles]
        SET
            [Title] = @Title,
            [Slug] = @SlugValue,
            [Summary] = @Summary,
            [Content] = @Content,
            [LanguageCode] = @LanguageCode,
            [HeroImageUrl] = @HeroImageUrl,
            [LastModifiedBy] = @ModifiedBy,
            [LastModifiedDate] = @Now,
            [PublishedDate] = CASE WHEN @IsPublished = 1 THEN @FinalPublishedDate ELSE NULL END,
            [IsPublished] = @IsPublished
        WHERE [NewsId] = @NewsId AND [IsArchived] = 0;

        IF (@@ROWCOUNT = 0)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @ResultCode = -5;
            SET @ResultMessage = 'News article not found or archived.';
            RETURN;
        END

        COMMIT TRANSACTION;

        SET @ResultCode = 1;
        SET @ResultMessage = 'News article updated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ResultCode = -50002;
        SET @ResultMessage = CONCAT('Error updating news: ', ERROR_MESSAGE());
    END CATCH
END
GO

IF OBJECT_ID(N'[dbo].[sp_News_SetPublishStatus]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_News_SetPublishStatus];
GO

CREATE PROCEDURE [dbo].[sp_News_SetPublishStatus]
    @NewsId INT,
    @IsPublished BIT,
    @ModifiedBy INT,
    @PublishedDate DATETIME = NULL,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @ResultCode = 0;
    SET @ResultMessage = 'Success';

    IF (@NewsId IS NULL OR @NewsId <= 0)
    BEGIN
        SET @ResultCode = -1;
        SET @ResultMessage = 'NewsId is required.';
        RETURN;
    END

    IF (@ModifiedBy IS NULL OR @ModifiedBy <= 0)
    BEGIN
        SET @ResultCode = -2;
        SET @ResultMessage = 'ModifiedBy is required.';
        RETURN;
    END

    DECLARE @Now DATETIME = GETUTCDATE();
    DECLARE @FinalPublishedDate DATETIME = NULL;

    IF (@IsPublished = 1)
        SET @FinalPublishedDate = ISNULL(@PublishedDate, @Now);

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [dbo].[NewsArticles]
        SET
            [IsPublished] = @IsPublished,
            [PublishedDate] = CASE WHEN @IsPublished = 1 THEN @FinalPublishedDate ELSE NULL END,
            [LastModifiedBy] = @ModifiedBy,
            [LastModifiedDate] = @Now
        WHERE [NewsId] = @NewsId AND [IsArchived] = 0;

        IF (@@ROWCOUNT = 0)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @ResultCode = -3;
            SET @ResultMessage = 'News article not found or archived.';
            RETURN;
        END

        COMMIT TRANSACTION;

        SET @ResultCode = 1;
        SET @ResultMessage = CASE WHEN @IsPublished = 1 THEN 'News article published.' ELSE 'News article unpublished.' END;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ResultCode = -50003;
        SET @ResultMessage = CONCAT('Error updating publish status: ', ERROR_MESSAGE());
    END CATCH
END
GO

IF OBJECT_ID(N'[dbo].[sp_News_Delete]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_News_Delete];
GO

CREATE PROCEDURE [dbo].[sp_News_Delete]
    @NewsId INT,
    @ModifiedBy INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @ResultCode = 0;
    SET @ResultMessage = 'Success';

    IF (@NewsId IS NULL OR @NewsId <= 0)
    BEGIN
        SET @ResultCode = -1;
        SET @ResultMessage = 'NewsId is required.';
        RETURN;
    END

    IF (@ModifiedBy IS NULL OR @ModifiedBy <= 0)
    BEGIN
        SET @ResultCode = -2;
        SET @ResultMessage = 'ModifiedBy is required.';
        RETURN;
    END

    DECLARE @Now DATETIME = GETUTCDATE();

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [dbo].[NewsArticles]
        SET
            [IsArchived] = 1,
            [IsPublished] = 0,
            [PublishedDate] = NULL,
            [LastModifiedBy] = @ModifiedBy,
            [LastModifiedDate] = @Now
        WHERE [NewsId] = @NewsId AND [IsArchived] = 0;

        IF (@@ROWCOUNT = 0)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @ResultCode = -3;
            SET @ResultMessage = 'News article not found or already archived.';
            RETURN;
        END

        COMMIT TRANSACTION;

        SET @ResultCode = 1;
        SET @ResultMessage = 'News article archived successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ResultCode = -50004;
        SET @ResultMessage = CONCAT('Error archiving news: ', ERROR_MESSAGE());
    END CATCH
END
GO

IF OBJECT_ID(N'[dbo].[sp_News_GetById]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_News_GetById];
GO

CREATE PROCEDURE [dbo].[sp_News_GetById]
    @NewsId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        n.[NewsId],
        n.[Title],
        n.[Slug],
        n.[Summary],
        n.[Content],
        n.[LanguageCode],
        n.[HeroImageUrl],
        n.[CreatedBy],
        n.[CreatedDate],
        n.[LastModifiedBy],
        n.[LastModifiedDate],
        n.[PublishedDate],
        n.[IsPublished],
        n.[IsArchived],
        n.[ViewCount],
        u.Username AS CreatedByUsername,
        COALESCE(
            NULLIF(LTRIM(RTRIM(CONCAT(
                NULLIF(LTRIM(RTRIM(u.FirstName)), ''),
                CASE
                    WHEN NULLIF(LTRIM(RTRIM(u.FirstName)), '') IS NOT NULL
                         AND NULLIF(LTRIM(RTRIM(u.LastName)), '') IS NOT NULL THEN ' '
                    ELSE ''
                END,
                NULLIF(LTRIM(RTRIM(u.LastName)), '')
            ))), ''),
            NULLIF(LTRIM(RTRIM(u.Username)), ''),
            'Unknown'
        ) AS CreatedByFullName,
        mu.Username AS ModifiedByUsername,
        COALESCE(
            NULLIF(LTRIM(RTRIM(CONCAT(
                NULLIF(LTRIM(RTRIM(mu.FirstName)), ''),
                CASE
                    WHEN NULLIF(LTRIM(RTRIM(mu.FirstName)), '') IS NOT NULL
                         AND NULLIF(LTRIM(RTRIM(mu.LastName)), '') IS NOT NULL THEN ' '
                    ELSE ''
                END,
                NULLIF(LTRIM(RTRIM(mu.LastName)), '')
            ))), ''),
            NULLIF(LTRIM(RTRIM(mu.Username)), ''),
            'Unknown'
        ) AS ModifiedByFullName
    FROM [dbo].[NewsArticles] n
    LEFT JOIN [dbo].[Users] u ON n.[CreatedBy] = u.[UserId]
    LEFT JOIN [dbo].[Users] mu ON n.[LastModifiedBy] = mu.[UserId]
    WHERE n.[NewsId] = @NewsId;
END
GO

IF OBJECT_ID(N'[dbo].[sp_News_Search]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_News_Search];
GO

CREATE PROCEDURE [dbo].[sp_News_Search]
    @SearchTerm NVARCHAR(200) = NULL,
    @LanguageCode NVARCHAR(5) = NULL,
    @IncludeUnpublished BIT = 0,
    @IncludeArchived BIT = 0,
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(50) = 'PublishedDate',
    @SortDirection NVARCHAR(4) = 'DESC',
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StatusFilter NVARCHAR(20) = 'All'
AS
BEGIN
    SET NOCOUNT ON;

    IF (@PageNumber IS NULL OR @PageNumber < 1) SET @PageNumber = 1;
    IF (@PageSize IS NULL OR @PageSize < 1) SET @PageSize = 10;
    IF (@PageSize > 100) SET @PageSize = 100;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    WITH FilteredNews AS
    (
        SELECT
            n.[NewsId],
            n.[Title],
            n.[Slug],
            n.[Summary],
            n.[Content],
            n.[LanguageCode],
            n.[HeroImageUrl],
            n.[CreatedBy],
            n.[CreatedDate],
            n.[LastModifiedBy],
            n.[LastModifiedDate],
            n.[PublishedDate],
            n.[IsPublished],
            n.[IsArchived],
            n.[ViewCount],
            ROW_NUMBER() OVER (
                ORDER BY
                    CASE WHEN @SortColumn = 'Title' AND @SortDirection = 'ASC' THEN n.[Title] END ASC,
                    CASE WHEN @SortColumn = 'Title' AND @SortDirection = 'DESC' THEN n.[Title] END DESC,
                    CASE WHEN @SortColumn = 'CreatedDate' AND @SortDirection = 'ASC' THEN n.[CreatedDate] END ASC,
                    CASE WHEN @SortColumn = 'CreatedDate' AND @SortDirection = 'DESC' THEN n.[CreatedDate] END DESC,
                    CASE WHEN @SortColumn = 'PublishedDate' AND @SortDirection = 'ASC' THEN n.[PublishedDate] END ASC,
                    CASE WHEN @SortColumn = 'PublishedDate' AND @SortDirection = 'DESC' THEN n.[PublishedDate] END DESC,
                    n.[NewsId] DESC
            ) AS RowNum,
            COUNT(1) OVER() AS TotalRecords
        FROM [dbo].[NewsArticles] n
        WHERE
            (@IncludeUnpublished = 1 OR n.[IsPublished] = 1)
            AND (@IncludeArchived = 1 OR n.[IsArchived] = 0)
            AND (
                @StatusFilter IS NULL OR
                UPPER(@StatusFilter) = 'ALL' OR
                (UPPER(@StatusFilter) = 'PUBLISHED' AND n.[IsPublished] = 1 AND n.[IsArchived] = 0) OR
                (UPPER(@StatusFilter) = 'UNPUBLISHED' AND n.[IsPublished] = 0 AND n.[IsArchived] = 0) OR
                (UPPER(@StatusFilter) = 'ARCHIVED' AND n.[IsArchived] = 1)
            )
            AND (@LanguageCode IS NULL OR n.[LanguageCode] = @LanguageCode)
            AND (
                    @SearchTerm IS NULL OR
                    n.[Title] LIKE '%' + @SearchTerm + '%' OR
                    n.[Summary] LIKE '%' + @SearchTerm + '%' OR
                    n.[Content] LIKE '%' + @SearchTerm + '%'
                )
            AND (
                    @StartDate IS NULL OR
                    (n.[PublishedDate] IS NOT NULL AND n.[PublishedDate] >= @StartDate) OR
                    (n.[PublishedDate] IS NULL AND n.[CreatedDate] >= @StartDate)
                )
            AND (
                    @EndDate IS NULL OR
                    (n.[PublishedDate] IS NOT NULL AND n.[PublishedDate] <= @EndDate) OR
                    (n.[PublishedDate] IS NULL AND n.[CreatedDate] <= @EndDate)
                )
    )
    SELECT
        f.[NewsId],
        f.[Title],
        f.[Slug],
        f.[Summary],
        f.[Content],
        f.[LanguageCode],
        f.[HeroImageUrl],
        f.[CreatedBy],
        f.[CreatedDate],
        f.[LastModifiedBy],
        f.[LastModifiedDate],
        f.[PublishedDate],
        f.[IsPublished],
        f.[IsArchived],
        f.[ViewCount],
        f.[TotalRecords]
    FROM FilteredNews f
    WHERE f.RowNum > @Offset AND f.RowNum <= (@Offset + @PageSize)
    ORDER BY f.RowNum;
END
GO

IF OBJECT_ID(N'[dbo].[sp_News_GetLatest]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_News_GetLatest];
GO

CREATE PROCEDURE [dbo].[sp_News_GetLatest]
    @TopCount INT = 5,
    @LanguageCode NVARCHAR(5) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF (@TopCount IS NULL OR @TopCount < 1) SET @TopCount = 5;
    IF (@TopCount > 50) SET @TopCount = 50;

    SELECT TOP (@TopCount)
        n.[NewsId],
        n.[Title],
        n.[Slug],
        n.[Summary],
        n.[Content],
        n.[LanguageCode],
        n.[HeroImageUrl],
        n.[CreatedBy],
        n.[CreatedDate],
        n.[LastModifiedBy],
        n.[LastModifiedDate],
        n.[PublishedDate],
        n.[IsPublished],
        n.[IsArchived],
        n.[ViewCount]
    FROM [dbo].[NewsArticles] n
    WHERE n.[IsPublished] = 1 AND n.[IsArchived] = 0
        AND (@LanguageCode IS NULL OR n.[LanguageCode] = @LanguageCode)
    ORDER BY n.[PublishedDate] DESC, n.[NewsId] DESC;
END
GO

IF OBJECT_ID(N'[dbo].[sp_News_IncrementViewCount]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_News_IncrementViewCount];
GO

CREATE PROCEDURE [dbo].[sp_News_IncrementViewCount]
    @NewsId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[NewsArticles]
    SET [ViewCount] = [ViewCount] + 1
    WHERE [NewsId] = @NewsId;
END
GO

-- =============================================
-- NEWSLETTER STORED PROCEDURES
-- =============================================

IF OBJECT_ID(N'[dbo].[sp_Newsletter_Subscribe]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_Newsletter_Subscribe];
GO

CREATE PROCEDURE [dbo].[sp_Newsletter_Subscribe]
    @Email NVARCHAR(256),
    @LanguageCode NVARCHAR(5) = 'es',
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT,
    @SubscriptionId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @ResultCode = 0;
    SET @ResultMessage = 'Success';
    SET @SubscriptionId = 0;

    IF (@Email IS NULL OR LTRIM(RTRIM(@Email)) = '')
    BEGIN
        SET @ResultCode = -1;
        SET @ResultMessage = 'Email is required.';
        RETURN;
    END

    DECLARE @EmailNormalized NVARCHAR(256) = UPPER(LTRIM(RTRIM(@Email)));
    DECLARE @Now DATETIME = GETUTCDATE();

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ExistingId INT;
        DECLARE @IsActive BIT;

        SELECT @ExistingId = [SubscriptionId], @IsActive = [IsActive]
        FROM [dbo].[NewsletterSubscriptions]
        WHERE [EmailNormalized] = @EmailNormalized;

        IF (@ExistingId IS NULL)
        BEGIN
            INSERT INTO [dbo].[NewsletterSubscriptions]
            (
                [Email],
                [EmailNormalized],
                [LanguageCode],
                [IsActive],
                [IsConfirmed],
                [CreatedDate],
                [ConfirmedDate],
                [LastUpdatedDate]
            )
            VALUES
            (
                @Email,
                @EmailNormalized,
                @LanguageCode,
                1,
                1,
                @Now,
                @Now,
                @Now
            );

            SET @SubscriptionId = SCOPE_IDENTITY();
            SET @ResultCode = 1;
            SET @ResultMessage = 'Subscription created successfully.';
        END
        ELSE IF (@IsActive = 0)
        BEGIN
            UPDATE [dbo].[NewsletterSubscriptions]
            SET [IsActive] = 1,
                [LanguageCode] = @LanguageCode,
                [IsConfirmed] = 1,
                [UnsubscribedDate] = NULL,
                [ConfirmedDate] = @Now,
                [LastUpdatedDate] = @Now
            WHERE [SubscriptionId] = @ExistingId;

            SET @SubscriptionId = @ExistingId;
            SET @ResultCode = 2;
            SET @ResultMessage = 'Subscription reactivated successfully.';
        END
        ELSE
        BEGIN
            UPDATE [dbo].[NewsletterSubscriptions]
            SET [LanguageCode] = @LanguageCode,
                [LastUpdatedDate] = @Now
            WHERE [SubscriptionId] = @ExistingId;

            SET @SubscriptionId = @ExistingId;
            SET @ResultCode = 3;
            SET @ResultMessage = 'Email is already subscribed.';
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ResultCode = -50011;
        SET @ResultMessage = CONCAT('Error subscribing email: ', ERROR_MESSAGE());
    END CATCH
END
GO

IF OBJECT_ID(N'[dbo].[sp_Newsletter_Unsubscribe]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_Newsletter_Unsubscribe];
GO

CREATE PROCEDURE [dbo].[sp_Newsletter_Unsubscribe]
    @Email NVARCHAR(256),
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @ResultCode = 0;
    SET @ResultMessage = 'Success';

    IF (@Email IS NULL OR LTRIM(RTRIM(@Email)) = '')
    BEGIN
        SET @ResultCode = -1;
        SET @ResultMessage = 'Email is required.';
        RETURN;
    END

    DECLARE @EmailNormalized NVARCHAR(256) = UPPER(LTRIM(RTRIM(@Email)));
    DECLARE @Now DATETIME = GETUTCDATE();

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [dbo].[NewsletterSubscriptions]
        SET [IsActive] = 0,
            [UnsubscribedDate] = @Now,
            [LastUpdatedDate] = @Now
        WHERE [EmailNormalized] = @EmailNormalized AND [IsActive] = 1;

        IF (@@ROWCOUNT = 0)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @ResultCode = -2;
            SET @ResultMessage = 'Subscription not found or already inactive.';
            RETURN;
        END

        COMMIT TRANSACTION;

        SET @ResultCode = 1;
        SET @ResultMessage = 'Subscription removed successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ResultCode = -50012;
        SET @ResultMessage = CONCAT('Error unsubscribing email: ', ERROR_MESSAGE());
    END CATCH
END
GO

IF OBJECT_ID(N'[dbo].[sp_Newsletter_GetSubscribers]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_Newsletter_GetSubscribers];
GO

CREATE PROCEDURE [dbo].[sp_Newsletter_GetSubscribers]
    @IsActive BIT = NULL,
    @SearchTerm NVARCHAR(200) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 25
AS
BEGIN
    SET NOCOUNT ON;

    IF (@PageNumber IS NULL OR @PageNumber < 1) SET @PageNumber = 1;
    IF (@PageSize IS NULL OR @PageSize < 1) SET @PageSize = 25;
    IF (@PageSize > 200) SET @PageSize = 200;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    WITH FilteredSubscribers AS
    (
        SELECT
            s.[SubscriptionId],
            s.[Email],
            s.[EmailNormalized],
            s.[LanguageCode],
            s.[IsActive],
            s.[IsConfirmed],
            s.[CreatedDate],
            s.[ConfirmedDate],
            s.[UnsubscribedDate],
            s.[LastUpdatedDate],
            ROW_NUMBER() OVER (ORDER BY s.[CreatedDate] DESC, s.[SubscriptionId] DESC) AS RowNum,
            COUNT(1) OVER() AS TotalRecords
        FROM [dbo].[NewsletterSubscriptions] s
        WHERE (
                @IsActive IS NULL OR s.[IsActive] = @IsActive
            )
            AND (
                @SearchTerm IS NULL OR
                s.[Email] LIKE '%' + @SearchTerm + '%' OR
                s.[EmailNormalized] LIKE '%' + UPPER(@SearchTerm) + '%'
            )
    )
    SELECT
        f.[SubscriptionId],
        f.[Email],
        f.[EmailNormalized],
        f.[LanguageCode],
        f.[IsActive],
        f.[IsConfirmed],
        f.[CreatedDate],
        f.[ConfirmedDate],
        f.[UnsubscribedDate],
        f.[LastUpdatedDate],
        f.[TotalRecords]
    FROM FilteredSubscribers f
    WHERE f.RowNum > @Offset AND f.RowNum <= (@Offset + @PageSize)
    ORDER BY f.RowNum;
END
GO

IF OBJECT_ID(N'[dbo].[sp_Newsletter_GetSummary]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_Newsletter_GetSummary];
GO

CREATE PROCEDURE [dbo].[sp_Newsletter_GetSummary]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        TotalSubscribers = COUNT(1),
        ActiveSubscribers = SUM(CASE WHEN [IsActive] = 1 THEN 1 ELSE 0 END),
        InactiveSubscribers = SUM(CASE WHEN [IsActive] = 0 THEN 1 ELSE 0 END),
        SubscribersLast30Days = SUM(CASE WHEN [CreatedDate] >= DATEADD(DAY, -30, GETUTCDATE()) THEN 1 ELSE 0 END)
    FROM [dbo].[NewsletterSubscriptions];
END
GO




