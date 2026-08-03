CREATE OR REPLACE FUNCTION keplersc.invr_rep_estxprod_sec_resmens_sel(dataxml xml)
 RETURNS TABLE(k_mesnum integer, k_mes text, k_entcant numeric, k_entmonto numeric, k_salcant numeric, k_salmonto numeric)
 LANGUAGE plpgsql
AS $function$
declare 
	--Variables de definicion de documento
	sucursal_id text = '';
	criterio text = '';
	producto text = '';
	ubicacion text = '';
	anio text = '';
	usuario_movto text = '';

	--Variables de proceso
	transaccion_id text='';
	xmlResultados xml;
	error text = '';
	expSql text = '';
	strValor text = '';
	xmlCadena xml = '';
	resultado text = '';
	mensaje text = '';
	adicionales text = '';
	total_registros int =0;

begin
	transaccion_id := keplersc.log_tran_id_gen();	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	criterio := (xpath('//document/criterio/text()', dataxml))[1];
	producto := (xpath('//document/producto/text()', dataxml))[1];
	ubicacion := (xpath('//document/ubicacion/text()', dataxml))[1];
	anio := (xpath('//document/anio/text()', dataxml))[1];
	usuario_movto := (xpath('//document/movimiento/usuario/text()', dataxml))[1];

	if criterio= 'U' then --Criterio por ubicacion
		select c1 into producto from keplersc.kdini where c5 = ubicacion order by c1 desc limit 1;
		if not found then
			raise exception 'La ubicación % no existe.',ubicacion;
		end if;
	end if;

	--Buscar producto base (con base en reemplazos)
	select xmlforest(producto as clave_producto)::text into strValor;
	select '<document>'||strValor||'</document>' into strValor;
	xmlCadena := strValor::xml;		

	select * into resultado, mensaje, adicionales from keplersc.prod_busca_producto(xmlCadena);
raise notice 'xmlCadena:%',xmlCadena;
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;
	producto = adicionales;	

	--Obtener resumen mensual de inventarios
	return query
	select * from
	(select 1 as k_mesnum, keplersc.gen_nombre_mes(1) as k_mes, c10 as k_entcant, c22 as k_entmonto, c40 as k_salcant, c52 as k_salmonto from keplersc.kdink where c1=sucursal_id and c2=producto and c3=anio
	union
	select 2 as k_mesnum, keplersc.gen_nombre_mes(2) as k_mes, c11 as k_entcant, c23 as k_entmonto, c41 as k_salcant, c53 as k_salmonto from keplersc.kdink where c1=sucursal_id and c2=producto and c3=anio
	union
	select 3 as k_mesnum, keplersc.gen_nombre_mes(3) as k_mes, c12 as k_entcant, c24 as k_entmonto, c42 as k_salcant, c54 as k_salmonto from keplersc.kdink where c1=sucursal_id and c2=producto and c3=anio
	union
	select 4 as k_mesnum, keplersc.gen_nombre_mes(4) as k_mes, c13 as k_entcant, c25 as k_entmonto, c43 as k_salcant, c55 as k_salmonto from keplersc.kdink where c1=sucursal_id and c2=producto and c3=anio
	union
	select 5 as k_mesnum, keplersc.gen_nombre_mes(5) as k_mes, c14 as k_entcant, c26 as k_entmonto, c44 as k_salcant, c56 as k_salmonto from keplersc.kdink where c1=sucursal_id and c2=producto and c3=anio
	union
	select 6 as k_mesnum, keplersc.gen_nombre_mes(6) as k_mes, c15 as k_entcant, c27 as k_entmonto, c45 as k_salcant, c57 as k_salmonto from keplersc.kdink where c1=sucursal_id and c2=producto and c3=anio
	union
	select 7 as k_mesnum, keplersc.gen_nombre_mes(7) as k_mes, c16 as k_entcant, c28 as k_entmonto, c46 as k_salcant, c58 as k_salmonto from keplersc.kdink where c1=sucursal_id and c2=producto and c3=anio
	union
	select 8 as k_mesnum, keplersc.gen_nombre_mes(8) as k_mes, c17 as k_entcant, c29 as k_entmonto, c47 as k_salcant, c59 as k_salmonto from keplersc.kdink where c1=sucursal_id and c2=producto and c3=anio
	union
	select 9 as k_mesnum, keplersc.gen_nombre_mes(9) as k_mes, c18 as k_entcant, c30 as k_entmonto, c48 as k_salcant, c60 as k_salmonto from keplersc.kdink where c1=sucursal_id and c2=producto and c3=anio
	union
	select 10 as k_mesnum, keplersc.gen_nombre_mes(10) as k_mes, c19 as k_entcant, c31 as k_entmonto, c49 as k_salcant, c61 as k_salmonto from keplersc.kdink where c1=sucursal_id and c2=producto and c3=anio
	union
	select 11 as k_mesnum, keplersc.gen_nombre_mes(11) as k_mes, c20 as k_entcant, c32 as k_entmonto, c50 as k_salcant, c62 as k_salmonto from keplersc.kdink where c1=sucursal_id and c2=producto and c3=anio
	union
	select 12 as k_mesnum, keplersc.gen_nombre_mes(12) as k_mes, c21 as k_entcant, c33 as k_entmonto, c51 as k_salcant, c63 as k_salmonto from keplersc.kdink where c1=sucursal_id and c2=producto and c3=anio
	order by 1)	as resultados;

exception
	when sqlstate 'P0001' then --Raised error 
		raise exception '%', sqlerrm;
	when others then
		error := 'keplersc.invr_rep_estxprod_sec_resmens_sel() ' || '['|| sqlstate || '] ' || sqlerrm ;
		call keplersc.log_transac_insert(transaccion_id, usuario_movto, '0', 'keplersc.invr_rep_estxprod_sec_resmens_sel', false, error, 'ERR', dataxml);
		raise exception '%', error;	
end;
$function$
