-- =============================================
-- Organization Administration System - SQL Server Stored Procedures
-- Author: Claude Code (SQL Stored Procedure Expert)
-- Create date: 2025-09-06
-- Description: Complete organization management system with member roles and security
-- Version: 1.0
-- =============================================

-- =============================================
-- TABLE CREATION SCRIPTS
-- =============================================

-- Organizations Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Organizations')
BEGIN
    CREATE TABLE Organizations (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL,
        Slug NVARCHAR(50) NOT NULL UNIQUE,
        Description NVARCHAR(500) NULL,
        OwnerId INT NOT NULL,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        ModifiedDate DATETIME NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        CONSTRAINT FK_Organizations_Users FOREIGN KEY (OwnerId) REFERENCES Users(UserId)
    );
    
    -- Create indexes for performance
    CREATE INDEX IX_Organizations_OwnerId ON Organizations(OwnerId);
    CREATE INDEX IX_Organizations_Slug ON Organizations(Slug);
    CREATE INDEX IX_Organizations_IsActive ON Organizations(IsActive);
    
    PRINT 'Organizations table created successfully';
END
ELSE
BEGIN
    PRINT 'Organizations table already exists';
END
GO

-- Organization Members Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrganizationMembers')
BEGIN
    CREATE TABLE OrganizationMembers (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        OrganizationId INT NOT NULL,
        UserId INT NOT NULL,
        Role NVARCHAR(50) NOT NULL CHECK (Role IN ('organization_admin', 'member')),
        JoinedDate DATETIME NOT NULL DEFAULT GETDATE(),
        IsActive BIT NOT NULL DEFAULT 1,
        CONSTRAINT FK_OrganizationMembers_Organizations FOREIGN KEY (OrganizationId) REFERENCES Organizations(Id),
        CONSTRAINT FK_OrganizationMembers_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
        CONSTRAINT UQ_OrganizationMembers_OrgUser UNIQUE (OrganizationId, UserId)
    );
    
    -- Create indexes for performance
    CREATE INDEX IX_OrganizationMembers_OrganizationId ON OrganizationMembers(OrganizationId);
    CREATE INDEX IX_OrganizationMembers_UserId ON OrganizationMembers(UserId);
    CREATE INDEX IX_OrganizationMembers_Role ON OrganizationMembers(Role);
    
    PRINT 'OrganizationMembers table created successfully';
END
ELSE
BEGIN
    PRINT 'OrganizationMembers table already exists';
END
GO

-- =============================================
-- ORGANIZATION STORED PROCEDURES
-- =============================================

-- =============================================
-- sp_CreateOrganization
-- Creates a new organization (only admin users can create)
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateOrganization')
    DROP PROCEDURE sp_CreateOrganization
GO

CREATE PROCEDURE sp_CreateOrganization
    @Name NVARCHAR(100),
    @Slug NVARCHAR(50),
    @Description NVARCHAR(500) = NULL,
    @OwnerId INT,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Input validation
        IF @Name IS NULL OR LTRIM(RTRIM(@Name)) = ''
        BEGIN
            RAISERROR('Organization name is required', 16, 1);
            RETURN -1;
        END
        
        IF @Slug IS NULL OR LTRIM(RTRIM(@Slug)) = ''
        BEGIN
            RAISERROR('Organization slug is required', 16, 1);
            RETURN -2;
        END
        
        -- Validate slug format (alphanumeric and hyphens only)
        IF @Slug NOT LIKE '%[^a-zA-Z0-9-]%' = 0
        BEGIN
            RAISERROR('Slug can only contain letters, numbers, and hyphens', 16, 1);
            RETURN -3;
        END
        
        -- Check if creator is admin
        DECLARE @CreatorRole NVARCHAR(50);
        SELECT @CreatorRole = UserRole FROM Users WHERE UserId = @CreatedBy AND IsActive = 1;
        
        IF @CreatorRole IS NULL
        BEGIN
            RAISERROR('Creator user not found or inactive', 16, 1);
            RETURN -4;
        END
        
        IF @CreatorRole != 'admin'
        BEGIN
            RAISERROR('Only admin users can create organizations', 16, 1);
            RETURN -5;
        END
        
        -- Check if owner exists and is active
        IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @OwnerId AND IsActive = 1)
        BEGIN
            RAISERROR('Owner user not found or inactive', 16, 1);
            RETURN -6;
        END
        
        -- Check if slug already exists
        IF EXISTS (SELECT 1 FROM Organizations WHERE Slug = @Slug)
        BEGIN
            RAISERROR('Organization slug already exists', 16, 1);
            RETURN -7;
        END
        
        -- Create organization
        DECLARE @NewOrgId INT;
        INSERT INTO Organizations (Name, Slug, Description, OwnerId, CreatedDate)
        VALUES (@Name, @Slug, @Description, @OwnerId, GETDATE());
        
        SET @NewOrgId = SCOPE_IDENTITY();
        
        -- Add owner as organization admin
        INSERT INTO OrganizationMembers (OrganizationId, UserId, Role, JoinedDate)
        VALUES (@NewOrgId, @OwnerId, 'organization_admin', GETDATE());
        
        COMMIT TRANSACTION;
        
        -- Return new organization ID
        SELECT @NewOrgId as OrganizationId;
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
-- sp_GetOrganizationById
-- Gets organization details by ID
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetOrganizationById')
    DROP PROCEDURE sp_GetOrganizationById
