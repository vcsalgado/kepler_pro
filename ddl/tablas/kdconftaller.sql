CREATE  TABLE keplersc.kdconftaller (
  c1 numeric NOT NULL DEFAULT 0,
  c2 character varying(7) NOT NULL DEFAULT ''::character varying,
  c3 character varying(20) NOT NULL DEFAULT ''::character varying,
  c4 character varying(20) NOT NULL DEFAULT ''::character varying,
  c5 character varying(20) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 integer NOT NULL DEFAULT 1,
  col_servicio_express character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdconftaller ADD CONSTRAINT pk_kdconftaller PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdconftaller IS 'Configuracion taller';
COMMENT ON COLUMN keplersc.kdconftaller.c9 IS 'Validacion Kodawari';
COMMENT ON COLUMN keplersc.kdconftaller.c8 IS 'Generar folio automatico para ordenes de servicio';
COMMENT ON COLUMN keplersc.kdconftaller.c7 IS 'Forzar validacion del cierre de internas con privilegio';
COMMENT ON COLUMN keplersc.kdconftaller.c6 IS 'Forzar validacion tipo de punto vs operario';
COMMENT ON COLUMN keplersc.kdconftaller.c5 IS 'ID Usuario Alterno Gerente';
COMMENT ON COLUMN keplersc.kdconftaller.c4 IS 'ID Usuario Alterno Gerente';
COMMENT ON COLUMN keplersc.kdconftaller.c3 IS 'ID Usuario Gerente';
COMMENT ON COLUMN keplersc.kdconftaller.c2 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdconftaller.c10 IS 'Dias en adelante a revisar disponibilidad de asesores(citas en linea)';
COMMENT ON COLUMN keplersc.kdconftaller.c1 IS 'Id Configuracion Taller';

