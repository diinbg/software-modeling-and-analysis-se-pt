/*
    Instagram Database & Analytics
    Stage 1: Create the operational database and relational tables
    Target: Microsoft SQL Server
    Source model: Instagram_Models_Chen_CrowsFoot_Reviewed.drawio

    Run this script in SQL Server Management Studio (SSMS).
    It creates a new database named InstagramDB.
*/

IF DB_ID(N'InstagramDB') IS NULL
BEGIN
    CREATE DATABASE InstagramDB;
END;
GO

USE InstagramDB;
GO

/* 1. USERS */
IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users
    (
        UserID INT IDENTITY(1,1) NOT NULL,
        Username NVARCHAR(30) NOT NULL,
        Email NVARCHAR(255) NOT NULL,
        PasswordHash NVARCHAR(255) NOT NULL,
        FullName NVARCHAR(100) NOT NULL,
        Bio NVARCHAR(500) NULL,
        ProfilePictureURL NVARCHAR(500) NULL,
        CreatedAt DATETIME2(0) NOT NULL
            CONSTRAINT DF_Users_CreatedAt DEFAULT SYSUTCDATETIME(),
        IsPrivate BIT NOT NULL
            CONSTRAINT DF_Users_IsPrivate DEFAULT (0),
        IsActive BIT NOT NULL
            CONSTRAINT DF_Users_IsActive DEFAULT (1),

        CONSTRAINT PK_Users PRIMARY KEY (UserID),
        CONSTRAINT UQ_Users_Username UNIQUE (Username),
        CONSTRAINT UQ_Users_Email UNIQUE (Email)
    );
END;
GO

