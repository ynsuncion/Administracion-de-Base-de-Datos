/*
Trabajo Integrador Final Administración de Base de Datos

Ejercicio 1

Contexto: La empresa requiere realizar una actualización masiva en la lista de precios de sus productos debido a una nueva normativa impositiva. 

Para garantizar la consistencia de los datos, la operación debe ser atómica (todo o nada).

Consigna: Escribir un script en Transact-SQL que cumpla con los siguientes requerimientos:

Lógica de Negocio: Incrementar un 15% el precio (ListPrice) de todos los productos de la tabla Production.Product cuyo precio actual sea mayor a cero.

Control de Transacciones: Si tras aplicar el incremento, el precio mínimo de los productos modificados no supera el promedio original de precios de la empresa,
la operación debe considerarse riesgosa y revertirse por completo (ROLLBACK). De lo contrario, se debe confirmar (COMMIT).

Manejo de Errores Dinámico: Envolver toda la lógica en un bloque TRY...CATCH. Si ocurre un error inesperado en la base de datos (por ejemplo, un error aritmético de división por cero simulado dinámicamente), se debe:
Verificar mediante funciones o variables del sistema si existe una transacción activa para revertirla.

Capturar las propiedades del error (ERROR_NUMBER(), ERROR_MESSAGE()).

Relanzar un error personalizado utilizando THROW o RAISERROR informando la falla crítica.
*/

USE AdventureWorks2008R2

DECLARE @PromedioOriginal MONEY;
DECLARE @MinimoPostIncremento MONEY;
DECLARE @FilasModificadas INT;

BEGIN TRY

    -- 1. Iniciamos la transacción controlada
    BEGIN TRANSACTION;
    PRINT '>>> Iniciando proceso de actualización masiva impositiva...';

    -- Obtener el promedio original antes del cambio
    SELECT @PromedioOriginal = AVG(ListPrice)
    FROM Production.Product
    WHERE ListPrice > 0;

    PRINT 'Auditoría: Promedio original de precios: $' + CAST(@PromedioOriginal AS VARCHAR);

    -- 2. Aplicamos la lógica de negocio (Incremento del 15%)
    -- Nota: Para probar el CATCH y el THROW, podés descomentar la línea de división por cero.
    UPDATE Production.Product
    SET ListPrice = (ListPrice * 1.15) -- / 0 <-- Descomentar para forzar error aritmético
    WHERE ListPrice > 0;

    -- Capturamos las filas afectadas inmediatamente usando la variable de sistema
    SET @FilasModificadas = @@ROWCOUNT;
    PRINT 'Auditoría: Productos afectados por el incremento: ' + CAST(@FilasModificadas AS VARCHAR);

    -- 3. Validación de regla de negocio post-incremento
    SELECT @MinimoPostIncremento = MIN(ListPrice)
    FROM Production.Product
    WHERE ListPrice > 0;

    PRINT 'Auditoría: Precio mínimo detectado post-incremento: $' + CAST(@MinimoPostIncremento AS VARCHAR);
    -- Evaluación de la condición solicitada
    IF @MinimoPostIncremento <= @PromedioOriginal
    BEGIN
        -- Si no supera el promedio, forzamos la reversión por regla de negocio
        ROLLBACK TRANSACTION;
        PRINT 'X OPERACIÓN REVERTIDA: El precio mínimo no superó el promedio original. Datos intactos.';
    END
    ELSE
    BEGIN
        -- Si pasa la validación, confirmamos los cambios de forma permanente
        COMMIT TRANSACTION;
        PRINT '  OPERACIÓN CONFIRMADA: Los precios se actualizaron exitosamente en un 15%.';
    END

END TRY
BEGIN CATCH
    -- 4. Gestión y captura de errores críticos del sistema
    PRINT '  SE DETECTÓ UN ERROR CRÍTICO EN LA EJECUCIÓN  ';

    -- Verificación de transacción activa mediante variable de sistema
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT '-> Transacción revertida automáticamente para preservar la integridad de AdventureWorks.';
    END;

    -- Captura de datos del error para la auditoría interna antes del THROW
    PRINT '--------------------------------------------------';
    PRINT 'Código de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Descripción: ' + ERROR_MESSAGE();
    PRINT 'Severidad: ' + CAST(ERROR_SEVERITY() AS VARCHAR);


    -- Lanzamos el error formal hacia la aplicacion o usuario utilizando THROW
    -- Usa el codigo 51000 que es el rango estandar para errores personalizados de usuario)

    THROW 51000, 'Error de Proceso : la actualizacion masiva falló debido a un problema tecnico o aritmetico interno. Operacion cancelada', 1;

      END CATCH;

   
/* Ejercicio 2

Contexto: La cadena de complejos deportivos "SportNet" requiere el diseño desde cero de su infraestructura de base de datos corporativa.
Debido al alto volumen de transacciones de accesos diarios, se exige una arquitectura que distribuya físicamente la información para optimizar el rendimiento de los discos, 
organice los módulos por responsabilidades mediante capas lógicas y estandarice tipos de datos críticos.

Consigna: Desarrollar un script unificado en Transact-SQL que implemente las siguientes directivas de arquitectura física y lógica:

Infraestructura de Almacenamiento (Sistema de Archivos): Crear la base de datos SportNetDB distribuyendo sus archivos en dos grupos diferenciados:

PRIMARY (Datos operativos y de configuración): Un archivo .MDF de 10 MB con crecimiento de 2 MB.

HISTORICO (Registro masivo de accesos/auditoría): Un grupo de archivos secundario con un archivo .NDF de 15 MB para balancear la carga de lectura/escritura de datos antiguos.

LOG (Transacciones): Un archivo .LDF de 5 MB con crecimiento de 1 MB.

Organización de Objetos (Esquemas): Estructurar la base de datos dividiéndola en dos áreas de negocio bien delimitadas: Socios (para datos personales y membresías) y Facturacion (para cobros y aranceles).
Estandarización de Dominios (UDT): Crear tipos de datos definidos por el usuario para asegurar la integridad semántica de la base de datos:

TipoDocumento (basado en VARCHAR(12), obligatorio).
CodigoPostal (basado en CHAR(8), opcional).

Construcción de Tablas Relacionales: Diseñar tres tablas interactuando con los esquemas y los UDT creados, definiendo correctamente sus claves primarias, externas y asignaciones de Filegroups:
Socios.FichaPersonal (Almacenada en el Filegroup PRIMARY).
Socios.RegistroAccesos (Almacenada explícitamente en el Filegroup HISTORICO).

*/

USE master;
GO

-- =========================================================================
-- 1. CREACIÓN DE LA BASE DE DATOS CON ARQUITECTURA MULTI-FILEGROUP
-- =========================================================================
PRINT '>>> Creando Base de Datos SportNetDB con Filegroups distribuidos...';

CREATE DATABASE SportNetDB
ON PRIMARY
(
    NAME = N'SportNet_Data',
    FILENAME = N'C:\DATA\SportNet.mdf',
    SIZE = 10 MB,
    MAXSIZE = 100 MB,
    FILEGROWTH = 2 MB
),
FILEGROUP HISTORICO
(
    NAME = N'SportNet_Historico_Data',
    FILENAME = N'C:\DATA\SportNet_Hist.ndf',
    SIZE = 15 MB,
    MAXSIZE = 200 MB,
    FILEGROWTH = 5 MB
)
LOG ON
(
    NAME = N'SportNet_Log',
    FILENAME = N'C:\DATA\SportNet_Log.ldf',
    SIZE = 5 MB,
    MAXSIZE = 50 MB,
    FILEGROWTH = 1 MB
);
GO

-- Poner en uso la base de datos e iniciar operaciones lógicas
USE SportNetDB;
GO

