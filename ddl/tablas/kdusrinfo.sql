CREATE  TABLE keplersc.kdusrinfo (
  c1 character varying(21) NOT NULL DEFAULT ''::character varying,
  c2 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c3 numeric NOT NULL DEFAULT 0,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(5) NOT NULL DEFAULT ''::character varying,
  c9 character varying(5) NOT NULL DEFAULT ''::character varying,
  c10 character varying(5) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(60) NOT NULL DEFAULT ''::character varying,
  c13 character varying(10) NOT NULL DEFAULT ''::character varying,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 character varying(7) NOT NULL DEFAULT ''::character varying,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 character varying(1) NOT NULL DEFAULT ''::character varying,
  c18 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c19 character varying(1) NOT NULL DEFAULT 'N'::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdusrinfo ON keplersc.kdusrinfo USING btree (c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdusrinfo02 ON keplersc.kdusrinfo USING btree (c12, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdusrinfo03 ON keplersc.kdusrinfo USING btree (c14, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdusrinfo04 ON keplersc.kdusrinfo USING btree (c8, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdusrinfo05 ON keplersc.kdusrinfo USING btree (c9, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdusrinfo06 ON keplersc.kdusrinfo USING btree (c10, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdusrinfo IS 'Catalogo Asesores';
COMMENT ON COLUMN keplersc.kdusrinfo.c9 IS 'Clave del Perfil 2';
COMMENT ON COLUMN keplersc.kdusrinfo.c8 IS 'Clave del perfil 1';
COMMENT ON COLUMN keplersc.kdusrinfo.c7 IS 'Permitir movimientos fuera de la fecha actual';
COMMENT ON COLUMN keplersc.kdusrinfo.c6 IS 'El usuario tiene privilegios de contabilidad';
COMMENT ON COLUMN keplersc.kdusrinfo.c5 IS 'El usuario tiene privilegios de administrador';
COMMENT ON COLUMN keplersc.kdusrinfo.c4 IS 'El password nunca caduca';
COMMENT ON COLUMN keplersc.kdusrinfo.c3 IS 'Vigencia del password';
COMMENT ON COLUMN keplersc.kdusrinfo.c2 IS 'Ultima actualizacion del password';
COMMENT ON COLUMN keplersc.kdusrinfo.c19 IS 'Privilegio para modificar citas';
COMMENT ON COLUMN keplersc.kdusrinfo.c18 IS 'Ultima Fecha de Acceso';
COMMENT ON COLUMN keplersc.kdusrinfo.c17 IS 'Privilegio para movimientos en cartera';
COMMENT ON COLUMN keplersc.kdusrinfo.c16 IS 'Privilegio para cerrar ordenes internas';
COMMENT ON COLUMN keplersc.kdusrinfo.c15 IS 'Sucursal default';
COMMENT ON COLUMN keplersc.kdusrinfo.c14 IS 'Se requiere de la autorizacion del usuario PEDIDO';
COMMENT ON COLUMN keplersc.kdusrinfo.c13 IS 'Password';
COMMENT ON COLUMN keplersc.kdusrinfo.c12 IS 'Nombre del Usuario';
COMMENT ON COLUMN keplersc.kdusrinfo.c11 IS 'Acceso al Generador';
COMMENT ON COLUMN keplersc.kdusrinfo.c10 IS 'Clave del Perfil 3';
COMMENT ON COLUMN keplersc.kdusrinfo.c1 IS 'Clave';

