/* =============================================
   TARGET DATABASE (optional)
   ============================================= */
USE YourDatabaseName; -- <<< change or remove when deploying
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =============================================
   STORED PROCEDURE: sp_UserAccount_GetDashboardData
   ============================================= */
IF OBJECT_ID('dbo.sp_UserAccount_GetDashboardData', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_UserAccount_GetDashboardData AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_UserAccount_GetDashboardData]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF (@UserId IS NULL OR @UserId <= 0)
    BEGIN
        SELECT CAST(NULL AS INT) AS [UserId],
               CAST(NULL AS NVARCHAR(50)) AS [Username],
               CAST(NULL AS NVARCHAR(255)) AS [Email],
               CAST(NULL AS NVARCHAR(100)) AS [FirstName],
               CAST(NULL AS NVARCHAR(100)) AS [LastName],
               CAST(NULL AS DATETIME) AS [CreatedDate],
               CAST(NULL AS DATETIME) AS [LastLoginDate],
               CAST(NULL AS BIT) AS [IsActive]
        WHERE 1 = 0;

        SELECT CAST(NULL AS INT) AS [SubscriptionId],
               CAST(NULL AS INT) AS [UserId],
               CAST(NULL AS INT) AS [ProductId],
               CAST(NULL AS NVARCHAR(200)) AS [ProductName],
               CAST(NULL AS DECIMAL(18, 2)) AS [ProductPrice],
               CAST(NULL AS NVARCHAR(50)) AS [BillingCycle],
               CAST(NULL AS NVARCHAR(150)) AS [CardholderName],
               CAST(NULL AS NVARCHAR(MAX)) AS [EncryptedCardNumber],
               CAST(NULL AS NVARCHAR(MAX)) AS [EncryptedCardholderName],
               CAST(NULL AS CHAR(4)) AS [CardLast4],
               CAST(NULL AS NVARCHAR(50)) AS [CardBrand],
               CAST(NULL AS TINYINT) AS [ExpirationMonth],
               CAST(NULL AS SMALLINT) AS [ExpirationYear],
               CAST(NULL AS DATETIME) AS [CreatedDateUtc],
               CAST(NULL AS BIT) AS [IsActive],
               CAST(NULL AS DATETIME) AS [CancelledDateUtc]
        WHERE 1 = 0;

        SELECT CAST(NULL AS INT) AS [BillingDocumentId],
               CAST(NULL AS NVARCHAR(20)) AS [DocumentType],
               CAST(NULL AS NVARCHAR(50)) AS [DocumentNumber],
               CAST(NULL AS DATETIME) AS [IssueDateUtc],
               CAST(NULL AS DATETIME) AS [DueDateUtc],
               CAST(NULL AS DECIMAL(18, 2)) AS [TotalAmount],
               CAST(NULL AS NVARCHAR(20)) AS [Status],
               CAST(NULL AS NVARCHAR(3)) AS [CurrencyCode]
        WHERE 1 = 0;
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE [UserId] = @UserId)
    BEGIN
        SELECT CAST(NULL AS INT) AS [UserId],
               CAST(NULL AS NVARCHAR(50)) AS [Username],
               CAST(NULL AS NVARCHAR(255)) AS [Email],
               CAST(NULL AS NVARCHAR(100)) AS [FirstName],
               CAST(NULL AS NVARCHAR(100)) AS [LastName],
               CAST(NULL AS DATETIME) AS [CreatedDate],
               CAST(NULL AS DATETIME) AS [LastLoginDate],
               CAST(NULL AS BIT) AS [IsActive]
        WHERE 1 = 0;

        SELECT CAST(NULL AS INT) AS [SubscriptionId],
               CAST(NULL AS INT) AS [UserId],
               CAST(NULL AS INT) AS [ProductId],
               CAST(NULL AS NVARCHAR(200)) AS [ProductName],
               CAST(NULL AS DECIMAL(18, 2)) AS [ProductPrice],
               CAST(NULL AS NVARCHAR(50)) AS [BillingCycle],
               CAST(NULL AS NVARCHAR(150)) AS [CardholderName],
               CAST(NULL AS NVARCHAR(MAX)) AS [EncryptedCardNumber],
               CAST(NULL AS NVARCHAR(MAX)) AS [EncryptedCardholderName],
               CAST(NULL AS CHAR(4)) AS [CardLast4],
               CAST(NULL AS NVARCHAR(50)) AS [CardBrand],
               CAST(NULL AS TINYINT) AS [ExpirationMonth],
               CAST(NULL AS SMALLINT) AS [ExpirationYear],
               CAST(NULL AS DATETIME) AS [CreatedDateUtc],
               CAST(NULL AS BIT) AS [IsActive],
               CAST(NULL AS DATETIME) AS [CancelledDateUtc]
        WHERE 1 = 0;

        SELECT CAST(NULL AS INT) AS [BillingDocumentId],
               CAST(NULL AS NVARCHAR(20)) AS [DocumentType],
               CAST(NULL AS NVARCHAR(50)) AS [DocumentNumber],
               CAST(NULL AS DATETIME) AS [IssueDateUtc],
               CAST(NULL AS DATETIME) AS [DueDateUtc],
               CAST(NULL AS DECIMAL(18, 2)) AS [TotalAmount],
               CAST(NULL AS NVARCHAR(20)) AS [Status],
               CAST(NULL AS NVARCHAR(3)) AS [CurrencyCode]
        WHERE 1 = 0;
        RETURN;
    END;

    SELECT [UserId], [Username], [Email], [FirstName], [LastName], [CreatedDate], [LastLoginDate], [IsActive]
    FROM [dbo].[Users]
    WHERE [UserId] = @UserId;

    SELECT ps.[SubscriptionId],
           ps.[UserId],
           ps.[ProductId],
           p.[Name] AS [ProductName],
           p.[Price] AS [ProductPrice],
           p.[BillingCycle],
           ps.[CardholderName],
           ps.[EncryptedCardNumber],
           ps.[EncryptedCardholderName],
           ps.[CardLast4],
           ps.[CardBrand],
           ps.[ExpirationMonth],
           ps.[ExpirationYear],
           ps.[CreatedDateUtc],
           ps.[IsActive],
           ps.[CancelledDateUtc]
    FROM [dbo].[ProductSubscriptions] ps
    INNER JOIN [dbo].[Products] p ON ps.[ProductId] = p.[ProductId]
    WHERE ps.[UserId] = @UserId
    ORDER BY ps.[CreatedDateUtc] DESC, ps.[SubscriptionId] DESC;

    SELECT bd.[BillingDocumentId],
           bd.[DocumentType],
           bd.[DocumentNumber],
           bd.[IssueDateUtc],
           bd.[DueDateUtc],
           bd.[TotalAmount],
           bd.[Status],
           bd.[CurrencyCode]
    FROM [dbo].[BillingDocuments] bd
    WHERE bd.[UserId] = @UserId
    ORDER BY bd.[IssueDateUtc] DESC, bd.[BillingDocumentId] DESC;