-- Verificación de la base de datos en el catálogo general
SELECT name, database_id, create_date, recovery_model_desc
FROM sys.databases
WHERE name = 'SportNetDB';
GO

-- =========================================================================
-- 2. CREACIÓN DE CAPAS LÓGICAS DE ORGANIZACIÓN (ESQUEMAS)
-- =========================================================================
PRINT '>>> Creando esquemas de negocio...';
GO 

CREATE SCHEMA Socios;
GO

CREATE SCHEMA Facturacion;
GO

-- Verificación de esquemas agregados (filtramos esquemas del sistema)
SELECT name, schema_id, principal_id
FROM sys.schemas
WHERE name IN ('Socios', 'Facturacion');
GO

-- =========================================================================
-- 3. DEFINICIÓN DE TIPOS DE DATOS DE USUARIO (UDT)
-- =========================================================================
PRINT '>>> Creando Tipos de Datos Personalizados (UDT)...';
CREATE TYPE TipoDocumento FROM VARCHAR(12) NOT NULL;
GO
CREATE TYPE CodigoPostal FROM CHAR(8) NULL;
GO

-- Verificación de tipos de datos en las vistas de sistema
SELECT name, system_type_id, max_length, is_nullable
FROM sys.types
WHERE is_user_defined = 1;
GO

-- =========================================================================
-- 4. CONSTRUCCIÓN DE TABLAS OPERATIVAS Y ASIGNACIÓN DE FILEGROUPS
-- =========================================================================
PRINT '>>> Creando estructuras de tablas con segmentación física...';

-- Tabla de Socios en el Filegroup Principal (PRIMARY por defecto)
CREATE TABLE Socios.FichaPersonal
(
    SocioID INT IDENTITY(1,1),
    Apellido VARCHAR(50) NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Documento TipoDocumento,  -- Uso de UDT
    CP CodigoPostal,          -- Uso de UDT
    FechaAlta DATE DEFAULT GETDATE(),
    CONSTRAINT PK_FichaPersonal PRIMARY KEY (SocioID)
) ON [PRIMARY];
GO

-- Tabla de Accesos Históricos direccionada al Filegroup de Alto Rendimiento (HISTORICO)
CREATE TABLE Socios.RegistroAccesos
(
    AccesoID BIGINT IDENTITY(1,1),
    SocioID INT NOT NULL,
    FechaHora DATETIME DEFAULT GETDATE(),
    DispositivoID INT NOT NULL,
    CONSTRAINT PK_RegistroAccesos PRIMARY KEY (AccesoID),
    CONSTRAINT FK_RegistroAccesos_Socios FOREIGN KEY (SocioID)
        REFERENCES Socios.FichaPersonal(SocioID)
) ON [HISTORICO]; -- Segmentación física de datos masivos
GO

/* Ejercicio 3
Contexto: El departamento de desarrollo de software ha detectado serios problemas de redundancia, anomalías de actualización y falta de integridad 
en el almacenamiento de las solicitudes de cotización. Se presenta una estructura no normalizada (vistas de tabla única o "tabla plana") y se solicita su proceso de normalización completo.

Consigna: Dada la siguiente estructura de datos plana:

Presupuesto_Solicitado = #Presupuesto + Fecha_Dia + Fecha_Caducidad + Razon_Social_Cliente + Codigo_Producto + Descripcion_Producto + Precio_Unitario + Cantidad + Precio_x_Cantidad +
Precio_Total

Aplicar el proceso de normalización paso a paso explicando las transformaciones para alcanzar la Primera (1FN), Segunda (2FN) y Tercera (3FN) Forma Normal. 
Omitir los atributos derivados o calculados en el modelo físico final para respetar las buenas prácticas de bases de datos relacionales.
*/

/*
Primera Forma Normal (1FN)
Presupuesto_Solicitado =  @#Presupuesto, Codigo_Producto, Fecha_Dia, Fecha_Caducidad, Razon_Social_Cliente, Descripcion_Producto, Precio_Unitario, Cantidad

Un mismo presupuesto puede contener varios productos y un producto puede aparecer en distintos presupuestos.

Segunda Forma Normal (2FN)

PRESUPUESTOS = @#Presupuesto, Fecha_Dia, Fecha_Caducidad, Razon_Social_Cliente
PRODUCTOS = Codigo_Producto, Descripcion_Producto, Precio_Unitario
DETALLE_PRESUPUESTOS @#Presupuesto, Codigo_Producto, Cantidad

Tercera Forma Normal (3FN)

CLIENTES = @ID_Cliente, Razon_Social_Cliente

PRESUPUESTOS = @#Presupuesto, Fecha_Dia, Fecha_Caducidad, ID_Cliente

PRODUCTOS = Codigo_Producto, Descripcion_Producto, Precio_Unitario

DETALLE_PRESUPUESTOS = @#Presupuesto, Codigo_Producto, Cantidad

*/

/* Ejercicio 4 

Contexto: El departamento de auditoría detectó que las búsquedas y reportes sobre la tabla de socios están sufriendo serios problemas de rendimiento debido a 
la falta de una estrategia de indexación sólida. Además, se han reportado ingresos de números de documentos duplicados. Se solicita rediseñar la estructura de índices de la tabla
para garantizar la máxima velocidad de consulta y asegurar la integridad de los datos.

Consigna: Escribir un script unificado en Transact-SQL que simule y resuelva el ciclo de vida de optimización de la tabla Socios.FichaPersonal cumpliendo las siguientes directivas:

Punto de Partida Ineficiente: Crear la estructura base sin asignación automática de índices y cargar registros que fuercen la existencia de apellidos duplicados.

Conflicto de Unicidad: Intentar aplicar un índice agrupado único sobre una columna con datos duplicados para analizar el comportamiento del motor.

Estrategia de Indexación Mixta: * Implementar un índice agrupado no único para optimizar búsquedas por rangos alfabéticos de apellidos.

Configurar la clave primaria de forma "No Agrupada" para evitar conflictos estructurales inmediatos.

Garantía de Integridad: Crear un índice único no agrupado para el documento de identidad y verificar el bloqueo ante intentos de duplicación.
Reingeniería Estructural (Refactorización): Demostrar la capacidad de reestructurar la tabla eliminando el índice anterior y regenerando la Clave Primaria para que sea, finalmente, 
el índice agrupado principal de la tabla.

USE SportNetDB;
GO

-- ============================================================================
-- 1. PREPARACIÓN DEL ESCENARIO (ESTRUCTURA BASE SIN ÍNDICES AUTOMÁTICOS)
-- ============================================================================
PRINT '>>> 1. Creando tabla de optimización de socios...';

-- Eliminamos la tabla si ya existía del punto 2 para hacer la simulación limpia
IF OBJECT_ID('Socios.FichaPersonal') IS NOT NULL 
    DROP TABLE Socios.FichaPersonal;
GO

CREATE TABLE Socios.FichaPersonal
(
    SocioID CHAR(5) NOT NULL,
    Documento CHAR(8) NOT NULL,
    Apellido VARCHAR(30) NOT NULL,
    Nombre VARCHAR(30) NOT NULL,
    ArancelMensual DECIMAL(10,2) NULL
);
GO

-- Inserción de registros de prueba (con apellidos duplicados adrede)
INSERT INTO Socios.FichaPersonal (SocioID, Documento, Apellido, Nombre, ArancelMensual)
VALUES  
('S0001', '40123456', 'Pérez', 'Juan', 8500.00),
('S0002', '41123457', 'Pérez', 'María', 7250.00),
('S0003', '42123458', 'Gómez', 'Lucas', 9000.00),
('S0004', '43123459', 'Rodríguez', 'Ana', 6500.00),
('S0005', '44123460', 'Fernández', 'Luis', 4000.00),
('S0006', '45123461', 'López', 'Laura', 9750.00);
GO

*/

