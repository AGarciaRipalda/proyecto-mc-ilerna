# Seguridad, Privacidad y Optimización

Este capítulo documenta las medidas de seguridad, estrategias de backup, cumplimiento normativo y recomendaciones de optimización para el sistema de base de datos de **Mc Ilerna Albor Croft**.

---

## Estrategia de Backups

### Política de Respaldo

El sistema implementa una estrategia de backups **híbrida** que combina respaldos completos e incrementales:

| Tipo de Backup | Frecuencia | Retención | Ventana de Ejecución |
|:---------------|:-----------|:----------|:---------------------|
| **Completo** | Diario | 30 días | 02:00 - 04:00 (madrugada) |
| **Incremental** | Cada hora | 7 días | Cada hora en punto |
| **Transaccional** | Continuo | 24 horas | Logs binarios en tiempo real |

### Implementación Técnica

#### Backup Completo Diario
```bash
#!/bin/bash
# Script: backup_completo.sh
# Descripción: Backup completo de la base de datos

FECHA=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/mcilerna"
DB_NAME="McIlerna_Albor_Croft"

mysqldump --single-transaction \
          --routines \
          --triggers \
          --events \
          --user=backup_user \
          --password=$MYSQL_BACKUP_PASS \
          $DB_NAME | gzip > $BACKUP_DIR/full_${FECHA}.sql.gz

# Eliminar backups completos con más de 30 días
find $BACKUP_DIR -name "full_*.sql.gz" -mtime +30 -delete
```

#### Backup Incremental Horario
```bash
#!/bin/bash
# Script: backup_incremental.sh
# Descripción: Backup incremental basado en binlogs

FECHA=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/mcilerna/incremental"

mysqlbinlog --read-from-remote-server \
            --raw \
            --stop-never \
            --result-file=$BACKUP_DIR/binlog_${FECHA} \
            mysql-bin.000001

# Eliminar incrementales con más de 7 días
find $BACKUP_DIR -name "binlog_*" -mtime +7 -delete
```

#### Configuración de MySQL para Backups
```sql
-- Habilitar logs binarios en my.cnf
[mysqld]
log-bin=mysql-bin
binlog_format=ROW
expire_logs_days=7
sync_binlog=1
```

### Procedimiento de Restauración

#### Restauración Completa
```bash
# 1. Restaurar backup completo
gunzip < /var/backups/mcilerna/full_20260113_020000.sql.gz | \
mysql -u root -p McIlerna_Albor_Croft

# 2. Aplicar logs binarios incrementales (si es necesario)
mysqlbinlog /var/backups/mcilerna/incremental/binlog_* | \
mysql -u root -p McIlerna_Albor_Croft
```

#### Restauración a Punto en el Tiempo
```bash
# Restaurar hasta una hora específica
mysqlbinlog --stop-datetime="2026-01-13 18:30:00" \
            /var/backups/mcilerna/incremental/binlog_* | \
mysql -u root -p McIlerna_Albor_Croft
```

---

## Cumplimiento RGPD

### Datos Personales Identificados

El sistema almacena datos personales sujetos al **Reglamento General de Protección de Datos (RGPD)**:

| Tabla | Datos Personales | Categoría RGPD |
|:------|:----------------|:---------------|
| `REPARTIDOR` | Nombre, Apellidos, DNI, Teléfono | Datos de empleados |
| `PEDIDO_DOMICILIO` | Teléfono, Dirección | Datos de clientes |

### Medidas de Cumplimiento

#### 1. Minimización de Datos
> **Artículo 5.1.c RGPD:** Los datos deben ser adecuados, pertinentes y limitados.

✅ **Implementado:**
- Solo se almacenan datos estrictamente necesarios para la operativa
- No se solicita email, nombre completo del cliente ni datos bancarios
- Los ingredientes se usan solo para información de alérgenos

#### 2. Derecho al Olvido
> **Artículo 17 RGPD:** Derecho de supresión.

**Procedimiento implementado:**
```sql
-- Anonimizar datos de cliente en pedidos antiguos (> 2 años)
UPDATE PEDIDO_DOMICILIO 
SET Telefono_Contacto = 'ANONIMIZADO',
    Direccion_Entrega = 'ANONIMIZADO',
    Poblacion = 'ANONIMIZADO'
WHERE Num_Pedido IN (
    SELECT Num_Pedido FROM PEDIDO 
    WHERE Fecha < DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
);

-- Eliminar repartidores que ya no trabajan (tras periodo legal)
DELETE FROM REPARTIDOR 
WHERE Num_Repartidor NOT IN (
    SELECT DISTINCT Num_Repartidor FROM PEDIDO_DOMICILIO
    WHERE Num_Pedido IN (
        SELECT Num_Pedido FROM PEDIDO 
        WHERE Fecha > DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    )
);
```

