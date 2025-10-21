/* ===== Target database (optional) ===== */
USE YourDatabaseName; -- <<< change or remove
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =============================================
   TABLES
   ============================================= */

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Surveys' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[Surveys]
    (
        [SurveyId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Title] NVARCHAR(200) NOT NULL,
        [Description] NVARCHAR(MAX) NULL,
        [LanguageCode] NVARCHAR(5) NOT NULL DEFAULT 'es',
        [StartDateUtc] DATETIME NULL,
        [EndDateUtc] DATETIME NULL,
        [IsActive] BIT NOT NULL DEFAULT 0,
        [AllowMultipleResponses] BIT NOT NULL DEFAULT 0,
        [CreatedBy] INT NOT NULL,
        [CreatedDateUtc] DATETIME NOT NULL DEFAULT GETUTCDATE(),
        [LastModifiedBy] INT NULL,
        [LastModifiedDateUtc] DATETIME NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SurveyQuestions' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[SurveyQuestions]
    (
        [SurveyQuestionId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [SurveyId] INT NOT NULL,
        [QuestionText] NVARCHAR(500) NOT NULL,
        [QuestionType] NVARCHAR(50) NOT NULL,
        [IsRequired] BIT NOT NULL DEFAULT 0,
        [SortOrder] INT NOT NULL DEFAULT 1,
        CONSTRAINT [FK_SurveyQuestions_Surveys]
            FOREIGN KEY ([SurveyId])
            REFERENCES [dbo].[Surveys] ([SurveyId])
            ON DELETE CASCADE
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SurveyOptions' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[SurveyOptions]
    (
        [SurveyOptionId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [SurveyQuestionId] INT NOT NULL,
        [OptionText] NVARCHAR(300) NOT NULL,
        [OptionValue] NVARCHAR(100) NULL,
        [SortOrder] INT NOT NULL DEFAULT 1,
        CONSTRAINT [FK_SurveyOptions_SurveyQuestions]
            FOREIGN KEY ([SurveyQuestionId])
            REFERENCES [dbo].[SurveyQuestions] ([SurveyQuestionId])
            ON DELETE CASCADE
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SurveyResponses' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[SurveyResponses]
    (
        [SurveyResponseId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [SurveyId] INT NOT NULL,
        [UserId] INT NOT NULL,
        [SubmittedDateUtc] DATETIME NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_SurveyResponses_Surveys]
            FOREIGN KEY ([SurveyId])
            REFERENCES [dbo].[Surveys] ([SurveyId])
            ON DELETE CASCADE
    );
END
GO

/* Ensure non-unique index on (SurveyId, UserId) and remove any legacy unique one */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_SurveyResponses_Survey_User' AND object_id = OBJECT_ID('dbo.SurveyResponses'))
    DROP INDEX [UX_SurveyResponses_Survey_User] ON [dbo].[SurveyResponses];
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SurveyResponses_Survey_User' AND object_id = OBJECT_ID('dbo.SurveyResponses'))
    CREATE INDEX [IX_SurveyResponses_Survey_User] ON [dbo].[SurveyResponses] ([SurveyId], [UserId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SurveyAnswers' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[SurveyAnswers]
    (
        [SurveyAnswerId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [SurveyResponseId] INT NOT NULL,
        [SurveyQuestionId] INT NOT NULL,
        [SurveyOptionId] INT NULL,
        [AnswerText] NVARCHAR(MAX) NULL,

        CONSTRAINT [FK_SurveyAnswers_SurveyResponses]
            FOREIGN KEY ([SurveyResponseId])
            REFERENCES [dbo].[SurveyResponses] ([SurveyResponseId])
            ON DELETE CASCADE,

        -- NO ACTION to avoid multiple cascade paths
        CONSTRAINT [FK_SurveyAnswers_SurveyQuestions]
            FOREIGN KEY ([SurveyQuestionId])
            REFERENCES [dbo].[SurveyQuestions] ([SurveyQuestionId])
            ON DELETE NO ACTION,

        CONSTRAINT [FK_SurveyAnswers_SurveyOptions]
            FOREIGN KEY ([SurveyOptionId])
            REFERENCES [dbo].[SurveyOptions] ([SurveyOptionId])
    );
END
ELSE
BEGIN
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SurveyAnswers_SurveyQuestions')
        ALTER TABLE [dbo].[SurveyAnswers] DROP CONSTRAINT [FK_SurveyAnswers_SurveyQuestions];

    ALTER TABLE [dbo].[SurveyAnswers] WITH CHECK
    ADD CONSTRAINT [FK_SurveyAnswers_SurveyQuestions]
        FOREIGN KEY ([SurveyQuestionId])
        REFERENCES [dbo].[SurveyQuestions] ([SurveyQuestionId])
        ON DELETE NO ACTION;
END
GO

/* =============================================
   SUPPORTING TYPE (create only if missing)
   ============================================= */
IF TYPE_ID(N'dbo.SurveyAnswerTableType') IS NULL
BEGIN
    EXEC(N'
        CREATE TYPE [dbo].[SurveyAnswerTableType] AS TABLE
        (
            [SurveyQuestionId] INT NOT NULL,
            [SurveyOptionId] INT NULL,
            [AnswerText] NVARCHAR(MAX) NULL
        );
    ');
END
GO

/* =============================================
   STORED PROCEDURES (robust 2-step: create stub, then ALTER)
   ============================================= */

/* sp_Survey_Create */
IF OBJECT_ID('dbo.sp_Survey_Create','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_Survey_Create AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_Survey_Create]
    @Title NVARCHAR(200),
    @Description NVARCHAR(MAX) = NULL,
    @LanguageCode NVARCHAR(5) = 'es',
    @StartDateUtc DATETIME = NULL,
    @EndDateUtc DATETIME = NULL,
    @IsActive BIT = 0,
    @AllowMultipleResponses BIT = 0,
    @CreatedBy INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT,
    @NewSurveyId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success'; SET @NewSurveyId = 0;

    IF (@Title IS NULL OR LTRIM(RTRIM(@Title)) = '')
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'Title is required.'; RETURN; END

    IF (@CreatedBy IS NULL OR @CreatedBy <= 0)
    BEGIN SET @ResultCode = -2; SET @ResultMessage = N'CreatedBy is required.'; RETURN; END

    IF (@EndDateUtc IS NOT NULL AND @StartDateUtc IS NOT NULL AND @EndDateUtc < @StartDateUtc)
    BEGIN SET @ResultCode = -3; SET @ResultMessage = N'EndDate cannot be earlier than StartDate.'; RETURN; END

    BEGIN TRY
        INSERT INTO [dbo].[Surveys]
        ( [Title], [Description], [LanguageCode], [StartDateUtc], [EndDateUtc],
          [IsActive], [AllowMultipleResponses], [CreatedBy] )
        VALUES
        ( @Title, @Description, @LanguageCode, @StartDateUtc, @EndDateUtc,
          @IsActive, @AllowMultipleResponses, @CreatedBy );

        SET @NewSurveyId = SCOPE_IDENTITY();
        SET @ResultCode = 1; SET @ResultMessage = N'Survey created successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50001;
        SET @ResultMessage = CONCAT(N'Error creating survey: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_Survey_Update */
IF OBJECT_ID('dbo.sp_Survey_Update','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_Survey_Update AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_Survey_Update]
    @SurveyId INT,
    @Title NVARCHAR(200),
    @Description NVARCHAR(MAX) = NULL,
    @LanguageCode NVARCHAR(5) = 'es',
    @StartDateUtc DATETIME = NULL,
    @EndDateUtc DATETIME = NULL,
    @IsActive BIT = 0,
    @AllowMultipleResponses BIT = 0,
    @ModifiedBy INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success';

    IF (@SurveyId IS NULL OR @SurveyId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'SurveyId is required.'; RETURN; END

    IF (@Title IS NULL OR LTRIM(RTRIM(@Title)) = '')
    BEGIN SET @ResultCode = -2; SET @ResultMessage = N'Title is required.'; RETURN; END

    IF (@ModifiedBy IS NULL OR @ModifiedBy <= 0)
    BEGIN SET @ResultCode = -3; SET @ResultMessage = N'ModifiedBy is required.'; RETURN; END

    IF (@EndDateUtc IS NOT NULL AND @StartDateUtc IS NOT NULL AND @EndDateUtc < @StartDateUtc)
    BEGIN SET @ResultCode = -4; SET @ResultMessage = N'EndDate cannot be earlier than StartDate.'; RETURN; END

    BEGIN TRY
        UPDATE [dbo].[Surveys]
        SET [Title]=@Title, [Description]=@Description, [LanguageCode]=@LanguageCode,
            [StartDateUtc]=@StartDateUtc, [EndDateUtc]=@EndDateUtc,
            [IsActive]=@IsActive, [AllowMultipleResponses]=@AllowMultipleResponses,
            [LastModifiedBy]=@ModifiedBy, [LastModifiedDateUtc]=GETUTCDATE()
        WHERE [SurveyId]=@SurveyId;

        IF (@@ROWCOUNT = 0)
        BEGIN SET @ResultCode = -5; SET @ResultMessage = N'Survey not found.'; RETURN; END

        SET @ResultCode = 1; SET @ResultMessage = N'Survey updated successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50002;
        SET @ResultMessage = CONCAT(N'Error updating survey: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_Survey_Delete */
IF OBJECT_ID('dbo.sp_Survey_Delete','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_Survey_Delete AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_Survey_Delete]
    @SurveyId INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success';

    IF (@SurveyId IS NULL OR @SurveyId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'SurveyId is required.'; RETURN; END

    BEGIN TRY
        DELETE FROM [dbo].[Surveys] WHERE [SurveyId]=@SurveyId;

        IF (@@ROWCOUNT = 0)
        BEGIN SET @ResultCode = -2; SET @ResultMessage = N'Survey not found.'; RETURN; END

        SET @ResultCode = 1; SET @ResultMessage = N'Survey deleted successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50003;
        SET @ResultMessage = CONCAT(N'Error deleting survey: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_SurveyQuestion_Create */
IF OBJECT_ID('dbo.sp_SurveyQuestion_Create','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_SurveyQuestion_Create AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_SurveyQuestion_Create]
    @SurveyId INT,
    @QuestionText NVARCHAR(500),
    @QuestionType NVARCHAR(50),
    @IsRequired BIT = 0,
    @SortOrder INT = 1,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT,
    @NewSurveyQuestionId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success'; SET @NewSurveyQuestionId = 0;

    IF (@SurveyId IS NULL OR @SurveyId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'SurveyId is required.'; RETURN; END

    IF (@QuestionText IS NULL OR LTRIM(RTRIM(@QuestionText)) = '')
    BEGIN SET @ResultCode = -2; SET @ResultMessage = N'QuestionText is required.'; RETURN; END

    IF (@QuestionType IS NULL OR LTRIM(RTRIM(@QuestionType)) = '')
    BEGIN SET @ResultCode = -3; SET @ResultMessage = N'QuestionType is required.'; RETURN; END

    BEGIN TRY
        INSERT INTO [dbo].[SurveyQuestions]
        ( [SurveyId], [QuestionText], [QuestionType], [IsRequired], [SortOrder] )
        VALUES
        ( @SurveyId, @QuestionText, @QuestionType, @IsRequired, @SortOrder );

        SET @NewSurveyQuestionId = SCOPE_IDENTITY();
        SET @ResultCode = 1; SET @ResultMessage = N'Survey question created successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50004;
        SET @ResultMessage = CONCAT(N'Error creating survey question: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_SurveyQuestion_Update */
IF OBJECT_ID('dbo.sp_SurveyQuestion_Update','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_SurveyQuestion_Update AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_SurveyQuestion_Update]
    @SurveyQuestionId INT,
    @QuestionText NVARCHAR(500),
    @QuestionType NVARCHAR(50),
    @IsRequired BIT = 0,
    @SortOrder INT = 1,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success';

    IF (@SurveyQuestionId IS NULL OR @SurveyQuestionId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'SurveyQuestionId is required.'; RETURN; END

    IF (@QuestionText IS NULL OR LTRIM(RTRIM(@QuestionText)) = '')
    BEGIN SET @ResultCode = -2; SET @ResultMessage = N'QuestionText is required.'; RETURN; END

    IF (@QuestionType IS NULL OR LTRIM(RTRIM(@QuestionType)) = '')
    BEGIN SET @ResultCode = -3; SET @ResultMessage = N'QuestionType is required.'; RETURN; END

    BEGIN TRY
        UPDATE [dbo].[SurveyQuestions]
        SET [QuestionText]=@QuestionText, [QuestionType]=@QuestionType,
            [IsRequired]=@IsRequired, [SortOrder]=@SortOrder
        WHERE [SurveyQuestionId]=@SurveyQuestionId;

        IF (@@ROWCOUNT = 0)
        BEGIN SET @ResultCode = -4; SET @ResultMessage = N'Survey question not found.'; RETURN; END

        SET @ResultCode = 1; SET @ResultMessage = N'Survey question updated successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50005;
        SET @ResultMessage = CONCAT(N'Error updating survey question: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_SurveyQuestion_Delete */
IF OBJECT_ID('dbo.sp_SurveyQuestion_Delete','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_SurveyQuestion_Delete AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_SurveyQuestion_Delete]
    @SurveyQuestionId INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success';

    IF (@SurveyQuestionId IS NULL OR @SurveyQuestionId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'SurveyQuestionId is required.'; RETURN; END

    -- FK is NO ACTION: block delete if answers exist
    IF EXISTS (SELECT 1 FROM [dbo].[SurveyAnswers] WHERE [SurveyQuestionId] = @SurveyQuestionId)
    BEGIN SET @ResultCode = -3; SET @ResultMessage = N'Cannot delete question: there are answers recorded for this question.'; RETURN; END

    BEGIN TRY
        DELETE FROM [dbo].[SurveyQuestions] WHERE [SurveyQuestionId]=@SurveyQuestionId;

        IF (@@ROWCOUNT = 0)
        BEGIN SET @ResultCode = -2; SET @ResultMessage = N'Survey question not found.'; RETURN; END

        SET @ResultCode = 1; SET @ResultMessage = N'Survey question deleted successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50006;
        SET @ResultMessage = CONCAT(N'Error deleting survey question: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_SurveyOption_Create */
IF OBJECT_ID('dbo.sp_SurveyOption_Create','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_SurveyOption_Create AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_SurveyOption_Create]
    @SurveyQuestionId INT,
    @OptionText NVARCHAR(300),
    @OptionValue NVARCHAR(100) = NULL,
    @SortOrder INT = 1,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT,
    @NewSurveyOptionId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success'; SET @NewSurveyOptionId = 0;

    IF (@SurveyQuestionId IS NULL OR @SurveyQuestionId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'SurveyQuestionId is required.'; RETURN; END

    IF (@OptionText IS NULL OR LTRIM(RTRIM(@OptionText)) = '')
    BEGIN SET @ResultCode = -2; SET @ResultMessage = N'OptionText is required.'; RETURN; END

    BEGIN TRY
        INSERT INTO [dbo].[SurveyOptions]
        ( [SurveyQuestionId], [OptionText], [OptionValue], [SortOrder] )
        VALUES
        ( @SurveyQuestionId, @OptionText, @OptionValue, @SortOrder );

        SET @NewSurveyOptionId = SCOPE_IDENTITY();
        SET @ResultCode = 1; SET @ResultMessage = N'Survey option created successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50007;
        SET @ResultMessage = CONCAT(N'Error creating survey option: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_SurveyOption_Update */
IF OBJECT_ID('dbo.sp_SurveyOption_Update','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_SurveyOption_Update AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_SurveyOption_Update]
    @SurveyOptionId INT,
    @OptionText NVARCHAR(300),
    @OptionValue NVARCHAR(100) = NULL,
    @SortOrder INT = 1,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success';

    IF (@SurveyOptionId IS NULL OR @SurveyOptionId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'SurveyOptionId is required.'; RETURN; END

    IF (@OptionText IS NULL OR LTRIM(RTRIM(@OptionText)) = '')
    BEGIN SET @ResultCode = -2; SET @ResultMessage = N'OptionText is required.'; RETURN; END

    BEGIN TRY
        UPDATE [dbo].[SurveyOptions]
        SET [OptionText]=@OptionText, [OptionValue]=@OptionValue, [SortOrder]=@SortOrder
        WHERE [SurveyOptionId]=@SurveyOptionId;

        IF (@@ROWCOUNT = 0)
        BEGIN SET @ResultCode = -3; SET @ResultMessage = N'Survey option not found.'; RETURN; END

        SET @ResultCode = 1; SET @ResultMessage = N'Survey option updated successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50008;
        SET @ResultMessage = CONCAT(N'Error updating survey option: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_SurveyOption_Delete */
IF OBJECT_ID('dbo.sp_SurveyOption_Delete','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_SurveyOption_Delete AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_SurveyOption_Delete]
    @SurveyOptionId INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success';

    IF (@SurveyOptionId IS NULL OR @SurveyOptionId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'SurveyOptionId is required.'; RETURN; END

    BEGIN TRY
        DELETE FROM [dbo].[SurveyOptions] WHERE [SurveyOptionId]=@SurveyOptionId;

        IF (@@ROWCOUNT = 0)
        BEGIN SET @ResultCode = -2; SET @ResultMessage = N'Survey option not found.'; RETURN; END

        SET @ResultCode = 1; SET @ResultMessage = N'Survey option deleted successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50009;
        SET @ResultMessage = CONCAT(N'Error deleting survey option: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_Survey_GetById */
IF OBJECT_ID('dbo.sp_Survey_GetById','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_Survey_GetById AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_Survey_GetById]
    @SurveyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT s.* FROM [dbo].[Surveys] s WHERE s.[SurveyId] = @SurveyId;

    SELECT q.* FROM [dbo].[SurveyQuestions] q
    WHERE q.[SurveyId] = @SurveyId
    ORDER BY q.[SortOrder], q.[SurveyQuestionId];

    SELECT o.* FROM [dbo].[SurveyOptions] o
    INNER JOIN [dbo].[SurveyQuestions] q ON q.[SurveyQuestionId] = o.[SurveyQuestionId]
    WHERE q.[SurveyId] = @SurveyId
    ORDER BY q.[SurveyQuestionId], o.[SortOrder], o.[SurveyOptionId];
END
GO

/* sp_Survey_GetAll */
IF OBJECT_ID('dbo.sp_Survey_GetAll','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_Survey_GetAll AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_Survey_GetAll]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT s.* FROM [dbo].[Surveys] s ORDER BY s.[CreatedDateUtc] DESC;
END
GO

/* sp_Survey_GetActiveForDisplay */
-- =============================================
-- Author:      SQL Server Expert
-- Create date: 2025-10-04
-- Description: Retrieves the most recent active survey for display to a user.
--              Returns 3 result sets: survey record, questions, and options.
--              Filters out surveys the user has already responded to.
-- Parameters:  @CurrentUtc - Current UTC datetime for date range validation
--              @LanguageCode - Optional language code filter (NULL = any language)
--              @UserId - Optional user ID to exclude already-responded surveys
-- Returns:     3 result sets if survey found, 0 otherwise
-- =============================================
IF OBJECT_ID('dbo.sp_Survey_GetActiveForDisplay','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_Survey_GetActiveForDisplay AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_Survey_GetActiveForDisplay]
    @CurrentUtc DATETIME,
    @LanguageCode NVARCHAR(5) = NULL,
    @UserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Return the most recent active survey that matches criteria
    -- and has NOT been responded to by the user (if @UserId provided)
    SELECT TOP 1 s.*
    FROM [dbo].[Surveys] s
    WHERE s.[IsActive] = 1
      AND (s.[StartDateUtc] IS NULL OR s.[StartDateUtc] <= @CurrentUtc)
      AND (s.[EndDateUtc] IS NULL OR s.[EndDateUtc] >= @CurrentUtc)
      AND (@LanguageCode IS NULL OR s.[LanguageCode] = @LanguageCode)
      AND (@UserId IS NULL OR NOT EXISTS (
          SELECT 1
          FROM [dbo].[SurveyResponses] sr
          WHERE sr.[SurveyId] = s.[SurveyId]
            AND sr.[UserId] = @UserId
      ))
    ORDER BY s.[CreatedDateUtc] DESC, s.[SurveyId] DESC;

    IF @@ROWCOUNT = 0 RETURN;

    -- Get the SurveyId with same filtering logic
    DECLARE @SurveyId INT = (
        SELECT TOP 1 s2.[SurveyId]
        FROM [dbo].[Surveys] s2
        WHERE s2.[IsActive] = 1
          AND (s2.[StartDateUtc] IS NULL OR s2.[StartDateUtc] <= @CurrentUtc)
          AND (s2.[EndDateUtc] IS NULL OR s2.[EndDateUtc] >= @CurrentUtc)
          AND (@LanguageCode IS NULL OR s2.[LanguageCode] = @LanguageCode)
          AND (@UserId IS NULL OR NOT EXISTS (
              SELECT 1
              FROM [dbo].[SurveyResponses] sr
              WHERE sr.[SurveyId] = s2.[SurveyId]
                AND sr.[UserId] = @UserId
          ))
        ORDER BY s2.[CreatedDateUtc] DESC, s2.[SurveyId] DESC
    );

    -- Return questions for the survey
    SELECT q.* FROM [dbo].[SurveyQuestions] q
    WHERE q.[SurveyId] = @SurveyId
    ORDER BY q.[SortOrder], q.[SurveyQuestionId];

    -- Return options for the questions
    SELECT o.* FROM [dbo].[SurveyOptions] o
    INNER JOIN [dbo].[SurveyQuestions] q ON q.[SurveyQuestionId] = o.[SurveyQuestionId]
    WHERE q.[SurveyId] = @SurveyId
    ORDER BY q.[SurveyQuestionId], o.[SortOrder], o.[SurveyOptionId];
END
GO

/* sp_Survey_SaveResponse */
IF OBJECT_ID('dbo.sp_Survey_SaveResponse','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_Survey_SaveResponse AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_Survey_SaveResponse]
    @SurveyId INT,
    @UserId INT,
    @Answers [dbo].[SurveyAnswerTableType] READONLY,
    @AllowMultipleResponses BIT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT,
    @NewSurveyResponseId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success'; SET @NewSurveyResponseId = 0;

    IF (@SurveyId IS NULL OR @SurveyId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'SurveyId is required.'; RETURN; END

    IF (@UserId IS NULL OR @UserId <= 0)
    BEGIN SET @ResultCode = -2; SET @ResultMessage = N'UserId is required.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Surveys] WHERE [SurveyId] = @SurveyId)
    BEGIN SET @ResultCode = -3; SET @ResultMessage = N'Survey not found.'; RETURN; END

    IF (@AllowMultipleResponses = 0 AND EXISTS (
            SELECT 1 FROM [dbo].[SurveyResponses] WHERE [SurveyId]=@SurveyId AND [UserId]=@UserId))
    BEGIN SET @ResultCode = -4; SET @ResultMessage = N'User has already responded to this survey.'; RETURN; END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[SurveyResponses] ([SurveyId], [UserId])
        VALUES (@SurveyId, @UserId);

        SET @NewSurveyResponseId = SCOPE_IDENTITY();

        INSERT INTO [dbo].[SurveyAnswers]
            ([SurveyResponseId], [SurveyQuestionId], [SurveyOptionId], [AnswerText])
        SELECT @NewSurveyResponseId, a.[SurveyQuestionId], a.[SurveyOptionId], a.[AnswerText]
        FROM @Answers a;

        COMMIT TRANSACTION;

        SET @ResultCode = 1; SET @ResultMessage = N'Survey response saved successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ResultCode = -50010;
        SET @ResultMessage = CONCAT(N'Error saving survey response: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_Survey_HasUserResponded */
IF OBJECT_ID('dbo.sp_Survey_HasUserResponded','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_Survey_HasUserResponded AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_Survey_HasUserResponded]
    @SurveyId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CASE WHEN EXISTS(
        SELECT 1 FROM [dbo].[SurveyResponses]
        WHERE [SurveyId]=@SurveyId AND [UserId]=@UserId
    ) THEN 1 ELSE 0 END AS HasResponded;
END
GO

/* sp_Survey_GetStatistics */
IF OBJECT_ID('dbo.sp_Survey_GetStatistics','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_Survey_GetStatistics AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_Survey_GetStatistics]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NowUtc DATETIME = GETUTCDATE();
    DECLARE @ThirtyDaysAgo DATETIME = DATEADD(DAY, -30, @NowUtc);

    ;WITH QuestionCounts AS
    (
        SELECT q.SurveyId, COUNT(*) AS QuestionCount
        FROM [dbo].[SurveyQuestions] q
        GROUP BY q.SurveyId
    ),
    ResponseAggregates AS
    (
        SELECT
            sr.SurveyId,
            COUNT(*) AS TotalResponses,
            SUM(CASE WHEN sr.SubmittedDateUtc >= @ThirtyDaysAgo THEN 1 ELSE 0 END) AS ResponsesLast30Days,
            MAX(sr.SubmittedDateUtc) AS LastResponseDateUtc
        FROM [dbo].[SurveyResponses] sr
        GROUP BY sr.SurveyId
    ),
    SurveyData AS
    (
        SELECT
            s.SurveyId,
            s.Title,
            s.IsActive,
            s.StartDateUtc,
            s.EndDateUtc,
            ISNULL(qc.QuestionCount, 0) AS QuestionCount,
            ISNULL(ra.TotalResponses, 0) AS TotalResponses,
            ISNULL(ra.ResponsesLast30Days, 0) AS ResponsesLast30Days,
            ra.LastResponseDateUtc
        FROM [dbo].[Surveys] s
        LEFT JOIN QuestionCounts qc ON qc.SurveyId = s.SurveyId
        LEFT JOIN ResponseAggregates ra ON ra.SurveyId = s.SurveyId
    )
    SELECT
        COUNT(*) AS TotalSurveys,
        SUM(CASE WHEN sd.IsActive = 1
                   AND (sd.StartDateUtc IS NULL OR sd.StartDateUtc <= @NowUtc)
                   AND (sd.EndDateUtc IS NULL OR sd.EndDateUtc >= @NowUtc) THEN 1 ELSE 0 END) AS ActiveSurveys,
        SUM(CASE WHEN sd.IsActive = 1 AND sd.StartDateUtc IS NOT NULL AND sd.StartDateUtc > @NowUtc THEN 1 ELSE 0 END) AS ScheduledSurveys,
        SUM(CASE WHEN sd.EndDateUtc IS NOT NULL AND sd.EndDateUtc < @NowUtc THEN 1 ELSE 0 END) AS ExpiredSurveys,
        ISNULL(SUM(sd.TotalResponses), 0) AS TotalResponses,
        ISNULL(SUM(sd.ResponsesLast30Days), 0) AS ResponsesLast30Days,
        CASE
            WHEN COUNT(*) > 0
                THEN ISNULL(SUM(CONVERT(DECIMAL(18, 4), sd.TotalResponses)), 0) / COUNT(*)
            ELSE 0
        END AS AverageResponsesPerSurvey,
        MAX(sd.LastResponseDateUtc) AS LastResponseDateUtc
    FROM SurveyData sd;

    ;WITH QuestionCounts AS
    (
        SELECT q.SurveyId, COUNT(*) AS QuestionCount
        FROM [dbo].[SurveyQuestions] q
        GROUP BY q.SurveyId
    ),
    ResponseAggregates AS
    (
        SELECT
            sr.SurveyId,
            COUNT(*) AS TotalResponses,
            SUM(CASE WHEN sr.SubmittedDateUtc >= @ThirtyDaysAgo THEN 1 ELSE 0 END) AS ResponsesLast30Days,
            MAX(sr.SubmittedDateUtc) AS LastResponseDateUtc
        FROM [dbo].[SurveyResponses] sr
        GROUP BY sr.SurveyId
    ),
    SurveyData AS
    (
        SELECT
            s.SurveyId,
            s.Title,
            s.IsActive,
            s.StartDateUtc,
            s.EndDateUtc,
            ISNULL(qc.QuestionCount, 0) AS QuestionCount,
            ISNULL(ra.TotalResponses, 0) AS TotalResponses,
            ISNULL(ra.ResponsesLast30Days, 0) AS ResponsesLast30Days,
            ra.LastResponseDateUtc
        FROM [dbo].[Surveys] s
        LEFT JOIN QuestionCounts qc ON qc.SurveyId = s.SurveyId
        LEFT JOIN ResponseAggregates ra ON ra.SurveyId = s.SurveyId
    )
    SELECT
        sd.SurveyId,
        sd.Title,
        sd.IsActive,
        sd.StartDateUtc,
        sd.EndDateUtc,
        sd.QuestionCount,
        sd.TotalResponses,
        sd.ResponsesLast30Days,
        sd.LastResponseDateUtc,
        CASE
            WHEN sd.IsActive = 1
                 AND (sd.StartDateUtc IS NULL OR sd.StartDateUtc <= @NowUtc)
                 AND (sd.EndDateUtc IS NULL OR sd.EndDateUtc >= @NowUtc)
                THEN 1 ELSE 0 END AS IsCurrentlyOpen
    FROM SurveyData sd
    ORDER BY sd.Title ASC;
END
GO

/* ===== Verification (optional) ===== */
SELECT 'Tables' AS kind, name FROM sys.tables WHERE name LIKE 'Survey%';
SELECT 'Type'   AS kind, TYPE_NAME(user_type_id) FROM sys.table_types WHERE name='SurveyAnswerTableType';
SELECT 'Proc'   AS kind, name FROM sys.procedures WHERE name LIKE 'sp_Survey%';
