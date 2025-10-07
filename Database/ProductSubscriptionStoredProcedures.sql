/* ===== Target database (optional) ===== */
USE YourDatabaseName; -- <<< change or remove
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =============================================
   TABLES
   ============================================= */

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductSubscriptions' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[ProductSubscriptions]
    (
        [SubscriptionId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [UserId] INT NOT NULL,
        [ProductId] INT NOT NULL,
        [CardholderName] NVARCHAR(150) NOT NULL,
        [CardLast4] CHAR(4) NOT NULL,
        [CardBrand] NVARCHAR(50) NULL,
        [ExpirationMonth] TINYINT NOT NULL,
        [ExpirationYear] SMALLINT NOT NULL,
        [CreatedDateUtc] DATETIME NOT NULL DEFAULT GETUTCDATE(),
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CancelledDateUtc] DATETIME NULL,

        CONSTRAINT [FK_ProductSubscriptions_Users]
            FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users]([UserId]),

        CONSTRAINT [FK_ProductSubscriptions_Products]
            FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Products]([ProductId])
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ProductSubscriptions_User_Product' AND object_id = OBJECT_ID('dbo.ProductSubscriptions'))
BEGIN
    CREATE UNIQUE INDEX [IX_ProductSubscriptions_User_Product]
        ON [dbo].[ProductSubscriptions] ([UserId], [ProductId])
        WHERE [IsActive] = 1;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ProductSubscriptions_User' AND object_id = OBJECT_ID('dbo.ProductSubscriptions'))
BEGIN
    CREATE INDEX [IX_ProductSubscriptions_User]
        ON [dbo].[ProductSubscriptions] ([UserId], [IsActive]);
END
GO

/* =============================================
   STORED PROCEDURES
   ============================================= */

