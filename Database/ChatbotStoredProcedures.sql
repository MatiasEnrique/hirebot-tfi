-- =============================================
-- Chatbot Management System - SQL Server Stored Procedures
-- Author: Claude Code (SQL Stored Procedure Expert)
-- Create date: 2025-09-08
-- Description: Complete chatbot management system with organization assignment and comprehensive validation
-- Version: 1.0
-- =============================================

-- =============================================
-- TABLE CREATION SCRIPTS
-- =============================================

-- Chatbots Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Chatbots')
BEGIN
    CREATE TABLE Chatbots (
        chatbot_id INT IDENTITY(1,1) PRIMARY KEY,
        organization_id INT NULL,
        name NVARCHAR(255) NOT NULL,
        instructions NVARCHAR(MAX) NOT NULL,
        color NVARCHAR(7) NOT NULL, -- Hex color code format #RRGGBB
        created_date DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        updated_date DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        is_active BIT NOT NULL DEFAULT 1,
        CONSTRAINT FK_Chatbots_Organizations FOREIGN KEY (organization_id) REFERENCES Organizations(Id),
        CONSTRAINT CK_Chatbots_Color CHECK (color LIKE '#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]')
    );
    
    -- Create indexes for performance
    CREATE INDEX IX_Chatbots_OrganizationId ON Chatbots(organization_id);
    CREATE INDEX IX_Chatbots_IsActive ON Chatbots(is_active);
    CREATE INDEX IX_Chatbots_Name ON Chatbots(name);
    CREATE INDEX IX_Chatbots_CreatedDate ON Chatbots(created_date);
    
    PRINT 'Chatbots table created successfully';
END
ELSE
BEGIN
    PRINT 'Chatbots table already exists';
END
GO

-- Chatbot Audit Log Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatbotAuditLog')
BEGIN
    CREATE TABLE ChatbotAuditLog (
        audit_id INT IDENTITY(1,1) PRIMARY KEY,
        chatbot_id INT NOT NULL,
        action_type NVARCHAR(50) NOT NULL, -- CREATE, UPDATE, DELETE, ASSIGN, UNASSIGN
        old_values NVARCHAR(MAX) NULL,
        new_values NVARCHAR(MAX) NULL,
        modified_by NVARCHAR(100) NULL,
        modified_date DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        organization_id INT NULL,
        CONSTRAINT FK_ChatbotAuditLog_Chatbots FOREIGN KEY (chatbot_id) REFERENCES Chatbots(chatbot_id)
    );
    
    -- Create indexes for audit log
    CREATE INDEX IX_ChatbotAuditLog_ChatbotId ON ChatbotAuditLog(chatbot_id);
    CREATE INDEX IX_ChatbotAuditLog_ModifiedDate ON ChatbotAuditLog(modified_date);
    CREATE INDEX IX_ChatbotAuditLog_ActionType ON ChatbotAuditLog(action_type);
    
    PRINT 'ChatbotAuditLog table created successfully';
END
ELSE
BEGIN
    PRINT 'ChatbotAuditLog table already exists';
END
GO

-- =============================================
-- HELPER FUNCTIONS AND PROCEDURES
-- =============================================

-- Helper procedure for audit logging
CREATE OR ALTER PROCEDURE sp_ChatbotAuditLog
    @ChatbotId INT,
    @ActionType NVARCHAR(50),
    @OldValues NVARCHAR(MAX) = NULL,
    @NewValues NVARCHAR(MAX) = NULL,
    @ModifiedBy NVARCHAR(100) = NULL,
    @OrganizationId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO ChatbotAuditLog (chatbot_id, action_type, old_values, new_values, modified_by, organization_id)
    VALUES (@ChatbotId, @ActionType, @OldValues, @NewValues, @ModifiedBy, @OrganizationId);
END
GO

-- Helper function to validate hex color format
CREATE OR ALTER FUNCTION dbo.fn_IsValidHexColor(@Color NVARCHAR(7))
RETURNS BIT
AS
BEGIN
    DECLARE @IsValid BIT = 0;
    
    IF @Color IS NOT NULL 
       AND LEN(@Color) = 7 
       AND LEFT(@Color, 1) = '#'
       AND @Color LIKE '#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]'
    BEGIN
        SET @IsValid = 1;
    END
    
    RETURN @IsValid;
END
GO

