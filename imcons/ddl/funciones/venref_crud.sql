CREATE OR REPLACE FUNCTION keplersc.venref_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: crud venref
--Autor: Luis Leal
--Fecha: 14/12/2021
--Bitacora de cambios
declare
	--Variables de definicion de documento
	Abreviatura text = '';
	Abreviatura_anterior text = '';
	Nombre text = '';
	Tipo text = '';
	sucursal text = '';

	crud text = '';

	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	--raise notice '% xml', dataxml;
	
	Abreviatura := upper((xpath('//document/input_abrv/text()', dataxml))[1]::text);
	Abreviatura_anterior := upper((xpath('//document/input_abrv_ant/text()', dataxml))[1]::text);
	Nombre := upper((xpath('//document/input_nombre/text()', dataxml))[1]::text);
	Tipo := upper((xpath('//document/input_tipo/text()', dataxml))[1]::text);
	sucursal :=	upper(coalesce((xpath('//document/k_sucn/r1/text()', dataxml))[1]::text,'')::text);
	

	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud = 'Nuevo' then
					
		insert into keplersc.kdvenref(c1,c2,c3,c4) values(Abreviatura,Nombre, Tipo,sucursal);

	end if;

	if crud = 'Modificar' then
					
		update keplersc.kdvenref set c1=Abreviatura, c2=Nombre, c3=Tipo, c4=sucursal where c1=Abreviatura_anterior;

	end if;

	if crud = 'Eliminar' then
	
		delete from keplersc.kdvenref where c1 = Abreviatura;
					
	end if;


	resultado := 1;
	mensaje := Abreviatura;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
	
		mensaje := 'ven_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		

		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
