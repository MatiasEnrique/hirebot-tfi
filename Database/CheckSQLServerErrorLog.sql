-- =============================================
-- Revisar el SQL Server Error Log para errores de backup
-- Ejecutar en SSMS en la base master
-- =============================================

USE [master]
GO

PRINT '========================================';
PRINT 'SQL SERVER ERROR LOG - Últimos errores';
PRINT '========================================';
PRINT '';

-- Ver los últimos 50 mensajes del error log relacionados con backup
EXEC xp_readerrorlog
    0,              -- Current error log file
    1,              -- SQL Server error log
    N'BACKUP',      -- Search string 1
    N'',            -- Search string 2
    NULL,           -- Start time
    NULL,           -- End time
    N'DESC';        -- Sort order

PRINT '';
PRINT '========================================';
PRINT 'Errores recientes (último minuto)';
PRINT '========================================';
PRINT '';

-- Ver TODOS los errores recientes (últimos 2 minutos)
DECLARE @TimeAgo DATETIME = DATEADD(MINUTE, -2, GETDATE());

EXEC xp_readerrorlog
    0,              -- Current error log file
    1,              -- SQL Server error log
    N'',            -- No filter
    N'',            -- No filter
    @TimeAgo,       -- Start time
    NULL,           -- End time
    N'DESC';        -- Sort order

PRINT '';
PRINT '========================================';
PRINT 'Información de espacio en disco';
PRINT '========================================';

-- Verificar espacio disponible en disco C:
EXEC xp_fixeddrives;

PRINT '';
PRINT '========================================';
PRINT 'Tamaño de la base de datos Hirebot';
PRINT '========================================';

-- Ver el tamaño de la base de datos
SELECT
    DB_NAME(database_id) AS DatabaseName,
    name AS LogicalFileName,
    type_desc AS FileType,
    CAST(size * 8.0 / 1024 AS DECIMAL(10,2)) AS 'Size (MB)',
    CAST(FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024 AS DECIMAL(10,2)) AS 'Used (MB)',
    physical_name AS PhysicalLocation
FROM sys.master_files
WHERE database_id = DB_ID('Hirebot')
ORDER BY type_desc;

PRINT '';
PRINT '========================================';
PRINT 'Configuración de compresión de backup';
PRINT '========================================';

-- Verificar si la compresión está soportada
SELECT
    SERVERPROPERTY('Edition') AS SQLServerEdition,
    CASE
        WHEN CAST(SERVERPROPERTY('Edition') AS VARCHAR(100)) LIKE '%Express%'
        THEN 'Express Edition - Compresión NO soportada en algunas versiones'
        ELSE 'Compresión debería estar soportada'
    END AS CompressionSupport;

PRINT '';
PRINT '========================================';