#### 3. Seguridad de los Datos
> **Artículo 32 RGPD:** Seguridad del tratamiento.

**Medidas técnicas:**
- ✅ Cifrado de conexiones: `REQUIRE SSL` para usuarios remotos
- ✅ Cifrado en reposo: Tablespaces cifrados con `ENCRYPTION='Y'`
- ✅ Control de acceso: Principio de mínimo privilegio
- ✅ Auditoría: Logs de acceso a datos personales

```sql
-- Habilitar cifrado de tablespace
ALTER TABLE REPARTIDOR ENCRYPTION='Y';
ALTER TABLE PEDIDO_DOMICILIO ENCRYPTION='Y';

-- Crear usuario con acceso restringido
CREATE USER 'app_mcilerna'@'localhost' 
IDENTIFIED BY 'password_seguro' 
REQUIRE SSL;

GRANT SELECT, INSERT, UPDATE ON McIlerna_Albor_Croft.PEDIDO TO 'app_mcilerna'@'localhost';
GRANT SELECT, INSERT, UPDATE ON McIlerna_Albor_Croft.PEDIDO_VENTANILLA TO 'app_mcilerna'@'localhost';
GRANT SELECT, INSERT, UPDATE ON McIlerna_Albor_Croft.PEDIDO_DOMICILIO TO 'app_mcilerna'@'localhost';
-- No se otorga DELETE para prevenir borrados accidentales
```

#### 4. Registro de Actividades
> **Artículo 30 RGPD:** Registro de actividades de tratamiento.

**Tabla de auditoría:**
```sql
CREATE TABLE AUDITORIA_ACCESO (
    Id_Auditoria INT AUTO_INCREMENT PRIMARY KEY,
    Usuario VARCHAR(50) NOT NULL,
    Tabla_Accedida VARCHAR(50) NOT NULL,
    Tipo_Operacion ENUM('SELECT', 'INSERT', 'UPDATE', 'DELETE') NOT NULL,
    Fecha_Hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IP_Origen VARCHAR(45),
    Registros_Afectados INT,
    INDEX idx_fecha (Fecha_Hora),
    INDEX idx_usuario (Usuario)
) ENGINE=InnoDB;

-- Trigger de ejemplo para auditar accesos a REPARTIDOR
DELIMITER $$
CREATE TRIGGER audit_repartidor_update
AFTER UPDATE ON REPARTIDOR
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_ACCESO (Usuario, Tabla_Accedida, Tipo_Operacion, Registros_Afectados)
    VALUES (USER(), 'REPARTIDOR', 'UPDATE', 1);
END$$
DELIMITER ;
```

---

## Gestión de Usuarios y Permisos

### Principio de Mínimo Privilegio

Se definen **4 roles** con permisos específicos:

#### 1. Administrador de Base de Datos
```sql
CREATE USER 'dba_mcilerna'@'localhost' IDENTIFIED BY 'password_admin';
GRANT ALL PRIVILEGES ON McIlerna_Albor_Croft.* TO 'dba_mcilerna'@'localhost';
GRANT SUPER, RELOAD, PROCESS ON *.* TO 'dba_mcilerna'@'localhost';
```

#### 2. Aplicación de Punto de Venta
```sql
CREATE USER 'app_pos'@'%' IDENTIFIED BY 'password_pos' REQUIRE SSL;
GRANT SELECT, INSERT ON McIlerna_Albor_Croft.PEDIDO TO 'app_pos'@'%';
GRANT SELECT, INSERT ON McIlerna_Albor_Croft.PEDIDO_VENTANILLA TO 'app_pos'@'%';
GRANT SELECT, INSERT ON McIlerna_Albor_Croft.PEDIDO_DOMICILIO TO 'app_pos'@'%';
GRANT SELECT, INSERT ON McIlerna_Albor_Croft.DETALLE_PEDIDO_PRODUCTO TO 'app_pos'@'%';
GRANT SELECT, INSERT ON McIlerna_Albor_Croft.DETALLE_PEDIDO_MENU TO 'app_pos'@'%';
GRANT SELECT ON McIlerna_Albor_Croft.PRODUCTO TO 'app_pos'@'%';
GRANT SELECT ON McIlerna_Albor_Croft.MENU TO 'app_pos'@'%';
GRANT SELECT ON McIlerna_Albor_Croft.REPARTIDOR TO 'app_pos'@'%';
```

