create database prueba
go
use prueba

--CREACION DE INDICES

create table libros(
  codigo int identity,
  titulo varchar(40),
  autor varchar(30),
  editorial varchar(15)
 )

--Creamos un índice agrupado único para el campo "codigo" de la tabla "libros":

 create unique clustered index I_libros_codigo
 on libros(codigo)

--Creamos un índice no agrupado para el campo "titulo":

 create nonclustered index I_libros_titulo
 on libros(titulo)

--Veamos los indices de "libros":

 sp_helpindex libros

--Aparecen 2 filas, uno por cada índice. Muestra el nombre del índice, si es agrupado (o no),
--primary (o unique) y el campo por el cual se indexa.

--Creamos una restricción "primary key" al campo "codigo" especificando que cree un índice 
--NO agrupado:

  alter table libros
  add constraint PK_libros_codigo
  primary key nonclustered (codigo)

--Verificamos que creó un índice automáticamente:

 sp_helpindex libros

--El nuevo índice es agrupado, porque no se especificó.

--Analicemos la información que nos muestra "sp_helpconstraint":

 sp_helpconstraint libros
 

--En la columna "constraint_type" aparece "PRIMARY KEY" y entre paréntesis, el tipo de índice
--creado.

--Creamos un índice compuesto para el campo "autor" y "editorial":

 create index I_libros_autoreditorial
 on libros(autor,editorial)

--Se creará uno no agrupado porque no especificamos el tipo, además, ya existe uno agrupado y
--solamente puede haber uno por tabla.

--Consultamos la tabla "sysindexes":

 select name from sysindexes

--Veamos los índices de la base de datos activa creados por nosotros podemos tipear la siguien
--te consulta:

 select name from sysindexes
 where name like 'I_%'
 
 
 drop table libros
 
 
 
--REGENERACION DE INDICES
 
  create table libros(
  codigo int identity,
  titulo varchar(40),
  autor varchar(30),
  editorial varchar(15)
 )

--Creamos un índice no agrupado para el campo "titulo":

 create nonclustered index I_libros_titulo
 on libros(titulo)

--Veamos la información:

 sp_helpindex libros
 
 
--Empleando la opción "drop_existing" junto con "create index" permite regenerar un 
--índice, con ello evitamos eliminarlo y volver a crearlo.
--Vamos a agregar el campo "autor" al índice "I_libros_titulo" y vemos si se modificó:

 create index I_libros_titulo
 on libros(titulo,autor)
 with drop_existing

 exec sp_helpindex libros

--Lo convertimos en agrupado y ejecutamos "sp_helpindex":

 create clustered index I_libros_titulo
 on libros(titulo,autor)
 with drop_existing

 exec sp_helpindex libros

--Quitamos un campo "autor" y verificamos la modificación:

 create clustered index I_libros_titulo
 on libros(titulo)
 with drop_existing

 exec sp_helpindex libros
 
 
 
--ELIMINACION DE INDICES
 
 
 --Eliminamos el índice "I_libros_titulo":

 drop index libros.I_libros_titulo

--Verificamos que se eliminó:

 sp_helpindex libros

--Solicitamos que se elimine el índice "I_libros_titulo" si existe:

 if exists (select name from sysindexes
  where name = 'I_libros_titulo')
   drop index libros.I_libros_titulo


 
 
 
 
