CREATE  TABLE keplersc.kdsercotstock (
  c1 character varying(5) NULL,
  c2 character varying(20) NULL
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS kdsercotstock_c1_idx ON keplersc.kdsercotstock USING btree (c1) TABLESPACE pg_default;

