-- bloki anonimowe zapełniajace tabele przykładowymi danymi

-- Utworzenie 500 użytkowników i profili użytkowników
BEGIN
    FOR i IN 1..500 LOOP
        INSERT INTO APPUSERS
        (
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
            'user' || i,
            'user' || i || '@mail.com',
            'hash' || i,
            'USER',
            0,
            0,
            SYSDATE,
            SYSDATE
        );

        INSERT INTO USERPROFILE
        (
            USERID,
            FIRSTNAME,
            LASTNAME,
            BIRTHDATE,
            AVATARURL
        )
        VALUES
        (
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



-- Kategorie filmów
BEGIN
    FOR i IN 1..500 LOOP
        INSERT INTO CATEGORYTYPE
        (
            CategoryName
        )
        VALUES
        (
            'CategoryName' || i
        );
    END LOOP;

    COMMIT;
END;
/


-- Filmy
BEGIN
    FOR i IN 1..900 LOOP

        sp_add_movie
        (
            'Film ' || i,
            'Opis filmu ' || i,
            SYSDATE - DBMS_RANDOM.VALUE(0,1000),
            'https://picsum.photos/300/200?random=' || i,
            'https://www.youtube.com/watch?v=movie' || i,
        );

    END LOOP;

    COMMIT;
END;
/


-- Oceny
BEGIN
    FOR i IN 1..1000 LOOP

        sp_add_rating
        (
            MOD(i, 500)+1,
            MOD(i, 900)+1,
            TRUNC(DBMS_RANDOM.VALUE(1,11))
        );

    END LOOP;

    COMMIT;
END;
/


-- Komentarze
BEGIN
    FOR i IN 1..600 LOOP

        sp_add_comment
        (
            MOD(i,500)+1,
            MOD(i,900)+1,
            'Komentarz nr ' || i
        );

    END LOOP;

    COMMIT;
END;
/


-- Playlist
BEGIN
    FOR i IN 1..500 LOOP

        sp_create_playlist 
        (
            TRUNC(DBMS_RANDOM.VALUE(1, 501)), 
            'Playlista ' || i
        );

    END LOOP;
    
    COMMIT;
END;
/


-- Historia oglądania
BEGIN
    FOR i IN 1..1000 LOOP
        INSERT INTO WATCHHISTORY
        (
            USERID,
            MOVIEID,
            WATCHEDAT
        )
        VALUES
        (
            MOD(i,10)+1,
            MOD(i,20)+1,
            SYSDATE - DBMS_RANDOM.VALUE(0,365)
        );
    END LOOP;

    COMMIT;
END;
/


-- Movie i CategoryType
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



