--TRABAJO PR?CTICO COPIA DE SEGURIDAD 

--Caso de Estudio: Distribuidora de Tecnolog?a "TecnoGBA"

--Objetivo: Dise?ar, ejecutar y validar una pol?tica de respaldos tradicional (Full, Diferencial y Log de Transacciones) para garantizar que la empresa no pierda ventas ante una falla catastr?fica de hardware.

--FASE 1: CREACI?N DEL ENTORNO DE TRABAJO (Punto de partida)
--Antes de iniciar la secuencia de backups, como DBA debes preparar el escenario montando la base de datos de la distribuidora, sus tablas principales y el inventario inicial de la empresa.
USE master;
GO

-- 1. Crear la base de datos limpia
CREATE DATABASE [TecnoGBA];
GO

USE [TecnoGBA];
GO

-- 2. Crear tabla de Clientes
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL,
    Localidad VARCHAR(100) NOT NULL
);
GO

-- 3. Crear tabla de Pedidos (Ventas)
CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY IDENTITY(1,1),
    ClienteID INT FOREIGN KEY REFERENCES Clientes(ClienteID),
    Producto VARCHAR(100) NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    FechaPedido DATETIME DEFAULT GETDATE()
);
GO

-- 4. Carga Inicial de Datos (Estado de la empresa a las 08:00 AM)
INSERT INTO Clientes (Nombre, Localidad) VALUES 
('Erica Ramos', 'Palermo'),
('Jorge Galv?n', 'Almagro'),
('Estudio Multimedial', 'Caballito');

INSERT INTO Pedidos (ClienteID, Producto, Monto) VALUES 
(1, 'Notebook Samsung Book3', 1200000.00),
(2, 'Monitor Samsung Odyssey G4', 450000.00);
GO

--Paso 1: Configurar el Modelo de Recuperaci?n Obligatorio
--Para poder respaldar los registros minuto a minuto, la base de datos no puede estar en modo simple.
ALTER DATABASE [TecnoGBA] SET RECOVERY FULL;
GO

--Paso 2: Generar la L?nea Base General (Backup Full)
--A las 09:00 AM se realiza el respaldo completo inicial del sistema.
BACKUP DATABASE [TecnoGBA]
TO DISK = 'c:\backups\tecnogba_full.bak'
WITH FORMAT, MEDIANAME = 'TecnoGBA_Media', NAME = 'Full TecnoGBA Backup';
GO

--Paso 3: Simulaci?n de Ventas de la Ma?ana
--A las 10:00 AM ingresa una nueva venta al sistema.
INSERT INTO Pedidos (ClienteID, Producto, Monto) VALUES 
(3, 'C?mara Sony Alpha 7', 2500000.00);
GO

--Paso 4: Generar Punto de Control Acumulativo (Backup Diferencial)
--A las 11:00 AM, para salvaguardar los cambios de la ma?ana sin saturar el disco duro, se ejecuta un respaldo diferencial.
BACKUP DATABASE [TecnoGBA]
TO DISK = 'c:\backups\tecnogba_diff.bak'
WITH DIFFERENTIAL, FORMAT, MEDIANAME = 'TecnoGBA_DiffMedia', NAME = 'Diff TecnoGBA Backup';
GO

--Paso 5: Nuevas Ventas de la Tarde y Primer Backup del Log
--A las 12:00 PM se registra un nuevo pedido de la sucursal de Palermo.
INSERT INTO Pedidos (ClienteID, Producto, Monto) VALUES 
(1, 'Celular Samsung S23 Plus', 950000.00);
GO

--Inmediatamente, se realiza el primer respaldo del Log de Transacciones (capturando esta ?ltima venta):
BACKUP LOG [TecnoGBA]
TO DISK = 'c:\backups\tecnogba_log1.trn'
WITH FORMAT, NAME = 'Log TecnoGBA Backup 1';
GO

--Paso 6: ?ltima Venta de la Jornada y Segundo Backup del Log
--A las 02:00 PM ingresa la ?ltima venta del laboratorio.
INSERT INTO Pedidos (ClienteID, Producto, Monto) VALUES 
(2, 'Tablet Samsung S9 FE', 680000.00);
GO

--Se ejecuta el segundo respaldo del Log transaccional para cerrar el d?a seguro:
BACKUP LOG [TecnoGBA]
TO DISK = 'c:\backups\tecnogba_log2.trn'
WITH FORMAT, NAME = 'Log TecnoGBA Backup 2';
GO

--FASE 3: EL DESASTRE OPERATIVO
--Escenario de Emergencia: A las 02:30 PM el disco duro principal que aloja la base de datos activa sufre un fallo mec?nico total e irrecuperable. Los archivos de datos en producci?n han desaparecido. La empresa est? paralizada.

--FASE 4: PROTOCOLO DE RECUPERACI?N DE EMERGENCIA (Restauraci?n)
--Instrucciones para el alumno: Como DBA de la distribuidora, debe reconstruir la base de datos utilizando ?nica y exclusivamente los archivos de respaldo resguardados en la carpeta externa (c:\backups\).

--Para tener ?xito, se debe respetar el orden cronol?gico estricto y el uso adecuado de las llaves de estado del motor (NORECOVERY y RECOVERY).
USE master;
GO

-- 1. Desconectar cualquier intento de reconexi?n de usuarios/aplicaciones
ALTER DATABASE [TecnoGBA] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- 2. Paso A: Restaurar la estructura base fundamental (Full)
RESTORE DATABASE [TecnoGBA]
FROM DISK = 'c:\backups\tecnogba_full.bak'
WITH NORECOVERY, REPLACE;
GO

-- 3. Paso B: Adelantar el tiempo con el punto acumulativo (Diferencial)
RESTORE DATABASE [TecnoGBA]
FROM DISK = 'c:\backups\tecnogba_diff.bak'
WITH NORECOVERY;
GO

-- 4. Paso C: Aplicar primer tramo de transacciones perdidas (Log 1)
RESTORE LOG [TecnoGBA]
FROM DISK = 'c:\backups\tecnogba_log1.trn'
WITH NORECOVERY;
GO

-- 5. Paso D: Aplicar el ?ltimo tramo y abrir la empresa al p?blico (Log 2 + RECOVERY)
RESTORE LOG [TecnoGBA]
FROM DISK = 'c:\backups\tecnogba_log2.trn'
WITH RECOVERY;
GO

--FASE 5: VALIDACI?N DE DATOS (Verificaci?n del Alumno)
--Para finalizar el TP y dar por aprobado el laboratorio, tenes que verificar que no se perdi? absolutamente ning?n registro comercial. Al ejecutar la siguiente consulta, el sistema debe devolver la cantidad de pedidos en total:
USE TecnoGBA;
GO
SELECT P.PedidoID, C.Nombre, C.Localidad, P.Producto, P.Monto 
FROM Pedidos P
INNER JOIN Clientes C ON P.ClienteID = C.ClienteID;
GO



