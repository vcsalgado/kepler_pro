CREATE OR REPLACE FUNCTION keplersc.cerrar_orden(dataxml xml)
 RETURNS TABLE(reslt text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion:  cerrar orden 
--Autor: Luis Leal
--Fecha: 01/11/2022
--Bitacora de cambios
--Luis Leal: 24/10/24 Programa Lealtad
--18/09/2025 Miriam Santana: Registrar el movimiento en bitacora
--11/11/2025 Miriam Santana: Registrar campanas realizadas en KDSERCAMPANA
declare
		sucursal_id text;
		f_orden text;
		t_orden text;
		vin text;
		fecha_seguimiento_posventa date;
		hora_seguimiento_posventa time;
		clave_autorizacion text;
		hora int;
		minutos text;
		dos_puntos text;
		estatus_encuesta numeric;
		num_dia numeric;
		ctd_encuesta numeric;
		kms_sal text;
		kms_entrada numeric;

		val_kodawari text;
		val_cierre_internas text;
		privilegio_cierre_internas text;
	
		flujo_admon numeric;
		flujo_servicio numeric;
		encuesta_estatus numeric;
		time_stamp_seguimiento text;
		diferencia_hrs numeric;
		hrs_minimas_seguimiento numeric;
		hrs_maximas_seguimiento numeric;
		llamadas_por_cuarto_de_hora numeric;
		ctd_registro_calidad numeric;
		registro_actividades text;
		registro_calidad text;
		tipo_punto text;
		clave_paq text;
		status_punto text;
		cerrado_ref_internas text;
		cerrado_tabulacion text; 
		cerrado_tots text; 
		cerrado_cargos_varios text;
		ctd_cierracalidad numeric ;
		precio_publico numeric ;
		numero_punto numeric;
	
	
		mano_obra numeric;
		refacciones numeric;
		tots numeric;
		cargos_varios numeric;
		--cfdi no calculos
		subtotal numeric;
		iva numeric;
		importe numeric;	
	
		--LGLG 24/10/24
		fol_tarjeta_lealtad text;
		partida numeric;
		area_negocio text;
		var_1 numeric;
		var_2 numeric;
		mano_obra_lealtad numeric;
		refacciones_lealtad numeric;
		tots_lealtad numeric;
		cargos_varios_lealtad numeric;
		subtotal_lealtad numeric;
		iva_lealtad numeric;
		importe_lealtad numeric;
		mano_obra_desc_total numeric;
		refs_desc_total numeric;
		tots_desc_total numeric;
		cargos_varios_desc_total numeric;
		iva_default numeric;
		iva_r numeric;
		iva_t numeric;
		iva_c numeric;
		iva_h numeric;

		gen_mov text = '';
		nat_mov text = '';
		gpo_mov numeric = 0;
		tipo_mov numeric =0;
		folio_mov text = '';
		--
		usuario text;
		estatus_servicio numeric = 0;
		desc_act text;
		resultado_encuesta text;
	
		get_resultado text;
		get_mensaje text; 
		get_adicionales text;
	
		totReg numeric(1);
		valor text;
		strValor text;
		reslt text;
		mensaje text = '';
	    adicionales text = '';
	   
	   	varXml xml;
	   
	   	cve_campana text = '';		--MSS 11112025 Regisrar campanas
   
begin 
	
		sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1]; 
		f_orden := coalesce((xpath('//document/folio_orden/text()', dataxml))[1]::text,'')::text;
	 	t_orden := coalesce((xpath('//document/tipo_orden/text()', dataxml))[1]::text,'')::text; 
	 	vin := coalesce((xpath('//document/vin/text()', dataxml))[1]::text,'')::text; 
	  	fecha_seguimiento_posventa := ((xpath('//document/k_fecha/text()', dataxml))[1]::text)::date; 
	  	hora_seguimiento_posventa  := ((xpath('//document/k_hora/text()', dataxml))[1]::text)::time; 
	  	clave_autorizacion  := ((xpath('//document/clave_autorizacion/text()', dataxml))[1]::text)::text; 
	  	kms_sal := coalesce((xpath('//document/kms_salida/text()', dataxml))[1],'0')::text;
	 	
	  	mano_obra := coalesce((xpath('//document/mano_obra/text()', dataxml))[1]::text,'0.00')::text; 
	  	refacciones := coalesce((xpath('//document/refacciones/text()', dataxml))[1]::text,'0.00')::text; 
	  	tots := coalesce((xpath('//document/tots/text()', dataxml))[1]::text,'0.00')::text; 
	  	cargos_varios := coalesce((xpath('//document/cargos_varios/text()', dataxml))[1]::text,'0.00')::text; 
	  	
	  	--cfdi no calculos
	  	subtotal := coalesce((xpath('//document/subtotal/text()', dataxml))[1]::text,'0.00')::text; 
	  	iva := coalesce((xpath('//document/iva/text()', dataxml))[1]::text,'0.00')::text; 
	  	importe := coalesce((xpath('//document/importe/text()', dataxml))[1]::text,'0.00')::text; 
	  
	  	--LGLG 24/10/24
	  	fol_tarjeta_lealtad := coalesce((xpath('//document/tarjeta_lealtad/text()', dataxml))[1]::text,'')::text;
	   	mano_obra_lealtad := coalesce((xpath('//document/mano_obra_lealtad/text()', dataxml))[1]::text,'0.00')::text; 
	  	refacciones_lealtad := coalesce((xpath('//document/refacciones_lealtad/text()', dataxml))[1]::text,'0.00')::text; 
	  	tots_lealtad := coalesce((xpath('//document/tots_lealtad/text()', dataxml))[1]::text,'0.00')::text; 
	  	cargos_varios_lealtad := coalesce((xpath('//document/cargos_varios_lealtad/text()', dataxml))[1]::text,'0.00')::text; 
	  	subtotal_lealtad := coalesce((xpath('//document/subtotal_lealtad/text()', dataxml))[1]::text,'0.00')::text; 
	  	iva_lealtad := coalesce((xpath('//document/iva_lealtad/text()', dataxml))[1]::text,'0.00')::text; 
	  	importe_lealtad := coalesce((xpath('//document/importe_lealtad/text()', dataxml))[1]::text,'0.00')::text; 

	  	--
	  	usuario  := ((xpath('//document/usuario/text()', dataxml))[1]::text)::text; 
	  
	  	--LGLG 25/10/24
		select c11 into iva_default from keplersc.kdmargen where c1=t_orden;
		
		--MSS 23122025 Valida si esta cerrada en 0s		
		select count(*) into totReg from keplersc.kdordceros
			where c1=sucursal_id and c2=t_orden and c3=f_orden;
		if totReg > 0 then
			raise exception 'La orden %  ya se encuentra cerrada en 0s',f_orden;
		end if;

	  	--Validar que la orden pueda cambiar su estatus a cerrada dependiendo del estatus actual
	  	--No se pueden cerrar ordens que su estatus sea 40 o 50, se supone que ya pasaron por este proceso
	  	--Integrado por Victor Salgado 04 May 2023
		select c8 into estatus_servicio from keplersc.kdord where c1=sucursal_id and c2=t_orden and c3=f_orden;
		if not found then
			raise exception 'No se encontro registro de la orden.';
		end if;
		if estatus_servicio = 40 then 
			raise exception 'La orden ya esta cerrada';
		end if;
		if estatus_servicio = 50 then --
			raise exception 'La orden ya esta cerrada y facturada';
		end if;	
	
	 	select c7, c9 into val_cierre_internas, val_kodawari from keplersc.kdconftaller where c2=sucursal_id;

	 	--SUB CIERRE_INTERNAS_VALIDO
	 	if t_orden = 'I' then
	 	
	 		select c16 into privilegio_cierre_internas from keplersc.kdusrinfo where c1=usuario ;
	 	
	 		if val_cierre_internas = 'S' and privilegio_cierre_internas <> 'S' then 
	 			raise exception '%', 'Usted no tiene privilegios para cerrar ordenes internas. ';
	 		end if;
	 	
	 	end if;	 	 

	 	--SUB VALIDA_KODAWARI
	 	if t_orden = 'E' or t_orden = 'G' or t_orden = 'H'
	 	or t_orden = 'S' or t_orden = 'T' or t_orden = 'X'  then
	
	 		if val_kodawari = 'S' then 
	 			--MSS: 17/04/2024 Capturar el kms de salida para las ordenes de garantia	 	
	 			if t_orden = 'G' then 
	 				if kms_sal = '' then 
	 					raise exception 'Es necesario capturar el kilometraje de salida para las ordenes de Garantia';
	 				
	 				end if;
	 			end if;	 		
	 			if kms_sal is not null and kms_sal <> '0' then	 			
	 				select c20 into kms_entrada 
	 					from keplersc.kdord
	 					where c1=sucursal_id and c2=t_orden and c3=f_orden;
	 				if kms_sal::numeric < kms_entrada then
	 					raise exception 'El kilometraje de salida no puede ser menor al kilometraje de entrada registrado en la recepcion de la orden';
	 				end if;
	 			end if;
	 			
	 			--FECHA_HORA_VALIDA
	 			if fecha_seguimiento_posventa <= current_date then 
	 				raise exception '%', 'El seguimiento postventa debe ser agendado despues del dia de la entrega.';
	 			end if;
	 		
	 			--HORAS_VALIDA_DOS_PUNTOS
	 			dos_puntos := substring(hora_seguimiento_posventa::text,3, 1);
	 			if dos_puntos = ':' then
	 				dos_puntos := substring(hora_seguimiento_posventa::text,6, 1);
	 				if  dos_puntos <> ':' then
	 					 raise exception '%', 'El formato de la hora debe ser 00:00:00';
	 				end if;
	 			else
	 				raise exception '%', 'El formato de la hora debe ser 00:00:00';
	 			end if;

	 			--HORAS_VALIDA_SPV
	 			hora := substring(hora_seguimiento_posventa::text,1, 2)::int;
	 			if hora < 9 or hora > 19 then 
	 			 	raise exception '%' , 'Solo se permiten horas entre las 09:00 y 19:00';
	 			end if;
	 		
	 			--HORAS_VALIDA_MINUTOS	
	 			minutos := substring(hora_seguimiento_posventa::text,4, 2);
	 			if minutos <> '00' and minutos <> '15' and minutos <> '30' and minutos <> '45' then 
	 				raise exception '%', 'Solo se permiten los siguientes minutos 00,15,30 0 45';
	 			end if;
	 		
	 		
	 			time_stamp_seguimiento := concat(fecha_seguimiento_posventa, ' ', hora_seguimiento_posventa);
	 			select extract ( epoch from ( time_stamp_seguimiento::timestamp - left(current_timestamp::text, 19)::timestamp  )) /60/60 into diferencia_hrs;
	 		
	 			select c4,c5 into hrs_minimas_seguimiento, hrs_maximas_seguimiento from keplersc.kdconfsegpos;
	 			if not found then
	 				hrs_minimas_seguimiento := 72;
	 				hrs_maximas_seguimiento := 120;
	 			end if;
	 			 		
	 			if diferencia_hrs < hrs_minimas_seguimiento then
	 				raise exception 'Esta intentando programar el seguimiento posventa en un lapso menor a % horas', hrs_minimas_seguimiento;
	 			else
	 				if diferencia_hrs > hrs_maximas_seguimiento then
	 					raise exception 'Esta intentando programar el seguimiento posventa en un lapso mayor a % horas', hrs_maximas_seguimiento;
	 				end if;
	 			end if;
	 			
	 			--SUB SEGPOSVENTA_VALIDO
				/*select c6 into estatus_encuesta from keplersc.kdencprog
				where c1=sucursal_id and c2=t_orden and c3=f_orden;
				if found then
				 if estatus_encuesta = 10 then
				 	raise exception '%' , 'La orden ya tiene programado un seguimiento posventa.';
				 else
				 	raise exception '%' , 'La orden ya tiene la encuesta del seguimiento posventa registrada.';
				 end if;
				end if;*/
			
				select extract(dow from fecha_seguimiento_posventa::date) into num_dia;
		
				if num_dia = 0 then
					raise exception '%', 'No es posible agendar el seguimiento posventa en dias DOMINGO.';
				else
					select count(*) into ctd_encuesta from keplersc.kdencprog
					where c1=sucursal_id and c4=fecha_seguimiento_posventa and c5=hora::text and c6=10;
								
					if ctd_encuesta > 0 then
					
						select c3 into llamadas_por_cuarto_de_hora from keplersc.kdconfsegpos;
						if found then
							if ctd_encuesta >= llamadas_por_cuarto_de_hora then
								raise exception '%', 'No hay espacio disponible para esa fecha y hora. Indique otro tiempo por favor.';
							end if;
						else
							if ctd_encuesta >= 1 then
								raise exception '%', 'No hay espacio disponible para esa fecha y hora. Indique otro tiempo por favor.';
							end if;
						end if;

					end if;
				end if;
						
			
				select c6, c7 into registro_actividades, registro_calidad from keplersc.kdconfsegpos;

				--MSS 28/08/24 Parametrizar la validacion:registro de calidad obligatorio en param_oper
				select coalesce(po.valor,'') into valor from keplersc.param_oper po
					where po.sucursal =sucursal_id and lower(po.parametro)='registro calidad obligatorio';

				--SUB REGISTRO_CALIDAD_VALIDO
				if registro_calidad = 'S' then
					select count(*) into ctd_registro_calidad from keplersc.kdpunres where c1=sucursal_id and c2=t_orden and c3=f_orden;
					if ctd_registro_calidad = 0 then
						--TO DO No todas las ordenes llevan el registro de calidad, validar esta excepcion
						if valor = 'S' then			--MSS 28/08/24 Parametrizar la validacion:registro de calidad obligatorio
							raise exception '%' , 'No se encontro el registro de calidad del Jefe de Taller para esta orden, Verifique con el jefe de taller.';
						end if;
					end if;
				end if;
			
				--SUB REGISTRO_ACTPREENT_VALIDO
				if registro_actividades = 'S' then
				
				
					select col_descripcion into desc_act from keplersc.kdordcuest 
					where col_sucursal=sucursal_id and col_tipo_actividad='PRE' 
					and col_tipo_orden=t_orden and col_folio_orden=f_orden;
					if found then
					
					
						for desc_act, resultado_encuesta in select col_descripcion, col_resultado
						from keplersc.kdordcuest where col_sucursal=sucursal_id and col_tipo_actividad='PRE'
						and col_tipo_orden=t_orden and col_folio_orden=f_orden
						loop 
							
							if resultado_encuesta = 'N' then 
							
								raise exception 'Error, La actividad:  %  , no ha sido completada.', desc_act; 
							
							end if;
							
						end loop;
						
					else
					
						raise exception '%', 'No se han registrado las actividades preentrega, registrelas antes de cerrar la orden.';
					
					end if;
				
				
				end if;

	 		end if;

	 	end if;
	 
	 
	 	for numero_punto, clave_paq, tipo_punto, status_punto,cerrado_ref_internas, cerrado_tabulacion, cerrado_tots, cerrado_cargos_varios, cve_campana
		in select c4,c5,c6,c7,c20, c22,c23, c24, c50 from keplersc.kdpun where c1=sucursal_id and c2=t_orden and c3=f_orden 
		loop 
						
			if val_kodawari = 'S' and  ( tipo_punto = 'F' or tipo_punto = 'G' or tipo_punto = 'P') then 
					
				--SUB REGISTRO_CALIDAD_MDT_VALIDO
				select count(*) into ctd_cierracalidad from keplersc.kdscierrecalidad 
				where c1=sucursal_id and c2=t_orden and c3=f_orden;
				
				--MSS 28/08/24 Parametrizar la validacion:cierre de calidad obligatorio en param_oper
				select coalesce(po.valor,'') into valor from keplersc.param_oper po
					where po.sucursal =sucursal_id and lower(po.parametro)='cierre calidad obligatorio';

				if ctd_cierracalidad =  0 then
					--TO DO Validar esta condicion
					if valor = 'S' then			--MSS 28/08/24 Parametrizar la validacion:cierre de calidad obligatorio
						raise exception '%', 'Esta orden tiene que ser Inspeccionada por el MDT,La orden no se puede Cerrar.';
					end if;
				end if;
						
			end if;
				
			if tipo_punto ='S' then
											
				select paq.c10 into precio_publico from keplersc.kdspaq as paq inner join keplersc.kdserie as ser 
				on ser.c2=paq.c1 and ser.c3=paq.c2 where ser.c1=vin and paq.c4=clave_paq;
										
				if precio_publico <= 0 then
					raise exception 'El paquete: % tiene un Precio Publico igual a cero, No puede Cerrar la Orden ', clave_paq;
				end if;
						
			end if;				
				
			if status_punto <> 'N' then
						
				if status_punto <> 'T' then
					raise exception 'El punto numero % no esta terminado en Control.', numero_punto;
				end if;
					
				if cerrado_ref_internas <> 'C' then
					raise exception 'El punto numero % no esta cerrado en Refacciones.', numero_punto;
				end if;
					
				if cerrado_tabulacion <> 'C' then
					raise exception 'El punto numero % no esta cerrado en Tabulacion.', numero_punto;
				end if;
					
				if cerrado_tots <> 'C' then
					raise exception 'El punto numero % no esta cerrado en TOTs.', numero_punto;
				end if;
					
				if cerrado_cargos_varios <> 'C' then
					raise exception 'El punto numero % no esta cerrado en Cargos Varios.', numero_punto;
				end if;
					
			else
				if clave_autorizacion <> 'XX00XX' then -- TODO, funcion que genere clave automatica 
					raise exception '%', 'ATENCION, La orden tiene puntos sin autorizar y no estas autorizado para cerrarla.';
				end if;
			end if;
			--MSS 11112025 Registrar las campañas realizadas
			if t_orden = 'C' or t_orden = 'G' or t_orden = 'M' then
				update keplersc.kdsercampana set c4=10, c5=current_date, c7=t_orden,c8=f_orden 
				where (c1=vin or c2= vin) and c3=cve_campana and c6=sucursal_id;
			
			end if;
					
		end loop;
	
	

			
		---LGLG 24/10/24 PROGRAMA LEALTAD------------------------
	
		select count(*) into totReg from keplersc.kdfoliotarjetalealtad  where c2=fol_tarjeta_lealtad;
		if  totReg > 0 then
			for numero_punto, partida, area_negocio,  var_1, var_2,
				gen_mov,nat_mov,gpo_mov,tipo_mov,folio_mov 
				in select c4, c8, c7, c9, c10
				from keplersc.kdlealtadmovs 
				where c1=sucursal_id and c2=t_orden and c3=f_orden
				order by c4, c8
			loop
							
				if area_negocio = 'R' then 
				
					iva_r := var_1 * (iva_default/100);

					update keplersc.kdref set c16 = var_1 , c15 =var_2,
					c21=iva_r, c22=(var_1 + iva_r)
					where c1=sucursal_id and c2=t_orden and c3=f_orden and c4=numero_punto 
					and c5=gen_mov and c6 =nat_mov and c7=gpo_mov and c8=tipo_mov and c9=folio_mov
					and c10=partida;
				
				elsif area_negocio = 'T' then 
				
					iva_t := var_1 * (iva_default/100);
				
					update keplersc.kdtot set c16 = var_1,
					c18= iva_t, c19= (var_1 + iva_t)
					where c1=sucursal_id and c2=t_orden and c3=f_orden 
					and c4=numero_punto and c15=partida;
				
				elsif area_negocio = 'C' then 
				
					iva_c := var_1 * (iva_default/100);
				
					update keplersc.kdcar set c10 = var_1,
					c11=iva_c, c12= (var_1 + iva_c)
					where c1=sucursal_id and c2=t_orden and c3=f_orden 
					and c4=numero_punto and c5=partida;
	
				elsif area_negocio = 'H' then 