-- =============================================
-- STORED PROCEDURE: sp_CreateChatbot
-- Description: Insert new chatbot with comprehensive validation
-- Parameters:  
--   @Name - Chatbot name (required)
--   @Instructions - Chatbot instructions (required)
--   @Color - Hex color code (required, format #RRGGBB)
--   @OrganizationId - Organization ID (optional)
--   @CreatedBy - User who created the chatbot (optional for logging)
-- Returns: 0 for success, negative values for specific errors
-- =============================================
CREATE OR ALTER PROCEDURE sp_CreateChatbot
    @Name NVARCHAR(255),
    @Instructions NVARCHAR(MAX),
    @Color NVARCHAR(7),
    @OrganizationId INT = NULL,
    @CreatedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Parameter validation
        IF @Name IS NULL OR LTRIM(RTRIM(@Name)) = ''
        BEGIN
            RAISERROR('Chatbot name is required', 16, 1);
            RETURN -1;
        END
        
        IF LEN(LTRIM(RTRIM(@Name))) > 255
        BEGIN
            RAISERROR('Chatbot name cannot exceed 255 characters', 16, 1);
            RETURN -2;
        END
        
        IF @Instructions IS NULL OR LTRIM(RTRIM(@Instructions)) = ''
        BEGIN
            RAISERROR('Chatbot instructions are required', 16, 1);
            RETURN -3;
        END
        
        IF @Color IS NULL OR LTRIM(RTRIM(@Color)) = ''
        BEGIN
            RAISERROR('Chatbot color is required', 16, 1);
            RETURN -4;
        END
        
        -- Validate hex color format using helper function
        IF dbo.fn_IsValidHexColor(@Color) = 0
        BEGIN
            RAISERROR('Color must be a valid hex code format (#RRGGBB)', 16, 1);
            RETURN -5;
        END
        
        -- Validate organization exists if provided
        IF @OrganizationId IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM Organizations WHERE Id = @OrganizationId AND IsActive = 1
        )
        BEGIN
            RAISERROR('Organization not found or inactive', 16, 1);
            RETURN -6;
        END
        
        -- Check for duplicate chatbot name within the same organization or global scope
        IF (@OrganizationId IS NULL AND EXISTS (
            SELECT 1 FROM Chatbots WHERE name = @Name AND organization_id IS NULL AND is_active = 1
        ))
        OR (@OrganizationId IS NOT NULL AND EXISTS (
            SELECT 1 FROM Chatbots WHERE name = @Name AND organization_id = @OrganizationId AND is_active = 1
        ))
        BEGIN
            RAISERROR('A chatbot with this name already exists in the specified scope', 16, 1);
            RETURN -7;
        END
        
        -- Create chatbot
        DECLARE @NewChatbotId INT;
        DECLARE @CurrentDateTime DATETIME2 = GETUTCDATE();
        
        INSERT INTO Chatbots (
            organization_id, 
            name, 
            instructions, 
            color, 
            created_date, 
            updated_date, 
            is_active
        )
        VALUES (
            @OrganizationId,
            LTRIM(RTRIM(@Name)),
            @Instructions,
            UPPER(@Color),
            @CurrentDateTime,
            @CurrentDateTime,
            1
        );
        
        SET @NewChatbotId = SCOPE_IDENTITY();
        
        -- Log the creation
        DECLARE @NewValues NVARCHAR(MAX) = CONCAT(
            'Name: ', @Name, 
            ', Instructions: ', LEFT(@Instructions, 100), '...', 
            ', Color: ', @Color,
            ', OrganizationId: ', ISNULL(CAST(@OrganizationId AS NVARCHAR), 'NULL')
        );
        
        EXEC sp_ChatbotAuditLog @NewChatbotId, 'CREATE', NULL, @NewValues, @CreatedBy, @OrganizationId;
        
        COMMIT TRANSACTION;
        
        -- Return new chatbot details
        SELECT 
            chatbot_id,
            organization_id,
            name,
            instructions,
            color,
            created_date,
            updated_date,
            is_active
        FROM Chatbots 
        WHERE chatbot_id = @NewChatbotId;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ERROR_PROCEDURE();
        
        RAISERROR('Error in %s at line %d: %s', @ErrorSeverity, @ErrorState, 
                  @ErrorProcedure, @ErrorLine, @ErrorMessage);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: sp_GetChatbotById
