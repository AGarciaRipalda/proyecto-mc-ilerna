-- ============================================================
-- 40 CONSULTAS SQL OPTIMIZADAS - BASE DE DATOS MC_ILERNA
-- ============================================================

USE mc_ilerna;

-- ============================================================
-- CONSULTAS BÁSICAS DE LISTADO (1-10)
-- ============================================================

-- 1. Listado completo de repartidores activos
-- BONUS: CONCAT nombre_completo
SELECT r.id_repartidor, CONCAT(
        r.nombre, ' ', r.apellido1, ' ', COALESCE(r.apellido2, '')
    ) AS nombre_completo, r.dni, r.telefono, r.turno
FROM repartidores AS r
ORDER BY r.apellido1, r.nombre;

-- 2. Productos por precio descendente
-- BONUS: CASE para destacar productos >4€
SELECT
    p.codigo_producto,
    p.nombre,
    p.ingredientes,
    CAST(p.precio AS DECIMAL(10, 2)) AS precio,
    CASE
        WHEN p.precio > 4 THEN 'DESTACADO'
        ELSE 'Normal'
    END AS categoria
FROM productos AS p
ORDER BY p.precio DESC;

-- 3. Menús con sus productos componentes
-- Alias: m=menus, cm=composicion_menus, p=productos
SELECT
    m.codigo_menu,
    m.nombre AS nombre_menu,
    CAST(m.precio AS DECIMAL(10, 2)) AS precio_menu,
    p.nombre AS producto,
    cm.cantidad
FROM
    menus AS m
    INNER JOIN composicion_menus AS cm ON m.codigo_menu = cm.codigo_menu
    INNER JOIN productos AS p ON cm.codigo_producto = p.codigo_producto
ORDER BY m.precio DESC;

-- 4. Pedidos del último mes por fecha
-- BONUS: Fechas dinámicas DATE_SUB(CURDATE())
SELECT p.id_pedido, p.fecha_hora, p.tipo_pedido, CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS total_facturado
FROM pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
WHERE
    p.fecha_hora >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY
    p.id_pedido,
    p.fecha_hora,
    p.tipo_pedido
ORDER BY p.fecha_hora DESC
LIMIT 20;

-- 5. Ventanillas más utilizadas
-- HAVING post-agregación
SELECT p.num_ventanilla, COUNT(p.id_pedido) AS num_pedidos
FROM pedidos AS p
WHERE
    p.tipo_pedido = 'Ventanilla'
GROUP BY
    p.num_ventanilla
HAVING
    COUNT(p.id_pedido) > 2
ORDER BY num_pedidos DESC;

-- 6. Repartidores por turno de trabajo
-- BONUS: GROUP_CONCAT, LEFT JOIN para incluir sin pedidos
SELECT
    r.turno,
    COUNT(DISTINCT r.id_repartidor) AS num_repartidores,
    GROUP_CONCAT(
        DISTINCT CONCAT(r.nombre, ' ', r.apellido1)
        ORDER BY r.apellido1 SEPARATOR ', '
    ) AS nombres,
    COUNT(p.id_pedido) AS total_entregas
FROM repartidores AS r
    LEFT JOIN pedidos AS p ON r.id_repartidor = p.id_repartidor
GROUP BY
    r.turno
ORDER BY r.turno;

-- 7. Productos con nombre que contenga "hamburguesa"
-- LEFT JOIN para incluir productos sin ventas, COALESCE para NULLs
SELECT
    p.codigo_producto,
    p.nombre,
    CAST(p.precio AS DECIMAL(10, 2)) AS precio,
    COALESCE(SUM(lp.cantidad), 0) AS unidades_vendidas
FROM
    productos AS p
    LEFT JOIN lineas_pedido AS lp ON p.codigo_producto = lp.codigo_producto
WHERE
    LOWER(p.nombre) LIKE '%hamburguesa%'
GROUP BY
    p.codigo_producto,
    p.nombre,
    p.precio
ORDER BY unidades_vendidas DESC;

-- 8. Clientes frecuentes por teléfono
-- Manejo NULLs con IS NOT NULL
SELECT
    p.telefono_contacto,
    COUNT(p.id_pedido) AS num_pedidos,
    MIN(p.fecha_hora) AS primer_pedido,
    MAX(p.fecha_hora) AS ultimo_pedido
FROM pedidos AS p
WHERE
    p.tipo_pedido = 'Domicilio'
    AND p.telefono_contacto IS NOT NULL
GROUP BY
    p.telefono_contacto
HAVING
    COUNT(p.id_pedido) >= 2
ORDER BY num_pedidos DESC;

-- 9. Pedidos caros (más de 15€)
-- DECIMAL(10,2) para dinero
SELECT
    p.id_pedido,
    p.fecha_hora,
    p.tipo_pedido,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS total_facturado,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) - 15 AS DECIMAL(10, 2)
    ) AS diferencia_15euros
