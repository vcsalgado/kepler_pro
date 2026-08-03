CREATE  TABLE keplersc.cat_estados_match (
  estado_canonico character varying(50) NOT NULL,
  patron_regex character varying(1000) NOT NULL,
  prioridad integer NOT NULL
) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_estado_trgm ON keplersc.cat_estados_match USING gin (estado_canonico keplersc.gin_trgm_ops) TABLESPACE pg_default;

