--Subconsultas en SQL--
--1) En el FROM como CTE---
SELECT pais, COUNT(*) AS cantidad
FROM (
    SELECT customers.country AS pais,
	orders.orderid
    FROM customers
    JOIN orders ON customers.customerid = orders.customerid
) AS sub
GROUP BY pais;
--2) En ell WHERE como un filtro adicional
SELECT customerid, totalamount
FROM orders
WHERE totalamount > (
    SELECT AVG(totalamount) FROM orders
);
--3) En el IN, para devolver una lista con elementos especificos
SELECT customerid, firstname
FROM customers
WHERE customerid IN (
    SELECT customerid FROM orders WHERE totalamount > 100
);

--Ejercicio--
SELECT 
    nombre, 
	apellido,
	pais
FROM (
   SELECT 
   customers.firstname AS nombre,
   customers.lastname AS apellido,
   customers.country
) AS sub