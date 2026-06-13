//bloki anonimowe zapełniajace tabele przykładowymi danymi

// Utworzenie 500 użytkowników
BEGIN
    FOR i IN 1..500 LOOP
        INSERT INTO APPUSERS
        (
            ID,
            USERNAME,
            EMAIL,
            PASSWORDHASH,
            USERROLE,
            ISBLOCKED,
            FAILEDLOGINATTEMPTS,
            CREATEDAT,
            UPDATEDAT
        )
        VALUES
        (
            SEQ_APPUSERS.NEXTVAL,
            'user' || i,
            'user' || i || '@mail.com',
            'hash' || i,
            'USER',
            0,
            0,
            SYSDATE,
            SYSDATE
        );
    END LOOP;

    COMMIT;
END;
/

// Utworzenie profilow użytkowników
BEGIN
    FOR i IN 1..500 LOOP
        INSERT INTO USERPROFILE
        (
            ID,
            USERID,
            FIRSTNAME,
            LASTNAME,
            BIRTHDATE,
            AVATARURL
        )
        VALUES
        (
            SEQ_USERPROFILE.NEXTVAL,
            i,
            'Name' || i,
            'Surname' || i,
            DATE '1995-01-01' + i * 100,
            'https://avatar.com/' || i
        );
    END LOOP;

    COMMIT;
END;
/

// Kategorie filmów
BEGIN
    FOR i IN 1..500 LOOP
        INSERT INTO CATEGORYTYPE
        (
            ID,
            CategoryName
        )
        VALUES
        (
            seq_categorytype.NEXTVAL,
            'CategoryName' || i
        );
    END LOOP;

    COMMIT;
END;
/

// Filmy
BEGIN
    FOR i IN 1..900 LOOP
        INSERT INTO MOVIE
        (
            ID,
            TITLE,
            MOVIEDESCRIPTION,
            RELEASEDATE,
            THUMBNAILURL,
            VIDEOURL,
            STATUS,
            ISDELETED,
            CREATEDAT,
            UPDATEDAT
        )
        VALUES
        (
            SEQ_MOVIE.NEXTVAL,
            'Film ' || i,
            'Opis filmu ' || i,
            SYSDATE - DBMS_RANDOM.VALUE(0,1000),
            'https://picsum.photos/300/200?random=' || i,
            'https://www.youtube.com/watch?v=movie' || i,
            'ACTIVE',
            0,
            SYSDATE,
            SYSDATE
        );
    END LOOP;

    COMMIT;
END;
/

// Oceny
BEGIN
    FOR i IN 1..1000 LOOP
        INSERT INTO RATING
        (
            ID,
            USERID,
            MOVIEID,
            RATE
        )
        VALUES
        (
            SEQ_RATING.NEXTVAL,
            MOD(i,10)+1,
            MOD(i,20)+1,
            TRUNC(DBMS_RANDOM.VALUE(1,6))
        );
    END LOOP;

    COMMIT;
END;
/

// Komentarze
BEGIN
    FOR i IN 1..600 LOOP
        INSERT INTO COMMENTS
        (
            ID,
            USERID,
            MOVIEID,
            COMMENTCONTENT,
            CREATEDAT,
            UPDATEDAT
        )
        VALUES
        (
            SEQ_COMMENT.NEXTVAL,
            MOD(i,10)+1,
            MOD(i,20)+1,
            'Komentarz nr ' || i,
            SYSDATE,
            SYSDATE
        );
    END LOOP;

    COMMIT;
END;
/

// Playlist
BEGIN
    FOR i IN 1..500 LOOP
        INSERT INTO Playlist (Id, UserId, Title, CreatedAt)
        VALUES (seq_playlist.NEXTVAL, TRUNC(DBMS_RANDOM.VALUE(1, 501)), 
                'Playlist ' || i || 'My favorite movies', 
                SYSDATE - DBMS_RANDOM.VALUE(0, 365));
    END LOOP;
    
    COMMIT;
END;
/

// Historia ogłądania
BEGIN
    FOR i IN 1..1000 LOOP
        INSERT INTO WATCHHISTORY
        (
            ID,
            USERID,
            MOVIEID,
            WATCHEDAT
        )
        VALUES
        (
            SEQ_WATCHHISTORY.NEXTVAL,
            MOD(i,10)+1,
            MOD(i,20)+1,
            SYSDATE - DBMS_RANDOM.VALUE(0,365)
        );
    END LOOP;

    COMMIT;
END;
/

// Movie i Category
DECLARE
    TYPE t_cat_ids IS TABLE OF CategoryType.Id%TYPE INDEX BY PLS_INTEGER;
    v_cat_ids t_cat_ids;
    v_movie_id Movie.Id%TYPE;
    v_cat1 NUMBER;
    v_cat2 NUMBER;
    v_cat3 NUMBER;
    v_count NUMBER;
BEGIN
    SELECT Id BULK COLLECT INTO v_cat_ids FROM CategoryType;
    
    IF v_cat_ids.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Brak kategorii w tabeli CategoryType!');
    END IF;

    DELETE FROM MovieCategory;
    
    FOR rec IN (SELECT Id FROM Movie) LOOP
        v_movie_id := rec.Id;

        LOOP
            v_cat1 := v_cat_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_cat_ids.COUNT + 1)));
            v_cat2 := v_cat_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_cat_ids.COUNT + 1)));
            v_cat3 := v_cat_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_cat_ids.COUNT + 1)));
            EXIT WHEN v_cat1 != v_cat2 AND v_cat1 != v_cat3 AND v_cat2 != v_cat3;
        END LOOP;
        
        -- Trzy powiązania
        INSERT INTO MovieCategory (MovieId, CategoryId) VALUES (v_movie_id, v_cat1);
        INSERT INTO MovieCategory (MovieId, CategoryId) VALUES (v_movie_id, v_cat2);
        INSERT INTO MovieCategory (MovieId, CategoryId) VALUES (v_movie_id, v_cat3);
    END LOOP;
    
    COMMIT;
END;
/



