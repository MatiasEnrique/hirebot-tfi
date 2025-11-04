-- =============================================
-- Verify Admin Database Stored Procedures
-- Run this script in [master] database to verify setup
-- =============================================

USE [master]
GO

PRINT '========================================';
PRINT 'Verificando procedimientos almacenados...';
PRINT '========================================';
PRINT '';

-- Check sp_Hirebot_BackupDatabase
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_BackupDatabase')
    PRINT '✓ sp_Hirebot_BackupDatabase - EXISTE'
ELSE
    PRINT '✗ sp_Hirebot_BackupDatabase - NO EXISTE (ejecutar AdminDatabaseStoredProcedures.sql)';

-- Check sp_Hirebot_RestoreDatabase
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_RestoreDatabase')
    PRINT '✓ sp_Hirebot_RestoreDatabase - EXISTE'
ELSE
    PRINT '✗ sp_Hirebot_RestoreDatabase - NO EXISTE (ejecutar AdminDatabaseStoredProcedures.sql)';

-- Check sp_Hirebot_ListBackups
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_ListBackups')
    PRINT '✓ sp_Hirebot_ListBackups - EXISTE'
ELSE
    PRINT '✗ sp_Hirebot_ListBackups - NO EXISTE (ejecutar AdminDatabaseStoredProcedures.sql)';

-- Check sp_Hirebot_GetBackupInfo
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_GetBackupInfo')
    PRINT '✓ sp_Hirebot_GetBackupInfo - EXISTE'
ELSE
    PRINT '✗ sp_Hirebot_GetBackupInfo - NO EXISTE (ejecutar AdminDatabaseStoredProcedures.sql)';

PRINT '';
PRINT '========================================';
PRINT 'Verificación completada';
PRINT '========================================';
