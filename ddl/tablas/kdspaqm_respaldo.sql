CREATE  TABLE keplersc.kdspaqm_respaldo (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(5) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(20) NOT NULL DEFAULT ''::character varying,
  c7 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdspaqm_respaldo ADD CONSTRAINT pk_kdspaqm_respaldo PRIMARY KEY (c1, c2, c4, c6);
COMMENT ON COLUMN keplersc.kdspaqm_respaldo.c7 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdspaqm_respaldo.c6 IS 'Clave';
COMMENT ON COLUMN keplersc.kdspaqm_respaldo.c4 IS 'Clave paquete';
COMMENT ON COLUMN keplersc.kdspaqm_respaldo.c3 IS 'Clave_Anio';
COMMENT ON COLUMN keplersc.kdspaqm_respaldo.c2 IS 'Clave modelo';
COMMENT ON COLUMN keplersc.kdspaqm_respaldo.c1 IS 'Clave marca';

