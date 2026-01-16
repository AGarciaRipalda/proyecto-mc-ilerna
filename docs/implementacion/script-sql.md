# Script SQL de Implementación

Este documento contiene el **código DDL completo** para la creación de la base de datos **Mc Ilerna Albor Croft**. El script está diseñado para MySQL/MariaDB con motor InnoDB.

---

## Creación de la Base de Datos

```sql
-- ============================================================
-- PROYECTO: Sistema de Gestión de Pedidos Mc Ilerna Albor Croft
-- AUTOR: Juan Sevillano - Albor Croft ASIR
-- FECHA: Enero 2026
-- DESCRIPCIÓN: Script DDL completo para creación de base de datos
-- ============================================================

-- Eliminar base de datos si existe (PRECAUCIÓN: solo en desarrollo)
DROP DATABASE IF EXISTS McIlerna_Albor_Croft;

-- Crear base de datos con charset UTF-8
CREATE DATABASE McIlerna_Albor_Croft
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

-- Seleccionar la base de datos
USE McIlerna_Albor_Croft;
```

---

## Tablas Maestras

### Tabla: REPARTIDOR

```sql
-- ============================================================
-- TABLA: REPARTIDOR
-- DESCRIPCIÓN: Almacena información de empleados repartidores
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
    
    -- Restricciones
    CONSTRAINT PK_Repartidor PRIMARY KEY (Num_Repartidor),
    CONSTRAINT UK_Repartidor_DNI UNIQUE (DNI),
    CONSTRAINT CHK_Repartidor_Turno CHECK (Turno IN ('M', 'T', 'N'))
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Empleados repartidores con turnos asignados';
```

**Comentarios:**
- `Num_Repartidor`: Clave primaria autoincremental
- `DNI`: Clave alternativa única para evitar duplicados
- `Turno`: M=Mañana, T=Tarde, N=Noche (validado con CHECK)

---

### Tabla: PRODUCTO

```sql
-- ============================================================
-- TABLA: PRODUCTO
-- DESCRIPCIÓN: Catálogo de productos individuales
-- ============================================================

CREATE TABLE PRODUCTO (
    Cod_Producto INT AUTO_INCREMENT,
    Nombre VARCHAR(100) NOT NULL,
    Ingredientes TEXT,
    Precio DECIMAL(6,2) NOT NULL,
    
    -- Restricciones
    CONSTRAINT PK_Producto PRIMARY KEY (Cod_Producto),
    CONSTRAINT CHK_Producto_Precio CHECK (Precio > 0)
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Productos individuales del catálogo';
```

**Comentarios:**
- `Ingredientes`: Texto libre para gestión de alérgenos
- `Precio`: DECIMAL(6,2) permite precios hasta 9999.99€

---

### Tabla: MENU

```sql
-- ============================================================
-- TABLA: MENU
-- DESCRIPCIÓN: Menús compuestos con precio promocional
-- ============================================================

CREATE TABLE MENU (
    Cod_Menu INT AUTO_INCREMENT,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion TEXT,
    Precio DECIMAL(6,2) NOT NULL,
    
    -- Restricciones
    CONSTRAINT PK_Menu PRIMARY KEY (Cod_Menu),
    CONSTRAINT CHK_Menu_Precio CHECK (Precio > 0)
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Menús promocionales con precio especial';
```

---

## Tablas de Pedidos (Jerarquía con Extensiones)

### Tabla Base: PEDIDO

```sql
-- ============================================================
-- TABLA: PEDIDO
-- DESCRIPCIÓN: Tabla base para todos los pedidos (ventanilla y domicilio)
-- ============================================================

CREATE TABLE PEDIDO (
    Num_Pedido INT AUTO_INCREMENT,
    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,
    
    -- Restricciones
    CONSTRAINT PK_Pedido PRIMARY KEY (Num_Pedido)
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Tabla base con numeración correlativa única de pedidos';
```

**Comentarios:**
- Numeración correlativa única para ventanilla y domicilio
- Las extensiones se definen en tablas separadas (1:1)

---

### Extensión: PEDIDO_VENTANILLA

```sql
-- ============================================================
-- TABLA: PEDIDO_VENTANILLA
-- DESCRIPCIÓN: Extensión de PEDIDO para pedidos en ventanilla
-- ============================================================

CREATE TABLE PEDIDO_VENTANILLA (
    Num_Pedido INT,
    Num_Ventanilla INT NOT NULL,
    
    -- Restricciones
    CONSTRAINT PK_Pedido_Ventanilla PRIMARY KEY (Num_Pedido),
    CONSTRAINT FK_PedidoVentanilla_Pedido 
        FOREIGN KEY (Num_Pedido) 
        REFERENCES PEDIDO(Num_Pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Pedidos realizados en ventanilla (extensión 1:1 de PEDIDO)';
```

**Comentarios:**
- `ON DELETE CASCADE`: Al eliminar un pedido base, se elimina automáticamente su extensión
- Relación 1:1 con PEDIDO (un pedido solo puede ser de ventanilla O de domicilio)

---

### Extensión: PEDIDO_DOMICILIO

```sql
-- ============================================================
-- TABLA: PEDIDO_DOMICILIO
-- DESCRIPCIÓN: Extensión de PEDIDO para pedidos a domicilio
-- ============================================================

CREATE TABLE PEDIDO_DOMICILIO (
    Num_Pedido INT,
    Telefono_Contacto VARCHAR(15) NOT NULL,
    Poblacion VARCHAR(100) NOT NULL,
    Direccion_Entrega VARCHAR(200) NOT NULL,
    Num_Repartidor INT NOT NULL,
    
    -- Restricciones
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
  COMMENT='Pedidos con entrega a domicilio (extensión 1:1 de PEDIDO)';
```

