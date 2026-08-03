CREATE  TABLE keplersc.kdtipocomis (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtipocomis ADD CONSTRAINT pk_kdtipocomis PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdtipocomis IS 'Ventas tipo de comision';
COMMENT ON COLUMN keplersc.kdtipocomis.c6 IS 'Lim sup edad 3';
COMMENT ON COLUMN keplersc.kdtipocomis.c5 IS 'Lim sup edad 2';
COMMENT ON COLUMN keplersc.kdtipocomis.c4 IS 'Lim sup edad 1';
COMMENT ON COLUMN keplersc.kdtipocomis.c3 IS '0 importe 10 Utilidad 20 Precio 30 Cuota fija';
COMMENT ON COLUMN keplersc.kdtipocomis.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdtipocomis.c1 IS 'Clasificacion de la comision';

