-- ════════════════════════════════════════════════════════════════════════════════
-- 📝 TRABAJO PRÁCTICO: SEGURIDAD A NIVEL DE BASE DE DATOS
-- ════════════════════════════════════════════════════════════════════════════════

-- 
-- INSTRUCCIONES:
-- 1. Lee cada enunciado con atención
-- 2. Resuelve los ejercicios en SSMS
-- 3. Verifica los resultados con las consultas de validación
-- 4. Este TP es sobre seguridad DENTRO de una base de datos (usuarios, roles, permisos)

-- ════════════════════════════════════════════════════════════════════════════════

-- ────────────────────────────────────────────────────────────────────────────────
-- CONFIGURACIÓN INICIAL: Crear base de datos y estructura de prueba
-- ────────────────────────────────────────────────────────────────────────────────

-- Crear base de datos para el ejercicio
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'EmpresaDB')
    DROP DATABASE EmpresaDB;
GO

CREATE DATABASE EmpresaDB;
GO

USE EmpresaDB;
GO

-- Crear tablas de ejemplo
CREATE TABLE dbo.Empleados (
    EmpleadoID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100),
    Apellido NVARCHAR(100),
    Salario DECIMAL(10,2),
    Departamento NVARCHAR(50)
);
GO

CREATE TABLE dbo.Productos (
    ProductoID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100),
    Precio DECIMAL(10,2),
    Stock INT
);
GO

CREATE TABLE dbo.Ventas (
    VentaID INT PRIMARY KEY IDENTITY(1,1),
    ProductoID INT,
    Cantidad INT,
    FechaVenta DATE,
    Total DECIMAL(10,2)
);
GO

-- Insertar datos de ejemplo
INSERT INTO dbo.Empleados (Nombre, Apellido, Salario, Departamento)
VALUES 
    ('Juan', 'Pérez', 50000, 'Ventas'),
    ('María', 'González', 60000, 'IT'),
    ('Carlos', 'López', 45000, 'Ventas'),
    ('Ana', 'Martínez', 75000, 'Gerencia');
GO

INSERT INTO dbo.Productos (Nombre, Precio, Stock)
VALUES 
    ('Laptop', 1200.00, 50),
    ('Mouse', 25.00, 200),
    ('Teclado', 45.00, 150);
GO

INSERT INTO dbo.Ventas (ProductoID, Cantidad, FechaVenta, Total)
VALUES 
    (1, 2, '2026-06-01', 2400.00),
    (2, 10, '2026-06-02', 250.00);
GO

PRINT '✅ Base de datos EmpresaDB creada con datos de ejemplo';
GO


-- ════════════════════════════════════════════════════════════════════════════════
-- IMPORTANTE: Asegúrate de tener los LOGINS creados en el servidor primero
-- ════════════════════════════════════════════════════════════════════════════════

USE [master];
GO

-- Crear logins si no existen (ejecutar solo si es necesario)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_ventas')
    CREATE LOGIN [usuario_ventas] WITH PASSWORD = 'Ventas2026!';
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_it')
    CREATE LOGIN [usuario_it] WITH PASSWORD = 'IT2026!';
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_rrhh')
    CREATE LOGIN [usuario_rrhh] WITH PASSWORD = 'RRHH2026!';
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_gerente')
    CREATE LOGIN [usuario_gerente] WITH PASSWORD = 'Gerente2026!';
GO

USE EmpresaDB;
GO


-- ════════════════════════════════════════════════════════════════════════════════
-- INICIO DE EJERCICIOS
-- ════════════════════════════════════════════════════════════════════════════════


-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 1: Crear Usuarios en la Base de Datos
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
Tu empresa tiene una base de datos (EmpresaDB) y necesitas crear usuarios
para que los empleados puedan acceder a ella.

IMPORTANTE: Un LOGIN es a nivel servidor, un USER es a nivel de base de datos.
Para crear un USER, primero debe existir el LOGIN correspondiente.

TAREAS:
a) Crea un usuario llamado "usuario_ventas" en la base de datos EmpresaDB
   (asociado al login del mismo nombre)
   
b) Crea un usuario llamado "usuario_it" en la base de datos EmpresaDB
   (asociado al login del mismo nombre)
   
c) Crea un usuario llamado "usuario_rrhh" en la base de datos EmpresaDB
   (asociado al login del mismo nombre)

VALIDACIÓN:
-- Ejecuta esta consulta para verificar:
SELECT 
    name AS UserName,
    type_desc AS UserType,
    create_date AS FechaCreacion
