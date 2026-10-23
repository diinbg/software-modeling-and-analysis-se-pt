USE InstagramDB;
GO

/* ============================================================
   05 - Data Warehouse enhancement: Post-Hashtag bridge
   Purpose: connect posts and hashtags for Power BI analysis.
   Run after 04_DataWarehouse_Instagram.sql.
   ============================================================ */

IF OBJECT_ID(N'dbo.BridgePostHashtag', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.BridgePostHashtag
    (
        PostKey INT NOT NULL,
        HashtagKey INT NOT NULL,
        CONSTRAINT PK_BridgePostHashtag PRIMARY KEY (PostKey, HashtagKey),
        CONSTRAINT FK_BridgePostHashtag_DimPost
            FOREIGN KEY (PostKey) REFERENCES dbo.DimPost(PostKey),
        CONSTRAINT FK_BridgePostHashtag_DimHashtag
            FOREIGN KEY (HashtagKey) REFERENCES dbo.DimHashtag(HashtagKey)
    );
END;
GO

INSERT INTO dbo.BridgePostHashtag (PostKey, HashtagKey)
SELECT dp.PostKey, dh.HashtagKey
FROM dbo.PostHashtags ph
JOIN dbo.DimPost dp ON dp.SourcePostID = ph.PostID
JOIN dbo.DimHashtag dh ON dh.SourceHashtagID = ph.HashtagID
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.BridgePostHashtag b
    WHERE b.PostKey = dp.PostKey
      AND b.HashtagKey = dh.HashtagKey
);
GO

SELECT
    (SELECT COUNT(*) FROM dbo.BridgePostHashtag) AS BridgeRows,
    (SELECT COUNT(*) FROM dbo.PostHashtags) AS SourcePostHashtagRows;
GO
