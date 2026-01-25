# Marco Estratégico y Fase de Requerimientos

La fase inicial de cualquier proyecto de base de datos requiere una comprensión profunda del dominio del problema. En Mc Ilerna Albor Croft, el sistema debe diferenciar claramente entre la operativa de ventanilla y la de entrega a domicilio, manteniendo una numeración correlativa única.

## Simulación de Intervenciones con el Cliente

### Acta de la Primera Reunión: Definición de Alcance Operativo
| Dato | Detalle |
| :--- | :--- |
| **Fecha y Hora** | 12 de enero de 2026, 09:00h - 11:30h |
| **Lugar** | Instalaciones Albor Croft, Jerez de la Frontera |
| **Asistentes** | Juan Sevillano (Consultor), Gerencia Mc Ilerna, Responsable Logística |

**Desarrollo:**
En esta sesión se desgranó la naturaleza de los pedidos. La gerencia enfatizó que el sistema debe estar preparado para futuras expansiones (apps móviles, tótems). Se acordó utilizar una entidad general para los pedidos con especialización para capturar datos específicos (ventanilla o dirección). Se definió que los turnos de trabajo serían: **Mañana, Tarde y Noche**.

### Acta de la Segunda Reunión: Estructura de Productos y Menús
| Dato | Detalle |
| :--- | :--- |
| **Fecha y Hora** | 15 de enero de 2026, 10:00h - 13:00h |
| **Lugar** | Oficina Técnica de Proyectos ASIR |
| **Asistentes** | Juan Sevillano (Consultor), Jefe de Cocina, Supervisor de Ventas |

**Desarrollo:**
Se clarificó la relación entre productos y menús. Un menú es una entidad comercial con precio y descripción propios, compuesta por productos que también se venden por separado. En esta reunión se discutió inicialmente almacenar los ingredientes como texto descriptivo para simplicidad operativa, priorizando la facilidad de gestión de alérgenos.

### Acta de la Tercera Reunión: Normalización de Ingredientes
| Dato | Detalle |
| :--- | :--- |
| **Fecha y Hora** | 21 de enero de 2026, 14:00h - 16:30h |
| **Lugar** | Sala de Reuniones Virtual (Microsoft Teams) |
| **Asistentes** | Juan Sevillano (Consultor), Responsable de Calidad, Nutricionista, Jefe de Cocina |

**Desarrollo:**
Tras una revisión del diseño inicial, el Responsable de Calidad planteó la necesidad de mejorar la gestión de alérgenos para cumplir con normativas sanitarias más estrictas. La nutricionista destacó la importancia de poder generar reportes precisos sobre ingredientes y alérgenos. Se decidió **normalizar completamente los ingredientes** creando una tabla dedicada `INGREDIENTE` con información detallada de alérgenos (tipo: gluten, lactosa, frutos secos, etc.) y una tabla de relación `PRODUCTO_INGREDIENTE` para vincular productos con sus ingredientes.

**Acuerdos alcanzados:**
- Crear tabla `INGREDIENTE` con campos: código, nombre (único), indicador de alérgeno, y tipo de alérgeno
- Crear tabla de relación N:M `PRODUCTO_INGREDIENTE` para vincular productos con ingredientes
- Eliminar campo de texto libre `Ingredientes` de la tabla `PRODUCTO`
- Sistema pasará de 9 a 11 tablas para cumplir estrictamente con 3FN
- Beneficios: mejor gestión de alérgenos, consultas más eficientes, eliminación de redundancia

**Justificación técnica:**
El cambio de decisión se fundamenta en el cumplimiento estricto de la Tercera Forma Normal (3FN), eliminando dependencias transitivas y grupos repetitivos. Aunque aumenta la complejidad de consultas (requiere JOINs), mejora significativamente la integridad de datos y facilita el cumplimiento normativo en gestión de alérgenos.
