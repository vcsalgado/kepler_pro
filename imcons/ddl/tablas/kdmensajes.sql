CREATE  TABLE keplersc.kdmensajes (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c4 character varying(10) NOT NULL DEFAULT ''::character varying,
  c5 character varying(10) NOT NULL DEFAULT ''::character varying,
  c6 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c7 character varying(231) NOT NULL DEFAULT ''::character varying,
  c8 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 character varying(60) NOT NULL DEFAULT ''::character varying,
  c11 character varying(99) NOT NULL DEFAULT ''::character varying,
  c12 character varying(99) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdmensajes ON keplersc.kdmensajes USING btree (c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdmensajes02 ON keplersc.kdmensajes USING btree (c1, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdmensajes03 ON keplersc.kdmensajes USING btree (c4, c1, c2, c3) TABLESPACE pg_default;

