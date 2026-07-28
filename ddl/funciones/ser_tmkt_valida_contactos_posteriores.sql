CREATE OR REPLACE FUNCTION keplersc.ser_tmkt_valida_contactos_posteriores(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Valida si existen contactos posteriores y regresa la fecha del siguiente contacto
--Autor: Miriam Santana
--Fecha: 2/11/2023
--Bitacora de cambios

declare
	--Variables de definicion de documento
	sucursal_id text = '';
	folio_tmkt text = '';
	serie text = '';
	fecha text = '';
	accion text = '';
	asesor_tmkt text = '';
	_crear_contacto text = '';

	--Variables de uso general
	sig_contacto date;
	contactos int = 0;

begin
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	folio_tmkt := (xpath('//document/folio/text()',dataxml))[1];
	serie := (xpath('//document/serie/text()',dataxml))[1];
	asesor_tmkt := (xpath('//document/asesor/text()',dataxml))[1];
	fecha := (xpath('//document/fecha/text()',dataxml))[1];
	accion := (xpath('//document/accion/text()',dataxml))[1];

	--Obtener si accion implica nuevo registro de contacto
	select crear_contacto into _crear_contacto 
		from keplersc.kdtmktaccion where accion_id = accion::integer;
	mensaje :='';
	if _crear_contacto ='S' then
		--Contactos posteriores y quiere recontactar
		select count(*) into contactos from keplersc.kdtmktser2
		where c1=sucursal_id and c14=serie and c2<>folio_tmkt and c8=0/*pendiente*/ and c23=0/*en pantalla*/ 
		and c5 > fecha::date/*mayor a la fecha del contacto actual*/ and c3=asesor_tmkt;
		if contactos > 0 then
			select c5 into sig_contacto from keplersc.kdtmktser2 k 
				where c1=sucursal_id and c14=serie and c2 <>folio_tmkt and c8=0/*pendiente*/ and c23=0/*en pantalla*/ 
				and c5 > fecha::date and c3=asesor_tmkt
				order by c5 limit 1;
				mensaje := sig_contacto::text;
								
				
		end if;
	end if;

	resultado := '1';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := '0';
		mensaje := 'ser_tmkt_valida_contactos_posteriores() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
		
end;
$function$
