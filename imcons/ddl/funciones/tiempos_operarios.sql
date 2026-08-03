CREATE OR REPLACE FUNCTION keplersc.tiempos_operarios(dataxml xml)
 RETURNS TABLE(tiempos_ope text, totales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: selecciona tiempos disponibles de operarios
--Autor: Luis Leal
--Fecha: 13/05/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	fecha_cita date;
	tipo_operacion text;
	folio_cita text;
	hrs_semana numeric;
	hrs_sabado numeric;
	porcentaje_hrs_vendibles numeric;
	
	oper text;
	oper_desc text;
	oper_activos numeric ;
	horas_disponibles numeric;
	horas_libres numeric;
	porcentaje_uso decimal;

	hrs_no_disp integer;
	carry_A_P integer;
	carry_S integer;
	dias_carry_a_p integer = 1;
	total_hrs_disp numeric = 0;
	total_hrs_libres numeric = 0;
	total_porcentaje_uso decimal = 0.00;

	hrs_cita_dia integer ;
	hrs_cita_modificar integer;
	fecha_cita_numero integer;
	fecha_mañana_numero integer;
	
	intValor integer = 0;

	--Variables de retorno
	tiempos_ope text;
	totales text;


begin
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	fecha_cita := ((xpath('//document/fecha_cita/text()', dataxml))[1]::text)::date;
	tipo_operacion :=  (xpath('//document/tipo_operacion/text()', dataxml))[1];
    folio_cita := coalesce((xpath('//document/folio_cita/text()', dataxml))[1]::text,'')::text; 
   
   	select c4,c5,c6 into hrs_semana,hrs_sabado,porcentaje_hrs_vendibles from keplersc.kdserconfctas; --where c31=sucursal_id
   	
	SELECT EXTRACT(DOW FROM fecha_cita::date) into fecha_cita_numero;
	SELECT EXTRACT(DOW FROM current_date + 1) into fecha_mañana_numero;

	for oper, oper_desc in select c1,c2 from keplersc.kdtoper
		loop 
			
			select count(*) into oper_activos from keplersc.kdoper where c2=oper and c12='S';--and c30=sucursal_id
	
			--calcular horas disponibles 
			if fecha_cita_numero = 0 then
				horas_disponibles := oper_activos * 0;
			end if;
			if fecha_cita_numero = 6 then
				horas_disponibles := ROUND((oper_activos*hrs_sabado)*(porcentaje_hrs_vendibles/100),2);
			end if;
		
			--si es entre semana
			if fecha_cita_numero <> 0 and fecha_cita_numero <> 6 then
				horas_disponibles := ROUND((oper_activos*hrs_semana)*(porcentaje_hrs_vendibles/100),2);
			end if;
		
			select sum(c4) into hrs_no_disp from keplersc.kdtiemposnd where c2=oper and c3=fecha_cita; -- and c9=sucursal_id
			if hrs_no_disp is not null then
				horas_disponibles:= horas_disponibles - hrs_no_disp;
			end if;
		
			horas_libres := horas_disponibles;
	
			select sum(mov.c9) into hrs_cita_dia from keplersc.kdctasser as cit inner join keplersc.kdctassermov 
			as mov on mov.c1=cit.c1 and mov.c2=cit.c2 where cit.c1=sucursal_id and cit.c2 <> folio_cita and cit.c12=fecha_cita and mov.c5=oper ;
			if hrs_cita_dia is not null then
				horas_libres:= horas_libres - hrs_cita_dia;
			end if;
			
			--TODO ANALIZAR ANTES DE BORRAR
			--si el dia de mañana es domingo carry over A/P a lunes
			/*if fecha_mañana_numero = 0 then
				dias_carry_a_p := 2;
			end if;
		
			--SOLO SI LA FECHA DE LA CITA ES MAÑANA, O EN CASO DE CORRERSE LA RUTINA EN SABADO LA CITA SEA EN LUNES
			--carry over A/P (PUNTOS ACTIVOS Y PENDIENTES)
			if current_date + dias_carry_a_p = fecha_cita then 
				select sum(case when pun.c40=0 then 1 else pun.c40 end) into carry_A_P 
				from keplersc.kdord as ord inner join keplersc.kdpun as pun 
				on pun.c1=ord.c1 and pun.c2=ord.c2 and pun.c3=ord.c3
				where ord.c1=sucursal_id and ord.c7=0 and pun.c37=oper and (pun.c7='P' or pun.c8= 'A');
				if carry_A_P is not null then
					horas_libres:= horas_libres - carry_A_P;
				end if;
			end if;
		
			--carry over S (PUNTOS SUSPENDIDOS)
			select sum(case when pun.c40=0 then 1 else pun.c40 end) into carry_S 
			from keplersc.kdord as ord inner join keplersc.kdpun as pun 
			on pun.c1=ord.c1 and pun.c2=ord.c2 and pun.c3=ord.c3
			where ord.c1=sucursal_id and ord.c7=0 and pun.c37=oper and pun.c7='S' and pun.c41>ord.c4 
			and pun.c41= fecha_cita;
			if carry_S is not null then
				horas_libres:= horas_libres - carry_S;
			end if;*/
		
			--error division entre cero
			if horas_disponibles = 0 then
				porcentaje_uso := 0.00;
			else
				porcentaje_uso := ((horas_disponibles-horas_libres)*100)/horas_disponibles;
			end if;
			
			tiempos_ope := concat(tiempos_ope,
			format('<r%1$s><oper>%2$s</oper><oper_desc>%3$s</oper_desc><hrs_disp>%4$s</hrs_disp>
			<hrs_libres>%5$s</hrs_libres><porcentaje_uso>%6$s</porcentaje_uso></r%1$s>',
			intValor,oper,oper_desc,horas_disponibles,horas_libres,ROUND(porcentaje_uso, 2)));
			intValor := intValor + 1;
		
			total_hrs_disp := total_hrs_disp + horas_disponibles;
			total_hrs_libres :=  total_hrs_libres + horas_libres;
		
		end loop;
	
		--error division entre cero
		if total_hrs_disp <> 0 then
			total_porcentaje_uso := ((total_hrs_disp-total_hrs_libres)*100)/total_hrs_disp;
		end if;

		totales := xmlforest(total_hrs_disp as total_hrs_disp, 
		total_hrs_libres as total_hrs_libres, ROUND(total_porcentaje_uso, 2) as total_porcentaje_uso);
		
	return query
	select tiempos_ope, totales;

exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
