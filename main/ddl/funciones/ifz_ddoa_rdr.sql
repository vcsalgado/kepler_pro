CREATE OR REPLACE FUNCTION keplersc.ifz_ddoa_rdr(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion:  Movimientos para la tabla ifz_ddoa_rdr_notif
--Autor: Roberto Herrera Flores del Campo
--Fecha: 04/03/2026
--Bitacora de cambios
declare
		sucursal_id text;
		tipo_ope text;
		mes text;
		anio text;

		gen_mov text;
		nat_mov text;
		gpo_mov numeric;
		tipo_mov numeric;	
		folio_mov text; --Se incluye folio de la venta
	
		fecha_proceso timestamp;

		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
		xmlResultado text = '';
   
begin 
	
		sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1]; 
/*
		gen_mov := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
		nat_mov := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
		gpo_mov := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
		tipo_mov := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
*/
		--Se cambian esas 4 lineas y se incluye el folio de la venta
		gen_mov := (xpath('//document/c_gen/text()', dataxml))[1];
		nat_mov := (xpath('//document/c_nat/text()', dataxml))[1];
		gpo_mov := (xpath('//document/c_gpo/text()', dataxml))[1];
		tipo_mov := (xpath('//document/c_tip/text()', dataxml))[1];
		folio_mov := (xpath('//document/c_folio/text()', dataxml))[1];

		tipo_ope := (xpath('//document/operacion/text()', dataxml))[1]; 

		SELECT date_part('month', (SELECT current_timestamp)) into mes;
		SELECT date_part('year', (SELECT current_timestamp)) into anio ; 
	
		fecha_proceso := current_timestamp;
/*
		INSERT INTO keplersc.ifz_ddoa_rdr_notif (sucursal, genero, naturaleza, 
		grupo, tipo, folio, fecha) 
		VALUES(sucursal_id, gen_mov, nat_mov, gpo_mov, tipo_mov, folio_operacion, fecha_proceso);	
*/	
		INSERT INTO keplersc.ifz_ddoa_rdr_notif (sucursal, genero, naturaleza, 
		grupo, tipo, folio, fecha) 
		VALUES(sucursal_id, gen_mov, nat_mov, gpo_mov, tipo_mov, folio_mov, fecha_proceso);	

		resultado := 1;
		mensaje := folio_operacion;
		adicionales := xmlResultado;
		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := 0;
			mensaje := 'ifz_ddoa_rdr() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
 	
end;
$function$
