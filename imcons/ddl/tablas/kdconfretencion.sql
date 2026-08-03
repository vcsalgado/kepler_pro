CREATE  TABLE keplersc.kdconfretencion (
  c1 numeric NOT NULL DEFAULT 0,
  c2 numeric(15,4) NOT NULL DEFAULT 0,
  c3 numeric(15,4) NOT NULL DEFAULT 0,
  c4 numeric(10,4) NOT NULL DEFAULT 0,
  c5 numeric(10,4) NOT NULL DEFAULT 0,
  c6 numeric(10,4) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdconfretencion ADD CONSTRAINT pk_kdconfretencion PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdconfretencion IS 'Configuracion de retenciones';
COMMENT ON COLUMN keplersc.kdconfretencion.c6 IS 'ISR a retener';
COMMENT ON COLUMN keplersc.kdconfretencion.c5 IS 'IVA';
COMMENT ON COLUMN keplersc.kdconfretencion.c4 IS 'Depreciación anual';
COMMENT ON COLUMN keplersc.kdconfretencion.c3 IS 'Excedente para pagar retencion';
COMMENT ON COLUMN keplersc.kdconfretencion.c2 IS 'Maximo precio para pagar retencion';
COMMENT ON COLUMN keplersc.kdconfretencion.c1 IS 'Consecutivo';

