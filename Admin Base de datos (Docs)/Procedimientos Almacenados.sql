create database procedimientos;

use procedimientos;


 create table empleados(
  documento char(8),
  nombre varchar(20),
  apellido varchar(20),
  sueldo decimal(6,2),
  cantidadhijos int,
  seccion varchar(20),
  primary key(documento)
 );

-- 2- Ingrese algunos registros:
 insert into empleados values('22222222','Juan','Perez',300,2,'Contaduria');
 insert into empleados values('22333333','Luis','Lopez',300,0,'Contaduria');
 insert into empleados values ('22444444','Marta','Perez',500,1,'Sistemas');
 insert into empleados values('22555555','Susana','Garcia',400,2,'Secretaria');
 insert into empleados values('22666666','Jose Maria','Morales',400,3,'Secretaria');

select * from empleados;

--Cree un procedimiento almacenado llamado "pa_empleados_sueldo" que seleccione los nombres, apellidos y sueldos de los empleados
CREATE PROCEDURE pa_empleados_sueldo
AS
BEGIN
    SELECT nombre, apellido, sueldo
    FROM empleados;
END;
GO

EXEC pa_empleados_sueldo 

-- ver los procedimientos de la base
SELECT name, create_date, modify_date
FROM sys.procedures;


--Cree un procedimiento almacenado llamado "pa_empleados_sueldo" que seleccione los nombres, 
-- apellidos y sueldos de los empleados que tengan un sueldo superior o igual al enviado como 
-- parámetro
CREATE PROCEDURE pa_empleados_sueldo
    @p_sueldo DECIMAL(6,2)
AS
BEGIN
    SELECT nombre, apellido, sueldo
    FROM empleados
    WHERE sueldo >= @p_sueldo;
END;
GO

EXEC pa_empleados_sueldo 300;

EXEC pa_empleados_sueldo @p_sueldo = 300;


--Cree un procedimiento almacenado llamado "pa_empleados_actualizar_sueldo" que actualice los 
-- sueldos iguales al enviado como primer parámetro con el valor enviado como segundo parámetro
CREATE PROCEDURE pa_empleados_actualizar_sueldo
    @p_sueldoanterior DECIMAL(6,2),
    @p_sueldonuevo DECIMAL(6,2)
AS
BEGIN
    UPDATE empleados
    SET sueldo = @p_sueldonuevo
    WHERE sueldo = @p_sueldoanterior;
END;
GO

EXEC pa_empleados_actualizar_sueldo 300, 350;
-- o
EXEC pa_empleados_actualizar_sueldo @p_sueldoanterior = 300, @p_sueldonuevo = 350;


select * from empleados

--Cree un procedimiento almacenado llamado "pa_seccion" al cual le enviamos el nombre de una 
-- sección y que nos retorne el promedio de sueldos de todos los empleados de esa sección y el valor 
-- mayor de sueldo (de esa sección)
CREATE PROCEDURE pa_seccion
    @p_seccion VARCHAR(20),
    @promedio FLOAT OUTPUT,
    @mayor FLOAT OUTPUT
AS
BEGIN
    SELECT @promedio = AVG(sueldo)
    FROM empleados
    WHERE seccion = @p_seccion;

    SELECT @mayor = MAX(sueldo)
    FROM empleados
    WHERE seccion = @p_seccion;
END;
GO


DECLARE @prom FLOAT, @may FLOAT;

EXEC pa_seccion 
    @p_seccion = 'Sistemas',
    @promedio = @prom OUTPUT,
    @mayor = @may OUTPUT;

SELECT @prom AS promedio, @may AS mayor;



-- Creamos un procedimiento que recibe un número de documento y un entero como parámetro de entrada y salida
CREATE TABLE empleados (
    documento CHAR(8),
    nombre VARCHAR(20),
    apellido VARCHAR(20),
    sueldo DECIMAL(6,2),
    cantidadhijos INT,
    seccion VARCHAR(20),
    PRIMARY KEY (documento)
);

INSERT INTO empleados VALUES ('22222222','Juan','Perez',300,2,'Contaduria');
INSERT INTO empleados VALUES ('22333333','Luis','Lopez',700,0,'Contaduria');
INSERT INTO empleados VALUES ('22444444','Marta','Perez',500,1,'Sistemas');
INSERT INTO empleados VALUES ('22555555','Susana','Garcia',400,2,'Secretaria');
INSERT INTO empleados VALUES ('22666666','Jose Maria','Morales',1200,3,'Secretaria');

