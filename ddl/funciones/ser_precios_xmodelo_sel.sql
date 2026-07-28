CREATE OR REPLACE FUNCTION keplersc.ser_precios_xmodelo_sel(dataxml xml)
 RETURNS TABLE(detpartidas xml)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Obtiene detalle de los los paquetes KDSPAQ por modelo
--Autor: Miriam Santana
--Fecha: 02/Feb/23
--Bitacora de cambios

	--Variables de definicion de documento
	marca_id text;
	modelo_id text;
	
	--Variables de uso general 
	expSql text = '';

	--Variables de retorno
	xmlDetalle xml;

begin	
	marca_id := (xpath('//document/k_marca/text()', dataxml))[1];
	modelo_id := (xpath('//document/k_modelo/text()',dataxml))[1];
	
	drop table if exists tmpResultados;
	create temp table tmpResultados (
		detalle xml);

	expSql= format('select paq.c4 as k_clave,paq.c5 as k_descripcion,paq.c8 as k_varios,paq.c9 as k_horas,paq.c10 as k_precio  
				from keplersc.kdspaq paq
				where paq.c1=%1$L and paq.c2=%2$L', marca_id,modelo_id);
		
	
	--raise notice '%', expSql;
	select query_to_xml(expSql,false,true,'') into xmlDetalle;
	--raise notice '%', xmlDetalle;
	insert into tmpResultados(detalle) values(xmlDetalle);

	return query select * from tmpResultados;

end;
$function$
