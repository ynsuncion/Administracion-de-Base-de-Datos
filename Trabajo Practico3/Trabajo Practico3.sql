-- Trabajo Practico Funciones 

-- Funciones Escalares 

-- 1. Crear una función que devuelva el promedio de los productos.
-- Tablas: Production.Product
-- Campos: ListPrice

GO
CREATE FUNCTION dbo.FN_Promedio()
RETURNS MONEY 
AS 
BEGIN 
		DECLARE @promedio MONEY;

		SELECT @promedio = AVG(ListPrice)
		FROM Production.Product

		RETURN @promedio

END
GO

SELECT dbo.FN_Promedio()


-- 2. Crear una función que dado un código de producto devuelva el total de ventas para dicho producto luego, mediante una consulta, traer código y total de ventas.
-- Tablas: Sales.SalesOrderDetail
-- Campos: ProductID, LineTotal

GO
CREATE FUNCTION dbo.FN_VentasProductos(@codigoProducto INT)
RETURNS MONEY
AS
	BEGIN 
		DECLARE @total MONEY;

		SELECT @total = SUM (LineTotal) 
		FROM Sales.SalesOrderDetail
		WHERE ProductID = @codigoProducto

	IF (@total IS NULL)
		SET @total = 0
	RETURN @total 

	END

GO

SELECT ProductID, dbo.FN_VentasProductos(ProductID) AS TotalVentas
FROM	Production.Product
ORDER BY TotalVentas DESC

-- 3. Crear una función que dado un código devuelva la cantidad de productos vendidos o cero si no se ha vendido.
-- Tablas: Sales.SalesOrderDetail
-- Campos: ProductID, OrderQty

CREATE fUNCTION dbo.FN_CantidadVentasProductos (@codigoProducto INT)
RETURNS INT
AS
	BEGIN 
		DECLARE @total INT;

		SELECT @total = SUM(OrderQty)
		FROM	Sales.SalesOrderDetail
		WHERE	ProductID = @codigoProducto 

		IF(@total IS NULL)
			SET @total=0

