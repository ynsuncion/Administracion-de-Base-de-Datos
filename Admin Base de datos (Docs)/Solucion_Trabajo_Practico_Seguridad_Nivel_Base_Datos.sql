-- ════════════════════════════════════════════════════════════════════════════════
-- 📝 SOLUCIÓN COMPLETA: TRABAJO PRÁCTICO SEGURIDAD A NIVEL DE BASE DE DATOS
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
-- Crear LOGINS en el servidor (nivel servidor)
-- ════════════════════════════════════════════════════════════════════════════════

USE [master];
GO

-- Eliminar logins si existen (para empezar limpio)
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_ventas')
    DROP LOGIN [usuario_ventas];
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_it')
    DROP LOGIN [usuario_it];
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_rrhh')
    DROP LOGIN [usuario_rrhh];
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_gerente')
    DROP LOGIN [usuario_gerente];
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_auditor')
    DROP LOGIN [usuario_auditor];
GO

-- Crear logins
CREATE LOGIN [usuario_ventas] WITH PASSWORD = 'Ventas2026!';
CREATE LOGIN [usuario_it] WITH PASSWORD = 'IT2026!';
CREATE LOGIN [usuario_rrhh] WITH PASSWORD = 'RRHH2026!';
CREATE LOGIN [usuario_gerente] WITH PASSWORD = 'Gerente2026!';
CREATE LOGIN [usuario_auditor] WITH PASSWORD = 'Auditor2026!';
GO

PRINT '✅ Logins creados en el servidor';
GO

USE EmpresaDB;
GO


-- ════════════════════════════════════════════════════════════════════════════════
-- EJERCICIO 1: Crear Usuarios en la Base de Datos
-- ════════════════════════════════════════════════════════════════════════════════

PRINT '';
PRINT '╔═══════════════════════════════════════════════════════════════╗';
PRINT '║           EJERCICIO 1: CREAR USUARIOS EN LA BD               ║';
PRINT '╚═══════════════════════════════════════════════════════════════╝';
GO

/*
CONCEPTO CLAVE:
- LOGIN: Credencial a nivel de servidor (permite conectarse a SQL Server)
- USER: Credencial a nivel de base de datos (permite acceder a una BD específica)

SINTAXIS:
CREATE USER [nombre_usuario] FOR LOGIN [nombre_login];
*/

-- a) Crear usuario_ventas
CREATE USER [usuario_ventas] FOR LOGIN [usuario_ventas];
GO

-- b) Crear usuario_it
CREATE USER [usuario_it] FOR LOGIN [usuario_it];
GO

-- c) Crear usuario_rrhh
CREATE USER [usuario_rrhh] FOR LOGIN [usuario_rrhh];
GO

PRINT '✅ Usuarios creados correctamente';
GO

-- VALIDACIÓN:
SELECT 
    name AS UserName,
    type_desc AS UserType,
    create_date AS FechaCreacion
FROM sys.database_principals
WHERE type = 'S' AND name LIKE 'usuario_%'
ORDER BY name;
GO

PRINT '';
PRINT '📖 EXPLICACIÓN:';
PRINT '   - Creamos 3 USERS en la base de datos EmpresaDB';
PRINT '   - Cada USER está asociado a un LOGIN del servidor';
PRINT '   - Los usuarios pueden conectarse, pero AÚN NO tienen permisos';
PRINT '';


-- ════════════════════════════════════════════════════════════════════════════════
-- EJERCICIO 2: Asignar Roles de Base de Datos
-- ════════════════════════════════════════════════════════════════════════════════

PRINT '';
PRINT '╔═══════════════════════════════════════════════════════════════╗';
PRINT '║         EJERCICIO 2: ASIGNAR ROLES DE BASE DE DATOS          ║';
PRINT '╚═══════════════════════════════════════════════════════════════╝';
GO