--raise exception 'Ajustando horas var_1 %',var_1;			
					iva_h := var_1 * (iva_default/100);
					
					update keplersc.kdhoras set c14 = var_2 ,
					c17=var_1, c18=iva_h, c19= (var_1 + iva_h)
					where c1=sucursal_id and c2=t_orden and c3=f_orden 
					and c4=numero_punto and c5=partida;
				
				end if;
	
				
			end loop;
		
			delete from keplersc.kdlealtadheader where c1=sucursal_id and c2=t_orden and c3=f_orden;

			mano_obra_desc_total := 0;
			if mano_obra > 0 then
				mano_obra_desc_total := (1-(mano_obra_lealtad/mano_obra))*100;
			end if;
		
			refs_desc_total := 0;
			if refacciones > 0 then
				refs_desc_total := (1-(refacciones_lealtad/refacciones))*100;
			end if;
		
			tots_desc_total := 0;
			if tots > 0 then
				tots_desc_total := (1-(tots_lealtad/tots))*100;
			end if;
		
			cargos_varios_desc_total := 0;
			if cargos_varios > 0 then
				cargos_varios_desc_total := (1-(cargos_varios_lealtad/cargos_varios))*100;
			end if;
		
			insert into keplersc.kdlealtadheader(c1,c2,c3,c4,c5,c6,c7) 
			values(sucursal_id,t_orden,f_orden, mano_obra_desc_total,
			refs_desc_total, tots_desc_total, cargos_varios_desc_total);
		
			if importe_lealtad > 0 then
				mano_obra := mano_obra_lealtad;
				refacciones := refacciones_lealtad;
				tots := tots_lealtad;
				cargos_varios := cargos_varios_lealtad;
				subtotal := subtotal_lealtad;
				iva := iva_lealtad;
				importe := importe_lealtad;
			end if;
		
		end if;
		---------------------------------------------------------------
	
		--cdfi no calculos
		--actualizar los datos de subt,iva y total con los datos que se muestran en pantalla (update c61,c62 y c63)
		--	SUB GUARDA_TOTALES_KDORD
	
		update keplersc.kdord set c7=10, c8=40,c35=current_date, c37=left(current_time::text, 2)::numeric
		,c30=mano_obra::numeric, c31=refacciones::numeric, c32=tots::numeric, c33=cargos_varios::numeric
		,c61=subtotal::numeric, c62=iva::numeric, c63=importe::numeric, kms_salida=kms_sal::numeric
		where c1=sucursal_id and c2=t_orden and c3=f_orden;

		update keplersc.kdtord set c12=current_date where c1=sucursal_id and c2=t_orden and c3=f_orden;
		
		--SUB REGISTRA_SPV
		if t_orden = 'E' or t_orden = 'G' or t_orden = 'H'
		or t_orden = 'S' or t_orden = 'T' or t_orden = 'X'  then
			
			if fecha_seguimiento_posventa is not null and hora_seguimiento_posventa is not null then
			
			 	delete from keplersc.kdencprog where c1=sucursal_id and c2=t_orden and c3=f_orden;
			  
				 insert into keplersc.kdencprog (c1,c2,c3,c4,c5,c6) values(sucursal_id,t_orden,
				 f_orden, fecha_seguimiento_posventa,  left(hora_seguimiento_posventa::text, 5) , 10);
				
			end if;
		
		end if;

		
	
		--MSS 18092025 Registrar el movimiento en bitacora
		select xmlforest(usuario, current_date as fecha, TO_CHAR(NOW(), 'HH24:MI:SS') as hora, 
				sucursal_id as sucursal, ' ' as genero, ' ' as naturaleza, 0 as grupo, 0 as tipo, t_orden || '-' ||f_orden as folio,
				'CERRAR ORDEN' as tipo_movto, ' ' as detalle_movto) :: text into strValor;
				
		select '<document>'||strValor||'</document>' into strValor;
		varXml := strValor::xml;
							
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(varXml);
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;	

		reslt := 1;
		mensaje := 'Orden Cerrada';
		adicionales := f_orden;
		return query select reslt, mensaje, adicionales;	

exception
		when others then
			reslt := 0;
			mensaje := 'cerrar_orden() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select reslt, mensaje, adicionales;	
	
end;
$function$
