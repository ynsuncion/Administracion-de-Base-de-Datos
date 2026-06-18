-- ============================================================================
-- PASO 1: CONFIGURACIÓN INICIAL Y GENERACIÓN DE LÍNEAS BASE
-- ============================================================================
ALTER DATABASE [pubs] SET RECOVERY FULL;
GO

BACKUP DATABASE [pubs]
TO DISK = 'c:\backups\pubs.bak'
WITH FORMAT, MEDIANAME = 'Pubs', NAME = 'Full-Pubs backup';
GO

-- Modificación de estructura de datos
USE pubs;
GO
CREATE TABLE prueba(codigo int);
GO

BACKUP DATABASE [pubs]
TO DISK = 'c:\backups\pubs_diff.bak'
WITH DIFFERENTIAL, FORMAT,
MEDIANAME = 'Native_SQLServerDiffBackup', NAME = 'Diff-pubs backup';
GO

-- ============================================================================
-- PASO 2: PROTECCIÓN INMEDIATA (CREACIÓN DEL SNAPSHOT)
-- ============================================================================
-- Creamos la instantánea estática antes de permitir inserciones complejas por la mañana.
-- Nota: Requiere especificar el nombre lógico del archivo de datos ('pubs')
CREATE DATABASE pubs_snapshot_mañana
ON ( 
    NAME = 'pubs', 
    FILENAME = 'c:\backups\pubs_mañana.ss'
)
AS SNAPSHOT OF [pubs];
GO

-- Inserciones de producción por parte de los operadores de la empresa
INSERT INTO prueba VALUES (10);
GO

-- ============================================================================
-- PASO 3: CADENA DE LOGS TRANSACCIONALES
-- ============================================================================
BACKUP LOG [pubs]
TO DISK = 'c:\backups\pubs_log1.trn'
WITH FORMAT, NAME = 'Log-Pubs backup 1';
GO

INSERT INTO prueba VALUES (20);
GO

BACKUP LOG [pubs]
TO DISK = 'c:\backups\pubs_log2.trn'
WITH FORMAT, NAME = 'Log-Pubs backup 2';
GO

-- ============================================================================
-- PASO 4: PROTOCOLO DE CONTINGENCIA A (REVERTIR POR SNAPSHOT - ULTRA RÁPIDO)
-- ============================================================================
-- Escenario: Un script malintencionado corrompe datos y decidimos volver al snapshot de la mañana.
-- Forzamos el modo monousuario para desconectar sesiones activas.
USE master;
GO
ALTER DATABASE [pubs] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Buscamos y matamos los procesos que estén usando la SNAPSHOT
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'KILL ' + CAST(session_id AS NVARCHAR(10)) + N';'
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('pubs_snapshot_mañana');

-- Si encontró procesos abiertos, los ejecuta para liberar la snapshot
IF @sql <> N''
    EXEC sp_executesql @sql;
GO

-- Volcamos el snapshot sobre la base original (revierte los cambios instantáneamente)
RESTORE DATABASE [pubs] 
FROM DATABASE_SNAPSHOT = 'pubs_snapshot_mañana';
GO

ALTER DATABASE [pubs] SET MULTI_USER;
GO

-- Una vez validada la estabilidad, destruimos el snapshot (Buena práctica de rendimiento)
DROP DATABASE pubs_snapshot_mañana;
GO

-- ============================================================================
-- PASO 5: PROTOCOLO DE CONTINGENCIA B (RESTAURACIÓN TRADICIONAL COMPLETA)
-- ============================================================================
-- Escenario alternativo: Fallo físico de disco. Reconstrucción completa mediante archivos .bak y .trn.

-- Primero echamos a todos los usuarios de 'pubs' de forma inmediata y forzada
ALTER DATABASE [pubs] 
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE [pubs]
FROM DISK = 'c:\backups\pubs.bak'
WITH NORECOVERY, REPLACE;
GO

RESTORE DATABASE [pubs]
FROM DISK = 'C:\backups\pubs_diff.bak'
WITH NORECOVERY;
GO

RESTORE LOG [pubs]
FROM DISK = 'c:\backups\pubs_log1.trn'
WITH NORECOVERY;
GO

RESTORE LOG [pubs]
FROM DISK = 'c:\backups\pubs_log2.trn'
WITH RECOVERY;
GO