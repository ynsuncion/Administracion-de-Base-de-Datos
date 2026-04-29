DECLARE @TotalVentas DECIMAL(18,2);

SELECT @TotalVentas = SUM(d.LineTotal)
FROM Sales.SalesOrderDetail d
INNER JOIN Sales.SalesOrderHeader h
    ON d.SalesOrderID = h.SalesOrderID
WHERE YEAR(h.OrderDate) = 2006; -- filtra solo el año 2006

PRINT 'Total de ventas en 2006: ' + CAST(@TotalVentas AS VARCHAR(50));

-- 2. Obtener el promedio de precios y guardarlo en una variable llamada @Promedio luego
-- hacer un reporte de todos los productos cuyo precio de venta sea menor al Promedio.

-- Tablas: Production.Product
-- Campos: ListPrice, ProductID

DECLARE @Promedio DECIMAL (18,2);

SELECT @Promedio = AVG(ListPrice)
FROM Production.Product;

-- Mostrar el valor del promedio (opcional)
PRINT 'Precio promedio: ' + CAST(@Promedio AS VARCHAR(50));

-- Reporte de productos con precio menor al promedio
SELECT ProductID, ListPrice
FROM Production.Product
WHERE ListPrice < @Promedio;

