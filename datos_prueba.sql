-- ============================================================
-- DATOS DE PRUEBA: Mc Ilerna Albor Croft
-- DESCRIPCIÓN: Datos de ejemplo para testing y validación
-- VERSIÓN: 2.0 (con normalización de ingredientes)
-- FECHA: 21 de enero de 2026
-- ============================================================

USE McIlerna_Albor_Croft;

-- ============================================================
-- INGREDIENTES (NUEVA TABLA)
-- ============================================================

INSERT INTO INGREDIENTE (Nombre, Alergeno, Tipo_Alergeno) VALUES
('Pan', TRUE, 'Gluten'),
('Carne de ternera', FALSE, NULL),
('Lechuga', FALSE, NULL),
('Tomate', FALSE, NULL),
('Queso cheddar', TRUE, 'Lactosa'),
('Mayonesa', TRUE, 'Huevo'),
('Cebolla', FALSE, NULL),
('Pepinillos', FALSE, NULL),
('Bacon', FALSE, NULL),
('Patatas', FALSE, NULL),
('Aceite de girasol', FALSE, NULL),
('Sal', FALSE, NULL);

-- ============================================================
-- REPARTIDORES
-- ============================================================

INSERT INTO REPARTIDOR (Nombre, Apellido1, Apellido2, DNI, Telefono, Matricula_Moto, Turno) VALUES
('Carlos', 'García', 'López', '12345678A', '+34 600123456', '1234ABC', 'M'),
('María', 'Rodríguez', 'Martínez', '23456789B', '+34 600234567', '2345BCD', 'T'),
('José', 'Fernández', 'Sánchez', '34567890C', '+34 600345678', '3456CDE', 'N'),
('Ana', 'Martín', 'Díaz', '45678901D', '+34 600456789', '4567DEF', 'M'),
('Luis', 'González', 'Ruiz', '56789012E', '+34 600567890', '5678EFG', 'T');

-- ============================================================
-- PRODUCTOS
-- ============================================================

INSERT INTO PRODUCTO (Nombre, Precio) VALUES
('Hamburguesa Simple', 3.50),
('Hamburguesa Doble', 5.50),
('Hamburguesa con Queso', 4.50),
('Patatas Fritas Medianas', 2.50),
('Patatas Fritas Grandes', 3.50),
('Coca-Cola Mediana', 2.00),
('Coca-Cola Grande', 2.50),
('Fanta Naranja', 2.00),
('Agua Mineral', 1.50),
('Helado de Vainilla', 2.00);

-- ============================================================
-- PRODUCTO_INGREDIENTE (NUEVA TABLA - Relación N:M)
-- ============================================================

-- Hamburguesa Simple (Cod_Producto = 1)
INSERT INTO PRODUCTO_INGREDIENTE (Cod_Producto, Cod_Ingrediente) VALUES
(1, 1),  -- Pan
(1, 2),  -- Carne de ternera
(1, 3),  -- Lechuga
(1, 4);  -- Tomate

-- Hamburguesa Doble (Cod_Producto = 2)
INSERT INTO PRODUCTO_INGREDIENTE (Cod_Producto, Cod_Ingrediente) VALUES
(2, 1),  -- Pan
(2, 2),  -- Carne de ternera (doble porción)
(2, 3),  -- Lechuga
(2, 4),  -- Tomate
(2, 7);  -- Cebolla

-- Hamburguesa con Queso (Cod_Producto = 3)
INSERT INTO PRODUCTO_INGREDIENTE (Cod_Producto, Cod_Ingrediente) VALUES
(3, 1),  -- Pan
(3, 2),  -- Carne de ternera
(3, 3),  -- Lechuga
(3, 4),  -- Tomate
(3, 5);  -- Queso cheddar (ALÉRGENO: Lactosa)

-- Patatas Fritas Medianas (Cod_Producto = 4)
INSERT INTO PRODUCTO_INGREDIENTE (Cod_Producto, Cod_Ingrediente) VALUES
(4, 10), -- Patatas
(4, 11), -- Aceite de girasol
(4, 12); -- Sal

