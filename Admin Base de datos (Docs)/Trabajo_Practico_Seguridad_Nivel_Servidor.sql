-- ════════════════════════════════════════════════════════════════════════════════
-- 📝 TRABAJO PRÁCTICO: SEGURIDAD A NIVEL SERVIDOR
-- ════════════════════════════════════════════════════════════════════════════════

-- 
-- INSTRUCCIONES:
-- 1. Lee cada enunciado con atención
-- 2. Resuelve los ejercicios en SSMS
-- 3. Verifica los resultados con las consultas de validación

-- ════════════════════════════════════════════════════════════════════════════════

USE [master];
GO

-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 1: Verificación del Modo de Autenticación
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
Tu jefe te pidió verificar si el servidor SQL Server está configurado para aceptar
logins de SQL Server Authentication, o solo acepta Windows Authentication.

TAREAS:
a) Escribe una consulta que muestre el modo de autenticación actual del servidor
   y que muestre un mensaje claro como "Mixed Mode" o "Windows Only"
   
b) Si el resultado muestra "Windows Only", escribe el script necesario para
   cambiar a "Mixed Mode" (comentado, para no ejecutarlo accidentalmente)
   
c) ¿Qué debes hacer después de ejecutar el script del punto b) para que el
   cambio tenga efecto?

VALIDACIÓN:
-- Ejecuta esta consulta para verificar:
SELECT 
    CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
        WHEN 0 THEN 'Mixed Mode ✅'
        WHEN 1 THEN 'Windows Only ⚠️'
    END AS ModoAutenticacion;
GO
*/

-- TU SOLUCIÓN AQUÍ:





-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 2: Crear Logins con Políticas de Seguridad
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
Tu empresa contrata a tres nuevos empleados para el departamento de Ventas:
- Ana García
- Carlos Rodríguez  
- Laura Martínez

Necesitas crear logins de SQL Server para cada uno, siguiendo las políticas
de seguridad corporativas.

TAREAS:
a) Crea un login llamado "AnaGarcia" con:
   - Contraseña: Ventas2026!
   - Base de datos por defecto: master
   - Verificación de políticas de Windows: ACTIVADA
   - Expiración de contraseña: ACTIVADA
   
b) Crea un login llamado "CarlosRodriguez" con:
   - Contraseña: Ventas2026!
   - Base de datos por defecto: master
   - Mismas políticas que Ana
   
c) Crea un login llamado "LauraMartinez" con:
   - Contraseña: Ventas2026!
   - Base de datos por defecto: master
   - Mismas políticas que Ana

VALIDACIÓN:
-- Ejecuta esta consulta para verificar que se crearon correctamente:
SELECT 
    name AS LoginName,
    type_desc AS Type,
    default_database_name AS DefaultDB,
    is_policy_checked AS CheckPolicy,
    is_expiration_checked AS CheckExpiration,
    create_date AS FechaCreacion
FROM sys.server_principals
WHERE name IN ('AnaGarcia', 'CarlosRodriguez', 'LauraMartinez')
ORDER BY name;
GO
*/

-- TU SOLUCIÓN AQUÍ:





-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 3: Modificar Logins Existentes
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
Han ocurrido varios eventos en la empresa:

1. Ana García se fue de vacaciones por 30 días
2. Carlos Rodríguez olvidó su contraseña y necesita una nueva
3. Laura Martínez será transferida al proyecto de la base de datos "ProyectoX",
   por lo que su base de datos por defecto debe cambiar

TAREAS:
a) Deshabilita temporalmente el login de Ana
b) Cambia la contraseña de Carlos a: NuevaVentas2026!
c) Cambia la base de datos por defecto de Laura a: ProyectoX
   (no importa si la BD no existe, solo practica el comando)

VALIDACIÓN:
-- Verifica los cambios:
SELECT 
    name AS LoginName,
    is_disabled AS Deshabilitado,
    default_database_name AS BDPorDefecto,
    modify_date AS UltimaModificacion
FROM sys.server_principals
WHERE name IN ('AnaGarcia', 'CarlosRodriguez', 'LauraMartinez')
ORDER BY name;
GO
*/

-- TU SOLUCIÓN AQUÍ:





-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 4: Asignar Server Roles
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
Ana regresó de vacaciones y los roles de cada empleado han sido definidos:

- Ana García: Necesita crear nuevas bases de datos para el departamento de Ventas
- Carlos Rodríguez: Debe poder realizar operaciones de importación masiva (BULK INSERT)
- Laura Martínez: Necesita ambos permisos (crear BDs e importación masiva)

TAREAS:
a) Habilita nuevamente el login de Ana (estaba deshabilitado)
b) Asigna a Ana al server role "dbcreator"
c) Asigna a Carlos al server role "bulkadmin"
d) Asigna a Laura a AMBOS server roles: "dbcreator" y "bulkadmin"

VALIDACIÓN:
-- Verifica las asignaciones:
SELECT 
    member.name AS LoginName,
    role.name AS ServerRole
FROM sys.server_role_members srm
JOIN sys.server_principals role ON srm.role_principal_id = role.principal_id
JOIN sys.server_principals member ON srm.member_principal_id = member.principal_id
WHERE member.name IN ('AnaGarcia', 'CarlosRodriguez', 'LauraMartinez')
ORDER BY member.name, role.name;
GO
*/

-- TU SOLUCIÓN AQUÍ: