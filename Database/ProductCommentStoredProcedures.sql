
-- Create ProductComments table with proper constraints and indexes
CREATE TABLE [dbo].[ProductComments] (
    [CommentId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ProductId] INT NOT NULL,
    [UserId] INT NOT NULL,
    [CommentText] NVARCHAR(2000) NOT NULL,
    [Rating] TINYINT NULL CHECK ([Rating] >= 1 AND [Rating] <= 5),
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME NULL,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [IsApproved] BIT NOT NULL DEFAULT 0,
    CONSTRAINT [FK_ProductComments_Products] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Products]([ProductId]),
    CONSTRAINT [FK_ProductComments_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users]([UserId])
);


CREATE NONCLUSTERED INDEX [IX_ProductComments_ProductId] ON [dbo].[ProductComments] ([ProductId]) INCLUDE ([IsActive], [IsApproved]);
CREATE NONCLUSTERED INDEX [IX_ProductComments_UserId] ON [dbo].[ProductComments] ([UserId]) INCLUDE ([IsActive]);
CREATE NONCLUSTERED INDEX [IX_ProductComments_CreatedDate] ON [dbo].[ProductComments] ([CreatedDate] DESC);
CREATE NONCLUSTERED INDEX [IX_ProductComments_Rating] ON [dbo].[ProductComments] ([ProductId], [Rating]) WHERE [IsActive] = 1 AND [IsApproved] = 1;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ProductComment_Insert]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ProductComment_Insert]
GO

CREATE PROCEDURE [dbo].[sp_ProductComment_Insert]
    @ProductId INT,
    @UserId INT,
    @CommentText NVARCHAR(2000),
    @Rating TINYINT = NULL,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT,
    @NewCommentId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Initialize output parameters
    SET @ResultCode = 0
    SET @ResultMessage = 'Success'
    SET @NewCommentId = 0
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Input validation
        IF @ProductId IS NULL OR @ProductId <= 0
        BEGIN
            SET @ResultCode = -1
            SET @ResultMessage = 'Invalid product ID'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            SET @ResultCode = -2
            SET @ResultMessage = 'Invalid user ID'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        IF @CommentText IS NULL OR LTRIM(RTRIM(@CommentText)) = ''
        BEGIN
            SET @ResultCode = -3
            SET @ResultMessage = 'Comment text cannot be null or empty'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Validate comment length
        IF LEN(LTRIM(RTRIM(@CommentText))) < 10
        BEGIN
            SET @ResultCode = -4
            SET @ResultMessage = 'Comment text must be at least 10 characters long'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        IF LEN(@CommentText) > 2000
        BEGIN
            SET @ResultCode = -5
            SET @ResultMessage = 'Comment text cannot exceed 2000 characters'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Validate rating if provided
        IF @Rating IS NOT NULL AND (@Rating < 1 OR @Rating > 5)
        BEGIN
            SET @ResultCode = -6
            SET @ResultMessage = 'Rating must be between 1 and 5'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Check if product exists and is active
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Products] WHERE ProductId = @ProductId AND IsActive = 1)
        BEGIN
            SET @ResultCode = -7
            SET @ResultMessage = 'Product not found or inactive'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Check if user exists and is active
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserId = @UserId AND IsActive = 1)
        BEGIN
            SET @ResultCode = -8
            SET @ResultMessage = 'User not found or inactive'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Check for duplicate comment (same user, same product, within last 24 hours)
        IF EXISTS (
            SELECT 1 FROM [dbo].[ProductComments] 
            WHERE ProductId = @ProductId 
              AND UserId = @UserId 
              AND CreatedDate >= DATEADD(HOUR, -24, GETDATE())
              AND IsActive = 1
        )
        BEGIN
            SET @ResultCode = -9
            SET @ResultMessage = 'You can only comment once per product every 24 hours'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Insert new comment
        INSERT INTO [dbo].[ProductComments] 
        (ProductId, UserId, CommentText, Rating, CreatedDate, IsActive, IsApproved)
        VALUES 
        (@ProductId, @UserId, LTRIM(RTRIM(@CommentText)), @Rating, GETDATE(), 1, 0)
        
        -- Get the new comment ID
        SET @NewCommentId = SCOPE_IDENTITY()
        
        COMMIT TRANSACTION
        
        -- Success
        SET @ResultCode = 1
        SET @ResultMessage = 'Comment added successfully and is pending approval'
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        SET @ResultCode = -999
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE()
        SET @NewCommentId = 0
    END CATCH
