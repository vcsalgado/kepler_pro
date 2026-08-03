CREATE OR REPLACE FUNCTION keplersc.ser_tmkt_generacontactosconfirmacion()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: Regenerar confirmacion de cita folios hechos en k75 posteriores a la implantacion k80 
--Autor: Miriam Santana
--Fecha: 14/09/2023
--Bitacora de cambios
declare
	dataxml text;
	fecha_confirmacion date;
	folio_tmkt text;
	
	--Variables de retorno
	get_resultado text;
	get_mensaje text; 
	get_adicionales text;

	resultado text = '';
	rec record;
begin
raise notice 'Inicio';
		dataxml := '<document>
						<paso>1</paso>
					</document>';
		for rec in select * from keplersc.kdctasser
			where c2 < '0000200000' and c12 > '2023-09-15' and c20=0		--c20=0 solo citas pendientes
			order by c12 asc 					
		loop
			--Creacion de contacto de seguimiento de cita(confirmacion)
			--Este registro queda pendiente por atender siempre que la cita
			--no sea para un dia despues
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('TMKT.', rec.c1),0,0, dataxml::xml);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
			folio_tmkt := get_mensaje; 
			raise notice 'folio_tmkt:%',folio_tmkt;
			if to_char(rec.c12, 'dy') = 'mon' then
				fecha_confirmacion = rec.c12::date - 2;
			else 	
				fecha_confirmacion = rec.c12::date - 1;
			end if;
			raise notice 'fecha_confirmacion:%',fecha_confirmacion;
			raise notice 'suc:% asesor:% vin:% folio_cita:% cliente:%',rec.c1,rec.c3,rec.c6,rec.c2,rec.c4;
			insert into keplersc.kdtmktser2
				(c1,c2,c3,c5,c6,
				c7,c14,c15,c18,c19,
				c20,c23) 
			values(rec.c1,folio_tmkt,rec.c3,fecha_confirmacion,10,
				30,rec.c6,rec.c2,0,'P', 
				rec.c4,0);			
		
		end loop;
--raise exception 'Alto manual';	
return '1';

end;
$function$
