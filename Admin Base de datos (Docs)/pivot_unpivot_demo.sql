-- ============================================================
--  DEMO: PIVOT y UNPIVOT en SQL Server
--  Tabla de ejemplo: Ventas (Vendedor, Mes, Importe)
-- ============================================================

-- 1. Crear tabla de ejemplo
CREATE TABLE Ventas (
    Vendedor NVARCHAR(50),
    Mes      NVARCHAR(20),
    Importe  INT
);

-- 2. Insertar datos
INSERT INTO Ventas VALUES
('Ana',   'Enero',   1200),
('Ana',   'Febrero',  950),
('Ana',   'Marzo',   1100),
('Luis',  'Enero',    800),
('Luis',  'Febrero', 1300),
('Luis',  'Marzo',    700),
('María', 'Enero',   1500),
('María', 'Febrero', 1100),
('María', 'Marzo',    950);

-- ============================================================
--  VER DATOS ORIGINALES
-- ============================================================
SELECT * FROM Ventas;

-- ============================================================
--  PIVOT: filas -> columnas
--  Cada mes pasa a ser una columna con la suma del importe
-- ============================================================
SELECT Vendedor, [Enero], [Febrero], [Marzo]
FROM Ventas
PIVOT (
    SUM(Importe)
    FOR Mes IN ([Enero], [Febrero], [Marzo])
) AS VentasPivot;

-- ============================================================
--  UNPIVOT: columnas -> filas
--  Usamos el resultado del PIVOT como CTE y lo deshacemos
-- ============================================================
WITH VentasPivot AS (
    SELECT Vendedor, [Enero], [Febrero], [Marzo]
    FROM Ventas
    PIVOT (
        SUM(Importe)
        FOR Mes IN ([Enero], [Febrero], [Marzo])
    ) AS p
)
SELECT Vendedor, Mes, Importe
FROM VentasPivot
UNPIVOT (
    Importe
    FOR Mes IN ([Enero], [Febrero], [Marzo])
) AS VentasUnpivot
ORDER BY Vendedor, Mes;

-- ============================================================
--  LIMPIAR (opcional)
-- ============================================================
-- DROP TABLE Ventas;
