# Neo4j

## Tareas
Se nos pide realizar una seria de consultas sobre nuestra base de datos en neo4j.

### Desde la interfaz web 
#### 1.	Buscar todas las salas de todas las mazmorras que contengan un tesoro en particular.
    MATCH (r:Room) – [:CONTAINS] – (l:Loot {name: $loot_name})
    RETURN r.name, l

#### 2.	Obtener todos los monstruos que hay en una sala en particular.
      MATCH (r:Room {room_name: $room_name}) – [:CONTAINS] – (m:Monster)
      RETURN m.name
  
#### 3.	Obtener todos los monstruos que no están presentes en ninguna sala.
      MATCH (m:Monster)
      WHERE NOT EXISTS {
          MATCH (:Room)-[:CONTAINS]->(m)
      }
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
##### Primera Query
En la que calculamos el número total de pasillos por mazmorra y almacenamos el resultado en un diccionario llamado num_connections_per_dungeon que tiene como clave el nombre de la mazmorra y como valor el número de pasillos.

      MATCH (r:Room)-[:IS_CONNECTED]->(:Room)
      WITH r.dungeon_name AS dungeon, COUNT(*) AS num_connections
      RETURN dungeon, num_connections
      
##### Segunda Query
Calculamos el número total de mazmorras y guardamos el resultado en una variable llamada total_dungeons.

        MATCH (r:Room)
        WITH DISTINCT r.dungeon_name AS dungeon
        RETURN COUNT(DISTINCT dungeon) AS total_dungeons

##### Tercera Query
Por último calculamos el número medio de pasillos por mazmorra.

        avg_connections = sum(num_connections_per_dungeon.values()) / total_dungeons

#### 12.	Buscar la/las salas que contienen el/los monstruos de más nivel de la mazmorra.
        MATCH (r:Room {dungeon_name: $dungeon_name})-[:CONTAINS]->(m:Monster)
        WITH r, m
        ORDER BY m.level DESC
        LIMIT 1
        RETURN r.room_name AS room_name

#### 13.	Calcular la experiencia total de cada uno de los encuentros (grupo de monstruos presentes en una sala) de una mazmorra y mostrarlos ordenados de mayor a menor experiencia.
        MATCH (r:Room {dungeon_name: $dungeon_name}) – [:CONTAINS] -> (m:Monster)
        WITH r, collect(m) AS monsters, sum(m.exp) AS totalExperience
        RETURN r, monsters, totalExperience
        ORDER BY totalExperience DESC

#### 14.    Buscar la sala dónde este el encuentro (grupo de monstruos presentes en una sala) que más experiencia da de una mazmorra.
        MATCH (r:Room {dungeon_name: $dungeon_name}) – [:CONTAINS] -> (m:Monster)
        WITH r, collect(m) AS monsters, sum(m.exp) AS totalExperience
        ORDER BY totalExperience DESC
        LIMIT 1
        RETURN r, monsters, totalExperience;

https://github.com/pastooor/PARTE1BDII/blob/main/editor_niveles/mapamundi.html

### Visualización 
Ahora pasamos a la parte de visualización donde a través de queries ejecutadas en python y la ayuda de la librería pyvis vamos a generar archivos html donde se van a mostrar los grafos solucion de cada una de las visualizaciones. 

En este Readme, solo vamos a mostrar las queries que hemos usado para después a través de código python crear los grafos, todo ese código se puede encontrar en el archivo **'visualizacion.ipynb'**.

#### 1.    **Mapamundi:** El mapamundi debe mostrar las distintas áreas del juego y como se interconectan unas con otras.
Con esta query vamos a sacar el camino más corto entre todas las areas del juego.

##### Query
        MATCH p=() - [:SHORTEST_PATH] - () RETURN p

En el achivo 'mapamundi.html' se puede ver el grafo resultante que hemos sacado para representar el mapamundi.

#### 2.    **Listado mazmorras:** El listado de mazmorras debe mostrar todas las mazmorras del juego y las áreas con las que están conectadas. Debería ser capaz de ver a simple vista que mazmorras están en cada área y mazmorras hacen de puente entre dos áreas. 

