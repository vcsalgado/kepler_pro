CREATE  TABLE keplersc.crdcreditvar (
  k_branch character varying(20) NOT NULL DEFAULT ''::character varying,
  k_cred character varying(10) NOT NULL DEFAULT ''::character varying,
  k_disp double precision NOT NULL DEFAULT 0,
  k_ndisp numeric NOT NULL DEFAULT 0,
  k_date timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  k_balance double precision NOT NULL DEFAULT 0,
  k_update numeric NOT NULL DEFAULT 0,
  k_liq numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.crdcreditvar ADD CONSTRAINT pk_crdcreditvar PRIMARY KEY (k_branch, k_cred);