**Comentarios:**
- `ON DELETE RESTRICT` en Repartidor: No se puede eliminar un repartidor con pedidos asignados
- Relación N:1 con REPARTIDOR (un repartidor puede tener múltiples pedidos)

---

## Tablas de Relación (N:M)

### COMPOSICION_MENU

```sql
-- ============================================================
-- TABLA: COMPOSICION_MENU
-- DESCRIPCIÓN: Relación N:M entre MENU y PRODUCTO
-- ============================================================

CREATE TABLE COMPOSICION_MENU (
    Cod_Menu INT,
    Cod_Producto INT,
    Cantidad INT NOT NULL,
    
    -- Restricciones
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
```

**Ejemplo:** Menú Ahorro = 1 Hamburguesa + 1 Bebida + 1 Patatas

---

### DETALLE_PEDIDO_PRODUCTO

```sql
-- ============================================================
-- TABLA: DETALLE_PEDIDO_PRODUCTO
-- DESCRIPCIÓN: Líneas de pedido para productos individuales
-- ============================================================

CREATE TABLE DETALLE_PEDIDO_PRODUCTO (
    Num_Pedido INT,
    Cod_Producto INT,
    Cantidad INT NOT NULL,
    Precio_Venta DECIMAL(6,2) NOT NULL,
    
    -- Restricciones
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
```

**Comentarios:**
- `Precio_Venta`: Almacena el precio en el momento de la venta (histórico)
- Permite aplicar descuentos sin modificar el catálogo

---

### DETALLE_PEDIDO_MENU

```sql
-- ============================================================
-- TABLA: DETALLE_PEDIDO_MENU
-- DESCRIPCIÓN: Líneas de pedido para menús
-- ============================================================

CREATE TABLE DETALLE_PEDIDO_MENU (
    Num_Pedido INT,
    Cod_Menu INT,
    Cantidad INT NOT NULL,
    Precio_Venta DECIMAL(6,2) NOT NULL,
    
    -- Restricciones
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
```

---

## Índices Adicionales para Optimización

```sql
-- ============================================================
-- ÍNDICES PARA OPTIMIZACIÓN DE CONSULTAS
-- ============================================================

-- Índice para consultas por fecha (estadísticas diarias)
CREATE INDEX idx_pedido_fecha ON PEDIDO(Fecha);

-- Índice para consultas por repartidor
CREATE INDEX idx_pedido_domicilio_repartidor ON PEDIDO_DOMICILIO(Num_Repartidor);

-- Índice para búsqueda de productos por nombre
CREATE INDEX idx_producto_nombre ON PRODUCTO(Nombre);

-- Índice compuesto para estadísticas por fecha y hora
CREATE INDEX idx_pedido_fecha_hora ON PEDIDO(Fecha, Hora);
```

---

## Verificación de la Estructura

```sql
-- ============================================================
-- VERIFICACIÓN DE TABLAS CREADAS
-- ============================================================

-- Mostrar todas las tablas
SHOW TABLES;

-- Verificar estructura de cada tabla
DESCRIBE REPARTIDOR;
DESCRIBE PRODUCTO;
DESCRIBE MENU;
DESCRIBE PEDIDO;
DESCRIBE PEDIDO_VENTANILLA;
DESCRIBE PEDIDO_DOMICILIO;
DESCRIBE COMPOSICION_MENU;
DESCRIBE DETALLE_PEDIDO_PRODUCTO;
DESCRIBE DETALLE_PEDIDO_MENU;

-- Verificar claves foráneas
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'McIlerna_Albor_Croft'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;
```

---

## Resumen de la Implementación

### Tablas Creadas

| # | Tabla | Tipo | Descripción |
|:--|:------|:-----|:------------|
| 1 | `REPARTIDOR` | Maestra | Empleados repartidores |
| 2 | `PRODUCTO` | Maestra | Catálogo de productos |
| 3 | `MENU` | Maestra | Catálogo de menús |
| 4 | `PEDIDO` | Base | Pedidos (tabla base) |
| 5 | `PEDIDO_VENTANILLA` | Extensión | Pedidos en ventanilla |
| 6 | `PEDIDO_DOMICILIO` | Extensión | Pedidos a domicilio |
| 7 | `COMPOSICION_MENU` | Relación | Menú ↔ Producto |
| 8 | `DETALLE_PEDIDO_PRODUCTO` | Relación | Pedido ↔ Producto |
| 9 | `DETALLE_PEDIDO_MENU` | Relación | Pedido ↔ Menú |

### Restricciones Implementadas

- ✅ **9 Claves Primarias** (todas con AUTO_INCREMENT donde aplica)
- ✅ **9 Claves Foráneas** con integridad referencial
- ✅ **1 Clave Alternativa** (DNI en REPARTIDOR)
- ✅ **7 Restricciones CHECK** (precios, cantidades, turnos)
- ✅ **ON DELETE CASCADE** en extensiones y detalles de pedido
- ✅ **ON DELETE RESTRICT** en referencias a catálogos

### Características Técnicas

- **Motor:** InnoDB (soporte transaccional ACID)
- **Charset:** UTF-8 (utf8mb4_unicode_ci)
- **Normalización:** Tercera Forma Normal (3FN)
- **Índices:** 4 índices adicionales para optimización

---

## Ejecución del Script

Para ejecutar este script completo:

```bash
# Desde línea de comandos
mysql -u root -p < script_mcilerna.sql

# O desde MySQL CLI
mysql> SOURCE /ruta/al/script_mcilerna.sql;
```

**Nota:** Asegúrate de tener permisos suficientes para crear bases de datos.

---

## Siguiente Paso

Una vez creada la estructura, proceder con la **carga de datos de prueba** documentada en [pruebas.md](pruebas.md).
