-- Permisos de DW sobre STAGE
GRANT SELECT ON stage.BD2_STG_DATOS TO dw;

-- Permisos de STAGE sobre PRODUCCION
GRANT SELECT, UPDATE ON produccion.WATERMARK TO stage;

-- (Opcional) Permisos de DW sobre WATERMARK
GRANT INSERT, UPDATE, SELECT ON produccion.WATERMARK TO dw;

-- (Opcional) Permisos cruzados para registrar seguimiento
GRANT INSERT ON dw.BD2_SEGUIMIENTO TO stage;
GRANT INSERT ON dw.BD2_SEGUIMIENTO TO produccion;