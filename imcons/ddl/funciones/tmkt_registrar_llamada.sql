CREATE OR REPLACE FUNCTION keplersc.tmkt_registrar_llamada(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

declare


	sucursal_id text;
	folio_contacto_nvo text;
	
	usuario text;
	serie text;
	cliente text;
	nombre_cli text;

	get_resultado text;
	get_mensaje text; 
	get_adicionales text;


begin
	
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	usuario := (xpath('//document/usuario/text()', dataxml))[1];
	serie := (xpath('//document/serie/text()', dataxml))[1];
	cliente := (xpath('//document/cliente/text()', dataxml))[1];
	nombre_cli := (xpath('//document/nombre_cli/text()', dataxml))[1];
	
	select * into get_resultado, get_mensaje, get_adicionales
	from keplersc.obtener_folio_documento(concat('TMKT.', sucursal_id),0,0, concat('<k_sucn>', sucursal_id ,'</k_sucn>')::xml);
		
	if get_resultado = '0' then
		raise exception '%',get_mensaje;
	end if;
	folio_contacto_nvo := get_mensaje; 

	insert into keplersc.kdtmktser2(c1,c2,c3,c5,c6,c7,c14,c18,c19,c20, c21, c23,c24, c25, c27) 
	values(sucursal_id,folio_contacto_nvo,usuario,current_date, 10, 50, serie, 0, 'R', cliente, nombre_cli,0, current_date, 'M', usuario);
			
	resultado := 1;
	mensaje := concat('Contacto ', folio_contacto_nvo,' registrado.');
	adicionales := folio_contacto_nvo;
	return query select resultado, mensaje, adicionales;	


exception
		when others then
			resultado := 0;
			mensaje := 'tmkt_registrar_llamada() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	

end;
$function$
