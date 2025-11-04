-- =============================================
-- Test Script for Enhanced sp_Hirebot_BackupDatabase
-- =============================================
-- This script tests the improved backup procedure with comprehensive error handling
-- Execute this in SQL Server Management Studio (SSMS)
-- =============================================

USE [master]
GO

PRINT '========================================';
PRINT 'Testing sp_Hirebot_BackupDatabase';
PRINT '========================================';
PRINT '';

-- =============================================
-- Test 1: Check if procedure exists
-- =============================================
PRINT 'Test 1: Checking if procedure exists...';
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_BackupDatabase')
    PRINT 'SUCCESS: Procedure sp_Hirebot_BackupDatabase exists';
ELSE
BEGIN
    PRINT 'ERROR: Procedure sp_Hirebot_BackupDatabase does not exist';
    PRINT 'Please run AdminDatabaseStoredProcedures.sql first';
    RETURN;
END
PRINT '';

-- =============================================
-- Test 2: Check SQL Server service account
-- =============================================
PRINT 'Test 2: SQL Server Service Account Information...';
SELECT
    servicename AS 'Service Name',
    service_account AS 'Service Account',
    status_desc AS 'Status'
FROM sys.dm_server_services
WHERE servicename LIKE 'SQL Server (%';
PRINT '';

-- =============================================
-- Test 3: Test with invalid path (null)
-- =============================================
PRINT 'Test 3: Testing with NULL path (should fail with validation error)...';
DECLARE @ErrorDetails1 NVARCHAR(MAX);
BEGIN TRY
    EXEC sp_Hirebot_BackupDatabase
        @BackupPath = NULL,
        @ErrorDetails = @ErrorDetails1 OUTPUT;
    PRINT 'ERROR: Should have failed with null path';
END TRY
BEGIN CATCH
    PRINT 'EXPECTED FAILURE: ' + ERROR_MESSAGE();
    PRINT 'Error Details: ' + ISNULL(@ErrorDetails1, 'N/A');
END CATCH
PRINT '';

-- =============================================
-- Test 4: Test with invalid characters
-- =============================================
PRINT 'Test 4: Testing with invalid characters in path...';
DECLARE @ErrorDetails2 NVARCHAR(MAX);
BEGIN TRY
    EXEC sp_Hirebot_BackupDatabase
        @BackupPath = 'C:\Backup\test|invalid.bak',
        @ErrorDetails = @ErrorDetails2 OUTPUT;
    PRINT 'ERROR: Should have failed with invalid characters';
END TRY
BEGIN CATCH
    PRINT 'EXPECTED FAILURE: ' + ERROR_MESSAGE();
    PRINT 'Error Details: ' + ISNULL(@ErrorDetails2, 'N/A');
END CATCH
PRINT '';

-- =============================================
-- Test 5: Test with non-existent directory
-- =============================================
PRINT 'Test 5: Testing with non-existent directory...';
DECLARE @ErrorDetails3 NVARCHAR(MAX);
BEGIN TRY
    EXEC sp_Hirebot_BackupDatabase
        @BackupPath = 'C:\NonExistentDirectory\backup.bak',
        @ErrorDetails = @ErrorDetails3 OUTPUT;
    PRINT 'ERROR: Should have failed with directory not found';
END TRY
BEGIN CATCH
    PRINT 'EXPECTED FAILURE: ' + ERROR_MESSAGE();
    PRINT 'Error Details: ' + ISNULL(@ErrorDetails3, 'N/A');
END CATCH
PRINT '';

-- =============================================
-- Test 6: Test with valid path (MODIFY THIS)
-- =============================================
PRINT 'Test 6: Testing with valid path...';
PRINT 'NOTE: Modify the path below to match your environment';
PRINT '';

-- MODIFY THIS PATH TO YOUR ACTUAL BACKUP DIRECTORY
DECLARE @BackupPath NVARCHAR(500) = 'C:\SQLBackups\Hirebot_Test_' +
    CONVERT(VARCHAR(8), GETDATE(), 112) + '_' +
    REPLACE(CONVERT(VARCHAR(8), GETDATE(), 108), ':', '') + '.bak';

PRINT 'Backup Path: ' + @BackupPath;
PRINT '';

-- Check if directory exists
DECLARE @BackupDir NVARCHAR(500) = 'C:\SQLBackups';
PRINT 'Checking if directory exists: ' + @BackupDir;

CREATE TABLE #DirCheck (
    FileExists INT,
    FileIsDirectory INT,
    ParentDirectoryExists INT
);

