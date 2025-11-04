-- =============================================
-- Admin Database Backup and Restore Procedures
-- These procedures must be created in the [master] database
-- =============================================

USE [master]
GO

-- =============================================
-- Procedure: sp_Hirebot_BackupDatabase
-- Description: Creates a full backup of Hirebot database
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_BackupDatabase')
    DROP PROCEDURE sp_Hirebot_BackupDatabase
GO

CREATE PROCEDURE sp_Hirebot_BackupDatabase
    @BackupPath NVARCHAR(500),
    @ErrorDetails NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BackupSQL NVARCHAR(MAX);
    DECLARE @ValidationSQL NVARCHAR(MAX);
    DECLARE @Directory NVARCHAR(500);
    DECLARE @FileName NVARCHAR(500);
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorNumber INT;
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @ErrorLine INT;
    DECLARE @ErrorProcedure NVARCHAR(200);
    DECLARE @ServiceAccount NVARCHAR(256);

    -- Initialize output parameter
    SET @ErrorDetails = NULL;

    BEGIN TRY
        -- =============================================
        -- STEP 1: Parameter Validation
        -- =============================================
        IF @BackupPath IS NULL OR LTRIM(RTRIM(@BackupPath)) = ''
        BEGIN
            SET @ErrorDetails = 'ERROR: Backup path cannot be null or empty.';
            RAISERROR(@ErrorDetails, 16, 1);
            RETURN -1;
        END

        -- Remove any quotes from the path
        SET @BackupPath = REPLACE(@BackupPath, '"', '');
        SET @BackupPath = REPLACE(@BackupPath, '''', '');

        -- =============================================
        -- STEP 2: Validate Path Format
        -- =============================================
        -- Check if path contains invalid characters
        IF @BackupPath LIKE '%[<>"|?*]%'
        BEGIN
            SET @ErrorDetails = 'ERROR: Backup path contains invalid characters (<>"|?*): ' + @BackupPath;
            RAISERROR(@ErrorDetails, 16, 1);
            RETURN -1;
        END

        -- Check if path has .bak extension
        IF RIGHT(@BackupPath, 4) <> '.bak'
        BEGIN
            SET @ErrorDetails = 'WARNING: Backup path should have .bak extension. Current path: ' + @BackupPath;
        END

        -- Extract directory and filename
        SET @Directory = LEFT(@BackupPath, LEN(@BackupPath) - CHARINDEX('\', REVERSE(@BackupPath)));
        SET @FileName = RIGHT(@BackupPath, CHARINDEX('\', REVERSE(@BackupPath)) - 1);

        -- =============================================
        -- STEP 3: Get SQL Server Service Account
        -- =============================================
        BEGIN TRY
            SELECT @ServiceAccount = service_account
            FROM sys.dm_server_services
            WHERE servicename LIKE 'SQL Server (%';
        END TRY
        BEGIN CATCH
            SET @ServiceAccount = 'UNKNOWN (insufficient permissions to query)';
        END CATCH

        -- =============================================
        -- STEP 4: Validate Directory Accessibility
        -- =============================================
        -- Create temp table for directory validation
        IF OBJECT_ID('tempdb..#DirTest') IS NOT NULL
            DROP TABLE #DirTest;

        CREATE TABLE #DirTest (
            FileExists INT,
            FileIsDirectory INT,
            ParentDirectoryExists INT
        );

        BEGIN TRY
            -- Use xp_fileexist to check directory
            INSERT INTO #DirTest
            EXEC master.dbo.xp_fileexist @Directory;

            DECLARE @ParentDirExists INT;
            SELECT @ParentDirExists = ParentDirectoryExists FROM #DirTest;

            IF @ParentDirExists = 0
            BEGIN
                SET @ErrorDetails = 'ERROR: Backup directory does not exist or is not accessible: ' + @Directory +
                                   CHAR(13) + CHAR(10) +
                                   'SQL Server Service Account: ' + @ServiceAccount +
                                   CHAR(13) + CHAR(10) +
                                   'Please ensure:' + CHAR(13) + CHAR(10) +
                                   '1. The directory exists' + CHAR(13) + CHAR(10) +
                                   '2. SQL Server service account has Read/Write permissions' + CHAR(13) + CHAR(10) +
                                   '3. The path is a valid Windows path (not UNC path without proper authentication)';
                DROP TABLE #DirTest;
                RAISERROR(@ErrorDetails, 16, 1);
                RETURN -1;
            END

            DROP TABLE #DirTest;
        END TRY
        BEGIN CATCH
            IF OBJECT_ID('tempdb..#DirTest') IS NOT NULL
                DROP TABLE #DirTest;

            SET @ErrorDetails = 'ERROR: Cannot validate directory accessibility. ' +
                               'Directory: ' + @Directory +
                               CHAR(13) + CHAR(10) +
                               'xp_fileexist error: ' + ERROR_MESSAGE() +
                               CHAR(13) + CHAR(10) +
                               'SQL Server Service Account: ' + @ServiceAccount;
            RAISERROR(@ErrorDetails, 16, 1);
            RETURN -1;
        END CATCH

        -- =============================================
        -- STEP 5: Check Database Accessibility
        -- =============================================
        IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Hirebot' AND state = 0)
        BEGIN
            SET @ErrorDetails = 'ERROR: Hirebot database is not accessible or not online.';
            RAISERROR(@ErrorDetails, 16, 1);
            RETURN -1;
        END

        -- =============================================
        -- STEP 6: Check if backup file already exists and is locked
        -- =============================================
        IF OBJECT_ID('tempdb..#BackupFileCheck') IS NOT NULL
            DROP TABLE #BackupFileCheck;

        CREATE TABLE #BackupFileCheck (
            FileExists INT,
            FileIsDirectory INT,
            ParentDirectoryExists INT
        );

        BEGIN TRY
            INSERT INTO #BackupFileCheck
            EXEC master.dbo.xp_fileexist @BackupPath;

            DECLARE @FileAlreadyExists INT;
            SELECT @FileAlreadyExists = FileExists FROM #BackupFileCheck;

            -- If file exists, warn but continue (WITH INIT will overwrite)
            IF @FileAlreadyExists = 1
            BEGIN
                SET @ErrorDetails = 'INFO: Backup file already exists and will be overwritten: ' + @BackupPath;
            END

            DROP TABLE #BackupFileCheck;
        END TRY
        BEGIN CATCH
            IF OBJECT_ID('tempdb..#BackupFileCheck') IS NOT NULL
                DROP TABLE #BackupFileCheck;
            -- Continue anyway
        END CATCH

        -- =============================================
        -- STEP 7: Execute Backup with SIMPLE options that work
        -- =============================================
        -- Based on successful test, use minimal options
        BEGIN TRY
            BACKUP DATABASE [Hirebot]
            TO DISK = @BackupPath
            WITH INIT, NAME = N'Hirebot Full Backup';
        END TRY
        BEGIN CATCH
            -- Re-throw with additional context
            DECLARE @InnerError NVARCHAR(4000) = ERROR_MESSAGE();
            DECLARE @InnerErrorNum INT = ERROR_NUMBER();

            SET @ErrorDetails = 'BACKUP command failed during execution.' + CHAR(13) + CHAR(10) +
                               'Error ' + CAST(@InnerErrorNum AS NVARCHAR(10)) + ': ' + @InnerError + CHAR(13) + CHAR(10) +
                               'Path: ' + @BackupPath + CHAR(13) + CHAR(10) +
                               'This often indicates:' + CHAR(13) + CHAR(10) +
                               '1. Insufficient disk space' + CHAR(13) + CHAR(10) +
                               '2. Antivirus blocking file creation' + CHAR(13) + CHAR(10) +
                               '3. File locked by another process' + CHAR(13) + CHAR(10) +
                               '4. Database in use (try closing connections)';
            RAISERROR(@ErrorDetails, 16, 1);
            RETURN -1;
        END CATCH

        -- Success message
        SET @ErrorDetails = 'SUCCESS: Backup completed successfully to: ' + @BackupPath;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- =============================================
        -- Comprehensive Error Capture
        -- =============================================
        SET @ErrorNumber = ERROR_NUMBER();
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();
        SET @ErrorLine = ERROR_LINE();
        SET @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), 'sp_Hirebot_BackupDatabase');
        SET @ErrorMessage = ERROR_MESSAGE();

        -- Build detailed error message
        SET @ErrorDetails =
            'BACKUP DATABASE FAILED' + CHAR(13) + CHAR(10) +
            '================================' + CHAR(13) + CHAR(10) +
            'Error Number: ' + CAST(@ErrorNumber AS NVARCHAR(10)) + CHAR(13) + CHAR(10) +
            'Error Severity: ' + CAST(@ErrorSeverity AS NVARCHAR(10)) + CHAR(13) + CHAR(10) +
            'Error State: ' + CAST(@ErrorState AS NVARCHAR(10)) + CHAR(13) + CHAR(10) +
            'Error Line: ' + CAST(@ErrorLine AS NVARCHAR(10)) + CHAR(13) + CHAR(10) +
            'Error Procedure: ' + @ErrorProcedure + CHAR(13) + CHAR(10) +
            'Error Message: ' + @ErrorMessage + CHAR(13) + CHAR(10) +
            '================================' + CHAR(13) + CHAR(10) +
            'Backup Path: ' + @BackupPath + CHAR(13) + CHAR(10) +
            'Directory: ' + ISNULL(@Directory, 'N/A') + CHAR(13) + CHAR(10) +
            'SQL Server Service Account: ' + @ServiceAccount + CHAR(13) + CHAR(10) +
            '================================' + CHAR(13) + CHAR(10);

        -- Add specific error guidance based on error number
        IF @ErrorNumber = 3201
        BEGIN
            SET @ErrorDetails = @ErrorDetails +
                'DIAGNOSIS: Cannot open backup device.' + CHAR(13) + CHAR(10) +
                'SOLUTION: Check that:' + CHAR(13) + CHAR(10) +
                '1. The directory exists' + CHAR(13) + CHAR(10) +
                '2. SQL Server service account (' + @ServiceAccount + ') has write permissions' + CHAR(13) + CHAR(10) +
                '3. The path is not too long (max 260 characters)' + CHAR(13) + CHAR(10) +
                '4. The disk has sufficient space';
        END
        ELSE IF @ErrorNumber = 3013
        BEGIN
            SET @ErrorDetails = @ErrorDetails +
                'DIAGNOSIS: BACKUP DATABASE is terminating abnormally.' + CHAR(13) + CHAR(10) +
                'SOLUTION: This is usually caused by permissions issues. Verify:' + CHAR(13) + CHAR(10) +
                '1. SQL Server service account has Full Control on backup directory' + CHAR(13) + CHAR(10) +
                '2. No antivirus blocking the backup file creation' + CHAR(13) + CHAR(10) +
                '3. Sufficient disk space available' + CHAR(13) + CHAR(10) +
                '4. Database is not in use by another process';
        END
        ELSE IF @ErrorNumber = 3033
        BEGIN
            SET @ErrorDetails = @ErrorDetails +
                'DIAGNOSIS: Backup set cannot be appended.' + CHAR(13) + CHAR(10) +
                'SOLUTION: The existing backup file may be corrupted or locked. Try:' + CHAR(13) + CHAR(10) +
                '1. Using a different filename' + CHAR(13) + CHAR(10) +
                '2. Deleting the existing backup file' + CHAR(13) + CHAR(10) +
                '3. Checking for file locks';
        END
        ELSE IF @ErrorNumber = 5035
        BEGIN
            SET @ErrorDetails = @ErrorDetails +
                'DIAGNOSIS: Invalid backup path or permission denied.' + CHAR(13) + CHAR(10) +
                'SOLUTION: Ensure the SQL Server service account has permissions on the target directory.';
        END
        ELSE
        BEGIN
            SET @ErrorDetails = @ErrorDetails +
                'DIAGNOSIS: Unexpected error occurred.' + CHAR(13) + CHAR(10) +
                'SOLUTION: Review the error message above and SQL Server error logs for more details.';
        END

        -- Raise error with detailed information
        RAISERROR(@ErrorDetails, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: sp_Hirebot_RestoreDatabase
-- Description: Restores Hirebot database from backup file
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_RestoreDatabase')
    DROP PROCEDURE sp_Hirebot_RestoreDatabase
GO

CREATE PROCEDURE sp_Hirebot_RestoreDatabase
    @BackupPath NVARCHAR(500),
    @DataPath NVARCHAR(260) = NULL,  -- Si es NULL, usa la ubicación por defecto
    @LogPath NVARCHAR(260) = NULL    -- Si es NULL, usa la ubicación por defecto
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DbName NVARCHAR(128) = 'Hirebot';
    DECLARE @DataFileName NVARCHAR(260);
    DECLARE @LogFileName NVARCHAR(260);
    DECLARE @RestoreSQL NVARCHAR(MAX);

    BEGIN TRY
        -- =============================================
        -- STEP 1: Validar que el archivo existe
        -- =============================================
        DECLARE @FileCheck TABLE (FileExists INT, FileIsDir INT, ParentExists INT);
        INSERT INTO @FileCheck EXEC master.dbo.xp_fileexist @BackupPath;

        IF NOT EXISTS (SELECT 1 FROM @FileCheck WHERE FileExists = 1)
            RAISERROR('El archivo de backup no existe o no es accesible para SQL Server: %s', 16, 1, @BackupPath);

        -- =============================================
        -- STEP 2: Verificar integridad del backup
        -- =============================================
        RESTORE VERIFYONLY FROM DISK = @BackupPath;

        -- =============================================
        -- STEP 3: Obtener paths por defecto
        -- =============================================
        IF @DataPath IS NULL
        BEGIN
            -- Intentar obtener de SERVERPROPERTY primero
            SET @DataPath = CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS NVARCHAR(260));

            -- Fallback: obtener de sys.master_files
            IF @DataPath IS NULL
            BEGIN
                SELECT @DataPath = SUBSTRING(physical_name, 1, CHARINDEX(N'Hirebot.mdf', LOWER(physical_name)) - 1)
                FROM sys.master_files
                WHERE database_id = DB_ID('Hirebot') AND type = 0;
            END
        END

        IF @LogPath IS NULL
        BEGIN
            SET @LogPath = CAST(SERVERPROPERTY('InstanceDefaultLogPath') AS NVARCHAR(260));
            IF @LogPath IS NULL
                SET @LogPath = @DataPath;
        END

        -- Asegurar que los paths terminan con \
        IF RIGHT(@DataPath, 1) <> '\' SET @DataPath = @DataPath + '\';
        IF RIGHT(@LogPath, 1) <> '\' SET @LogPath = @LogPath + '\';

        -- =============================================
        -- STEP 4: Obtener nombres lógicos del backup
        -- =============================================
        DECLARE @LogicalDataName NVARCHAR(128);
        DECLARE @LogicalLogName NVARCHAR(128);

        -- Tabla para FILELISTONLY compatible con SQL Server 2019+
        DECLARE @FileList TABLE (
            LogicalName NVARCHAR(128),
            PhysicalName NVARCHAR(260),
            [Type] CHAR(1),
            FileGroupName NVARCHAR(128),
            Size NUMERIC(20,0),
            MaxSize NUMERIC(20,0),
            FileId INT,
            CreateLSN NUMERIC(25,0),
            DropLSN NUMERIC(25,0),
            UniqueId UNIQUEIDENTIFIER,
            ReadOnlyLSN NUMERIC(25,0),
            ReadWriteLSN NUMERIC(25,0),
            BackupSizeInBytes BIGINT,
            SourceBlockSize INT,
            FileGroupId INT,
            LogGroupGUID UNIQUEIDENTIFIER,
            DifferentialBaseLSN NUMERIC(25,0),
            DifferentialBaseGUID UNIQUEIDENTIFIER,
            IsReadOnly BIT,
            IsPresent BIT,
            TDEThumbprint VARBINARY(32),
            SnapshotUrl NVARCHAR(360)
        );

        INSERT INTO @FileList
        EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @BackupPath + '''');

        SELECT TOP 1 @LogicalDataName = LogicalName FROM @FileList WHERE [Type] = 'D' ORDER BY FileId;
        SELECT TOP 1 @LogicalLogName = LogicalName FROM @FileList WHERE [Type] = 'L' ORDER BY FileId;

        IF @LogicalDataName IS NULL OR @LogicalLogName IS NULL
            RAISERROR('No se pudieron obtener los nombres lógicos de los archivos del backup.', 16, 1);

        -- =============================================
        -- STEP 5: Construir nombres físicos
        -- =============================================
        SET @DataFileName = @DataPath + @DbName + '.mdf';
        SET @LogFileName = @LogPath + @DbName + '_log.ldf';

        -- =============================================
        -- STEP 6: Cerrar todas las conexiones activas
        -- =============================================
        -- Matar todas las sesiones conectadas a la base de datos
        DECLARE @kill_sql NVARCHAR(MAX) = '';

        SELECT @kill_sql = @kill_sql + 'KILL ' + CAST(session_id AS NVARCHAR(10)) + '; '
        FROM sys.dm_exec_sessions
        WHERE database_id = DB_ID(@DbName)
        AND session_id <> @@SPID; -- No matar la sesión actual

        IF LEN(@kill_sql) > 0
        BEGIN
            EXEC(@kill_sql);
            -- Esperar un momento para que las sesiones terminen
            WAITFOR DELAY '00:00:01';
        END

        -- =============================================
        -- STEP 7: Poner en modo SINGLE_USER
        -- =============================================
        IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @DbName)
        BEGIN
            DECLARE @SingleUserSQL NVARCHAR(500) =
                'ALTER DATABASE [' + @DbName + '] SET SINGLE_USER WITH ROLLBACK IMMEDIATE';
            EXEC(@SingleUserSQL);

            -- Esperar a que se complete
            WAITFOR DELAY '00:00:01';
        END

        -- =============================================
        -- STEP 8: Ejecutar RESTORE
        -- =============================================
        SET @RestoreSQL = '
            RESTORE DATABASE [' + @DbName + ']
            FROM DISK = N''' + @BackupPath + '''
            WITH REPLACE, RECOVERY, STATS = 5,
                 MOVE N''' + @LogicalDataName + ''' TO N''' + @DataFileName + ''',
                 MOVE N''' + @LogicalLogName + ''' TO N''' + @LogFileName + ''';
        ';

        EXEC(@RestoreSQL);

        -- =============================================
        -- STEP 9: Volver a MULTI_USER
        -- =============================================
        DECLARE @MultiUserSQL NVARCHAR(500) =
            'ALTER DATABASE [' + @DbName + '] SET MULTI_USER';
        EXEC(@MultiUserSQL);

    END TRY
    BEGIN CATCH
        -- Intentar volver a multi-user en caso de error
        BEGIN TRY
            IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Hirebot' AND user_access = 1)
            BEGIN
                ALTER DATABASE [Hirebot] SET MULTI_USER;
            END
        END TRY
        BEGIN CATCH
            -- Ignorar errores al intentar restaurar multi-user
        END CATCH

        -- Propagar el error original
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorNum INT = ERROR_NUMBER();
        RAISERROR('Error al restaurar la base de datos (Error %d): %s', 16, 1, @ErrorNum, @ErrorMsg);
    END CATCH
