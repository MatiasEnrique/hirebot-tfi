-- =============================================
-- Script: Add AdminUsers Permission
-- Description: Adds the AdminUsers page permission to the AdminPermissions table
--              and assigns it to the System Administrator role
-- Author: Factory AI
-- Created: 2025-11-04
-- =============================================

USE Hirebot;
GO

-- Add AdminUsers permission if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM AdminPermissions WHERE PermissionKey = '~/AdminUsers.aspx')
BEGIN
    INSERT INTO AdminPermissions (PermissionKey, DisplayName, Category, SortOrder, IsActive, CreatedDateUtc)
    VALUES (
        '~/AdminUsers.aspx',
        'User Management',
        'Admin',
        88, -- Between AdminDatabase (87) and AdminReports (80)
        1,
        SYSUTCDATETIME()
    );
    
    PRINT 'AdminUsers permission added successfully.';
END
ELSE
BEGIN
    PRINT 'AdminUsers permission already exists.';
END
GO

-- Assign AdminUsers permission to System Administrator role (RoleId = 1)
IF NOT EXISTS (
    SELECT 1 
    FROM AdminRolePermissions 
    WHERE RoleId = 1 
    AND PermissionKey = '~/AdminUsers.aspx'
)
BEGIN
    INSERT INTO AdminRolePermissions (RoleId, PermissionKey, AssignedDateUtc, AssignedByUserId)
    VALUES (
        1, -- System Administrator role
        '~/AdminUsers.aspx',
        SYSUTCDATETIME(),
        5 -- Default admin user (adjust if needed)
    );
    
    PRINT 'AdminUsers permission assigned to System Administrator role.';
END
ELSE
BEGIN
    PRINT 'AdminUsers permission already assigned to System Administrator role.';
END
GO

-- Verify the permission was added
SELECT 
    ap.PermissionKey,
    ap.DisplayName,
    ap.Category,
    ap.SortOrder,
    ap.IsActive
FROM AdminPermissions ap
WHERE ap.PermissionKey = '~/AdminUsers.aspx';

-- Verify role assignment
SELECT 
    r.RoleId,
    r.RoleName,
    rp.PermissionKey,
    ap.DisplayName
FROM AdminRoles r
INNER JOIN AdminRolePermissions rp ON r.RoleId = rp.RoleId
INNER JOIN AdminPermissions ap ON rp.PermissionKey = ap.PermissionKey
WHERE rp.PermissionKey = '~/AdminUsers.aspx';

PRINT 'AdminUsers permission setup completed.';
GO
