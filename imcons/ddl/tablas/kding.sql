CREATE  TABLE keplersc.kding (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kding ADD CONSTRAINT pk_kding PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kding IS 'Pedido sugerido grupos';
COMMENT ON COLUMN keplersc.kding.c3 IS 'Marca como phase out';
COMMENT ON COLUMN keplersc.kding.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kding.c1 IS 'Id Agrupador';

