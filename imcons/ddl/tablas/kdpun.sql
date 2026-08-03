CREATE  TABLE keplersc.kdpun (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(5) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(85) NOT NULL DEFAULT ''::character varying,
  c9 character varying(6) NOT NULL DEFAULT ''::character varying,
  c10 character varying(2) NOT NULL DEFAULT ''::character varying,
  c11 character varying(2) NOT NULL DEFAULT ''::character varying,
  c12 character varying(50) NOT NULL DEFAULT ''::character varying,
  c13 character varying(50) NOT NULL DEFAULT ''::character varying,
  c14 character varying(50) NOT NULL DEFAULT ''::character varying,
  c15 character varying(40) NOT NULL DEFAULT ''::character varying,
  c16 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c17 character varying(5) NOT NULL DEFAULT ''::character varying,
  c18 character varying(40) NOT NULL DEFAULT ''::character varying,
  c19 character varying(40) NOT NULL DEFAULT ''::character varying,
  c20 character varying(1) NOT NULL DEFAULT ''::character varying,
  c21 character varying(1) NOT NULL DEFAULT ''::character varying,
  c22 character varying(1) NOT NULL DEFAULT ''::character varying,
  c23 character varying(1) NOT NULL DEFAULT ''::character varying,
  c24 character varying(1) NOT NULL DEFAULT ''::character varying,
  c25 numeric(10,3) NOT NULL DEFAULT 0,
  c26 character varying(8) NOT NULL DEFAULT ''::character varying,
  c27 character varying(8) NOT NULL DEFAULT ''::character varying,
  c28 character varying(8) NOT NULL DEFAULT ''::character varying,
  c29 character varying(8) NOT NULL DEFAULT ''::character varying,
  c30 character varying(8) NOT NULL DEFAULT ''::character varying,
  c31 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c32 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c33 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c34 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c35 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c36 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c37 character varying(5) NOT NULL DEFAULT ''::character varying,
  c38 character varying(40) NOT NULL DEFAULT ''::character varying,
  c39 character varying(1) NOT NULL DEFAULT ''::character varying,
  c40 numeric(6,2) NOT NULL DEFAULT 0,
  c41 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c42 character varying(50) NOT NULL DEFAULT ''::character varying,
  c43 character varying(50) NOT NULL DEFAULT ''::character varying,
  c44 character varying(50) NOT NULL DEFAULT ''::character varying,
  c45 character varying(50) NOT NULL DEFAULT ''::character varying,
  c46 character varying(50) NOT NULL DEFAULT ''::character varying,
  c47 character varying(50) NOT NULL DEFAULT ''::character varying,
  c48 character varying(40) NOT NULL DEFAULT ''::character varying,
  c49 character varying(40) NOT NULL DEFAULT ''::character varying,
  c50 character varying NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdpun ADD CONSTRAINT pk_kdpun PRIMARY KEY (c1, c2, c3, c4);
CREATE INDEX IF NOT EXISTS sindkdpun02 ON keplersc.kdpun USING btree (c1, c7, c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdpun03 ON keplersc.kdpun USING btree (c1, c9, c2, c3, c4) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdpun IS 'Puntos de las Ordenes de Servicio';
COMMENT ON COLUMN keplersc.kdpun.c9 IS 'Operario';
COMMENT ON COLUMN keplersc.kdpun.c8 IS 'Trabajo a Realizar';
COMMENT ON COLUMN keplersc.kdpun.c7 IS 'Status: Pendiente, Activo, Suspendido ,Terminado o No Autorizdo (kdstatuspun)';
COMMENT ON COLUMN keplersc.kdpun.c6 IS 'Tipo de Punto';
COMMENT ON COLUMN keplersc.kdpun.c50 IS 'Clave Campaña';
COMMENT ON COLUMN keplersc.kdpun.c5 IS 'Kit';
COMMENT ON COLUMN keplersc.kdpun.c49 IS 'Notas para punto no autorizado';
COMMENT ON COLUMN keplersc.kdpun.c48 IS 'Notas para punto no autorizado';
COMMENT ON COLUMN keplersc.kdpun.c47 IS 'Corrección';
COMMENT ON COLUMN keplersc.kdpun.c46 IS 'Corrección';
COMMENT ON COLUMN keplersc.kdpun.c45 IS 'Causa';
COMMENT ON COLUMN keplersc.kdpun.c44 IS 'Causa';
COMMENT ON COLUMN keplersc.kdpun.c43 IS 'Problema';
COMMENT ON COLUMN keplersc.kdpun.c42 IS 'Problema';
COMMENT ON COLUMN keplersc.kdpun.c41 IS 'Fecha Programada';
COMMENT ON COLUMN keplersc.kdpun.c40 IS 'Horas estimadas';
COMMENT ON COLUMN keplersc.kdpun.c4 IS 'Numero de Punto';
COMMENT ON COLUMN keplersc.kdpun.c38 IS 'Notas para punto no autorizado';
COMMENT ON COLUMN keplersc.kdpun.c37 IS 'Tipo de Operario';
COMMENT ON COLUMN keplersc.kdpun.c36 IS 'Fecha de suspension';
COMMENT ON COLUMN keplersc.kdpun.c35 IS 'Fecha cierre Cargos Varios';
COMMENT ON COLUMN keplersc.kdpun.c34 IS 'Fecha cierre TOTs';
COMMENT ON COLUMN keplersc.kdpun.c33 IS 'Fecha cierre Tabulacion';
COMMENT ON COLUMN keplersc.kdpun.c32 IS 'Fecha cierre Externas';
COMMENT ON COLUMN keplersc.kdpun.c31 IS 'Fecha cierre Internas';
COMMENT ON COLUMN keplersc.kdpun.c30 IS 'Hora cierre cargos varios';
COMMENT ON COLUMN keplersc.kdpun.c3 IS 'Folio de la Orden';
COMMENT ON COLUMN keplersc.kdpun.c29 IS 'Hora cierre TOTs';
COMMENT ON COLUMN keplersc.kdpun.c28 IS 'Hora cierre Tabulacion';
COMMENT ON COLUMN keplersc.kdpun.c27 IS 'Hora cierre Externas';
COMMENT ON COLUMN keplersc.kdpun.c26 IS 'Hora cierre Internas';
COMMENT ON COLUMN keplersc.kdpun.c25 IS 'Total en horas tabuldas';
COMMENT ON COLUMN keplersc.kdpun.c24 IS 'Cerrado en cargos varios';
COMMENT ON COLUMN keplersc.kdpun.c23 IS 'Cerrado en  TOTs';
COMMENT ON COLUMN keplersc.kdpun.c22 IS 'Cerrado en tabulacion';
COMMENT ON COLUMN keplersc.kdpun.c21 IS 'Cerrado en refacciones Externas';
COMMENT ON COLUMN keplersc.kdpun.c20 IS 'Cerrado en refacciones Internas';
COMMENT ON COLUMN keplersc.kdpun.c2 IS 'Tipo de la Orden';
COMMENT ON COLUMN keplersc.kdpun.c19 IS 'Notas al cliente';
COMMENT ON COLUMN keplersc.kdpun.c18 IS 'Notas al cliente';
COMMENT ON COLUMN keplersc.kdpun.c17 IS 'Codigo de Suspensión';
COMMENT ON COLUMN keplersc.kdpun.c16 IS 'Fecha de Terminacion del Punto';
COMMENT ON COLUMN keplersc.kdpun.c15 IS 'Notas al Cliente';
COMMENT ON COLUMN keplersc.kdpun.c14 IS 'Correccion';
COMMENT ON COLUMN keplersc.kdpun.c13 IS 'Causa';
COMMENT ON COLUMN keplersc.kdpun.c12 IS 'Problema';
COMMENT ON COLUMN keplersc.kdpun.c11 IS 'Queja del Cliente para Garantias';
COMMENT ON COLUMN keplersc.kdpun.c10 IS 'Codigo de Falla para Garantias';
COMMENT ON COLUMN keplersc.kdpun.c1 IS 'Sucursal';

