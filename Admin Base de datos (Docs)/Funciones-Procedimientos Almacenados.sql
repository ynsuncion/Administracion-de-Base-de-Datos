--Funciones
--funciones escalares

-- devolver todos los libros cuyo precio sea mayor al promedio

use pubs
go

SELECT *
FROM titles
WHERE price>(SELECT avg(price) FROM titles)

CREATE FUNCTION promedio()
returns money
as
BEGIN
		declare @promedio money
		select @promedio=avg(price) from titles
		return @promedio
END

select * from titles where price >dbo.promedio()

drop function promedio

--funcion escalar con pasaje por parametros

CREATE FUNCTION promedio_2(@categoria varchar(30))
returns money
as
BEGIN

		declare @promedio money
		select @promedio=avg(price) from titles where type=@categoria
		return @promedio
END

select * from titles where price > dbo.promedio_2(type)

drop function promedio_2


-- funciones de tabla en linea

CREATE FUNCTION autoresLibros(@cat varchar(30))
returns table
as
	return (SELECT		a.au_id,
						a.au_fname,
						a.au_lname,
						a.state,
						t.pub_id,
						t.type,
						t.price
					

			FROM		authors a
			INNER JOIN	titleauthor ta
			ON			a.au_id=ta.au_id
			INNER JOIN	titles t
			ON			ta.title_id=t.title_id)


SELECT * FROM autoresLibros('business')

drop function autoresLibros

--variables de tipo tabla

declare @t table(codigo int,nombre varchar(200))

insert into @t
select 1,'juan'

insert into @t
select 2,'pepe'

select * from @t


--funciones de multisentencia

CREATE FUNCTION fnMultisentencia()
returns @t table(codigo int,nombre varchar(200))
as
BEGIN

		insert into @t
		select 1,'juan'

		insert into @t
		select 2,'pepe'

		insert into @t
		select 3,'martin'

		return
END

select * from dbo.fnMultisentencia()

drop function fnMultisentencia



--Procedimientos Almacenados

CREATE PROCEDURE listarLibros
as
BEGIN
	select *
	from titles
END

exec listarLibros

drop procedure listarLibros

--otro
use AdventureWorks2008R2
go

--El siguiente ejemplo muestra como se puede crear un procedimiento que devuelve un
--conjunto de registros de todos los productos que llevan m�s de un d�a de fabricaci�n.
CREATE PROC Production.LongLeadProducts
AS
  SELECT Name, ProductNumber, DaysToManufacture
  FROM Production.Product
  WHERE DaysToManufacture >= 1
  ORDER BY DaysToManufacture DESC, Name
GO