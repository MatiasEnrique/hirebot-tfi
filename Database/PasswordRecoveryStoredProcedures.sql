-- =============================================
-- Password Recovery System for Hirebot-TFI
-- Author: Claude Code SQL Expert
-- Create date: 2025-09-06
-- Description: Complete password recovery system with UUID tokens, 15-minute expiration,
--              comprehensive error handling, and security audit trail
-- Features:
--   - Cryptographically secure UUID tokens
--   - 15-minute token expiration window
--   - One-time use token validation
--   - IP address tracking for security
--   - Comprehensive error handling with specific error codes
--   - Audit trail capabilities
--   - Automatic cleanup of expired tokens
-- =============================================

-- =============================================
-- Table: PasswordRecovery
-- Description: Stores password recovery requests with secure tokens
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PasswordRecovery]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[PasswordRecovery] (
        RecoveryId INT IDENTITY(1,1) NOT NULL,
        RecoveryToken UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        UserId INT NOT NULL,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        ExpiryDate DATETIME NOT NULL,
        IsUsed BIT NOT NULL DEFAULT 0,
        UsedDate DATETIME NULL,
        RequestIP NVARCHAR(45) NULL, -- IPv4 (15) or IPv6 (45) support
        UserAgent NVARCHAR(500) NULL,
        
        CONSTRAINT PK_PasswordRecovery PRIMARY KEY CLUSTERED (RecoveryId ASC),
        CONSTRAINT FK_PasswordRecovery_Users FOREIGN KEY(UserId) REFERENCES [dbo].[Users] (UserId),
        CONSTRAINT UX_PasswordRecovery_Token UNIQUE (RecoveryToken)
    )
    
    -- Create indexes for performance
    CREATE NONCLUSTERED INDEX IX_PasswordRecovery_UserId ON [dbo].[PasswordRecovery] (UserId)
    CREATE NONCLUSTERED INDEX IX_PasswordRecovery_Token_Active ON [dbo].[PasswordRecovery] (RecoveryToken, IsUsed, ExpiryDate)
    CREATE NONCLUSTERED INDEX IX_PasswordRecovery_Cleanup ON [dbo].[PasswordRecovery] (ExpiryDate, IsUsed)
    
    PRINT 'PasswordRecovery table created successfully with indexes'
END
ELSE
BEGIN
    PRINT 'PasswordRecovery table already exists'
END
GO

-- =============================================
-- Stored Procedure: sp_CreatePasswordRecoveryRequest
-- Author: Claude Code SQL Expert
-- Create date: 2025-09-06
-- Description: Creates a new password recovery request with UUID token
-- Parameters:  
--   @UserId - ID of user requesting password recovery
--   @RequestIP - IP address of the requesting client (optional)
--   @UserAgent - User agent string of the requesting client (optional)
--   @RecoveryToken - OUTPUT parameter returning the generated UUID token
--   @ResultCode - OUTPUT parameter: 1 = success, negative = error
--   @ResultMessage - OUTPUT parameter with detailed message
-- Returns:     0 for success, -1 for error
-- Security:    Validates user exists and is active, generates cryptographically secure UUID
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CreatePasswordRecoveryRequest]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_CreatePasswordRecoveryRequest]
GO

