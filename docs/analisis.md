# Análisis de Requisitos y Normalización

## Requisitos Funcionales

El sistema de base de datos para **Mc Ilerna Albor Croft** debe satisfacer los siguientes requisitos funcionales identificados durante las reuniones con el cliente:

### RF-01: Gestión Unificada de Pedidos
El sistema debe mantener una **numeración correlativa única** para todos los pedidos, independientemente del canal de venta (ventanilla o domicilio). Esto permite:
- Trazabilidad completa de todas las operaciones
- Auditoría contable sin duplicidades
- Estadísticas consolidadas de volumen de negocio

### RF-02: Diferenciación de Canales de Venta
Aunque la numeración sea única, el sistema debe capturar información específica según el tipo de pedido:

| Canal | Atributos Específicos |
|:------|:---------------------|
| **Ventanilla** | Número de ventanilla de atención |
| **Domicilio** | Teléfono de contacto, población, dirección de entrega, repartidor asignado |

### RF-03: Gestión de Repartidores
El sistema debe registrar y gestionar la información de los repartidores:
- Datos personales: Nombre, apellidos, DNI (único)
- Datos de contacto: Teléfono
- Datos logísticos: Matrícula de la moto
- Datos operativos: Turno de trabajo (Mañana, Tarde, Noche)

**Restricción:** Cada pedido a domicilio debe tener asignado **exactamente un repartidor**.

### RF-04: Catálogo de Productos y Menús
El sistema debe diferenciar entre:

**Productos individuales:**
- Código único
- Nombre descriptivo
- Ingredientes (texto libre para gestión de alérgenos)
- Precio unitario

**Menús:**
- Código único
- Nombre comercial
- Descripción
- Precio del menú (puede ser diferente a la suma de productos)
- Composición: lista de productos que lo integran con sus cantidades

### RF-05: Líneas de Pedido
Cada pedido puede contener:
- Múltiples productos individuales (con cantidad)
- Múltiples menús (con cantidad)
- Registro del precio de venta en el momento del pedido (para histórico)

### RF-06: Escalabilidad Futura
El diseño debe permitir la integración futura de:
- Aplicaciones móviles
- Tótems de autoservicio
- Sistemas de predicción de demanda

---

## Requisitos No Funcionales

### RNF-01: Integridad de Datos
- **Integridad referencial:** Todas las relaciones deben estar protegidas con claves foráneas
- **Integridad de dominio:** Validación de precios (> 0), cantidades (> 0), turnos (M/T/N)
- **Integridad de entidad:** Claves primarias autoincrementales sin nulos

### RNF-02: Rendimiento
- Motor de almacenamiento **InnoDB** para soporte transaccional
- Índices en columnas de búsqueda frecuente (Fecha, Num_Repartidor)
- Optimización para consultas de estadísticas

### RNF-03: Seguridad y Privacidad
- Cumplimiento **RGPD** para datos personales de empleados y clientes
- Backups incrementales horarios
- Auditoría de operaciones críticas

### RNF-04: Mantenibilidad
- Código SQL documentado
- Nomenclatura consistente en español
- Diseño normalizado hasta 3FN

---

## Proceso de Normalización

### Análisis de Dependencias Funcionales

Partiendo de una tabla universal hipotética, se identifican las siguientes dependencias funcionales:

```
PEDIDO_UNIVERSAL (
    Num_Pedido, Fecha, Hora, Num_Ventanilla, 
    Telefono_Contacto, Poblacion, Direccion_Entrega,
    Num_Repartidor, Nombre_Repartidor, Apellidos_Repartidor, 
    DNI_Repartidor, Telefono_Repartidor, Matricula_Moto, Turno,
    Cod_Producto, Nombre_Producto, Ingredientes, Precio_Producto,
    Cantidad_Producto, Precio_Venta_Producto,
    Cod_Menu, Nombre_Menu, Descripcion_Menu, Precio_Menu,
    Cantidad_Menu, Precio_Venta_Menu
)
```

**Dependencias funcionales identificadas:**

