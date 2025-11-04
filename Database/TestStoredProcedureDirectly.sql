-- =============================================
-- Test del stored procedure actualizado directamente
-- Ejecutar en SSMS en la base master
-- =============================================

USE [master]
GO

PRINT '========================================';
PRINT 'TEST DEL STORED PROCEDURE';
PRINT '========================================';
PRINT '';

-- 1. Verificar que el procedimiento existe
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_BackupDatabase')
    PRINT '✓ sp_Hirebot_BackupDatabase existe';
ELSE
BEGIN
    PRINT '✗ sp_Hirebot_BackupDatabase NO existe';
    PRINT 'Ejecuta AdminDatabaseStoredProcedures.sql primero';
    RETURN;
END

PRINT '';

-- 2. Probar el stored procedure directamente
DECLARE @BackupPath NVARCHAR(500) = 'C:\Backups\SP_TEST_' + CONVERT(VARCHAR(8), GETDATE(), 112) + '_' + REPLACE(CONVERT(VARCHAR(8), GETDATE(), 108), ':', '') + '.bak';
DECLARE @ErrorDetails NVARCHAR(MAX);

PRINT 'Llamando a sp_Hirebot_BackupDatabase...';
PRINT 'Path: ' + @BackupPath;
PRINT '';

BEGIN TRY
    EXEC sp_Hirebot_BackupDatabase
        @BackupPath = @BackupPath,
        @ErrorDetails = @ErrorDetails OUTPUT;

    PRINT '';
    PRINT '*** RESULTADO ***';
    PRINT @ErrorDetails;
    PRINT '';

    IF @ErrorDetails LIKE 'SUCCESS:%'
        PRINT '✓✓✓ BACKUP EXITOSO ✓✓✓';
    ELSE
        PRINT '✗ BACKUP FALLÓ - Ver mensaje arriba';
END TRY
BEGIN CATCH
    PRINT '';
    PRINT '*** ERROR CAPTURADO ***';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT '';
    IF @ErrorDetails IS NOT NULL
    BEGIN
        PRINT 'Detalles del error:';
        PRINT @ErrorDetails;
    END
END CATCH

PRINT '';
PRINT '========================================';
PRINT 'Verificar si el archivo fue creado:';
PRINT @BackupPath;
PRINT '========================================';
