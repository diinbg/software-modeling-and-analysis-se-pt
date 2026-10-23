/*
    Instagram Database & Analytics
    Stage 2: Seed InstagramDB with reproducible demonstration data
    Target: Microsoft SQL Server

    Notes:
    - Uses a fixed synthetic dataset for repeatable results.
    - PasswordHash values are placeholders only; this project does not implement authentication.
    - Run after 01_Create_InstagramDB.sql.
*/

USE InstagramDB;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    /* Users: insert only if the dataset has not already been seeded. */
    IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = N'alex.photo')
    BEGIN
        INSERT dbo.Users
            (Username, Email, PasswordHash, FullName, Bio, ProfilePictureURL, CreatedAt, IsPrivate, IsActive)
        VALUES
        (N'alex.photo',       N'alex.photo@example.com',       N'DEMO_HASH_NOT_FOR_AUTH', N'Alex Petrov',    N'Travel and photography', N'https://example.com/profiles/alex.jpg',       '2026-01-03T09:15:00', 0, 1),
        (N'maria.fit',        N'maria.fit@example.com',        N'DEMO_HASH_NOT_FOR_AUTH', N'Maria Ivanova',  N'Fitness and healthy habits', N'https://example.com/profiles/maria.jpg',    '2026-01-05T11:30:00', 0, 1),
        (N'georgi.dev',       N'georgi.dev@example.com',       N'DEMO_HASH_NOT_FOR_AUTH', N'Georgi Dimitrov',N'Code, coffee and tech', N'https://example.com/profiles/georgi.jpg',       '2026-01-08T08:45:00', 0, 1),
        (N'eli.art',          N'eli.art@example.com',          N'DEMO_HASH_NOT_FOR_AUTH', N'Elena Georgieva',N'Digital art', N'https://example.com/profiles/eli.jpg',             '2026-01-12T14:00:00', 1, 1),
        (N'nikola.travels',   N'nikola.travels@example.com',   N'DEMO_HASH_NOT_FOR_AUTH', N'Nikola Stoyanov',N'Weekend trips', N'https://example.com/profiles/nikola.jpg',       '2026-01-15T16:20:00', 0, 1),
        (N'simona.food',      N'simona.food@example.com',      N'DEMO_HASH_NOT_FOR_AUTH', N'Simona Koleva',  N'Food experiments', N'https://example.com/profiles/simona.jpg',        '2026-01-18T10:10:00', 0, 1),
        (N'petar.gaming',     N'petar.gaming@example.com',     N'DEMO_HASH_NOT_FOR_AUTH', N'Petar Nikolov',  N'Games and streams', N'https://example.com/profiles/petar.jpg',         '2026-01-20T19:40:00', 1, 1),
        (N'iva.design',       N'iva.design@example.com',       N'DEMO_HASH_NOT_FOR_AUTH', N'Iva Hristova',   N'Graphic design', N'https://example.com/profiles/iva.jpg',             '2026-01-23T12:25:00', 0, 1),
        (N'daniel.music',     N'daniel.music@example.com',     N'DEMO_HASH_NOT_FOR_AUTH', N'Daniel Angelov', N'Music and live shows', N'https://example.com/profiles/daniel.jpg',      '2026-01-25T20:00:00', 0, 1),
        (N'victoria.books',   N'victoria.books@example.com',   N'victoria.books@example.com', N'Victoria Petrova',N'Reading list', N'https://example.com/profiles/victoria.jpg', '2026-01-28T09:00:00', 0, 1),
        (N'martin.outdoors',  N'martin.outdoors@example.com',  N'DEMO_HASH_NOT_FOR_AUTH', N'Martin Vasilev', N'Hiking and nature', N'https://example.com/profiles/martin.jpg',       '2026-02-02T07:30:00', 0, 1),
        (N'plamena.photo',    N'plamena.photo@example.com',    N'DEMO_HASH_NOT_FOR_AUTH', N'Plamena Ilieva', N'Film photography', N'https://example.com/profiles/plamena.jpg',     '2026-02-06T15:45:00', 0, 1),
        (N'boris.cooks',      N'boris.cooks@example.com',      N'DEMO_HASH_NOT_FOR_AUTH', N'Boris Todorov',  N'Home cooking', N'https://example.com/profiles/boris.jpg',         '2026-02-10T17:10:00', 0, 1),
        (N'anna.runner',      N'anna.runner@example.com',      N'DEMO_HASH_NOT_FOR_AUTH', N'Anna Marinova',  N'Running and outdoors', N'https://example.com/profiles/anna.jpg',      '2026-02-14T06:50:00', 0, 1),
        (N'hristo.cinema',    N'hristo.cinema@example.com',    N'DEMO_HASH_NOT_FOR_AUTH', N'Hristo Petkov',  N'Films and cinema', N'https://example.com/profiles/hristo.jpg',      '2026-02-18T21:00:00', 0, 1),
        (N'kristina.travel',  N'kristina.travel@example.com',  N'DEMO_HASH_NOT_FOR_AUTH', N'Kristina Yordanova',N'City breaks', N'https://example.com/profiles/kristina.jpg', '2026-02-21T13:15:00', 0, 1),
        (N'ivan.tech',        N'ivan.tech@example.com',        N'DEMO_HASH_NOT_FOR_AUTH', N'Ivan Kolev',     N'Hardware and software', N'https://example.com/profiles/ivan.jpg',        '2026-02-25T18:35:00', 0, 1),
        (N'desi.plants',      N'desi.plants@example.com',      N'DEMO_HASH_NOT_FOR_AUTH', N'Desislava Markova',N'Plants and gardening', N'https://example.com/profiles/desi.jpg',    '2026-03-01T10:00:00', 0, 1),
        (N'teodor.urban',     N'teodor.urban@example.com',     N'DEMO_HASH_NOT_FOR_AUTH', N'Teodor Ivanov',  N'Urban photography', N'https://example.com/profiles/teodor.jpg',       '2026-03-05T16:40:00', 0, 1),
        (N'raya.dance',       N'raya.dance@example.com',       N'DEMO_HASH_NOT_FOR_AUTH', N'Raya Nikolova',  N'Dance practice', N'https://example.com/profiles/raya.jpg',           '2026-03-09T18:50:00', 0, 1);
    END;

    /* Posts: add synthetic posts only when none from this sample exist. */
    IF NOT EXISTS (SELECT 1 FROM dbo.Posts WHERE LEFT(Caption, 7) = N'[DEMO] ')
    BEGIN
        INSERT dbo.Posts
            (UserID, Caption, MediaURL, MediaType, Location, CreatedAt, IsArchived)
        SELECT u.UserID, v.Caption, v.MediaURL, v.MediaType, v.Location, v.CreatedAt, 0
        FROM (VALUES
            (N'alex.photo',      N'[DEMO] Sunrise in the mountains', N'https://example.com/media/post01.jpg', 'Image',    N'Rila Mountains',       CAST('2026-03-01T07:20:00' AS DATETIME2(0))),
            (N'maria.fit',       N'[DEMO] Morning training session', N'https://example.com/media/post02.jpg', 'Image',    N'Plovdiv',              CAST('2026-03-02T08:10:00' AS DATETIME2(0))),
            (N'georgi.dev',      N'[DEMO] My desk setup',            N'https://example.com/media/post03.jpg', 'Carousel', N'Sofia',                CAST('2026-03-03T12:00:00' AS DATETIME2(0))),
            (N'eli.art',         N'[DEMO] New digital illustration', N'https://example.com/media/post04.png', 'Image',    N'Home studio',          CAST('2026-03-04T16:45:00' AS DATETIME2(0))),
            (N'nikola.travels',  N'[DEMO] Weekend by the sea',       N'https://example.com/media/post05.mp4', 'Video',    N'Burgas',               CAST('2026-03-05T18:30:00' AS DATETIME2(0))),
            (N'simona.food',     N'[DEMO] Homemade pasta',           N'https://example.com/media/post06.jpg', 'Image',    N'Plovdiv',              CAST('2026-03-06T13:15:00' AS DATETIME2(0))),
            (N'petar.gaming',    N'[DEMO] New gaming setup',         N'https://example.com/media/post07.jpg', 'Carousel', N'Varna',                CAST('2026-03-07T20:00:00' AS DATETIME2(0))),
            (N'iva.design',      N'[DEMO] Poster design process',    N'https://example.com/media/post08.mp4', 'Video',    N'Sofia',                CAST('2026-03-08T11:35:00' AS DATETIME2(0))),
            (N'daniel.music',    N'[DEMO] Live music tonight',       N'https://example.com/media/post09.jpg', 'Image',    N'Plovdiv',              CAST('2026-03-09T21:10:00' AS DATETIME2(0))),
            (N'victoria.books',  N'[DEMO] Current reading list',     N'https://example.com/media/post10.jpg', 'Image',    N'Sofia',                CAST('2026-03-10T10:05:00' AS DATETIME2(0))),
            (N'martin.outdoors', N'[DEMO] Forest trail',             N'https://example.com/media/post11.jpg', 'Image',    N'Rhodope Mountains',    CAST('2026-03-11T09:00:00' AS DATETIME2(0))),
            (N'plamena.photo',   N'[DEMO] Film camera test',         N'https://example.com/media/post12.jpg', 'Image',    N'Veliko Tarnovo',       CAST('2026-03-12T14:25:00' AS DATETIME2(0))),
            (N'boris.cooks',     N'[DEMO] Bread from scratch',       N'https://example.com/media/post13.jpg', 'Image',    N'Home kitchen',         CAST('2026-03-13T17:45:00' AS DATETIME2(0))),
            (N'anna.runner',     N'[DEMO] Park run',                 N'https://example.com/media/post14.mp4', 'Video',    N'Plovdiv',              CAST('2026-03-14T07:40:00' AS DATETIME2(0))),
            (N'hristo.cinema',   N'[DEMO] Film photography walk',    N'https://example.com/media/post15.jpg', 'Image',    N'Sofia',                CAST('2026-03-15T15:20:00' AS DATETIME2(0))),
            (N'kristina.travel', N'[DEMO] Old town streets',         N'https://example.com/media/post16.jpg', 'Image',    N'Plovdiv Old Town',     CAST('2026-03-16T12:30:00' AS DATETIME2(0))),
            (N'ivan.tech',       N'[DEMO] Building a PC',            N'https://example.com/media/post17.jpg', 'Carousel', N'Sofia',                CAST('2026-03-17T19:15:00' AS DATETIME2(0))),
            (N'desi.plants',     N'[DEMO] Repotting day',            N'https://example.com/media/post18.jpg', 'Image',    N'Home',                 CAST('2026-03-18T10:50:00' AS DATETIME2(0))),
            (N'teodor.urban',    N'[DEMO] City after rain',          N'https://example.com/media/post19.jpg', 'Image',    N'Plovdiv',              CAST('2026-03-19T18:05:00' AS DATETIME2(0))),
            (N'raya.dance',      N'[DEMO] Dance rehearsal',          N'https://example.com/media/post20.mp4', 'Video',    N'Studio',               CAST('2026-03-20T20:30:00' AS DATETIME2(0)))
        ) AS v(Username, Caption, MediaURL, MediaType, Location, CreatedAt)
        INNER JOIN dbo.Users u ON u.Username = v.Username;
    END;

    /* Follows: deterministic sample network. */
    IF NOT EXISTS (SELECT 1 FROM dbo.Follows)
    BEGIN
        INSERT dbo.Follows (FollowerID, FollowedID, FollowedAt, Status)
        SELECT a.UserID, b.UserID, DATEADD(DAY, n.DayOffset, CAST('2026-03-01' AS DATETIME2(0))), 'Accepted'
        FROM (VALUES
            (N'alex.photo', N'maria.fit', 0),(N'alex.photo', N'georgi.dev', 1),(N'alex.photo', N'eli.art', 2),
            (N'maria.fit', N'alex.photo', 0),(N'maria.fit', N'simona.food', 2),(N'maria.fit', N'anna.runner', 4),
            (N'georgi.dev', N'ivan.tech', 1),(N'georgi.dev', N'petar.gaming', 3),(N'georgi.dev', N'iva.design', 5),
            (N'eli.art', N'iva.design', 0),(N'eli.art', N'plamena.photo', 3),(N'eli.art', N'victoria.books', 5),
            (N'nikola.travels', N'kristina.travel', 0),(N'nikola.travels', N'martin.outdoors', 2),(N'nikola.travels', N'alex.photo', 4),
            (N'simona.food', N'boris.cooks', 1),(N'simona.food', N'maria.fit', 3),(N'simona.food', N'desi.plants', 5),
            (N'petar.gaming', N'georgi.dev', 0),(N'petar.gaming', N'ivan.tech', 2),(N'petar.gaming', N'daniel.music', 4),
            (N'iva.design', N'eli.art', 0),(N'iva.design', N'teodor.urban', 2),(N'iva.design', N'raya.dance', 4),
            (N'daniel.music', N'hristo.cinema', 0),(N'daniel.music', N'raya.dance', 2),(N'daniel.music', N'iva.design', 4),
            (N'victoria.books', N'hristo.cinema', 0),(N'victoria.books', N'eli.art', 2),(N'victoria.books', N'plamena.photo', 4),
            (N'martin.outdoors', N'nikola.travels', 0),(N'martin.outdoors', N'alex.photo', 2),(N'martin.outdoors', N'anna.runner', 4),
            (N'plamena.photo', N'alex.photo', 0),(N'plamena.photo', N'teodor.urban', 2),(N'plamena.photo', N'eli.art', 4),
            (N'boris.cooks', N'simona.food', 0),(N'boris.cooks', N'maria.fit', 2),(N'boris.cooks', N'desi.plants', 4),
            (N'anna.runner', N'martin.outdoors', 0),(N'anna.runner', N'maria.fit', 2),(N'anna.runner', N'nikola.travels', 4),
            (N'hristo.cinema', N'daniel.music', 0),(N'hristo.cinema', N'victoria.books', 2),(N'hristo.cinema', N'plamena.photo', 4),
            (N'kristina.travel', N'nikola.travels', 0),(N'kristina.travel', N'alex.photo', 2),(N'kristina.travel', N'martin.outdoors', 4),
            (N'ivan.tech', N'georgi.dev', 0),(N'ivan.tech', N'petar.gaming', 2),(N'ivan.tech', N'iva.design', 4),
            (N'desi.plants', N'boris.cooks', 0),(N'desi.plants', N'simona.food', 2),(N'desi.plants', N'maria.fit', 4),
            (N'teodor.urban', N'plamena.photo', 0),(N'teodor.urban', N'iva.design', 2),(N'teodor.urban', N'kristina.travel', 4),
            (N'raya.dance', N'daniel.music', 0),(N'raya.dance', N'iva.design', 2),(N'raya.dance', N'maria.fit', 4)
        ) AS n(FollowerUsername, FollowedUsername, DayOffset)
        INNER JOIN dbo.Users a ON a.Username = n.FollowerUsername
        INNER JOIN dbo.Users b ON b.Username = n.FollowedUsername
        WHERE a.UserID <> b.UserID;
    END;

    /* Hashtags */
    IF NOT EXISTS (SELECT 1 FROM dbo.Hashtags WHERE TagName = N'travel')
    BEGIN
        INSERT dbo.Hashtags (TagName, CreatedAt)
        VALUES
        (N'travel', '2026-02-01'), (N'fitness', '2026-02-02'), (N'tech', '2026-02-03'),
        (N'art', '2026-02-04'), (N'food', '2026-02-05'), (N'gaming', '2026-02-06'),
        (N'music', '2026-02-07'), (N'books', '2026-02-08'), (N'nature', '2026-02-09'),
        (N'photography', '2026-02-10'), (N'plovdiv', '2026-02-11'), (N'design', '2026-02-12'),
        (N'citylife', '2026-02-13'), (N'cooking', '2026-02-14'), (N'dance', '2026-02-15');
    END;

    /* PostHashtags */
    IF NOT EXISTS (SELECT 1 FROM dbo.PostHashtags)
    BEGIN
        INSERT dbo.PostHashtags (PostID, HashtagID)
        SELECT p.PostID, h.HashtagID
        FROM (VALUES
            (N'alex.photo', N'travel'),(N'alex.photo', N'nature'),(N'alex.photo', N'photography'),
            (N'maria.fit', N'fitness'),(N'maria.fit', N'plovdiv'),
            (N'georgi.dev', N'tech'),(N'georgi.dev', N'design'),
            (N'eli.art', N'art'),(N'eli.art', N'design'),
            (N'nikola.travels', N'travel'),(N'nikola.travels', N'photography'),
            (N'simona.food', N'food'),(N'simona.food', N'cooking'),
            (N'petar.gaming', N'gaming'),(N'petar.gaming', N'tech'),
            (N'iva.design', N'design'),(N'iva.design', N'art'),
            (N'daniel.music', N'music'),(N'daniel.music', N'citylife'),
            (N'victoria.books', N'books'),
            (N'martin.outdoors', N'nature'),(N'martin.outdoors', N'travel'),
            (N'plamena.photo', N'photography'),(N'plamena.photo', N'art'),
            (N'boris.cooks', N'cooking'),(N'boris.cooks', N'food'),
            (N'anna.runner', N'fitness'),(N'anna.runner', N'nature'),
            (N'hristo.cinema', N'citylife'),(N'hristo.cinema', N'art'),
            (N'kristina.travel', N'travel'),(N'kristina.travel', N'plovdiv'),
            (N'ivan.tech', N'tech'),(N'ivan.tech', N'gaming'),
            (N'desi.plants', N'nature'),(N'desi.plants', N'photography'),
            (N'teodor.urban', N'citylife'),(N'teodor.urban', N'photography'),
            (N'raya.dance', N'dance'),(N'raya.dance', N'music')
        ) AS v(Username, TagName)
        INNER JOIN dbo.Users u ON u.Username = v.Username
        INNER JOIN dbo.Posts p ON p.UserID = u.UserID AND LEFT(p.Caption, 7) = N'[DEMO] '
        INNER JOIN dbo.Hashtags h ON h.TagName = v.TagName;
    END;

    /* Likes: patterned distribution across posts, excluding the author's own like. */
    IF NOT EXISTS (SELECT 1 FROM dbo.Likes)
    BEGIN
        INSERT dbo.Likes (UserID, PostID, LikedAt)
        SELECT u.UserID, p.PostID, DATEADD(MINUTE, (u.UserID * 7 + p.PostID * 13) % 1440, p.CreatedAt)
        FROM dbo.Users u
        CROSS JOIN dbo.Posts p
        WHERE LEFT(p.Caption, 7) = N'[DEMO] '
          AND u.UserID <> p.UserID
          AND ((u.UserID * 3 + p.PostID * 5) % 4) IN (0, 1);
    END;

    /* Comments */
    IF NOT EXISTS (SELECT 1 FROM dbo.Comments WHERE LEFT(CommentText, 7) = N'[DEMO] ')
    BEGIN
        INSERT dbo.Comments (PostID, UserID, CommentText, CreatedAt)
        SELECT p.PostID, u.UserID, v.CommentText, v.CreatedAt
        FROM (VALUES
            (N'alex.photo', N'maria.fit', N'[DEMO] Amazing view!', CAST('2026-03-01T08:00:00' AS DATETIME2(0))),
            (N'alex.photo', N'nikola.travels', N'[DEMO] Adding this place to my list.', CAST('2026-03-01T08:20:00' AS DATETIME2(0))),
            (N'maria.fit', N'anna.runner', N'[DEMO] Great consistency!', CAST('2026-03-02T09:00:00' AS DATETIME2(0))),
            (N'georgi.dev', N'ivan.tech', N'[DEMO] Nice setup. What keyboard is that?', CAST('2026-03-03T12:30:00' AS DATETIME2(0))),
            (N'eli.art', N'iva.design', N'[DEMO] Love the color palette.', CAST('2026-03-04T17:00:00' AS DATETIME2(0))),
            (N'nikola.travels', N'kristina.travel', N'[DEMO] Looks like a perfect weekend.', CAST('2026-03-05T19:00:00' AS DATETIME2(0))),
            (N'simona.food', N'boris.cooks', N'[DEMO] Recipe please!', CAST('2026-03-06T14:00:00' AS DATETIME2(0))),
            (N'petar.gaming', N'georgi.dev', N'[DEMO] What are the specs?', CAST('2026-03-07T20:30:00' AS DATETIME2(0))),
            (N'iva.design', N'eli.art', N'[DEMO] The layout is clean.', CAST('2026-03-08T12:00:00' AS DATETIME2(0))),
            (N'daniel.music', N'hristo.cinema', N'[DEMO] Great atmosphere.', CAST('2026-03-09T21:40:00' AS DATETIME2(0))),
            (N'victoria.books', N'eli.art', N'[DEMO] Adding this to my reading list.', CAST('2026-03-10T11:00:00' AS DATETIME2(0))),
            (N'martin.outdoors', N'nikola.travels', N'[DEMO] Which trail is this?', CAST('2026-03-11T09:45:00' AS DATETIME2(0))),
            (N'plamena.photo', N'teodor.urban', N'[DEMO] Beautiful tones.', CAST('2026-03-12T15:00:00' AS DATETIME2(0))),
            (N'boris.cooks', N'simona.food', N'[DEMO] That looks delicious.', CAST('2026-03-13T18:10:00' AS DATETIME2(0))),
            (N'anna.runner', N'maria.fit', N'[DEMO] Strong session!', CAST('2026-03-14T08:00:00' AS DATETIME2(0))),
            (N'hristo.cinema', N'daniel.music', N'[DEMO] This reminds me of a great soundtrack.', CAST('2026-03-15T16:00:00' AS DATETIME2(0))),
            (N'kristina.travel', N'alex.photo', N'[DEMO] I need to visit Plovdiv again.', CAST('2026-03-16T13:00:00' AS DATETIME2(0))),
            (N'ivan.tech', N'georgi.dev', N'[DEMO] Cable management goals.', CAST('2026-03-17T20:00:00' AS DATETIME2(0))),
            (N'desi.plants', N'boris.cooks', N'[DEMO] Green and peaceful.', CAST('2026-03-18T11:30:00' AS DATETIME2(0))),
            (N'raya.dance', N'daniel.music', N'[DEMO] Great energy!', CAST('2026-03-20T21:00:00' AS DATETIME2(0)))
        ) AS v(PostUsername, CommenterUsername, CommentText, CreatedAt)
        INNER JOIN dbo.Users pu ON pu.Username = v.PostUsername
        INNER JOIN dbo.Posts p ON p.UserID = pu.UserID AND LEFT(p.Caption, 7) = N'[DEMO] '
        INNER JOIN dbo.Users u ON u.Username = v.CommenterUsername;
    END;

    /* Stories: timestamps guarantee expiry occurs after creation. */
    IF NOT EXISTS (SELECT 1 FROM dbo.Stories)
    BEGIN
        INSERT dbo.Stories (UserID, MediaURL, MediaType, CreatedAt, ExpiresAt, IsArchived)
        SELECT u.UserID, v.MediaURL, v.MediaType, v.CreatedAt, DATEADD(HOUR, 24, v.CreatedAt), 0
        FROM (VALUES
            (N'alex.photo', N'https://example.com/media/story01.jpg', 'Image', CAST('2026-03-20T08:00:00' AS DATETIME2(0))),
            (N'maria.fit', N'https://example.com/media/story02.mp4', 'Video', CAST('2026-03-20T09:00:00' AS DATETIME2(0))),
            (N'eli.art', N'https://example.com/media/story03.jpg', 'Image', CAST('2026-03-20T10:00:00' AS DATETIME2(0))),
            (N'nikola.travels', N'https://example.com/media/story04.mp4', 'Video', CAST('2026-03-20T11:00:00' AS DATETIME2(0))),
            (N'simona.food', N'https://example.com/media/story05.jpg', 'Image', CAST('2026-03-20T12:00:00' AS DATETIME2(0))),
            (N'iva.design', N'https://example.com/media/story06.jpg', 'Image', CAST('2026-03-20T13:00:00' AS DATETIME2(0))),
            (N'daniel.music', N'https://example.com/media/story07.mp4', 'Video', CAST('2026-03-20T14:00:00' AS DATETIME2(0))),
            (N'martin.outdoors', N'https://example.com/media/story08.jpg', 'Image', CAST('2026-03-20T15:00:00' AS DATETIME2(0))),
            (N'anna.runner', N'https://example.com/media/story09.mp4', 'Video', CAST('2026-03-20T16:00:00' AS DATETIME2(0))),
            (N'teodor.urban', N'https://example.com/media/story10.jpg', 'Image', CAST('2026-03-20T17:00:00' AS DATETIME2(0)))
        ) AS v(Username, MediaURL, MediaType, CreatedAt)
        INNER JOIN dbo.Users u ON u.Username = v.Username;
    END;

    /* Messages */
    IF NOT EXISTS (SELECT 1 FROM dbo.Messages)
    BEGIN
        INSERT dbo.Messages (SenderID, ReceiverID, MessageText, SentAt, IsRead)
        SELECT s.UserID, r.UserID, v.MessageText, v.SentAt, v.IsRead
        FROM (VALUES
            (N'alex.photo', N'nikola.travels', N'Hey, where was that mountain photo taken?', CAST('2026-03-20T09:00:00' AS DATETIME2(0)), 1),
            (N'nikola.travels', N'alex.photo', N'Near the Rila Lakes trail.', CAST('2026-03-20T09:05:00' AS DATETIME2(0)), 1),
            (N'maria.fit', N'anna.runner', N'Are you running this weekend?', CAST('2026-03-20T10:00:00' AS DATETIME2(0)), 0),
            (N'anna.runner', N'maria.fit', N'Yes, on Sunday morning.', CAST('2026-03-20T10:10:00' AS DATETIME2(0)), 1),
            (N'georgi.dev', N'ivan.tech', N'Can you recommend a GPU?', CAST('2026-03-20T11:00:00' AS DATETIME2(0)), 0),
            (N'ivan.tech', N'georgi.dev', N'Depends on your budget and resolution.', CAST('2026-03-20T11:15:00' AS DATETIME2(0)), 1),
            (N'simona.food', N'boris.cooks', N'Send me your bread recipe.', CAST('2026-03-20T12:00:00' AS DATETIME2(0)), 0),
            (N'boris.cooks', N'simona.food', N'I will write it down tonight.', CAST('2026-03-20T12:20:00' AS DATETIME2(0)), 0),
            (N'eli.art', N'iva.design', N'Can you review my latest illustration?', CAST('2026-03-20T13:00:00' AS DATETIME2(0)), 1),
            (N'iva.design', N'eli.art', N'Sure, I will send feedback later.', CAST('2026-03-20T13:30:00' AS DATETIME2(0)), 0),
            (N'daniel.music', N'hristo.cinema', N'Found a great live show next month.', CAST('2026-03-20T14:00:00' AS DATETIME2(0)), 1),
            (N'hristo.cinema', N'daniel.music', N'Send me the event details.', CAST('2026-03-20T14:05:00' AS DATETIME2(0)), 0)
        ) AS v(SenderUsername, ReceiverUsername, MessageText, SentAt, IsRead)
        INNER JOIN dbo.Users s ON s.Username = v.SenderUsername
        INNER JOIN dbo.Users r ON r.Username = v.ReceiverUsername;
    END;

    /* PostViews: multiple viewing events per post make analytics meaningful. */
    IF NOT EXISTS (SELECT 1 FROM dbo.PostViews)
    BEGIN
        INSERT dbo.PostViews (UserID, PostID, ViewedAt, WatchDurationSeconds)
        SELECT u.UserID, p.PostID,
               DATEADD(MINUTE, (u.UserID * 11 + p.PostID * 17) % 10000, p.CreatedAt),
               (u.UserID * 13 + p.PostID * 7) % 91
        FROM dbo.Users u
        CROSS JOIN dbo.Posts p
        WHERE LEFT(p.Caption, 7) = N'[DEMO] '
          AND u.UserID <> p.UserID
          AND ((u.UserID + p.PostID * 2) % 3) = 0;
    END;

    COMMIT TRANSACTION;
    PRINT 'Synthetic demonstration data inserted successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

/* Summary: run after seeding to confirm row counts. */
SELECT 'Users' AS TableName, COUNT_BIG(*) AS [RowCount] FROM dbo.Users
UNION ALL SELECT 'Posts', COUNT_BIG(*) FROM dbo.Posts
UNION ALL SELECT 'Follows', COUNT_BIG(*) FROM dbo.Follows
UNION ALL SELECT 'Likes', COUNT_BIG(*) FROM dbo.Likes
UNION ALL SELECT 'Comments', COUNT_BIG(*) FROM dbo.Comments
UNION ALL SELECT 'Hashtags', COUNT_BIG(*) FROM dbo.Hashtags
UNION ALL SELECT 'PostHashtags', COUNT_BIG(*) FROM dbo.PostHashtags
UNION ALL SELECT 'Stories', COUNT_BIG(*) FROM dbo.Stories
UNION ALL SELECT 'Messages', COUNT_BIG(*) FROM dbo.Messages
UNION ALL SELECT 'PostViews', COUNT_BIG(*) FROM dbo.PostViews
ORDER BY TableName;
GO
