CREATE OR REPLACE FUNCTION keplersc.invr_calc_tabla_pecios_sel(dataxml xml)
 RETURNS TABLE(k_cveprecio text, k_descripcion text, k_precio numeric)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Resuelve a ITABLAPRECIOS, obtiene los precios un producto con 
--base en la tabla kdicatprecios para cada uno de los registros
--Autor: Victor Salgado
--Fecha: 10/10/2021
declare 
	--Variables de definicion de documento
	sucursal_id text  ='';
	producto text = '';
	usuario_movto text = '';

	--Variables de proceso
	transaccion_id text='';
	error text = '';

	--Variables de retorno
	cveprecio text = '';
	descripcion text = '';
	precio decimal = 0.00;

begin
	transaccion_id := keplersc.log_tran_id_gen();	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	producto := (xpath('//document/producto/text()', dataxml))[1];
	usuario_movto := (xpath('//document/movimiento/usuario/text()', dataxml))[1];

	return query
	select c1::text as k_cveprecio, c2::text as k_decripcion, 
		keplersc.invr_calc_precio_metodo_sel(format('<document><sucursal_id>%1$s</sucursal_id><producto>%2$s</producto>
		<nombre_precio>%3$s</nombre_precio></document>',sucursal_id,producto,lower(c1))::xml)::numeric 	as k_precio
	from keplersc.kdicatprecio order by c1;

exception
	when others then
		error := 'keplersc.invr_calc_tabla_pecios_sel() ' || '['|| sqlstate || '] ' || sqlerrm ;
		call keplersc.log_transac_insert(transaccion_id, usuario_movto, '0', 'keplersc.invr_calc_tabla_pecios_sel', false, SQLERRM, 'ERR', dataxml);
		raise exception '%', sqlerrm;	
end;
$function$
