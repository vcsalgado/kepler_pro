CREATE  TABLE keplersc.ifz_repo_warranty_payments (
  dealer_id character varying(7) NOT NULL DEFAULT ''::character varying,
  document_id character varying(30) NOT NULL DEFAULT ''::character varying,
  payment_cycle_end_date character varying(15) NOT NULL DEFAULT ''::character varying,
  claim_invoice_number_string character varying(15) NULL DEFAULT ''::character varying,
  process_date character varying(15) NULL DEFAULT ''::character varying,
  to_be_paid_amount numeric(9,2) NULL DEFAULT 0,
  currency_id character varying(5) NULL DEFAULT ''::character varying,
  vin character varying(18) NULL DEFAULT ''::character varying,
  claim_type_string character varying(10) NULL DEFAULT ''::character varying,
  oem_claim_number_string character varying(15) NULL DEFAULT ''::character varying,
  claim_gas_indicator character varying(10) NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_repo_warranty_payments ADD CONSTRAINT pk_ifz_repo_warranty_payments PRIMARY KEY (dealer_id, document_id);
COMMENT ON TABLE keplersc.ifz_repo_warranty_payments IS 'Reportes Warranty Payments DDOA';
COMMENT ON COLUMN keplersc.ifz_repo_warranty_payments.vin IS 'VIN';
COMMENT ON COLUMN keplersc.ifz_repo_warranty_payments.to_be_paid_amount IS 'ToBePaidAmount';
COMMENT ON COLUMN keplersc.ifz_repo_warranty_payments.process_date IS 'ProcessDate';
COMMENT ON COLUMN keplersc.ifz_repo_warranty_payments.payment_cycle_end_date IS 'PaymentCycleEndDate';
COMMENT ON COLUMN keplersc.ifz_repo_warranty_payments.oem_claim_number_string IS 'OEMClaimNumberString';
COMMENT ON COLUMN keplersc.ifz_repo_warranty_payments.document_id IS 'Document ID';
COMMENT ON COLUMN keplersc.ifz_repo_warranty_payments.dealer_id IS 'Dealer ID';
COMMENT ON COLUMN keplersc.ifz_repo_warranty_payments.currency_id IS 'currencyID';
COMMENT ON COLUMN keplersc.ifz_repo_warranty_payments.claim_type_string IS 'ClaimTypeString';
COMMENT ON COLUMN keplersc.ifz_repo_warranty_payments.claim_invoice_number_string IS 'ClaimInvoiceNumberString';
COMMENT ON COLUMN keplersc.ifz_repo_warranty_payments.claim_gas_indicator IS 'ClaimGasIndicator';

