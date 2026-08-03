CREATE  TABLE keplersc.kdcoachsem (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c4 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcoachsem ADD CONSTRAINT pk_kdcoachsem PRIMARY KEY (c1, c2, c3);
COMMENT ON COLUMN keplersc.kdcoachsem.c4 IS 'Comision';
COMMENT ON COLUMN keplersc.kdcoachsem.c3 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdcoachsem.c2 IS 'Coach';
COMMENT ON COLUMN keplersc.kdcoachsem.c1 IS 'Sucursal';

