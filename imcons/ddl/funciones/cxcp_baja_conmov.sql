CREATE OR REPLACE FUNCTION keplersc.cxcp_baja_conmov(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: cxcp_baja_conmov
--Autor: Luis Leal
--Fecha: 22/10/2022
declare
	--Variables de definicion de documento
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_clave text;
	referencia text;
	documento int;
	clave_cteprov text;
	monto_iva decimal;
	monto_total decimal;
	fecha_operacion text;
	xml_kduxg_baja xml ;

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

	for referencia,monto_total,monto_iva in select c3,c13,c14 from keplersc.kduxe	
	where c1=sucursal_id and c2=clave_cteprov and c5=genero and c6=naturaleza 
	and c7=grupo::integer  and c8=tipo_clave::integer and c9=folio_operacion 	
		loop 
		
			xml_kduxg_baja := format('	
			<document>
				<k_sucn><r1>%1$s</r1></k_sucn>
				<k_tipon><r1>%2$s</r1><r2>%3$s</r2></k_tipon>
				<k_clave>%4$s</k_clave>
				<k_refer>%5$s</k_refer>
				<k_fecha>%6$s</k_fecha>
				<k_iva>%7$s</k_iva>
				<k_monto>%8$s</k_monto>
				<k_documento>%9$s</k_documento>
			</document>
			', sucursal_id,genero,naturaleza, clave_cteprov, referencia,
			fecha_operacion, monto_iva, monto_total, documento);
			
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_conmov_kduxg(xml_kduxg_baja, 'Baja');
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;	
		
		end loop;
	
	update  keplersc.kduxe set c17='C' where c1=sucursal_id and c2=clave_cteprov 
	and c5=genero and c6=naturaleza and c7=grupo::integer  and c8=tipo_clave::integer
	and c9=folio_operacion;	
					

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cxcp_baja_conmov() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
