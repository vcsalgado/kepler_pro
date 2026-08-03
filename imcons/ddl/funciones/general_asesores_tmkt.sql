CREATE OR REPLACE PROCEDURE keplersc.general_asesores_tmkt()
 LANGUAGE plpgsql
AS $procedure$
--Descripcion: asigna todos los contactos sin asignar 
--Autor: Luis Leal
--Fecha: 10/04/2024
--Bitacora de cambios
declare 

	sucursal text;
	folio text;
	serie text;
	asesor_elegido text;
		
begin
	
	for sucursal, folio, serie in select c1,c2,c14 from keplersc.kdtmktser2 where c3='' order by c5
	loop 
		
		select * into asesor_elegido from keplersc.asesores_tmkt(sucursal,serie);
		
		update keplersc.kdtmktser2 set c3=asesor_elegido where c1=sucursal and c2=folio and c14=serie;
		
	end loop;
	
		
	raise notice 'Proceso Terminado';
		
END;
$procedure$