-- Description: Get single chatbot by ID
-- Parameters: @ChatbotId - Chatbot identifier
-- Returns: 0 for success, negative values for errors
-- =============================================
CREATE OR ALTER PROCEDURE sp_GetChatbotById
    @ChatbotId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Parameter validation
        IF @ChatbotId IS NULL OR @ChatbotId <= 0
        BEGIN
            RAISERROR('Valid chatbot ID is required', 16, 1);
            RETURN -1;
        END
        
        -- Get chatbot with organization details
        SELECT 
            c.chatbot_id,
            c.organization_id,
            o.Name as organization_name,
            c.name,
            c.instructions,
            c.color,
            c.created_date,
            c.updated_date,
            c.is_active
        FROM Chatbots c
        LEFT JOIN Organizations o ON c.organization_id = o.Id
        WHERE c.chatbot_id = @ChatbotId;
        
        -- Check if chatbot was found
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Chatbot not found', 16, 1);
            RETURN -2;
        END
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ERROR_PROCEDURE();
        
        RAISERROR('Error in %s at line %d: %s', @ErrorSeverity, @ErrorState, 
                  @ErrorProcedure, @ErrorLine, @ErrorMessage);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: sp_GetAllChatbots
-- Description: Get all chatbots with pagination support and optional name search
-- Parameters:  
--   @PageNumber - Page number (default 1)
--   @PageSize - Records per page (default 10, max 100)
--   @SortColumn - Column to sort by (default 'created_date')
--   @SortDirection - ASC or DESC (default 'DESC')
--   @IncludeInactive - Include inactive chatbots (default 0)
--   @NameFilter - Optional chatbot name filter (searches for partial match)
--   @OrganizationId - Optional organization filter (NULL for all, -1 for unassigned)
-- Returns: 0 for success, negative values for errors
-- =============================================
CREATE OR ALTER PROCEDURE sp_GetAllChatbots
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(50) = 'created_date',
    @SortDirection NVARCHAR(4) = 'DESC',
    @IncludeInactive BIT = 0,
    @NameFilter NVARCHAR(255) = NULL,
    @OrganizationId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Parameter validation
        IF @PageNumber < 1 SET @PageNumber = 1;
        IF @PageSize < 1 SET @PageSize = 10;
        IF @PageSize > 100 SET @PageSize = 100;
        
        IF @SortColumn NOT IN ('chatbot_id', 'name', 'created_date', 'updated_date', 'organization_name')
            SET @SortColumn = 'created_date';
            
        IF @SortDirection NOT IN ('ASC', 'DESC')
            SET @SortDirection = 'DESC';
        
        -- Calculate offset
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
        
        -- Normalize name filter
        SET @NameFilter = NULLIF(LTRIM(RTRIM(@NameFilter)), '');
        
        -- Build WHERE conditions
        DECLARE @WhereConditions NVARCHAR(MAX) = '(@IncludeInactive = 1 OR c.is_active = 1)';
        
        -- Add name filter condition
        IF @NameFilter IS NOT NULL
        BEGIN
            SET @WhereConditions = @WhereConditions + ' AND c.name LIKE ''%' + REPLACE(@NameFilter, '''', '''''') + '%''';
        END
        
        -- Add organization filter condition
        IF @OrganizationId IS NOT NULL
        BEGIN
            IF @OrganizationId = -1
            BEGIN
                -- Filter for unassigned chatbots
                SET @WhereConditions = @WhereConditions + ' AND c.organization_id IS NULL';
            END
            ELSE
            BEGIN
                -- Filter for specific organization
                SET @WhereConditions = @WhereConditions + ' AND c.organization_id = ' + CAST(@OrganizationId AS NVARCHAR);
            END
        END
        
        -- Get total count with dynamic WHERE clause
        DECLARE @CountSQL NVARCHAR(MAX) = N'
        SELECT @TotalRecordsOut = COUNT(*)
        FROM Chatbots c
        LEFT JOIN Organizations o ON c.organization_id = o.Id
        WHERE ' + @WhereConditions;
        
        DECLARE @TotalRecords INT;
        EXEC sp_executesql @CountSQL, N'@IncludeInactive BIT, @TotalRecordsOut INT OUTPUT', 
                          @IncludeInactive, @TotalRecords OUTPUT;
        
        -- Get paginated results with dynamic sorting and filtering
        DECLARE @SQL NVARCHAR(MAX) = N'
        SELECT 
            c.chatbot_id,
            c.organization_id,
            o.Name as organization_name,
            c.name,
            c.instructions,
            c.color,
            c.created_date,
            c.updated_date,
            c.is_active,
            ' + CAST(@TotalRecords AS NVARCHAR) + ' as total_records,
            ' + CAST(@PageNumber AS NVARCHAR) + ' as current_page,
            ' + CAST(@PageSize AS NVARCHAR) + ' as page_size,
            CEILING(CAST(' + CAST(@TotalRecords AS NVARCHAR) + ' AS FLOAT) / ' + CAST(@PageSize AS NVARCHAR) + ') as total_pages
        FROM Chatbots c
        LEFT JOIN Organizations o ON c.organization_id = o.Id
        WHERE ' + @WhereConditions + '
        ORDER BY ' + @SortColumn + ' ' + @SortDirection + '
        OFFSET ' + CAST(@Offset AS NVARCHAR) + ' ROWS
        FETCH NEXT ' + CAST(@PageSize AS NVARCHAR) + ' ROWS ONLY';
        
        EXEC sp_executesql @SQL, N'@IncludeInactive BIT', @IncludeInactive;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ERROR_PROCEDURE();
        
        RAISERROR('Error in %s at line %d: %s', @ErrorSeverity, @ErrorState, 
                  @ErrorProcedure, @ErrorLine, @ErrorMessage);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: sp_GetChatbotsByOrganization
-- Description: Get chatbots filtered by organization
-- Parameters:  
--   @OrganizationId - Organization ID (NULL for unassigned chatbots)
--   @PageNumber - Page number (default 1)
--   @PageSize - Records per page (default 10)
--   @IncludeInactive - Include inactive chatbots (default 0)
-- Returns: 0 for success, negative values for errors
-- =============================================
CREATE OR ALTER PROCEDURE sp_GetChatbotsByOrganization
    @OrganizationId INT = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Parameter validation
        IF @PageNumber < 1 SET @PageNumber = 1;
        IF @PageSize < 1 SET @PageSize = 10;
        IF @PageSize > 100 SET @PageSize = 100;
        
        -- Validate organization exists if provided
        IF @OrganizationId IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM Organizations WHERE Id = @OrganizationId
        )
        BEGIN
            RAISERROR('Organization not found', 16, 1);
            RETURN -1;
        END
        
        -- Calculate offset
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
        
        -- Get total count for the specific organization filter
        DECLARE @TotalRecords INT;
        SELECT @TotalRecords = COUNT(*)
        FROM Chatbots c
        WHERE (
            (@OrganizationId IS NULL AND c.organization_id IS NULL) OR 
            (@OrganizationId IS NOT NULL AND c.organization_id = @OrganizationId)
        )
        AND (@IncludeInactive = 1 OR c.is_active = 1);
        
        -- Get paginated results
        SELECT 
            c.chatbot_id,
            c.organization_id,
            o.Name as organization_name,
            c.name,
            c.instructions,
            c.color,
            c.created_date,
            c.updated_date,
            c.is_active,
            @TotalRecords as total_records,
            @PageNumber as current_page,
            @PageSize as page_size,
            CEILING(CAST(@TotalRecords AS FLOAT) / @PageSize) as total_pages
        FROM Chatbots c
        LEFT JOIN Organizations o ON c.organization_id = o.Id
        WHERE (
            (@OrganizationId IS NULL AND c.organization_id IS NULL) OR 
            (@OrganizationId IS NOT NULL AND c.organization_id = @OrganizationId)
        )
        AND (@IncludeInactive = 1 OR c.is_active = 1)
        ORDER BY c.created_date DESC
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ERROR_PROCEDURE();
        
        RAISERROR('Error in %s at line %d: %s', @ErrorSeverity, @ErrorState, 
                  @ErrorProcedure, @ErrorLine, @ErrorMessage);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: sp_UpdateChatbot
