CREATE  TABLE keplersc.kdfplacas (
  c1 numeric NOT NULL DEFAULT 0,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdfplacas ADD CONSTRAINT pk_kdfplacas PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdfplacas IS 'Formato placas';
COMMENT ON COLUMN keplersc.kdfplacas.c3 IS 'Formato';
COMMENT ON COLUMN keplersc.kdfplacas.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdfplacas.c1 IS 'IdFormato';

