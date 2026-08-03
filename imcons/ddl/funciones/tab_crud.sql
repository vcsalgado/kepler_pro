CREATE OR REPLACE FUNCTION keplersc.tab_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: crud del catalogo de tabulacion
--Autor: Luis Leal
--Fecha: 15/12/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	Marca text = '';
	Modelo text = '';
	Clave text = '';
	descr text = '';
	horas text = '';
	crud text = '';

	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	Marca := upper((xpath('//document/input_marca/text()', dataxml))[1]::text);
	Modelo := upper((xpath('//document/input_modelo/text()', dataxml))[1]::text);
	Clave := upper((xpath('//document/input_clave/text()', dataxml))[1]::text);
	descr := upper(coalesce((xpath('//document/input_desc/text()', dataxml))[1]::text,'')::text);
	horas := upper(coalesce((xpath('//document/input_horas/text()', dataxml))[1]::text,'')::text);
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'Eliminar' then
		if Marca is null then 
			raise exception 'Tiene que seleccionar una marca';
		end if;
	
		if Modelo is null then 
			raise exception 'Tiene que seleccionar una modelo';
		end if;
	
		if Clave is null then 
			raise exception 'Tiene que introducir una clave';
		end if;
	
		if descr = '' then 
			raise exception 'Tiene que introducir una descripcion';
		end if;

		if horas = '' or horas = '0' then 
			raise exception 'Tiene que introducir horas';
		end if;
	end if; 

	if crud = 'Nuevo' then		
		insert into keplersc.kdtab(c1,c2,c3,c4,c5) values(Marca, Modelo, Clave, descr,horas::numeric);
	end if;

	if crud = 'Modificar' then
		update keplersc.kdtab set c4=descr,c5=horas::numeric where c1=Marca and c2=Modelo and c3=Clave;
	end if;

	if crud = 'Eliminar' then
		delete from keplersc.kdtab where c1=Marca and c2=Modelo and c3=Clave;	
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || Clave;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
	
		mensaje := 'tab_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		

		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
