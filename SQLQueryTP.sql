-- TPN1 Writing Queries con SQL Server	
-- select - where
-- 1. mostrar los empleados que tienen mas de 90 horas de vacaciones 
select 
from humanResorces.employee
where vaationHours > 90

-- 2. mostrar el nombre, precio y precio con iva de los productos fabricados
select Name, ListPrice, ListPrice * 1.21 as 'Precio con iva'
from production.Product

-- 3. mostrar los diferentes titulos de trabajo que existen
select JobTitle as 'Titulo de empleado'
from HumanResources.Employee

-- 4. mostrar todos los posibles colores de productos 
select Color
from Production.Product

-- 5. mostrar todos los tipos de pesonas que existen 
select PersonType
from Person.Person

-- 6. mostrar el nombre concatenado con el apellido de las personas cuyo apellido sea johnson
select	FirstName + ' ' + LastName as 'Nombre de Persona'
from	Person.Person
where	LastName = 'johnson'

-- 7. mostrar todos los productos cuyo precio sea inferior a 150$ de color rojo o cuyo precio sea mayor a 500$ de color negro
select	*
from	Production.Product
where	ListPrice < 150 and Color = 'red'
or		ListPrice > 500 and Color = 'black'

-- listar los productos cuyo color sea blanco, negro o rojo
select	*
from	Production.Product
-- where	Color in ('white','black','red')
where	Color not in ('white','black','red') 

-- 8. mostrar el codigo, fecha de ingreso y horas de vacaciones de los empleados ingresaron a partir del año 2000 
select	*
from	HumanResources.Employee
where	HireDate > '2000-01-01'

-- listar los empleados que ingresaron entre los años 1990 y 2000
select	*
from	HumanResources.Employee
where	year(HireDate) between 1990 and 2000

-- listar los empleados que ingresaron el 31 de Julio del 2000
select	*
from	HumanResources.Employee
where	year(HireDate) = 2000
and		MONTH(HireDate) = 7
and		day(HireDate) = 31

-- 9. mostrar el nombre,nmero de producto, precio de lista y el precio de lista incrementado en un 10% de los productos cuya fecha de fin de venta sea anerior al dia de hoy
select	*
from	Production.Product
where	SellEndDate < GETDATE()

-- operador Like
-- listar todos los empleados que ingresaron entre 2000 y 2004
select	*
from	HumanResources.Employee
-- where	HireDate like '%200[0-4]%' -- rango de valores
-- where	HireDate like '%200[1,3,4]%' -- lista de valores
-- where	HireDate like '%200[^1]%' -- negacion
-- where	HireDate like '%200[^1-3]%' -- negacion de rango
where	HireDate like '%200[^1,3]%' -- negacion de lista

-- listar el nombre de las personas que empiecen con m, el segundo
-- caracter sea cualquiera, el 3er caracter sea r y el resto como sea. Ordenar alfabeticamente
-- Maria, Marcelo, Moria, Mirko, Mariana, Martin, Mercedes, Mirtha
select		FirstName + ' ' + LastName as Nombre
from		Person.Person
where		FirstName like 'm_r%'
order by	1

-- 10. mostrar todos los productos cuyo precio de lista este entre 200 y 300 
select ListPrice 
from Production.Product
where ListPrice between 200 and 300

-- 11. mostrar todos los empleados que nacieron entre 1970 y 1985 
select *
from HumanResources.Employee
where BirthDate between '1970' and '1985'

-- 12. mostrar los codigos de venta y producto,cantidad de venta y precio unitario de los articulos 750,753 y 770
SELECT SalesOrderID, OrderQty, ProductID, UnitPrice
FROM Sales.SalesOrderDetail
WHERE ProductID IN (750, 753, 770)

-- 13. mostrar todos los productos cuyo color sea verde, blanco y azul 
select *
from Production.Product
where Color in ('green','white', 'blue')


-- 14. mostrar la fecha,numero de version y subtotal de las ventas efectuadas en los años 2005 y 2006 
select OrderDate, AccountNumber'Numero de version' ,SubTotal
from Sales.SalesOrderHeader
where year(OrderDate) between 2005 and 2006


