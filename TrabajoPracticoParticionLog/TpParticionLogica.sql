-- Trabajo Practico Partición Lógica de Tablas
/*OBJETIVO:
  Implementar una estrategia de particionamiento horizontal sobre una tabla de
  historial de ventas, distribuyendo los datos en filegroups separados según
  rangos anuales de fecha de orden.

ESCENARIO:
  La empresa necesita mejorar el rendimiento de las consultas sobre la tabla
  de órdenes de venta, que contiene millones de registros históricos.
  Se decide particionar la tabla SalesOrderHeader por año de OrderDate,
  creando 4 particiones:
    - Partición 1: Órdenes anteriores al 01/01/2005
    - Partición 2: Órdenes entre 01/01/2005 y 31/12/2005
    - Partición 3: Órdenes entre 01/01/2006 y 31/12/2006
    - Partición 4: Órdenes a partir del 01/01/2007

BASE DE DATOS: AdventureWorks
CONSIGNA 1: FUNCIÓN DE PARTICIÓN
-- Crear una función de partición llamada pf_SalesYear de tipo RANGE RIGHT
-- sobre un campo datetime, con valores límite:
--   '01/01/2005', '01/01/2006', '01/01/2007' */

	USE AdventureWorks2008R2

	CREATE PARTITION FUNCTION pf_SalesYear (datetime)
	AS RANGE RIGHT
	FOR VALUES ('01/01/2005', '01/01/2006', '01/01/2007')

-- PREGUNTA TEÓRICA:
--   ¿Qué diferencia hay entre RANGE LEFT y RANGE RIGHT?
 /* RANGE LEFT incluye el valor límite en la partición izquierda, mientras que RANGE RIGHT lo incluye en la partición derecha.
La diferencia está en dónde queda almacenado el valor límite definido en la función de partición.*/

--   ¿A qué partición pertenece la fecha '01/01/2006' con RANGE RIGHT?
/* la fecha '01/01/2006' pertenece a la partición de la derecha del límite, es decir, a la partición 3.*/

--CONSIGNA 2: FILEGROUPS Y ARCHIVOS DE DATOS
-- a) Agregar 4 filegroups a la base de datos AdventureWorks:
--       fgSales1, fgSales2, fgSales3, fgSales4

ALTER DATABASE AdventureWorks2008R2 ADD FILEGROUP fgSales1
ALTER DATABASE AdventureWorks2008R2 ADD FILEGROUP fgSales2
ALTER DATABASE AdventureWorks2008R2 ADD FILEGROUP fgSales3
ALTER DATABASE AdventureWorks2008R2 ADD FILEGROUP fgSales4
GO

BACKUP LOG AdventureWorks TO DISK = 'NUL';
--GO
--
-- b) Agregar un archivo .ndf a cada filegroup con las siguientes características:
--       - Nombres lógicos:  salesdata1, salesdata2, salesdata3, salesdata4
--       - Ruta:  C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\
--       - Nombres físicos: SalesHist1.ndf, SalesHist2.ndf, SalesHist3.ndf, SalesHist4.ndf
--       - SIZE = 2MB, MAXSIZE = 200MB, FILEGROWTH = 2MB


ALTER DATABASE AdventureWorks2008R2
ADD FILE 
( NAME = salesdata1,
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SalesHist1.ndf',
  SIZE = 2MB,
  MAXSIZE = 200MB,
  FILEGROWTH = 2MB)
TO FILEGROUP fgSales1
GO

ALTER DATABASE AdventureWorks2008R2
ADD FILE 
( NAME = salesdata2,
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SalesHist2.ndf',
  SIZE = 2MB,
  MAXSIZE = 200MB,
  FILEGROWTH = 2MB)
TO FILEGROUP fgSales2
GO

ALTER DATABASE AdventureWorks2008R2
ADD FILE 
( NAME = salesdata3,
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SalesHist3.ndf',
  SIZE = 2MB,
  MAXSIZE = 200MB,
  FILEGROWTH = 2MB)
TO FILEGROUP fgSales3
GO

ALTER DATABASE AdventureWorks2008R2
ADD FILE 
( NAME = salesdata4,
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SalesHist4.ndf',
  SIZE = 2MB,
  MAXSIZE = 200MB,
  FILEGROWTH = 2MB)
TO FILEGROUP fgSales4
GO

--
-- PREGUNTA TEÓRICA:
--   ¿Para qué sirve distribuir particiones en filegroups distintos?
-- Para seguridad y almacenamiento 

--   Mencione al menos dos ventajas operativas.
/* 1) Permite realizar backups y restores parciales,
   recuperando solamente los filegroups necesarios.

2) Facilita el mantenimiento de datos históricos,
   pudiendo mover, archivar o eliminar particiones
   sin afectar toda la tabla.

3) Mejora el rendimiento de consultas al acceder
   únicamente a las particiones necesarias.

*/

