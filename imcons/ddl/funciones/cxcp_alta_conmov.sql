CREATE OR REPLACE FUNCTION keplersc.cxcp_alta_conmov(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: cxcp_alta_conmov
--Autor: Luis Leal
--Fecha: 19/10/2022
--Bitacora de cambios
--29/02/2024 (JMM) :
---- Se Incluyen Campos Prov_Pago al final 
---- para las Operaciones de los Documentos que aplique, dentro del Nvo Esquema de CxP 
--Fecha: 12/03/2024
---- Adapted Transfer Operations
--29/10/2024 Miriam Santana: Se incluye validaciones para anulacion de cobro
--30/009/2025 Victor Salgado:  Se incluyen impuestos adicionales

declare
	--Variables de definicion de documento
	sucursal_desc text;
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_compuesto text;
	tipo_clave text;
	referencia text;
	documento int;
	clave_cteprov text;
	monto_iva decimal;
	monto_total decimal;
	fecha_operacion text;
	plazo_vencimiento text;

	monto_ivaret decimal = 0;
	monto_isrret decimal = 0;
	monto_iepstras decimal = 0;
	monto_otroimptoa decimal = 0;
	monto_otroimptob decimal = 0;
	monto_subtotal decimal = 0;

	vencimiento_fact text;

	intereses_moratorios decimal;
	tabla text;
	cobranza decimal;
	numero_partida numeric;
	anticipos numeric = 0;
	conf_iva numeric;
	xml_kduxg_alta xml ;

	--Added 20240229 by JMM , Proveedor de Pago
	clave_provpago text = '';
	--Added 20240305 by JMM , Esquema CxP 
	clave_provoper text = '';
	rec record;
	flag_gastos text = '';

	--MSS 29/10/2024 Anulacion de cobros
	tipo_cxcp text ='';			
	flag_cobros text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	strValor text;
	intValor int;
	totalReg int;

	--Variables de retorno desde funciones externas
	get_resultado text; --retorno
	get_mensaje text; --retorno
	get_adicionales text; --retorno

begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	--Tipo de documento
	tipo_desc := (xpath('//document/k_tipon/r0/text()', dataxml))[1]; 
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	clave_cteprov := (xpath('//document/k_clave/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	plazo_vencimiento := coalesce((xpath('//document/k_vence/text()', dataxml))[1]::text,'1990-01-01')::text;
	tabla := coalesce((xpath('//document/k_tabla_mov/text()', dataxml))[1]::text,'kdm2')::text;

	intereses_moratorios := coalesce((xpath('//document/intereses_moratorios/text()', dataxml))[1]::text,'0.00')::decimal;
	cobranza := coalesce((xpath('//document/cobranza/text()', dataxml))[1]::text,'0.00')::decimal;

	--VCSS 30/09/2025 Complemento de impuestos

	monto_isrret := coalesce((xpath('//document/uuid/retisr/text()',dataxml))[1]::text,'0')::decimal;
	monto_ivaret := coalesce((xpath('//document/uuid/retiva/text()',dataxml))[1]::text,'0')::decimal;
	monto_iepstras := coalesce((xpath('//document/uuid/iepstras/text()',dataxml))[1]::text,'0')::decimal;
	monto_subtotal := coalesce((xpath('//document/uuid/subtotal/text()',dataxml))[1]::text,'0')::decimal;
	monto_otroimptoa := coalesce((xpath('//document/uuid/otroimptoa/text()',dataxml))[1]::text,'0')::decimal;
	monto_otroimptob := coalesce((xpath('//document/uuid/otroimptob/text()',dataxml))[1]::text,'0')::decimal;

	--  * * * * *  Added 20240229 by JMM, Proveedor de Pago  
	clave_provpago := '';

	if xpath_exists('//document/k_clave_pago/text()', dataxml) = true /*false*/ then 
		clave_provpago := coalesce((xpath('//document/k_clave_pago/text()',dataxml))[1]::text,'')::text;
	end if;

	-- Si no existe dato del Proveedor de Pago, se igualara al Proveedor de la Operacion 
	if length(clave_provpago) = 0 then 
		if upper(genero) = 'X' then
			clave_provpago := clave_cteprov; 
		end if;
	end if;
	--  * * * * *  End : Proveedor de Pago
	
	--MSS 29102024 Anulacion de cobros
	tipo_cxcp :='Alta';
	flag_cobros :=coalesce((xpath('//document/ambiente/flag_cobros/text()',dataxml))[1]::text,'')::text;
	
	for referencia,documento,numero_partida,monto_total,monto_iva, vencimiento_fact 
		in execute format('select c14,c11,c7,c12,c13,c15 
		from keplersc.%1$s where c1=%2$L and c2=%3$L and c3=%4$L and c4=%5$s and c5=%6$s and c6=%7$L' 
		,tabla,sucursal_id,genero,naturaleza,grupo::integer ,tipo_clave::integer ,folio_operacion)
	loop 
					
		-- To Check 20240305 ... 
		/*raise exception '%',tabla;*/
		
		--Added by JMM 20240305
		flag_gastos = '';
		if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
			flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
		end if;
		if upper(flag_gastos) = 'CXP_PAGO' or upper(flag_gastos) = 'CXP_TRANSFER'/*Added by JMM 20240312*/ then
			if upper(tabla) in ('KDM5') then
				select * into rec from keplersc.kdm5 
				where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::integer and c5 = tipo_clave::integer and c6 = folio_operacion 
					and c7 = numero_partida and c14 = referencia;
				if not found then 
					mensaje := 'No se encontro registro en KDM5 de la CxP de Origen ... ' || referencia;
					raise exception '%',mensaje;
				else
					mensaje := '';
					clave_cteprov := rec.cve_prov_oper;
				
					--Added by JMM 20240312 ...
					if length(trim(clave_cteprov)) = 0 then
						raise exception '%', 'No se pudo determinar el Proveedor de Operacion ... Partida ' || numero_partida::text;
					end if;
				
					--Added by JMM 20240312 ... Reasignando el Proveedor de Pago
					if upper(flag_gastos) = 'CXP_TRANSFER' then 
						clave_provpago := '';
						clave_provpago := rec.cve_prov_pago;
						if length(trim(clave_provpago)) = 0 then
							raise exception '%', 'No se pudo determinar el Proveedor de Pago ... Partida ' || numero_partida::text;
						end if;
					end if;
				
					-- For Testing, It Continuing ...
					/*raise exception '%''%''%''%','Cliente_Reasignado',numero_partida,clave_cteprov,referencia;*/
				end if;
							
			else
				raise exception 'Esquema Invalido de CXP_PAGO ... Tabla debe ser kdm5';
			end if;
		end if;
		
		select count(*) into totalReg from keplersc.kduxe	
		where c1=sucursal_id and c2=clave_cteprov and c3= referencia::text
			and c4=1 and c5=genero and c6=naturaleza and c7=grupo::integer 
			and c8=tipo_clave::integer and c9=folio_operacion and c10=numero_partida;	
		
		if substring(vencimiento_fact,1,10) = '1990-01-01' or vencimiento_fact = '0' then       --MSS 22122024: PUSE EL SUBSTRING NO ENTRABA AL IF
			vencimiento_fact := plazo_vencimiento;
		end if;
			
		if totalReg = 0 then	
					
			insert into keplersc.kduxe (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16 ,cve_prov_pago
				,ivaret,isrret,iepstras,otroimptoa,otroimptob,subtotal)
			values(sucursal_id,clave_cteprov,referencia,documento,genero,naturaleza,
			grupo::integer,tipo_clave::integer,folio_operacion,numero_partida,to_date(fecha_operacion,'YYYY-MM-DD'),
			to_date(vencimiento_fact,'YYYY-MM-DD'),monto_total,monto_iva,intereses_moratorios,cobranza ,clave_provpago
			,monto_ivaret,monto_isrret,monto_iepstras,monto_otroimptoa,monto_otroimptob,monto_subtotal );
			
		end if;

		xml_kduxg_alta := format('	
		<document>
			<k_sucn><r1>%1$s</r1></k_sucn>
			<k_tipon><r1>%2$s</r1><r2>%3$s</r2></k_tipon>
			<k_clave>%4$s</k_clave>
			<k_refer>%5$s</k_refer>
			<k_fecha>%6$s</k_fecha>
			<k_vence>%7$s</k_vence>
			<k_iva>%8$s</k_iva>
			<k_monto>%9$s</k_monto>
			<k_documento>%10$s</k_documento>
			<k_clave_pago>%11$s</k_clave_pago>
			<k_flag_cobros>%12$s</k_flag_cobros>
		</document>
		', sucursal_id,genero,naturaleza,clave_cteprov,referencia,
		fecha_operacion,vencimiento_fact,monto_iva,monto_total,documento,clave_provpago/*Added 240229*/,flag_cobros);--MSS 12122024 Anulacion de cobro
		
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_conmov_kduxg(xml_kduxg_alta, tipo_cxcp);--MSS 29102024 CONDICIONAR 2NDO PARAMETRO
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;	
					
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cxcp_alta_conmov() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
