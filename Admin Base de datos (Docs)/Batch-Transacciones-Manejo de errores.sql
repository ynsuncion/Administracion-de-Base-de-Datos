/*
Ejecuci�n de sentencias SQL:
�	Din�micos
�	Batch
�	Transacci�n
�	Scripts
*/

--Din�micos: son generadas durante la ejecuci�n de un script. 
--por ejemplo se puede generar un store procedure con variables para construir una sentencia SELECT que incorpore esas variables

DECLARE @tabla varchar(20), @bd varchar(20)
SET @tabla = 'authors'
SET @bd = 'pubs'
EXECUTE ('USE '+ @bd + ' SELECT * FROM ' + @tabla )

--Ejemplo:

DECLARE @tabla varchar(20), @bd varchar(20),@campo varchar(20),@funcion varchar (20)
set @funcion='avg(price)'
set @campo='type'
SET @tabla = 'sales'
SET @bd = 'pubs'

if(@tabla = 'titles')
	begin
		EXECUTE ('USE '+ @bd + ' SELECT '+ @campo + @funcion +'promedio '  +' FROM ' + @tabla+' GROUP BY '+@campo )
	end
	
else
	begin
		set @funcion='sum(qty)'
		set @campo='stor_id'
		SET @tabla = 'sales'
		EXECUTE ('USE '+ @bd + ' SELECT '+ @campo+' tienda, '+@funcion +'ventas '  +' FROM ' + @tabla+' GROUP BY '+@campo )
	end



--Batch: ejecuci�n de varias sentencias juntas.
--mejoran el performance de SQL Server debido a que compila y ejecuta todo junto


SELECT MAX(price) AS 'M�ximo precio'
FROM titles
PRINT ''
SELECT MIN(price) AS 'Menor precio' 
FROM titles
PRINT ''
SELECT AVG(price) AS 'Precio promedio'
FROM titles
GO

--Transacciones: se ejecutan como un bloque
--si alguna sentencia falla, no se ejecuta nada del bloque

BEGIN TRANSACTION
			update clientes
			set categoria=categoria+1
			where nombre='carlos'
COMMIT TRANSACTION --rollback transacction deshace la operacion


--Clausulas try catch:permite manejar de modo seguro transacciones

BEGIN TRY
			PRINT 'Continuo OK';
END TRY
BEGIN CATCH
			RAISERROR('mensaje de error',16,1)
			--Eleva un error a la aplicaci�n o batch que lo llamo 
			--RAISERROR ( { msg_id | msg_str } { , severidad , estado }  ] 
			--msg_id: N�mero de error en la tabla sysmessages
			PRINT 'fallo el proceso'
END CATCH


--try catch con transacciones

create database dml
go
use dml


create table clientes(
						codigo int identity(1,1),
						nombre varchar(40) not null,
						dni int not null unique,
						sexo char(1) not null default 'F',
						categoria int not null check (categoria between 1 and 10) 
  
						);
						

select * from clientes

insert into clientes (nombre,dni,sexo,categoria)
values	('carlos',25765981,'M',6)

insert into clientes (nombre,dni,sexo,categoria)
values	('jose',24578965,'M',3)

insert into clientes (nombre,dni,categoria)
values	('maria',19653827,8)

insert into clientes (nombre,dni,categoria)
values	('mariana',20123456,5)


BEGIN TRY
		BEGIN TRAN
			update clientes
			set categoria=categoria+1
			where nombre='carlos'
		COMMIT TRAN
END TRY
BEGIN CATCH
		ROLLBACK TRAN
		PRINT 'fallo el proceso'
END CATCH