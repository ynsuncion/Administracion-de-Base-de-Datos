-- Transacciones; Trabajo Práctico 6 

-- Sobre la base AdventureWorks
-- 1. Borrar todos los productos que no se hayan vendido y luego revertir la operación.
use AdventureWorks2008R2
begin tran

    delete pp
    from Production.Product pp
    where not exists(
                    select 1
                    from Sales.SalesOrderDetail so
                    where pp.ProductID = so.ProductID
    )
    ROLLBACK

-- 2. Incrementar el precio a 200 para todos los productos cuyo precio sea igual a cero y confirmar la transacción.

begin tran
    update Production.Product
    set ListPrice = 200
    where ListPrice = 0
COMMIT

-- 3. Obtener el promedio del listado de precios y guardarlo en una variable llamada @Promedio. Incrementar todos los productos un 15% pero si el precio mínimo no supera el promedio revertir toda la operación.

begin tran 
    declare @prom money;
    select @prom = avg(ListPrice) from Production.Product

update Production.Product
set ListPrice = ListPrice * 1.15

if @prom < (select min(ListPrice) from Production.Product)
    ROLLBACK
ELSE
    COMMIT TRANSACTION