#### 3. Usuario de Reportes (Solo Lectura)
```sql
CREATE USER 'reportes'@'localhost' IDENTIFIED BY 'password_reportes';
GRANT SELECT ON McIlerna_Albor_Croft.* TO 'reportes'@'localhost';
```

#### 4. Usuario de Backups
```sql
CREATE USER 'backup_user'@'localhost' IDENTIFIED BY 'password_backup';
GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON McIlerna_Albor_Croft.* TO 'backup_user'@'localhost';
```

---

## Optimización y Rendimiento

### Índices Recomendados

Además de los índices automáticos en PKs y FKs:

```sql
-- Optimización para consultas por fecha (estadísticas diarias)
CREATE INDEX idx_pedido_fecha ON PEDIDO(Fecha);

-- Optimización para consultas por repartidor
CREATE INDEX idx_pedido_domicilio_repartidor ON PEDIDO_DOMICILIO(Num_Repartidor);

-- Optimización para búsqueda de productos por nombre
CREATE INDEX idx_producto_nombre ON PRODUCTO(Nombre);

-- Índice compuesto para estadísticas por fecha y tipo
CREATE INDEX idx_pedido_fecha_hora ON PEDIDO(Fecha, Hora);
```

### Consultas Optimizadas

#### Estadística: Ticket Medio por Canal
```sql
-- Versión optimizada con índices
SELECT 
    'Ventanilla' AS Canal,
    COUNT(DISTINCT p.Num_Pedido) AS Total_Pedidos,
    SUM(
        COALESCE(dpp.Cantidad * dpp.Precio_Venta, 0) + 
        COALESCE(dpm.Cantidad * dpm.Precio_Venta, 0)
    ) AS Facturacion_Total,
    AVG(
        COALESCE(dpp.Cantidad * dpp.Precio_Venta, 0) + 
        COALESCE(dpm.Cantidad * dpm.Precio_Venta, 0)
    ) AS Ticket_Medio
FROM PEDIDO p
INNER JOIN PEDIDO_VENTANILLA pv ON p.Num_Pedido = pv.Num_Pedido
LEFT JOIN DETALLE_PEDIDO_PRODUCTO dpp ON p.Num_Pedido = dpp.Num_Pedido
LEFT JOIN DETALLE_PEDIDO_MENU dpm ON p.Num_Pedido = dpm.Num_Pedido
WHERE p.Fecha BETWEEN '2026-01-01' AND '2026-01-31'

UNION ALL

SELECT 
    'Domicilio' AS Canal,
    COUNT(DISTINCT p.Num_Pedido),
    SUM(
        COALESCE(dpp.Cantidad * dpp.Precio_Venta, 0) + 
        COALESCE(dpm.Cantidad * dpm.Precio_Venta, 0)
    ),
    AVG(
        COALESCE(dpp.Cantidad * dpp.Precio_Venta, 0) + 
        COALESCE(dpm.Cantidad * dpm.Precio_Venta, 0)
    )
FROM PEDIDO p
INNER JOIN PEDIDO_DOMICILIO pd ON p.Num_Pedido = pd.Num_Pedido
LEFT JOIN DETALLE_PEDIDO_PRODUCTO dpp ON p.Num_Pedido = dpp.Num_Pedido
LEFT JOIN DETALLE_PEDIDO_MENU dpm ON p.Num_Pedido = dpm.Num_Pedido
WHERE p.Fecha BETWEEN '2026-01-01' AND '2026-01-31';
```

### Configuración de MySQL para Rendimiento

```ini
# my.cnf - Configuración optimizada para sistema de pedidos

[mysqld]
# Motor y caché
default-storage-engine=InnoDB
innodb_buffer_pool_size=2G
innodb_log_file_size=512M

# Conexiones
max_connections=200
thread_cache_size=50

# Consultas
query_cache_type=1
query_cache_size=128M

# Logs
slow_query_log=1
slow_query_log_file=/var/log/mysql/slow-query.log
long_query_time=2

# Seguridad
ssl-ca=/etc/mysql/ssl/ca-cert.pem
ssl-cert=/etc/mysql/ssl/server-cert.pem
ssl-key=/etc/mysql/ssl/server-key.pem
```

---

## Plan de Recuperación ante Desastres

### Escenarios y Procedimientos

