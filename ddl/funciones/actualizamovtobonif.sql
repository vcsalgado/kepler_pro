CREATE OR REPLACE FUNCTION keplersc.actualizamovtobonif()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: Actualiza el registro de las bonificaciones cuando tiene una baja de bonificacion el inventario
--Autor: Miriam Santana
--Fecha: 30/08/2023
--Bitacora de cambios
declare
	estado_movto text;

	--Variables Loop
	folio_bajabonif text='';
	fecha_bajabonif text='';
	folio_altabonif text='';
	inventario text;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	intValor int = 0;

	rec record;
begin
	/*
Paso1
1. Leer kdm5 NA28 Bajas obtener folio, inventario y monto
2. buscar en kdm1 el folio de la baja y obtener la fecha de alta c9
3. Buscar en kdm5 el folio de la alta de bonificacion por inv y monto obtenido en el punto 1 de los NA
4. Buscar en kdm1 folio de la alta y actualizar c43='C' y el c197= fecha c9 del folio de la baja en kdm1 del punto 2
*/
raise notice 'Inicio';
		for rec in select * from keplersc.kdm5 k where c2='N' and c3='A' and c4='28'		--bajas
		loop
			select c6,c9 into folio_bajabonif, fecha_bajabonif from keplersc.kdm1			--movto baja en kdm1
				where c1=rec.c1 and c2=rec.c2 and c3=rec.c3 and c4=rec.c4 
				and c5=rec.c5 and c6=rec.c6;
			if found then	
				raise notice 'folio_bajabonif: %, fecha_bajabonif:%', folio_bajabonif, fecha_bajabonif;
				select c6 into folio_altabonif from keplersc.kdm5 							--altas
					where c1=rec.c1 and c2='N' and c3='D' and c4='28' and c5=rec.c5 and c14=rec.c14 and c12=rec.c12;
				if found then
					raise notice 'inventario: %, monto:%, folio_Altabonif:%', rec.c14, rec.c12, folio_altabonif;
					estado_movto := 'C';
					select count(*) into intValor from keplersc.kdm1
					where c1=rec.c1 and c2='N' and c3='D' and c4='28' and c5=rec.c5 and c6=folio_altabonif;
					if intValor = 1 then
						raise notice 'Actualiza registro folioAltaBonif:%', folio_altabonif;
						
						 update keplersc.kdm1 
							set c43=estado_movto, c197=to_date(fecha_bajabonif,'YYYY-MM-DD')
							where c1=rec.c1 and c2='N' and c3='D' and c4='28' and c5=rec.c5 and c6=folio_altabonif;
							
							resultado := 1;
					else
						raise notice '....No actualizo registro folioAltaBonif:%', folio_altabonif;
					end if;
				else
					raise notice 'No encontro registro de alta folioAltaBonif:%', folio_altabonif;
				end if;
			else
				mensaje := 'No se encuentra el movimiento baja';
				resultado := 0;
			end if;
		
		
		end loop;
	
return 1;

end;
$function$
