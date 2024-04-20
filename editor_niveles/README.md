# Neo4J

## Tareas
Se nos pide realizar una seria de consultas sobre nuestra base de datos.

### Desde la interfaz web 
#### 1.	Buscar todas las salas de todas las mazmorras que contengan un tesoro en particular.
    MATCH (r:Room) – [:CONTAINS] – (l:Loot {name: $loot_name})
    RETURN r.name, l

#### 2.	Obtener todos los monstruos que hay en una sala en particular.
  MATCH (r:Room {room_name: $room_name}) – [:CONTAINS] – (m:Monster)
  RETURN m.name
  
#### 3.	Obtener todos los monstruos que no están presentes en ninguna sala.
  MATCH p=(r:Room {room_name: $room_name}) – [:CONTAINS] – (m:Monster)
  WHERE m NOT IN (p)
  RETURN m.name

#### 4.	Calcular el camino más corto de un área a otra área.
  MATCH (a1:Area {name: $start_area}), (a2:Area {name: $end_area})
  CALL apoc.algo.dijkstra(a1, a2, 'IS_CONNECTED', 'weight') 
  YIELD path, weight
  RETURN path, weight

#### 5.	Mostrar los enemigos que es necesario derrotar para ir de un área del juego a otra por el camino más corto.
  MATCH (a1:Area {name: $start_area}), (a2:Area {name: $end_area})
  CALL apoc.algo.dijkstra(a1, a2, 'IS_CONNECTED', 'weight') 
  YIELD path, weight
  MATCH (r:Room) – [:CONTAINS] -> (m:Monster)
  WHERE r IN nodes(path)
  RETURN DISTINCT m

#### 6.	Crear una nueva arista que conecta las distintas áreas del juego, las aristas deben tener un atributo peso con la longitud del camino más corto que unen las dos áreas.
  MATCH (a:Area) - [c1:IS_CONNECTED] -> (r1:Room)
  MATCH (b:Area) <- [c2:IS_CONNECTED] - (r2:Room)
  WHERE c1.dungeon_name = c2.dungeon_name AND a <> b
  CALL apoc.algo.dijkstra(a, b, 'IS_CONNECTED', 'weight') 
  YIELD weight, path
  WITH a, b, length(path) AS path_length
  WITH a, b, MIN(path_length) AS min
  CREATE (a) - [:SHORTEST_PATH {weight: min}] -> (b)

#### 7.	Mostrar el mapa-mundi del juego, es decir, las áreas que contiene y como están conectadas.
  MATCH p=()-[r:SHORTEST_PATH]->() RETURN p
#### 8.	Crea un atributo nuevo en las habitaciones que contenga el nombre de la mazmorra a la que pertenecen.
  MATCH (:Area) - [c:IS_CONNECTED] -> (r:Room)
  SET r.dungeon_name = c.dungeon_name
  WITH r.dungeon_name AS dungeon_name, collect(r) AS rooms
  CALL apoc.path.subgraphAll(rooms, {relationshipFilter: "IS_CONNECTED>", labelFilter: '-Area'})
  YIELD nodes
  UNWIND nodes AS r
  SET r.dungeon_name = dungeon_name
  
### Desde Python
#### 9.	Calcular el total de oro que valen los tesoros de una mazmorra.
  MATCH (r:Room {dungeon_name: $dungeon_name})-[:CONTAINS]->(l:Loot)
  RETURN sum(l.gold) AS totalGold;

#### 10.	Calcular el nivel medio de los monstruos de una mazmorra.
  MATCH (r:Room {dungeon_name: $dungeon_name})-[:CONTAINS]->(m:Monster)
  RETURN avg(m.level) AS avgLevel;

#### 11.	Calcular el número medio de pasillos (tanto entrantes como salientes) que tienen las salas de una mazmorra.
  MATCH (r:Room)-[:IS_CONNECTED]->(:Room)
  WITH r.dungeon_name AS dungeon, COUNT(*) AS num_connections
  RETURN dungeon, num_connections


