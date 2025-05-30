# 📊 Proyecto Data Warehouse – Fase Cero y Uno

[![OracleDB](https://img.shields.io/badge/Oracle-21c-red)](https://www.oracle.com/database/)
[![PL/SQL](https://img.shields.io/badge/PL--SQL-Supported-blue)](https://docs.oracle.com/en/database/oracle/oracle-database/)

📅 **Fecha de entrega**: Mayo 2025  
🧩 **Versión actual**: Fase 1 completada

---

## 👨‍💻 Proyecto realizado por

| Nombre completo                  | Carné           | Correo institucional     | Rol                           |
|----------------------------------|------------------|----------------------------|-------------------------------|
| Alexis Vidal Juárez Siguantay   | 7590-14-3421     | ajuarezs3@miumg.edu.gt     | Modelado y procedimientos     |
| Jose Alberto Avila Alvarado     | 7590-22-9949     | javilaa5@miumg.edu.gt      | Carga, triggers y testing     |

---

## 🧱 Ambientes y Usuarios

| Ambiente            | Usuario      | Contraseña | Descripción                             |
|---------------------|--------------|------------|-----------------------------------------|
| STAGE               | `stage`      | `stage123` | Ambiente de carga cruda desde `.csv`    |
| DATA WAREHOUSE (DW) | `dw`         | `dw`       | Ambiente de transformación y modelado   |
| PRODUCCIÓN          | `produccion` | `prod123`  | Ambiente final para consulta y auditoría|

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

- **Carga de datos**: `SQL*Loader` con archivos `.csv`
- **Ejecutar**:
  ```bash
  sqlldr stage/stage123@XEPDB1 control=/opt/oracle/csv/data.ctl log=/opt/oracle/csv/datos.log
  ```

- **Procedimientos y Triggers**:
  - `PRC_CONSTRUYE_HECHOS`
  - `PRC_DEVUELVE_CORRELATIVOS`
  - `PRC_DIM_*` (uno por cada dimensión)
  - `PRC_SINCRONIZACION` (en STAGE)
  - `TRG_TABLA_SINC` (en PRODUCCIÓN)

---

## 🚀 Ejecución rápida (Quickstart)

1. **Cargar datos desde CSV:**
   ```bash
   sqlldr stage/stage123@XEPDB1 control=/opt/oracle/csv/data.ctl log=/opt/oracle/csv/datos.log
   ```

2. **Construir dimensiones:**
   ```sql
   EXEC PRC_DIM_HORA(1);
   EXEC PRC_DIM_SELECCION(1);
   EXEC PRC_DIM_RONDA(1);
   EXEC PRC_DIM_PAIS_ORGANIZADOR(1);
   EXEC PRC_DIM_CIUDAD(1);
   EXEC PRC_DIM_ESTADIO(1);
   ```

3. **Construir tabla de hechos:**
   ```sql
   EXEC PRC_CONSTRUYE_HECHOS(1);
   ```

4. **Sincronizar hacia STAGE:**
   ```sql
   EXEC PRC_SINCRONIZACION;
   ```

5. **Verificar Watermark:**
   ```sql
   SELECT * FROM produccion.WATERMARK;
   ```

---

## 📌 Recomendaciones

- Usar `SERVICE_NAME = XEPDB1` para conectarse (no SID).
- Asegurar que las carpetas compartidas (`oracle-data`, `csv/`) tengan permisos correctos:
  ```bash
  chown 54321:54321 /ruta/al/directorio
  ```
- Mantener separados los scripts por ambiente.
- Conectarse a Oracle desde Docker con:
  ```bash
  docker exec -it db2-proyecto-oracle-db-1 bash
  ```
