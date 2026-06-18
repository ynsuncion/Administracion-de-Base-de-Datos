-- Variables

/* declaracion, inicializacion e impresion */
declare @nombre as nvarchar(20)
set @nombre = 'Juan'
--select @nombre /*muestra como resultado de query*/
print @nombre/*muestra como mensaje*/

/* condicional if */
declare @nombre as nvarchar(20)
set @nombre = 'Juan'
if (@nombre = 'Juan')
	begin
		print 'Es Juan'
	end
else
	begin
		print 'no es juan'
	end 
 
 /* bucle while */
declare @valor as int
set @valor = 1
while(@valor<=10) 
	begin
		print @valor
		set @valor=@valor+1
	 end
 
/* variable que almacena query */
use pubs
go

declare @maximo as int
declare @minimo as int

select @maximo = max(price),/* por ser mezcla entre query y variable debe ir select NO set*/
       @minimo = min (price)
from titles

select @maximo
select @minimo

/* variables y funciones del sistema */
select @@servername /*variables del sistema*/

select @@max_connections

select getdate()/*funciones del sistema*/