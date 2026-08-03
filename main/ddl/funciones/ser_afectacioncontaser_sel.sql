CREATE OR REPLACE FUNCTION keplersc.ser_afectacioncontaser_sel(dataxml xml)
 RETURNS TABLE(detpartidas xml)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Obtiene detalle de las cuentas contables de servicio
--Autor: Miriam Santana
--Fecha: 05/Feb/23
--Bitacora de cambios

	--Variables de definicion de documento
	sucursal_id text;
	anio text;
	
	--Variables de uso general 
	expSql text = '';
	esNumero bool;	

	--Variables de retorno
	xmlDetalle xml;

begin	
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	anio := (xpath('//document/k_anio/text()',dataxml))[1];
	
	if anio is null then
		raise exception 'Falta especificar el año';
	else
		select anio ~ '^[0-9\.]+$' into esNumero; 
		if not esNumero then
			raise exception 'El año debe ser un número';
		end if;
	end if;
	drop table if exists tmpResultados;
	create temp table tmpResultados (
		detalle xml);

	expSql= format('select tall.c1 as k_tipo,cat.c2 as k_descripcion,tall.c5 as k_vtasmo,tall.c6 as k_vtasrefacc,tall.c7 as k_vtastots,
				tall.c8 as k_vtasvarios,tall.c10 as k_costomo,tall.c11 as k_costorefacc,tall.c12 as k_costotots,tall.c13 as k_costovarios,
				tall.c15 as k_ptemo,tall.c16 as k_invrefacc,tall.c17 as k_ptetots,tall.c18 as k_ptevarios
				from keplersc.kdtallcont tall
				left join keplersc.catpuntos cat on cat.c1=tall.c1
				where tall.c2=%1$L and tall.c3=%2$L order by tall.c1', sucursal_id,anio);
		
	
	--raise notice '%', expSql;
	select query_to_xml(expSql,false,true,'') into xmlDetalle;
	--raise notice '%', xmlDetalle;
	insert into tmpResultados(detalle) values(xmlDetalle);

	return query select * from tmpResultados;

end;
$function$