/* 2. POSTS */
IF OBJECT_ID(N'dbo.Posts', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Posts
    (
        PostID INT IDENTITY(1,1) NOT NULL,
        UserID INT NOT NULL,
        Caption NVARCHAR(2200) NULL,
        MediaURL NVARCHAR(500) NOT NULL,
        MediaType VARCHAR(20) NOT NULL,
        Location NVARCHAR(150) NULL,
        CreatedAt DATETIME2(0) NOT NULL
            CONSTRAINT DF_Posts_CreatedAt DEFAULT SYSUTCDATETIME(),
        IsArchived BIT NOT NULL
            CONSTRAINT DF_Posts_IsArchived DEFAULT (0),

        CONSTRAINT PK_Posts PRIMARY KEY (PostID),
        CONSTRAINT FK_Posts_Users FOREIGN KEY (UserID)
            REFERENCES dbo.Users(UserID),
        CONSTRAINT CK_Posts_MediaType
            CHECK (MediaType IN ('Image', 'Video', 'Carousel'))
    );
END;
GO

/* 3. FOLLOWS: associative table for the recursive User-to-User relationship */
IF OBJECT_ID(N'dbo.Follows', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Follows
    (
        FollowerID INT NOT NULL,
        FollowedID INT NOT NULL,
        FollowedAt DATETIME2(0) NOT NULL
            CONSTRAINT DF_Follows_FollowedAt DEFAULT SYSUTCDATETIME(),
        Status VARCHAR(20) NOT NULL
            CONSTRAINT DF_Follows_Status DEFAULT ('Accepted'),

        CONSTRAINT PK_Follows PRIMARY KEY (FollowerID, FollowedID),
        CONSTRAINT FK_Follows_Follower FOREIGN KEY (FollowerID)
            REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_Follows_Followed FOREIGN KEY (FollowedID)
            REFERENCES dbo.Users(UserID),
        CONSTRAINT CK_Follows_NoSelfFollow CHECK (FollowerID <> FollowedID),
        CONSTRAINT CK_Follows_Status CHECK (Status IN ('Pending', 'Accepted'))
    );
END;
GO

/* 4. LIKES: each user can like a given post only once */
IF OBJECT_ID(N'dbo.Likes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Likes
    (
        UserID INT NOT NULL,
        PostID INT NOT NULL,
        LikedAt DATETIME2(0) NOT NULL
            CONSTRAINT DF_Likes_LikedAt DEFAULT SYSUTCDATETIME(),

        CONSTRAINT PK_Likes PRIMARY KEY (UserID, PostID),
        CONSTRAINT FK_Likes_Users FOREIGN KEY (UserID)
            REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_Likes_Posts FOREIGN KEY (PostID)
            REFERENCES dbo.Posts(PostID)
    );
END;
GO

/* 5. COMMENTS */
IF OBJECT_ID(N'dbo.Comments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Comments
    (
        CommentID INT IDENTITY(1,1) NOT NULL,
        PostID INT NOT NULL,
        UserID INT NOT NULL,
        ParentCommentID INT NULL,
        CommentText NVARCHAR(2200) NOT NULL,
        CreatedAt DATETIME2(0) NOT NULL
            CONSTRAINT DF_Comments_CreatedAt DEFAULT SYSUTCDATETIME(),

        CONSTRAINT PK_Comments PRIMARY KEY (CommentID),
        CONSTRAINT FK_Comments_Posts FOREIGN KEY (PostID)
            REFERENCES dbo.Posts(PostID),
        CONSTRAINT FK_Comments_Users FOREIGN KEY (UserID)
            REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_Comments_ParentComment FOREIGN KEY (ParentCommentID)
            REFERENCES dbo.Comments(CommentID),
        CONSTRAINT CK_Comments_NotOwnParent
            CHECK (ParentCommentID IS NULL OR ParentCommentID <> CommentID)
    );
END;
GO

/* 6. HASHTAGS */
IF OBJECT_ID(N'dbo.Hashtags', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Hashtags
    (
        HashtagID INT IDENTITY(1,1) NOT NULL,
        TagName NVARCHAR(100) NOT NULL,
        CreatedAt DATETIME2(0) NOT NULL
            CONSTRAINT DF_Hashtags_CreatedAt DEFAULT SYSUTCDATETIME(),

        CONSTRAINT PK_Hashtags PRIMARY KEY (HashtagID),
        CONSTRAINT UQ_Hashtags_TagName UNIQUE (TagName)
    );
END;
GO

/* 7. POSTHASHTAGS: associative table for Post-to-Hashtag M:N relationship */
IF OBJECT_ID(N'dbo.PostHashtags', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PostHashtags
    (
        PostID INT NOT NULL,
        HashtagID INT NOT NULL,

        CONSTRAINT PK_PostHashtags PRIMARY KEY (PostID, HashtagID),
        CONSTRAINT FK_PostHashtags_Posts FOREIGN KEY (PostID)
            REFERENCES dbo.Posts(PostID),
        CONSTRAINT FK_PostHashtags_Hashtags FOREIGN KEY (HashtagID)
            REFERENCES dbo.Hashtags(HashtagID)
    );
END;
GO

/* 8. STORIES */
IF OBJECT_ID(N'dbo.Stories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Stories
    (
        StoryID INT IDENTITY(1,1) NOT NULL,
        UserID INT NOT NULL,
        MediaURL NVARCHAR(500) NOT NULL,
        MediaType VARCHAR(20) NOT NULL,
        CreatedAt DATETIME2(0) NOT NULL
            CONSTRAINT DF_Stories_CreatedAt DEFAULT SYSUTCDATETIME(),
        ExpiresAt DATETIME2(0) NOT NULL,
        IsArchived BIT NOT NULL
            CONSTRAINT DF_Stories_IsArchived DEFAULT (0),

        CONSTRAINT PK_Stories PRIMARY KEY (StoryID),
        CONSTRAINT FK_Stories_Users FOREIGN KEY (UserID)
            REFERENCES dbo.Users(UserID),
        CONSTRAINT CK_Stories_MediaType
            CHECK (MediaType IN ('Image', 'Video')),
        CONSTRAINT CK_Stories_Expiry CHECK (ExpiresAt > CreatedAt)
    );
END;
GO

/* 9. MESSAGES: Sender and Receiver are separate roles of Users */
IF OBJECT_ID(N'dbo.Messages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Messages
    (
        MessageID INT IDENTITY(1,1) NOT NULL,
        SenderID INT NOT NULL,
        ReceiverID INT NOT NULL,
        MessageText NVARCHAR(4000) NOT NULL,
        SentAt DATETIME2(0) NOT NULL
            CONSTRAINT DF_Messages_SentAt DEFAULT SYSUTCDATETIME(),
        IsRead BIT NOT NULL
            CONSTRAINT DF_Messages_IsRead DEFAULT (0),

        CONSTRAINT PK_Messages PRIMARY KEY (MessageID),
        CONSTRAINT FK_Messages_Sender FOREIGN KEY (SenderID)
            REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_Messages_Receiver FOREIGN KEY (ReceiverID)
            REFERENCES dbo.Users(UserID),
        CONSTRAINT CK_Messages_DifferentUsers CHECK (SenderID <> ReceiverID)
    );
END;
GO

/* 10. POSTVIEWS: one row represents one view event */
IF OBJECT_ID(N'dbo.PostViews', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PostViews
    (
        ViewID INT IDENTITY(1,1) NOT NULL,
        UserID INT NOT NULL,
        PostID INT NOT NULL,
        ViewedAt DATETIME2(0) NOT NULL
            CONSTRAINT DF_PostViews_ViewedAt DEFAULT SYSUTCDATETIME(),
        WatchDurationSeconds INT NOT NULL
            CONSTRAINT DF_PostViews_WatchDuration DEFAULT (0),

        CONSTRAINT PK_PostViews PRIMARY KEY (ViewID),
        CONSTRAINT FK_PostViews_Users FOREIGN KEY (UserID)
            REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_PostViews_Posts FOREIGN KEY (PostID)
            REFERENCES dbo.Posts(PostID),
        CONSTRAINT CK_PostViews_Duration CHECK (WatchDurationSeconds >= 0)
    );
END;
GO

/* Supporting indexes for common joins and lookups */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Posts_UserID_CreatedAt' AND object_id = OBJECT_ID(N'dbo.Posts'))
    CREATE INDEX IX_Posts_UserID_CreatedAt ON dbo.Posts(UserID, CreatedAt DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Comments_PostID_CreatedAt' AND object_id = OBJECT_ID(N'dbo.Comments'))
    CREATE INDEX IX_Comments_PostID_CreatedAt ON dbo.Comments(PostID, CreatedAt);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Follows_FollowedID' AND object_id = OBJECT_ID(N'dbo.Follows'))
    CREATE INDEX IX_Follows_FollowedID ON dbo.Follows(FollowedID, Status);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Messages_ReceiverID_SentAt' AND object_id = OBJECT_ID(N'dbo.Messages'))
    CREATE INDEX IX_Messages_ReceiverID_SentAt ON dbo.Messages(ReceiverID, SentAt DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PostViews_PostID_ViewedAt' AND object_id = OBJECT_ID(N'dbo.PostViews'))
    CREATE INDEX IX_PostViews_PostID_ViewedAt ON dbo.PostViews(PostID, ViewedAt);
GO

PRINT 'InstagramDB and its 10 tables were created or already existed.';
GO
