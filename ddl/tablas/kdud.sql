CREATE  TABLE keplersc.kdud (
  c1 character varying(7) NOT NULL DEFAULT '01'::character varying,
  c2 character varying(7) NOT NULL DEFAULT ''::character varying,
  c3 character varying(130) NOT NULL DEFAULT ''::character varying,
  c4 character varying(80) NOT NULL DEFAULT ''::character varying,
  c5 character varying(70) NOT NULL DEFAULT ''::character varying,
  c6 character varying(70) NOT NULL DEFAULT ''::character varying,
  c7 character varying(20) NOT NULL DEFAULT ''::character varying,
  c8 character varying(20) NOT NULL DEFAULT ''::character varying,
  c9 character varying(20) NOT NULL DEFAULT ''::character varying,
  c10 character varying(18) NULL DEFAULT ''::character varying,
  c11 character varying(100) NOT NULL DEFAULT ''::character varying,
  c12 character varying(5) NOT NULL DEFAULT ''::character varying,
  c13 character varying(5) NOT NULL DEFAULT ''::character varying,
  c14 character varying(5) NOT NULL DEFAULT ''::character varying,
  c15 numeric(15,2) NOT NULL DEFAULT 0,
  c16 character varying(4) NOT NULL DEFAULT ''::character varying,
  c17 character varying(4) NOT NULL DEFAULT ''::character varying,
  c18 character varying(4) NOT NULL DEFAULT ''::character varying,
  c19 character varying(4) NOT NULL DEFAULT ''::character varying,
  c20 character varying(2) NOT NULL DEFAULT ''::character varying,
  c21 character varying(11) NOT NULL DEFAULT ''::character varying,
  c22 character varying(2) NOT NULL DEFAULT ''::character varying,
  c23 character varying(11) NOT NULL DEFAULT ''::character varying,
  c24 character varying(40) NOT NULL DEFAULT ''::character varying,
  c25 character varying(40) NOT NULL DEFAULT ''::character varying,
  c26 character varying(40) NOT NULL DEFAULT ''::character varying,
  c27 character varying(10) NOT NULL DEFAULT ''::character varying,
  c28 numeric(7,4) NOT NULL DEFAULT 0,
  c29 numeric(7,4) NOT NULL DEFAULT 0,
  c30 character varying(130) NULL DEFAULT ''::character varying,
  c31 character varying(1) NOT NULL DEFAULT ''::character varying,
  c32 character varying(90) NOT NULL DEFAULT ''::character varying,
  c33 character varying(30) NOT NULL DEFAULT ''::character varying,
  c34 character varying(30) NOT NULL DEFAULT ''::character varying,
  c35 character varying(100) NOT NULL DEFAULT ''::character varying,
  c36 character varying(15) NOT NULL DEFAULT ''::character varying,
  c37 character varying(7) NOT NULL DEFAULT ''::character varying,
  c38 character varying(1) NOT NULL DEFAULT ''::character varying,
  c39 character varying(1) NOT NULL DEFAULT ''::character varying,
  c40 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c41 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c42 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c43 character varying(20) NOT NULL DEFAULT ''::character varying,
  c44 character varying(1) NOT NULL DEFAULT ''::character varying,
  c45 character varying(27) NOT NULL DEFAULT ''::character varying,
  c46 character varying(27) NOT NULL DEFAULT ''::character varying,
  c47 character varying(70) NOT NULL DEFAULT ''::character varying,
  c48 character varying(35) NOT NULL DEFAULT ''::character varying,
  c49 character varying(35) NOT NULL DEFAULT 'MEX'::character varying,
  c50 character varying(1) NOT NULL DEFAULT ''::character varying,
  c51 character varying(1) NOT NULL DEFAULT ''::character varying,
  c52 character varying(5) NULL DEFAULT ''::character varying,
  c53 character varying(20) NOT NULL DEFAULT ''::character varying,
  c54 character varying(3) NULL,
  c55 character varying(30) NULL,
  c56 character varying(20) NULL,
  c57 character varying(30) NULL,
  c58 character varying(20) NULL,
  c59 character varying(100) NULL,
  c60 character varying(100) NULL,
  c61 numeric NOT NULL DEFAULT 0,
  estatus numeric NOT NULL DEFAULT 0,
  subestatus numeric NOT NULL DEFAULT 0,
  nombre_referencia character varying(90) NOT NULL DEFAULT ''::character varying,
  parentesco_refer_cte character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdud02 ON keplersc.kdud USING btree (c3, c2) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdud ON keplersc.kdud USING btree (c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdud03 ON keplersc.kdud USING btree (c12, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdud04 ON keplersc.kdud USING btree (c13, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdud05 ON keplersc.kdud USING btree (c14, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdud06 ON keplersc.kdud USING btree (c40, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdud07 ON keplersc.kdud USING btree (c10) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdud IS 'Catalogo de clientes';
COMMENT ON COLUMN keplersc.kdud.subestatus IS 'Subestatus del cliente';
COMMENT ON COLUMN keplersc.kdud.parentesco_refer_cte IS 'Parentesco de la referencia con el cliente';
COMMENT ON COLUMN keplersc.kdud.nombre_referencia IS 'Nombre referencia';
COMMENT ON COLUMN keplersc.kdud.estatus IS 'Estatus del cliente';
COMMENT ON COLUMN keplersc.kdud.c9 IS 'Movil';
COMMENT ON COLUMN keplersc.kdud.c8 IS 'Telefono2';
COMMENT ON COLUMN keplersc.kdud.c7 IS 'Telefono';
COMMENT ON COLUMN keplersc.kdud.c61 IS 'Medio de contacto preferente (0 llamada, 10 Correo, 20 Whatsapp, 30 SMS) (kdmediocontacto)';
COMMENT ON COLUMN keplersc.kdud.c6 IS 'Ciudad o Poblacion';
COMMENT ON COLUMN keplersc.kdud.c59 IS 'D = Duplicado';
COMMENT ON COLUMN keplersc.kdud.c58 IS 'Telefono chofer';
COMMENT ON COLUMN keplersc.kdud.c57 IS 'Contacto chofer';
COMMENT ON COLUMN keplersc.kdud.c56 IS 'Telefono autoriza';
COMMENT ON COLUMN keplersc.kdud.c55 IS 'Contacto autoriza';
COMMENT ON COLUMN keplersc.kdud.c54 IS 'Clave del regimen fiscal';
COMMENT ON COLUMN keplersc.kdud.c53 IS 'Uso del CFDI/Cuenta';
COMMENT ON COLUMN keplersc.kdud.c52 IS 'Metodo de Pago/Forma de Pago';
COMMENT ON COLUMN keplersc.kdud.c51 IS 'Desglozar factura servicio';
COMMENT ON COLUMN keplersc.kdud.c50 IS 'Revisado';
COMMENT ON COLUMN keplersc.kdud.c5 IS 'Colonia';
COMMENT ON COLUMN keplersc.kdud.c49 IS 'Pais';
COMMENT ON COLUMN keplersc.kdud.c48 IS 'Estado';
COMMENT ON COLUMN keplersc.kdud.c47 IS 'Municipio';
COMMENT ON COLUMN keplersc.kdud.c46 IS 'Numero interior';
COMMENT ON COLUMN keplersc.kdud.c45 IS 'Numero exterior';
COMMENT ON COLUMN keplersc.kdud.c43 IS 'Modificador';
COMMENT ON COLUMN keplersc.kdud.c42 IS 'Ultima modificacion';
COMMENT ON COLUMN keplersc.kdud.c41 IS 'Penultimo movimiento';
COMMENT ON COLUMN keplersc.kdud.c40 IS 'Ultimo movimiento';
COMMENT ON COLUMN keplersc.kdud.c4 IS 'calle numero';
COMMENT ON COLUMN keplersc.kdud.c37 IS 'Extension';
COMMENT ON COLUMN keplersc.kdud.c36 IS 'Radio';
COMMENT ON COLUMN keplersc.kdud.c35 IS 'Nombres';
COMMENT ON COLUMN keplersc.kdud.c34 IS 'Apellido Materno';
COMMENT ON COLUMN keplersc.kdud.c33 IS 'Apellido Paterno';
COMMENT ON COLUMN keplersc.kdud.c32 IS 'Contacto';
COMMENT ON COLUMN keplersc.kdud.c30 IS 'Nombre impresion';
COMMENT ON COLUMN keplersc.kdud.c3 IS 'Nombre cliente';
COMMENT ON COLUMN keplersc.kdud.c29 IS 'Porcentaje comision cobranza';
COMMENT ON COLUMN keplersc.kdud.c28 IS 'Porcentaje comision';
COMMENT ON COLUMN keplersc.kdud.c27 IS 'Codigo Postal';
COMMENT ON COLUMN keplersc.kdud.c26 IS 'Lugar entrega mercancia tres';
COMMENT ON COLUMN keplersc.kdud.c25 IS 'Lugar entrega mercancia dos';
COMMENT ON COLUMN keplersc.kdud.c24 IS 'Lugar entrega mercancia';
COMMENT ON COLUMN keplersc.kdud.c23 IS 'Hora Pago';
COMMENT ON COLUMN keplersc.kdud.c22 IS 'Dia pago';
COMMENT ON COLUMN keplersc.kdud.c21 IS 'Hora revision';
COMMENT ON COLUMN keplersc.kdud.c20 IS 'Dia revision';
COMMENT ON COLUMN keplersc.kdud.c2 IS 'Clave cliente';
COMMENT ON COLUMN keplersc.kdud.c19 IS 'Porcentaje tercer descuento';
COMMENT ON COLUMN keplersc.kdud.c18 IS 'Porcentaje segundo descuento';
COMMENT ON COLUMN keplersc.kdud.c17 IS 'Porcentaje descuento';
COMMENT ON COLUMN keplersc.kdud.c16 IS 'Plazo credito';
COMMENT ON COLUMN keplersc.kdud.c15 IS 'Limite credito';
COMMENT ON COLUMN keplersc.kdud.c14 IS 'Clave zona';
COMMENT ON COLUMN keplersc.kdud.c13 IS 'Clave grupo';
COMMENT ON COLUMN keplersc.kdud.c12 IS 'Clave vendedor';
COMMENT ON COLUMN keplersc.kdud.c11 IS 'Email';
COMMENT ON COLUMN keplersc.kdud.c10 IS 'RFC';
COMMENT ON COLUMN keplersc.kdud.c1 IS 'Clave sucursal';

