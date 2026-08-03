CREATE OR REPLACE FUNCTION keplersc.ser_cargos_varios_sel(dataxml xml)
 RETURNS TABLE(encabezado xml, detpartidas xml)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Obtiene en formato XML el encabezado y detalle de los movimientos de Cargos Varios
--Autor: Miriam Santana
--Fecha: 30/Ago/22
--Bitacora de cambios

	--Variables de definicion de documento
	sucursal_id text;
	tipo_orden text;
	num_orden text;
	punto text;
	tipo_punto text;

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	xmlReqDoctos text = '';
	expSql text = '';

	--Variables de retorno
	xmlEncabezado xml;
	xmlDetalle xml;

begin	
	sucursal_id := (xpath('//document/k_sucursal/text()', dataxml))[1];
	tipo_orden := (xpath('//document/k_tipo/text()',dataxml))[1];
	num_orden := (xpath('//document/k_folio/text()',dataxml))[1];
	punto := (xpath('//document/k_punto/text()',dataxml))[1];

	drop table if exists tmpResultados;
	create temp table tmpResultados (
		encabezado xml,
		detalle xml);

	expSql= format('select ms.c1 as k_sucursal, ms.c2 as k_sucnombre, ord.c4 as fecha,
				ord.c2 as k_tipo_orden, ord.c3 as k_num_orden, pun.c4 as k_punto, ord.c11 as k_nombre, ord.c12 as k_direccion, ord.c13 as k_colonia, ord.c18 as k_cp,
				ord.c6 as k_serie, ser.c2 as k_marca, ser.c3 as k_modelo, ser.c11 as k_anio
				from keplersc.kdord ord 
				inner join  keplersc.kdms ms on ms.c1 = ord.c1
				left outer join keplersc.kdserie ser on ser.c1 = ord.c6
				left outer join keplersc.kdpun pun on pun.c1=ord.c1  and pun.c2=ord.c2 and pun.c3 =ord.c3 and pun.c4 =%4$s
				where ord.c1= %1$L and ord.c2=%2$L and ord.c3=%3$L',sucursal_id,tipo_orden,num_orden, punto);
	
	raise notice '%', expSql;
	select query_to_xml(expSql,false,true,'') into xmlEncabezado;
	raise notice '%', xmlEncabezado;

	select pun.c6 into tipo_punto from keplersc.kdpun pun
		where c1= sucursal_id and c2= tipo_orden and c3 = num_orden and c4 = punto::integer; 
	raise notice '%', 'tipo_punto:' ||tipo_punto ;	
	
	if tipo_punto ='S' then
		expSql= format('select paq.c4 as k_cve_cargo,paq.c5 as k_descripcion,paq.c8 as k_importe 
				from keplersc.kdspaq paq
				left outer join (select ord.c6 as k_serie, ser.c2 as k_marca, ser.c3 as k_modelo from keplersc.kdord ord  
				left outer join keplersc.kdserie ser on ser.c1 = ord.c6
				where ord.c1=%1$L  and ord.c2=%2$L and ord.c3=%3$L) 
				auto on paq.c1= auto.k_marca and paq.c2= auto.k_modelo
				left outer join (select pun.c5 from keplersc.kdpun pun
				where c1=%1$L  and c2=%2$L and c3 =%3$L and c4 =%4$s) kit on paq.c4= kit.c5									
				where paq.c1=auto.k_marca and paq.c2=auto.k_modelo and paq.c4= kit.c5', sucursal_id,tipo_orden,num_orden,punto);
		
	else
		expSql= format('select car.c6 as k_cve_cargo, car.c7 as k_descripcion,car.c10 as k_importe 
				from keplersc.kdpun pun
				left outer join keplersc.kdcar car on pun.c1=car.c1 and pun.c2=car.c2 and pun.c3=car.c3 and pun.c4=car.c4
				where pun.c1= %1$L and pun.c2= %2$L and pun.c3 = %3$L and pun.c4 = %4$s',sucursal_id,tipo_orden,num_orden,punto);
	end if;

	raise notice '%', expSql;
	select query_to_xml(expSql,false,true,'') into xmlDetalle;
	raise notice '%', xmlDetalle;
	insert into tmpResultados(encabezado,detalle) values(xmlEncabezado,xmlDetalle);

	return query select * from tmpResultados;

end;
$function$
