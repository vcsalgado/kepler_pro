CREATE  TABLE keplersc.doctype (
  k_code character varying(20) NOT NULL DEFAULT ''::character varying,
  k_parent character varying(20) NOT NULL DEFAULT ''::character varying,
  k_dscr character varying(40) NOT NULL DEFAULT ''::character varying,
  k_level character varying(1) NOT NULL DEFAULT ''::character varying,
  k_foliocode character varying(20) NOT NULL DEFAULT ''::character varying,
  k_foliofield character varying(10) NOT NULL DEFAULT ''::character varying,
  k_gender character varying(1) NOT NULL DEFAULT ''::character varying,
  k_nature character varying(1) NOT NULL DEFAULT ''::character varying,
  k_inactive numeric NOT NULL DEFAULT 0,
  k_sttstc character varying(1) NOT NULL DEFAULT ''::character varying,
  k_jtype character varying(8) NOT NULL DEFAULT ''::character varying,
  k_doc7 character varying(8) NOT NULL DEFAULT ''::character varying,
  k_binv numeric NOT NULL DEFAULT 0,
  k_bacr numeric NOT NULL DEFAULT 0,
  k_bacc numeric NOT NULL DEFAULT 0,
  k_bcash numeric NOT NULL DEFAULT 0,
  k_pg character varying(20) NOT NULL DEFAULT ''::character varying,
  k_pgcode character varying(20) NOT NULL DEFAULT ''::character varying,
  k_pginv character varying(10) NOT NULL DEFAULT ''::character varying,
  k_pgprt character varying(10) NOT NULL DEFAULT ''::character varying,
  k_pgacc character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.doctype ADD CONSTRAINT pk_doctype PRIMARY KEY (k_code);
CREATE UNIQUE INDEX IF NOT EXISTS inddoctype1 ON keplersc.doctype USING btree (k_parent, k_code) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS inddoctype2 ON keplersc.doctype USING btree (k_doc7, k_code) TABLESPACE pg_default;

