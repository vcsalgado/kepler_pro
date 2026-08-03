CREATE  TABLE keplersc.kdscierrecalidad (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c6 character varying(8) NOT NULL DEFAULT ''::character varying,
  c7 character varying(10) NOT NULL DEFAULT ''::character varying,
  c8 character varying(300) NOT NULL DEFAULT ''::character varying,
  c9 character varying(70) NOT NULL DEFAULT ''::character varying,
  c10 character varying(70) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdscierrecalidad ADD CONSTRAINT pk_kdscierrecalidad PRIMARY KEY (c1, c2, c3);
COMMENT ON TABLE keplersc.kdscierrecalidad IS 'cierre calidad';
COMMENT ON COLUMN keplersc.kdscierrecalidad.c9 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdscierrecalidad.c8 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdscierrecalidad.c7 IS 'Usuario Autorizando';
COMMENT ON COLUMN keplersc.kdscierrecalidad.c6 IS 'Hora de Autorizacion';
COMMENT ON COLUMN keplersc.kdscierrecalidad.c5 IS 'Fecha de Autorizacion';
COMMENT ON COLUMN keplersc.kdscierrecalidad.c3 IS 'Folio de la Orden';
COMMENT ON COLUMN keplersc.kdscierrecalidad.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdscierrecalidad.c10 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdscierrecalidad.c1 IS 'Sucursal';

