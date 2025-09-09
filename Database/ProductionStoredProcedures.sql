-- =============================================
-- Production-Ready Hirebot-TFI Stored Procedures with UserRole Support
-- Includes comprehensive error handling, validations, and constraints
-- =============================================

-- =============================================
-- Stored Procedure: sp_CreateUser (Production Ready)
-- Description: Creates a new user account with full validation and error handling
-- Returns: Result code and message for proper error handling
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CreateUser]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_CreateUser]
GO

CREATE PROCEDURE [dbo].[sp_CreateUser]
    @Username NVARCHAR(20),
    @Email NVARCHAR(255),
    @PasswordHash NVARCHAR(64),
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @UserRole NVARCHAR(20),
    @CreatedDate DATETIME,
    @IsActive BIT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Initialize output parameters
    SET @ResultCode = 0
    SET @ResultMessage = 'Success'
    
    BEGIN TRY
        -- Input validation
        IF @Username IS NULL OR LTRIM(RTRIM(@Username)) = ''
        BEGIN
            SET @ResultCode = -1
            SET @ResultMessage = 'Username cannot be null or empty'
            RETURN
        END
        
        IF @Email IS NULL OR LTRIM(RTRIM(@Email)) = ''
        BEGIN
            SET @ResultCode = -2
            SET @ResultMessage = 'Email cannot be null or empty'
            RETURN
        END
        
        IF @PasswordHash IS NULL OR LTRIM(RTRIM(@PasswordHash)) = ''
        BEGIN
            SET @ResultCode = -3
            SET @ResultMessage = 'Password hash cannot be null or empty'
            RETURN
        END
        
        IF @FirstName IS NULL OR LTRIM(RTRIM(@FirstName)) = ''
        BEGIN
            SET @ResultCode = -4
            SET @ResultMessage = 'First name cannot be null or empty'
            RETURN
        END
        
        IF @LastName IS NULL OR LTRIM(RTRIM(@LastName)) = ''
        BEGIN
            SET @ResultCode = -5
            SET @ResultMessage = 'Last name cannot be null or empty'
            RETURN
        END
        
        IF @UserRole IS NULL OR LTRIM(RTRIM(@UserRole)) = ''
        BEGIN
            SET @UserRole = 'user' -- Default role
        END
        
        -- Validate UserRole against allowed values
        IF @UserRole NOT IN ('user', 'admin', 'moderator')
        BEGIN
            SET @ResultCode = -6
            SET @ResultMessage = 'Invalid user role. Allowed values: user, admin, moderator'
            RETURN
        END
        
        -- Validate username length
        IF LEN(LTRIM(RTRIM(@Username))) < 3 OR LEN(LTRIM(RTRIM(@Username))) > 20
        BEGIN
            SET @ResultCode = -7
            SET @ResultMessage = 'Username must be between 3 and 20 characters'
            RETURN
        END
        
        -- Validate email format (basic check)
        IF @Email NOT LIKE '%_@_%._%'
        BEGIN
            SET @ResultCode = -8
            SET @ResultMessage = 'Invalid email format'
            RETURN
        END
        
        -- Check for duplicate username
        IF EXISTS (SELECT 1 FROM [dbo].[Users] WHERE Username = @Username)
        BEGIN
            SET @ResultCode = -9
            SET @ResultMessage = 'Username already exists'
            RETURN
        END
        
        -- Check for duplicate email
        IF EXISTS (SELECT 1 FROM [dbo].[Users] WHERE Email = @Email)
        BEGIN
            SET @ResultCode = -10
            SET @ResultMessage = 'Email already exists'
            RETURN
        END
        
        -- Insert new user
        INSERT INTO [dbo].[Users] 
        (Username, Email, PasswordHash, FirstName, LastName, UserRole, CreatedDate, IsActive)
        VALUES 
        (@Username, @Email, @PasswordHash, @FirstName, @LastName, @UserRole, @CreatedDate, @IsActive)
        
        -- Success
        SET @ResultCode = 1
        SET @ResultMessage = 'User created successfully'
        
    END TRY
    BEGIN CATCH
        SET @ResultCode = -999
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE()
    END CATCH
END
GO

