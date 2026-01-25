# Resumen de Normalización de Ingredientes a 3FN

## ✅ Cambios Implementados

### **Sistema Actualizado: 11 Tablas (antes 9)**

---

## 🆕 **Nuevas Tablas Agregadas**

### **1. INGREDIENTE** (Tabla Maestra)
| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| Cod_Ingrediente | INT | PK, AUTO_INCREMENT | Identificador único |
| Nombre | VARCHAR(100) | UNIQUE, NOT NULL | Nombre del ingrediente |
| Alergeno | BOOLEAN | NOT NULL, DEFAULT FALSE | Indica si es alérgeno |
| Tipo_Alergeno | VARCHAR(50) | NULL | Tipo: Gluten, Lactosa, etc. |

**Ejemplos de datos:**
```sql
INSERT INTO INGREDIENTE (Nombre, Alergeno, Tipo_Alergeno) VALUES
('Pan', TRUE, 'Gluten'),
('Carne de ternera', FALSE, NULL),
('Lechuga', FALSE, NULL),
('Tomate', FALSE, NULL),
('Queso cheddar', TRUE, 'Lactosa'),
('Mayonesa', TRUE, 'Huevo');
```

### **2. PRODUCTO_INGREDIENTE** (Relación N:M)
| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| Cod_Producto | INT | **PK (parte 1 de 2)**, FK → PRODUCTO | Código del producto |
| Cod_Ingrediente | INT | **PK (parte 2 de 2)**, FK → INGREDIENTE | Código del ingrediente |

**Clave primaria compuesta:** (Cod_Producto, Cod_Ingrediente)

**Ejemplos de datos:**
```sql
-- Hamburguesa Simple (Cod_Producto = 1)
INSERT INTO PRODUCTO_INGREDIENTE VALUES
(1, 1),  -- Pan
(1, 2),  -- Carne
(1, 3),  -- Lechuga
(1, 4);  -- Tomate

-- Hamburguesa Doble (Cod_Producto = 2)
INSERT INTO PRODUCTO_INGREDIENTE VALUES
(2, 1),  -- Pan
(2, 2),  -- Carne
(2, 5);  -- Queso cheddar
```

---

## 📝 **Tabla Modificada**

### **PRODUCTO** (Campo eliminado)

**ANTES:**
```sql
PRODUCTO (
    Cod_Producto INT PK,
    Nombre VARCHAR(100),
    Ingredientes TEXT,  -- ❌ ELIMINADO
    Precio DECIMAL(6,2)
)
```

**DESPUÉS:**
```sql
PRODUCTO (
    Cod_Producto INT PK,
    Nombre VARCHAR(100),
    Precio DECIMAL(6,2)
)
```

---

## 🔑 **Resumen de Claves Primarias**

### **Claves Simples (7 tablas):**
1. REPARTIDOR → Num_Repartidor
2. **INGREDIENTE** → Cod_Ingrediente ✨ NUEVA
3. PRODUCTO → Cod_Producto
4. MENU → Cod_Menu
5. PEDIDO → Num_Pedido
6. PEDIDO_VENTANILLA → Num_Pedido
7. PEDIDO_DOMICILIO → Num_Pedido

### **Claves Compuestas (4 tablas):**
1. **PRODUCTO_INGREDIENTE** → (Cod_Producto, Cod_Ingrediente) ✨ NUEVA
2. COMPOSICION_MENU → (Cod_Menu, Cod_Producto)
3. DETALLE_PEDIDO_PRODUCTO → (Num_Pedido, Cod_Producto)
4. DETALLE_PEDIDO_MENU → (Num_Pedido, Cod_Menu)

---

## ✅ **Verificación de 3FN**

### **Primera Forma Normal (1FN)**
✅ **Cumplida** - No hay grupos repetitivos
- Antes: Campo `Ingredientes` contenía lista separada por comas
- Ahora: Cada ingrediente es una fila en PRODUCTO_INGREDIENTE

### **Segunda Forma Normal (2FN)**
✅ **Cumplida** - No hay dependencias parciales
- PRODUCTO_INGREDIENTE tiene clave compuesta
- No hay atributos que dependan solo de parte de la clave

### **Tercera Forma Normal (3FN)**
✅ **Cumplida** - No hay dependencias transitivas
- Información de ingredientes (nombre, alérgeno) depende de Cod_Ingrediente
- No depende transitivamente de Cod_Producto