END
GO

-- =============================================
-- Stored Procedure: sp_ProductComment_GetByProductId (Production Ready)
-- Description: Retrieves all approved comments for a specific product
-- Author: Claude Code Assistant
-- Create date: 2025-09-06
-- Parameters: @ProductId - Product ID to get comments for
--            @IncludePending - Include pending/unapproved comments (admin feature)
--            @PageNumber - Page number for pagination
--            @PageSize - Number of comments per page
-- Returns: Comment data with user information
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ProductComment_GetByProductId]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ProductComment_GetByProductId]
GO

CREATE PROCEDURE [dbo].[sp_ProductComment_GetByProductId]
    @ProductId INT,
    @IncludePending BIT = 0,
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Input validation
    IF @ProductId IS NULL OR @ProductId <= 0
    BEGIN
        RAISERROR('Invalid product ID', 16, 1)
        RETURN
    END
    
    IF @PageNumber IS NULL OR @PageNumber < 1
        SET @PageNumber = 1
        
    IF @PageSize IS NULL OR @PageSize < 1 OR @PageSize > 100
        SET @PageSize = 10
    
    -- Check if product exists
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Products] WHERE ProductId = @ProductId)
    BEGIN
        RAISERROR('Product not found', 16, 1)
        RETURN
    END
    
    -- Calculate offset
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize
    
    -- Return paginated comments with user information
    SELECT 
        c.CommentId,
        c.ProductId,
        c.UserId,
        c.CommentText,
        c.Rating,
        c.CreatedDate,
        c.ModifiedDate,
        c.IsActive,
        c.IsApproved,
        u.Username,
        u.FirstName + ' ' + u.LastName AS UserFullName,
        p.Name AS ProductName,
        -- Summary info
        COUNT(*) OVER() AS TotalComments,
        CEILING(CAST(COUNT(*) OVER() AS FLOAT) / @PageSize) AS TotalPages
    FROM [dbo].[ProductComments] c
    INNER JOIN [dbo].[Users] u ON c.UserId = u.UserId
    INNER JOIN [dbo].[Products] p ON c.ProductId = p.ProductId
    WHERE c.ProductId = @ProductId
      AND c.IsActive = 1
      AND (@IncludePending = 1 OR c.IsApproved = 1)
    ORDER BY c.CreatedDate DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY
END
GO

-- =============================================
-- Stored Procedure: sp_ProductComment_GetById (Production Ready)
-- Description: Retrieves a specific comment by ID with full details
-- Author: Claude Code Assistant
-- Create date: 2025-09-06
-- Parameters: @CommentId - Comment ID to retrieve
-- Returns: Comment details with user and product information
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ProductComment_GetById]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ProductComment_GetById]
GO

CREATE PROCEDURE [dbo].[sp_ProductComment_GetById]
    @CommentId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Input validation
    IF @CommentId IS NULL OR @CommentId <= 0
    BEGIN
        RAISERROR('Invalid comment ID', 16, 1)
        RETURN
    END
    
    -- Return comment details
    SELECT 
        c.CommentId,
        c.ProductId,
        c.UserId,
        c.CommentText,
        c.Rating,
        c.CreatedDate,
        c.ModifiedDate,
        c.IsActive,
        c.IsApproved,
        u.Username,
        u.FirstName + ' ' + u.LastName AS UserFullName,
        u.Email AS UserEmail,
        p.Name AS ProductName,
        p.Description AS ProductDescription
    FROM [dbo].[ProductComments] c
    INNER JOIN [dbo].[Users] u ON c.UserId = u.UserId
    INNER JOIN [dbo].[Products] p ON c.ProductId = p.ProductId
    WHERE c.CommentId = @CommentId AND c.IsActive = 1
END
GO

-- =============================================
-- Stored Procedure: sp_ProductComment_Update (Production Ready)
-- Description: Updates an existing comment with validation
-- Author: Claude Code Assistant
-- Create date: 2025-09-06
-- Parameters: @CommentId - Comment to update
--            @UserId - User making the update (must be comment owner or admin)
--            @CommentText - New comment text
--            @Rating - New rating (optional)
--            @ResultCode - Output result code
--            @ResultMessage - Output result message
-- Returns: Success/error status
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ProductComment_Update]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ProductComment_Update]
GO

