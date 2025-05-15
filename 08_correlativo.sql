--Para manejo de correlativos
CREATE OR REPLACE PROCEDURE DW.PRC_DEVUELVE_CORRELATIVOS (
    p_nombre_dimension IN VARCHAR2,
    p_correlativo_salida OUT NUMBER
)
IS
    PRAGMA AUTONOMOUS_TRANSACTION; -- ¡ESTA LÍNEA ES CRUCIAL!
    v_contador NUMBER;
    v_valor_actual NUMBER;
BEGIN
    -- Verificar si la dimensión ya existe en la tabla de correlativos
    SELECT COUNT(*)
    INTO v_contador
    FROM DW.BD2_CORRELATIVOS
    WHERE DIMENSION = UPPER(p_nombre_dimension);

    IF v_contador = 0 THEN
        -- La dimensión no existe, insertarla y establecer el primer valor
        INSERT INTO DW.BD2_CORRELATIVOS (DIMENSION, VALOR)
        VALUES (UPPER(p_nombre_dimension), 1); -- El valor que se usará

        p_correlativo_salida := 1; -- Devolver 1 como el primer valor

        -- Actualizar para el siguiente llamado (el valor en tabla será 2)
        UPDATE DW.BD2_CORRELATIVOS
        SET VALOR = VALOR + 1
        WHERE DIMENSION = UPPER(p_nombre_dimension);

    ELSE
        -- La dimensión existe, obtener el valor actual para devolverlo y luego incrementarlo para el próximo uso
        SELECT VALOR
        INTO v_valor_actual
        FROM DW.BD2_CORRELATIVOS
        WHERE DIMENSION = UPPER(p_nombre_dimension)
        FOR UPDATE; -- Bloquear la fila para evitar condiciones de carrera si la concurrencia es una preocupación

        p_correlativo_salida := v_valor_actual; -- Devolver el valor actual

        -- Incrementar el valor en la tabla para el próximo uso
        UPDATE DW.BD2_CORRELATIVOS
        SET VALOR = v_valor_actual + 1
        WHERE DIMENSION = UPPER(p_nombre_dimension);

    END IF;

    COMMIT; -- COMMIT de la transacción autónoma. Esto es seguro gracias a PRAGMA AUTONOMOUS_TRANSACTION.

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- ROLLBACK de la transacción autónoma en caso de error.
        -- Considera registrar el error o usar RAISE_APPLICATION_ERROR para dar más detalles.
        -- DBMS_OUTPUT.PUT_LINE('Error en PRC_DEVUELVE_CORRELATIVOS (Autonomo): ' || SQLERRM); -- Para depuración
        RAISE; -- Propagar la excepción para que el trigger y la sentencia INSERT fallen.
END PRC_DEVUELVE_CORRELATIVOS;
/

--TRIGGERS PARA MANEJO DE CORRELATIVOS DE CADA DIMENSIÓN

--dim_hora
CREATE OR REPLACE TRIGGER DW.TRG_BD2_DIM_HORA_KEY
BEFORE INSERT ON DW.BD2_DIM_HORA
FOR EACH ROW
BEGIN
    IF :NEW.HORA_KEY IS NULL THEN
        DW.PRC_DEVUELVE_CORRELATIVOS(
            p_nombre_dimension => 'DIM_HORA',
            p_correlativo_salida => :NEW.HORA_KEY
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error al generar KEY para BD2_DIM_HORA: ' || SQLERRM);
END TRG_BD2_DIM_HORA_KEY;
/
--dim_seleccion
CREATE OR REPLACE TRIGGER DW.TRG_BD2_DIM_SELECCION_KEY
BEFORE INSERT ON DW.BD2_DIM_SELECCION
FOR EACH ROW
BEGIN
    IF :NEW.SELECCION_KEY IS NULL THEN
        DW.PRC_DEVUELVE_CORRELATIVOS(
            p_nombre_dimension => 'DIM_SELECCION',
            p_correlativo_salida => :NEW.SELECCION_KEY
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error al generar KEY para BD2_DIM_SELECCION: ' || SQLERRM);
END TRG_BD2_DIM_SELECCION_KEY;
/
--dim_ronda
CREATE OR REPLACE TRIGGER DW.TRG_BD2_DIM_RONDA_KEY
BEFORE INSERT ON DW.BD2_DIM_RONDA
FOR EACH ROW
BEGIN
    IF :NEW.RONDA_KEY IS NULL THEN
        DW.PRC_DEVUELVE_CORRELATIVOS(
            p_nombre_dimension => 'DIM_RONDA',
            p_correlativo_salida => :NEW.RONDA_KEY
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error al generar KEY para BD2_DIM_RONDA: ' || SQLERRM);
END TRG_BD2_DIM_RONDA_KEY;
/
--dim_pais
CREATE OR REPLACE TRIGGER DW.TRG_BD2_DIM_PAIS_ORG_KEY  -- Nombre abreviado para evitar que sea muy largo
BEFORE INSERT ON DW.BD2_DIM_PAIS_ORGANIZADOR
FOR EACH ROW
BEGIN
    IF :NEW.PAIS_KEY IS NULL THEN
        DW.PRC_DEVUELVE_CORRELATIVOS(
            p_nombre_dimension => 'DIM_PAIS_ORGANIZADOR',
            p_correlativo_salida => :NEW.PAIS_KEY
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error al generar KEY para BD2_DIM_PAIS_ORGANIZADOR: ' || SQLERRM);
END TRG_BD2_DIM_PAIS_ORG_KEY;
/
--dim_pais
CREATE OR REPLACE TRIGGER DW.TRG_BD2_DIM_CIUDAD_KEY
BEFORE INSERT ON DW.BD2_DIM_CIUDAD
FOR EACH ROW
BEGIN
    IF :NEW.CIUDAD_KEY IS NULL THEN
        DW.PRC_DEVUELVE_CORRELATIVOS(
            p_nombre_dimension => 'DIM_CIUDAD',
            p_correlativo_salida => :NEW.CIUDAD_KEY
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20005, 'Error al generar KEY para BD2_DIM_CIUDAD: ' || SQLERRM);
END TRG_BD2_DIM_CIUDAD_KEY;
/
--dim_estadio
CREATE OR REPLACE TRIGGER DW.TRG_BD2_DIM_ESTADIO_KEY
BEFORE INSERT ON DW.BD2_DIM_ESTADIO
FOR EACH ROW
BEGIN
    IF :NEW.ESTADIO_KEY IS NULL THEN
        DW.PRC_DEVUELVE_CORRELATIVOS(
            p_nombre_dimension => 'DIM_ESTADIO',
            p_correlativo_salida => :NEW.ESTADIO_KEY
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20006, 'Error al generar KEY para BD2_DIM_ESTADIO: ' || SQLERRM);
END TRG_BD2_DIM_ESTADIO_KEY;
/

