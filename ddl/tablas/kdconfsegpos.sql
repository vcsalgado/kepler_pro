CREATE  TABLE keplersc.kdconfsegpos (
  c1 numeric NOT NULL DEFAULT 0,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdconfsegpos ADD CONSTRAINT pk_kdconfsegpos PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdconfsegpos IS 'Conf seg post venta';
COMMENT ON COLUMN keplersc.kdconfsegpos.c7 IS 'Obligatorio registro de calidad';
COMMENT ON COLUMN keplersc.kdconfsegpos.c6 IS 'Obligatorio registro de actividades';
COMMENT ON COLUMN keplersc.kdconfsegpos.c5 IS 'Horas maximas para seguimiento';
COMMENT ON COLUMN keplersc.kdconfsegpos.c4 IS 'Horas minimas para seguimiento';
COMMENT ON COLUMN keplersc.kdconfsegpos.c3 IS 'Llamadas por cuarto de  hora';
COMMENT ON COLUMN keplersc.kdconfsegpos.c2 IS 'Encuesta';
COMMENT ON COLUMN keplersc.kdconfsegpos.c1 IS 'ID';

