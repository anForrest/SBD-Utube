
-- SEQUENCES - do automatycznego generowania kolejnych numerów ID tabel

CREATE SEQUENCE seq_appusers START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_userprofile START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_movie START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_categorytype START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_comment START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_rating START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_playlist START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_external_description START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_logbook START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE seq_watchhistory START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_comment_history START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_movie_history START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_playlist_history START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_user_history START WITH 1 INCREMENT BY 1;



-- APP USERS

CREATE TABLE AppUsers (
    Id NUMBER PRIMARY KEY,
    Username VARCHAR2(50) UNIQUE NOT NULL,
    Email VARCHAR2(50) UNIQUE NOT NULL,
    PasswordHash VARCHAR2(255) NOT NULL,
    UserRole VARCHAR2(20) DEFAULT 'USER',
    IsBlocked NUMBER(1) DEFAULT 0,
    FailedLoginAttempts NUMBER DEFAULT 0,
    CreatedAt DATE DEFAULT SYSDATE,
    UpdatedAt DATE
);

CREATE OR REPLACE TRIGGER trg_users_id
BEFORE INSERT ON AppUsers
FOR EACH ROW
BEGIN
    :NEW.Id := seq_appusers.NEXTVAL;
END;
/


-- USER PROFILE

CREATE TABLE UserProfile (
    Id NUMBER PRIMARY KEY,
    UserId NUMBER UNIQUE,
    FirstName VARCHAR2(50),
    LastName VARCHAR2(50),
    BirthDate DATE,
    AvatarUrl VARCHAR2(500),

    CONSTRAINT fk_profile_user
        FOREIGN KEY (UserId)
        REFERENCES AppUsers(Id)
        ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_profile_id
BEFORE INSERT ON UserProfile
FOR EACH ROW
BEGIN
    :NEW.Id := seq_userprofile.NEXTVAL;
END;
/


-- MOVIE

CREATE TABLE Movie (
    Id NUMBER PRIMARY KEY,
    Title VARCHAR2(200) NOT NULL,
    MovieDescription CLOB, -- typ danych do przechowywania dużej ilości tekstu (do 4GB)
    ReleaseDate DATE,
    ThumbnailUrl VARCHAR2(500),
    VideoUrl VARCHAR2(500),
    Status VARCHAR2(20) DEFAULT 'ACTIVE',
    IsDeleted NUMBER(1) DEFAULT 0,   -- ?
    CreatedAt DATE DEFAULT SYSDATE,
    UpdatedAt DATE
);

CREATE OR REPLACE TRIGGER trg_movie_id
BEFORE INSERT ON Movie
FOR EACH ROW
BEGIN
    :NEW.Id := seq_movie.NEXTVAL;
END;
/


-- CATEGORY TYPE

CREATE TABLE CategoryType (
    Id NUMBER PRIMARY KEY,
    CategoryName VARCHAR2(50) UNIQUE NOT NULL
);

CREATE OR REPLACE TRIGGER trg_category_id
BEFORE INSERT ON CategoryType
FOR EACH ROW
BEGIN
    :NEW.Id := seq_categorytype.NEXTVAL;
END;
/


-- MOVIE CATEGORY - RELACJA MANY TO MANY

CREATE TABLE MovieCategory (
    MovieId NUMBER,
    CategoryId NUMBER,

    PRIMARY KEY (MovieId, CategoryId),

    CONSTRAINT fk_mc_movie
        FOREIGN KEY (MovieId)
        REFERENCES Movie(Id)
        ON DELETE CASCADE,

    CONSTRAINT fk_mc_category
        FOREIGN KEY (CategoryId)
        REFERENCES CategoryType(Id)
        ON DELETE CASCADE
);


-- COMMENTS

CREATE TABLE Comments (
    Id NUMBER PRIMARY KEY,
    UserId NUMBER NOT NULL,
    MovieId NUMBER NOT NULL,
    CommentContent CLOB NOT NULL,
    CreatedAt DATE DEFAULT SYSDATE,
    UpdatedAt DATE,

    CONSTRAINT fk_comment_user
        FOREIGN KEY (UserId)
        REFERENCES AppUsers(Id)
        ON DELETE CASCADE,

    CONSTRAINT fk_comment_movie
        FOREIGN KEY (MovieId)
        REFERENCES Movie(Id)
        ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_comment_id
BEFORE INSERT ON Comments
FOR EACH ROW
BEGIN
    :NEW.Id := seq_comment.NEXTVAL;
END;
/


-- RATING

CREATE TABLE Rating (
    Id NUMBER PRIMARY KEY,
    UserId NUMBER NOT NULL,
    MovieId NUMBER NOT NULL,
    Rate NUMBER NOT NULL,

    CONSTRAINT fk_rating_user
        FOREIGN KEY (UserId)
        REFERENCES AppUsers(Id)
        ON DELETE CASCADE,

    CONSTRAINT fk_rating_movie
        FOREIGN KEY (MovieId)
        REFERENCES Movie(Id)
        ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_rating_id
BEFORE INSERT ON Rating
FOR EACH ROW
BEGIN
    :NEW.Id := seq_rating.NEXTVAL;
END;
/


-- RATING VALIDATION

CREATE OR REPLACE TRIGGER trg_rating_validation
BEFORE INSERT OR UPDATE ON Rating
FOR EACH ROW
BEGIN
    IF :NEW.Rate < 1 OR :NEW.Rate > 10 THEN
        RAISE_APPLICATION_ERROR (
            -20001,
            'Rating must be between 1 and 10'
        );
    END IF;
END;
/


-- FAVORITE

CREATE TABLE Favorite (
    UserId NUMBER,
    MovieId NUMBER,
    CreatedAt DATE DEFAULT SYSDATE,

    PRIMARY KEY (UserId, MovieId),

    CONSTRAINT fk_favorite_user
        FOREIGN KEY (UserId)
        REFERENCES AppUsers(Id)
        ON DELETE CASCADE,

    CONSTRAINT fk_favorite_movie
        FOREIGN KEY (MovieId)
        REFERENCES Movie(Id)
        ON DELETE CASCADE
);


-- PLAYLIST

CREATE TABLE Playlist (
    Id NUMBER PRIMARY KEY,
    UserId NUMBER NOT NULL,
    Title VARCHAR2(255) NOT NULL,
    CreatedAt DATE DEFAULT SYSDATE,

    CONSTRAINT fk_playlist_user
        FOREIGN KEY (UserId)
        REFERENCES AppUsers(Id)
        ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_playlist_id
BEFORE INSERT ON Playlist
FOR EACH ROW
BEGIN
    :NEW.Id := seq_playlist.NEXTVAL;
END;
/


-- PLAYLIST MOVIE - many to many

CREATE TABLE PlaylistMovie (
    PlaylistId NUMBER,
    MovieId NUMBER,

    PRIMARY KEY (PlaylistId, MovieId),

    CONSTRAINT fk_pm_playlist
        FOREIGN KEY (PlaylistId)
        REFERENCES Playlist(Id)
        ON DELETE CASCADE,

    CONSTRAINT fk_pm_movie
        FOREIGN KEY (MovieId)
        REFERENCES Movie(Id)
        ON DELETE CASCADE
);


-- WATCH HISTORY

CREATE TABLE WatchHistory (
    Id NUMBER PRIMARY KEY,
    UserId NUMBER NOT NULL,
    MovieId NUMBER NOT NULL,
    WatchedAt DATE DEFAULT SYSDATE,

    CONSTRAINT fk_watch_user
        FOREIGN KEY (UserId)
        REFERENCES AppUsers(Id)
        ON DELETE CASCADE,

    CONSTRAINT fk_watch_movie
        FOREIGN KEY (MovieId)
        REFERENCES Movie(Id)
        ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_watchhistory_id
BEFORE INSERT ON WatchHistory
FOR EACH ROW
BEGIN
    :NEW.Id := seq_watchhistory.NEXTVAL;
END;
/


-- EXTERNAL DESCRIPTION 

CREATE TABLE ExternalDescription (
    Id NUMBER PRIMARY KEY,
    MovieId NUMBER NOT NULL,
    GeneratedDescription CLOB,
    GeneratedBy VARCHAR2(100),
    GeneratedAt DATE DEFAULT SYSDATE,

    CONSTRAINT fk_ext_movie
        FOREIGN KEY (MovieId)
        REFERENCES Movie(Id)
        ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_external_description_id
BEFORE INSERT ON ExternalDescription
FOR EACH ROW
BEGIN
    :NEW.Id := seq_external_description.NEXTVAL;
END;
/


-- LOG BOOK

CREATE TABLE LogBook (
    Id NUMBER PRIMARY KEY,
    UserId NUMBER,
    ActionType VARCHAR2(100),
    TableName VARCHAR2(100),
    ActionDate DATE DEFAULT SYSDATE
);


CREATE OR REPLACE TRIGGER trg_log_id
BEFORE INSERT ON LogBook
FOR EACH ROW
BEGIN
    :NEW.Id := seq_logbook.NEXTVAL;
END;
/



-- HISTORY TABLES

CREATE TABLE Comment_History (
    HistoryId NUMBER PRIMARY KEY,
    CommentId NUMBER,
    OldContent CLOB,
    ModifiedAt DATE
);

CREATE TABLE Movie_History (
    HistoryId NUMBER PRIMARY KEY,
    MovieId NUMBER,
    OldTitle VARCHAR2(200),
    OldDescription CLOB,
    ModifiedAt DATE
);

CREATE TABLE Playlist_History (
    HistoryId NUMBER PRIMARY KEY,
    PlaylistId NUMBER,
    OldTitle VARCHAR2(100),
    ModifiedAt DATE
);

CREATE TABLE User_History (
    HistoryId NUMBER PRIMARY KEY,
    UserId NUMBER,
    OldUsername VARCHAR2(50),
    OldEmail VARCHAR2(50),
    ModifiedAt DATE
);


-- COMMENT HISTORY TRIGGER

CREATE OR REPLACE TRIGGER trg_comment_history
AFTER UPDATE OR DELETE ON Comments
FOR EACH ROW
BEGIN
    INSERT INTO Comment_History ( HistoryId, CommentId, OldContent, ModifiedAt )
    VALUES ( seq_comment_history.NEXTVAL, :OLD.Id, :OLD.CommentContent, SYSDATE );
END;
/


-- MOVIE HISTORY TRIGGER

CREATE OR REPLACE TRIGGER trg_movie_history
AFTER UPDATE OR DELETE ON Movie
FOR EACH ROW
BEGIN
    INSERT INTO Movie_History ( HistoryId, MovieId, OldTitle, OldDescription, ModifiedAt )
    VALUES ( seq_movie_history.NEXTVAL, :OLD.Id, :OLD.Title, :OLD.MovieDescription, SYSDATE );
END;
/


-- PLAYLIST HISTORY TRIGGER

CREATE OR REPLACE TRIGGER trg_playlist_history
AFTER UPDATE OR DELETE ON Playlist
FOR EACH ROW
BEGIN
    INSERT INTO Playlist_History ( HistoryId, PlaylistId, OldTitle, ModifiedAt )
    VALUES ( seq_playlist_history.NEXTVAL, :OLD.Id, :OLD.Title, SYSDATE );
END;
/


-- USER HISTORY TRIGGER

CREATE OR REPLACE TRIGGER trg_user_history
AFTER UPDATE OR DELETE ON AppUsers
FOR EACH ROW
BEGIN
    INSERT INTO User_History ( HistoryId, UserId, OldUsername, OldEmail, ModifiedAt )
    VALUES ( seq_user_history.NEXTVAL, :OLD.Id, :OLD.Username, :OLD.Email, SYSDATE );
END;
/


-- VIEWS

CREATE OR REPLACE VIEW vw_movie_rating AS
SELECT m.Id, m.Title, ROUND(AVG(r.Rate), 2) AS AverageRating
FROM Movie m
LEFT JOIN Rating r
    ON m.Id = r.MovieId
GROUP BY m.Id, m.Title;

--

CREATE OR REPLACE VIEW vw_user_playlists AS
SELECT u.Username, p.Title AS PlaylistTitle
FROM AppUsers u
JOIN Playlist p
    ON u.Id = p.UserId;

--

CREATE OR REPLACE VIEW vw_popular_movies AS
SELECT m.Id, m.Title, COUNT(w.Id) AS WatchCount
FROM Movie m
LEFT JOIN WatchHistory w
    ON m.Id = w.MovieId
GROUP BY m.Id, m.Title
ORDER BY WatchCount DESC;

--

CREATE OR REPLACE VIEW vw_movie_comments AS
SELECT m.Title, u.Username, c.CommentContent, c.CreatedAt
FROM Comments c
JOIN AppUsers u
    ON c.UserId = u.Id
JOIN Movie m
    ON c.MovieId = m.Id;


-- FUNCTIONS

CREATE OR REPLACE FUNCTION fn_average_rating( p_movie_id NUMBER )
RETURN NUMBER
IS
    v_avg NUMBER;
BEGIN
    SELECT AVG(Rate) INTO v_avg
    FROM Rating
    WHERE MovieId = p_movie_id;

    RETURN NVL(v_avg, 0);
END;
/

--

CREATE OR REPLACE FUNCTION fn_user_watch_count( p_user_id NUMBER )
RETURN NUMBER
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM WatchHistory
    WHERE UserId = p_user_id;

    RETURN v_count;
END;
/

 -- Logowanie
CREATE OR REPLACE FUNCTION fn_login_user(
    p_login VARCHAR2,
    p_password VARCHAR2
)
RETURN NUMBER
IS
    v_id NUMBER;
BEGIN
    SELECT Id
    INTO v_id
    FROM AppUsers
    WHERE (Username = p_login OR Email = p_login)
      AND PasswordHash = p_password
      AND IsBlocked = 0;

    RETURN v_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

-- Rola uzytkownika
CREATE OR REPLACE FUNCTION fn_get_user_role(
    p_user_id NUMBER
)
RETURN VARCHAR2
IS
    v_role VARCHAR2(20);
BEGIN
    SELECT UserRole
    INTO v_role
    FROM AppUsers
    WHERE Id = p_user_id;

    RETURN v_role;
END;
/

-- PROCEDURES
CREATE OR REPLACE PROCEDURE sp_add_movie(
    p_title VARCHAR2,
    p_description CLOB,
    p_release_date DATE,
    p_thumbnail VARCHAR2,
    p_video VARCHAR2
)
IS
BEGIN
    INSERT INTO Movie
    (
        Id,
        Title,
        MovieDescription,
        ReleaseDate,
        ThumbnailUrl,
        VideoUrl
    )
    VALUES
    (
        seq_movie.NEXTVAL,
        p_title,
        p_description,
        p_release_date,
        p_thumbnail,
        p_video
    );

    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE sp_update_movie(
    p_movie_id NUMBER,
    p_title VARCHAR2,
    p_description CLOB,
    p_release_date DATE,
    p_thumbnail VARCHAR2,
    p_video VARCHAR2
)
IS
BEGIN
    UPDATE Movie
    SET
        Title = p_title,
        MovieDescription = p_description,
        ReleaseDate = p_release_date,
        ThumbnailUrl = p_thumbnail,
        VideoUrl = p_video,
        UpdatedAt = SYSDATE
    WHERE Id = p_movie_id;

    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE sp_delete_movie(
    p_movie_id NUMBER
)
IS
BEGIN
    DELETE FROM Movie
    WHERE Id = p_movie_id;

    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE sp_create_playlist(
    p_user_id NUMBER,
    p_title VARCHAR2
)
IS
BEGIN
    INSERT INTO Playlist (Id, UserId, Title)
    VALUES (seq_playlist.NEXTVAL, p_user_id, p_title);

    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE sp_update_playlist(
    p_playlist_id NUMBER,
    p_title VARCHAR2
)
IS
BEGIN
    UPDATE Playlist
    SET Title = p_title
    WHERE Id = p_playlist_id;

    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE sp_delete_playlist(
    p_playlist_id NUMBER
)
IS
BEGIN
    DELETE FROM Playlist
    WHERE Id = p_playlist_id;

    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE sp_add_comment(
    p_user_id NUMBER,
    p_movie_id NUMBER,
    p_content CLOB
)
IS
BEGIN
    INSERT INTO Comments
    (
        Id,
        UserId,
        MovieId,
        CommentContent
    )
    VALUES
    (
        seq_comment.NEXTVAL,
        p_user_id,
        p_movie_id,
        p_content
    );

    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE sp_update_comment(
    p_comment_id NUMBER,
    p_content CLOB
)
IS
BEGIN
    UPDATE Comments
    SET
        CommentContent = p_content,
        UpdatedAt = SYSDATE
    WHERE Id = p_comment_id;

    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE sp_delete_comment(
    p_comment_id NUMBER
)
IS
BEGIN
    DELETE FROM Comments
    WHERE Id = p_comment_id;

    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE sp_add_movie_to_playlist(
    p_playlist_id NUMBER,
    p_movie_id NUMBER
)
IS
BEGIN
    INSERT INTO PlaylistMovie
    (
        PlaylistId,
        MovieId
    )
    VALUES
    (
        p_playlist_id,
        p_movie_id
    );

    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE sp_remove_movie_from_playlist(
    p_playlist_id NUMBER,
    p_movie_id NUMBER
)
IS
BEGIN
    DELETE FROM PlaylistMovie
    WHERE PlaylistId = p_playlist_id
      AND MovieId = p_movie_id;

    COMMIT;
END;
/

COMMIT;


