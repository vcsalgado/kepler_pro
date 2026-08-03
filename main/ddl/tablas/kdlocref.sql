CREATE  TABLE keplersc.kdlocref (
  c1 character varying(7) NULL,
  c2 character varying(18) NULL,
  c3 character varying(1) NULL,
  c4 character varying(6) NULL,
  c5 character varying(6) NULL,
  c6 character varying(6) NULL,
  CONSTRAINT kdlocref_unique UNIQUE (c1, c2)
) TABLESPACE pg_default;

