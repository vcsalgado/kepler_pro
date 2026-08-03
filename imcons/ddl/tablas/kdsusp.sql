CREATE  TABLE keplersc.kdsusp (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdsusp ADD CONSTRAINT pk_kdsusp PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdsusp02 ON keplersc.kdsusp USING btree (c1, c3) TABLESPACE pg_default;

