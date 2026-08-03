CREATE OR REPLACE FUNCTION keplersc.horario_taller_editar(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Edita horario taller
--Autor: Luis Leal
--Fecha: 10/06/2024
--Bitacora de cambios
declare
	sucursal_id text;
	dia_semana text;
	recep_ini text;
	recep_fin text;
	mins text;
	
	no_partidas int = 0;
	strValor text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	
	sucursal_id:=coalesce((xpath('//document/k_sucN/r1/text()', dataxml))[1],'');
	strValor:=coalesce((xpath('//document/k_partidas/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;


	for cont in 0..no_partidas loop
		
		dia_semana := coalesce((xpath('//document/k_mov/r' ||cont||'/dia/text()',dataxml))[1],'');
		recep_ini := coalesce((xpath('//document/k_mov/r' ||cont||'/recepcion_inicio/text()',dataxml))[1],'');
		recep_fin := coalesce((xpath('//document/k_mov/r' ||cont||'/recepcion_fin/text()',dataxml))[1],'');
	
		if recep_ini <> '' then 
		
			--valida minutos
			mins := right(left(recep_ini::text,5)::text,2);
			if mins <> '00' and mins <> '15' and mins <> '30' and mins <> '45' then 
				raise exception 'Recepcion Inicio del % solo se permiten los siguientes minutos 00,15,30,45 ',dia_semana ; 
			end if;
		
		end if;
		
		if recep_fin <> '' then 
		
			--valida minutos
			mins := right(left(recep_fin::text,5)::text,2);
			if mins <> '00' and mins <> '15' and mins <> '30' and mins <> '45' then 
				raise exception 'Recepcion Final del % solo se permiten los siguientes minutos 00,15,30,45 ',dia_semana ; 
			end if;
		
		end if;

		
		update keplersc.horario_taller 
		set recepcion_inicio=recep_ini, recepcion_fin=recep_fin
		where sucursal=sucursal_id and dia=dia_semana;
	
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'horario_taller_editar() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
