CREATE OR REPLACE FUNCTION keplersc.actualiza_estatus_citaxconfirmacion_contacto()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: Actualiza estatus de la cita al confirmar mediante pantalla antender contacto 
--Autor: Miriam Santana
--Fecha: 24/10/2023
--Bitacora de cambios
declare
	fecha_confirmacion date;
	folio_tmkt text;
	cita_actualizar text;
	fol_act text;
	--Variables de retorno
	get_resultado text;
	get_mensaje text; 
	get_adicionales text;

	resultado text = '';
	rec record;
begin
raise notice 'Inicio';
		for rec in select * from keplersc.kdtmktser2
			where c8=50					
		loop
			raise notice 'folio_tmkt KDTMKTSER2 rec.c2:%',rec.c2;
			raise notice 'folio_cita_actualizar KDTMKTSER2 rec.c15:%',rec.c15;			
			select c2 into cita_actualizar from keplersc.kdctasser k  
					where c2=rec.c15 and c20=0;
			raise notice 'Cita estatus pendiente KDCTASSER:%',cita_actualizar;
			update keplersc.kdctasser set c20=10
			--	select c2 into fol_act from keplersc.kdtmktser2 
					where c1='01' and c2=cita_actualizar; 
		raise notice 'UPDATE Cita actualizar:%',cita_actualizar;
		end loop;
--raise exception 'Alto manual';	
return '1';

end;
$function$