-- Description: Update chatbot details with comprehensive validation
-- Parameters:  
--   @ChatbotId - Chatbot identifier (required)
--   @Name - Chatbot name (required)
--   @Instructions - Chatbot instructions (required)
--   @Color - Hex color code (required)
--   @ModifiedBy - User who modified the chatbot (optional for logging)
-- Returns: 0 for success, negative values for errors
-- =============================================
CREATE OR ALTER PROCEDURE sp_UpdateChatbot
    @ChatbotId INT,
    @Name NVARCHAR(255),
    @Instructions NVARCHAR(MAX),
    @Color NVARCHAR(7),
    @ModifiedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Parameter validation
        IF @ChatbotId IS NULL OR @ChatbotId <= 0
        BEGIN
            RAISERROR('Valid chatbot ID is required', 16, 1);
            RETURN -1;
        END
        
        IF @Name IS NULL OR LTRIM(RTRIM(@Name)) = ''
        BEGIN
            RAISERROR('Chatbot name is required', 16, 1);
            RETURN -2;
        END
        
        IF LEN(LTRIM(RTRIM(@Name))) > 255
        BEGIN
            RAISERROR('Chatbot name cannot exceed 255 characters', 16, 1);
            RETURN -3;
        END
        
        IF @Instructions IS NULL OR LTRIM(RTRIM(@Instructions)) = ''
        BEGIN
            RAISERROR('Chatbot instructions are required', 16, 1);
            RETURN -4;
        END
        
        IF @Color IS NULL OR LTRIM(RTRIM(@Color)) = ''
        BEGIN
            RAISERROR('Chatbot color is required', 16, 1);
            RETURN -5;
        END
        
        -- Validate hex color format
        IF dbo.fn_IsValidHexColor(@Color) = 0
        BEGIN
            RAISERROR('Color must be a valid hex code format (#RRGGBB)', 16, 1);
            RETURN -6;
        END
        
        -- Check if chatbot exists and is active
        DECLARE @CurrentOrgId INT, @CurrentName NVARCHAR(255), @CurrentInstructions NVARCHAR(MAX), @CurrentColor NVARCHAR(7);
        
        SELECT 
            @CurrentOrgId = organization_id,
            @CurrentName = name,
            @CurrentInstructions = instructions,
            @CurrentColor = color
        FROM Chatbots 
        WHERE chatbot_id = @ChatbotId AND is_active = 1;
        
        IF @CurrentOrgId IS NULL AND @CurrentName IS NULL
        BEGIN
            RAISERROR('Chatbot not found or inactive', 16, 1);
            RETURN -7;
        END
        
        -- Check for duplicate chatbot name (excluding current chatbot)
        IF (@CurrentOrgId IS NULL AND EXISTS (
            SELECT 1 FROM Chatbots 
            WHERE name = @Name AND organization_id IS NULL AND is_active = 1 AND chatbot_id != @ChatbotId
        ))
        OR (@CurrentOrgId IS NOT NULL AND EXISTS (
            SELECT 1 FROM Chatbots 
            WHERE name = @Name AND organization_id = @CurrentOrgId AND is_active = 1 AND chatbot_id != @ChatbotId
        ))
        BEGIN
            RAISERROR('A chatbot with this name already exists in the specified scope', 16, 1);
            RETURN -8;
        END
        
        -- Prepare audit values
        DECLARE @OldValues NVARCHAR(MAX) = CONCAT(
            'Name: ', @CurrentName, 
            ', Instructions: ', LEFT(@CurrentInstructions, 100), '...', 
            ', Color: ', @CurrentColor
        );
        
        DECLARE @NewValues NVARCHAR(MAX) = CONCAT(
            'Name: ', @Name, 
            ', Instructions: ', LEFT(@Instructions, 100), '...', 
            ', Color: ', @Color
        );
        
        -- Update chatbot
        UPDATE Chatbots 
        SET 
            name = LTRIM(RTRIM(@Name)),
            instructions = @Instructions,
            color = UPPER(@Color),
            updated_date = GETUTCDATE()
        WHERE chatbot_id = @ChatbotId;
        
        -- Log the update
        EXEC sp_ChatbotAuditLog @ChatbotId, 'UPDATE', @OldValues, @NewValues, @ModifiedBy, @CurrentOrgId;
        
        COMMIT TRANSACTION;
        
        -- Return updated chatbot details
        SELECT 
            c.chatbot_id,
            c.organization_id,
            o.Name as organization_name,
            c.name,
            c.instructions,
            c.color,
            c.created_date,
            c.updated_date,
            c.is_active
        FROM Chatbots c
        LEFT JOIN Organizations o ON c.organization_id = o.Id
        WHERE c.chatbot_id = @ChatbotId;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ERROR_PROCEDURE();
        
        RAISERROR('Error in %s at line %d: %s', @ErrorSeverity, @ErrorState, 
                  @ErrorProcedure, @ErrorLine, @ErrorMessage);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: sp_DeleteChatbot