-- =============================================
-- Stored Procedure: sp_GetUserByUsername (Production Ready)
-- Description: Retrieves user by username with error handling
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_GetUserByUsername]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_GetUserByUsername]
GO

CREATE PROCEDURE [dbo].[sp_GetUserByUsername]
    @Username NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Input validation
    IF @Username IS NULL OR LTRIM(RTRIM(@Username)) = ''
    BEGIN
        RAISERROR('Username cannot be null or empty', 16, 1)
        RETURN
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
    FROM [dbo].[Users]
    WHERE Username = @Username AND IsActive = 1
END
GO

-- =============================================
-- Stored Procedure: sp_GetUserByEmail (Production Ready)
-- Description: Retrieves user by email with error handling
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_GetUserByEmail]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_GetUserByEmail]
GO

CREATE PROCEDURE [dbo].[sp_GetUserByEmail]
    @Email NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Input validation
    IF @Email IS NULL OR LTRIM(RTRIM(@Email)) = ''
    BEGIN
        RAISERROR('Email cannot be null or empty', 16, 1)
        RETURN
    END
    
    -- Basic email format validation
    IF @Email NOT LIKE '%_@_%._%'
    BEGIN
        RAISERROR('Invalid email format', 16, 1)
        RETURN
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
    FROM [dbo].[Users]
    WHERE Email = @Email AND IsActive = 1
END
GO

-- =============================================
-- Stored Procedure: sp_CheckUserExists (Production Ready)
-- Description: Checks if username or email already exists with proper validation
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CheckUserExists]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_CheckUserExists]
GO

CREATE PROCEDURE [dbo].[sp_CheckUserExists]
    @Username NVARCHAR(20),
    @Email NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Input validation
    IF (@Username IS NULL OR LTRIM(RTRIM(@Username)) = '') AND (@Email IS NULL OR LTRIM(RTRIM(@Email)) = '')
    BEGIN
        SELECT 0 AS UserCount, 'No valid username or email provided' AS ErrorMessage
        RETURN
    END
    
    -- Check for existing users
    SELECT COUNT(*) AS UserCount,
           CASE 
               WHEN COUNT(*) > 0 THEN 'User already exists'
               ELSE 'User does not exist'
           END AS Message
    FROM [dbo].[Users]
    WHERE (Username = @Username AND @Username IS NOT NULL AND LTRIM(RTRIM(@Username)) <> '') 
       OR (Email = @Email AND @Email IS NOT NULL AND LTRIM(RTRIM(@Email)) <> '')
END
GO

-- =============================================
-- Stored Procedure: sp_UpdateLastLoginDate (Production Ready)
-- Description: Updates the last login timestamp with validation
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_UpdateLastLoginDate]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_UpdateLastLoginDate]
GO

CREATE PROCEDURE [dbo].[sp_UpdateLastLoginDate]
    @UserId INT,
    @LastLoginDate DATETIME,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Initialize output parameters
    SET @ResultCode = 0
    SET @ResultMessage = 'Success'
    
    BEGIN TRY
        -- Input validation
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            SET @ResultCode = -1
            SET @ResultMessage = 'Invalid user ID'
            RETURN
        END
        
        IF @LastLoginDate IS NULL
        BEGIN
            SET @LastLoginDate = GETDATE()
        END
        
        -- Check if user exists and is active
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserId = @UserId AND IsActive = 1)
        BEGIN
            SET @ResultCode = -2
            SET @ResultMessage = 'User not found or inactive'
            RETURN
        END
        
        -- Update last login date
        UPDATE [dbo].[Users]
        SET LastLoginDate = @LastLoginDate
        WHERE UserId = @UserId AND IsActive = 1
        
        -- Check if update was successful
        IF @@ROWCOUNT = 0
        BEGIN
            SET @ResultCode = -3
            SET @ResultMessage = 'Failed to update last login date'
            RETURN
        END
        
        SET @ResultCode = 1
        SET @ResultMessage = 'Last login date updated successfully'
        
    END TRY
    BEGIN CATCH
        SET @ResultCode = -999
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE()
    END CATCH
END
GO

