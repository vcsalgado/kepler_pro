CREATE  TABLE keplersc.sqliov (
  c1 character varying(20) NOT NULL DEFAULT ''::character varying,
  c2 numeric NOT NULL DEFAULT 0,
  c3 numeric NOT NULL DEFAULT 0,
  c4 character varying(51) NOT NULL DEFAULT ''::character varying,
  c5 character varying NULL,
  c6 character varying NULL,
  col_sucursal character varying(2) NOT NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.sqliov ADD CONSTRAINT sqliov_pk PRIMARY KEY (col_sucursal, c1, c2, c3);
CREATE UNIQUE INDEX IF NOT EXISTS sqliov_c1_idx ON keplersc.sqliov USING btree (c1, c2, c3) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_sqliov ON keplersc.sqliov USING btree (c1, c2, c3) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.sqliov IS 'Folios';
COMMENT ON COLUMN keplersc.sqliov.c6 IS 'Campo donde buscar folio';
COMMENT ON COLUMN keplersc.sqliov.c5 IS 'Tabla';

