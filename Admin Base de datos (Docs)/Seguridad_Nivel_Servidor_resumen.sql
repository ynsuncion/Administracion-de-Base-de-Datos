-- ================================================================================
-- PARTE 1: SEGURIDAD A NIVEL SERVIDOR
-- ================================================================================

-- --------------------------------------------------------------------------------
-- SECCIÓN 1: LOGINS (AUTENTICACIÓN)
-- --------------------------------------------------------------------------------

-- ============================================
-- 1.1 CREAR LOGINS
-- ============================================

-- ───────────────────────────────────────────
-- A. Login con Autenticación de Windows
-- ───────────────────────────────────────────

-- IMPORTANTE: Los ejemplos con DOMAIN\Usuario y CONTOSO\JuanPerez solo funcionan
-- si estás en un dominio corporativo con Active Directory.
-- Si estás en WORKGROUP, debes usar el NOMBRE DE TU MÁQUINA.

-- Ejemplo genérico (NO EJECUTAR directamente - es solo sintaxis)
-- CREATE LOGIN [DOMAIN\Usuario] FROM WINDOWS;

-- ───────────────────────────────────────────
-- PASO 1: Verificar tu configuración
-- ───────────────────────────────────────────

-- Ver el nombre de TU dominio actual
-- Si devuelve WORKGROUP → No estás en un dominio
-- Si devuelve MIEMPRESA → Estás en un dominio corporativo
SELECT DEFAULT_DOMAIN() AS Dominio;
GO

-- Ver el nombre de tu PC
SELECT SERVERPROPERTY('MachineName') AS NombreMaquina;
GO

-- Ver tu usuario actual de Windows
SELECT SYSTEM_USER AS TuUsuarioActual;
GO

-- ───────────────────────────────────────────
-- PASO 2: Crear login según tu configuración
-- ───────────────────────────────────────────

-- Si estás en WORKGROUP (sin dominio):
-- Reemplaza DESKTOP-ABC123 con el nombre de TU PC
-- Reemplaza smata con TU nombre de usuario
-- CREATE LOGIN [DESKTOP-ABC123\smata] FROM WINDOWS;
-- GO

-- Si estás en un DOMINIO corporativo:
-- Reemplaza MIEMPRESA con tu dominio real
-- Reemplaza juan.perez con un usuario real del dominio
-- CREATE LOGIN [MIEMPRESA\juan.perez] FROM WINDOWS;
-- GO

-- Ver logins de Windows que ya existen (para referencia)
SELECT 
    name AS LoginName,
    type_desc AS Type,
    create_date AS CreateDate
FROM sys.server_principals
WHERE type_desc LIKE '%WINDOWS%'
ORDER BY name;
GO

-- ───────────────────────────────────────────
-- B. Login con Autenticación de SQL Server
-- ───────────────────────────────────────────

-- Esta opción es más fácil para practicar ya que no requiere
-- configurar Windows Authentication o Active Directory

-- Login básico
CREATE LOGIN [UsuarioApp]
WITH PASSWORD = 'P@ssw0rd123!';
GO

-- Login con opciones completas
CREATE LOGIN [UsuarioCompleto]
WITH PASSWORD = 'P@ssw0rd123!',
     DEFAULT_DATABASE = [master],
     CHECK_EXPIRATION = ON,-- dura 42 dias x defecto en windows
     CHECK_POLICY = ON;
GO

-- ════════════════════════════════════════════════════════════════════════════════
-- 🛡️ ¿QUÉ HACE CHECK_POLICY = ON?
-- ════════════════════════════════════════════════════════════════════════════════

