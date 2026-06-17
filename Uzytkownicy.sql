CREATE USER app_admin IDENTIFIED BY admin123;
CREATE USER app_identity IDENTIFIED BY app123;
CREATE USER dev1 IDENTIFIED BY dev123;

-- Możliwość zalogowania dla użytkowników
GRANT CREATE SESSION TO app_admin;
GRANT CREATE SESSION TO app_identity;
GRANT CREATE SESSION TO dev1;

-- ROLES

CREATE ROLE utube_admin;
CREATE ROLE utube_user;
CREATE ROLE db_procexecutor;

-- UTUBE_ADMIN PERMISSIONS

GRANT SELECT, INSERT, UPDATE, DELETE ON AppUsers TO utube_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Movie TO utube_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Comments TO utube_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Rating TO utube_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Playlist TO utube_admin;

-- UTUBE_USER PERMISSIONS 
-- usuwanie i edytowanie dla USER w ASP.NET albo dodać poprzez procedury

GRANT SELECT ON Movie TO utube_user;
GRANT SELECT, INSERT ON Comments TO utube_user;
GRANT SELECT, INSERT ON Rating TO utube_user;
GRANT SELECT, INSERT ON Playlist TO utube_user;


-- procedury
GRANT EXECUTE ON sp_add_movie TO db_procexecutor;
GRANT EXECUTE ON sp_create_playlist TO db_procexecutor;

-- APP
GRANT SELECT, INSERT, UPDATE, DELETE ON Movie TO app_identity;
GRANT SELECT, INSERT, UPDATE, DELETE ON Rating TO app_identity;
GRANT SELECT, INSERT, UPDATE, DELETE ON Comments TO app_identity;

GRANT db_procexecutor TO app_identity;

-- DEV (READ ONLY)
GRANT SELECT ON Movie TO dev1;
GRANT SELECT ON Rating TO dev1;

-- ADMIN
GRANT DBA TO app_admin;

-- AUDYT
AUDIT SELECT ON Movie;
AUDIT INSERT ON Movie;
AUDIT UPDATE ON Movie;
AUDIT DELETE ON Movie;

AUDIT INSERT ON Rating;
AUDIT INSERT ON Comments;

-- LOGI
SELECT * FROM USER_AUDIT_TRAIL;
