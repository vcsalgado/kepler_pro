CREATE OR REPLACE FUNCTION keplersc.tipocomis_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: crud del catalogo de comisiones
--Autor: Luis Leal
--Fecha: 16/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	clave_comision text = '';
	desc_comision text = '';
	tipo_comision int ;
	limite_sup_edad_1 numeric ;
	limite_sup_edad_2 numeric;
	limite_sup_edad_3 numeric;
	crud text = '';


	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	clave_comision := upper((xpath('//document/clave_com/text()', dataxml))[1]::text);
	desc_comision := upper((xpath('//document/desc_com/text()', dataxml))[1]::text);
	tipo_comision := upper((xpath('//document/tipo_com/text()', dataxml))[1]::text);
	limite_sup_edad_1 := coalesce((xpath('//document/limite_sup_edad_1/text()', dataxml))[1]::text,'0')::text;
	limite_sup_edad_2 := coalesce((xpath('//document/limite_sup_edad_2/text()', dataxml))[1]::text,'0')::text;
	limite_sup_edad_3 := coalesce((xpath('//document/limite_sup_edad_3/text()', dataxml))[1]::text,'0')::text;
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'Eliminar' then
		if clave_comision is null then 
			raise exception 'Tiene que seleccionar una comision.';
		end if;
	
		if desc_comision is null then 
			raise exception 'Tiene que ingresar una descripcion.';
		end if;
	
		if tipo_comision is null then 
			raise exception 'Tiene que ingresar un tipo.';
		end if;
	
	end if; 

	if crud = 'Nuevo' then		
		insert into keplersc.kdtipocomis(c1,c2,c3,c4,c5,c6) values(clave_comision,desc_comision, tipo_comision, limite_sup_edad_1, limite_sup_edad_2, limite_sup_edad_3);
	end if;

	if crud = 'Modificar' then
		update keplersc.kdtipocomis set c2=desc_comision,c3=tipo_comision, c4=limite_sup_edad_1,
		c5=limite_sup_edad_2 , c6=limite_sup_edad_3 where c1=clave_comision ;
	end if;

	if crud = 'Eliminar' then
		delete from keplersc.kdtipocomis where c1=clave_comision ;	
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || clave_comision;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
	
		mensaje := 'tipocomis_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		

		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
