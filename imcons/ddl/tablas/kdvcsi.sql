CREATE  TABLE keplersc.kdvcsi (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(2) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying,
  c4 numeric(10,5) NOT NULL DEFAULT 0,
  c5 numeric(10,5) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvcsi ADD CONSTRAINT pk_kdvcsi PRIMARY KEY (c1, c2, c3);
COMMENT ON COLUMN keplersc.kdvcsi.c5 IS 'CSI Plata';
COMMENT ON COLUMN keplersc.kdvcsi.c4 IS 'CSI Interno';
COMMENT ON COLUMN keplersc.kdvcsi.c3 IS 'Mes';
COMMENT ON COLUMN keplersc.kdvcsi.c2 IS 'Año';
COMMENT ON COLUMN keplersc.kdvcsi.c1 IS 'Sucursal';