--CONSIGNA 3: ESQUEMA DE PARTICIÓN
-- Crear un esquema de partición llamado ps_SalesYear que utilice la función
-- pf_SalesYear y asigne cada partición a su filegroup correspondiente:
--   Partición 1 ? fgSales1
--   Partición 2 ? fgSales2
--   Partición 3 ? fgSales3
--   Partición 4 ? fgSales4

CREATE PARTITION SCHEME ps_SalesYear
AS PARTITION pf_SalesYear 
TO (fgSales1, fgSales2 ,fgSales3 ,fgSales4 )
GO

-- CONSIGNA 4: TABLA PARTICIONADA
-- Crear la tabla dbo.SalesOrderHeader con la siguiente estructura,
-- particionada sobre el esquema ps_SalesYear usando la columna OrderDate:
--
--   SalesID        int IDENTITY(1,1) NOT NULL
--   SalesOrderID   int NOT NULL
--   CustomerID     int NOT NULL
--   OrderDate      datetime NOT NULL DEFAULT (getdate())
--   TotalDue       money NOT NULL
--   Status         tinyint NOT NULL


-- Create partitioned table
CREATE TABLE dbo.SalesOrderHeader
(
	SalesID        int IDENTITY(1,1) NOT NULL,
  SalesOrderID   int NOT NULL,
   CustomerID     int NOT NULL,
   OrderDate      datetime NOT NULL DEFAULT (getdate()),
   TotalDue       money NOT NULL,
   Status         tinyint NOT NULL
	
)
ON ps_SalesYear(OrderDate)
GO


--CONSIGNA 5: INSERCIÓN DE DATOS
-- a) Insertar en dbo.SalesOrderHeader los datos de la vista/tabla
--    Sales.SalesOrderHeader de AdventureWorks, tomando las columnas:
--    SalesOrderID, CustomerID, OrderDate, TotalDue, Status

-- Insert data
INSERT INTO dbo.SalesOrderHeader 
SELECT	 SalesOrderID, CustomerID, OrderDate, TotalDue, Status
FROM  Sales.SalesOrderHeader
GO


-- b) Insertar manualmente un registro con:
--    SalesOrderID = 99999, CustomerID = 1, OrderDate = '06/15/2001',
--    TotalDue = 500.00, Status = 5
--    (Este registro debe caer en la Partición 1)

INSERT INTO dbo.SalesOrderHeader
(
    SalesOrderID,
    CustomerID,
    OrderDate,
    TotalDue,
    Status
)
VALUES
(
    99999,
    1,
    '2001-06-15',
    500.00,
    5
);

GO


-- CONSIGNA 6: CONSULTAS DE VERIFICACIÓN
-- a) Mostrar todos los registros de dbo.SalesOrderHeader
SELECT *
FROM dbo.SalesOrderHeader;
GO

-- b) Consultar sys.Partitions para obtener el número de filas por partición
--    de la tabla dbo.SalesOrderHeader

-- View partition metadata
SELECT * FROM sys.Partitions
WHERE [object_id] = OBJECT_ID('dbo.SalesOrderHeader')


-- c) Mostrar SalesID, OrderDate y el número de partición de cada fila

-- View data with partition number
SELECT SalesID, OrderDate, $PARTITION.pf_SalesYear(OrderDate)
FROM dbo.SalesOrderHeader




-- d) Para cada partición, mostrar la fecha mínima y máxima de OrderDate
--    y la cantidad de registros. Ordenar por número de partición.
-- Verify lowest value in each partition
/*SELECT MIN(TransactionDate) FirstTran, $Partition.pf_OrderDate() PartitionNo
FROM dbo.PartitionedTransactions
GROUP BY $Partition.pf_OrderDate(TransactionDate)
ORDER BY PartitionNo*/


--
-- PREGUNTA TEÓRICA: ¿Los resultados coinciden con los rangos definidos
-- en la función de partición? Justifique.


-- LIMPIEZA - EJECUTAR AL FINALIZAR EL TP

-- ATENCIÓN: Ejecutar esta sección solo una vez completadas y verificadas
-- todas las consignas anteriores.

DROP TABLE dbo.SalesOrderHeader
DROP PARTITION SCHEME ps_SalesYear
DROP PARTITION FUNCTION pf_SalesYear
ALTER DATABASE AdventureWorks REMOVE FILE salesdata1
ALTER DATABASE AdventureWorks REMOVE FILE salesdata2
ALTER DATABASE AdventureWorks REMOVE FILE salesdata3
ALTER DATABASE AdventureWorks REMOVE FILE salesdata4
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fgSales1
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fgSales2
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fgSales3
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fgSales4