GO

CREATE PROCEDURE sp_GetOrganizationById
    @OrganizationId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Input validation
        IF @OrganizationId IS NULL OR @OrganizationId <= 0
        BEGIN
            RAISERROR('Valid Organization ID is required', 16, 1);
            RETURN -1;
        END
        
        SELECT 
            o.Id,
            o.Name,
            o.Slug,
            o.Description,
            o.OwnerId,
            u.Username as OwnerUsername,
            u.FirstName + ' ' + u.LastName as OwnerFullName,
            o.CreatedDate,
            o.ModifiedDate,
            o.IsActive,
            (SELECT COUNT(*) FROM OrganizationMembers om WHERE om.OrganizationId = o.Id AND om.IsActive = 1) as MemberCount
        FROM Organizations o
        INNER JOIN Users u ON o.OwnerId = u.UserId
        WHERE o.Id = @OrganizationId AND o.IsActive = 1;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- sp_GetOrganizationBySlug
-- Gets organization details by slug for navigation
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetOrganizationBySlug')
    DROP PROCEDURE sp_GetOrganizationBySlug
GO

CREATE PROCEDURE sp_GetOrganizationBySlug
    @Slug NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Input validation
        IF @Slug IS NULL OR LTRIM(RTRIM(@Slug)) = ''
        BEGIN
            RAISERROR('Organization slug is required', 16, 1);
            RETURN -1;
        END
        
        SELECT 
            o.Id,
            o.Name,
            o.Slug,
            o.Description,
            o.OwnerId,
            u.Username as OwnerUsername,
            u.FirstName + ' ' + u.LastName as OwnerFullName,
            o.CreatedDate,
            o.ModifiedDate,
            o.IsActive,
            (SELECT COUNT(*) FROM OrganizationMembers om WHERE om.OrganizationId = o.Id AND om.IsActive = 1) as MemberCount
        FROM Organizations o
        INNER JOIN Users u ON o.OwnerId = u.UserId
        WHERE o.Slug = @Slug AND o.IsActive = 1;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- sp_GetAllOrganizations
-- Gets all organizations with pagination
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllOrganizations')
    DROP PROCEDURE sp_GetAllOrganizations
GO

CREATE PROCEDURE sp_GetAllOrganizations
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(50) = 'Name',
    @SortDirection NVARCHAR(4) = 'ASC',
    @SearchTerm NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Input validation
        IF @PageNumber < 1 SET @PageNumber = 1;
        IF @PageSize < 1 OR @PageSize > 100 SET @PageSize = 10;
        IF @SortDirection NOT IN ('ASC', 'DESC') SET @SortDirection = 'ASC';
        IF @SortColumn NOT IN ('Name', 'CreatedDate', 'MemberCount') SET @SortColumn = 'Name';
        
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
        
        -- Get total count
        DECLARE @TotalCount INT;
        SELECT @TotalCount = COUNT(*)
        FROM Organizations o
        WHERE o.IsActive = 1
        AND (@SearchTerm IS NULL OR o.Name LIKE '%' + @SearchTerm + '%' OR o.Description LIKE '%' + @SearchTerm + '%');
        
        -- Get paginated results with dynamic sorting
        WITH OrganizationCTE AS (
            SELECT 
                o.Id,
                o.Name,
                o.Slug,
                o.Description,
                o.OwnerId,
                COALESCE(u.Username, 'Unknown') as OwnerUsername,
                COALESCE(NULLIF(RTRIM(LTRIM(u.FirstName)), '') + ' ' + NULLIF(RTRIM(LTRIM(u.LastName)), ''), u.Username, 'Unknown') as OwnerFullName,
                o.CreatedDate,
                o.ModifiedDate,
                o.IsActive,
                (SELECT COUNT(*) FROM OrganizationMembers om WHERE om.OrganizationId = o.Id AND om.IsActive = 1) as MemberCount,
                ROW_NUMBER() OVER (
                    ORDER BY 
                        CASE WHEN @SortColumn = 'Name' AND @SortDirection = 'ASC' THEN o.Name END ASC,
                        CASE WHEN @SortColumn = 'Name' AND @SortDirection = 'DESC' THEN o.Name END DESC,
                        CASE WHEN @SortColumn = 'CreatedDate' AND @SortDirection = 'ASC' THEN o.CreatedDate END ASC,
                        CASE WHEN @SortColumn = 'CreatedDate' AND @SortDirection = 'DESC' THEN o.CreatedDate END DESC,
                        CASE WHEN @SortColumn = 'MemberCount' AND @SortDirection = 'ASC' THEN (SELECT COUNT(*) FROM OrganizationMembers om WHERE om.OrganizationId = o.Id AND om.IsActive = 1) END ASC,
                        CASE WHEN @SortColumn = 'MemberCount' AND @SortDirection = 'DESC' THEN (SELECT COUNT(*) FROM OrganizationMembers om WHERE om.OrganizationId = o.Id AND om.IsActive = 1) END DESC
                ) as RowNum
            FROM Organizations o
            LEFT JOIN Users u ON o.OwnerId = u.UserId
            WHERE o.IsActive = 1
            AND (@SearchTerm IS NULL OR o.Name LIKE '%' + @SearchTerm + '%' OR o.Description LIKE '%' + @SearchTerm + '%')
        )
        SELECT 
            *,
            @TotalCount as TotalCount,
            CEILING(CAST(@TotalCount as FLOAT) / @PageSize) as TotalPages
        FROM OrganizationCTE
        WHERE RowNum BETWEEN @Offset + 1 AND @Offset + @PageSize
        ORDER BY RowNum;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- sp_UpdateOrganization
