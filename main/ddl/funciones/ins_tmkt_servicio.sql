CREATE OR REPLACE FUNCTION keplersc.ins_tmkt_servicio(contador_contactos_neg integer, max_operaciones integer, num_dia_programado_neg integer, fecha_orden date, limite_inferior_inactivo date, serie text, sucursal text, tipo_servicio_tmkt numeric, kilometros_diarios numeric, clave_cliente text, km_desde_ult_orden numeric, km_promedio_extra numeric, km_necesarios numeric, dias_urgente integer, recordatorio_ant_1 numeric, recordatorio_ant_2 numeric, recordatorio_ant_3 numeric, recordatorio_ant_4 numeric, dataxml xml)
 RETURNS TABLE(resultado1 integer, resultado2 integer)
 LANGUAGE plpgsql
AS $function$

declare

	motivo_contacto numeric = 10;
	folio_contacto_nvo text;
	fecha_programacion date;
	observacion1 text = '';
	observacion2 text = '';
	folio_contacto text;
	asesor_base text;
	fecha_contacto date;
	ultimo_motivo_tmkt numeric;
	ultimo_resultado_tmkt numeric;
	ultimo_accion_tmkt numeric;
	folio_cita text;
	fecha_cita date;
	status_cita numeric;
	agregar_contacto text;
	cita_no_concretada text;
	orden_activa text;
	tipo_trabajo text;
	tipo_n_ult_contacto text;
	medio_contacto_preferente int = 10;
	medio_contacto int = 0;
	nombre_dia text;
	fecha_N date;
	tipo_N numeric;
	km_aprox_recorridos numeric = 0;
	dias_sumar int;
	res_auto int;
	asesor_elegido text;

	--Variables de retorno
	resultado1 integer ;
	resultado2 integer ;
	resultado3 integer ;
	resultado4 integer;

	get_resultado text;
	get_mensaje text; 
	get_adicionales text;

	clave_folio text;

