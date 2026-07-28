CREATE  TABLE keplersc.cat_arrendadoras (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  clave_arrendadora character varying(5) NOT NULL DEFAULT ''::character varying,
  nombre_arrendadora character varying(50) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.cat_arrendadoras ADD CONSTRAINT cat_arrendadoras_pk PRIMARY KEY (sucursal, clave_arrendadora);
COMMENT ON TABLE keplersc.cat_arrendadoras IS 'Catalogo de Arrendadoras';
COMMENT ON COLUMN keplersc.cat_arrendadoras.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.cat_arrendadoras.nombre_arrendadora IS 'Nombre de la arrendadora';
COMMENT ON COLUMN keplersc.cat_arrendadoras.clave_arrendadora IS 'Identificador de la arrendadora';

