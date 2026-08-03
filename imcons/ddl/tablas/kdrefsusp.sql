CREATE  TABLE keplersc.kdrefsusp (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(18) NOT NULL DEFAULT ''::character varying,
  c7 character varying(40) NOT NULL DEFAULT ''::character varying,
  c8 numeric(10,5) NOT NULL DEFAULT 0,
  c9 character varying(5) NOT NULL DEFAULT ''::character varying,
  c10 numeric(10,2) NOT NULL DEFAULT 0,
  c11 numeric(10,2) NOT NULL DEFAULT 0,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdrefsusp ADD CONSTRAINT pk_kdrefsusp PRIMARY KEY (c1, c12, c2, c3, c4, c5);
CREATE INDEX IF NOT EXISTS sindkdrefsusp02 ON keplersc.kdrefsusp USING btree (c1, c2, c3, c4, c5) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdrefsusp.c9 IS 'Unidad';
COMMENT ON COLUMN keplersc.kdrefsusp.c8 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdrefsusp.c7 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdrefsusp.c6 IS 'Clave';
COMMENT ON COLUMN keplersc.kdrefsusp.c5 IS 'Partida';
COMMENT ON COLUMN keplersc.kdrefsusp.c4 IS 'Punto';
COMMENT ON COLUMN keplersc.kdrefsusp.c3 IS 'Orden';
COMMENT ON COLUMN keplersc.kdrefsusp.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdrefsusp.c12 IS 'Interna / Externa';
COMMENT ON COLUMN keplersc.kdrefsusp.c11 IS 'Importe';
COMMENT ON COLUMN keplersc.kdrefsusp.c10 IS 'Unitario';
COMMENT ON COLUMN keplersc.kdrefsusp.c1 IS 'Sucursal';