/*
CHECK_POLICY = ON → Aplica las POLÍTICAS DE CONTRASEÑAS DE WINDOWS al login de SQL Server

📋 POLÍTICAS QUE VALIDA:
┌─────────────────────────────────────┬────────────────────────────────────────────┐
│ Política                            │ Ejemplo                                    │
├─────────────────────────────────────┼────────────────────────────────────────────┤
│ ✅ Complejidad                      │ Debe tener: mayúsculas, minúsculas,       │
│                                     │ números, símbolos                          │
│                                     │ ❌ '123456' → Rechazada                    │
│                                     │ ✅ 'P@ssw0rd123!' → Aceptada              │
├─────────────────────────────────────┼────────────────────────────────────────────┤
│ ✅ Longitud mínima                  │ Mínimo 8 caracteres (por defecto Windows) │
│                                     │ ❌ 'Ab1!' → Muy corta                      │
│                                     │ ✅ 'Abcd1234!' → OK                        │
├─────────────────────────────────────┼────────────────────────────────────────────┤
│ ✅ No usar nombre del usuario       │ ❌ LOGIN Juan, PASSWORD 'Juan123!'        │
│                                     │ ✅ LOGIN Juan, PASSWORD 'Segura123!'      │
├─────────────────────────────────────┼────────────────────────────────────────────┤
│ ✅ Bloqueo tras intentos fallidos   │ Después de 5 intentos → Cuenta bloqueada │
├─────────────────────────────────────┼────────────────────────────────────────────┤
│ ✅ Historial de contraseñas         │ No puedes reutilizar las últimas N        │
│                                     │ contraseñas                                │
└─────────────────────────────────────┴────────────────────────────────────────────┘

🆚 DIFERENCIA CON CHECK_EXPIRATION:
┌───────────────────┬─────────────────────────────────────────────────────────────┐
│ Opción            │ ¿Qué controla?                                              │
├───────────────────┼─────────────────────────────────────────────────────────────┤
│ CHECK_POLICY      │ CALIDAD de la contraseña (¿Es suficientemente compleja?)   │
│ CHECK_EXPIRATION  │ VIGENCIA de la contraseña (¿Caducó después de 42 días?)    │
└───────────────────┴─────────────────────────────────────────────────────────────┘

⚙️ VER POLÍTICAS ACTIVAS EN WINDOWS:
*/

-- Ver políticas desde T-SQL (ejecutar en SSMS):
-- EXEC xp_cmdshell 'net accounts';
-- GO

-- O ejecutar en CMD/PowerShell:
-- net accounts

/* Resultado típico:
    Longitud mínima de contraseña:      8
    Duración máxima de contraseña:      42 días
    Umbral de bloqueos:                 5 intentos
    Duración del bloqueo:               30 minutos
*/

-- ════════════════════════════════════════════════════════════════════════════════

--Duración máxima de la contraseña(ver en CMD):
-- net accounts

-- Para cambiar la duracion (afecta a todas las contraseñas de windows):
--net accounts /maxpwage:90

-- Crear múltiples logins de prueba
---- Ver primero el modo de autenticación actual
SELECT 
    CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
        WHEN 1 THEN '⚠️ SOLO Windows Authentication (necesitas cambiarlo)'
        WHEN 0 THEN '✅ Mixed Mode (Windows + SQL Server)'
    END AS ModoAutenticacion;
GO

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔄 CAMBIAR MODO DE AUTENTICACIÓN (Windows Only ↔ Mixed Mode)
-- ════════════════════════════════════════════════════════════════════════════════

/*
📋 TABLA DE REFERENCIA RÁPIDA:
┌───────┬──────────────────┬────────────────────────────────────────────────────────┐
│ Valor │ Modo             │ Descripción                                            │
├───────┼──────────────────┼────────────────────────────────────────────────────────┤
│   1   │ Windows Only     │ Solo acepta Windows Authentication                     │
│   2   │ Mixed Mode       │ Acepta Windows + SQL Server Authentication             │
└───────┴──────────────────┴────────────────────────────────────────────────────────┘

⚠️ IMPORTANTE: Después de cambiar el modo, DEBES REINICIAR SQL Server
*/

