CREATE  TABLE keplersc.kdvntall (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 character varying(10) NOT NULL DEFAULT ''::character varying,
  c11 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c12 character varying(7) NOT NULL DEFAULT ''::character varying,
  c13 character varying(7) NOT NULL DEFAULT ''::character varying,
  c14 character varying(10) NOT NULL DEFAULT ''::character varying,
  c15 character varying(5) NOT NULL DEFAULT ''::character varying,
  c16 character varying(10) NOT NULL DEFAULT ''::character varying,
  c17 numeric(15,2) NOT NULL DEFAULT 0,
  c18 character varying(1) NOT NULL DEFAULT ''::character varying,
  c19 character varying(1) NOT NULL DEFAULT ''::character varying,
  c20 numeric(10,2) NOT NULL DEFAULT 0,
  c21 numeric(10,2) NOT NULL DEFAULT 0,
  c22 numeric(10,2) NOT NULL DEFAULT 0,
  c23 numeric(10,2) NOT NULL DEFAULT 0,
  c24 character varying(1) NOT NULL DEFAULT ''::character varying,
  c25 numeric(19,6) NOT NULL DEFAULT 0,
  c26 numeric(10,2) NOT NULL DEFAULT 0,
  c27 character varying(8) NOT NULL DEFAULT ''::character varying,
  col_foliomig character varying(10) NULL,
  col_foliofin character varying(10) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvntall ADD CONSTRAINT pk_kdvntall PRIMARY KEY (c1, c2, c3, c4);
CREATE INDEX IF NOT EXISTS sindkdvntall02 ON keplersc.kdvntall USING btree (c1, c6, c7, c8, c9, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvntall03 ON keplersc.kdvntall USING btree (c1, c2, c11, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvntall04 ON keplersc.kdvntall USING btree (c1, c13, c11, c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvntall05 ON keplersc.kdvntall USING btree (c1, c14, c11, c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvntall06 ON keplersc.kdvntall USING btree (c1, c15, c16, c11, c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvntall07 ON keplersc.kdvntall USING btree (c1, c5, c11, c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvntall08 ON keplersc.kdvntall USING btree (c1, c6, c7, c8, c9, c11, c10) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdvntall.c9 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdvntall.c8 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdvntall.c7 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdvntall.c6 IS 'Genero';
COMMENT ON COLUMN keplersc.kdvntall.c5 IS '0=Alta 10=Baja';
COMMENT ON COLUMN keplersc.kdvntall.c4 IS 'Partida';
COMMENT ON COLUMN keplersc.kdvntall.c3 IS 'Folio';
COMMENT ON COLUMN keplersc.kdvntall.c26 IS 'Importe';
COMMENT ON COLUMN keplersc.kdvntall.c25 IS 'IVA';
COMMENT ON COLUMN keplersc.kdvntall.c23 IS 'Preco cargos varios';
COMMENT ON COLUMN keplersc.kdvntall.c22 IS 'Precio TOTs';
COMMENT ON COLUMN keplersc.kdvntall.c21 IS 'Precio Refacciones';
COMMENT ON COLUMN keplersc.kdvntall.c20 IS 'Precio Mano de Obra';
COMMENT ON COLUMN keplersc.kdvntall.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdvntall.c17 IS 'Kilometraje';
COMMENT ON COLUMN keplersc.kdvntall.c16 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdvntall.c15 IS 'Marca';
COMMENT ON COLUMN keplersc.kdvntall.c14 IS 'Identificador';
COMMENT ON COLUMN keplersc.kdvntall.c13 IS 'Recepcionista';
COMMENT ON COLUMN keplersc.kdvntall.c12 IS 'Cliente';
COMMENT ON COLUMN keplersc.kdvntall.c11 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdvntall.c10 IS 'Folio';
COMMENT ON COLUMN keplersc.kdvntall.c1 IS 'Sucursal';
CREATE TRIGGER kdvntall_notif AFTER INSERT OR DELETE OR UPDATE ON keplersc.kdvntall FOR EACH ROW EXECUTE FUNCTION keplersc.notif_registrar_movto();

