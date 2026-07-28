CREATE OR REPLACE FUNCTION keplersc.cxcp_conmov_kduxg(dataxml xml, tipo_ope text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: cxcp_conmov_kduxg
--Autor: Luis Leal
--Fecha: 21/10/2022
--Bitacora de cambios
--29/02/2024 (JMM) :
---- Se Incluyen Campos Prov_Pago al final 
---- para las Operaciones de los Documentos que aplique, dentro del Nvo Esquema de CxP 
--23/04/2024 (JMM) :
---- Se Incluyen Valores para la Operacion del Contrarecibo Tipo DEV CLIENTES 
--22/12/2024 Miriam Santana: Se incluye validaciones para anulacion de cobros
--06/04/2026 Miriam Santana: Deje generico la seccion de UD, antes solo lo habia puesto para anulacion de cobros flag_cobros = 'ANULACION_COB'

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
	no_partidas int;
	referencia text;
	documento numeric;
	clave_cteprov text;
	fecha_operacion text; --yyyy-mm-dd
	plazo_vencimiento text;	
	monto_iva text;
	monto_total text;
	cargos_pasados decimal;
	abonos_pasados decimal;
	iva_cargos_pasados decimal;
	iva_abonos_pasados decimal;

	--variables kduxg
	cargos_xg decimal;
	abonos_xg decimal;
	iva_cargos_xg decimal;
	iva_abonos_xg decimal;
	saldado_xg int;
	fecha_exp_xg text;
	fecha_venc_xg text;
	
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

	flag_cobros text = '';	--MSS 12122024 Anulacion de cobro

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
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	clave_cteprov := (xpath('//document/k_clave/text()', dataxml))[1];
	referencia := (xpath('//document/k_refer/text()',dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	plazo_vencimiento := coalesce((xpath('//document/k_vence/text()', dataxml))[1]::text,'1800-01-01')::text;
	monto_iva := (xpath('//document/k_iva/text()',dataxml))[1];		
	monto_total := (xpath('//document/k_monto/text()',dataxml))[1];
	documento := coalesce((xpath('//document/k_documento/text()', dataxml))[1]::text,'1')::text;

	flag_cobros :=coalesce((xpath('//document/k_flag_cobros/text()',dataxml))[1]::text,'')::text;		--MSS 12122024 Anulacion de cobro

	--  * * * * *  Added 20240229 by JMM, Proveedor de Pago  
	clave_provpago := '';

	if xpath_exists('//document/k_clave_pago/text()', dataxml) = true /*false*/ then 
		clave_provpago := coalesce((xpath('//document/k_clave_pago/text()',dataxml))[1]::text,'')::text;
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
	ref_compl = ''; /*Este campo de inicio siempre ira en blanco*/
	
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
	--  * * * * *  End : Tipo Contra-Recibo  x Comprobar

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


	cargos_xg := 0;
	abonos_xg := 0;
	iva_cargos_xg := 0;
	iva_abonos_xg := 0;
	saldado_xg := 0; 
	fecha_exp_xg := fecha_operacion;
	fecha_venc_xg := plazo_vencimiento;

	if naturaleza = 'D' then
		cargos_xg = monto_total::decimal;
		iva_cargos_xg = monto_iva::decimal;
	else
		abonos_xg = monto_total::decimal;
		iva_abonos_xg = monto_iva::decimal;
	end if;

	select c6,c7,c8,c9 into cargos_pasados, abonos_pasados,iva_cargos_pasados,iva_abonos_pasados
	from keplersc.kduxg where c1=sucursal_id and c2=genero and c3=clave_cteprov 
	and c4=referencia and c5=documento::numeric;
	if found then
	
		if genero = 'U' and naturaleza = 'A' then
		
			if tipo_ope = 'Alta' then
				abonos_xg := abonos_xg + abonos_pasados;
				iva_abonos_xg := iva_abonos_xg + iva_abonos_pasados;
			end if;
		
			if tipo_ope = 'Baja' then
				abonos_xg := abonos_pasados - abonos_xg;
				iva_abonos_xg := iva_abonos_pasados - iva_abonos_xg;
			end if;
		
			if cargos_pasados <= abonos_xg  then
				saldado_xg := 10;
			end if;
			cargos_xg := cargos_pasados; 
			iva_cargos_xg := iva_cargos_pasados;
		end if;
		
		if genero = 'X' and naturaleza = 'D' then
		
			if tipo_ope = 'Alta' then
				cargos_xg := cargos_xg + cargos_pasados;
				iva_cargos_xg := iva_cargos_xg + iva_cargos_pasados;
			end if;
		
			if tipo_ope = 'Baja' then
				cargos_xg := cargos_pasados - cargos_xg ;
				iva_cargos_xg := iva_cargos_pasados - iva_cargos_xg;
			end if;
		
			if abonos_pasados <= cargos_xg then
				saldado_xg := 10;
			end if;
			abonos_xg := abonos_pasados;
			iva_abonos_xg := iva_abonos_pasados;
		end if;
	
		if genero = 'U' and naturaleza = 'D' then			--MSS 12122024 Anulacion de cobro
--			if flag_cobros = 'ANULACION_COB' then
				if tipo_ope = 'Alta' then
					cargos_xg := cargos_xg + cargos_pasados;
					iva_cargos_xg := iva_cargos_xg + iva_cargos_pasados;
				end if;
			
				if tipo_ope = 'Baja' then
					cargos_xg := cargos_pasados - cargos_xg ;
					iva_cargos_xg := iva_cargos_pasados - iva_cargos_xg;
				end if;
	
				if cargos_xg <= abonos_pasados  then
					saldado_xg := 10;
				end if;
				abonos_xg := abonos_pasados;
				iva_abonos_xg := iva_abonos_pasados;
--			end if;
		end if;
		
		update keplersc.kduxg set c6=cargos_xg,c7=abonos_xg,c8=iva_cargos_xg,c9=iva_abonos_xg,c10=saldado_xg
		where c1=sucursal_id and c2=genero and c3=clave_cteprov and c4=referencia and c5=documento::numeric;
	
	else 
		insert into keplersc.kduxg (c1,c2,c3,c4,c5,
			c6,c7,c8,c9,c10,
			c11,c12 ,cve_prov_pago/*Added 240229*/ ,st_x_comprobar/*Added 20240328*/,doc_refer_compl/*Added 20240328*/ )
		values(sucursal_id,genero,clave_cteprov,referencia,documento::numeric,
			cargos_xg,abonos_xg,iva_cargos_xg,iva_abonos_xg,saldado_xg,
			to_date(fecha_exp_xg,'YYYY-MM-DD'),to_date(fecha_venc_xg,'YYYY-MM-DD') ,clave_provpago/*Added 240229*/ ,cr_st/*Added 20240328*/,ref_compl/*Added 20240328*/ );	
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cxcp_conmov_kduxg() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
