CREATE  TABLE keplersc.kdf3headextras (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(300) NOT NULL DEFAULT ''::character varying,
  c9 character varying(80) NOT NULL DEFAULT ''::character varying,
  c10 character varying(80) NOT NULL DEFAULT ''::character varying,
  c11 character varying(15) NOT NULL DEFAULT ''::character varying,
  c12 numeric NOT NULL DEFAULT 0,
  c13 character varying(10) NOT NULL DEFAULT ''::character varying,
  c14 character varying(20) NOT NULL DEFAULT ''::character varying,
  c15 character varying(5) NOT NULL DEFAULT ''::character varying,
  c16 character varying(20) NOT NULL DEFAULT ''::character varying,
  c17 character varying(30) NOT NULL DEFAULT ''::character varying,
  c18 character varying(1) NOT NULL DEFAULT ''::character varying,
  c19 character varying(3) NOT NULL DEFAULT ''::character varying,
  c20 character varying(80) NOT NULL DEFAULT ''::character varying,
  motivo_cancelacion character varying(2) NOT NULL DEFAULT ''::character varying,
  movto_sustitucion character varying(21) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3headextras ADD CONSTRAINT pk_kdf3headextras PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
COMMENT ON TABLE keplersc.kdf3headextras IS 'F3 Header extras';
COMMENT ON COLUMN keplersc.kdf3headextras.movto_sustitucion IS 'Movimiento sustitucion';
COMMENT ON COLUMN keplersc.kdf3headextras.motivo_cancelacion IS 'Motivo cancelacion CFDI';
COMMENT ON COLUMN keplersc.kdf3headextras.c9 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3headextras.c8 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3headextras.c7 IS 'Consecutivo cfdi';
COMMENT ON COLUMN keplersc.kdf3headextras.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdf3headextras.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdf3headextras.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdf3headextras.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdf3headextras.c20 IS 'Descripcion regimen fiscal';
COMMENT ON COLUMN keplersc.kdf3headextras.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdf3headextras.c19 IS 'Regimen fiscal';
COMMENT ON COLUMN keplersc.kdf3headextras.c18 IS 'Anulacion S o N';
COMMENT ON COLUMN keplersc.kdf3headextras.c17 IS 'Descripción documento';
COMMENT ON COLUMN keplersc.kdf3headextras.c16 IS 'Transmisión';
COMMENT ON COLUMN keplersc.kdf3headextras.c15 IS 'Bonete';
COMMENT ON COLUMN keplersc.kdf3headextras.c14 IS 'Siniestro/Orden compra';
COMMENT ON COLUMN keplersc.kdf3headextras.c13 IS 'Fecha pago';
COMMENT ON COLUMN keplersc.kdf3headextras.c12 IS 'Plazo pago';
COMMENT ON COLUMN keplersc.kdf3headextras.c11 IS 'Referencia';
COMMENT ON COLUMN keplersc.kdf3headextras.c10 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3headextras.c1 IS 'Sucursal';

