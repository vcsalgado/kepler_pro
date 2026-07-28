CREATE  TABLE keplersc.kdlealtadmov (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(5) NOT NULL DEFAULT ''::character varying,
  c7 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c8 numeric(10,5) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdlealtadmov ADD CONSTRAINT pk_kdlealtadmov PRIMARY KEY (c1, c2, c3, c4);
COMMENT ON COLUMN keplersc.kdlealtadmov.c8 IS '% Descuento';
COMMENT ON COLUMN keplersc.kdlealtadmov.c7 IS 'Fecha de Cierre';
COMMENT ON COLUMN keplersc.kdlealtadmov.c6 IS 'Clave Paquete';
COMMENT ON COLUMN keplersc.kdlealtadmov.c5 IS 'Tipo Punto';
COMMENT ON COLUMN keplersc.kdlealtadmov.c4 IS 'Punto';
COMMENT ON COLUMN keplersc.kdlealtadmov.c3 IS 'Orden';
COMMENT ON COLUMN keplersc.kdlealtadmov.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdlealtadmov.c1 IS 'Sucursal';

