CREATE OR REPLACE FUNCTION keplersc.ser_tmkt_ins(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	serie text = '';
	asesor text = '';
	motivo text = '';
	observaciones text = '';
	tipo_servicio text = '';
	cliente text='';
	tipo_trabajo text ='';
	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	nuevo_folio text = '';


	--Variables de retorno de folio
	get_resultado text;
	get_mensaje text; 
	get_adicionales text;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	serie := (xpath('//document/serie/text()', dataxml))[1];
	asesor := (xpath('//document/asesor/text()', dataxml))[1];
	motivo := (xpath('//document/motivo/text()', dataxml))[1];
	observaciones := (xpath('//document/observaciones/text()', dataxml))[1];
	tipo_servicio := (xpath('//document/tipo_servicio/text()', dataxml))[1];
	cliente:=(xpath('//document/cliente_id/text()', dataxml))[1];
	tipo_trabajo:=(xpath('//document/tipo_trabajo/text()', dataxml))[1];

	select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('TMKT.', sucursal_id),0,0, dataxml);
	if get_resultado = '0' then
		raise exception '%',get_mensaje;
	end if;
	nuevo_folio := get_mensaje; 

	insert into keplersc.kdtmktser2(c1,c2,c3,c5,c6,
	c7,c14,c18,c19,c20) 
	values(sucursal_id,nuevo_folio,asesor,current_date,10,
	motivo::numeric,serie,tipo_servicio::numeric,tipo_trabajo,cliente);
	
	resultado := 1;
	mensaje := nuevo_folio;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_tmkt_ins() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
