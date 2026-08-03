CREATE OR REPLACE FUNCTION keplersc.cfd_regenera_folio(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Regenera un xml de CFDI para un folio con la funcion CFD_CREA_ARCHIVO
--Autor: Miriam Santana
--Fecha: 29/12/2022
--Bitacora de cambios
--29/09/2025 Miriam Santana: Enviar datos necesarios para la aplicacion de anticipos y anulacion de cobros a la funcion de creacion de cfdi cfd_crea_archivo
	--Variables para xml 
	sucursal_id text;
	genero text='';
	naturaleza text='';
	grupo text='';
	tipo text='';
	folio_operacion text='';
	usuario text;
	uen text='';
	cve_cteprov text='';
	forma_pago text ='';
	cuenta text ='';
	metodo_pago text ='';
	uso_cfdi text ='';
	rfc text ='';
	regfiscal text ='';
	valida_cuenta text ='';
	expSql text;
	strValor text;
	xmlPartidas text;
	xmlKDMM xml;
	xmlKDM1 xml;
	folioxml xml;
	datcfdi text='';

	--MSS 29092025 Aplicacion de anticipos
	flag_cobros text = '';
	naturaleza_docto text = '';
	grupo_docto text = '0';
	tipo_docto text = '0';
	folio_docto text = '';
	importe decimal = 0.0;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	--Tipo de documento
	sucursal_id := (xpath('//document/k_sucn/r1/text()',dataxml))[1];
	genero := (xpath('//document/k_gen/text()',dataxml))[1];
	naturaleza := (xpath('//document/k_nat/text()',dataxml))[1];
	grupo := (xpath('//document/k_gpo/text()',dataxml))[1];
	tipo := (xpath('//document/k_tpo/text()',dataxml))[1];
	folio_operacion := (xpath('//document/k_folio/text()',dataxml))[1];
	cve_cteprov := (xpath('//document/k_clave/text()',dataxml))[1];
	forma_pago := (xpath('//document/k_f_pago/r1/text()',dataxml))[1];
	cuenta := (xpath('//document/k_cuenta/text()',dataxml))[1];
	metodo_pago := (xpath('//document/k_m_pago/text()',dataxml))[1];
	uso_cfdi := (xpath('//document/k_cfdi/r1/text()',dataxml))[1];
	regfiscal := (xpath('//document/k_regfiscal/r1/text()',dataxml))[1];
	rfc := (xpath('//document/k_rfc/text()',dataxml))[1];
	usuario := (xpath('//document/movimiento/usuario/text()', dataxml))[1];
	strValor := substring(folio_operacion, 1,1);
	datcfdi := (xpath('//document/datcfdi/text()',dataxml))[1];

	--MSS 29092025 Aplicacion de anticipos
	flag_cobros :=coalesce((xpath('//document/ambiente/flag_cobros/text()',dataxml))[1]::text,'')::text;
	naturaleza_docto := coalesce((xpath('//document/k_natdocto/text()',dataxml))[1]::text,'')::text;
	grupo_docto := coalesce((xpath('//document/k_gpodocto/text()',dataxml))[1]::text,'0')::text;
	tipo_docto := coalesce((xpath('//document/k_tipodocto/text()',dataxml))[1]::text,'0')::text;
	folio_docto := coalesce((xpath('//document/k_foliodocto/text()',dataxml))[1]::text,'')::text;
	importe :=  coalesce((xpath('//document/k_monto/text()',dataxml))[1]::text,'0')::text;

	--raise notice 'suc:% g:% n:% g:% t:% folio:% uen:%',sucursal_id,genero,naturaleza,grupo,tipo,folio_operacion,uen;
	if strValor = 'X' then 
		uen := 'XXX';
		elseif strValor = 'S' then 
			uen := 'SER';
		elseif strValor = 'R' then 
			uen := 'REF';
		elseif strValor = 'V' then 
			uen := 'VEN';
	end if;
	--raise notice 'suc:% g:% n:% g:% t:% folio:% uen:%',sucursal_id,genero,naturaleza,grupo,tipo,folio_operacion,uen;
	--Validacion de la cuenta
	select * into valida_cuenta from keplersc.cfd_valid_cuenta(dataxml);

	if rfc is null or rfc ='' then
		raise exception 'El RFC no puede estar en blanco';
	end if;
	if metodo_pago is null or metodo_pago ='' then
		raise exception 'El Metodo de Pago es invalido';
	end if;
	if uso_cfdi is null or uso_cfdi ='' then
		raise exception 'El Uso del CFDI es invalido';
	end if;
	if regfiscal is null or regfiscal ='' then
		raise exception 'El Regimen Fiscal es invalido';
	end if;
/* Con la pantalla de validacion cfdi ya no se actualiza
	--Actualizar los datos del cfdi en Kdm1
	update keplersc.kdm1 set
		c160 = forma_pago,
		c161 = cuenta,
		c162 = metodo_pago,
		c164 = uso_cfdi,
		c166 = regfiscal,
		c22 = rfc
	where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion;

	--Actualizar los datos del regimen fiscal para el cliente en Kdud
	update keplersc.kdud set
		c54 = regfiscal
	where c2=cve_cteprov;
*/
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
		
	xmlPartidas := format('<document>
								<k_sucn><r1>%1$s</r1></k_sucn>
								<k_tipon><r1>%2$s</r1></k_tipon>
								<k_tipon><r2>%3$s</r2></k_tipon>
								<k_tipon><r3>%4$s</r3></k_tipon>
								<k_tipon><r4>%5$s</r4></k_tipon>
								<k_clave>%8$s</k_clave>
								<datcfdi>%9$s</datcfdi>
								<k_monto>%11$s</k_monto>
								<k_natdocto>%12$s</k_natdocto>
								<k_gpodocto>%13$s</k_gpodocto>
								<k_tipodocto>%14$s</k_tipodocto>
								<k_foliodocto>%15$s</k_foliodocto>
								<movimiento><usuario>%6$s</usuario></movimiento>
								<ambiente><uen>%7$s</uen><flag_cobros>%10$s</flag_cobros>
								</ambiente>
							</document>',
					       	sucursal_id,genero,naturaleza,grupo,tipo,usuario,uen,cve_cteprov,datcfdi,flag_cobros,importe,naturaleza_docto,grupo_docto,tipo_docto,folio_docto);
								         
	folioxml := xmlPartidas::xml; 

	--Se llama la funcion para generar xml del cfdi
	select * into resultado, mensaje, adicionales from keplersc.cfd_crea_archivo(folioxml,xmlKDM1,xmlKDMM,folio_operacion);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;	

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cfd_regenera_folio() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
