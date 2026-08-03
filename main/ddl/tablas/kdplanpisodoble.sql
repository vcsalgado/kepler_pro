CREATE  TABLE keplersc.kdplanpisodoble (
  c1 character varying(10) NOT NULL,
  c2 character varying(30) NOT NULL,
  c3 character varying(10) NOT NULL,
  c4 character varying(20) NOT NULL,
  c5 character varying(10) NOT NULL,
  c6 numeric(10,2) NOT NULL,
  c7 numeric(10,2) NOT NULL,
  c8 numeric(10,2) NOT NULL,
  c9 character varying(30) NOT NULL
) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdplanpisodoble.c9 IS 'Detalle de prestamos';
COMMENT ON COLUMN keplersc.kdplanpisodoble.c8 IS 'Monto de Pago';
COMMENT ON COLUMN keplersc.kdplanpisodoble.c7 IS 'Saldo de Capital';
COMMENT ON COLUMN keplersc.kdplanpisodoble.c6 IS 'Monto por Vencer';
COMMENT ON COLUMN keplersc.kdplanpisodoble.c5 IS 'Fecha Factura';
COMMENT ON COLUMN keplersc.kdplanpisodoble.c4 IS 'Numero de VIN';
COMMENT ON COLUMN keplersc.kdplanpisodoble.c3 IS 'Numero de operacion';
COMMENT ON COLUMN keplersc.kdplanpisodoble.c2 IS 'Nombre DBA del Cliente';
COMMENT ON COLUMN keplersc.kdplanpisodoble.c1 IS 'Distribuidor';

