# 📊 Proyecto DW – Fase Cero y Uno

Este proyecto consiste en la construcción de un **Data Warehouse** distribuido en tres ambientes (`STAGE`, `DW`, `PRODUCCION`) sincronizados entre sí, con procedimientos, triggers y carga de datos desde archivos Excel (convertidos a CSV).

---

## 🧱 Ambientes y Usuarios

| Ambiente            | Usuario      | Contraseña | Descripción                             |
| ------------------- | ------------ | ---------- | --------------------------------------- |
| STAGE               | `stage`      | `stage123` | Ambiente de carga cruda desde Excel     |
| DATA WAREHOUSE (DW) | `dw`         | `dw`       | Ambiente de transformación y modelado   |
| PRODUCCIÓN          | `produccion` | `prod123`  | Ambiente final, de consulta y auditoría |

---

## 📂 Tablas por ambiente

### 🟩 STAGE

- `BD2_STG_DATOS` — Carga inicial desde `.csv` con `SQL*Loader`

### 🟦 DW

- `BD2_DIM_HORA`
- `BD2_DIM_SELECCION`
- `BD2_DIM_RONDA`
- `BD2_DIM_PAIS_ORGANIZADOR`
- `BD2_DIM_CIUDAD`
- `BD2_DIM_ESTADIO`
- `BD2_HECHOS`
- `BD2_NO_HECHOS`
- `BD2_CORRELATIVOS`
- `BD2_SEGUIMIENTO`
- `BD2_VALORES_DEFAULT`

### 🟥 PRODUCCIÓN

- `WATERMARK`

---

## 🛡️ Permisos otorgados

### Desde `stage`:

```sql
GRANT SELECT ON BD2_STG_DATOS TO dw;
```

### Desde `dw`:

```sql
GRANT INSERT ON BD2_SEGUIMIENTO TO stage;
GRANT INSERT ON BD2_SEGUIMIENTO TO produccion;
```

### Desde `produccion`:

```sql
GRANT SELECT, UPDATE ON WATERMARK TO stage;
GRANT INSERT, UPDATE, SELECT ON WATERMARK TO dw;
```

---

## 🔃 Herramientas y funciones clave

- 📥 **Carga de datos**: `SQL*Loader` con archivos `.csv`
- 🧠 **Procedimientos y Triggers**:
  - `PRC_CONSTRUYE_HECHOS`
  - `PRC_DEVUELVE_CORRELATIVOS`
  - `PRC_DIM_*`
  - `PRC_SINCRONIZACION` (en STAGE)
  - `TRG_TABLA_SINC` (en PRODUCCIÓN)

---

## 📌 Recomendaciones

- Siempre usar `SERVICE_NAME = XEPDB1` para conectarse (no SID).
- Asegurar que las carpetas compartidas (`oracle-data`, `csv/`) tengan permisos adecuados (`chown 54321:54321`).
- Mantener separados los scripts por ambiente.
- Usar `docker exec -it db2-proyecto-oracle-db-1 bash` para interactuar dentro del contenedor.

---

## 🧪 Próximos pasos

- Crear procedimientos `MERGE` por dimensión
- Implementar trigger `TRG_TABLA_SINC`
- Ejecutar sincronización con `PRC_SINCRONIZACION`
- Poblar la tabla `WATERMARK` desde operaciones `UPDATE` o `SELECT`
