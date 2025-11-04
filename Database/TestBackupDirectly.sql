-- =============================================
-- Test de backup directo sin stored procedure
-- Ejecutar en SSMS conectado a la base MASTER
-- =============================================

USE [master]
GO

PRINT '========================================';
PRINT 'TEST DE BACKUP DIRECTO';
PRINT '========================================';
PRINT '';

-- 1. Verificar estado de la base de datos
PRINT '1. Estado de la base de datos Hirebot:';
SELECT
    name,
    state_desc,
    user_access_desc,
    recovery_model_desc,
    database_id
FROM sys.databases
WHERE name = 'Hirebot';
PRINT '';

-- 2. Verificar si hay sesiones activas que puedan estar bloqueando
PRINT '2. Sesiones activas en Hirebot:';
SELECT
    session_id,
    login_name,
    host_name,
    program_name,
    status
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('Hirebot');
PRINT '';

-- 3. Intentar backup con comando T-SQL directo (sin dynamic SQL)
PRINT '3. Intentando backup directo con T-SQL...';
DECLARE @BackupFile NVARCHAR(500) = 'C:\Backups\DirectTest_' + CONVERT(VARCHAR(8), GETDATE(), 112) + '.bak';
PRINT 'Archivo: ' + @BackupFile;
PRINT '';

BEGIN TRY
    BACKUP DATABASE [Hirebot]
    TO DISK = @BackupFile
    WITH
        FORMAT,
        INIT,
        NAME = 'Hirebot Test Backup',
        SKIP,
        NOREWIND,
        NOUNLOAD,
        COMPRESSION,
        STATS = 10;

    PRINT '';
    PRINT '*** ÉXITO *** Backup creado correctamente!';
    PRINT 'Archivo: ' + @BackupFile;
    PRINT '';
    PRINT 'Si este backup funcionó, el problema está en el stored procedure.';
END TRY
BEGIN CATCH
    PRINT '';
    PRINT '*** ERROR ***';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR(10));
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT '';

    -- Diagnóstico adicional según el error
    IF ERROR_NUMBER() = 3013
    BEGIN
        PRINT 'DIAGNÓSTICO ADICIONAL:';
        PRINT '---';

        -- Verificar espacio en disco
        PRINT 'Verificando espacio en disco C:...';
        EXEC xp_cmdshell 'wmic logicaldisk where "DeviceID=''C:''" get FreeSpace,Size';
        PRINT '';

        -- Verificar acceso al archivo
        PRINT 'Verificando acceso al directorio...';
        DECLARE @FileTest TABLE (FileExists INT, IsDir INT, ParentExists INT);
        INSERT INTO @FileTest
        EXEC master.dbo.xp_fileexist 'C:\Backups';

        SELECT
            CASE FileExists WHEN 1 THEN 'Sí' ELSE 'No' END AS 'Archivo/Directorio Existe',
            CASE IsDir WHEN 1 THEN 'Sí' ELSE 'No' END AS 'Es Directorio',
            CASE ParentExists WHEN 1 THEN 'Sí' ELSE 'No' END AS 'Directorio Padre Existe'
        FROM @FileTest;
        PRINT '';

        -- Verificar si hay archivos .bak existentes que puedan estar bloqueados
        PRINT 'Archivos existentes en C:\Backups:';
        EXEC xp_cmdshell 'dir C:\Backups\*.bak /B';
        PRINT '';
    END

    PRINT 'POSIBLES CAUSAS:';
    PRINT '1. Antivirus bloqueando la creación del archivo';
    PRINT '2. Disco lleno o casi lleno';
    PRINT '3. Archivo .bak existente bloqueado por otro proceso';
    PRINT '4. xp_cmdshell deshabilitado (necesario para algunas operaciones)';
    PRINT '5. SQL Server Express tiene límite de 10GB por base de datos';
END CATCH

PRINT '';
PRINT '========================================';
PRINT 'FIN DEL TEST';
PRINT '========================================';
