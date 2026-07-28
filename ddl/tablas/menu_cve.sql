CREATE  TABLE keplersc.menu_cve (
  c1 character varying(23) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(60) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_menu_cve ON keplersc.menu_cve USING btree (c1) TABLESPACE pg_default;

