CREATE  TABLE keplersc.kdtmktcomis_trabajo (
  sucursal character varying(2) NOT NULL,
  anio character varying(4) NOT NULL,
  mes character varying(2) NOT NULL,
  periodo character varying(1) NOT NULL DEFAULT ''::character varying,
  asesor_tmkt character varying(12) NOT NULL DEFAULT ''::character varying,
  tipo_trabajo character varying NOT NULL DEFAULT ''::character varying,
  inferior integer NOT NULL DEFAULT 0,
  superior integer NOT NULL DEFAULT 0,
  comision numeric(12,2) NULL DEFAULT 0,
  citas integer NOT NULL DEFAULT 0
) TABLESPACE pg_default;

