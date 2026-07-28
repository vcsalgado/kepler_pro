CREATE OR REPLACE FUNCTION keplersc.ser_factura_orden_rep(dataxml xml)
 RETURNS TABLE(encabezado xml)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Obtiene en formato XML del encabezado con los datos requeridos para el reporte de factura orden
--Autor: Miriam Santana
--Fecha: 25/Oct/22
--Bitacora de cambios

	--Variables de definicion de documento
	sucursal_id text = '';
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	folio text;

	--Variables de uso general 
	expSql text = '';
	strValor text = '||';
	espacio text = ' ';

	--Variables de retorno
	xmlEncabezado xml;

begin	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	genero := (xpath('//document/genero/text()', dataxml))[1];
	naturaleza := (xpath('//document/naturaleza/text()', dataxml))[1];
	grupo := (xpath('//document/grupo/text()', dataxml))[1];
	tipo := (xpath('//document/tipo/text()', dataxml))[1];
	folio := (xpath('//document/folio/text()', dataxml))[1];

	drop table if exists tmpResultados;
	create temp table tmpResultados (
		encabezado xml);

expSql= format('
		select dm1.c9 as fecha,dm1.c69 as hora,dm1.c22 as rfc,dm1.c32 as nombre,dm1.c33 as calle,dm1.c121%7$s%8$L%7$sdm1.c122 as orden,dm1.c6 as folio,
		dm1.c16 as importe_total,dm1.c160 as forma_pago,dm1.c67 as cajera,ser.c4 as vin
		from keplersc.kdm1 dm1
		inner join keplersc.kdord ord on ord.c1 = dm1.c1 and ord.c2=dm1.c121 and ord.c3=dm1.c122
		inner join keplersc.kdserie ser on ser.c1 = ord.c6
		where dm1.c1= %1$L and dm1.c2=%2$L and dm1.c3=%3$L and dm1.c4=%4$s and dm1.c5=%5$s and dm1.c6=%6$L'
		,sucursal_id,genero,naturaleza,grupo,tipo,folio,strValor,espacio);	

select query_to_xml(expSql,false,true,'') into xmlEncabezado;

insert into tmpResultados(encabezado) 
	values(xmlEncabezado);

return query select * from tmpResultados;

END;
$function$
