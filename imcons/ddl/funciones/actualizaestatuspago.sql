CREATE OR REPLACE FUNCTION keplersc.actualizaestatuspago()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: Actualiza el registro de los pagos cuando tiene una susutitucion o anulacion
--Autor: Miriam Santana
--Fecha: 30/01/2025
--Bitacora de cambios
declare
	estado_movto text;
	estatus_actual text;
	--Variables Loop
	folio_cobro text='';
	fecha_baja text='';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	intValor int = 0;

	rec record;
begin
	/*
Paso1
1. Leer kdm1 los movto de sustitucion UA32 y aulacion UD32, tomar el folio del pago c39(docto_docto) y fecha de operacion c9
2. Buscar en kdm1 folio del pago  y actualizar c43='C' y el c197= fecha c9 del folio de la sustitucio o anulacion del punto 1
*/
raise notice 'Inicio';
		for rec in select * from keplersc.kdm1 k where c2='U' and c3 in ('A','D') and c4='32'		--Sustituciones y anulaciones
		loop
			fecha_baja:=rec.c9;			--fecha de baja
			folio_cobro:=rec.c39;
			select count(*) into intValor from keplersc.kdm1			--movto baja en kdm1
				where c1=rec.c1 and c2=rec.c2 and c3=rec.c36 and c4=rec.c37 
				and c5=rec.c38 and c6=rec.c39;
			if intValor=1 then	
				raise notice 'suc:%, folio_baja: %, folio_cobro:%, fecha_baja:%',rec.c1,rec.c6, folio_cobro, fecha_baja;
				estado_movto := 'C';
				update keplersc.kdm1 
					set c43=estado_movto, c197=to_date(fecha_baja,'YYYY-MM-DD')
					where c1=rec.c1 and c2=rec.c2 and c3=rec.c36 and c4=rec.c37 
				and c5=rec.c38 and c6=rec.c39;
				
				select c43 into estatus_actual from keplersc.kdm1 
					where c1=rec.c1 and c2=rec.c2 and c3=rec.c36 and c4=rec.c37 
					and c5=rec.c38 and c6=rec.c39;
				raise notice 'suc:%, folio_baja: %, folio_cobro:%, fecha_baja:%, estatus_actual:%',rec.c1,rec.c6, folio_cobro, fecha_baja,estatus_actual;							
			else
				raise notice '....No actualizo registro folio_baja:%, folio_cobro:%', rec.c6,folio_cobro;
			end if;
		
		end loop;
--raise exception 'Alto manual';	
return 1;

end;
$function$
