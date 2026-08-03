CREATE OR REPLACE FUNCTION keplersc.invr_rep_exisprod_sel(dataxml xml)
 RETURNS TABLE(k_clave text, k_descripcion text, k_existencias numeric, k_valor numeric, k_promedio numeric, k_minimo numeric, k_maximo numeric, k_loc text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Esta funcion crea el reporte de existencias OIRE
--Seutilizan la tabla kdinm para los calculos
--Autor: Victor Salgado
--Fecha: 18/10/2021
--Bitacora de cambios: 

declare 
	--Variables de definicion de documento
	sucursal_id text = '';
	producto_ini text = '';
	producto_fin text = '';
	fecha text = '';
	usuario_movto text = '';
	fecha_corte date; --to_date(fecha_ini,'YYYY-MM-DD')	

	--Variables de proceso
	transaccion_id text ='';
	error text = '';
	expSql text = '';
	strValor text = '';

	
begin
	transaccion_id := keplersc.log_tran_id_gen();	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	producto_ini := (xpath('//document/producto_ini/text()', dataxml))[1];
	producto_fin := (xpath('//document/producto_fin/text()', dataxml))[1];
	fecha := (xpath('//document/fecha/text()', dataxml))[1];
	usuario_movto := (xpath('//document/movimiento/usuario/text()', dataxml))[1];


	--Calcular fecha a fin del mes
	fecha_corte:= (date_trunc('month', to_date(fecha,'YYYY-MM-DD')) + interval '1 month')::date;

	return query 
	select producto::text as k_clave, 
		prod.c2::text as k_descripcion, 
		COALESCE(cantent,0)-COALESCE(cantsal,0) as k_existencias,
		COALESCE(montoent,0)-COALESCE(montosal,0) as k_valor,
		case 
			when COALESCE(cantent,0)-COALESCE(cantsal,0) <> 0 then
				(COALESCE(montoent,0)-COALESCE(montosal,0))/(COALESCE(cantent,0)-COALESCE(cantsal,0))
			else
				0.00::numeric
		end as k_promedio,
		prod.c21::numeric as k_minimo, 
		prod.c22::numeric as k_maximo, 
		prod.c4 || ' ' || prod.c5 || ' ' || prod.c6::text as k_Loc
	from
	(select sucursal, producto, 
		sum(cantent) as cantent, sum(cantsal) as cantsal, 
		sum(montoent) as montoent, sum(montosal) as montosal
		from 
		(select m.c1 as sucursal, m.c2 as producto,
			case when m.c6='A' then sum(m.c11) end as cantent,
			case when m.c6='D' then sum(m.c11) end as cantsal,
			case when m.c6='A' then sum(m.c12) end as montoent,
			case when m.c6='D' then sum(m.c12) end as montosal
			/*case when (m.c5='U' and m.c6='A') or (m.c5='X' and m.c6='A') or (m.c5='N' and m.c6='A') then sum(m.c11) end as cantent,
			case when (m.c5='U' and m.c6='D') or (m.c5='X' and m.c6='D') or (m.c5='N' and m.c6='D') then sum(m.c11) end as cantsal,
			case when (m.c5='U' and m.c6='A') or (m.c5='X' and m.c6='A') or (m.c5='N' and m.c6='A') then sum(m.c12) end as montoent,
			case when (m.c5='U' and m.c6='D') or (m.c5='X' and m.c6='D') or (m.c5='N' and m.c6='D') then sum(m.c12) end as montosal*/
		from keplersc.kdinm m
		where m.c1=sucursal_id and m.c2 between producto_ini and producto_fin and c3 <=fecha_corte
		group by m.c1,m.c2, m.c5,m.c6,m.c11 
		order by m.c1,m.c2) as res1
	group by sucursal, producto) as res2, keplersc.kdini prod
	where  prod.c1 = res2.producto and (COALESCE(cantent,0)-COALESCE(cantsal,0) <> 0 or montoent-montosal <>0 )
	order by sucursal, prod.c1;

	--return query select 0 as k_clave, '' as k_descripcion, 0 as k_existencias, 0 as k_valor, 
	--	0 as k_promedio, 0 as k_minimo, 0 as k_maximo, '' as k_loc;

exception
	when sqlstate 'P0001' then --Raised error 
		raise exception '%', sqlerrm;
	when others then
		error := 'keplersc.invr_rep_exisprod_sel() ' || '['|| sqlstate || '] ' || sqlerrm ;
		call keplersc.log_transac_insert(transaccion_id, usuario_movto, '0', 'keplersc.invr_rep_exisprod_sel', false, error, 'ERR', dataxml);
		raise exception '%', error;	
end;
$function$
