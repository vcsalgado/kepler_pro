CREATE  TABLE keplersc.kdrefadicionales (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(18) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 numeric NOT NULL DEFAULT 0,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(10) NOT NULL DEFAULT ''::character varying,
  c9 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdrefadicionales ADD CONSTRAINT pk_kdrefadicionales PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7, c8);
CREATE INDEX IF NOT EXISTS sindkdrefadicionales02 ON keplersc.kdrefadicionales USING btree (c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdrefadicionales03 ON keplersc.kdrefadicionales USING btree (c1, c4, c5, c6, c7, c8) TABLESPACE pg_default;