-- like
-- 15. mostrar el nombre, precio y color de los accesorios para asientos de las bicicletas cuyo precio sea  mayor a 100 pesos
select	Name Nombre, 
		ListPrice Precio, 
		Color
from	Production.Product
where	ListPrice > 100 and Name like '%seat%'

-- 16. mostrar las bicicletas de montaña que  cuestan entre $1000 y $1200 
select 
from Production.Product
where

-- 17. mostrar los nombre de los productos que tengan cualquier combinacion de ‘mountain bike’ 
-- 18. mostrar las personas que su nombre empiece con la letra y 
-- 19. mostrar las personas que la segunda letra de su apellido es una s 


-- 20. mostrar el nombre concatenado con el apellido de las personas cuyo apellido tengan terminacion española (ez)
select	FirstName + ' ' + LastName as Persona
from	Person.Person
where	LastName like '%ez'

-- 21. mostrar los nombres de los productos que su nombre termine en un numero 
select	Name as Producto
from	Production.Product
where	Name like '%[0-9]'

-- 22. mostrar las personas cuyo  nombre tenga una c o C como primer caracter, cualquier otro como segundo caracter, ni d ni D ni f ni g como tercer caracter, cualquiera entre j y r o entre s y w como cuarto caracter y el resto sin restricciones
select	FirstName Nombre
from	Person.Person
where	FirstName like '[c,C]_[^dDfg][j-w]%'

-- 23. mostrar las personas ordernadas primero por su apellido y luego por su nombre
select		FirstName + '            ' + LastName as Persona 
from		Person.Person
order by	LastName asc, FirstName asc

-- 24. mostrar cinco productos mas caros y su nombre ordenado en forma alfabetica
select	top 5	*
from			Production.Product
order by		ListPrice desc, Name asc

-- 25. mostrar la fecha mas reciente de venta
select	MAX(OrderDate) as 'fecha mas reciente de venta'
from	Sales.SalesOrderHeader


-- 26. mostrar el precio mas barato de todas las bicicletas 
select	MIN(ListPrice) as 'bici mas barata'
from	Production.Product
where	ProductNumber like '%bk%'

-- 27. mostrar la fecha de nacimiento del empleado mas joven 
select	Max(BirthDate) as 'Nacimiento del empleado mas joven'
from	HumanResources.Employee

-- 28. mostrar los representantes de ventas (vendedores) que no tienen definido el numero de territorio
SELECT *
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL


-- 29. mostrar el peso promedio de todos los articulos. si el peso no estuviese definido, reemplazar por cero
select	AVG(ISNULL(Weight, 0)) as 'Peso Promedio'
from	Production.Product

-- 30. mostrar el codigo de subcategoria y el precio del producto mas barato de cada una de ellas 
select		ProductSubcategoryID as Subcategoria,
			MIN(ListPrice) 'Precio mas barato'
from		Production.Product
group by	ProductSubcategoryID

-- 31. mostrar los productos y la cantidad total vendida de cada uno de ellos
select		ProductID as Producto,
			SUM(OrderQty) as 'Total de Ventas'
from		Sales.SalesOrderDetail
group by	ProductID
order by	1

-- 33. mostrar todas las facturas realizadas y el total facturado de cada una de ellas ordenado por numero de factura.
select		SalesOrderID as Factura,
			SUM(OrderQty * UnitPrice) as Subtotal
from		Sales.SalesOrderDetail
group by	SalesOrderID
-- order by	1
-- order by	SalesOrderID
order by	Factura

--34. mostrar todas las facturas realizadas y el total facturado de cada una de ellas ordenado por nro de factura  pero solo de aquellas ordenes superen un total de $10.000
select		SalesOrderID as Factura,
			SUM(OrderQty * UnitPrice) as Subtotal
from		Sales.SalesOrderDetail
group by	SalesOrderID
having		SUM(OrderQty * UnitPrice) > 10000
order by	1

--36. mostrar las subcategorias de los productos que tienen dos o mas productos que cuestan menos de $150 
select		ProductSubcategoryID as 'Subcategoria de Producto',
			COUNT(*) as Cantidad
from		Production.Product
where		ListPrice < 150
group by	ProductSubcategoryID
having		COUNT(*) >= 2
order by	2 desc