SELECT * FROM empleados;

DROP PROCEDURE IF EXISTS pa_cantidad_hijos;
GO

CREATE PROCEDURE pa_cantidad_hijos
    @p_documento CHAR(8),
    @cantidad INT OUTPUT
AS
BEGIN
    SELECT @cantidad = cantidadhijos + @cantidad
    FROM empleados
    WHERE documento = @p_documento;
END;
GO

-- Ejecutar:
DECLARE @cant INT = 0;

EXEC pa_cantidad_hijos 
    @p_documento = '22222222',
    @cantidad = @cant OUTPUT;

SELECT @cant AS cant; -- muestra un 2



-- sp con condicionales
USE procedimientos;
GO

DROP PROCEDURE IF EXISTS pa_mayor;
GO

CREATE PROCEDURE pa_mayor
    @valor1 INT,
    @valor2 INT
AS
BEGIN
    IF @valor1 > @valor2
        SELECT @valor1 AS mayor;
    ELSE
        SELECT @valor2 AS mayor;
END;
GO

EXEC pa_mayor 20, 400;

-- sp con bucles
DROP PROCEDURE IF EXISTS pa_generar_dos_aleatorios;
GO

CREATE PROCEDURE pa_generar_dos_aleatorios
    @valor1 INT OUTPUT,
    @valor2 INT OUTPUT
AS
BEGIN
    DECLARE @cont INT;

    SET @valor1 = 0;
    SET @valor2 = 0;
    SET @cont = 0;

    WHILE @valor1 = @valor2
    BEGIN
        SET @valor1 = CAST(RAND() * 10 AS INT);
        SET @valor2 = CAST(RAND() * 10 AS INT);
        SET @cont = @cont + 1;
    END;

    SELECT @cont AS cont;
END;
GO

-- Ejecutar:
DECLARE @v1 INT, @v2 INT;

EXEC pa_generar_dos_aleatorios
    @valor1 = @v1 OUTPUT,
    @valor2 = @v2 OUTPUT;

SELECT @v1 AS valor1, @v2 AS valor2;


-- variante
DROP PROCEDURE IF EXISTS pa_generar_dos_aleatorios;
GO

CREATE PROCEDURE pa_generar_dos_aleatorios
    @valor1 INT OUTPUT,
    @valor2 INT OUTPUT
AS
BEGIN
    DECLARE @cont INT = 0;

    WHILE 1 = 1
    BEGIN
        SET @valor1 = CAST(RAND() * 10 AS INT);
        SET @valor2 = CAST(RAND() * 10 AS INT);
        SET @cont = @cont + 1;

        IF @valor1 <> @valor2 BREAK;  -- equivalente al UNTIL
    END;

    SELECT @cont AS cont;
END;
GO

-- variante 2
DROP PROCEDURE IF EXISTS pa_generar_dos_aleatorios;
GO

CREATE PROCEDURE pa_generar_dos_aleatorios
    @valor1 INT OUTPUT,
    @valor2 INT OUTPUT
AS
BEGIN
    WHILE 1 = 1
    BEGIN
        SET @valor1 = CAST(RAND() * 10 AS INT);
        SET @valor2 = CAST(RAND() * 10 AS INT);

        IF @valor1 <> @valor2 BREAK;  -- equivalente al LEAVE etiqueta1
    END;
END;
GO

-- Ejecutar:
DECLARE @v1 INT, @v2 INT;

EXEC pa_generar_dos_aleatorios
    @valor1 = @v1 OUTPUT,
    @valor2 = @v2 OUTPUT;

SELECT @v1 AS valor1, @v2 AS valor2;


-- switch case
DROP PROCEDURE IF EXISTS pa_tipo_medalla;
GO

CREATE PROCEDURE pa_tipo_medalla
    @puesto INT,
    @tipo VARCHAR(20) OUTPUT
AS
BEGIN
    SET @tipo = CASE @puesto
        WHEN 1 THEN 'oro'
        WHEN 2 THEN 'plata'
        WHEN 3 THEN 'bronce'
    END;
END;
GO

-- Ejecutar:
DECLARE @ti VARCHAR(20);

EXEC pa_tipo_medalla @puesto = 1, @tipo = @ti OUTPUT;
SELECT @ti AS tipo;

EXEC pa_tipo_medalla @puesto = 2, @tipo = @ti OUTPUT;
SELECT @ti AS tipo;

