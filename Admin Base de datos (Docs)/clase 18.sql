
-- Sistema de Archivos

-- ============================================================
-- EJERCICIO 1: Creación de base de datos simple
-- ============================================================
/*
Cree una base de datos llamada GestionPersonal con las siguientes
especificaciones para el archivo de datos principal (PRIMARY):

  - Nombre lógico : GestionPersonal_Data
  - Archivo físico: C:\DATA\GestionPersonal.MDF
  - Tamaño inicial: 5 MB
  - Crecimiento    : 1 MB

Y para el archivo de log de transacciones:

  - Nombre lógico : GestionPersonal_Log
  - Archivo físico: C:\DATA\GestionPersonal_Log.LDF
  - Tamaño inicial: 2 MB
  - Crecimiento    : 1 MB

Luego, ponga en uso la base de datos creada.
*/


CREATE DATABASE GestionPersonal
ON PRIMARY
	(
	NAME       = N'GestionPersonal_Data',
	FILENAME   = N'C:\DATA\GestionPersonal.MDF',
	SIZE       = 5 MB,
	FILEGROWTH = 1 MB
	)
LOG ON
	(
	NAME       = N'GestionPersonal_Log',
	FILENAME   = N'C:\DATA\GestionPersonal_Log.LDF',
	SIZE       = 2 MB,
	FILEGROWTH = 1 MB
	)
GO

USE GestionPersonal
GO


-- ============================================================
-- EJERCICIO 2: Creación de base de datos con filegroup adicional
-- ============================================================
/*
Cree una base de datos llamada Inventario con la siguiente estructura:

  Filegroup PRIMARY (archivo principal):
    - Nombre lógico : Inventario_Data1
    - Archivo físico: C:\DATA\Inventario1.MDF
    - Tamaño inicial: 10 MB

  Filegroup adicional llamado HISTORICO (archivo secundario):
    - Nombre lógico : Inventario_Data2
    - Archivo físico: C:\DATA\Inventario2.NDF
    - Tamaño inicial: 10 MB

  Archivo de log:
    - Nombre lógico : Inventario_Log
    - Archivo físico: C:\DATA\Inventario_Log.LDF
    - Tamaño inicial: 5 MB

Luego de crear la base de datos, verifique que existe consultando
la vista del sistema SYS.DATABASES filtrando por el nombre Inventario.
*/



CREATE DATABASE Inventario
ON PRIMARY
	(
	NAME     = N'Inventario_Data1',
	FILENAME = N'C:\DATA\Inventario1.MDF',
	SIZE     = 10 MB
	),
FILEGROUP [HISTORICO]
	(
	NAME     = N'Inventario_Data2',
	FILENAME = N'C:\DATA\Inventario2.NDF',
	SIZE     = 10 MB
	)
LOG ON
	(
	NAME     = N'Inventario_Log',
	FILENAME = N'C:\DATA\Inventario_Log.LDF',
	SIZE     = 5 MB
	)
GO

-- Verificar que la base de datos existe
SELECT name, database_id, create_date
FROM   SYS.DATABASES
WHERE  name = 'Inventario'
GO


-- ============================================================
-- EJERCICIO 3: Creación y uso de esquemas
-- ============================================================
/*
Dentro de la base de datos GestionPersonal (creada en el Ejercicio 1):

  a) Cree los esquemas: Rrhh, Contabilidad y Logistica.
  b) Consulte la vista SYS.SCHEMAS para verificar que los tres esquemas
     fueron creados correctamente.
  c) Cree la siguiente tabla dentro del esquema Rrhh:

       Empleados (
           EmpleadoID   int          PRIMARY KEY,
           Apellido     varchar(40)  NOT NULL,
           Nombre       varchar(30)  NOT NULL,
           Cargo        varchar(30)  NULL,
           FechaIngreso date         NULL
       )

  d) Cree la siguiente tabla dentro del esquema Contabilidad:

       CuentasContables (
           CuentaID     int          PRIMARY KEY,
           Descripcion  varchar(60)  NOT NULL,
           Saldo        decimal(18,2) NULL
       )

  e) Intente eliminar el esquema Rrhh con DROP SCHEMA y observe
     qué ocurre. Justifique el resultado con un comentario en el script.
*/



USE GestionPersonal
GO

-- a) Creación de esquemas
CREATE SCHEMA Rrhh
GO
CREATE SCHEMA Contabilidad
GO
CREATE SCHEMA Logistica
GO