--37. mostrar todos los codigos de categorias existentes junto con la cantidad de productos y el precio de lista promedio por cada uno de aquellos productos que cuestan mas de $70 y el precio promedio es mayor a $300 
select		ProductSubcategoryID as 'Subcategoria de Producto',
			COUNT(*) as cantidad,
			AVG(ListPrice) as 'Precio Promedio'
from		Production.Product
where		ListPrice > 70
group by	ProductSubcategoryID
having		AVG(ListPrice) > 300
order by	2 desc

--39.mostrar  los empleados que también son vendedores
select		e.*
from		HumanResources.Employee e
inner join	Sales.SalesPerson s
on			e.BusinessEntityID = s.BusinessEntityID

--40. mostrar  los empleados ordenados alfabeticamente por apellido y por nombre 
select		p.LastName + ' ' + p.FirstName as Empleado
from		Person.Person p
inner join	HumanResources.Employee e
on			e.BusinessEntityID = p.BusinessEntityID
order by	1

--41. mostrar el codigo de logueo, numero de territorio y sueldo basico de los vendedores 
select		e.LoginID 'Codigo de Logueo',
			s.TerritoryID 'Numero de Territorio',
			s.Bonus 'Sueldo Basico'
from		HumanResources.Employee e
inner join	Sales.SalesPerson s
on			e.BusinessEntityID = s.BusinessEntityID

--42.mostrar los productos que sean ruedas(subcategoria - Wheels)
select		*
from		Production.Product p
inner join	Production.ProductSubcategory ps
on			p.ProductSubcategoryID = ps.ProductSubcategoryID
where		ps.Name = 'Wheels'

-- 43. mostrar los nombres de los productos que no son bicicletas(subcategoria - bikes) 
select		*
from		Production.Product p
inner join	Production.ProductSubcategory ps
on			p.ProductSubcategoryID = ps.ProductSubcategoryID
where		ps.Name not like '%bikes%'

--44.mostrar los precios de venta de aquellos  productos donde el precio de venta sea inferior al precio de lista recomendado  para ese producto ordenados por nombre de producto
select		p.Name Producto,
			sd.UnitPrice 'Precio Unitario',
			p.ListPrice 'Precio de Lista'
from		Production.Product p
inner join	Sales.SalesOrderDetail sd
on			p.ProductID = sd.ProductID
where		sd.UnitPrice < p.ListPrice
order by	p.Name

--45. Mostrar todos los productos que tengan igual precio. Se deben mostrar de a pares. codigo y nombre de cada uno de los dos productos y el precio de ambos.ordenar por precio en forma descendente 
-- self join
select		p1.Name 'Producto 1', 
			p2.Name 'Producto 2',
			p1.ListPrice 'Precio 1',
			p2.ListPrice 'Precio 2'
from		Production.Product p1
inner join	Production.Product p2
on			p1.ListPrice = p2.ListPrice
where		p1.ProductID > p2.ProductID -- evita duplicados
order by	3 desc

use pubs
go
select		t1.title 'Libro 1', 
			t2.title 'Libro 2',
			t1.price 'Precio 1',
			t2.price 'Precio 2'
from		titles t1
inner join	titles t2
on			t1.price = t2.price
where		t1.title_id > t2.title_id
order by	t1.title



-- 47.mostrar el nombre de los productos y de los proveedores cuya subcategoria es 15 ordenados por nombre de proveedor 
use AdventureWorks2008R2
go

select		p.Name Producto,
			v.Name Proveedor
from		Production.Product p
inner join	Purchasing.ProductVendor pv on p.ProductID = pv.ProductID
inner join	Purchasing.Vendor v on pv.BusinessEntityID = v.BusinessEntityID
where		p.ProductSubcategoryID = 15
order by	v.Name

-- 48.mostrar todas las personas (nombre y apellido) y en el caso que sean empleados mostrar tambien el login id, sino mostrar null 
-- tabla ppal: Person.Person
-- Listar las personas que no son empleados
select			p.FirstName + ' ' + p.LastName 'Nombre Completo'
				-- ,e.LoginID as Login
from			Person.Person p
left outer join	HumanResources.Employee e
on				p.BusinessEntityID = e.BusinessEntityID
where			e.BusinessEntityID is null

