-- =============================================
-- Test Connection and Verify Setup
-- Run this script in [master] database
-- =============================================

USE [master]
GO

PRINT '========================================';
PRINT 'TEST 1: Verificar conexión a master';
PRINT '========================================';
SELECT @@SERVERNAME AS ServerName, DB_NAME() AS CurrentDatabase;
PRINT '';

PRINT '========================================';
PRINT 'TEST 2: Verificar que Hirebot existe';
PRINT '========================================';
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Hirebot')
    PRINT '✓ Base de datos [Hirebot] existe'
ELSE
    PRINT '✗ Base de datos [Hirebot] NO existe';
PRINT '';

PRINT '========================================';
PRINT 'TEST 3: Verificar stored procedures';
PRINT '========================================';

DECLARE @SPCount INT = 0;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_BackupDatabase')
BEGIN
    PRINT '✓ sp_Hirebot_BackupDatabase - EXISTE';
    SET @SPCount = @SPCount + 1;
END
ELSE
    PRINT '✗ sp_Hirebot_BackupDatabase - NO EXISTE';

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_RestoreDatabase')
BEGIN
    PRINT '✓ sp_Hirebot_RestoreDatabase - EXISTE';
    SET @SPCount = @SPCount + 1;
END
ELSE
    PRINT '✗ sp_Hirebot_RestoreDatabase - NO EXISTE';

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_ListBackups')
BEGIN
    PRINT '✓ sp_Hirebot_ListBackups - EXISTE';
    SET @SPCount = @SPCount + 1;
END
ELSE
    PRINT '✗ sp_Hirebot_ListBackups - NO EXISTE';

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_GetBackupInfo')
BEGIN
    PRINT '✓ sp_Hirebot_GetBackupInfo - EXISTE';
    SET @SPCount = @SPCount + 1;
END
ELSE
    PRINT '✗ sp_Hirebot_GetBackupInfo - NO EXISTE';

PRINT '';
PRINT 'Total de procedimientos encontrados: ' + CAST(@SPCount AS VARCHAR(10)) + '/4';
PRINT '';

PRINT '========================================';
PRINT 'TEST 4: Intentar crear backup de prueba';
PRINT '========================================';

IF @SPCount = 4
BEGIN
    PRINT 'Todos los procedimientos existen. Procedimientos listos para usar.';
END
ELSE
BEGIN
    PRINT 'FALTA EJECUTAR: Database/AdminDatabaseStoredProcedures.sql';
    PRINT 'Pasos:';
    PRINT '1. Abrir AdminDatabaseStoredProcedures.sql en SSMS';
    PRINT '2. Asegurarse de estar conectado a [master]';
    PRINT '3. Ejecutar el script completo (F5)';
END
