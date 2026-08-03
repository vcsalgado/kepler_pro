CREATE OR REPLACE FUNCTION keplersc.alta_cont_doc_no_deduc(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserci�n de movimientos contables en KDMDOCSNODEDUC
---- para uso exclusivo de las Operaciones de Nvo Esquema de CxP - Contrarecibo Convert No Deduc (Comprobacion de C x P)
--Autor: Jose Mendoza
--Fecha: 23/09/2024
-- Incluye Concepto Presupuesto para nuevo SCH - Gastos ( C x P . Contra Recibos)

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

	--Variables de uso general 
	strValor text;

	--Added by JMM 20240308
	flag_contrarec text = '';
	afecta_inventario text = '';

	--Added by JMM 20240718 ... for budgets
	func_Valor text = '';
	st_prspto_concept text = '';
	prspto_monto numeric;
	prspto_ejercido numeric;
	nvo_monto numeric;
	fecha text = '';
	concepto_presupuesto text = '';

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

	--Added by JMM 20240308 ... Moved here by JMM 20240404
	flag_contrarec = '';
	if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
		flag_contrarec := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
	end if;

	if upper(flag_contrarec) <> 'CXP_CONTR_REC_CONVERT_NO_DEDUC' then 
		raise exception '%', 'Se esta llamando a la funcion [ alta_cont_doc_no_deduc ] desde una Operacion No Valida ...';
	end if;

	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	

	numero_partida := 0;

	for cont in 0..no_partidas - 1 loop
		
			clave_cuenta := coalesce((xpath('//document/k_mov/r' ||cont||'/k_cuenta/text()',dataxml))[1], '');
			if clave_cuenta = '' then
				continue;
			end if;
			numero_partida := numero_partida + 1;
			descr_cuenta := (xpath('//document/k_mov/r' ||cont||'/k_cuentadesc/text()',dataxml))[1];
			cargo := (xpath('//document/k_mov/r' ||cont||'/k_cargo/text()',dataxml))[1];
			abono := (xpath('//document/k_mov/r' ||cont||'/k_abono/text()',dataxml))[1];		
			inventario := coalesce((xpath('//document/k_mov/r' ||cont||'/k_inventario/text()',dataxml))[1],'');	
		
			afecta_inventario = '';
			concepto_presupuesto = ''; /*Added by JMM 20240718*/
		
			/*if upper(flag_contrarec) = 'CXP_CONTR_REC_CONVERT_NO_DEDUC' then*/ -- Moved and evaluated to UP 20240404
			
				if length(trim(inventario)) > 0 then
					afecta_inventario := coalesce((xpath('//document/k_mov/r' ||cont||'/k_afecta/text()',dataxml))[1],'');
					if length(trim(afecta_inventario)) = 0 then
						mensaje := 'No se cuenta con la afectacion para el inventario registrado ' || inventario || ' , partida ' || numero_partida::text;
						raise exception '%' , mensaje;
					end if;
				end if;
			
				------  START : Segment for Budgets  ,  Added by JMM 20240718 
			
				st_prspto_concept := coalesce((xpath('//document/k_mov/r' ||cont||'/k_ctopto/text()',dataxml))[1],'');
				
				--Adapted by JMM 20240820 
				/*fecha := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'')::text;*/
				fecha := coalesce((xpath('//document/c_fecha/text()', dataxml))[1]::text,'')::text;
			
				--For Testing
				/*raise exception '%', 'c_fecha : ' || fecha;*/				

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
					
						-- For Testing ...
						--raise exception '%', 'Continua ... No Maneja Presupuesto';
					
					end if;
				
				end if;
			
				------  END : Segment for Budgets  ,  Added by JMM 20240718 		
			
			/*end if;*/ -- Moved and evaluated to UP 20240404
		
		
			if cargo <> '' then
				monto := cargo::numeric;
				cargo_abono:= 'C';
			else
				monto := abono::numeric;
				cargo_abono:= 'A';
			end if;
		
			insert into keplersc.kdmdocsnodeduc (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c13 ,c12/*Added by JMM 20240308*/ ,ctopto/*Added by JMM 20240723*/)
			values(sucursal_id,genero,naturaleza,grupo::integer,tipo_clave::integer,
				folio_operacion,numero_partida, clave_cuenta, descr_cuenta, cargo_abono, monto, inventario 
				,afecta_inventario/*Added by JMM 20240308*/ ,concepto_presupuesto/*Added by JMM 20240718*/);
			
	end loop ;	
	
	--Added by JMM 20240923
	if numero_partida <> 1 then 
		raise exception '%', 'El Documento No es Elegible para la Conversion como No Deducible, cuenta con ' || numero_partida || ' Partidas ' ;
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_cont_doc_no_deduc() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
