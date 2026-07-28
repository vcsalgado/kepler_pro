CREATE OR REPLACE FUNCTION keplersc.asesores_tmkt(sucursal text, serie text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
--Descripcion: regresa el asesor que de manera proporcional le corresponde atender el siguiente contacto tmkt 
--Autor: Luis Leal
--Fecha: 03/08/2023
--Bitacora de cambios
declare 

	ult_asesor text;
	asesor_elegido text;
	contador int;
	menos_contactos_asignados int;
	asesor_con_menos text;
	clave_asesor text;
	ctd int;
		
begin
	
		
	select c3 into ult_asesor from keplersc.kdtmktser2 where c1=sucursal and c14=serie and c5 < current_date order by c2 desc limit 1;
	if found then
	
		asesor_elegido := ult_asesor;

	else
	
		contador := 0;
		menos_contactos_asignados := 0;
		asesor_con_menos := '';
		for clave_asesor in select c1 from keplersc.kdsercattmkt where c1<>'SA' and c3='A' 
		loop 
			
			select count(*) into ctd from keplersc.kdtmktser2 where c3=clave_asesor and c5 >= current_date ;
			if ctd > 0 then 
			
				if contador = 0 then 
					menos_contactos_asignados := ctd;
					asesor_con_menos := clave_asesor;
				end if;
			
				if ctd < menos_contactos_asignados then 
					menos_contactos_asignados := ctd;
					asesor_con_menos := clave_asesor;
				end if;
							
			else
							
				menos_contactos_asignados := 1;
				asesor_con_menos := clave_asesor;
			
				exit;
			
			end if;
		
			contador := contador + 1;
			
		end loop;
		
		
		asesor_elegido := asesor_con_menos;
			
	end if;


	return asesor_elegido;
		
END;
$function$
