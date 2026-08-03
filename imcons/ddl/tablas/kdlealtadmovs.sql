CREATE  TABLE keplersc.kdlealtadmovs (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(5) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric(20,6) NOT NULL DEFAULT 0,
  c10 numeric(20,6) NOT NULL DEFAULT 0,
  precio_original_sin_iva numeric(20,6) NULL DEFAULT 0,
  clave_descuento character varying NULL DEFAULT ''::character varying,
  importe_descuento numeric(20,6) NULL DEFAULT 0,
  base_descuento numeric(20,6) NULL DEFAULT 0,
  gen character varying(1) NULL DEFAULT ''::character varying,
  nat character varying(1) NULL DEFAULT ''::character varying,
  gpo numeric NULL DEFAULT 0,
  tipo numeric NULL DEFAULT 0,
  folio character varying(10) NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdlealtadmovs_c1_idx ON keplersc.kdlealtadmovs USING btree (c1, c2, c3, c4, c7, c8) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdlealtadmovs.tipo IS 'Tipo movto';
COMMENT ON COLUMN keplersc.kdlealtadmovs.precio_original_sin_iva IS 'Precio sin descuento sin iva';
COMMENT ON COLUMN keplersc.kdlealtadmovs.nat IS 'Naturaleza movto';
COMMENT ON COLUMN keplersc.kdlealtadmovs.importe_descuento IS 'Importe del descuento';
COMMENT ON COLUMN keplersc.kdlealtadmovs.gpo IS 'Grupo movto';
COMMENT ON COLUMN keplersc.kdlealtadmovs.gen IS 'Genero del movto';
COMMENT ON COLUMN keplersc.kdlealtadmovs.folio IS 'folio movto';
COMMENT ON COLUMN keplersc.kdlealtadmovs.clave_descuento IS 'Clave del programa de descuento';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c9 IS 'Var 1';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c8 IS 'Partida';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c7 IS 'H(Horas),R(Refs),T(Tots),C(Cargos Varios)';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c6 IS 'Clave Paquete';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c5 IS 'Tipo Punto';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c4 IS 'Punto';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c3 IS 'Orden';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c10 IS 'Var 2';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c1 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdlealtadmovs.base_descuento IS 'Importe de descuento a aplicar al concepto correspondiente';

