# CASSANDRA

#### 1. Diseña una base de datos Cassandra para dar servicio a las lecturas y escrituras anteriores. Argumenta tus decisiones de diseño.

Para esta tarea hemos pensado en realizar tres tablas, a continuación la explicación y justificación de cada una de ellas:

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
  
 - La clave primaria formada por ((country, dungeon_id), time_minutes, date), se ha diseñado de esta manera para poder acceder de manera adecuada a cada país y dungeon como te especifica el problema. Además hemos añadido la variable time_minutes, ya que luego la necesitaremos en las consultas de lectura para ordenarlos de menor a mayor, y la variable date, ya que es la única variable con valores únicos.

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

#### 2. Crea las consultas .sql necesarias para exportar los datos de la base de datos relacional a ficheros .csv. Los ficheros deberán tener un formato acorde al diseño del punto 1.

Para esta tarea hemos creado el archivo consultas.sql, que ejecuta las consultas sql necesarias para crear los .csv necesarios. Para ello hemos trabajado con MYSQL Workbench y en el docker-compose.yml que hemos utilizado para realizar la tarea 3, hemos creado un servicio de sql para guardar ahí los .csv de cara a las siguientes tareas.

#### 3. Prepara un cluster local de 3 nodos todos en el mismo rack y datacenter.

Esta tarea está realizada en el docker-compose.yml, que esta dentro de esta carpeta. En el archivo podemos ver como creamos los tres nodos, que después utilizaremos para desplegar nuestro diseño de Cassandra y realizar las consultas de escritura y de lectura.

#### 4. Haz un fichero .cql que creen tu diseño en Cassandra y cargue los ficheros .csv creados en el paso 2. Se debe utilizar un factor de replicación de 2 y tener en cuenta que las pruebas se ejecutaran en un cluster local.

El fichero en cuestión es el llamado archivo.cql, que como vemos realiza la tarea deseada. Ya que hay que tener en cuenta que las pruebas se ejecutan en un cluster local, los pasos para ejecutar este archivo es el siguiente:

 ##### 1. Correr el docker-compose.yml

        docker-compose up -d

 ##### 2. Una vez creada la estructura de Cassandra, introducirnos en un nodo de Cassandra

        docker exec -it cassandra1 cqlsh

 ##### 3. Ejecutar el siguiente comando para correr el archivo requerido

        SOURCE 'var/lib/cassandra/archivo.cql';

La ruta es esa, ya que es la que hemos añadido en el volumen del docker-compose.yml, que hemos mencionado anteriormente. Con todos estos pasos tendríamos nuestros .csv cargados en nuestro diseño de Cassandra. Recordar que este archivo tiene que estar dentro del nodo en el que nos hayamos metido, en este caso el nodo1, al igual que los .csv, para que la carga de los datos sea exitosa.

#### 5. [OPCIONAL] Si el diseño lo necesita, actualiza la tabla de escrituras para incluir cualquier modificación que sea necesaria en la información que se le debe proporcionar al servidor.

Hemos realizado varias modificaciones:

- Hemos añadido que escriba el país, ya que es importante para la tabla hall_of_fame
- Para la tabla top_horde, hemos cambiado que no hace falta que escriba el monster_id, ya que nosotros solo necesitamos el n_kills, que iremos actualizando usando la función UPDATE, que explicaremos en la siguiente tarea.

#### 6. Haz un fichero .cql que realice las consultas de escritura y lectura necesarias. Incluye el nivel de consistencia de cada consulta, teniendo en cuenta las características de los diferentes rankings.

El fichero de esta tarea es el llamado consultas.cql, para ejecutarlo hay que seguir los mismos pasos que en la tarea 4, pero en este caso hay que cambiar el último paso por el siguiente:

    SOURCE 'var/lib/cassandra/consultas.cql';

Hay que tener en cuenta que para ejecutar este archivo hay que tener ejecutado el archivo 'archivo.cql', para que funcionen las consultas.


##### Consultas de lectura

###### Lectura en la tabla hall_of_fame con nivel de consistencia ONE

Hemos elegido consitencia ONE ya que en el aspecto de rendimiento es más rápido y se reduce la carga en el sistema y mejora la escalabilidad. No ofrece la misma resistencia a fallos que otras consistencias, pero como ponía en el enunciado, no es relevante. Esta consulta te saca el top5 según el tiempo que ha tardado el usuario en completar la dungeon, de un país y un dungeon concreto. En el enunciado ponía de sacar de todos los países el top5 de cada dungeon. Para ello, tendríamos que hacer un .py en el que crearíamos un bucle for que recorriese los dungeons en cada país para sacar el top5.

###### Lectura en la tabla user_statistics con nivel de consistencia ONE

Esta consulta te devuelve el tiempo y la fecha en el que completó la dungeon un usuario concreto. Hemos elegido la misma consistencia por los mismos motivos mencionados anteriormente. Está ordenado de menor a mayor según el tiempor que tardó en completar la dungeon.

###### Lectura en la tabla top_horde con nivel de consistencia ONE

Esta consulta devuelve el número de kills, el email y el nombre del usuario, de un país y un evento en concreto. Las kills no están ordenadas ya que son de tipo COUNTER. Usamos la consistencia ONE

##### Consultas de escritura

###### Escritura en la tabla hall_of_fame y user_statistics con nivel de consistencia ONE

Esta consulta inserta en la tabla hall_of_fame y user_statistics los valores requeridos. En la de hall_of_fame hemos añadido el país ya que es importante a la hora de después encontrarlo en la consulta de lectura. Usamos la consistencia de tipo ONE

###### Escritura en la tabla top_horde con nivel de consistencia ONE

Esta consulta actualiza el número de kills de un usuario, en un evento de un país. Usamos la función UPDATE, ya que damos por hecho que todos los usuarios han hecho kills. Usamos la consistencia de tipo ONE. 













    