-- ────────────────────────────────────────────────────────────────────────────────
-- OPCIÓN 1: Cambiar a MIXED MODE (Windows + SQL Server Authentication)
-- ────────────────────────────────────────────────────────────────────────────────

 --USE [master];
 --GO
 
 --EXEC xp_instance_regwrite 
 --    N'HKEY_LOCAL_MACHINE', 
 --    N'Software\Microsoft\MSSQLServer\MSSQLServer',
 --    N'LoginMode', 
 --    REG_DWORD, 
 --    2;  -- 2 = Mixed Mode (Windows + SQL Server)
 --GO
 
 --PRINT '✅ Configurado para cambiar a: Mixed Mode';
 --PRINT '⚠️ REINICIA SQL Server para aplicar cambios:';
 --PRINT '   CMD: net stop MSSQLSERVER && net start MSSQLSERVER';
 --PRINT '   PowerShell: Restart-Service -Name MSSQLSERVER -Force';
 --GO

-- ────────────────────────────────────────────────────────────────────────────────
-- OPCIÓN 2: Cambiar a WINDOWS ONLY (Solo Windows Authentication)
-- ────────────────────────────────────────────────────────────────────────────────

-- USE [master];
-- GO
-- 
-- EXEC xp_instance_regwrite 
--     N'HKEY_LOCAL_MACHINE', 
--     N'Software\Microsoft\MSSQLServer\MSSQLServer',
--     N'LoginMode', 
--     REG_DWORD, 
--     1;  -- 1 = Solo Windows Authentication
-- GO
-- 
-- PRINT '✅ Configurado para cambiar a: Windows Only';
-- PRINT '⚠️ REINICIA SQL Server para aplicar cambios:';
-- PRINT '   CMD: net stop MSSQLSERVER && net start MSSQLSERVER';
-- PRINT '   PowerShell: Restart-Service -Name MSSQLSERVER -Force';
-- PRINT '';
-- PRINT '⚠️ ADVERTENCIA: Los logins de SQL Server NO podrán conectarse';
-- GO

-- ────────────────────────────────────────────────────────────────────────────────
-- SCRIPT COMPLETO CON VALIDACIÓN
-- ────────────────────────────────────────────────────────────────────────────────

/*
-- Script para cambiar modo con validación completa
USE [master];
GO

-- Ver modo actual
DECLARE @ModoActual INT;
SET @ModoActual = SERVERPROPERTY('IsIntegratedSecurityOnly');

PRINT '========================================';
PRINT 'CAMBIO DE MODO DE AUTENTICACIÓN';
PRINT '========================================';
PRINT 'Modo actual: ' + 
    CASE @ModoActual 
        WHEN 1 THEN 'Windows Only (1)'
        WHEN 0 THEN 'Mixed Mode (0)'
    END;
PRINT '';

-- DESCOMENTA LA OPCIÓN QUE NECESITES:

-- Para cambiar a Mixed Mode (Windows + SQL):
EXEC xp_instance_regwrite 
    N'HKEY_LOCAL_MACHINE', 
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'LoginMode', 
    REG_DWORD, 
    2;
PRINT '✅ Configurado para cambiar a: Mixed Mode (2)';

-- Para cambiar a Windows Only (descomenta esto y comenta lo anterior):
-- EXEC xp_instance_regwrite 
--     N'HKEY_LOCAL_MACHINE', 
--     N'Software\Microsoft\MSSQLServer\MSSQLServer',
--     N'LoginMode', 
--     REG_DWORD, 
--     1;
-- PRINT '✅ Configurado para cambiar a: Windows Only (1)';

PRINT '';
PRINT '⚠️⚠️⚠️ IMPORTANTE ⚠️⚠️⚠️';
PRINT 'El cambio NO tendrá efecto hasta que reinicies SQL Server';
PRINT '';
PRINT 'Ejecuta en CMD (como Administrador):';
PRINT '    net stop MSSQLSERVER';
PRINT '    net start MSSQLSERVER';
PRINT '';
PRINT 'O en PowerShell (como Administrador):';
PRINT '    Restart-Service -Name MSSQLSERVER -Force';
PRINT '========================================';
GO

-- Verificar cambio (ejecutar DESPUÉS de reiniciar)
SELECT 
    SERVERPROPERTY('IsIntegratedSecurityOnly') AS ValorNumerico,
    CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
        WHEN 0 THEN '✅ Mixed Mode (Windows + SQL Server)'
        WHEN 1 THEN '🔒 Windows Only'
    END AS ModoActual;
GO
*/

