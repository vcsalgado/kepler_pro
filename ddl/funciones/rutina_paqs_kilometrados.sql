CREATE OR REPLACE PROCEDURE keplersc.rutina_paqs_kilometrados()
 LANGUAGE plpgsql
AS $procedure$
	declare 
	--Descripcion: enumera servicios kilometrados
	--Autor: Luis Leal
	--Fecha: 03/09/2023
		marca text;
		modelo text;
		clave_paq text;
		contador int;
	
	begin 
	
	 
		for marca, modelo in select c1,c2 from keplersc.kdspaq group by c1,c2
		loop 
			
			contador := 1;
			for clave_paq in select c4 from keplersc.kdspaq where c1=marca and c2=modelo 
			and left(c4,1)= 'S' and right(c4, 1) ~ '^[0-9\.]+$'  and c4 <> 'S10F1' order by substring(c4, 2)::numeric 
			loop 
				
				update keplersc.kdspaq set c12=contador, c13=concat(substring(c4, 2), '000')::numeric where c1=marca and c2=modelo and c4=clave_paq;
		
				contador := contador + 1;
		
			end loop;
		
		end loop;
		  		   
		   
	EXCEPTION
		WHEN others THEN
			ROLLBACK;
			raise exception '%', SQLERRM;
		    
	end;
$procedure$