-- Updates organization details
-- Permissions: Organization owners, organization admins, and system admins
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateOrganization')
    DROP PROCEDURE sp_UpdateOrganization
GO

CREATE PROCEDURE sp_UpdateOrganization
    @OrganizationId INT,
    @Name NVARCHAR(100),
    @Slug NVARCHAR(50),
    @Description NVARCHAR(500) = NULL,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Input validation
        IF @OrganizationId IS NULL OR @OrganizationId <= 0
        BEGIN
            RAISERROR('Valid Organization ID is required', 16, 1);
            RETURN -1;
        END
        
        IF @Name IS NULL OR LTRIM(RTRIM(@Name)) = ''
        BEGIN
            RAISERROR('Organization name is required', 16, 1);
            RETURN -2;
        END
        
        IF @Slug IS NULL OR LTRIM(RTRIM(@Slug)) = ''
        BEGIN
            RAISERROR('Organization slug is required', 16, 1);
            RETURN -3;
        END
        
        -- Check if modifying user exists and is active
        DECLARE @ModifierRole NVARCHAR(50);
        SELECT @ModifierRole = UserRole FROM Users WHERE UserId = @ModifiedBy AND IsActive = 1;
        
        IF @ModifierRole IS NULL
        BEGIN
            RAISERROR('User not found or inactive', 16, 1);
            RETURN -4;
        END
        
        -- Check if organization exists and is active
        DECLARE @OwnerId INT;
        SELECT @OwnerId = OwnerId 
        FROM Organizations 
        WHERE Id = @OrganizationId AND IsActive = 1;
        
        IF @OwnerId IS NULL
        BEGIN
            RAISERROR('Organization not found or inactive', 16, 1);
            RETURN -5;
        END
        
        -- Permission check hierarchy: System Admin > Organization Owner > Organization Admin
        DECLARE @HasPermission BIT = 0;
        DECLARE @PermissionReason NVARCHAR(100) = '';
        
        -- 1. First check if user is system admin (highest priority)
        IF @ModifierRole = 'admin'
        BEGIN
            SET @HasPermission = 1;
            SET @PermissionReason = 'System Administrator';
        END
        -- 2. Check if user is organization owner
        ELSE IF @ModifiedBy = @OwnerId
        BEGIN
            SET @HasPermission = 1;
            SET @PermissionReason = 'Organization Owner';
        END
        -- 3. Check if user is organization admin
        ELSE IF EXISTS (
            SELECT 1 FROM OrganizationMembers 
            WHERE OrganizationId = @OrganizationId 
            AND UserId = @ModifiedBy 
            AND Role = 'organization_admin' 
            AND IsActive = 1
        )
        BEGIN
            SET @HasPermission = 1;
            SET @PermissionReason = 'Organization Administrator';
        END
        
        IF @HasPermission = 0
        BEGIN
            RAISERROR('Insufficient permissions to update organization. Only organization owners, organization admins, or system administrators can update organizations', 16, 1);
            RETURN -6;
        END
        
        -- Check if slug already exists (excluding current organization)
        IF EXISTS (SELECT 1 FROM Organizations WHERE Slug = @Slug AND Id != @OrganizationId)
        BEGIN
            RAISERROR('Organization slug already exists', 16, 1);
            RETURN -7;
        END
        
        -- Update organization
        UPDATE Organizations 
        SET Name = @Name,
            Slug = @Slug,
            Description = @Description,
            ModifiedDate = GETDATE()
        WHERE Id = @OrganizationId;
        
        -- Log successful update for audit purposes
        DECLARE @AffectedRows INT = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        -- Return success with permission context for logging
        SELECT 
            @AffectedRows as RowsUpdated,
            @PermissionReason as PermissionGrantedAs,
            @ModifierRole as UserRole;
        
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
-- sp_DeleteOrganization
-- Soft delete organization (sets IsActive = 0)
-- Permissions: Organization owners and system admins only
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteOrganization')
    DROP PROCEDURE sp_DeleteOrganization
