CREATE  TABLE keplersc.kdplanpisotfs (
  c1 character varying(10) NOT NULL,
  c2 character varying(30) NOT NULL,
  c3 character varying(10) NOT NULL,
  c4 character varying(20) NOT NULL,
  c5 date NOT NULL,
  c6 numeric(10,2) NOT NULL,
  c7 numeric(10,2) NOT NULL,
  c8 numeric(10,2) NOT NULL,
  c9 character varying(30) NOT NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdplanpisotfs ADD CONSTRAINT kdplanpisotfs_pk PRIMARY KEY (c4);
COMMENT ON COLUMN keplersc.kdplanpisotfs.c9 IS 'Detalle de prestamos';
COMMENT ON COLUMN keplersc.kdplanpisotfs.c8 IS 'Monto de Pago';
COMMENT ON COLUMN keplersc.kdplanpisotfs.c7 IS 'Saldo de Capital';
COMMENT ON COLUMN keplersc.kdplanpisotfs.c6 IS 'Monto por Vencer';
COMMENT ON COLUMN keplersc.kdplanpisotfs.c5 IS 'Fecha Factura';
COMMENT ON COLUMN keplersc.kdplanpisotfs.c4 IS 'Numero de VIN';
COMMENT ON COLUMN keplersc.kdplanpisotfs.c3 IS 'Numero de operacion';
COMMENT ON COLUMN keplersc.kdplanpisotfs.c2 IS 'Nombre DBA del Cliente';
COMMENT ON COLUMN keplersc.kdplanpisotfs.c1 IS 'Distribuidor';

