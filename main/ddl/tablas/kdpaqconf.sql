CREATE  TABLE keplersc.kdpaqconf (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdpaqconf ADD CONSTRAINT pk_kdpaqconf PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdpaqconf.c2 IS 'Acción sobre los paquetes (F=Precio Fijo, S=Sum)';
COMMENT ON COLUMN keplersc.kdpaqconf.c1 IS 'Sucursal';