-- Description: Soft delete chatbot (set is_active = 0)
-- Parameters:  
--   @ChatbotId - Chatbot identifier (required)
--   @DeletedBy - User who deleted the chatbot (optional for logging)
-- Returns: 0 for success, negative values for errors
-- =============================================
CREATE OR ALTER PROCEDURE sp_DeleteChatbot
    @ChatbotId INT,
    @DeletedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Parameter validation
        IF @ChatbotId IS NULL OR @ChatbotId <= 0
        BEGIN
            RAISERROR('Valid chatbot ID is required', 16, 1);
            RETURN -1;
        END
        
        -- Check if chatbot exists and is active
        DECLARE @ChatbotName NVARCHAR(255), @OrgId INT;
        
        SELECT 
            @ChatbotName = name,
            @OrgId = organization_id
        FROM Chatbots 
        WHERE chatbot_id = @ChatbotId AND is_active = 1;
        
        IF @ChatbotName IS NULL
        BEGIN
            RAISERROR('Chatbot not found or already inactive', 16, 1);
            RETURN -2;
        END
        
        -- Soft delete the chatbot
        UPDATE Chatbots 
        SET 
            is_active = 0,
            updated_date = GETUTCDATE()
        WHERE chatbot_id = @ChatbotId;
        
        -- Log the deletion
        DECLARE @OldValues NVARCHAR(MAX) = CONCAT('Name: ', @ChatbotName, ', IsActive: 1');
        DECLARE @NewValues NVARCHAR(MAX) = CONCAT('Name: ', @ChatbotName, ', IsActive: 0');
        
        EXEC sp_ChatbotAuditLog @ChatbotId, 'DELETE', @OldValues, @NewValues, @DeletedBy, @OrgId;
        
        COMMIT TRANSACTION;
        
        -- Return success message
        SELECT 
            @ChatbotId as chatbot_id,
            'Chatbot successfully deleted' as message,
            GETUTCDATE() as deleted_date;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ERROR_PROCEDURE();
        
        RAISERROR('Error in %s at line %d: %s', @ErrorSeverity, @ErrorState, 
                  @ErrorProcedure, @ErrorLine, @ErrorMessage);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: sp_AssignChatbotToOrganization
