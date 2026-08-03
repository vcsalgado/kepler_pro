CREATE OR REPLACE FUNCTION keplersc.invr_margen_utilidad_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Configuracion de margen de utilidad de refacciones
--Autor: Victor Salgado
--Fecha: 28/10/2024
--Bitacora de cambios
declare
	clave text;
	descripcion text;
	metodo text;
	utilidad text;
	iva text;
	catalogo text;
	comisionable text;

	no_partidas int = 0;
	strValor text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	strValor:=coalesce((xpath('//document/k_partidas/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;

	for cont in 0..no_partidas loop
		
		clave := coalesce((xpath('//document/k_mov/r' ||cont||'/clave/text()',dataxml))[1],'');
		descripcion := coalesce((xpath('//document/k_mov/r' ||cont||'/descripcion/text()',dataxml))[1],'SIN DESCRIPCION');
		metodo := coalesce((xpath('//document/k_mov/r' ||cont||'/metodo/text()',dataxml))[1],'0');
		utilidad := coalesce((xpath('//document/k_mov/r' ||cont||'/utilidad/text()',dataxml))[1],'0');
		iva := coalesce((xpath('//document/k_mov/r' ||cont||'/iva/text()',dataxml))[1],'0');
		catalogo := coalesce((xpath('//document/k_mov/r' ||cont||'/catalogo/text()',dataxml))[1],'0');
		comisionable := coalesce((xpath('//document/k_mov/r' ||cont||'/comisionable/text()',dataxml))[1],'N');

		if clave = '' then
			continue;
		end if;
		
		update keplersc.kdicatprecio set c2=descripcion, c3=metodo::numeric, c4=utilidad::numeric, c5=iva::numeric, c6=catalogo::numeric, c7=comisionable where c1=clave;
	
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'invr_margen_utilidad_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
