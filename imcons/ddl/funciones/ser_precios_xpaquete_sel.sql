CREATE OR REPLACE FUNCTION keplersc.ser_precios_xpaquete_sel(dataxml xml)
 RETURNS TABLE(detpartidas xml)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Obtiene detalle de los los paquetes KDSPAQ por paquete
--Autor: Miriam Santana
--Fecha: 02/Feb/23
--Bitacora de cambios

	--Variables de definicion de documento
	paquete_id text;
	
	--Variables de uso general 
	expSql text = '';

	--Variables de retorno
	xmlDetalle xml;

begin	
	paquete_id := (xpath('//document/k_paquete/text()', dataxml))[1];
	
	drop table if exists tmpResultados;
	create temp table tmpResultados (
		detalle xml);

	expSql= format('select paq.c1 as k_marca,paq.c2 as k_modelo,paq.c8 as k_varios,paq.c9 as k_horas,paq.c10 as k_precio  
				from keplersc.kdspaq paq 
				where paq.c4=%1$L', paquete_id);
		
	select query_to_xml(expSql,false,true,'') into xmlDetalle;
	raise notice '%', xmlDetalle;
	insert into tmpResultados(detalle) values(xmlDetalle);

	return query select * from tmpResultados;

end;
$function$