##### Query
        MATCH (d:Room) 
        WHERE d.dungeon_name IS NOT NULL 
        WITH DISTINCT d.dungeon_name AS dungeon_name, collect(d) AS rooms 
        UNWIND rooms AS room 
        MATCH (room)-[:IS_CONNECTED]-(a:Area) 
        RETURN dungeon_name, collect(DISTINCT a.name) AS connected_areas"

En el achivo 'listado_mazmorras.html' se pueden ver todas las mazmorras del juego que pertenezcan al menos a una de las 10 areas del juego. 
Las areas del juego se representan de color amarillo y las mazmorras de color azul.


#### 2.    **Listado mazmorras:** El listado de mazmorras debe mostrar todas las mazmorras del juego y las áreas con las que están conectadas. Debería ser capaz de ver a simple vista que mazmorras están en cada área y mazmorras hacen de puente entre dos áreas. 

##### Query
        MATCH (d:Room) 
        WHERE d.dungeon_name IS NOT NULL 
        WITH DISTINCT d.dungeon_name AS dungeon_name, collect(d) AS rooms 
        UNWIND rooms AS room 
        MATCH (room)-[:IS_CONNECTED]-(a:Area) 
        RETURN dungeon_name, collect(DISTINCT a.name) AS connected_areas"

En el achivo 'listado_mazmorras.html' se pueden ver todas las mazmorras del juego que pertenezcan al menos a una de las 10 areas del juego. 
Las areas del juego se representan de color amarillo y las mazmorras de color azul.


#### 3.    Mini-mapa mazmorra: Dada una mazmorra el mini mapa debe mostrar información que ayude a los aventureros a explorar la mazmorra. En el mini mapa debe ser fácil reconocer las entradas y las salidas de una mazmorra. Los pasillos que llevan a salas interesantes. Las zonas donde hay monstruos o tesoros y el nivel/precio de estos. 

Gracias a estas querie vamos a poder sacar toda la información de un mazmorra.
##### Query 1
Simplemente con esta query ya tendriamos toda la información de cada una de las habitaciones de la mazmorra pero nos faltaría saber el camino para poder recorrer esa mazmorra, las conexiones entre las habitaciones.

        MATCH (entrance:Room {dungeon_name: $dungeon_name})-[:IS_CONNECTED]->(:Area) 
        MATCH (exit:Room {dungeon_name: $dungeon_name}) <- [:IS_CONNECTED] - (:Area) 
        WHERE entrance <> exit 
        OPTIONAL MATCH  (entrance) - [:CONTAINS] - (m1:Monster) 
        OPTIONAL MATCH  (entrance) - [:CONTAINS] - (l1:Loot) 
        OPTIONAL MATCH  (exit) - [:CONTAINS] - (m2:Monster) 
        OPTIONAL MATCH  (exit) - [:CONTAINS] - (l2:Loot) 
        MATCH (r:Room {dungeon_name: $dungeon_name}) - [:IS_CONNECTED] - (:Room)
        WHERE r <> entrance AND r <> exit 
        MATCH (r) - [:CONTAINS] - (m:Monster), 
              (r) - [:CONTAINS] - (l:Loot) 
        RETURN entrance, exit, r, m, l, m1, l1, m2, l2

##### Query 2
Como ya se ha explicado para saber como avanzar y poder superar una mazmorra hay que saber el camino a seguir y esto lo sacamos conectando las habitaciones.

        MATCH p=(r:Room {dungeon_name: $dungeon_name}) - [:IS_CONNECTED] - (r2:Room {dungeon_name: $dungeon_name})
        RETURN p

En el achivo 'mazmorras.html' se puede ver cada una de las habitaciones, tesoros y monstruos que hay en la mazmorra que se desee.
Dentro del grafo que se saca, se pueden ver la habitación de entrada y salida de color verde oscuro y verde claro respectivamente, el resto de las habitaciones de color rosa, sus conexiones con otras habitaciones y el contenido en el caso de que esa habitación tenga tanto de tesoros como de monstruos, de color amarillo y azul respectivamente. 

Gracias a este grafo un jugador podría elegir por que habitaciones le interesa pasar en función de lo que busque ya sean kills, recompensas o records de tiempos.

