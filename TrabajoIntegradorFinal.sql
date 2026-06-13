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
Reingeniería Estructural (Refactorización): Demostrar la capacidad de reestructurar la tabla eliminando el índice anterior y regenerando la Clave Primaria para que sea, finalmente, el índice agrupado principal de la tabla.

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

