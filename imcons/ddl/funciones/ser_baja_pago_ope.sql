CREATE OR REPLACE FUNCTION keplersc.ser_baja_pago_ope(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Baja pago a operarios
--Autor: Luis Leal
--Fecha: 24/09/2022
--Bitacora de cambios
declare

		sucursal_id text;
		genero text;
		naturaleza text;
		grupo numeric;
		tipo numeric;
	
		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
	      
begin 
	
		sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1]; 
		genero := coalesce((xpath('//document/k_tipon/r1/text()', dataxml))[1]::text,'')::text;
		naturaleza := coalesce((xpath('//document/k_tipon/r2/text()', dataxml))[1]::text,'')::text;
		grupo := coalesce((xpath('//document/k_tipon/r3/text()', dataxml))[1]::text,'')::text;
		tipo := coalesce((xpath('//document/k_tipon/r4/text()', dataxml))[1]::text,'')::text;

		update keplersc.kdhorpag set c5=0, c6='', c7='', c8=0, c9=0, c10='',c12='1800-01-01 00:00:00', 
		c15=0 where c1=sucursal_id and c6= genero and c7=naturaleza 
		and c8=grupo::integer and c9=tipo::integer and c10=folio_operacion;
		
		update keplersc.kdtablanom set c17='B', c18=current_date where c1=sucursal_id and c2= genero 
		and c3=naturaleza and c4=grupo::integer and c5=tipo::integer  and c6= folio_operacion;
			
		resultado := 1;
		mensaje := 'Pagos dados de baja';
		adicionales := folio_operacion;
		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := 0;
			mensaje := 'ser_baja_pago_ope() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
	
end;
$function$
