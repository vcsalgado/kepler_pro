CREATE  TABLE keplersc.kdcompord (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 character varying(7) NOT NULL DEFAULT ''::character varying,
  c5 character varying(70) NOT NULL DEFAULT ''::character varying,
  c6 character varying(70) NOT NULL DEFAULT ''::character varying,
  c7 character varying(70) NULL DEFAULT ''::character varying,
  c8 character varying(50) NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcompord ADD CONSTRAINT pk_kdcompord PRIMARY KEY (c1, c2, c3, c4);
COMMENT ON COLUMN keplersc.kdcompord.c8 IS 'Tipo Componente C-Completo M-Medio B-Basico';
COMMENT ON COLUMN keplersc.kdcompord.c7 IS 'Observaciones';
COMMENT ON COLUMN keplersc.kdcompord.c6 IS 'Estado componente';
COMMENT ON COLUMN keplersc.kdcompord.c5 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdcompord.c4 IS 'Clave actividad';
COMMENT ON COLUMN keplersc.kdcompord.c3 IS 'Folio orden';
COMMENT ON COLUMN keplersc.kdcompord.c2 IS 'Tipo orden';
COMMENT ON COLUMN keplersc.kdcompord.c1 IS 'Sucursal';