FROM pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
GROUP BY
    p.id_pedido,
    p.fecha_hora,
    p.tipo_pedido
HAVING
    total_facturado > 15
ORDER BY total_facturado DESC;

-- 10. Zonas de entrega más solicitadas
-- Subconsulta para totales, DECIMAL(10,2)
SELECT
    p.poblacion,
    COUNT(DISTINCT p.id_pedido) AS num_pedidos,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS total_facturado,
    CAST(
        AVG(totales.total_pedido) AS DECIMAL(10, 2)
    ) AS ticket_medio
FROM
    pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
    INNER JOIN (
        SELECT id_pedido, SUM(cantidad * precio_unitario) AS total_pedido
        FROM lineas_pedido
        GROUP BY
            id_pedido
    ) AS totales ON p.id_pedido = totales.id_pedido
WHERE
    p.tipo_pedido = 'Domicilio'
GROUP BY
    p.poblacion
ORDER BY num_pedidos DESC
LIMIT 10;

-- ============================================================
-- CONSULTAS CON JOINS SIMPLES (11-20)
-- ============================================================

-- 11. Detalle completo pedidos ventanilla
-- BONUS: Alias correctos p, lp, pr, m
SELECT
    p.id_pedido,
    p.fecha_hora,
    p.num_ventanilla,
    COALESCE(pr.nombre, m.nombre) AS producto_menu,
    lp.cantidad,
    CAST(
        lp.precio_unitario AS DECIMAL(10, 2)
    ) AS precio_unitario,
    CAST(
        lp.cantidad * lp.precio_unitario AS DECIMAL(10, 2)
    ) AS subtotal
FROM
    pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
    LEFT JOIN productos AS pr ON lp.codigo_producto = pr.codigo_producto
    LEFT JOIN menus AS m ON lp.codigo_menu = m.codigo_menu
WHERE
    p.tipo_pedido = 'Ventanilla'
ORDER BY p.fecha_hora DESC;

-- 12. Pedidos domicilio con repartidor
-- INNER JOIN para solo pedidos con repartidor asignado
SELECT
    p.id_pedido,
    p.fecha_hora,
    p.telefono_contacto,
    p.poblacion,
    CONCAT(
        r.nombre,
        ' ',
        r.apellido1,
        ' ',
        COALESCE(r.apellido2, '')
    ) AS repartidor,
    CAST(
        p.km_recorridos AS DECIMAL(10, 2)
    ) AS km_recorridos
FROM pedidos AS p
    INNER JOIN repartidores AS r ON p.id_repartidor = r.id_repartidor
WHERE
    p.tipo_pedido = 'Domicilio'
ORDER BY p.km_recorridos DESC;

-- 13. Composición detallada del Menú Clásico
-- WHERE específico, alias legibles
SELECT
    m.codigo_menu,
    m.nombre AS nombre_menu,
    p.codigo_producto,
    p.nombre AS nombre_producto,
    cm.cantidad,
    CAST(p.precio AS DECIMAL(10, 2)) AS precio_producto,
    CAST(m.precio AS DECIMAL(10, 2)) AS precio_total_menu
FROM
    menus AS m
    INNER JOIN composicion_menus AS cm ON m.codigo_menu = cm.codigo_menu
    INNER JOIN productos AS p ON cm.codigo_producto = p.codigo_producto
WHERE
    m.nombre = 'Menú Clásico';

-- 14. Facturación total por repartidor
-- GROUP BY completo, DECIMAL(10,2)
SELECT
    CONCAT(
        r.nombre,
        ' ',
        r.apellido1,
        ' ',
        COALESCE(r.apellido2, '')
    ) AS repartidor,
    COUNT(DISTINCT p.id_pedido) AS total_entregas,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS facturacion_total,
    CAST(
        AVG(totales.total_pedido) AS DECIMAL(10, 2)
    ) AS ticket_medio
FROM
    repartidores AS r
    INNER JOIN pedidos AS p ON r.id_repartidor = p.id_repartidor
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
    INNER JOIN (
        SELECT id_pedido, SUM(cantidad * precio_unitario) AS total_pedido
        FROM lineas_pedido
        GROUP BY
            id_pedido
    ) AS totales ON p.id_pedido = totales.id_pedido
GROUP BY
    r.id_repartidor,
    r.nombre,
    r.apellido1,
    r.apellido2
ORDER BY facturacion_total DESC;

-- 15. Productos más vendidos por cantidad
-- Subconsulta para facturación, TOP 10
SELECT
    p.codigo_producto,
    p.nombre,
    SUM(lp.cantidad) AS unidades_totales,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS facturacion,
    CAST(
        AVG(lp.precio_unitario) AS DECIMAL(10, 2)
    ) AS precio_medio