FROM sys.database_principals
WHERE type = 'S' AND name LIKE 'usuario_%'
ORDER BY name;
GO
*/

-- TU SOLUCIÓN AQUÍ:





-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 2: Asignar Roles de Base de Datos
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
Ahora que los usuarios están creados, necesitas asignarles roles según
sus responsabilidades en la empresa:

- usuario_ventas: Debe poder LEER todas las tablas (SELECT)
- usuario_it: Debe poder LEER y ESCRIBIR en todas las tablas (SELECT, INSERT, UPDATE, DELETE)
- usuario_rrhh: Debe poder LEER todas las tablas

ROLES DE BASE DE DATOS MÁS COMUNES:
- db_datareader: Puede hacer SELECT en todas las tablas
- db_datawriter: Puede hacer INSERT, UPDATE, DELETE en todas las tablas
- db_owner: Control total sobre la base de datos

TAREAS:
a) Asigna al usuario "usuario_ventas" el rol "db_datareader"
b) Asigna al usuario "usuario_it" los roles "db_datareader" Y "db_datawriter"
c) Asigna al usuario "usuario_rrhh" el rol "db_datareader"

VALIDACIÓN:
-- Verifica las asignaciones:
SELECT 
    USER_NAME(member_principal_id) AS Usuario,
    USER_NAME(role_principal_id) AS Rol
FROM sys.database_role_members
WHERE USER_NAME(member_principal_id) LIKE 'usuario_%'
ORDER BY Usuario, Rol;
GO
*/

-- TU SOLUCIÓN AQUÍ:





-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 3: Permisos Específicos con GRANT
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
El gerente necesita un acceso especial. Crea un nuevo usuario y asígnale
permisos específicos sobre tablas individuales.

TAREAS:
a) Crea un usuario llamado "usuario_gerente" (asociado al login existente)

b) Otorga al usuario "usuario_gerente" permiso de SELECT en la tabla Empleados

c) Otorga al usuario "usuario_gerente" permisos de SELECT, INSERT y UPDATE 
   en la tabla Ventas (NO debe poder hacer DELETE)

d) Otorga al usuario "usuario_gerente" permiso SELECT en la tabla Productos

VALIDACIÓN:
-- Verifica los permisos otorgados:
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    OBJECT_NAME(major_id) AS Tabla,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'usuario_gerente'
  AND class_desc = 'OBJECT_OR_COLUMN'
ORDER BY Tabla, Permiso;
GO
*/

-- TU SOLUCIÓN AQUÍ:





-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 4: Usar DENY para Restringir Acceso
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
Por políticas de seguridad de la empresa, los empleados de RRHH pueden ver
todos los datos EXCEPTO los salarios, que son confidenciales.

Actualmente usuario_rrhh tiene el rol db_datareader (puede ver todo).
Necesitas DENEGAR específicamente el acceso a la columna Salario.

TAREAS:
a) Deniega al usuario "usuario_rrhh" el permiso SELECT sobre la columna 
   "Salario" de la tabla Empleados
   
b) Verifica que el DENY está activo consultando sys.database_permissions

NOTA: Recuerda que DENY siempre tiene prioridad sobre GRANT. Aunque usuario_rrhh
tenga db_datareader, el DENY bloqueará el acceso a esa columna específica.

VALIDACIÓN:
-- Verifica el DENY:
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    OBJECT_NAME(major_id) AS Tabla,
    COL_NAME(major_id, minor_id) AS Columna,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'usuario_rrhh'
  AND state_desc = 'DENY'
ORDER BY Tabla, Columna;
GO

-- Prueba (ejecutar como usuario_rrhh - debería fallar):
-- EXECUTE AS USER = 'usuario_rrhh';
-- SELECT Nombre, Apellido, Salario FROM dbo.Empleados;  -- ❌ Error en Salario
-- SELECT Nombre, Apellido FROM dbo.Empleados;           -- ✅ Funciona
-- REVERT;
*/

-- TU SOLUCIÓN AQUÍ:





-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 5: Modificar Permisos con REVOKE
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
El departamento de IT ya no necesita modificar datos en la tabla Productos.
Necesitas quitarle los permisos de escritura pero mantener el de lectura.

Actualmente usuario_it tiene los roles db_datareader y db_datawriter (puede
hacer INSERT, UPDATE, DELETE en todas las tablas).

TAREAS:
a) Deniega (DENY) al usuario "usuario_it" los permisos INSERT, UPDATE y DELETE
   específicamente en la tabla Productos
   
b) Verifica que usuario_it aún puede hacer SELECT en Productos (por db_datareader)
   pero NO puede modificarla

