CREATE KEYSPACE IF NOT EXISTS video_game WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 2};

USE video_game;

CREATE TABLE IF NOT EXISTS hall_of_fame (
    country TEXT,
    dungeon_id INT,
    dungeon_name TEXT,
    email TEXT,
    user_name TEXT,
    time_minutes INT,
    date TIMESTAMP,
    PRIMARY KEY ((country, dungeon_id), time_minutes, date)
);

CREATE TABLE IF NOT EXISTS user_statistics (
    email TEXT,
    dungeon_id INT,
    time_minutes INT,
    date TIMESTAMP,
    PRIMARY KEY ((email, dungeon_id), time_minutes, date)
);

CREATE TABLE IF NOT EXISTS top_horde (
    country TEXT,
    event_id INT,
    email TEXT,
    user_name TEXT,
    n_kills COUNTER,
    PRIMARY KEY ((country, event_id), user_name, email));

COPY hall_of_fame(country, dungeon_id, dungeon_name, email, user_name, time_minutes, date) FROM 'var/lib/cassandra/hall_of_fame.csv';
COPY user_statistics(email, dungeon_id, time_minutes, date) FROM 'var/lib/cassandra/user_statistics.csv';
COPY top_horde(country, event_id, email, user_name, n_kills) FROM 'var/lib/cassandra/top_Horde.csv';