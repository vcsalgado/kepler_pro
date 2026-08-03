CREATE OR REPLACE FUNCTION keplersc.ifz_habilita(p_sucursal text, p_interfaz text)
 RETURNS TABLE(resultado text)
 LANGUAGE plpgsql
AS $function$
--Descripcion:  Indica si la interfaz solicitada esta activa
--Autor: Roberto Herrera Flores del Campo
--Fecha: 07/04/2026
--Bitacora de cambios
declare
		sucursal_id text;
		interfaz text;
		resultado text = '';
   
begin 
	
		sucursal_id := p_sucursal; 
		interfaz := p_interfaz; 
		SELECT valor INTO resultado FROM keplersc.param_oper where sucursal = sucursal_id and upper(parametro) = upper(interfaz) LIMIT 1;
		IF resultado is null THEN
			resultado := X;
		END IF;

		return query select resultado;	

exception
		when others then
			resultado := 'X';
			return query select resultado;	
 	
end;
$function$