-- ────────────────────────────────────────────────────────────────────────────────
-- REINICIAR SQL SERVER (Opciones)
-- ────────────────────────────────────────────────────────────────────────────────

/*
OPCIÓN A: Desde CMD (como Administrador)
    net stop MSSQLSERVER
    net start MSSQLSERVER

OPCIÓN B: Desde PowerShell (como Administrador)
    Restart-Service -Name MSSQLSERVER -Force

OPCIÓN C: Desde T-SQL (si tienes permisos)
    SHUTDOWN WITH NOWAIT;
    -- Luego iniciar manualmente desde Services o CMD

OPCIÓN D: Desde Services (GUI)
    1. Win + R → services.msc
    2. Buscar "SQL Server (MSSQLSERVER)"
    3. Clic derecho → Restart
*/

-- ════════════════════════════════════════════════════════════════════════════════

CREATE LOGIN Juan WITH PASSWORD = 'Pass123!';
CREATE LOGIN Maria WITH PASSWORD = 'Pass123!';
CREATE LOGIN Pedro WITH PASSWORD = 'Pass123!';
GO

-- Verificar que se crearon
SELECT 
    name AS LoginName,
    type_desc AS Type,
    create_date AS CreateDate
FROM sys.server_principals
WHERE type = 'S'  -- S = SQL Login
AND name IN ('Juan', 'Maria', 'Pedro', 'UsuarioApp', 'UsuarioCompleto')
ORDER BY name;
GO

-- ============================================
-- 1.2 MODIFICAR LOGINS
-- ============================================

-- Cambiar contraseña
ALTER LOGIN [UsuarioApp]
WITH PASSWORD = 'Nueva_P@ssw0rd!';
GO

-- Cambiar base de datos por defecto
-- Cuando este Login se conecte, nos lleva directo a la base master
ALTER LOGIN [UsuarioApp]
WITH DEFAULT_DATABASE = [master];
GO

ALTER LOGIN [Juan] WITH PASSWORD = 'Nueva_P@ssw0rd!';

-- Deshabilitar login
ALTER LOGIN [UsuarioApp] DISABLE;
GO

-- Maria se va de vacaciones por 1 mes
ALTER LOGIN [Maria] DISABLE;

-- Cuando regresa:
ALTER LOGIN [UsuarioApp] ENABLE;
GO

ALTER LOGIN [Maria] ENABLE;
GO

-- ============================================
-- 1.3 CONSULTAR LOGINS (Básico)
-- ============================================

-- Ver todos los logins
SELECT 
    name AS LoginName,
    type_desc AS Type,
    create_date AS CreateDate,
    default_database_name AS DefaultDB,
    is_disabled AS IsDisabled
FROM sys.server_principals
WHERE type IN ('S', 'U', 'G')  -- S=SQL, U=Windows User, G=Windows Group
ORDER BY name;
GO

-- Ver logins y sus roles de servidor
SELECT 
    sp.name AS LoginName,
    sp.type_desc AS Type,
    sr.name AS ServerRole
FROM sys.server_principals sp
LEFT JOIN sys.server_role_members srm ON sp.principal_id = srm.member_principal_id
LEFT JOIN sys.server_principals sr ON srm.role_principal_id = sr.principal_id
WHERE sp.type IN ('S', 'U', 'G')
ORDER BY sp.name;
GO

-- ============================================
-- 1.4 ELIMINAR LOGINS
-- ============================================

-- Eliminar login (comentado para evitar ejecución accidental)
-- DROP LOGIN [UsuarioApp];
-- GO