USE SportNetDB;
GO

-- ============================================================================
-- 1. PREPARACIÓN DEL ESCENARIO (ESTRUCTURA BASE SIN ÍNDICES AUTOMÁTICOS)
-- ============================================================================

-- Eliminamos la tabla si ya existía del punto 2 para hacer la simulación limpia
IF OBJECT_ID('Socios.FichaPersonal') IS NOT NULL 
    DROP TABLE Socios.FichaPersonal;
GO

CREATE TABLE Socios.FichaPersonal
(
    SocioID CHAR(5) NOT NULL,
    Documento CHAR(8) NOT NULL,
    Apellido VARCHAR(30) NOT NULL,
    Nombre VARCHAR(30) NOT NULL,
    ArancelMensual DECIMAL(10,2) NULL
);
GO

-- Inserción de registros de prueba (con apellidos duplicados adrede)
INSERT INTO Socios.FichaPersonal (SocioID, Documento, Apellido, Nombre, ArancelMensual)
VALUES  
('S0001', '40123456', 'Pérez', 'Juan', 8500.00),
('S0002', '41123457', 'Pérez', 'María', 7250.00),
('S0003', '42123458', 'Gómez', 'Lucas', 9000.00),
('S0004', '43123459', 'Rodríguez', 'Ana', 6500.00),
('S0005', '44123460', 'Fernández', 'Luis', 4000.00),
('S0006', '45123461', 'López', 'Laura', 9750.00);
GO

-- ============================================================================
-- 2. CONFLICTO DE UNICIDAD (INTENTO DE ÍNDICE ÚNICO SOBRE DUPLICADOS)
-- ============================================================================
-- Intento aplicar unicidad sobre 'Apellido', sabiendo que existen dos 'Pérez'.
-- Se arroja el error 1505, ya que la unicidad es una restricción física.

    CREATE UNIQUE CLUSTERED INDEX FichaPersonal_Apellido_Unico 
    ON Socios.FichaPersonal(Apellido);
    
GO

-- ============================================================================
-- 3. ESTRATEGIA DE INDEXACIÓN MIXTA
-- ============================================================================

-- A. Creamos el índice agrupado NO único para optimizar búsquedas por rangos alfabéticos
-- Como el índice agrupado ordena físicamente los datos, esto acelera reportes por apellido.

CREATE CLUSTERED INDEX FichaPersonal_Apellido 
ON Socios.FichaPersonal(Apellido);
GO

-- B. Configuramos la Clave Primaria como NO Agrupada (Non-Clustered)
-- Esto permite que la PK garantice unicidad sin forzar el reordenamiento físico de toda la tabla.

ALTER TABLE Socios.FichaPersonal
ADD CONSTRAINT PK_FichaPersonal PRIMARY KEY NONCLUSTERED (SocioID);
GO

-- ============================================================================
-- 4. GARANTÍA DE INTEGRIDAD (ÍNDICE ÚNICO NO AGRUPADO)
-- ============================================================================

CREATE UNIQUE NONCLUSTERED INDEX FichaPersonal_Documento 
ON Socios.FichaPersonal(Documento);
GO

-- Verificando el bloqueo ante un intento de duplicación de documento

    INSERT INTO Socios.FichaPersonal (SocioID, Documento, Apellido, Nombre, ArancelMensual)
    VALUES ('S0007', '40123456', 'Alvarez', 'Carlos', 5000.00); -- Documento repetido de Juan Pérez

   -- ============================================================================
-- 5. REINGENIERÍA ESTRUCTURAL (REFACTORIZACIÓN)
-- ============================================================================


-- A. Elimino el índice agrupado anterior sobre la columna Apellido
DROP INDEX FichaPersonal_Apellido ON Socios.FichaPersonal;
GO

-- B. Elimino la Clave Primaria No Agrupada actual
ALTER TABLE Socios.FichaPersonal
DROP CONSTRAINT PK_FichaPersonal;
GO

-- C. Regenero la Clave Primaria para que sea el índice agrupado principal de la tabla.

ALTER TABLE Socios.FichaPersonal
ADD CONSTRAINT PK_FichaPersonal PRIMARY KEY CLUSTERED (SocioID);
GO

/*
Ejercicio 5

Contexto: El volumen de transacciones de preventas y detalles de órdenes en AdventureWorks ha crecido exponencialmente, ralentizando los índices 
y aumentando los tiempos de mantenimiento de backups. Como Ingeniero de Datos / DBA, se le solicita diseñar e implementar una arquitectura de tabla particionada 
para la auditoría de ventas trimestrales del año 2011(Sales.SalesOrderDetail), distribuyendo la carga en almacenamiento físico diferenciado para optimizar el rendimiento de entrada/salida (I/O).

Consigna: Desarrollar un script en Transact-SQL que ejecute paso a paso las siguientes fases de ingeniería de almacenamiento:

Infraestructura Física: Crear 4 Filegroups independientes con un archivo secundario (.ndf) cada uno en el directorio de datos.

Lógica de Particionado: Definir una función de partición basada en rangos temporales para segmentar los trimestres de un año fiscal y mapearlos 
mediante un esquema de partición a los Filegroups creados.

Migración Masiva: Construir una réplica de la tabla de órdenes de venta particionada, poblarla con la información histórica real de AdventureWorks y testear
inserciones en los límites de los rangos.

Metadatos y Auditoría: Consultar las vistas del sistema para auditar la distribución de registros por partición exacta, documentando detalladamente las diferencias operativas de las funciones de partición.
Rollback Estructural: Proveer la secuencia de desmantelamiento seguro y ordenado de los objetos creados para limpieza del entorno.
*/

use AdventureWorks2008R2 


-- ============================================================================
-- 1. INFRAESTRUCTURA FÍSICA: CREACIÓN DE FILEGROUPS Y ARCHIVOS (.NDF)
-- ============================================================================

-- A. AGREGAR LOS 4 FILEGROUPS INDEPENDIENTES

ALTER DATABASE AdventureWorks2008R2  ADD FILEGROUP fg1;
ALTER DATABASE AdventureWorks2008R2  ADD FILEGROUP fg2;
ALTER DATABASE AdventureWorks2008R2  ADD FILEGROUP fg3;
ALTER DATABASE AdventureWorks2008R2  ADD FILEGROUP fg4;
GO

-- B. ASIGNAR UN ARCHIVO SECUNDARIO A CADA FILEGROUP
-- Importante: Verifica que la ruta 'C:\SQLData\' exista en tu servidor o reemplázala por tu ruta de datos.


ALTER DATABASE AdventureWorks2008R2
ADD FILE 
(
    NAME = data1,
    FILENAME = 'C:\SQLData\data1.ndf',
    SIZE = 1MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 1MB
) 
TO FILEGROUP fg1;
GO

ALTER DATABASE AdventureWorks2008R2
ADD FILE 
(
    NAME = data2,
    FILENAME = 'C:\SQLData\data2.ndf',
    SIZE = 1MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 1MB
) 
TO FILEGROUP fg2;
GO

ALTER DATABASE AdventureWorks2008R2
ADD FILE 
(
    NAME = data3,
    FILENAME = 'C:\SQLData\data3.ndf',
    SIZE = 1MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 1MB
) 
TO FILEGROUP fg3;
GO

ALTER DATABASE AdventureWorks2008R2
ADD FILE 
(
    NAME = data4,
    FILENAME = 'C:\SQLData\data4.ndf',
    SIZE = 1MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 1MB
) 
TO FILEGROUP fg4;
GO


-- ALTER DATABASE AdventureWorks2008R2  SET MULTI_USER;
-- GO

-- Lógica de Particionado: Definir una función de partición basada en rangos temporales para segmentar los trimestres de un año fiscal y mapearlos 
-- mediante un esquema de partición a los Filegroups creados.

-- ============================================================================
-- 2. LÓGICA DE PARTICIONADO: FUNCIÓN Y ESQUEMA DE PARTICIÓN
-- ============================================================================

CREATE PARTITION FUNCTION pflimites (DATETIME)
AS RANGE RIGHT FOR VALUES 
('2011-04-01', '2011-07-01', '2011-10-01');
GO

-- B. ESQUEMA DE PARTICIÓN
-- Mapea las 4 particiones lógicas a los 4 Filegroups físicos creados anteriormente.

CREATE PARTITION SCHEME pslimites
AS PARTITION pflimites
TO (fg1, fg2, fg3, fg4);
GO

-- ============================================================================
-- 3. MIGRACION MASIVA
-- ============================================================================
-- Migración Masiva: Construir una réplica de la tabla de órdenes de venta particionada, 
-- poblarla con la información histórica real de AdventureWorks y testear
-- inserciones en los límites de los rangos.

CREATE TABLE dbo.PartitionedTransactions
(
	TransactionID int IDENTITY(1,1) NOT NULL,
	ProductID int NOT NULL,
	TransactionDate datetime NOT NULL DEFAULT (getdate()),
	TransactionType nchar(1) NOT NULL
)
ON pslimites(TransactionDate)
GO

-- Insert data
INSERT INTO dbo.PartitionedTransactions
SELECT	ProductID, TransactionDate, TransactionType
FROM Production.TransactionHistory
GO

INSERT INTO dbo.PartitionedTransactions
VALUES
(1, '01/01/2011', 'S')
GO

select * from dbo.PartitionedTransactions

 -- poblarla con la información histórica real de AdventureWorks y testear
-- inserciones en los límites de los rangos

INSERT INTO dbo.PartitionedTransactions
VALUES (1,'2011-04-01','S');

INSERT INTO dbo.PartitionedTransactions
VALUES (1,'2011-07-01','S');

INSERT INTO dbo.PartitionedTransactions
VALUES (1,'2011-10-01','S');

-- ============================================================================
-- 4. METADATOS Y AUDITORIA 
-- ============================================================================
-- Consultar las vistas del sistema para auditar la distribución de registros por partición exacta, documentando detalladamente las diferencias operativas de las funciones de partición.
-- Rollback Estructural: Proveer la secuencia de desmantelamiento seguro y ordenado de los objetos creados para limpieza del entorno.

SELECT * FROM sys.Partitions
WHERE [object_id] = OBJECT_ID('dbo.PartitionedTransactions')

-- View data with partition number
SELECT TransactionID, TransactionDate, $Partition.pflimites(TransactionDate) PartitionNo
FROM dbo.PartitionedTransactions

-- Verify lowest value in each partition
SELECT MIN(TransactionDate) FirstTran, $Partition.pflimites(TransactionDate) PartitionNo
FROM dbo.PartitionedTransactions
GROUP BY $Partition.pflimites(TransactionDate)
ORDER BY PartitionNo

-- ============================================================================
-- 5. ROLLBACK ESTRUCTURAL
-- ============================================================================

DROP TABLE dbo.PartitionedTransactions;
GO

DROP PARTITION SCHEME pslimites;
GO

DROP PARTITION FUNCTION pflimites;
GO

ALTER DATABASE AdventureWorks2008R2 REMOVE FILE data1;
ALTER DATABASE AdventureWorks2008R2 REMOVE FILE data2;
ALTER DATABASE AdventureWorks2008R2 REMOVE FILE data3;
ALTER DATABASE AdventureWorks2008R2 REMOVE FILE data4;
GO

ALTER DATABASE AdventureWorks2008R2 REMOVE FILEGROUP fg1;
ALTER DATABASE AdventureWorks2008R2 REMOVE FILEGROUP fg2;
ALTER DATABASE AdventureWorks2008R2 REMOVE FILEGROUP fg3;
ALTER DATABASE AdventureWorks2008R2 REMOVE FILEGROUP fg4;
GO


/* 
Ejercicio 6

Contexto: La Fintech "CryptoAr" está expandiendo su infraestructura y requiere configurar la seguridad de acceso global para su nueva instancia de producción de SQL Server. 
La política corporativa exige auditorías estrictas de acceso, separación de funciones según el principio de "privilegio mínimo" y la habilitación segura de logins de aplicaciones.

Consigna: Escribir un script unificado en Transact-SQL que implemente la configuración de seguridad perimetral del servidor bajo los siguientes requerimientos:

Auditoría de Instancia: Verificar programáticamente el modo de seguridad de la instancia. Si no admite logins internos, dejar documentado el
procedimiento de cambio a modo mixto y el requerimiento operativo de infraestructura.

Aprovisionamiento con Políticas: Crear tres logins de servidor para el nuevo personal del Centro de Operaciones de Red (NOC) y del Equipo de Seguridad (SecOps):
SecAuditor_Gomez
NocMonitor_Lopez
DbaJunior_Paz

Todos deben cumplir obligatoriamente con las políticas de expiración y complejidad del sistema operativo.

Gestión de Ciclo de Vida: Simular una ventana de mantenimiento donde se bloqueen accesos sospechosos, se reestablezcan 
credenciales comprometidas y se reasigne el contexto de base de datos por defecto a un entorno seguro corporativo.

Separación de Funciones (Server Roles): Asignar roles fijos de servidor específicos según el perfil técnico:

El auditor debe poder revisar logs y configuraciones globales (securityadmin).
El monitor del NOC debe analizar la salud, recursos y procesos del motor (processadmin).
El DBA Junior debe administrar el espacio en disco y archivos lógicos (diskadmin).
Validación Dinámica: Consultar las vistas de catálogo del sistema para verificar estados y mapeos de roles vigentes.

*/

USE master

-- ============================================================================
-- 1. AUDITORIA DE INSTANCIA
-- ============================================================================

-- Verificar programáticamente el modo de seguridad de la instancia. Si no admite logins internos, dejar documentado el
-- procedimiento de cambio a modo mixto y el requerimiento operativo de infraestructura.


SELECT 
    SERVERPROPERTY('MachineName') AS ServidorFisico,
    SERVERPROPERTY('ServerName') AS InstanciaSQL,
    CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
        WHEN 0 THEN 'MODO MIXTO (Windows + SQL Server logins habilitados)'
        WHEN 1 THEN 'SOLO WINDOWS (SQL Logins deshabilitados)'
        ELSE 'Estado desconocido'
    END AS ModoSeguridad;
GO
/*
===========================================================
CAMBIO A MODO MIXTO (SI ES NECESARIO)
===========================================================

EXEC xp_instance_regwrite 
    N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'LoginMode',
    REG_DWORD,
    2;  -- Mixed Mode

REQUERIMIENTO:
- Reinicio del servicio SQL Server obligatorio
- Validación con SERVERPROPERTY
*/


-- ============================================================================
-- 2. APROVISIONAMIENTO CON POLITICAS
-- ============================================================================
-- Crear tres logins de servidor para el nuevo personal del Centro de Operaciones de Red (NOC) y del Equipo de Seguridad (SecOps):
/* SecAuditor_Gomez
NocMonitor_Lopez
DbaJunior_Paz

*/


CREATE LOGIN SecAuditor_Gomez
WITH PASSWORD = 'UnaPasswordFuerte#2026',
DEFAULT_DATABASE = [master],
CHECK_POLICY = ON,
CHECK_EXPIRATION = ON;
GO

