CREATE OR REPLACE FUNCTION keplersc.alta_cont_sec(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserci?n de movimientos contables en KDM6
--Autor: Luis Leal
--Fecha: 07/10/22
--08/03/2024 (JMM) :
---- Se Incluyen Campos Afectacion Inventario al final 
---- para las Operaciones de Nvo Esquema de CxP - Contrarecibo Unico (Unificado)
--17/07/2024 (JMM) : 
---- Incluir Concepto Presupuesto para nuevo SCH - Gastos ( C x P . Contra Recibos) 
--12/11/2025 VCSS Impuestos

declare
	--Variables de definicion de documento
	sucursal_desc text;
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text; 
	tipo_clave text;


	--Variables Loop
	no_partidas int;
	numero_partida int;
	clave_cuenta text;
	descr_cuenta text;
	cargo text;
	abono text;	
	monto numeric = 0;
	cargo_abono text;
	inventario text;
	primera_partida int=0;

	--Variables de uso general 
	strValor text;

	--Added by JMM 20240308
	flag_contrarec text = '';
	afecta_inventario text = '';

	--Added by JMM 20240716 ... for budgets
	func_Valor text = '';
	st_prspto_concept text = '';
	prspto_monto numeric;
	prspto_ejercido numeric;
	nvo_monto numeric;
	fecha text = '';
	concepto_presupuesto text = '';

	--VCSS 12/11/2025 Impuestos
	tagMovtosCtas text = '';
	concepto_factura text='';
	referencia_uuid text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;


begin
	sucursal_desc := (xpath('//document/k_sucn/r0/text()', dataxml))[1];
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];

	--Tipo de documento
	tipo_desc := (xpath('//document/k_tipon/r0/text()', dataxml))[1]; 
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	concepto_factura:= coalesce((xpath('//document/uuid/concepto_factura/text()',dataxml))[1]::text,'')::text;

	--Partidas
	flag_contrarec := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;

	if xpath_exists('//document/k_mov_ctas', dataxml) = true then 
		tagMovtosCtas =  'k_mov_ctas';
	else
 		tagMovtosCtas =  'k_mov';
	end if;

	strValor := (xpath('//document/' || tagMovtosCtas ||' /no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	

	primera_partida := 0;
	numero_partida := 0;
	if concepto_factura <> '' then
		if flag_contrarec = 'CXP_TRANSFER_CONVERT' then
			select coalesce(max(c7),0) into primera_partida from keplersc.kdm6 
				where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::int 
				and c5=tipo_clave::int and c6=folio_operacion;
		end if;
	end if;

	numero_partida=primera_partida;

	for cont in 0..no_partidas - 1 loop
		
			clave_cuenta := coalesce((xpath('//document/' || tagMovtosCtas ||'/r' ||cont||'/k_cuenta/text()',dataxml))[1], '');
			cargo := coalesce((xpath('//document/' || tagMovtosCtas ||'/r' ||cont||'/k_cargo/text()',dataxml))[1],'0');
			abono := coalesce((xpath('//document/' || tagMovtosCtas ||'/r' ||cont||'/k_abono/text()',dataxml))[1],'0');
			if clave_cuenta = '' or (cargo='0' and abono = '0') then
				continue;
			end if;
			numero_partida := numero_partida + 1;
			descr_cuenta := (xpath('//document/' || tagMovtosCtas ||'/r' ||cont||'/k_cuentadesc/text()',dataxml))[1];
			cargo := (xpath('//document/' || tagMovtosCtas ||'/r' ||cont||'/k_cargo/text()',dataxml))[1];
			abono := (xpath('//document/' || tagMovtosCtas ||'/r' ||cont||'/k_abono/text()',dataxml))[1];		
			inventario := coalesce((xpath('//document/' || tagMovtosCtas ||'/r' ||cont||'/k_inventario/text()',dataxml))[1],'');	

			referencia_uuid := coalesce((xpath('//document/' || tagMovtosCtas ||'/r' ||cont||'/k_referencia_uuid/text()',dataxml))[1],''); --VCSS impuestos


			--Added by JMM 20240308
			flag_contrarec = '';
			if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
				flag_contrarec := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
			end if;
		
			afecta_inventario = '';
			concepto_presupuesto = ''; /*Added by JMM 20240716*/
			if upper(flag_contrarec) in ('CXP_CONTR_REC','CXP_CONTR_REC_INTERNO','CXP_CM_RETENCIONES') then --Adapted by JMM 20241015 
			
				if length(trim(inventario)) > 0 then
					afecta_inventario := coalesce((xpath('//document/' || tagMovtosCtas ||'/r' ||cont||'/k_afecta/text()',dataxml))[1],'');
					if length(trim(afecta_inventario)) = 0 then
						mensaje := 'No se cuenta con la afectacion para el inventario registrado ' || inventario || ' , partida ' || numero_partida::text;
						raise exception '%' , mensaje;
					end if;
				end if;
			
				------  START : Segment for Budgets  ,  Added by JMM 20240716 
			
				st_prspto_concept := coalesce((xpath('//document/' || tagMovtosCtas ||'/r' ||cont||'/k_ctopto/text()',dataxml))[1],'');
				fecha := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'')::text;

				func_Valor := '';
				select * into func_Valor from keplersc.prspto_cc_maneja(sucursal_id/*Added by JMM 20240820*/, clave_cuenta, fecha);
			
				if upper(left(func_Valor,5)) = 'ERR -' then
					raise exception '%' , right(func_Valor, length(func_Valor) - 6) || ' Partida ' || numero_partida;
				else
				
					if upper(func_Valor) = 'S' then -- Cuenta Maneja Presupuesto
					
						--raise exception '%', 'Maneja Presupuesto ... Se haran Validaciones';
					
						concepto_presupuesto := st_prspto_concept;
					
						prspto_monto := 0;
						prspto_ejercido := 0;
						nvo_monto := 0;
					
						func_Valor := '';
						select * into func_Valor from keplersc.prspto_valida_concepto(sucursal_id, st_prspto_concept);
					
						if upper(left(func_Valor,5)) = 'ERR -' then
							raise exception '%' , right(func_Valor, length(func_Valor) - 6) || ' Partida ' || numero_partida;
						else
						
							func_Valor := '';
							select * into func_Valor from keplersc.prspto_monto_periodo(sucursal_id, st_prspto_concept, fecha);
						
							if upper(left(func_Valor,5)) = 'ERR -' then
								raise exception '%' , right(func_Valor, length(func_Valor) - 6) || ' Partida ' || numero_partida;
							else
							
								prspto_monto := func_Valor::numeric;
								if prspto_monto <= 0 then
									raise exception '%', 'No se ha Registrado el Presupuesto para el Concepto, dentro del periodo de la Operacion ...' || ' Partida ' || numero_partida;
								end if;
							
								func_Valor := '';
								select * into func_Valor from keplersc.prspto_ejercido_periodo(sucursal_id, st_prspto_concept, fecha);
						
								if upper(left(func_Valor,5)) = 'ERR -' then
									raise exception '%' , right(func_Valor, length(func_Valor) - 6) || ' Partida ' || numero_partida;
								else
									prspto_ejercido := func_Valor::numeric;
								end if;
							
								if cargo <> '' then
									nvo_monto := prspto_ejercido + cargo::numeric;
									if nvo_monto > prspto_monto then
										raise exception '%', 'No puedes exceder el Presupuesto para el Concepto ... ' || ' Partida ' || numero_partida || ' , Nvo. Monto ' || nvo_monto || ' > Presupuesto ' || prspto_monto;
									end if;
								end if;
							end if;
						end if;
					else

					end if;
				end if;	
				------  END : Segment for Budgets  ,  Added by JMM 20240716 		
			end if;
		
		
			if cargo <> '' then
				monto := cargo::numeric;
				cargo_abono:= 'C';
			else
				monto := abono::numeric;
				cargo_abono:= 'A';
			end if;
		
			insert into keplersc.kdm6 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c13 ,c12,ctopto,referencia)
			values(sucursal_id,genero,naturaleza,grupo::integer,tipo_clave::integer,
				folio_operacion,numero_partida, clave_cuenta, descr_cuenta, cargo_abono, monto, inventario 
				,afecta_inventario,concepto_presupuesto,referencia_uuid);
			
	end loop ;	
	
	resultado := 1;
	mensaje := '';
	adicionales := 'primera_partida=' || primera_partida::text;
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_cont_sec() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
