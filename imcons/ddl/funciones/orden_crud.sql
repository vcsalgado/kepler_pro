CREATE OR REPLACE FUNCTION keplersc.orden_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: guarda o modifica orden
--Autor: Luis Leal
--Fecha: 22/06/2022
--Bitacora de cambios
--Miriam Santana:  05/12/24 Paramerizar folio manual
--Miriam Santana:  14/11/2025 Manejo de campanas para ordenes G o M-Garantia adicional a las C, y ajustes por interface de campanas
declare

		sucursal_id text;
		kodawari text;
		fol_orden_modificar text;
		tipo_orden text;
		folio_orden text;
		hrs_entrega numeric;
		recepcionista text;
		recep_horario text;
		recepcionista_cita text;
		puntos text;
		Asesor_TMKT text;
		recep_anterior text;
		fol_cita_encontrada text;
		usuario text;
		tipo_operacion int;
		fecha_captura_orden date;
		hora_captura_orden time;
	
		--serie
		vin text;
		serie text;
		placas text;
		marca text;
		modelo text;
		anio text;
		kms numeric = 0.00;
		codigo text;
		ult_kms numeric = 0.00;
		ult_visita date;
		penult_kms text;
		penult_visita text;
		kms_promedio_diario numeric = 0.00;
		bonete text;
		siniestro text;
		sql_serie text;
		kms_diferencia numeric;
		dias_diferencia numeric;
		ult_kms_ord numeric = 0.00;
			
		--cliente
		clave_cliente text;
		cliente_nombre text;
		cli_direccion text;
		cli_colonia text;
		cli_poblacion text;
		cli_tel_1 text;
		cli_tel_2 text;
		cli_rfc text;
		cli_cp text;
		cli_num_ext text;
		cli_num_int text;
		cli_municipio text;
		cli_estado text;
		cli_pais text;
		cli_desea_ser_contactado text; 
		
		fecha_original date;
		hora_original time;
		fecha_promesa_entrega date;
		hora_promesa_entrega time;
		max_cts_recep numeric;
		validar_cts_recep numeric;
		validaciones_recep text;
		cts_misma_hora numeric;
		entregas_misma_hora numeric;
		entregas_ords_misma_hora numeric;
		recep_activo text;
		fol_orden_abierta text;
		message text;
		mins_entrega text;
		observaciones text;
	
		--puntos
		tipo_punto text;
		tipo_operario text;
		clave_paquete text;
		trabajo_a_realizar text;
		horas text;
		no_puntos int;
		numero_punto int;	
		ctd_pnts_iguales int;
		ope_permitido text;
		ctd_puntos int;
		pnt_ya_asignado text;
		clave_campana text;
		campana_igual text;
		clave_operario text;
		status_punto text;
	
		--sintomas
		no_sintomas int;
		tipo_sintoma text;
		clave_sintoma text;
		cmnts_sintoma text;
		punto_sintoma text;
		nombre_var_punto_sint text;
		contador_sint_por_punto int;
		tipo_pun_sint text;
	
		--tmkt
		tmkt_folio text;
		tmkt_motivo numeric;
		tmkt_resultado numeric;
		tmkt_accion numeric;
		tmk_folio_orden text;
	
		tipo_serv text = '';		--Tipo servicio: Recoleccion, Servicio a Domicilio, Mantenimiento Express
		ubicacion_serv text = '';	--Ubicacion de servicio
		promocion text = '';		--Promocion aplicable
	
		
		--Datos para recoleccion
		calle_rec text = '';
		num_ext_rec  text = '';
		num_int_rec text = '';
		colonia_rec text = '';
		poblacion_rec text = '';
		municipio_rec text = '';
		estado_rec text = '';
		cp_rec text = '';
		contacto_rec text = '';
		fecha_rec text = '';
		hora_rec text = '';
		regresa_domicilio text = '';
		observaciones_rec text = '';
	
		get_resultado text;
		get_mensaje text; 
		get_adicionales text;
	
		strValor text;
		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
	   
	   	folio_orden_ingresado text;
	   	folioManual text;				--MSS 05122024 Folio manual
	   	
	   	tipo_crud text;
   
	