-- 49. mostrar los vendedores (nombre y apellido) y el territorio asignado a c/u(identificador y nombre de territorio). En los casos en que un territorio no tiene vendedores mostrar igual los datos del territorio unicamente sin datos de vendedores
-- tabla ppal: SalesTerritory
select				p.FirstName + ' ' + p.LastName Vendedor,
					st.TerritoryID Identidicador,
					st.Name Territorio
from				Sales.SalesPerson sp
right outer join	Sales.SalesTerritory st on st.TerritoryID = sp.TerritoryID
inner join			Person.Person p on p.BusinessEntityID = sp.BusinessEntityID

-- 50.mostrar el producto cartesiano entre la tabla de vendedores cuyo numero de identificacion de negocio sea 280 y el territorio de venta sea el de francia
select		*
from		Sales.SalesPerson sp
cross join	Sales.SalesTerritory st
where		sp.BusinessEntityID = 280 
and			st.Name = 'France'

select * from [HumanResources].[EmployeeDepartmentHistory]

--51.listar todos las productos cuyo precio sea inferior al precio promedio de todos los productos 
select      * 
FROM        [Production].[Product]
where       ListPrice < (select avg(ListPrice) from [Production].[Product])
ORDER BY    ListPrice DESC

-- promedio de precio de los productos por categoria = 438,6662 USD

--52.listar el nombre, precio de lista, precio promedio y diferencia de precios entre cada producto y el valor promedio general 
SELECT          Name Producto, 
                ListPrice Precio, 
                (select avg(ListPrice) from Production.Product) as Promedio, 
                ListPrice - (select avg(ListPrice) from Production.Product) as Diferencia
FROM            Production.Product
ORDER BY        ListPrice DESC

-- 53. mostrar el o los codigos del producto mas caro 
SELECT      ProductID Codigo, 
            Name Producto,
            ListPrice Precio 
FROM        Production.Product
-- WHERE       ListPrice = (SELECT MAX(ListPrice) FROM Production.Product)
WHERE       ListPrice = 3578.27

-- valor maximo = 3578,27 USD


--54. mostrar el producto mas barato de cada subcategoría. mostrar subcategoria, codigo de producto y el precio de lista mas barato ordenado por subcategoria 
SELECT      psc.Name Subcategoria, 
            p.ProductID Codigo, 
            p.ListPrice Precio
FROM        Production.Product p
INNER JOIN  Production.ProductSubcategory psc 
ON          p.ProductSubcategoryID = psc.ProductSubcategoryID
WHERE       ListPrice = (
                            SELECT  MIN(ListPrice) 
                            FROM    Production.Product p2 
                            WHERE   p2.ProductSubcategoryID = psc.ProductSubcategoryID
                        )
ORDER BY    psc.Name


--55.mostrar los nombres de todos los productos presentes en la subcategoría de ruedas 

-- x join
SELECT      p.Name Producto
FROM        Production.Product p    
INNER JOIN  Production.ProductSubcategory psc 
ON          p.ProductSubcategoryID = psc.ProductSubcategoryID
WHERE       psc.Name = 'Wheels'

--x subconsulta
SELECT      Name Producto
FROM        Production.Product
WHERE       ProductSubcategoryID = (
                                        SELECT  ProductSubcategoryID 
                                        FROM    Production.ProductSubcategory 
                                        WHERE   Name = 'Wheels'
                                    )

--x subconsulta con EXISTS
SELECT      Name Producto
FROM        Production.Product p
WHERE       EXISTS (
                        SELECT  1 
                        FROM    Production.ProductSubcategory psc 
                        WHERE   psc.Name = 'Wheels' 
                                AND psc.ProductSubcategoryID = p.ProductSubcategoryID
                    )



--56.mostrar todos los productos que no fueron vendidos
-- X join
SELECT      p.Name Producto
FROM        Production.Product p
LEFT JOIN   Sales.SalesOrderDetail sod  
ON          p.ProductID = sod.ProductID
WHERE       sod.SalesOrderDetailID IS NULL

-- por subconsulta con exists
SELECT      Name Producto
FROM        Production.Product p
WHERE       NOT EXISTS (
                            SELECT  1 
                            FROM    Sales.SalesOrderDetail sod 
                            WHERE   sod.ProductID = p.ProductID
                        )   