1. `Num_Pedido → Fecha, Hora`
2. `Num_Pedido → Num_Ventanilla` (solo para pedidos de ventanilla)
3. `Num_Pedido → Telefono_Contacto, Poblacion, Direccion_Entrega, Num_Repartidor` (solo para domicilio)
4. `Num_Repartidor → Nombre_Repartidor, Apellidos_Repartidor, DNI_Repartidor, Telefono_Repartidor, Matricula_Moto, Turno`
5. `DNI_Repartidor → Num_Repartidor` (clave alternativa)
6. `Cod_Producto → Nombre_Producto, Ingredientes, Precio_Producto`
7. `Cod_Menu → Nombre_Menu, Descripcion_Menu, Precio_Menu`
8. `(Num_Pedido, Cod_Producto) → Cantidad_Producto, Precio_Venta_Producto`
9. `(Num_Pedido, Cod_Menu) → Cantidad_Menu, Precio_Venta_Menu`
10. `(Cod_Menu, Cod_Producto) → Cantidad` (composición del menú)

---

### Primera Forma Normal (1FN)

> **Definición:** Una tabla está en 1FN si todos sus atributos contienen valores atómicos (no hay grupos repetitivos ni atributos multivaluados).

**Problema inicial:** En la tabla universal, un pedido puede tener múltiples productos y múltiples menús, lo que genera grupos repetitivos.

**Solución:** Separar en tablas diferentes:

```
PEDIDO (Num_Pedido, Fecha, Hora, Tipo_Pedido)
PEDIDO_VENTANILLA (Num_Pedido, Num_Ventanilla)
PEDIDO_DOMICILIO (Num_Pedido, Telefono_Contacto, Poblacion, Direccion_Entrega, Num_Repartidor)
REPARTIDOR (Num_Repartidor, Nombre, Apellidos, DNI, Telefono, Matricula_Moto, Turno)
PRODUCTO (Cod_Producto, Nombre, Ingredientes, Precio)
MENU (Cod_Menu, Nombre, Descripcion, Precio)
DETALLE_PEDIDO_PRODUCTO (Num_Pedido, Cod_Producto, Cantidad, Precio_Venta)
DETALLE_PEDIDO_MENU (Num_Pedido, Cod_Menu, Cantidad, Precio_Venta)
COMPOSICION_MENU (Cod_Menu, Cod_Producto, Cantidad)
```

**Resultado:** ✅ Todos los atributos son atómicos.

---

### Segunda Forma Normal (2FN)

> **Definición:** Una tabla está en 2FN si está en 1FN y todos los atributos no clave dependen completamente de la clave primaria (no hay dependencias parciales).

**Análisis de tablas con claves compuestas:**

| Tabla | Clave Primaria | Dependencias | ¿Cumple 2FN? |
|:------|:--------------|:-------------|:-------------|
| `DETALLE_PEDIDO_PRODUCTO` | (Num_Pedido, Cod_Producto) | Cantidad, Precio_Venta dependen de ambos | ✅ Sí |
| `DETALLE_PEDIDO_MENU` | (Num_Pedido, Cod_Menu) | Cantidad, Precio_Venta dependen de ambos | ✅ Sí |
| `COMPOSICION_MENU` | (Cod_Menu, Cod_Producto) | Cantidad depende de ambos | ✅ Sí |

**Resultado:** ✅ No existen dependencias parciales. Todas las tablas están en 2FN.

---

### Tercera Forma Normal (3FN)

> **Definición:** Una tabla está en 3FN si está en 2FN y no existen dependencias transitivas (ningún atributo no clave depende de otro atributo no clave).

**Análisis de dependencias transitivas:**

En la tabla `PEDIDO_DOMICILIO` original podría existir:
- `Num_Pedido → Num_Repartidor`
- `Num_Repartidor → Nombre, Apellidos, DNI, Telefono, Matricula, Turno`

Esto crearía una dependencia transitiva: `Num_Pedido → Num_Repartidor → Datos_Repartidor`

**Solución:** Separar en dos tablas:
```
PEDIDO_DOMICILIO (Num_Pedido, Telefono_Contacto, Poblacion, Direccion_Entrega, Num_Repartidor)
REPARTIDOR (Num_Repartidor, Nombre, Apellidos, DNI, Telefono, Matricula_Moto, Turno)
```

**Verificación final:**

| Tabla | Dependencias Transitivas | ¿Cumple 3FN? |
|:------|:------------------------|:-------------|
| `PEDIDO` | No existen | ✅ Sí |
| `PEDIDO_VENTANILLA` | No existen | ✅ Sí |
| `PEDIDO_DOMICILIO` | Eliminadas (Repartidor separado) | ✅ Sí |
| `REPARTIDOR` | No existen | ✅ Sí |
| `PRODUCTO` | No existen | ✅ Sí |
| `MENU` | No existen | ✅ Sí |
| Tablas de detalle | No existen | ✅ Sí |

