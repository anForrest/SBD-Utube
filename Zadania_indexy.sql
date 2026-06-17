// Zapytanie 1
EXPLAIN PLAN FOR
SELECT 
    m.Title,
    u.Username,
    COUNT(c.Id) AS CommentCount,
    AVG(r.Rate) AS AvgRating
FROM Movie m
JOIN Comments c ON m.Id = c.MovieId
JOIN AppUsers u ON c.UserId = u.Id
LEFT JOIN Rating r ON m.Id = r.MovieId
GROUP BY m.Title, u.Username
ORDER BY AvgRating DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

// Zapytanie 2
EXPLAIN PLAN FOR
SELECT 
    m.Id,
    m.Title,
    COUNT(w.Id) AS WatchCount
FROM Movie m
LEFT JOIN WatchHistory w ON m.Id = w.MovieId
WHERE 
    m.Status = 'ACTIVE'
    AND (m.IsDeleted = 0 OR m.IsDeleted IS NULL)
    AND m.Id IN (
        SELECT MovieId
        FROM Rating
        GROUP BY MovieId
        HAVING AVG(Rate) >= 7
    )
GROUP BY m.Id, m.Title
ORDER BY WatchCount DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


// Indexy B-tree(Join optimization)
CREATE INDEX idx_comments_movie ON Comments(MovieId);
CREATE INDEX idx_comments_user ON Comments(UserId);
CREATE INDEX idx_rating_movie ON Rating(MovieId);

// Bitmap(status filmow)
CREATE BITMAP INDEX idx_movie_status ON Movie(Status);
CREATE BITMAP INDEX idx_movie_deleted ON Movie(IsDeleted);

// Composite
CREATE INDEX idx_rating_movie_rate ON Rating(MovieId, Rate);


// Ponownie plany

// 1
EXPLAIN PLAN FOR
SELECT 
    m.Title,
    u.Username,
    COUNT(c.Id),
    AVG(r.Rate)
FROM Movie m
JOIN Comments c ON m.Id = c.MovieId
JOIN AppUsers u ON c.UserId = u.Id
LEFT JOIN Rating r ON m.Id = r.MovieId
GROUP BY m.Title, u.Username;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


// 2
EXPLAIN PLAN FOR
SELECT 
    m.Id,
    m.Title,
    COUNT(w.Id)
FROM Movie m
LEFT JOIN WatchHistory w ON m.Id = w.MovieId
WHERE 
    m.Status = 'ACTIVE'
    AND m.IsDeleted = 0
    AND m.Id IN (
        SELECT MovieId
        FROM Rating
        GROUP BY MovieId
        HAVING AVG(Rate) >= 7
    )
GROUP BY m.Id, m.Title;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


/*Porównanie planów wykonania wykazało częściową poprawę wydajności tylko w zapytaniu drugim.*/

// Zadanie 6, 7

// Usuwamy IN, zamieniamy na JOIN
EXPLAIN PLAN FOR
SELECT 
    m.Id,
    m.Title,
    COUNT(w.Id)
FROM Movie m
JOIN (
    SELECT MovieId
    FROM Rating
    GROUP BY MovieId
    HAVING AVG(Rate) >= 7
) r ON r.MovieId = m.Id
LEFT JOIN WatchHistory w ON w.MovieId = m.Id
WHERE 
    m.Status = 'ACTIVE'
    AND m.IsDeleted = 0
GROUP BY m.Id, m.Title;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);





