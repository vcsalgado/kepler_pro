CREATE  TABLE keplersc.kdconfgen (
  c1 numeric NOT NULL DEFAULT 0,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 character varying(7) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdconfgen ADD CONSTRAINT pk_kdconfgen PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdconfgen IS 'Configuracion general';
COMMENT ON COLUMN keplersc.kdconfgen.c3 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdconfgen.c2 IS 'Directorio de datos de refacciones';
COMMENT ON COLUMN keplersc.kdconfgen.c1 IS 'ID';

