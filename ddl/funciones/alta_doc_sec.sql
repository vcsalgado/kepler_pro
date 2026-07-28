CREATE OR REPLACE FUNCTION keplersc.alta_doc_sec(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserci�n de movimientos en KDM5
--Autor: Luis Leal
--Fecha: 18/10/22
--04/03/2024 (JMM) :
---- Se Incluyen Campos Prov Operacion, Prov Pago al final 
---- para las Operaciones de Nvo Esquema de CxP - Pagos Cheques
--12/03/2024 (JMM) :
---- Se Incluyen valores de los campos Prov Operacion, Prov Pago 
---- para las Operaciones de Nvo Esquema de CxP - Pagos Transfers {NEW DOC TYPE}
--14/03/2024 (JMM) :
---- Se Guarda la Cuenta de Deposito (del Grid) en CAT Proveedores 
---- para las Operaciones de Nvo Esquema de CxP - Pagos Transfers {NEW DOC TYPE}
--25/04/2024 (JMM) :
---- Se Implementa Discriminar la Cuenta de Deposito (del Grid) para No guardarse en 
---- el CAT Proveedores cuando el Proveedor es Interno usado para Devoluciones Anticipo / Clientes 
---- para las Operaciones de Nvo Esquema de CxP - Pagos Transfers {NEW DOC TYPE}


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
	factura text;
	num_docto text;
	monto text;
	iva text;
	vence text;

	-- Added by JMM 20240304 
	flag_gastos text = '';
	clave_prov_oper text = '';
	clave_prov_pago text = '';

	-- Added by JMM 20240314 
	cta_dep text = ''; /*Cuenta Deposito del Proveedor, uso en SCH.Transfer*/
	
	-- Added by JMM 20240425
	is_pagdev numeric;
	doc_param text = '';

	-- Added by JMM 20240805
	ref_compl text = '';
	rec1 record;

	--Variables de uso general 
	strValor text;

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


	--Added by JMM 20240304
	flag_gastos := '';
	clave_prov_pago := '';
	if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
		flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
		if upper(flag_gastos) = 'CXP_PAGO' then
			clave_prov_pago := coalesce((xpath('//document/k_clave/text()', dataxml))[1]::text,'')::text;
		end if;
	end if;


	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	

	numero_partida := 0;

	for cont in 0..no_partidas - 1 loop
		
		factura := (xpath('//document/k_mov/r' ||cont||'/k_factura/text()',dataxml))[1];

		if factura <> '' or factura is not null then
			numero_partida := numero_partida + 1;
		
			monto := (xpath('//document/k_mov/r' ||cont||'/k_monto_factura/text()',dataxml))[1];
			num_docto := coalesce((xpath('//document/k_mov/r' ||cont||'/k_documento/text()',dataxml))[1]::text,'1');
			iva := (xpath('//document/k_mov/r' ||cont||'/k_iva_factura/text()',dataxml))[1];
			vence := coalesce((xpath('//document/k_mov/r' ||cont||'/k_vencimiento_factura/text()',dataxml))[1]::text,'1990-01-01')::text;

		
			--Added by JMM 20240312
			if upper(flag_gastos) = 'CXP_TRANSFER' then
			
				clave_prov_pago := ''; 
				clave_prov_pago := coalesce((xpath('//document/k_mov/r' ||cont||'/k_clave/text()',dataxml))[1]::text,'')::text;
				if length(trim(clave_prov_pago)) = 0 then
					raise exception '%', 'No se pudo determinar el Proveedor de Pago ... Partida ' || numero_partida::text;
				end if;
				
				--Added by JMM 20240314
				cta_dep := '';
				cta_dep := coalesce((xpath('//document/k_mov/r' ||cont||'/c_cuenta/text()',dataxml))[1]::text,'')::text;
				if length(trim(cta_dep)) = 0 then
					raise exception '%', 'No se pudo obtener la Cta de Deposito del Proveedor para la Transferencia  ... Partida ' || numero_partida::text;
				else
					
					-- Added by JMM 20240425 ... Verificar si Proveedor es Interno para uso de Pago Devoluciones 
					-- Start : Section - Verificar se Prov es PagDev 
					doc_param := '';
					is_pagdev := 0;
				
					select pagdev into is_pagdev from keplersc.kdxd where /*c1 = sucursal_id and*/ c2 = clave_prov_pago;
					is_pagdev := coalesce(is_pagdev,0);
				
					select (coalesce(valor,'')) into doc_param from keplersc.param_oper 
					where sucursal = sucursal_id and upper(parametro) = upper('Devolucion Clientes Proveedor');

					doc_param := trim(doc_param);
				
					if is_pagdev = 1 or doc_param = clave_prov_pago then 
					
						-- No se Actualiza la CTA DEPOSITO en CAT PROV
					
						--For Testing
						/*raise exception '%', 'Es Proveedor Generico de Devoluciones de Anticipos';*/
				
					-- END : Section - Verificar se Prov es PagDev 
					else 
					
						-- Esta segmento se incluyo en el else por JMM 20240425
						-- Actualizar Dato Cta Deposito del Proveedor de Pago de la Transferencia 
						update keplersc.kdxd 
						set ctadep = trim(cta_dep)
						where /*c1 = sucursal_id and*/ c2 = clave_prov_pago;
						strValor := '';
						select ctadep into strValor from keplersc.kdxd where /*c1 = sucursal_id and*/ c2 = clave_prov_pago;
						if cta_dep <> coalesce(strValor,'') then
							raise exception '%', 'Se presentaron inconsistencias al obtener la Cta de Deposito del Proveedor para la Transferencia  ... Partida ' || numero_partida::text;
						end if;
					
					end if;
				
				end if;
			
			else
				cta_dep := ''; --Added by JMM 20240327
			end if;
		
		
			--Added by JMM 20240304
			clave_prov_oper = '';		
			if upper(flag_gastos) = 'CXP_PAGO' or upper(flag_gastos) = 'CXP_TRANSFER' /*Added by JMM 20240312*/ then
				clave_prov_oper := coalesce((xpath('//document/k_mov/r' ||cont||'/k_prov/text()',dataxml))[1]::text,'')::text;
				if length(trim(clave_prov_oper)) = 0 then
					raise exception '%', 'No se pudo determinar el Proveedor de la Operacion ... Partida ' || numero_partida::text;
				end if;
			
			-- START SECTION CODE {Extra Rer} : Added by JMM 20240805 ... To Save Extended Data For IDs Lookups
			
				ref_compl := '';
			
				select w.* into rec1 from keplersc.kduxg g 
				inner join keplersc.kduxe e on g.c1 = e.c1 and g.c2 = e.c5 and g.c3 = e.c2 and g.c4 = e.c3
				inner join keplersc.kdm1 w on w.c1 = e.c1 and w.c2 = e.c5 and w.c3 = e.c6 and w.c4 = e.c7 and w.c5 = e.c8 and w.c6 = e.c9 
				where g.c1 = sucursal_id and e.c6 = 'A' and g.c2 = genero/*'X'*/ and g.c3 = clave_prov_oper and g.c4 = factura/*rec.c14*/
					and w.c16 > 0 /*Added by JMM 20240925*/;
				
				if not found then 
					mensaje := 'No se encontro registro en KDM1 de la CxP de Origen ... ' || factura/*rec.c14*/;
					raise exception '%',mensaje;
				else
					mensaje := '';
					-- For Testing, It Continuing ...
					-- raise exception '%''%',rec1.c11,rec1.doc_refer_compl;
				end if;
			
				if length( coalesce(rec1.c11,'') ) > 0 then
					ref_compl := '[R] ' || rec1.c11 || ' | ';
				end if;
				if length( coalesce(rec1.doc_refer_compl,'') ) > 0 then
					ref_compl := ref_compl || '[C] ' || rec1.doc_refer_compl || ' | ';
				end if;
			
				if length( ref_compl ) > 0 then
					ref_compl := '[D] ' || rec1.c2 || rec1.c3 || rec1.c4 || rec1.c5 || rec1.c6 || ' | ' || ref_compl;
					-- For Testing, It Continuing ...
					--raise exception 'ref_compl %', ref_compl;
				else
					raise exception '%', 'No se pudo determinar la Referencia de seguimiento para la Cuenta : ' || factura;
				end if;
				
			else
				ref_compl := '';
			
			-- END SECTION CODE {Extra Rer} : Added by JMM 20240805 ... To Save Extended Data For IDs Lookups
			
			end if;
	
			insert into keplersc.kdm5 (c1,c2,c3,c4,c5,c6,c7,c11,c12,c13,c14, c15, c16
				, cve_prov_oper, cve_prov_pago, cta_deposito/*Added by JMM 20240327*/ , doc_refer_compl/*Added by JMM 20240805*/ )
			values(sucursal_id,genero,naturaleza,grupo::integer,tipo_clave::integer,
				folio_operacion,numero_partida,'1', monto::numeric,iva::numeric,factura, vence::date, num_docto::numeric
				, clave_prov_oper, clave_prov_pago, cta_dep/*Added by JMM 20240327*/ , ref_compl/*Added by JMM 20240805*/);
		end if;	
	
	end loop ;	
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_doc_sec() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
