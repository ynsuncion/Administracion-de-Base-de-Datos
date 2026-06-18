-- Variables

-- 1. Obtener el total de ventas del año 2014 y guardarlo en una variable llamada @TotalVentas, luego imprimir el resultado.

--Tablas: Sales.SalesOrderDetail
--Campos: LineTotal
DECLARE @TotalVentas MONEY;

SELECT @TotalVentas = SUM(LineTotal)
FROM Sales.SalesOrderDetail sod
INNER JOIN Sales.SalesOrderHeader soh
    ON sod.SalesOrderID = soh.SalesOrderID
WHERE YEAR(soh.OrderDate) = 2006;

PRINT 'Total de ventas en 2006: ' + CONVERT(VARCHAR(20), @TotalVentas);


-- 2. Obtener el promedio de precios y guardarlo en una variable llamada @Promedio luego
-- hacer un reporte de todos los productos cuyo precio de venta sea menor al Promedio.

-- Tablas: Production.Product
-- Campos: ListPrice, ProductID

DECLARE @Promedio DECIMAL (6,2);

SELECT @Promedio = AVG(ListPrice)
FROM Production.Product;

PRINT 'Precio promedio: ' + CAST(@Promedio AS VARCHAR(50));

SELECT ProductID, ListPrice
FROM Production.Product
WHERE ListPrice < @Promedio;

-- 3. Utilizando la variable @Promedio incrementar en un 10% el valor de los productos sean inferior al promedio.

-- Tablas: Production.Product
-- Campos: ListPrice

DECLARE @Promedio DECIMAL (6,2)

SELECT @Promedio = AVG(ListPrice)
FROM Production.Product;

update Production.Product
SET ListPrice = ListPrice * 1.10
WHERE ListPrice < @Promedio;

-- Verificación

SELECT ProductID, ListPrice
FROM Production.Product
WHERE ListPrice < @Promedio;

-- 4. Crear un variable de tipo tabla con las categorías y subcategoría de productos y
-- reportar el resultado.

-- Tablas: Production.ProductSubcategory, Production.ProductCategory
-- Campos: Name

DECLARE @tabla table (categoria VARCHAR(50),
	SubCategoria VARCHAR (50));

INSERT INTO @tabla
SELECT		PP.Name, ps.Name 
FROM		Production.ProductSubcategory pp
INNER JOIN  Production.ProductCategory ps
ON			pp.ProductCategoryID= ps.ProductCategoryID

SELECT * FROM @tabla;


-- 5. Analizar el promedio de la lista de precios de productos, si su valor es menor a 500 imprimir el mensaje el PROMEDIO BAJO de lo contrario imprimir el mensaje PROMEDIO ALTO.

-- Tablas: Production.Product
-- Campos: ListPrice

DECLARE @Promedio DECIMAL (6,2)

SELECT @Promedio = AVG(ListPrice)
FROM Production.Product;

IF (@Promedio<500)

	PRINT 'PROMEDIO BAJO'

ELSE
	PRINT 'PROMEDIO ALTO'


--Funciones

--	FUNCIONES ESCALARES


--1)Crear una función que devuelva el promedio de los productos.
--Tablas: Production.Product
--Campos: ListPrice
GO
CREATE FUNCTION dbo.FN_Promedio()
RETURNS MONEY
AS
BEGIN
		DECLARE @promedio MONEY;

		SELECT	@promedio=AVG(ListPrice) 
		FROM	Production.Product
		
		RETURN	@promedio
END
GO

SELECT dbo.FN_Promedio()


--2)Crear una función que dado un código de producto devuelva el total de ventas para dicho producto luego, mediante una  consulta, traer código y total de ventas.
--Tablas: Sales.SalesOrderDetail
--Campos: ProductID, LineTotal

GO
CREATE FUNCTION dbo.FN_VentasProductos(@codigoProducto INT) 
RETURNS INT
AS
 BEGIN
	   DECLARE @total INT;

	   SELECT	@total = SUM(LineTotal)
	   FROM		Sales.SalesOrderDetail
	   WHERE	ProductID= @codigoProducto
	   
	   IF (@total IS NULL)
		  SET @total = 0
	   
	   RETURN @total
 END
