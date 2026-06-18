-- GROUP BY y HAVING
use [AdventureWorks2008R2]
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


--JOINS

create database empresa
go
use empresa
go
create table sucursales(suc_id int, suc_nombre varchar(20))
create table empleados(emp_id int, emp_nombre varchar(20), suc_id int)
go
insert into sucursales values(1,'Centro'),(2,'Congreso'),(3,'Almagro'),(4,'Palermo')
go
insert into empleados values(1,'Juan',1),(2,'Jose',2),(3,'Carlos',2),(4,'Maria',null)
go
select * from sucursales
select * from empleados

-- listar el nombre de las sucursales y de los empleados que trabajan en ellas
select		suc_nombre, emp_nombre
from		sucursales as s
inner join	empleados e
on			s.suc_id = e.suc_id

-- no ANSI
select		suc_nombre, emp_nombre
from		sucursales as s, empleados e
where		s.suc_id = e.suc_id

-- producto cartesiano
select		suc_nombre, emp_nombre
from		sucursales, empleados

select		suc_nombre, emp_nombre
from		sucursales
cross join	empleados

-- listar los empleados que no trabajan en ninguna sucursal
-- tabla ppal: empleados
select		e.emp_nombre
			--, s.*
from		sucursales s right join empleados e
on			e.suc_id = s.suc_id
where		s.suc_id is null