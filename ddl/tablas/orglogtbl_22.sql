CREATE  TABLE keplersc.orglogtbl_22 (
  k_table character varying(25) NOT NULL DEFAULT ''::character varying,
  k_mode character varying(3) NOT NULL DEFAULT ''::character varying,
  k_date timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  k_cns numeric NOT NULL DEFAULT 0,
  k_user character varying(20) NOT NULL DEFAULT ''::character varying,
  k_str1 character varying(150) NOT NULL DEFAULT ''::character varying,
  k_str2 character varying(150) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.orglogtbl_22 ADD CONSTRAINT pk_orglogtbl_22 PRIMARY KEY (k_table, k_mode, k_date, k_cns);
CREATE UNIQUE INDEX IF NOT EXISTS indorglogtbl_221 ON keplersc.orglogtbl_22 USING btree (k_date, k_cns, k_table, k_mode) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS indorglogtbl_222 ON keplersc.orglogtbl_22 USING btree (k_user, k_date, k_cns, k_table, k_mode) TABLESPACE pg_default;

