CREATE OR REPLACE FUNCTION keplersc.bloquear_horarios_comida()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
	declare 
	--bloquea horarios de comida de recepcionistas
	
		num_dia int = 0;
		dia date;
		mes text; 
		anio int;

	begin
		
		
		delete from keplersc.kdtiemposnd where c7='COMIDA' and c1 in ('ECAZA', 'LALC', 'JFL');

		for num_dia in 0 .. 70 loop
		
			dia := current_date + num_dia;
			mes := extract(month from to_date(dia::text,'YYYY-MM-DD') )::text;
		    mes := TO_CHAR(mes::int, 'fm00');
			anio := extract(year from to_date(dia::text,'YYYY-MM-DD') );
				
			
			INSERT INTO keplersc.kdtiemposnd
			(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10)
			VALUES('ECAZA', 'RECEP', dia , 1.5, mes, anio, 'COMIDA', 0, '13:30', '15:00');
		
			INSERT INTO keplersc.kdtiemposnd
			(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10)
			VALUES('LALC', 'RECEP', dia, 1.5, mes, anio, 'COMIDA', 0, '14:30', '16:00');
		
			INSERT INTO keplersc.kdtiemposnd
			(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10)
			VALUES('JFL', 'RECEP', dia, 1.5, mes, anio, 'COMIDA', 0, '13:00', '14:30');
		
		end loop;
	
	
		return num_dia;


	END;
$function$
