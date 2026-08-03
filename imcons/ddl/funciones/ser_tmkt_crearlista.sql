CREATE OR REPLACE PROCEDURE keplersc.ser_tmkt_crearlista(dataxml xml)
 LANGUAGE plpgsql
AS $procedure$
	declare 
	--Descripcion: rutina para crear lista de contactos tmkt
	--Autor: Luis Leal
	--Fecha: 24/03/2022
	--Bitacora de cambios
	--Fecha: 29/06/2023
	--se incorporaron requerimientos toyota
	--Fecha: 12/08/2024
	--se agrego configuracion para sucursal de ventas
		sucursal text;
		suc_ventas text;

		--variables configuracion TMKT
		conf_marca text; 
		km_necesarios numeric;
		limite_inferior_servicio integer;
		limite_superior_servicio integer;
		limite_inferior_entregas integer;
		limite_superior_entregas integer;
		max_oper_servicio integer;
		max_oper_entregas integer;
		limite_inferior_inactivo date;
		dias_urgente integer;
		
		folio_contacto text;
		folio_contacto_nvo text;
		tipo_trabajo text;
		asesor text;
		status_asesor text;
	
		fecha_contacto_duplicado date;
		tipo_contacto numeric;
		motivo_contacto numeric; 
	
		pantalla numeric;
		obs1 text;
		obs2 text;
		obs3 text;
		fol_cita text;
		tipo_tmkt numeric = 0;
		origen text;
		fecha_val_ult_serv date;
		ident_proceso text;
	
		folio_orden text;
		serie text;
		clave_cliente text;
		fecha_orden date;
		puntos_S_F text;
		ult_orden text;
		tipo_punto text;
		medio_contacto int = 0;
		medio_contacto_preferente int = 10;
		fecha_programacion date;
		tip_n text;
		tipo_N numeric;
		fecha_N date;
		nombre_dia text;
		dias_sumar int;
		fecha_vale_salida date;
		res_auto int;
		asesor_elegido text;
		estado_venta numeric;
	
		recordatorio_ant_1 numeric;
		recordatorio_ant_2 numeric;
		recordatorio_ant_3 numeric;
		recordatorio_ant_4 numeric;

		contador_contactos_servicio_neg integer = 0;
		contador_contactos_entregas integer = 0;
		contador_dia_servicio_neg integer = 0;
		contador_dia_entregas integer = 0;
	
		folio_penult_orden text;
		fecha_penult_orden date;
	
		KM_ult_orden numeric;
		KM_penutl_orden numeric;
		KM_calculado numeric;
	
		dias_entre_ordenes numeric;
		km_entre_ordenes numeric;	 
		km_promedio_diario numeric = 50;
		km_promedio_extra numeric;
		dias_desde_ult_orden numeric;
		km_desde_ult_orden numeric;
		
		get_resultado text;
		get_mensaje text; 
		get_adicionales text;
					 
	
	begin 
	
	 	sucursal := (xpath('//k_sucn/text()', dataxml))[1];
	 
	 
	 	--obtener configuraciones TMKT
	 	select c2,c3,c5,c14,c4,c13,c16,c17,c20 ,c21,c22,c23,c24,col_suc_ventas into conf_marca, km_necesarios,
	 	limite_inferior_servicio,limite_superior_servicio,limite_inferior_entregas,limite_superior_entregas, max_oper_servicio,
	 	max_oper_entregas, dias_urgente, recordatorio_ant_1,recordatorio_ant_2,recordatorio_ant_3,recordatorio_ant_4, suc_ventas
	  	from keplersc.kdtmktserconf where c1=sucursal;
	 
	 	limite_inferior_inactivo = current_date - limite_superior_entregas;
	 
	 	--paso1(registra en configuracion TMKT dia en que se recorre rutina)
	 	update keplersc.kdtmktserconf set c6=current_date where c1=sucursal ;
	 
	 	--borra registros que nunca se atendieron
	 	delete from keplersc.kdtmktser2 where c1=sucursal and c5 <= current_date - 30 and c8=0 and c9=0;

		--paso 2 vuelve a crear contactos para contactos pendientes con asesores inactivos
		for folio_contacto,asesor,status_asesor,pantalla,fecha_contacto_duplicado, tipo_contacto,motivo_contacto,
		obs1,obs2,obs3,serie,fol_cita,tipo_tmkt,tipo_trabajo,clave_cliente, tip_n, medio_contacto,origen,fecha_val_ult_serv, ident_proceso
		in select k.c2,k.c3,t.c3,k.c4,k.c5,k.c6, k.c7,k.c11,k.c12,k.c13,k.c14,k.c15,k.c18,k.c19,k.c20,k.c22,k.c23,k.c25,k.c26, k.c28 
		from keplersc.kdtmktser2 as k inner join keplersc.kdsercattmkt as t on k.c3=t.c1 where k.c1=sucursal and k.c8=0 
			loop 	
				if status_asesor = 'I' then
				
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('TMKT.', sucursal),0,0, dataxml);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;
					folio_contacto_nvo := get_mensaje; 
				
					select * into asesor_elegido from keplersc.asesores_tmkt(sucursal,serie);
					
					--duplicar contacto con asesor sin asignar 
					insert into keplersc.kdtmktser2(c1,c2,c3,c4,c5,c6,c7,c8,c9,c11,c12,c13,c14,c15,c18,c19,c20,c22,c23,c24,c25,c26,c28) 
					values(sucursal,folio_contacto_nvo,asesor_elegido,pantalla,fecha_contacto_duplicado,tipo_contacto,motivo_contacto,0,0,obs1,obs2,obs3,
					serie,fol_cita,tipo_tmkt,tipo_trabajo,clave_cliente, tip_n, medio_contacto,current_date,origen,fecha_val_ult_serv,ident_proceso);
				
					--poner que contacto nunca fue realizado
					update keplersc.kdtmktser2 set c8=60 where c1=sucursal and c2=folio_contacto ;
				
				end if;
			end loop;
		
