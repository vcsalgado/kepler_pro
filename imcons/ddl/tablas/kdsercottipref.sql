CREATE  TABLE keplersc.kdsercottipref (
  c1 character varying(5) NULL,
  c2 character varying(30) NULL
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS kdsercottipref_c1_idx ON keplersc.kdsercottipref USING btree (c1) TABLESPACE pg_default;