-- 58.mostrar todos los vendedores (nombre y apellido) que no tengan asignado un territorio de ventas 

-- x join
SELECT      p.FirstName + ' ' + p.LastName as Vendedor
FROM        Person.Person p
INNER JOIN  Sales.SalesPerson sp
ON          p.BusinessEntityID = sp.BusinessEntityID
LEFT JOIN   Sales.SalesTerritory st
ON          st.TerritoryID = sp.TerritoryID
WHERE       st.TerritoryID IS NULL

-- por subconsulta con exists
SELECT      p.FirstName + ' ' + p.LastName as Vendedor
FROM        Person.Person p
INNER JOIN  Sales.SalesPerson sp
ON          p.BusinessEntityID = sp.BusinessEntityID
WHERE       NOT EXISTS (
                            SELECT  1 
                            FROM    Sales.SalesTerritory st 
                            WHERE   st.TerritoryID = sp.TerritoryID
                        )

|

--59. mostrar las ordenes de venta que se hayan facturado en territorio de estado unidos unicamente 'us' 
-- por join
SELECT      soh.*
FROM        Sales.SalesOrderHeader AS soh
INNER JOIN  Sales.SalesTerritory AS st ON soh.TerritoryID = st.TerritoryID
WHERE       st.CountryRegionCode = 'US'

-- por subconsulta
SELECT      *
FROM        Sales.SalesOrderHeader 
WHERE       TerritoryID IN (SELECT TerritoryID 
                                FROM Sales.SalesTerritory 
                                WHERE CountryRegionCode = 'US')


-- 60. al ejercicio anterior agregar ordenes de francia e inglaterra
SELECT      *
FROM        Sales.SalesOrderHeader 
WHERE       TerritoryID IN (SELECT TerritoryID 
                                FROM Sales.SalesTerritory 
                                WHERE CountryRegionCode IN ('US', 'FR', 'GB'))

--61.mostrar los nombres de los diez productos mas caros. Utilizr subconsultas con operador IN
SELECT      Name, ListPrice
FROM        Production.Product
WHERE       ListPrice IN (  SELECT TOP 10 ListPrice 
                            FROM Production.Product 
                            ORDER BY ListPrice DESC
                        )

--62.mostrar aquellos productos cuya cantidad de pedidos de venta sea igual o superior a 20 utilizando subconsultas con operador IN
SELECT      Name, ProductID
FROM        Production.Product
WHERE       ProductID IN (  SELECT ProductID
                            FROM Sales.SalesOrderDetail 
                            GROUP BY ProductID 
                            HAVING COUNT(*) >= 20
                        )

--63. listar el nombre y apellido de los empleados que tienen un sueldo basico de 5000 pesos. Utilizar subconsultas con operador IN
SELECT      p.FirstName +' '+ p.LastName as Empleado
FROM        HumanResources.Employee e
INNER JOIN  Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
WHERE       e.BusinessEntityID IN   (   SELECT BusinessEntityID 
                                        FROM Sales.SalesPerson   
                                        WHERE Bonus = 5000
                                    ) 

-- 64.mostrar los nombres de todos los productos de ruedas que fabrica adventure works cycles. Resolver por subconsulta con =any
SELECT Name producto
FROM Production.Product
WHERE ProductSubcategoryID =ANY (	SELECT	ProductSubcategoryID
									FROM	Production.ProductSubcategory
									WHERE	Name = 'Wheels')

--65.mostrar los clientes ubicados en un territorio no cubierto por ningún vendedor
-- por subconsulta con operador <>ALL
SELECT *
FROM Sales.Customer 
-- WHERE TerritoryID NOT IN (SELECT TerritoryID FROM Sales.SalesPerson)
WHERE TerritoryID != ALL (SELECT TerritoryID FROM Sales.SalesPerson) 

--66. listar los productos cuyos precios de venta sean mayores o iguales que el precio de venta máximo de cualquier subcategoría de producto. Por subconsulta con operador >=ANY
SELECT Name producto, ListPrice
FROM Production.Product
WHERE ListPrice >= ANY (SELECT MAX(ListPrice)
						FROM Production.Product
						GROUP BY ProductSubcategoryID)


