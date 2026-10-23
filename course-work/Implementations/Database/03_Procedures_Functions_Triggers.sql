USE InstagramDB;
GO

/* ============================================================
   03 - Stored procedures, functions and triggers
   Run after 01_Create_InstagramDB.sql and 02_Seed_InstagramDB.sql
   SQL Server / T-SQL
   ============================================================ */

/* 1. Activity log used by the two triggers */
IF OBJECT_ID(N'dbo.ActivityLog', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ActivityLog
    (
        ActivityLogID BIGINT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_ActivityLog PRIMARY KEY,
        UserID INT NULL,
        ActivityType NVARCHAR(30) NOT NULL,
        PostID INT NULL,
        CommentID INT NULL,
        ActivityAt DATETIME2(0) NOT NULL
            CONSTRAINT DF_ActivityLog_ActivityAt DEFAULT (SYSUTCDATETIME()),
        Details NVARCHAR(500) NULL,
        CONSTRAINT FK_ActivityLog_Users
            FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_ActivityLog_Posts
            FOREIGN KEY (PostID) REFERENCES dbo.Posts(PostID),
        CONSTRAINT FK_ActivityLog_Comments
            FOREIGN KEY (CommentID) REFERENCES dbo.Comments(CommentID)
    );
END;
GO

/* 2. Function: number of accepted followers for a user */
CREATE OR ALTER FUNCTION dbo.fn_GetFollowerCount
(
    @UserID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @FollowerCount INT;

    SELECT @FollowerCount = COUNT(*)
    FROM dbo.Follows
    WHERE FollowedID = @UserID
      AND Status = N'Accepted';

    RETURN COALESCE(@FollowerCount, 0);
END;
GO

/* 3. Function: number of likes for a post */
CREATE OR ALTER FUNCTION dbo.fn_GetPostLikeCount
(
    @PostID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @LikeCount INT;

    SELECT @LikeCount = COUNT(*)
    FROM dbo.Likes
    WHERE PostID = @PostID;

    RETURN COALESCE(@LikeCount, 0);
END;
GO

/* 4. Procedure: create a post */
CREATE OR ALTER PROCEDURE dbo.sp_CreatePost
    @UserID INT,
    @Caption NVARCHAR(2200) = NULL,
    @MediaURL NVARCHAR(500),
    @MediaType NVARCHAR(20),
    @Location NVARCHAR(150) = NULL,
    @IsArchived BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE UserID = @UserID AND IsActive = 1)
    BEGIN
        THROW 50001, 'User does not exist or is inactive.', 1;
    END;

    IF @MediaType NOT IN (N'Image', N'Video', N'Carousel')
    BEGIN
        THROW 50002, 'MediaType must be Image, Video, or Carousel.', 1;
    END;

    INSERT INTO dbo.Posts (UserID, Caption, MediaURL, MediaType, Location, IsArchived)
    VALUES (@UserID, @Caption, @MediaURL, @MediaType, @Location, @IsArchived);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS CreatedPostID;
END;
GO

/* 5. Procedure: get profile and basic statistics */
CREATE OR ALTER PROCEDURE dbo.sp_GetUserProfile
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE UserID = @UserID)
    BEGIN
        THROW 50003, 'User not found.', 1;
    END;

    SELECT
        u.UserID,
        u.Username,
        u.FullName,
        u.Bio,
        u.ProfilePictureURL,
        u.CreatedAt,
        u.IsPrivate,
        u.IsActive,
        dbo.fn_GetFollowerCount(u.UserID) AS FollowerCount,
        (
            SELECT COUNT(*)
            FROM dbo.Follows f
            WHERE f.FollowerID = u.UserID
              AND f.Status = N'Accepted'
        ) AS FollowingCount,
        (
            SELECT COUNT(*)
            FROM dbo.Posts p
            WHERE p.UserID = u.UserID
              AND p.IsArchived = 0
        ) AS ActivePostCount
    FROM dbo.Users u
    WHERE u.UserID = @UserID;
END;
GO

/* 6. Trigger: log each newly inserted like */
CREATE OR ALTER TRIGGER dbo.trg_Likes_LogInsert
ON dbo.Likes
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ActivityLog (UserID, ActivityType, PostID, ActivityAt, Details)
    SELECT
        i.UserID,
        N'Like',
        i.PostID,
        i.LikedAt,
        CONCAT(N'User ', i.UserID, N' liked post ', i.PostID)
    FROM inserted AS i;
END;
GO

/* 7. Trigger: log each newly inserted comment */
CREATE OR ALTER TRIGGER dbo.trg_Comments_LogInsert
ON dbo.Comments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ActivityLog
        (UserID, ActivityType, PostID, CommentID, ActivityAt, Details)
    SELECT
        i.UserID,
        N'Comment',
        i.PostID,
        i.CommentID,
        i.CreatedAt,
        CONCAT(N'User ', i.UserID, N' commented on post ', i.PostID)
    FROM inserted AS i;
END;
GO

/* 8. Quick verification: objects created */
SELECT N'Procedure' AS ObjectType, name AS ObjectName
FROM sys.procedures
WHERE name IN (N'sp_CreatePost', N'sp_GetUserProfile')
UNION ALL
SELECT N'Function', name
FROM sys.objects
WHERE type IN (N'FN', N'IF', N'TF')
  AND name IN (N'fn_GetFollowerCount', N'fn_GetPostLikeCount')
UNION ALL
SELECT N'Trigger', name
FROM sys.triggers
WHERE name IN (N'trg_Likes_LogInsert', N'trg_Comments_LogInsert')
UNION ALL
SELECT N'Table', name
FROM sys.tables
WHERE name = N'ActivityLog'
ORDER BY ObjectType, ObjectName;
GO

/* 9. Optional tests
   Uncomment and run separately if you want to test write operations.
   The INSERT tests below create an additional post and activity rows.

-- EXEC dbo.sp_GetUserProfile @UserID = 1;
-- SELECT dbo.fn_GetFollowerCount(1) AS FollowerCount;
-- SELECT dbo.fn_GetPostLikeCount(1) AS LikeCountForPost1;

-- EXEC dbo.sp_CreatePost
--     @UserID = 1,
--     @Caption = N'Test post created by stored procedure',
--     @MediaURL = N'https://example.com/test-post.jpg',
--     @MediaType = N'Image',
--     @Location = N'Plovdiv';

-- To test trigger, insert a like that does not already exist:
-- INSERT INTO dbo.Likes (UserID, PostID) VALUES (1, 20);
-- SELECT TOP (10) * FROM dbo.ActivityLog ORDER BY ActivityLogID DESC;
*/
