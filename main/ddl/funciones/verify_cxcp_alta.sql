CREATE OR REPLACE FUNCTION keplersc.verify_cxcp_alta(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare 
--Descripcion: Realiza validacion de una alta de cxcp o cxc
--Autor: Miriam Santana
--Fecha: 04/09/2022
--Bitacora de cambios
--24/04/2024 (JMM) :
---- Se Incluyen Campos Asociados a la Referencia Complementaria ( DOC.Devolucion_Clientes) 
---- para las Operaciones de los Comtrarecibos Tipo DEV CLIE, dentro del Nvo Esquema de CxP 
--17/03/2025 Miriam Santana: Incuir validaciones para Aplicacion de anticipos, no validar la fecha de vencimiento
--03/06/2025 Miriam Santana: Anulacion por sustitucion, validar que no tenga movimientos pendientes por cancelar
	
	--Variables de definicion de documento
	no_partidas int = 0;
	cantidad_unidades text = '';
	clave_producto text = '';
	sucursal_id text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo_clave text = '';
	fecha_operacion text = '';
	tipo_movto text = '';
	hora_movto text = '';
	referencia text = '';
	clave_cteprov text = '';
	monto_total text = '';
	fecha_vencimiento text = '';

	-- Added by JMM 221122 
	folio_docto text = '';
	ref_doc text = '';
	uen text = '';
	saldo decimal;
	importe text;
	n_importe decimal;

	-- Added by JMM 20240424
	flag_gastos text = '';
	ref_compl text = '';
	aux_gen text = ''; 
	aux_nat text = '';
	aux_gpo text = '0'; 
	aux_tip text = '0';
	aux_folio text = '';

	flag_anulacion text = '';	--MSS 03062025 Anulacion por sustitucion
	anulacion decimal;			--MSS 03062025 Anulacion por sustitucion
	pagos decimal;				--MSS 03062025 Anulacion por sustitucion

	--Variables de uso general
	cargos decimal;
	abonos decimal;
   	var_monto decimal;
   	msg_err text;
 	strValor text = '';
 	totReg	int;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin 

	msg_err := '';
	
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	monto_total := (xpath('//document/k_monto/text()', dataxml))[1];
	referencia := (xpath('//document/k_refer/text()', dataxml))[1];
	clave_cteprov := (xpath('//document/k_clave/text()', dataxml))[1]; raise notice 'clave_cteprov %', clave_cteprov;
	fecha_vencimiento := (xpath('//document/k_vence/text()', dataxml))[1];	

	-- Tags Added By JMM 221122 , TAG folio docto tomado del tag usado para almacenar en la KDM1
	folio_docto := coalesce((xpath('//document/k_foliodocto/text()',dataxml))[1]::text,'')::text;--c39
	uen := coalesce((xpath('//document/ambiente/uen/text()', dataxml))[1]::text,'');
	importe := coalesce((xpath('//document/k_monto/text()',dataxml))[1]::text,'0')::text;

	flag_anulacion :=coalesce((xpath('//document/ambiente/flag_anulacion/text()',dataxml))[1]::text,'')::text;	--MSS 03062025 Anulacion por sustitucion
	----- SECTION ADDED BY JMM 20240424 ... NEW SCH GASTOS 

	flag_gastos = '';
	ref_compl = '';

	aux_gen := ''; 
	aux_nat := '';
	aux_gpo := '0'; 
	aux_tip := '0';
	aux_folio := '';

	if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
		flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
	end if;

	if upper(flag_gastos) = 'CXP_CONTR_REC_DEVCLI' then
		
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
			or length(referencia) = 0 or length(aux_folio) = 0 or length(ref_compl) = 0 
		then 
			raise exception '%', 'Los Datos de Devolucion estan Incompletos ...';
		else
			-- For testing ...
			/*raise exception '%', 'Es un Gasto de Devolucion a Cliente ...';*/
			-- THIS CONTINUE ... 
		end if;
	
	end if;

	----- END : SECTION ADDED BY JMM 20240424 ... NEW SCH GASTOS 


	if (genero = 'U' and naturaleza = 'D') or (genero = 'X' and naturaleza = 'A') then
		if genero = 'X' then
			if (xpath('//row/c47/text()', xmlKDMM))[1]::text  = 'S' then		--Tiene pantalla de movtos cxcp
				--TO DO: VALIDACION PARA PANTALLA CXCP
			else 

				-- Codigo Incluido por JMM el 221202, para compras de Autos Usados
				-- Podran incluirse nuevas CxP si las otras estan Saldadas ... 
			
				if upper((xpath('//document/ambiente/uen/text()', dataxml))[1]::text) = 'VEN' 
					and ( grupo = '7' or grupo = '6' /* or gpo.6 Added by JMM 20240709*/ )
				then
					
					select count(*) into totReg, abonos from keplersc.kduxg k
					where c1 = sucursal_id and c2 = genero and c3 = clave_cteprov and c4 = referencia 
						and (c6 <> 0 or c7 <> 0) and (c6 <> c7);
					
				else
				
					-- Codigo Original, incluido en este if el 221202 por JMM
					/*
					select count(*) into totReg, abonos from keplersc.kduxg k
					where c1 = sucursal_id and c2 = genero and c3 = clave_cteprov and c4 = referencia and (c6 <> 0 or c7 <> 0);
					*/
				
					--UPD by JMM 20240424 
					-- Para discriminar Operaciones de Contrarecibos Tipo DEV Cliente 
					-- Incluyendo en el Filtro la Referencia Complemento correspondiente a la Devolucion Asociada  
					-- No tiene impactos en otros Documentos porque este campo debe estar vacio
					select count(*) into totReg, abonos from keplersc.kduxg k
					where c1 = sucursal_id and c2 = genero and c3 = clave_cteprov 
						and c4 = referencia and (c6 <> 0 or c7 <> 0)
						and doc_refer_compl like '%' || aux_folio || '%'; /*line added by JMM 20240424*/
				
				end if;
			
				raise notice '%', 'paso 2';
				if totReg > 0 then
					raise exception 'Esta tratando de ingresar la misma factura dos veces';
				end if;	
			
			end if;
		end if;
		if (xpath('//row/c47/text()', xmlKDMM))[1]::text  = 'S' then		--Tiene pantalla de movtos cxcp
			--TO DO: VALIDACION PARA PANTALLA CXCP			    
		else 
			if fecha_vencimiento::date<fecha_operacion::date and concat(genero,naturaleza,grupo) <> 'UD81' then 		--MSS 17032025 Aplicacion de anticipos
				raise exception 'La fecha de vencimiento es antes del dia de hoy';
			end if;
		end if;
	end if;	

	if (genero = 'X' and naturaleza = 'D') or (genero = 'U' and naturaleza = 'A') then
		--TO DO: Realizar validaciones para que no te permita pagar
	
		-- Codigo Desarrollado por Jose Mendoza para resolver esta verificacion 
		-- Basado en MOVLIB - VERIFY_CXCP_ALTA (AUTOS)
		if (xpath('//row/c47/text()', xmlKDMM))[1]::text  = 'S' then	
					--TO DO: VALIDACION PARA PANTALLA CXCP
		
		else 
		
			if genero = 'U' then  
				ref_doc := folio_docto; raise notice 'folio_docto %',folio_docto;
			else 
				ref_doc := referencia; raise notice 'referencia %',referencia;
				if uen = 'VEN' then
					ref_doc := lpad(referencia,10,'0');
				end if;
			end if;
		
			select count(*) into totReg from keplersc.kduxg 
			where c1 = sucursal_id and c2 = genero and c3 = clave_cteprov and c4 = ref_doc /*referencia*/;
	
			if totReg = 0 then
				mensaje = concat('No se encuentra la cuenta ', ref_doc ,' [TBL kduxg] ...');
				raise exception '%', mensaje;
			
			else
			
				cargos := 0;
				abonos := 0;
				n_importe := importe::numeric;
			
				select coalesce(c6,0), coalesce(c7,0) into cargos, abonos from keplersc.kduxg 
				where c1 = sucursal_id and c2 = genero and c3 = clave_cteprov and c4 = ref_doc /*referencia*/;

				if naturaleza = 'D' then
					saldo := abonos - cargos;
				else
					saldo := cargos - abonos;
				end if;
				
----				
				if flag_anulacion='CANCELA_X_SUST' then					--MSS 03062025 Anulacion por sustitucion, validar que no tenga movtos pendientes por cancelar
					--suma de pagos
					select coalesce(sum(c13),0) into pagos from keplersc.kduxe
						where c1 = sucursal_id and c2 = clave_cteprov and c3 = ref_doc and c5 = genero and c6='A' and c7=29;
					--suma de anulacion de pagos
					select coalesce(sum(c13),0) into anulacion from keplersc.kduxe
						where c1 = sucursal_id and c2 = clave_cteprov and c3 = ref_doc  and c5 = genero and c6='D' and c7=32;
					if pagos-anulacion > 0 then 
						raise exception 'No es posible realizar el movimiento, la factura tiene pagos pendientes de anular por sustitucion';
					end if;
					pagos :=0;
					anulacion :=0;
					--suma de notas de descuento
					select coalesce(sum(c13),0) into pagos from keplersc.kduxe
						where c1 = sucursal_id and c2 = clave_cteprov and c3 = ref_doc and c5 = genero and c6='A' and c7=52;
					--suma de anulaciones notas de descuento
					select coalesce(sum(c13),0) into anulacion from keplersc.kduxe
						where c1 = sucursal_id and c2 = clave_cteprov and c3 = ref_doc  and c5 = genero and c6='D' and c7 in(61,63);
						
					if pagos-anulacion > 0 then 
						raise exception 'No es posible realizar el movimiento, la factura tiene notas de descuento pendientes de dar de baja';
					end if;
					
				end if;
----			
				if n_importe > saldo then 
					raise exception '%','Si se realiza la operacion el importe excederia al Saldo ' || saldo::text; 
               	end if;
			
			end if;	
		
		end if;
	
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'verify_cxcp_alta() ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