GO

CREATE PROCEDURE sp_DeleteOrganization
    @OrganizationId INT,
    @DeletedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Input validation
        IF @OrganizationId IS NULL OR @OrganizationId <= 0
        BEGIN
            RAISERROR('Valid Organization ID is required', 16, 1);
            RETURN -1;
        END
        
        IF @DeletedBy IS NULL OR @DeletedBy <= 0
        BEGIN
            RAISERROR('Valid User ID is required for deletion tracking', 16, 1);
            RETURN -2;
        END
        
        -- Check if organization exists and is active
        DECLARE @OwnerId INT;
        DECLARE @OrganizationName NVARCHAR(100);
        SELECT @OwnerId = OwnerId, @OrganizationName = Name
        FROM Organizations 
        WHERE Id = @OrganizationId AND IsActive = 1;
        
        IF @OwnerId IS NULL
        BEGIN
            RAISERROR('Organization not found or already deleted', 16, 1);
            RETURN -3;
        END
        
        -- Check if deleting user exists and is active
        DECLARE @DeleterRole NVARCHAR(50);
        DECLARE @DeleterUsername NVARCHAR(50);
        SELECT @DeleterRole = UserRole, @DeleterUsername = Username 
        FROM Users 
        WHERE UserId = @DeletedBy AND IsActive = 1;
        
        IF @DeleterRole IS NULL
        BEGIN
            RAISERROR('User not found or inactive', 16, 1);
            RETURN -4;
        END
        
        -- Permission check: Only organization owners or system admins can delete organizations
        DECLARE @HasPermission BIT = 0;
        DECLARE @PermissionReason NVARCHAR(100) = '';
        DECLARE @MemberCount INT;
        
        -- Get current member count for audit
        SELECT @MemberCount = COUNT(*) 
        FROM OrganizationMembers 
        WHERE OrganizationId = @OrganizationId AND IsActive = 1;
        
        -- 1. Check if user is system admin (highest priority - can delete any organization)
        IF @DeleterRole = 'admin'
        BEGIN
            SET @HasPermission = 1;
            SET @PermissionReason = 'System Administrator Override';
        END
        -- 2. Check if user is organization owner
        ELSE IF @DeletedBy = @OwnerId
        BEGIN
            SET @HasPermission = 1;
            SET @PermissionReason = 'Organization Owner';
        END
        
        IF @HasPermission = 0
        BEGIN
            RAISERROR('Insufficient permissions to delete organization. Only organization owners or system administrators can delete organizations', 16, 1);
            RETURN -5;
        END
        
        -- Additional safety check for system admin deletions
        IF @DeleterRole = 'admin' AND @DeletedBy != @OwnerId AND @MemberCount > 10
        BEGIN
            -- Log warning but allow deletion - system admins may need to delete large organizations
            DECLARE @WarningMessage NVARCHAR(500);
            SET @WarningMessage = CONCAT('System admin ', @DeleterUsername, ' deleting organization "', 
                                       @OrganizationName, '" with ', @MemberCount, ' members');
            PRINT @WarningMessage; -- This will appear in SQL Server logs
        END
        
        -- Perform soft delete of organization
        UPDATE Organizations 
        SET IsActive = 0,
            ModifiedDate = GETDATE()
        WHERE Id = @OrganizationId;
        
        DECLARE @OrgRowsAffected INT = @@ROWCOUNT;
        
        -- Deactivate all organization members
        UPDATE OrganizationMembers 
        SET IsActive = 0
        WHERE OrganizationId = @OrganizationId;
        
        DECLARE @MemberRowsAffected INT = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        -- Return success information for audit logging
        SELECT 
            @OrganizationId as OrganizationId,
            @OrganizationName as OrganizationName,
            @OrgRowsAffected as OrganizationRowsAffected,
            @MemberRowsAffected as MemberRowsDeactivated,
            @PermissionReason as PermissionGrantedAs,
            @DeleterRole as DeleterRole,
            @DeleterUsername as DeleterUsername,
            GETDATE() as DeletionTimestamp;
        
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
-- sp_GetOrganizationsByOwner
-- Gets all organizations owned by a specific user
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetOrganizationsByOwner')
    DROP PROCEDURE sp_GetOrganizationsByOwner
GO

CREATE PROCEDURE sp_GetOrganizationsByOwner
    @OwnerId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Input validation
        IF @OwnerId IS NULL OR @OwnerId <= 0
        BEGIN
            RAISERROR('Valid Owner ID is required', 16, 1);
            RETURN -1;
        END
        
        SELECT 
            o.Id,
            o.Name,
            o.Slug,
            o.Description,
            o.OwnerId,
            u.Username as OwnerUsername,
            u.FirstName + ' ' + u.LastName as OwnerFullName,
            o.CreatedDate,
            o.ModifiedDate,
            o.IsActive,
            (SELECT COUNT(*) FROM OrganizationMembers om WHERE om.OrganizationId = o.Id AND om.IsActive = 1) as MemberCount
        FROM Organizations o
        INNER JOIN Users u ON o.OwnerId = u.UserId
        WHERE o.OwnerId = @OwnerId AND o.IsActive = 1
        ORDER BY o.CreatedDate DESC;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- ORGANIZATION MEMBERS STORED PROCEDURES
