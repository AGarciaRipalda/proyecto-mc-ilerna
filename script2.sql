-- 1. Eliminar base de datos si existe y crear nueva
DROP DATABASE IF EXISTS mc_ilerna;

CREATE DATABASE mc_ilerna CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE mc_ilerna;

-- 2. Tabla REPARTIDORES
CREATE TABLE repartidores (
    id_repartidor INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    apellido1 VARCHAR(50) NOT NULL,
    apellido2 VARCHAR(50),
    dni CHAR(9) UNIQUE NOT NULL,
    telefono VARCHAR(12) NOT NULL,
    matricula_moto CHAR(8) UNIQUE NOT NULL,
    turno ENUM('Manana', 'Tarde', 'Noche') NOT NULL
);
-- 3. Tabla PRODUCTOS
CREATE TABLE productos (
    codigo_producto CHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ingredientes TEXT,
    precio DECIMAL(6, 2) NOT NULL CHECK (precio > 0)
);
-- 4. Tabla MENUS
CREATE TABLE menus (
    codigo_menu CHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(6, 2) NOT NULL CHECK (precio > 0)
);
-- 5. Tabla COMPOSICION_MENUS (N:M)
CREATE TABLE composicion_menus (
    codigo_menu CHAR(10),
    codigo_producto CHAR(10),
    cantidad INT DEFAULT 1 CHECK (cantidad > 0),
    PRIMARY KEY (codigo_menu, codigo_producto),
    FOREIGN KEY (codigo_menu) REFERENCES menus (codigo_menu) ON DELETE CASCADE,
    FOREIGN KEY (codigo_producto) REFERENCES productos (codigo_producto) ON DELETE CASCADE
);
-- 6. Tabla PEDIDOS
-- Nota: num_ventanilla es NULL para domicilio
-- telefono_contacto, poblacion, direccion_entrega, id_repartidor, km_recorridos son NULL para ventanilla
CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    fecha_hora DATETIME NOT NULL,
    num_ventanilla INT CHECK (
        num_ventanilla >= 1
        AND num_ventanilla <= 10
    ),
    telefono_contacto VARCHAR(12),
    poblacion VARCHAR(100),
    direccion_entrega TEXT,
    id_repartidor INT,
    km_recorridos DECIMAL(5, 2),
    tipo_pedido ENUM('Ventanilla', 'Domicilio') NOT NULL,
    FOREIGN KEY (id_repartidor) REFERENCES repartidores (id_repartidor)
);
-- 7. Tabla LINEAS_PEDIDO
-- Nota: codigo_menu es NULL si es producto suelto, codigo_producto es NULL si es menu
CREATE TABLE lineas_pedido (
    id_pedido INT,
    linea INT,
    codigo_producto CHAR(10),
    codigo_menu CHAR(10),
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(6, 2) NOT NULL,
    PRIMARY KEY (id_pedido, linea),
    FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (codigo_producto) REFERENCES productos (codigo_producto),
    FOREIGN KEY (codigo_menu) REFERENCES menus (codigo_menu)
);