IF OBJECT_ID('dbo.sp_ProductSubscription_Create', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_ProductSubscription_Create AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_ProductSubscription_Create]
    @UserId INT,
    @ProductId INT,
    @CardholderName NVARCHAR(150),
    @CardLast4 CHAR(4),
    @CardBrand NVARCHAR(50) = NULL,
    @ExpirationMonth TINYINT,
    @ExpirationYear SMALLINT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT,
    @NewSubscriptionId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success'; SET @NewSubscriptionId = 0;

    IF (@UserId IS NULL OR @UserId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'UserId is required.'; RETURN; END

    IF (@ProductId IS NULL OR @ProductId <= 0)
    BEGIN SET @ResultCode = -2; SET @ResultMessage = N'ProductId is required.'; RETURN; END

    IF (@CardholderName IS NULL OR LTRIM(RTRIM(@CardholderName)) = '')
    BEGIN SET @ResultCode = -3; SET @ResultMessage = N'Cardholder name is required.'; RETURN; END

    IF (@CardLast4 IS NULL OR LEN(@CardLast4) <> 4)
    BEGIN SET @ResultCode = -4; SET @ResultMessage = N'Card last 4 digits are required.'; RETURN; END

    IF (@ExpirationMonth < 1 OR @ExpirationMonth > 12)
    BEGIN SET @ResultCode = -5; SET @ResultMessage = N'Expiration month is invalid.'; RETURN; END

    IF (@ExpirationYear < YEAR(GETUTCDATE()) OR @ExpirationYear > YEAR(GETUTCDATE()) + 30)
    BEGIN SET @ResultCode = -6; SET @ResultMessage = N'Expiration year is invalid.'; RETURN; END

    DECLARE @ProductPrice DECIMAL(18,2);
    DECLARE @BillingCycle NVARCHAR(20);

    SELECT @ProductPrice = [Price], @BillingCycle = [BillingCycle]
    FROM [dbo].[Products]
    WHERE [ProductId] = @ProductId AND [IsActive] = 1;

    IF (@ProductPrice IS NULL)
    BEGIN SET @ResultCode = -7; SET @ResultMessage = N'Product not found or inactive.'; RETURN; END

    IF EXISTS (SELECT 1 FROM [dbo].[ProductSubscriptions]
               WHERE [UserId] = @UserId AND [ProductId] = @ProductId AND [IsActive] = 1)
    BEGIN SET @ResultCode = -8; SET @ResultMessage = N'User already has an active subscription for this product.'; RETURN; END

    BEGIN TRY
        INSERT INTO [dbo].[ProductSubscriptions]
        ([UserId], [ProductId], [CardholderName], [CardLast4], [CardBrand], [ExpirationMonth], [ExpirationYear])
        VALUES
        (@UserId, @ProductId, LTRIM(RTRIM(@CardholderName)), @CardLast4, NULLIF(LTRIM(RTRIM(@CardBrand)), ''), @ExpirationMonth, @ExpirationYear);

        SET @NewSubscriptionId = SCOPE_IDENTITY();
        SET @ResultCode = 1; SET @ResultMessage = N'Subscription created successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50001;
        SET @ResultMessage = CONCAT(N'Error creating subscription: ', ERROR_MESSAGE());
    END CATCH
END
GO

IF OBJECT_ID('dbo.sp_ProductSubscription_GetByUser', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_ProductSubscription_GetByUser AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_ProductSubscription_GetByUser]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ps.[SubscriptionId],
        ps.[UserId],
        ps.[ProductId],
        p.[Name] AS [ProductName],
        p.[Price] AS [ProductPrice],
        p.[BillingCycle],
        ps.[CardholderName],
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
    ORDER BY ps.[CreatedDateUtc] DESC;
END
GO

IF OBJECT_ID('dbo.sp_ProductSubscription_GetActiveByUserAndProduct', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_ProductSubscription_GetActiveByUserAndProduct AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_ProductSubscription_GetActiveByUserAndProduct]
    @UserId INT,
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        ps.[SubscriptionId],
        ps.[UserId],
        ps.[ProductId],
        p.[Name] AS [ProductName],
        p.[Price] AS [ProductPrice],
        p.[BillingCycle],
        ps.[CardholderName],
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
      AND ps.[ProductId] = @ProductId
      AND ps.[IsActive] = 1;
END
GO

IF OBJECT_ID('dbo.sp_ProductSubscription_GetById', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_ProductSubscription_GetById AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_ProductSubscription_GetById]
    @SubscriptionId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        ps.[SubscriptionId],
        ps.[UserId],
        ps.[ProductId],
        p.[Name] AS [ProductName],
        p.[Price] AS [ProductPrice],
        p.[BillingCycle],
        ps.[CardholderName],
        ps.[CardLast4],
        ps.[CardBrand],
        ps.[ExpirationMonth],
        ps.[ExpirationYear],
        ps.[CreatedDateUtc],
        ps.[IsActive],
        ps.[CancelledDateUtc]
    FROM [dbo].[ProductSubscriptions] ps
    INNER JOIN [dbo].[Products] p ON ps.[ProductId] = p.[ProductId]
    WHERE ps.[SubscriptionId] = @SubscriptionId;
END
GO

IF OBJECT_ID('dbo.sp_ProductSubscription_Cancel', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_ProductSubscription_Cancel AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_ProductSubscription_Cancel]
    @SubscriptionId INT,
    @UserId INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0;
    SET @ResultMessage = N'Success';

    IF (@SubscriptionId IS NULL OR @SubscriptionId <= 0)
    BEGIN
        SET @ResultCode = -1;
        SET @ResultMessage = N'SubscriptionId is required.';
        RETURN;
    END

    IF (@UserId IS NULL OR @UserId <= 0)
    BEGIN
        SET @ResultCode = -2;
        SET @ResultMessage = N'UserId is required.';
        RETURN;
    END

    DECLARE @OwnerId INT;
    DECLARE @IsActive BIT;

    SELECT
        @OwnerId = [UserId],
        @IsActive = [IsActive]
    FROM [dbo].[ProductSubscriptions]
    WHERE [SubscriptionId] = @SubscriptionId;

    IF (@OwnerId IS NULL)
    BEGIN
        SET @ResultCode = -3;
        SET @ResultMessage = N'Subscription not found.';
        RETURN;
    END

    IF (@OwnerId <> @UserId)
    BEGIN
        SET @ResultCode = -4;
        SET @ResultMessage = N'User is not authorized to cancel this subscription.';
        RETURN;
    END

    IF (@IsActive IS NULL OR @IsActive = 0)
    BEGIN
        SET @ResultCode = -5;
        SET @ResultMessage = N'The subscription is already cancelled.';
        RETURN;
    END

    BEGIN TRY
        UPDATE [dbo].[ProductSubscriptions]
        SET [IsActive] = 0,
            [CancelledDateUtc] = GETUTCDATE()
        WHERE [SubscriptionId] = @SubscriptionId;

        SET @ResultCode = 1;
        SET @ResultMessage = N'Subscription cancelled successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50001;
        SET @ResultMessage = CONCAT(N'Error cancelling subscription: ', ERROR_MESSAGE());
    END CATCH
END
GO
