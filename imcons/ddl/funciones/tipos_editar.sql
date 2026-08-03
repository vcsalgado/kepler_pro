CREATE OR REPLACE FUNCTION keplersc.tipos_editar(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Edita Tabla de tipos
--Autor: Luis Leal
--Fecha: 17/01/2023
--Bitacora de cambios
declare
	sucursal_id text;
	esquema text;
	operacion text;
	tipo_vehiculo text;
	comision text;

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
		
		esquema := coalesce((xpath('//document/k_mov/r' ||cont||'/esquema/text()',dataxml))[1],'');
		operacion := coalesce((xpath('//document/k_mov/r' ||cont||'/operacion/text()',dataxml))[1],'');
		tipo_vehiculo := coalesce((xpath('//document/k_mov/r' ||cont||'/tipo_vehiculo/text()',dataxml))[1],'');
		comision := coalesce((xpath('//document/k_mov/r' ||cont||'/comision/text()',dataxml))[1],'');
		
		if esquema = '' and operacion = '' and tipo_vehiculo = '' and comision = '' then 
			continue;
		end if;
	
		update keplersc.kdvesqveh set c5=comision where c1=sucursal_id and c2=esquema and c3=operacion and c4=tipo_vehiculo;
	
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'tipos_editar() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
