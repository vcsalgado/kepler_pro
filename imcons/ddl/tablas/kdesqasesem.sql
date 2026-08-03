CREATE  TABLE keplersc.kdesqasesem (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c4 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;

