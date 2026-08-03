CREATE  TABLE keplersc.kdreflastmov (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(18) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdreflastmov ON keplersc.kdreflastmov USING btree (c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdreflastmov02 ON keplersc.kdreflastmov USING btree (c1, c3, c2) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdreflastmov.c3 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdreflastmov.c2 IS 'Producto';
COMMENT ON COLUMN keplersc.kdreflastmov.c1 IS 'Sucursal_id';