CREATE PROCEDURE [dbo].[sp_ProductComment_Update]
    @CommentId INT,
    @UserId INT,
    @CommentText NVARCHAR(2000),
    @Rating TINYINT = NULL,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Initialize output parameters
    SET @ResultCode = 0
    SET @ResultMessage = 'Success'
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Input validation
        IF @CommentId IS NULL OR @CommentId <= 0
        BEGIN
            SET @ResultCode = -1
            SET @ResultMessage = 'Invalid comment ID'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            SET @ResultCode = -2
            SET @ResultMessage = 'Invalid user ID'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        IF @CommentText IS NULL OR LTRIM(RTRIM(@CommentText)) = ''
        BEGIN
            SET @ResultCode = -3
            SET @ResultMessage = 'Comment text cannot be null or empty'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Validate comment length
        IF LEN(LTRIM(RTRIM(@CommentText))) < 10
        BEGIN
            SET @ResultCode = -4
            SET @ResultMessage = 'Comment text must be at least 10 characters long'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        IF LEN(@CommentText) > 2000
        BEGIN
            SET @ResultCode = -5
            SET @ResultMessage = 'Comment text cannot exceed 2000 characters'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Validate rating if provided
        IF @Rating IS NOT NULL AND (@Rating < 1 OR @Rating > 5)
        BEGIN
            SET @ResultCode = -6
            SET @ResultMessage = 'Rating must be between 1 and 5'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Check if comment exists and is active
        DECLARE @CommentUserId INT, @IsAdmin BIT = 0
        SELECT @CommentUserId = UserId FROM [dbo].[ProductComments] 
        WHERE CommentId = @CommentId AND IsActive = 1
        
        IF @CommentUserId IS NULL
        BEGIN
            SET @ResultCode = -7
            SET @ResultMessage = 'Comment not found or inactive'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Check if requesting user is admin
        IF EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserId = @UserId AND UserRole = 'admin' AND IsActive = 1)
            SET @IsAdmin = 1
        
        -- Check authorization (must be comment owner or admin)
        IF @CommentUserId != @UserId AND @IsAdmin = 0
        BEGIN
            SET @ResultCode = -8
            SET @ResultMessage = 'Unauthorized: You can only update your own comments'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Check edit time limit (users can only edit within 24 hours, admins anytime)
        IF @IsAdmin = 0 AND EXISTS (
            SELECT 1 FROM [dbo].[ProductComments] 
            WHERE CommentId = @CommentId 
              AND CreatedDate < DATEADD(HOUR, -24, GETDATE())
        )
        BEGIN
            SET @ResultCode = -9
            SET @ResultMessage = 'Comments can only be edited within 24 hours of creation'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Update comment (if edited by user, reset approval status)
        UPDATE [dbo].[ProductComments]
        SET CommentText = LTRIM(RTRIM(@CommentText)),
            Rating = @Rating,
            ModifiedDate = GETDATE(),
            IsApproved = CASE WHEN @IsAdmin = 1 THEN IsApproved ELSE 0 END
        WHERE CommentId = @CommentId
        
        -- Check if update was successful
        IF @@ROWCOUNT = 0
        BEGIN
            SET @ResultCode = -10
            SET @ResultMessage = 'Failed to update comment'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        COMMIT TRANSACTION
        
        SET @ResultCode = 1
        SET @ResultMessage = CASE WHEN @IsAdmin = 1 
                                  THEN 'Comment updated successfully'
                                  ELSE 'Comment updated successfully and is pending re-approval'
                             END
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        SET @ResultCode = -999
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE()
    END CATCH
END
GO

-- =============================================
-- Stored Procedure: sp_ProductComment_Delete (Production Ready)
-- Description: Soft deletes a comment with authorization checks
-- Author: Claude Code Assistant
-- Create date: 2025-09-06
-- Parameters: @CommentId - Comment to delete
--            @UserId - User requesting deletion
--            @ResultCode - Output result code
--            @ResultMessage - Output result message
-- Returns: Success/error status
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ProductComment_Delete]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ProductComment_Delete]
GO