---

## 📊 **Consultas Útiles**

### **1. Listar ingredientes de un producto**
```sql
SELECT i.Nombre, i.Alergeno, i.Tipo_Alergeno
FROM PRODUCTO p
JOIN PRODUCTO_INGREDIENTE pi ON p.Cod_Producto = pi.Cod_Producto
JOIN INGREDIENTE i ON pi.Cod_Ingrediente = i.Cod_Ingrediente
WHERE p.Cod_Producto = 1;
```

### **2. Productos con un ingrediente específico**
```sql
SELECT p.Nombre
FROM PRODUCTO p
JOIN PRODUCTO_INGREDIENTE pi ON p.Cod_Producto = pi.Cod_Producto
JOIN INGREDIENTE i ON pi.Cod_Ingrediente = i.Cod_Ingrediente
WHERE i.Nombre = 'Lechuga';
```

### **3. Productos SIN lactosa (aptos para intolerantes)**
```sql
SELECT p.Nombre
FROM PRODUCTO p
WHERE p.Cod_Producto NOT IN (
    SELECT pi.Cod_Producto
    FROM PRODUCTO_INGREDIENTE pi
    JOIN INGREDIENTE i ON pi.Cod_Ingrediente = i.Cod_Ingrediente
    WHERE i.Tipo_Alergeno = 'Lactosa'
);
```

### **4. Ingredientes más usados**
```sql
SELECT i.Nombre, COUNT(*) as Num_Productos
FROM INGREDIENTE i
JOIN PRODUCTO_INGREDIENTE pi ON i.Cod_Ingrediente = pi.Cod_Ingrediente
GROUP BY i.Cod_Ingrediente
ORDER BY Num_Productos DESC;
```

### **5. Productos con alérgenos**
```sql
SELECT DISTINCT p.Nombre, GROUP_CONCAT(i.Tipo_Alergeno) as Alergenos
FROM PRODUCTO p
JOIN PRODUCTO_INGREDIENTE pi ON p.Cod_Producto = pi.Cod_Producto
JOIN INGREDIENTE i ON pi.Cod_Ingrediente = i.Cod_Ingrediente
WHERE i.Alergeno = TRUE
GROUP BY p.Cod_Producto;
```

---

## 📁 **Archivos Actualizados**

✅ **DICCIONARIO_DATOS.xlsx** - Excel con formato visual
- Nuevas tablas en verde claro
- Claves compuestas en amarillo
- Total: 43 filas de datos

✅ **DICCIONARIO_DATOS.csv** - CSV para importar
- Formato estándar con 9 columnas
- Compatible con Excel, Google Sheets, etc.

---

## 🎨 **Formato Visual en Excel**

- **Nuevas tablas (INGREDIENTE, PRODUCTO_INGREDIENTE):**
  - Fondo: Verde claro (#C6EFCE)
  - Nombre de tabla: Verde oscuro (#006100) en negrita

- **Claves primarias compuestas:**
  - Fondo: Amarillo (#FFE699)
  - Nombre de campo: Rojo (#CC0000) en negrita

- **Tablas existentes:**
  - Alternado: Gris claro / Blanco

---

## 📈 **Beneficios de la Normalización**

1. ✅ **Cumplimiento estricto de 3FN**
2. ✅ **Gestión eficiente de alérgenos**
3. ✅ **Eliminación de redundancia** (ingredientes únicos)
4. ✅ **Consistencia de datos** (UNIQUE en nombre)
5. ✅ **Consultas más potentes** (filtros por alérgenos)
6. ✅ **Facilita estadísticas** (ingredientes más usados)
7. ✅ **Escalabilidad** (fácil agregar nuevos ingredientes)

---

## 🔄 **Próximos Pasos Sugeridos**

1. Actualizar `docs/diseno-er.md` con entidades INGREDIENTE y PRODUCTO_INGREDIENTE
2. Actualizar `docs/diseno-logico.md` con diccionarios de datos
3. Actualizar `docs/implementacion/script-sql.md` con CREATE TABLE
4. Actualizar `docs/implementacion/pruebas.md` con datos de ejemplo
5. Actualizar `DOCUMENTACION_COMPLETA.tex` con todas las secciones

---

**Fecha de actualización:** 21 de enero de 2026
**Estado:** ✅ Normalización completada - Sistema cumple 3FN
