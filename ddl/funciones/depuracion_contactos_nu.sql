CREATE OR REPLACE FUNCTION keplersc.depuracion_contactos_nu()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: Depuracion de contactos duplicados NU en kdtmktser2
--Autor: Miriam Santana
--Fecha: 12/12/2023
--Bitacora de cambios
declare
	folio_respetar text;
	fecha_creacion date;
	asesor_base text;
	fecha_contacto date;
	ultimo_motivo_tmkt numeric;
	ultimo_resultado_tmkt numeric;
	ultimo_accion_tmkt numeric;
	reg_borrados integer;
	serie text;

	--Variables de retorno
	get_resultado text;
	get_mensaje text; 
	get_adicionales text;

	resultado text = '';
	rec record;
begin
raise notice 'Inicio Sin asignar';
	--Folio tmkt contactos NU sin atender y sin asignar
	for rec in select distinct c14 from keplersc.kdtmktser2 k 
				where c22='NU' and c8 =0 and c3 =''
				order by c14
	loop
raise notice 'VIN:%',rec.c14;
		--tomar del for loop el ultimo contacto generado y tomar el folio 
		select c2,c24 into folio_respetar,fecha_creacion
			from keplersc.kdtmktser2 k 
			where c14=rec.c14 /*vin*/ and c22='NU' and c8 =0 and c3 =''
			order by c24 desc limit 1;
raise notice 'Folio_respetar:%',folio_respetar;		
		--eliminiar los reg excepto el del folio del paso anterior	
		select count(*) into reg_borrados from keplersc.kdtmktser2 
			where c14=rec.c14 /*vin*/ and c22='NU' and c8 =0 and c3 ='' and c2 <> folio_respetar/*folio NU que no se borrara*/;	
		delete from keplersc.kdtmktser2  
			where c14=rec.c14 /*vin*/ and c22='NU' and c8 =0 and c3 ='' and c2 <> folio_respetar/*folio NU que no se borrara*/;
raise notice 'Registros a borrar:%',reg_borrados;		
	end loop;	

raise notice 'Inicio Asignados';
	--Folio tmkt contactos NU sin atender y que estan asignados
	for rec in select distinct c14 from keplersc.kdtmktser2 k 
				where c22='NU' and c8 =0 and c3 <>''
				order by c14
	loop
raise notice 'VIN:%',rec.c14;
		--tomar del for loop el ultimo contacto generado y tomar el folio 
		select c2,c3,c5,c7,c8,c9,c15,c19 
			into folio_respetar,asesor_base,fecha_contacto, ultimo_motivo_tmkt , 
			ultimo_resultado_tmkt, ultimo_accion_tmkt
			from keplersc.kdtmktser2 k 
			where c14=rec.c14 /*vin*/ and C22='NU' and C8 =0 and c3 <>''
			order by c24 desc limit 1;	
raise notice 'Folio_respetar:% Asesor base:%',folio_respetar,asesor_base;			
		--eliminiar los reg excepto el del folio del paso anterior	
		select count(*) into reg_borrados from keplersc.kdtmktser2 
			where c14=rec.c14 /*vin*/ and c22='NU' and c8 =0 and c2 <> folio_respetar/*folio NU que no se borrara*/;	
		delete from keplersc.kdtmktser2 
			where c14=rec.c14 /*vin*/ and c22='NU' and c8 =0 and c2 <> folio_respetar/*folio NU que no se borrara*/;
raise notice 'Registros a borrar:%',reg_borrados;		
		--Guardar en kdserie inf de ultimo contacto 
		--select c1 into serie from keplersc.kdserie
		update keplersc.kdserie set ult_motivo_tmkt=ultimo_motivo_tmkt, ult_resultado_tmkt=ultimo_resultado_tmkt, 
			ult_accion_tmkt=ultimo_accion_tmkt, fecha_ult_contacto_tmkt=fecha_contacto, asesor_base_tmkt=asesor_base
			where c1=rec.c14;
raise notice 'Actualiza kdserie:%',rec.c14;			
	end loop;	
	
--raise exception 'Alto manual';	
return '1';

end;
$function$
