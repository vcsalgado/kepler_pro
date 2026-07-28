CREATE OR REPLACE FUNCTION keplersc.invr_det_movtos_prod_sel(dataxml xml)
 RETURNS TABLE(clave_producto text, desc_producto text, fecha text, documento text, descripcion text, cantidad numeric, entradas numeric, salidas numeric, unidad text, tipo text, monto numeric)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	producto_ini text = '';
	producto_fin text = '';
	fecha_ini text = '';
	fecha_fin text = '';
	usuario_movto text='';

	--Variables de proceso
	transaccion_id text='';
	error text = '';

begin
	
	transaccion_id := keplersc.log_tran_id_gen();	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	producto_ini := (xpath('//document/producto_ini/text()', dataxml))[1];
	producto_fin := (xpath('//document/producto_fin/text()', dataxml))[1];
	fecha_ini := (xpath('//document/fecha_ini/text()', dataxml))[1];
	fecha_fin := (xpath('//document/fecha_fin/text()', dataxml))[1];
	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];

	return query
	select ini.c1::text as clave_producto,
	ini.c2::text as desc_producto,
	inm.c3::text as fecha, 
	mm.c1||mm.c2||lpad(mm.c3::text,2,'0')||lpad(mm.c4::text,3,'0')||'-'||inm.c9 as documento,
	mm.c5::text as descripcion,
	inm.c11 as cantidad,
	case when mm.c2 = 'A' then inm.c11
		else 0 end as entradas,
	case when mm.c2 <> 'A' then inm.c11
		else 0 end as salidas,
	ini.c19::text as unidad,
	case when inm.c13 = 1 then 'ALTA'
		when inm.c13 = 2 then 'BAJA'
		else '----' end as tipo,
	inm.c12 as monto
	from keplersc.kdinm inm, keplersc.kdmm mm, keplersc.kdini ini 
	where ini.c1 = inm.c2 and mm.c1 = inm.c5 and mm.c2=inm.c6 and mm.c3=inm.c7
	and mm.c4=inm.c8
	and inm.c1=sucursal_id and  inm.c2 between producto_ini and producto_fin 
	and inm.c3 between to_date(fecha_ini,'YYYY-MM-DD') and to_date(fecha_fin,'YYYY-MM-DD')
	order by inm.c2,inm.c3;
exception
	when others then
		error := 'keplersc.invr_resumen_saldos_productos() ' || '['|| sqlstate || '] ' || sqlerrm ;
		call keplersc.log_transac_insert(transaccion_id, usuario_movto, '0', 'keplersc.invr_det_movtos_prod_sel', false, SQLERRM, 'ERR', dataxml);
		raise exception '%', error;	
end;
$function$