**Resultado:** ✅ El esquema completo está en **Tercera Forma Normal (3FN)**.

---

## Decisiones de Diseño Justificadas

### 1. Especialización de Pedidos mediante Extensiones de Tabla

**Decisión:** Utilizar una tabla base `PEDIDO` con dos tablas de extensión (`PEDIDO_VENTANILLA` y `PEDIDO_DOMICILIO`) en lugar de una única tabla con campos opcionales.

**Justificación:**
- ✅ **Integridad:** Evita valores NULL innecesarios
- ✅ **Escalabilidad:** Facilita agregar nuevos canales (app móvil, tótem)
- ✅ **Claridad:** Separa claramente las responsabilidades
- ✅ **Normalización:** Mantiene 3FN sin redundancia

**Alternativa descartada:** Tabla única con campos opcionales generaría múltiples NULL y violaría principios de diseño limpio.

---

### 2. Normalización Completa de Ingredientes

**Decisión:** Crear tabla dedicada `INGREDIENTE` y tabla de relación `PRODUCTO_INGREDIENTE` para normalizar completamente los ingredientes.

**Justificación:**
- ✅ **Cumplimiento de 3FN:** Elimina dependencias transitivas y grupos repetitivos
- ✅ **Gestión de alérgenos:** Permite consultas eficientes por tipo de alérgeno (gluten, lactosa, etc.)
- ✅ **Eliminación de redundancia:** Cada ingrediente se almacena una sola vez
- ✅ **Consistencia:** UNIQUE en nombre evita duplicados
- ✅ **Cumplimiento normativo:** Facilita reportes precisos para normativas sanitarias
- ✅ **Consultas potentes:** Permite filtrar productos por ingredientes o alérgenos

**Contexto:** Según acta de la tercera reunión (21/01/2026), el Responsable de Calidad y la nutricionista plantearon la necesidad de mejorar la gestión de alérgenos para cumplir con normativas sanitarias más estrictas. Se decidió cambiar el enfoque inicial (texto libre) por normalización completa.

**Implementación:**
```sql
-- Tabla de ingredientes
INGREDIENTE (Cod_Ingrediente, Nombre UNIQUE, Alergeno, Tipo_Alergeno)

-- Relación N:M con productos
PRODUCTO_INGREDIENTE (Cod_Producto, Cod_Ingrediente)
  PRIMARY KEY (Cod_Producto, Cod_Ingrediente)
```

**Ventajas sobre texto libre:**
- Consultas como "productos sin lactosa" son simples JOINs en lugar de búsquedas de texto
- Cambiar información de un ingrediente (ej: marcar como alérgeno) afecta automáticamente a todos los productos
- Permite estadísticas: ingredientes más usados, productos por alérgeno, etc.

---

### 3. Precio de Venta Histórico

**Decisión:** Almacenar `Precio_Venta` en las tablas de detalle de pedido, además del precio actual en `PRODUCTO` y `MENU`.

**Justificación:**
- ✅ **Histórico:** Permite consultar el precio exacto en el momento de la venta
- ✅ **Auditoría:** Esencial para contabilidad y análisis retrospectivo
- ✅ **Promociones:** Permite aplicar descuentos sin perder el precio de catálogo

---

### 4. Turno como Enumeración

**Decisión:** Utilizar restricción `CHECK` con valores ('M', 'T', 'N') en lugar de tabla de turnos.

**Justificación:**
- ✅ **Estabilidad:** Los turnos son valores fijos que no cambiarán
- ✅ **Rendimiento:** Evita JOINs innecesarios
- ✅ **Simplicidad:** Reduce el número de tablas

---

## Conclusiones del Análisis

El diseño resultante cumple con:

1. ✅ **Tercera Forma Normal (3FN)** en todas las tablas
2. ✅ **Integridad referencial** completa mediante claves foráneas
3. ✅ **Escalabilidad** para futuros canales de venta
4. ✅ **Trazabilidad** mediante numeración correlativa única
5. ✅ **Flexibilidad** para promociones y cambios de precio
6. ✅ **Simplicidad** en la gestión de ingredientes y turnos

El modelo está preparado para soportar la operativa actual y futuras expansiones del negocio, manteniendo la integridad de los datos y facilitando la extracción de estadísticas de negocio.
