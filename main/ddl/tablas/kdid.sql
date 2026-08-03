CREATE  TABLE keplersc.kdid (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(7) NOT NULL DEFAULT ''::character varying,
  c3 character varying(90) NULL,
  c4 character varying(70) NULL,
  c5 character varying(70) NULL,
  c6 character varying(70) NULL,
  c7 character varying(20) NULL,
  c8 character varying(20) NULL,
  c9 character varying(20) NULL,
  c10 character varying(18) NULL,
  c11 character varying(80) NULL,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 character varying(1) NOT NULL DEFAULT ''::character varying,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 character varying(1) NOT NULL DEFAULT ''::character varying,
  c18 character varying(1) NOT NULL DEFAULT ''::character varying,
  c19 character varying(1) NOT NULL DEFAULT ''::character varying,
  c20 character varying(1) NOT NULL DEFAULT ''::character varying,
  c21 character varying(1) NOT NULL DEFAULT ''::character varying,
  c22 character varying(1) NOT NULL DEFAULT ''::character varying,
  c23 character varying(1) NOT NULL DEFAULT ''::character varying,
  c24 character varying(1) NOT NULL DEFAULT ''::character varying,
  c25 character varying(1) NOT NULL DEFAULT ''::character varying,
  c26 character varying(1) NOT NULL DEFAULT ''::character varying,
  c27 character varying(5) NOT NULL DEFAULT ''::character varying,
  c28 character varying(1) NOT NULL DEFAULT ''::character varying,
  c29 character varying(1) NOT NULL DEFAULT ''::character varying,
  c30 character varying(1) NOT NULL DEFAULT ''::character varying,
  c31 character varying(1) NOT NULL DEFAULT ''::character varying,
  c32 character varying(1) NOT NULL DEFAULT ''::character varying,
  c33 character varying(1) NOT NULL DEFAULT ''::character varying,
  c34 character varying(1) NOT NULL DEFAULT ''::character varying,
  c35 character varying(1) NOT NULL DEFAULT ''::character varying,
  c36 character varying(1) NOT NULL DEFAULT ''::character varying,
  c37 character varying(1) NOT NULL DEFAULT ''::character varying,
  c38 character varying(1) NOT NULL DEFAULT ''::character varying,
  c39 character varying(1) NOT NULL DEFAULT ''::character varying,
  c40 character varying(1) NOT NULL DEFAULT ''::character varying,
  c41 character varying(1) NOT NULL DEFAULT ''::character varying,
  c42 character varying(1) NOT NULL DEFAULT ''::character varying,
  c43 character varying(1) NOT NULL DEFAULT ''::character varying,
  c44 character varying(1) NOT NULL DEFAULT ''::character varying,
  c45 character varying(7) NOT NULL DEFAULT ''::character varying,
  c46 character varying(7) NOT NULL DEFAULT ''::character varying,
  c47 character varying(70) NOT NULL DEFAULT ''::character varying,
  c48 character varying(35) NOT NULL DEFAULT ''::character varying,
  c49 character varying(35) NOT NULL DEFAULT ''::character varying,
  c50 character varying(1) NOT NULL DEFAULT ''::character varying,
  c51 character varying(1) NOT NULL DEFAULT ''::character varying,
  c52 character varying(5) NOT NULL DEFAULT ''::character varying,
  c53 character varying(6) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdid ADD CONSTRAINT pk_kdid PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdid02 ON keplersc.kdid USING btree (c3, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdid IS 'Catalogo intercompanias';
COMMENT ON COLUMN keplersc.kdid.c9 IS 'Fax';
COMMENT ON COLUMN keplersc.kdid.c8 IS 'Segundo numero';
COMMENT ON COLUMN keplersc.kdid.c7 IS 'Telefono';
COMMENT ON COLUMN keplersc.kdid.c6 IS 'Poblacion';
COMMENT ON COLUMN keplersc.kdid.c5 IS 'Colonia';
COMMENT ON COLUMN keplersc.kdid.c4 IS 'Calle y numero';
COMMENT ON COLUMN keplersc.kdid.c3 IS 'Nombre del proveedor';
COMMENT ON COLUMN keplersc.kdid.c2 IS 'Clave';
COMMENT ON COLUMN keplersc.kdid.c11 IS 'Correo electronico';
COMMENT ON COLUMN keplersc.kdid.c10 IS 'RFC';
COMMENT ON COLUMN keplersc.kdid.c1 IS 'Sucursal';