CREATE LOGIN NocMonitor_Lopez
WITH PASSWORD = 'OtraPasswordFuerte#2026',
DEFAULT_DATABASE = [master],
CHECK_POLICY = ON,
CHECK_EXPIRATION = ON;
GO

CREATE LOGIN DbaJunior_Paz
WITH PASSWORD = 'TerceraPasswordFuerte#2026',
DEFAULT_DATABASE = [master],
CHECK_POLICY = ON,
CHECK_EXPIRATION = ON;
GO

-- ============================================================================
-- 3. GESTION DE CICLO DE VIDA
-- ============================================================================
/*  Simular una ventana de mantenimiento donde se bloqueen accesos sospechosos, se reestablezcan 
credenciales comprometidas y se reasigne el contexto de base de datos por defecto a un entorno seguro corporativo. */

-- Bloqueo preventivo de accesos sospechosos
ALTER LOGIN SecAuditor_Gomez DISABLE;
ALTER LOGIN NocMonitor_Lopez DISABLE;
ALTER LOGIN DbaJunior_Paz DISABLE;
GO
-- se reestablezcan credenciales comprometidas 
ALTER LOGIN SecAuditor_Gomez WITH PASSWORD = 'Nuev@PasswordAuditor2026#' MUST_CHANGE;
ALTER LOGIN NocMonitor_Lopez WITH PASSWORD = 'Nuev@PasswordMonitor2026#' MUST_CHANGE;
ALTER LOGIN DbaJunior_Paz WITH PASSWORD = 'Nuev@PasswordDbaJr2026#' MUST_CHANGE;
GO

---  Reasignación de contexto de Base de Datos por defecto a un entorno seguro corporativo
-- Se asume que existe la BD corporativa o se usa 'seguridaddb' para evitar apuntar a 'master'
-- Por seguridad y portabilidad en el ejemplo, mitigamos apuntando temporalmente a tempdb.

create database seguridaddb
ALTER LOGIN SecAuditor_Gomez WITH DEFAULT_DATABASE = [seguridaddb];
ALTER LOGIN NocMonitor_Lopez WITH DEFAULT_DATABASE = [seguridaddb];
ALTER LOGIN DbaJunior_Paz WITH DEFAULT_DATABASE = [seguridaddb];
GO

ALTER LOGIN SecAuditor_Gomez ENABLE;
ALTER LOGIN NocMonitor_Lopez ENABLE;
ALTER LOGIN DbaJunior_Paz ENABLE;
GO

-- ============================================================================
-- 4. SEPARACION DE FUNCIONES (SERVER ROLES)
-- ============================================================================
-- Asignar roles fijos de servidor específicos según el perfil técnico:

-- El auditor debe poder revisar logs y configuraciones globales (securityadmin).

ALTER SERVER ROLE securityadmin ADD MEMBER SecAuditor_Gomez;

-- El monitor del NOC debe analizar la salud, recursos y procesos del motor (processadmin).
ALTER SERVER ROLE processadmin ADD MEMBER NocMonitor_Lopez;

-- El DBA Junior debe administrar el espacio en disco y archivos lógicos (diskadmin).
ALTER SERVER ROLE diskadmin  ADD MEMBER DbaJunior_Paz;

-- Validación Dinámica: Consultar las vistas de catálogo del sistema para verificar estados y mapeos de roles vigentes.

SELECT 
    member.name AS LoginName,
    role.name AS ServerRole
FROM sys.server_role_members srm
JOIN sys.server_principals role ON srm.role_principal_id = role.principal_id
JOIN sys.server_principals member ON srm.member_principal_id = member.principal_id
WHERE member.name IN ('SecAuditor_Gomez', 'NocMonitor_Lopez', 'DbaJunior_Paz')
ORDER BY member.name, role.name;
GO

/*
Ejercicio 7

Contexto: La plataforma de streaming "StreamPlay" necesita configurar la seguridad interna de su base de datos de producción. 
El área de ciberseguridad exige aplicar de forma estricta el principio de "privilegio mínimo", resguardar datos sensibles de los clientes
(como los métodos de pago) y dar acceso controlado al equipo de soporte, creadores de contenido y auditores de sistemas.

Consigna: Desarrollar un script unificado en Transact-SQL que implemente la infraestructura de seguridad lógica en la base de datos StreamPlayDB
resolviendo los siguientes requerimientos prácticos:

Modelado Base: Crear la base de datos y tres estructuras clave: Suscripciones (datos de usuarios y cobros), Catalogo (películas y series) y Visualizaciones (historial de reproducción).

Aprovisionamiento Perimetral: Crear cinco logins a nivel de servidor y sus correspondientes usuarios mapeados exclusivamente dentro de la base de datos del negocio.

Roles de Base de Datos: Asignar los roles fijos db_datareader y db_datawriter según corresponda para dar acceso de lectura global o control operativo de datos.

Seguridad Granular (GRANT): Configurar permisos específicos tabla por tabla para perfiles gerenciales, limitando la capacidad de eliminación destructiva de registros.

Restricción de Privilegios (DENY): Implementar bloqueos perimetrales absolutos mediante DENY. Se debe proteger el catálogo de modificaciones accidentales y ocultar columnas con datos financieros sensibles a nivel de celda.

Seguridad Avanzada y Roles Personalizados: Crear un rol de auditoría a la medida que herede permisos de lectura y obtenga privilegios de inspección de código fuente (VIEW DEFINITION).

Normalización de Permisos (REVOKE): Demostrar la remoción de privilegios explícitos para devolver una entidad a su estado heredado neutral.
*/

-- ============================================================================
-- 1. MODELADO DE BASES
-- ============================================================================
--  Crear la base de datos y tres estructuras clave: Suscripciones (datos de usuarios y cobros), Catalogo (películas y series) y Visualizaciones (historial de reproducción).

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'StreamPlayDB')
    DROP DATABASE StreamPlayDB;
GO

CREATE DATABASE StreamPlayDB;
GO

USE StreamPlayDB;
GO

-- Crear tablas de ejemplo

CREATE TABLE dbo.Suscripciones (
     IdSuscripcion INT IDENTITY(1,1) PRIMARY KEY,

    NombreUsuario VARCHAR(100) NOT NULL,

    Email VARCHAR(150) NOT NULL UNIQUE,

    MetodoPago VARCHAR(50) NOT NULL,

    NumeroTarjeta VARCHAR(30) NOT NULL,

    FechaAlta DATE NOT NULL DEFAULT GETDATE(),

    TipoPlan VARCHAR(30) NOT NULL,

    EstadoSuscripcion VARCHAR(20) NOT NULL
        CHECK (EstadoSuscripcion IN ('Activa','Suspendida','Cancelada')),

    ImporteMensual DECIMAL(10,2) NOT NULL
);
GO



