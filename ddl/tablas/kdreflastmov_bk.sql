CREATE  TABLE keplersc.kdreflastmov_bk (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(18) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS kdreflastmov_bk_c1_c2_idx ON keplersc.kdreflastmov_bk USING btree (c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdreflastmov_bk_c1_c3_c2_idx ON keplersc.kdreflastmov_bk USING btree (c1, c3, c2) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdreflastmov_bk.c3 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdreflastmov_bk.c2 IS 'Producto';
COMMENT ON COLUMN keplersc.kdreflastmov_bk.c1 IS 'Sucursal_id';

