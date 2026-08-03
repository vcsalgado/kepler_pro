CREATE  TABLE keplersc.kdscsi (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(2) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying,
  c4 numeric(10,5) NOT NULL DEFAULT 0,
  c5 numeric(10,5) NOT NULL DEFAULT 0,
  c6 numeric(15,2) NOT NULL DEFAULT 0,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 numeric NOT NULL DEFAULT 0,
  c11 numeric NOT NULL DEFAULT 0,
  c12 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdscsi ADD CONSTRAINT pk_kdscsi PRIMARY KEY (c1, c2, c3);
COMMENT ON COLUMN keplersc.kdscsi.c7 IS 'Errores en la auditoria de plan piso';
COMMENT ON COLUMN keplersc.kdscsi.c6 IS 'Presupuesto objetivo';
COMMENT ON COLUMN keplersc.kdscsi.c5 IS 'CSI Planta';
COMMENT ON COLUMN keplersc.kdscsi.c4 IS 'CSI Interno';
COMMENT ON COLUMN keplersc.kdscsi.c3 IS 'Mes';
COMMENT ON COLUMN keplersc.kdscsi.c2 IS 'Anio';
COMMENT ON COLUMN keplersc.kdscsi.c12 IS 'Porcentaje de Cobertura de Capacitacion de Ventas';
COMMENT ON COLUMN keplersc.kdscsi.c11 IS 'Porcentaje de Cobertura de Capacitacion de Servicio';
COMMENT ON COLUMN keplersc.kdscsi.c1 IS 'Sucursal';

