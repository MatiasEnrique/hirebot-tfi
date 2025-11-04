-- =============================================
-- Add DatabaseBackup Permission
-- This script adds the permission for database backup/restore operations
-- =============================================

USE [Hirebot]
GO


-- Check if the permission already exists
IF NOT EXISTS (SELECT 1 FROM AdminPermissions WHERE PermissionKey = 'DatabaseBackup')
BEGIN
    -- Insert the new permission
    INSERT INTO AdminPermissions (PermissionKey, DisplayName, Category, SortOrder, IsActive)
    VALUES (
        'DatabaseBackup',
        'Gestión de Base de Datos',
        100,
        1,
        1
    );

    PRINT 'Permiso DatabaseBackup agregado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El permiso DatabaseBackup ya existe.';
END
GO
