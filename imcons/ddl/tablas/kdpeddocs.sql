CREATE  TABLE keplersc.kdpeddocs (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c5 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdpeddocs ADD CONSTRAINT pk_kdpeddocs PRIMARY KEY (c1, c2, c3);
COMMENT ON COLUMN keplersc.kdpeddocs.c5 IS 'Pago';
COMMENT ON COLUMN keplersc.kdpeddocs.c4 IS 'Vencimiento';
COMMENT ON COLUMN keplersc.kdpeddocs.c3 IS 'Documento';
COMMENT ON COLUMN keplersc.kdpeddocs.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdpeddocs.c1 IS 'Sucursal';

