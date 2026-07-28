CREATE OR REPLACE FUNCTION keplersc.cxcp_sinmov_kduxg_alta(dataxml xml, xmlkduxe xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Bitacora de cambios
--29/02/2024 (JMM) :
---- Se Incluyen Campos Prov_Pago al final 
---- para las Operaciones de los Documentos que aplique, dentro del Nvo Esquema de CxP 
--23/04/2024 (JMM) :
---- Se Incluyen Valores para la Operacion del Contrarecibo Tipo DEV CLIENTES 

declare
	--Variables de definicion de documento
	sucursal_desc text;
	sucursal_id text;
	tipo_desc text;
	genero text;
	grupo text;
	naturaleza text;
	tipo_compuesto text;
	tipo_clave text;
	no_partidas int;
	referencia text;
	clave_cteprov text;
	fecha_operacion text; --yyyy-mm-dd
	plazo_vencimiento text;	
	monto_iva text;
	monto_total text;
	retencion_iva text;


	--variables kduxg
	factura_xg text;
	docpar_xg int;
	cargos_xg decimal;
	abonos_xg decimal;
	iva_cargos_xg decimal;
	iva_abonos_xg decimal;
	saldado_xg int;
	fecha_exp_xg text;
	fecha_venc_xg text;

	-- Added by JMM 221120 
	factura_xe text = '';
	fecha_exp_xe date;
	fecha_venc_xe date;
	fecha_exp date;
	fecha_venc date;
	var_cargos decimal;
	var_abonos decimal;

	--Added 20240229 by JMM , Proveedor de Pago
	clave_provpago text = '';

	--Added 20240328 by JMM, Contra-Recibo to_regtype (x Comprobar)
	flag_gastos text = '';
	cr_type text = ''; 
	cr_st text = '';
	ref_compl text = ''; 

	--Added 20240423 by JMM, Contra-Recibo to_regtype (DEV Clientes)
	aux_gen text = ''; 
	aux_nat text = '';
	aux_gpo text = '0'; 
	aux_tip text = '0';
	aux_folio text = '';

	partida	text;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	strValor text;
	intValor int;
	totalReg int;

begin
	--Valores de XML
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//row/c5/text()', xmlKDUXE))[1];
	naturaleza := (xpath('//row/c6/text()', xmlKDUXE))[1];
	clave_cteprov := (xpath('//row/c2/text()', xmlKDUXE))[1];
	referencia := (xpath('//row/c3/text()',xmlKDUXE))[1];
	fecha_exp_xe := (xpath('//row/c11/text()',xmlKDUXE))[1];
	fecha_venc_xe := (xpath('//row/c12/text()',xmlKDUXE))[1];
	monto_iva := (xpath('//row/c14/text()',xmlKDUXE))[1];		
	monto_total := (xpath('//row/c13/text()',xmlKDUXE))[1];
--	raise notice 'cte:% refer:% fec_exp_xe:% fec_venc_xe:% iva:% monto_total:%',clave_cteprov,referencia,fecha_exp_xe,fecha_venc_xe,monto_iva,monto_total;


	--  * * * * *  Added 20240229 by JMM, Proveedor de Pago  
	clave_provpago := '';

	if xpath_exists('//row/cve_prov_pago/text()', xmlKDUXE) = true /*false*/ then 
		clave_provpago := coalesce((xpath('//row/cve_prov_pago/text()',xmlKDUXE))[1]::text,'')::text;
	end if;

	-- Si no existe dato del Proveedor de Pago, se igualara al Proveedor de la Operacion 
	if length(clave_provpago) = 0 then 
		clave_provpago := clave_cteprov; 
	end if;
	--  * * * * *  End : Proveedor de Pago

	--  * * * * *  Added 20240328 by JMM, Tipo Contra-Recibo x Comprobar	
	flag_gastos = '';
	if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
		flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
	end if;

	cr_type = '';
	cr_st = '';
	ref_compl = ''; /*Este campo de inicio siempre ira en blanco en la opcion x comprobar*/
	
	if upper(flag_gastos) = 'CXP_CONTR_REC' then
		cr_type := coalesce((xpath('//document/chk_pc/text()', dataxml))[1]::text,'')::text;
		if length(cr_type) > 0 and cr_type::integer = 1 then
			cr_st = 'S';
		-- For testing ...
		/*
			raise exception '%', 'Es un Gasto por Comprobar ...';
		else
			raise exception '%', 'No es un Gasto por Comprobar ...';
		*/
		end if;
	end if;
	--  * * * * *  End : Tipo Contra-Recibo x Comprobar 

	--  * * * * *  Added 20240423 by JMM, Tipo Contra-Recibo DEV CLIENTES
	if upper(flag_gastos) = 'CXP_CONTR_REC_DEVCLI' then
	
		/*cr_st = 'D';*/
	
		if xpath_exists('//document/c_gen/text()', dataxml) = true then 
			aux_gen := coalesce((xpath('//document/c_gen/text()',dataxml))[1]::text,'')::text;
		end if;
		if xpath_exists('//document/c_nat/text()', dataxml) = true then 
			aux_nat := coalesce((xpath('//document/c_nat/text()',dataxml))[1]::text,'')::text;
		end if;
		if xpath_exists('//document/c_gpo/text()', dataxml) = true then 
			aux_gpo := coalesce((xpath('//document/c_gpo/text()',dataxml))[1]::text,'')::text;
		end if;
		if xpath_exists('//document/c_tip/text()', dataxml) = true then 
			aux_tip := coalesce((xpath('//document/c_tip/text()',dataxml))[1]::text,'')::text;
		end if;
		if xpath_exists('//document/c_folio/text()', dataxml) = true then 
			aux_folio := coalesce((xpath('//document/c_folio/text()',dataxml))[1]::text,'')::text;
		end if;
		if xpath_exists('//document/c_ref/text()', dataxml) = true then 
			ref_compl := coalesce((xpath('//document/c_ref/text()',dataxml))[1]::text,'')::text;
		end if;
	
		if length(aux_gen) = 0 or length(aux_nat) = 0 or length(aux_gpo) = 0 or length(aux_tip) = 0 
			or length(aux_folio) = 0 or length(ref_compl) = 0 
		then 
			raise exception '%', 'Los Datos de Devolucion estan Incompletos ...';
		else
			-- Armar ref compl para CxP de la DEVOLUCION ... ( Documento Referenciado )
			ref_compl := 'CTE.[' || ref_compl || ']';
			ref_compl := ref_compl || ' DOC.[' || upper(aux_gen) || upper(aux_nat);
			ref_compl := ref_compl || lpad(aux_gpo,2,'0') || lpad(aux_tip,3,'0');
			ref_compl := ref_compl || '-' || upper(aux_folio) || ']';
			ref_compl := left(ref_compl,40);
			--for testing 
			/*raise exception '%', ref_compl || ' , LEN ' || length(ref_compl)::text;*/
		end if;
	
	end if;
	--  * * * * *  End : Added 20240423 by JMM, Tipo Contra-Recibo DEV CLIENTES


	select count(*) into totalReg from keplersc.kduxg 	
		where c1 = sucursal_id and c2= genero and c3 = clave_cteprov 
			and c4 = referencia and c5 = 1;		
	if totalReg = 0 then	
	
		-- Codigo Original se incluyo dentro de este IF (UPD By JMM 20221120)
		docpar_xg := 1;
		cargos_xg := 0;
		abonos_xg := 0;
		iva_cargos_xg := 0;
		iva_abonos_xg := 0;
		saldado_xg := 0; --TO DO: Validar que para esta transaccion el saldo es 0 (es el inicial) 
	
		--TODO, ver si aplica
		/* Opcion 1
		  if genero ='X' and naturaleza= 'A' and grupo = '12' then
			retencion_iva := (xpath('//document/k_retencion_iva/text()',dataxml))[1];
			monto_iva := monto_iva::decimal - retencion_iva::decimal;
			monto_total := monto_total::decimal - monto_iva::decimal;			
		end if;
	
		   Opcion 2
		if genero ='X' and naturaleza= 'A' and grupo = '12' then
			monto_iva := 0 ;
		end if;*/
	
		if naturaleza = 'D' then
			cargos_xg = monto_total::decimal;
			iva_cargos_xg = monto_iva::decimal; 
		else
			abonos_xg = monto_total::decimal;
			iva_abonos_xg = monto_iva::decimal;
		end if;

		insert into keplersc.kduxg (c1,c2,c3,c4,c5,
			c6,c7,c8,c9,c10,
			c11,c12 ,cve_prov_pago/*Added 240229*/ ,st_x_comprobar/*Added 20240328*/,doc_refer_compl/*Added 20240328*/ )
		values(sucursal_id,genero,clave_cteprov,referencia,docpar_xg,
			cargos_xg,abonos_xg,iva_cargos_xg,iva_abonos_xg,saldado_xg,
			fecha_exp_xe,fecha_venc_xe ,clave_provpago/*Added 240229*/ ,cr_st/*Added 20240328*/,ref_compl/*Added 20240328*/ );
		
	else
	
		-- New Code Added by JMM 20221120 
		cargos_xg := 0;
		abonos_xg := 0;
		iva_cargos_xg := 0;
		iva_abonos_xg := 0;
	
		if naturaleza = 'D' then
			cargos_xg = monto_total::decimal;
			iva_cargos_xg = monto_iva::decimal;
			
		else
			abonos_xg = monto_total::decimal;
			iva_abonos_xg = monto_iva::decimal;
			
		end if;
	
		select c11, c12 into fecha_exp, fecha_venc from keplersc.kduxg 	
		where c1 = sucursal_id and c2 = genero and c3 = clave_cteprov 
			and c4 = referencia and c5 = 1;	

		if (genero = 'X' and naturaleza = 'A') or (genero = 'U' and naturaleza = 'D') then 
		
			if fecha_exp >= fecha_exp_xe or fecha_exp=to_date('1800-01-01','YYYY-MM-DD') then
				fecha_exp := fecha_exp_xe;
				fecha_venc := fecha_venc_xe;
			end if;
		
		end if;
	
		update keplersc.kduxg
			set c6 = c6 + cargos_xg , c7 = c7 + abonos_xg , c8 = c8 + iva_cargos_xg , c9 = c9 + iva_abonos_xg 
				, c11 = fecha_exp , c12 = fecha_venc   
		where c1 = sucursal_id and c2 = genero and c3 = clave_cteprov and c4 = referencia and c5 = 1;
	
		select c6, c7 into var_cargos, var_abonos from keplersc.kduxg 	
		where c1 = sucursal_id and c2 = genero and c3 = clave_cteprov 
			and c4 = referencia and c5 = 1;
	
		saldado_xg := 0;
	
		if genero = 'U' and var_cargos <= var_abonos then 
			saldado_xg := 10;
		end if;
	
		if genero = 'X' and var_abonos <= var_cargos then 
			saldado_xg := 10;
		end if;
	
		update keplersc.kduxg 
		set c10 = saldado_xg  
		where c1 = sucursal_id and c2 = genero and c3 = clave_cteprov and c4 = referencia and c5 = 1;	
	
	end if;

	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cxcp_sinmov_kduxg_alta() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
