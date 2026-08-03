CREATE OR REPLACE FUNCTION keplersc.porcentajes_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Crud para configurar la tabla de porcentajes
--Autor: Luis Leal
--Fecha: 14/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	tipo_comision text = '';
	limite_inferior int ;
	limite_superior int ;
	prc numeric;
	prc_1 numeric;
	prc_2 numeric;
	prc_3 numeric;
	prc_4 numeric;
	notas_desc numeric;
	gastos_adm numeric;
	seguro numeric;
	accesorios numeric;
	garantia_ext numeric;
	ult_limite_inferior int = 0;
	ult_limite_superior int = 0;
	no_partidas int = 0;
	strValor text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	
	tipo_comision := (xpath('//document/tipo_comision/r1/text()', dataxml))[1];
	strValor:=coalesce((xpath('//document/k_partidas/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;

	--Eliminar registrados asociados con el tipo de comision seleccionado
	delete from keplersc.kdporcentajes where c1=tipo_comision;

	--Insertar nuevos registros
	for cont in 0..no_partidas loop
		
		limite_inferior := coalesce((xpath('//document/k_mov/r' ||cont||'/limite_inferior/text()',dataxml))[1],'0');
		limite_superior := coalesce((xpath('//document/k_mov/r' ||cont||'/limite_superior/text()',dataxml))[1],'0');
		prc := coalesce((xpath('//document/k_mov/r' ||cont||'/prc/text()',dataxml))[1],'0');
		prc_1 := coalesce((xpath('//document/k_mov/r' ||cont||'/prc_1/text()',dataxml))[1],'0');
		prc_2 := coalesce((xpath('//document/k_mov/r' ||cont||'/prc_2/text()',dataxml))[1],'0');
		prc_3 := coalesce((xpath('//document/k_mov/r' ||cont||'/prc_3/text()',dataxml))[1],'0');
		prc_4 := coalesce((xpath('//document/k_mov/r' ||cont||'/prc_4/text()',dataxml))[1],'0');
		notas_desc := coalesce((xpath('//document/k_mov/r' ||cont||'/notas_desc/text()',dataxml))[1],'0');
		gastos_adm := coalesce((xpath('//document/k_mov/r' ||cont||'/gastos_adm/text()',dataxml))[1],'0');
		seguro := coalesce((xpath('//document/k_mov/r' ||cont||'/seguro/text()',dataxml))[1],'0');
		accesorios := coalesce((xpath('//document/k_mov/r' ||cont||'/accesorios/text()',dataxml))[1],'0');
		garantia_ext := coalesce((xpath('//document/k_mov/r' ||cont||'/garantia_ext/text()',dataxml))[1],'0');
		
		if limite_inferior = 0 and limite_superior = 0 then
			if  prc = 0 and prc_1 = 0 and prc_2 = 0 and prc_3 = 0 and prc_4 = 0 and notas_desc = 0 
			and gastos_adm = 0 and seguro = 0 and accesorios = 0  and garantia_ext = 0 then 
				continue;
			end if;
			raise exception 'Debe escoger un limite inferior y superior para el registro %' ,  cont + 1; 
		end if;
	
		if limite_inferior > limite_superior then
			raise exception 'El limite inferior del registro % no puede ser mayor que el limite superior' ,  cont + 1; 
		end if;
	
		if limite_inferior > 100 or limite_superior > 100  then
			raise exception 'Los limites del registro % no pueden ser mayores que 100' ,  cont + 1; 
		end if;
		
		if ult_limite_inferior <> 0 and ult_limite_superior <> 0 then 
			if limite_inferior <= ult_limite_inferior or limite_inferior <= ult_limite_superior or 
			limite_superior <= ult_limite_inferior or limite_superior <= ult_limite_superior then 
				raise exception 'Los limites inferiores y superiores del registro % deben ser mayores que los limites del registro anterior' ,  cont + 1; 
			end if;
		end if;
	
		insert into keplersc.kdporcentajes(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13)
		values(tipo_comision,limite_inferior, limite_superior, prc, prc_1, prc_2, prc_3,
		prc_4, notas_desc, gastos_adm, seguro, accesorios, garantia_ext);
	
		ult_limite_inferior := limite_inferior;
		ult_limite_superior := limite_superior;
	
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'porcentajes_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
