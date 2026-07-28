CREATE  TABLE keplersc.kdtord (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 character varying(6) NOT NULL DEFAULT ''::character varying,
  c5 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c6 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 numeric NOT NULL DEFAULT 0,
  c10 numeric NOT NULL DEFAULT 0,
  c11 character varying(10) NOT NULL DEFAULT ''::character varying,
  c12 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtord ADD CONSTRAINT pk_kdtord PRIMARY KEY (c1, c2, c3);
CREATE INDEX IF NOT EXISTS kdtord_c1_idx ON keplersc.kdtord USING btree (c1, c7, c8, c9, c10, c11) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtord02 ON keplersc.kdtord USING btree (c1, c5, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtord03 ON keplersc.kdtord USING btree (c1, c6, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtord04 ON keplersc.kdtord USING btree (c1, c4, c5, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtord05 ON keplersc.kdtord USING btree (c1, c4, c6, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtord06 ON keplersc.kdtord USING btree (c1, c5, c6, c2, c3) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdtord.c9 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdtord.c8 IS 'Genero';
COMMENT ON COLUMN keplersc.kdtord.c7 IS 'Naturaleza Factura';
COMMENT ON COLUMN keplersc.kdtord.c6 IS 'Fecha de Salida';
COMMENT ON COLUMN keplersc.kdtord.c5 IS 'Fecha de Entrada';
COMMENT ON COLUMN keplersc.kdtord.c4 IS 'Recepcionista';
COMMENT ON COLUMN keplersc.kdtord.c3 IS 'Folio de Orden';
COMMENT ON COLUMN keplersc.kdtord.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdtord.c12 IS 'Fecha de Cierre';
COMMENT ON COLUMN keplersc.kdtord.c11 IS 'Folio';
COMMENT ON COLUMN keplersc.kdtord.c10 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdtord.c1 IS 'Sucursal';

