CREATE  TABLE keplersc.kdserie (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 character varying(20) NOT NULL DEFAULT ''::character varying,
  c5 character varying(20) NOT NULL DEFAULT ''::character varying,
  c6 character varying(20) NOT NULL DEFAULT ''::character varying,
  c7 character varying(20) NOT NULL DEFAULT ''::character varying,
  c8 character varying(10) NOT NULL DEFAULT ''::character varying,
  c9 character varying(7) NOT NULL DEFAULT ''::character varying,
  c10 character varying(20) NOT NULL DEFAULT ''::character varying,
  c11 character varying(4) NOT NULL DEFAULT ''::character varying,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c14 character varying(5) NOT NULL DEFAULT ''::character varying,
  c15 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c16 character varying(130) NOT NULL DEFAULT ''::character varying,
  c17 character varying(15) NULL DEFAULT ''::character varying,
  c18 character varying(20) NULL DEFAULT '0'::character varying,
  c19 timestamp without time zone NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c20 character varying(90) NULL DEFAULT ''::character varying,
  c21 character varying(20) NULL DEFAULT ''::character varying,
  c22 character varying(90) NOT NULL DEFAULT ''::character varying,
  c23 character varying(20) NOT NULL DEFAULT ''::character varying,
  c24 character varying(50) NOT NULL DEFAULT ''::character varying,
  c25 character varying(50) NOT NULL DEFAULT ''::character varying,
  c26 character varying(60) NOT NULL DEFAULT ''::character varying,
  c27 character varying(50) NOT NULL DEFAULT ''::character varying,
  c28 character varying(50) NOT NULL DEFAULT ''::character varying,
  c29 character varying(60) NOT NULL DEFAULT ''::character varying,
  c30 character varying(13) NOT NULL DEFAULT ''::character varying,
  c31 character varying(13) NOT NULL DEFAULT ''::character varying,
  c32 character varying(5) NOT NULL DEFAULT ''::character varying,
  c33 character varying(20) NOT NULL DEFAULT ''::character varying,
  c34 character varying(5) NOT NULL DEFAULT ''::character varying,
  c35 character varying(20) NOT NULL DEFAULT ''::character varying,
  c36 numeric NOT NULL DEFAULT 0,
  c37 numeric NOT NULL DEFAULT 0,
  c38 character varying(1) NOT NULL DEFAULT ''::character varying,
  c39 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c40 character varying(1) NOT NULL DEFAULT ''::character varying,
  c41 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  ult_motivo_tmkt numeric NOT NULL DEFAULT 0,
  ult_resultado_tmkt numeric NOT NULL DEFAULT 0,
  ult_accion_tmkt numeric NOT NULL DEFAULT 0,
  fecha_ult_contacto_tmkt timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  asesor_base_tmkt character varying NOT NULL DEFAULT ''::character varying,
  c42 character varying(45) NOT NULL DEFAULT ''::character varying,
  c43 character varying(15) NOT NULL DEFAULT ''::character varying,
  c44 character varying(45) NOT NULL DEFAULT ''::character varying,
  c45 character varying(15) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdserie ADD CONSTRAINT pk_kdserie PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdserie02 ON keplersc.kdserie USING btree (c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdserie03 ON keplersc.kdserie USING btree (c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdserie04 ON keplersc.kdserie USING btree (c15, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdserie06 ON keplersc.kdserie USING btree (c8, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdserie07 ON keplersc.kdserie USING btree (c9, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdserie05 ON keplersc.kdserie USING btree (c16, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdserie.ult_resultado_tmkt IS 'Ultimo Resultado TMKT';
COMMENT ON COLUMN keplersc.kdserie.ult_motivo_tmkt IS 'Ultimo Motivo TMKT';
COMMENT ON COLUMN keplersc.kdserie.ult_accion_tmkt IS 'Ultima Accion TMKT';
COMMENT ON COLUMN keplersc.kdserie.fecha_ult_contacto_tmkt IS 'Fecha Ultimo Contacto TMKT';
COMMENT ON COLUMN keplersc.kdserie.c9 IS 'Clave contacto';
COMMENT ON COLUMN keplersc.kdserie.c8 IS 'Placas';
COMMENT ON COLUMN keplersc.kdserie.c7 IS 'Eje trasero';
COMMENT ON COLUMN keplersc.kdserie.c6 IS 'Transmision';
COMMENT ON COLUMN keplersc.kdserie.c5 IS 'Motor';
COMMENT ON COLUMN keplersc.kdserie.c45 IS 'No. poliza seguro vehicular';
COMMENT ON COLUMN keplersc.kdserie.c44 IS 'Aseguradora seguro vehicular';
COMMENT ON COLUMN keplersc.kdserie.c43 IS 'No. poliza garantia extendida ';
COMMENT ON COLUMN keplersc.kdserie.c42 IS 'Aseguradora garantia extendida';
COMMENT ON COLUMN keplersc.kdserie.c41 IS 'Vigencia seguro';
COMMENT ON COLUMN keplersc.kdserie.c40 IS 'Seguro vehicular';
COMMENT ON COLUMN keplersc.kdserie.c4 IS 'Serie';
COMMENT ON COLUMN keplersc.kdserie.c39 IS 'Expiracion garantia extendida';
COMMENT ON COLUMN keplersc.kdserie.c38 IS 'Garantia extendida S/N';
COMMENT ON COLUMN keplersc.kdserie.c37 IS 'Clave sub-condicion';
COMMENT ON COLUMN keplersc.kdserie.c36 IS 'Clave condicion';
COMMENT ON COLUMN keplersc.kdserie.c35 IS 'Numero contacto preferido compras';
COMMENT ON COLUMN keplersc.kdserie.c34 IS 'Contacto preferido compras';
COMMENT ON COLUMN keplersc.kdserie.c33 IS 'Numero contacto preferido conductor';
COMMENT ON COLUMN keplersc.kdserie.c32 IS 'Contacto preferido conductor';
COMMENT ON COLUMN keplersc.kdserie.c31 IS 'Rfc contacto compras';
COMMENT ON COLUMN keplersc.kdserie.c30 IS 'Rfc contacto conductor';
COMMENT ON COLUMN keplersc.kdserie.c3 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdserie.c29 IS 'E-mail contacto compras';
COMMENT ON COLUMN keplersc.kdserie.c28 IS 'Apellido materno contacto compras';
COMMENT ON COLUMN keplersc.kdserie.c27 IS 'Apellido paterno contacto compras';
COMMENT ON COLUMN keplersc.kdserie.c26 IS 'E-mail contacto conductor';
COMMENT ON COLUMN keplersc.kdserie.c25 IS 'Apellido materno contacto conductor';
COMMENT ON COLUMN keplersc.kdserie.c24 IS 'Apellido paterno contacto conductor';
COMMENT ON COLUMN keplersc.kdserie.c23 IS 'Telefono contacto compras';
COMMENT ON COLUMN keplersc.kdserie.c22 IS 'Nombre contacto compras';
COMMENT ON COLUMN keplersc.kdserie.c21 IS 'Telefono contacto conductor';
COMMENT ON COLUMN keplersc.kdserie.c20 IS 'Nombre contacto conductor';
COMMENT ON COLUMN keplersc.kdserie.c2 IS 'Marca';
COMMENT ON COLUMN keplersc.kdserie.c19 IS 'Fecha Dofu';
COMMENT ON COLUMN keplersc.kdserie.c18 IS 'Version';
COMMENT ON COLUMN keplersc.kdserie.c17 IS 'Codigo Planta (Katashiki)';
COMMENT ON COLUMN keplersc.kdserie.c16 IS 'Nombre del Contacto';
COMMENT ON COLUMN keplersc.kdserie.c15 IS 'Ultima visita';
COMMENT ON COLUMN keplersc.kdserie.c14 IS 'Njumero concesionario';
COMMENT ON COLUMN keplersc.kdserie.c13 IS 'Fecha venta';
COMMENT ON COLUMN keplersc.kdserie.c12 IS 'Kilometraje';
COMMENT ON COLUMN keplersc.kdserie.c11 IS 'Anio';
COMMENT ON COLUMN keplersc.kdserie.c10 IS 'Color';
COMMENT ON COLUMN keplersc.kdserie.c1 IS 'Identificador';
COMMENT ON COLUMN keplersc.kdserie.asesor_base_tmkt IS 'Asesor Base TMKT';

