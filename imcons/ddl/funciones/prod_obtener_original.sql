CREATE OR REPLACE FUNCTION keplersc.prod_obtener_original(datatx text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
--Descripcion: Se obtiene el producto original dada una clave
--Autor: Victor Salgado
--Fecha: 03/10/2023
--Bitacora de cambios
declare
	clave_original text;
	clave_actual text;
	clave_reemplazo text;
	remplazo_encontrado integer = 1;
	fecha text;
	xmlResultado text;
	totReg int =0;

begin
	
	clave_reemplazo := datatx;
	clave_original:=clave_reemplazo;
	while remplazo_encontrado = 1 loop	
		select c2 into clave_original from keplersc.kdinr where c1=clave_reemplazo;
		if not found then
			remplazo_encontrado = 0;
		else 
			clave_reemplazo := clave_original;			
		end if;
	end loop;
	clave_original:=clave_reemplazo;
	--Buscar la clave original en catalogo para validar existencia
	select count(*) into totReg from keplersc.kdini where c1=clave_original;
	if totReg = 0 then
		clave_original:=0;
	end if;
	return clave_original;
end;
$function$
