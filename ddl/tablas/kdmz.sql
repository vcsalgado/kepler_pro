CREATE  TABLE keplersc.kdmz (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c3 character varying(6) NOT NULL DEFAULT ''::character varying,
  c4 double precision NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdmz ADD CONSTRAINT pk_kdmz PRIMARY KEY (c1, c2);

