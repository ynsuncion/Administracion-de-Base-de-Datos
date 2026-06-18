--Esquemas

CREATE DATABASE Test
go
use Test

CREATE SCHEMA Ventas

SELECT * FROM SYS.SCHEMAS

CREATE TABLE Ventas.Prueba(codigo int,nombre varchar(30))

DROP SCHEMA Ventas

DROP DATABASE Test

--Creacion de base de datos. Filegroups

/*El siguiente ejemplo crea la base de datos TestDB en la unidad D: con un
espacio inicial de 20 megabytes y crecimiento automático.
*/

CREATE DATABASE TestDB
ON PRIMARY 
	(NAME = N'TestDB_Data',
	FILENAME = N'C:\DATA\TestDB.MDF',
	SIZE = 3 MB,
	FILEGROWTH = 1 MB
	)
LOG ON 
	(NAME = N'TestDB_Log',
	FILENAME = N'C:\DATA\TestDB_Log.LDF',
	SIZE = 1 MB,
	FILEGROWTH = 1 MB
	)

drop database TestDB

/*El siguiente ejemplo crea la base de datos FACTURACION en la unidad C:
con un espacio de 20 megabytes y un archivo de registro de transacciones (LOG)
de 5Mb en el drive E. Todas las tablas que se creen en el filegroup HISTORICO 
se guardarán en el archivo FACTURACION2 en la unidad C.
*/

CREATE DATABASE [FACTURACION]
ON PRIMARY
	(
	NAME = N'FACTURACION_Data1',
	FILENAME = N'C:\DATA\FACTURACION1.MDF',
	SIZE = 20 MB
	),
FILEGROUP [HISTORICO]
	(
	NAME = N'FACTURACION_Data2',
	FILENAME = N'C:\DATA\FACTURACION2.NDF',
	SIZE = 20 MB
	)
LOG ON
	(
	NAME = N'FACTURACION_Log',
	FILENAME = N'C:\DATA\FACTURACION_Log.LDF',
	SIZE = 5 MB
	)