CREATE PROCEDURE [dbo].[sp_ProductComment_Delete]
    @CommentId INT,
    @UserId INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Initialize output parameters
    SET @ResultCode = 0
    SET @ResultMessage = 'Success'
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Input validation
        IF @CommentId IS NULL OR @CommentId <= 0
        BEGIN
            SET @ResultCode = -1
            SET @ResultMessage = 'Invalid comment ID'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        IF @UserId IS NULL OR @UserId <= 0
        BEGIN
            SET @ResultCode = -2
            SET @ResultMessage = 'Invalid user ID'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Check if comment exists and is active
        DECLARE @CommentUserId INT, @IsAdmin BIT = 0
        SELECT @CommentUserId = UserId FROM [dbo].[ProductComments] 
        WHERE CommentId = @CommentId AND IsActive = 1
        
        IF @CommentUserId IS NULL
        BEGIN
            SET @ResultCode = -3
            SET @ResultMessage = 'Comment not found or already deleted'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Check if requesting user is admin
        IF EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserId = @UserId AND UserRole = 'admin' AND IsActive = 1)
            SET @IsAdmin = 1
        
        -- Check authorization (must be comment owner or admin)
        IF @CommentUserId != @UserId AND @IsAdmin = 0
        BEGIN
            SET @ResultCode = -4
            SET @ResultMessage = 'Unauthorized: You can only delete your own comments'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Soft delete comment
        UPDATE [dbo].[ProductComments]
        SET IsActive = 0,
            ModifiedDate = GETDATE()
        WHERE CommentId = @CommentId AND IsActive = 1
        
        -- Check if update was successful
        IF @@ROWCOUNT = 0
        BEGIN
            SET @ResultCode = -5
            SET @ResultMessage = 'Failed to delete comment'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        COMMIT TRANSACTION
        
        SET @ResultCode = 1
        SET @ResultMessage = 'Comment deleted successfully'
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        SET @ResultCode = -999
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE()
    END CATCH
END
GO

-- =============================================
-- Stored Procedure: sp_ProductComment_Approve (Production Ready)
-- Description: Approves or rejects a comment (admin only)
-- Author: Claude Code Assistant
-- Create date: 2025-09-06
-- Parameters: @CommentId - Comment to approve/reject
--            @AdminUserId - Admin user performing the action
--            @IsApproved - 1 to approve, 0 to reject
--            @ResultCode - Output result code
--            @ResultMessage - Output result message
-- Returns: Success/error status
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ProductComment_Approve]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ProductComment_Approve]
GO

CREATE PROCEDURE [dbo].[sp_ProductComment_Approve]
    @CommentId INT,
    @AdminUserId INT,
    @IsApproved BIT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Initialize output parameters
    SET @ResultCode = 0
    SET @ResultMessage = 'Success'
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Input validation
        IF @CommentId IS NULL OR @CommentId <= 0
        BEGIN
            SET @ResultCode = -1
            SET @ResultMessage = 'Invalid comment ID'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        IF @AdminUserId IS NULL OR @AdminUserId <= 0
        BEGIN
            SET @ResultCode = -2
            SET @ResultMessage = 'Invalid admin user ID'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        IF @IsApproved IS NULL
        BEGIN
            SET @ResultCode = -3
            SET @ResultMessage = 'Approval status must be specified'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Check if requesting user is admin
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserId = @AdminUserId AND UserRole = 'admin' AND IsActive = 1)
        BEGIN
            SET @ResultCode = -4
            SET @ResultMessage = 'Unauthorized: Only admins can approve/reject comments'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Check if comment exists and is active
        IF NOT EXISTS (SELECT 1 FROM [dbo].[ProductComments] WHERE CommentId = @CommentId AND IsActive = 1)
        BEGIN
            SET @ResultCode = -5
            SET @ResultMessage = 'Comment not found or inactive'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Update approval status
        UPDATE [dbo].[ProductComments]
        SET IsApproved = @IsApproved,
            ModifiedDate = GETDATE()
        WHERE CommentId = @CommentId AND IsActive = 1
        
        -- Check if update was successful
        IF @@ROWCOUNT = 0
        BEGIN
            SET @ResultCode = -6
            SET @ResultMessage = 'Failed to update comment approval status'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        COMMIT TRANSACTION
        
        SET @ResultCode = 1
        SET @ResultMessage = CASE WHEN @IsApproved = 1 
                                  THEN 'Comment approved successfully'
                                  ELSE 'Comment rejected successfully'
                             END
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        SET @ResultCode = -999
        SET @ResultMessage = 'Database error: ' + ERROR_MESSAGE()
    END CATCH