CREATE PROCEDURE [dbo].[sp_CreatePasswordRecoveryRequest]
    @UserId INT,
    @RequestIP NVARCHAR(45) = NULL,
    @UserAgent NVARCHAR(500) = NULL,
    @RecoveryToken UNIQUEIDENTIFIER OUTPUT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Initialize output parameters
    SET @ResultCode = 0
    SET @ResultMessage = 'Success'
    SET @RecoveryToken = NULL
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Input validation
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            SET @ResultCode = -1
            SET @ResultMessage = 'Invalid user ID'
            ROLLBACK TRANSACTION
            RETURN -1
        END
        
        -- Validate user exists and is active
        DECLARE @UserExists BIT = 0
        DECLARE @UserEmail NVARCHAR(255)
        
        SELECT @UserExists = 1, @UserEmail = Email
        FROM [dbo].[Users] 
        WHERE UserId = @UserId AND IsActive = 1
        
        IF @UserExists = 0
        BEGIN
            SET @ResultCode = -2
            SET @ResultMessage = 'User not found or inactive'
            ROLLBACK TRANSACTION
            RETURN -1
        END
        
        -- Check for existing active recovery requests (prevent spam)
        DECLARE @ActiveRequestCount INT
        SELECT @ActiveRequestCount = COUNT(*)
        FROM [dbo].[PasswordRecovery]
        WHERE UserId = @UserId 
          AND IsUsed = 0 
          AND ExpiryDate > GETDATE()
          AND CreatedDate > DATEADD(MINUTE, -5, GETDATE()) -- Max 1 request per 5 minutes
        
        IF @ActiveRequestCount > 0
        BEGIN
            SET @ResultCode = -3
            SET @ResultMessage = 'Active recovery request already exists. Please wait before requesting another.'
            ROLLBACK TRANSACTION
            RETURN -1
        END
        
        -- Generate cryptographically secure UUID token
        SET @RecoveryToken = NEWID()
        
        -- Calculate expiry date (15 minutes from now)
        DECLARE @ExpiryDate DATETIME = DATEADD(MINUTE, 15, GETDATE())
        
        -- Insert recovery request
        INSERT INTO [dbo].[PasswordRecovery] 
        (RecoveryToken, UserId, CreatedDate, ExpiryDate, IsUsed, RequestIP, UserAgent)
        VALUES 
        (@RecoveryToken, @UserId, GETDATE(), @ExpiryDate, 0, @RequestIP, @UserAgent)
        
        -- Verify insertion
        IF @@ROWCOUNT = 0
        BEGIN
            SET @ResultCode = -4
            SET @ResultMessage = 'Failed to create recovery request'
            ROLLBACK TRANSACTION
            RETURN -1
        END
        
        COMMIT TRANSACTION
        
        -- Success
        SET @ResultCode = 1
        SET @ResultMessage = 'Password recovery request created successfully'
        RETURN 0
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        
        SET @ResultCode = -999
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE()
        RETURN -1
    END CATCH
END
GO

-- =============================================
-- Stored Procedure: sp_ValidatePasswordRecoveryToken
-- Author: Claude Code SQL Expert
-- Create date: 2025-09-06
-- Description: Validates if UUID recovery token exists and is still valid
-- Parameters:  
--   @RecoveryToken - UUID token to validate
--   @UserId - OUTPUT parameter returning the associated user ID if valid
--   @ResultCode - OUTPUT parameter: 1 = valid, 2 = expired, 3 = used, 4 = not found
--   @ResultMessage - OUTPUT parameter with detailed message
-- Returns:     0 for success, -1 for error
-- Security:    Checks token existence, expiration, and usage status
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ValidatePasswordRecoveryToken]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ValidatePasswordRecoveryToken]
GO

CREATE PROCEDURE [dbo].[sp_ValidatePasswordRecoveryToken]
    @RecoveryToken UNIQUEIDENTIFIER,
    @UserId INT OUTPUT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Initialize output parameters
    SET @ResultCode = 0
    SET @ResultMessage = 'Success'
    SET @UserId = NULL
    
    BEGIN TRY
        -- Input validation
        IF @RecoveryToken IS NULL
        BEGIN
            SET @ResultCode = -1
            SET @ResultMessage = 'Recovery token cannot be null'
            RETURN -1
        END
        
        -- Check if token exists
        DECLARE @TokenUserId INT
        DECLARE @IsUsed BIT
        DECLARE @ExpiryDate DATETIME
        DECLARE @IsUserActive BIT
        
        SELECT 
            @TokenUserId = pr.UserId,
            @IsUsed = pr.IsUsed,
            @ExpiryDate = pr.ExpiryDate,
            @IsUserActive = u.IsActive
        FROM [dbo].[PasswordRecovery] pr
        INNER JOIN [dbo].[Users] u ON pr.UserId = u.UserId
        WHERE pr.RecoveryToken = @RecoveryToken
        
        -- Token not found
        IF @TokenUserId IS NULL
        BEGIN
            SET @ResultCode = 4
            SET @ResultMessage = 'Recovery token not found'
            RETURN 0
        END
        
        -- User is inactive
        IF @IsUserActive = 0
        BEGIN
            SET @ResultCode = 5
            SET @ResultMessage = 'Associated user account is inactive'
            RETURN 0
        END
        
        -- Token already used
        IF @IsUsed = 1
        BEGIN
            SET @ResultCode = 3
            SET @ResultMessage = 'Recovery token has already been used'
            RETURN 0
        END
        
        -- Token expired
        IF @ExpiryDate <= GETDATE()
        BEGIN
            SET @ResultCode = 2
            SET @ResultMessage = 'Recovery token has expired'
            RETURN 0
        END
        
        -- Token is valid
        SET @UserId = @TokenUserId
        SET @ResultCode = 1
        SET @ResultMessage = 'Recovery token is valid'
        RETURN 0
        
    END TRY
    BEGIN CATCH
        SET @ResultCode = -999
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE()
        RETURN -1
    END CATCH
