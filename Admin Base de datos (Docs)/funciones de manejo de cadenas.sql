-- Funciones de manejo de caracteres

-- Retorna posicion de una subcadena dentro de otra cadena
SELECT CHARINDEX('b', 'a,b,c'); --3
SELECT CHARINDEX('Mu', 'Hola Mundo');-- 6

--retorna la longitud de la cadena argumento.
SELECT LEN('Hola Mundo'); -- 10

-- Relleno: RIGHT con REPLICATE
SELECT RIGHT(REPLICATE('0', 10) + 'hola', 10);  -- '000000hola'

--retorna la cantidad (longitud) de caracteres de la cadena comenzando desde la inquierda, primer caracter
SELECT LEFT('buenos dias', 8);

--retorna una subcadena de tantos caracteres de longitud como especifica 
-- en tercer argumento, de la cadena enviada como primer argumento, empezando desde la posición especificada en el segundo argumento
SELECT SUBSTRING('Buenas tardes', 3, 6); --enas t

SELECT SUBSTRING('Margarita', 4, LEN('Margarita'));-- garita

-- LTRIM: quitar espacios a la izquierda
SELECT LTRIM('  hola');   -- 'hola'  

-- RTRIM: quitar espacios a la derecha
SELECT RTRIM('hola  ');   -- 'hola'  

SELECT TRIM('  hola mundo  ');   -- 'hola mundo' (SQL Server 2017+)

-- SQL Server 2022+: LTRIM con carácter (solo espacios en versiones anteriores)
SELECT LTRIM('00hola00', '0');  -- 'hola00' ✅ (SQL Server 2022+)

-- SQL Server anterior a 2022: con STUFF + PATINDEX
SELECT STUFF('00hola00', 1,
    PATINDEX('%[^0]%', '00hola00') - 1,
    ''
);  -- 'hola00'


SELECT REPLACE('xxx.mysql.com', 'x', 'w');  -- 'www.mysql.com'

SELECT REVERSE('Hola');  -- 'aloH'

-- equivalente mySQL: select insert('bxxnas tardes',2,7,'xx');
SELECT STUFF('bxxnas tardes', 2, 7, 'xx');-- 'bxxardes'





