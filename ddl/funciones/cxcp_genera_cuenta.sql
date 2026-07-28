CREATE OR REPLACE FUNCTION keplersc.cxcp_genera_cuenta(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Genera cuenta por cobrar o pagar de movimientos que al darse de alta no se genero
--Autor: Miriam Santana
--Fecha: 15/12/2025
--Bitacora de cambios
declare

	--Variables de definicion de documento
	sucursal_id text;
	sucursal text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	referencia text;
	cve_cteprov text;
	monto_iva text;
	monto_total text;
	fecha_operacion text;
	folio_operacion text;
	plazo_vencimiento text;
	nat_docto_anx text;
	gpo_docto_anx text;
	tipo_docto_anx text;
	folio_docto_anx text;	
	anticipos decimal = 0;
	conf_iva decimal;
	ivaValor decimal =0;
	factura_xe text;
	clave_provpago text = '';
	selreg text ='';
	usuario text;
	factura_ini text;
	flag_factura_sust text ='';
	flag_gastos text = '';
	uen text;
	tipo_relacion text;
	motivo_cancelacion text;
	esquema text ='';

	cve_prov_pago text;
	cr_type int;
	st_x_comprobar text;	
	doc_refer_compl text;
	gen_aux text;
	nat_aux text;
	gpo_aux text;
	tip_aux text;
	folio_aux text;
	
	--Variables complemento de impuestos
	isrret_uuid text = '';
	ivaret_uuid text = '';
	iepstras_uuid text = '';
	totalimptoret_uuid text ='';
	totalimptotras_uuid text ='';
	subtotal_uuid text = '';
	otroimptoa_uuid text = '';
	otroimptob_uuid text = '';

	--variables de uso general
	strValor text;
	intValor int;
	totalReg int;
	expSql text;
	no_partidas int=0;
	numero_partida int=0;
	xmlPartidas text;
	xmlKDMM xml;
	xmlKDM1 xml;
	xmlKDUXE xml;
	folioxml xml;
	cxcpren int = 0;

	rec record;
	varXml xml;
	strbitacora text = '';
	suc_xe text;
	gen_xe text;
	cteprov_xe text;
	ref_xe text;
	str_diferencia int = 0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	strerrores_gen text = '';

begin
	usuario := (xpath('//document/movimiento/usuario/text()', dataxml))[1];
	sucursal := (xpath('//document/cmb_sucursal/r1/text()',dataxml))[1];
	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	
	--Procesar detalle
--raise notice 'Entro a genera cxcp';	
	for cont in 0..no_partidas - 1 loop
		selreg := (xpath('//document/k_mov/r' ||cont||'/sel_reg/text()',dataxml))[1];
		--Tipo de documento
		sucursal_id := (xpath('//document/k_mov/r' ||cont||'/k_sucn/text()',dataxml))[1];
		genero := (xpath('//document/k_mov/r' ||cont||'/genero/text()',dataxml))[1];
		naturaleza := (xpath('//document/k_mov/r' ||cont||'/naturaleza/text()',dataxml))[1];
		grupo := (xpath('//document/k_mov/r' ||cont||'/grupo/text()',dataxml))[1];
		tipo := (xpath('//document/k_mov/r' ||cont||'/tipo/text()',dataxml))[1];
		folio_operacion := (xpath('//document/k_mov/r' ||cont||'/folio/text()',dataxml))[1];
		if selreg = 'S' then
			uen:='';

--raise notice 'sel:% suc:% g:% n:% g:% t:% folio:% uen:%',selreg,sucursal_id,genero,naturaleza,grupo,tipo,folio_operacion,uen;
			--Obtener xml de KDM1 de registro generado 		
			expSql = 'select * from keplersc.kdm1 where' || 
					' c1=' || E'\'' || sucursal_id || E'\'' ||  
					' and c2=' || E'\'' || genero || E'\'' ||
					' and c3=' || E'\'' || naturaleza || E'\'' || 
					' and c4=' || grupo || 
					' and c5=' || tipo ||
				  	' and c6=' || E'\'' || folio_operacion || E'\'';
			select query_to_xml(expSql, true, false, '') into xmlKDM1;
			
			--Obtener xml de KDMM de documento 		
			expSql = 'select * from keplersc.kdmm where col_sucursal=' || E'\'' || sucursal_id || E'\'' || ' and c1='  || E'\'' || genero || E'\'' ||														
					' and c2=' || E'\'' || naturaleza || E'\'' || ' and c3=' || grupo || ' and c4=' || tipo;	
			select query_to_xml(expSql, true, false, '') into xmlKDMM;
			
			cve_cteprov := (xpath('//row/c10/text()', xmlKDM1))[1]::text;
			referencia := (xpath('//row/c11/text()', xmlKDM1))[1]::text; --Factura para 'X'
			monto_iva := (xpath('//row/c14/text()', xmlKDM1))[1]::text;	
			monto_total := (xpath('//row/c16/text()', xmlKDM1))[1]::text;
			fecha_operacion := (xpath('//row/c9/text()', xmlKDM1))[1]::text;
			plazo_vencimiento := (xpath('//row/c18/text()', xmlKDM1))[1]::text;
			anticipos := (xpath('//document/k_montoanticipo/text()',dataxml))[1];			
			nat_docto_anx := (xpath('//row/c36/text()', xmlKDM1))[1]::text;
			gpo_docto_anx := (xpath('//row/c37/text()', xmlKDM1))[1]::text;
			tipo_docto_anx := (xpath('//row/c38/text()', xmlKDM1))[1]::text;
			folio_docto_anx := (xpath('//row/c39/text()', xmlKDM1))[1]::text;
			
			--Buscar la factura inicial
			if concat(genero,naturaleza,grupo) = 'UD63' or concat(genero,naturaleza,grupo) = 'UD19' or concat(genero,naturaleza,grupo) = 'UD81' then
				select * into rec from keplersc.kdm1 where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo and c5=tipo and c6=folio_operacion;		--Obtener el documento por anexar
				
				select c39 into factura_ini from keplersc.kdm1 where c1=sucursal_id and c2=rec.c2 and c3=rec.c36 and c4=rec.c37 and c5=rec.c38 and c6=rec.c39;	--Obtener el docto por anexar del documento original=factura original
			end if;
	
			tipo_relacion := (xpath('//document/tipo_relacion/text()',xmlKDM1))[1];
			motivo_cancelacion := (xpath('//document/motivo_cancelacion/text()',xmlKDM1))[1];
		
			isrret_uuid := coalesce((xpath('//row/uuid_retisr/text()', xmlKDM1))[1]::text,'0')::text;
			ivaret_uuid := coalesce((xpath('//row/uuid_retiva/text()', xmlKDM1))[1]::text,'0')::text;
			iepstras_uuid := coalesce((xpath('//row/uuid_trasieps/text()', xmlKDM1))[1]::text,'0')::text;
			totalimptoret_uuid := coalesce((xpath('//row/uuid_totalimptoret/text()', xmlKDM1))[1]::text,'0')::text;
			totalimptotras_uuid := coalesce((xpath('//row/uuid_totalimptotras/text()', xmlKDM1))[1]::text,'0')::text;
			subtotal_uuid := coalesce((xpath('//row/uuid_subtotal/text()', xmlKDM1))[1]::text,'0')::text;
			otroimptoa_uuid := coalesce((xpath('//row/uuid_otroimptoa/text()', xmlKDM1))[1]::text,'0')::text;
			otroimptob_uuid := coalesce((xpath('//row/uuid_otroimptob/text()', xmlKDM1))[1]::text,'0')::text;
		
			clave_provpago := coalesce((xpath('//row/cve_prov_pago/text()', xmlKDM1))[1]::text,'')::text;
			doc_refer_compl := coalesce((xpath('//row/doc_refer_compl/text()', xmlKDM1))[1]::text,'')::text;
			st_x_comprobar := coalesce((xpath('//row/st_x_comprobar/text()', xmlKDM1))[1]::text,'')::text;
			gen_aux := coalesce((xpath('//row/gen_aux/text()', xmlKDM1))[1]::text,'')::text;	
			nat_aux := coalesce((xpath('//row/nat_aux/text()', xmlKDM1))[1]::text,'')::text;
			gpo_aux := coalesce((xpath('//row/gpo_aux/text()', xmlKDM1))[1]::text,'')::text;
			tip_aux := coalesce((xpath('//row/tip_aux/text()', xmlKDM1))[1]::text,'')::text;
			folio_aux := coalesce((xpath('//row/folio_aux/text()', xmlKDM1))[1]::text,'')::text;
			
			esquema := (xpath('//document/esquema/text()',xmlKDM1))[1];
			if tipo_relacion = '04' then
				flag_factura_sust := 'FACTURA_X_SUST';
			end if;

			if esquema = 'CXP_CONTR_REC' or  esquema = 'CXP_CONTR_REC_DEVCLI' then
				flag_gastos := esquema;
			end if;		
	
			if st_x_comprobar = 'S' then
				cr_type := 1;
			end if;

			strValor := substring(folio_operacion, 1,1);
--raise notice 'sel:% suc:% g:% n:% g:% t:% folio:% uen:%',selreg,sucursal_id,genero,naturaleza,grupo,tipo,folio_operacion,uen;
			if strValor = 'X' then 
				uen := 'XXX';
				elseif strValor = 'S' then 
					uen := 'SER';
				elseif strValor = 'R' then 
					uen := 'REF';
				elseif strValor = 'V' then 
					uen := 'VEN';
			end if;
	
			xmlPartidas := format('<document>
										<k_sucn><r1>%1$s</r1></k_sucn>
										<k_tipon><r1>%2$s</r1></k_tipon>
										<k_tipon><r2>%3$s</r2></k_tipon>
										<k_tipon><r3>%4$s</r3></k_tipon>
										<k_tipon><r4>%5$s</r4></k_tipon>
										<k_clave>%6$s</k_clave>
										<k_refer>%7$s</k_refer>
										<k_iva>%8$s</k_iva>
										<k_monto>%9$s</k_monto>
										<k_fecha>%10$s</k_fecha>
										<k_vence>%11$s</k_vence>
										<k_montoanticipo>%12$s</k_montoanticipo>
										<k_natdocto>%13$s</k_natdocto>
										<k_gpodocto>%14$s</k_gpodocto>
										<k_tipodocto>%15$s</k_tipodocto>
										<k_foliodocto>%16$s</k_foliodocto>		
										<k_facturaini>%17$s</k_facturaini>
										<k_clave_pago>%18$s</k_clave_pago>
										<uuid>
										<retisr>%19$s</retisr>
										<retiva>%20$s</retiva>
										<iepstras>%21$s</iepstras>
										<totalimptoret>%22$s</totalimptoret>
										<totalimptotras>%23$s</totalimptotras>
										<subtotal>%24$s</subtotal>
										<otroimptoa>%25$s</otroimptoa>
										<otroimptob>%26$s</otroimptob>
										</uuid>
										<chk_pc>%27$s</chk_pc>
										<c_gen>%28$s</c_gen>
										<c_nat>%29$s</c_nat>
										<c_gpo>%30$s</c_gpo>
										<c_tip>%31$s</c_tip>
										<c_folio>%32$s</c_folio>
										<c_ref>%33$s</c_ref>										
										<movimiento><usuario>%34$s</usuario></movimiento>
										<ambiente>
										<schema>%35$s</schema>
										<flag_factura_sust>%36$s</flag_factura_sust>										
										</ambiente>
									</document>',
						         	sucursal_id,genero,naturaleza,grupo,tipo,
						         	cve_cteprov,referencia,monto_iva,monto_total,fecha_operacion,
						         	plazo_vencimiento,anticipos,nat_docto_anx,gpo_docto_anx,tipo_docto_anx,
						         	folio_docto_anx,factura_ini,clave_provpago,isrret_uuid,ivaret_uuid,
						         	iepstras_uuid,totalimptoret_uuid,totalimptotras_uuid,subtotal_uuid,otroimptoa_uuid,
						         	otroimptob_uuid,cr_type,gen_aux,nat_aux,gpo_aux,
						         	tip_aux,folio_aux,doc_refer_compl,usuario,flag_gastos,			         	
						         	flag_factura_sust);
							         
			folioxml := xmlPartidas::xml; 

--raise notice 'folioxml: %',folioxml;
			begin
				--Por cada registro se llama la funcion para generar la cuenta xcp
				select * into resultado, mensaje, adicionales from keplersc.cxcp_sinmov_kduxe_alta(folioxml, xmlKDMM, folio_operacion);
				if resultado = '0' then
					raise exception '%',mensaje;
					strerrores_gen := strerrores_gen || folio_operacion ||'-'|| mensaje || '~';
					continue;
				else
--raise notice 'KDUXExml: %',adicionales::xml;
					xmlKDUXE := adicionales::xml;
					select * into resultado, mensaje, adicionales from keplersc.cxcp_sinmov_kduxg_alta(folioxml, adicionales::xml, folio_operacion);
					if resultado = '0' then
						raise exception '%',mensaje;
						strerrores_gen := strerrores_gen || folio_operacion ||'-'|| mensaje || '~';
						continue;
					else 
--raise notice 'KDUXExml_2: %',xmlKDUXE::xml;
						suc_xe := (xpath('//row/c1/text()', xmlKDUXE))[1];
						gen_xe := (xpath('//row/c5/text()', xmlKDUXE))[1];
						cteprov_xe := (xpath('//row/c2/text()', xmlKDUXE))[1];
						ref_xe := (xpath('//row/c3/text()',xmlKDUXE))[1];
						select * into rec from keplersc.kduxg	
							where c1 = suc_xe and c2 = gen_xe and c3 = cteprov_xe and c4 = ref_xe and c5 = 1;
						if rec.c10 = 10 then
							if rec.c6 <> rec.c7 then 
								str_diferencia := 1;
							end if;
						end if;
--raise notice 'KDUXGxml: %',rec;
--raise notice 'str_diferencia:%',str_diferencia;
						cxcpren := cxcpren + 1;
						if str_diferencia = 1 then
							strerrores_gen := strerrores_gen || folio_operacion ||'-'|| 'CUENTA CxCP GENERADA' ||'-'|| 'CUENTA SALDADA C/DIFERENCIA EN CARGOS Y ABONOS' || '~';
						else
							strerrores_gen := strerrores_gen || folio_operacion ||'-'|| 'CUENTA CxCP GENERADA' || '~';
						end if;
						strbitacora := strbitacora || folio_operacion ||' | ';
						str_diferencia := 0;		--Se pone en 0 para que no considere que hay diferencia y guarde la misma cadena que cuando encontro una diferencia
					end if;	
				end if;	
			exception 
				when others then
					strerrores_gen := strerrores_gen || folio_operacion ||'-'|| mensaje || '~';
				
			end;	
				
		end if;
	end loop;

	--Registro en bitacora
	select xmlforest(usuario, current_date as fecha, TO_CHAR(NOW(), 'HH24:MI:SS') as hora, 
					sucursal, ' ' as genero, ' ' as naturaleza, 0 as grupo, 0 as tipo, 'GENCXCP' as folio,
					'GENERACION DE CXCP' as tipo_movto, strbitacora as detalle_movto) :: text into strValor;
					
	select '<document>'||strValor||'</document>' into strValor;
	varXml := strValor::xml;										
	select * into resultado, mensaje, adicionales from keplersc.usr_kdusraccess_alta(varXml);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;

	resultado := 1;
	mensaje := cxcpren;
	adicionales := strerrores_gen;
--raise notice 'strerrores_gen:%',strerrores_gen;

--raise notice 'mensaje:%',mensaje;
		return query select resultado, mensaje, adicionales;
	
--raise exception 'Alto manual para pruebas';

exception
	when others then
		resultado := 0;
		mensaje := 'cxcp_genera_cuenta() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
