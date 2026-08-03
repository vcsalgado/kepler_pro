CREATE  TABLE keplersc.kdigm (
  c1 character varying(8) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric(9,2) NOT NULL DEFAULT 0,
  c6 numeric(9,2) NOT NULL DEFAULT 0,
  c7 numeric(9,2) NOT NULL DEFAULT 0,
  c8 character varying(30) NOT NULL DEFAULT ''::character varying,
  c9 character varying(4) NOT NULL DEFAULT ''::character varying,
  c10 character varying(4) NOT NULL DEFAULT ''::character varying,
  c11 numeric NOT NULL DEFAULT 0,
  c12 numeric(9,2) NOT NULL DEFAULT 0,
  c13 numeric NOT NULL DEFAULT 0,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 character varying(1) NOT NULL DEFAULT ''::character varying,
  c16 character varying(3) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdigm ADD CONSTRAINT pk_kdigm PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdigm02 ON keplersc.kdigm USING btree (c2, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdigm03 ON keplersc.kdigm USING btree (c16, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdigm.c9 IS 'Primer Año de Servicio';
COMMENT ON COLUMN keplersc.kdigm.c8 IS 'Aplicacion';
COMMENT ON COLUMN keplersc.kdigm.c7 IS 'Precio Lista c/IVA';
COMMENT ON COLUMN keplersc.kdigm.c6 IS 'Precio Medio Mayoreo';
COMMENT ON COLUMN keplersc.kdigm.c5 IS 'Costo Concesionario';
COMMENT ON COLUMN keplersc.kdigm.c4 IS 'SubGrupo';
COMMENT ON COLUMN keplersc.kdigm.c3 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdigm.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdigm.c16 IS 'Linea de producto';
COMMENT ON COLUMN keplersc.kdigm.c15 IS 'Numeros con reemplazo';
COMMENT ON COLUMN keplersc.kdigm.c14 IS 'Margen Menor a precio de lista';
COMMENT ON COLUMN keplersc.kdigm.c13 IS 'Unidad de Empaque';
COMMENT ON COLUMN keplersc.kdigm.c12 IS 'Precio Casco sin IVA';
COMMENT ON COLUMN keplersc.kdigm.c11 IS 'Codigo Retornable';
COMMENT ON COLUMN keplersc.kdigm.c10 IS 'Ultimo Año de Servicio';
COMMENT ON COLUMN keplersc.kdigm.c1 IS 'Codigo';

