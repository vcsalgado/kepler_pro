CREATE OR REPLACE FUNCTION keplersc.prod_busca_producto_plain(clave_producto text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
--	clave_producto text = '';	

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	totProd int = 0;
	tipoError text = 'Prog';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin	
	--clave_producto := (xpath('//document/clave_producto/text()', dataxml))[1];
--raise notice 'FASE 0, clave_prod:%',clave_producto;
	totProd := 0;
	select count(*) into totProd from keplersc.kdini where c1 = clave_producto;
--raise notice 'FASE 1, clave_prod:%, total:%',clave_producto,totProd;	
	while totProd = 0 loop	
		select count(*) into totProd from keplersc.kdinr where c1 = clave_producto;
--raise notice 'FASE 2 clave_prod:%, total:%',clave_producto,totProd;		
		if totProd <> 0 then
			select c2 into clave_producto from keplersc.kdinr where c1 = clave_producto;
		else
			--No hay reemplazo
			clave_producto = '';
			exit;
		end if;
		select count(*) into totProd from keplersc.kdini where c1 = clave_producto;
--raise notice 'FASE 3 clave_prod:%, total:%',clave_producto,totProd;		
	end loop;	

	if clave_producto = '' then
		clave_producto := (xpath('//document/clave_producto/text()', dataxml))[1];
		tipoError := 'Logic';
		raise exception 'El producto % no existe.',clave_producto;
	end if;

	resultado := 1;
	mensaje := clave_producto;
	adicionales := clave_producto;
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		if tipoError = 'Logic' then
			mensaje := sqlerrm;
		else
			mensaje := 'prod_busca_producto() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		end if;

		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
