CREATE  TABLE keplersc.kdclaspaq (
  c1 character varying(5) NOT NULL,
  c2 character varying(29) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdclaspaq ADD CONSTRAINT kdclaspaq_pkey PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdclaspaq.c2 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdclaspaq.c1 IS 'Clave';