-- =============================================
-- Stored Procedure: sp_GetAllUsers (Production Ready)
-- Description: Retrieves all active users with optional filtering
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_GetAllUsers]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_GetAllUsers]
GO

CREATE PROCEDURE [dbo].[sp_GetAllUsers]
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Return user data with optional inactive users
    SELECT 
        UserId,
        Username,
        FirstName,
        LastName,
        Email,
        UserRole,
        CreatedDate,
        LastLoginDate,
        IsActive,
        FirstName + ' ' + LastName + ' (' + Username + ')' AS DisplayName
    FROM [dbo].[Users]
    WHERE (@IncludeInactive = 1 OR IsActive = 1)
    ORDER BY FirstName, LastName
END
GO

-- =============================================
-- Stored Procedure: sp_GetUsersByRole (Production Ready)
-- Description: Retrieves users by specific role with validation
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_GetUsersByRole]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_GetUsersByRole]
GO

CREATE PROCEDURE [dbo].[sp_GetUsersByRole]
    @UserRole NVARCHAR(20),
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Input validation
    IF @UserRole IS NULL OR LTRIM(RTRIM(@UserRole)) = ''
    BEGIN
        RAISERROR('User role cannot be null or empty', 16, 1)
        RETURN
    END
    
    -- Validate UserRole against allowed values
    IF @UserRole NOT IN ('user', 'admin', 'moderator')
    BEGIN
        RAISERROR('Invalid user role. Allowed values: user, admin, moderator', 16, 1)
        RETURN
    END
    
    -- Return users by role
    SELECT 
        UserId,
        Username,
        Email,
        FirstName,
        LastName,
        UserRole,
        CreatedDate,
        LastLoginDate,
        IsActive
    FROM [dbo].[Users]
    WHERE UserRole = @UserRole 
      AND (@IncludeInactive = 1 OR IsActive = 1)
    ORDER BY CreatedDate DESC
END
GO

-- =============================================
-- Stored Procedure: sp_UpdateUserRole (Production Ready)
-- Description: Updates a user's role with comprehensive validation
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_UpdateUserRole]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_UpdateUserRole]
GO

CREATE PROCEDURE [dbo].[sp_UpdateUserRole]
    @UserId INT,
    @NewUserRole NVARCHAR(20),
    @ModifiedBy INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Initialize output parameters
    SET @ResultCode = 0
    SET @ResultMessage = 'Success'
    
    BEGIN TRY
        -- Input validation
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            SET @ResultCode = -1
            SET @ResultMessage = 'Invalid user ID'
            RETURN
        END
        
        IF @ModifiedBy IS NULL OR @ModifiedBy <= 0
        BEGIN
            SET @ResultCode = -2
            SET @ResultMessage = 'Invalid modifier user ID'
            RETURN
        END
        
        IF @NewUserRole IS NULL OR LTRIM(RTRIM(@NewUserRole)) = ''
        BEGIN
            SET @ResultCode = -3
            SET @ResultMessage = 'New user role cannot be null or empty'
            RETURN
        END
        
        -- Validate UserRole against allowed values
        IF @NewUserRole NOT IN ('user', 'admin', 'moderator')
        BEGIN
            SET @ResultCode = -4
            SET @ResultMessage = 'Invalid user role. Allowed values: user, admin, moderator'
            RETURN
        END
        
        -- Check if target user exists and is active
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserId = @UserId AND IsActive = 1)
        BEGIN
            SET @ResultCode = -5
            SET @ResultMessage = 'Target user not found or inactive'
            RETURN
        END
        
        -- Check if modifier user exists and is admin
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserId = @ModifiedBy AND IsActive = 1 AND UserRole = 'admin')
        BEGIN
            SET @ResultCode = -6
            SET @ResultMessage = 'Modifier user must be an active admin'
            RETURN
        END
        
        -- Prevent removing the last admin
        IF @NewUserRole <> 'admin' AND 
           (SELECT UserRole FROM [dbo].[Users] WHERE UserId = @UserId) = 'admin' AND
           (SELECT COUNT(*) FROM [dbo].[Users] WHERE UserRole = 'admin' AND IsActive = 1) = 1
        BEGIN
            SET @ResultCode = -7
            SET @ResultMessage = 'Cannot remove the last admin user'
            RETURN
        END
        
        -- Update user role
        UPDATE [dbo].[Users]
        SET UserRole = @NewUserRole
        WHERE UserId = @UserId AND IsActive = 1
        
        -- Check if update was successful
        IF @@ROWCOUNT = 0
        BEGIN
            SET @ResultCode = -8
            SET @ResultMessage = 'Failed to update user role'
            RETURN
        END
        
        SET @ResultCode = 1
        SET @ResultMessage = 'User role updated successfully'
        
    END TRY
    BEGIN CATCH
        SET @ResultCode = -999
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE()
    END CATCH