END
GO

-- =============================================
-- Stored Procedure: sp_ProductComment_GetPendingApproval (Production Ready)
-- Description: Gets all comments pending approval for moderation (admin only)
-- Author: Claude Code Assistant
-- Create date: 2025-09-06
-- Parameters: @AdminUserId - Admin user requesting the list
--            @PageNumber - Page number for pagination
--            @PageSize - Number of comments per page
-- Returns: Pending comments with user and product information
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ProductComment_GetPendingApproval]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ProductComment_GetPendingApproval]
GO

CREATE PROCEDURE [dbo].[sp_ProductComment_GetPendingApproval]
    @AdminUserId INT,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Input validation
    IF @AdminUserId IS NULL OR @AdminUserId <= 0
    BEGIN
        RAISERROR('Invalid admin user ID', 16, 1)
        RETURN
    END
    
    -- Check if requesting user is admin
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserId = @AdminUserId AND UserRole = 'admin' AND IsActive = 1)
    BEGIN
        RAISERROR('Unauthorized: Only admins can view pending comments', 16, 1)
        RETURN
    END
    
    IF @PageNumber IS NULL OR @PageNumber < 1
        SET @PageNumber = 1
        
    IF @PageSize IS NULL OR @PageSize < 1 OR @PageSize > 100
        SET @PageSize = 20
    
    -- Calculate offset
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize
    
    -- Return paginated pending comments
    SELECT 
        c.CommentId,
        c.ProductId,
        c.UserId,
        c.CommentText,
        c.Rating,
        c.CreatedDate,
        c.ModifiedDate,
        u.Username,
        u.FirstName + ' ' + u.LastName AS UserFullName,
        u.Email AS UserEmail,
        p.Name AS ProductName,
        p.Description AS ProductDescription,
        -- Summary info
        COUNT(*) OVER() AS TotalPendingComments,
        CEILING(CAST(COUNT(*) OVER() AS FLOAT) / @PageSize) AS TotalPages
    FROM [dbo].[ProductComments] c
    INNER JOIN [dbo].[Users] u ON c.UserId = u.UserId
    INNER JOIN [dbo].[Products] p ON c.ProductId = p.ProductId
    WHERE c.IsActive = 1 AND c.IsApproved = 0
    ORDER BY c.CreatedDate ASC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY
END
GO

-- =============================================
-- Stored Procedure: sp_ProductComment_GetStatistics (Production Ready)
-- Description: Gets comment statistics for a product or overall
-- Author: Claude Code Assistant
-- Create date: 2025-09-06
-- Parameters: @ProductId - Product ID (NULL for overall statistics)
-- Returns: Comment statistics including counts, ratings, etc.
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ProductComment_GetStatistics]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ProductComment_GetStatistics]
GO

CREATE PROCEDURE [dbo].[sp_ProductComment_GetStatistics]
    @ProductId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- If ProductId is provided, validate it
    IF @ProductId IS NOT NULL AND @ProductId > 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Products] WHERE ProductId = @ProductId)
        BEGIN
            RAISERROR('Product not found', 16, 1)
            RETURN
        END
    END
    
    -- Return statistics
    SELECT 
        @ProductId AS ProductId,
        COUNT(*) AS TotalComments,
        COUNT(CASE WHEN IsApproved = 1 THEN 1 END) AS ApprovedComments,
        COUNT(CASE WHEN IsApproved = 0 THEN 1 END) AS PendingComments,
        COUNT(CASE WHEN Rating IS NOT NULL THEN 1 END) AS CommentsWithRating,
        ROUND(AVG(CAST(Rating AS FLOAT)), 2) AS AverageRating,
        COUNT(CASE WHEN Rating = 1 THEN 1 END) AS OneStarCount,
        COUNT(CASE WHEN Rating = 2 THEN 1 END) AS TwoStarCount,
        COUNT(CASE WHEN Rating = 3 THEN 1 END) AS ThreeStarCount,
        COUNT(CASE WHEN Rating = 4 THEN 1 END) AS FourStarCount,
        COUNT(CASE WHEN Rating = 5 THEN 1 END) AS FiveStarCount,
        MIN(CreatedDate) AS FirstCommentDate,
        MAX(CreatedDate) AS LastCommentDate
    FROM [dbo].[ProductComments]
    WHERE IsActive = 1
      AND (@ProductId IS NULL OR ProductId = @ProductId)
