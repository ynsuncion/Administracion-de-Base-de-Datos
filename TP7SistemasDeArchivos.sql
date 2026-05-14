
-- Trabajo Practico Sistema de Archivos
-- EJERCICIO 1: Creación de base de datos simple

CREATE DATABASE GestionPersonal 
ON PRIMARY 
	(NAME = N'GestionPersonal_Data',
	FILENAME = N'C:\DATA\GestionPersonal.MDF',
	SIZE = 5 MB,
	FILEGROWTH = 1 MB
	)
LOG ON 
	(NAME = N'GestionPersonal_Log',
	FILENAME = N'C:\DATA\GestionPersonal_Log.LDF',
	SIZE = 2 MB,
	FILEGROWTH = 1 MB
	)

use GestionPersonal	

-- EJERCICIO 2: Creación de base de datos con filegroup adicional

CREATE DATABASE Inventario
ON PRIMARY 
	(NAME = N'Inventario_Data1',
	FILENAME = N'C:\DATA\Inventario1.MDF',
	SIZE = 10MB
	),

	FILEGROUP [HISTORICO]
	(
	NAME = N'Inventario_Data2',
	FILENAME = N'C:\DATA\Inventario2.NDF',
	SIZE = 10 MB
	)
LOG ON 
	(NAME = N': Inventario_Log',
	FILENAME = N'C:\DATA\Inventario_Log.LDF',
	SIZE = 5 MB
	)

	/*Luego de crear la base de datos, verifique que existe consultando
la vista del sistema SYS.DATABASES filtrando por el nombre Inventario*/

select * from SYS.DATABASES 
WHERE NAME = 'Inventario'


-- EJERCICIO 3: Creación y uso de esquemas

USE GestionPersonal

-- a) Cree los esquemas: Rrhh, Contabilidad y Logistica.
go -- hace una pausa  ejecuta una siguiente sentencia 
CREATE SCHEMA  Rrhh
go
CREATE SCHEMA Contabilidad 
go
CREATE SCHEMA Logistica

/*b) Consulte la vista SYS.SCHEMAS para verificar que los tres esquemas
     fueron creados correctamente. */

	 select * from SYS.SCHEMAS

 /*c) Cree la siguiente tabla dentro del esquema Rrhh:

       Empleados (
           EmpleadoID   int          PRIMARY KEY,
           Apellido     varchar(40)  NOT NULL,
           Nombre       varchar(30)  NOT NULL,
           Cargo        varchar(30)  NULL,
           FechaIngreso  date         NULL
       )
	   */

	 
	 create table rrhh.empleados(
	 EmpleadoID   int          PRIMARY KEY,
           Apellido     varchar(40)  NOT NULL,
           Nombre       varchar(30)  NOT NULL,
           Cargo        varchar(30)  NULL,
           FechaIngreso  date         NULL
       )

/* d) Cree la siguiente tabla dentro del esquema Contabilidad:

       CuentasContables (
           CuentaID     int          PRIMARY KEY,
           Descripcion  varchar(60)  NOT NULL,
           Saldo        decimal(18,2) NULL
       )

*/

create table Contabilidad. CuentasContables (
           CuentaID     int          PRIMARY KEY,
           Descripcion  varchar(60)  NOT NULL,
           Saldo        decimal(18,2) NULL
       )


/*   e) Intente eliminar el esquema Rrhh con DROP SCHEMA y observe
     qué ocurre. Justifique el resultado con un comentario en el script.
*/

DROP SCHEMA Rrhh

/*no se puede borrar porque hay una tabla dentro del schema, la tabla empleados 
primero tendria que borrar la tabla antes de borrar el schema*/

-- EJERCICIO 4: Tipos de datos definidos por el usuario

/*
Dentro de la base de datos GestionPersonal: (clase 13)

  a) Cree los siguientes tipos de datos definidos por el usuario (UDT):

       - DNI      basado en char(8),    NOT NULL
       - Telefono basado en varchar(20), NULL
       - Email    basado en varchar(80), NULL

*/
CREATE TYPE DNI 
FROM char(8) NOT NULL

CREATE TYPE Telefono
FROM varchar(20) NULL

CREATE TYPE Email
FROM varchar(80)NULL

/* b) Consulte la vista SYS.TYPES para verificar que los tipos
     fueron registrados.*/

	select * from sys.types

/* c) Cree la tabla Rrhh.Contactos utilizando los tipos definidos:

       Contactos (
           ContactoID  int        PRIMARY KEY,
           EmpleadoID  int        NOT NULL,  -- FK hacia Rrhh.Empleados
           Dni         DNI,
           Celular     Telefono,
           CorreoElec  Email
       )

     Incluya la FOREIGN KEY hacia Rrhh.Empleados(EmpleadoID). */