-- Description: Assign chatbot to organization with validation
-- Parameters:  
--   @ChatbotId - Chatbot identifier (required)
--   @OrganizationId - Organization identifier (required)
--   @AssignedBy - User who assigned the chatbot (optional for logging)
-- Returns: 0 for success, negative values for errors
-- =============================================
CREATE OR ALTER PROCEDURE sp_AssignChatbotToOrganization
    @ChatbotId INT,
    @OrganizationId INT,
    @AssignedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Parameter validation
        IF @ChatbotId IS NULL OR @ChatbotId <= 0
        BEGIN
            RAISERROR('Valid chatbot ID is required', 16, 1);
            RETURN -1;
        END
        
        IF @OrganizationId IS NULL OR @OrganizationId <= 0
        BEGIN
            RAISERROR('Valid organization ID is required', 16, 1);
            RETURN -2;
        END
        
        -- Check if chatbot exists and is active
        DECLARE @ChatbotName NVARCHAR(255), @CurrentOrgId INT;
        
        SELECT 
            @ChatbotName = name,
            @CurrentOrgId = organization_id
        FROM Chatbots 
        WHERE chatbot_id = @ChatbotId AND is_active = 1;
        
        IF @ChatbotName IS NULL
        BEGIN
            RAISERROR('Chatbot not found or inactive', 16, 1);
            RETURN -3;
        END
        
        -- Check if organization exists and is active
        IF NOT EXISTS (SELECT 1 FROM Organizations WHERE Id = @OrganizationId AND IsActive = 1)
        BEGIN
            RAISERROR('Organization not found or inactive', 16, 1);
            RETURN -4;
        END
        
        -- Check if chatbot is already assigned to this organization
        IF @CurrentOrgId = @OrganizationId
        BEGIN
            RAISERROR('Chatbot is already assigned to this organization', 16, 1);
            RETURN -5;
        END
        
        -- Check for duplicate chatbot name within target organization
        IF EXISTS (
            SELECT 1 FROM Chatbots 
            WHERE name = @ChatbotName AND organization_id = @OrganizationId AND is_active = 1
        )
        BEGIN
            RAISERROR('A chatbot with this name already exists in the target organization', 16, 1);
            RETURN -6;
        END
        
        -- Assign chatbot to organization
        UPDATE Chatbots 
        SET 
            organization_id = @OrganizationId,
            updated_date = GETUTCDATE()
        WHERE chatbot_id = @ChatbotId;
        
        -- Log the assignment
        DECLARE @OldValues NVARCHAR(MAX) = CONCAT('OrganizationId: ', ISNULL(CAST(@CurrentOrgId AS NVARCHAR), 'NULL'));
        DECLARE @NewValues NVARCHAR(MAX) = CONCAT('OrganizationId: ', @OrganizationId);
        
        EXEC sp_ChatbotAuditLog @ChatbotId, 'ASSIGN', @OldValues, @NewValues, @AssignedBy, @OrganizationId;
        
        COMMIT TRANSACTION;
        
        -- Return updated chatbot details
        SELECT 
            c.chatbot_id,
            c.organization_id,
            o.Name as organization_name,
            c.name,
            c.instructions,
            c.color,
            c.created_date,
            c.updated_date,
            c.is_active,
            'Chatbot successfully assigned to organization' as message
        FROM Chatbots c
        LEFT JOIN Organizations o ON c.organization_id = o.Id
        WHERE c.chatbot_id = @ChatbotId;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ERROR_PROCEDURE();
        
        RAISERROR('Error in %s at line %d: %s', @ErrorSeverity, @ErrorState, 
                  @ErrorProcedure, @ErrorLine, @ErrorMessage);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: sp_UnassignChatbotFromOrganization
