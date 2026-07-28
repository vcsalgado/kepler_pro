CREATE  TABLE keplersc.kdms (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 character varying(3) NOT NULL DEFAULT ''::character varying,
  c4 character varying(50) NOT NULL DEFAULT ''::character varying,
  c5 character varying(30) NOT NULL DEFAULT ''::character varying,
  c6 character varying(5) NOT NULL DEFAULT ''::character varying,
  c7 character varying(5) NOT NULL DEFAULT ''::character varying,
  c8 character varying(5) NOT NULL DEFAULT ''::character varying,
  c9 character varying(7) NOT NULL DEFAULT ''::character varying,
  c10 character varying(16) NOT NULL DEFAULT ''::character varying,
  c11 character varying(16) NOT NULL DEFAULT ''::character varying,
  c12 character varying(100) NOT NULL DEFAULT ''::character varying,
  col_nombre_publico character varying NOT NULL DEFAULT ''::character varying,
  col_direccion character varying NOT NULL DEFAULT ''::character varying,
  col_telefono character varying NOT NULL DEFAULT ''::character varying,
  col_fax character varying NOT NULL DEFAULT ''::character varying,
  col_paginaweb character varying NOT NULL DEFAULT ''::character varying,
  nombre_firma_atn_ctes character varying NOT NULL DEFAULT ''::character varying,
  col_kodawari character varying(1) NOT NULL DEFAULT 'N'::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdms ADD CONSTRAINT kdms_pk PRIMARY KEY (c1);
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdms ON keplersc.kdms USING btree (c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdms02 ON keplersc.kdms USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdms IS 'Sucursales';
COMMENT ON COLUMN keplersc.kdms.nombre_firma_atn_ctes IS 'Nombre gerente Atn a clientes ';
COMMENT ON COLUMN keplersc.kdms.col_telefono IS 'Telefono';
COMMENT ON COLUMN keplersc.kdms.col_paginaweb IS 'Pagina web';
COMMENT ON COLUMN keplersc.kdms.col_kodawari IS 'S o N';
COMMENT ON COLUMN keplersc.kdms.col_fax IS 'Fax';
COMMENT ON COLUMN keplersc.kdms.col_direccion IS 'Direccion completa';
COMMENT ON COLUMN keplersc.kdms.c6 IS 'Codigo Postal';
COMMENT ON COLUMN keplersc.kdms.c5 IS 'Clave distribuidor';
COMMENT ON COLUMN keplersc.kdms.c4 IS 'Lugar expedicion';
COMMENT ON COLUMN keplersc.kdms.c3 IS 'Identificacion';
COMMENT ON COLUMN keplersc.kdms.c2 IS 'Nombre';
COMMENT ON COLUMN keplersc.kdms.c12 IS 'Time zone';
COMMENT ON COLUMN keplersc.kdms.c1 IS 'Sucursal';