67.listar el nombre de los productos, el nombre de la subcategoria a la que pertenece junto a su categoría de precio. La categoría de precio se calcula de la siguiente manera. 
	-si el precio está entre 0 y 1000 la categoría es económica.
	-si la categoría está entre 1001 y 2000, normal 
	-y si su valor es mayor a 2000 la categoría es cara.
*/
SELECT      p.Name producto,
            p.ListPrice Precio,
            ps.Name subcategoria,
            (CASE 
                WHEN ListPrice BETWEEN 0 AND 1000 THEN 'Economica'
                WHEN ListPrice BETWEEN 1001 AND 2000 THEN 'Normal'
                ELSE 'Cara'
            END) as categoria
FROM        Production.Product p
INNER JOIN  Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
ORDER BY    p.ListPrice DESC


--68.tomando el ejercicio anterior, mostrar unicamente aquellos productos cuya categoria sea "economica"
SELECT  *
FROM    (   SELECT  p.Name producto,
                    p.ListPrice Precio,
                    ps.Name subcategoria,
                    (CASE 
                        WHEN ListPrice BETWEEN 0 AND 1000 THEN 'Economica'
                        WHEN ListPrice BETWEEN 1001 AND 2000 THEN 'Normal'
                        ELSE 'Cara'
                    END) as categoria
            FROM        Production.Product p
            INNER JOIN  Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        ) as subconsulta
WHERE   subconsulta.categoria = 'Economica'

-- insert, update y delete

-- 69.aumentar un 20% el precio de lista de todos los productos  
UPDATE Production.Product
SET ListPrice = ListPrice * 1.2

--70.aumentar un 20% el precio de lista de los productos del proveedor 1540
UPDATE Production.Product
SET ListPrice = ListPrice * 1.2
WHERE ProductID IN (SELECT ProductID 
                    FROM Purchasing.ProductVendor 
                    WHERE BusinessEntityID = 1540)

-- por join
UPDATE p
SET ListPrice = ListPrice * 1.2
FROM Production.Product p
INNER JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
WHERE pv.BusinessEntityID = 1540 


-- 71.agregar un dia de vacaciones a los 10 empleados con mayor antiguedad.
UPDATE  e
SET     VacationHours = VacationHours + 24
FROM    HumanResources.Employee e
WHERE   BusinessEntityID IN     (
                                    SELECT TOP 10   BusinessEntityID 
                                    FROM            HumanResources.Employee 
                                    ORDER BY        HireDate
                                )

--72. eliminar los detalles de compra (purchaseorderdetail) cuyas fechas de vencimiento pertenezcan al tercer trimestre del año 2006
DELETE FROM Purchasing.PurchaseOrderDetail
-- WHERE DueDate BETWEEN '2006-07-01' AND '2006-09-30'
WHERE YEAR(DueDate) = 2006 AND MONTH(DueDate) BETWEEN 7 AND 9

--73.quitar registros de la tabla salespersonquotahistory cuando las ventas del año hasta la fecha almacenadas en la tabla salesperson supere el valor de 2500000
DELETE FROM Sales.SalesPersonQuotaHistory
WHERE       BusinessEntityID IN (
                                    SELECT BusinessEntityID 
                                    FROM Sales.SalesPerson 
                                    WHERE SalesYTD > 2500000
                                )


-- 74. clonar estructura y datos de los campos nombre ,color y precio de lista de la tabla production.product en una tabla llamada productos
use [AdventureWorks2008R2] 

SELECT Name, Color, ListPrice
INTO 	productos
FROM	Production.product

select * from productos

-- 75. clonar solo estructura de los campos identificador ,nombre y apellido de la tabla person.person en una tabla llamada personas 
SELECT BusinessEntityID, FirstName, LastName
INTO 	personas	
FROM	person.Person
WHERE 	1=2

SELECT * FROM personas

--76.insertar un producto dentro de la tabla productos.tener en cuenta los siguientes datos. el color de producto debe ser rojo, el nombre debe ser "bicicleta mountain bike" y el precio de lista debe ser de 4000 pesos.
INSERT INTO productos (Name, Color, ListPrice)
VALUES ('bicicleta mountain bike', 'rojo', 4000)

select * from productos

