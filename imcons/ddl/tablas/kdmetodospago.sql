CREATE  TABLE keplersc.kdmetodospago (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(45) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdmetodospago ADD CONSTRAINT pk_kdmetodospago PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdmetodospago02 ON keplersc.kdmetodospago USING btree (c3, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdmetodospago IS 'Metodos de pago';
COMMENT ON COLUMN keplersc.kdmetodospago.c3 IS 'Usar';
COMMENT ON COLUMN keplersc.kdmetodospago.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdmetodospago.c1 IS 'ID Metodo';

