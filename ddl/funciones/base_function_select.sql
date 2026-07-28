CREATE OR REPLACE FUNCTION keplersc.base_function_select(dataxml xml)
 RETURNS TABLE(producto text, descripcion text)
 LANGUAGE plpgsql
AS $function$
declare 
	--Variables de definicion de documento
	criterio text = '';
	producto text = '';
	ubicacion text = '';
	anio text = '';

	--Variables de proceso
	transaccion_id text='';
	error text = '';

begin
	transaccion_id := keplersc.log_tran_id_gen();	
	criterio := (xpath('//document/criterio/text()', dataxml))[1];

	return query select ci as producto, c2 as descripcion from keplersc.kdini;
exception
	when others then
		error := 'keplersc.invr_rep_estxprod_sec_prod_sel() ' || '['|| sqlstate || '] ' || sqlerrm ;
		call keplersc.log_transac_insert(transaccion_id, usuario_movto, '0', 'keplersc.invr_rep_estxprod_sec_prod_sel', false, SQLERRM, 'ERR', dataxml);
		raise exception '%', error;	
end;
$function$
