select abs(-20);-- 20

-- CEILING: redondea hacia arriba
SELECT CEILING(12.34);   -- 13
SELECT CEILING(12.99);   -- 13
SELECT CEILING(-12.34);  -- -12  (hacia arriba = menos negativo)

-- FLOOR: redondea hacia abajo
SELECT FLOOR(12.34);     -- 12
SELECT FLOOR(12.99);     -- 12
SELECT FLOOR(-12.34);    -- -13  (hacia abajo = más negativo)


SELECT CASE WHEN 3 >= 7 THEN 3 ELSE 7 END;  -- para 2 valores

-- En MySQL son: greatest(x,y,..), least(x,y,...) y mod(n,m)
SELECT (SELECT MAX(v) FROM (VALUES (3),(7),(2),(9),(1)) AS t(v));  -- 9  
SELECT (SELECT MIN(v) FROM (VALUES (3),(7),(2),(9),(1)) AS t(v));  -- 1  
SELECT 10 % 3;       -- 1  (operador equivalente)

SELECT POWER(2, 3);-- 8

SELECT SQRT(25);-- 5


SELECT ROUND(12.547654, 2);
SELECT ROUND(12.547654, 2, 0);
SELECT ROUND(12.547654, 2, 1);


