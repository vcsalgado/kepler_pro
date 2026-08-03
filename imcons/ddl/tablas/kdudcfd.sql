CREATE  TABLE keplersc.kdudcfd (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(130) NOT NULL DEFAULT ''::character varying,
  c3 character varying(80) NOT NULL DEFAULT ''::character varying,
  c4 character varying(70) NOT NULL DEFAULT ''::character varying,
  c5 character varying(27) NOT NULL DEFAULT ''::character varying,
  c6 character varying(30) NOT NULL DEFAULT ''::character varying,
  c7 character varying(70) NOT NULL DEFAULT ''::character varying,
  c8 character varying(35) NOT NULL DEFAULT ''::character varying,
  c9 character varying(35) NOT NULL DEFAULT ''::character varying,
  c10 character varying(7) NOT NULL DEFAULT ''::character varying,
  c11 character varying(18) NOT NULL DEFAULT ''::character varying,
  c12 character varying(100) NOT NULL DEFAULT ''::character varying,
  c13 character varying(7) NOT NULL DEFAULT ''::character varying,
  c14 character varying(70) NOT NULL DEFAULT ''::character varying,
  c15 character varying(1) NOT NULL DEFAULT ''::character varying,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 character varying(1) NOT NULL DEFAULT ''::character varying,
  c18 character varying(1) NOT NULL DEFAULT ''::character varying,
  c19 character varying(1) NOT NULL DEFAULT ''::character varying,
  c20 character varying(2) NOT NULL DEFAULT ''::character varying,
  c21 character varying(3) NOT NULL DEFAULT ''::character varying,
  c22 character varying(50) NOT NULL DEFAULT ''::character varying,
  c23 character varying(4) NOT NULL DEFAULT ''::character varying,
  c24 character varying(3) NOT NULL DEFAULT ''::character varying,
  c25 character varying(80) NOT NULL DEFAULT ''::character varying,
  tipo_relacion character varying NOT NULL DEFAULT ''::character varying,
  genero_doctorel character varying(1) NOT NULL DEFAULT ''::character varying,
  naturaleza_doctorel character varying(1) NOT NULL DEFAULT ''::character varying,
  grupo_doctorel numeric NOT NULL DEFAULT 0,
  tipo_doctorel numeric NOT NULL DEFAULT 0,
  folio_relacionado character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdudcfd ADD CONSTRAINT pk_kdudcfd PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdudcfd.tipo_relacion IS 'Tipo de relacion CFDI';
COMMENT ON COLUMN keplersc.kdudcfd.tipo_doctorel IS 'Tipo documento relacionado';
COMMENT ON COLUMN keplersc.kdudcfd.naturaleza_doctorel IS 'Naturaleza documento relacionado';
COMMENT ON COLUMN keplersc.kdudcfd.grupo_doctorel IS 'Grupo documento relacionado';
COMMENT ON COLUMN keplersc.kdudcfd.genero_doctorel IS 'Genero documento relacionado';
COMMENT ON COLUMN keplersc.kdudcfd.folio_relacionado IS 'Folio relacionado';
COMMENT ON COLUMN keplersc.kdudcfd.c9 IS 'Pais';
COMMENT ON COLUMN keplersc.kdudcfd.c8 IS 'Estado';
COMMENT ON COLUMN keplersc.kdudcfd.c7 IS 'Municipio';
COMMENT ON COLUMN keplersc.kdudcfd.c6 IS 'Num Interior';
COMMENT ON COLUMN keplersc.kdudcfd.c5 IS 'Num Exterior';
COMMENT ON COLUMN keplersc.kdudcfd.c4 IS 'Colonia';
COMMENT ON COLUMN keplersc.kdudcfd.c3 IS 'Calle y numero';
COMMENT ON COLUMN keplersc.kdudcfd.c25 IS 'Descripcion del Regimen Fiscal';
COMMENT ON COLUMN keplersc.kdudcfd.c24 IS 'Clave del Regimen Fiscal';
COMMENT ON COLUMN keplersc.kdudcfd.c23 IS 'Uso del CFDI';
COMMENT ON COLUMN keplersc.kdudcfd.c22 IS 'Numero Cuenta Pago';
COMMENT ON COLUMN keplersc.kdudcfd.c21 IS 'Metodo de Pago';
COMMENT ON COLUMN keplersc.kdudcfd.c20 IS 'Forma de Pago';
COMMENT ON COLUMN keplersc.kdudcfd.c2 IS 'Nombre del cliente';
COMMENT ON COLUMN keplersc.kdudcfd.c14 IS 'Ciudad o Poblacion';
COMMENT ON COLUMN keplersc.kdudcfd.c13 IS 'Clave Sucursal';
COMMENT ON COLUMN keplersc.kdudcfd.c12 IS 'Correo Electronico';
COMMENT ON COLUMN keplersc.kdudcfd.c11 IS 'RFC';
COMMENT ON COLUMN keplersc.kdudcfd.c10 IS 'Codigo Postal';
COMMENT ON COLUMN keplersc.kdudcfd.c1 IS 'Clave del cliente';

