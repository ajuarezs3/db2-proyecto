CREATE TABLE BD2_STG_DATOS
   ( ANIO 			NUMBER,
     FECHA  		DATE,
	 HORA			VARCHAR2(8 BYTE),
	 RONDA			VARCHAR2(50 BYTE),
	 ESTADIO		VARCHAR2(100 BYTE),
	 CIUDAD			VARCHAR2(100 BYTE),
	 PAIS			VARCHAR2(100 BYTE),
	 EQUIPO_LOCAL	VARCHAR2(100 BYTE),
	 GOL_LOCAL		NUMBER,
	 EQUIPO_VISITA	VARCHAR2(100 BYTE),
	 GOL_VISITA		NUMBER,
	 ASISTENCIA		NUMBER
   ) ;

