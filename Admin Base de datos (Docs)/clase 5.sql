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


-- Subconsultas = subqueries = subselect = consultas anidadas

-- formato de datos devueltos x una subconsulta
-- escalares (un unico valor)
-- lista de valores
-- tabla de valores

/*
	SELECT	(escalar)
	FROM	(tabla de valores)
	WHERE	(escalar) (lista de valores)
	GROUP BY -
	HAVING	(escalar)
	ORDER BY -

*/































