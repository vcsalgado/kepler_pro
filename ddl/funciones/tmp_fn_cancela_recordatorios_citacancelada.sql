CREATE OR REPLACE FUNCTION keplersc.tmp_fn_cancela_recordatorios_citacancelada()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: Cancela recordatorios de confirtmacion de cita cuando se cancela una cita 
--Autor: Miriam Santana
--Fecha: 23/10/2023
--Bitacora de cambios
declare
	dataxml text;
	fecha_confirmacion date;
	folio_tmkt text;
	folio_cancelar text;
	fol_canc text;
	--Variables de retorno
	get_resultado text;
	get_mensaje text; 
	get_adicionales text;

	resultado text = '';
	rec record;
begin
raise notice 'Inicio';
		for rec in select * from keplersc.kdctasser
			where c20=40 and c16 >'2023-09-04 00:00:00.000' 					
		loop
			raise notice 'folio_cita_canc rec.c2:%',rec.c2;			
			select c2 into folio_cancelar from keplersc.kdtmktser2 
					where c15=rec.c2 and c7=30 and c14=rec.c6;
			raise notice 'folio_tmkt_canc:%',folio_cancelar;
				update keplersc.kdtmktser2 
					set c8=21, c9=50, c29= 'Cita cancelada'
				--select c2 into fol_canc from keplersc.kdtmktser2 
					where c1='01' and c2=folio_cancelar; 
		raise notice 'folio actualizar:%',fol_canc;
		end loop;
--raise exception 'Alto manual';	
return '1';

end;
$function$
