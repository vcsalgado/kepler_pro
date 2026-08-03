CREATE OR REPLACE FUNCTION keplersc.pedidosespserie(dataxml xml)
 RETURNS TABLE(pedidos xml)
 LANGUAGE plpgsql
AS $function$
--Descripcion: selecciona informacion de cliente
--Autor: Luis Leal
--Fecha: 28/04/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	vin text;
	sql_pedidos text = '';
	
begin
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	vin := (xpath('//document/vin/text()', dataxml))[1];

	sql_pedidos := format('select ped.c4 as vin,ped.c2 as pedido,ped.c3::date as solicitud 
	,mov.c7::date as eta, case when mov.c8=10 then ''Si'' else ''No'' end as surtido, 
	mov.c9::date as fecha, ped.c11 as tipo_orden,ped.c12 as orden, ped.c10 as anticipo, 
	mov.c4 as pieza,ini.c2 as desc, mov.c5 as cantidad from keplersc.kdserped as ped 
	inner join keplersc.kdserpedmov as mov on mov.c1=ped.c1  
	and mov.c2= ped.c2 inner join keplersc.kdini as ini on ini.c1=mov.c4
	where ped.c1=%1$L and ped.c14=%2$s', sucursal_id, 0 );

	if vin is not null then 
		sql_pedidos = concat(sql_pedidos, format(' and right(ped.c4,8)=%1$L',vin ));
	end if;
	
	select query_to_xml(sql_pedidos, false, true, '' ) :: xml into pedidos;
	

	return query
	select pedidos;
	
exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
