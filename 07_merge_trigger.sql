
-- ===================================
-- MERGE DESDE STAGE A DW
-- ===================================

-- HORA
MERGE INTO dw.BD2_DIM_HORA d
USING (
  SELECT DISTINCT HoraPartido AS HORA_PARTIDO
  FROM stage.BD2_STG_DATOS
) s
ON (d.HORA_PARTIDO = s.HORA_PARTIDO)
WHEN NOT MATCHED THEN
  INSERT (HORA_PARTIDO)
  VALUES (s.HORA_PARTIDO);

-- RONDA
MERGE INTO dw.BD2_DIM_RONDA d
USING (
  SELECT DISTINCT Ronda
  FROM stage.BD2_STG_DATOS
) s
ON (d.RONDA = s.RONDA)
WHEN NOT MATCHED THEN
  INSERT (RONDA)
  VALUES (s.RONDA);

-- ESTADIO
MERGE INTO dw.BD2_DIM_ESTADIO d
USING (
  SELECT DISTINCT Estadio
  FROM stage.BD2_STG_DATOS
) s
ON (d.NOMBRE_ESTADIO = s.Estadio)
WHEN NOT MATCHED THEN
  INSERT (NOMBRE_ESTADIO)
  VALUES (s.Estadio);

-- CIUDAD
MERGE INTO dw.BD2_DIM_CIUDAD d
USING (
  SELECT DISTINCT CiudadOrganizadora
  FROM stage.BD2_STG_DATOS
) s
ON (d.NOMBRE_CIUDAD = s.CiudadOrganizadora)
WHEN NOT MATCHED THEN
  INSERT (NOMBRE_CIUDAD)
  VALUES (s.CiudadOrganizadora);

-- PAIS ORGANIZADOR
MERGE INTO dw.BD2_DIM_PAIS_ORGANIZADOR d
USING (
  SELECT DISTINCT PaisOrganizador
  FROM stage.BD2_STG_DATOS
) s
ON (d.NOMBRE_PAIS = s.PaisOrganizador)
WHEN NOT MATCHED THEN
  INSERT (NOMBRE_PAIS)
  VALUES (s.PaisOrganizador);

-- SELECCIONES (LOCAL)
MERGE INTO dw.BD2_DIM_SELECCION d
USING (
  SELECT DISTINCT EquipoLocal AS NOMBRE_SELECCION
  FROM stage.BD2_STG_DATOS
) s
ON (d.NOMBRE_SELECCION = s.NOMBRE_SELECCION)
WHEN NOT MATCHED THEN
  INSERT (NOMBRE_SELECCION)
  VALUES (s.NOMBRE_SELECCION);

-- SELECCIONES (VISITA)
MERGE INTO dw.BD2_DIM_SELECCION d
USING (
  SELECT DISTINCT EquipoVisita AS NOMBRE_SELECCION
  FROM stage.BD2_STG_DATOS
) s
ON (d.NOMBRE_SELECCION = s.NOMBRE_SELECCION)
WHEN NOT MATCHED THEN
  INSERT (NOMBRE_SELECCION)
  VALUES (s.NOMBRE_SELECCION);

-- HECHOS
MERGE INTO dw.BD2_HECHOS d
USING (
  SELECT
    Anio,
    FechaPartido,
    HoraPartido,
    Ronda,
    Estadio,
    CiudadOrganizadora,
    PaisOrganizador,
    EquipoLocal,
    golesLocal,
    golesVisita,
    EquipoVisita,
    Asistencia
  FROM stage.BD2_STG_DATOS
) s
ON (
  d.Anio = s.Anio AND
  d.FechaPartido = s.FechaPartido AND
  d.EquipoLocal = s.EquipoLocal AND
  d.EquipoVisita = s.EquipoVisita
)
WHEN MATCHED THEN
  UPDATE SET
    d.golesLocal = s.golesLocal,
    d.golesVisita = s.golesVisita,
    d.Asistencia = s.Asistencia
WHEN NOT MATCHED THEN
  INSERT (
    Anio,
    FechaPartido,
    HoraPartido,
    Ronda,
    Estadio,
    CiudadOrganizadora,
    PaisOrganizador,
    EquipoLocal,
    golesLocal,
    golesVisita,
    EquipoVisita,
    Asistencia
  ) VALUES (
    s.Anio,
    s.FechaPartido,
    s.HoraPartido,
    s.Ronda,
    s.Estadio,
    s.CiudadOrganizadora,
    s.PaisOrganizador,
    s.EquipoLocal,
    s.golesLocal,
    s.golesVisita,
    s.EquipoVisita,
    s.Asistencia
  );


CREATE OR REPLACE TRIGGER produccion.TRG_BD2_HECHOS_SINC
AFTER UPDATE ON produccion.BD2_HECHOS
FOR EACH ROW
BEGIN
  INSERT INTO produccion.WATERMARK (
    TABLA_AFECTADA,
    TIPO_OPERACION,
    USUARIO,
    FECHA_OPERACION
  ) VALUES (
    'BD2_HECHOS',
    'UPDATE',
    USER,
    SYSDATE
  );
END;
/


CREATE OR REPLACE PROCEDURE stage.PRC_SINCRONIZACION AS
BEGIN
  -- Borra datos en STAGE
  DELETE FROM stage.BD2_STG_DATOS;

  -- Inserta nuevamente desde DW
  INSERT INTO stage.BD2_STG_DATOS (
    Anio, FechaPartido, HoraPartido, Ronda, Estadio,
    CiudadOrganizadora, PaisOrganizador,
    EquipoLocal, golesLocal, golesVisita, EquipoVisita, Asistencia
  )
  SELECT
    Anio, FechaPartido, HoraPartido, Ronda, Estadio,
    CiudadOrganizadora, PaisOrganizador,
    EquipoLocal, golesLocal, golesVisita, EquipoVisita, Asistencia
  FROM dw.BD2_HECHOS;
END;
/
