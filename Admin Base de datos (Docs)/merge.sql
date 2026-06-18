--MERGE(combinar)

--En SQL Server, se pueden realizar operaciones de inserción, actualización o eliminación en una sola instrucción utilizando 
--la instrucción MERGE. La instrucción MERGE le permite combinar un origen de datos con una tabla o vista de destino y, a continuación,
-- realizar varias acciones con el destino según los resultados de esa combinación. Por ejemplo, puede utilizar la instrucción MERGE 
-- para realizar las operaciones siguientes:

--Condicionalmente insertar o actualizar filas en una tabla de destino.

--•	Si la fila existe en la tabla de destino, actualizar una o varias columnas; de lo contrario, insertar los datos en una fila nueva.

--•	Sincronizar dos tablas.

--•	Insertar, actualizar o eliminar filas en una tabla de destino según las diferencias con los datos de origen.

--•	La sintaxis de MERGE está compuesta de cinco cláusulas principales:

--•	La cláusula MERGE especifica la tabla o vista que es el destino de las operaciones de inserción, actualización o eliminación.

--•	La cláusula USING especifica el origen de datos que va a combinarse con el destino.

--•	La cláusula ON especifica las condiciones de combinación que determinan las coincidencias entre el destino y el origen.

--•	Las cláusulas WHEN (WHEN MATCHED, WHEN NOT MATCHED BY TARGET y WHEN NOT MATCHED BY SOURCE) especifican las acciones que se van 
--a llevar a cabo según los resultados de la cláusula ON y cualquier criterio de búsqueda adicional especificado en las cláusulas WHEN.

--•	La cláusula OUTPUT devuelve una fila por cada fila del destino que se inserta, actualiza o elimina.

USE tempdb;
GO
CREATE TABLE dbo.Target(EmployeeID int, EmployeeName varchar(10), 
     CONSTRAINT Target_PK PRIMARY KEY(EmployeeID));
CREATE TABLE dbo.Source(EmployeeID int, EmployeeName varchar(10), 
     CONSTRAINT Source_PK PRIMARY KEY(EmployeeID));
GO
INSERT dbo.Target(EmployeeID, EmployeeName) VALUES(100, 'Mary');
INSERT dbo.Target(EmployeeID, EmployeeName) VALUES(101, 'Sara');
INSERT dbo.Target(EmployeeID, EmployeeName) VALUES(102, 'Stefano');

GO
INSERT dbo.Source(EmployeeID, EmployeeName) Values(103, 'Bob');
INSERT dbo.Source(EmployeeID, EmployeeName) Values(104, 'Steve');
GO


select * from source
select * from target

drop table Source
drop table Target

-- MERGE statement with the join conditions specified correctly.
USE tempdb;
go
MERGE Target AS T
USING Source AS S
ON (T.EmployeeID = S.EmployeeID) 
WHEN NOT MATCHED BY TARGET AND S.EmployeeName LIKE 'S%' 
    THEN INSERT(EmployeeID, EmployeeName) VALUES(S.EmployeeID, S.EmployeeName)
WHEN MATCHED 
    THEN UPDATE SET T.EmployeeName = S.EmployeeName
WHEN NOT MATCHED BY SOURCE AND T.EmployeeName LIKE 'S%'
    THEN DELETE 
OUTPUT $action, inserted.*, deleted.*;

GO 

select * from source
select * from target