CREATE TABLE dbo.Catalogo
(
    IdContenido INT IDENTITY(1,1) PRIMARY KEY,

    Titulo VARCHAR(200) NOT NULL,

    TipoContenido VARCHAR(20) NOT NULL
        CHECK (TipoContenido IN ('Pelicula','Serie')),

    Genero VARCHAR(100) NOT NULL,

    AnioLanzamiento INT NOT NULL,

    ClasificacionEdad VARCHAR(10),

    Activo BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE dbo.Visualizaciones
(
    IdVisualizacion INT IDENTITY(1,1) PRIMARY KEY,

    IdSuscripcion INT NOT NULL,

    IdContenido INT NOT NULL,

    FechaVisualizacion DATETIME NOT NULL DEFAULT GETDATE(),

    MinutosReproducidos INT NOT NULL,

    Dispositivo VARCHAR(50),

    CONSTRAINT FK_Visualizaciones_Suscripciones
        FOREIGN KEY (IdSuscripcion)
        REFERENCES Suscripciones(IdSuscripcion),

    CONSTRAINT FK_Visualizaciones_Catalogo
        FOREIGN KEY (IdContenido)
        REFERENCES Catalogo(IdContenido)
);
GO

/* ==========================================================
   DATOS DE PRUEBA
   ========================================================== */

INSERT INTO dbo.Suscripciones
(
    NombreUsuario,
    Email,
    MetodoPago,
    NumeroTarjeta,
    TipoPlan,
    EstadoSuscripcion,
    ImporteMensual
)
VALUES
('Juan Perez','juan@correo.com','Visa','4111111111111111','Premium','Activa',15.99),
('Maria Gomez','maria@correo.com','Mastercard','5500000000000004','Estandar','Activa',9.99);
GO

INSERT INTO dbo.Catalogo
(
    Titulo,
    TipoContenido,
    Genero,
    AnioLanzamiento,
    ClasificacionEdad
)
VALUES
('La Gran Aventura','Pelicula','Accion',2024,'+13'),
('Codigo Oscuro','Serie','Suspenso',2025,'+16');
GO

INSERT INTO dbo.Visualizaciones
(
    IdSuscripcion,
    IdContenido,
    MinutosReproducidos,
    Dispositivo
)
VALUES
(1,1,120,'Smart TV'),
(2,2,45,'Celular');
GO

/* ==========================================================
   CONSULTA DE VERIFICACION
   ========================================================== */

SELECT * FROM Suscripciones;
SELECT * FROM Catalogo;
SELECT * FROM Visualizaciones;
GO

-- ============================================================================
-- 2. APROVISIONAMIENTO PERIMETRAL
-- ============================================================================
--  Crear cinco logins a nivel de servidor y sus correspondientes usuarios mapeados exclusivamente dentro de la base de datos del negocio.

USE master;
GO

-- Eliminar logins si existen 
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'login_admin_stream')
    DROP LOGIN login_admin_stream;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'login_soporte')
    DROP LOGIN login_soporte;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'login_creador')
    DROP LOGIN login_creador;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'login_auditor')
    DROP LOGIN login_auditor;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'login_reportes')
    DROP LOGIN login_reportes;
GO

-- Crear logins

CREATE LOGIN login_admin_stream
WITH PASSWORD = 'Admin#2026';

CREATE LOGIN login_soporte
WITH PASSWORD = 'Soporte#2026';

CREATE LOGIN login_creador
WITH PASSWORD = 'Creador#2026';

CREATE LOGIN login_auditor
WITH PASSWORD = 'Auditor#2026';

CREATE LOGIN login_reportes
WITH PASSWORD = 'Reportes#2026';
GO

PRINT '? Logins creados en el servidor';
GO

USE StreamPlayDB;
GO

/* Eliminar usuarios si existen (opcional) */

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usr_admin_stream')
    DROP USER usr_admin_stream;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usr_soporte')
    DROP USER usr_soporte;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usr_creador')
    DROP USER usr_creador;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usr_auditor')
    DROP USER usr_auditor;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usr_reportes')
    DROP USER usr_reportes;
GO

/* Mapear usuarios a logins */

CREATE USER usr_admin_stream
FOR LOGIN login_admin_stream;
GO

CREATE USER usr_soporte
FOR LOGIN login_soporte;
GO

CREATE USER usr_creador
FOR LOGIN login_creador;
GO

CREATE USER usr_auditor
FOR LOGIN login_auditor;
GO

CREATE USER usr_reportes
FOR LOGIN login_reportes;
GO


-- verificacion
SELECT name, type_desc
FROM sys.server_principals
WHERE name LIKE 'login_%';

USE StreamPlayDB;
GO

SELECT name, type_desc
FROM sys.database_principals
WHERE name LIKE 'usr_%';


-- ============================================================================
-- 3. ROLES DE BASE DE DATOS
-- ============================================================================
-- Asignar los roles fijos db_datareader y db_datawriter según corresponda para dar acceso de lectura global o control operativo de datos.

ALTER ROLE db_datareader ADD MEMBER usr_admin_stream;
ALTER ROLE db_datawriter ADD MEMBER usr_admin_stream;
GO

ALTER ROLE db_datareader ADD MEMBER usr_soporte;
GO


ALTER ROLE db_datareader ADD MEMBER usr_creador;
ALTER ROLE db_datawriter ADD MEMBER usr_creador;
GO

ALTER ROLE db_datareader ADD MEMBER usr_reportes;
GO

ALTER ROLE db_datareader ADD MEMBER usr_auditor;
GO

-- ============================================================================
-- 4. SEGURIDAD GRANULAR (GRANT)
-- ============================================================================
-- Configurar permisos específicos tabla por tabla para perfiles gerenciales, 
-- limitando la capacidad de eliminación destructiva de registros.

GRANT SELECT, UPDATE ON dbo.suscripciones TO usr_admin_stream;
GRANT SELECT, UPDATE ON dbo.catalogo TO usr_admin_stream;
GRANT SELECT, UPDATE ON dbo.Visualizaciones TO usr_admin_stream;

-- verificacion 
SELECT 
    dp.name AS Usuario,
    o.name AS Objeto,
    p.permission_name,
    p.state_desc
FROM sys.database_permissions p
JOIN sys.database_principals dp
    ON p.grantee_principal_id = dp.principal_id
JOIN sys.objects o
    ON p.major_id = o.object_id
WHERE dp.name = 'usr_admin_stream';

 
 -- ============================================================================
-- 5. RESTRICCION DE PRIVILEGIOS (DENY)
-- ============================================================================
--  Implementar bloqueos perimetrales absolutos mediante DENY. 
-- Se debe proteger el catálogo de modificaciones accidentales y ocultar columnas con datos financieros sensibles a nivel de celda.

DENY DELETE ON dbo.suscripciones TO usr_admin_stream;

-- Proteger catálogo contra modificaciones accidentales
DENY UPDATE ON dbo.Catalogo TO usr_admin_stream;
GO

-- Ocultar datos financieros sensibles (nivel columna)
DENY SELECT ON dbo.Suscripciones (NumeroTarjeta) TO usr_admin_stream;
GO

DENY SELECT ON dbo.Suscripciones (MetodoPago) TO usr_admin_stream;
GO


-- verificacion

SELECT 
    dp.name AS Usuario,
    o.name AS Objeto,
    c.name AS Columna,
    p.permission_name,
    p.state_desc
FROM sys.database_permissions p
JOIN sys.database_principals dp
    ON p.grantee_principal_id = dp.principal_id
JOIN sys.objects o
    ON p.major_id = o.object_id
LEFT JOIN sys.columns c
    ON p.major_id = c.object_id 
   AND p.minor_id = c.column_id
WHERE dp.name = 'usr_admin_stream';

-- ============================================================================
-- 6. SEGURIDAD AVANZADA Y ROLES PERSONALIZADOS
-- ============================================================================

--  Crear un rol de auditoría a la medida que herede permisos de lectura y obtenga privilegios de inspección de código fuente (VIEW DEFINITION).

CREATE ROLE [AuditorRole];
GO

ALTER ROLE [db_datareader] ADD MEMBER [AuditorRole];
GO

GRANT VIEW DEFINITION TO [AuditorRole];
GO


ALTER ROLE [AuditorRole] ADD MEMBER usr_auditor;
GO

-- verificacion

SELECT 
    r.name AS Rol,
    m.name AS Usuario
FROM sys.database_role_members rm
JOIN sys.database_principals r
    ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m
    ON rm.member_principal_id = m.principal_id
WHERE r.name = 'AuditorRole';

SELECT 
    pr.name AS Principal,
    pe.permission_name,
    pe.state_desc