-- Patatas Fritas Grandes (Cod_Producto = 5)
INSERT INTO PRODUCTO_INGREDIENTE (Cod_Producto, Cod_Ingrediente) VALUES
(5, 10), -- Patatas
(5, 11), -- Aceite de girasol
(5, 12); -- Sal

-- ============================================================
-- MENÚS
-- ============================================================

INSERT INTO MENU (Nombre, Descripcion, Precio) VALUES
('Menú Ahorro', 'Hamburguesa Simple + Bebida + Patatas', 6.90),
('Menú Doble', 'Hamburguesa Doble + Bebida Grande + Patatas Grandes', 9.90),
('Menú Infantil', 'Hamburguesa Simple + Bebida + Helado', 5.90);

-- ============================================================
-- COMPOSICION_MENU
-- ============================================================

-- Menú Ahorro (Cod_Menu = 1)
INSERT INTO COMPOSICION_MENU (Cod_Menu, Cod_Producto, Cantidad) VALUES
(1, 1, 1),  -- 1 Hamburguesa Simple
(1, 6, 1),  -- 1 Coca-Cola Mediana
(1, 4, 1);  -- 1 Patatas Fritas Medianas

-- Menú Doble (Cod_Menu = 2)
INSERT INTO COMPOSICION_MENU (Cod_Menu, Cod_Producto, Cantidad) VALUES
(2, 2, 1),  -- 1 Hamburguesa Doble
(2, 7, 1),  -- 1 Coca-Cola Grande
(2, 5, 1);  -- 1 Patatas Fritas Grandes

-- Menú Infantil (Cod_Menu = 3)
INSERT INTO COMPOSICION_MENU (Cod_Menu, Cod_Producto, Cantidad) VALUES
(3, 1, 1),  -- 1 Hamburguesa Simple
(3, 8, 1),  -- 1 Fanta Naranja
(3, 10, 1); -- 1 Helado de Vainilla

-- ============================================================
-- PEDIDOS
-- ============================================================

INSERT INTO PEDIDO (Fecha, Hora) VALUES
('2026-01-21', '12:30:00'),
('2026-01-21', '12:45:00'),
('2026-01-21', '13:00:00'),
('2026-01-21', '13:15:00'),
('2026-01-21', '13:30:00');

-- ============================================================
-- PEDIDOS DE VENTANILLA
-- ============================================================

INSERT INTO PEDIDO_VENTANILLA (Num_Pedido, Num_Ventanilla) VALUES
(1, 1),
(3, 2),
(5, 1);

-- ============================================================
-- PEDIDOS A DOMICILIO
-- ============================================================

INSERT INTO PEDIDO_DOMICILIO (Num_Pedido, Telefono_Contacto, Poblacion, Direccion_Entrega, Num_Repartidor) VALUES
(2, '+34 666111222', 'Jerez de la Frontera', 'Calle Mayor 123, 3ºB', 1),
(4, '+34 666333444', 'Jerez de la Frontera', 'Avenida Andalucía 45, 1ºA', 2);

-- ============================================================
-- DETALLE_PEDIDO_PRODUCTO
-- ============================================================

-- Pedido 1 (Ventanilla)
INSERT INTO DETALLE_PEDIDO_PRODUCTO (Num_Pedido, Cod_Producto, Cantidad, Precio_Venta) VALUES
(1, 1, 2, 3.50),  -- 2 Hamburguesas Simples
(1, 6, 2, 2.00);  -- 2 Coca-Colas Medianas

-- Pedido 3 (Ventanilla)
INSERT INTO DETALLE_PEDIDO_PRODUCTO (Num_Pedido, Cod_Producto, Cantidad, Precio_Venta) VALUES
(3, 2, 1, 5.50),  -- 1 Hamburguesa Doble
(3, 4, 1, 2.50),  -- 1 Patatas Medianas
(3, 7, 1, 2.50);  -- 1 Coca-Cola Grande

-- ============================================================
-- DETALLE_PEDIDO_MENU
-- ============================================================