FROM
    productos AS p
    INNER JOIN lineas_pedido AS lp ON p.codigo_producto = lp.codigo_producto
GROUP BY
    p.codigo_producto,
    p.nombre
ORDER BY unidades_totales DESC
LIMIT 10;

-- 16. Menús más populares
-- Subconsulta para porcentaje total
SELECT
    m.codigo_menu,
    m.nombre,
    SUM(lp.cantidad) AS unidades_vendidas,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS facturacion,
    CAST(
        SUM(lp.cantidad) * 100.0 / COALESCE(
            (
                SELECT SUM(cantidad)
                FROM lineas_pedido
                WHERE
                    codigo_menu IS NOT NULL
            ),
            1
        ) AS DECIMAL(10, 2)
    ) AS porcentaje
FROM menus AS m
    INNER JOIN lineas_pedido AS lp ON m.codigo_menu = lp.codigo_menu
GROUP BY
    m.codigo_menu,
    m.nombre
ORDER BY unidades_vendidas DESC
LIMIT 10;

-- 17. Pedidos por día de la semana
-- DAYNAME para día legible, GROUP BY completo
SELECT
    DAYNAME(p.fecha_hora) AS dia_semana,
    DATE(p.fecha_hora) AS fecha,
    COUNT(DISTINCT p.id_pedido) AS num_pedidos,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS facturacion_total,
    CAST(
        AVG(totales.total_pedido) AS DECIMAL(10, 2)
    ) AS ticket_medio
FROM
    pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
    INNER JOIN (
        SELECT id_pedido, SUM(cantidad * precio_unitario) AS total_pedido
        FROM lineas_pedido
        GROUP BY
            id_pedido
    ) AS totales ON p.id_pedido = totales.id_pedido
GROUP BY
    DAYNAME(p.fecha_hora),
    DATE(p.fecha_hora)
ORDER BY DATE(p.fecha_hora);

-- 18. Ventas por turno de repartidor
-- Comparativa turnos, DECIMAL(10,2)
SELECT
    r.turno,
    COUNT(DISTINCT p.id_pedido) AS num_entregas,
    CAST(
        SUM(p.km_recorridos) AS DECIMAL(10, 2)
    ) AS km_totales,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS facturacion,
    CAST(
        AVG(p.km_recorridos) AS DECIMAL(10, 2)
    ) AS km_promedio_pedido
FROM
    repartidores AS r
    INNER JOIN pedidos AS p ON r.id_repartidor = p.id_repartidor
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
WHERE
    p.tipo_pedido = 'Domicilio'
GROUP BY
    r.turno
ORDER BY r.turno;

-- 19. Productos caros nunca vendidos
-- LEFT JOIN IS NULL para detectar sin ventas
SELECT p.codigo_producto, p.nombre, CAST(p.precio AS DECIMAL(10, 2)) AS precio, 'Sin ventas' AS razon
FROM
    productos AS p
    LEFT JOIN lineas_pedido AS lp ON p.codigo_producto = lp.codigo_producto
WHERE
    p.precio > 5
    AND lp.codigo_producto IS NULL
ORDER BY p.precio DESC;

-- 20. Total facturado por pedido con detalle
-- MAX para detectar menú, CASE legible
SELECT
    p.id_pedido,
    p.fecha_hora,
    p.tipo_pedido,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS total_facturado,
    COUNT(lp.linea) AS num_lineas,
    CASE
        WHEN MAX(lp.codigo_menu) IS NOT NULL THEN 'SÍ'
        ELSE 'NO'
    END AS contiene_menu
FROM pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
GROUP BY
    p.id_pedido,
    p.fecha_hora,
    p.tipo_pedido
ORDER BY total_facturado DESC
LIMIT 20;

-- ============================================================
-- CONSULTAS AGRUPADAS CON FILTROS (21-30)
-- ============================================================

-- 21. Ticket medio por tipo de pedido
-- BONUS: Fechas dinámicas, GROUP BY completo, DECIMAL(10,2)
SELECT
    p.tipo_pedido,
    COUNT(DISTINCT p.id_pedido) AS num_pedidos,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS facturacion_total,
    CAST(
        AVG(totales.total_pedido) AS DECIMAL(10, 2)
    ) AS ticket_medio,
    CAST(
        AVG(lineas.num_lineas) AS DECIMAL(10, 2)
    ) AS lineas_promedio,
    CAST(
        SUM(
            CASE
                WHEN lp.codigo_menu IS NOT NULL THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(lp.linea) AS DECIMAL(10, 2)
    ) AS porcentaje_menus
FROM
    pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
    INNER JOIN (
        SELECT id_pedido, SUM(cantidad * precio_unitario) AS total_pedido
        FROM lineas_pedido
        GROUP BY
            id_pedido
    ) AS totales ON p.id_pedido = totales.id_pedido
    INNER JOIN (
        SELECT id_pedido, COUNT(linea) AS num_lineas
        FROM lineas_pedido
        GROUP BY
            id_pedido
    ) AS lineas ON p.id_pedido = lineas.id_pedido
WHERE
    p.fecha_hora >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY
    p.tipo_pedido;

-- 22. Repartidores con más km recorridos
-- HAVING >10, TOP 8, DECIMAL(10,2)
SELECT
    CONCAT(
        r.nombre,
        ' ',
        r.apellido1,
        ' ',
        COALESCE(r.apellido2, '')
    ) AS repartidor,
    COUNT(DISTINCT p.id_pedido) AS entregas,
    CAST(
        SUM(p.km_recorridos) AS DECIMAL(10, 2)
    ) AS km_totales,
    CAST(
        AVG(p.km_recorridos) AS DECIMAL(10, 2)
    ) AS km_promedio,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) / NULLIF(SUM(p.km_recorridos), 0) AS DECIMAL(10, 2)
    ) AS facturacion_por_km
