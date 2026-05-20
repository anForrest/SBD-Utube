Dotychczasowo jest:

TABLE : 
AppUsers, UserProfile, Movie, CategoryType, MovieCategory, Comments, Rating, Favorite, Playlist, PlaylistMovie, WatchHistory, ExternalDescription, LogBook, Comment_History, Movie_History, Playlist_History, User_History

FOREIGN KEY CONSTRAINTS

SEQUENCES dla tych tabel które potrzebują Id i TRIGGERS wstawiające kolejne id przed INSERT dla tych tabel

Dodatkowe TRIGGERS :
trg_rating_validation - upewnia się że rating należy do zbioru <1; 10>

VIEWS :
vw_movie_rating, vw_user_playlists, vw_popular_movies, vw_movie_comments

FUNCTIONS :
fn_average_rating, fn_user_watch_count

PROCEDURES :
sp_add_movie, sp_create_playlist

ROLES :
UTUBE_ADMIN, UTUBE_USER