-- b) Verificar esquemas creados
SELECT name, schema_id, principal_id
FROM   SYS.SCHEMAS
WHERE  name IN ('Rrhh', 'Contabilidad', 'Logistica')
GO

-- c) Tabla en esquema Rrhh
CREATE TABLE Rrhh.Empleados
(
	EmpleadoID   int          PRIMARY KEY,
	Apellido     varchar(40)  NOT NULL,
	Nombre       varchar(30)  NOT NULL,
	Cargo        varchar(30)  NULL,
	FechaIngreso date         NULL
)
GO

-- d) Tabla en esquema Contabilidad
CREATE TABLE Contabilidad.CuentasContables
(
	CuentaID    int           PRIMARY KEY,
	Descripcion varchar(60)   NOT NULL,
	Saldo       decimal(18,2) NULL
)
GO

-- e) Intento de eliminar el esquema Rrhh
DROP SCHEMA Rrhh
GO
/*
  RESULTADO: SQL Server devuelve un error indicando que no se puede
  eliminar el esquema 'Rrhh' porque contiene objetos (la tabla Empleados).
  Para poder eliminar un esquema primero deben eliminarse o trasladarse
  todos los objetos que pertenecen a él.
*/


-- ============================================================
-- EJERCICIO 4: Tipos de datos definidos por el usuario
-- ============================================================
/*
Dentro de la base de datos GestionPersonal:

  a) Cree los siguientes tipos de datos definidos por el usuario (UDT):

       - DNI      basado en char(8),    NOT NULL
       - Telefono basado en varchar(20), NULL
       - Email    basado en varchar(80), NULL

  b) Consulte la vista SYS.TYPES para verificar que los tipos
     fueron registrados.

  c) Cree la tabla Rrhh.Contactos utilizando los tipos definidos:

       Contactos (
           ContactoID  int        PRIMARY KEY,
           EmpleadoID  int        NOT NULL,  -- FK hacia Rrhh.Empleados
           Dni         DNI,
           Celular     Telefono,
           CorreoElec  Email
       )

     Incluya la FOREIGN KEY hacia Rrhh.Empleados(EmpleadoID).
*/



USE GestionPersonal
GO

-- a) Creación de tipos de datos definidos por el usuario
CREATE TYPE DNI
FROM char(8) NOT NULL
GO

CREATE TYPE Telefono
FROM varchar(20) NULL
GO

CREATE TYPE Email
FROM varchar(80) NULL
GO

-- b) Verificar los UDT creados
SELECT name, system_type_id, user_type_id, max_length
FROM   SYS.TYPES
WHERE  name IN ('DNI', 'Telefono', 'Email')
GO

-- c) Tabla Rrhh.Contactos usando los UDT
CREATE TABLE Rrhh.Contactos
(
	ContactoID int      PRIMARY KEY,
	EmpleadoID int      NOT NULL,
	Dni        DNI,
	Celular    Telefono,
	CorreoElec Email,
	CONSTRAINT FK_Contactos_Empleados
		FOREIGN KEY (EmpleadoID) REFERENCES Rrhh.Empleados(EmpleadoID)
)
GO


-- ============================================================
-- EJERCICIO 5: Ejercicio integrador
-- ============================================================
/*
Cree una base de datos llamada Clinica con:
  - Archivo principal en C:\DATA\Clinica.MDF, 8 MB de tamaño inicial,
    crecimiento de 2 MB.
  - Archivo de log en C:\DATA\Clinica_Log.LDF, 3 MB de tamaño inicial,
    crecimiento de 1 MB.

Dentro de Clinica:

  a) Cree los esquemas: Pacientes y Medicos.

  b) Cree los tipos de datos de usuario:
       - MatriculaMedica  basado en varchar(10), NOT NULL
       - ObraSocial       basado en varchar(50), NULL

  c) Cree las siguientes tablas usando los esquemas y UDT correspondientes:

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

  d) Consulte SYS.SCHEMAS y SYS.TABLES para listar los objetos creados.

  e) Al finalizar, elimine los UDT MatriculaMedica y ObraSocial.
     ¿Es posible hacerlo directamente? Justifique con un comentario.
*/