FROM sys.database_permissions pe
JOIN sys.database_principals pr
    ON pe.grantee_principal_id = pr.principal_id
WHERE pr.name = 'AuditorRole';

-- ============================================================================
-- 7. NORMALIZACION DE PERMISOS (REVOKE)
-- ============================================================================

-- Demostrar la remoción de privilegios explícitos para devolver una entidad a su estado heredado neutral

REVOKE SELECT, UPDATE ON dbo.suscripciones FROM usr_admin_stream;
GO 

REVOKE SELECT, UPDATE ON dbo.Catalogo FROM usr_admin_stream;
GO

REVOKE SELECT, UPDATE ON dbo.Visualizaciones FROM usr_admin_stream;
GO

/* 
Ejercicio 8

Contexto: Para optimizar el espacio de almacenamiento de la plataforma "SportNet", el equipo de desarrollo solicitó que los registros de la tabla de 
accesos que tengan más de 30 días de antigüedad se eliminen de forma automática. De esta manera, se evita que la base de datos crezca indefinidamente con datos obsoletos.

Consigna: Escribir un script unificado en Transact-SQL utilizando el subsistema de msdb que configure un Job automatizado en el SQL Server Agent bajo las siguientes especificaciones:

Configuración Global: Crear un Job llamado Limpieza_Automatica_Accesos_SportNet.

Definición del Paso (Job Step): Configurar un paso de ejecución de tipo T-SQL que aplique un comando estándar de eliminación (DELETE) 
sobre la tabla Socios.RegistroAccesos de la base de datos SportNetDB. El comando debe borrar las filas cuya fecha sea menor a la actual. Establecer una política de 2 reintentos ante fallas.

Planificación Horaria (Schedule): Programar la tarea para que se ejecute de forma recurrente todos los domingos a las 03:00 AM.

Asignación de Destino: Enlazar el Job para que corra de manera local en la instancia del servidor actual.
*/

USE SportNetDB;
GO

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'Limpieza_Automatica_Accesos_SportNet')
BEGIN
    EXEC msdb.dbo.sp_delete_job 
        @job_name = 'Limpieza_Automatica_Accesos_SportNet';
END
GO

EXEC msdb.dbo.sp_add_job
    @job_name = N'Limpieza_Automatica_Accesos_SportNet', 
    @enabled = 1,
    @description = N'Elimina accesos con más de 30 días de antigüedad en SportNet';
GO

-- =========================================================================
-- 2. DEFINICION DEL PASO (JOB STEP)
-- =========================================================================
-- Configurar un paso de ejecución de tipo T-SQL que aplique un comando estándar de eliminación (DELETE) 
-- sobre la tabla Socios.RegistroAccesos de la base de datos SportNetDB. El comando debe borrar las filas cuya fecha sea menor a la actual. Establecer una política de 2 reintentos ante fallas.

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Limpieza_Automatica_Accesos_SportNet',
    @step_name = N'Eliminacion de accesos antiguos',
    @subsystem = N'TSQL',
    @database_name = N'SportNetDB',
    @command = N'
        DELETE FROM Socios.RegistroAccesos
        WHERE FechaAcceso < GETDATE();
    ',
    @on_success_action = 1, --Sigue al siguiente step
    @on_fail_action = 2, --  TERMINA EL JOB CON ERROR
    @retry_attempts = 2, -- REINTENTA 2 VECES SI FALLA
    @retry_interval = 5; -- ESPERA 5 MIN EN INTERVALOS
GO

-- =========================================================================
-- 3. PLANIFICACION HORARIA (SCHEDULE)
-- =========================================================================

--  Programar la tarea para que se ejecute de forma recurrente todos los domingos a las 03:00 AM.

EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'Limpieza_Automatica_Accesos_SportNet',
    @name = N'Programacion_Domingos_03AM',
    @freq_type = 8,                   -- semanal
    @freq_interval = 1,               -- domingo
    @freq_recurrence_factor = 1,      -- cada 1 semana (OBLIGATORIO)
    @active_start_time = 030000 ;     -- Formato de hora estándar HHMMSS
GO

-- =========================================================================
-- 4. ASIGNACION DE DESTINO
-- =========================================================================
--  Enlazar el Job para que corra de manera local en la instancia del servidor actual.

EXEC  msdb.dbo.sp_add_jobserver
    @job_name = N'Limpieza_Automatica_Accesos_SportNet',
    @server_name = N'(local)' ;
GO

/* Ejercicio 9

Contexto: La cadena "CoffeeHouse" opera con un sistema de puntos de venta centralizado. 
Debido a la criticidad de las transacciones comerciales, el área de sistemas exige implementar una política de respaldo bajo el modelo de recuperación completa (FULL).
Como Administrador de Bases de Datos (DBA), debe simular el flujo diario de operaciones, ejecutar la secuencia de copias de seguridad programadas y, ante un escenario
simulado de pérdida total de datos, liderar el protocolo de restauración de emergencia sin perder una sola venta.

Consigna: Desarrollar un script unificado en Transact-SQL que implemente las siguientes fases de contingencia:

Infraestructura Base: Crear la base de datos CoffeeHouseDB junto con las tablas relacionales de clientes y órdenes de compra con una carga de datos inicial (Simulación: Estado de ventas a las 08:00 AM).

Línea Base General (Backup Full): Configurar el modelo de recuperación en modo completo y generar el respaldo total de la estructura (Simulación: 09:00 AM).

Punto de Control Acumulativo (Backup Diferencial): Insertar actividad comercial y generar un respaldo diferencial para empaquetar los cambios de la mañana (Simulación: 11:00 AM).

Resguardos Transaccionales (Backups de Log): Intercalar nuevas ventas con la ejecución secuencial de dos copias del Log de transacciones para registrar la actividad de la tarde (Simulación: 12:00 PM y 02:00 PM).

Protocolo de Recuperación: Simular un colapso crítico del sistema y reconstruir la base de datos de forma ordenada utilizando las cláusulas NORECOVERY y RECOVERY en el orden cronológico correcto.

Validación de Integridad: Comprobar mediante consultas de combinación que la base de datos fue recuperada en su totalidad.

*/

USE master;
GO
-- =========================================================================
-- 1. INFRAESTRUCTURA BASE
-- =========================================================================
--  Crear la base de datos CoffeeHouseDB junto con las tablas relacionales de clientes y órdenes de compra con una carga de datos inicial (Simulación: Estado de ventas a las 08:00 AM).

IF DB_ID('CoffeeHouseDB') IS NOT NULL
    DROP DATABASE CoffeeHouseDB;
GO

CREATE DATABASE CoffeeHouseDB;
GO

USE CoffeeHouseDB;
GO

CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100),
    Email VARCHAR(100)
);

