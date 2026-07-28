CREATE  TABLE keplersc.kdpuncot (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(70) NOT NULL DEFAULT ''::character varying,
  c7 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdpuncot ADD CONSTRAINT pk_kdpuncot PRIMARY KEY (c1, c2, c3, c4, c5);

