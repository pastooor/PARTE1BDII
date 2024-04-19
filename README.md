# CASSANDRA

1. Diseña una base de datos Cassandra para dar servicio a las lecturas y escrituras
anteriores. Argumenta tus decisiones de diseño.

Para esta tarea hemos pensado en realizar tres tablas, a continuación la explicación y justificación de ellas:

Tabla hall_of_fame:

    country TEXT,
    dungeon_id INT,
    dungeon_name TEXT,
    email TEXT,
    user_name TEXT,
    time_minutes INT,
    date TIMESTAMP,
    PRIMARY KEY ((country, dungeon_id), time_minutes, date)

  Justificación:
  
 - La clave primaria formada por ((country, dungeon_id), time_minutes, date), se ha diseñado de esta manera para poder acceder de manera adecuada a cada país y dungeon. Además hemos añadido la variable time_minutes, ya que luego la necesitaremos en las consultas de lectura para ordenarlos de menor a mayor, y la variable date, ya que son valores únicos.

Tabla user_statistics:

    email TEXT,
    dungeon_id INT,
    time_minutes INT,
    date TIMESTAMP,
    PRIMARY KEY ((email, dungeon_id), time_minutes, date)

Justificación:

- La clave primaria formada por ((email, dungeon_id), time_minutes, date), se ha diseñado de esta manera para acceder de manera adecuada a cada usuario y dungeon. Además hemos añadido la variable time_minutes, ya que luego la necesitaremos en las consultas de lectura para ordenarlos de menor a mayor, y la variable date, ya que son valores únicos.

Tabla top_horde:

    country TEXT,
    event_id INT,
    email TEXT,
    user_name TEXT,
    n_kills COUNTER,
    PRIMARY KEY ((country, event_id), user_name, email))

Justificación:

- La clave primaria formada por ((country, event_id), user_name, email)), se ha diseñado de esta manera para acceder de manera adecuada a cada país y horda. Además hemos añadido la variable user_name y la variable email, ya que hemos creado la variable n_kills de tipo COUNTER, que será nuestro contador de kills, y para que funcione la tabla tienes que meter de clave primaria a todos los valores de la tabla menos el de tipo COUNTER.

2. Crea las consultas .sql necesarias para exportar los datos de la base de datos
relacional a ficheros .csv. Los ficheros deberán tener un formato acorde al diseño
del punto 1.

3. Prepara un cluster local de 3 nodos todos en el mismo rack y datacenter.

Esta tarea está realizada en el docker-compose.yml, que esta dentro de esta carpeta



    
