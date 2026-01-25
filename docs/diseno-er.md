# Diseño Conceptual: El Modelo Entidad/Relación

El Modelo Entidad/Relación (E/R) constituye la abstracción de la realidad empresarial de **Mc Ilerna Albor Croft**. La elección de las entidades y sus interrelaciones busca minimizar la redundancia mientras se maximiza la expresividad de los datos.

> **Nota:** El sistema cuenta con **11 tablas** normalizadas a 3FN, incluyendo las nuevas tablas INGREDIENTE y PRODUCTO_INGREDIENTE para gestión de alérgenos.

## Entidades y Atributos Principales

Se han identificado entidades fuertes que sostienen la estructura y entidades de especialización que aportan el detalle operativo:

* **Pedido:** Núcleo del sistema. Posee una clave primaria `Num_Pedido` correlativa. Sus atributos incluyen Fecha y Hora.
* **Especializaciones de Pedido:**
    * **Pedido_Ventanilla:** Incluye el atributo `Num_Ventanilla`.
    * **Pedido_Domicilio:** Incluye `Telefono_Contacto`, `Poblacion` y `Direccion_Entrega`.
* **Repartidor:** Contiene `Num_Repartidor` (PK), Nombre, Apellidos, DNI, Teléfono, Matrícula de la moto y Turno (Mañana, Tarde, Noche).
* **Ingrediente:** Catálogo de ingredientes con `Cod_Ingrediente` (PK), Nombre (UNIQUE), Alergeno (booleano) y Tipo_Alergeno (gluten, lactosa, etc.).
* **Producto:** Catálogo individual con `Cod_Producto`, Nombre y Precio. Los ingredientes se gestionan mediante relación N:M.
* **Menú:** Entidad comercial con `Cod_Menu`, Nombre, Descripción y Precio.

A continuación se presenta el diseño conceptual del sistema

```mermaid
erDiagram
    REPARTIDOR {
        int Num_Repartidor PK "Autoincremental"
        string Nombre "NOT NULL"
        string Apellido1 "NOT NULL"
        string Apellido2
        string DNI UK "Unique Key"
        string Telefono
        string Matricula_Moto
        string Turno "CHECK (M, T, N)"
    }

    INGREDIENTE {
        int Cod_Ingrediente PK "Autoincremental"
        string Nombre UK "Unique Key"
        boolean Alergeno "DEFAULT FALSE"
        string Tipo_Alergeno "Gluten, Lactosa, etc."
    }

    PEDIDO {
        int Num_Pedido PK "Correlativo"
        date Fecha
        time Hora
    }

    PRODUCTO {
        int Cod_Producto PK
        string Nombre
        decimal Precio "CHECK > 0"
    }

    MENU {
        int Cod_Menu PK
        string Nombre
        string Descripcion
        decimal Precio "CHECK > 0"
    }

    %% ---------------------------------------------------------
    %% ENTIDADES DE ESPECIALIZACIÓN (JERARQUÍA)
    %% ---------------------------------------------------------

    PEDIDO_VENTANILLA {
        int Num_Pedido PK, FK
        int Num_Ventanilla
    }

    PEDIDO_DOMICILIO {
        int Num_Pedido PK, FK
        string Telefono_Contacto
        string Poblacion
        string Direccion_Entrega
        int Num_Repartidor FK
    }

    %% ---------------------------------------------------------
    %% TABLAS INTERMEDIAS (RELACIONES N:M EXPLÍCITAS)
    %% ---------------------------------------------------------
    
    %% Estas tablas existen físicamente en el SQL para gestionar cantidades

    PRODUCTO_INGREDIENTE {
        int Cod_Producto PK, FK
        int Cod_Ingrediente PK, FK
    }

    DETALLE_PEDIDO_PRODUCTO {
        int Num_Pedido PK, FK
        int Cod_Producto PK, FK
        int Cantidad
        decimal Precio_Venta
    }

    DETALLE_PEDIDO_MENU {
        int Num_Pedido PK, FK
        int Cod_Menu PK, FK
        int Cantidad
        decimal Precio_Venta
    }

    COMPOSICION_MENU {
        int Cod_Menu PK, FK
        int Cod_Producto PK, FK
        int Cantidad
    }

    %% ---------------------------------------------------------
    %% RELACIONES Y CARDINALIDADES
    %% ---------------------------------------------------------

    %% 1. Especialización (Herencia)
    PEDIDO ||--|| PEDIDO_VENTANILLA : "es procesado en"
    PEDIDO ||--|| PEDIDO_DOMICILIO : "es enviado a"

    %% 2. Relación Repartidor - Pedido Domicilio (1:N)
    REPARTIDOR ||--o{ PEDIDO_DOMICILIO : "entrega"

    %% 3. Relación Producto - Ingrediente (N:M)
    PRODUCTO ||--|{ PRODUCTO_INGREDIENTE : "contiene"
    INGREDIENTE ||--|{ PRODUCTO_INGREDIENTE : "forma parte de"

    %% 4. Relación Pedido - Producto (N:M resuelta con entidad débil)
    PEDIDO ||--|{ DETALLE_PEDIDO_PRODUCTO : "contiene"
    PRODUCTO ||--|{ DETALLE_PEDIDO_PRODUCTO : "está en"

    %% 5. Relación Pedido - Menú (N:M resuelta con entidad débil)
    PEDIDO ||--|{ DETALLE_PEDIDO_MENU : "contiene"
    MENU ||--|{ DETALLE_PEDIDO_MENU : "está en"

    %% 6. Relación Menú - Producto (N:M resuelta con entidad débil)
    MENU ||--|{ COMPOSICION_MENU : "se compone de"
    PRODUCTO ||--|{ COMPOSICION_MENU : "forma parte de"
```
