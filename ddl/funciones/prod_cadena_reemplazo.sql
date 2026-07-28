CREATE OR REPLACE FUNCTION keplersc.prod_cadena_reemplazo(dataxml xml)
 RETURNS TABLE(clave_original text, clave_actual text, cadena_reemplazo text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	clave_producto text = '';
	fecha text = '';
	criterio_fecha text = 'N';

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	totProd int = 0;
	mensaje text = '';

	--Variables de retorno
	clave_original text;
	clave_actual text;
	cadena_reemplazo text;

begin
	
	clave_producto := (xpath('//document/clave_producto/text()', dataxml))[1];
	fecha := (xpath('//document/fecha/text()', dataxml))[1];
	criterio_fecha := (xpath('//document/criterio_fecha/text()', dataxml))[1];

	--Obtener el producto origen en tabla de reemplazos
	clave_original := clave_producto;
	totProd := 1;
	while totProd = 1 loop	
		select count(*) into totProd from keplersc.kdinr where c1 = clave_original;
		if totProd <> 0 then
			select c2 into strValor from keplersc.kdinr where c1 = clave_original;
			clave_original := strValor;
		end if;
	end loop;	

	--Obtener el producto actual en tabla de reemplazos
	clave_actual := clave_original;
	cadena_reemplazo := clave_actual;
	totProd := 1;
	while totProd = 1 loop	
		select count(*) into totProd from keplersc.kdinr where c2 = clave_actual;
		if totProd <> 0 then
			select c1 into clave_actual from keplersc.kdinr where c2 = clave_actual;
			cadena_reemplazo := cadena_reemplazo || '|' || clave_actual;		
		end if;
	end loop;

	--Verifica que el producto actual se encuentre en la tabla de productos
	select count(*) into totProd from keplersc.kdini where c1 = clave_original;

	if totProd = 0 then
		clave_producto := (xpath('//document/clave_producto/text()', dataxml))[1];
		raise exception 'El producto % no existe.',clave_producto;
	end if;

	return query select clave_original, clave_actual, cadena_reemplazo;	
end;
$function$
