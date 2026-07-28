CREATE  TABLE keplersc.prepicking (
  c1 character varying NOT NULL,
  c2 character varying NOT NULL,
  c3 character varying NOT NULL,
  c4 numeric NOT NULL,
  c5 numeric NOT NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.prepicking IS 'prepicking de refacciones en citas de servicio';
COMMENT ON COLUMN keplersc.prepicking.c5 IS 'Status';
COMMENT ON COLUMN keplersc.prepicking.c4 IS 'Cantidad';
COMMENT ON COLUMN keplersc.prepicking.c3 IS 'Clave Refaccion';
COMMENT ON COLUMN keplersc.prepicking.c2 IS 'Folio Cita';
COMMENT ON COLUMN keplersc.prepicking.c1 IS 'Sucursal';

