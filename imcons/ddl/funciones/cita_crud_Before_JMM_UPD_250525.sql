CREATE OR REPLACE FUNCTION keplersc."cita_crud_Before_JMM_UPD_250525"(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: guarda o modifica cita
--Autor: Luis Leal
--Fecha: 16/05/2022
--Bitacora de cambios
--Miriam Santana:  14/09/2023 Cancelar recordatorios posteriores a la cita, ajusten en la creacion de contacto para confirmacion de cita
--				   18-09-2023 Ajuste no permitir citas en el  mismo horario al mismo asesor, solo valida contra horario de recepcion,
--				   no validar contra horario promesa de entrewga y entrega de ordenes por peticion coord citas Celaya Belem Rodriguez 
--				   Permitir alta de otra cita tipo G- Garantia y tener 2 citas activas una de otro tipo y una G
--				   19/09/2023 - Permitir modificar o cancelar cita a usr con privilegios kdusrinfo
--Luis Leal:	   15/01/2024 Modulo citas en linea
--Miriam Santana:  28/08/2024 Parametrizar la validacion:permitir cita con orden en taller solo si ='S' en param_oper
--Miriam Santana:  16/04/2025 Controlar los horarios de recepcion para todos no solo para kodawari 
declare

	sucursal_id text;
	kodawari text;
	fecha_captura_cita date;
	hora_captura_cita time;
	fecha_cita date;
	hora_cita time;
	fecha_promesa_entrega date;
	hora_promesa_entrega time;
	posible_fecha_entrega date;
	posible_hora_entrega time;
	folio_cita text;
	fol_cita_modificar text;
	folio_tmkt text;
	hrs_cit numeric;
	hrs_entrega numeric;
	recepcionista text;
	recep_horario text;
	puntos text;
	Asesor_TMKT text;
	Asesor_TMKT_anterior text;
	clave_cliente text;
	usuario text;
	tipo_operacion int;
	tipo_cita text;
	observaciones text;
	vin text;
	serie text;
	placas text;
	marca text;
	modelo text;
	anio text;
	kms text;
	codigo text;
	fecha_anterior date;
	hora_anterior text;
	fecha_confirmacion date;
	p_modcitas text = '';
	fecha_vale date;
	folio_cancelar text;--mss
	no_show text;
	alimento text; --LGLG 15/01/24
	bebida text; 
	amenidad text;
	cita_en_linea text;


	max_cts_recep numeric;
	validar_cts_recep numeric;
	validaciones_recep text;
	cts_misma_hora numeric;
	entregas_misma_hora numeric;
	entregas_ords_misma_hora numeric;
	tmkt_activo text;
	fol_cita_activa text;
	orden_abierta text;
	message text;
	recep_activo text;
	mins_cita text;
	mins_entrega text;
	ctd_puntos int;
	estatus_cita int = 0;
	estatus_cita_anterior int = 0;
	reprogramacion int = 0;
	tipo_trabajo text = '';
	tipo_servicio numeric;
	accion_tmkt numeric;

	--puntos
	tipo_punto text;
	tipo_operario text;
	clave_paquete text;
	trabajo_a_realizar text;
	horas text;
	precio_punto text;
	no_puntos int;
	numero_punto int;	
	coincide_ope text;
	clave_campana text;
	campana_igual text;
	clave_operario text;
	horario_inicio text;
	horario_fin text;
	mins_horario_ini text;
	mins_horario_fin text;
	hrs_ini time;
	hrs_fin time;
	col_hrs text ;
	sql_select text;
	datos xml;
	registro text;

	--refs paquetes
	clave_ref text;
	cantidad_ref text;
	ctd_entradas text;
	ctd_salidas text;

	--sintomas
	no_sintomas int;
	tipo_sintoma text;
	clave_sintoma text;
	cmnts_sintoma text;
	punto_sintoma text;
	tipo_pun_sint text;
	nombre_var_punto_sint text;
	contador_sint_por_punto int;

	tipo_serv text = '';		--Tipo servicio en citas: Recoleccion, Servicio a Domicilio, Mantenimiento Express
	ubicacion_serv text = '';	--Ubicacion de servicio en citas
	promocion text = '';		--Promocion aplicable a la cita
	
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

	expSql text;
	strValor text;
	valor text;
	intValor int;
	resultado text = '';
	mensaje text = '';
    adicionales text = '';
 
   	tipo_crud text;  
	
begin 
	
	sucursal_id := (xpath('//document/k_sucN/r1/text()', dataxml))[1]; 
	fol_cita_modificar:= coalesce((xpath('//document/folio_cita/text()', dataxml))[1]::text,'')::text;
	Asesor_TMKT :=  coalesce((xpath('//document/Cve_TMKT/r1/text()', dataxml))[1]::text,'')::text; 
	clave_cliente := (xpath('//document/cliente_id/text()', dataxml))[1]; 

	fecha_captura_cita := ((xpath('//document/fecha_captura/text()', dataxml))[1]::text)::date; 
	hora_captura_cita := ((xpath('//document/hora_captura_cita/text()', dataxml))[1]::text)::time;
		
	fecha_cita := ((xpath('//document/fecha_cita/text()', dataxml))[1]::text)::date; 
	hora_cita :=  ((xpath('//document/hora_cita/text()', dataxml))[1]::text)::time; 
	fecha_promesa_entrega := ((xpath('//document/fecha_entrega/text()', dataxml))[1]::text)::date;  
	hora_promesa_entrega := ((xpath('//document/hora_entrega/text()', dataxml))[1]::text)::time; 
	recepcionista := (xpath('//document/recepcionista/r1/text()', dataxml))[1]; 

	posible_fecha_entrega := ((xpath('//document/posible_fecha_entrega/text()', dataxml))[1]::text)::date;  
	posible_hora_entrega := ((xpath('//document/posible_hora_entrega/text()', dataxml))[1]::text)::time; 

	folio_tmkt := coalesce((xpath('//document/folio_tmkt/text()', dataxml))[1]::text,'')::text;

	vin := coalesce((xpath('//document/vin/text()', dataxml))[1]::text,'')::text; 
	placas := coalesce((xpath('//document/placas/text()', dataxml))[1]::text,'')::text; 
 	marca := (xpath('//document/marca/text()', dataxml))[1];
	modelo := (xpath('//document/modelo/text()', dataxml))[1];
	serie := coalesce((xpath('//document/serie/text()', dataxml))[1]::text,'')::text; 
	anio := coalesce((xpath('//document/anio/text()', dataxml))[1]::text,'')::text; 
	kms := coalesce((xpath('//document/kms/text()', dataxml))[1]::text,'0.00')::text; 
	
	observaciones := coalesce((xpath('//document/observaciones/text()', dataxml))[1]::text,'')::text; 
	codigo := coalesce((xpath('//document/codigo/text()', dataxml))[1]::text,'')::text; 
	tipo_cita := (xpath('//document/tipo_cita/r1/text()', dataxml))[1]; 
	puntos := (xpath('//document/tabla_puntos/text()', dataxml))[1];
	usuario := coalesce((xpath('//document/usuario/text()', dataxml))[1]::text,'')::text;
 	tipo_operacion := ((xpath('//document/tipo_operacion/text()', dataxml))[1]::text)::integer; 
 	no_show := coalesce((xpath('//document/no_show/text()', dataxml))[1]::text,'no')::text;

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

 	--LGLG 15/01/24 modulo citas en linea
 	alimento := coalesce((xpath('//document/alimento/text()', dataxml))[1]::text,'')::text;  
 	bebida := coalesce((xpath('//document/bebida/text()', dataxml))[1]::text,'')::text; 
 	amenidad := coalesce((xpath('//document/amenidad/text()', dataxml))[1]::text,'')::text; 
  	cita_en_linea := coalesce((xpath('//document/cita_en_linea/text()', dataxml))[1]::text,'N')::text;
  
   	if tipo_operacion = 0 then
  		tipo_crud := 'A';
  	else
  		tipo_crud := 'M';
  	end if;
 
	-- valida asesor TMKT
	select c3 into tmkt_activo from keplersc.kdsercattmkt where c1=usuario; 
	if found then 
		if tmkt_activo='I' then  
			raise exception 'Usuario Inactivo';
		end if;
		if Asesor_TMKT is null then
			raise exception 'Falta Clave TMKT por llenar';
		end if;
		if tipo_operacion = 0 and usuario <> Asesor_TMKT then 
			if no_show = 'no' then
				raise exception 'El sistema no deja dar de alta una cita para otro asesor de Telemarketing ';
			end if;
		end if;
		--valida que asesor no pueda modificar cita de otro asesor tmkt activo
		if tipo_operacion <> 0 then 
			select tmkt.c1, tmkt.c3 into Asesor_TMKT_anterior, tmkt_activo from keplersc.kdctasser as cit 
			inner join keplersc.kdsercattmkt as tmkt on tmkt.c1=cit.c3 where cit.c1=sucursal_id and cit.c2=fol_cita_modificar;
			if tmkt_activo='A' and usuario <> Asesor_TMKT_anterior  then 
				raise exception 'El sistema no deja Modificar una cita que pertenece a otro asesor de Telemarketing que esta Activo, Para Modificar solicite a sistemas que inactive al asesor anterior de TMKT';
			end if;
		end if;
		
	else 
		--MSS Permitir modificar o cancelar cita a usr con privilegios
		select c19 into p_modcitas from keplersc.kdusrinfo
			where c1=usuario;
		if found then
			if p_modcitas <> 'S' then
				raise exception 'Su usuario No tiene privilegios para modificar o cancelar citas';
			end if;
		else 
			raise exception 'Solo Asesores TMKT o con privilegios pueden crear, modificar o cancelar citas';
		end if;
	end if;
	
	--Si es un alta o modificacion
	if tipo_operacion <> 2 then
	
		if recepcionista is null then
			raise exception 'Falta recepcionista por llenar';
		end if;
	
		if fecha_cita is null or hora_cita is null then
			raise exception 'Debe llenar fecha y hora de la cita';
		end if;
	
		if fecha_promesa_entrega is null or hora_promesa_entrega is null then
			raise exception 'Debe llenar fecha y hora de la promesa de entrega';
		end if;
	
		if clave_cliente is null then
			raise exception 'Debe seleccionar la clave del cliente';
		end if;
	
		if marca is null or modelo is null then
			raise exception 'Debe llenar marca y modelo';
		end if;

		--valida recepcionista 
		if tipo_operacion = 0 or tipo_operacion = 1 then 
			select c11 into recep_activo from keplersc.kdrecep where c1=recepcionista; 
			if recep_activo = 'N' then
				raise exception 'Recepcionista inactivo';
			end if;
		end if;
		
		--valida fecha
		if fecha_cita < fecha_captura_cita then
			raise exception 'La cita tiene que tener una Fecha igual o posterior al dia de su captura';	
		end if;
		if fecha_promesa_entrega < fecha_cita then
			raise exception 'La Promesa de entrega tiene que tener una Fecha igual o posterior a la fecha de la cita';	
		end if;
	
		--valida minutos
		--VCSS Integracion de recepcion y entrega cada 20 mins, requerimiento deGM
		select count(*) into intValor from keplersc.param_oper where parametro = 'esquema horas recepcion';
		if intValor > 0 then
			select oper.valor into strValor from keplersc.param_oper oper where oper.parametro = 'esquema horas recepcion'; 
		else
			strValor='15'; --Default
		end if;
		intValor:=strValor::int;
		if intValor <> 20 then
			intValor:=15; --Valor por defecto
		end if;		

		if intValor=15 then
			mins_cita := right(left(hora_cita::text,5)::text,2);
			if mins_cita <> '00' and mins_cita <> '15' and mins_cita <> '30' and mins_cita <> '45' then 
				raise exception 'Solo se permiten los siguientes minutos en la cita 00,15,30,45 '; 
			end if;
			mins_entrega := right(left(hora_promesa_entrega::text,5)::text,2);
			if mins_entrega <> '00' and mins_entrega <> '15' and mins_entrega <> '30' and mins_entrega <> '45' then 
				raise exception 'Solo se permiten los siguientes minutos en la entrega 00,15,30,45 '; 
			end if;
		else
			mins_cita := right(left(hora_cita::text,5)::text,2);
			if mins_cita <> '00' and mins_cita <> '20' and mins_cita <> '40' then 
				raise exception 'Solo se permiten los siguientes minutos en la cita 00,20,40'; 
			end if;
			mins_entrega := right(left(hora_promesa_entrega::text,5)::text,2);
			if mins_entrega <> '00' and mins_entrega <> '20' and mins_entrega <> '40' then 
				raise exception 'Solo se permiten los siguientes minutos en la entrega 00,20,40'; 
			end if;
		end if;
		--valida hora	
		if fecha_cita = fecha_captura_cita then
			if hora_cita < hora_captura_cita then
				raise exception 'La hora de la cita no puede ser antes que la de captura';	
			end if;
		end if;
	
		--valida tiempo	
		/*if fecha_promesa_entrega < posible_fecha_entrega then
			raise exception 'El dia de entrega es antes del tiempo necesario para hacer el servicio';	
		end if;
	
		if fecha_promesa_entrega = posible_fecha_entrega then
			if hora_promesa_entrega < posible_hora_entrega then
				raise exception 'La hora de entrega es antes del tiempo necesario para hacer el servicio';	
			end if;
		end if;*/
		
		if puntos is null then
			raise exception 'La cita no tiene puntos de trabajo y al menos uno es obligatorio.';
		end if;
	
		--valida si hay citas activas para la serie
		select c2 into fol_cita_activa from keplersc.kdctasser where c1=sucursal_id and c2 <> fol_cita_modificar  
		and c20<=10 and c9=serie and c12 >= fecha_captura_cita limit 1;
		if found then
			if tipo_cita <> 'G' and tipo_operacion = 0 then		--MSS Permitir alta de otra cita tipo G- Garantia y tener 2 citas activas una de otro tipo y una G
				message := concat('El n�mero de SERIE tiene otra cita que no ha sido Concretada con Folio: ',fol_cita_activa, ', Imposible Continuar');
				raise exception '%', message;
			end if;
		else 
			select c2 into fol_cita_activa from keplersc.kdctasser where c1=sucursal_id and c2 <> fol_cita_modificar  
			and c20<=10 and c5=placas and c5 <>'SP' and c5 <> '' and c12 >= fecha_captura_cita limit 1;
			if found then
				if tipo_cita <> 'G' and tipo_operacion = 0 then		--MSS Permitir alta de otra cita tipo G- Garantia y tener 2 citas activas una de otro tipo y una G
					message := concat('Estas placas tienen otra cita que no ha sido Concretada con Folio: ',fol_cita_activa, ', Imposible Continuar');
					raise exception '%', message;
				end if;
			end if;
		end if;
	
		select c9 into kodawari from keplersc.kdconftaller where c2=sucursal_id;
	
		--if kodawari = 'S' then		--MSS 16042025 Controlar horarios de recepcion no solo para kodawari
		
			select c3::numeric,c8::numeric,c14 into max_cts_recep,validar_cts_recep,validaciones_recep from keplersc.kdserconfctas; --where c31=sucursal_id
			if validar_cts_recep= 10 and (tipo_cita='N' or (validaciones_recep='S' and tipo_cita <> 'N')) then 
				
				hrs_cit := left(hora_cita::text,2);
			
				hrs_entrega := left(hora_promesa_entrega::text,2);
												
				--checar que la hora de la cita y de la entrega esten en los horarios del recepcionista	 
				select * into recep_horario from keplersc.kdrecep where c1=recepcionista and (c14<=hrs_cit and c15>=hrs_cit 
				or c16<= hrs_cit and c17>=hrs_cit) and (c14<= hrs_entrega and c15>=hrs_entrega 
				or c16<= hrs_entrega and c17>=hrs_entrega);
				if found then 
					--validar citas al mismo tiempo que cita o entrega
					select count(*) into cts_misma_hora from keplersc.kdctasser	where c1=sucursal_id 
					and c2 <> fol_cita_modificar and c20<=10 and c17=recepcionista 
					and (c12=fecha_cita and c13=LEFT(hora_cita::text,5) 
					--or c12=fecha_promesa_entrega and c13=LEFT(hora_promesa_entrega::text,5)		--18/09/23 MSS se quita validacion fecha promesa de entrega a peticion area de citas Celaya
					);
				
					if cts_misma_hora >= max_cts_recep then			-- MSS: >=
						raise exception ',402, El Asesor de Servicio ya tiene reservado ese horario","Escoja otro horario, u otro Asesor de Servicio';
					end if;
				
					/*	--18/09/23 MSS se quita validacion fecha promesa de entrega y entrega de ordenes a peticion �rea de citas Celaya
					--validar entregas al mismo tiempo que cita o entrega
					select count(*) into entregas_misma_hora from keplersc.kdctasfent as ent 
					inner join keplersc.kdctasser as cit on cit.c1=ent.c1 and cit.c2=ent.c2 where ent.c1=sucursal_id 
					and ent.c2 <> fol_cita_modificar and cit.c17=recepcionista and cit.c20<=10
					and (ent.c3=fecha_promesa_entrega and ent.c4=LEFT(hora_promesa_entrega::text,5) or 
					ent.c3=fecha_cita and ent.c4=LEFT(hora_cita::text,5));
					if entregas_misma_hora >= max_cts_recep then	-- MSS: >=
						raise exception 'El Asesor de Servicio ya tiene reservado ese horario","Escoja otro horario, u otro Asesor de Servicio';
					end if;
				
					--validar entregas de ordenes de servicio al mismo tiempo que cita o entrega
					select count(*) into entregas_ords_misma_hora from keplersc.kdordfent as ent 
					inner join keplersc.kdord as ord on ord.c1=ent.c1 and ord.c2=ent.c2 and ord.c3=ent.c3 
					where ent.c1=sucursal_id and ord.c22=recepcionista
					and (ent.c4=fecha_promesa_entrega and ent.c5= LEFT(hora_promesa_entrega::text,5)
					or ent.c4=fecha_cita and ent.c5= LEFT(hora_cita::text,5) );
					if entregas_ords_misma_hora >= max_cts_recep then	-- MSS: >=
						raise exception 'El Asesor de Servicio ya tiene reservado ese horario","Escoja otro horario, u otro Asesor de Servicio';
					end if;
					*/
				else 
					raise exception 'El Asesor de Servicio no puede recibir o entregar citas en ese horario';
				end if;
			
				--busca si la serie tiene una orden abierta
				--MSS 28/08/24 Parametrizar la validacion:permitir cita con orden en taller solo si ='S' en param_oper
				select coalesce(po.valor,'') into valor from keplersc.param_oper po
					where po.sucursal =sucursal_id and lower(po.parametro)='permitir cita con orden en taller';
				
				select c3 into orden_abierta from keplersc.kdord where c1=sucursal_id and c6=right(serie,8) and c7<=10;
				if found then
					if valor <> 'S' then
						raise exception 'No puede hacer una cita para una unidad que tiene una orden que esta en el Taller';
					end if;
				end if;
			end if;
	
		--end if;	--MSS 16042025 Controlar horarios de recepcion no solo para kodawari
	
		--modificacion
		if tipo_operacion = 1 then  
			select c12,c13,c20 into fecha_anterior, hora_anterior, estatus_cita_anterior 
			from keplersc.kdctasser where c1=sucursal_id and c2=fol_cita_modificar;
			
			if fecha_anterior <> fecha_cita or hora_anterior <> LEFT(hora_cita::text,5) then 
				reprogramacion := 1;	
				estatus_cita_anterior := 30;
				
				--obtener folio nuevo 
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('CITAS.', sucursal_id),0,0, dataxml);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
				folio_cita := get_mensaje; 
				
				--cambiar estatus de cita pasada y asignar folio de cita nueva
				update keplersc.kdctasser set c20=estatus_cita_anterior, c24=folio_cita where c1=sucursal_id and c2=fol_cita_modificar;
				
				mensaje := 'La cita tiene un cambio de fecha y hora. Se considera una reprogramacion. Folio nuevo: ' || folio_cita;
				
			else 
			
				--elimina prepicking  LGLG 15/01/24 
				delete from keplersc.prepicking where c1=sucursal_id and c2=fol_cita_modificar;
				--elimina fecha y hora entrega
				delete from keplersc.kdctasfent where c1=sucursal_id and c2=fol_cita_modificar;
				--elimina sintomas cita 
				delete from keplersc.kdctassint where c1=sucursal_id and c2=fol_cita_modificar;
				--elimina puntos cita 
				delete from keplersc.kdctassermov where c1=sucursal_id and c2=fol_cita_modificar;
				--elimina cita 
				delete from keplersc.kdctasser where c1=sucursal_id and c2=fol_cita_modificar;
				
				folio_cita := fol_cita_modificar;
				estatus_cita := estatus_cita_anterior;
				mensaje := 'Cita modificada correctamente';
							
			end if;
	
		end if;
	
		--si es un alta obten folio
		if tipo_operacion = 0 then 
			--obtener folio nuevo 
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('CITAS.', sucursal_id),0,0, dataxml);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
			folio_cita := get_mensaje; 
		end if;

		--guardar cita  
		insert into keplersc.kdctasser(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,
		c15,c16,c17,c20,c30,c36,c37, 
		tipo_servicio,ubicacion_servicio,calle_rec,num_ext_rec,num_int_rec,
		colonia_rec,poblacion_rec,municipio_rec,estado_rec,cp_rec,
		contacto_rec,fecha_rec,hora_rec,regresa_domicilio,observaciones_rec,promocion,
		col_alimento,col_bebida,col_amenidad, col_cita_en_linea,c19)		
		values(sucursal_id,folio_cita,Asesor_TMKT, clave_cliente,placas,
		vin,marca,modelo,serie,anio,kms::numeric,fecha_cita,LEFT(hora_cita::text,5),fecha_promesa_entrega,
		LEFT(hora_promesa_entrega::text,5),fecha_captura_cita,recepcionista,estatus_cita,observaciones,codigo,tipo_cita,
		tipo_serv,ubicacion_serv,calle_rec,num_ext_rec,num_int_rec,
		colonia_rec,poblacion_rec,municipio_rec,estado_rec,cp_rec,
		contacto_rec,to_date(fecha_rec,'YYYY-MM-DD'),hora_rec,regresa_domicilio,
		observaciones_rec,promocion,alimento,bebida,amenidad, cita_en_linea,tipo_crud);
	
		strValor := (xpath('//document/ctd_puntos/text()',dataxml))[1];
		no_puntos := strValor::integer;	
		ctd_puntos = no_puntos;
	

		--guardar puntos
		for cont in 0..no_puntos - 1 loop
			numero_punto := cont + 1;
		
			tipo_punto := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/tipo_punto/text()',dataxml))[1]::text,'');
			tipo_operario := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/tipo_operario/text()',dataxml))[1]::text,'');
			clave_paquete := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/clave_paquete/text()',dataxml))[1]::text,'');
			trabajo_a_realizar := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/trabajo_a_realizar/text()',dataxml))[1]::text,'');
			horas := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/horas/text()',dataxml))[1]::text,'0');
			clave_campana := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/clave_campana/text()',dataxml))[1]::text,'');
			precio_punto := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/precio_punto/text()',dataxml))[1]::text,'0');
			clave_operario := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/clave_operario/text()',dataxml))[1]::text,'');
			horario_inicio := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/horario_inicio/text()',dataxml))[1]::text,'');
			horario_fin := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/horario_fin/text()',dataxml))[1]::text,'');

				
			if tipo_punto = '' and tipo_operario = '' and clave_paquete = '' and trabajo_a_realizar = '' 
			and horas = ''  and precio_punto = ''  and clave_operario = '' then  
				ctd_puntos = ctd_puntos - 1;
			else 
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
			
			
				if tipo_cita = 'C' then
							
					if no_puntos  > 1 then
						raise exception '%' , 'Las Citas C solo pueden tener un punto G';
					end if;
					
					if tipo_punto <> 'G' then
						raise exception '%', format('Error en punto numero %1$L. Una Cita C debe tener solo un punto G', numero_punto);
					end if;
				
					if clave_campana = '' then
						raise exception '%', format('Error en punto numero %1$L. No tiene una campa�a asignada.', numero_punto);
					end if;
				
				else
				
					if clave_campana <> '' then
						raise exception '%', format('Error en punto numero %1$L. Solo las Citas C pueden tener campa�as.', numero_punto);
					end if;
			
				end if;
			
			
			
				if cita_en_linea <> 'S' then --LGLG 15/01/24 modulo citas en linea

					if horario_inicio = '' or  horario_fin = '' then 
						raise exception '%', format('Faltan llenar la hora inicio y fin para el punto numero %1$L.', numero_punto);
					end if;
				
					--valida horario ini seleccionado 
					mins_horario_ini:= right(left(horario_inicio::text,5)::text,2);
				
					if mins_horario_ini <> '00' and mins_horario_ini <> '15' and mins_horario_ini <> '30' and mins_horario_ini <> '45' then 
						raise exception '%', format('Error en punto numero %1$L. Solo se permiten los siguientes minutos 00,15,30,45', numero_punto);
					end if;
				
					--valida horario fin seleccionado
					mins_horario_fin:= right(left(horario_fin::text,5)::text,2);
					if mins_horario_fin <> '00' and mins_horario_fin <> '15' and mins_horario_fin <> '30' and mins_horario_fin <> '45' then 
						raise exception '%', format('Error en punto numero %1$L. Solo se permiten los siguientes minutos 00,15,30,45', numero_punto);
					end if;
				
		
					hrs_ini := horario_inicio;
					hrs_fin := horario_fin;
				
			
					while hrs_ini < hrs_fin loop
		
						col_hrs := 	concat('h_',  split_part(hrs_ini::text, ':', '1') , '_',split_part(hrs_ini::text, ':', '2')) ;
					
						sql_select := format('select %1$s as registro from keplersc.control_de_citas 
						where col_fecha=%2$L and col_clave_operador=%3$L', col_hrs, fecha_cita, clave_operario);
										
						select query_to_xml(sql_select, false, true, '' ) :: xml into datos;
	
						registro := (xpath('//row/registro/text()', datos))[1];
					
						if registro is null then 
							expSql := format('update keplersc.control_de_citas set %1$s=%2$L where col_fecha=%3$L and col_clave_operador=%4$L',
							col_hrs , concat(folio_cita, '-', tipo_punto), fecha_cita, clave_operario);
							execute expSql;
						else 
						
							if left(registro, 10) <> fol_cita_modificar then
								if registro <> 'COMIDA' then
									raise exception 'Horario % ocupado para el operador %, verifica horarios en control de citas.' , left(hrs_ini::text, 5), clave_operario ;
								end if;
							end if;
						end if;
					
						hrs_ini := hrs_ini + interval '15 minute';
	
					end loop;
				
				else
				
					clave_operario := '';
				
				end if;
				
					
			

				select * into coincide_ope from keplersc.kdpuntop where c1=tipo_punto and c2=tipo_operario;
				if found then 
				
					/*select * into strValor from keplersc.kdctasser as cta inner join keplersc.kdctassermov as mov
					on cta.c1=mov.c1 and cta.c2=mov.c2 where cta.c1=sucursal_id and cta.c12=fecha_cita
					and mov.c10=clave_operario and (mov.c12 >= horario_inicio and mov.c12 < horario_fin or 
					mov.c13 > horario_inicio and mov.c13 < horario_fin );
					if found then
						raise exception '%', format('Error en punto numero %1$L. El horario seleccionado para el operario %2$L acaba de ser reservado por uno de tus compa�eros.', numero_punto, clave_operario);
					end if;*/
						
					insert into keplersc.kdctassermov (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13)
					values(sucursal_id,folio_cita,numero_punto,tipo_punto,tipo_operario,
					clave_paquete,trabajo_a_realizar,precio_punto::decimal,horas::numeric,
					clave_operario,clave_campana, horario_inicio, horario_fin );
				else 
					raise exception '%', format('El punto numero %1$L no coincide con el tipo de Operario que le corresponde.', numero_punto);
				end if;
			
			
				--TODO Prepicking
			
				for clave_ref,cantidad_ref,ctd_entradas,ctd_salidas in select paq.c6, paq.c7, movs.c5, movs.c6
				from keplersc.kdspaqm as paq inner join keplersc.kdinl as movs on movs.c2=paq.c6 
				where paq.c1=marca  and paq.c2=modelo and paq.c4=clave_paquete and movs.c1=sucursal_id
					loop 
						--existencia := ctd_entradas-ctd_salidas;
					
						insert into keplersc.prepicking (c1,c2,c3,c4,c5)
						values(sucursal_id,folio_cita,clave_ref,cantidad_ref::numeric, estatus_cita::numeric);
						
					end loop;
			end if;
		
		end loop ;

	
		strValor := coalesce((xpath('//document/ctd_sintomas/text()',dataxml))[1], '0');
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
			punto_sintoma := coalesce((xpath('//document/tabla_sintomas/r' ||cont||'/punto_sintoma/text()',dataxml))[1]::text,'1');
			
			
			if tipo_sintoma = '' and clave_sintoma = '' and cmnts_sintoma = '' and punto_sintoma = '' then  
				exit;
			else 
				if tipo_sintoma = '' or clave_sintoma = '' or cmnts_sintoma = '' or punto_sintoma = '' then  
					raise exception '%', format('Faltan datos por llenar para el sintoma numero %1$L.', cont + 1);
				end if;
				
				if punto_sintoma::int > ctd_puntos or punto_sintoma::int < 1 then 
					raise exception '%', format('El sintoma numero %1$L no corresponde a ningun punto.', cont + 1);
				end if;
				
				select c4 into tipo_pun_sint from keplersc.kdctassermov 
				where c1=sucursal_id and c2=folio_cita and c3=punto_sintoma::int ;
				if found then 
					if tipo_pun_sint = 'S' or tipo_pun_sint = 'L' then 
						raise exception '%', format('El sintoma numero %1$L no puede corresponder a un punto S o L.', cont + 1);
					end if;
				end if;
				
				nombre_var_punto_sint := format('var.%1$s', punto_sintoma);
				SELECT current_setting(nombre_var_punto_sint) into contador_sint_por_punto;
				contador_sint_por_punto := contador_sint_por_punto + 1;		
				EXECUTE format('SET %I TO %L', nombre_var_punto_sint , contador_sint_por_punto);
							
				insert into keplersc.kdctassint (c1,c2,c3,c4,c5,c6,c7)
				values(sucursal_id,folio_cita,punto_sintoma::integer,contador_sint_por_punto
				,tipo_sintoma, clave_sintoma,cmnts_sintoma );
			
			end if;
				
		end loop ;	 
	
		--guardar fecha y hora entrega
		insert into keplersc.kdctasfent (c1,c2,c3,c4)
		values(sucursal_id,folio_cita,fecha_promesa_entrega,LEFT(hora_promesa_entrega::text,5) );
	
	else
	
		--cancelacion
		update keplersc.kdctasser set c20=40 where c1=sucursal_id and c2=fol_cita_modificar;
	
		mensaje := 'cita cancelada';
		folio_cita := fol_cita_modificar; --LGLG 15/01/24 Citas en linea

	end if;

		
	if cita_en_linea <> 'S' then --LGLG 15/01/24 modulo citas en linea

		--GUARDA TMKT
		if tipo_operacion = 0 then
			select c18,c19,c26 into tipo_servicio,tipo_trabajo,fecha_vale from keplersc.kdtmktser2
			where c1=sucursal_id and c2=folio_tmkt;
		else 
			select c2,c18,c19,c26 into folio_tmkt,tipo_servicio,tipo_trabajo,fecha_vale from keplersc.kdtmktser2 
			where c1=sucursal_id and c15=fol_cita_modificar order by c2 desc limit 1;		
		end if;
		
	
		if folio_tmkt <> '' then 
		
			update keplersc.kdtmktser2 set c14=vin, c20=clave_cliente 
			where c1=sucursal_id and c2=folio_tmkt;
		
			--si es una reprogramacion o una alta 
			if tipo_operacion = 0 or reprogramacion = 1 then
			--Actualizacion de contacto base de la cita(Se agendo cita)
			
				if fecha_cita <= current_date + 1 then 
					if extract(hour from now())<16 then	
					--Recontactar para confirmar cita
						accion_tmkt = 40;
					else
					--Esperar a que cliente se presente a Cita
						accion_tmkt = 30;
					end if;
				else 
					--Recontactar para confirmar cita
					accion_tmkt = 40;
				end if;
			
				update keplersc.kdtmktser2 
				set c4=10, c8=40, c9=accion_tmkt, c10=now(), c11=coalesce(observaciones,''), c15= folio_cita, c27=Asesor_TMKT
				where c1=sucursal_id and c2=folio_tmkt;
			
				--MSS: Cancelar recordatorios posteriores a la cita 
				--c8=21 Cancelado, c9=50 Terminado c29='Se agendo previamente una cita'
				if tipo_cita <> 'G' then	--No cancelar contactos para una G y dejar activo el contacto de la orden adicional activa a la de G
					update keplersc.kdtmktser2 
						set c8=21, c9=50, c10=now(), c29='Se agendo previamente una cita'
					where c1=sucursal_id and c14=vin and c8=0; 
				
				end if;
					
				if to_char(fecha_cita, 'dy') = 'mon' then
					fecha_confirmacion = fecha_cita - 2;
				else 	
					fecha_confirmacion = fecha_cita - 1;
				end if;
			
				if fecha_cita > current_date + 1 then 
				
					--Creacion de contacto de seguimiento de cita(confirmacion)
					--Este registro queda pendiente por atender siempre que la cita
					--no sea para un dia despues
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('TMKT.', sucursal_id),0,0, dataxml);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;
					folio_tmkt := get_mensaje; 
					--MSS:el asesor del nuevo contacto debe ser el base de kdserie, QUITAR COMENTARIO CUANDO YA TENGA DATOS EN KDSERIE.asesor_base_tmkt
					--select asesor_base_tmkt into Asesor_TMKT 
					--	from keplersc.kdserie where c1=vin;					
					insert into keplersc.kdtmktser2
						(c1,c2,c3,c5,c6,
						c7,c14,c15,c18,c19,
						c20,c23,c24,c26) 
					values(sucursal_id,folio_tmkt,Asesor_TMKT,fecha_confirmacion,10,
						30,vin,folio_cita,tipo_servicio,tipo_trabajo,
						clave_cliente,0,now(),fecha_vale);	
				else
				
					if (fecha_cita = current_date + 1) and extract(hour from now())<16 then
						select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('TMKT.', sucursal_id),0,0, dataxml);
						if get_resultado = '0' then
							raise exception '%',get_mensaje;
						end if;
						folio_tmkt := get_mensaje;
						--Crear contacto solo si la cita es para ma�ana y la hora < a las 4
						insert into keplersc.kdtmktser2
							(c1,c2,c3,c5,c6,
							c7,c14,c15,c18,c19,
							c20,c23,c24,c26) 
						values(sucursal_id,folio_tmkt,Asesor_TMKT,fecha_confirmacion,10,
							30,vin,folio_cita,tipo_servicio,tipo_trabajo, 
							clave_cliente,0,now(),fecha_vale);	
					
					end if;
				
				end if;
			
			end if;
			--Cancelar recordatorio de la cita cancelada
			if tipo_operacion = 2 then			--Cancelacion de cita
				select c2 into folio_cancelar from keplersc.kdtmktser2 
					where c15=fol_cita_modificar and c7=30 and c14=vin;
				update keplersc.kdtmktser2 
					set c8=21, c9=50, c10=now(), c29= 'Por cancelacion de cita, usuario ' || usuario
				where c1=sucursal_id and c2=folio_cancelar and c8=0;
			end if;
		end if;
	
	end if;

	resultado := 1;
	if mensaje = '' then
		mensaje := 'Cita guardada:' || folio_cita;
	end if;
	adicionales := folio_cita;
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cita_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
