CREATE  TABLE keplersc.ifz_bp_citas_usrtmkt (
  usrtmkt character varying(20) NOT NULL DEFAULT ''::character varying,
  id_usr_bp integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_citas_usrtmkt_un UNIQUE (id_usr_bp)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_citas_usrtmkt ADD CONSTRAINT ifz_bp_citas_usrtmkt_pk PRIMARY KEY (usrtmkt);
COMMENT ON TABLE keplersc.ifz_bp_citas_usrtmkt IS 'Tabla Interface GM-BP - Gestionar Usuarios TMKT';
COMMENT ON COLUMN keplersc.ifz_bp_citas_usrtmkt.usrtmkt IS 'Usuario TMKT Inmotion';
COMMENT ON COLUMN keplersc.ifz_bp_citas_usrtmkt.id_usr_bp IS 'Id Usuario en BP';