-- =============================================

-- =============================================
-- sp_AddOrganizationMember
-- Adds a user to an organization
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_AddOrganizationMember')
    DROP PROCEDURE sp_AddOrganizationMember
GO

CREATE PROCEDURE sp_AddOrganizationMember
    @OrganizationId INT,
    @UserId INT,
    @Role NVARCHAR(50) = 'member',
    @AddedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Input validation
        IF @OrganizationId IS NULL OR @OrganizationId <= 0
        BEGIN
            RAISERROR('Valid Organization ID is required', 16, 1);
            RETURN -1;
        END
        
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            RAISERROR('Valid User ID is required', 16, 1);
            RETURN -2;
        END
        
        IF @Role NOT IN ('organization_admin', 'member')
        BEGIN
            RAISERROR('Role must be either "organization_admin" or "member"', 16, 1);
            RETURN -3;
        END
        
        -- Check if organization exists and is active
        IF NOT EXISTS (SELECT 1 FROM Organizations WHERE Id = @OrganizationId AND IsActive = 1)
        BEGIN
            RAISERROR('Organization not found or inactive', 16, 1);
            RETURN -4;
        END
        
        -- Check if user exists and is active
        IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId AND IsActive = 1)
        BEGIN
            RAISERROR('User not found or inactive', 16, 1);
            RETURN -5;
        END
        
        -- Check if user adding has permission (must be organization admin or owner)
        DECLARE @HasPermission BIT = 0;
        
        -- Check if user is owner
        IF EXISTS (SELECT 1 FROM Organizations WHERE Id = @OrganizationId AND OwnerId = @AddedBy)
            SET @HasPermission = 1;
        
        -- Check if user is organization admin
        IF @HasPermission = 0 AND EXISTS (
            SELECT 1 FROM OrganizationMembers 
            WHERE OrganizationId = @OrganizationId 
            AND UserId = @AddedBy 
            AND Role = 'organization_admin' 
            AND IsActive = 1
        )
            SET @HasPermission = 1;
        
        IF @HasPermission = 0
        BEGIN
            RAISERROR('Only organization admins can add members', 16, 1);
            RETURN -6;
        END
        
        -- Check if user is already a member
        IF EXISTS (SELECT 1 FROM OrganizationMembers 
                  WHERE OrganizationId = @OrganizationId AND UserId = @UserId AND IsActive = 1)
        BEGIN
            RAISERROR('User is already a member of this organization', 16, 1);
            RETURN -7;
        END
        
        -- Check if there's an inactive membership to reactivate
        IF EXISTS (SELECT 1 FROM OrganizationMembers 
                  WHERE OrganizationId = @OrganizationId AND UserId = @UserId AND IsActive = 0)
        BEGIN
            -- Reactivate existing membership
            UPDATE OrganizationMembers 
            SET Role = @Role,
                JoinedDate = GETDATE(),
                IsActive = 1
            WHERE OrganizationId = @OrganizationId AND UserId = @UserId;
        END
        ELSE
        BEGIN
            -- Add new member
            INSERT INTO OrganizationMembers (OrganizationId, UserId, Role, JoinedDate)
            VALUES (@OrganizationId, @UserId, @Role, GETDATE());
        END
        
        COMMIT TRANSACTION;
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
-- sp_RemoveOrganizationMember
-- Removes a user from an organization
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_RemoveOrganizationMember')
    DROP PROCEDURE sp_RemoveOrganizationMember
GO