/*
ROLES DE BASE DE DATOS MÁS COMUNES:
┌────────────────────┬──────────────────────────────────────────┐
│ ROL                │ PERMISOS                                 │
├────────────────────┼──────────────────────────────────────────┤
│ db_owner           │ Control total sobre la base de datos     │
│ db_datareader      │ SELECT en todas las tablas               │
│ db_datawriter      │ INSERT, UPDATE, DELETE en todas tablas   │
│ db_ddladmin        │ Crear/modificar objetos (DDL)            │
│ db_securityadmin   │ Gestionar permisos                       │
│ db_backupoperator  │ Realizar backups                         │
└────────────────────┴──────────────────────────────────────────┘

SINTAXIS:
ALTER ROLE [nombre_rol] ADD MEMBER [nombre_usuario];
*/

-- a) usuario_ventas → db_datareader (solo lectura)
ALTER ROLE [db_datareader] ADD MEMBER [usuario_ventas];
GO

-- b) usuario_it → db_datareader Y db_datawriter (lectura y escritura)
ALTER ROLE [db_datareader] ADD MEMBER [usuario_it];
ALTER ROLE [db_datawriter] ADD MEMBER [usuario_it];
GO

-- c) usuario_rrhh → db_datareader (solo lectura)
ALTER ROLE [db_datareader] ADD MEMBER [usuario_rrhh];
GO

PRINT '✅ Roles asignados correctamente';
GO

-- VALIDACIÓN:
SELECT 
    USER_NAME(member_principal_id) AS Usuario,
    USER_NAME(role_principal_id) AS Rol
FROM sys.database_role_members
WHERE USER_NAME(member_principal_id) LIKE 'usuario_%'
ORDER BY Usuario, Rol;
GO

PRINT '';
PRINT '📖 EXPLICACIÓN:';
PRINT '   - usuario_ventas: Puede ver todos los datos (SELECT)';
PRINT '   - usuario_it: Puede ver Y modificar datos (SELECT, INSERT, UPDATE, DELETE)';
PRINT '   - usuario_rrhh: Puede ver todos los datos (SELECT)';
PRINT '';


-- ════════════════════════════════════════════════════════════════════════════════
-- EJERCICIO 3: Permisos Específicos con GRANT
-- ════════════════════════════════════════════════════════════════════════════════

PRINT '';
PRINT '╔═══════════════════════════════════════════════════════════════╗';
PRINT '║         EJERCICIO 3: PERMISOS ESPECÍFICOS CON GRANT          ║';
PRINT '╚═══════════════════════════════════════════════════════════════╝';
GO

/*
SINTAXIS GRANT:
GRANT {permiso} ON {objeto} TO {usuario/rol};

PERMISOS COMUNES:
- SELECT: Leer datos
- INSERT: Insertar datos
- UPDATE: Modificar datos
- DELETE: Eliminar datos
- EXECUTE: Ejecutar procedimientos almacenados
- CONTROL: Control total sobre el objeto
*/

-- a) Crear usuario_gerente
CREATE USER [usuario_gerente] FOR LOGIN [usuario_gerente];
GO

-- b) Permiso SELECT en Empleados
GRANT SELECT ON dbo.Empleados TO [usuario_gerente];
GO

-- c) Permisos SELECT, INSERT, UPDATE en Ventas (NO DELETE)
GRANT SELECT ON dbo.Ventas TO [usuario_gerente];
GRANT INSERT ON dbo.Ventas TO [usuario_gerente];
GRANT UPDATE ON dbo.Ventas TO [usuario_gerente];
GO

-- d) Permiso SELECT en Productos
GRANT SELECT ON dbo.Productos TO [usuario_gerente];
GO

PRINT '✅ Permisos GRANT otorgados correctamente';
GO

-- VALIDACIÓN:
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

