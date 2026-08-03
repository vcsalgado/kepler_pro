CREATE OR REPLACE FUNCTION keplersc.cat_isantabla_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Crud para configurar la tabla de isan
--Autor: Victor Salgado
--Fecha: 30/01/2023
--Bitacora de cambios
declare
	tipo_calculo text = '';
	codigo text = '';
	descripcion text = '';
	limite_inferior numeric=0.00;
	limite_superior numeric=0.00;
	porcentaje numeric=0.00;
	tarifa numeric=0.00;
	reduccion numeric=0.00;
	excedente numeric=0.00;
	restador numeric=0.00;
	ult_limite_inferior numeric=0.00;
	ult_limite_superior numeric=0.00;
	no_partidas int = 0;
	strValor text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	
	tipo_calculo:= (xpath('//document/tipo_calculo/r1/text()', dataxml))[1];
	strValor:=coalesce((xpath('//document/k_partidas/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;

	--Eliminar registrados asociados con el tipo de comision seleccionado
	delete from keplersc.kdisan where c1=tipo_calculo;

	--Insertar nuevos registros
	for cont in 0..no_partidas loop
		codigo:=coalesce((xpath('//document/k_mov/r' ||cont||'/codigo/text()',dataxml))[1],'0');
		descripcion:=coalesce((xpath('//document/k_mov/r' ||cont||'/descripcion/text()',dataxml))[1],'0');
		strValor:=coalesce((xpath('//document/k_mov/r' ||cont||'/limite_inferior/text()',dataxml))[1],'0');
		limite_inferior:=strValor::numeric;
		strValor:=coalesce((xpath('//document/k_mov/r' ||cont||'/limite_superior/text()',dataxml))[1],'0');
		limite_superior:=strValor::numeric;
		strValor:=coalesce((xpath('//document/k_mov/r' ||cont||'/porcentaje/text()',dataxml))[1],'0');
		porcentaje:=strValor::numeric;
		strValor:=coalesce((xpath('//document/k_mov/r' ||cont||'/tarifa/text()',dataxml))[1],'0');	
		tarifa:=strValor::numeric;
		strValor:=coalesce((xpath('//document/k_mov/r' ||cont||'/reducion/text()',dataxml))[1],'0');
		reduccion:=strValor::numeric;
		strValor:=coalesce((xpath('//document/k_mov/r' ||cont||'/excedente/text()',dataxml))[1],'0');
		excedente:=strValor::numeric;
		strValor:=coalesce((xpath('//document/k_mov/r' ||cont||'/restador/text()',dataxml))[1],'0');
		restador:=strValor::numeric;
		
		if limite_inferior = 0 and limite_superior = 0 then
			if  porcentaje = 0 and tarifa = 0 and reduccion = 0 and excedente = 0 and restador = 0 then 
				continue;
			end if;
			raise exception 'Debe escoger un límite inferior y superior para el registro %' ,  cont + 1; 
		end if;
	
		if limite_inferior > limite_superior then
			raise exception 'El límite inferior del registro % no puede ser mayor que el limite superior' ,  cont + 1; 
		end if;
	
		if ult_limite_inferior <> 0 and ult_limite_superior <> 0 then 
			if limite_inferior <= ult_limite_inferior or limite_inferior <= ult_limite_superior or 
			limite_superior <= ult_limite_inferior or limite_superior <= ult_limite_superior then 
				raise exception 'Los límites inferiores y superiores del registro % deben ser mayores que los límites del registro anterior' ,  cont + 1; 
			end if;
		end if;
	
		insert into keplersc.kdisan(c1,c2,c3,c4,c5,
		c6,c7,c8,c9,c10)
		values(tipo_calculo,codigo,descripcion,limite_inferior,limite_superior, 
		porcentaje,tarifa,reduccion,excedente,restador);
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
		mensaje := 'cat_isantabla_crud_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
