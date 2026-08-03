CREATE OR REPLACE FUNCTION keplersc.actualiza_descuentos(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Actualiza descuentos paquetes
--Autor: Luis Leal
--Fecha: 21/10/2024
--Bitacora de cambios
declare
	paquete text = '';
	descuento_agencia numeric=0.00;
	descuento_otra_agencia numeric=0.00;
	no_partidas int = 0;
	strValor text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	
	strValor:=coalesce((xpath('//document/k_partidas/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;
	
	--Insertar nuevos registros
	for cont in 0..no_partidas loop
		paquete:=coalesce((xpath('//document/k_mov/r' ||cont||'/paquete/text()',dataxml))[1],'');
		strValor:=coalesce((xpath('//document/k_mov/r' ||cont||'/descuento_agencia/text()',dataxml))[1],'0');
		descuento_agencia:=strValor::numeric;
		strValor:=coalesce((xpath('//document/k_mov/r' ||cont||'/descuento_otra_agencia/text()',dataxml))[1],'0');
		descuento_otra_agencia:=strValor::numeric;
	
		if descuento_agencia = 0 and descuento_otra_agencia = 0 then 
			continue;
		end if;
		
		delete from keplersc.kdcatpaqlealtad where c1=paquete;
	
		insert into keplersc.kdcatpaqlealtad(c1,c2,c3)
		values(paquete,descuento_agencia,descuento_otra_agencia);
	
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'actualiza_descuentos() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
