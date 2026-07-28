CREATE  TABLE keplersc.kdinp (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(18) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric(10,2) NOT NULL DEFAULT 0,
  c5 numeric(10,2) NOT NULL DEFAULT 0,
  c6 numeric(10,2) NOT NULL DEFAULT 0,
  c7 numeric(10,2) NOT NULL DEFAULT 0,
  c8 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdinp ON keplersc.kdinp USING btree (c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinp02 ON keplersc.kdinp USING btree (c3, c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinp03 ON keplersc.kdinp USING btree (c7) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinp04 ON keplersc.kdinp USING btree (c8, c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinp05 ON keplersc.kdinp USING btree (c4, c1, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdinp IS 'Pedido sugerido detalle';
COMMENT ON COLUMN keplersc.kdinp.c8 IS 'MAD 12 meses';
COMMENT ON COLUMN keplersc.kdinp.c7 IS 'Ventas ultimo mes';
COMMENT ON COLUMN keplersc.kdinp.c6 IS 'Maxima fluctuacion demanda';
COMMENT ON COLUMN keplersc.kdinp.c5 IS 'MIP';
COMMENT ON COLUMN keplersc.kdinp.c4 IS 'MAD';
COMMENT ON COLUMN keplersc.kdinp.c3 IS 'Phase (Out, In)';
COMMENT ON COLUMN keplersc.kdinp.c2 IS 'Numero Original';
COMMENT ON COLUMN keplersc.kdinp.c1 IS 'Sucursal';