begin 
	
		sucursal_id := (xpath('//document/k_sucN/r1/text()', dataxml))[1]; 
		fol_orden_modificar:= coalesce((xpath('//document/folio_orden_bus/text()', dataxml))[1]::text,'')::text;
	 	tipo_orden := coalesce((xpath('//document/tipo_orden/r1/text()', dataxml))[1]::text,'')::text; 
	 	recepcionista := (xpath('//document/recepcionista/r1/text()', dataxml))[1]; 
		Asesor_TMKT :=  coalesce((xpath('//document/cve_tmkt/text()', dataxml))[1]::text,'')::text; 
		clave_cliente := (xpath('//document/cliente_id/text()', dataxml))[1]; 
		fol_cita_encontrada :=  coalesce((xpath('//document/folio_cita_encontrada/text()', dataxml))[1]::text,'')::text;
	
		fecha_captura_orden := ((xpath('//document/fecha_captura_orden/text()', dataxml))[1]::text)::date;  
		hora_captura_orden := ((xpath('//document/hora_captura_orden/text()', dataxml))[1]::text)::time; 

		cliente_nombre := coalesce((xpath('//document/cliente_nombre/text()', dataxml))[1]::text,'')::text;
		cli_direccion := coalesce((xpath('//document/cliente_calle/text()', dataxml))[1]::text,'')::text;
		cli_colonia := coalesce((xpath('//document/cliente_colonia/text()', dataxml))[1]::text,'')::text;
		cli_poblacion := coalesce((xpath('//document/cliente_poblacion/text()', dataxml))[1]::text,'')::text;
		cli_tel_1 := coalesce((xpath('//document/cliente_tcasa/text()', dataxml))[1]::text,'')::text;
		cli_tel_2 := coalesce((xpath('//document/cliente_toficina/text()', dataxml))[1]::text,'')::text;
		cli_cp := coalesce((xpath('//document/cliente_cp/text()', dataxml))[1]::text,'')::text;
		cli_num_ext := coalesce((xpath('//document/cliente_ext/text()', dataxml))[1]::text,'')::text;
		cli_num_int := coalesce((xpath('//document/cliente_int/text()', dataxml))[1]::text,'')::text;
		cli_municipio := coalesce((xpath('//document/cliente_municipio/text()', dataxml))[1]::text,'')::text;
		cli_estado := coalesce((xpath('//document/cliente_estado/text()', dataxml))[1]::text,'')::text;
		cli_pais := coalesce((xpath('//document/cliente_pais/text()', dataxml))[1]::text,'')::text;
		cli_rfc := coalesce((xpath('//document/cliente_rfc/text()', dataxml))[1]::text,'')::text;
	
		fecha_promesa_entrega := ((xpath('//document/fecha_entrega/text()', dataxml))[1]::text)::date;  
		hora_promesa_entrega := ((xpath('//document/hora_entrega/text()', dataxml))[1]::text)::time; 
		--MSS 010824
		fecha_original := ((xpath('//document/fecha_original/text()', dataxml))[1]::text)::date;  
		hora_original := ((xpath('//document/hora_original/text()', dataxml))[1]::text)::time; 

	
		vin := coalesce((xpath('//document/vin/text()', dataxml))[1]::text,'')::text; 
		placas := (xpath('//document/placas/text()', dataxml))[1];
	 	marca := (xpath('//document/marca/text()', dataxml))[1];
		modelo := (xpath('//document/modelo/text()', dataxml))[1];
		serie := (xpath('//document/serie/text()', dataxml))[1];
		anio := coalesce((xpath('//document/anio/text()', dataxml))[1]::text,'')::text; 
		kms := (xpath('//document/kms/text()', dataxml))[1];
		bonete :=  coalesce((xpath('//document/bonete/text()', dataxml))[1]::text,'')::text; 
		siniestro := coalesce((xpath('//document/siniestro/text()', dataxml))[1]::text,'')::text; 
		cli_desea_ser_contactado :=  coalesce((xpath('//document/cli_desea_ser_contactado/r0/text()', dataxml))[1]::text,'')::text; 
	
		observaciones := coalesce((xpath('//document/observaciones/text()', dataxml))[1]::text,'')::text; 
		codigo := coalesce((xpath('//document/codigo/text()', dataxml))[1]::text,'')::text; 
		puntos := (xpath('//document/tabla_puntos/text()', dataxml))[1];
	 	tipo_operacion := ((xpath('//document/tipo_operacion/text()', dataxml))[1]::text)::integer; 
		usuario := coalesce((xpath('//document/usuario/text()', dataxml))[1]::text,'')::text;
	
		tipo_serv := (xpath('//document/cmb_tipo_servicio/r1/text()', dataxml))[1];
		ubicacion_serv := (xpath('//document/cmb_ubica_servicio/r1/text()', dataxml))[1];
		calle_rec := (xpath('//document/calle_recoleccion/text()', dataxml))[1];
		num_ext_rec := (xpath('//document/num_ext_recoleccion/text()', dataxml))[1];
		num_int_rec := (xpath('//document/num_int_recoleccion/text()', dataxml))[1];
		colonia_rec := (xpath('//document/colonia_recoleccion/text()', dataxml))[1];
		poblacion_rec := (xpath('//document/poblacion_recoleccion/text()', dataxml))[1];
		municipio_rec := (xpath('//document/municipio_recoleccion/text()', dataxml))[1];
		estado_rec := (xpath('//document/estado_recoleccion/text()', dataxml))[1];
		cp_rec := (xpath('//document/cp_recoleccion/text()', dataxml))[1];
		contacto_rec := (xpath('//document/contacto_recoleccion/text()', dataxml))[1];
		fecha_rec := (xpath('//document/fecha_recoleccion/text()', dataxml))[1];
		hora_rec := (xpath('//document/horario_recoleccion/text()', dataxml))[1];
		regresa_domicilio := (xpath('//document/regresa_domicilio/text()', dataxml))[1];
		observaciones_rec := (xpath('//document/observaciones_recoleccion/text()', dataxml))[1];
		promocion := (xpath('//document/cmb_promocion/r1/text()', dataxml))[1];
		
		if tipo_operacion = 0 then
			tipo_crud := 'A';
		else 
			tipo_crud := 'M';
		end if;
	
		-- valida recepcionista
		/*select c11 into recep_activo from keplersc.kdrecep where c1=usuario; 
		if found then 
			if recep_activo <> 'S' then  
				raise exception 'Usuario Inactivo';
			end if;
			
			if recepcionista is null then
				raise exception 'Falta recepcionista por llenar';
			end if;
			
			if tipo_operacion = 0 and usuario <> recepcionista then 
				raise exception 'El sistema no deja dar de alta una cita para otro Recepcionista ';
			end if;
			--valida que recep no pueda modificar orden de otro recep activo
			if tipo_operacion <> 0 then 
				select recep.c1, recep.c11 into recep_anterior, recep_activo from keplersc.kdord as ord 
				inner join keplersc.kdrecep as recep on recep.c1=ord.c22 
				where ord.c1=sucursal_id and ord.c2=tipo_orden and ord.c3=fol_orden_modificar;
				if tmkt_activo='S' and usuario <> recep_anterior then 
					raise exception 'El sistema no deja Modificar una orden que pertenece a otro Recepcionista que esta Activo, Para Modificar solicite a sistemas que inactive al Recepcionista anterior';
				end if;
			end if;
			
		else 
			raise exception 'Solo Recepcionistas pueden crear o modificar Ordenes.';
		end if;*/
	
		if recepcionista is null then
			raise exception 'Falta recepcionista por llenar';
		else
			select c1 into recepcionista from keplersc.kdrecep where c12=recepcionista;
		end if;
 	
		if clave_cliente is null then
			raise exception 'Debe seleccionar la clave del cliente';
		end if;
	
		if serie is null then
			raise exception 'Debe seleccionar la serie del vehiculo';
		end if;
	
		if marca is null or modelo is null then
			raise exception 'Debe llenar marca y modelo';
		end if;
	
		if fecha_promesa_entrega is null or hora_promesa_entrega is null then 
			raise exception 'Debe llenar fecha y hora de la promesa de entrega';
		end if;
	
		if kms is null then
			raise exception 'Falta Kilometraje por llenar';
		end if;
		if placas is null then
			raise exception 'Faltan placas por llenar';
		end if;
	
		--MSS 020824 Validar fecha no sea futura
		if fecha_captura_orden > current_date then
			raise exception 'La fecha de la orden no puede ser mayor a la fecha del dia de hoy';
		end if;

		if fecha_promesa_entrega < fecha_captura_orden then
			raise exception 'La Promesa de entrega tiene que tener una Fecha igual o posterior a la dia de captura';	
		end if;
	
		--valida minutos
		mins_entrega := right(left(hora_promesa_entrega::text,5)::text,2);
		if mins_entrega <> '00' and mins_entrega <> '15' and mins_entrega <> '30' and mins_entrega <> '45' then 
			raise exception 'Solo se permiten los siguientes minutos 00,15,30,45 '; 
		end if;
	
		--valida hora entrega
		if fecha_promesa_entrega = fecha_captura_orden then
			if hora_promesa_entrega < hora_captura_orden then
				raise exception 'La hora de entrega no puede ser menor a la hora de la orden';	
			end if;
		end if;
		
		if puntos is null then
			raise exception 'La orden no tiene puntos de trabajo y al menos uno es obligatorio.';
		end if;
		
		--TODO, Analizar antes de borrar
		--valida si hay orden abierta para la serie
		/*select c2 into fol_orden_abierta from keplersc.kdord where c1=sucursal_id and c3 <> fol_orden_modificar  
		and c6=right(serie,8) and c7<=10;
		if found then
			message := concat('El numero de SERIE tiene otra orden abierta con Folio: ', fol_orden_abierta, ',  Imposible Continuar');
			raise exception '%', message; 
		end if;*/
		
		select c9 into kodawari from keplersc.kdconftaller where c2=sucursal_id;
	
		if kodawari = 'S' then
		
			--k75 VALIDA_CITA_RECEPCIONISTA
			if tipo_operacion = 0 then
				select c17 into recepcionista_cita from keplersc.kdctasser where c1=sucursal_id and c2=fol_cita_encontrada;
				if found then
					if recepcionista <> recepcionista_cita then
						raise exception 'La cita se agendo para otro recepcionista, Imposible Registrar la orden';	
					end if;
				end if;
			end if;
		
			select c3::numeric,c8::numeric,c14 into max_cts_recep,validar_cts_recep,validaciones_recep from keplersc.kdserconfctas; --where c31=sucursal_id
			if validar_cts_recep= 10 and (tipo_orden='T' or (validaciones_recep='S' and tipo_orden <> 'T')) then
							
				hrs_entrega := left(hora_promesa_entrega::text,2);
			
				--checar que la hora de la entrega este en los horarios del recepcionista	 
				select * into recep_horario from keplersc.kdrecep where c1=recepcionista and (c14<= hrs_entrega and c15>=hrs_entrega) 
				or (c16<= hrs_entrega and c17>=hrs_entrega);
				if found then 
					--validar citas al mismo tiempo que entrega de orden
					select count(*) into cts_misma_hora from keplersc.kdctasser	where c1=sucursal_id 
					and c2 <> fol_cita_encontrada and c20<=10 and c17=recepcionista 
					and c12=fecha_promesa_entrega and c13=LEFT(hora_promesa_entrega::text,5);
					if cts_misma_hora > max_cts_recep then
						raise exception 'El Asesor de Servicio ya tiene reservado ese horario","Escoja otro horario, u otro Asesor de Servicio';
					end if;
				
					--validar entregas de citas al mismo tiempo que entrega de orden
					select count(*) into entregas_misma_hora from keplersc.kdctasfent as ent 
					inner join keplersc.kdctasser as cit on cit.c1=ent.c1 and cit.c2=ent.c2 where ent.c1=sucursal_id 
					and ent.c2 <> fol_cita_encontrada and ent.c3=fecha_promesa_entrega
					and ent.c4=LEFT(hora_promesa_entrega::text,5) and cit.c17=recepcionista and cit.c20<=10 ;
					if entregas_misma_hora > max_cts_recep then
						raise exception 'El Asesor de Servicio ya tiene reservado ese horario","Escoja otro horario, u otro Asesor de Servicio';
					end if;
				
					--validar entregas de ordenes de servicio al mismo tiempo que entrega de orden
					select count(*) into entregas_ords_misma_hora from keplersc.kdordfent as ent 
					inner join keplersc.kdord as ord on ord.c1=ent.c1 and ord.c2=ent.c2 and ord.c3=ent.c3 
					where ent.c1=sucursal_id and ent.c3 <> fol_orden_modificar and ent.c4=fecha_promesa_entrega 
					and ent.c5= LEFT(hora_promesa_entrega::text,5) and ord.c22=recepcionista;
					if entregas_ords_misma_hora > max_cts_recep then
						raise exception 'El Asesor de Servicio ya tiene reservado ese horario","Escoja otro horario, u otro Asesor de Servicio';
					end if;
	
				else 
					raise exception 'El Asesor de Servicio no puede recibir o entregar en ese horario';
				end if;
			
			end if;
	
		end if;
			
		--si es un alta obten folio
		if tipo_operacion = 0 then 
			
			--MSS 05122024 Folio manual
			select coalesce(valor,'') into folioManual from keplersc.param_oper
				where sucursal=sucursal_id and parametro='Folio manual orden';
			if folioManual = 'S' then						--MSS 05122024 Folio manual
				---folio manual 
				folio_orden_ingresado := coalesce((xpath('//document/folio_orden_bus/text()', dataxml))[1]::text,'')::text;
			
				if folio_orden_ingresado = '' then
					raise exception 'Debe ingresar un folio para la orden.' ;
				end if;
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.valida_folio_orden_ingresado(concat(sucursal_id,'.',folio_orden_ingresado));
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
				folio_orden := get_mensaje;				 
			else
				--obtener folio nuevo 