begin
	
	
	--selecciona cualquier cita creada que no se haya concretado
	select cit.c2 into cita_no_concretada from keplersc.kdctasser as cit 
	where cit.c1=sucursal and cit.c6=serie and cit.c12 >= current_date ;
	if not found then
	
		select c3 into orden_activa from keplersc.kdord where c1=sucursal and c2='S' and c6=serie and c8 <> 50;
		if not found then 
	
				--busca si ya existe un contacto tmkt para la serie		
				select c2,c3,c5,c7,c8,c9,c15,c19,c22 into folio_contacto,asesor_base,fecha_contacto, ultimo_motivo_tmkt , 
				ultimo_resultado_tmkt, ultimo_accion_tmkt,folio_cita, tipo_trabajo, tipo_n_ult_contacto
				from keplersc.kdtmktser2 where c1=sucursal and c14=serie order by c5 desc limit 1;
				if found then				
					if fecha_contacto < current_date then	
		
						if ultimo_accion_tmkt <> 20 then
							agregar_contacto := 'Si';
						end if;
						
						update keplersc.kdserie set ult_motivo_tmkt=ultimo_motivo_tmkt, ult_resultado_tmkt=ultimo_resultado_tmkt, 
						ult_accion_tmkt=ultimo_accion_tmkt, fecha_ult_contacto_tmkt=fecha_contacto, asesor_base_tmkt=asesor_base where c1=serie;
						
					end if;
	
				else
					--VCSS 25/Mar/2026, se agregan valores por defecto cuando no hay historial de citas pero si ordenes
					tipo_n_ult_contacto = 'NU';
					ultimo_resultado_tmkt = 60; --Nunca se realizo contacto
					ultimo_accion_tmkt = 50; --Terminado

					agregar_contacto := 'Si';
				end if;
			
		end if;

	end if;

	
	if agregar_contacto = 'Si' then 
	
		select * into asesor_elegido from keplersc.asesores_tmkt(sucursal,serie);
	
		if kilometros_diarios <> 0 then 
			motivo_contacto := 11;
			km_aprox_recorridos := km_desde_ult_orden + km_promedio_extra;
		end if;
	
		if fecha_orden <= limite_inferior_inactivo then
			--por cliente inactivo
			motivo_contacto := 20;
		end if;
	
		select c61 into medio_contacto_preferente from keplersc.kdud where c2=clave_cliente;
			
		
		fecha_programacion := current_date;
	
		if contador_contactos_neg >= max_operaciones then 
			num_dia_programado_neg := num_dia_programado_neg + 1;
			contador_contactos_neg := 0;
		end if;
		fecha_programacion := fecha_programacion + num_dia_programado_neg;
						
		SELECT to_char(fecha_programacion, 'Day') into nombre_dia;
	
		nombre_dia := trim(nombre_dia);
	
		if nombre_dia = 'Sunday' then
			num_dia_programado_neg := num_dia_programado_neg + 1;
			fecha_programacion := fecha_programacion + 1;
		end if;
		
	
	   --si ya pasaron limite de dias o de kilometraje para contacto urgente(N-U), probablemente solo cuando rutina se corra por primera vez
		if current_date - fecha_orden >= dias_urgente or km_desde_ult_orden >= km_necesarios then
		
			if tipo_n_ult_contacto <> 'NU' or  (tipo_n_ult_contacto = 'NU' and ultimo_resultado_tmkt <> 0 and ultimo_accion_tmkt <> 0) then 
		
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('TMKT.', sucursal),0,0, dataxml);
					
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
				folio_contacto_nvo := get_mensaje; 
			
				if motivo_contacto = 11 then
					observacion2 := concat('Sugerido por KM, ha recorrido aprox ',km_desde_ult_orden ,' km. ', ' Promedio por dia: ', kilometros_diarios , ' km. ' );
				end if;
			
				insert into keplersc.kdtmktser2(c1,c2,c3,c4,c5,c6,c7,c8,c9,c11,c12,c14,c18,c19,c20,c22,c23,c24,c25,c26,c28) 
				values(sucursal,folio_contacto_nvo,asesor_elegido,10,fecha_programacion, 10, motivo_contacto,0,0,observacion1,
				observacion2,serie,tipo_servicio_tmkt, 'P', clave_cliente, 'NU', medio_contacto, current_date,'A',fecha_orden,0);
			
			end if;
		
		else
		
			for i in 1..4 loop	

				select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('TMKT.', sucursal),0,0, dataxml);
					
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
				folio_contacto_nvo := get_mensaje; 
			
				if i = 1 then
					medio_contacto := medio_contacto_preferente;
					fecha_N := fecha_programacion;
					tipo_N := recordatorio_ant_1;
				elsif i = 2 then
					dias_sumar := recordatorio_ant_1 - recordatorio_ant_2;
					fecha_N := fecha_programacion + dias_sumar;
					tipo_N := recordatorio_ant_2;
				elsif i = 3 then
					medio_contacto := 0;
					dias_sumar := recordatorio_ant_1 - recordatorio_ant_3;
					fecha_N := fecha_programacion + dias_sumar;
					tipo_N := recordatorio_ant_3;
				elsif i = 4 then
					dias_sumar := recordatorio_ant_1 - recordatorio_ant_4;
					fecha_N := fecha_programacion + dias_sumar;
					tipo_N := recordatorio_ant_4;
				end if;
			
				if motivo_contacto = 11 then
					observacion2 := concat('Sugerido por KM, habra recorrido aprox ',km_aprox_recorridos, ' km dentro de ', tipo_N ,' dias. ', ' Promedio por dia: ', kilometros_diarios , ' km. ');
				end if;
				
				--VCSS 15 oct 2025 Solo se crean contactos N-7, TO DO: Parameterizar
				if tipo_N = 7 then
					insert into keplersc.kdtmktser2(c1,c2,c3,c4,c5,c6,c7,c8,c9,c11,c12,c14,c18,c19,c20,c22,c23,c24,c25,c26,c28) 
					values(sucursal,folio_contacto_nvo,asesor_elegido,10,fecha_N, 10, motivo_contacto,0,0,observacion1,observacion2,serie,
					tipo_servicio_tmkt, 'P', clave_cliente, concat('N-', tipo_N::text), medio_contacto, current_date, 'A', fecha_orden,0);
				end if;
			end loop;
		
		end if;
	
		contador_contactos_neg := contador_contactos_neg + 1;
		
	end if;

	resultado1 := num_dia_programado_neg;
	resultado2 := contador_contactos_neg;

	return query select resultado1, resultado2;	
			

end;
$function$
