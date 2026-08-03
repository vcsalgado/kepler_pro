CREATE OR REPLACE FUNCTION keplersc.prod_obtener_prod_ubi(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
	--Descripcion: Obtiene la clave del producto a una ubicacion dada, si hay varios
	--productos en la ubicacion, se regresa el ultimo
	--Autor: Victor Salgado
	--Fecha: 13/Oct/2021
	--Bitacora de cambios:
declare
	--Variables de definicion de documento
	ubicacion text = '';	

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	totProd int = 0;
	tipoError text = 'Prog';
	producto text = '0';

	--Variables de retorno
	resultado text  ='';
	mensaje text = '';
	adicionales text = '';

begin
	ubicacion := (xpath('//document/ubicacion/text()', dataxml))[1];
	totProd := 0;
	select count(*) into totProd from keplersc.kdini where c5 = ubicacion;
raise notice '%', totProd;
	if (totProd > 0) then
		select c1 into producto from keplersc.kdini where c5=ubicacion order by c1 desc limit 1;
	else
		tipoError = 'Logic';
		raise exception 'No se encontró ninguna coincidencia con la ubicación ingresada';
	end if;
	
	resultado := 1;
	mensaje := producto;
	adicionales := producto;
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		if tipoError = 'Logic' then
			mensaje := sqlerrm;
		else
			mensaje := 'prod_obtener_prod_ubi() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		end if;

		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