### Filtro Colaborativo
#### 1. . Una que realice una consulta Cypher y sin usar plugins busque otros monstruos que coaparezcan en otras salas con los monstruos de nuestro encuentro. 

    from neo4j import GraphDatabase

    # Preparamos la sesión para acceder a neo4j
    driver = GraphDatabase.driver('neo4j://localhost:7687', auth=("neo4j", "BDII2023"))
    session = driver.session()

    def search_monsters(room_name):
        query = """
        MATCH (r:Room {room_name: $room_name}) - [:CONTAINS] - (m:Monster) 
        MATCH (r2:Room) - [:CONTAINS] - (m)
        MATCH (r2) - [:CONTAINS] - (m2:Monster)
        RETURN DISTINCT m, m2
        """  
    
        results = session.run(query, room_name=room_name).data()
        monsters_dict = {}
        
        for record in results:
            m = (record['m']['name'], record['m']['monsters_id'])  # Clave como tupla de nombre e id
            m2 = {'name': record['m2']['name'], 'monsters_id': record['m2']['monsters_id']}  # Valor como diccionario con nombre e id
            
            if m not in monsters_dict:
                monsters_dict[m] = []
            
            # Agregamos m2 a la lista correspondiente a m
            monsters_dict[m].append(m2)
        # Si no hay ningún monstruo
        if monsters_dict == {}:
            print('Esta sala no tiene monstruos')
        else:
            return monsters_dict

Esta función toma como parámetro el nombre de una habitación y devuelve un diccionario que tiene como claves una tupla con el nombre e id del monstruos de la habitación deseada y como valor una lista de tuplas también con el nombre e id de los otros monstruos que coaparecen en otras salas con el monstruo que aparece como clave. En caso de que no haya monstruos en esa sala se imprime un mensaje. 


#### 2. Una que utilice el plugin de GDS para realizar una recomendación de 5 monstruos ordenados del que mas recomendaría al que menos recomendaría.

        from graphdatascience import GraphDataScience
        import pandas as pd
        
        # configure connection
        gds = GraphDataScience("neo4j://localhost:7687", auth=("neo4j", "BDII2023"))
        print(f"GDS version: {gds.version()}")

        def monster_recommendations(room_name):
            node_query = """
            MATCH (r1:Room)-[:CONTAINS]->(m1:Monster)<-[:CONTAINS]-(r2:Room)-[:CONTAINS]->(m2:Monster)
            RETURN DISTINCT id(m1) as id
            """
            edge_query = """
            MATCH (r1:Room)-[:CONTAINS]->(m1:Monster)<-[:CONTAINS]-(r2:Room)-[:CONTAINS]->(m2:Monster)
            RETURN DISTINCT id(m1) as source, id(m2) as target, 1 as weight
            """
        
            with gds.graph.project.cypher("monster_coappearances", node_query, edge_query) as g_temp:
                q_source = """
                    MATCH (:Room {room_name: $room_name})-[:CONTAINS]->(m:Monster) 
                    RETURN id(m) as sources
                """
                sources = gds.run_cypher(q_source, params={"room_name": room_name}).iloc[:, 0]
                # print(sources)
                result = gds.pageRank.stream(g_temp, sourceNodes=sources, relationshipWeightProperty="weight")
                result = result.query("score > 0")
        
                nodes = result.nodeId.to_list()
                q = """
                MATCH (:Room {room_name: $room_name})-[:CONTAINS]->(m:Monster) WITH collect(m) as sources
                MATCH (m:Monster) WHERE id(m) IN $nodes AND NOT(m in sources) 
                RETURN id(m) AS nodeId, m.name AS monster
                """
                df = gds.run_cypher(q, params={"room_name": room_name, "nodes": nodes})
        
                recommendation = pd.merge(result, df, how="left", left_on="nodeId", right_on="nodeId").dropna().sort_values("score",     ascending=False).head(5)

            return recommendation

Esta función, al igual que la anterior, toma como parámetro el nombre de una habitación. Busca los monstruos que aparecen en nuestra habitación y busca los otros monstruos que aparecen en otras salas junto a los monstruos de nuestro encuentro. Una vez obtenidos, se aplica el procedimiento de pageRank de gds y nos devuelve un score para cada monstruo en forma de dataframe. Por último, como solo queremos que aparezcan el resto de monstruos (no los que aparecen en nuestro encuentro) los filtramos y devolvemos solo los 5 primeros con el score más alto. 
