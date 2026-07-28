CREATE  TABLE keplersc.kdtmktcomis_det (
  sucursal character varying(2) NOT NULL,
  anio character varying(4) NOT NULL,
  mes character varying(2) NOT NULL,
  periodo character varying(1) NOT NULL DEFAULT ''::character varying,
  tipo_trabajo character varying(1) NOT NULL DEFAULT ''::character varying,
  contacto character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_cita character varying(1) NOT NULL,
  folio_cita character varying(10) NOT NULL DEFAULT ''::character varying,
  asesor_tmkt character varying(12) NOT NULL DEFAULT ''::character varying,
  tipo_orden character varying(10) NOT NULL,
  folio_orden character varying(10) NOT NULL,
  fecha_ord_ent timestamp without time zone NULL,
  estatus_cita_orden character varying(2) NOT NULL DEFAULT ''::character varying,
  punto integer NOT NULL DEFAULT 0,
  tipo_punto character varying(1) NOT NULL DEFAULT ''::character varying,
  desc_punto character varying(100) NOT NULL DEFAULT ''::character varying,
  clave_paquete character varying(5) NOT NULL DEFAULT ''::character varying,
  paq_comision numeric(18,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;

