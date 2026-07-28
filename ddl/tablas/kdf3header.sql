CREATE  TABLE keplersc.kdf3header (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(2) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(15) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 character varying(10) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(3) NOT NULL DEFAULT ''::character varying,
  c14 character varying(10) NOT NULL DEFAULT ''::character varying,
  c15 character varying(8) NOT NULL DEFAULT ''::character varying,
  c16 character varying(3) NOT NULL DEFAULT ''::character varying,
  c17 numeric(20,8) NOT NULL DEFAULT 0,
  c18 numeric(20,8) NOT NULL DEFAULT 0,
  c19 character varying(5) NOT NULL DEFAULT ''::character varying,
  c20 character varying(2) NOT NULL DEFAULT ''::character varying,
  c21 character varying(50) NOT NULL DEFAULT ''::character varying,
  c22 character varying(4) NOT NULL DEFAULT ''::character varying,
  c23 character varying(14) NOT NULL DEFAULT ''::character varying,
  c24 character varying(100) NOT NULL DEFAULT ''::character varying,
  c25 character varying(130) NOT NULL DEFAULT ''::character varying,
  c26 character varying(1) NOT NULL DEFAULT ''::character varying,
  c27 character varying(18) NOT NULL DEFAULT ''::character varying,
  c28 character varying(20) NOT NULL DEFAULT ''::character varying,
  c29 character varying(80) NOT NULL DEFAULT ''::character varying,
  c30 character varying(4) NOT NULL DEFAULT ''::character varying,
  c31 character varying(50) NOT NULL DEFAULT ''::character varying,
  c32 character varying(50) NOT NULL DEFAULT ''::character varying,
  c33 character varying(1) NOT NULL DEFAULT ''::character varying,
  c34 character varying(10) NOT NULL DEFAULT ''::character varying,
  c35 numeric(16,2) NOT NULL DEFAULT 0,
  c36 character varying(15) NOT NULL DEFAULT ''::character varying,
  c37 character varying(30) NOT NULL DEFAULT ''::character varying,
  c38 character varying(15) NOT NULL DEFAULT ''::character varying,
  c39 character varying(20) NOT NULL DEFAULT ''::character varying,
  c40 character varying(20) NOT NULL DEFAULT ''::character varying,
  c41 character varying(10) NOT NULL DEFAULT ''::character varying,
  c42 character varying(10) NOT NULL DEFAULT ''::character varying,
  c43 character varying(3) NOT NULL DEFAULT ''::character varying,
  c44 character varying(3) NOT NULL DEFAULT ''::character varying,
  c45 character varying(3) NOT NULL DEFAULT ''::character varying,
  c46 character varying(20) NOT NULL DEFAULT ''::character varying,
  c47 character varying(4) NOT NULL DEFAULT ''::character varying,
  c48 character varying(4) NOT NULL DEFAULT ''::character varying,
  c49 character varying(12) NOT NULL DEFAULT ''::character varying,
  c50 character varying(10) NOT NULL DEFAULT ''::character varying,
  c51 character varying(10) NOT NULL DEFAULT ''::character varying,
  c52 character varying(1) NOT NULL DEFAULT ''::character varying,
  c53 character varying(1) NOT NULL DEFAULT ''::character varying,
  c54 character varying(3) NOT NULL DEFAULT ''::character varying,
  c55 character varying(10) NOT NULL DEFAULT ''::character varying,
  c56 numeric(20,8) NOT NULL DEFAULT 0,
  c57 numeric(7,4) NOT NULL DEFAULT 0,
  c58 numeric(20,8) NOT NULL DEFAULT 0,
  c59 character varying(3) NOT NULL DEFAULT ''::character varying,
  c60 character varying(10) NOT NULL DEFAULT ''::character varying,
  c61 numeric(20,8) NOT NULL DEFAULT 0,
  c62 numeric(7,4) NOT NULL DEFAULT 0,
  c63 numeric(20,8) NOT NULL DEFAULT 0,
  c64 character varying(2) NOT NULL DEFAULT ''::character varying,
  c65 character varying(1) NOT NULL DEFAULT ''::character varying,
  c66 character varying(1) NOT NULL DEFAULT ''::character varying,
  c67 numeric NOT NULL DEFAULT 0,
  c68 numeric NOT NULL DEFAULT 0,
  c69 character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3header ADD CONSTRAINT pk_kdf3header PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
CREATE INDEX IF NOT EXISTS kdf3header_c1_idx ON keplersc.kdf3header USING btree (c1, c65, c66, c67, c68, c69) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdf3header IS 'F3 Header';
COMMENT ON COLUMN keplersc.kdf3header.c9 IS 'CDF Automatico';
COMMENT ON COLUMN keplersc.kdf3header.c8 IS 'Usuario';
COMMENT ON COLUMN keplersc.kdf3header.c7 IS 'Consecutivo';
COMMENT ON COLUMN keplersc.kdf3header.c69 IS 'Folio';
COMMENT ON COLUMN keplersc.kdf3header.c68 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdf3header.c67 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdf3header.c66 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdf3header.c65 IS 'Genero';
COMMENT ON COLUMN keplersc.kdf3header.c64 IS 'Tipo relacion';
COMMENT ON COLUMN keplersc.kdf3header.c63 IS 'Monto base impuesto';
COMMENT ON COLUMN keplersc.kdf3header.c62 IS 'Tasa impuesto';
COMMENT ON COLUMN keplersc.kdf3header.c61 IS 'Monto impuesto';
COMMENT ON COLUMN keplersc.kdf3header.c60 IS 'Tasa, cuota o excento';
COMMENT ON COLUMN keplersc.kdf3header.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdf3header.c59 IS 'Clave impuesto SAT';
COMMENT ON COLUMN keplersc.kdf3header.c58 IS 'Monto base impuesto';
COMMENT ON COLUMN keplersc.kdf3header.c57 IS 'Tasa impuesto';
COMMENT ON COLUMN keplersc.kdf3header.c56 IS 'Monto impuesto';
COMMENT ON COLUMN keplersc.kdf3header.c55 IS 'Tasa, cuota o excento';
COMMENT ON COLUMN keplersc.kdf3header.c54 IS 'Clave impuesto SAT';
COMMENT ON COLUMN keplersc.kdf3header.c52 IS 'Traspaso agencias (S/N)';
COMMENT ON COLUMN keplersc.kdf3header.c51 IS 'Contado o credito';
COMMENT ON COLUMN keplersc.kdf3header.c50 IS 'Fecha pedimiento aduanal';
COMMENT ON COLUMN keplersc.kdf3header.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdf3header.c49 IS 'Año curso y num pedimento aduanal';
COMMENT ON COLUMN keplersc.kdf3header.c48 IS 'Patente aduanal';
COMMENT ON COLUMN keplersc.kdf3header.c47 IS 'Año operacion y aduana';
COMMENT ON COLUMN keplersc.kdf3header.c46 IS 'Combustible';
COMMENT ON COLUMN keplersc.kdf3header.c45 IS 'Numero pasajeros';
COMMENT ON COLUMN keplersc.kdf3header.c44 IS 'Numero cilindros';
COMMENT ON COLUMN keplersc.kdf3header.c43 IS 'Numero puertas';
COMMENT ON COLUMN keplersc.kdf3header.c42 IS 'Clave vehicular';
COMMENT ON COLUMN keplersc.kdf3header.c41 IS 'Registro vehicular';
COMMENT ON COLUMN keplersc.kdf3header.c40 IS 'Procedencia';
COMMENT ON COLUMN keplersc.kdf3header.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdf3header.c39 IS 'Clase';
COMMENT ON COLUMN keplersc.kdf3header.c38 IS 'Inventario vehiculo';
COMMENT ON COLUMN keplersc.kdf3header.c37 IS 'Asesor servicio';
COMMENT ON COLUMN keplersc.kdf3header.c36 IS 'Placas';
COMMENT ON COLUMN keplersc.kdf3header.c35 IS 'Kilometraje';
COMMENT ON COLUMN keplersc.kdf3header.c34 IS 'Orden servicio';
COMMENT ON COLUMN keplersc.kdf3header.c33 IS 'Tipo orden sercivio';
COMMENT ON COLUMN keplersc.kdf3header.c32 IS 'Numero motor';
COMMENT ON COLUMN keplersc.kdf3header.c31 IS 'Color';
COMMENT ON COLUMN keplersc.kdf3header.c30 IS 'Año modelo';
COMMENT ON COLUMN keplersc.kdf3header.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdf3header.c29 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdf3header.c28 IS 'Marca';
COMMENT ON COLUMN keplersc.kdf3header.c27 IS 'VIN';
COMMENT ON COLUMN keplersc.kdf3header.c25 IS 'Razon social';
COMMENT ON COLUMN keplersc.kdf3header.c24 IS 'Email';
COMMENT ON COLUMN keplersc.kdf3header.c23 IS 'RFC receptor';
COMMENT ON COLUMN keplersc.kdf3header.c22 IS 'Uso CFDI';
COMMENT ON COLUMN keplersc.kdf3header.c21 IS 'Cuenta, tarjeta, cheque, etc.';
COMMENT ON COLUMN keplersc.kdf3header.c20 IS 'Forma pago SAT';
COMMENT ON COLUMN keplersc.kdf3header.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdf3header.c19 IS 'CP SAT';
COMMENT ON COLUMN keplersc.kdf3header.c18 IS 'Importe';
COMMENT ON COLUMN keplersc.kdf3header.c17 IS 'Precio antes impuestos';
COMMENT ON COLUMN keplersc.kdf3header.c16 IS 'Metodo pago SAT';
COMMENT ON COLUMN keplersc.kdf3header.c15 IS 'Hora generacion';
COMMENT ON COLUMN keplersc.kdf3header.c14 IS 'Fecha generacion';
COMMENT ON COLUMN keplersc.kdf3header.c13 IS 'Serie documento';
COMMENT ON COLUMN keplersc.kdf3header.c12 IS 'Layout PDF';
COMMENT ON COLUMN keplersc.kdf3header.c11 IS 'Ingreso, Egreso o Pago';
COMMENT ON COLUMN keplersc.kdf3header.c10 IS 'Area Doc V entas,S ervicio,R efacciones,G enérico';
COMMENT ON COLUMN keplersc.kdf3header.c1 IS 'Sucursal';

