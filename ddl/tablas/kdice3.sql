CREATE  TABLE keplersc.kdice3 (
  c1 character varying(18) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 character varying(40) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdice3 ADD CONSTRAINT pk_kdice3 PRIMARY KEY (c1, c3);
COMMENT ON TABLE keplersc.kdice3 IS 'Catalogo colores interiores';
COMMENT ON COLUMN keplersc.kdice3.c4 IS 'Descripción del color';
COMMENT ON COLUMN keplersc.kdice3.c3 IS 'Cve del color';
COMMENT ON COLUMN keplersc.kdice3.c1 IS 'Clave del Producto';