CREATE TABLE Rrhh.Contactos (
           ContactoID  int        PRIMARY KEY,
           EmpleadoID  int        NOT NULL,  -- FK hacia Rrhh.Empleados
           Dni         DNI,
           Celular     Telefono,
           CorreoElec  Email,
		   foreign key(EmpleadoID) references rrhh.empleados(EmpleadoID)
       )


-- EJERCICIO 5: Ejercicio integrador
/*Cree una base de datos llamada Clínica con:
  - Archivo principal en C:\DATA\Clinica.MDF, 8 MB de tamaño inicial,
    crecimiento de 2 MB.
  - Archivo de log en C:\DATA\Clinica_Log.LDF, 3 MB de tamaño inicial,
    crecimiento de 1 MB.

Dentro de Clínica:

  a) Cree los esquemas: Pacientes y Médicos.

*/

CREATE DATABASE Clinica
ON PRIMARY 
	(NAME = N'Clinica_Data',
	FILENAME = N'C:\DATA\Clinica.MDF',
	SIZE = 8 MB,
	FILEGROWTH = 2 MB
	)

	LOG ON 
	(NAME = N'Clinica_Log',
	FILENAME = N'C:\DATA\Clinica_Log.LDF',
	SIZE = 3 MB,
	FILEGROWTH = 1 MB
	)

	go 
	CREATE SCHEMA Pacientes
	go
	CREATE SCHEMA Medicos 

	SELECT * FROM SYS.schemas

/* b) Cree los tipos de datos de usuario:
       - MatriculaMedica  basado en varchar(10), NOT NULL
       - ObraSocial       basado en varchar(50), NULL

*/

CREATE TYPE MatriculaMedica
FROM varchar(10) NOT NULL

CREATE TYPE ObraSocial 
FROM varchar(50) NULL

/*  c) Cree las siguientes tablas usando los esquemas y UDT correspondientes:

       Medicos.Profesionales (
           MedicoID    int               PRIMARY KEY,
           Apellido    varchar(40)       NOT NULL,
           Nombre      varchar(30)       NOT NULL,
           Matricula   MatriculaMedica,
           Especialidad varchar(40)      NULL
       )

       Pacientes.Personas (
           PacienteID  int               PRIMARY KEY,
           Apellido    varchar(40)       NOT NULL,
           Nombre      varchar(30)       NOT NULL,
           FechaNac    date              NULL,
           Cobertura   ObraSocial
       )


       Pacientes.Turnos (
           TurnoID     int               PRIMARY KEY,
           PacienteID  int               NOT NULL,
           MedicoID    int               NOT NULL,
           FechaTurno  datetime          NOT NULL,
           Observaciones varchar(200)    NULL,
           FOREIGN KEY (PacienteID) REFERENCES Pacientes.Personas(PacienteID),
           FOREIGN KEY (MedicoID)   REFERENCES Medicos.Profesionales(MedicoID)
       )
*/

CREATE TABLE Medicos.Profesionales (
           MedicoID    int               PRIMARY KEY,
           Apellido    varchar(40)       NOT NULL,
           Nombre      varchar(30)       NOT NULL,
           Matricula   MatriculaMedica,
           Especialidad varchar(40)      NULL
       )

CREATE TABLE  Pacientes.Personas (
           PacienteID  int               PRIMARY KEY,
           Apellido    varchar(40)       NOT NULL,
           Nombre      varchar(30)       NOT NULL,
           FechaNac    date              NULL,
           Cobertura   ObraSocial
       )

CREATE TABLE Pacientes.Turnos (
           TurnoID     int               PRIMARY KEY,
           PacienteID  int               NOT NULL,
           MedicoID    int               NOT NULL,
           FechaTurno  datetime          NOT NULL,
           Observaciones varchar(200)    NULL,
           FOREIGN KEY (PacienteID) REFERENCES Pacientes.Personas(PacienteID),
           FOREIGN KEY (MedicoID)   REFERENCES Medicos.Profesionales(MedicoID)
       )

-- d) Consulte SYS.SCHEMAS y SYS.TABLES para listar los objetos creados.

select * from sys.schemas 
select * from sys.tables

--   e) Al finalizar, elimine los UDT MatriculaMedica y ObraSocial.
-- ¿Es posible hacerlo directamente? Justifique con un comentario.
drop type MatriculaMedica 
drop type ObraSocial

-- No se pueden eliminar porque estaan dentro de las tablas 