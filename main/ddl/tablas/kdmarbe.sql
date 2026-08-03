CREATE  TABLE keplersc.kdmarbe (
  c1 numeric NOT NULL,
  c2 character varying(18) NULL,
  c3 character varying(60) NULL,
  c4 character varying(6) NULL,
  c5 character varying(6) NULL,
  c6 character varying(6) NULL,
  c7 character varying(5) NULL,
  col_sucursal character varying(2) NULL DEFAULT ''::character varying,
  CONSTRAINT kdmarbe_unique UNIQUE (col_sucursal, c1)
) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdmarbe.col_sucursal IS 'Sucursal Id';