-- Description: Unassign chatbot from organization (set organization_id = NULL)
-- Parameters:  
--   @ChatbotId - Chatbot identifier (required)
--   @UnassignedBy - User who unassigned the chatbot (optional for logging)
-- Returns: 0 for success, negative values for errors
-- =============================================
CREATE OR ALTER PROCEDURE sp_UnassignChatbotFromOrganization
    @ChatbotId INT,
    @UnassignedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Parameter validation
        IF @ChatbotId IS NULL OR @ChatbotId <= 0
        BEGIN
            RAISERROR('Valid chatbot ID is required', 16, 1);
            RETURN -1;
        END
        
        -- Check if chatbot exists and is active
        DECLARE @ChatbotName NVARCHAR(255), @CurrentOrgId INT;
        
        SELECT 
            @ChatbotName = name,
            @CurrentOrgId = organization_id
        FROM Chatbots 
        WHERE chatbot_id = @ChatbotId AND is_active = 1;
        
        IF @ChatbotName IS NULL
        BEGIN
            RAISERROR('Chatbot not found or inactive', 16, 1);
            RETURN -2;
        END
        
        -- Check if chatbot is currently assigned to an organization
        IF @CurrentOrgId IS NULL
        BEGIN
            RAISERROR('Chatbot is not currently assigned to any organization', 16, 1);
            RETURN -3;
        END
        
        -- Check for name conflicts in global scope
        IF EXISTS (
            SELECT 1 FROM Chatbots 
            WHERE name = @ChatbotName AND organization_id IS NULL AND is_active = 1 AND chatbot_id != @ChatbotId
        )
        BEGIN
            RAISERROR('Cannot unassign: A chatbot with this name already exists in the global scope', 16, 1);
            RETURN -4;
        END
        
        -- Unassign chatbot from organization
        UPDATE Chatbots 
        SET 
            organization_id = NULL,
            updated_date = GETUTCDATE()
        WHERE chatbot_id = @ChatbotId;
        
        -- Log the unassignment
        DECLARE @OldValues NVARCHAR(MAX) = CONCAT('OrganizationId: ', @CurrentOrgId);
        DECLARE @NewValues NVARCHAR(MAX) = 'OrganizationId: NULL';
        
        EXEC sp_ChatbotAuditLog @ChatbotId, 'UNASSIGN', @OldValues, @NewValues, @UnassignedBy, NULL;
        
        COMMIT TRANSACTION;
        
        -- Return updated chatbot details
        SELECT 
            c.chatbot_id,
            c.organization_id,
            NULL as organization_name,
            c.name,
            c.instructions,
            c.color,
            c.created_date,
            c.updated_date,
            c.is_active,
            'Chatbot successfully unassigned from organization' as message
        FROM Chatbots c
        WHERE c.chatbot_id = @ChatbotId;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ERROR_PROCEDURE();
        
        RAISERROR('Error in %s at line %d: %s', @ErrorSeverity, @ErrorState, 
                  @ErrorProcedure, @ErrorLine, @ErrorMessage);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- ADDITIONAL UTILITY STORED PROCEDURES
-- =============================================

