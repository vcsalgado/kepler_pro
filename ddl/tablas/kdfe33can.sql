CREATE  TABLE keplersc.kdfe33can (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 character varying(36) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(7) NOT NULL DEFAULT ''::character varying,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 character varying(5) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(30) NOT NULL DEFAULT ''::character varying,
  c14 character varying(100) NOT NULL DEFAULT ''::character varying,
  c15 character varying(1) NOT NULL DEFAULT ''::character varying,
  c16 character varying(20) NOT NULL DEFAULT ''::character varying,
  c17 character varying(30) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdfe33can ADD CONSTRAINT pk_kdfe33can PRIMARY KEY (c1, c2, c3);
CREATE INDEX IF NOT EXISTS sindkdfe33can02 ON keplersc.kdfe33can USING btree (c2, c3, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdfe33can03 ON keplersc.kdfe33can USING btree (c1, c5, c6, c7, c8, c9) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdfe33can04 ON keplersc.kdfe33can USING btree (c16, c1, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdfe33can05 ON keplersc.kdfe33can USING btree (c17, c16, c1, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdfe33can06 ON keplersc.kdfe33can USING btree (c4, c1, c2, c3) TABLESPACE pg_default;

