CREATE  TABLE keplersc.kdcomadic (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(18) NOT NULL DEFAULT ''::character varying,
  c9 numeric(10,2) NOT NULL DEFAULT 0,
  c10 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c11 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcomadic ADD CONSTRAINT pk_kdcomadic PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
CREATE INDEX IF NOT EXISTS sindkdcomadic02 ON keplersc.kdcomadic USING btree (c10, c8, c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;