CREATE PROCEDURE sp_RemoveOrganizationMember
    @OrganizationId INT,
    @UserId INT,
    @RemovedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Input validation
        IF @OrganizationId IS NULL OR @OrganizationId <= 0
        BEGIN
            RAISERROR('Valid Organization ID is required', 16, 1);
            RETURN -1;
        END
        
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            RAISERROR('Valid User ID is required', 16, 1);
            RETURN -2;
        END
        
        -- Check if organization exists and is active
        DECLARE @OwnerId INT;
        SELECT @OwnerId = OwnerId 
        FROM Organizations 
        WHERE Id = @OrganizationId AND IsActive = 1;
        
        IF @OwnerId IS NULL
        BEGIN
            RAISERROR('Organization not found or inactive', 16, 1);
            RETURN -3;
        END
        
        -- Cannot remove the owner
        IF @UserId = @OwnerId
        BEGIN
            RAISERROR('Cannot remove organization owner from organization', 16, 1);
            RETURN -4;
        END
        
        -- Check if membership exists
        IF NOT EXISTS (SELECT 1 FROM OrganizationMembers 
                      WHERE OrganizationId = @OrganizationId AND UserId = @UserId AND IsActive = 1)
        BEGIN
            RAISERROR('User is not a member of this organization', 16, 1);
            RETURN -5;
        END
        
        -- Check if user removing has permission (must be organization admin, owner, or the user themselves)
        DECLARE @HasPermission BIT = 0;
        
        -- User can remove themselves
        IF @RemovedBy = @UserId
            SET @HasPermission = 1;
        
        -- Check if user is owner
        IF @HasPermission = 0 AND @RemovedBy = @OwnerId
            SET @HasPermission = 1;
        
        -- Check if user is organization admin
        IF @HasPermission = 0 AND EXISTS (
            SELECT 1 FROM OrganizationMembers 
            WHERE OrganizationId = @OrganizationId 
            AND UserId = @RemovedBy 
            AND Role = 'organization_admin' 
            AND IsActive = 1
        )
            SET @HasPermission = 1;
        
        IF @HasPermission = 0
        BEGIN
            RAISERROR('Insufficient permissions to remove member', 16, 1);
            RETURN -6;
        END
        
        -- Remove member (soft delete)
        UPDATE OrganizationMembers 
        SET IsActive = 0
        WHERE OrganizationId = @OrganizationId AND UserId = @UserId;
        
        COMMIT TRANSACTION;
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
-- sp_GetOrganizationMembers
-- Gets all active members of an organization
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetOrganizationMembers')
    DROP PROCEDURE sp_GetOrganizationMembers
GO

CREATE PROCEDURE sp_GetOrganizationMembers
    @OrganizationId INT,
    @RequestingUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Input validation
        IF @OrganizationId IS NULL OR @OrganizationId <= 0
        BEGIN
            RAISERROR('Valid Organization ID is required', 16, 1);
            RETURN -1;
        END
        
        -- Check if organization exists and is active
        IF NOT EXISTS (SELECT 1 FROM Organizations WHERE Id = @OrganizationId AND IsActive = 1)
        BEGIN
            RAISERROR('Organization not found or inactive', 16, 1);
            RETURN -2;
        END
        
        -- Check if requesting user has permission to view members (must be member or admin)
        IF @RequestingUserId IS NOT NULL
        BEGIN
            DECLARE @HasViewPermission BIT = 0;
            
            -- Check if user is member of organization
            IF EXISTS (SELECT 1 FROM OrganizationMembers 
                      WHERE OrganizationId = @OrganizationId 
                      AND UserId = @RequestingUserId 
                      AND IsActive = 1)
                SET @HasViewPermission = 1;
            
            -- Check if user is system admin
            IF @HasViewPermission = 0 AND EXISTS (
                SELECT 1 FROM Users 
                WHERE UserId = @RequestingUserId 
                AND UserRole = 'admin' 
                AND IsActive = 1
            )
                SET @HasViewPermission = 1;
            
            IF @HasViewPermission = 0
            BEGIN
                RAISERROR('Insufficient permissions to view organization members', 16, 1);
                RETURN -3;
            END
        END
        
        SELECT 
            om.Id as MembershipId,
            om.OrganizationId,
            om.UserId,
            u.Username,
            u.FirstName,
            u.LastName,
            u.Email,
            om.Role,
            om.JoinedDate,
            om.IsActive,
            CASE WHEN o.OwnerId = om.UserId THEN 1 ELSE 0 END as IsOwner
        FROM OrganizationMembers om
        INNER JOIN Users u ON om.UserId = u.UserId
        INNER JOIN Organizations o ON om.OrganizationId = o.Id
        WHERE om.OrganizationId = @OrganizationId 
        AND om.IsActive = 1
        AND u.IsActive = 1
        ORDER BY 
            CASE WHEN o.OwnerId = om.UserId THEN 0 ELSE 1 END, -- Owner first
            CASE WHEN om.Role = 'organization_admin' THEN 0 ELSE 1 END, -- Admins second
            om.JoinedDate; -- Then by join date
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- sp_GetUserOrganizations
-- Gets all organizations a user belongs to
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserOrganizations')
    DROP PROCEDURE sp_GetUserOrganizations
GO

