CREATE OR REPLACE FUNCTION keplersc.rep_vencomis_mensdet_sel(dataxml xml)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
declare

	--Variables de definicion de documento
	sucursal text = '';
	vendedor text = '';
	anio text = '';
	mes text = '';

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	expSql text = '';

	--Variables de retorno
	xmlResultado xml;

begin
	
	sucursal := (xpath('//document/sucursal/text()', dataxml))[1];
	vendedor := (xpath('//document/vendedor/text()', dataxml))[1];
	anio := (xpath('//document/anio/text()', dataxml))[1];
	mes := (xpath('//document/mes/text()', dataxml))[1];

	sucursal := trim(sucursal);
	vendedor := trim(vendedor);
	anio := trim(anio);
	mes := trim(mes);


	/*
	raise notice '%', 'Entro al FUNC_Detail';
	raise notice 'suc:%',sucursal;
	raise notice 'vend:%',vendedor;
	raise notice 'anio:%',anio;
	raise notice 'mes:%',mes;
	*/

	-- Workflow ... 
	strValor := 'YYYY-MM-DD';

	--/*
	expSql := format(
		'
		select 
			C.c1 as suc, C.c2 as anio, C.c3 as mes, C.c4 as vendedor, V.c3 as nombre 
			, case when C.c5 = 0 then ''Venta'' else case when C.c5 = 10 then ''Toma'' else case when C.c5 = 20 then ''Toma < 30 dias'' else ''Unknown'' end end end as tipo
			, case when C.C8 = 0 then ''Alta'' else ''Baja'' end as ab 
			, C.c6 as inventario, C.c9 as fecha, C.c10 as oper, C.c11 as modelo, C.c15 as linea, C.c17 as edad 
			, C.c19 as utilidad, C.c26 as c_base, C.c27 as c_traslado, C.c28 as c_edad, C.c29 as c_linea 
			, C.c30 as c_gastos, C.c31 as c_seguro, C.c32 as c_extras, C.c33 as c_accesorios, C.c34 as c_semana 
			, C.c35 as c_total_sub, C.c36 as c_dcto_tmkt, C.c37 as tot_comis 
		from keplersc.kdcomisventas C 
		inner join keplersc.kduv V on V.c1 = C.c1 and V.c2 = C.c4 
		inner join keplersc.kdvesq H on H.c1 = V.c8 
		where C.c1 = %1$L and C.c2 = %2$L and C.c3 = %3$L and C.c5 < 30 
			 and C.c4 = %4$L
		order by C.c1, C.c2, C.c3, C.c4, C.c5, C.c9, C.c6  
		'
		, sucursal,anio,mes,vendedor);
	--*/

	--expSql='insert into tmpDoctos select c1 as clave_prod, c2 as desc_prod, ''''::xml as folios from keplersc.kdini';
	--raise notice '%', expSql; 
	--execute format(expSql);
	
	--select query_to_xml('select * from tmpDoctosDet',false,true,'') into xmlResultado;
   select query_to_xml(expSql,false,true,'') into xmlResultado;
  
   --raise notice '%', xmlResultado;
  
   return xmlResultado;

end;
$function$
