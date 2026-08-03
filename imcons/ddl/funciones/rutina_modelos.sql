CREATE OR REPLACE FUNCTION keplersc.rutina_modelos(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Rutina Modelos
--Autor: Luis Leal
--Fecha: 02/02/2023
--Bitacora de cambios
declare
	sucursal_id text;
	marca_origen text;
	modelo_origen text;
	marca_destino text;
	modelo_destino text;

	--loops
	paquete text;
	ctd_paq int;
	clave_tab text;
	ctd_tab int;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	
	sucursal_id:=coalesce((xpath('//document/k_sucN/r1/text()', dataxml))[1],'');
	marca_origen:=coalesce((xpath('//document/marca_origen/text()', dataxml))[1],'');
	modelo_origen:=coalesce((xpath('//document/modelo_origen/text()', dataxml))[1],'');
	marca_destino:=coalesce((xpath('//document/marca_destino/text()', dataxml))[1],'');
	modelo_destino:=coalesce((xpath('//document/modelo_destino/text()', dataxml))[1],'');


	for paquete in select paq.c4 from keplersc.kdspaq as paq 
	inner join keplersc.kdcatpaq as cat on paq.c4=cat.c1
	where paq.c1=marca_origen and paq.c2=modelo_origen
	loop 
		
		select count(*) into ctd_paq from keplersc.kdspaq where c1=marca_destino and c2=modelo_destino and c4=paquete;
		if ctd_paq = 0 then
				
			update keplersc.kdspaqm set c1=marca_destino, c2=modelo_destino 
			where c1=marca_origen and c2=modelo_origen and c4=paquete;
		
			update keplersc.kdspaq set c1=marca_destino, c2=modelo_destino 
			where c1=marca_origen and c2=modelo_origen and c4=paquete;
		
		else
		
			delete from keplersc.kdspaqm where c1=marca_origen and c2=modelo_origen and c4=paquete;
			delete from keplersc.kdspaq where c1=marca_origen and c2=modelo_origen and c4=paquete;
		
		end if;
		
	end loop;


	update keplersc.kdserie set c2=marca_destino, c3=modelo_destino where c2=marca_origen and c3=modelo_origen;

	update keplersc.kdctasser set c7=marca_destino, c8=modelo_destino where c1=sucursal_id and c7=marca_origen and c8=modelo_origen;

	update keplersc.kdvntall set c15=marca_destino, c16=modelo_destino where c1=sucursal_id and c15=marca_origen and c16=modelo_origen;

	for clave_tab in select c3 from keplersc.kdtab where c1=marca_origen and c2=modelo_origen
	loop 
		
		select count(*) into ctd_tab from keplersc.kdtab where c1=marca_destino and c2=modelo_destino and c3=clave_tab;
		if ctd_tab = 0 then
			update keplersc.kdtab set c1=marca_destino, c2=modelo_destino where c1=marca_origen and c2=modelo_origen and c3=clave_tab;
		else
			delete from keplersc.kdtab where c1=marca_origen and c2=modelo_origen and c3=clave_tab;
		end if;
		
	end loop;
	
	delete from keplersc.kdmodelos where c1=marca_origen and c2=modelo_origen;
	

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'rutina_modelos() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