VALIDACIÓN:
-- Verifica los DENY aplicados:
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    OBJECT_NAME(major_id) AS Tabla,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'usuario_it'
  AND OBJECT_NAME(major_id) = 'Productos'
  AND state_desc = 'DENY'
ORDER BY Permiso;
GO

-- Prueba (ejecutar como usuario_it):
-- EXECUTE AS USER = 'usuario_it';
-- SELECT * FROM dbo.Productos;                    -- ✅ Funciona
-- UPDATE dbo.Productos SET Stock = 100 WHERE ProductoID = 1;  -- ❌ Error
-- REVERT;
*/

-- TU SOLUCIÓN AQUÍ:





-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 6: Crear Rol Personalizado
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
Tu empresa necesita un rol personalizado para los auditores que:
- Puedan ver (SELECT) todas las tablas
- Puedan ver las definiciones de tablas y vistas
- NO puedan modificar ningún dato

TAREAS:
a) Crea un rol de base de datos llamado "AuditorRole"

b) Asigna al rol "AuditorRole" el rol de base de datos "db_datareader"

c) Otorga al rol "AuditorRole" el permiso VIEW DEFINITION a nivel de base de datos

d) Crea un usuario "usuario_auditor" (asociado al login, créalo si no existe)

e) Agrega al usuario "usuario_auditor" al rol "AuditorRole"

VALIDACIÓN:
-- Verifica el rol y sus miembros:
SELECT 
    USER_NAME(role_principal_id) AS Rol,
    USER_NAME(member_principal_id) AS Miembro
FROM sys.database_role_members
WHERE USER_NAME(role_principal_id) = 'AuditorRole'
   OR USER_NAME(member_principal_id) = 'AuditorRole';
GO

-- Verifica permisos del rol:
SELECT 
    USER_NAME(grantee_principal_id) AS Rol,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'AuditorRole';
GO
*/

-- TU SOLUCIÓN AQUÍ:





-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 7: Limpieza de Permisos
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
El usuario_gerente cambió de área y ya no necesita permisos sobre Ventas.
Necesitas limpiar sus permisos.

TAREAS:
a) Revoca (REVOKE) todos los permisos que tiene usuario_gerente sobre la tabla Ventas
   Recuerda: Son SELECT, INSERT y UPDATE

b) Verifica que se quitaron los permisos de Ventas pero conserva los de otras tablas

VALIDACIÓN:
-- Verifica los permisos actuales de usuario_gerente:
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    OBJECT_NAME(major_id) AS Tabla,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'usuario_gerente'
  AND class_desc = 'OBJECT_OR_COLUMN'
ORDER BY Tabla, Permiso;
GO
-- Deberías ver permisos en Empleados y Productos, pero NO en Ventas
*/

-- TU SOLUCIÓN AQUÍ:





-- ════════════════════════════════════════════════════════════════════════════════
-- EJERCICIO BONUS: Consultas Útiles de Auditoría
-- ════════════════════════════════════════════════════════════════════════════════
/*
ENUNCIADO:
Como administrador de base de datos, necesitas consultas para auditar la seguridad.

TAREAS:
Escribe consultas para:

a) Listar TODOS los usuarios de la base de datos y sus roles

b) Listar TODOS los permisos GRANT otorgados a nivel de tabla

c) Listar TODOS los permisos DENY activos en la base de datos

d) Listar qué usuarios NO tienen ningún permiso asignado

e) Ver un resumen de permisos por usuario (cuántos GRANT, DENY tiene cada uno)
*/

-- TU SOLUCIÓN AQUÍ:

-- a) Usuarios y sus roles


-- b) Permisos GRANT a nivel de tabla


-- c) Permisos DENY activos


-- d) Usuarios sin permisos


-- e) Resumen de permisos por usuario




-- ════════════════════════════════════════════════════════════════════════════════
-- FIN DEL TRABAJO PRÁCTICO
-- ════════════════════════════════════════════════════════════════════════════════

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '✅ Trabajo Práctico Completado';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';
PRINT '📊 Resumen de lo aprendido:';
PRINT '   1. Crear USERS en una base de datos';
PRINT '   2. Asignar roles de base de datos (db_datareader, db_datawriter)';
PRINT '   3. Otorgar permisos específicos con GRANT';
PRINT '   4. Denegar permisos con DENY (bloquea incluso roles)';
PRINT '   5. Quitar permisos con REVOKE';
PRINT '   6. Crear roles personalizados';
PRINT '   7. Auditar permisos y seguridad';
PRINT '';
GO