CREATE PROCEDURE sp_GetUserOrganizations
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Input validation
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            RAISERROR('Valid User ID is required', 16, 1);
            RETURN -1;
        END
        
        -- Check if user exists and is active
        IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId AND IsActive = 1)
        BEGIN
            RAISERROR('User not found or inactive', 16, 1);
            RETURN -2;
        END
        
        SELECT 
            o.Id as OrganizationId,
            o.Name,
            o.Slug,
            o.Description,
            o.OwnerId,
            owner.Username as OwnerUsername,
            owner.FirstName + ' ' + owner.LastName as OwnerFullName,
            om.Role as UserRole,
            om.JoinedDate,
            o.CreatedDate,
            o.ModifiedDate,
            CASE WHEN o.OwnerId = @UserId THEN 1 ELSE 0 END as IsOwner,
            (SELECT COUNT(*) FROM OrganizationMembers om2 WHERE om2.OrganizationId = o.Id AND om2.IsActive = 1) as MemberCount
        FROM OrganizationMembers om
        INNER JOIN Organizations o ON om.OrganizationId = o.Id
        INNER JOIN Users owner ON o.OwnerId = owner.UserId
        WHERE om.UserId = @UserId 
        AND om.IsActive = 1
        AND o.IsActive = 1
        ORDER BY 
            CASE WHEN o.OwnerId = @UserId THEN 0 ELSE 1 END, -- Owned organizations first
            o.Name; -- Then alphabetical by name
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- sp_UpdateMemberRole
-- Updates a member's role in an organization
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateMemberRole')
    DROP PROCEDURE sp_UpdateMemberRole
GO

CREATE PROCEDURE sp_UpdateMemberRole
    @OrganizationId INT,
    @UserId INT,
    @NewRole NVARCHAR(50),
    @UpdatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Input validation
        IF @OrganizationId IS NULL OR @OrganizationId <= 0
        BEGIN
            RAISERROR('Valid Organization ID is required', 16, 1);
            RETURN -1;
        END
        
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            RAISERROR('Valid User ID is required', 16, 1);
            RETURN -2;
        END
        
        IF @NewRole NOT IN ('organization_admin', 'member')
        BEGIN
            RAISERROR('Role must be either "organization_admin" or "member"', 16, 1);
            RETURN -3;
        END
        
        -- Check if organization exists and is active
        DECLARE @OwnerId INT;
        SELECT @OwnerId = OwnerId 
        FROM Organizations 
        WHERE Id = @OrganizationId AND IsActive = 1;
        
        IF @OwnerId IS NULL
        BEGIN
            RAISERROR('Organization not found or inactive', 16, 1);
            RETURN -4;
        END
        
        -- Cannot change owner's role
        IF @UserId = @OwnerId
        BEGIN
            RAISERROR('Cannot change organization owner role', 16, 1);
            RETURN -5;
        END
        
        -- Check if membership exists
        DECLARE @CurrentRole NVARCHAR(50);
        SELECT @CurrentRole = Role 
        FROM OrganizationMembers 
        WHERE OrganizationId = @OrganizationId AND UserId = @UserId AND IsActive = 1;
        
        IF @CurrentRole IS NULL
        BEGIN
            RAISERROR('User is not a member of this organization', 16, 1);
            RETURN -6;
        END
        
        -- Check if role is actually changing
        IF @CurrentRole = @NewRole
        BEGIN
            RAISERROR('User already has the specified role', 16, 1);
            RETURN -7;
        END
        
        -- Check if user updating has permission (must be owner or organization admin)
        DECLARE @HasPermission BIT = 0;
        
        -- Check if user is owner
        IF @UpdatedBy = @OwnerId
            SET @HasPermission = 1;
        
        -- Check if user is organization admin
        IF @HasPermission = 0 AND EXISTS (
            SELECT 1 FROM OrganizationMembers 
            WHERE OrganizationId = @OrganizationId 
            AND UserId = @UpdatedBy 
            AND Role = 'organization_admin' 
            AND IsActive = 1
        )
            SET @HasPermission = 1;
        
        IF @HasPermission = 0
        BEGIN
            RAISERROR('Only organization admins can update member roles', 16, 1);
            RETURN -8;
        END
        
        -- Update member role
        UPDATE OrganizationMembers 
        SET Role = @NewRole
        WHERE OrganizationId = @OrganizationId AND UserId = @UserId;
        
        COMMIT TRANSACTION;
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
-- sp_CheckUserOrganizationRole
-- Checks if user has specific role in organization
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CheckUserOrganizationRole')
    DROP PROCEDURE sp_CheckUserOrganizationRole
GO

