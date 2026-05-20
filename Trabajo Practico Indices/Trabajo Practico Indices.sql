-- EJERCITACIÓN

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


--  3-Intente crear un índice agrupado único para el campo "apellido".

create unique clustered index apellido
 on alumnos (apellido)

 -- 4-Cree un índice agrupado, no único, para el campo "apellido".
 create clustered index apellido_nounico
 on alumnos(apellido)