--				select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('ORDENES.', sucursal_id),0,0, dataxml);
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_orden(sucursal_id, tipo_orden,'ORDENES');
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
				folio_orden := get_mensaje;
			end if;
		
			--Estas lineas se pasan debajo del insert para efecto de BP VS 26-05-25
			--K75 AMARRA CITA
			--update keplersc.kdctasser set c20=20, c21=tipo_orden , c22=folio_orden
			--where c1=sucursal_id and c2=fol_cita_encontrada;
		
			--UPDATE prepicking 
			update keplersc.prepicking set c5=20 where c1=sucursal_id and c2=fol_cita_encontrada;
	
			--K75 GUARDA_TMKT
			select c2,c7,c8,c9 into tmkt_folio, tmkt_motivo, tmkt_resultado, tmkt_accion
			from keplersc.kdtmktser2 where c1=sucursal_id and c14=right(serie,8) and c15=fol_cita_encontrada;
			if found then
				--Agrega Orden a ultimo contacto TMKT solo si en este se confirmo cita de servicio
				-- tmkt_motivo=Confirmar Cita de Servicio,tmkt_resultado=Se confirmo cita de servicio,tmkt_accion=Esperar a que cliente se presente a Cita
				if tmkt_motivo = 30 and tmkt_resultado = 50 and tmkt_accion= 30 then 
				 	update keplersc.kdtmktser2 set c16=tipo_orden,c17=folio_orden where c1=sucursal_id and c2=tmkt_folio;
				end if;
			end if;
		
			--guardar fecha y hora entrega
			insert into keplersc.kdordent (c1,c2,c3,c4,c5,c6,c7)
			values(sucursal_id,tipo_orden,folio_orden,fecha_promesa_entrega,LEFT(hora_promesa_entrega::text,5),
			fecha_promesa_entrega,LEFT(hora_promesa_entrega::text,5));
		
			--dando de alta orden para poder hacer reportes varios
			insert into keplersc.kdtord(c1,c2,c3,c4,c5)
			values(sucursal_id,tipo_orden,folio_orden,recepcionista,fecha_captura_orden);

		
		else --es una modificacion
			--MSS 020824 Actualizar fecha y hora original, cuando cambio de fecha orden G
			update keplersc.kdordent set c2=tipo_orden, c4=fecha_promesa_entrega , c5=LEFT(hora_promesa_entrega::text,5),
			c6= fecha_original, c7= LEFT(hora_original::text,5)
			where c1=sucursal_id and c2=tipo_orden and c3=fol_orden_modificar;
		
			--elimina fecha y hora entrega orden
			delete from keplersc.kdordfent where c1=sucursal_id and c2=tipo_orden and c3=fol_orden_modificar;
				
			delete from keplersc.kdordsint where c1=sucursal_id and c2=tipo_orden and c3=fol_orden_modificar;
			--elimina orden  
			delete from keplersc.kdord where c1=sucursal_id and c2=tipo_orden and c3=fol_orden_modificar;
				
			folio_orden := fol_orden_modificar;
			mensaje := 'Orden modificada correctamente';	
			
			
		
		end if;
		
		--MSS 23102024 No permitir grabar registros con folio de orden en blanco
		if folio_orden = '' then
			raise exception 'El no. de la orden no puede estar en blanco....Verifique' ;
		end if;
		--guardar orden,  TODO ver si insertar c46,c47,c51, K75 MODIFICA_DATOS_ORDEN
		insert into keplersc.kdord(c1,c2,c3,c4,c5,c6,c10,c11,c12,c13,c14,c15,c16,
		c17,c18,c56,c57,c58,c59,c60,c19,c20,c21,c22,c24,c36,c53,c55,
		tipo_servicio,ubicacion_servicio,calle_rec,num_ext_rec,num_int_rec,
		colonia_rec,poblacion_rec,municipio_rec,estado_rec,cp_rec,
		contacto_rec,fecha_rec,hora_rec,regresa_domicilio,observaciones_rec,promocion,c9) 
		values(sucursal_id,tipo_orden, folio_orden, fecha_captura_orden, hora_captura_orden::text ,right(serie, 8),
		clave_cliente, cliente_nombre,cli_direccion, cli_colonia,cli_poblacion,cli_tel_1,cli_tel_2,
		cli_rfc,cli_cp,cli_num_ext,cli_num_int,cli_municipio,cli_estado,cli_pais, bonete,kms, placas,
		recepcionista, observaciones, left(hora_captura_orden::text,2)::numeric,cli_desea_ser_contactado,siniestro,
		tipo_serv,ubicacion_serv,calle_rec,num_ext_rec,num_int_rec,
		colonia_rec,poblacion_rec,municipio_rec,estado_rec,cp_rec,
		contacto_rec,to_date(fecha_rec,'YYYY-MM-DD'),hora_rec,regresa_domicilio,observaciones_rec,promocion,tipo_crud);
	
		if tipo_operacion = 0 then
			--K75 AMARRA CITA
			update keplersc.kdctasser set c20=20, c21=tipo_orden , c22=folio_orden
			where c1=sucursal_id and c2=fol_cita_encontrada;
		end if;
		
		--guardar fecha y hora entrega
		insert into keplersc.kdordfent (c1,c2,c3,c4,c5) values(sucursal_id,tipo_orden,
		folio_orden,fecha_promesa_entrega,LEFT(hora_promesa_entrega::text,5));
	
	
		strValor := (xpath('//document/ctd_puntos/text()',dataxml))[1];
		no_puntos := strValor::integer;	
		ctd_puntos = no_puntos;
		
		for cont in 0..no_puntos - 1 loop
			numero_punto := cont + 1;
		
			tipo_punto := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/tipo_punto/text()',dataxml))[1]::text,'');
			tipo_operario := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/tipo_operario/text()',dataxml))[1]::text,'');
			clave_paquete := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/clave_paquete/text()',dataxml))[1]::text,'');
			trabajo_a_realizar := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/trabajo_a_realizar/text()',dataxml))[1]::text,'');
			clave_campana := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/clave_campana/text()',dataxml))[1]::text,'');
			horas := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/horas/text()',dataxml))[1]::text,'0');
			clave_operario := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/clave_operario/text()',dataxml))[1]::text,'');

			if tipo_punto = '' and tipo_operario = '' and clave_paquete = '' and trabajo_a_realizar = '' 
				and horas = '' and clave_campana = '' and clave_operario = '' then  
				raise exception '%', format('Error , No puedes dejar en blanco el punto numero %1$L', numero_punto);
			end if;
			
			if tipo_punto = '' or tipo_operario = '' or trabajo_a_realizar = '' or clave_operario = '' then  
				raise exception '%', format('Faltan datos por llenar para el punto numero %1$L.', numero_punto);
			end if;
						
			if tipo_punto = 'S' then 
				if clave_paquete = '' then
					raise exception '%', format('Error en punto numero %1$L. Los puntos S deben tener un paquete.', numero_punto);
				end if;
			else
				if clave_paquete <> '' then
					raise exception '%', format('Error en punto numero %1$L. Solo los puntos S pueden tener paquetes.', numero_punto);
				end if;
			end if;
		
		
			if tipo_orden = 'C' then
			
				if no_puntos > 1 then
					raise exception '%' , 'Las Ordenes C solo pueden tener un punto G';
				end if;
			
				if tipo_punto <> 'G' then
					raise exception '%', format('Error en punto numero %1$L. Una Orden C debe tener solo un punto G', numero_punto);
				end if;
								
				if clave_campana = '' then
					raise exception '%', format('Error en punto numero %1$L. No tiene una campana asignada.', numero_punto);
				end if;
				--MSS 11112025 Le pongo comentario a las sig. lineas, el registro de las campanas se paso a la funcion cerrar_orden 
				/*
				update keplersc.kdsercampana set c4=10, c5=fecha_captura_orden, c7=tipo_orden,c8=folio_orden 
				where (c1=vin or c2= serie) and c3=clave_campana and c6=sucursal_id;
				*/
			else
				if tipo_orden <> 'G' and tipo_orden <> 'M' then		--MSS 14112025 Agregar manejo de campanas para ordenes de garantia G o M
					if clave_campana <> '' then
						raise exception '%', format('Error en punto numero %1$L. Solo las Ordenes C,G o M pueden tener campañas.', numero_punto);
					end if;
				end if;
			end if;
				
		
			select c2 into ope_permitido from keplersc.kdpuntop where c1=tipo_punto and c2=tipo_operario;
			if found then 
							
				select c7 into status_punto from keplersc.kdpun where c1=sucursal_id and c2=tipo_orden 
				and c3=folio_orden and c4 = numero_punto ;
				if found then
					if status_punto <> 'P' then
					
						--verifica si se modifico punto
						select c7 into status_punto from keplersc.kdpun where c1=sucursal_id and c2=tipo_orden 
						and c3=folio_orden and c4=numero_punto and c5=clave_paquete and c6=tipo_punto 
						and c8=trabajo_a_realizar and c37=tipo_operario and c40=horas::numeric 
						and c50=clave_campana and c9=clave_operario  ;
						if not found then 
							raise exception '%', format('Error en punto numero %1$L. Solo se pueden modificar puntos con status P.', numero_punto);
						end if;
					else
						
						update keplersc.kdpun set c5=clave_paquete , c6=tipo_punto, c8=trabajo_a_realizar,
						c37=tipo_operario, c40=horas::numeric, c50=clave_campana, c9=clave_operario
						where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto;
					end if;
					
				else
					
					insert into keplersc.kdpun (c1,c2,c3,c4,c5,c6,c7,c8,c37,c40,c41,c50,c9)
					values(sucursal_id,tipo_orden,folio_orden,numero_punto,clave_paquete, tipo_punto,'P',
					trabajo_a_realizar,tipo_operario,horas::numeric,fecha_captura_orden, clave_campana,clave_operario);
						
				end if;
		
			else 
				raise exception '%', format('El punto numero %1$L no coincide con el tipo de Operario que le corresponde.', numero_punto);
			end if;
			
				
		end loop ;
		
		strValor := (xpath('//document/ctd_sintomas/text()',dataxml))[1];
		no_sintomas := strValor::integer;	
			
		--crea variables dinamicas para sintomas 
		for cont in 0..no_sintomas - 1 loop
		
			punto_sintoma := coalesce((xpath('//document/tabla_sintomas/r' ||cont||'/punto_sintoma/text()',dataxml))[1]::text,'1');
			nombre_var_punto_sint := format('var.%1$s', punto_sintoma);
			EXECUTE format('SET %I TO %L', nombre_var_punto_sint , 0);
				
		end loop ;	 
		
		--guardar sintomas
		for cont in 0..no_sintomas - 1 loop
		
			tipo_sintoma := coalesce((xpath('//document/tabla_sintomas/r' ||cont||'/tipo_sintoma/text()',dataxml))[1]::text,'');
			clave_sintoma := coalesce((xpath('//document/tabla_sintomas/r' ||cont||'/clave_sintoma/text()',dataxml))[1]::text,'');
			cmnts_sintoma := coalesce((xpath('//document/tabla_sintomas/r' ||cont||'/cmnts_sintoma/text()',dataxml))[1]::text,'');
			punto_sintoma := coalesce((xpath('//document/tabla_sintomas/r' ||cont||'/punto_sintoma/text()',dataxml))[1]::text,'');
			
			if tipo_sintoma = '' and clave_sintoma = '' and cmnts_sintoma = '' and punto_sintoma = '' then  
				raise exception '%', format('Error , No puedes dejar en blanco el sintoma numero %1$L.', cont + 1);
			end if;
			
			if tipo_sintoma = '' or clave_sintoma = '' or cmnts_sintoma = '' or punto_sintoma = '' then  
				raise exception '%', format('Faltan datos por llenar para el sintoma numero %1$L.', cont + 1);
			end if;
				
			if punto_sintoma::int > ctd_puntos or punto_sintoma::int < 1 then 
				raise exception '%', format('El sintoma numero %1$L no corresponde a ningun punto.', cont + 1);
			end if;
				
			select c6 into tipo_pun_sint from keplersc.kdpun 
			where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=punto_sintoma::int;
			if found then 
				if tipo_pun_sint = 'S' or tipo_pun_sint = 'L' then 
					raise exception '%', format('El sintoma numero %1$L no puede corresponder a un punto S o L.', cont + 1);
				end if;
			end if;
					
			nombre_var_punto_sint := format('var.%1$s', punto_sintoma);
			SELECT current_setting(nombre_var_punto_sint) into contador_sint_por_punto;
			contador_sint_por_punto := contador_sint_por_punto + 1;		
			EXECUTE format('SET %I TO %L', nombre_var_punto_sint , contador_sint_por_punto);
								
			insert into keplersc.kdordsint (c1,c2,c3,c4,c5,c6,c7,c8)
			values(sucursal_id,tipo_orden,folio_orden,punto_sintoma::int,contador_sint_por_punto
			,tipo_sintoma, clave_sintoma,cmnts_sintoma );
						
		end loop ;
	
		--K75 MODIFICA_SERIE
		if serie <> '' then
			--Obtener ultimo kilometraje en orden con estado 50, auto fuera de taller
			select coalesce(c17,0) into ult_kms_ord from keplersc.kdvntall k 
			where c14=right(serie,8) 
			order by c11 desc limit 1;
			
			select c12,c15,c18,c19 into ult_kms,ult_visita,penult_kms,penult_visita
			from keplersc.kdserie where c1=right(serie,8);
			sql_serie := format(' update keplersc.kdserie set c9=%1$L,c15=%2$L,c16=%3$L ',
			clave_cliente, fecha_captura_orden ,cliente_nombre);
			if codigo <> '' then
				sql_serie := concat(sql_serie,format(' ,c17=%1$L ',codigo));
			end if;
		
			if ult_kms_ord > 0 then
				ult_kms	= ult_kms_ord;
			end if;
		
			if kms > ult_kms then 
				--Obsoleto
				/*kms_diferencia := kms-ult_kms;
				dias_diferencia := current_date - ult_visita;
				if dias_diferencia = 0 or tipo_operacion = 1 then
					if penult_visita <> '' and penult_visita <> '90-01-01' then
						dias_diferencia := current_date - penult_visita::date;
						ult_visita := penult_visita::date;
					else 
						dias_diferencia := 1;
					end if;
					if penult_kms <> '0' then
						kms_diferencia := kms-penult_kms::numeric;
						ult_kms := penult_kms::numeric;
					end if;
				end if;
				kms_promedio_diario := kms_diferencia/dias_diferencia;*/
				sql_serie := concat(sql_serie,format(' , c12=%1$L',kms ));
			else 
				if kms <> ult_kms then
					raise exception 'El Kilometraje es menor al ultimo registro. (%)',ult_kms;
				end if;
			end if;
			sql_serie := concat(sql_serie, format(' where c1=%1$L',  right(serie,8)));
			execute sql_serie;
		end if;
		
		resultado := 1;
		if mensaje = '' then
			mensaje := 'Orden guardada:' || folio_orden;
		end if;
		adicionales := folio_orden;

		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := 0;
			mensaje := 'orden_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
	
end;
$function$
