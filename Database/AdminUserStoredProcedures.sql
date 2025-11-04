-- =============================================
-- Admin User Management Stored Procedures
-- Description: CRUD operations for admin user management
-- Created: 2025-11-04
-- =============================================

USE [Hirebot]
GO

-- =============================================
-- sp_Admin_GetUserById - Get user by ID for editing
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Admin_GetUserById]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_Admin_GetUserById]
GO

CREATE PROCEDURE [dbo].[sp_Admin_GetUserById]
    @UserId INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validation
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            SET @ResultCode = -1;
            SET @ResultMessage = 'Invalid user ID';
            RETURN;
        END

        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
        BEGIN
            SET @ResultCode = 0;
            SET @ResultMessage = 'User not found';
            RETURN;
        END

        -- Return user data
        SELECT 
            UserId,
            Username,
            Email,
            PasswordHash,
            FirstName,
            LastName,
            UserRole,
            CreatedDate,
            LastLoginDate,
            IsActive
        FROM Users
        WHERE UserId = @UserId;

        SET @ResultCode = 1;
        SET @ResultMessage = 'User retrieved successfully';
    END TRY
    BEGIN CATCH
        SET @ResultCode = -999;
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- sp_Admin_UpdateUser - Update user information
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Admin_UpdateUser]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_Admin_UpdateUser]
GO

CREATE PROCEDURE [dbo].[sp_Admin_UpdateUser]
    @UserId INT,
    @Username NVARCHAR(50),
    @Email NVARCHAR(100),
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @UserRole NVARCHAR(20),
    @IsActive BIT,
    @ModifiedBy INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validation
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            SET @ResultCode = -1;
            SET @ResultMessage = 'Invalid user ID';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @ModifiedBy IS NULL OR @ModifiedBy <= 0
        BEGIN
            SET @ResultCode = -2;
            SET @ResultMessage = 'Invalid modifier user ID';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
        BEGIN
            SET @ResultCode = 0;
            SET @ResultMessage = 'User not found';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if username is taken by another user
        IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username AND UserId != @UserId)
        BEGIN
            SET @ResultCode = -3;
            SET @ResultMessage = 'Username already exists';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if email is taken by another user
        IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email AND UserId != @UserId)
        BEGIN
            SET @ResultCode = -4;
            SET @ResultMessage = 'Email already exists';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validate role
        IF @UserRole NOT IN ('user', 'admin')
        BEGIN
            SET @ResultCode = -5;
            SET @ResultMessage = 'Invalid user role';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Update user
        UPDATE Users
        SET 
            Username = @Username,
            Email = @Email,
            FirstName = @FirstName,
            LastName = @LastName,
            UserRole = @UserRole,
            IsActive = @IsActive
        WHERE UserId = @UserId;

        -- Log the action
        INSERT INTO Logs (LogType, UserId, Description, CreatedAt)
        VALUES ('UPDATE', @ModifiedBy, 'Admin updated user ' + @Username + ' (ID: ' + CAST(@UserId AS NVARCHAR(10)) + ')', GETDATE());

        COMMIT TRANSACTION;

        SET @ResultCode = 1;
        SET @ResultMessage = 'User updated successfully';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @ResultCode = -999;
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- sp_Admin_DeleteUser - Soft delete user
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Admin_DeleteUser]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_Admin_DeleteUser]
GO

CREATE PROCEDURE [dbo].[sp_Admin_DeleteUser]
    @UserId INT,
    @DeletedBy INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validation
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            SET @ResultCode = -1;
            SET @ResultMessage = 'Invalid user ID';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @DeletedBy IS NULL OR @DeletedBy <= 0
        BEGIN
            SET @ResultCode = -2;
            SET @ResultMessage = 'Invalid deleter user ID';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if user exists
        DECLARE @Username NVARCHAR(50);
        SELECT @Username = Username FROM Users WHERE UserId = @UserId;
        
        IF @Username IS NULL
        BEGIN
            SET @ResultCode = 0;
            SET @ResultMessage = 'User not found';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Prevent deleting yourself
        IF @UserId = @DeletedBy
        BEGIN
            SET @ResultCode = -3;
            SET @ResultMessage = 'Cannot delete your own account';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if user is already inactive
        DECLARE @IsActive BIT;
        SELECT @IsActive = IsActive FROM Users WHERE UserId = @UserId;
        
        IF @IsActive = 0
        BEGIN
            SET @ResultCode = -4;
            SET @ResultMessage = 'User is already inactive';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Soft delete (deactivate) the user
        UPDATE Users
        SET IsActive = 0
        WHERE UserId = @UserId;

        -- Log the action
        INSERT INTO Logs (LogType, UserId, Description, CreatedAt)
        VALUES ('DELETE', @DeletedBy, 'Admin deleted user ' + @Username + ' (ID: ' + CAST(@UserId AS NVARCHAR(10)) + ')', GETDATE());

        COMMIT TRANSACTION;

        SET @ResultCode = 1;
        SET @ResultMessage = 'User deleted successfully';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @ResultCode = -999;
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- sp_Admin_ActivateUser - Reactivate a user
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Admin_ActivateUser]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_Admin_ActivateUser]
GO

CREATE PROCEDURE [dbo].[sp_Admin_ActivateUser]
    @UserId INT,
    @ActivatedBy INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validation
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            SET @ResultCode = -1;
            SET @ResultMessage = 'Invalid user ID';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @ActivatedBy IS NULL OR @ActivatedBy <= 0
        BEGIN
            SET @ResultCode = -2;
            SET @ResultMessage = 'Invalid activator user ID';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if user exists
        DECLARE @Username NVARCHAR(50);
        SELECT @Username = Username FROM Users WHERE UserId = @UserId;
        
        IF @Username IS NULL
        BEGIN
            SET @ResultCode = 0;
            SET @ResultMessage = 'User not found';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if user is already active
        DECLARE @IsActive BIT;
        SELECT @IsActive = IsActive FROM Users WHERE UserId = @UserId;
        
        IF @IsActive = 1
        BEGIN
            SET @ResultCode = -3;
            SET @ResultMessage = 'User is already active';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Activate the user
        UPDATE Users
        SET IsActive = 1
        WHERE UserId = @UserId;

        -- Log the action
        INSERT INTO Logs (LogType, UserId, Description, CreatedAt)
        VALUES ('UPDATE', @ActivatedBy, 'Admin activated user ' + @Username + ' (ID: ' + CAST(@UserId AS NVARCHAR(10)) + ')', GETDATE());

        COMMIT TRANSACTION;

        SET @ResultCode = 1;
        SET @ResultMessage = 'User activated successfully';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @ResultCode = -999;
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

PRINT 'Admin User Stored Procedures created successfully';
GO