raise notice 'limite_superior_servicio:%; limite_inferior_servicio;%; conf_marca:%',limite_superior_servicio,limite_inferior_servicio,conf_marca;
		--paso3 (crear contactos TMKT para las series con ultima orden de servicio entre las fechas establecidas en la conf TMKT)
		for folio_orden,fecha_orden,clave_cliente, serie in select distinct pun.c3,ord.c11,ord.c12,ord.c14 
			from keplersc.kdvntall as ord inner join keplersc.kdvnpun as pun on ord.c1=pun.c1 and ord.c2=pun.c2 and ord.c3=pun.c3 and pun.c13='S'
			where ord.c1=sucursal and ord.c11 between current_date - limite_superior_servicio and current_date - limite_inferior_servicio
		    and ord.c11 = ( select max(vn.c11) from keplersc.kdvntall vn inner join keplersc.kdvnpun pn on vn.c1=pn.c1
			and vn.c2=pn.c2 and vn.c3=pn.c3 and pn.c13='S' where vn.c1 = ord.c1 and vn.c14=ord.c14) and ord.c15=conf_marca --and c38 = 'S' and c39 > current_date
		    order by ord.c11 desc
			loop
									
				--verificar si no se volvio a comprar serie y esta en inventario
				select c32 into estado_venta from keplersc.kdinf where c1=suc_ventas and c7=serie and c21='USADO';
				if not found then
														 			
					select resultado1,resultado2 into contador_dia_servicio_neg,contador_contactos_servicio_neg  
					from keplersc.ins_tmkt_servicio(contador_contactos_servicio_neg, max_oper_servicio , contador_dia_servicio_neg, 
					fecha_orden , limite_inferior_inactivo ,serie , sucursal , 0, 0, clave_cliente, 0, 0, km_necesarios,
					dias_urgente, recordatorio_ant_1,recordatorio_ant_2,recordatorio_ant_3,recordatorio_ant_4,dataxml);
												
				end if;
																
			end loop;
																				
		
		--paso4 (Crear contactos TMKT para las series con vales de salida entre las fechas establecidas en la conf TMKT)
		for serie, clave_cliente, fecha_vale_salida in select inf.c7,km1.c10,com.c7 from keplersc.kdcomismov as com 
			inner join keplersc.kdinf as inf on com.c1=inf.c1 and com.c8= inf.c2 inner join keplersc.kdm1 as km1 on com.c1=km1.c1 
			and com.c2=km1.c2 and com.c3=km1.c3 and com.c4=km1.c4 and com.c5=km1.c5 and com.c6=km1.c6
			where com.c1 = suc_ventas and com.c7 between current_date - limite_superior_entregas and current_date - limite_inferior_entregas
			and com.c7 = (select max(cm.c7) from keplersc.kdcomismov cm where cm.c1 = com.c1 and cm.c8=com.c8) and inf.c17=conf_marca order by com.c7 desc
			loop	
				
				
				--verificar si no se volvio a comprar serie y esta en inventario
				select c32 into estado_venta from keplersc.kdinf where c1=suc_ventas and c7=serie and c21='USADO';
				if not found then
				  
					--valida si no existe ya una orden de servicio con puntos S para la serie
					select pun.c3 into ult_orden from keplersc.kdvntall as ord inner join keplersc.kdvnpun as pun 
					on ord.c1=pun.c1 and ord.c2=pun.c2 and ord.c3=pun.c3 and pun.c13='S'
					where ord.c1=sucursal and ord.c14=serie limit 1;
					if not found then 
									
						--valida si no existe ya un contacto registrado para la serie 
						select c2 into folio_contacto from keplersc.kdtmktser2 where c1=sucursal and c14=serie limit 1;
						if not found then 
						
							medio_contacto := 0;
							select c61 into medio_contacto_preferente from keplersc.kdud where c2=clave_cliente;
						
							fecha_programacion := current_date;
	
	
							if contador_contactos_entregas >= max_oper_entregas then 
								contador_dia_entregas := contador_dia_entregas + 1;
								contador_contactos_entregas := 0;
							end if;	
							fecha_programacion := fecha_programacion + contador_dia_entregas;
						
							SELECT to_char(fecha_programacion, 'Day') into nombre_dia;
						
							nombre_dia := trim(nombre_dia);
						
							if nombre_dia = 'Sunday' then
								contador_dia_entregas := contador_dia_entregas + 1;
								fecha_programacion := fecha_programacion + 1;
							end if;
							
						
							select * into asesor_elegido from keplersc.asesores_tmkt(sucursal,serie);
						
							--si no han pasado el tiempo para contacto urgente
							if current_date - fecha_vale_salida < dias_urgente then
							
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
									--VCSS 15 oct 2025 Solo se crean contactos N-7, TO DO: Parameterizar
									if tipo_N = 7 then
										insert into keplersc.kdtmktser2(c1,c2,c3,c4,c5,c6,c7,c8,c9,c14,c18,c19,c20,c22,c23,c24,c25,c26,c28) 
										values(sucursal,folio_contacto_nvo,asesor_elegido,10,fecha_N,10,0,0,0,serie,10,'P',clave_cliente, 
										concat('N-',tipo_N::text), medio_contacto,current_date,'A',fecha_vale_salida,0);
									end if;
								end loop;
							
							--si ya paso tiempo para contacto urgente, caso raro, solo cuando la rutina se corre por primera vez
							else 
									select * into asesor_elegido from keplersc.asesores_tmkt(sucursal,serie);			
				
									select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('TMKT.', sucursal),0,0, dataxml);
									if get_resultado = '0' then
										raise exception '%',get_mensaje;
									end if;
									folio_contacto_nvo := get_mensaje; 
								
									insert into keplersc.kdtmktser2(c1,c2,c3,c4,c5,c6,c7,c8,c9,c14,c18,c19,c20,c22,c23,c24,c25,c26,c28) 
									values(sucursal,folio_contacto_nvo,asesor_elegido,10,fecha_programacion,10,0,0,0,serie,10,
									'P',clave_cliente, 'NU', medio_contacto,current_date,'A', fecha_vale_salida,0);
								
							end if;
	
							contador_contactos_entregas := contador_contactos_entregas + 1;
						
						end if;
					
					end if;
				
				end if;

			end loop;
	
		contador_contactos_servicio_neg := 0;
		contador_dia_servicio_neg := 0;
	
		--paso5 (Crear contactos TMKT para las series con mas de 10,000 km recorridos desde ultima orden de servicio)
		for folio_orden,fecha_orden,clave_cliente,serie,KM_ult_orden in select distinct pun.c3,ord.c11,ord.c12,ord.c14,ord.c17
			from keplersc.kdvntall as ord inner join keplersc.kdvnpun as pun on ord.c1=pun.c1 and ord.c2=pun.c2 and ord.c3=pun.c3 and pun.c13='S' 
			where ord.c1=sucursal and ord.c11 between current_date - limite_inferior_servicio and current_date 
		    and ord.c11 = (select max(vn.c11) from keplersc.kdvntall vn inner join keplersc.kdvnpun pn on vn.c1=pn.c1
			and vn.c2=pn.c2 and vn.c3=pn.c3 and pn.c13='S' where vn.c1 = ord.c1 and vn.c14=ord.c14 ) and ord.c15=conf_marca --and c38 = 'S' and c39 > current_date 
		    order by ord.c11 desc
		   	loop 
			   				   	
			   	--verificar si no se volvio a comprar serie y esta en inventario
				select c32 into estado_venta from keplersc.kdinf where c1=suc_ventas and c7=serie and c21='USADO';
				if not found then
				  
			   		--obtener penultima orden
			   		select ord.c11,ord.c17 into fecha_penult_orden, KM_penutl_orden 
		   			from keplersc.kdvntall as ord inner join keplersc.kdvnpun as pun 
		   			on ord.c1=pun.c1 and ord.c2=pun.c2 and ord.c3=pun.c3 and pun.c13='S'
		   			where ord.c1=sucursal and ord.c14=serie and ord.c11 < fecha_orden
				    order by ord.c11 desc limit 1;
				    if found then 
					   dias_entre_ordenes := fecha_orden - fecha_penult_orden;
					   km_entre_ordenes := KM_ult_orden - KM_penutl_orden; 
					   km_promedio_diario := round(km_entre_ordenes/dias_entre_ordenes);
					else
						km_promedio_diario := 50;
					end if;
					dias_desde_ult_orden := current_date - fecha_orden;
					km_desde_ult_orden := km_promedio_diario * dias_desde_ult_orden;
					--promedio multiplicado por los dias que faltan para la fecha recomendable de la cita(recordatorio_ant_1)
					km_promedio_extra := km_promedio_diario * recordatorio_ant_1;
					if km_desde_ult_orden + km_promedio_extra >= km_necesarios then
					
						--crear contacto
						select resultado1,resultado2 into contador_dia_servicio_neg,contador_contactos_servicio_neg 
						from keplersc.ins_tmkt_servicio(contador_contactos_servicio_neg, max_oper_servicio,contador_dia_servicio_neg , 
						fecha_orden , limite_inferior_inactivo , serie , sucursal , 0,km_promedio_diario, clave_cliente, 
						km_desde_ult_orden, km_promedio_extra, km_necesarios, dias_urgente, recordatorio_ant_1,recordatorio_ant_2
						,recordatorio_ant_3,recordatorio_ant_4, dataxml);
					
					end if;

				end if;

		   	end loop;
		  		   
		  
	EXCEPTION
		WHEN others THEN
			ROLLBACK;
			raise exception '%', SQLERRM;
		    
	end;
$procedure$
