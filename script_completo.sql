-- ============================================================
-- BASE DE DATOS: Mc Ilerna Albor Croft
-- DESCRIPCIÓN: Sistema de gestión de pedidos para restaurante
-- VERSIÓN: 2.0 (con normalización de ingredientes a 3FN)
-- TABLAS: 11 (antes 9)
-- FECHA: 21 de enero de 2026
-- ============================================================

-- Eliminar base de datos si existe
DROP DATABASE IF EXISTS McIlerna_Albor_Croft;

-- Crear base de datos con charset UTF-8
CREATE DATABASE McIlerna_Albor_Croft
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

-- Seleccionar la base de datos
USE McIlerna_Albor_Croft;

-- ============================================================
-- TABLAS MAESTRAS
-- ============================================================

-- ============================================================
-- TABLA: REPARTIDOR
-- DESCRIPCIÓN: Empleados repartidores con turnos asignados
-- ============================================================

CREATE TABLE REPARTIDOR (
    Num_Repartidor INT AUTO_INCREMENT,
    Nombre VARCHAR(50) NOT NULL,
    Apellido1 VARCHAR(50) NOT NULL,
    Apellido2 VARCHAR(50),
    DNI VARCHAR(9) NOT NULL,
    Telefono VARCHAR(15),
    Matricula_Moto VARCHAR(10),
    Turno CHAR(1) NOT NULL,
    
    CONSTRAINT PK_Repartidor PRIMARY KEY (Num_Repartidor),
    CONSTRAINT UK_Repartidor_DNI UNIQUE (DNI),
    CONSTRAINT CHK_Repartidor_Turno CHECK (Turno IN ('M', 'T', 'N'))
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Empleados repartidores con turnos asignados';

-- ============================================================
-- TABLA: INGREDIENTE (NUEVA)
-- DESCRIPCIÓN: Catálogo de ingredientes con información de alérgenos
-- ============================================================

CREATE TABLE INGREDIENTE (
    Cod_Ingrediente INT AUTO_INCREMENT,
    Nombre VARCHAR(100) NOT NULL,
    Alergeno BOOLEAN NOT NULL DEFAULT FALSE,
    Tipo_Alergeno VARCHAR(50),
    
    CONSTRAINT PK_Ingrediente PRIMARY KEY (Cod_Ingrediente),
    CONSTRAINT UK_Ingrediente_Nombre UNIQUE (Nombre)
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Catálogo de ingredientes con información de alérgenos';

-- ============================================================
-- TABLA: PRODUCTO (MODIFICADA - sin campo Ingredientes)
-- DESCRIPCIÓN: Productos individuales del catálogo
-- ============================================================

CREATE TABLE PRODUCTO (
    Cod_Producto INT AUTO_INCREMENT,
    Nombre VARCHAR(100) NOT NULL,
    Precio DECIMAL(6,2) NOT NULL,
    
    CONSTRAINT PK_Producto PRIMARY KEY (Cod_Producto),
    CONSTRAINT CHK_Producto_Precio CHECK (Precio > 0)
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Productos individuales del catálogo';

-- ============================================================
-- TABLA: MENU
-- DESCRIPCIÓN: Menús promocionales con precio especial
-- ============================================================

CREATE TABLE MENU (
    Cod_Menu INT AUTO_INCREMENT,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion TEXT,
    Precio DECIMAL(6,2) NOT NULL,
    
    CONSTRAINT PK_Menu PRIMARY KEY (Cod_Menu),
    CONSTRAINT CHK_Menu_Precio CHECK (Precio > 0)
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Menús promocionales con precio especial';

-- ============================================================
-- TABLAS DE PEDIDOS
-- ============================================================

-- ============================================================
-- TABLA: PEDIDO
-- DESCRIPCIÓN: Tabla base con numeración correlativa única
-- ============================================================

CREATE TABLE PEDIDO (
    Num_Pedido INT AUTO_INCREMENT,
    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,
    
    CONSTRAINT PK_Pedido PRIMARY KEY (Num_Pedido)
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Tabla base con numeración correlativa única';

-- ============================================================
-- TABLA: PEDIDO_VENTANILLA
-- DESCRIPCIÓN: Pedidos en ventanilla (extensión 1:1)
-- ============================================================

CREATE TABLE PEDIDO_VENTANILLA (
    Num_Pedido INT,
    Num_Ventanilla INT NOT NULL,
    
    CONSTRAINT PK_Pedido_Ventanilla PRIMARY KEY (Num_Pedido),
    CONSTRAINT FK_PedidoVentanilla_Pedido 
        FOREIGN KEY (Num_Pedido) 
        REFERENCES PEDIDO(Num_Pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Pedidos en ventanilla (extensión 1:1)';

-- ============================================================
-- TABLA: PEDIDO_DOMICILIO
-- DESCRIPCIÓN: Pedidos a domicilio (extensión 1:1)
-- ============================================================

CREATE TABLE PEDIDO_DOMICILIO (
    Num_Pedido INT,
    Telefono_Contacto VARCHAR(15) NOT NULL,
    Poblacion VARCHAR(100) NOT NULL,
    Direccion_Entrega VARCHAR(200) NOT NULL,
    Num_Repartidor INT NOT NULL,
    
    CONSTRAINT PK_Pedido_Domicilio PRIMARY KEY (Num_Pedido),
    CONSTRAINT FK_PedidoDomicilio_Pedido 
        FOREIGN KEY (Num_Pedido) 
        REFERENCES PEDIDO(Num_Pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_PedidoDomicilio_Repartidor 
        FOREIGN KEY (Num_Repartidor) 
        REFERENCES REPARTIDOR(Num_Repartidor)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Pedidos a domicilio (extensión 1:1)';

-- ============================================================
-- TABLAS DE RELACIÓN (N:M)
-- ============================================================

-- ============================================================
-- TABLA: PRODUCTO_INGREDIENTE (NUEVA)
-- DESCRIPCIÓN: Relación N:M entre PRODUCTO e INGREDIENTE
-- ============================================================

CREATE TABLE PRODUCTO_INGREDIENTE (
    Cod_Producto INT,
    Cod_Ingrediente INT,
    
    CONSTRAINT PK_Producto_Ingrediente PRIMARY KEY (Cod_Producto, Cod_Ingrediente),
    CONSTRAINT FK_ProductoIngrediente_Producto 
        FOREIGN KEY (Cod_Producto) 
        REFERENCES PRODUCTO(Cod_Producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_ProductoIngrediente_Ingrediente 
        FOREIGN KEY (Cod_Ingrediente) 
        REFERENCES INGREDIENTE(Cod_Ingrediente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Define qué ingredientes componen cada producto';

-- ============================================================
-- TABLA: COMPOSICION_MENU
-- DESCRIPCIÓN: Relación N:M entre MENU y PRODUCTO
-- ============================================================

CREATE TABLE COMPOSICION_MENU (
    Cod_Menu INT,
    Cod_Producto INT,
    Cantidad INT NOT NULL,
    
    CONSTRAINT PK_Composicion_Menu PRIMARY KEY (Cod_Menu, Cod_Producto),
    CONSTRAINT FK_ComposicionMenu_Menu 
        FOREIGN KEY (Cod_Menu) 
        REFERENCES MENU(Cod_Menu)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_ComposicionMenu_Producto 
        FOREIGN KEY (Cod_Producto) 
        REFERENCES PRODUCTO(Cod_Producto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT CHK_ComposicionMenu_Cantidad CHECK (Cantidad > 0)
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Define qué productos componen cada menú';

-- ============================================================
-- TABLA: DETALLE_PEDIDO_PRODUCTO
-- DESCRIPCIÓN: Líneas de pedido para productos individuales
-- ============================================================

CREATE TABLE DETALLE_PEDIDO_PRODUCTO (
    Num_Pedido INT,
    Cod_Producto INT,
    Cantidad INT NOT NULL,
    Precio_Venta DECIMAL(6,2) NOT NULL,
    
    CONSTRAINT PK_Detalle_Pedido_Producto PRIMARY KEY (Num_Pedido, Cod_Producto),
    CONSTRAINT FK_DetallePedidoProducto_Pedido 
        FOREIGN KEY (Num_Pedido) 
        REFERENCES PEDIDO(Num_Pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_DetallePedidoProducto_Producto 
        FOREIGN KEY (Cod_Producto) 
        REFERENCES PRODUCTO(Cod_Producto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT CHK_DetallePedidoProducto_Cantidad CHECK (Cantidad > 0),
    CONSTRAINT CHK_DetallePedidoProducto_Precio CHECK (Precio_Venta > 0)
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Productos individuales incluidos en cada pedido';

-- ============================================================
-- TABLA: DETALLE_PEDIDO_MENU
-- DESCRIPCIÓN: Líneas de pedido para menús
-- ============================================================

CREATE TABLE DETALLE_PEDIDO_MENU (
    Num_Pedido INT,
    Cod_Menu INT,
    Cantidad INT NOT NULL,
    Precio_Venta DECIMAL(6,2) NOT NULL,
    
    CONSTRAINT PK_Detalle_Pedido_Menu PRIMARY KEY (Num_Pedido, Cod_Menu),
    CONSTRAINT FK_DetallePedidoMenu_Pedido 
        FOREIGN KEY (Num_Pedido) 
        REFERENCES PEDIDO(Num_Pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_DetallePedidoMenu_Menu 
        FOREIGN KEY (Cod_Menu) 
        REFERENCES MENU(Cod_Menu)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT CHK_DetallePedidoMenu_Cantidad CHECK (Cantidad > 0),
    CONSTRAINT CHK_DetallePedidoMenu_Precio CHECK (Precio_Venta > 0)
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Menús incluidos en cada pedido';

-- ============================================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- ============================================================

-- Índice para consultas por fecha
CREATE INDEX idx_pedido_fecha ON PEDIDO(Fecha);

-- Índice para consultas por repartidor
CREATE INDEX idx_pedido_domicilio_repartidor 
    ON PEDIDO_DOMICILIO(Num_Repartidor);

-- Índice para búsqueda de productos
CREATE INDEX idx_producto_nombre ON PRODUCTO(Nombre);

-- Índice compuesto para estadísticas
CREATE INDEX idx_pedido_fecha_hora ON PEDIDO(Fecha, Hora);

-- ============================================================
-- RESUMEN DE LA BASE DE DATOS
-- ============================================================

/*
TOTAL DE TABLAS: 11

TABLAS MAESTRAS (4):
  1. REPARTIDOR
  2. INGREDIENTE (NUEVA)
  3. PRODUCTO (MODIFICADA - sin campo Ingredientes)
  4. MENU

TABLAS DE PEDIDOS (3):
  5. PEDIDO
  6. PEDIDO_VENTANILLA
  7. PEDIDO_DOMICILIO

TABLAS DE RELACIÓN N:M (4):
  8. PRODUCTO_INGREDIENTE (NUEVA)
  9. COMPOSICION_MENU
  10. DETALLE_PEDIDO_PRODUCTO
  11. DETALLE_PEDIDO_MENU

CARACTERÍSTICAS TÉCNICAS:
  - Motor: InnoDB (soporte transaccional ACID)
  - Charset: UTF-8 (utf8mb4_unicode_ci)
  - Normalización: Tercera Forma Normal (3FN)
  - Claves primarias: 11 (7 simples + 4 compuestas)
  - Claves foráneas: 11
  - Restricciones CHECK: 9
  - Restricciones UNIQUE: 2
  - Índices adicionales: 4