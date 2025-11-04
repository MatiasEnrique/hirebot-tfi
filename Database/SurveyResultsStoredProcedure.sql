-- =============================================
-- Stored Procedure: sp_Survey_GetResultsForDisplay
-- Purpose: Get survey results with vote counts per option for chart display
-- Author: Droid
-- Date: 2025-11-04
-- Returns: 
--   Result Set 1: Survey basic info (SurveyId, Title)
--   Result Set 2: Questions with total vote counts
--   Result Set 3: Options with individual vote counts and percentages
--   Result Set 4: Text answers for unique answer questions
-- =============================================

USE [Hirebot]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Drop procedure if it already exists
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Survey_GetResultsForDisplay]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_Survey_GetResultsForDisplay]
GO

CREATE PROCEDURE [dbo].[sp_Survey_GetResultsForDisplay]
    @SurveyId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate input
    IF (@SurveyId IS NULL OR @SurveyId <= 0)
    BEGIN
        RAISERROR('SurveyId is required and must be positive.', 16, 1);
        RETURN;
    END

    -- Check if survey exists
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Surveys] WHERE [SurveyId] = @SurveyId)
    BEGIN
        RAISERROR('Survey not found.', 16, 1);
        RETURN;
    END

    -- Result Set 1: Return survey basic info
    SELECT 
        s.[SurveyId],
        s.[Title]
    FROM [dbo].[Surveys] s
    WHERE s.[SurveyId] = @SurveyId;

    -- Result Set 2: Return questions with vote counts
    -- Total votes = unique number of responses that answered this question
    SELECT 
        q.[SurveyQuestionId],
        q.[QuestionText],
        q.[QuestionType],
        q.[SortOrder],
        ISNULL(COUNT(DISTINCT sa.[SurveyResponseId]), 0) AS TotalVotes
    FROM [dbo].[SurveyQuestions] q
    LEFT JOIN [dbo].[SurveyAnswers] sa ON sa.[SurveyQuestionId] = q.[SurveyQuestionId]
    WHERE q.[SurveyId] = @SurveyId
    GROUP BY q.[SurveyQuestionId], q.[QuestionText], q.[QuestionType], q.[SortOrder]
    ORDER BY q.[SortOrder], q.[SurveyQuestionId];

    -- Result Set 3: Return options with vote counts and percentages
    -- For each option, count how many times it was selected
    -- Calculate percentage relative to total answers for that question
    SELECT 
        o.[SurveyOptionId],
        o.[SurveyQuestionId],
        o.[OptionText],
        o.[SortOrder],
        ISNULL(COUNT(sa.[SurveyAnswerId]), 0) AS VoteCount,
        -- Calculate percentage: (votes for this option / total votes for question) * 100
        CASE 
            WHEN (SELECT COUNT(*) FROM [dbo].[SurveyAnswers] sa2 WHERE sa2.[SurveyQuestionId] = o.[SurveyQuestionId]) > 0
            THEN CAST(ISNULL(COUNT(sa.[SurveyAnswerId]), 0) * 100.0 / 
                 (SELECT COUNT(*) FROM [dbo].[SurveyAnswers] sa2 WHERE sa2.[SurveyQuestionId] = o.[SurveyQuestionId]) AS DECIMAL(5,2))
            ELSE 0.00
        END AS VotePercentage
    FROM [dbo].[SurveyOptions] o
    LEFT JOIN [dbo].[SurveyAnswers] sa ON sa.[SurveyOptionId] = o.[SurveyOptionId]
    WHERE o.[SurveyQuestionId] IN (
        SELECT [SurveyQuestionId] 
        FROM [dbo].[SurveyQuestions] 
        WHERE [SurveyId] = @SurveyId
    )
    GROUP BY o.[SurveyOptionId], o.[SurveyQuestionId], o.[OptionText], o.[SortOrder]
    ORDER BY o.[SurveyQuestionId], o.[SortOrder], o.[SurveyOptionId];

    -- Result Set 4: Return text answers for unique answer questions
    -- Get all text answers where there's no option selected (unique answer type)
    SELECT 
        sa.[SurveyAnswerId],
        sa.[SurveyQuestionId],
        sa.[AnswerText],
        sr.[SubmittedDateUtc]
    FROM [dbo].[SurveyAnswers] sa
    INNER JOIN [dbo].[SurveyResponses] sr ON sr.[SurveyResponseId] = sa.[SurveyResponseId]
    WHERE sa.[SurveyQuestionId] IN (
        SELECT [SurveyQuestionId] 
        FROM [dbo].[SurveyQuestions] 
        WHERE [SurveyId] = @SurveyId
    )
    AND sa.[SurveyOptionId] IS NULL
    AND sa.[AnswerText] IS NOT NULL
    ORDER BY sa.[SurveyQuestionId], sr.[SubmittedDateUtc] DESC;
END
GO

-- Grant execute permissions
GRANT EXECUTE ON [dbo].[sp_Survey_GetResultsForDisplay] TO PUBLIC;
GO

PRINT 'Stored procedure sp_Survey_GetResultsForDisplay created successfully.'
GO
