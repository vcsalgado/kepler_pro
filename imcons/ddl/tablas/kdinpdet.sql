CREATE  TABLE keplersc.kdinpdet (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(18) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdinpdet ADD CONSTRAINT pk_kdinpdet PRIMARY KEY (c1, c2);
COMMENT ON TABLE keplersc.kdinpdet IS 'PEdido sugerido resumen mensual producto';
COMMENT ON COLUMN keplersc.kdinpdet.c8 IS 'Ventas mes 6 (hace 1 mes)';
COMMENT ON COLUMN keplersc.kdinpdet.c7 IS 'Ventas mes 5 (hace 2 meses)';
COMMENT ON COLUMN keplersc.kdinpdet.c6 IS 'Ventas mes 4 (hace 3 meses)';
COMMENT ON COLUMN keplersc.kdinpdet.c5 IS 'Ventas mes 3 (hace 4 meses)';
COMMENT ON COLUMN keplersc.kdinpdet.c4 IS 'Ventas mes 2 (hace 5 meses)';
COMMENT ON COLUMN keplersc.kdinpdet.c3 IS 'Ventas mes 1 (hace 6 meses)';
COMMENT ON COLUMN keplersc.kdinpdet.c2 IS 'Numero Original';
COMMENT ON COLUMN keplersc.kdinpdet.c1 IS 'Sucursal';