-- =============================================
-- STORED PROCEDURE: sp_GetChatbotAuditLog
-- Description: Get audit log for a specific chatbot
-- Parameters:  
--   @ChatbotId - Chatbot identifier (required)
--   @PageNumber - Page number (default 1)
--   @PageSize - Records per page (default 20)
-- Returns: 0 for success, negative values for errors
-- =============================================
CREATE OR ALTER PROCEDURE sp_GetChatbotAuditLog
    @ChatbotId INT,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Parameter validation
        IF @ChatbotId IS NULL OR @ChatbotId <= 0
        BEGIN
            RAISERROR('Valid chatbot ID is required', 16, 1);
            RETURN -1;
        END
        
        IF @PageNumber < 1 SET @PageNumber = 1;
        IF @PageSize < 1 SET @PageSize = 20;
        IF @PageSize > 100 SET @PageSize = 100;
        
        -- Calculate offset
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
        
        -- Get total count
        DECLARE @TotalRecords INT;
        SELECT @TotalRecords = COUNT(*) FROM ChatbotAuditLog WHERE chatbot_id = @ChatbotId;
        
        -- Get paginated audit log
        SELECT 
            audit_id,
            chatbot_id,
            action_type,
            old_values,
            new_values,
            modified_by,
            modified_date,
            organization_id,
            @TotalRecords as total_records,
            @PageNumber as current_page,
            @PageSize as page_size,
            CEILING(CAST(@TotalRecords AS FLOAT) / @PageSize) as total_pages
        FROM ChatbotAuditLog
        WHERE chatbot_id = @ChatbotId
        ORDER BY modified_date DESC
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ERROR_PROCEDURE();
        
        RAISERROR('Error in %s at line %d: %s', @ErrorSeverity, @ErrorState, 
                  @ErrorProcedure, @ErrorLine, @ErrorMessage);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: sp_GetChatbotStatistics
-- Description: Get statistics about chatbots in the system
-- Returns: 0 for success, negative values for errors
-- =============================================
CREATE OR ALTER PROCEDURE sp_GetChatbotStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            COUNT(*) as total_chatbots,
            COUNT(CASE WHEN is_active = 1 THEN 1 END) as active_chatbots,
            COUNT(CASE WHEN is_active = 0 THEN 1 END) as inactive_chatbots,
            COUNT(CASE WHEN organization_id IS NULL AND is_active = 1 THEN 1 END) as unassigned_active_chatbots,
            COUNT(CASE WHEN organization_id IS NOT NULL AND is_active = 1 THEN 1 END) as assigned_active_chatbots,
            COUNT(DISTINCT organization_id) as organizations_with_chatbots,
            MIN(created_date) as first_chatbot_created,
            MAX(created_date) as last_chatbot_created,
            AVG(CAST(LEN(instructions) AS FLOAT)) as avg_instructions_length
        FROM Chatbots;
        
        -- Get chatbots per organization
        SELECT 
            o.Id as organization_id,
            o.Name as organization_name,
            COUNT(c.chatbot_id) as chatbot_count,
            COUNT(CASE WHEN c.is_active = 1 THEN 1 END) as active_chatbot_count
        FROM Organizations o
        LEFT JOIN Chatbots c ON o.Id = c.organization_id
        GROUP BY o.Id, o.Name
        HAVING COUNT(c.chatbot_id) > 0
        ORDER BY chatbot_count DESC;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ERROR_PROCEDURE();
        
        RAISERROR('Error in %s at line %d: %s', @ErrorSeverity, @ErrorState, 
                  @ErrorProcedure, @ErrorLine, @ErrorMessage);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- SUCCESS MESSAGE
-- =============================================
PRINT '===========================================';
PRINT 'Chatbot Management System Setup Complete!';
PRINT 'Created Tables:';
PRINT '- Chatbots (with foreign key to Organizations)';
PRINT '- ChatbotAuditLog (audit trail for all operations)';
PRINT '';
PRINT 'Created Stored Procedures:';
PRINT '- sp_CreateChatbot';
PRINT '- sp_GetChatbotById';
PRINT '- sp_GetAllChatbots';
PRINT '- sp_GetChatbotsByOrganization';
PRINT '- sp_UpdateChatbot';
PRINT '- sp_DeleteChatbot';
PRINT '- sp_AssignChatbotToOrganization';
PRINT '- sp_UnassignChatbotFromOrganization';
PRINT '- sp_GetChatbotAuditLog';
PRINT '- sp_GetChatbotStatistics';
PRINT '';
PRINT 'Helper Functions:';
PRINT '- fn_IsValidHexColor';
PRINT '- sp_ChatbotAuditLog';
PRINT '===========================================';