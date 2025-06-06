-- ============================================
-- PROCEDIMIENTO DE LLENADO DE HECHOS
-- ============================================
CREATE OR REPLACE PROCEDURE PRC_CONSTRUYE_HECHOS(p_param IN NUMBER) IS
BEGIN
  IF p_param = 1 THEN
    FOR r IN (
      SELECT
        S.ANIO,
        S.FECHA,
        TO_NUMBER(TO_CHAR(S.FECHA, 'YYYYMMDD')) AS FECHA_KEY,
        S.HORA,
        S.RONDA,
        S.ESTADIO,
        S.CIUDAD,
        S.PAIS,
        S.EQUIPO_LOCAL,
        S.GOL_LOCAL,
        S.EQUIPO_VISITA,
        S.GOL_VISITA,
        S.ASISTENCIA,
        H.HORA_KEY,
        RON.RONDA_KEY,
        EST.ESTADIO_KEY,
        C.CIUDAD_KEY,
        P.PAIS_KEY,
        L.SELECCION_KEY AS LOCAL_KEY,
        V.SELECCION_KEY AS VISITANTE_KEY
      FROM stage.BD2_STG_DATOS S
      LEFT JOIN DW.BD2_DIM_HORA H ON S.HORA = H.HORA
      LEFT JOIN DW.BD2_DIM_RONDA RON ON S.RONDA = RON.NOMBRE_RONDA
      LEFT JOIN DW.BD2_DIM_ESTADIO EST ON S.ESTADIO = EST.NOMBRE_ESTADIO
      LEFT JOIN DW.BD2_DIM_CIUDAD C ON S.CIUDAD = C.CIUDAD_ORGANIZADOR
      LEFT JOIN DW.BD2_DIM_PAIS_ORGANIZADOR P ON S.PAIS = P.NOMBRE_PAIS_ORGANIZADOR
      LEFT JOIN DW.BD2_DIM_SELECCION L ON S.EQUIPO_LOCAL = L.NOMBRE_SELECCION
      LEFT JOIN DW.BD2_DIM_SELECCION V ON S.EQUIPO_VISITA = V.NOMBRE_SELECCION
    ) LOOP

         DBMS_OUTPUT.PUT_LINE(r.ANIO || ', ' || r.FECHA || ', ' || r.HORA || ', ' || r.RONDA || ', ' ||r.ESTADIO || ', ' || r.CIUDAD || ', ' || r.PAIS || ', ' ||r.EQUIPO_LOCAL || ', ' || r.GOL_LOCAL || ', ' ||r.EQUIPO_VISITA || ', ' || r.GOL_VISITA || ', ' ||r.ASISTENCIA);

      IF r.HORA_KEY IS NOT NULL AND r.RONDA_KEY IS NOT NULL AND r.ESTADIO_KEY IS NOT NULL AND
         r.CIUDAD_KEY IS NOT NULL AND r.PAIS_KEY IS NOT NULL AND
         r.LOCAL_KEY IS NOT NULL AND r.VISITANTE_KEY IS NOT NULL THEN

             INSERT INTO DW.BD2_HECHOS (
          ANIO, FECHA_KEY, HORA_KEY, RONDA_KEY, ESTADIO_KEY,
          LOCAL_KEY, VISITANTE_KEY, GOL_LOCAL, GOL_VISITA, ASISTENCIA
        ) VALUES (
          r.ANIO, r.FECHA_KEY, r.HORA_KEY, r.RONDA_KEY, r.ESTADIO_KEY,
          r.LOCAL_KEY, r.VISITANTE_KEY, r.GOL_LOCAL, r.GOL_VISITA, r.ASISTENCIA
        );
      ELSE

       INSERT INTO DW.BD2_NO_HECHOS (
          ANIO, FECHA_COD, HORA_COD, NOMBRE_RONDA, ESTADIO, CIUDAD, PAIS,
          EQUIPO_LOCAL, GOL_LOCAL, EQUIPO_VISITA, GOL_VISITA, ASISTENCIA
        ) VALUES (
          r.ANIO, r.FECHA, TRIM(r.HORA), r.RONDA, r.ESTADIO, r.CIUDAD, r.PAIS,
          r.EQUIPO_LOCAL, r.GOL_LOCAL, r.EQUIPO_VISITA, r.GOL_VISITA, r.ASISTENCIA
        );
      END IF;
    END LOOP;

  ELSIF p_param = 2 THEN
    FOR r IN (
      SELECT
        NH.ANIO,
        NH.FECHA_COD,
        TO_NUMBER(TO_CHAR(NH.FECHA_COD, 'YYYYMMDD')) AS FECHA_KEY,
        NH.HORA_COD,
        NH.NOMBRE_RONDA,
        NH.ESTADIO,
        NH.CIUDAD,
        NH.PAIS,
        NH.EQUIPO_LOCAL,
        NH.GOL_LOCAL,
        NH.EQUIPO_VISITA,
        NH.GOL_VISITA,
        NH.ASISTENCIA,
        H.HORA_KEY,
        RON.RONDA_KEY,
        EST.ESTADIO_KEY,
        C.CIUDAD_KEY,
        P.PAIS_KEY,
        L.SELECCION_KEY AS LOCAL_KEY,
        V.SELECCION_KEY AS VISITANTE_KEY
      FROM DW.BD2_NO_HECHOS NH
      LEFT JOIN DW.BD2_DIM_HORA H ON NH.HORA_COD = H.HORA
      LEFT JOIN DW.BD2_DIM_RONDA RON ON NH.NOMBRE_RONDA = RON.NOMBRE_RONDA
      LEFT JOIN DW.BD2_DIM_ESTADIO EST ON NH.ESTADIO = EST.NOMBRE_ESTADIO
      LEFT JOIN DW.BD2_DIM_CIUDAD C ON NH.CIUDAD = C.CIUDAD_ORGANIZADOR
      LEFT JOIN DW.BD2_DIM_PAIS_ORGANIZADOR P ON NH.PAIS = P.NOMBRE_PAIS_ORGANIZADOR
      LEFT JOIN DW.BD2_DIM_SELECCION L ON NH.EQUIPO_LOCAL = L.NOMBRE_SELECCION
      LEFT JOIN DW.BD2_DIM_SELECCION V ON NH.EQUIPO_VISITA = V.NOMBRE_SELECCION
    ) LOOP
      INSERT INTO DW.BD2_HECHOS (
        ANIO, FECHA_KEY, HORA_KEY, RONDA_KEY, ESTADIO_KEY,
        LOCAL_KEY, VISITANTE_KEY, GOL_LOCAL, GOL_VISITA, ASISTENCIA
      ) VALUES (
        r.ANIO, r.FECHA_KEY, r.HORA_KEY, r.RONDA_KEY, r.ESTADIO_KEY,
        r.LOCAL_KEY, r.VISITANTE_KEY, r.GOL_LOCAL, r.GOL_VISITA, r.ASISTENCIA
      );
    END LOOP;
  END IF;
