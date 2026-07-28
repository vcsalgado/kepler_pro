CREATE OR REPLACE FUNCTION keplersc.cont_pago_operarios(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
--Descripcion: Alta pago a operarios
--Autor: Luis Leal
--Fecha: 15/09/2022
--Bitacora de cambios
declare
		sucursal_id text;
		genero text;
		naturaleza text;
		grupo numeric;
		tipo numeric;
	
		nomina numeric;
		referencia_pol text;
		descripcion_pol text;
		fecha_inicial date;
		fecha_final date;
		horas_reales_trabajadas numeric = 0;
		costo_hr_general numeric;
	
		no_pagos int;
		clave_ope text;
		nombre_ope text;
		horas_tabuladas text;
		horas_base text;
		costo_por_hora  text;
		sueldo_base text;
		comisiones  text;
		total numeric;
		horas numeric;
	 	tipo_ord text; 
	 	fol_ord text;
	 	punto numeric;
		tipo_punto text;
		usuario text;
		--ayudante text;
	
		hrs_puntos_s numeric = 0;
		hrs_puntos_f numeric = 0;
		hrs_puntos_h numeric = 0;
		hrs_puntos_l numeric = 0;
		hrs_puntos_g numeric = 0;
		hrs_puntos_i numeric = 0;
		hrs_puntos_q numeric = 0;
		hrs_puntos_r numeric = 0;
		hrs_puntos_p numeric = 0;
	
		tipo_orden text;
		cuenta_cargo_m_obra text;
		cargo numeric;
		total_abono numeric = 0;
		anio text;
		partida numeric = 0;
		cuenta_abono text;
		
		strValor text;
	   	xml_partidas text = '';
	    xml_poliza text = '';
	   	error text = '';
	      
begin 
	
		sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1]; 
		genero := coalesce((xpath('//document/k_tipon/r1/text()', dataxml))[1]::text,'')::text;
		naturaleza := coalesce((xpath('//document/k_tipon/r2/text()', dataxml))[1]::text,'')::text;
		grupo := coalesce((xpath('//document/k_tipon/r3/text()', dataxml))[1]::text,'')::text;
		tipo := coalesce((xpath('//document/k_tipon/r4/text()', dataxml))[1]::text,'')::text;
		referencia_pol := coalesce((xpath('//document/k_refer/text()', dataxml))[1]::text,'')::text;
		descripcion_pol := coalesce((xpath('//document/k_descr/text()', dataxml))[1]::text,'')::text;
		nomina := coalesce((xpath('//document/nomina/text()', dataxml))[1]::text,'')::text;
		horas_reales_trabajadas := coalesce((xpath('//document/horas_reales_trabajadas/text()', dataxml))[1]::text,'')::text;
		usuario := coalesce((xpath('//document/movimiento/usuario/text()', dataxml))[1]::text,'')::text;
		fecha_inicial := (xpath('//document/fecha_inicial/text()', dataxml))[1];
		fecha_final := (xpath('//document/fecha_final/text()', dataxml))[1];
	
		costo_hr_general := nomina/horas_reales_trabajadas;
			
		strValor := (xpath('//document/ctd_pagos/text()',dataxml))[1];
		no_pagos := strValor::integer;		
	
		if fecha_inicial is null or fecha_final is null then 
			raise exception 'Debe seleccionar un rango de fechas.'; 
		end if;
		
		for cont in 0..no_pagos - 1 loop
		
			clave_ope := coalesce((xpath('//document/tabla_pagos/r' ||cont||'/clave_ope/text()',dataxml))[1]::text,'');
			nombre_ope := coalesce((xpath('//document/tabla_pagos/r' ||cont||'/nombre_ope/text()',dataxml))[1]::text,'');
			horas_tabuladas := coalesce((xpath('//document/tabla_pagos/r' ||cont||'/horas_tabuladas/text()',dataxml))[1]::text,'0');
			horas_base :=  coalesce((xpath('//document/tabla_pagos/r' ||cont||'/horas_base/text()',dataxml))[1]::text,'0');
			costo_por_hora := coalesce((xpath('//document/tabla_pagos/r' ||cont||'/costo_por_hora/text()',dataxml))[1]::text,'0');
			sueldo_base := coalesce((xpath('//document/tabla_pagos/r' ||cont||'/sueldo_base/text()',dataxml))[1]::text,'0');
			comisiones :=  coalesce((xpath('//document/tabla_pagos/r' ||cont||'/comisiones/text()',dataxml))[1]::text,'0');
			total := coalesce((xpath('//document/tabla_pagos/r' ||cont||'/total/text()',dataxml))[1]::text,'0');
			--ayudante := coalesce((xpath('//document/tabla_pagos/r' ||cont||'/ayudante/text()',dataxml))[1]::text,'');
				
			if total > 0 then
			
				insert into keplersc.kdtablanom (c1,c2,c3,c4,c5,c6,c7, c8, c9, c10, c12, c13, c15,c16, c17 ) 
				values(sucursal_id, genero,naturaleza, grupo, tipo, folio_operacion, clave_ope , 
				horas_tabuladas::numeric, horas_base::numeric, costo_por_hora::numeric,
				sueldo_base::numeric,comisiones::numeric, round(total::numeric, 2),current_date, 'A');
			
				for tipo_ord,fol_ord,punto,horas, tipo_punto in select hrs.c2,hrs.c3,hrs.c4,hrs.c14, pun.c6, hrs.c11
				from keplersc.kdhorpag as hrs inner join keplersc.kdpun as pun 
				on pun.c1=hrs.c1 and pun.c2=hrs.c2 and pun.c3=hrs.c3 and pun.c4=hrs.c4
				where hrs.c1=sucursal_id and hrs.c5=0 and hrs.c11>=fecha_inicial and hrs.c11<=fecha_final and hrs.c13=clave_ope 
				loop 
					
					update keplersc.kdhorpag set c5=10, c6=genero, c7=naturaleza, c8=grupo, 
					c9=tipo, c10=folio_operacion, c12=current_date, c15=(costo_hr_general)*horas
					where c1=sucursal_id  and c2=tipo_ord and c3=fol_ord and c4=punto and c5=0
					and c11>=fecha_inicial and c11<=fecha_final and c13=clave_ope ;
				
					if tipo_punto = 'S' then
						hrs_puntos_s = hrs_puntos_s + horas;
					end if;
					if tipo_punto = 'F' then
						hrs_puntos_f = hrs_puntos_f + horas;
					end if;
					if tipo_punto = 'H' then
						hrs_puntos_h = hrs_puntos_h + horas;
					end if;
					if tipo_punto = 'L' then
						hrs_puntos_l = hrs_puntos_l + horas;
					end if;
					if tipo_punto = 'G' then
						hrs_puntos_g = hrs_puntos_g + horas;
					end if;
					if tipo_punto = 'I' then
						hrs_puntos_i = hrs_puntos_i + horas;
					end if;
					if tipo_punto = 'Q' then
						hrs_puntos_q = hrs_puntos_q + horas;
					end if;
					if tipo_punto = 'R' then
						hrs_puntos_r = hrs_puntos_r + horas;
					end if;
					if tipo_punto = 'P' then				
						hrs_puntos_p = hrs_puntos_p + horas;
					end if;

				end loop;
			
			end if;

		end loop ;
	
		-----CONT_PAGO_OPERARIOS
		anio := substring(current_date::text, 3, 2);
		for tipo_orden, cuenta_cargo_m_obra in select c1, c10 from keplersc.kdtallcont where c3=anio
		loop 
			
			if tipo_orden = 'S' then 
				cargo := costo_hr_general * hrs_puntos_s;
			end if;
			if tipo_orden = 'F' then 
				cargo := costo_hr_general * hrs_puntos_f;
			end if;
			if tipo_orden = 'H' then 
				cargo := costo_hr_general * hrs_puntos_h;
			end if;
			if tipo_orden = 'L' then 
				cargo := costo_hr_general * hrs_puntos_l;
			end if;
			if tipo_orden = 'G' then 
				cargo := costo_hr_general * hrs_puntos_g;
			end if;
			if tipo_orden = 'I' then 
				cargo := costo_hr_general * hrs_puntos_i;
			end if;
			if tipo_orden = 'Q' then 
				cargo := costo_hr_general * hrs_puntos_q;
			end if;
			if tipo_orden = 'R' then 
				cargo := costo_hr_general * hrs_puntos_r;
			end if;
			if tipo_orden = 'P' then 
				cargo := costo_hr_general * hrs_puntos_p;
			end if;
				
			--CARGOS
			if cargo > 0 then
				partida := partida + 1;
				xml_partidas := concat(xml_partidas,format('<partida_%1$s><cuenta>%2$s</cuenta>
				<tipo_asiento>%3$s</tipo_asiento><monto>%4$s</monto>
				<descripcion_partida>%5$s</descripcion_partida>
				<descripcion_cuenta>%6$s</descripcion_cuenta>
				<referencia>%7$s</referencia></partida_%1$s>', 
				partida, cuenta_cargo_m_obra,'C',round(cargo,2), descripcion_pol, 'Cuenta creada por el sistema', referencia_pol ));
			end if;
		
			total_abono := total_abono + round(cargo,2);
		
		end loop;	
	
		--ABONO
		select c20 into cuenta_abono from keplersc.kdmm where c1='N' and c2='A' and c3=19 and c4=1;
		partida := partida + 1;
		xml_partidas := concat(xml_partidas,format('<partida_%1$s><cuenta>%2$s</cuenta>
		<tipo_asiento>%3$s</tipo_asiento><monto>%4$s</monto>
		<descripcion_partida>%5$s</descripcion_partida>
		<descripcion_cuenta>%6$s</descripcion_cuenta>
		<referencia>%7$s</referencia></partida_%1$s>', 
		partida, cuenta_abono,'A',total_abono, descripcion_pol, 'Cuenta creada por el sistema', referencia_pol ));
	
		if abs(nomina-total_abono) < .5  then
			xml_poliza := concat(
			'<poliza>', 
				'<poliza_enc>', 
					'<monto_base_kdmm>', 0, '</monto_base_kdmm>',
					'<descripcion_poliza>', descripcion_pol, '</descripcion_poliza>',
					'<referencia>', referencia_pol, '</referencia>',
					'<no_partidas>', partida, '</no_partidas>',
					'<error>0</error>',
				'</poliza_enc>' ,
				'<partidas>' ,xml_partidas, '</partidas>',
			'</poliza>');
		
		else 
			raise exception '%' , 'Error, montos no cuadran';
		end if;
			
		return xml_poliza::xml;	
	
exception
	when others then
		error := 'keplersc.cont_pago_operarios() ' || '['|| sqlstate || '] ' || sqlerrm ;
		raise exception '%', error;	
end;
$function$
