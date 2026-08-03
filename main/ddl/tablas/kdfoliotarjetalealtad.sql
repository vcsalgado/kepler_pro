CREATE  TABLE keplersc.kdfoliotarjetalealtad (
  c1 character varying(18) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdfoliotarjetalealtad ADD CONSTRAINT pk_kdfoliotarjetalealtad PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdfoliotarjetalealtad02 ON keplersc.kdfoliotarjetalealtad USING btree (c2) TABLESPACE pg_default;

