CREATE  TABLE keplersc.kdcp (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying,
  c3 character varying(7) NOT NULL DEFAULT ''::character varying,
  c4 character varying(7) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(40) NOT NULL DEFAULT ''::character varying,
  c7 character varying(40) NOT NULL DEFAULT ''::character varying,
  c8 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c10 numeric NOT NULL DEFAULT 0,
  c11 numeric NOT NULL DEFAULT 0,
  c12 character varying(7) NOT NULL DEFAULT ''::character varying,
  c13 character varying(70) NOT NULL DEFAULT ''::character varying,
  c14 character varying(70) NOT NULL DEFAULT ''::character varying,
  c15 character varying(70) NOT NULL DEFAULT ''::character varying,
  c16 character varying(18) NOT NULL DEFAULT ''::character varying,
  c17 double precision NOT NULL DEFAULT 0,
  c18 double precision NOT NULL DEFAULT 0,
  c19 numeric(15,2) NOT NULL DEFAULT 0,
  c20 character varying(1) NOT NULL DEFAULT ''::character varying,
  c21 character varying(1) NOT NULL DEFAULT ''::character varying,
  c22 numeric NOT NULL DEFAULT 0,
  c23 numeric NOT NULL DEFAULT 0,
  c24 character varying(7) NOT NULL DEFAULT ''::character varying,
  c25 numeric NOT NULL DEFAULT 0,
  c26 numeric NOT NULL DEFAULT 0,
  c27 character varying(6) NOT NULL DEFAULT ''::character varying,
  c28 character varying(6) NOT NULL DEFAULT ''::character varying,
  c29 character varying(6) NOT NULL DEFAULT ''::character varying,
  c30 character varying(6) NOT NULL DEFAULT ''::character varying,
  c31 character varying(6) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcp ADD CONSTRAINT pk_kdcp PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdcp02 ON keplersc.kdcp USING btree (c4, c20, c21, c22, c23, c24, c25, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcp03 ON keplersc.kdcp USING btree (c5, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcp IS 'Orden de trabajo';
COMMENT ON COLUMN keplersc.kdcp.c9 IS 'Fecha entrega';
COMMENT ON COLUMN keplersc.kdcp.c8 IS 'Fecha contrato';
COMMENT ON COLUMN keplersc.kdcp.c7 IS 'Nombre contacto';
COMMENT ON COLUMN keplersc.kdcp.c6 IS 'Nombre encargado';
COMMENT ON COLUMN keplersc.kdcp.c5 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdcp.c4 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdcp.c3 IS 'Clave cliente';
COMMENT ON COLUMN keplersc.kdcp.c2 IS 'Descripcion orden';
COMMENT ON COLUMN keplersc.kdcp.c15 IS 'Notas';
COMMENT ON COLUMN keplersc.kdcp.c14 IS 'Notas';
COMMENT ON COLUMN keplersc.kdcp.c13 IS 'Notas';
COMMENT ON COLUMN keplersc.kdcp.c12 IS 'Folio docto cotizacion';
COMMENT ON COLUMN keplersc.kdcp.c11 IS 'Tipo docto cotizacion';
COMMENT ON COLUMN keplersc.kdcp.c10 IS 'Grupo docto cotizacion';
COMMENT ON COLUMN keplersc.kdcp.c1 IS 'Folio orden';

