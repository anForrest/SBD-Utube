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

/*
Zapytanie 1
Mozliwe problemy:
full table scan na rating, appusers, comments, movie
HASH JOIN (3 poziomy): movie-comments, comments-appuser, movie-rating
GROUP BY, SORT ORDER BY na dużej liczbie rekordów
Comments - bardzo duża tabela (dużo JOINów)
brak indeksów na Comments.MovieId, Comments.UserId, Rating.MovieId

Najwiekszy bottleneck:
Comments + Rating (FULL SCAN + JOIN)
*/

/*
Zapytanie 2
Mozliwe problemy:
full table scan
Subquery z GROUP BY + HAVING
FILTER (HAVING AVG(RATE))
Brak indeksu Rating.MovieId, WatchHistory.MovieId, IsDeleted

Njwiekszy bottleneck: subquery na Rating + FULL SCAN Movie

Przyczyny:
filtracja dopiero po JOIN
subquery materializowane
sortowanie ORDER BY WatchCount
*/

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

// Mimo utworzenia indeksów, Oracle nie zdecydował się na ich wykorzystanie w zapytaniu, ponieważ koszt pełnych skanów tabel był niższy niż koszt dostępu indeksowego przy dużej liczbie rekordów. Plan wykonania nadal opiera się na FULL TABLE SCAN oraz HASH JOIN
// Utworzenie indeksów nie wpłynęło na plan wykonania pierwszego zapytania, ponieważ jego charakter charakteryzuje się niską selektywnością oraz dużą liczbą zwracanych rekordów. W takich przypadkach optymalizator Oracle preferuje pełne skanowanie tabel (FULL TABLE SCAN) oraz operacje HASH JOIN, które są bardziej efektywne niż wykorzystanie indeksów B-tree. Indeksy nie zostały użyte, ponieważ nie zmniejszałyby istotnie liczby przetwarzanych wierszy.

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

// W drugim zapytaniu Oracle wykorzystał indeksy bitmapowe na kolumnach Status oraz IsDeleted, co pozwoliło na wcześniejszą filtrację danych w tabeli Movie. Dzięki temu zmniejszono liczbę wierszy przekazywanych do dalszych operacji JOIN. Natomiast w podzapytaniu dotyczącym tabeli Rating nadal występuje pełne skanowanie tabeli, ponieważ operacja agregacji (GROUP BY + AVG) nie sprzyja wykorzystaniu indeksów B-tree.

/*Porównanie planów wykonania wykazało częściową poprawę wydajności tylko w zapytaniu drugim.*/

// Zadanie 6, 7

// Usuwamy IN, zamieniamy na JOIN do wcześniej agregowanej tabeli, wymuszamy lepsze użycie indeksu composite Rating(MovieId, Rate)
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

// W porównaniu do wcześniejszej wersji zapytania, w zmodyfikowanym planie wykonania Oracle wykorzystał indeksy bitmapowe na kolumnach Status oraz IsDeleted, co zastąpiło wcześniejsze pełne skanowanie tabeli Movie. Dzięki temu filtracja danych odbywa się na poziomie indeksów, co zmniejsza liczbę wierszy przekazywanych do operacji JOIN. Dodatkowo struktura zapytania została uproszczona poprzez zastąpienie operatora IN konstrukcją JOIN, co poprawiło czytelność planu wykonania i umożliwiło lepszą optymalizację.

// Oracle nie robi FULL TABLE SCAN Movie, filtruje dane już na poziomie indeksów, łączy warunki bitmapowo (AND)