END
GO

-- =============================================
-- Stored Procedure: sp_ProductComment_GetUserComments (Production Ready)
-- Description: Gets all comments by a specific user
-- Author: Claude Code Assistant
-- Create date: 2025-09-06
-- Parameters: @UserId - User ID to get comments for
--            @PageNumber - Page number for pagination
--            @PageSize - Number of comments per page
-- Returns: User's comments with product information
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ProductComment_GetUserComments]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ProductComment_GetUserComments]
GO

CREATE PROCEDURE [dbo].[sp_ProductComment_GetUserComments]
    @UserId INT,
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Input validation
    IF @UserId IS NULL OR @UserId <= 0
    BEGIN
        RAISERROR('Invalid user ID', 16, 1)
        RETURN
    END
    
    -- Check if user exists
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserId = @UserId AND IsActive = 1)
    BEGIN
        RAISERROR('User not found or inactive', 16, 1)
        RETURN
    END
    
    IF @PageNumber IS NULL OR @PageNumber < 1
        SET @PageNumber = 1
        
    IF @PageSize IS NULL OR @PageSize < 1 OR @PageSize > 100
        SET @PageSize = 10
    
    -- Calculate offset
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize
    
    -- Return paginated user comments
    SELECT 
        c.CommentId,
        c.ProductId,
        c.UserId,
        c.CommentText,
        c.Rating,
        c.CreatedDate,
        c.ModifiedDate,
        c.IsActive,
        c.IsApproved,
        p.Name AS ProductName,
        p.Description AS ProductDescription,
        p.Category AS ProductCategory,
        -- Summary info
        COUNT(*) OVER() AS TotalUserComments,
        CEILING(CAST(COUNT(*) OVER() AS FLOAT) / @PageSize) AS TotalPages
    FROM [dbo].[ProductComments] c
    INNER JOIN [dbo].[Products] p ON c.ProductId = p.ProductId
    WHERE c.UserId = @UserId AND c.IsActive = 1
    ORDER BY c.CreatedDate DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY
END
GO

-- =============================================
-- Verification Query: Check if all procedures were created successfully
-- =============================================
SELECT 
    name AS ProcedureName,
    create_date AS DateCreated,
    modify_date AS DateModified
FROM sys.procedures 
WHERE name LIKE 'sp_ProductComment_%'
ORDER BY name

PRINT 'Production-ready Product Comment stored procedures created successfully!'
PRINT 'Procedures created:'
PRINT '- sp_ProductComment_Insert: Add new comments with comprehensive validation'
PRINT '- sp_ProductComment_GetByProductId: Get comments for a product with pagination'
PRINT '- sp_ProductComment_GetById: Get specific comment details'
PRINT '- sp_ProductComment_Update: Update comments with authorization checks'
PRINT '- sp_ProductComment_Delete: Soft delete comments with authorization'
PRINT '- sp_ProductComment_Approve: Admin approval/rejection of comments'
PRINT '- sp_ProductComment_GetPendingApproval: Get comments pending moderation'
PRINT '- sp_ProductComment_GetStatistics: Get comment statistics and ratings'
PRINT '- sp_ProductComment_GetUserComments: Get all comments by a user'
PRINT ''
PRINT 'Features include:'
PRINT '- Complete CRUD operations with authorization'
PRINT '- Comment moderation system with approval workflow'
PRINT '- 1-5 star rating system'
PRINT '- Pagination support for better performance'
PRINT '- 24-hour edit window for users'
PRINT '- Duplicate comment prevention'
PRINT '- Comprehensive input validation and sanitization'
PRINT '- SQL injection protection'
PRINT '- Transaction management with rollback on errors'
PRINT '- Detailed error codes and messages'
PRINT '- Performance optimized with proper indexing suggestions'
PRINT '- Admin-only moderation functions'
PRINT '- Soft delete for data integrity'
PRINT '- Statistical analysis capabilities'