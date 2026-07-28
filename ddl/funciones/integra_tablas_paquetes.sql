CREATE OR REPLACE PROCEDURE keplersc.integra_tablas_paquetes()
 LANGUAGE plpgsql
AS $procedure$
--Descripcion: integra las tablas de paquetes
--Autor: Luis Leal
--Fecha: 02/02/2023
--Bitacora de cambios
declare 
	paquete text;
	desc_paq text;
	desc_paq_original text;
	strValor text;
	pr_resultado text;
begin
	
	for paquete, desc_paq in select c4,c5 from keplersc.kdspaq  
	loop 
		
		select c2 into desc_paq_original from keplersc.kdcatpaq where c1=paquete;
		if found then
		
			if desc_paq_original <> desc_paq then
			
				update keplersc.kdcatpaq set c2=desc_paq where c1=paquete and c2=desc_paq_original;
			
			
			end if;	
		
		else
		
			insert into keplersc.kdcatpaq(c1,c2,c3,c4) values(paquete, desc_paq, '', '');
			
		end if;
		
	end loop;

	
	
exception
	when others then
	pr_resultado :=  xmlforest('0' AS resultado, '['|| sqlstate || '] ' || sqlerrm AS mensaje, 'log_transac_insert' as valores);
end;
$procedure$