END
GO

-- =============================================
-- Stored Procedure: sp_UsePasswordRecoveryToken
-- Author: Claude Code SQL Expert
-- Create date: 2025-09-06
-- Description: Uses a recovery token to reset user password and marks token as used
-- Parameters:  
--   @RecoveryToken - UUID token to use for password reset
--   @NewPasswordHash - New SHA256 password hash for the user
--   @UpdateIP - IP address performing the password update (optional)
--   @ResultCode - OUTPUT parameter: 1 = success, negative = error
--   @ResultMessage - OUTPUT parameter with detailed message
-- Returns:     0 for success, -1 for error
-- Security:    Validates token, updates password, marks token as used, atomic transaction
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_UsePasswordRecoveryToken]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_UsePasswordRecoveryToken]
GO

CREATE PROCEDURE [dbo].[sp_UsePasswordRecoveryToken]
    @RecoveryToken UNIQUEIDENTIFIER,
    @NewPasswordHash NVARCHAR(64),
    @UpdateIP NVARCHAR(45) = NULL,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Initialize output parameters
    SET @ResultCode = 0
    SET @ResultMessage = 'Success'
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Input validation
        IF @RecoveryToken IS NULL
        BEGIN
            SET @ResultCode = -1
            SET @ResultMessage = 'Recovery token cannot be null'
            ROLLBACK TRANSACTION
            RETURN -1
        END
        
        IF @NewPasswordHash IS NULL OR LTRIM(RTRIM(@NewPasswordHash)) = ''
        BEGIN
            SET @ResultCode = -2
            SET @ResultMessage = 'New password hash cannot be null or empty'
            ROLLBACK TRANSACTION
            RETURN -1
        END
        
        -- Validate password hash length (SHA256 should be 64 characters)
        IF LEN(@NewPasswordHash) != 64
        BEGIN
            SET @ResultCode = -3
            SET @ResultMessage = 'Invalid password hash format (expected 64-character SHA256)'
            ROLLBACK TRANSACTION
            RETURN -1
        END
        
        -- First validate the token using our validation procedure
        DECLARE @TokenUserId INT
        DECLARE @ValidationResultCode INT
        DECLARE @ValidationMessage NVARCHAR(255)
        
        EXEC [dbo].[sp_ValidatePasswordRecoveryToken] 
            @RecoveryToken = @RecoveryToken,
            @UserId = @TokenUserId OUTPUT,
            @ResultCode = @ValidationResultCode OUTPUT,
            @ResultMessage = @ValidationMessage OUTPUT
        
        -- If token validation failed, return the validation error
        IF @ValidationResultCode != 1
        BEGIN
            SET @ResultCode = @ValidationResultCode
            SET @ResultMessage = @ValidationMessage
            ROLLBACK TRANSACTION
            RETURN -1
        END
        
        -- Update user password
        UPDATE [dbo].[Users]
        SET PasswordHash = @NewPasswordHash
        WHERE UserId = @TokenUserId AND IsActive = 1
        
        IF @@ROWCOUNT = 0
        BEGIN
            SET @ResultCode = -4
            SET @ResultMessage = 'Failed to update user password'
            ROLLBACK TRANSACTION
            RETURN -1
        END
        
        -- Mark recovery token as used
        UPDATE [dbo].[PasswordRecovery]
        SET IsUsed = 1,
            UsedDate = GETDATE()
        WHERE RecoveryToken = @RecoveryToken
        
        IF @@ROWCOUNT = 0
        BEGIN
            SET @ResultCode = -5
            SET @ResultMessage = 'Failed to mark recovery token as used'
            ROLLBACK TRANSACTION
            RETURN -1
        END
        
        COMMIT TRANSACTION
        
        -- Success
        SET @ResultCode = 1
        SET @ResultMessage = 'Password reset successfully'
        RETURN 0
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        
        SET @ResultCode = -999
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE()
        RETURN -1
    END CATCH
END
GO

-- =============================================
-- Stored Procedure: sp_CleanupExpiredRecoveryTokens
-- Author: Claude Code SQL Expert
-- Create date: 2025-09-06
-- Description: Housekeeping procedure to clean up expired recovery tokens
-- Parameters:  
--   @CleanupDays - Number of days to keep expired tokens (default 7 for audit trail)
--   @ResultCode - OUTPUT parameter: number of records cleaned up, negative = error
--   @ResultMessage - OUTPUT parameter with detailed message
-- Returns:     0 for success, -1 for error
-- Security:    Only removes tokens older than specified days and already expired/used
-- Usage:       Should be called periodically via SQL Server Agent job
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CleanupExpiredRecoveryTokens]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_CleanupExpiredRecoveryTokens]
GO

