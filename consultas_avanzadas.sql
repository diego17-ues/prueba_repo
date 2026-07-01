--Ejercicios práctica Repe P2--
SELECT 
  airports_data.airport_code,
  airports_data.city ->>'en' AS ciudad,
  COUNT(routes.departure_airport) AS total_vuelos,
  AVG(routes.duration) AS promedio_duracion
FROM airports_data
JOIN routes ON airports_data.airport_code=routes.departure_airport
GROUP BY  airports_data.airport_code, airports_data.city ->>'en'
HAVING COUNT(routes.departure_airport)>50
--Solucion Claude--
WITH 
cantidad_vuelos AS (
SELECT 
   airports_data.airport_code AS codigo_aeropuerto,
   airports_data.city ->>'en' AS ciudad,
   COUNT(DISTINCT flights.flight_id) AS cantidad_vuelos
FROM airports_data 
JOIN routes ON airports_data.airport_code=routes.departure_airport
JOIN flights ON routes.route_no=flights.route_no
GROUP BY airports_data.airport_code, airports_data.city ->>'en'
),
promedio_duracion AS (
SELECT 
   airports_data.airport_code AS codigo_aeropuerto,
   airports_data.city ->>'en' AS ciudad,
   AVG(routes.duration) AS duracion_promedio
FROM airports_data
JOIN routes ON airports_data.airport_code=routes.departure_airport
GROUP BY airports_data.airport_code, airports_data.city ->>'en'
)
SELECT 
cantidad_vuelos.codigo_aeropuerto,
cantidad_vuelos.ciudad,
cantidad_vuelos.cantidad_vuelos,
promedio_duracion.duracion_promedio
FROM cantidad_vuelos
JOIN promedio_duracion ON cantidad_vuelos.codigo_aeropuerto=promedio_duracion.codigo_aeropuerto

--Ejercicio 2--
WITH cantidad_vuelos AS (
    SELECT
        airplanes_data.airplane_code AS codigo,
        airplanes_data.model ->>'en' AS modelo,
        COUNT(DISTINCT flights.flight_id) AS cantidad_vuelos
    FROM airplanes_data
    JOIN routes ON airplanes_data.airplane_code = routes.airplane_code
    JOIN flights ON routes.route_no = flights.route_no
    GROUP BY airplanes_data.airplane_code, airplanes_data.model ->>'en'
),
cantidad_pasajeros AS (
    SELECT
        flights.flight_id,
        COUNT(DISTINCT tickets.passenger_id) AS cantidad_pasajeros
    FROM flights
    JOIN segments ON flights.flight_id = segments.flight_id
    JOIN tickets ON segments.ticket_no = tickets.ticket_no
    GROUP BY flights.flight_id
),
pasajeros_por_avion AS (
    SELECT
        routes.airplane_code AS codigo,
        SUM(cantidad_pasajeros.cantidad_pasajeros) AS total_pasajeros
    FROM cantidad_pasajeros
    JOIN flights ON cantidad_pasajeros.flight_id = flights.flight_id
    JOIN routes ON flights.route_no = routes.route_no
    GROUP BY routes.airplane_code
)
SELECT
    cantidad_vuelos.codigo,
    cantidad_vuelos.modelo,
    cantidad_vuelos.cantidad_vuelos,
    pasajeros_por_avion.total_pasajeros
FROM cantidad_vuelos
JOIN pasajeros_por_avion ON cantidad_vuelos.codigo = pasajeros_por_avion.codigo
WHERE cantidad_vuelos.cantidad_vuelos > 100;

--Ejercicio 3--
WITH 
total_segmentos AS (
SELECT 
    routes.route_no AS ruta,
	routes.departure_airport AS aeropuerto_salida,
	routes.arrival_airport AS aeropuerto_destino,
    COUNT(DISTINCT segments.flight_id) AS cantidad_vuelos
FROM routes 
JOIN flights ON routes.route_no=flights.route_no
JOIN segments ON flights.flight_id=segments.flight_id
GROUP BY routes.route_no, routes.departure_airport, routes.arrival_airport
),
total_pasajeros_vuelo AS (
SELECT 
     segments.flight_id,
	 COUNT(segments.ticket_no) AS cantidad_pasajeros
FROM segments
GROUP BY segments.flight_id
),
total_pasajeros_ruta AS (
SELECT 
    routes.route_no AS ruta,
	SUM(total_pasajeros_vuelo.cantidad_pasajeros) AS total_pasajeros
FROM total_pasajeros_vuelo
JOIN flights ON total_pasajeros_vuelo.flight_id=flights.flight_id
JOIN routes ON flights.route_no=routes.route_no
GROUP BY routes.route_no
)
SELECT 
    total_segmentos.ruta,
	total_segmentos.aeropuerto_salida,
	total_segmentos.aeropuerto_destino,
	total_segmentos.cantidad_vuelos,
	total_pasajeros_ruta.total_pasajeros
FROM total_segmentos
JOIN total_pasajeros_ruta ON total_segmentos.ruta=total_pasajeros_ruta.ruta

--Version optimizada--
WITH metricas_por_ruta AS (
    SELECT
        routes.route_no AS ruta,
        routes.departure_airport AS aeropuerto_salida,
        routes.arrival_airport AS aeropuerto_destino,
        COUNT(segments.ticket_no) AS total_segmentos,
        COUNT(DISTINCT segments.ticket_no) AS total_pasajeros
    FROM routes
    JOIN flights ON routes.route_no = flights.route_no
    JOIN segments ON flights.flight_id = segments.flight_id
    GROUP BY routes.route_no, routes.departure_airport, routes.arrival_airport
)
SELECT *
FROM metricas_por_ruta
WHERE total_pasajeros > (
    SELECT AVG(total_pasajeros) FROM metricas_por_ruta
);
