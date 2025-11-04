-- =============================================
-- Test de backup SIMPLE sin opciones complejas
-- Ejecutar en SSMS en la base master
-- =============================================

USE [master]
GO

PRINT '========================================';
PRINT 'TEST DE BACKUP SIMPLE';
PRINT '========================================';
PRINT '';

DECLARE @BackupPath NVARCHAR(500) = 'C:\Backups\SIMPLE_TEST.bak';

PRINT '1. Verificando edición de SQL Server...';
SELECT
    SERVERPROPERTY('Edition') AS Edition,
    SERVERPROPERTY('ProductVersion') AS Version,
    SERVERPROPERTY('ProductLevel') AS ServicePack;
PRINT '';

PRINT '2. Verificando estado de la base de datos Hirebot...';
SELECT
    name,
    state_desc,
    user_access_desc
FROM sys.databases
WHERE name = 'Hirebot';
PRINT '';

PRINT '3. Intentando backup MÁS SIMPLE posible (sin compresión, sin opciones)...';
PRINT 'Ruta: ' + @BackupPath;
BEGIN TRY
    BACKUP DATABASE [Hirebot]
    TO DISK = @BackupPath
    WITH INIT;

    PRINT '';
    PRINT '*** ÉXITO ***';
    PRINT 'Backup creado exitosamente en: ' + @BackupPath;
    PRINT '';
    PRINT 'Esto significa que:';
    PRINT '- Los permisos están correctos';
    PRINT '- El problema puede estar en las opciones del backup (COMPRESSION, etc)';
END TRY
BEGIN CATCH
    PRINT '';
    PRINT '*** ERROR ***';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT '';

    -- Si falló, intentar sin WITH INIT
    PRINT '4. Intentando sin WITH INIT...';
    BEGIN TRY
        DECLARE @BackupPath2 NVARCHAR(500) = 'C:\Backups\SIMPLE_TEST2.bak';
        BACKUP DATABASE [Hirebot] TO DISK = @BackupPath2;

        PRINT '*** ÉXITO con backup básico ***';
        PRINT 'Archivo: ' + @BackupPath2;
    END TRY
    BEGIN CATCH
        PRINT '*** También falló el backup básico ***';
        PRINT 'Error: ' + ERROR_MESSAGE();
        PRINT '';
        PRINT 'Revisar el Error Log de SQL Server:';
        PRINT 'EXEC xp_readerrorlog 0, 1, N''BACKUP''';
    END CATCH
END CATCH

PRINT '';
PRINT '========================================';
