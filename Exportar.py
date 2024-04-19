import csv
import pymysql

# Conectarse a la base de datos MySQL
conn = pymysql.connect(host='127.0.0.1',
                       user='root',
                       password='BDII2023',
                       database='videogame')

# Crear un cursor para ejecutar consultas SQL
cursor = conn.cursor()

# Ejecutar la consulta SQL
sql_query1 = """
SELECT wu.country, cd.idD AS dungeon_id, d.name AS dungeon_name, cd.email, wu.userName AS user_name, cd.time AS time_minutes, cd.date
FROM WebUser wu
INNER JOIN CompletedDungeons cd ON wu.email = cd.email
INNER JOIN Dungeon d ON cd.idD = d.idD
"""
cursor.execute(sql_query1)

# Obtener los resultados de la consulta
results = cursor.fetchall()

# Especificar la ubicación y el nombre del archivo CSV
csv_file1 = 'Hall_of_fame.csv'

# Escribir los resultados en un archivo CSV
with open(csv_file1, 'w', newline='') as file:
    writer = csv.writer(file)
    # Escribir la cabecera
    writer.writerow(['Country', 'Dungeon ID', 'Dungeon Name', 'Email', 'User Name', 'Time', 'Date'])
    # Escribir cada fila de resultados
    for row in results:
        writer.writerow(row)



# Ejecutar la consulta SQL
sql_query2 = """
SELECT cd.email AS user_id, cd.idD AS dungeon_id, cd.time AS time_minutes, cd.date
FROM CompletedDungeons cd
"""
cursor.execute(sql_query2)

# Obtener los resultados de la consulta
results = cursor.fetchall()

# Especificar la ubicación y el nombre del archivo CSV
csv_file2 = 'User_statistics.csv'

# Escribir los resultados en un archivo CSV
with open(csv_file2, 'w', newline='') as file:
    writer = csv.writer(file)
    # Escribir la cabecera
    writer.writerow(['Email', 'Dungeon ID', 'Time', 'Date'])
    # Escribir cada fila de resultados
    for row in results:
        writer.writerow(row)
        
        
# Ejecutar la consulta SQL
sql_query3 = """
SELECT wu.country, k.idE, k.email, wu.userName, COUNT(*) AS n_kills
FROM Kills k 
INNER JOIN  WebUser wu ON wu.email = k.email
GROUP BY k.email, k.idE
"""
cursor.execute(sql_query3)

# Obtener los resultados de la consulta
results = cursor.fetchall()

# Especificar la ubicación y el nombre del archivo CSV
csv_file3 = 'Top_Horde.csv'

# Escribir los resultados en un archivo CSV
with open(csv_file3, 'w', newline='') as file:
    writer = csv.writer(file)
    # Escribir la cabecera
    writer.writerow(['Country', 'Event ID', 'Email', 'User Name','N Kills'])
    # Escribir cada fila de resultados
    for row in results:
        writer.writerow(row)       
        

# Cerrar el cursor y la conexión a la base de datos
cursor.close()
conn.close()

print("Los resultados se han exportado correctamente")