--77. copiar los registros de la tabla person.person a la tabla personas cuyo identificador este entre 100 y 200
INSERT INTO personas (BusinessEntityID, FirstName, LastName)
SELECT BusinessEntityID, FirstName, LastName
FROM person.Person
WHERE BusinessEntityID BETWEEN 100 AND 200

--78. aumentar en un 15% el precio de los pedales de bicicleta
UPDATE productos
SET ListPrice = ListPrice * 1.15
WHERE Name LIKE '%pedal%'

SELECT * FROM productos
WHERE Name LIKE '%pedal%'

--79. eliminar de las personas cuyo nombre empiecen con la letra m
DELETE FROM personas
WHERE FirstName LIKE 'm%'

SELECT * FROM personas

--80. borrar todo el contenido de la tabla productos
DELETE FROM productos

--81. borrar todo el contenido de la tabla personas sin utilizar la instrucción delete.
TRUNCATE TABLE personas


--82: Crear un procedimiento almacenado que dada una determinada inicial ,devuelva codigo, nombre,apellido y direccion de correo de los empleados cuyo nombre coincida con la inicial ingresada

 CREATE PROCEDURE InformarEmpleadosPorInicial(@inicial char(1))
 AS 
    BEGIN
        SELECT		BusinessEntityID as Codigo, 
                    FirstName +' '+ LastName as Empleado, 
                    EmailAddress as 'Correo Electronico'
        FROM		HumanResources.vEmployee
        WHERE		FirstName LIKE @inicial + '%'
        ORDER BY	FirstName
    END

GO
EXECUTE InformarEmpleadosPorInicial @inicial='a'
EXECUTE InformarEmpleadosPorInicial @inicial='j'
EXECUTE InformarEmpleadosPorInicial @inicial='m'


--83: Crear un procedimiento almacenado que devuelva los productos que lleven de fabricado la cantidad de dias que le 
pasemos como parametro

create Procedure TiempoDeFabricacion(@dias int = 1)
AS
    BEGIN
        SELECT	    Name, ProductNumber, DaysToManufacture
        FROM		Production.Product
        WHERE		DaysToManufacture = @dias
    END
GO

EXECUTE TiempoDeFabricacion @dias=2
EXECUTE TiempoDeFabricacion @dias=4
EXECUTE TiempoDeFabricacion @dias=5 
EXECUTE TiempoDeFabricacion


84: Crear un procedimiento almacenado que permita actualizar y ver los precios de un determinado 
producto que reciba como parametro

CREATE PROCEDURE ActualizarPrecios
(@cantidad as float,@codigo as int)
AS
    BEGIN
        UPDATE Production.Product
        SET ListPrice = ListPrice*@cantidad
        WHERE ProductID=@codigo

        SELECT Name,ListPrice
        FROM Production.Product
        WHERE ProductID=@codigo
    END

GO
EXECUTE ActualizarPrecios 1.1, 886

SELECT listPrice from production.Product
WHERE ProductID=886 -- Antes: 366,762  Despues: 403,4382


--85: Armar un procedimineto almacenado que devuelva los proveedores que proporcionan el producto especificado por parametro

CREATE PROCEDURE Proveedores(@producto varchar(30)='%')
AS
    
    SELECT      v.Name proveedor,
                p.Name producto 
    
    FROM        Purchasing.Vendor AS v 
    INNER JOIN  Purchasing.ProductVendor AS pv
    ON          v.BusinessEntityID = pv.BusinessEntityID 
    INNER JOIN  Production.Product AS p 
    ON          pv.ProductID = p.ProductID 
    WHERE       p.Name LIKE @producto
    ORDER BY    v.Name 
GO    

EXECUTE Proveedores 'r%'
EXECUTE Proveedores 'reflector'
EXECUTE Proveedores 


--86: Crear un procedimiento almacenado que devuelva nombre,apellido y sector del empleado que le 
pasemos como argumento.no es necesario pasar el nombre y apellido exactos al procedimiento.
 
CREATE PROCEDURE empleados
    @apellido nvarchar(50)='%', 
    @nombre nvarchar(50)='%' 
AS 
    SELECT FirstName, LastName,Department
    FROM HumanResources.vEmployeeDepartmentHistory
    WHERE FirstName LIKE @nombre AND LastName LIKE @apellido
