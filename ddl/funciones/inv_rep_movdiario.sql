CREATE OR REPLACE FUNCTION keplersc.inv_rep_movdiario(dataxml xml)
 RETURNS TABLE(clave text, producto text, fecha text, documento text, descripcion text, tipo text, cantidad numeric, unidad text, entrada numeric, salida numeric)
 LANGUAGE plpgsql
AS $function$
declare 
	--Variables de definicion de documento
	sucursal_id text = '';
	fecha_ini text = '';
	fecha_fin text = '';
	genero text='';
	naturaleza text ='';
	grupo text='';
	tipo text='';
	
	--Variables de proceso
	transaccion_id text='';
	error text = '';

begin
	transaccion_id := keplersc.log_tran_id_gen();	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	fecha_ini := (xpath('//document/fecha_ini/text()', dataxml))[1];
	fecha_fin := (xpath('//document/fecha_fin/text()', dataxml))[1];
	genero := (xpath('//document/genero/text()',dataxml))[1];
	naturaleza := (xpath('//document/naturaleza/text()',dataxml))[1];
	grupo := (xpath('//document/grupo/text()',dataxml))[1];
	tipo := (xpath('//document/tipo/text()',dataxml))[1];
	
raise notice '%',1;

	return query
	select ini.c1::text as clave,
	ini.c2::text as producto,
	to_date(inm.c3::text,'YYYY-MM-DD')::text as fecha, 
	(inm.c5||inm.c6||lpad(inm.c7::text,2,'0')||lpad(inm.c8::text,3,'0')||'-'||inm.c9)::text as documento,
	mm.c5::text as descripcion,
	case when inm.c13 = 1 then 'ALTA' else  'BAJA' end  as tipo,
	inm.c11 as ctd, 
	ini.c19::text as unidad,
	case when inm.c6 = 'A' then inm.c11 else 0 end as entrada,
	case when inm.c6 <> 'A' then inm.c11 else 0  end as salida
	from keplersc.kdinm inm, keplersc.kdini ini, keplersc.kdmm mm
	where inm.c2 = ini.c1 and inm.c1=mm.col_sucursal and inm.c5 = mm.c1 and inm.c6 = mm.c2 and inm.c7 = mm.c3 and inm.c8 = mm.c4
	and inm.c1 = sucursal_id
	and inm.c5 = genero and inm.c6 = naturaleza and inm.c7 = grupo::numeric and inm.c8= tipo::numeric
	and inm.c3 between to_date(fecha_ini,'YYYY-MM-DD') and to_date( fecha_fin,'YYYY-MM-DD');

exception
	when others then
		error := 'keplersc.inv_rep_movdiario() ' || '['|| sqlstate || '] ' || sqlerrm ;
		raise exception '%', error;	
end;
$function$