CREATE TABLE Ordenes (
    OrdenID INT PRIMARY KEY IDENTITY(1,1),
    ClienteID INT,
    Fecha DATETIME DEFAULT GETDATE(),
    Monto DECIMAL(10,2),
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

-- Carga inicial (08:00 AM - estado base)
INSERT INTO Clientes (Nombre, Email)
VALUES 
('Ana López', 'ana@coffee.com'),
('Juan Pérez', 'juan@coffee.com');

INSERT INTO Ordenes (ClienteID, Monto)
VALUES 
(1, 120.50),
(2, 80.00);

PRINT 'Estado inicial cargado (08:00 AM)';
GO

-- =========================================================================
-- 2. LINEA BASE GENERAL (BACKUP FULL)
-- =========================================================================
-- Configurar el modelo de recuperación en modo completo y generar el respaldo total de la estructura (Simulación: 09:00 AM).

ALTER DATABASE CoffeeHouseDB
SET RECOVERY FULL;
GO

BACKUP DATABASE CoffeeHouseDB
TO DISK = 'C:\Backups\CoffeeHouseDB_FULL.bak'
WITH FORMAT, NAME = 'Backup FULL 09:00 AM';

PRINT 'Backup FULL realizado (09:00 AM)';
GO

-- =========================================================================
-- 3. PUNTO DE CONTROL ACUMULATIVO (BACKUP DIFERENCIAL)
-- =========================================================================

-- Insertar actividad comercial y generar un respaldo diferencial para empaquetar los cambios de la mañana (Simulación: 11:00 AM).

-- Inserción de actividad comercial (11:00 AM)
INSERT INTO Clientes (Nombre, Email)
VALUES ('Lucía Fernández', 'lucia@coffee.com');

INSERT INTO Ordenes (ClienteID, Monto)
VALUES (1, 95.00),
       (2, 140.00);

PRINT 'Actividad comercial registrada (11:00 AM)';
GO

BACKUP DATABASE CoffeeHouseDB
TO DISK = 'c:\backups\CoffeeHouseDB_diff.bak'
WITH DIFFERENTIAL, FORMAT, NAME = 'Diff CoffeeHouseDB Backup';
GO

-- =========================================================================
-- 4. RESGUARDOS TRANSACCIONALES (BACKUPS DE LOG)
-- =========================================================================
-- Intercalar nuevas ventas con la ejecución secuencial de dos copias del Log de transacciones para registrar la actividad de la tarde (Simulación: 12:00 PM y 02:00 PM).

-- Nuevas ventas (12:00 PM)

INSERT INTO Ordenes (ClienteID, Monto)
VALUES 
(1, 210.00),
(3, 180.00);

PRINT 'Actividad comercial registrada (12:00 PM)';
GO

-- Backup de LOG 1
BACKUP LOG CoffeeHouseDB
TO DISK = 'C:\Backups\CoffeeHouseDB_LOG_12PM.trn'
WITH NAME = 'Log Backup 12:00 PM';

PRINT 'Backup de LOG 12:00 PM realizado';
GO

-- Nuevas ventas (02:00 PM)
INSERT INTO Ordenes (ClienteID, Monto)
VALUES 
(2, 320.00),
(3, 275.00);

PRINT 'Actividad comercial registrada (02:00 PM)';
GO

-- Backup de LOG 2
BACKUP LOG CoffeeHouseDB
TO DISK = 'C:\Backups\CoffeeHouseDB_LOG_02PM.trn'
WITH NAME = 'Log Backup 02:00 PM';

PRINT 'Backup de LOG 02:00 PM realizado';
GO

-- =========================================================================
-- 5. PROTOCOLO DE RECUPERACION
-- =========================================================================
-- Simular un colapso crítico del sistema y reconstruir la base de datos de forma ordenada utilizando las cláusulas NORECOVERY y RECOVERY en el orden cronológico correcto.

USE master;
GO

ALTER DATABASE [CoffeeHouseDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE [CoffeeHouseDB]
FROM DISK = 'c:\backups\CoffeeHouseDB_FULL.bak'
WITH NORECOVERY, REPLACE;
GO


PRINT 'Restore FULL completado (base en NORECOVERY)';
GO


--  RESTORE DIFERENCIAL

RESTORE DATABASE CoffeeHouseDB
FROM DISK = 'C:\Backups\CoffeeHouseDB_DIFF.bak'
WITH 
    NORECOVERY;
GO

PRINT 'Restore DIF completado';
GO


-- RESTORE LOG 12:00 PM

RESTORE LOG CoffeeHouseDB
FROM DISK = 'C:\Backups\CoffeeHouseDB_LOG_12PM.trn'
WITH 
    NORECOVERY;
GO

PRINT 'Restore LOG 12:00 PM completado';
GO



-- RESTORE LOG 02:00 PM (FINAL)

RESTORE LOG CoffeeHouseDB
FROM DISK = 'C:\Backups\CoffeeHouseDB_LOG_02PM.trn'
WITH 
    RECOVERY;
GO

PRINT 'Restore LOG 02:00 PM completado - BASE RECUPERADA';
GO


-- =========================================================================
-- 6. VALIDACION DE INTEGRIDAD
-- =========================================================================
-- Comprobar mediante consultas de combinación que la base de datos fue recuperada en su totalidad.

USE CoffeeHouseDB;
GO
SELECT c.ClienteID,
    c.Nombre,
    c.Email,
    o.OrdenID,
    o.Monto,
    o.Fecha
FROM Clientes c
INNER JOIN Ordenes o ON c.ClienteID = o.ClienteID ORDER BY o.Fecha; 
GO

/* 
Ejercicio 10

Responde el siguiente cuestionario de múltiple choice sobre Alta Disponibilidad.

1. Si la prioridad absoluta de una empresa es poder utilizar el servidor secundario de respaldo para generar reportes pesados de forma aislada, ¿cuál es la solución tecnológica recomendada por defecto en la actualidad?
A) Clustering (FCI), porque el nodo pasivo permite lecturas transparentes.
B) Mirroring (Reflejo), ya que mantiene la base de datos en estado de recuperación legible.
C) Always On AG, debido a que permite configurar copias legibles (Secondaries Read-Only) para reportes.
D) Replicación, ya que es la opción que ofrece el failover automático más veloz del mercado.

RESPUESTA 
C

2. Al analizar la infraestructura de almacenamiento de la tecnología Clustering (FCI), ¿cuál es el principal riesgo técnico asociado a su diseño?
A) Que duplica el uso de discos independientes por cada servidor, encareciendo los costos.
B) El uso de almacenamiento compartido (SAN/NAS), que introduce un riesgo de punto único de falla.
C) Que obliga a que la base de datos permanezca en un estado inaccesible llamado RECOVERING.
D) Que no requiere la configuración de un clúster de Windows (WSFC), perdiendo soporte del sistema operativo.

RESPUESTA 
B


3. Un administrador de sistemas propone utilizar "Mirroring" (Reflejo) para proteger una base de datos individual en un proyecto nuevo. Según el estado actual de la tecnología (2026), ¿cuál es la postura correcta ante esta sugerencia?
A) Debe aceptarse, ya que es el estándar actual de la industria para bases de datos individuales.
B) Debe rechazarse, porque es una tecnología depreciada sin soporte activo por parte de Microsoft.
C) Debe aceptarse, porque ofrece un failover automático a nivel de grupo de bases de datos.
D) Debe rechazarse, únicamente porque requiere obligatoriamente la instalación de un clúster de Windows (WSFC).

RESPUESTA
B

4. ¿Cuál es la diferencia conceptual clave en el "Nivel de Protección" entre Clustering (FCI) y Always On AG ante una falla de hardware?
A) FCI protege objetos individuales (tablas/vistas) y Always On protege servidores físicos completos.
B) FCI ofrece failover manual y Always On es la única que permite failover automático.
C) FCI protege bases de datos individuales aisladas y Always On requiere discos compartidos SAN/NAS.
D) FCI protege la instancia completa de SQL Server, mientras que Always On protege un grupo de bases de datos elegidas.

RESPUESTA
D

5. ¿Qué requisito del sistema operativo Windows comparten obligatoriamente las tecnologías "Clustering (FCI)" y "Always On AG" para poder operar?
A) Ninguno, ambas tecnologías funcionan de forma nativa sin requerimientos especiales de Windows.
B) Ambas dependen estrictamente de un servidor de testigos externo (Witness).
C) Ambas dependen de la configuración de un Windows Server Failover Cluster (WSFC).
D) Ambas requieren que los discos de almacenamiento de los servidores estén físicamente duplicados.

RESPUESTA
C
*/