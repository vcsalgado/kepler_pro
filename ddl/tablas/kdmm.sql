CREATE  TABLE keplersc.kdmm (
  c1 character varying(1) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(40) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 character varying(4) NOT NULL DEFAULT ''::character varying,
  c16 character varying(4) NOT NULL DEFAULT ''::character varying,
  c17 character varying(8) NOT NULL DEFAULT ''::character varying,
  c18 character varying(1) NOT NULL DEFAULT ''::character varying,
  c19 character varying(20) NOT NULL DEFAULT ''::character varying,
  c20 character varying(16) NOT NULL DEFAULT ''::character varying,
  c21 character varying(16) NOT NULL DEFAULT ''::character varying,
  c22 character varying(16) NOT NULL DEFAULT ''::character varying,
  c23 character varying(16) NOT NULL DEFAULT ''::character varying,
  c24 character varying(16) NOT NULL DEFAULT ''::character varying,
  c25 numeric NOT NULL DEFAULT 0,
  c26 numeric NOT NULL DEFAULT 0,
  c27 character varying(1) NOT NULL DEFAULT ''::character varying,
  c28 character varying(1) NOT NULL DEFAULT ''::character varying,
  c29 character varying(1) NOT NULL DEFAULT ''::character varying,
  c30 character varying(1) NOT NULL DEFAULT ''::character varying,
  c31 character varying(1) NOT NULL DEFAULT ''::character varying,
  c32 numeric NOT NULL DEFAULT 0,
  c33 character varying(4) NOT NULL DEFAULT ''::character varying,
  c34 character varying(16) NOT NULL DEFAULT ''::character varying,
  c35 character varying(16) NOT NULL DEFAULT ''::character varying,
  c36 character varying(16) NOT NULL DEFAULT ''::character varying,
  c37 character varying(16) NOT NULL DEFAULT ''::character varying,
  c38 character varying(16) NOT NULL DEFAULT ''::character varying,
  c39 character varying(16) NOT NULL DEFAULT ''::character varying,
  c40 character varying(16) NOT NULL DEFAULT ''::character varying,
  c41 character varying(16) NOT NULL DEFAULT ''::character varying,
  c42 character varying(1) NOT NULL DEFAULT ''::character varying,
  c43 character varying(1) NOT NULL DEFAULT ''::character varying,
  c44 character varying(1) NOT NULL DEFAULT ''::character varying,
  c45 character varying(16) NOT NULL DEFAULT ''::character varying,
  c46 character varying(16) NOT NULL DEFAULT ''::character varying,
  c47 character varying(1) NOT NULL DEFAULT ''::character varying,
  c48 character varying(1) NOT NULL DEFAULT ''::character varying,
  c49 numeric NOT NULL DEFAULT 0,
  c50 numeric NOT NULL DEFAULT 0,
  c51 character varying(1) NOT NULL DEFAULT ''::character varying,
  c52 character varying(1) NOT NULL DEFAULT ''::character varying,
  c53 character varying(1) NOT NULL DEFAULT ''::character varying,
  c54 numeric NOT NULL DEFAULT 0,
  c55 numeric NOT NULL DEFAULT 0,
  c56 numeric NOT NULL DEFAULT 0,
  c57 numeric NOT NULL DEFAULT 0,
  c58 numeric NOT NULL DEFAULT 0,
  c59 numeric NOT NULL DEFAULT 0,
  c60 numeric NOT NULL DEFAULT 0,
  c61 numeric NOT NULL DEFAULT 0,
  c62 numeric NOT NULL DEFAULT 0,
  c63 numeric NOT NULL DEFAULT 0,
  c64 character varying(16) NOT NULL DEFAULT ''::character varying,
  c65 numeric NOT NULL DEFAULT 0,
  c66 character varying(1) NOT NULL DEFAULT ''::character varying,
  c67 character varying(1) NOT NULL DEFAULT ''::character varying,
  c68 character varying(50) NOT NULL DEFAULT ''::character varying,
  c69 character varying(16) NOT NULL DEFAULT ''::character varying,
  c70 numeric NOT NULL DEFAULT 0,
  c71 character varying(1) NOT NULL DEFAULT ''::character varying,
  c72 character varying(16) NOT NULL DEFAULT ''::character varying,
  c73 character varying(16) NOT NULL DEFAULT ''::character varying,
  c74 character varying(16) NOT NULL DEFAULT ''::character varying,
  c75 character varying(4) NOT NULL DEFAULT ''::character varying,
  c76 character varying(1) NOT NULL DEFAULT ''::character varying,
  c77 character varying(1) NOT NULL DEFAULT ''::character varying,
  c78 character varying(1) NOT NULL DEFAULT ''::character varying,
  c79 character varying(1) NOT NULL DEFAULT ''::character varying,
  c80 character varying(1) NOT NULL DEFAULT ''::character varying,
  c81 character varying(1) NOT NULL DEFAULT ''::character varying,
  c82 character varying(1) NOT NULL DEFAULT ''::character varying,
  c83 character varying(1) NOT NULL DEFAULT ''::character varying,
  c84 character varying(1) NOT NULL DEFAULT ''::character varying,
  c85 character varying(1) NOT NULL DEFAULT ''::character varying,
  c86 character varying(1) NOT NULL DEFAULT ''::character varying,
  c87 character varying(1) NOT NULL DEFAULT ''::character varying,
  c88 character varying(1) NOT NULL DEFAULT ''::character varying,
  c89 character varying(1) NOT NULL DEFAULT ''::character varying,
  c90 character varying(1) NOT NULL DEFAULT ''::character varying,
  c91 character varying(1) NOT NULL DEFAULT ''::character varying,
  c92 character varying(1) NOT NULL DEFAULT ''::character varying,
  c93 character varying(1) NOT NULL DEFAULT ''::character varying,
  c94 character varying(1) NOT NULL DEFAULT 'G'::character varying,
  c95 character varying(1) NOT NULL DEFAULT ''::character varying,
  c96 character varying(1) NOT NULL DEFAULT ''::character varying,
  c97 character varying(1) NOT NULL DEFAULT ''::character varying,
  c98 character varying(1) NOT NULL DEFAULT ''::character varying,
  c99 character varying(1) NOT NULL DEFAULT ''::character varying,
  c100 character varying(20) NOT NULL DEFAULT ''::character varying,
  c101 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c102 character varying NOT NULL DEFAULT ''::character varying,
  col_sucursal character varying(2) NOT NULL DEFAULT '01'::character varying,
  folio_manual character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdmm ADD CONSTRAINT kdmm_pk PRIMARY KEY (c1, c2, c3, c4, col_sucursal);
COMMENT ON TABLE keplersc.kdmm IS 'Catálogo de documentos';
COMMENT ON COLUMN keplersc.kdmm.folio_manual IS 'Folio manual';
COMMENT ON COLUMN keplersc.kdmm.c95 IS 'Uen V=Ventas, S=Servicio, R=Refacciones';
COMMENT ON COLUMN keplersc.kdmm.c94 IS 'N=Nota de Credito, A=Anulacion, G=General';
COMMENT ON COLUMN keplersc.kdmm.c93 IS 'Registra proteccion antilavado o Folio automatico';
COMMENT ON COLUMN keplersc.kdmm.c92 IS 'Requiere privilegios mov cartera';
COMMENT ON COLUMN keplersc.kdmm.c91 IS 'Paga comisiones refacciones';
COMMENT ON COLUMN keplersc.kdmm.c90 IS 'Documento invalido';
COMMENT ON COLUMN keplersc.kdmm.c9 IS 'S=Afecta estadística de ventas brutas ó N=No afecta';
COMMENT ON COLUMN keplersc.kdmm.c89 IS 'CFD adenda';
COMMENT ON COLUMN keplersc.kdmm.c88 IS 'Original/copia';
COMMENT ON COLUMN keplersc.kdmm.c87 IS 'CFD automatico';
COMMENT ON COLUMN keplersc.kdmm.c86 IS 'Abrir campo importe';
COMMENT ON COLUMN keplersc.kdmm.c85 IS 'Backorder';
COMMENT ON COLUMN keplersc.kdmm.c84 IS 'Pedido Sugerido';
COMMENT ON COLUMN keplersc.kdmm.c83 IS 'Pedido Especial';
COMMENT ON COLUMN keplersc.kdmm.c82 IS 'Layout CFD';
COMMENT ON COLUMN keplersc.kdmm.c81 IS 'Tipo CFD';
COMMENT ON COLUMN keplersc.kdmm.c80 IS 'Genera CFD';
COMMENT ON COLUMN keplersc.kdmm.c8 IS 'S=Afecta Inventarios';
COMMENT ON COLUMN keplersc.kdmm.c77 IS 'Afecta costo inventario';
COMMENT ON COLUMN keplersc.kdmm.c76 IS 'Intersucursales';
COMMENT ON COLUMN keplersc.kdmm.c75 IS 'Porcentaje otras retenciones';
COMMENT ON COLUMN keplersc.kdmm.c74 IS 'Cuenta otras retenciones';
COMMENT ON COLUMN keplersc.kdmm.c73 IS 'IVA anticipos';
COMMENT ON COLUMN keplersc.kdmm.c72 IS 'IVA anticipos';
COMMENT ON COLUMN keplersc.kdmm.c71 IS 'Tiene pantalla movimientos contables';
COMMENT ON COLUMN keplersc.kdmm.c70 IS 'Campo a añadir';
COMMENT ON COLUMN keplersc.kdmm.c7 IS 'S=Afecta Cuentas x Cobrar ó Ctas x Pagar';
COMMENT ON COLUMN keplersc.kdmm.c69 IS 'Cuenta extra despues IVA';
COMMENT ON COLUMN keplersc.kdmm.c68 IS 'Directorio taller';
COMMENT ON COLUMN keplersc.kdmm.c67 IS 'Cargo/abono costo';
COMMENT ON COLUMN keplersc.kdmm.c66 IS 'Ventas contado';
COMMENT ON COLUMN keplersc.kdmm.c65 IS 'Estado operacion inventario';
COMMENT ON COLUMN keplersc.kdmm.c64 IS 'Cuenta retencion IVA';
COMMENT ON COLUMN keplersc.kdmm.c63 IS 'Campo añadir cta extra 10';
COMMENT ON COLUMN keplersc.kdmm.c62 IS 'Campo añadir cta extra 9';
COMMENT ON COLUMN keplersc.kdmm.c61 IS 'Campo añadir cta extra 8';
COMMENT ON COLUMN keplersc.kdmm.c60 IS 'Campo añadir cta extra 7';
COMMENT ON COLUMN keplersc.kdmm.c6 IS 'S=Afecta Contabilidad General';
COMMENT ON COLUMN keplersc.kdmm.c59 IS 'Campo añadir cta extra 6';
COMMENT ON COLUMN keplersc.kdmm.c58 IS 'Campo añadir cta extra 5';
COMMENT ON COLUMN keplersc.kdmm.c57 IS 'Campo añadir cta extra 4';
COMMENT ON COLUMN keplersc.kdmm.c56 IS 'Campo añadir cta extra 3';
COMMENT ON COLUMN keplersc.kdmm.c55 IS 'Campo añadir cta extra 2';
COMMENT ON COLUMN keplersc.kdmm.c54 IS 'Campo añadir cta extra 1';
COMMENT ON COLUMN keplersc.kdmm.c53 IS 'Entrada Salida';
COMMENT ON COLUMN keplersc.kdmm.c52 IS 'Maneja backorder';
COMMENT ON COLUMN keplersc.kdmm.c51 IS 'Ingreso Egreso Caja';
COMMENT ON COLUMN keplersc.kdmm.c50 IS 'Campo añadir cuenta destino banco';
COMMENT ON COLUMN keplersc.kdmm.c5 IS 'Descripción del movimineto';
COMMENT ON COLUMN keplersc.kdmm.c49 IS 'Campo añadir cuenta origen banco';
COMMENT ON COLUMN keplersc.kdmm.c48 IS 'Afecta refacciones vehiculos';
COMMENT ON COLUMN keplersc.kdmm.c47 IS 'Pantalla movimientos CxP';
COMMENT ON COLUMN keplersc.kdmm.c46 IS 'Cuenta destino';
COMMENT ON COLUMN keplersc.kdmm.c45 IS 'Cuenta origen';
COMMENT ON COLUMN keplersc.kdmm.c44 IS 'Tipo movimiento bancos';
COMMENT ON COLUMN keplersc.kdmm.c43 IS 'Afecta bancos';
COMMENT ON COLUMN keplersc.kdmm.c42 IS 'Movimiento intercompañias';
COMMENT ON COLUMN keplersc.kdmm.c41 IS 'Cuenta contable extra 10';
COMMENT ON COLUMN keplersc.kdmm.c40 IS 'Cuenta contable extra 9';
COMMENT ON COLUMN keplersc.kdmm.c4 IS 'Tipo del movimiento';
COMMENT ON COLUMN keplersc.kdmm.c39 IS 'Cuenta contable extra 8';
COMMENT ON COLUMN keplersc.kdmm.c38 IS 'Cuenta contable extra 7';
COMMENT ON COLUMN keplersc.kdmm.c37 IS 'Cuenta contable extra 6';
COMMENT ON COLUMN keplersc.kdmm.c36 IS 'Cuenta contable extra 5';
COMMENT ON COLUMN keplersc.kdmm.c35 IS 'Cuenta contable extra 4';
COMMENT ON COLUMN keplersc.kdmm.c34 IS 'Cuenta contable extra 3';
COMMENT ON COLUMN keplersc.kdmm.c33 IS 'Porciento de IVA retenido';
COMMENT ON COLUMN keplersc.kdmm.c32 IS 'No de campo a añadir al nombre del archivo de folio';
COMMENT ON COLUMN keplersc.kdmm.c31 IS 'S=Divide la cta de IEPS en cuentas complemetarias';
COMMENT ON COLUMN keplersc.kdmm.c30 IS 'S=Divide la cta de IVA en cuentas complemetarias';
COMMENT ON COLUMN keplersc.kdmm.c3 IS 'Número de grupo de movimientos';
COMMENT ON COLUMN keplersc.kdmm.c29 IS 'S=Divide la cta secundaria en cuentas complemetaria';
COMMENT ON COLUMN keplersc.kdmm.c28 IS 'S=Divide la cta princiapl en cuentas complemetarias';
COMMENT ON COLUMN keplersc.kdmm.c27 IS 'S=Restinge a no facturar en rojo';
COMMENT ON COLUMN keplersc.kdmm.c26 IS 'Número del campo a añadir a la cuenta secundaria';
COMMENT ON COLUMN keplersc.kdmm.c25 IS 'Número del campo a añadir a la cuenta principal';
COMMENT ON COLUMN keplersc.kdmm.c24 IS 'Abonos Anticipos/Bonificaciones';
COMMENT ON COLUMN keplersc.kdmm.c23 IS 'Cargos Anticipos/Bonificaciones';
COMMENT ON COLUMN keplersc.kdmm.c22 IS 'Cuenta contable retencion ISR / IVA complementario / o del  IEPS';
COMMENT ON COLUMN keplersc.kdmm.c21 IS 'Cuenta contable del IVA';
COMMENT ON COLUMN keplersc.kdmm.c20 IS 'Cuenta contable del Abono';
COMMENT ON COLUMN keplersc.kdmm.c2 IS 'Naturaleza: D=Duedora  A=Acreedora N=No Aplica';
COMMENT ON COLUMN keplersc.kdmm.c19 IS 'Cuenta contable del Cargo';
COMMENT ON COLUMN keplersc.kdmm.c18 IS 'El tipo de póliza a producir: E/I/D';
COMMENT ON COLUMN keplersc.kdmm.c17 IS 'Nombre del archivo que contiene el folio';
COMMENT ON COLUMN keplersc.kdmm.c16 IS 'IVA porcentual (99 toma IVA del producto)';
COMMENT ON COLUMN keplersc.kdmm.c15 IS 'Porcentaje de retención del ISR';
COMMENT ON COLUMN keplersc.kdmm.c14 IS 'S=Afecta fecha del último cobro ó N=No afecta';
COMMENT ON COLUMN keplersc.kdmm.c13 IS 'S=Afecta estadística de Notas de cargo ó N=No afect';
COMMENT ON COLUMN keplersc.kdmm.c12 IS 'S=Afecta estadística de Notas de crédito ó N=No afecta';
COMMENT ON COLUMN keplersc.kdmm.c11 IS 'S=Afecta estadística de devoluciones ó N=No afecta';
COMMENT ON COLUMN keplersc.kdmm.c10 IS 'S=Afecta estadística de bonificaciones ó N=No afecta';
COMMENT ON COLUMN keplersc.kdmm.c1 IS 'Género: U=Ctas x cobrar X=Ctas x Pagar N=Otras';

