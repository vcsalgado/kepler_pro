CREATE  TABLE keplersc.kdbonolineacoaches (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 character varying(2) NOT NULL DEFAULT ''::character varying,
  c5 character varying(2) NOT NULL DEFAULT ''::character varying,
  c6 numeric NOT NULL DEFAULT 0,
  c7 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdbonolineacoaches ADD CONSTRAINT pk_kdbonolineacoaches PRIMARY KEY (c1, c2, c3, c4, c5);
COMMENT ON TABLE keplersc.kdbonolineacoaches IS 'Objetivos por linea para Coach';
COMMENT ON COLUMN keplersc.kdbonolineacoaches.c7 IS 'Bono';
COMMENT ON COLUMN keplersc.kdbonolineacoaches.c6 IS 'Objetivo';
COMMENT ON COLUMN keplersc.kdbonolineacoaches.c5 IS 'Mes';
COMMENT ON COLUMN keplersc.kdbonolineacoaches.c4 IS 'Anio';
COMMENT ON COLUMN keplersc.kdbonolineacoaches.c3 IS 'Clave Linea';
COMMENT ON COLUMN keplersc.kdbonolineacoaches.c2 IS 'Clave Esquema';
COMMENT ON COLUMN keplersc.kdbonolineacoaches.c1 IS 'Sucursal';

