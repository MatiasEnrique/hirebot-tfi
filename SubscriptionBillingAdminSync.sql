-- Run this against the application database.

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF COL_LENGTH('dbo.BillingDocuments', 'SubscriptionId') IS NULL
    ALTER TABLE dbo.BillingDocuments ADD SubscriptionId INT NULL;
GO

IF COL_LENGTH('dbo.BillingDocuments', 'PrimaryPaymentMethod') IS NULL
    ALTER TABLE dbo.BillingDocuments ADD PrimaryPaymentMethod NVARCHAR(30) NULL;
GO

IF COL_LENGTH('dbo.BillingDocuments', 'SecondaryPaymentMethod') IS NULL
    ALTER TABLE dbo.BillingDocuments ADD SecondaryPaymentMethod NVARCHAR(30) NULL;
GO

IF COL_LENGTH('dbo.BillingDocuments', 'CardBrand') IS NULL
    ALTER TABLE dbo.BillingDocuments ADD CardBrand NVARCHAR(50) NULL;
GO

IF COL_LENGTH('dbo.BillingDocuments', 'CardLast4') IS NULL
    ALTER TABLE dbo.BillingDocuments ADD CardLast4 CHAR(4) NULL;
GO

IF COL_LENGTH('dbo.BillingDocuments', 'TransferReference') IS NULL
    ALTER TABLE dbo.BillingDocuments ADD TransferReference NVARCHAR(100) NULL;
GO

IF COL_LENGTH('dbo.BillingDocuments', 'SecondTransferReference') IS NULL
    ALTER TABLE dbo.BillingDocuments ADD SecondTransferReference NVARCHAR(100) NULL;
GO

