CREATE  TABLE keplersc.ifz_ddoa_rdr_preenvio (
  sucursal character varying(2) NOT NULL DEFAULT ''::character varying,
  genero character varying(1) NOT NULL DEFAULT ''::character varying,
  naturaleza character varying(1) NOT NULL DEFAULT ''::character varying,
  grupo numeric NOT NULL DEFAULT 0,
  tipo numeric NOT NULL DEFAULT 0,
  folio character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT now(),
  method character varying(50) NOT NULL DEFAULT 'RetailDeliveryReporting'::character varying,
  dealer_id character varying(10) NULL,
  invoice_number character varying(30) NULL,
  sales_date character varying(10) NULL,
  sale_category_string character varying(1) NULL,
  sale_subcategory_string character varying(2) NULL,
  sales_person_party_id character varying(10) NULL,
  sales_manager_party_id character varying(10) NULL,
  currency_id character varying(5) NULL,
  cbp_customer_legal_id character varying(13) NULL,
  cbp_given_name character varying(35) NULL,
  cbp_middle_name character varying(1) NULL,
  cbp_family_name character varying(35) NULL,
  cbp_salutation character varying(5) NULL,
  cbp_name_suffix character varying(10) NULL,
  cbp_company_name character varying(35) NULL,
  cbp_person_name character varying(70) NULL,
  cbp_ra_line_one character varying(45) NULL,
  cbp_ra_line_two character varying(45) NULL,
  cbp_ra_city_name character varying(28) NULL,
  cbp_ra_country_id character varying(10) NULL,
  cbp_ra_postcode character varying(5) NULL,
  cbp_ra_state_or_province_country_subdivision_id character varying(3) NULL,
  cbp_phones_channel_code1 character varying(10) NULL,
  cbp_phones_complete_number1 character varying(20) NULL,
  cbp_phones_use_code1 character varying(10) NULL,
  cbp_phones_channel_code2 character varying(10) NULL,
  cbp_phones_complete_number2 character varying(20) NULL,
  cbp_phones_use_code2 character varying(10) NULL,
  cbp_emails_uriid character varying(70) NULL,
  cbp_emails_channel_code character varying(5) NULL,
  cbp_contact_method_type_code character varying(15) NULL,
  cbp_preferred_language_code character varying(10) NULL,
  cbp_preferred_privacy_indicator character varying(5) NULL,
  ccbp_customer_legal_id character varying(13) NULL,
  ccbp_given_name character varying(35) NULL,
  ccbp_middle_name character varying(1) NULL,
  ccbp_family_name character varying(35) NULL,
  ccbp_salutation character varying(5) NULL,
  ccbp_name_suffix character varying(10) NULL,
  ccbp_ra_line_one character varying(45) NULL,
  ccbp_ra_line_two character varying(45) NULL,
  ccbp_ra_city_name character varying(28) NULL,
  ccbp_ra_country_id character varying(10) NULL,
  ccbp_ra_postcode character varying(5) NULL,
  ccbp_ra_state_or_province_country_subdivision_id character varying(3) NULL,
  ccbp_phones_channel_code1 character varying(10) NULL,
  ccbp_phones_complete_number1 character varying(20) NULL,
  ccbp_phones_use_code1 character varying(10) NULL,
  ccbp_phones_channel_code2 character varying(10) NULL,
  ccbp_phones_complete_number2 character varying(20) NULL,
  ccbp_phones_use_code2 character varying(10) NULL,
  ccbp_emails_uriid character varying(70) NULL,
  ccbp_emails_channel_code character varying(5) NULL,
  sf_finance_type_string character varying(10) NULL,
  sf_credit_application_date character varying(10) NULL,
  sf_gross_amount numeric(18,2) NULL,
  sf_purchase_price_amount numeric(18,2) NULL,
  sf_whole_sale_value_amount numeric(18,2) NULL,
  sf_company_name character varying(35) NOT NULL DEFAULT ''::character varying,
  sf_line_one character varying(45) NOT NULL DEFAULT ''::character varying,
  sf_city_name character varying(28) NOT NULL DEFAULT ''::character varying,
  sf_country_id character varying(10) NOT NULL DEFAULT ''::character varying,
  sf_postcode character varying(5) NOT NULL DEFAULT ''::character varying,
  sf_state_or_province_country_subdivision_id character varying(3) NOT NULL DEFAULT ''::character varying,
  vehicle_model character varying(500) NULL,
  vehicle_model_year character varying(4) NULL,
  vehicle_make_string character varying(100) NULL,
  vehicle_sale_class_code character varying(4) NULL,
  vehicle_vehicle_id character varying(17) NULL,
  vehicle_unit_code character varying(10) NULL,
  vehicle_delivery_distance_measure numeric(18,2) NULL,
  vehicle_vehicle_stock_string character varying(20) NULL,
  vehicle_dcp_price_code1 character varying(30) NULL,
  vehicle_dcp_charge_amount1 numeric(18,2) NULL,
  vehicle_dcp_price_code2 character varying(30) NULL,
  vehicle_dcp_charge_amount2 numeric(18,2) NULL,
  vehicle_ss_contract_id character varying(30) NULL,
  vehicle_ss_contract_type_string character varying(20) NULL,
  vehicle_ss_time_unit_code character varying(10) NULL,
  vehicle_ss_term_measure numeric(18,2) NULL,
  vehicle_ss_contract_start_date character varying(10) NULL,
  vehicle_ss_total_contract_amount numeric(18,2) NULL,
  vehicle_ss_distance_unit_code character varying(10) NULL,
  vehicle_ss_contract_start_distance_measure numeric(18,2) NULL,
  vehicle_ss_contract_effective_date character varying(10) NULL,
  vehicle_ss_contract_registration_date character varying(10) NULL,
  vehicle_ss_contract_term_distance_measure numeric(18,2) NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.ifz_ddoa_rdr_preenvio IS 'Datos para el envío al Retail Delivery Reporting';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_vehicle_stock_string IS 'Número de inventario del vehículo que se reporta';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_vehicle_id IS 'VIN o número de serie del vehículo que se reporta';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_unit_code IS 'Unidad de medida del odómetro que marca la distancia recorrida por el vehículo que se reporta al momento de su venta';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_ss_total_contract_amount IS 'Valor total del contrato';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_ss_time_unit_code IS 'Unidad de tiempo en la que se mide el contrato:month';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_ss_term_measure IS 'Tiempo de vigencia del contrato';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_ss_distance_unit_code IS 'Unidad de medida sobre la distancia recorrida en el odómetro del vehículo:kilometer,mile';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_ss_contract_type_string IS 'Tipo de contrato para el servicio del vehículo que se reporta:Autocare,VSA';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_ss_contract_term_distance_measure IS 'Distancia final del vehículo cuando termina el contrato de servicio';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_ss_contract_start_distance_measure IS 'Distancia inicial del vehículo cuando inicia el contrato de servicio';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_ss_contract_start_date IS 'Fecha de inicio del contrato, formato AAAA-MM-DD';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_ss_contract_registration_date IS 'Fecha de registro del contrato, formato AAAA-MM-DD';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_ss_contract_id IS 'Número de contrato para el servicio del vehículo que se reporta';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_ss_contract_effective_date IS 'Fecha efectiva del contrato de servicio, formato AAAA-MM-DD';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_sale_class_code IS 'Tipo del vehículo que se reporta:New-vehículo nuevo,Used-vehículo seminuevo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_model_year IS 'Año modelo del vehículo que se reporta';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_model IS 'Código del catalogo correspondiente al modelo del vehículo que se reporta';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_make_string IS 'Nombre de la marca del vehículo que se reporta';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_delivery_distance_measure IS 'Medición del odómetro del vehículo que se reporta al momento de su venta';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_dcp_price_code2 IS 'Segundo Identificador del tipo de costo que se reporta:Total Vehicle Cost - costo total del vehículo,Reconditioning Cost - costo de acondicionamiento';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_dcp_price_code1 IS 'Primer Identificador del tipo de costo que se reporta:Total Vehicle Cost - costo total del vehículo,Reconditioning Cost - costo de acondicionamiento';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_dcp_charge_amount2 IS 'Segundo Importe del costo que se reporta';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.vehicle_dcp_charge_amount1 IS 'Primer Importe del costo que se reporta';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.tipo IS 'Tipo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sf_whole_sale_value_amount IS 'Importe del valor total de la venta del vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sf_state_or_province_country_subdivision_id IS 'Id estado de la republica donde se encuentra el domicilio de la empresa que financia la venta del vehículo:AGS,BCN,BCS,CMP,CAH,COL,CHP,CHI,DF,DGO,GTO,GRO,HGO,JAL,EDM,MCH,MOR,NYT,NL,OAX,PUE,QRO,QNR,SLP,SIN,SON,TAB,TPS,TLX,VER,YUC,ZCS,Si no aplica enviar cadena vacía';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sf_purchase_price_amount IS 'Importe del precio de la venta del  sin impuestos';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sf_postcode IS 'Código postal del domicilio de la empresa que financia la venta del vehículo, si no aplica enviar cadena vacía';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sf_line_one IS 'Calle, número exterior y número interior del domicilio de la empresa que financia la venta del vehículo, si no aplica enviar cadena vacía';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sf_gross_amount IS 'Importe bruto de la venta del vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sf_finance_type_string IS 'Id tipo de financiamiento con el que se realiza la venta del vehículo:ED-Contrato electrónico TFS,PD-Contrato de papel TFS,CD-Acuerdo en efectivo, sin acuerdo TFS';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sf_credit_application_date IS 'Fecha de aplicación del crédito en formato AAAA-MM-DD';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sf_country_id IS 'Código ISO del país donde se encuentra el domicilio de la empresa que financia la venta del vehículo, si no aplica enviar cadena vacía';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sf_company_name IS 'Nombre de la empresa que financia la venta del vehículo, si no aplica enviar cadena vacía';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sf_city_name IS 'Nombre de la ciudad del domicilio de la empresa que financia la venta del vehículo, si no aplica enviar cadena vacía';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sales_person_party_id IS 'Identificador del asesor de venta de autos que realizó la venta del vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sales_manager_party_id IS 'Identificador del jefe o manager de venta de autos que supervisó la venta del vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sales_date IS 'Fecha de la venta del vehículo que se reporta, formato AAAA-MM-DD';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sale_subcategory_string IS 'Indicador del tipo de venta:01-Venta a persona física,02-Venta a minorista TMS SPP,03-Venta a persona moral,04-Arrendamiento a persona moral,05-Arrendamiento a persona física,06-Alquiler,07-Venta para reventa';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.sale_category_string IS 'Indicador del status de la venta:B-venta realizada,C-venta cancelada,P-venta pendiente';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.naturaleza IS 'Naturaleza';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.method IS 'Identificador del método que se reporta: RetailDeliveryReporting';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.invoice_number IS 'Número de factura de la venta del vehículo que se reporta';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.grupo IS 'Grupo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.genero IS 'Genero';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.folio IS 'Folio del movimiento';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.fecha IS 'Fecha del movimiento';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.dealer_id IS 'Identificador asignado por Toyota para el distribuidor';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.currency_id IS 'Identificador del tipo de moneda de la orden de servicio:Para México-MXP,Para USA-USD';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_salutation IS 'Saludo que aplica al aval que respalda al cliente al que se vende el vehículo:Mr,Mrs,Miss,Dr';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_ra_state_or_province_country_subdivision_id IS 'Id estado de la republica del domicilio aval que respalda al cliente al que se vende el vehículo:AGS,BCN,BCS,CMP,CAH,COL,CHP,CHI,DF,DGO,GTO,GRO,HGO,JAL,EDM,MCH,MOR,NYT,NL,OAX,PUE,QRO,QNR,SLP,SIN,SON,TAB,TPS,TLX,VER,YUC,ZCS';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_ra_postcode IS 'Código postal del domicilio del aval que respalda al cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_ra_line_two IS 'Entre calles, colonia y municipio del domicilio del aval que respalda al cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_ra_line_one IS 'Calle, número exterior y número interior del domicilio del aval que respalda al cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_ra_country_id IS 'Código ISO del país donde se encuentra el domicilio del aval que respalda al cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_ra_city_name IS 'Nombre de la ciudad del domicilio del aval que respalda al cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_phones_use_code2 IS 'Segundo Código del uso del teléfono del del aval que respalda al cliente al que se vende el vehículo:Home,Work';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_phones_use_code1 IS 'Primer Código del uso del teléfono del del aval que respalda al cliente al que se vende el vehículo:Home,Work';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_phones_complete_number2 IS 'Segundo Número completo del teléfono del aval que respalda al cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_phones_complete_number1 IS 'Primer Número completo del teléfono del aval que respalda al cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_phones_channel_code2 IS 'Segundo Código de comunicación del teléfonodel aval que respalda al cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_phones_channel_code1 IS 'Primer Código de comunicación del teléfonodel aval que respalda al cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_name_suffix IS 'Información adicional del aval que respalda al cliente al que se vende el vehículo, tal como Jr o III';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_middle_name IS 'Inicial del primer apellido del aval que respalda al cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_given_name IS 'Nombre propio del aval que respalda al cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_family_name IS 'Apellido(s) del aval que respalda al cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_emails_uriid IS 'Correo electrónico del aval que respalda al cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_emails_channel_code IS 'Id canal para correo electrónico del aval que respalda al cliente al que se vende el vehículo:email';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.ccbp_customer_legal_id IS 'RFC del aval que respalda al cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_salutation IS 'Saludo que aplica al cliente al que se vende el vehículo, aplica para clientes físicos:Mr,Mrs,Miss,Dr';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_ra_state_or_province_country_subdivision_id IS 'Id estado de la republica del domicilio cliente al que se vende el vehículo:AGS,BCN,BCS,CMP,CAH,COL,CHP,CHI,DF,DGO,GTO,GRO,HGO,JAL,EDM,MCH,MOR,NYT,NL,OAX,PUE,QRO,QNR,SLP,SIN,SON,TAB,TPS,TLX,VER,YUC,ZCS';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_ra_postcode IS 'Código postal del domicilio del cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_ra_line_two IS 'Entre calles, colonia y municipio del domicilio del cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_ra_line_one IS 'Calle, número exterior y número interior del domicilio del cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_ra_country_id IS 'Código ISO del país donde se encuentra el domicilio del cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_ra_city_name IS 'Nombre de la ciudad del domicilio del cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_preferred_privacy_indicator IS 'Bandera para indicar si el cliente acepta que se le contacte, valores válidos:true,false';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_preferred_language_code IS 'Código del lenguaje del cliente al que se vende el vehículo habla';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_phones_use_code2 IS 'Segundo Código del uso del teléfono del cliente al que se vende el vehículo:Home,Work';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_phones_use_code1 IS 'Primer Código del uso del teléfono del cliente al que se vende el vehículo:Home,Work';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_phones_complete_number2 IS 'Segundo Número completo del teléfono del cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_phones_complete_number1 IS 'Primer Número completo del teléfono del cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_phones_channel_code2 IS 'Segundo Código de comunicación del teléfono del cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_phones_channel_code1 IS 'Primer Código de comunicación del teléfono del cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_person_name IS 'Nombre del contacto primario para la empresa a la que se vende el vehículo, aplica para clientes morales';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_name_suffix IS 'Información adicional del cliente al que se vende el vehículo, aplica para clientes físicos, tal como Jr o III';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_middle_name IS 'Inicial del primer apellido del cliente al que se vende el vehículo, aplica para clientes físicos';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_given_name IS 'Nombre propio del cliente al que se vende el vehículo, aplica para clientes físicos';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_family_name IS 'Apellido(s) del cliente al que se vende el vehículo, aplica para clientes físicos';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_emails_uriid IS 'Correo electrónico del cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_emails_channel_code IS 'Id del canal para correo electrónico del cliente al que se vende el vehículo:email';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_customer_legal_id IS 'RFC del cliente al que se vende el vehículo';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_contact_method_type_code IS 'Metodo de contacto que el cliente al que se vende el vehículo acepta:Day Phone,Evening Phone,Cell Phone,Work Fax,Home Fax,Pager,Work Email,Home Email,US Mail,Other,N/A';
COMMENT ON COLUMN keplersc.ifz_ddoa_rdr_preenvio.cbp_company_name IS 'Nombre de la empresa a la que se vende el vehículo, aplica para clientes morales';
CREATE TRIGGER ifzddoa_rdr_preenvio AFTER INSERT ON keplersc.ifz_ddoa_rdr_preenvio FOR EACH ROW EXECUTE FUNCTION keplersc.notif_registrar_movto();