PRINT '';
PRINT '📖 EXPLICACIÓN:';
PRINT '   - usuario_gerente puede leer (SELECT) Empleados, Productos y Ventas';
PRINT '   - usuario_gerente puede agregar y modificar registros en Ventas (INSERT, UPDATE)';
PRINT '   - usuario_gerente NO puede eliminar registros de Ventas (sin DELETE)';
PRINT '   - Estos permisos son MÁS ESPECÍFICOS que los roles (tabla por tabla)';
PRINT '';


-- ════════════════════════════════════════════════════════════════════════════════
-- EJERCICIO 4: Usar DENY para Restringir Acceso
-- ════════════════════════════════════════════════════════════════════════════════

PRINT '';
PRINT '╔═══════════════════════════════════════════════════════════════╗';
PRINT '║         EJERCICIO 4: RESTRINGIR ACCESO CON DENY              ║';
PRINT '╚═══════════════════════════════════════════════════════════════╝';
GO

/*
JERARQUÍA DE PERMISOS (de mayor a menor prioridad):
1. DENY   ← Siempre bloquea, incluso si hay GRANT
2. GRANT  ← Otorga permiso
3. REVOKE ← Neutral (quita GRANT o DENY)

SINTAXIS DENY:
DENY {permiso} ON {objeto} TO {usuario/rol};

DENY a nivel de COLUMNA:
DENY SELECT ON dbo.Tabla (Columna1, Columna2) TO usuario;
*/

-- a) Denegar SELECT sobre la columna Salario de Empleados
DENY SELECT ON dbo.Empleados (Salario) TO [usuario_rrhh];
GO

PRINT '✅ DENY aplicado correctamente';
GO

-- b) VALIDACIÓN:
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

PRINT '';
PRINT '📖 EXPLICACIÓN:';
PRINT '   - usuario_rrhh tiene rol db_datareader (puede ver todo)';
PRINT '   - Pero el DENY SELECT en columna Salario LO BLOQUEA';
PRINT '   - DENY tiene MÁXIMA PRIORIDAD (sobrescribe cualquier GRANT)';
PRINT '';
PRINT '🧪 PRUEBA:';
PRINT '   Esta consulta debería FALLAR para usuario_rrhh:';
PRINT '   SELECT Nombre, Apellido, Salario FROM dbo.Empleados;  ❌';
PRINT '';
PRINT '   Esta consulta debería FUNCIONAR para usuario_rrhh:';
PRINT '   SELECT Nombre, Apellido FROM dbo.Empleados;  ✅';
PRINT '';

-- Prueba práctica (comentado para no dar error en la ejecución):
/*
EXECUTE AS USER = 'usuario_rrhh';
SELECT Nombre, Apellido, Salario FROM dbo.Empleados;  -- ❌ Error: permiso SELECT denegado en columna Salario
REVERT;

EXECUTE AS USER = 'usuario_rrhh';
SELECT Nombre, Apellido, Departamento FROM dbo.Empleados;  -- ✅ Funciona sin problema
REVERT;
*/


-- ════════════════════════════════════════════════════════════════════════════════
-- EJERCICIO 5: Modificar Permisos con DENY
-- ════════════════════════════════════════════════════════════════════════════════

PRINT '';
PRINT '╔═══════════════════════════════════════════════════════════════╗';
PRINT '║         EJERCICIO 5: DENEGAR PERMISOS ESPECÍFICOS            ║';
PRINT '╚═══════════════════════════════════════════════════════════════╝';
GO

/*
ESCENARIO:
- usuario_it tiene db_datawriter → puede hacer INSERT, UPDATE, DELETE en TODAS las tablas
- Necesitamos que NO pueda modificar la tabla Productos (protegerla)
- Pero debe mantener lectura (db_datareader)

SOLUCIÓN: Usar DENY en INSERT, UPDATE, DELETE sobre Productos
*/

