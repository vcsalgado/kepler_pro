CREATE OR REPLACE FUNCTION keplersc.invr_res_saldos_prod_sel(dataxml xml)
 RETURNS TABLE(clave_prod text, desc_prod text, cantidad_ini numeric, monto_ini numeric, cantidad_fin numeric, monto_fin numeric, tot_movtos numeric)
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
	excluir_ceros text='';

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
	excluir_ceros := (xpath('//document/excluir_ceros/text()',dataxml))[1];
	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
raise notice '%',1;
	return query
	select * from (
	select clave_producto::text as clave_prod, ini.c2::text as desc_prod, sum(cantidad_inicial) as cantidad_ini, sum(monto_inicial) as monto_ini, 
		sum(cantidad_final) as cantidad_fin, sum(monto_final) as monto_fin, sum(total_movtos) as tot_movtos 
	from
		(select clave_producto, sum(cantidad) as cantidad_inicial, sum(monto) as monto_inicial, 0 as cantidad_final, 0 as monto_final, sum(total_movtos) * -1 as total_movtos 
		from
		(select inm.c2 as clave_producto, 'E' as tipo, sum(inm.c11) as cantidad, sum(inm.c12) as monto, count(*) as total_movtos
		from keplersc.kdinm inm 
		where inm.c1=sucursal_id and inm.c2 between producto_ini and  producto_fin and inm.c3 < to_date(fecha_ini,'YYYY-MM-DD') and inm.c6 = 'A'
		group by inm.c2
		union
		select inm.c2 as clave_producto, 'S' as tipo, sum(inm.c11) * -1 as cantidad, sum(inm.c12) * -1 as monto, count(*) as total_movtos
		from keplersc.kdinm inm
		where inm.c1=sucursal_id and inm.c2 between producto_ini and  producto_fin and inm.c3 < to_date(fecha_ini,'YYYY-MM-DD') and inm.c6 = 'D'
		group by inm.c2) as inicial group by clave_producto
		union
		select clave_producto,  0 as cantidad_inicial, 0 as monto_inicial, sum(cantidad) as cantidad_final, sum(monto) as monto_final, sum(total_movtos)  as total_movtos from
		(select inm.c2 as clave_producto, 'E' as tipo, sum(inm.c11) as cantidad, sum(inm.c12) as monto, count(*) as total_movtos
		from keplersc.kdinm inm 
		where inm.c1=sucursal_id and  inm.c2 between producto_ini and producto_fin and inm.c3 <= to_date(fecha_fin,'YYYY-MM-DD') and inm.c6 = 'A'
		group by inm.c2
		union
		select inm.c2 as clave_producto, 'S' as tipo, sum(inm.c11) * -1 as cantidad, sum(inm.c12) * -1 as monto, count(*) as total_movtos
		from keplersc.kdinm inm 
		where inm.c1=sucursal_id and  inm.c2 between producto_ini and producto_fin and inm.c3 <= to_date(fecha_fin,'YYYY-MM-DD') and inm.c6 = 'D'
		group by inm.c2) as final group by clave_producto
		) as saldos inner join keplersc.kdini ini on saldos.clave_producto = ini.c1
	group by clave_producto, ini.c2 order by clave_producto) as resultado 
	where case when excluir_ceros='1' then resultado.tot_movtos > 0 else resultado.tot_movtos=resultado.tot_movtos end;

exception
	when others then
		error := 'keplersc.invr_res_saldos_prod_sel() ' || '['|| sqlstate || '] ' || sqlerrm ;
		call keplersc.log_transac_insert(transaccion_id, usuario_movto, '0', 'keplersc.invr_res_saldos_prod_sel', false, SQLERRM, 'ERR', dataxml);
		raise exception '%', error;	
end;
$function$
