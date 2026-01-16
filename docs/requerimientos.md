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
Se clarificó la relación entre productos y menús. Un menú es una entidad comercial con precio y descripción propios, compuesta por productos que también se venden por separado. Se decidió que los ingredientes se almacenarán como texto descriptivo para facilitar la gestión de alérgenos.