-- a) Denegar INSERT, UPDATE y DELETE en Productos para usuario_it
DENY INSERT ON dbo.Productos TO [usuario_it];
DENY UPDATE ON dbo.Productos TO [usuario_it];
DENY DELETE ON dbo.Productos TO [usuario_it];
GO

PRINT '✅ Permisos DENY aplicados correctamente';
GO

-- VALIDACIÓN:
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

PRINT '';
PRINT '📖 EXPLICACIÓN:';
PRINT '   - usuario_it tiene db_datawriter (puede modificar todas las tablas)';
PRINT '   - Los DENY en Productos BLOQUEAN solo esa tabla';
PRINT '   - usuario_it puede leer Productos (SELECT), pero NO modificarla';
PRINT '   - usuario_it puede modificar otras tablas (Empleados, Ventas)';
PRINT '';
PRINT '🧪 PRUEBA:';
PRINT '   SELECT * FROM dbo.Productos;  ✅ Funciona';
PRINT '   UPDATE dbo.Productos SET Stock = 100;  ❌ Error (DENY)';
PRINT '';

-- Prueba práctica (comentado):
/*
EXECUTE AS USER = 'usuario_it';
SELECT * FROM dbo.Productos;  -- ✅ Funciona
REVERT;

EXECUTE AS USER = 'usuario_it';
UPDATE dbo.Productos SET Stock = 100 WHERE ProductoID = 1;  -- ❌ Error: permiso UPDATE denegado
REVERT;
*/


-- ════════════════════════════════════════════════════════════════════════════════
-- EJERCICIO 6: Crear Rol Personalizado
-- ════════════════════════════════════════════════════════════════════════════════

PRINT '';
PRINT '╔═══════════════════════════════════════════════════════════════╗';
PRINT '║         EJERCICIO 6: CREAR ROL PERSONALIZADO                 ║';
PRINT '╚═══════════════════════════════════════════════════════════════╝';
GO

/*
ROL PERSONALIZADO: AuditorRole
- Puede leer todas las tablas (SELECT)
- Puede ver definiciones de objetos (VIEW DEFINITION)
- NO puede modificar datos

PASOS:
1. Crear el rol
2. Asignarle permisos/roles
3. Agregar usuarios al rol
*/

-- a) Crear el rol AuditorRole
CREATE ROLE [AuditorRole];
GO

-- b) Asignar rol db_datareader al AuditorRole
ALTER ROLE [db_datareader] ADD MEMBER [AuditorRole];
GO

-- c) Otorgar permiso VIEW DEFINITION a nivel de base de datos
GRANT VIEW DEFINITION TO [AuditorRole];
GO

/*
	El permiso VIEW DEFINITION permite ver la definición (código fuente) de objetos en la base de datos, pero NO permite ejecutarlos ni modificarlos.

	Con este permiso, el usuario puede ver el código de:

	-- Puede ver el código del procedimiento
	EXEC sp_helptext 'NombreProcedimiento';

	-- Puede ver cómo está programada la función
	EXEC sp_helptext 'NombreFuncion';

	-- Puede ver la consulta SELECT de la vista
	EXEC sp_helptext 'NombreVista';

	-- Puede ver el código del trigger
	EXEC sp_helptext 'NombreTrigger';

	-- Puede ver la definición de la tabla
	EXEC sp_help 'NombreTabla';

	Es PERFECTO para auditores porque:

✅ Pueden revisar el código para auditorías
✅ Pueden documentar cómo funcionan los procesos
✅ Pueden verificar la lógica de negocio
❌ NO pueden ejecutar los procedimientos
❌ NO pueden modificar el código
❌ NO pueden ver los datos de las tablas (solo la estructura)
*/

-- d) Crear usuario_auditor
CREATE USER [usuario_auditor] FOR LOGIN [usuario_auditor];
GO

-- e) Agregar usuario_auditor al rol AuditorRole
ALTER ROLE [AuditorRole] ADD MEMBER [usuario_auditor];
GO

