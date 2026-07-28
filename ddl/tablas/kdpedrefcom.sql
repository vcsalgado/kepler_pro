CREATE  TABLE keplersc.kdpedrefcom (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 character varying(18) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric(10,2) NOT NULL DEFAULT 0,
  c10 character varying(7) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 numeric NOT NULL DEFAULT 0,
  c14 numeric NOT NULL DEFAULT 0,
  c15 character varying(10) NOT NULL DEFAULT ''::character varying,
  c16 numeric NOT NULL DEFAULT 0,
  c17 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c18 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdpedrefcom ADD CONSTRAINT pk_kdpedrefcom PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7, c8);
CREATE INDEX IF NOT EXISTS sindkdpedrefcom02 ON keplersc.kdpedrefcom USING btree (c10, c11, c12, c13, c14, c15, c16) TABLESPACE pg_default;

