USE video_game;

-- Lectura en la tabla hall_of_fame con nivel de consistencia ONE

SELECT dungeon_id, dungeon_name, email, user_name, time_minutes, date
FROM hall_of_fame
WHERE country = 'es_ES' and dungeon_id = 0
ORDER BY time_minutes ASC
LIMIT 5;

-- Lectura en la tabla user_statistics con nivel de consistencia ONE

SELECT time_minutes, date
FROM user_statistics
WHERE email = 'begonavera@example.net'
    AND dungeon_id = 0
ORDER BY time_minutes ASC;

-- Lectura en la tabla top_horde con nivel de consistencia ONE

SELECT email, user_name, n_kills
FROM top_horde
WHERE country = 'es_ES'
    AND event_id = 1
LIMIT 3;

-- Escritura en la tabla hall_of_fame y user_statistics con nivel de consistencia ONE

BEGIN BATCH
    -- Insertar datos en la tabla hall_of_fame
    INSERT INTO hall_of_fame (country, dungeon_id, email, time_minutes, date)
    VALUES ('es_ES', 0, 'jorge.pastor.velasco@gmail.com', 0, toTimestamp(now()));

    -- Insertar datos en la tabla user_statistics
    INSERT INTO user_statistics (email, dungeon_id, time_minutes, date)
    VALUES ('jorge.pastor.velasco@gmail.com', 0, 0, toTimestamp(now()));
APPLY BATCH;

-- Lectura en la tabla hall_of_fame con nivel de consistencia ONE

SELECT dungeon_id, dungeon_name, email, user_name, time_minutes, date
FROM hall_of_fame
WHERE country = 'es_ES' and dungeon_id = 0
ORDER BY time_minutes ASC
LIMIT 5;

-- Lectura en la tabla user_statistics con nivel de consistencia ONE

SELECT time_minutes, date
FROM user_statistics
WHERE email = 'jorge.pastor.velasco@gmail.com'
    AND dungeon_id = 0
ORDER BY time_minutes ASC;

--  Escritura en la tabla top_horde con nivel de consistencia ONE
UPDATE top_horde 
SET n_kills = n_kills + 1
WHERE country = 'es_ES' 
  AND event_id = 1 
  AND user_name = 'abarco' 
  AND email = 'pruano@example.org';

-- Lectura en la tabla top_horde con nivel de consistencia ONE
SELECT email, user_name, n_kills
FROM top_horde
WHERE country = 'es_ES'
    AND event_id = 1
LIMIT 3;