PRINT '✅ Rol personalizado AuditorRole creado correctamente';
GO

-- VALIDACIÓN: Ver el rol y sus miembros
SELECT 
    USER_NAME(role_principal_id) AS Rol,
    USER_NAME(member_principal_id) AS Miembro
FROM sys.database_role_members
WHERE USER_NAME(role_principal_id) = 'AuditorRole'
   OR USER_NAME(member_principal_id) = 'AuditorRole';
GO

-- VALIDACIÓN: Ver permisos del rol
SELECT 
    USER_NAME(grantee_principal_id) AS Rol,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'AuditorRole';
GO

PRINT '';
PRINT '📖 EXPLICACIÓN:';
PRINT '   - AuditorRole es un rol PERSONALIZADO (no viene con SQL Server)';
PRINT '   - Hereda permisos de db_datareader (SELECT en todas las tablas)';
PRINT '   - Tiene permiso VIEW DEFINITION (ver código de objetos)';
PRINT '   - usuario_auditor obtiene TODOS los permisos del rol';
PRINT '';
PRINT '💡 VENTAJA DE ROLES PERSONALIZADOS:';
PRINT '   - Asignas permisos al ROL (no a cada usuario)';
PRINT '   - Si cambias el rol, afecta a TODOS sus miembros';
PRINT '   - Más fácil de mantener y auditar';
PRINT '';


-- ════════════════════════════════════════════════════════════════════════════════
-- EJERCICIO 7: Limpieza de Permisos con REVOKE
-- ════════════════════════════════════════════════════════════════════════════════

PRINT '';
PRINT '╔═══════════════════════════════════════════════════════════════╗';
PRINT '║         EJERCICIO 7: LIMPIEZA DE PERMISOS CON REVOKE         ║';
PRINT '╚═══════════════════════════════════════════════════════════════╝';
GO

/*
REVOKE: Quita permisos (vuelve a estado NEUTRAL)

DIFERENCIAS:
┌────────────┬──────────────────────────────────────────────────┐
│ COMANDO    │ EFECTO                                           │
├────────────┼──────────────────────────────────────────────────┤
│ GRANT      │ Otorga permiso explícitamente                    │
│ DENY       │ Bloquea permiso explícitamente (máxima prioridad)│
│ REVOKE     │ Quita GRANT o DENY (vuelve a neutral/heredado)   │
└────────────┴──────────────────────────────────────────────────┘

SINTAXIS:
REVOKE {permiso} ON {objeto} FROM {usuario};
*/

-- Estado actual de usuario_gerente sobre Ventas:
-- - SELECT (GRANT)
-- - INSERT (GRANT)
-- - UPDATE (GRANT)

-- a) Revocar todos los permisos sobre Ventas
REVOKE SELECT ON dbo.Ventas FROM [usuario_gerente];
REVOKE INSERT ON dbo.Ventas FROM [usuario_gerente];
REVOKE UPDATE ON dbo.Ventas FROM [usuario_gerente];
GO

PRINT '✅ Permisos REVOKE aplicados correctamente';
GO

-- VALIDACIÓN:
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

PRINT '';
PRINT '📖 EXPLICACIÓN:';
PRINT '   - ANTES: usuario_gerente tenía GRANT SELECT, INSERT, UPDATE en Ventas';
PRINT '   - DESPUÉS: Se quitaron esos permisos con REVOKE';
PRINT '   - usuario_gerente CONSERVA permisos en Empleados y Productos';
PRINT '   - La tabla Ventas ahora está "neutral" para usuario_gerente';
PRINT '';
PRINT '⚠️ DIFERENCIA IMPORTANTE:';
PRINT '   - REVOKE quita el permiso (neutral)';
PRINT '   - DENY bloquea activamente el permiso';
PRINT '   - Si usuario_gerente estuviera en db_datareader:';
PRINT '     * Con REVOKE: Podría leer por herencia del rol';
PRINT '     * Con DENY: NO podría leer (DENY bloquea todo)';
PRINT '';