GO

SELECT	ProductID, dbo.FN_VentasProductos(ProductID) AS TotalVentas
FROM	Production.Product
ORDER BY TotalVentas DESC


--3) Crear una función que dado un código devuelva la cantidad de productos vendidos o cero si no se ha vendido.
--Tablas: Sales.SalesOrderDetail
--Campos: ProductID, OrderQty

CREATE FUNCTION dbo.FN_CantidadVentasProductos(@codigoProducto INT) 
RETURNS INT
AS
 BEGIN
	   DECLARE @total INT;

	   SELECT	@total = SUM(OrderQty)
	   FROM		Sales.SalesOrderDetail
	   WHERE	ProductID= @codigoProducto
	   
	   IF (@total IS NULL)
		  SET @total = 0
	   
	   RETURN @total
 END
GO

SELECT dbo.FN_CantidadVentasProductos(712)



--4)Crear una función que devuelva el promedio de precio. Luego obtener los productos cuyo precio sea inferior al promedio.
--Tablas: Production.Product
--Campos: ProductID, ListPrice
GO
CREATE FUNCTION dbo.FN_PromedioVentas()
RETURNS MONEY
AS
BEGIN
        DECLARE @promedio MONEY;

        SELECT	@promedio=AVG(ListPrice) 
        FROM	Production.Product

        --PRINT 'El promedio de venta es: ' + CAST(@promedio AS VARCHAR(20))
        
        RETURN	@promedio
END
GO

SELECT		ProductID, ListPrice
FROM		Production.Product
WHERE		ListPrice < dbo.FN_PromedioVentas()
ORDER BY	ListPrice desc



--	FUNCIONES DE TABLA EN LÍNEA

--5) Crear una función que dado un año, devuelva nombre y  apellido de los empleados que ingresaron ese año 
--Tablas: Person.Person, HumanResources.Employee
--Campos: FirstName, LastName,HireDate, BusinessEntityID
GO
CREATE FUNCTION  dbo.IF_IngresoEmpleadosAnuales(@año INT)
RETURNS TABLE
AS
	RETURN
	(
		SELECT		FirstName
					,LastName
					,HireDate
		FROM		Person.Person p
		INNER JOIN	HumanResources.Employee e
		ON			e.BusinessEntityID= p.BusinessEntityID
		WHERE		YEAR(HireDate)=@año
	)
GO	

SELECT	* 
FROM	dbo.IF_IngresoEmpleadosAnuales(2003)



--6) Crear una función que reciba un parámetro correspondiente a un precio y nos retorna 
--una tabla con  código,nombre, color y precio de todos los productos cuyo precio sea inferior al parámetro  ingresado
--Tablas: Production.Product
--Campos: ProductID, Name, Color, ListPrice
GO
CREATE FUNCTION dbo.if_PrecioProducto(@precio money)
RETURNS TABLE
AS
RETURN 
(
    SELECT	ProductID
			,Name
			,Color
			,ListPrice
    FROM	Production.Product AS P		
    WHERE	ListPrice<@precio
)
GO

SELECT		* 
FROM		dbo.if_PrecioProducto (1340)
ORDER BY	ProductID, Name   DESC;


--	FUNCIONES DE MULTI SENTENCIA 

--7)Realizar el mismo pedido que en el punto anterior pero utilizando este  tipo de función
--Tablas: Production.Product
--Campos: ProductID, Name, Color, ListPrice
GO
CREATE FUNCTION dbo.tf_ofertas( @minimo DECIMAL(6,2))
RETURNS @oferta 
TABLE
(
	Codigo		INT
	,Nombre		VARCHAR(40)
	,Color		VARCHAR(30)
	,Precio		DECIMAL(6,2)
)
AS
BEGIN
	INSERT @oferta
	SELECT	ProductID
			,Name
			,Color
			,ListPrice
	FROM	Production.Product
	WHERE	ListPrice<@minimo
	RETURN
END
GO

 SELECT *
 FROM	dbo.tf_ofertas(50)