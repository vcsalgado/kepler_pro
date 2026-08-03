CREATE OR REPLACE FUNCTION keplersc.separar_nombre(nombre_completo text)
 RETURNS TABLE(nombre text, ap_paterno text, ap_materno text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Separa nombre completo en nombre,apellido paterno, materno, con algunas excepciones
--Autor: Miriam Santana
--Fecha: 20/05/2025
--Bitacora de cambios
declare 
    separa_nombre text[];
    items int;
	ap_materno text ='';
	ap_paterno text ='';
	nombre text ='';
   	excepciones TEXT[] := ARRAY['de', 'del', 'la', 'las', 'los', 'san', 'santa'];
begin 
    separa_nombre := string_to_array(nombre_completo, ' ');
    items := array_length(separa_nombre, 1);
	raise notice 'separa_nombre:% items:%',separa_nombre,items;  
    if items > 2 then
        ap_materno := separa_nombre[items];       
        ap_paterno := separa_nombre[items - 1];
 
        -- Si ap_materno es compuesto, une palabras anteriores
    	raise notice'separa_nombre[items - 1]:% ap_materno:%',separa_nombre[items - 1], ap_materno;
       	if lower(separa_nombre[items - 1]) = any (excepciones) and items > 3 then
            ap_materno := separa_nombre[items - 1] || ' ' || ap_materno;
            ap_paterno := separa_nombre[items - 2];
			raise notice 'mat comp';
            -- Si ap_paterno también es compuesto, lo une
		raise notice 'separa_nombre[items - 3]:%',separa_nombre[items - 3];
            if lower(separa_nombre[items - 3]) = any (excepciones) and items > 4 then
				raise notice'separa_nombre[items - 3]:% ap_paterno:%',separa_nombre[items - 3], ap_paterno;
				raise notice 'mat y pat comp';
            	ap_paterno := separa_nombre[items - 3] || ' ' || ap_paterno;
                nombre := array_to_string(separa_nombre[1:(items - 4)], ' ');
            else 
                nombre := array_to_string(separa_nombre[1:(items - 3)], ' ');
            end if;
        else
			raise notice 'pat comp';        
            -- Si ap_paterno es compuesto
            if lower(separa_nombre[items - 2]) = any (excepciones) and items > 3 then
            raise notice'separa_nombre[items - 2]:% ap_paterno:%',separa_nombre[items - 2], ap_paterno;
                ap_paterno := separa_nombre[items - 2] || ' ' || ap_paterno;
                nombre := array_to_string(separa_nombre[1:(items - 3)], ' ');
            else
                nombre := array_to_string(separa_nombre[1:(items - 2)], ' ');
            end if;
        end if;
    
	raise notice 'ap:% am:% n:%',ap_paterno, ap_materno,nombre;       
    else 
    	if  items = 2 then
		    nombre := separa_nombre[1];
		    ap_paterno := separa_nombre[2];
		    ap_materno := '.';
		else
			if items = 1 then
		        nombre := separa_nombre[1];
		        ap_paterno := '.';
		        ap_materno := '.';
			else
		        nombre := '.';
		        ap_paterno := '.';
		        ap_materno := '.';
			end if;		       
	    end if;
	end if;

	--Retorno tipo tabla
	return query select nombre, ap_paterno, ap_materno;

EXCEPTION
	WHEN others then
		--Retorno tipo tabla
		nombre := nombre_completo;
		ap_paterno := nombre_completo;
		ap_materno:= nombre_completo;
		return query select nombre, ap_paterno, ap_materno;
end;
$function$
