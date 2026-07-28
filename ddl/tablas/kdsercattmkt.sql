CREATE  TABLE keplersc.kdsercattmkt (
  c1 character varying(20) NOT NULL DEFAULT ''::character varying,
  c2 character varying NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying NOT NULL DEFAULT ''::character varying,
  c5 character varying NOT NULL DEFAULT ''::character varying,
  c6 character varying NOT NULL DEFAULT ''::character varying,
  c7 character varying NOT NULL DEFAULT ''::character varying,
  col_sucursal character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdsercattmkt ADD CONSTRAINT pk_kdsercattmkt PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdsercattmkt IS 'Asesores de Telemarketing';
COMMENT ON COLUMN keplersc.kdsercattmkt.c7 IS 'Extension';
COMMENT ON COLUMN keplersc.kdsercattmkt.c6 IS 'Telefono 2';
COMMENT ON COLUMN keplersc.kdsercattmkt.c5 IS 'Telefono 1';
COMMENT ON COLUMN keplersc.kdsercattmkt.c4 IS 'Mail';
COMMENT ON COLUMN keplersc.kdsercattmkt.c3 IS 'A=Activo; I=Inactivo';
COMMENT ON COLUMN keplersc.kdsercattmkt.c2 IS 'Nombre';
COMMENT ON COLUMN keplersc.kdsercattmkt.c1 IS 'Clave';

