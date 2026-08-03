CREATE  TABLE keplersc.ifz_repo_seguimiento (
  metodo character varying(50) NOT NULL DEFAULT ''::character varying,
  dealer_id character varying(7) NOT NULL DEFAULT ''::character varying,
  document_id character varying(20) NOT NULL DEFAULT ''::character varying,
  result character varying(55) NOT NULL DEFAULT ''::character varying,
  message character varying NULL DEFAULT ''::character varying,
  fecha_hora timestamp without time zone NULL DEFAULT now()
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_repo_seguimiento ADD CONSTRAINT pk_ifz_repo_seguimiento PRIMARY KEY (metodo, dealer_id, document_id);
COMMENT ON TABLE keplersc.ifz_repo_seguimiento IS 'Reportes para metodos de seguimiento DDOA';
COMMENT ON COLUMN keplersc.ifz_repo_seguimiento.result IS 'Result';
COMMENT ON COLUMN keplersc.ifz_repo_seguimiento.metodo IS 'Metodo';
COMMENT ON COLUMN keplersc.ifz_repo_seguimiento.message IS 'Message';
COMMENT ON COLUMN keplersc.ifz_repo_seguimiento.document_id IS 'Document ID';
COMMENT ON COLUMN keplersc.ifz_repo_seguimiento.dealer_id IS 'Dealer ID';

