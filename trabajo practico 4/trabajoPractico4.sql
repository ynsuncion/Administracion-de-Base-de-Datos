-- Procedimientos Almacenados; Trabajo Práctico 4

use AdventureWorks2008R2;
-- 1. Crear un procedimiento almacenado en el esquema HumanResources que dada una determinada inicial, devuelva codigo, nombre, apellido y dirección de correo de los empleados cuyo nombre coincida con la inicial ingresada.

-- Vistas: HumanResources.vEmployee
-- Campos: BusinessEntityID, FirstName, LastName, EmailAddress

select * from HumanResources.vEmployee
go
create procedure BuscarEmpleados
    @inicial char(1)
AS
begin
    select  BusinessEntityID, FirstName + ' '+ LastName, EmailAddress
    from HumanResources.vEmployee 
    where FirstName like @inicial+'%'
    order by FirstName
end

-- drop procedure BuscarEmpleados;
exec BuscarEmpleados @inicial = m;

-- 2. Crear un procedimiento almacenado llamado ProductoVendido que permita ingresar un producto como parámetro, si el producto ha sido vendido imprimir el mensaje “El PRODUCTO HA SIDO VENDIDO” de lo contrario imprimir “El PRODUCTO NO HA SIDO VENDIDO”

-- Tablas: Sales.SalesOrderDetail
-- Campos: ProductID

select * from Sales.SalesOrderDetail
select * from Production.Product

go
create procedure ProductoVendido
    @producto nvarchar(50)
as
BEGIN
    IF EXISTS(  select pp.ProductID 
                from Production.Product pp 
                join Sales.SalesOrderDetail sod on pp.ProductID = sod.ProductID
                where pp.Name = @producto)
        PRINT 'El PRODUCTO HA SIDO VENDIDO'
    else
    print 'El PRODUCTO NO HA SIDO VENDIDO'
END

-- drop procedure ProductoVendido;
EXEC ProductoVendido @producto ='Mountain-100 Black, 42'; -- Producto Vendido
EXEC ProductoVendido @producto ='Bearing Ball'; -- Producto Vendido


-- 3. Crear un procedimiento almacenado en el esquema dbo para la actualización de precios llamado ActualizaPrecio recibiendo como parámetros el producto y el precio.

-- Tablas: Production.Product
-- Campos: ProductID, Name, ListPrice



-- 4. Crear un procedimiento almacenado llamado ProveedorProducto que devuelva los proveedores, el nombre del producto y el número de cuenta, y el código de unidad de medida que proporciona el producto especificado por parámetro.

-- Tablas: Purchasing.Vendor, Purchasing.ProductVendor, Production.Product
-- Campos: Name, AccountNumber, UnitMeasureCode

select* from Purchasing.Vendor;
select* from Purchasing.ProductVendor;
select* from Production.Product;
go
create procedure ProveedorProducto
    @UnitMeasureCode nvarchar(4)
AS
BEGIN
    select pp.Name, pv.AccountNumber, ppv.UnitMeasureCode
    from Production.Product pp
    join Purchasing.ProductVendor ppv on pp.ProductID = ppv.ProductID
    join Purchasing.Vendor pv on ppv.BusinessEntityID = pv.BusinessEntityID
    where ppv.UnitMeasureCode like @UnitMeasureCode 
END

EXEC ProveedorProducto @UnitMeasureCode ='ctn';

-- 5. Crear un procedimiento almacenado llamado EmpleadoSector que devuelva
-- nombre, apellido y sector del empleado que le pasemos como argumento. No es necesario pasar el nombre y apellido exactos al procedimiento.

-- Vistas: HumanResources.vEmployeeDepartmentHistory
-- Campos: FirstName, LastName,Department
select * from HumanResources.vEmployeeDepartmentHistory;
go
create procedure EmpleadoSector
    @EmpleadoBuscado nvarchar(50)
as
begin
    select FirstName + ' ' + LastName Empleado,Department
    from HumanResources.vEmployeeDepartmentHistory
    where FirstName like '%' + @EmpleadoBuscado + '%' or LastName like '%' + @EmpleadoBuscado + '%'
    order by FirstName
end

-- drop procedure EmpleadoSector;
exec EmpleadoSector @EmpleadoBuscado =''