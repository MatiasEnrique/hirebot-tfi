-- =============================================
-- Obtener el ERROR REAL del SQL Server Error Log
-- Ejecutar en SSMS en la base master INMEDIATAMENTE después del error
-- =============================================

USE [master]
GO

PRINT '========================================';
PRINT 'SQL SERVER ERROR LOG - ERROR REAL';
PRINT '========================================';
PRINT '';
I GET
-- Ver los últimos errores (último minuto) sin filtro
PRINT 'Últimos mensajes del error log (incluye el error subyacente):';
PRINT '-------------------------------------------------------------';

DECLARE @Time DATETIME = DATEADD(MINUTE, -1, GETDATE());

CREATE TABLE #ErrorLog (
    LogDate DATETIME,
    ProcessInfo NVARCHAR(100),
    LogText NVARCHAR(MAX)
);

INSERT INTO #ErrorLog
EXEC xp_readerrorlog 0, 1, N'', N'', @Time, NULL, N'DESC';

-- Mostrar todos los mensajes recientes
SELECT
    LogDate,
    ProcessInfo,
    LogText
FROM #ErrorLog
ORDER BY LogDate DESC;

DROP TABLE #ErrorLog;

PRINT '';
PRINT '========================================';
PRINT 'BUSCAR ESPECÍFICAMENTE:';
PRINT '- Mensajes con "failed"';
PRINT '- Mensajes con "operating system error"';
PRINT '- Mensajes con "access denied"';
PRINT '- Mensajes con "I/O error"';
PRINT '========================================';
