CREATE OR REPLACE FUNCTION keplersc.ser_tmkt_actualizacontacto(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Actualiza el cliente en los contactos generados de una serie en KDTMKTSER2, cuando cambian el contacto en KDSERIE
--Autor: Miriam Santana
--Fecha: 30/10/2023
--Bitacora de cambios

declare
	--Variables de definicion de documento
	sucursal_id text;
	folio_tmkt text;
	serie text;
	cliente text;
	nombre_cliente text ='';
	
	--Variables de uso general
	cliente_ant text ='';
	cliente_nvo text ='';
	totReg int;

begin
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	folio_tmkt := (xpath('//document/folio_tmkt/text()',dataxml))[1];
	serie := (xpath('//document/serie/text()',dataxml))[1];
	cliente := (xpath('//document/cliente/text()',dataxml))[1];
	
	mensaje ='';
	select coalesce(c20,'') into cliente_ant
		from keplersc.kdtmktser2 
		where c1=sucursal_id and c2=folio_tmkt;

	if cliente_ant ='' then
		cliente_ant = cliente;
	end if;
	
	select ser.c9,ud.c3 into cliente_nvo,nombre_cliente
		from keplersc.kdserie ser
		inner join keplersc.kdud ud on ud.c2=ser.c9
		where ser.c1=serie;

	if cliente_ant <> cliente_nvo then
		--Actualiza contactos tmkt pendientes
		update keplersc.kdtmktser2 
			set c20=cliente_nvo,
			c21=nombre_cliente
		where c1=sucursal_id and c14=serie and c8=0;
		mensaje := 'Cambio propietario';
		--Actualiza cita pendiente
		update keplersc.kdctasser  
			set c4=cliente_nvo
		where c1=sucursal_id and c6=serie and c20=0;
	end if;

	resultado := 1;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_tmkt_actualizacontacto() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
		
end;
$function$
