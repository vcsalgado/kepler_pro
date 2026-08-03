CREATE OR REPLACE FUNCTION keplersc.reemplazo_prod_text(datatx text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
--Descripcion: reemplazo prod
--Autor: Jose Mendoza
--Fecha: 05/09/2023
--Bitacora de cambios
declare

	clave_original text;
	clave_actual text;
	clave_reemplazo text;
	remplazo_encontrado integer = 1;
	contador integer = 0;
	fecha text;
	xmlResultado text;

begin
	
	clave_original := datatx; /*(xpath('//document/clave_original/text()', dataxml))[1];*/

	clave_actual := clave_original;
	
	while remplazo_encontrado = 1 loop	
	
		select c1,c3 into clave_reemplazo, fecha from keplersc.kdinr where c2=clave_actual;
		if not found then
			remplazo_encontrado = 0;
		else 
		
			/*
			xmlResultado := concat(xmlResultado, format('<r%1$s><clave_reemplazo>%2$s</clave_reemplazo><fecha>%3$s</fecha></r%1$s>'
			,contador, clave_reemplazo, to_date(fecha,'YYYY-MM-DD') ));
			*/
			
			clave_actual := clave_reemplazo;
			
		end if;
	
		contador := contador + 1;
	
	end loop;	
	
	/*return xmlResultado;*/

	return clave_actual;

end;
$function$