-- Crear la base de datos Clinica
CREATE DATABASE Clinica
ON PRIMARY
	(
	NAME       = N'Clinica_Data',
	FILENAME   = N'C:\DATA\Clinica.MDF',
	SIZE       = 8 MB,
	FILEGROWTH = 2 MB
	)
LOG ON
	(
	NAME       = N'Clinica_Log',
	FILENAME   = N'C:\DATA\Clinica_Log.LDF',
	SIZE       = 3 MB,
	FILEGROWTH = 1 MB
	)
GO

USE Clinica
GO

-- a) Creación de esquemas
CREATE SCHEMA Pacientes
GO
CREATE SCHEMA Medicos
GO

-- b) Tipos de datos de usuario
CREATE TYPE MatriculaMedica
FROM varchar(10) NOT NULL
GO

CREATE TYPE ObraSocial
FROM varchar(50) NULL
GO

-- c) Tablas con esquemas y UDT
CREATE TABLE Medicos.Profesionales
(
	MedicoID     int             PRIMARY KEY,
	Apellido     varchar(40)     NOT NULL,
	Nombre       varchar(30)     NOT NULL,
	Matricula    MatriculaMedica,
	Especialidad varchar(40)     NULL
)
GO

CREATE TABLE Pacientes.Personas
(
	PacienteID int         PRIMARY KEY,
	Apellido   varchar(40) NOT NULL,
	Nombre     varchar(30) NOT NULL,
	FechaNac   date        NULL,
	Cobertura  ObraSocial
)
GO

CREATE TABLE Pacientes.Turnos
(
	TurnoID       int          PRIMARY KEY,
	PacienteID    int          NOT NULL,
	MedicoID      int          NOT NULL,
	FechaTurno    datetime     NOT NULL,
	Observaciones varchar(200) NULL,
	CONSTRAINT FK_Turnos_Pacientes
		FOREIGN KEY (PacienteID) REFERENCES Pacientes.Personas(PacienteID),
	CONSTRAINT FK_Turnos_Medicos
		FOREIGN KEY (MedicoID)   REFERENCES Medicos.Profesionales(MedicoID)
)
GO

-- d) Consultar objetos creados
SELECT name, schema_id
FROM   SYS.SCHEMAS
WHERE  name IN ('Pacientes', 'Medicos')
GO

SELECT s.name AS Esquema, t.name AS Tabla
FROM   SYS.TABLES  t
JOIN   SYS.SCHEMAS s ON t.schema_id = s.schema_id
ORDER  BY s.name, t.name
GO

-- e) Intento de eliminar los UDT
DROP TYPE MatriculaMedica
GO
DROP TYPE ObraSocial
GO
/*
  RESULTADO: SQL Server devuelve un error porque los tipos MatriculaMedica
  y ObraSocial están siendo utilizados como tipo de columna en las tablas
  Medicos.Profesionales y Pacientes.Personas respectivamente.
  Para poder eliminar un UDT primero deben eliminarse (o modificarse)
  todas las columnas y objetos que lo referencian.
*/

-- Cambiar la columna que usa MatriculaMedica por su tipo base varchar(10)
ALTER TABLE Medicos.Profesionales
ALTER COLUMN Matricula varchar(10) NOT NULL
GO

-- Cambiar la columna que usa ObraSocial por su tipo base varchar(50)
ALTER TABLE Pacientes.Personas
ALTER COLUMN Cobertura varchar(50) NULL
GO

-- Ahora sí se pueden eliminar los UDT
DROP TYPE MatriculaMedica
GO
DROP TYPE ObraSocial
GO



-- Sinonimos

-- Los sinónimos se pueden crear utilizando la instrucción CREATE SYNONYM de SQL Server. La sintaxis básica es la siguiente:


-- CREATE SYNONYM [nombre_sinonimo]
-- FOR [objeto_base_de_datos]
-- [([esquema])];

-- Recomendaciones para el uso de sinónimos:

-- Utilice sinónimos para nombres de objetos largos o complejos.
-- Utilice sinónimos para crear nombres de objetos más descriptivos.
-- Utilice sinónimos para ocultar la complejidad de la estructura de la base de datos a los usuarios.

CREATE SYNONYM miTablaClientes
FOR Sales.Customer

SELECT * FROM dbo.miTablaClientes

-- En este ejemplo, la consulta selecciona todas las filas de la tabla Production.Customers (a la que se hace referencia mediante el sinónimo mi_tabla_clientes).


DROP SYNONYM [miTablaClientes]

