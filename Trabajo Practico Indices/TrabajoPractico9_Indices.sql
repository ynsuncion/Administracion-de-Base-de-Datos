-- EJERCITACI?N

-- 1-Crear una tabla llamada alumnos con los siguientes campos:
  
  /*legajo: char(5) not null
  documento: char(8) not null
  apellido: varchar(30)
  nombre: varchar(30)
  nota: decimal(4,2) */

  create database Escuela 

  use Escuela

  create table alumnos (
  legajo char(5) not null,
  documento char(8) not null,
  apellido varchar(30),
  nombre varchar(30),
  nota decimal(4,2)
  );

  -- 2-Ingresar 6 registros con, al menos, 2 registros con igual apellido.

  INSERT INTO alumnos (legajo, documento, apellido, nombre, nota)
VALUES
('A0001', '30111222', 'Perez', 'Juan', 8.50),
('A0002', '28999888', 'Gonzalez', 'Maria', 7.25),
('A0003', '41222333', 'Perez', 'Lucas', 9.10),
('A0004', '33444555', 'Martinez', 'Ana', 6.75),
('A0005', '35666777', 'Perez', 'Sofia', 8.90),
('A0006', '27888999', 'Ramirez', 'Diego', 5.50);


--  3-Intente crear un ?ndice agrupado ?nico para el campo "apellido".

create unique clustered index apellido
 on alumnos (apellido)

 --No se puede crear porque un apellido se repite 

 -- 4-Cree un ?ndice agrupado, no ?nico, para el campo "apellido".
 create clustered index apellido_nounico
 on alumnos(apellido)

 -- 5-Intente establecer una restricción "primary key" al campo 
 -- "legajo" especificando que cree un índice agrupado.

  alter table alumnos
  add constraint PK_legajo
  primary key clustered (legajo)

  -- No se puede porque no se puede crear mas de un índice agrupado por tabla

--  6-Establezca la restricción "primary key" al campo "legajo"
-- especificando que cree un índice no agrupado.

	alter table alumnos 
	add constraint PK_alumnos_legajo
	primary key nonclustered (legajo)


-- 7-Vea los índices y las restricciones de la tabla alumnos:

	EXEC sp_helpindex alumnos 

-- 8-Cree un índice unique no agrupado para el campo "documento".

 create unique nonclustered index I_documento -- nombre del indice
 on alumnos(documento) -- tabla (el campo de la tabla)

-- 9-Intente ingresar un alumno con documento duplicado.
	INSERT INTO alumnos (legajo, documento, apellido, nombre, nota)
	VALUES ('A0007', '30111222', 'Lopez', 'Carlos', 7.80);

-- 10-Elimine el indice agrupado al campo apellido.

DROP INDEX apellido_nounico
ON alumnos;
	
-- 11-Regenere el indice del campo legajo para que sea agrupado.
alter table alumnos 
drop constraint PK_alumnos_legajo
go

alter table alumnos 
add constraint pk_alumnos_legajo
primary key clustered (legajo)
go

exec sp_helpindex alumnos
go 
exec sp_helpconstraint alumnos 
go