GO

EXECUTE empleados  'eric%' 
EXECUTE empleados



--FUNCIONES ESCALARES

--87: Armar una funcion que devuelva los productos que estan por encima del promedio de precios general

CREATE FUNCTION promedio()
RETURNS MONEY
AS
BEGIN
        DECLARE @promedio MONEY
        SELECT @promedio=AVG(ListPrice) FROM Production.Product
        RETURN @promedio
END


--uso de la funcion
SELECT  * 
FROM    Production.Product 
WHERE   ListPrice >dbo.promedio()

SELECT AVG(ListPrice) FROM Production.Product --438.6662


--88: Armar una función que dado un código de producto devuelva el total de ventas para dicho producto.Luego, mediante una consulta, traer codigo, nombre y total de ventas ordenados por esta ultima columna

CREATE FUNCTION VentasProductos(@codigoProducto int) 
RETURNS int
AS
 BEGIN
   DECLARE @total int
   SELECT @total = SUM(OrderQty)
   FROM Sales.SalesOrderDetail WHERE ProductID = @codigoProducto
   IF (@total IS NULL)
      SET @total = 0
   RETURN @total
 END
 
--uso de la funcion
SELECT      ProductID "codigo producto",
            Name nombre,
            dbo.VentasProductos(ProductID) AS "total de ventas"
FROM        Production.Product
ORDER BY    3 DESC

--89: Armar una función que dado un año , devuelva nombre y  apellido de los empleados que ingresaron ese año

CREATE FUNCTION AñoIngresoEmpleados (@año int)
RETURNS TABLE
AS
	RETURN
	(
		SELECT FirstName, LastName,HireDate
		FROM Person.Person p
		INNER JOIN HumanResources.Employee e
		ON e.BusinessEntityID= p.BusinessEntityID
		WHERE year(HireDate)=@año
	)
	
--uso de la funcion
SELECT * FROM dbo.AñoIngresoEmpleados(2004)-- 45
SELECT * FROM dbo.AñoIngresoEmpleados(2000)-- 1

--90: Armar una función que dado el codigo de negocio cliente de la fabrica, devuelva el codigo, nombre y las ventas del año hasta la fecha para cada producto vendido en el negocio ordenadas por esta ultima columna.

CREATE FUNCTION VentasNegocio (@codNegocio int)
RETURNS TABLE
AS
RETURN 
(
    SELECT P.ProductID, P.Name, SUM(SD.LineTotal) AS 'Total'
    FROM Production.Product AS P 
    JOIN Sales.SalesOrderDetail AS SD ON SD.ProductID = P.ProductID
    JOIN Sales.SalesOrderHeader AS SH ON SH.SalesOrderID = SD.SalesOrderID
    JOIN Sales.Customer AS C ON SH.CustomerID = C.CustomerID
    WHERE C.StoreID = @codNegocio
    GROUP BY P.ProductID, P.Name
    
)

--uso de la funcion
SELECT		* 
FROM		dbo.VentasNegocio (1340)
ORDER BY	3 DESC;

--91: Crear una  función llmada "ofertas" que reciba un parámetro correspondiente a un precio y nos retorne una 
tabla con código,nombre, color y precio de todos los productos cuyo precio sea inferior al parámetro ingresado


 CREATE FUNCTION ofertas(@minimo decimal(6,2))
 RETURNS @oferta table
 (codigo int,
  nombre varchar(40),
  color varchar(30),
  precio decimal(6,2)
 )
 AS
	 BEGIN
	    INSERT @oferta
		SELECT	ProductID,Name,Color,ListPrice
		FROM	Production.Product
		WHERE	ListPrice<@minimo
	    RETURN
	 END

--uso de la funcion

 SELECT *
 FROM	dbo.ofertas(1)


 --92: Mostrar la cantidad de horas que transcurrieron desde el comienzo del año

SELECT DATEDIFF(HOUR, '01-01-2000',GETDATE())


--93: Mostrar la cantidad de dias transcurridos entre la primer y la ultima venta 

SELECT	DATEDIFF(DAY,(SELECT MIN(OrderDate)FROM Sales.SalesOrderHeader),
					 (SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader))





