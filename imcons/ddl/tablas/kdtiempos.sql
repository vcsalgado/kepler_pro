CREATE  TABLE keplersc.kdtiempos (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c7 character varying(8) NOT NULL DEFAULT ''::character varying,
  c8 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c9 character varying(8) NOT NULL DEFAULT ''::character varying,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  c11 character varying(20) NOT NULL DEFAULT ''::character varying,
  c12 character varying(5) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtiempos ADD CONSTRAINT pk_kdtiempos PRIMARY KEY (c1, c2, c3, c4, c5);
COMMENT ON COLUMN keplersc.kdtiempos.c9 IS 'Hora Fin';
COMMENT ON COLUMN keplersc.kdtiempos.c8 IS 'Fecha Fin';
COMMENT ON COLUMN keplersc.kdtiempos.c7 IS 'Hora Inicio';
COMMENT ON COLUMN keplersc.kdtiempos.c6 IS 'Fecha Inicio';
COMMENT ON COLUMN keplersc.kdtiempos.c5 IS 'Consecutivo';
COMMENT ON COLUMN keplersc.kdtiempos.c4 IS 'Punto Orden';
COMMENT ON COLUMN keplersc.kdtiempos.c3 IS 'Folio Orden';
COMMENT ON COLUMN keplersc.kdtiempos.c2 IS 'Tipo Orden';
COMMENT ON COLUMN keplersc.kdtiempos.c12 IS 'Clave Tecnico';
COMMENT ON COLUMN keplersc.kdtiempos.c11 IS 'Usuario Tecnico';
COMMENT ON COLUMN keplersc.kdtiempos.c10 IS 'Mins transcurridos';
COMMENT ON COLUMN keplersc.kdtiempos.c1 IS 'Sucursal';

