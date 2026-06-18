--Transacciones

--1) Borrar todos los productos que no se hayan vendido y luego revertir la operación.

--Tablas: Production.Product, Sales.SalesOrderDetail
--Campos: ProductID



BEGIN TRAN

	DELETE pp
	FROM Production.Product pp
	WHERE NOT EXISTS( 
						SELECT	1 
						FROM	Sales.SalesOrderDetail SO 
						WHERE	PP.ProductID = SO.ProductID
					)
ROLLBACK

--2)Incrementar el precio a 200 para todos los productos cuyo precio sea igual a cero y confirmar la transacción.

--Tablas: Production.Product
--Campos: ListPrice

BEGIN TRAN
	UPDATE	Production.Product 
	SET		ListPrice=200
	WHERE	ListPrice=0
COMMIT



--3) Obtener el promedio del listado de precios y guardarlo en una variable llamada @Promedio. Incrementar todos los productos un 15% pero si el precio mínimo no supera el promedio revertir toda la operación.

--Tablas: Production.Product
--Campos: ListPrice

BEGIN TRAN
	DECLARE @prom MONEY;	
	
	SELECT	@prom = AVG([ListPrice]) FROM [Production].[Product]

UPDATE	[Production].[Product] 
SET		[ListPrice] = [ListPrice] * 1.15 

IF @prom < ( SELECT MIN([ListPrice]) from [Production].[Product]) 
	ROLLBACK TRAN
ELSE
	COMMIT TRAN