FROM
    repartidores AS r
    INNER JOIN pedidos AS p ON r.id_repartidor = p.id_repartidor
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
WHERE
    p.tipo_pedido = 'Domicilio'
GROUP BY
    r.id_repartidor,
    r.nombre,
    r.apellido1,
    r.apellido2
HAVING
    entregas > 10
ORDER BY km_totales DESC
LIMIT 8;

-- 23. Horarios más activos (hora del día)
-- HOUR(), fechas dinámicas, CASE tipo dominante
SELECT
    HOUR(p.fecha_hora) AS hora,
    COUNT(DISTINCT p.id_pedido) AS num_pedidos,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS facturacion_total,
    CAST(
        AVG(totales.total_pedido) AS DECIMAL(10, 2)
    ) AS ticket_medio,
    CASE
        WHEN SUM(
            CASE
                WHEN p.tipo_pedido = 'Ventanilla' THEN 1
                ELSE 0
            END
        ) > SUM(
            CASE
                WHEN p.tipo_pedido = 'Domicilio' THEN 1
                ELSE 0
            END
        ) THEN 'Ventanilla'
        ELSE 'Domicilio'
    END AS tipo_dominante
FROM
    pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
    INNER JOIN (
        SELECT id_pedido, SUM(cantidad * precio_unitario) AS total_pedido
        FROM lineas_pedido
        GROUP BY
            id_pedido
    ) AS totales ON p.id_pedido = totales.id_pedido
WHERE
    p.fecha_hora >= DATE_SUB(CURDATE(), INTERVAL 15 DAY)
GROUP BY
    HOUR(p.fecha_hora)
ORDER BY hora;

-- 24. Poblaciones lejanas vs rentables
-- Cálculo margen, DECIMAL(10,2)
SELECT
    p.poblacion,
    COUNT(DISTINCT p.id_pedido) AS num_pedidos,
    CAST(
        AVG(p.km_recorridos) AS DECIMAL(10, 2)
    ) AS km_promedio,
    CAST(
        AVG(totales.total_pedido) AS DECIMAL(10, 2)
    ) AS facturacion_promedio,
    CAST(
        AVG(totales.total_pedido) - (AVG(p.km_recorridos) * 0.3) AS DECIMAL(10, 2)
    ) AS margen
FROM pedidos AS p
    INNER JOIN (
        SELECT id_pedido, SUM(cantidad * precio_unitario) AS total_pedido
        FROM lineas_pedido
        GROUP BY
            id_pedido
    ) AS totales ON p.id_pedido = totales.id_pedido
WHERE
    p.tipo_pedido = 'Domicilio'
GROUP BY
    p.poblacion
ORDER BY margen DESC;

-- 25. Productos estrella por día semana
-- Window function alternativa con subconsulta
SELECT
    dia_semana,
    producto,
    unidades,
    CAST(porcentaje AS DECIMAL(10, 2)) AS porcentaje_ventas
FROM (
        SELECT
            DAYNAME(p.fecha_hora) AS dia_semana, pr.nombre AS producto, SUM(lp.cantidad) AS unidades, SUM(lp.cantidad) * 100.0 / SUM(SUM(lp.cantidad)) OVER (
                PARTITION BY
                    DAYNAME(p.fecha_hora)
            ) AS porcentaje, ROW_NUMBER() OVER (
                PARTITION BY
                    DAYNAME(p.fecha_hora)
                ORDER BY SUM(lp.cantidad) DESC
            ) AS ranking
        FROM
            pedidos AS p
            INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
            INNER JOIN productos AS pr ON lp.codigo_producto = pr.codigo_producto
        WHERE
            lp.codigo_producto IS NOT NULL
        GROUP BY
            DAYNAME(p.fecha_hora), pr.codigo_producto, pr.nombre
    ) AS ranked
WHERE
    ranking = 1
