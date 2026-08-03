CREATE OR REPLACE PROCEDURE keplersc.rutina_paqs_kilometrados()
 LANGUAGE plpgsql
AS $procedure$
	declare 
	--Descripcion: enumera servicios kilometrados
	--Autor: Luis Leal
	--Fecha: 06/02/2024
		clave_paq text;	
	begin 
		
		for clave_paq in select c1 from keplersc.kdcatpaq where 
	 	left(c1,1)= 'S' and right(c1, 1) ~ '^[0-9\.]+$'  and c1 <> 'S10F1' order by substring(c1, 2)::numeric 
		loop 
			
			update keplersc.kdcatpaq set col_kms=concat(substring(c1, 2), '000')::numeric
			where c1=clave_paq and c3='SPOL';
	
		end loop;
			   
		   
	EXCEPTION
		WHEN others THEN
			ROLLBACK;
			raise exception '%', SQLERRM;
		    
	end;
$procedure$