END;
/





-- ==========================================
-- Procedimiento: PRC_DIMENSIONES_FALTANTES
-- Detecta claves nulas en NO_HECHOS y ejecuta PRC_DIM_* con parámetro 2
-- ==========================================
CREATE OR REPLACE PROCEDURE PRC_DIMENSIONES_FALTANTES IS
BEGIN
  FOR r IN (
    SELECT DISTINCT 'BD2_DIM_HORA' AS DIM FROM DW.BD2_NO_HECHOS WHERE HORA_KEY IS NULL
    UNION
    SELECT DISTINCT 'BD2_DIM_RONDA' FROM DW.BD2_NO_HECHOS WHERE RONDA_KEY IS NULL
    UNION
    SELECT DISTINCT 'BD2_DIM_ESTADIO' FROM DW.BD2_NO_HECHOS WHERE ESTADIO_KEY IS NULL
    UNION
    SELECT DISTINCT 'BD2_DIM_CIUDAD' FROM DW.BD2_NO_HECHOS WHERE CIUDAD IS NULL
    UNION
    SELECT DISTINCT 'BD2_DIM_PAIS_ORGANIZADOR' FROM DW.BD2_NO_HECHOS WHERE PAIS IS NULL
    UNION
    SELECT DISTINCT 'BD2_DIM_SELECCION' FROM DW.BD2_NO_HECHOS WHERE LOCAL_KEY IS NULL OR VISITANTE_KEY IS NULL
  ) LOOP
    IF r.DIM = 'BD2_DIM_HORA' THEN PRC_DIM_HORA(2);
    ELSIF r.DIM = 'BD2_DIM_RONDA' THEN PRC_DIM_RONDA(2);
    ELSIF r.DIM = 'BD2_DIM_ESTADIO' THEN PRC_DIM_ESTADIO(2);
    ELSIF r.DIM = 'BD2_DIM_CIUDAD' THEN PRC_DIM_CIUDAD(2);
    ELSIF r.DIM = 'BD2_DIM_PAIS_ORGANIZADOR' THEN PRC_DIM_PAIS_ORGANIZADOR(2);
    ELSIF r.DIM = 'BD2_DIM_SELECCION' THEN PRC_DIM_SELECCION(2);
    END IF;
  END LOOP;
END;
/