END
GO

-- =============================================
-- Procedure: sp_Hirebot_ListBackups
-- Description: Lists available backup files in specified directory
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_ListBackups')
    DROP PROCEDURE sp_Hirebot_ListBackups
GO

CREATE PROCEDURE sp_Hirebot_ListBackups
    @BackupDirectory NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Create temporary table to hold directory listing
        CREATE TABLE #BackupFiles (
            FileName NVARCHAR(500),
            Depth INT,
            IsFile BIT
        );

        -- Get list of files in backup directory
        DECLARE @Command NVARCHAR(4000);
        SET @Command = 'DIR "' + @BackupDirectory + '\*.bak" /B';

        INSERT INTO #BackupFiles (FileName, Depth, IsFile)
        EXEC xp_dirtree @BackupDirectory, 1, 1;

        -- Return only .bak files
        SELECT
            FileName,
            @BackupDirectory + '\' + FileName AS FullPath
        FROM #BackupFiles
        WHERE IsFile = 1 AND FileName LIKE '%.bak'
        ORDER BY FileName DESC;

        DROP TABLE #BackupFiles;
    END TRY
    BEGIN CATCH
        IF OBJECT_ID('tempdb..#BackupFiles') IS NOT NULL
            DROP TABLE #BackupFiles;

        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO

-- =============================================
-- Procedure: sp_Hirebot_GetBackupInfo
-- Description: Gets information about a backup file
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_Hirebot_GetBackupInfo')
    DROP PROCEDURE sp_Hirebot_GetBackupInfo
GO

CREATE PROCEDURE sp_Hirebot_GetBackupInfo
    @BackupPath NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Get backup header information
        RESTORE HEADERONLY
        FROM DISK = @BackupPath;
    END TRY
    BEGIN CATCH
        SELECT 'ERROR' AS Result, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

PRINT 'Admin Database stored procedures created successfully in [master] database';