CREATE OR ALTER PROCEDURE dbo.sp_BillingDocument_Create
    @UserId INT,
    @DocumentType NVARCHAR(20),
    @DocumentNumber NVARCHAR(50),
    @ReferenceDocumentId INT = NULL,
    @IssueDateUtc DATETIME = NULL,
    @DueDateUtc DATETIME = NULL,
    @CurrencyCode NVARCHAR(3) = 'ARS',
    @Status NVARCHAR(20) = 'Draft',
    @SubscriptionId INT = NULL,
    @PrimaryPaymentMethod NVARCHAR(30) = NULL,
    @SecondaryPaymentMethod NVARCHAR(30) = NULL,
    @CardBrand NVARCHAR(50) = NULL,
    @CardLast4 CHAR(4) = NULL,
    @TransferReference NVARCHAR(100) = NULL,
    @SecondTransferReference NVARCHAR(100) = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @CreatedBy INT,
    @Items dbo.BillingDocumentItemTableType READONLY,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT,
    @NewBillingDocumentId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @ResultCode = 0;
    SET @ResultMessage = N'Success';
    SET @NewBillingDocumentId = 0;

    IF (@UserId IS NULL OR @UserId <= 0)
    BEGIN
        SET @ResultCode = -1;
        SET @ResultMessage = N'UserId is required.';
        RETURN;
    END

    IF (@DocumentType NOT IN ('Invoice', 'DebitNote', 'CreditNote'))
    BEGIN
        SET @ResultCode = -2;
        SET @ResultMessage = N'Invalid document type.';
        RETURN;
    END

    IF (@DocumentNumber IS NULL OR LTRIM(RTRIM(@DocumentNumber)) = '')
    BEGIN
        SET @ResultCode = -3;
        SET @ResultMessage = N'Document number is required.';
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM dbo.BillingDocuments
        WHERE DocumentType = @DocumentType
          AND DocumentNumber = @DocumentNumber
    )
    BEGIN
        SET @ResultCode = -4;
        SET @ResultMessage = N'Document number already exists for this type.';
        RETURN;
    END

    IF (@CreatedBy IS NULL OR @CreatedBy <= 0)
    BEGIN
        SET @ResultCode = -5;
        SET @ResultMessage = N'CreatedBy is required.';
        RETURN;
    END

    IF (@Status NOT IN ('Draft', 'Issued', 'Paid', 'Cancelled'))
    BEGIN
        SET @ResultCode = -6;
        SET @ResultMessage = N'Invalid status value.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM @Items)
    BEGIN
        SET @ResultCode = -7;
        SET @ResultMessage = N'At least one line item is required.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM @Items WHERE Quantity <= 0 OR UnitPrice < 0 OR TaxRate < 0)
    BEGIN
        SET @ResultCode = -8;
        SET @ResultMessage = N'Invalid item quantity, unit price, or tax rate.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM @Items WHERE ProductId IS NULL OR ProductId <= 0)
    BEGIN
        SET @ResultCode = -9;
        SET @ResultMessage = N'Each line item must reference a valid product.';
        RETURN;
    END

    DECLARE @UseProductCatalog BIT =
        CASE
            WHEN EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Products' AND schema_id = SCHEMA_ID('dbo')) THEN 1
            ELSE 0
        END;

    IF (@UseProductCatalog = 1 AND EXISTS
    (
        SELECT 1
        FROM @Items i
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.Products p
            WHERE p.ProductId = i.ProductId
              AND p.IsActive = 1
        )
    ))
    BEGIN
        SET @ResultCode = -10;
        SET @ResultMessage = N'One or more items reference an inactive or missing product.';
        RETURN;
    END

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
            INSERT INTO @ItemTotals
            (
                ProductId,
                LineSubtotal,
                LineTax,
                LineTotal,
                Description,
                Quantity,
                UnitPrice,
                TaxRate,
                LineNotes
            )
            SELECT
                i.ProductId,
                ROUND(i.Quantity * p.Price, 2),
                ROUND(i.Quantity * p.Price * (i.TaxRate / 100.0), 2),
                ROUND(i.Quantity * p.Price * (1 + (i.TaxRate / 100.0)), 2),
                CASE
                    WHEN i.Description IS NULL OR LTRIM(RTRIM(i.Description)) = '' THEN LEFT(p.Name, 300)
                    ELSE i.Description
                END,
                i.Quantity,
                p.Price,
                i.TaxRate,
                i.LineNotes
            FROM @Items i
            INNER JOIN dbo.Products p ON p.ProductId = i.ProductId;
        END
        ELSE
        BEGIN
            INSERT INTO @ItemTotals
            (
                ProductId,
                LineSubtotal,
                LineTax,
                LineTotal,
                Description,
                Quantity,
                UnitPrice,
                TaxRate,
                LineNotes
            )
            SELECT
                i.ProductId,
                ROUND(i.Quantity * i.UnitPrice, 2),
                ROUND(i.Quantity * i.UnitPrice * (i.TaxRate / 100.0), 2),
                ROUND(i.Quantity * i.UnitPrice * (1 + (i.TaxRate / 100.0)), 2),
                i.Description,
                i.Quantity,
                i.UnitPrice,
                i.TaxRate,
                i.LineNotes
            FROM @Items i;
        END

        DECLARE @Subtotal DECIMAL(18,2) = (SELECT SUM(LineSubtotal) FROM @ItemTotals);
        DECLARE @Tax DECIMAL(18,2) = (SELECT SUM(LineTax) FROM @ItemTotals);
        DECLARE @Total DECIMAL(18,2) = (SELECT SUM(LineTotal) FROM @ItemTotals);

        INSERT INTO dbo.BillingDocuments
        (
            UserId,
            DocumentType,
            DocumentNumber,
            ReferenceDocumentId,
            IssueDateUtc,
            DueDateUtc,
            CurrencyCode,
            SubtotalAmount,
            TaxAmount,
            TotalAmount,
            Status,
            SubscriptionId,
            PrimaryPaymentMethod,
            SecondaryPaymentMethod,
            CardBrand,
            CardLast4,
            TransferReference,
            SecondTransferReference,
            Notes,
            CreatedBy,
            CreatedDateUtc,
            LastModifiedBy,
            LastModifiedDateUtc
        )
        VALUES
        (
            @UserId,
            @DocumentType,
            @DocumentNumber,
            @ReferenceDocumentId,
            @NowUtc,
            @DueDateUtc,
            @CurrencyCode,
            @Subtotal,
            @Tax,
            @Total,
            @Status,
            @SubscriptionId,
            NULLIF(LTRIM(RTRIM(@PrimaryPaymentMethod)), ''),
            NULLIF(LTRIM(RTRIM(@SecondaryPaymentMethod)), ''),
            NULLIF(LTRIM(RTRIM(@CardBrand)), ''),
            NULLIF(@CardLast4, ''),
            NULLIF(LTRIM(RTRIM(@TransferReference)), ''),
            NULLIF(LTRIM(RTRIM(@SecondTransferReference)), ''),
            @Notes,
            @CreatedBy,
            @NowUtc,
            NULL,
            NULL
        );

        SET @NewBillingDocumentId = SCOPE_IDENTITY();

        INSERT INTO dbo.BillingDocumentItems
        (
            BillingDocumentId,
            ProductId,
            Description,
            Quantity,
            UnitPrice,
            TaxRate,
            LineSubtotal,
            LineTaxAmount,
            LineTotal,
            LineNotes
        )
        SELECT
            @NewBillingDocumentId,
            t.ProductId,
            t.Description,
            t.Quantity,
            t.UnitPrice,
            t.TaxRate,
            t.LineSubtotal,
            t.LineTax,
            t.LineTotal,
            t.LineNotes
        FROM @ItemTotals t;

        COMMIT TRANSACTION;

        SET @ResultCode = 1;
        SET @ResultMessage = N'Billing document created successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @ResultCode = -50001;
        SET @ResultMessage = CONCAT(N'Error creating billing document: ', ERROR_MESSAGE());
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_BillingDocument_GetMonthlyStatistics
    @Year INT = NULL,
    @MaxMonths INT = 12,
    @SortDirection NVARCHAR(4) = 'DESC'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NowUtc DATETIME = GETUTCDATE();
    DECLARE @NormalizedSort NVARCHAR(4) = CASE WHEN UPPER(ISNULL(@SortDirection, 'DESC')) = 'ASC' THEN 'ASC' ELSE 'DESC' END;
    DECLARE @Months INT =
        CASE
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
        FROM dbo.BillingDocuments bd
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

    ;WITH PaymentMethodCategories AS
    (
        SELECT 'Tarjeta' AS PaymentMethodKey, 1 AS SortOrder
        UNION ALL SELECT 'Transferencia', 2
        UNION ALL SELECT 'CuentaCorriente', 3
        UNION ALL SELECT 'PagoCombinado', 4
    )
    SELECT
        pm.PaymentMethodKey,
        COUNT(bd.BillingDocumentId) AS TotalDocuments,
        ISNULL(SUM(bd.TotalAmount), 0) AS TotalAmount
    FROM PaymentMethodCategories pm
    LEFT JOIN dbo.BillingDocuments bd
        ON bd.IssueDateUtc >= @PeriodStart
       AND bd.IssueDateUtc < @PeriodEnd
       AND bd.PrimaryPaymentMethod = pm.PaymentMethodKey
    GROUP BY pm.PaymentMethodKey, pm.SortOrder
    ORDER BY pm.SortOrder;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_BillingDocument_Search
    @DocumentType NVARCHAR(20) = NULL,
    @Status NVARCHAR(20) = NULL,
    @FromIssueDateUtc DATETIME = NULL,
    @ToIssueDateUtc DATETIME = NULL,
    @UserId INT = NULL,
    @DocumentNumber NVARCHAR(50) = NULL,
    @PaymentMethod NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.BillingDocuments
    WHERE (@DocumentType IS NULL OR DocumentType = @DocumentType)
      AND (@Status IS NULL OR Status = @Status)
      AND (@FromIssueDateUtc IS NULL OR IssueDateUtc >= @FromIssueDateUtc)
      AND (@ToIssueDateUtc IS NULL OR IssueDateUtc <= @ToIssueDateUtc)
      AND (@UserId IS NULL OR UserId = @UserId)
      AND (@DocumentNumber IS NULL OR DocumentNumber = @DocumentNumber)
      AND (@PaymentMethod IS NULL OR PrimaryPaymentMethod = @PaymentMethod)
    ORDER BY IssueDateUtc DESC, BillingDocumentId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProductSubscription_Create
    @UserId INT,
    @ProductId INT,
    @PaymentMethod NVARCHAR(30) = 'Tarjeta',
    @CardholderName NVARCHAR(150) = NULL,
    @CardLast4 CHAR(4) = NULL,
    @CardBrand NVARCHAR(50) = NULL,
    @EncryptedCardNumber NVARCHAR(MAX) = NULL,
    @EncryptedCardholderName NVARCHAR(MAX) = NULL,
    @ExpirationMonth TINYINT = NULL,
    @ExpirationYear SMALLINT = NULL,
    @TransferReference NVARCHAR(100) = NULL,
    @SecondPaymentMethod NVARCHAR(30) = NULL,
    @SecondTransferReference NVARCHAR(100) = NULL,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT,
    @NewSubscriptionId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @ResultCode = 0;
    SET @ResultMessage = N'Success';
    SET @NewSubscriptionId = 0;

    IF (@UserId IS NULL OR @UserId <= 0)
    BEGIN
        SET @ResultCode = -1;
        SET @ResultMessage = N'UserId is required.';
        RETURN;
    END

    IF (@ProductId IS NULL OR @ProductId <= 0)
    BEGIN
        SET @ResultCode = -2;
        SET @ResultMessage = N'ProductId is required.';
        RETURN;
    END

    IF (@PaymentMethod NOT IN ('Tarjeta', 'Transferencia', 'CuentaCorriente', 'PagoCombinado'))
    BEGIN
        SET @ResultCode = -3;
        SET @ResultMessage = N'Invalid payment method.';
        RETURN;
    END

    DECLARE @HasCardPayload BIT =
        CASE
            WHEN NULLIF(LTRIM(RTRIM(@CardholderName)), '') IS NOT NULL THEN 1
            WHEN NULLIF(@CardLast4, '') IS NOT NULL THEN 1
            WHEN NULLIF(LTRIM(RTRIM(@CardBrand)), '') IS NOT NULL THEN 1
            WHEN NULLIF(LTRIM(RTRIM(@EncryptedCardNumber)), '') IS NOT NULL THEN 1
            WHEN NULLIF(LTRIM(RTRIM(@EncryptedCardholderName)), '') IS NOT NULL THEN 1
            WHEN ISNULL(@ExpirationMonth, 0) > 0 THEN 1
            WHEN ISNULL(@ExpirationYear, 0) > 0 THEN 1
            ELSE 0
        END;

    IF (@PaymentMethod = 'Tarjeta' OR (@PaymentMethod = 'PagoCombinado' AND @HasCardPayload = 1))
    BEGIN
        IF (@CardholderName IS NULL OR LTRIM(RTRIM(@CardholderName)) = '')
        BEGIN
            SET @ResultCode = -4;
            SET @ResultMessage = N'Cardholder name is required for card payments.';
            RETURN;
        END

        IF (@CardLast4 IS NULL OR LEN(@CardLast4) <> 4)
        BEGIN
            SET @ResultCode = -5;
            SET @ResultMessage = N'Card last 4 digits are required for card payments.';
            RETURN;
        END

        IF (@EncryptedCardNumber IS NULL OR LEN(@EncryptedCardNumber) = 0)
        BEGIN
            SET @ResultCode = -6;
            SET @ResultMessage = N'Encrypted card number is required for card payments.';
            RETURN;
        END

        IF (@EncryptedCardholderName IS NULL OR LEN(@EncryptedCardholderName) = 0)
        BEGIN
            SET @ResultCode = -7;
            SET @ResultMessage = N'Encrypted cardholder name is required for card payments.';
            RETURN;
        END

        IF (@ExpirationMonth < 1 OR @ExpirationMonth > 12)
        BEGIN
            SET @ResultCode = -8;
            SET @ResultMessage = N'Expiration month is invalid.';
            RETURN;
        END

        IF (@ExpirationYear < YEAR(GETUTCDATE()) OR @ExpirationYear > YEAR(GETUTCDATE()) + 30)
        BEGIN
            SET @ResultCode = -9;
            SET @ResultMessage = N'Expiration year is invalid.';
            RETURN;
        END
    END

    IF (@PaymentMethod = 'Transferencia')
    BEGIN
        IF (@TransferReference IS NULL OR LTRIM(RTRIM(@TransferReference)) = '')
        BEGIN
            SET @ResultCode = -10;
            SET @ResultMessage = N'Transfer reference is required for bank transfer payments.';
            RETURN;
        END
    END

    IF (@PaymentMethod = 'PagoCombinado')
    BEGIN
        IF (@SecondPaymentMethod IS NULL OR @SecondPaymentMethod NOT IN ('Tarjeta', 'Transferencia', 'CuentaCorriente'))
        BEGIN
            SET @ResultCode = -11;
            SET @ResultMessage = N'Second payment method is required for combined payments.';
            RETURN;
        END

        IF (@SecondPaymentMethod = 'Transferencia' AND (@SecondTransferReference IS NULL OR LTRIM(RTRIM(@SecondTransferReference)) = ''))
        BEGIN
            SET @ResultCode = -12;
            SET @ResultMessage = N'Second transfer reference is required.';
            RETURN;
        END
    END

    DECLARE @ProductPrice DECIMAL(18,2);
    DECLARE @ProductName NVARCHAR(200);
    DECLARE @NowUtc DATETIME = GETUTCDATE();
    DECLARE @BillingDocumentNumber NVARCHAR(50);

    SELECT
        @ProductPrice = Price,
        @ProductName = Name
    FROM dbo.Products
    WHERE ProductId = @ProductId
      AND IsActive = 1;

    IF (@ProductPrice IS NULL)
    BEGIN
        SET @ResultCode = -13;
        SET @ResultMessage = N'Product not found or inactive.';
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM dbo.ProductSubscriptions
        WHERE UserId = @UserId
          AND ProductId = @ProductId
          AND IsActive = 1
    )
    BEGIN
        SET @ResultCode = -14;
        SET @ResultMessage = N'User already has an active subscription for this product.';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.ProductSubscriptions
        (
            UserId,
            ProductId,
            PaymentMethod,
            CardholderName,
            CardLast4,
            CardBrand,
            EncryptedCardNumber,
            EncryptedCardholderName,
            ExpirationMonth,
            ExpirationYear,
            TransferReference,
            SecondPaymentMethod,
            SecondTransferReference
        )
        VALUES
        (
            @UserId,
            @ProductId,
            @PaymentMethod,
            NULLIF(LTRIM(RTRIM(@CardholderName)), ''),
            NULLIF(@CardLast4, ''),
            NULLIF(LTRIM(RTRIM(@CardBrand)), ''),
            NULLIF(LTRIM(RTRIM(@EncryptedCardNumber)), ''),
            NULLIF(LTRIM(RTRIM(@EncryptedCardholderName)), ''),
            @ExpirationMonth,
            @ExpirationYear,
            NULLIF(LTRIM(RTRIM(@TransferReference)), ''),
            NULLIF(LTRIM(RTRIM(@SecondPaymentMethod)), ''),
            NULLIF(LTRIM(RTRIM(@SecondTransferReference)), '')
        );

        SET @NewSubscriptionId = SCOPE_IDENTITY();
        SET @BillingDocumentNumber = CONCAT('INV-SUB-', CONVERT(NVARCHAR(20), @NewSubscriptionId));

        INSERT INTO dbo.BillingDocuments
        (
            UserId,
            DocumentType,
            DocumentNumber,
            ReferenceDocumentId,
            IssueDateUtc,
            DueDateUtc,
            CurrencyCode,
            SubtotalAmount,
            TaxAmount,
            TotalAmount,
            Status,
            SubscriptionId,
            PrimaryPaymentMethod,
            SecondaryPaymentMethod,
            CardBrand,
            CardLast4,
            TransferReference,
            SecondTransferReference,
            Notes,
            CreatedBy,
            CreatedDateUtc,
            LastModifiedBy,
            LastModifiedDateUtc
        )
        VALUES
        (
            @UserId,
            'Invoice',
            @BillingDocumentNumber,
            NULL,
            @NowUtc,
            NULL,
            'ARS',
            @ProductPrice,
            0,
            @ProductPrice,
            'Paid',
            @NewSubscriptionId,
            @PaymentMethod,
            NULLIF(LTRIM(RTRIM(@SecondPaymentMethod)), ''),
            NULLIF(LTRIM(RTRIM(@CardBrand)), ''),
            NULLIF(@CardLast4, ''),
            NULLIF(LTRIM(RTRIM(@TransferReference)), ''),
            NULLIF(LTRIM(RTRIM(@SecondTransferReference)), ''),
            NULL,
            @UserId,
            @NowUtc,
            NULL,
            NULL
        );

        INSERT INTO dbo.BillingDocumentItems
        (
            BillingDocumentId,
            ProductId,
            Description,
            Quantity,
            UnitPrice,
            TaxRate,
            LineSubtotal,
            LineTaxAmount,
            LineTotal,
            LineNotes
        )
        VALUES
        (
            SCOPE_IDENTITY(),
            @ProductId,
            LEFT(ISNULL(@ProductName, 'Subscription product'), 300),
            1,
            @ProductPrice,
            0,
            @ProductPrice,
            0,
            @ProductPrice,
            NULL
        );

        COMMIT TRANSACTION;

        SET @ResultCode = 1;
        SET @ResultMessage = N'Subscription created successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @ResultCode = -50001;
        SET @ResultMessage = CONCAT(N'Error creating subscription: ', ERROR_MESSAGE());
    END CATCH
END
GO