BEGIN TRY
    INSERT INTO #DirCheck
    EXEC master.dbo.xp_fileexist @BackupDir;

    DECLARE @DirExists INT;
    SELECT @DirExists = ParentDirectoryExists FROM #DirCheck;

    IF @DirExists = 1
    BEGIN
        PRINT 'Directory exists. Proceeding with backup test...';
        PRINT '';

        DECLARE @ErrorDetails6 NVARCHAR(MAX);
        BEGIN TRY
            EXEC sp_Hirebot_BackupDatabase
                @BackupPath = @BackupPath,
                @ErrorDetails = @ErrorDetails6 OUTPUT;

            PRINT 'SUCCESS: Backup completed';
            PRINT 'Details: ' + ISNULL(@ErrorDetails6, 'N/A');
            PRINT '';

            -- Verify backup file exists
            PRINT 'Verifying backup file...';
            CREATE TABLE #FileCheck (
                FileExists INT,
                FileIsDirectory INT,
                ParentDirectoryExists INT
            );

            INSERT INTO #FileCheck
            EXEC master.dbo.xp_fileexist @BackupPath;

            DECLARE @FileExists INT;
            SELECT @FileExists = FileExists FROM #FileCheck;

            IF @FileExists = 1
                PRINT 'SUCCESS: Backup file verified at: ' + @BackupPath;
            ELSE
                PRINT 'WARNING: Backup file not found at: ' + @BackupPath;

            DROP TABLE #FileCheck;
        END TRY
        BEGIN CATCH
            PRINT 'FAILURE: Backup failed';
            PRINT 'Error: ' + ERROR_MESSAGE();
            PRINT 'Error Details: ' + ISNULL(@ErrorDetails6, 'N/A');
        END CATCH
    END
    ELSE
    BEGIN
        PRINT 'Directory does not exist. Please create: ' + @BackupDir;
        PRINT 'Then rerun this test.';
    END

    DROP TABLE #DirCheck;
END TRY
BEGIN CATCH
    IF OBJECT_ID('tempdb..#DirCheck') IS NOT NULL
        DROP TABLE #DirCheck;
    PRINT 'ERROR checking directory: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- =============================================
-- Test 7: Show SQL Server default backup location
-- =============================================
PRINT 'Test 7: SQL Server Default Backup Location...';
DECLARE @DefaultBackupDir NVARCHAR(512);
EXEC master.dbo.xp_instance_regread
    N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'BackupDirectory',
    @DefaultBackupDir OUTPUT;

PRINT 'Default Backup Directory: ' + ISNULL(@DefaultBackupDir, 'Not configured');
PRINT 'TIP: You can use this directory for backups if it exists';
PRINT '';

-- =============================================
-- Test 8: Check required permissions
-- =============================================
PRINT 'Test 8: Checking required permissions...';
PRINT 'Required permissions for backup operations:';
PRINT '1. BACKUP DATABASE permission on Hirebot database';
PRINT '2. SQL Server service account must have Read/Write on backup directory';
PRINT '3. xp_fileexist, xp_dirtree, and xp_instance_regread must be enabled';
PRINT '';

-- Check if current user has BACKUP DATABASE permission
IF HAS_PERMS_BY_NAME('Hirebot', 'DATABASE', 'BACKUP DATABASE') = 1
    PRINT 'SUCCESS: Current user has BACKUP DATABASE permission';
ELSE
    PRINT 'WARNING: Current user may not have BACKUP DATABASE permission';
PRINT '';

-- =============================================
-- Summary
-- =============================================
PRINT '========================================';
PRINT 'Test Summary';
PRINT '========================================';
PRINT 'The enhanced sp_Hirebot_BackupDatabase procedure includes:';
PRINT '1. Parameter validation (null, empty, invalid characters)';
PRINT '2. Path format validation (.bak extension check)';
PRINT '3. SQL Server service account identification';
PRINT '4. Directory accessibility validation using xp_fileexist';
PRINT '5. Database state verification';
PRINT '6. Comprehensive error capture (number, severity, state, line)';
PRINT '7. Context-specific error guidance for common SQL Server backup errors';
PRINT '8. Output parameter for detailed error information';
PRINT '';
PRINT 'Common Error Codes Handled:';
PRINT '  3201 - Cannot open backup device';
PRINT '  3013 - BACKUP DATABASE is terminating abnormally';
PRINT '  3033 - Backup set cannot be appended';
PRINT '  5035 - Invalid backup path or permission denied';
PRINT '';
PRINT 'To use the procedure in your application:';
PRINT '  DECLARE @ErrorDetails NVARCHAR(MAX);';
PRINT '  EXEC sp_Hirebot_BackupDatabase';
PRINT '      @BackupPath = ''C:\SQLBackups\Hirebot.bak'',';
PRINT '      @ErrorDetails = @ErrorDetails OUTPUT;';
PRINT '  PRINT @ErrorDetails;';
PRINT '';
PRINT '========================================';
PRINT 'End of Tests';
PRINT '========================================';
