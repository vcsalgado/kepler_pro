CREATE OR REPLACE FUNCTION keplersc.verify_es_factura_cancelable_x_sustitucion(sucursal_id text, genero text, naturaleza text, grupo text, tipo text, factura text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Valida si una factura de auto tiene un tipo de relacion CFDI 04 y es considerada como cancelable por sustitucion
--Autor: Miriam Santana
--Fecha: 24/02/2025
--Bitacora de cambios
declare 
	factura_sust text ='';
	naturaleza_sust text='';
	grupo_sust text='';
	tipo_sust text='';
	estatus text=''; 
	
	totreg int;	

	--Variables de retorno
	resultado text ='0';
	mensaje text ='';
	adicionales text ='';

begin
	if factura = '' then
		resultado := '0';
		adicionales:= 'Falta capturar el numero de factura a validar';
	else		
		--valida que sea cancelable por sustitucion
		select c3,c4,c38,c39 into naturaleza_sust,grupo_sust,tipo_sust,factura_sust from keplersc.kdm1
			where c1=sucursal_id and c2=genero and c36=naturaleza and c37=grupo::integer and c38=tipo::integer and c39=factura and tipo_relacion='04';
		if not found then
			resultado := '0';
			adicionales := resultado||'|No es cancelable por sustitucion';
		else
			select c43 into estatus from keplersc.kdm1
			where c1=sucursal_id and c2=genero and c3=naturaleza_sust and c4 =grupo_sust::integer and c5=tipo_sust::integer and c6=factura_sust;
			if not found then
				resultado := '0';
				adicionales := resultado||'|No existe registro de factura';
			else
				if estatus='C' then
					resultado := '0';
					adicionales := resultado||'|Factura Cancelada. No es cancelable por sustitucion';
				else
					resultado := '1';
					adicionales := resultado||'|Es cancelable por sustitucion';
				end if;
			end if;
		end if;
	end if;
				
	--Retorno tipo tabla
	return query select resultado, mensaje, adicionales;

EXCEPTION
	WHEN others then
		--Retorno tipo tabla
		resultado := '0';
		mensaje := 'verify_es_factura_cancelable_x_sustitucion(): ' || sqlerrm;
		adicionales:= '';
		return query select resultado, mensaje, adicionales;
end;
$function$