-- ════════════════════════════════════════════════════════════════════════════════
-- EJERCICIO BONUS: Consultas Útiles de Auditoría
-- ════════════════════════════════════════════════════════════════════════════════

PRINT '';
PRINT '╔═══════════════════════════════════════════════════════════════╗';
PRINT '║         EJERCICIO BONUS: CONSULTAS DE AUDITORÍA              ║';
PRINT '╚═══════════════════════════════════════════════════════════════╝';
GO

-- a) Listar TODOS los usuarios de la base de datos y sus roles
PRINT '📊 a) USUARIOS Y SUS ROLES:';
SELECT 
    dp.name AS Usuario,
    dp.type_desc AS TipoUsuario,
    STRING_AGG(role.name, ', ') AS Roles
FROM sys.database_principals dp
LEFT JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
LEFT JOIN sys.database_principals role ON drm.role_principal_id = role.principal_id
WHERE dp.type IN ('S', 'U')  -- S = SQL user, U = Windows user
  AND dp.name NOT IN ('guest', 'INFORMATION_SCHEMA', 'sys', 'dbo')
GROUP BY dp.name, dp.type_desc
ORDER BY dp.name;
GO

PRINT '';

-- b) Listar TODOS los permisos GRANT otorgados a nivel de tabla
PRINT '📊 b) PERMISOS GRANT A NIVEL DE TABLA:';
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    OBJECT_NAME(major_id) AS Tabla,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE class_desc = 'OBJECT_OR_COLUMN'
  AND state_desc = 'GRANT'
  AND major_id > 0
ORDER BY Usuario, Tabla, Permiso;
GO

PRINT '';

-- c) Listar TODOS los permisos DENY activos en la base de datos
PRINT '📊 c) PERMISOS DENY ACTIVOS:';
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    CASE 
        WHEN class_desc = 'OBJECT_OR_COLUMN' THEN OBJECT_NAME(major_id)
        WHEN class_desc = 'DATABASE' THEN 'BASE DE DATOS'
        ELSE class_desc
    END AS ObjetoAfectado,
    CASE 
        WHEN minor_id > 0 THEN COL_NAME(major_id, minor_id)
        ELSE 'N/A'
    END AS Columna,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE state_desc = 'DENY'
ORDER BY Usuario, ObjetoAfectado;
GO

PRINT '';

-- d) Listar qué usuarios NO tienen ningún permiso asignado
PRINT '📊 d) USUARIOS SIN PERMISOS ASIGNADOS:';
SELECT 
    dp.name AS Usuario,
    dp.type_desc AS Tipo
FROM sys.database_principals dp
WHERE dp.type IN ('S', 'U')  -- Solo usuarios SQL y Windows
  AND dp.name NOT IN ('guest', 'INFORMATION_SCHEMA', 'sys', 'dbo')
  AND NOT EXISTS (
      -- No tienen permisos directos
      SELECT 1 FROM sys.database_permissions
      WHERE grantee_principal_id = dp.principal_id
  )
  AND NOT EXISTS (
      -- No están en ningún rol
      SELECT 1 FROM sys.database_role_members
      WHERE member_principal_id = dp.principal_id
  )
ORDER BY dp.name;
GO

PRINT '';

-- e) Ver un resumen de permisos por usuario
PRINT '📊 e) RESUMEN DE PERMISOS POR USUARIO:';
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    COUNT(*) AS TotalPermisos,
    SUM(CASE WHEN state_desc = 'GRANT' THEN 1 ELSE 0 END) AS TotalGRANT,
    SUM(CASE WHEN state_desc = 'DENY' THEN 1 ELSE 0 END) AS TotalDENY,
    SUM(CASE WHEN class_desc = 'OBJECT_OR_COLUMN' THEN 1 ELSE 0 END) AS PermisosEnTablas,
    SUM(CASE WHEN class_desc = 'DATABASE' THEN 1 ELSE 0 END) AS PermisosEnBD
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) LIKE 'usuario_%'
   OR USER_NAME(grantee_principal_id) = 'AuditorRole'
