-- 1. REPARTIDORES (5 registros)
INSERT INTO
    repartidores
VALUES (
        1,
        'Juan',
        'Pérez',
        'García',
        '12345678A',
        '600123456',
        '4567ABC',
        'Mañana'
    ),
    (
        2,
        'María',
        'López',
        'Martín',
        '87654321B',
        '600987654',
        '7890DEF',
        'Tarde'
    ),
    (
        3,
        'Carlos',
        'García',
        'Rodríguez',
        '11112222C',
        '600111222',
        '1234GHI',
        'Noche'
    ),
    (
        4,
        'Ana',
        'Sánchez',
        'Fernández',
        '33334444D',
        '600333444',
        '5678JKL',
        'Mañana'
    ),
    (
        5,
        'Pedro',
        'Martín',
        'López',
        '55556666E',
        '600555666',
        '9012MNO',
        'Tarde'
    );
-- 2. PRODUCTOS (8 registros)
INSERT INTO
    productos
VALUES (
        'P001',
        'Hamburguesa Simple',
        'Carne, pan, lechuga',
        3.50
    ),
    (
        'P002',
        'Hamburguesa Doble',
        'Carne doble, queso, pan',
        5.00
    ),
    (
        'P003',
        'Coca-Cola Pequeña',
        'Bebida gaseosa 33cl',
        1.50
    ),
    (
        'P004',
        'Coca-Cola Grande',
        'Bebida gaseosa 50cl',
        2.00
    ),
    (
        'P005',
        'Ensalada Mixta',
        'Lechuga, tomate, zanahoria',
        4.00
    ),
    (
        'P006',
        'Patatas Fritas',
        'Patatas crujientes',
        2.50
    ),
    (
        'P007',
        'Hamburguesa Alemana',
        'Carne, salchicha, mostaza',
        6.00
    ),
    (
        'P008',
        'Postre Chocolate',
        'Tarta de chocolate',
        3.00
    );
-- 3. MENUS (4 registros)
INSERT INTO
    menus
VALUES (
        'M001',
        'Menú Niño',
        'Hamburguesa simple + refresco pequeño',
        5.50
    ),
    (
        'M002',
        'Menú Clásico',
        'Hamburguesa doble + patatas + refresco',
        9.50
    ),
    (
        'M003',
        'Menú Salud',
        'Ensalada + refresco grande',
        6.50
    ),
    (
        'M004',
        'Menú Familiar',
        '2 hamburguesas + 2 refrescos + postre',
        15.00
    );
-- 4. COMPOSICION_MENUS (relación N:M productos-menús, 8 registros)
INSERT INTO
    composicion_menus
VALUES ('M001', 'P001', 1),
    ('M001', 'P003', 1),
    ('M002', 'P002', 1),
    ('M002', 'P006', 1),
    ('M002', 'P004', 1),
    ('M003', 'P005', 1),
    ('M003', 'P004', 1),
    ('M004', 'P001', 2);
-- 5. PEDIDOS (10 registros)
INSERT INTO
    pedidos
VALUES (
        1,
        '2026-01-10 12:30:00',
        1,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        1
    ), -- Ventanilla
    (
        2,
        '2026-01-10 13:15:00',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        1
    ),
    (
        3,
        '2026-01-10 20:45:00',
        NULL,
        '600999888',
        'Cádiz',
        'Calle Real 123',
        1,
        15,
        2
    ), -- Domicilio
    (
        4,
        '2026-01-11 09:20:00',
        3,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        1
    ),
    (
        5,
        '2026-01-11 18:30:00',
        NULL,
        '655444333',
        'Jerez',
        'Avenida Sevilla 45',
        2,
        10,
        2
    ),
    (
        6,
        '2026-01-12 14:00:00',
        2,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        1
    ),
    (
        7,
        '2026-01-12 22:10:00',
        NULL,
        '699877766',
        'El Puerto',
        'Plaza España 7',
        3,
        20,
        2
    ),
    (
        8,
        '2026-01-13 11:45:00',
        4,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        1
    ),
    (
        9,
        '2026-01-13 19:55:00',
        NULL,
        '622211100',
        'San Fernando',
        'Calle Mayor 89',
        4,
        12,
        2
    ),
    (
        10,
        '2026-01-14 16:20:00',
        NULL,
        '688877766',
        'Chiclana',
        'Paseo Marítimo 12',
        5,
        18,
        2
    );
-- 6. LINEAS_PEDIDO (30 registros de ejemplo para pedidos)
INSERT INTO
    lineas_pedido
VALUES (1, 1, 'P001', 2, 3.50),
    (1, 2, 'M001', 1, 5.50),
    (2, 1, 'P002', 1, 5.00),
    (2, 2, 'P006', 1, 2.50),
    (3, 1, 'M002', 2, 9.50),
    (4, 1, 'P003', 3, 1.50),
    (5, 1, 'P007', 1, 6.00),
    (5, 2, 'P008', 1, 3.00),
    (6, 1, 'M003', 1, 6.50),
    (7, 1, 'P004', 4, 2.00),
    (3, 3, 'P005', NULL, 1, 4.00),
    (4, 1, 'P003', NULL, 3, 1.50),
    (4, 2, 'P006', NULL, 2, 2.50),
    (4, 3, 'P008', NULL, 1, 3.00),
    (4, 4, NULL, 'M003', 1, 6.50),
    (5, 1, 'P007', NULL, 1, 6.00),
    (5, 2, 'P008', NULL, 1, 3.00),
    (5, 3, NULL, 'M001', 1, 5.50),
    (5, 4, 'P002', NULL, 1, 5.00),
    (6, 1, NULL, 'M003', 1, 6.50),
    (6, 2, 'P003', NULL, 2, 1.50),
    (6, 3, 'P006', NULL, 1, 2.50),
    (7, 1, 'P004', NULL, 4, 2.00),
    (7, 2, 'P002', NULL, 2, 5.00),
    (7, 3, 'P006', NULL, 3, 2.50),
    (7, 4, NULL, 'M001', 1, 5.50),
    (8, 1, 'P001', NULL, 1, 3.50),
    (8, 2, 'P005', NULL, 1, 4.00),
    (8, 3, 'P004', NULL, 1, 2.00),
    (8, 4, NULL, 'M002', 1, 9.50);