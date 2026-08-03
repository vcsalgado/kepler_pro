CREATE OR REPLACE FUNCTION keplersc.cancela_contactos_citagendada()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: Cancela contactos cuando ya existe una cita agendada registrada en los contactos del vin
--Autor: Miriam Santana
--Fecha: 02/12/2023
--Bitacora de cambios
declare
	folio_tmkt_cita text;
	sucursal_id text;
	vin text;
	folio_can text;
	fecha_contacto date;
	--Variables de retorno
	get_resultado text;
	get_mensaje text; 
	get_adicionales text;

	resultado text = '';
	rec record;
begin
raise notice 'Inicio';
	--Folio tmkt con citas agendadtas
	for rec in select * from keplersc.kdtmktser2 k 
		where c8=0 and c14 in (select k2.c14 from keplersc.kdtmktser2 k2
		where k2.c8=40 /*Vin con una cita agendada c8=40-Se agendo cita*/ and k.c14=k2.c14) and c23 =0 /*Llamada */ and c7 <>30/*Confirmacion cita*/ and c7<>40/*Seguimiento No show*/
		loop
			raise notice 'Vin:% Folio_tmkt:% tipo_n:% resultado:%',rec.c14,rec.c2,rec.c22,rec.c8;
		--tomar el folio del contacto que tiene el c8=40 que es se agendo cita
		select c1,c2,c10 into sucursal_id,folio_tmkt_cita,fecha_contacto from keplersc.kdtmktser2 k 
		where c14 =rec.c14 and c8=40;
		raise notice 'folio tmkt cita agendada:%',folio_tmkt_cita;
		--cancelar los folios
		update keplersc.kdtmktser2 
			set c8=21, c9=50, c10=fecha_contacto, c29='Se agendo previamente una cita'
		where c1=sucursal_id and c14=rec.c14 and c2<> folio_tmkt_cita and c2=rec.c2 and c8=0;
		--select c2 into folio_can from keplersc.kdtmktser2
		--where c1=sucursal_id and c14=rec.c14 and c2<> folio_tmkt_cita and c2=rec.c2 and c8=0;

raise notice 'folio a cancelar:%',folio_can;
		end loop;
--raise exception 'Alto manual';	
return '1';

end;
$function$
