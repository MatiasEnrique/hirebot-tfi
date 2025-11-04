-- =============================================
-- Script de diagnóstico para permisos de backup
-- Ejecutar en SQL Server Management Studio
-- =============================================

USE [master]
GO

PRINT '========================================';
PRINT 'DIAGNÓSTICO DE PERMISOS DE BACKUP';
PRINT '========================================';
PRINT '';

-- 1. Verificar cuenta de servicio de SQL Server
PRINT '1. CUENTA DE SERVICIO SQL SERVER:';
PRINT '-----------------------------------';
SELECT
    servicename AS 'Servicio',
    service_account AS 'Cuenta de Servicio',
    status_desc AS 'Estado'
FROM sys.dm_server_services
WHERE servicename LIKE 'SQL Server (%';
PRINT '';

-- 2. Verificar permisos del usuario actual
PRINT '2. USUARIO ACTUAL Y PERMISOS:';
PRINT '------------------------------';
SELECT
    SUSER_SNAME() AS 'Usuario Actual',
    IS_SRVROLEMEMBER('sysadmin') AS 'Es SysAdmin (1=Si, 0=No)';
PRINT '';

-- 3. Verificar si el procedimiento existe en master
PRINT '3. STORED PROCEDURES EN [master]:';
PRINT '----------------------------------';
SELECT
    name AS 'Procedimiento',
    create_date AS 'Fecha Creación',
    modify_date AS 'Última Modificación'
FROM sys.objects
WHERE type = 'P'
AND name LIKE 'sp_Hirebot_%'
ORDER BY name;
PRINT '';

-- 4. Verificar estado de la base de datos Hirebot
PRINT '4. ESTADO DE LA BASE DE DATOS:';
PRINT '-------------------------------';
SELECT
    name AS 'Base de Datos',
    state_desc AS 'Estado',
    user_access_desc AS 'Acceso',
    recovery_model_desc AS 'Modelo Recuperación'
FROM sys.databases
WHERE name = 'Hirebot';
PRINT '';

-- 5. Probar acceso a directorio con xp_fileexist
PRINT '5. PRUEBA DE ACCESO A DIRECTORIO:';
PRINT '----------------------------------';
DECLARE @TestPath NVARCHAR(260) = 'C:\Backups';
DECLARE @FileExists INT;
DECLARE @FileIsDirectory INT;
DECLARE @ParentDirectoryExists INT;

CREATE TABLE #DirTest (
    FileExists INT,
    FileIsDirectory INT,
    ParentDirectoryExists INT
);

BEGIN TRY
    PRINT 'Probando acceso a: ' + @TestPath;
    INSERT INTO #DirTest
    EXEC master.dbo.xp_fileexist @TestPath;

    SELECT
        @FileExists = FileExists,
        @FileIsDirectory = FileIsDirectory,
        @ParentDirectoryExists = ParentDirectoryExists
    FROM #DirTest;

    PRINT 'Archivo existe: ' + CAST(@FileExists AS VARCHAR(1)) + ' (1=Si, 0=No)';
    PRINT 'Es directorio: ' + CAST(@FileIsDirectory AS VARCHAR(1)) + ' (1=Si, 0=No)';
    PRINT 'Directorio padre existe: ' + CAST(@ParentDirectoryExists AS VARCHAR(1)) + ' (1=Si, 0=No)';

    DROP TABLE #DirTest;
END TRY
BEGIN CATCH
    PRINT 'ERROR al probar acceso al directorio:';
    PRINT ERROR_MESSAGE();
    IF OBJECT_ID('tempdb..#DirTest') IS NOT NULL
        DROP TABLE #DirTest;
END CATCH
PRINT '';

-- 6. Configuración de xp_cmdshell (para diagnóstico avanzado)
PRINT '6. CONFIGURACIÓN xp_cmdshell:';
PRINT '------------------------------';
SELECT
    name,
    CAST(value AS INT) AS 'Habilitado (1=Si, 0=No)',
    CAST(value_in_use AS INT) AS 'En Uso'
FROM sys.configurations
WHERE name = 'xp_cmdshell';
PRINT '';

-- 7. Prueba de backup a un archivo temporal
PRINT '7. PRUEBA DE BACKUP (a C:\Backups\TEST_Hirebot.bak):';
PRINT '------------------------------------------------------';
DECLARE @TestBackupPath NVARCHAR(500) = 'C:\Backups\TEST_Hirebot_' + CONVERT(VARCHAR(20), GETDATE(), 112) + '.bak';
DECLARE @ErrorDetails NVARCHAR(MAX);

BEGIN TRY
    PRINT 'Intentando crear backup de prueba...';
    PRINT 'Ruta: ' + @TestBackupPath;

    EXEC sp_Hirebot_BackupDatabase
        @BackupPath = @TestBackupPath,
        @ErrorDetails = @ErrorDetails OUTPUT;

    PRINT '';
    PRINT 'RESULTADO DEL BACKUP:';
    PRINT @ErrorDetails;
END TRY
BEGIN CATCH
    PRINT '';
    PRINT 'ERROR EN BACKUP DE PRUEBA:';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT '';
    IF @ErrorDetails IS NOT NULL
    BEGIN
        PRINT 'Detalles adicionales:';
        PRINT @ErrorDetails;
    END
END CATCH
PRINT '';

PRINT '========================================';
PRINT 'FIN DEL DIAGNÓSTICO';
PRINT '========================================';
PRINT '';
PRINT 'SOLUCIONES COMUNES:';
PRINT '-------------------';
PRINT '1. Si ParentDirectoryExists = 0: Crear el directorio C:\Backups manualmente';
PRINT '2. Si hay error de permisos: Dar permisos de Control Total a la cuenta de servicio SQL Server en C:\Backups';
PRINT '3. Si xp_fileexist falla: Verificar permisos de la cuenta de servicio';
PRINT '4. Si el procedimiento no existe: Ejecutar AdminDatabaseStoredProcedures.sql en la base [master]';
PRINT '';