ORDER BY dia_semana;

-- 26. Pedidos con múltiples menús
-- GROUP_CONCAT, HAVING >=2
SELECT
    p.id_pedido,
    p.fecha_hora,
    GROUP_CONCAT(
        DISTINCT m.nombre
        ORDER BY m.nombre SEPARATOR ', '
    ) AS menus_incluidos,
    COUNT(DISTINCT lp.codigo_menu) AS total_menus,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS total_facturado,
    p.tipo_pedido
FROM
    pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
    INNER JOIN menus AS m ON lp.codigo_menu = m.codigo_menu
WHERE
    lp.codigo_menu IS NOT NULL
GROUP BY
    p.id_pedido,
    p.fecha_hora,
    p.tipo_pedido
HAVING
    COUNT(DISTINCT lp.codigo_menu) >= 2
ORDER BY total_menus DESC;

-- 27. Ventanilla vs Domicilio por fecha
-- Tabla comparativa, fechas dinámicas
SELECT
    DATE(p.fecha_hora) AS fecha,
    SUM(
        CASE
            WHEN p.tipo_pedido = 'Ventanilla' THEN 1
            ELSE 0
        END
    ) AS pedidos_ventanilla,
    SUM(
        CASE
            WHEN p.tipo_pedido = 'Domicilio' THEN 1
            ELSE 0
        END
    ) AS pedidos_domicilio,
    CAST(
        SUM(
            CASE
                WHEN p.tipo_pedido = 'Ventanilla' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(DISTINCT p.id_pedido) AS DECIMAL(10, 2)
    ) AS porcentaje_ventanilla,
    CAST(
        SUM(
            CASE
                WHEN p.tipo_pedido = 'Domicilio' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(DISTINCT p.id_pedido) AS DECIMAL(10, 2)
    ) AS porcentaje_domicilio,
    CAST(
        SUM(
            CASE
                WHEN p.tipo_pedido = 'Ventanilla' THEN lp.cantidad * lp.precio_unitario
                ELSE 0
            END
        ) AS DECIMAL(10, 2)
    ) AS facturacion_ventanilla,
    CAST(
        SUM(
            CASE
                WHEN p.tipo_pedido = 'Domicilio' THEN lp.cantidad * lp.precio_unitario
                ELSE 0
            END
        ) AS DECIMAL(10, 2)
    ) AS facturacion_domicilio
FROM pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
WHERE
    p.fecha_hora >= DATE_SUB(CURDATE(), INTERVAL 10 DAY)
GROUP BY
    DATE(p.fecha_hora)
ORDER BY fecha DESC;

-- 28. Repartidores lentos (km/pedido bajo)
-- Subconsulta media general, HAVING <5
SELECT
    CONCAT(
        r.nombre,
        ' ',
        r.apellido1,
        ' ',
        COALESCE(r.apellido2, '')
    ) AS repartidor,
    COUNT(DISTINCT p.id_pedido) AS entregas,
    CAST(
        AVG(p.km_recorridos) AS DECIMAL(10, 2)
    ) AS km_promedio,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS facturacion,
    (
        SELECT CAST(
                AVG(km_recorridos) AS DECIMAL(10, 2)
            )
        FROM pedidos
        WHERE
            tipo_pedido = 'Domicilio'
            AND km_recorridos IS NOT NULL
    ) AS media_general
FROM
    repartidores AS r
    INNER JOIN pedidos AS p ON r.id_repartidor = p.id_repartidor
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
WHERE
    p.tipo_pedido = 'Domicilio'
GROUP BY
    r.id_repartidor,
    r.nombre,
    r.apellido1,
    r.apellido2
HAVING
    AVG(p.km_recorridos) < 5
ORDER BY km_promedio;

-- 29. Menús rentables vs productos sueltos
-- UNION ALL, cálculo margen, COALESCE
SELECT
    'MENU' AS tipo,
    m.codigo_menu AS codigo,
    m.nombre,
    CAST(
        m.precio - COALESCE(
            SUM(p.precio * cm.cantidad),
            0
        ) AS DECIMAL(10, 2)
    ) AS margen,
    CAST(
        (
            m.precio - COALESCE(
                SUM(p.precio * cm.cantidad),
                0
            )
        ) * 100.0 / NULLIF(m.precio, 0) AS DECIMAL(10, 2)
    ) AS margen_porcentaje,
    COALESCE(SUM(lp.cantidad), 0) AS veces_vendido
FROM
    menus AS m
    LEFT JOIN composicion_menus AS cm ON m.codigo_menu = cm.codigo_menu
    LEFT JOIN productos AS p ON cm.codigo_producto = p.codigo_producto
    LEFT JOIN lineas_pedido AS lp ON m.codigo_menu = lp.codigo_menu
GROUP BY
    m.codigo_menu,
    m.nombre,
    m.precio
UNION ALL
SELECT
    'PRODUCTO' AS tipo,
    pr.codigo_producto AS codigo,
    pr.nombre,
    CAST(0 AS DECIMAL(10, 2)) AS margen,
    CAST(0 AS DECIMAL(10, 2)) AS margen_porcentaje,
    COALESCE(SUM(lp.cantidad), 0) AS veces_vendido
FROM
    productos AS pr
    LEFT JOIN lineas_pedido AS lp ON pr.codigo_producto = lp.codigo_producto
GROUP BY
    pr.codigo_producto,
    pr.nombre
ORDER BY tipo, margen DESC;

-- 30. Clientes madrugadores vs noctámbulos
-- CASE segmentación horaria, GROUP BY completo
SELECT
    CASE
        WHEN HOUR(p.fecha_hora) BETWEEN 8 AND 13  THEN 'Mañana (8-14h)'
        WHEN HOUR(p.fecha_hora) BETWEEN 14 AND 19  THEN 'Tarde (14-20h)'
        WHEN HOUR(p.fecha_hora) BETWEEN 20 AND 23  THEN 'Noche (20-24h)'
        ELSE 'Otro'
    END AS segmento_horario,
    COUNT(DISTINCT p.telefono_contacto) AS clientes,
    COUNT(DISTINCT p.id_pedido) AS pedidos_totales,
    CAST(
        AVG(totales.total_pedido) AS DECIMAL(10, 2)
    ) AS ticket_medio,
    CAST(
        COUNT(DISTINCT p.id_pedido) * 1.0 / NULLIF(
            COUNT(DISTINCT p.telefono_contacto),
            0
        ) AS DECIMAL(10, 2)
    ) AS frecuencia_promedio
FROM pedidos AS p
    INNER JOIN (
        SELECT id_pedido, SUM(cantidad * precio_unitario) AS total_pedido
        FROM lineas_pedido
        GROUP BY
            id_pedido
    ) AS totales ON p.id_pedido = totales.id_pedido
WHERE
    p.tipo_pedido = 'Domicilio'
    AND p.telefono_contacto IS NOT NULL
GROUP BY
    segmento_horario
ORDER BY segmento_horario;

-- ============================================================
-- CONSULTAS CON SUBCONSULTAS Y CONDICIONALES (31-40)
-- ============================================================

-- 31. Pedidos por encima de ticket medio
-- BONUS: CTE (WITH), subconsulta media
WITH
    ticket_medio_general AS (
        SELECT CAST(AVG(total) AS DECIMAL(10, 2)) AS ticket_medio
        FROM (
                SELECT SUM(cantidad * precio_unitario) AS total
                FROM lineas_pedido
                GROUP BY
                    id_pedido
            ) AS totales
    )
SELECT
    p.id_pedido,
    p.fecha_hora,
    p.tipo_pedido,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS total,
    CAST(
        (
            SUM(
                lp.cantidad * lp.precio_unitario
            ) - tmg.ticket_medio
        ) * 100.0 / NULLIF(tmg.ticket_medio, 0) AS DECIMAL(10, 2)
    ) AS porcentaje_sobre_media
FROM
    pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
    CROSS JOIN ticket_medio_general AS tmg
GROUP BY
    p.id_pedido,
    p.fecha_hora,
    p.tipo_pedido,
    tmg.ticket_medio
HAVING
    total > tmg.ticket_medio
ORDER BY total DESC;

-- 32. Repartidores por encima de media km
-- CTE para media, HAVING
WITH
    km_medio_general AS (
        SELECT CAST(
                AVG(km_recorridos) AS DECIMAL(10, 2)
            ) AS km_medio
        FROM pedidos
        WHERE
            tipo_pedido = 'Domicilio'
            AND km_recorridos IS NOT NULL
    )
SELECT
    CONCAT(
        r.nombre,
        ' ',
        r.apellido1,
        ' ',
        COALESCE(r.apellido2, '')
    ) AS repartidor,
    CAST(
        AVG(p.km_recorridos) AS DECIMAL(10, 2)
    ) AS km_promedio_personal,
    CAST(
        (
            AVG(p.km_recorridos) - kmg.km_medio
        ) * 100.0 / NULLIF(kmg.km_medio, 0) AS DECIMAL(10, 2)
    ) AS porcentaje_sobre_media,
    COUNT(DISTINCT p.id_pedido) AS total_entregas
FROM
    repartidores AS r
    INNER JOIN pedidos AS p ON r.id_repartidor = p.id_repartidor
    CROSS JOIN km_medio_general AS kmg
WHERE
    p.tipo_pedido = 'Domicilio'
GROUP BY
    r.id_repartidor,
    r.nombre,
    r.apellido1,
    r.apellido2,
    kmg.km_medio
HAVING
    AVG(p.km_recorridos) > kmg.km_medio
ORDER BY km_promedio_personal DESC;

-- 33. Productos de menús muy vendidos
-- HAVING >5, INNER JOIN
SELECT
    p.codigo_producto,
    p.nombre AS producto,
    m.nombre AS menu,
    COUNT(DISTINCT lp.id_pedido) AS veces_vendido_menu,
    CAST(p.precio AS DECIMAL(10, 2)) AS precio
FROM
    productos AS p
    INNER JOIN composicion_menus AS cm ON p.codigo_producto = cm.codigo_producto
    INNER JOIN menus AS m ON cm.codigo_menu = m.codigo_menu
    INNER JOIN lineas_pedido AS lp ON m.codigo_menu = lp.codigo_menu
GROUP BY
    p.codigo_producto,
    p.nombre,
    m.codigo_menu,
    m.nombre,
    p.precio
HAVING
    COUNT(DISTINCT lp.id_pedido) > 5
ORDER BY veces_vendido_menu DESC;

-- 34. Pedidos "perfectos" con menú
-- BONUS: EXISTS para subconsulta eficiente
SELECT
    p.id_pedido,
    (
        SELECT m.nombre
        FROM lineas_pedido AS lp2
            INNER JOIN menus AS m ON lp2.codigo_menu = m.codigo_menu
        WHERE
            lp2.id_pedido = p.id_pedido
        LIMIT 1
    ) AS menu_usado,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS total_facturado,
    p.tipo_pedido
FROM pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
WHERE
    EXISTS (
        SELECT 1
        FROM lineas_pedido AS lp_check
        WHERE
            lp_check.id_pedido = p.id_pedido
        GROUP BY
            lp_check.id_pedido
        HAVING
            SUM(
                CASE
                    WHEN lp_check.codigo_menu IS NOT NULL THEN 1
                    ELSE 0
                END
            ) = 1
    )
GROUP BY
    p.id_pedido,
    p.tipo_pedido
LIMIT 20;

-- 35. Zonas con reparto caro
-- HAVING km >100, DECIMAL(10,2)
SELECT
    p.poblacion,
    COUNT(DISTINCT p.id_pedido) AS entregas,
    CAST(
        SUM(p.km_recorridos) AS DECIMAL(10, 2)
    ) AS km_totales,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS facturacion,
    CAST(
        SUM(p.km_recorridos) * 0.3 AS DECIMAL(10, 2)
    ) AS coste_estimado
FROM pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
WHERE
    p.tipo_pedido = 'Domicilio'
GROUP BY
    p.poblacion
HAVING
    SUM(p.km_recorridos) > 100
ORDER BY km_totales DESC;

-- 36. Productos "solitarios"
-- Subconsulta para pedidos 1 línea
SELECT
    p.codigo_producto,
    p.nombre,
    COUNT(DISTINCT lp.id_pedido) AS veces_vendido_solo,
    CAST(
        AVG(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS ticket_medio,
    CAST(
        COUNT(
            DISTINCT CASE
                WHEN total_lineas.num = 1 THEN lp.id_pedido
            END
        ) * 100.0 / NULLIF(
            COUNT(DISTINCT lp.id_pedido),
            0
        ) AS DECIMAL(10, 2)
    ) AS porcentaje_solitario
FROM
    productos AS p
    INNER JOIN lineas_pedido AS lp ON p.codigo_producto = lp.codigo_producto
    INNER JOIN (
        SELECT id_pedido, COUNT(linea) AS num
        FROM lineas_pedido
        GROUP BY
            id_pedido
    ) AS total_lineas ON lp.id_pedido = total_lineas.id_pedido
WHERE
    total_lineas.num = 1
GROUP BY
    p.codigo_producto,
    p.nombre
ORDER BY veces_vendido_solo DESC;

-- 37. Días récord de facturación
-- BONUS: Window function LAG para comparativa
WITH
    facturacion_diaria AS (
        SELECT
            DATE(p.fecha_hora) AS fecha,
            CAST(
                SUM(
                    lp.cantidad * lp.precio_unitario
                ) AS DECIMAL(10, 2)
            ) AS facturacion,
            COUNT(DISTINCT p.id_pedido) AS pedidos,
            CAST(
                AVG(totales.total_pedido) AS DECIMAL(10, 2)
            ) AS ticket_medio,
            CASE
                WHEN SUM(
                    CASE
                        WHEN p.tipo_pedido = 'Ventanilla' THEN 1
                        ELSE 0
                    END
                ) > SUM(
                    CASE
                        WHEN p.tipo_pedido = 'Domicilio' THEN 1
                        ELSE 0
                    END
                ) THEN 'Ventanilla'
                ELSE 'Domicilio'
            END AS tipo_dominante
        FROM
            pedidos AS p
            INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
            INNER JOIN (
                SELECT id_pedido, SUM(cantidad * precio_unitario) AS total_pedido
                FROM lineas_pedido
                GROUP BY
                    id_pedido
            ) AS totales ON p.id_pedido = totales.id_pedido
        GROUP BY
            DATE(p.fecha_hora)
    )
SELECT
    fecha,
    facturacion,
    pedidos,
    ticket_medio,
    tipo_dominante,
    (
        SELECT CAST(
                AVG(facturacion) AS DECIMAL(10, 2)
            )
        FROM facturacion_diaria
    ) AS media_diaria
FROM facturacion_diaria
ORDER BY facturacion DESC
LIMIT 5;

-- 38. Repartidores especialistas
-- Window function RANK, porcentaje >70%
WITH
    entregas_por_producto AS (
        SELECT
            r.id_repartidor,
            CONCAT(
                r.nombre,
                ' ',
                r.apellido1,
                ' ',
                COALESCE(r.apellido2, '')
            ) AS repartidor,
            pr.codigo_producto,
            pr.nombre AS producto,
            COUNT(DISTINCT p.id_pedido) AS entregas_producto,
            CAST(
                SUM(
                    lp.cantidad * lp.precio_unitario
                ) AS DECIMAL(10, 2)
            ) AS facturacion_producto
        FROM
            repartidores AS r
            INNER JOIN pedidos AS p ON r.id_repartidor = p.id_repartidor
            INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
            INNER JOIN productos AS pr ON lp.codigo_producto = pr.codigo_producto
        WHERE
            lp.codigo_producto IS NOT NULL
        GROUP BY
            r.id_repartidor,
            r.nombre,
            r.apellido1,
            r.apellido2,
            pr.codigo_producto,
            pr.nombre
    ),
    total_por_repartidor AS (
        SELECT id_repartidor, SUM(entregas_producto) AS total_entregas
        FROM entregas_por_producto
        GROUP BY
            id_repartidor
    )
SELECT
    epp.repartidor,
    epp.producto AS producto_dominante,
    CAST(
        epp.entregas_producto * 100.0 / NULLIF(tpr.total_entregas, 0) AS DECIMAL(10, 2)
    ) AS porcentaje_especializacion,
    epp.facturacion_producto
FROM
    entregas_por_producto AS epp
    INNER JOIN total_por_repartidor AS tpr ON epp.id_repartidor = tpr.id_repartidor
WHERE
    epp.entregas_producto * 100.0 / NULLIF(tpr.total_entregas, 0) > 70
ORDER BY porcentaje_especializacion DESC;

-- 39. Pedidos "familiares" grandes
-- HAVING >4 líneas OR >6 unidades
SELECT
    p.id_pedido,
    p.fecha_hora,
    COUNT(lp.linea) AS num_lineas,
    SUM(lp.cantidad) AS unidades_totales,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS total_facturado,
    p.tipo_pedido
FROM pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
GROUP BY
    p.id_pedido,
    p.fecha_hora,
    p.tipo_pedido
HAVING
    COUNT(lp.linea) > 4
    OR SUM(lp.cantidad) > 6
ORDER BY unidades_totales DESC;

-- 40. Comparativa rendimiento mensual
-- BONUS: Window function LAG para crecimiento %
SELECT
    DATE_FORMAT(p.fecha_hora, '%Y-%m') AS mes,
    CAST(
        SUM(
            lp.cantidad * lp.precio_unitario
        ) AS DECIMAL(10, 2)
    ) AS facturacion,
    COUNT(DISTINCT p.id_pedido) AS pedidos,
    CAST(
        AVG(totales.total_pedido) AS DECIMAL(10, 2)
    ) AS ticket_medio,
    CAST(
        (
            SUM(
                lp.cantidad * lp.precio_unitario
            ) - LAG(
                SUM(
                    lp.cantidad * lp.precio_unitario
                )
            ) OVER (
                ORDER BY DATE_FORMAT(p.fecha_hora, '%Y-%m')
            )
        ) * 100.0 / NULLIF(
            LAG(
                SUM(
                    lp.cantidad * lp.precio_unitario
                )
            ) OVER (
                ORDER BY DATE_FORMAT(p.fecha_hora, '%Y-%m')
            ),
            0
        ) AS DECIMAL(10, 2)
    ) AS crecimiento_porcentaje
FROM
    pedidos AS p
    INNER JOIN lineas_pedido AS lp ON p.id_pedido = lp.id_pedido
    INNER JOIN (
        SELECT id_pedido, SUM(cantidad * precio_unitario) AS total_pedido
        FROM lineas_pedido
        GROUP BY
            id_pedido
    ) AS totales ON p.id_pedido = totales.id_pedido
GROUP BY
    DATE_FORMAT(p.fecha_hora, '%Y-%m')
ORDER BY mes;

-- ============================================================
-- FIN DE LAS 40 CONSULTAS OPTIMIZADAS
-- ============================================================