USE InstagramDB;
GO

/* ============================================================
   04 - Instagram Data Warehouse
   Creates 6 dimensions and 3 fact tables, then loads sample data
   from the transactional InstagramDB schema.
   Run after scripts 01, 02 and 03.
   ============================================================ */

/* -------------------------
   DIMENSIONS (6)
   ------------------------- */

IF OBJECT_ID(N'dbo.DimDate', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimDate
    (
        DateKey INT NOT NULL CONSTRAINT PK_DimDate PRIMARY KEY, -- YYYYMMDD
        FullDate DATE NOT NULL,
        DayNumber TINYINT NOT NULL,
        MonthNumber TINYINT NOT NULL,
        MonthName NVARCHAR(20) NOT NULL,
        QuarterNumber TINYINT NOT NULL,
        YearNumber SMALLINT NOT NULL,
        CONSTRAINT UQ_DimDate_FullDate UNIQUE (FullDate)
    );
END;
GO

IF OBJECT_ID(N'dbo.DimUser', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimUser
    (
        UserKey INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimUser PRIMARY KEY,
        SourceUserID INT NOT NULL,
        Username NVARCHAR(50) NOT NULL,
        FullName NVARCHAR(100) NULL,
        IsPrivate BIT NOT NULL,
        IsActive BIT NOT NULL,
        CreatedAt DATETIME2(0) NOT NULL,
        CONSTRAINT UQ_DimUser_SourceUserID UNIQUE (SourceUserID)
    );
END;
GO

IF OBJECT_ID(N'dbo.DimPost', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimPost
    (
        PostKey INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimPost PRIMARY KEY,
        SourcePostID INT NOT NULL,
        SourceUserID INT NOT NULL,
        MediaType NVARCHAR(20) NOT NULL,
        Location NVARCHAR(150) NULL,
        IsArchived BIT NOT NULL,
        CreatedAt DATETIME2(0) NOT NULL,
        CONSTRAINT UQ_DimPost_SourcePostID UNIQUE (SourcePostID)
    );
END;
GO

IF OBJECT_ID(N'dbo.DimHashtag', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimHashtag
    (
        HashtagKey INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimHashtag PRIMARY KEY,
        SourceHashtagID INT NOT NULL,
        TagName NVARCHAR(100) NOT NULL,
        CONSTRAINT UQ_DimHashtag_SourceHashtagID UNIQUE (SourceHashtagID)
    );
END;
GO

IF OBJECT_ID(N'dbo.DimActivityType', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimActivityType
    (
        ActivityTypeKey INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimActivityType PRIMARY KEY,
        ActivityTypeName NVARCHAR(30) NOT NULL,
        ActivityDescription NVARCHAR(200) NULL,
        CONSTRAINT UQ_DimActivityType_Name UNIQUE (ActivityTypeName)
    );
END;
GO

IF OBJECT_ID(N'dbo.DimMediaType', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimMediaType
    (
        MediaTypeKey INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimMediaType PRIMARY KEY,
        MediaTypeName NVARCHAR(20) NOT NULL,
        MediaDescription NVARCHAR(100) NULL,
        CONSTRAINT UQ_DimMediaType_Name UNIQUE (MediaTypeName)
    );
END;
GO

/* -------------------------
   FACT TABLES (3)
   ------------------------- */

IF OBJECT_ID(N'dbo.FactPostEngagement', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FactPostEngagement
    (
        PostEngagementKey BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_FactPostEngagement PRIMARY KEY,
        DateKey INT NOT NULL,
        UserKey INT NOT NULL,
        PostKey INT NOT NULL,
        MediaTypeKey INT NOT NULL,
        ActivityTypeKey INT NOT NULL,
        LikeCount INT NOT NULL CONSTRAINT DF_FactPostEngagement_Likes DEFAULT (0),
        CommentCount INT NOT NULL CONSTRAINT DF_FactPostEngagement_Comments DEFAULT (0),
        EngagementCount AS (LikeCount + CommentCount) PERSISTED,
        CONSTRAINT FK_FPE_Date FOREIGN KEY (DateKey) REFERENCES dbo.DimDate(DateKey),
        CONSTRAINT FK_FPE_User FOREIGN KEY (UserKey) REFERENCES dbo.DimUser(UserKey),
        CONSTRAINT FK_FPE_Post FOREIGN KEY (PostKey) REFERENCES dbo.DimPost(PostKey),
        CONSTRAINT FK_FPE_Media FOREIGN KEY (MediaTypeKey) REFERENCES dbo.DimMediaType(MediaTypeKey),
        CONSTRAINT FK_FPE_Activity FOREIGN KEY (ActivityTypeKey) REFERENCES dbo.DimActivityType(ActivityTypeKey),
        CONSTRAINT CK_FPE_Counts CHECK (LikeCount >= 0 AND CommentCount >= 0)
    );
END;
GO

IF OBJECT_ID(N'dbo.FactUserActivity', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FactUserActivity
    (
        UserActivityKey BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_FactUserActivity PRIMARY KEY,
        DateKey INT NOT NULL,
        UserKey INT NOT NULL,
        ActivityTypeKey INT NOT NULL,
        ActivityCount INT NOT NULL CONSTRAINT DF_FactUserActivity_Count DEFAULT (1),
        CONSTRAINT FK_FUA_Date FOREIGN KEY (DateKey) REFERENCES dbo.DimDate(DateKey),
        CONSTRAINT FK_FUA_User FOREIGN KEY (UserKey) REFERENCES dbo.DimUser(UserKey),
        CONSTRAINT FK_FUA_Activity FOREIGN KEY (ActivityTypeKey) REFERENCES dbo.DimActivityType(ActivityTypeKey),
        CONSTRAINT CK_FUA_Count CHECK (ActivityCount >= 0)
    );
END;
GO

IF OBJECT_ID(N'dbo.FactPostViews', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FactPostViews
    (
        PostViewFactKey BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_FactPostViews PRIMARY KEY,
        DateKey INT NOT NULL,
        UserKey INT NOT NULL,
        PostKey INT NOT NULL,
        MediaTypeKey INT NOT NULL,
        ViewCount INT NOT NULL CONSTRAINT DF_FPV_ViewCount DEFAULT (1),
        TotalWatchDurationSeconds BIGINT NOT NULL CONSTRAINT DF_FPV_Duration DEFAULT (0),
        CONSTRAINT FK_FPV_Date FOREIGN KEY (DateKey) REFERENCES dbo.DimDate(DateKey),
        CONSTRAINT FK_FPV_User FOREIGN KEY (UserKey) REFERENCES dbo.DimUser(UserKey),
        CONSTRAINT FK_FPV_Post FOREIGN KEY (PostKey) REFERENCES dbo.DimPost(PostKey),
        CONSTRAINT FK_FPV_Media FOREIGN KEY (MediaTypeKey) REFERENCES dbo.DimMediaType(MediaTypeKey),
        CONSTRAINT CK_FPV_Values CHECK (ViewCount >= 0 AND TotalWatchDurationSeconds >= 0)
    );
END;
GO

/* -------------------------
   LOAD DIMENSIONS
   ------------------------- */

/* Calendar dimension: populate dates covering source data and current year */
DECLARE @StartDate DATE = '2026-01-01';
DECLARE @EndDate DATE = '2027-12-31';

;WITH DateSeries AS
(
    SELECT @StartDate AS FullDate
    UNION ALL
    SELECT DATEADD(DAY, 1, FullDate)
    FROM DateSeries
    WHERE FullDate < @EndDate
)
INSERT INTO dbo.DimDate (DateKey, FullDate, DayNumber, MonthNumber, MonthName, QuarterNumber, YearNumber)
SELECT
    YEAR(FullDate) * 10000 + MONTH(FullDate) * 100 + DAY(FullDate),
    FullDate,
    DAY(FullDate),
    MONTH(FullDate),
    DATENAME(MONTH, FullDate),
    DATEPART(QUARTER, FullDate),
    YEAR(FullDate)
FROM DateSeries d
WHERE NOT EXISTS (SELECT 1 FROM dbo.DimDate x WHERE x.FullDate = d.FullDate)
OPTION (MAXRECURSION 0);
GO

INSERT INTO dbo.DimUser (SourceUserID, Username, FullName, IsPrivate, IsActive, CreatedAt)
SELECT u.UserID, u.Username, u.FullName, u.IsPrivate, u.IsActive, u.CreatedAt
FROM dbo.Users u
WHERE NOT EXISTS
(
    SELECT 1 FROM dbo.DimUser du WHERE du.SourceUserID = u.UserID
);
GO

INSERT INTO dbo.DimPost (SourcePostID, SourceUserID, MediaType, Location, IsArchived, CreatedAt)
SELECT p.PostID, p.UserID, p.MediaType, p.Location, p.IsArchived, p.CreatedAt
FROM dbo.Posts p
WHERE NOT EXISTS
(
    SELECT 1 FROM dbo.DimPost dp WHERE dp.SourcePostID = p.PostID
);
GO

INSERT INTO dbo.DimHashtag (SourceHashtagID, TagName)
SELECT h.HashtagID, h.TagName
FROM dbo.Hashtags h
WHERE NOT EXISTS
(
    SELECT 1 FROM dbo.DimHashtag dh WHERE dh.SourceHashtagID = h.HashtagID
);
GO

INSERT INTO dbo.DimActivityType (ActivityTypeName, ActivityDescription)
SELECT v.ActivityTypeName, v.ActivityDescription
FROM (VALUES
    (N'PostEngagement', N'Combined likes and comments on posts'),
    (N'Like', N'A user likes a post'),
    (N'Comment', N'A user comments on a post'),
    (N'PostView', N'A user views a post'),
    (N'Follow', N'A user follows another user'),
    (N'Message', N'A user sends a direct message')
) v(ActivityTypeName, ActivityDescription)
WHERE NOT EXISTS
(
    SELECT 1 FROM dbo.DimActivityType d WHERE d.ActivityTypeName = v.ActivityTypeName
);
GO

INSERT INTO dbo.DimMediaType (MediaTypeName, MediaDescription)
SELECT v.MediaTypeName, v.MediaDescription
FROM (VALUES
    (N'Image', N'Still image post or story'),
    (N'Video', N'Video post or story'),
    (N'Carousel', N'Multiple images or media in one post')
) v(MediaTypeName, MediaDescription)
WHERE NOT EXISTS
(
    SELECT 1 FROM dbo.DimMediaType d WHERE d.MediaTypeName = v.MediaTypeName
);
GO

/* -------------------------
   LOAD FACT TABLES
   ------------------------- */

/* FactPostEngagement: one row per post, with total likes and comments */
INSERT INTO dbo.FactPostEngagement
    (DateKey, UserKey, PostKey, MediaTypeKey, ActivityTypeKey, LikeCount, CommentCount)
SELECT
    dd.DateKey,
    du.UserKey,
    dp.PostKey,
    dmt.MediaTypeKey,
    dat.ActivityTypeKey,
    (SELECT COUNT(*) FROM dbo.Likes l WHERE l.PostID = p.PostID),
    (SELECT COUNT(*) FROM dbo.Comments c WHERE c.PostID = p.PostID)
FROM dbo.Posts p
JOIN dbo.DimDate dd ON dd.FullDate = CAST(p.CreatedAt AS DATE)
JOIN dbo.DimUser du ON du.SourceUserID = p.UserID
JOIN dbo.DimPost dp ON dp.SourcePostID = p.PostID
JOIN dbo.DimMediaType dmt ON dmt.MediaTypeName = p.MediaType
JOIN dbo.DimActivityType dat ON dat.ActivityTypeName = N'PostEngagement'
WHERE NOT EXISTS
(
    SELECT 1 FROM dbo.FactPostEngagement f WHERE f.PostKey = dp.PostKey
);
GO

/* FactUserActivity: aggregated user actions by date and activity type */
;WITH UserActions AS
(
    SELECT CAST(l.LikedAt AS DATE) AS ActivityDate, l.UserID, N'Like' AS ActivityTypeName, COUNT(*) AS ActivityCount
    FROM dbo.Likes l
    GROUP BY CAST(l.LikedAt AS DATE), l.UserID

    UNION ALL

    SELECT CAST(c.CreatedAt AS DATE), c.UserID, N'Comment', COUNT(*)
    FROM dbo.Comments c
    GROUP BY CAST(c.CreatedAt AS DATE), c.UserID

    UNION ALL

    SELECT CAST(m.SentAt AS DATE), m.SenderID, N'Message', COUNT(*)
    FROM dbo.Messages m
    GROUP BY CAST(m.SentAt AS DATE), m.SenderID

    UNION ALL

    SELECT CAST(f.FollowedAt AS DATE), f.FollowerID, N'Follow', COUNT(*)
    FROM dbo.Follows f
    WHERE f.Status = N'Accepted'
    GROUP BY CAST(f.FollowedAt AS DATE), f.FollowerID
)
INSERT INTO dbo.FactUserActivity (DateKey, UserKey, ActivityTypeKey, ActivityCount)
SELECT dd.DateKey, du.UserKey, dat.ActivityTypeKey, ua.ActivityCount
FROM UserActions ua
JOIN dbo.DimDate dd ON dd.FullDate = ua.ActivityDate
JOIN dbo.DimUser du ON du.SourceUserID = ua.UserID
JOIN dbo.DimActivityType dat ON dat.ActivityTypeName = ua.ActivityTypeName
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.FactUserActivity f
    WHERE f.DateKey = dd.DateKey
      AND f.UserKey = du.UserKey
      AND f.ActivityTypeKey = dat.ActivityTypeKey
);
GO

/* FactPostViews: one row per recorded post view */
INSERT INTO dbo.FactPostViews
    (DateKey, UserKey, PostKey, MediaTypeKey, ViewCount, TotalWatchDurationSeconds)
SELECT
    dd.DateKey,
    du.UserKey,
    dp.PostKey,
    dmt.MediaTypeKey,
    COUNT(*) AS ViewCount,
    SUM(CAST(pv.WatchDurationSeconds AS BIGINT)) AS TotalWatchDurationSeconds
FROM dbo.PostViews pv
JOIN dbo.DimDate dd ON dd.FullDate = CAST(pv.ViewedAt AS DATE)
JOIN dbo.DimUser du ON du.SourceUserID = pv.UserID
JOIN dbo.DimPost dp ON dp.SourcePostID = pv.PostID
JOIN dbo.DimMediaType dmt ON dmt.MediaTypeName = dp.MediaType
GROUP BY dd.DateKey, du.UserKey, dp.PostKey, dmt.MediaTypeKey
HAVING NOT EXISTS
(
    SELECT 1
    FROM dbo.FactPostViews f
    WHERE f.DateKey = dd.DateKey
      AND f.UserKey = du.UserKey
      AND f.PostKey = dp.PostKey
);
GO

/* -------------------------
   VERIFICATION
   ------------------------- */
SELECT N'Dimension' AS ObjectType, name AS ObjectName
FROM sys.tables
WHERE name IN (N'DimDate', N'DimUser', N'DimPost', N'DimHashtag', N'DimActivityType', N'DimMediaType')
UNION ALL
SELECT N'Fact table', name
FROM sys.tables
WHERE name IN (N'FactPostEngagement', N'FactUserActivity', N'FactPostViews')
ORDER BY ObjectType, ObjectName;
GO

SELECT N'DimDate' AS TableName, COUNT(*) AS [RowCount] FROM dbo.DimDate
UNION ALL SELECT N'DimUser', COUNT(*) FROM dbo.DimUser
UNION ALL SELECT N'DimPost', COUNT(*) FROM dbo.DimPost
UNION ALL SELECT N'DimHashtag', COUNT(*) FROM dbo.DimHashtag
UNION ALL SELECT N'DimActivityType', COUNT(*) FROM dbo.DimActivityType
UNION ALL SELECT N'DimMediaType', COUNT(*) FROM dbo.DimMediaType
UNION ALL SELECT N'FactPostEngagement', COUNT(*) FROM dbo.FactPostEngagement
UNION ALL SELECT N'FactUserActivity', COUNT(*) FROM dbo.FactUserActivity
UNION ALL SELECT N'FactPostViews', COUNT(*) FROM dbo.FactPostViews
ORDER BY TableName;
GO
