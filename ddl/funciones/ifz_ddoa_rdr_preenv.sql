CREATE OR REPLACE FUNCTION keplersc.ifz_ddoa_rdr_preenv(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion:  Movimientos para la tabla ifz_ddoa_rdr_preenvio
--Autor: Roberto Herrera Flores del Campo
--Fecha: 04/03/2026
--Bitacora de cambios
declare
		sucursal_id text;
		tipo_ope text;
		mes text;
		anio text;

		gen_mov text;
		nat_mov text;
		gpo_mov numeric;
		tipo_mov numeric;	
		folio_mov text; --Se incluye folio de la venta
	
		fecha_proceso timestamp;

		v_method text;
		v_dealer_id text;
		v_invoice_number text;
		v_sales_date text;
		v_sale_category_string text;
		v_sale_subcategory_string text;
		v_sales_person_party_id text;
		v_sales_manager_party_id text;
		v_currency_id text;
		v_cbp_customer_legal_id text;
		v_cbp_given_name text;
		v_cbp_middle_name text;
		v_cbp_family_name text;
		v_cbp_salutation text;
		v_cbp_name_suffix text;
		v_cbp_company_name text;
		v_cbp_person_name text;
		v_cbp_ra_line_one text;
		v_cbp_ra_line_two text;
		v_cbp_ra_city_name text;
		v_cbp_ra_country_id text;
		v_cbp_ra_postcode text;
		v_cbp_ra_state_or_province_country_subdivision_id text;
		v_cbp_phones_channel_code1 text;
		v_cbp_phones_complete_number1 text;
		v_cbp_phones_use_code1 text;
		v_cbp_phones_channel_code2 text;
		v_cbp_phones_complete_number2 text;
		v_cbp_phones_use_code2 text;
		v_cbp_emails_uriid text;
		v_cbp_emails_channel_code text;
		v_cbp_contact_method_type_code text;
		v_cbp_preferred_language_code text;
		v_cbp_preferred_privacy_indicator text;
		v_ccbp_customer_legal_id text;
		v_ccbp_given_name text;
		v_ccbp_middle_name text;
		v_ccbp_family_name text;
		v_ccbp_salutation text;
		v_ccbp_name_suffix text;
		v_ccbp_ra_line_one text;
		v_ccbp_ra_line_two text;
		v_ccbp_ra_city_name text;
		v_ccbp_ra_country_id text;
		v_ccbp_ra_postcode text;
		v_ccbp_ra_state_or_province_country_subdivision_id text;
		v_ccbp_phones_channel_code1 text;
		v_ccbp_phones_complete_number1 text;
		v_ccbp_phones_use_code1 text;
		v_ccbp_phones_channel_code2 text;
		v_ccbp_phones_complete_number2 text;
		v_ccbp_phones_use_code2 text;
		v_ccbp_emails_uriid text;
		v_ccbp_emails_channel_code text;
		v_sf_finance_type_string text;
		v_sf_credit_application_date text;
		v_sf_gross_amount numeric;
		v_sf_purchase_price_amount numeric;
		v_sf_whole_sale_value_amount numeric;
		v_sf_company_name text;
		v_sf_line_one text;
		v_sf_city_name text;
		v_sf_country_id text;
		v_sf_postcode text;
		v_sf_state_or_province_country_subdivision_id text;
		v_vehicle_model text;
		v_vehicle_model_year text;
		v_vehicle_make_string text;
		v_vehicle_sale_class_code text;
		v_vehicle_vehicle_id text;
		v_vehicle_unit_code text;
		v_vehicle_delivery_distance_measure numeric;
		v_vehicle_vehicle_stock_string text;
		v_vehicle_dcp_price_code1 text;
		v_vehicle_dcp_charge_amount1 numeric;
		v_vehicle_dcp_price_code2 text;
		v_vehicle_dcp_charge_amount2 numeric;
		v_vehicle_ss_contract_id text;
		v_vehicle_ss_contract_type_string text;
		v_vehicle_ss_time_unit_code text;
		v_vehicle_ss_term_measure numeric;
		v_vehicle_ss_contract_start_date text;
		v_vehicle_ss_total_contract_amount numeric;
		v_vehicle_ss_distance_unit_code text;
		v_vehicle_ss_contract_start_distance_measure numeric;
		v_vehicle_ss_contract_effective_date text;
		v_vehicle_ss_contract_registration_date text;
		v_vehicle_ss_contract_term_distance_measure numeric;

		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
		xmlResultado text = '';
   
begin 
	
		sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1]; 

		gen_mov := (xpath('//document/c_gen/text()', dataxml))[1];
		nat_mov := (xpath('//document/c_nat/text()', dataxml))[1];
		gpo_mov := (xpath('//document/c_gpo/text()', dataxml))[1];
		tipo_mov := (xpath('//document/c_tip/text()', dataxml))[1];
		folio_mov := (xpath('//document/c_folio/text()', dataxml))[1];

		tipo_ope := (xpath('//document/operacion/text()', dataxml))[1]; 

		SELECT date_part('month', (SELECT current_timestamp)) into mes;
		SELECT date_part('year', (SELECT current_timestamp)) into anio ; 
	
		fecha_proceso := current_timestamp;

		v_method := (xpath('//document/method/text()', dataxml))[1];
		v_dealer_id := (xpath('//document/dealer_id/text()', dataxml))[1];
		v_invoice_number := (xpath('//document/invoice_number/text()', dataxml))[1];
		v_sales_date := (xpath('//document/sales_date/text()', dataxml))[1];
		v_sale_category_string := (xpath('//document/sale_category_string/text()', dataxml))[1];
		v_sale_subcategory_string := (xpath('//document/sale_subcategory_string/text()', dataxml))[1];
		v_sales_person_party_id := (xpath('//document/sales_person_party_id/text()', dataxml))[1];
		v_sales_manager_party_id := (xpath('//document/sales_manager_party_id/text()', dataxml))[1];
		v_currency_id := (xpath('//document/currency_id/text()', dataxml))[1];
		v_cbp_customer_legal_id := (xpath('//document/cbp_customer_legal_id/text()', dataxml))[1];
		v_cbp_given_name := (xpath('//document/cbp_given_name/text()', dataxml))[1];
		v_cbp_middle_name := (xpath('//document/cbp_middle_name/text()', dataxml))[1];
		v_cbp_family_name := (xpath('//document/cbp_family_name/text()', dataxml))[1];
		v_cbp_salutation := (xpath('//document/cbp_salutation/text()', dataxml))[1];
		v_cbp_name_suffix := (xpath('//document/cbp_name_suffix/text()', dataxml))[1];
		v_cbp_company_name := (xpath('//document/cbp_company_name/text()', dataxml))[1];
		v_cbp_person_name := (xpath('//document/cbp_person_name/text()', dataxml))[1];
		v_cbp_ra_line_one := (xpath('//document/cbp_ra_line_one/text()', dataxml))[1];
		v_cbp_ra_line_two := (xpath('//document/cbp_ra_line_two/text()', dataxml))[1];
		v_cbp_ra_city_name := (xpath('//document/cbp_ra_city_name/text()', dataxml))[1];
		v_cbp_ra_country_id := (xpath('//document/cbp_ra_country_id/text()', dataxml))[1];
		v_cbp_ra_postcode := (xpath('//document/cbp_ra_postcode/text()', dataxml))[1];
		v_cbp_ra_state_or_province_country_subdivision_id := (xpath('//document/cbp_ra_state_or_province_country_subdivision_id/text()', dataxml))[1];
		v_cbp_phones_channel_code1 := (xpath('//document/cbp_phones_channel_code1/text()', dataxml))[1];
		v_cbp_phones_complete_number1 := (xpath('//document/cbp_phones_complete_number1/text()', dataxml))[1];
		v_cbp_phones_use_code1 := (xpath('//document/cbp_phones_use_code1/text()', dataxml))[1];
		v_cbp_phones_channel_code2 := (xpath('//document/cbp_phones_channel_code2/text()', dataxml))[1];
		v_cbp_phones_complete_number2 := (xpath('//document/cbp_phones_complete_number2/text()', dataxml))[1];
		v_cbp_phones_use_code2 := (xpath('//document/cbp_phones_use_code2/text()', dataxml))[1];
		v_cbp_emails_uriid := (xpath('//document/cbp_emails_uriid/text()', dataxml))[1];
		v_cbp_emails_channel_code := (xpath('//document/cbp_emails_channel_code/text()', dataxml))[1];
		v_cbp_contact_method_type_code := (xpath('//document/cbp_contact_method_type_code/text()', dataxml))[1];
		v_cbp_preferred_language_code := (xpath('//document/cbp_preferred_language_code/text()', dataxml))[1];
		v_cbp_preferred_privacy_indicator := (xpath('//document/cbp_preferred_privacy_indicator/text()', dataxml))[1];
		v_ccbp_customer_legal_id := (xpath('//document/ccbp_customer_legal_id/text()', dataxml))[1];
		v_ccbp_given_name := (xpath('//document/ccbp_given_name/text()', dataxml))[1];
		v_ccbp_middle_name := (xpath('//document/ccbp_middle_name/text()', dataxml))[1];
		v_ccbp_family_name := (xpath('//document/ccbp_family_name/text()', dataxml))[1];
		v_ccbp_salutation := (xpath('//document/ccbp_salutation/text()', dataxml))[1];
		v_ccbp_name_suffix := (xpath('//document/ccbp_name_suffix/text()', dataxml))[1];
		v_ccbp_ra_line_one := (xpath('//document/ccbp_ra_line_one/text()', dataxml))[1];
		v_ccbp_ra_line_two := (xpath('//document/ccbp_ra_line_two/text()', dataxml))[1];
		v_ccbp_ra_city_name := (xpath('//document/ccbp_ra_city_name/text()', dataxml))[1];
		v_ccbp_ra_country_id := (xpath('//document/ccbp_ra_country_id/text()', dataxml))[1];
		v_ccbp_ra_postcode := (xpath('//document/ccbp_ra_postcode/text()', dataxml))[1];
		v_ccbp_ra_state_or_province_country_subdivision_id := (xpath('//document/ccbp_ra_state_or_province_country_subdivision_id/text()', dataxml))[1];
		v_ccbp_phones_channel_code1 := (xpath('//document/ccbp_phones_channel_code1/text()', dataxml))[1];
		v_ccbp_phones_complete_number1 := (xpath('//document/ccbp_phones_complete_number1/text()', dataxml))[1];
		v_ccbp_phones_use_code1 := (xpath('//document/ccbp_phones_use_code1/text()', dataxml))[1];
		v_ccbp_phones_channel_code2 := (xpath('//document/ccbp_phones_channel_code2/text()', dataxml))[1];
		v_ccbp_phones_complete_number2 := (xpath('//document/ccbp_phones_complete_number2/text()', dataxml))[1];
		v_ccbp_phones_use_code2 := (xpath('//document/ccbp_phones_use_code2/text()', dataxml))[1];
		v_ccbp_emails_uriid := (xpath('//document/ccbp_emails_uriid/text()', dataxml))[1];
		v_ccbp_emails_channel_code := (xpath('//document/ccbp_emails_channel_code/text()', dataxml))[1];
		v_sf_finance_type_string := (xpath('//document/sf_finance_type_string/text()', dataxml))[1];
		v_sf_credit_application_date := (xpath('//document/sf_credit_application_date/text()', dataxml))[1];
		v_sf_gross_amount := (xpath('//document/sf_gross_amount/text()', dataxml))[1];
		v_sf_purchase_price_amount := (xpath('//document/sf_purchase_price_amount/text()', dataxml))[1];
		v_sf_whole_sale_value_amount := (xpath('//document/sf_whole_sale_value_amount/text()', dataxml))[1];
		v_sf_company_name := (xpath('//document/sf_company_name/text()', dataxml))[1];
		v_sf_line_one := (xpath('//document/sf_line_one/text()', dataxml))[1];
		v_sf_city_name := (xpath('//document/sf_city_name/text()', dataxml))[1];
		v_sf_country_id := (xpath('//document/sf_country_id/text()', dataxml))[1];
		v_sf_postcode := (xpath('//document/sf_postcode/text()', dataxml))[1];
		v_sf_state_or_province_country_subdivision_id := (xpath('//document/sf_state_or_province_country_subdivision_id/text()', dataxml))[1];
		v_vehicle_model := (xpath('//document/vehicle_model/text()', dataxml))[1];
		v_vehicle_model_year := (xpath('//document/vehicle_model_year/text()', dataxml))[1];
		v_vehicle_make_string := (xpath('//document/vehicle_make_string/text()', dataxml))[1];
		v_vehicle_sale_class_code := (xpath('//document/vehicle_sale_class_code/text()', dataxml))[1];
		v_vehicle_vehicle_id := (xpath('//document/vehicle_vehicle_id/text()', dataxml))[1];
		v_vehicle_unit_code := (xpath('//document/vehicle_unit_code/text()', dataxml))[1];
		v_vehicle_delivery_distance_measure := (xpath('//document/vehicle_delivery_distance_measure/text()', dataxml))[1];
		v_vehicle_vehicle_stock_string := (xpath('//document/vehicle_vehicle_stock_string/text()', dataxml))[1];
		v_vehicle_dcp_price_code1 := (xpath('//document/vehicle_dcp_price_code1/text()', dataxml))[1];
		v_vehicle_dcp_charge_amount1 := (xpath('//document/vehicle_dcp_charge_amount1/text()', dataxml))[1];
		v_vehicle_dcp_price_code2 := (xpath('//document/vehicle_dcp_price_code2/text()', dataxml))[1];
		v_vehicle_dcp_charge_amount2 := (xpath('//document/vehicle_dcp_charge_amount2/text()', dataxml))[1];
		v_vehicle_ss_contract_id := (xpath('//document/vehicle_ss_contract_id/text()', dataxml))[1];
		v_vehicle_ss_contract_type_string := (xpath('//document/vehicle_ss_contract_type_string/text()', dataxml))[1];
		v_vehicle_ss_time_unit_code := (xpath('//document/vehicle_ss_time_unit_code/text()', dataxml))[1];
		v_vehicle_ss_term_measure := (xpath('//document/vehicle_ss_term_measure/text()', dataxml))[1];
		v_vehicle_ss_contract_start_date := (xpath('//document/vehicle_ss_contract_start_date/text()', dataxml))[1];
		v_vehicle_ss_total_contract_amount := (xpath('//document/vehicle_ss_total_contract_amount/text()', dataxml))[1];
		v_vehicle_ss_distance_unit_code := (xpath('//document/vehicle_ss_distance_unit_code/text()', dataxml))[1];
		v_vehicle_ss_contract_start_distance_measure := (xpath('//document/vehicle_ss_contract_start_distance_measure/text()', dataxml))[1];
		v_vehicle_ss_contract_effective_date := (xpath('//document/vehicle_ss_contract_effective_date/text()', dataxml))[1];
		v_vehicle_ss_contract_registration_date := (xpath('//document/vehicle_ss_contract_registration_date/text()', dataxml))[1];
		v_vehicle_ss_contract_term_distance_measure := (xpath('//document/vehicle_ss_contract_term_distance_measure/text()', dataxml))[1];

		INSERT INTO keplersc.ifz_ddoa_rdr_preenvio (sucursal, genero, naturaleza, grupo, tipo, folio, fecha,
		method, dealer_id, invoice_number, sales_date, sale_category_string, sale_subcategory_string,
		sales_person_party_id, sales_manager_party_id, currency_id, cbp_customer_legal_id, cbp_given_name,
		cbp_middle_name, cbp_family_name, cbp_salutation, cbp_name_suffix, cbp_company_name,
		cbp_person_name, cbp_ra_line_one, cbp_ra_line_two, cbp_ra_city_name, cbp_ra_country_id,
		cbp_ra_postcode, cbp_ra_state_or_province_country_subdivision_id, cbp_phones_channel_code1,
		cbp_phones_complete_number1, cbp_phones_use_code1, cbp_phones_channel_code2, cbp_phones_complete_number2,
		cbp_phones_use_code2, cbp_emails_uriid, cbp_emails_channel_code, cbp_contact_method_type_code,
		cbp_preferred_language_code, cbp_preferred_privacy_indicator, ccbp_customer_legal_id,
		ccbp_given_name, ccbp_middle_name, ccbp_family_name, ccbp_salutation, ccbp_name_suffix,
		ccbp_ra_line_one, ccbp_ra_line_two, ccbp_ra_city_name, ccbp_ra_country_id, ccbp_ra_postcode,
		ccbp_ra_state_or_province_country_subdivision_id, ccbp_phones_channel_code1,
		ccbp_phones_complete_number1, ccbp_phones_use_code1, ccbp_phones_channel_code2,
		ccbp_phones_complete_number2, ccbp_phones_use_code2, ccbp_emails_uriid, ccbp_emails_channel_code,
		sf_finance_type_string, sf_credit_application_date, sf_gross_amount, sf_purchase_price_amount,
		sf_whole_sale_value_amount, sf_company_name, sf_line_one, sf_city_name, sf_country_id, sf_postcode,
		sf_state_or_province_country_subdivision_id, vehicle_model, vehicle_model_year, vehicle_make_string,
		vehicle_sale_class_code, vehicle_vehicle_id, vehicle_unit_code, vehicle_delivery_distance_measure,
		vehicle_vehicle_stock_string, vehicle_dcp_price_code1, vehicle_dcp_charge_amount1,
		vehicle_dcp_price_code2, vehicle_dcp_charge_amount2, vehicle_ss_contract_id,
		vehicle_ss_contract_type_string, vehicle_ss_time_unit_code, vehicle_ss_term_measure,
		vehicle_ss_contract_start_date, vehicle_ss_total_contract_amount, vehicle_ss_distance_unit_code,
		vehicle_ss_contract_start_distance_measure, vehicle_ss_contract_effective_date,
		vehicle_ss_contract_registration_date, vehicle_ss_contract_term_distance_measure) 
		VALUES(sucursal_id, gen_mov, nat_mov, gpo_mov, tipo_mov, folio_mov, fecha_proceso,
		v_method, v_dealer_id, v_invoice_number, v_sales_date, v_sale_category_string, v_sale_subcategory_string,
		v_sales_person_party_id, v_sales_manager_party_id, v_currency_id, v_cbp_customer_legal_id, v_cbp_given_name,
		v_cbp_middle_name, v_cbp_family_name, v_cbp_salutation, v_cbp_name_suffix, v_cbp_company_name,
		v_cbp_person_name, v_cbp_ra_line_one, v_cbp_ra_line_two, v_cbp_ra_city_name, v_cbp_ra_country_id,
		v_cbp_ra_postcode, v_cbp_ra_state_or_province_country_subdivision_id, v_cbp_phones_channel_code1,
		v_cbp_phones_complete_number1, v_cbp_phones_use_code1, v_cbp_phones_channel_code2, v_cbp_phones_complete_number2,
		v_cbp_phones_use_code2, v_cbp_emails_uriid, v_cbp_emails_channel_code, v_cbp_contact_method_type_code,
		v_cbp_preferred_language_code, v_cbp_preferred_privacy_indicator, v_ccbp_customer_legal_id,
		v_ccbp_given_name, v_ccbp_middle_name, v_ccbp_family_name, v_ccbp_salutation, v_ccbp_name_suffix,
		v_ccbp_ra_line_one, v_ccbp_ra_line_two, v_ccbp_ra_city_name, v_ccbp_ra_country_id, v_ccbp_ra_postcode,
		v_ccbp_ra_state_or_province_country_subdivision_id, v_ccbp_phones_channel_code1,
		v_ccbp_phones_complete_number1, v_ccbp_phones_use_code1, v_ccbp_phones_channel_code2,
		v_ccbp_phones_complete_number2, v_ccbp_phones_use_code2, v_ccbp_emails_uriid, v_ccbp_emails_channel_code,
		v_sf_finance_type_string, v_sf_credit_application_date, v_sf_gross_amount, v_sf_purchase_price_amount,
		v_sf_whole_sale_value_amount, coalesce(v_sf_company_name,''), coalesce(v_sf_line_one,''), 
		coalesce(v_sf_city_name,''), coalesce(v_sf_country_id,''), coalesce(v_sf_postcode,''),
		coalesce(v_sf_state_or_province_country_subdivision_id,''), v_vehicle_model, v_vehicle_model_year, v_vehicle_make_string,
		v_vehicle_sale_class_code, v_vehicle_vehicle_id, v_vehicle_unit_code, v_vehicle_delivery_distance_measure,
		v_vehicle_vehicle_stock_string, v_vehicle_dcp_price_code1, v_vehicle_dcp_charge_amount1,
		v_vehicle_dcp_price_code2, v_vehicle_dcp_charge_amount2, v_vehicle_ss_contract_id,
		v_vehicle_ss_contract_type_string, v_vehicle_ss_time_unit_code, v_vehicle_ss_term_measure,
		v_vehicle_ss_contract_start_date, v_vehicle_ss_total_contract_amount, v_vehicle_ss_distance_unit_code,
		v_vehicle_ss_contract_start_distance_measure, v_vehicle_ss_contract_effective_date,
		v_vehicle_ss_contract_registration_date, v_vehicle_ss_contract_term_distance_measure);	

		resultado := 1;
		mensaje := folio_operacion;
		adicionales := xmlResultado;
		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := 0;
			mensaje := 'ifz_ddoa_rdr_preenv() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
 	
end;
$function$
