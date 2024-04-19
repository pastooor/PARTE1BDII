SELECT wu.country, cd.idD AS dungeon_id, d.name AS dungeon_name, cd.email, wu.userName AS user_name, cd.time AS time_minutes, cd.date
INTO OUTFILE '/var/lib/mysql-files/hall_of_fame.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'FROM WebUser wu
INNER JOIN CompletedDungeons cd ON wu.email = cd.email
INNER JOIN Dungeon d ON cd.idD = d.idD;

SELECT cd.email AS user_id, cd.idD AS dungeon_id, cd.time AS time_minutes, cd.date
INTO OUTFILE '/var/lib/mysql-files/user_statistics.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
FROM CompletedDungeons cd;

SELECT wu.country, k.idE, k.email, wu.userName, COUNT(*) AS n_killsç
INTO OUTFILE '/var/lib/mysql-files/top_horde.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
FROM Kills k 
INNER JOIN  WebUser wu ON wu.email = k.email
GROUP BY k.email, k.idE

