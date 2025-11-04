-- =============================================
-- Test del stored procedure sp_Hirebot_ListBackups
-- Ejecutar en SSMS en la base master
-- =============================================

USE [master]
GO

PRINT '========================================';
PRINT 'TEST DE sp_Hirebot_ListBackups';
PRINT '========================================';
PRINT '';

-- Probar directamente
EXEC sp_Hirebot_ListBackups @BackupDirectory = 'C:\Backups';

PRINT '';
PRINT '========================================';