GROUP BY grantee_principal_id
ORDER BY Usuario;
GO


-- ════════════════════════════════════════════════════════════════════════════════
-- RESUMEN FINAL Y TABLA DE COMANDOS
-- ════════════════════════════════════════════════════════════════════════════════

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '✅ TRABAJO PRÁCTICO COMPLETADO - TODOS LOS EJERCICIOS RESUELTOS';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';
PRINT '📚 CONCEPTOS APRENDIDOS:';
PRINT '';
PRINT '1️⃣ USUARIOS:';
PRINT '   CREATE USER [nombre] FOR LOGIN [login];';
PRINT '   - Los usuarios son a nivel de BASE DE DATOS';
PRINT '   - Necesitan un LOGIN a nivel de servidor';
PRINT '';
PRINT '2️⃣ ROLES DE BASE DE DATOS:';
PRINT '   ALTER ROLE [rol] ADD MEMBER [usuario];';
PRINT '   - db_datareader: Solo lectura (SELECT)';
PRINT '   - db_datawriter: Escritura (INSERT, UPDATE, DELETE)';
PRINT '   - db_owner: Control total';
PRINT '';
PRINT '3️⃣ PERMISOS ESPECÍFICOS:';
PRINT '   GRANT {permiso} ON {objeto} TO {usuario};';
PRINT '   - SELECT, INSERT, UPDATE, DELETE, EXECUTE';
PRINT '   - Más granular que roles';
PRINT '';
PRINT '4️⃣ DENEGAR ACCESO:';
PRINT '   DENY {permiso} ON {objeto} TO {usuario};';
PRINT '   - Máxima prioridad (bloquea todo)';
PRINT '   - Incluso sobrescribe GRANT y roles';
PRINT '';
PRINT '5️⃣ QUITAR PERMISOS:';
PRINT '   REVOKE {permiso} ON {objeto} FROM {usuario};';
PRINT '   - Vuelve a estado neutral';
PRINT '   - Permite herencia de roles';
PRINT '';
PRINT '6️⃣ ROLES PERSONALIZADOS:';
PRINT '   CREATE ROLE [nombre];';
PRINT '   - Agrupan permisos';
PRINT '   - Más fácil de mantener';
PRINT '';
PRINT '7️⃣ AUDITORÍA:';
PRINT '   - sys.database_principals (usuarios y roles)';
PRINT '   - sys.database_permissions (permisos)';
PRINT '   - sys.database_role_members (membresía)';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';
PRINT '⚠️ JERARQUÍA DE PERMISOS:';
PRINT '   1. DENY   ← Máxima prioridad (BLOQUEA TODO)';
PRINT '   2. GRANT  ← Otorga permiso';
PRINT '   3. REVOKE ← Neutral (puede heredar de roles)';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';

-- Tabla resumen visual
PRINT '📋 RESUMEN DE PERMISOS FINALES:';
PRINT '┌────────────────────┬───────────────────────────────────────┐';
PRINT '│ USUARIO            │ PERMISOS                              │';
PRINT '├────────────────────┼───────────────────────────────────────┤';
PRINT '│ usuario_ventas     │ Lectura en todas las tablas           │';
PRINT '│ usuario_it         │ Lectura/escritura (excepto Productos) │';
PRINT '│ usuario_rrhh       │ Lectura (excepto columna Salario)     │';
PRINT '│ usuario_gerente    │ Permisos en Empleados y Productos     │';
PRINT '│ usuario_auditor    │ Lectura + VIEW DEFINITION             │';
PRINT '└────────────────────┴───────────────────────────────────────┘';
PRINT '';
GO
