-- =============================================
-- Hirebot-TFI Database Creation Script
-- Author: Claude Code
-- Description: Creates the Hirebot database and core tables
-- =============================================

-- Create Database
IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'Hirebot')
BEGIN
    CREATE DATABASE [Hirebot]
    PRINT 'Database Hirebot created successfully'
END
ELSE
BEGIN
    PRINT 'Database Hirebot already exists'
END
GO

USE [Hirebot]
GO

-- =============================================
-- Table: Users
-- Description: Core user table for authentication system
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Users] (
        UserId INT IDENTITY(1,1) NOT NULL,
        Username NVARCHAR(50) NOT NULL,
        Email NVARCHAR(255) NOT NULL,
        PasswordHash NVARCHAR(255) NOT NULL,
        FirstName NVARCHAR(100) NOT NULL,
        LastName NVARCHAR(100) NOT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
        LastLoginDate DATETIME NULL,
        
        CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (UserId ASC),
        CONSTRAINT UX_Users_Username UNIQUE (Username),
        CONSTRAINT UX_Users_Email UNIQUE (Email)
    )
    
    -- Create indexes for performance
    CREATE NONCLUSTERED INDEX IX_Users_Username ON [dbo].[Users] (Username)
    CREATE NONCLUSTERED INDEX IX_Users_Email ON [dbo].[Users] (Email)
    CREATE NONCLUSTERED INDEX IX_Users_Active ON [dbo].[Users] (IsActive)
    
    PRINT 'Users table created successfully with indexes'
END
ELSE
BEGIN
    PRINT 'Users table already exists'
END
GO

-- =============================================
-- Table: SystemLogs
-- Description: System logging table for audit and debugging
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SystemLogs]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[SystemLogs] (
        LogId INT IDENTITY(1,1) NOT NULL,
        UserId INT NULL,
        LogType NVARCHAR(50) NOT NULL, -- Login, Logout, Register, Error, Access, System, etc.
        Description NVARCHAR(MAX) NOT NULL,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        IPAddress NVARCHAR(45) NULL,
        UserAgent NVARCHAR(500) NULL,
        
        CONSTRAINT PK_SystemLogs PRIMARY KEY CLUSTERED (LogId ASC),
        CONSTRAINT FK_SystemLogs_Users FOREIGN KEY(UserId) REFERENCES [dbo].[Users] (UserId)
    )
    
    -- Create indexes for performance
    CREATE NONCLUSTERED INDEX IX_SystemLogs_UserId ON [dbo].[SystemLogs] (UserId)
    CREATE NONCLUSTERED INDEX IX_SystemLogs_LogType ON [dbo].[SystemLogs] (LogType)
    CREATE NONCLUSTERED INDEX IX_SystemLogs_Date ON [dbo].[SystemLogs] (CreatedDate DESC)
    
    PRINT 'SystemLogs table created successfully with indexes'
END
ELSE
BEGIN
    PRINT 'SystemLogs table already exists'
END
GO

PRINT 'Database setup completed successfully'