END
GO

-- =============================================
-- Stored Procedure: sp_DeactivateUser (New Production Ready)
-- Description: Safely deactivates a user account with validation
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_DeactivateUser]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_DeactivateUser]
GO

CREATE PROCEDURE [dbo].[sp_DeactivateUser]
    @UserId INT,
    @DeactivatedBy INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Initialize output parameters
    SET @ResultCode = 0
    SET @ResultMessage = 'Success'
    
    BEGIN TRY
        -- Input validation
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            SET @ResultCode = -1
            SET @ResultMessage = 'Invalid user ID'
            RETURN
        END
        
        IF @DeactivatedBy IS NULL OR @DeactivatedBy <= 0
        BEGIN
            SET @ResultCode = -2
            SET @ResultMessage = 'Invalid deactivator user ID'
            RETURN
        END
        
        -- Check if target user exists and is active
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserId = @UserId AND IsActive = 1)
        BEGIN
            SET @ResultCode = -3
            SET @ResultMessage = 'Target user not found or already inactive'
            RETURN
        END
        
        -- Check if deactivator user exists and is admin
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserId = @DeactivatedBy AND IsActive = 1 AND UserRole = 'admin')
        BEGIN
            SET @ResultCode = -4
            SET @ResultMessage = 'Deactivator user must be an active admin'
            RETURN
        END
        
        -- Prevent deactivating the last admin
        IF (SELECT UserRole FROM [dbo].[Users] WHERE UserId = @UserId) = 'admin' AND
           (SELECT COUNT(*) FROM [dbo].[Users] WHERE UserRole = 'admin' AND IsActive = 1) = 1
        BEGIN
            SET @ResultCode = -5
            SET @ResultMessage = 'Cannot deactivate the last admin user'
            RETURN
        END
        
        -- Prevent self-deactivation
        IF @UserId = @DeactivatedBy
        BEGIN
            SET @ResultCode = -6
            SET @ResultMessage = 'Users cannot deactivate themselves'
            RETURN
        END
        
        -- Deactivate user
        UPDATE [dbo].[Users]
        SET IsActive = 0
        WHERE UserId = @UserId
        
        -- Check if update was successful
        IF @@ROWCOUNT = 0
        BEGIN
            SET @ResultCode = -7
            SET @ResultMessage = 'Failed to deactivate user'
            RETURN
        END
        
        SET @ResultCode = 1
        SET @ResultMessage = 'User deactivated successfully'
        
    END TRY
    BEGIN CATCH
        SET @ResultCode = -999
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE()
    END CATCH
END
GO

-- =============================================
-- Verification Query: Check if all procedures were created successfully
-- =============================================
SELECT 
    name AS ProcedureName,
    create_date AS DateCreated,
    modify_date AS DateModified
FROM sys.procedures 
WHERE name IN (
    'sp_CreateUser',
    'sp_GetUserByUsername', 
    'sp_GetUserByEmail',
    'sp_CheckUserExists',
    'sp_UpdateLastLoginDate',
    'sp_GetAllUsers',
    'sp_GetUsersByRole',
    'sp_UpdateUserRole',
    'sp_DeactivateUser'
)
ORDER BY name

PRINT 'Production-ready stored procedures with comprehensive validation created successfully!'
PRINT 'Features include:'
PRINT '- Input validation and sanitization'
PRINT '- Duplicate prevention for username/email'
PRINT '- Role validation (user, admin, moderator)'
PRINT '- Admin protection (cannot remove last admin)'
PRINT '- Comprehensive error handling with specific error codes'
PRINT '- Output parameters for proper error reporting'