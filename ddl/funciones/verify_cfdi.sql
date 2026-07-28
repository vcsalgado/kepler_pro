CREATE OR REPLACE FUNCTION keplersc.verify_cfdi(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: verify_cfdi
--Autor: Luis Leal
--Fecha: 13/12/2021
--Bitacora de cambios
--17/03/2025 Miriam Santana: Incluir validaciones para Aplicacion de anticipos 
--25/06/2025 Miriam Santana: Se incluye validaciones para anulacion por sustitución (flag_anulacion)

declare

	--EN ESTA FUNCION PARA LOS DOCUMENTOS GENERO "U" NATURALEZA "D" EN K75 SE MANDAN LAS VARIABLES DEL A2-A4 
	--PARA LOS GENERO "U" NATURALEZA "A" EN K75 SE MANDAN LAS VARIABLES DEL A36-A39 PARA LA IDENTIFICACION DEL DOCUMENTO

	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	--tipo_clave text;
	--operacion_desc text = '';


	m86 text;
	m87 text;
	m88 text;
	datos_cteprov text;
	cp_cteprov text;
	forma_de_pago text;
	uso_cfdi text;
	monto_iva text;
	seriecfdi text;
	forma_p_busqueda text;
    cp_p_busqueda text;
    uso_p_busqueda text;
    statusNC int;
   	c16 text;
   	sustitucion_results text;
   	natdocto_anx text = '';
	gpodocto_anx text = '';
	tipodocto_anx text = '';
	foliodocto_anx text = '';
	regFiscal text = '';		--cfdi regfiscal
	clave_cteprov text = '';	--cfdi regfiscal
	metodo_de_pago text = '';	--cfdi regfiscal
	dat_cfdi text = '';	--Pantalla validacion cfdi
	tipoNC_A int;				--MSS NC y Anulacion
	
	--SUSTITUCION 
	folio_a_sustituir text;
	genero_a_sustituir text;
	naturaleza_a_sustituir text;
	grupo_a_sustituir text;
	tipo_a_sustituir text;

	fecha_factura date;
	monto numeric;
	monto_factura numeric;
   
   
  	validacion_pedimento text;
   	validacion_cuenta text;
   
   	--MSS 12032025 Aplicacion de anticipos
	flag_cobros text = '';
	no_partidas int;
	numero_partida int;
	gen_docto_aplicar text;
	nat_docto_aplicar text;
	gpo_docto_aplicar text;
	tpo_docto_aplicar text;
	folio_docto_aplicar text;
	factura text;
   
   	flag_anulacion text = '';	--MSS 25062025 Anulacion por sustitucion
	
	--variables de uso general
	strValor text;

	resultado text;


begin

	resultado = '0';

	--Documento
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	--tipo_clave := (xpath('//document/k_tipon/r5/text()', dataxml))[1];	
	--operacion_desc := (xpath('//document/operacion/text()', dataxml))[1];

	strValor := (xpath('//document/k_datcve/text()',dataxml))[1];
	datos_cteprov := regexp_replace(strValor, '\n','|','g');
	cp_cteprov := split_part(datos_cteprov, '|', 5);
	forma_de_pago := coalesce((xpath('//document/k_f_pago/r1/text()',dataxml))[1]::text,'')::text;
	uso_cfdi := coalesce((xpath('//document/k_cfdi/text()',dataxml))[1]::text,'')::text;
	natdocto_anx := (xpath('//document/k_natdocto/text()', dataxml))[1];
	gpodocto_anx := (xpath('//document/k_gpodocto/text()', dataxml))[1];
	tipodocto_anx := (xpath('//document/k_tipodocto/text()', dataxml))[1];
	foliodocto_anx := (xpath('//document/k_foliodocto/text()', dataxml))[1];	

	clave_cteprov := coalesce((xpath('//document/k_clave/text()', dataxml))[1]::text,'0')::text;	--cfdi regFiscal
	metodo_de_pago := coalesce((xpath('//document/k_m_pago/text()',dataxml))[1]::text,'')::text;	--cfdi regFiscal
	--SUSTITUCION 
	naturaleza_a_sustituir := (xpath('//document/k_natdocto/text()', dataxml))[1];
	grupo_a_sustituir := (xpath('//document/k_gpodocto/text()', dataxml))[1];
	tipo_a_sustituir := (xpath('//document/k_tipodocto/text()', dataxml))[1];
	folio_a_sustituir := (xpath('//document/k_foliodocto/text()', dataxml))[1];

	monto := (xpath('//document/k_monto/text()', dataxml))[1];	
	
	--MSS 12032025 Aplicacion de anticipos
	flag_cobros :=coalesce((xpath('//document/ambiente/flag_cobros/text()',dataxml))[1]::text,'')::text;
	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	

   	flag_anulacion :=coalesce((xpath('//document/ambiente/flag_anulacion/text()',dataxml))[1]::text,'')::text;	--MSS 25062025 Anulacion por sustitucion
	
	if genero = 'U' then --Cuentas por cobrar 
		--raise notice '%', xpath('//row/c80/text()', xmlKDMM);
		--SUB VERIFY_CFDI
		if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' then
			m86 := (xpath('//row/c86/text()', xmlKDMM))[1];
			m87 := (xpath('//row/c87/text()', xmlKDMM))[1];
			m88 := (xpath('//row/c88/text()', xmlKDMM))[1];
		
/***********Se comenta hasta que se ponga el dato <dat_cfdi> a todas las pantallas que kdmm.c80='S'(generen CFDI)**********					
			--Pantalla validacion cfdi
			if xpath_exists('//document/datcfdi', dataxml) = false then 
				raise exception 'No tiene pantalla de validacion, avisar al  rea de sistemas';
			else 
				if dat_cfdi='N' then 
					raise exception 'No se ha Validado la informaci n del cfdi';
				end if;
			end if;
			--
**********Se comenta hasta que se ponga el dato <dat_cfdi> a todas las pantallas que kdmm.c80='S'(generen CFDI)***********/			
		
			--raise notice '%,%,%', m86,m87,m88;	
			if m87 <> 'S' and m87 <> 'N' or m87 is null then 
				raise exception 'No esta configurado si el CFDI es Automatico o no, Revise la configuracion';
			end if;

			if m86 <> 'A' and m86 <> 'F'  and m86 <> 'P'  and m86 <> 'S' and m86 <> 'C' and m86 <> 'O' and m86 <> 'N' or m86 is null then 
				raise exception 'El tipo de CFDI solo puede ser (A)nticipo (F)actura (P)ago (S)ustitucion Nota de (C)argo o Cancelaci(O)n o Cancelacion de A(N)ticipo, Revise la configuracion';
			end if;
			
            if m88 <> 'V' and m88 <> 'S'  and m88 <> 'R'  and m88 <> 'G' or m88 is null then 
				raise exception 'El origen del CFDI solo puede ser (V)entas (S)ervicio (R)efacciones o (G)enerico, Revise la configuracion';
			end if;
			
            select c6 into seriecfdi from keplersc.kdcfdsersucdoc where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::int  and c5=tipo::int;
			if not found then
				raise exception 'Falta configurar la Serie del Folio para este CFDI, Revise la configuracion';
			end if;
			if length(seriecfdi) <> 2 then
				raise exception 'La Serie del CFDI tiene que tener 2 digitos Alfanumericos, Revise la configuracion';
			end if;
		
			/*select * into cp_p_busqueda from keplersc.kdf3cp where c1=cp_cteprov;
			if not found then
				raise exception 'El Codigo Postal es Invalido';
			end if;*/

			select * into forma_p_busqueda from keplersc.kdf3fp where c1=forma_de_pago;
			if not found then
				raise exception 'La Forma de Pago es Invalida';
			end if;
--MSS Faltaba IF M86><"S" AND M86><"N" AND M86><"O" THEN
			if (m86 <>'S' and m86 <>'N' and m86 <>'O') then			
				select * into uso_p_busqueda from keplersc.kdf3uso where c1=uso_cfdi;
				if not found then
					raise exception 'El Uso es Invalido, edite datos del Cliente';
				end if;
			end if;

            --Validar Regimen fiscal			--cfdi regfiscal
			select rf.c2 into regFiscal from keplersc.kdudcfd ud
				inner join keplersc.kdf3rf rf on rf.c1= ud.c24
				where ud.c1=clave_cteprov;
			if not found then
				raise exception 'El Regimen Fiscal es invalido, edite datos del Cliente';
			end if;		
		
			select c2 into strvalor from keplersc.kdf3mp
				where c1=metodo_de_pago;
			if not found then
				raise exception 'El Metodo de Pago es Invalido, edite datos del Cliente';
			end if;
		
			monto_iva := coalesce((xpath('//document/k_iva/text()',dataxml))[1]::text,'0')::text;
			c16= (xpath('//row/c16/text()', xmlKDMM))[1];
			if m86= 'P' and c16 <= '0' and monto_iva > '0' then 
				raise exception 'No puedes generar un Cobro de Credito con IVA, en una pantalla configurada sin IVA';
			end if;
			
			if m86= 'P' and forma_de_pago = '99' then 
				raise exception 'Para un cobro de Credito el tipo de Pago no puede ser 99';
			end if;
		
			select resultado_valid_pedimento into validacion_pedimento from keplersc.cfd_valid_pedimento(dataxml,xmlKDMM);
		
			select resultado_valid_cuenta into validacion_cuenta from keplersc.cfd_valid_cuenta(dataxml);
--MSS, faltaba el m86='N' en el  IF (M86="A" OR M86="N") AND M2="A"
--Diferencia de comentario para una NC 79 y para una Anulacion 80
--Validar si ya hay una NC no pueda hacer Anulacion y visceversa si hay Anulacion no pueda hacer NC
			if (m86='A' or m86='N') and naturaleza = 'A' then --VALIDAR QUE NO SE DUPLIQUE LA NOTA DE CREDITO, ANULACION O DEVOLUCION PARA EL MISMO ANTICIPO
				--MSS 12032025 Aplicacion de anticipos
				if upper(flag_cobros) = 'APLICA_ANTICIPO' then
					--Validar c/anticipo seleccionado que no este aplicado

					numero_partida := 0;
					for cont in 0..no_partidas - 1 loop	
						folio_docto_aplicar := (xpath('//document/k_mov/r' ||cont||'/k_factura/text()',dataxml))[1];

						if folio_docto_aplicar <> '' or folio_docto_aplicar is not null then
							numero_partida := numero_partida + 1;
							gen_docto_aplicar := (xpath('//document/k_mov/r' ||cont||'/gen_anticipo/text()',dataxml))[1];
							nat_docto_aplicar := (xpath('//document/k_mov/r' ||cont||'/nat_anticipo/text()',dataxml))[1];
							gpo_docto_aplicar := (xpath('//document/k_mov/r' ||cont||'/gpo_anticipo/text()',dataxml))[1];
							tpo_docto_aplicar := (xpath('//document/k_mov/r' ||cont||'/tpo_anticipo/text()',dataxml))[1];
							select c8,c10,folio_relacionado into statusNC,tipoNC_A,factura from keplersc.kdf3ncant 
								where c1=sucursal_id and c2=gen_docto_aplicar and c3=nat_docto_aplicar and c4=gpo_docto_aplicar::integer and c5=tpo_docto_aplicar::integer and c6=folio_docto_aplicar;			
			
							if (statusNC = 10) then	--YA EXISTE LA NOTA DE CREDITO, ANULACION O DEVOLUCION PARA ESE ANTICIPO
								if tipoNC_A = 81 then
									raise exception 'El anticipo % ya esta aplicado a la factura %, Imposible Continuar',folio_docto_aplicar,factura;
								end if;
							end if;
						end if;				
					end loop;
				else
					select c8,c10,folio_relacionado into statusNC,tipoNC_A,factura from keplersc.kdf3ncant 
						where c1=sucursal_id and c2=genero and c3=natdocto_anx and c4=gpodocto_anx::integer and c5=tipodocto_anx::integer and c6=foliodocto_anx;
					if (statusNC = 10) then	--YA EXISTE LA NOTA DE CREDITO, ANULACION O DEVOLUCION PARA ESE ANTICIPO
						if tipoNC_A = 79 then
							raise exception 'Ya existe una Nota de Credito para este Anticipo, Imposible Continuar';
						end if;
						if tipoNC_A = 80 then
							raise exception 'El Anticipo ya esta anulado, Imposible Continuar';
						end if;
						if tipoNC_A = 78 then
							raise exception 'Ya existe una Devolucion para este Anticipo, Imposible Continuar';
						end if;
						if tipoNC_A = 81 and factura <> '' then		--MSS 12032025 Aplicacion de anticipos
							raise exception 'Este anticipo ya esta aplicado a la factura: %, Imposible Continuar',factura;
						end if;
					else
						--MSS 12032025 Aplicacion de anticipos
						if 	factura <> '' then
							raise exception 'El anticipo ya esta seleccionado y relacionado a la factura %, Imposible Continuar',factura;
						end if;
					end if;				
				end if;
			end if;
		
			--VALIDANDO LAS NOTAS DE CREDITO Y ANULACIONES							
			select c9, m1.c16 into fecha_factura, monto_factura from keplersc.kdm1 m1 where c1=sucursal_id and c2=genero and c3=natdocto_anx 
			and c4=gpodocto_anx::integer and c5=tipodocto_anx::integer and c6=foliodocto_anx;
				
			--VALIDAMOS QUE VENGA DE UN DOCUMENTO DE CLIENTE
   			--QUE EL DOCUMENTO ORIGINAL A CANCELAR EXISTA
   			--QUE EL TOTAL DEL DOCUMENTO ORIGINAL SEA IGUAL AL DEL QUE SE ESTA GENERANDO PARA ASEGURAR QUE LO CANCELA TOTALMENTE
			if upper(flag_anulacion) <> 'CANCELA_X_SUST' then	--MSS 25062025 Anulacion por sustitucion			
				if ( ((naturaleza = 'A' and natdocto_anx = 'D') or (naturaleza = 'D' and natdocto_anx = 'A')) and  monto_factura = monto)-- VALIDANDO QUE SEAN DOCUMENTOS OPUESTOS DE CANCELACION
					or (monto_factura <> monto and naturaleza = 'D' and natdocto_anx = 'D') then --AJUSTE PARA BAJAS DE NOTAS DESCUENTO Y SUBSIDIOS
					----MSS 150125: Para anulaciones de notas de servicio UD19 no hay NC, no debe hacer la sig. validacion		
					if left(fecha_factura::text,4) <> left(current_date::text, 4) and (xpath('//row/c94/text()', xmlKDMM))[1]::text = 'A' and (concat(genero,naturaleza,grupo) <>'UD32' and concat(genero,naturaleza,grupo) <>'UD19') then		--MSS 060124: Para anulaciones de cobros UD32 no hay NC, no debe hacer esta validacion 
						raise exception 'La Factura es del Año: % y la Anulacion es del Año: %, Por favor emita una Nota de Credito.' ,left(fecha_factura::text,4), left(current_date::text, 4) ;
					end if;
				
				--Solo para los movimientos diferentes a Unidades Reportadas(U-A-63) validar el a o del movimiento			
				--MSS 151124: Cambie asi para respetar el comentario de solo <>U-A-63
					if concat(genero,naturaleza,grupo) <>'UA63' and concat(genero,naturaleza,grupo) <>'UA79' then	
						if left(fecha_factura::text,4) = left(current_date::text, 4) and (xpath('//row/c94/text()', xmlKDMM))[1]::text = 'N' then 
							raise exception 'LA Factura es del Año: % y la Nota de Credito es del Año: %, Por favor emita una Anulacion.' ,left(fecha_factura::text,4), left(current_date::text, 4) ;
						end if;
					end if;
					if left(fecha_factura::text,4) = left(current_date::text, 4) and (m86='F' or m86='C') then 
						--MSS 151124: Cambie asi para respetar el comentario de solo <>U-A-63
						if concat(genero,naturaleza,grupo) <>'UA63' and concat(genero,naturaleza,grupo) <>'UA79' then
						   raise exception 'La Factura es del Año: % y la Nota de Credito es del Año: %, Por favor emita una Anulacion.' ,left(fecha_factura::text,4), left(current_date::text, 4) ;
					    end if;
					end if;
				end if;
			end if;
		
			--MSS 25052026 No permitir anulacion o NC si la factura tiene aplicacion de anticipos
			if concat(genero,naturaleza,grupo) ='UA60' or concat(genero,naturaleza,grupo) ='UA70' then
				select c8,c10,folio_relacionado into statusNC,tipoNC_A,factura from keplersc.kdf3ncant 
					where c1=sucursal_id and tipo_relacion='07' and genero_doctorel=genero and naturaleza_doctorel=natdocto_anx and grupo_doctorel=gpodocto_anx::integer and tipo_doctorel=tipodocto_anx::integer and folio_relacionado=foliodocto_anx;
				if tipoNC_A = 81 then	
					raise exception 'Factura con Aplicacion de Anticipos. Por favor anule primero la Aplicacion de Anticipos';
				end  if;
			end if;

		end if;
	end if;

	resultado ='1';
	return query select resultado;				
end;
$function$
