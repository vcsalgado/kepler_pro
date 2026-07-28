CREATE  TABLE keplersc.ifz_ddoa_rdr_notif (
  sucursal character varying(2) NOT NULL,
  genero character varying(1) NOT NULL DEFAULT ''::character varying,
  naturaleza character varying(1) NOT NULL DEFAULT ''::character varying,
  grupo numeric NOT NULL DEFAULT 0,
  tipo numeric NOT NULL DEFAULT 0,
  folio character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT ifz_ddoa_rdr_notif_unique UNIQUE (sucursal, genero, naturaleza, grupo, tipo, folio)
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.ifz_ddoa_rdr_notif IS 'Notificaciones DDOA Toyota Retail Delivery Reporting RDR';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_notif.tipo IS 'Tipo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_notif.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_notif.naturaleza IS 'Naturaleza';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_notif.grupo IS 'Grupo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_notif.genero IS 'Genero';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_notif.folio IS 'Folio del movimiento';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_notif.fecha IS 'Fecha del movimiento';

