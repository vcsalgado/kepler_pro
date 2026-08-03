CREATE OR REPLACE FUNCTION keplersc.verify_es_cobro_cancelable_x_sustitucion(sucursal_id text, genero text, naturaleza text, grupo text, tipo text, factura text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Valida si un cobro tiene un tipo de relacion CFDI 04 y es considerado como cancelable por sustitucion
--Autor: Miriam Santana
--Fecha: 24/02/2025
--Bitacora de cambios
declare 
	cobro_sust text ='';
	cobro_nvo text ='';
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
		raise exception 'Falta capturar el numero de factura a validar';
	else
		--valida que sea cancelable por sustitucion
		select c6,c3,c4,c38,c39 into cobro_nvo,naturaleza_sust,grupo_sust,tipo_sust,cobro_sust from keplersc.kdm1
			where c1=sucursal_id and c2=genero and c36=naturaleza and c37=grupo::integer and c38=tipo::integer and c39=factura and tipo_relacion='04';
		if not found then
			raise exception 'Sin cobro x sustitucion';
		else
			select c43 into estatus from keplersc.kdm1
			where c1=sucursal_id and c2=genero and c3=naturaleza_sust and c4 =grupo_sust::integer and c5=tipo_sust::integer and c6=cobro_sust;
			if not found then
				raise exception 'No existe registro';
			else
				if estatus='C' then
					raise exception 'Cobro cancelado y sustituido por:%',cobro_nvo;
				else
					resultado := '1';
					mensaje := 'Es cancelable por sustitucion';
					adicionales := 'Es cancelable por sustitucion';

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
		mensaje := sqlerrm;
		adicionales:= sqlerrm;
		return query select resultado, mensaje, adicionales;
end;
$function$
