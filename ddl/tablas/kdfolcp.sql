CREATE  TABLE keplersc.kdfolcp (
  c1 numeric NOT NULL DEFAULT 0,
  c2 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdfolcp ADD CONSTRAINT pk_kdfolcp PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdfolcp.c2 IS 'Folio proveedores';
COMMENT ON COLUMN keplersc.kdfolcp.c1 IS 'Folio clientes';