-- Pedido 2 (Domicilio)
INSERT INTO DETALLE_PEDIDO_MENU (Num_Pedido, Cod_Menu, Cantidad, Precio_Venta) VALUES
(2, 1, 2, 6.90);  -- 2 Menús Ahorro

-- Pedido 4 (Domicilio)
INSERT INTO DETALLE_PEDIDO_MENU (Num_Pedido, Cod_Menu, Cantidad, Precio_Venta) VALUES
(4, 2, 1, 9.90),  -- 1 Menú Doble
(4, 3, 1, 5.90);  -- 1 Menú Infantil

-- Pedido 5 (Ventanilla)
INSERT INTO DETALLE_PEDIDO_MENU (Num_Pedido, Cod_Menu, Cantidad, Precio_Venta) VALUES
(5, 1, 3, 6.90);  -- 3 Menús Ahorro

-- ============================================================
-- CONSULTAS DE VALIDACIÓN
-- ============================================================

-- 1. Listar todos los ingredientes
SELECT * FROM INGREDIENTE ORDER BY Nombre;

-- 2. Productos con alérgenos
SELECT DISTINCT p.Nombre, GROUP_CONCAT(i.Tipo_Alergeno) as Alergenos
FROM PRODUCTO p
JOIN PRODUCTO_INGREDIENTE pi ON p.Cod_Producto = pi.Cod_Producto
JOIN INGREDIENTE i ON pi.Cod_Ingrediente = i.Cod_Ingrediente
WHERE i.Alergeno = TRUE
GROUP BY p.Cod_Producto;

-- 3. Productos SIN lactosa (aptos para intolerantes)
SELECT p.Nombre
FROM PRODUCTO p
WHERE p.Cod_Producto NOT IN (
    SELECT pi.Cod_Producto
    FROM PRODUCTO_INGREDIENTE pi
    JOIN INGREDIENTE i ON pi.Cod_Ingrediente = i.Cod_Ingrediente
    WHERE i.Tipo_Alergeno = 'Lactosa'
);

-- 4. Ingredientes de un producto específico
SELECT i.Nombre, i.Alergeno, i.Tipo_Alergeno
FROM PRODUCTO p
JOIN PRODUCTO_INGREDIENTE pi ON p.Cod_Producto = pi.Cod_Producto
JOIN INGREDIENTE i ON pi.Cod_Ingrediente = i.Cod_Ingrediente
WHERE p.Cod_Producto = 3  -- Hamburguesa con Queso
ORDER BY i.Nombre;

-- 5. Ingredientes más usados
SELECT i.Nombre, COUNT(*) as Num_Productos
FROM INGREDIENTE i
JOIN PRODUCTO_INGREDIENTE pi ON i.Cod_Ingrediente = pi.Cod_Ingrediente
GROUP BY i.Cod_Ingrediente
ORDER BY Num_Productos DESC;

-- 6. Pedidos del día con totales
SELECT 
    p.Num_Pedido,
    p.Fecha,
    p.Hora,
    CASE 
        WHEN pv.Num_Pedido IS NOT NULL THEN 'Ventanilla'
        WHEN pd.Num_Pedido IS NOT NULL THEN 'Domicilio'
    END AS Tipo,
    COALESCE(SUM(dpp.Cantidad * dpp.Precio_Venta), 0) + 
    COALESCE(SUM(dpm.Cantidad * dpm.Precio_Venta), 0) AS Total
FROM PEDIDO p
LEFT JOIN PEDIDO_VENTANILLA pv ON p.Num_Pedido = pv.Num_Pedido
LEFT JOIN PEDIDO_DOMICILIO pd ON p.Num_Pedido = pd.Num_Pedido
LEFT JOIN DETALLE_PEDIDO_PRODUCTO dpp ON p.Num_Pedido = dpp.Num_Pedido
LEFT JOIN DETALLE_PEDIDO_MENU dpm ON p.Num_Pedido = dpm.Num_Pedido
GROUP BY p.Num_Pedido
ORDER BY p.Fecha, p.Hora;

-- ============================================================
-- FIN DE DATOS DE PRUEBA
-- ============================================================
