--Cursores

--procedimiento que aumenta un 10% el precio de los libros con precio menor a 10$
--y baja un 10% el precio de los libros con precio igual o mayor a 10$

use pubs
go

CREATE PROCEDURE aumentarPrecio
as
BEGIN
	declare @price as float,@id as tid
	declare titulo cursor for
	
	select title_id,price
	from titles
	
	open titulo
	fetch next  from titulo into @id,@price

	while (@@fetch_status=0)
		begin
			if @price<10
				begin
					update titles
					set price=price*1.1
					where title_id=@id
				end
			else
				begin
					update titles
					set price=price*0.9
					where title_id=@id
				end			
		fetch next  from titulo into @id,@price
		end


	close titulo
	deallocate  titulo
	
END


EXEC aumentarPrecio 

select * from titles

drop proc aumentarPrecio