END
GO

/* =============================================
   STORED PROCEDURE: sp_UserAccount_UpdateProfile
   ============================================= */
IF OBJECT_ID('dbo.sp_UserAccount_UpdateProfile', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_UserAccount_UpdateProfile AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_UserAccount_UpdateProfile]
    @UserId INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(255),
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0;
    SET @ResultMessage = N'Success';

    IF (@UserId IS NULL OR @UserId <= 0)
    BEGIN
        SET @ResultCode = -1;
        SET @ResultMessage = N'Invalid user identifier.';
        RETURN;
    END;

    IF (@FirstName IS NULL OR LTRIM(RTRIM(@FirstName)) = '')
    BEGIN
        SET @ResultCode = -2;
        SET @ResultMessage = N'First name is required.';
        RETURN;
    END;

    IF (@LastName IS NULL OR LTRIM(RTRIM(@LastName)) = '')
    BEGIN
        SET @ResultCode = -3;
        SET @ResultMessage = N'Last name is required.';
        RETURN;
    END;

    IF (@Email IS NULL OR LTRIM(RTRIM(@Email)) = '')
    BEGIN
        SET @ResultCode = -4;
        SET @ResultMessage = N'Email is required.';
        RETURN;
    END;

    IF (LEN(LTRIM(RTRIM(@Email))) > 255)
    BEGIN
        SET @ResultCode = -5;
        SET @ResultMessage = N'Email exceeds maximum length.';
        RETURN;
    END;

    IF (LEN(LTRIM(RTRIM(@FirstName))) > 100 OR LEN(LTRIM(RTRIM(@LastName))) > 100)
    BEGIN
        SET @ResultCode = -6;
        SET @ResultMessage = N'First or last name exceeds maximum length.';
        RETURN;
    END;

    DECLARE @NormalizedEmail NVARCHAR(255) = LOWER(LTRIM(RTRIM(@Email)));

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE [UserId] = @UserId)
    BEGIN
        SET @ResultCode = -7;
        SET @ResultMessage = N'User not found.';
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM [dbo].[Users]
               WHERE [Email] = @NormalizedEmail AND [UserId] <> @UserId)
    BEGIN
        SET @ResultCode = -8;
        SET @ResultMessage = N'Email is already in use by another user.';
        RETURN;
    END;

    BEGIN TRY
        UPDATE [dbo].[Users]
        SET [FirstName] = LTRIM(RTRIM(@FirstName)),
            [LastName] = LTRIM(RTRIM(@LastName)),
            [Email] = @NormalizedEmail,
            [ModifiedDate] = GETDATE()
        WHERE [UserId] = @UserId;

        IF (@@ROWCOUNT = 0)
        BEGIN
            SET @ResultCode = -9;
            SET @ResultMessage = N'No changes were applied.';
            RETURN;
        END;

        SET @ResultCode = 1;
        SET @ResultMessage = N'Profile updated successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50001;
        SET @ResultMessage = CONCAT(N'Error updating profile: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* =============================================
   STORED PROCEDURE: sp_UserAccount_UpdatePassword
   ============================================= */
IF OBJECT_ID('dbo.sp_UserAccount_UpdatePassword', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_UserAccount_UpdatePassword AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_UserAccount_UpdatePassword]
    @UserId INT,
    @CurrentPasswordHash NVARCHAR(255),
    @NewPasswordHash NVARCHAR(255),
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0;
    SET @ResultMessage = N'Success';

    IF (@UserId IS NULL OR @UserId <= 0)
    BEGIN
        SET @ResultCode = -1;
        SET @ResultMessage = N'Invalid user identifier.';
        RETURN;
    END;

    IF (@CurrentPasswordHash IS NULL OR LEN(LTRIM(RTRIM(@CurrentPasswordHash))) = 0)
    BEGIN
        SET @ResultCode = -2;
        SET @ResultMessage = N'Current password hash is required.';
        RETURN;
    END;

    IF (@NewPasswordHash IS NULL OR LEN(LTRIM(RTRIM(@NewPasswordHash))) = 0)
    BEGIN
        SET @ResultCode = -3;
        SET @ResultMessage = N'New password hash is required.';
        RETURN;
    END;

    DECLARE @ExistingHash NVARCHAR(255);

    SELECT @ExistingHash = [PasswordHash]
    FROM [dbo].[Users]
    WHERE [UserId] = @UserId;

    IF (@ExistingHash IS NULL)
    BEGIN
        SET @ResultCode = -4;
        SET @ResultMessage = N'User not found.';
        RETURN;
    END;

    IF (@ExistingHash <> @CurrentPasswordHash)
    BEGIN
        SET @ResultCode = -5;
        SET @ResultMessage = N'Current password is incorrect.';
        RETURN;
    END;

    IF (@ExistingHash = @NewPasswordHash)
    BEGIN
        SET @ResultCode = -6;
        SET @ResultMessage = N'The new password must be different from the current password.';
        RETURN;
    END;

    BEGIN TRY
        UPDATE [dbo].[Users]
        SET [PasswordHash] = @NewPasswordHash,
            [ModifiedDate] = GETDATE()
        WHERE [UserId] = @UserId;

        IF (@@ROWCOUNT = 0)
        BEGIN
            SET @ResultCode = -7;
            SET @ResultMessage = N'No changes were applied.';
            RETURN;
        END;

        SET @ResultCode = 1;
        SET @ResultMessage = N'Password updated successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50002;
        SET @ResultMessage = CONCAT(N'Error updating password: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* =============================================
   STORED PROCEDURE: sp_UserAccount_CancelSubscription
   ============================================= */
IF OBJECT_ID('dbo.sp_UserAccount_CancelSubscription', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_UserAccount_CancelSubscription AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_UserAccount_CancelSubscription]
    @UserId INT,
    @SubscriptionId INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0;
    SET @ResultMessage = N'Success';

    IF (@UserId IS NULL OR @UserId <= 0)
    BEGIN
        SET @ResultCode = -1;
        SET @ResultMessage = N'Invalid user identifier.';
        RETURN;
    END;

    IF (@SubscriptionId IS NULL OR @SubscriptionId <= 0)
    BEGIN
        SET @ResultCode = -2;
        SET @ResultMessage = N'Invalid subscription identifier.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE [UserId] = @UserId)
    BEGIN
        SET @ResultCode = -3;
        SET @ResultMessage = N'User not found.';
        RETURN;
    END;

    DECLARE @IsActive BIT;
    DECLARE @CancelledDateUtc DATETIME;

    SELECT @IsActive = [IsActive],
           @CancelledDateUtc = [CancelledDateUtc]
    FROM [dbo].[ProductSubscriptions]
    WHERE [SubscriptionId] = @SubscriptionId
      AND [UserId] = @UserId;

    IF (@IsActive IS NULL)
    BEGIN
        SET @ResultCode = -4;
        SET @ResultMessage = N'Subscription not found.';
        RETURN;
    END;

    IF (@IsActive = 0)
    BEGIN
        SET @ResultCode = -5;
        SET @ResultMessage = N'Subscription is already cancelled.';
        RETURN;
    END;

    BEGIN TRY
        UPDATE [dbo].[ProductSubscriptions]
        SET [IsActive] = 0,
            [CancelledDateUtc] = CASE WHEN [CancelledDateUtc] IS NULL THEN GETUTCDATE() ELSE [CancelledDateUtc] END
        WHERE [SubscriptionId] = @SubscriptionId
          AND [UserId] = @UserId;

        IF (@@ROWCOUNT = 0)
        BEGIN
            SET @ResultCode = -6;
            SET @ResultMessage = N'No changes were applied.';
            RETURN;
        END;

        SET @ResultCode = 1;
        SET @ResultMessage = N'Subscription cancelled successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50003;
        SET @ResultMessage = CONCAT(N'Error cancelling subscription: ', ERROR_MESSAGE());
    END CATCH
END
GO
