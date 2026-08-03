CREATE OR REPLACE FUNCTION keplersc.vendedores_editar(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Edita datos de los vendedores
--Autor: Luis Leal
--Fecha: 17/01/2023
--Bitacora de cambios
declare
	sucursal_id text;
	clave text;
	nombre text;
	empresa text;
	usuario text;
	activo text;
	grupo text;
	esquema text;

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
		
		clave := coalesce((xpath('//document/k_mov/r' ||cont||'/clave/text()',dataxml))[1],'');
		nombre := coalesce((xpath('//document/k_mov/r' ||cont||'/nombre/text()',dataxml))[1],'');
		empresa := coalesce((xpath('//document/k_mov/r' ||cont||'/empresa/text()',dataxml))[1],'');
		usuario := coalesce((xpath('//document/k_mov/r' ||cont||'/usuario/text()',dataxml))[1],'');
		activo := coalesce((xpath('//document/k_mov/r' ||cont||'/activo/text()',dataxml))[1],'');
		grupo := coalesce((xpath('//document/k_mov/r' ||cont||'/grupo/text()',dataxml))[1],'');
		esquema := coalesce((xpath('//document/k_mov/r' ||cont||'/esquema/text()',dataxml))[1],'');

		if clave = '' then
			if nombre = '' and empresa = '' and usuario = '' and activo = '' and grupo = '' and esquema = '' then 
				continue;
			end if;
			raise exception '%' ,'Error cada vendedor debe tener una clave' ; 
		end if;
		
		update keplersc.kduv set c3=nombre, c4=empresa, c5=usuario, c6=activo, c7=grupo, c8=esquema where c1=sucursal_id and c2=clave;
	
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'vendedores_editar() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