DROP LOGIN Juan;

-- --------------------------------------------------------------------------------
-- SECCIÓN 2: SERVER ROLES (ROLES DE SERVIDOR)
-- --------------------------------------------------------------------------------

-- ============================================
-- 2.1 ASIGNAR LOGIN A SERVER ROLE
-- ============================================

/*
════════════════════════════════════════════════════════════════════════════════
⚠️ IMPORTANTE: SERVER ROLE vs DATABASE ROLE
════════════════════════════════════════════════════════════════════════════════

❓ Si Juan tiene rol 'dbcreator', ¿puede crear TABLAS?

📋 RESPUESTA: DEPENDE DE QUÉ BASE DE DATOS

┌────────────────────────────────────────────────────────────────────────────┐
│ ESCENARIO 1: Base de datos CREADA POR JUAN                                │
├────────────────────────────────────────────────────────────────────────────┤
│ CREATE DATABASE MiBD;  -- Juan puede (tiene dbcreator)                    │
│ GO                                                                         │
│ USE MiBD;                                                                  │
│ CREATE TABLE Productos (ID INT);  -- ✅ FUNCIONA (Juan es dueño/dbo)     │
│ GO                                                                         │
└────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────┐
│ ESCENARIO 2: Base de datos EXISTENTE (creada por otro)                    │
├────────────────────────────────────────────────────────────────────────────┤
│ USE ComprasDB;  -- BD que ya existía                                      │
│ CREATE TABLE MiTabla (ID INT);  -- ❌ ERROR: Permission denied            │
│                                                                            │
│ ¿Por qué? Juan NO tiene USER en esa BD, o no tiene permisos              │
└────────────────────────────────────────────────────────────────────────────┘
-- Agregar login al rol dbcreator (puede crear bases de datos)

*/

ALTER SERVER ROLE dbcreator 
ADD MEMBER [Juan];
GO

-- Agregar login al rol bulkadmin (puede hacer operaciones BULK INSERT)
ALTER SERVER ROLE bulkadmin 
ADD MEMBER [Juan];
GO

-- ============================================
-- 2.2 REMOVER LOGIN DE SERVER ROLE
-- ============================================

-- Remover a Juan del rol dbcreator
ALTER SERVER ROLE dbcreator 
DROP MEMBER [Juan];
GO

-- ============================================
-- 2.3 CREAR SERVER ROLE PERSONALIZADO
-- ============================================

-- Crear rol personalizado (SQL Server 2012+)
CREATE SERVER ROLE [MonitorRole];
GO

-- Asignar permisos específicos al rol
GRANT VIEW SERVER STATE TO [MonitorRole];
GRANT VIEW ANY DATABASE TO [MonitorRole];
GO

-- Agregar miembros al rol
ALTER SERVER ROLE [MonitorRole] ADD MEMBER [UsuarioApp];
GO

-- ============================================
-- 2.4 CONSULTAR SERVER ROLES
-- ============================================

-- Ver todos los server roles
SELECT name, type_desc, is_fixed_role
FROM sys.server_principals
WHERE type = 'R'
ORDER BY name;
GO

-- Ver miembros de un server role específico
SELECT 
    role.name AS RoleName,
    member.name AS MemberName,
    member.type_desc AS MemberType
FROM sys.server_role_members srm
JOIN sys.server_principals role ON srm.role_principal_id = role.principal_id
JOIN sys.server_principals member ON srm.member_principal_id = member.principal_id
WHERE role.name = 'dbcreator'
ORDER BY member.name;
GO

-- Ver todos los roles de un login específico
SELECT 
    sp.name AS ServerRole
FROM sys.server_role_members srm
JOIN sys.server_principals sp ON srm.role_principal_id = sp.principal_id
WHERE srm.member_principal_id = (
    SELECT principal_id 
    FROM sys.server_principals 
    WHERE name = 'UsuarioApp'
);
GO

