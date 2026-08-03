CREATE  TABLE keplersc.kdil (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 numeric NOT NULL DEFAULT 0,
  c3 character varying(18) NOT NULL DEFAULT ''::character varying,
  c4 double precision NOT NULL DEFAULT 0,
  c5 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c6 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c7 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c8 double precision NOT NULL DEFAULT 0,
  c9 double precision NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdil ADD CONSTRAINT pk_kdil PRIMARY KEY (c1, c2, c3);
CREATE INDEX IF NOT EXISTS sindkdil02 ON keplersc.kdil USING btree (c1, c3, c2) TABLESPACE pg_default;

