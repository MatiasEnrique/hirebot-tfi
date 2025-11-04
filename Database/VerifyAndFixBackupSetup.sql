-- =============================================
-- Script para verificar y corregir la configuración de backup
-- Ejecutar en SQL Server Management Studio
-- =============================================

USE [master]
GO

PRINT '========================================';
PRINT 'VERIFICACIÓN DE SETUP DE BACKUP';
PRINT '========================================';
PRINT '';

-- 1. Verificar si los procedimientos existen
PRINT '1. Verificando stored procedures...';
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_BackupDatabase')
    PRINT '   ✓ sp_Hirebot_BackupDatabase existe';
ELSE
    PRINT '   ✗ sp_Hirebot_BackupDatabase NO existe - ejecutar AdminDatabaseStoredProcedures.sql';

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_RestoreDatabase')
    PRINT '   ✓ sp_Hirebot_RestoreDatabase existe';
ELSE
    PRINT '   ✗ sp_Hirebot_RestoreDatabase NO existe';

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_ListBackups')
    PRINT '   ✓ sp_Hirebot_ListBackups existe';
ELSE
    PRINT '   ✗ sp_Hirebot_ListBackups NO existe';

PRINT '';

-- 2. Verificar permisos de xp_cmdshell (para diagnóstico avanzado)
PRINT '2. Probando permisos del sistema de archivos...';
DECLARE @TestResult TABLE (Output NVARCHAR(4000));

BEGIN TRY
    -- Intentar usar xp_fileexist para probar acceso
    DECLARE @FileExists INT, @DirExists INT, @ParentExists INT;

    CREATE TABLE #FileTest (
        FileExists INT,
        FileIsDir INT,
        ParentDirExists INT
    );

    INSERT INTO #FileTest
    EXEC master.dbo.xp_fileexist 'C:\Backups';

    SELECT
        @FileExists = FileExists,
        @DirExists = FileIsDir,
        @ParentExists = ParentDirExists
    FROM #FileTest;

    IF @ParentExists = 1
        PRINT '   ✓ SQL Server puede ver el directorio C:\Backups';
    ELSE
        PRINT '   ✗ SQL Server NO puede ver C:\Backups - verificar que existe';

    DROP TABLE #FileTest;
END TRY
BEGIN CATCH
    PRINT '   ✗ Error al verificar directorio: ' + ERROR_MESSAGE();
END CATCH

PRINT '';

-- 3. Información de la cuenta de servicio
PRINT '3. Cuenta de servicio SQL Server:';
SELECT
    '   Servicio: ' + servicename AS Info,
    '   Cuenta: ' + service_account AS Info2
FROM sys.dm_server_services
WHERE servicename LIKE 'SQL Server (%';

PRINT '';

-- 4. Crear directorio de prueba si es posible
PRINT '4. Intentando crear un backup de prueba simple...';
DECLARE @TestPath NVARCHAR(500) = 'C:\Backups\TEST_' + CONVERT(VARCHAR(8), GETDATE(), 112) + '.bak';
DECLARE @SQL NVARCHAR(MAX);

BEGIN TRY
    SET @SQL = 'BACKUP DATABASE [Hirebot] TO DISK = N''' + @TestPath + ''' WITH FORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, STATS = 10;';
    EXEC(@SQL);
    PRINT '   ✓ ¡ÉXITO! Backup de prueba creado en: ' + @TestPath;
    PRINT '';
    PRINT '   Si esto funcionó, el problema está resuelto.';
    PRINT '   Puedes eliminar el archivo de prueba: ' + @TestPath;
END TRY
BEGIN CATCH
    PRINT '   ✗ FALLÓ: Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT '   Mensaje: ' + ERROR_MESSAGE();
    PRINT '';
    PRINT '   SOLUCIÓN REQUERIDA:';
    PRINT '   1. Abre el Explorador de Windows';
    PRINT '   2. Navega a C:\ y crea la carpeta "Backups" si no existe';
    PRINT '   3. Clic derecho en C:\Backups → Propiedades → Seguridad → Editar';
    PRINT '   4. Click en "Agregar"';
    PRINT '   5. Escribe: NT Service\MSSQL$SQLEXPRESS';
    PRINT '   6. Click "Comprobar nombres" → Aceptar';
    PRINT '   7. Selecciona la cuenta y marca "Control total"';
    PRINT '   8. Aplicar → Aceptar';
    PRINT '';
    PRINT '   Alternativamente, ejecuta este comando en PowerShell como Administrador:';
    PRINT '   icacls "C:\Backups" /grant "NT Service\MSSQL$SQLEXPRESS:(OI)(CI)F"';
END CATCH

PRINT '';
PRINT '========================================';
PRINT 'FIN DE VERIFICACIÓN';
PRINT '========================================';