CREATE PROCEDURE sp_CheckUserOrganizationRole
    @UserId INT,
    @OrganizationId INT,
    @RequiredRole NVARCHAR(50) = NULL -- If NULL, checks if user is any kind of member
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Input validation
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            RAISERROR('Valid User ID is required', 16, 1);
            RETURN -1;
        END
        
        IF @OrganizationId IS NULL OR @OrganizationId <= 0
        BEGIN
            RAISERROR('Valid Organization ID is required', 16, 1);
            RETURN -2;
        END
        
        IF @RequiredRole IS NOT NULL AND @RequiredRole NOT IN ('organization_admin', 'member', 'owner')
        BEGIN
            RAISERROR('Role must be "organization_admin", "member", "owner", or NULL', 16, 1);
            RETURN -3;
        END
        
        DECLARE @UserRole NVARCHAR(50);
        DECLARE @IsOwner BIT = 0;
        DECLARE @HasAccess BIT = 0;
        
        -- Check if user is owner
        IF EXISTS (SELECT 1 FROM Organizations WHERE Id = @OrganizationId AND OwnerId = @UserId AND IsActive = 1)
            SET @IsOwner = 1;
        
        -- Get user's role in organization
        SELECT @UserRole = Role 
        FROM OrganizationMembers 
        WHERE OrganizationId = @OrganizationId 
        AND UserId = @UserId 
        AND IsActive = 1;
        
        -- Determine access based on requirements
        IF @RequiredRole IS NULL
        BEGIN
            -- Just checking if user is any kind of member
            IF @IsOwner = 1 OR @UserRole IS NOT NULL
                SET @HasAccess = 1;
        END
        ELSE IF @RequiredRole = 'owner'
        BEGIN
            -- Must be owner
            IF @IsOwner = 1
                SET @HasAccess = 1;
        END
        ELSE IF @RequiredRole = 'organization_admin'
        BEGIN
            -- Must be owner or organization admin
            IF @IsOwner = 1 OR @UserRole = 'organization_admin'
                SET @HasAccess = 1;
        END
        ELSE IF @RequiredRole = 'member'
        BEGIN
            -- Can be any role (owner, admin, or regular member)
            IF @IsOwner = 1 OR @UserRole IS NOT NULL
                SET @HasAccess = 1;
        END
        
        -- Return results
        SELECT 
            @HasAccess as HasAccess,
            @IsOwner as IsOwner,
            ISNULL(@UserRole, CASE WHEN @IsOwner = 1 THEN 'owner' ELSE NULL END) as Role,
            @UserId as UserId,
            @OrganizationId as OrganizationId;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -99;
    END CATCH
END
GO

-- =============================================
-- UTILITY PROCEDURES FOR AUDIT AND MAINTENANCE
-- =============================================

-- =============================================
-- sp_GetOrganizationStats
-- Gets comprehensive statistics for an organization
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetOrganizationStats')
    DROP PROCEDURE sp_GetOrganizationStats
GO

CREATE PROCEDURE sp_GetOrganizationStats
    @OrganizationId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Input validation
        IF @OrganizationId IS NULL OR @OrganizationId <= 0
        BEGIN
            RAISERROR('Valid Organization ID is required', 16, 1);
            RETURN -1;
        END
        
        -- Check if organization exists
        IF NOT EXISTS (SELECT 1 FROM Organizations WHERE Id = @OrganizationId AND IsActive = 1)
        BEGIN
            RAISERROR('Organization not found or inactive', 16, 1);
            RETURN -2;
        END
        
        SELECT 
            o.Id,
            o.Name,
            o.Slug,
            o.Description,
            o.CreatedDate,
            o.ModifiedDate,
            owner.Username as OwnerUsername,
            owner.FirstName + ' ' + owner.LastName as OwnerFullName,
            (SELECT COUNT(*) FROM OrganizationMembers om WHERE om.OrganizationId = o.Id AND om.IsActive = 1) as TotalMembers,
            (SELECT COUNT(*) FROM OrganizationMembers om WHERE om.OrganizationId = o.Id AND om.Role = 'organization_admin' AND om.IsActive = 1) as AdminCount,
            (SELECT COUNT(*) FROM OrganizationMembers om WHERE om.OrganizationId = o.Id AND om.Role = 'member' AND om.IsActive = 1) as RegularMemberCount,
            (SELECT MIN(JoinedDate) FROM OrganizationMembers om WHERE om.OrganizationId = o.Id AND om.IsActive = 1) as FirstMemberJoinDate,
            (SELECT MAX(JoinedDate) FROM OrganizationMembers om WHERE om.OrganizationId = o.Id AND om.IsActive = 1) as LastMemberJoinDate
        FROM Organizations o
        INNER JOIN Users owner ON o.OwnerId = owner.UserId
        WHERE o.Id = @OrganizationId;
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -99;
    END CATCH
END
GO

PRINT 'Organization Administration System - All stored procedures created successfully!';
PRINT '';
PRINT 'Created Tables:';
PRINT '- Organizations';
PRINT '- OrganizationMembers';
PRINT '';
PRINT 'Organization Procedures:';
PRINT '- sp_CreateOrganization';
PRINT '- sp_GetOrganizationById';
PRINT '- sp_GetOrganizationBySlug';
PRINT '- sp_GetAllOrganizations';
PRINT '- sp_UpdateOrganization';
PRINT '- sp_DeleteOrganization';
PRINT '- sp_GetOrganizationsByOwner';
PRINT '';
PRINT 'Member Management Procedures:';
PRINT '- sp_AddOrganizationMember';
PRINT '- sp_RemoveOrganizationMember';
PRINT '- sp_GetOrganizationMembers';
PRINT '- sp_GetUserOrganizations';
PRINT '- sp_UpdateMemberRole';
PRINT '- sp_CheckUserOrganizationRole';
PRINT '';
PRINT 'Utility Procedures:';
PRINT '- sp_GetOrganizationStats';
PRINT '';
PRINT 'All procedures include comprehensive error handling, parameter validation, and security checks.';