CREATE PROCEDURE [dbo].[sp_CleanupExpiredRecoveryTokens]
    @CleanupDays INT = 7,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Initialize output parameters
    SET @ResultCode = 0
    SET @ResultMessage = 'Success'
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Input validation
        IF @CleanupDays IS NULL OR @CleanupDays < 1
        BEGIN
            SET @CleanupDays = 7 -- Default to 7 days
        END
        
        -- Calculate cleanup date
        DECLARE @CleanupDate DATETIME = DATEADD(DAY, -@CleanupDays, GETDATE())
        
        -- Delete expired and old recovery tokens
        DELETE FROM [dbo].[PasswordRecovery]
        WHERE (ExpiryDate < @CleanupDate)  -- Expired more than X days ago
           OR (IsUsed = 1 AND UsedDate < @CleanupDate) -- Used more than X days ago
        
        DECLARE @RecordsDeleted INT = @@ROWCOUNT
        
        COMMIT TRANSACTION
        
        -- Success
        SET @ResultCode = @RecordsDeleted
        SET @ResultMessage = 'Cleanup completed. Removed ' + CAST(@RecordsDeleted AS NVARCHAR(10)) + ' expired recovery tokens'
        RETURN 0
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        
        SET @ResultCode = -999
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE()
        RETURN -1
    END CATCH
END
GO

-- =============================================
-- Stored Procedure: sp_GetPasswordRecoveryStats
-- Author: Claude Code SQL Expert
-- Create date: 2025-09-06
-- Description: Returns statistics about password recovery requests for monitoring
-- Parameters:  None
-- Returns:     Result set with recovery statistics
-- Usage:       For administrative monitoring and security analysis
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_GetPasswordRecoveryStats]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_GetPasswordRecoveryStats]
GO

CREATE PROCEDURE [dbo].[sp_GetPasswordRecoveryStats]
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        'Active Tokens' AS StatType,
        COUNT(*) AS Count
    FROM [dbo].[PasswordRecovery]
    WHERE IsUsed = 0 AND ExpiryDate > GETDATE()
    
    UNION ALL
    
    SELECT 
        'Expired Tokens' AS StatType,
        COUNT(*) AS Count
    FROM [dbo].[PasswordRecovery]
    WHERE IsUsed = 0 AND ExpiryDate <= GETDATE()
    
    UNION ALL
    
    SELECT 
        'Used Tokens' AS StatType,
        COUNT(*) AS Count
    FROM [dbo].[PasswordRecovery]
    WHERE IsUsed = 1
    
    UNION ALL
    
    SELECT 
        'Total Requests Today' AS StatType,
        COUNT(*) AS Count
    FROM [dbo].[PasswordRecovery]
    WHERE CAST(CreatedDate AS DATE) = CAST(GETDATE() AS DATE)
    
    UNION ALL
    
    SELECT 
        'Successful Recoveries Today' AS StatType,
        COUNT(*) AS Count
    FROM [dbo].[PasswordRecovery]
    WHERE IsUsed = 1 AND CAST(UsedDate AS DATE) = CAST(GETDATE() AS DATE)
    
    ORDER BY StatType
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
    'sp_CreatePasswordRecoveryRequest',
    'sp_ValidatePasswordRecoveryToken', 
    'sp_UsePasswordRecoveryToken',
    'sp_CleanupExpiredRecoveryTokens',
    'sp_GetPasswordRecoveryStats'
)
ORDER BY name

PRINT 'Password Recovery System created successfully!'
PRINT 'Features implemented:'
PRINT '- Secure UUID token generation'
PRINT '- 15-minute token expiration'
PRINT '- One-time use validation'
PRINT '- IP address tracking'
PRINT '- Comprehensive error handling'
PRINT '- Automatic cleanup capabilities'
PRINT '- Administrative monitoring'
PRINT '- Audit trail preservation'
PRINT ''
PRINT 'SECURITY NOTES:'
PRINT '- Tokens are cryptographically secure UUIDs'
PRINT '- Maximum 1 request per user per 5 minutes (anti-spam)'
PRINT '- All operations are transactional for data integrity'
PRINT '- Comprehensive input validation on all parameters'
PRINT '- IP address logging for security audit'
PRINT ''
PRINT 'MAINTENANCE:'
PRINT '- Run sp_CleanupExpiredRecoveryTokens weekly via SQL Agent'
PRINT '- Monitor stats with sp_GetPasswordRecoveryStats'
PRINT '- Review PasswordRecovery table for security analysis'