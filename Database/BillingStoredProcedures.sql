/* =============================================
   TARGET DATABASE (optional)
   ============================================= */
USE YourDatabaseName; -- <<< change or remove for deployment
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =============================================
   TABLES
   ============================================= */

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'BillingDocuments' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[BillingDocuments]
    (
        [BillingDocumentId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [UserId] INT NOT NULL,
        [DocumentType] NVARCHAR(20) NOT NULL,
        [DocumentNumber] NVARCHAR(50) NOT NULL,
        [ReferenceDocumentId] INT NULL,
        [IssueDateUtc] DATETIME NOT NULL DEFAULT GETUTCDATE(),
        [DueDateUtc] DATETIME NULL,
        [CurrencyCode] NVARCHAR(3) NOT NULL DEFAULT 'ARS',
        [SubtotalAmount] DECIMAL(18, 2) NOT NULL DEFAULT 0,
        [TaxAmount] DECIMAL(18, 2) NOT NULL DEFAULT 0,
        [TotalAmount] DECIMAL(18, 2) NOT NULL DEFAULT 0,
        [Status] NVARCHAR(20) NOT NULL DEFAULT 'Draft',
        [Notes] NVARCHAR(MAX) NULL,
        [CreatedBy] INT NOT NULL,
        [CreatedDateUtc] DATETIME NOT NULL DEFAULT GETUTCDATE(),
        [LastModifiedBy] INT NULL,
        [LastModifiedDateUtc] DATETIME NULL,
        CONSTRAINT [CK_BillingDocuments_DocumentType]
            CHECK ([DocumentType] IN ('Invoice', 'DebitNote', 'CreditNote')),
        CONSTRAINT [CK_BillingDocuments_Status]
            CHECK ([Status] IN ('Draft', 'Issued', 'Paid', 'Cancelled'))
    );

    CREATE INDEX [IX_BillingDocuments_UserId] ON [dbo].[BillingDocuments] ([UserId]);
    CREATE UNIQUE INDEX [UX_BillingDocuments_Type_Number]
        ON [dbo].[BillingDocuments] ([DocumentType], [DocumentNumber]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'BillingDocumentItems' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[BillingDocumentItems]
    (
        [BillingDocumentItemId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [BillingDocumentId] INT NOT NULL,
        [ProductId] INT NOT NULL,
        [Description] NVARCHAR(300) NOT NULL,
        [Quantity] DECIMAL(18, 2) NOT NULL,
        [UnitPrice] DECIMAL(18, 2) NOT NULL,
        [TaxRate] DECIMAL(5, 2) NOT NULL,
        [LineSubtotal] DECIMAL(18, 2) NOT NULL,
        [LineTaxAmount] DECIMAL(18, 2) NOT NULL,
        [LineTotal] DECIMAL(18, 2) NOT NULL,
        [LineNotes] NVARCHAR(500) NULL,
        CONSTRAINT [FK_BillingDocumentItems_BillingDocuments]
            FOREIGN KEY ([BillingDocumentId])
            REFERENCES [dbo].[BillingDocuments] ([BillingDocumentId])
            ON DELETE CASCADE
    );

    CREATE INDEX [IX_BillingDocumentItems_DocumentId]
        ON [dbo].[BillingDocumentItems] ([BillingDocumentId]);

    CREATE INDEX [IX_BillingDocumentItems_ProductId]
        ON [dbo].[BillingDocumentItems] ([ProductId]);
END
GO

IF COL_LENGTH('dbo.BillingDocumentItems', 'ProductId') IS NULL
BEGIN
    ALTER TABLE [dbo].[BillingDocumentItems]
        ADD [ProductId] INT NULL;
END
GO

/* Ensure foreign key for reference document exists and prevents invalid self-reference */
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BillingDocuments_Reference')
    ALTER TABLE [dbo].[BillingDocuments] DROP CONSTRAINT [FK_BillingDocuments_Reference];

ALTER TABLE [dbo].[BillingDocuments] WITH CHECK
ADD CONSTRAINT [FK_BillingDocuments_Reference]
    FOREIGN KEY ([ReferenceDocumentId])
    REFERENCES [dbo].[BillingDocuments] ([BillingDocumentId]);
GO

/* Optional foreign keys to Users table if available */
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Users' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BillingDocuments_Users')
        ALTER TABLE [dbo].[BillingDocuments] WITH CHECK
        ADD CONSTRAINT [FK_BillingDocuments_Users]
            FOREIGN KEY ([UserId])
            REFERENCES [dbo].[Users] ([UserId]);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BillingDocuments_CreatedBy')
        ALTER TABLE [dbo].[BillingDocuments] WITH CHECK
        ADD CONSTRAINT [FK_BillingDocuments_CreatedBy]
            FOREIGN KEY ([CreatedBy])
            REFERENCES [dbo].[Users] ([UserId]);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BillingDocuments_LastModifiedBy')
        ALTER TABLE [dbo].[BillingDocuments] WITH CHECK
        ADD CONSTRAINT [FK_BillingDocuments_LastModifiedBy]
            FOREIGN KEY ([LastModifiedBy])
            REFERENCES [dbo].[Users] ([UserId]);
END
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Products' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BillingDocumentItems_Products')
        ALTER TABLE [dbo].[BillingDocumentItems] WITH CHECK
        ADD CONSTRAINT [FK_BillingDocumentItems_Products]
            FOREIGN KEY ([ProductId])
            REFERENCES [dbo].[Products] ([ProductId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_BillingDocumentItems_ProductId' AND object_id = OBJECT_ID('[dbo].[BillingDocumentItems]'))
BEGIN
    CREATE INDEX [IX_BillingDocumentItems_ProductId]
        ON [dbo].[BillingDocumentItems] ([ProductId]);
END
GO

/* =============================================
   SUPPORTING TYPES
   ============================================= */
IF OBJECT_ID('dbo.sp_BillingDocument_Create','P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_BillingDocument_Create];
GO

IF TYPE_ID(N'dbo.BillingDocumentItemTableType') IS NOT NULL
    DROP TYPE [dbo].[BillingDocumentItemTableType];
GO

EXEC(N'
    CREATE TYPE [dbo].[BillingDocumentItemTableType] AS TABLE
    (
        [ProductId] INT NOT NULL,
        [Description] NVARCHAR(300) NOT NULL,
        [Quantity] DECIMAL(18, 2) NOT NULL,
        [UnitPrice] DECIMAL(18, 2) NOT NULL,
        [TaxRate] DECIMAL(5, 2) NOT NULL,
        [LineNotes] NVARCHAR(500) NULL
    );
');
GO

/* =============================================
   STORED PROCEDURES
   ============================================= */

/* sp_BillingDocument_Create */
IF OBJECT_ID('dbo.sp_BillingDocument_Create','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_BillingDocument_Create AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_BillingDocument_Create]
    @UserId INT,
    @DocumentType NVARCHAR(20),
    @DocumentNumber NVARCHAR(50),
    @ReferenceDocumentId INT = NULL,
    @IssueDateUtc DATETIME = NULL,
    @DueDateUtc DATETIME = NULL,
    @CurrencyCode NVARCHAR(3) = 'ARS',
    @Status NVARCHAR(20) = 'Draft',
    @Notes NVARCHAR(MAX) = NULL,
    @CreatedBy INT,
    @Items [dbo].[BillingDocumentItemTableType] READONLY,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT,
    @NewBillingDocumentId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success'; SET @NewBillingDocumentId = 0;

    IF (@UserId IS NULL OR @UserId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'UserId is required.'; RETURN; END

    IF (@DocumentType NOT IN ('Invoice', 'DebitNote', 'CreditNote'))
    BEGIN SET @ResultCode = -2; SET @ResultMessage = N'Invalid document type.'; RETURN; END

    IF (@DocumentNumber IS NULL OR LTRIM(RTRIM(@DocumentNumber)) = '')
    BEGIN SET @ResultCode = -3; SET @ResultMessage = N'Document number is required.'; RETURN; END

    IF (EXISTS (SELECT 1 FROM [dbo].[BillingDocuments]
                WHERE [DocumentType] = @DocumentType AND [DocumentNumber] = @DocumentNumber))
    BEGIN SET @ResultCode = -4; SET @ResultMessage = N'Document number already exists for this type.'; RETURN; END

    IF (@CreatedBy IS NULL OR @CreatedBy <= 0)
    BEGIN SET @ResultCode = -5; SET @ResultMessage = N'CreatedBy is required.'; RETURN; END

    IF (@Status NOT IN ('Draft', 'Issued', 'Paid', 'Cancelled'))
    BEGIN SET @ResultCode = -6; SET @ResultMessage = N'Invalid status value.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM @Items)
    BEGIN SET @ResultCode = -7; SET @ResultMessage = N'At least one line item is required.'; RETURN; END

    IF EXISTS (SELECT 1 FROM @Items WHERE [Quantity] <= 0 OR [UnitPrice] < 0 OR [TaxRate] < 0)
    BEGIN SET @ResultCode = -8; SET @ResultMessage = N'Invalid item quantity, unit price, or tax rate.'; RETURN; END

    IF EXISTS (SELECT 1 FROM @Items WHERE [ProductId] IS NULL OR [ProductId] <= 0)
    BEGIN SET @ResultCode = -9; SET @ResultMessage = N'Each line item must reference a valid product.'; RETURN; END

    DECLARE @UseProductCatalog BIT = CASE WHEN EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Products' AND schema_id = SCHEMA_ID('dbo')) THEN 1 ELSE 0 END;

    IF (@UseProductCatalog = 1 AND EXISTS (
            SELECT 1
            FROM @Items i
            WHERE NOT EXISTS (
                SELECT 1
                FROM [dbo].[Products] p
                WHERE p.[ProductId] = i.[ProductId]
                  AND p.[IsActive] = 1
            )
        ))
    BEGIN SET @ResultCode = -10; SET @ResultMessage = N'One or more items reference an inactive or missing product.'; RETURN; END

    DECLARE @NowUtc DATETIME = ISNULL(@IssueDateUtc, GETUTCDATE());

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ItemTotals TABLE
        (
            ProductId INT NOT NULL,
            LineSubtotal DECIMAL(18,2) NOT NULL,
            LineTax DECIMAL(18,2) NOT NULL,
            LineTotal DECIMAL(18,2) NOT NULL,
            Description NVARCHAR(300) NOT NULL,
            Quantity DECIMAL(18,2) NOT NULL,
            UnitPrice DECIMAL(18,2) NOT NULL,
            TaxRate DECIMAL(5,2) NOT NULL,
            LineNotes NVARCHAR(500) NULL
        );

        IF (@UseProductCatalog = 1)
        BEGIN
            INSERT INTO @ItemTotals (ProductId, LineSubtotal, LineTax, LineTotal, Description, Quantity, UnitPrice, TaxRate, LineNotes)
            SELECT
                i.[ProductId],
                ROUND(i.[Quantity] * p.[Price], 2) AS LineSubtotal,
                ROUND(i.[Quantity] * p.[Price] * (i.[TaxRate] / 100.0), 2) AS LineTax,
                ROUND(i.[Quantity] * p.[Price] * (1 + (i.[TaxRate] / 100.0)), 2) AS LineTotal,
                CASE WHEN i.[Description] IS NULL OR LTRIM(RTRIM(i.[Description])) = ''
                     THEN LEFT(p.[Name], 300)
                     ELSE i.[Description]
                END AS Description,
                i.[Quantity],
                p.[Price],
                i.[TaxRate],
                i.[LineNotes]
            FROM @Items i
            INNER JOIN [dbo].[Products] p ON p.[ProductId] = i.[ProductId];
        END
        ELSE
        BEGIN
            INSERT INTO @ItemTotals (ProductId, LineSubtotal, LineTax, LineTotal, Description, Quantity, UnitPrice, TaxRate, LineNotes)
            SELECT
                i.[ProductId],
                ROUND(i.[Quantity] * i.[UnitPrice], 2) AS LineSubtotal,
                ROUND(i.[Quantity] * i.[UnitPrice] * (i.[TaxRate] / 100.0), 2) AS LineTax,
                ROUND(i.[Quantity] * i.[UnitPrice] * (1 + (i.[TaxRate] / 100.0)), 2) AS LineTotal,
                i.[Description], i.[Quantity], i.[UnitPrice], i.[TaxRate], i.[LineNotes]
            FROM @Items i;
        END

        DECLARE @Subtotal DECIMAL(18,2) = (SELECT SUM(LineSubtotal) FROM @ItemTotals);
        DECLARE @Tax DECIMAL(18,2) = (SELECT SUM(LineTax) FROM @ItemTotals);
        DECLARE @Total DECIMAL(18,2) = (SELECT SUM(LineTotal) FROM @ItemTotals);

        INSERT INTO [dbo].[BillingDocuments]
        (
            [UserId], [DocumentType], [DocumentNumber], [ReferenceDocumentId], [IssueDateUtc], [DueDateUtc],
            [CurrencyCode], [SubtotalAmount], [TaxAmount], [TotalAmount], [Status], [Notes],
            [CreatedBy], [CreatedDateUtc], [LastModifiedBy], [LastModifiedDateUtc]
        )
        VALUES
        (
            @UserId, @DocumentType, @DocumentNumber, @ReferenceDocumentId, @NowUtc, @DueDateUtc,
            @CurrencyCode, @Subtotal, @Tax, @Total, @Status, @Notes,
            @CreatedBy, @NowUtc, NULL, NULL
        );

        SET @NewBillingDocumentId = SCOPE_IDENTITY();

        INSERT INTO [dbo].[BillingDocumentItems]
        (
            [BillingDocumentId], [ProductId], [Description], [Quantity], [UnitPrice], [TaxRate],
            [LineSubtotal], [LineTaxAmount], [LineTotal], [LineNotes]
        )
        SELECT
            @NewBillingDocumentId,
            t.[ProductId], t.[Description], t.[Quantity], t.[UnitPrice], t.[TaxRate],
            t.[LineSubtotal], t.[LineTax], t.[LineTotal], t.[LineNotes]
        FROM @ItemTotals t;

        COMMIT TRANSACTION;

        SET @ResultCode = 1;
        SET @ResultMessage = N'Billing document created successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ResultCode = -50001;
        SET @ResultMessage = CONCAT(N'Error creating billing document: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_BillingDocument_UpdateStatus */
IF OBJECT_ID('dbo.sp_BillingDocument_UpdateStatus','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_BillingDocument_UpdateStatus AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_BillingDocument_UpdateStatus]
    @BillingDocumentId INT,
    @NewStatus NVARCHAR(20),
    @ModifiedBy INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success';

    IF (@BillingDocumentId IS NULL OR @BillingDocumentId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'BillingDocumentId is required.'; RETURN; END

    IF (@NewStatus NOT IN ('Draft', 'Issued', 'Paid', 'Cancelled'))
    BEGIN SET @ResultCode = -2; SET @ResultMessage = N'Invalid status value.'; RETURN; END

    IF (@ModifiedBy IS NULL OR @ModifiedBy <= 0)
    BEGIN SET @ResultCode = -3; SET @ResultMessage = N'ModifiedBy is required.'; RETURN; END

    BEGIN TRY
        UPDATE [dbo].[BillingDocuments]
        SET [Status] = @NewStatus,
            [LastModifiedBy] = @ModifiedBy,
            [LastModifiedDateUtc] = GETUTCDATE()
        WHERE [BillingDocumentId] = @BillingDocumentId;

        IF (@@ROWCOUNT = 0)
        BEGIN SET @ResultCode = -4; SET @ResultMessage = N'Billing document not found.'; RETURN; END

        SET @ResultCode = 1;
        SET @ResultMessage = N'Status updated successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50002;
        SET @ResultMessage = CONCAT(N'Error updating status: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_BillingDocument_GetById */
IF OBJECT_ID('dbo.sp_BillingDocument_GetById','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_BillingDocument_GetById AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_BillingDocument_GetById]
    @BillingDocumentId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [dbo].[BillingDocuments]
    WHERE [BillingDocumentId] = @BillingDocumentId;

    SELECT *
    FROM [dbo].[BillingDocumentItems]
    WHERE [BillingDocumentId] = @BillingDocumentId
    ORDER BY [BillingDocumentItemId];
END
GO

/* sp_BillingDocument_GetByUser */
IF OBJECT_ID('dbo.sp_BillingDocument_GetByUser','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_BillingDocument_GetByUser AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_BillingDocument_GetByUser]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [dbo].[BillingDocuments]
    WHERE [UserId] = @UserId
    ORDER BY [IssueDateUtc] DESC, [BillingDocumentId] DESC;
END
GO

/* sp_BillingDocument_Search */
IF OBJECT_ID('dbo.sp_BillingDocument_Search','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_BillingDocument_Search AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_BillingDocument_Search]
    @DocumentType NVARCHAR(20) = NULL,
    @Status NVARCHAR(20) = NULL,
    @FromIssueDateUtc DATETIME = NULL,
    @ToIssueDateUtc DATETIME = NULL,
    @UserId INT = NULL,
    @DocumentNumber NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [dbo].[BillingDocuments]
    WHERE (@DocumentType IS NULL OR [DocumentType] = @DocumentType)
      AND (@Status IS NULL OR [Status] = @Status)
      AND (@FromIssueDateUtc IS NULL OR [IssueDateUtc] >= @FromIssueDateUtc)
      AND (@ToIssueDateUtc IS NULL OR [IssueDateUtc] <= @ToIssueDateUtc)
      AND (@UserId IS NULL OR [UserId] = @UserId)
      AND (@DocumentNumber IS NULL OR [DocumentNumber] = @DocumentNumber)
    ORDER BY [IssueDateUtc] DESC, [BillingDocumentId] DESC;
END
GO

/* sp_BillingDocument_AddItem (for existing documents) */
IF OBJECT_ID('dbo.sp_BillingDocument_AddItem','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_BillingDocument_AddItem AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_BillingDocument_AddItem]
    @BillingDocumentId INT,
    @ProductId INT,
    @Description NVARCHAR(300),
    @Quantity DECIMAL(18,2),
    @UnitPrice DECIMAL(18,2),
    @TaxRate DECIMAL(5,2),
    @LineNotes NVARCHAR(500) = NULL,
    @ModifiedBy INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success';

    IF (@BillingDocumentId IS NULL OR @BillingDocumentId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'BillingDocumentId is required.'; RETURN; END

    IF (@ProductId IS NULL OR @ProductId <= 0)
    BEGIN SET @ResultCode = -2; SET @ResultMessage = N'ProductId is required.'; RETURN; END

    IF (@Quantity <= 0 OR @UnitPrice < 0 OR @TaxRate < 0)
    BEGIN SET @ResultCode = -3; SET @ResultMessage = N'Invalid quantity, unit price, or tax rate.'; RETURN; END

    IF (@ModifiedBy IS NULL OR @ModifiedBy <= 0)
    BEGIN SET @ResultCode = -4; SET @ResultMessage = N'ModifiedBy is required.'; RETURN; END

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Products' AND schema_id = SCHEMA_ID('dbo'))
        BEGIN
            DECLARE @ProductPrice DECIMAL(18,2);
            DECLARE @ProductName NVARCHAR(300);
            SELECT @ProductPrice = [Price],
                   @ProductName = [Name]
            FROM [dbo].[Products]
            WHERE [ProductId] = @ProductId
              AND [IsActive] = 1;

            IF (@ProductPrice IS NULL)
            BEGIN
                ROLLBACK TRANSACTION;
                SET @ResultCode = -5;
                SET @ResultMessage = N'Product not found or inactive.';
                RETURN;
            END

            SET @UnitPrice = @ProductPrice;

            IF (@Description IS NULL OR LTRIM(RTRIM(@Description)) = '')
            BEGIN
                SET @Description = LEFT(ISNULL(@ProductName, ''), 300);
            END
        END
        ELSE IF (@Description IS NULL OR LTRIM(RTRIM(@Description)) = '')
        BEGIN
            ROLLBACK TRANSACTION;
            SET @ResultCode = -6;
            SET @ResultMessage = N'Description is required when product catalog is unavailable.';
            RETURN;
        END

        DECLARE @LineSubtotal DECIMAL(18,2) = ROUND(@Quantity * @UnitPrice, 2);
        DECLARE @LineTax DECIMAL(18,2) = ROUND(@LineSubtotal * (@TaxRate / 100.0), 2);
        DECLARE @LineTotal DECIMAL(18,2) = ROUND(@LineSubtotal + @LineTax, 2);

        INSERT INTO [dbo].[BillingDocumentItems]
        (
            [BillingDocumentId], [ProductId], [Description], [Quantity], [UnitPrice], [TaxRate],
            [LineSubtotal], [LineTaxAmount], [LineTotal], [LineNotes]
        )
        VALUES
        (
            @BillingDocumentId, @ProductId, @Description, @Quantity, @UnitPrice, @TaxRate,
            @LineSubtotal, @LineTax, @LineTotal, @LineNotes
        );

        UPDATE [dbo].[BillingDocuments]
        SET [SubtotalAmount] = [SubtotalAmount] + @LineSubtotal,
            [TaxAmount] = [TaxAmount] + @LineTax,
            [TotalAmount] = [TotalAmount] + @LineTotal,
            [LastModifiedBy] = @ModifiedBy,
            [LastModifiedDateUtc] = GETUTCDATE()
        WHERE [BillingDocumentId] = @BillingDocumentId;

        IF (@@ROWCOUNT = 0)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @ResultCode = -7;
            SET @ResultMessage = N'Billing document not found.';
            RETURN;
        END

        COMMIT TRANSACTION;

        SET @ResultCode = 1;
        SET @ResultMessage = N'Item added successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ResultCode = -50003;
        SET @ResultMessage = CONCAT(N'Error adding item: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_BillingDocument_RemoveItem */
IF OBJECT_ID('dbo.sp_BillingDocument_RemoveItem','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_BillingDocument_RemoveItem AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_BillingDocument_RemoveItem]
    @BillingDocumentItemId INT,
    @ModifiedBy INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success';

    IF (@BillingDocumentItemId IS NULL OR @BillingDocumentItemId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'BillingDocumentItemId is required.'; RETURN; END

    IF (@ModifiedBy IS NULL OR @ModifiedBy <= 0)
    BEGIN SET @ResultCode = -2; SET @ResultMessage = N'ModifiedBy is required.'; RETURN; END

    BEGIN TRY
        DECLARE @BillingDocumentId INT;
        DECLARE @LineSubtotal DECIMAL(18,2);
        DECLARE @LineTax DECIMAL(18,2);
        DECLARE @LineTotal DECIMAL(18,2);

        SELECT @BillingDocumentId = [BillingDocumentId],
               @LineSubtotal = [LineSubtotal],
               @LineTax = [LineTaxAmount],
               @LineTotal = [LineTotal]
        FROM [dbo].[BillingDocumentItems]
        WHERE [BillingDocumentItemId] = @BillingDocumentItemId;

        IF (@BillingDocumentId IS NULL)
        BEGIN SET @ResultCode = -3; SET @ResultMessage = N'Billing document item not found.'; RETURN; END

        DELETE FROM [dbo].[BillingDocumentItems]
        WHERE [BillingDocumentItemId] = @BillingDocumentItemId;

        UPDATE [dbo].[BillingDocuments]
        SET [SubtotalAmount] = [SubtotalAmount] - @LineSubtotal,
            [TaxAmount] = [TaxAmount] - @LineTax,
            [TotalAmount] = [TotalAmount] - @LineTotal,
            [LastModifiedBy] = @ModifiedBy,
            [LastModifiedDateUtc] = GETUTCDATE()
        WHERE [BillingDocumentId] = @BillingDocumentId;

        SET @ResultCode = 1;
        SET @ResultMessage = N'Item removed successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50004;
        SET @ResultMessage = CONCAT(N'Error removing item: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_BillingDocument_Delete */
IF OBJECT_ID('dbo.sp_BillingDocument_Delete','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_BillingDocument_Delete AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_BillingDocument_Delete]
    @BillingDocumentId INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    SET @ResultCode = 0; SET @ResultMessage = N'Success';

    IF (@BillingDocumentId IS NULL OR @BillingDocumentId <= 0)
    BEGIN SET @ResultCode = -1; SET @ResultMessage = N'BillingDocumentId is required.'; RETURN; END

    BEGIN TRY
        DELETE FROM [dbo].[BillingDocuments]
        WHERE [BillingDocumentId] = @BillingDocumentId;

        IF (@@ROWCOUNT = 0)
        BEGIN SET @ResultCode = -2; SET @ResultMessage = N'Billing document not found.'; RETURN; END

        SET @ResultCode = 1;
        SET @ResultMessage = N'Billing document deleted successfully.';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -50005;
        SET @ResultMessage = CONCAT(N'Error deleting billing document: ', ERROR_MESSAGE());
    END CATCH
END
GO

/* sp_BillingDocument_GetMonthlyStatistics */
IF OBJECT_ID('dbo.sp_BillingDocument_GetMonthlyStatistics','P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_BillingDocument_GetMonthlyStatistics AS SET NOCOUNT ON;');
GO
ALTER PROCEDURE [dbo].[sp_BillingDocument_GetMonthlyStatistics]
    @Year INT = NULL,
    @MaxMonths INT = 12,
    @SortDirection NVARCHAR(4) = 'DESC'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NowUtc DATETIME = GETUTCDATE();
    DECLARE @NormalizedSort NVARCHAR(4) = CASE WHEN UPPER(ISNULL(@SortDirection, 'DESC')) = 'ASC' THEN 'ASC' ELSE 'DESC' END;
    DECLARE @Months INT = CASE
                              WHEN @MaxMonths IS NULL OR @MaxMonths < 1 THEN 12
                              WHEN @MaxMonths > 120 THEN 120
                              ELSE @MaxMonths
                          END;

    DECLARE @PeriodStart DATETIME;
    DECLARE @PeriodEnd DATETIME;

    DECLARE @MonthlyData TABLE
    (
        YearNumber INT NOT NULL,
        MonthNumber INT NOT NULL,
        MonthName NVARCHAR(30) NOT NULL,
        SortKey INT NOT NULL,
        TotalDocuments INT NOT NULL,
        PaidDocuments INT NOT NULL,
        CancelledDocuments INT NOT NULL,
        DraftDocuments INT NOT NULL,
        IssuedDocuments INT NOT NULL,
        TotalAmount DECIMAL(18, 2) NOT NULL,
        PaidAmount DECIMAL(18, 2) NOT NULL,
        OutstandingAmount DECIMAL(18, 2) NOT NULL,
        LastActivityUtc DATETIME NULL
    );

    IF (@Year IS NOT NULL)
    BEGIN
        SET @PeriodStart = DATEFROMPARTS(@Year, 1, 1);
        SET @PeriodEnd = DATEADD(YEAR, 1, @PeriodStart);
    END
    ELSE
    BEGIN
        DECLARE @CurrentMonth DATETIME = DATEFROMPARTS(YEAR(@NowUtc), MONTH(@NowUtc), 1);
        SET @PeriodEnd = DATEADD(MONTH, 1, @CurrentMonth);
        SET @PeriodStart = DATEADD(MONTH, -(@Months - 1), @CurrentMonth);
    END;

    ;WITH MonthSeries AS
    (
        SELECT 0 AS Ordinal, DATEFROMPARTS(YEAR(@PeriodStart), MONTH(@PeriodStart), 1) AS MonthStart
        UNION ALL
        SELECT Ordinal + 1, DATEADD(MONTH, 1, MonthStart)
        FROM MonthSeries
        WHERE DATEADD(MONTH, 1, MonthStart) < @PeriodEnd
    ),
    SourceBilling AS
    (
        SELECT
            YEAR(bd.IssueDateUtc) AS YearNumber,
            MONTH(bd.IssueDateUtc) AS MonthNumber,
            bd.Status,
            bd.TotalAmount,
            bd.IssueDateUtc,
            bd.CreatedDateUtc,
            bd.LastModifiedDateUtc
        FROM [dbo].[BillingDocuments] bd
        WHERE bd.IssueDateUtc >= @PeriodStart
          AND bd.IssueDateUtc < @PeriodEnd
    ),
    AggregatedBilling AS
    (
        SELECT
            sb.YearNumber,
            sb.MonthNumber,
            COUNT(1) AS TotalDocuments,
            SUM(CASE WHEN sb.Status = 'Paid' THEN 1 ELSE 0 END) AS PaidDocuments,
            SUM(CASE WHEN sb.Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledDocuments,
            SUM(CASE WHEN sb.Status = 'Draft' THEN 1 ELSE 0 END) AS DraftDocuments,
            SUM(CASE WHEN sb.Status = 'Issued' THEN 1 ELSE 0 END) AS IssuedDocuments,
            SUM(ISNULL(sb.TotalAmount, 0)) AS TotalAmount,
            SUM(CASE WHEN sb.Status = 'Paid' THEN ISNULL(sb.TotalAmount, 0) ELSE 0 END) AS PaidAmount,
            SUM(CASE WHEN sb.Status IN ('Draft', 'Issued') THEN ISNULL(sb.TotalAmount, 0) ELSE 0 END) AS OutstandingAmount,
            MAX(ISNULL(sb.LastModifiedDateUtc, sb.CreatedDateUtc)) AS LastActivityUtc
        FROM SourceBilling sb
        GROUP BY sb.YearNumber, sb.MonthNumber
    ),
    MonthJoined AS
    (
        SELECT
            YEAR(ms.MonthStart) AS YearNumber,
            MONTH(ms.MonthStart) AS MonthNumber,
            DATENAME(MONTH, ms.MonthStart) AS MonthName,
            (YEAR(ms.MonthStart) * 100) + MONTH(ms.MonthStart) AS SortKey,
            ISNULL(ab.TotalDocuments, 0) AS TotalDocuments,
            ISNULL(ab.PaidDocuments, 0) AS PaidDocuments,
            ISNULL(ab.CancelledDocuments, 0) AS CancelledDocuments,
            ISNULL(ab.DraftDocuments, 0) AS DraftDocuments,
            ISNULL(ab.IssuedDocuments, 0) AS IssuedDocuments,
            ISNULL(ab.TotalAmount, 0) AS TotalAmount,
            ISNULL(ab.PaidAmount, 0) AS PaidAmount,
            ISNULL(ab.OutstandingAmount, 0) AS OutstandingAmount,
            ab.LastActivityUtc
        FROM MonthSeries ms
        LEFT JOIN AggregatedBilling ab
                 ON ab.YearNumber = YEAR(ms.MonthStart)
                AND ab.MonthNumber = MONTH(ms.MonthStart)
    )
    INSERT INTO @MonthlyData
    (
        YearNumber,
        MonthNumber,
        MonthName,
        SortKey,
        TotalDocuments,
        PaidDocuments,
        CancelledDocuments,
        DraftDocuments,
        IssuedDocuments,
        TotalAmount,
        PaidAmount,
        OutstandingAmount,
        LastActivityUtc
    )
    SELECT
        YearNumber,
        MonthNumber,
        MonthName,
        SortKey,
        TotalDocuments,
        PaidDocuments,
        CancelledDocuments,
        DraftDocuments,
        IssuedDocuments,
        TotalAmount,
        PaidAmount,
        OutstandingAmount,
        LastActivityUtc
    FROM MonthJoined;

    SELECT
        ISNULL(SUM(md.TotalDocuments), 0) AS TotalDocuments,
        ISNULL(SUM(md.PaidDocuments), 0) AS PaidDocuments,
        ISNULL(SUM(md.DraftDocuments + md.IssuedDocuments), 0) AS OutstandingDocuments,
        ISNULL(SUM(md.CancelledDocuments), 0) AS CancelledDocuments,
        ISNULL(SUM(md.TotalAmount), 0) AS TotalAmount,
        ISNULL(SUM(md.PaidAmount), 0) AS PaidAmount,
        ISNULL(SUM(md.OutstandingAmount), 0) AS OutstandingAmount,
        CASE
            WHEN SUM(md.TotalDocuments) > 0
                THEN SUM(md.TotalAmount) / SUM(CONVERT(DECIMAL(18, 4), md.TotalDocuments))
            ELSE 0
        END AS AverageInvoiceAmount,
        MAX(md.LastActivityUtc) AS LastUpdatedDateUtc
    FROM @MonthlyData md;

    SELECT
        md.YearNumber,
        md.MonthNumber,
        md.MonthName,
        md.TotalDocuments,
        md.PaidDocuments,
        md.CancelledDocuments,
        md.DraftDocuments,
        md.IssuedDocuments,
        md.TotalAmount,
        md.PaidAmount,
        md.OutstandingAmount
    FROM @MonthlyData md
    ORDER BY
        CASE WHEN @NormalizedSort = 'ASC' THEN md.SortKey END ASC,
        CASE WHEN @NormalizedSort = 'DESC' THEN md.SortKey END DESC
    OPTION (MAXRECURSION 0);
END
GO

/* ===== Verification (optional) ===== */
SELECT 'Tables' AS kind, name FROM sys.tables WHERE name LIKE 'BillingDocument%';
SELECT 'Type' AS kind, TYPE_NAME(user_type_id) FROM sys.table_types WHERE name = 'BillingDocumentItemTableType';
SELECT 'Proc' AS kind, name FROM sys.procedures WHERE name LIKE 'sp_BillingDocument%';
GO