#### Escenario 1: Corrupción de Tabla
```sql
-- Verificar integridad
CHECK TABLE PEDIDO;

-- Reparar si es necesario
REPAIR TABLE PEDIDO;

-- Si falla, restaurar desde backup
-- (Ver sección de Restauración Completa)
```

#### Escenario 2: Pérdida Total del Servidor
1. **Provisionar nuevo servidor** con MySQL
2. **Restaurar backup completo** más reciente
3. **Aplicar logs binarios** incrementales
4. **Verificar integridad** de datos
5. **Actualizar DNS/IP** de aplicaciones
6. **Tiempo estimado de recuperación (RTO):** 2 horas
7. **Punto de recuperación objetivo (RPO):** 1 hora

#### Escenario 3: Borrado Accidental de Datos
```sql
-- Iniciar transacción para pruebas
START TRANSACTION;

-- Restaurar en base de datos temporal
CREATE DATABASE McIlerna_Temp;
-- (Restaurar backup en McIlerna_Temp)

-- Copiar datos específicos
INSERT INTO McIlerna_Albor_Croft.PEDIDO
SELECT * FROM McIlerna_Temp.PEDIDO
WHERE Num_Pedido BETWEEN 1000 AND 1050;

COMMIT;
```

---

## Evolución Futura: Integración con IA

### Predicción de Demanda

**Objetivo:** Utilizar Machine Learning para predecir la demanda basándose en:
- Histórico de pedidos
- Día de la semana
- Eventos locales (partidos, festivales)
- Condiciones meteorológicas

**Implementación sugerida:**
```python
# Pseudocódigo de integración
import pandas as pd
from sklearn.ensemble import RandomForestRegressor

# Extraer datos históricos
query = """
    SELECT Fecha, DAYOFWEEK(Fecha) AS Dia_Semana, 
           COUNT(*) AS Total_Pedidos
    FROM PEDIDO
    WHERE Fecha >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    GROUP BY Fecha
"""
df = pd.read_sql(query, mysql_connection)

# Entrenar modelo
model = RandomForestRegressor()
model.fit(df[['Dia_Semana']], df['Total_Pedidos'])

# Predecir demanda para mañana
prediccion = model.predict([[5]])  # Viernes
print(f"Pedidos esperados: {prediccion[0]:.0f}")
```

### Vista Materializada para Analytics
```sql
-- Crear vista para análisis rápido
CREATE VIEW V_ESTADISTICAS_DIARIAS AS
SELECT 
    p.Fecha,
    COUNT(DISTINCT p.Num_Pedido) AS Total_Pedidos,
    COUNT(DISTINCT pv.Num_Pedido) AS Pedidos_Ventanilla,
    COUNT(DISTINCT pd.Num_Pedido) AS Pedidos_Domicilio,
    SUM(dpp.Cantidad * dpp.Precio_Venta) AS Ingresos_Productos,
    SUM(dpm.Cantidad * dpm.Precio_Venta) AS Ingresos_Menus
FROM PEDIDO p
LEFT JOIN PEDIDO_VENTANILLA pv ON p.Num_Pedido = pv.Num_Pedido
LEFT JOIN PEDIDO_DOMICILIO pd ON p.Num_Pedido = pd.Num_Pedido
LEFT JOIN DETALLE_PEDIDO_PRODUCTO dpp ON p.Num_Pedido = dpp.Num_Pedido
LEFT JOIN DETALLE_PEDIDO_MENU dpm ON p.Num_Pedido = dpm.Num_Pedido
GROUP BY p.Fecha;
```

---

## Resumen de Medidas de Seguridad

| Categoría | Medida Implementada | Estado |
|:----------|:-------------------|:-------|
| **Backups** | Completos diarios + Incrementales horarios | ✅ Implementado |
| **RGPD** | Anonimización automática + Derecho al olvido | ✅ Implementado |
| **Cifrado** | SSL en conexiones + Tablespaces cifrados | ✅ Implementado |
| **Acceso** | 4 roles con mínimo privilegio | ✅ Implementado |
| **Auditoría** | Logs de acceso a datos personales | ✅ Implementado |
| **Recuperación** | Plan de desastres con RTO 2h, RPO 1h | ✅ Documentado |
| **Optimización** | Índices estratégicos + Configuración tuneada | ✅ Implementado |
| **Futuro** | Integración con IA para predicción | 📋 Planificado |

El sistema cumple con los estándares de seguridad, privacidad y rendimiento requeridos para un entorno de producción.
