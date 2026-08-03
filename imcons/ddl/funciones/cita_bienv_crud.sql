CREATE OR REPLACE FUNCTION keplersc.cita_bienv_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: guarda o modifica cita para evento de bienvenida
--Autor: Miriam Santana
--Fecha: 11/10/2022
--Bitacora de cambios
declare

	sucursal_id text;
	kodawari text;
	fecha_captura_cita date;
	hora_captura_cita time;
	fecha_cita date;
	hora_cita time;
	inventario text;
	folio_cita text;
	fol_cita_modificar text;
	inv_modificar text;
	folio_tmkt text;
	hrs_cit numeric;
	vendedor text;
	tmkt_activo text;
	Asesor_TMKT text;
	Asesor_TMKT_anterior text;
	clave_cliente text;
	usuario text;
	tipo_operacion int;
	tipo_cita text;
	observaciones text;
	medio_preferido text;
	num_preferido text;
	tipo_snack text;
	desc_snack text;
	tipo_bebida text;
	desc_bebida text;
	kms text;
	vin text;
	serie text;
	placas text;
	marca text;
	modelo text;
	anio text;
	color text;
	concesionario text;
	fecha_anterior date;
	hora_anterior text;
	fecha_confirmacion date;
	p_modcitas text = '';
	cve_asistir text;
	persona_evento text;
	asistio_evento text;
	message text;
	estatus_cita int = 0;
	estatus_cita_anterior int = 0;
	reprogramacion int = 0;
	tipo_trabajo text = '';
	tipo_servicio numeric;
	accion_tmkt numeric;

	get_resultado text;
	get_mensaje text; 
	get_adicionales text;

	totReg integer=0;
	strValor text;
	resultado text = '';
	mensaje text = '';
    adicionales text = '';
   
	
begin 
	
	sucursal_id := (xpath('//document/k_sucN/r1/text()', dataxml))[1]; 
	fol_cita_modificar:= coalesce((xpath('//document/folio_cita/text()', dataxml))[1]::text,'')::text;
	Asesor_TMKT :=  coalesce((xpath('//document/Cve_TMKT/r1/text()', dataxml))[1]::text,'')::text; 
	clave_cliente := (xpath('//document/cliente_id/text()', dataxml))[1]; 
	inventario := (xpath('//document/inventario/text()', dataxml))[1];
	fecha_captura_cita := ((xpath('//document/fecha_captura/text()', dataxml))[1]::text)::date; 
	hora_captura_cita := ((xpath('//document/hora_captura_cita/text()', dataxml))[1]::text)::time;
		
	fecha_cita := ((xpath('//document/fecha_cita/text()', dataxml))[1]::text)::date; 
	hora_cita :=  ((xpath('//document/hora_cita/text()', dataxml))[1]::text)::time; 
	vendedor := (xpath('//document/vendedor/text()', dataxml))[1]; 
	persona_evento := (xpath('//document/persona_evento/text()', dataxml))[1]; 
	cve_asistir  := (xpath('//document/cmb_asistira/r1/text()', dataxml))[1];
	folio_tmkt := coalesce((xpath('//document/folio_tmkt/text()', dataxml))[1]::text,'')::text;
	 
	vin := coalesce((xpath('//document/vin/text()', dataxml))[1]::text,'')::text; 
	placas := coalesce((xpath('//document/placas/text()', dataxml))[1]::text,'')::text; 
 	marca := (xpath('//document/marca/text()', dataxml))[1];
	modelo := (xpath('//document/modelo/text()', dataxml))[1];
	serie := coalesce((xpath('//document/serie/text()', dataxml))[1]::text,'')::text; 
	anio := coalesce((xpath('//document/anio/text()', dataxml))[1]::text,'')::text; 
	kms := coalesce((xpath('//document/kms/text()', dataxml))[1]::text,'0.00')::text; 
	medio_preferido := coalesce((xpath('//document/medio_preferido/text()', dataxml))[1]::text,'')::text; 
	num_preferido := coalesce((xpath('//document/num_preferido/text()', dataxml))[1]::text,'')::text; 
	tipo_snack := coalesce((xpath('//document/tipo_snack/r1/text()', dataxml))[1]::text,'')::text; 
	desc_snack := coalesce((xpath('//document/desc_snack/text()', dataxml))[1]::text,'')::text; 
	tipo_bebida := coalesce((xpath('//document/tipo_bebida/r1/text()', dataxml))[1]::text,'')::text;
	desc_bebida := coalesce((xpath('//document/desc_bebida/text()', dataxml))[1]::text,'')::text;
	observaciones := coalesce((xpath('//document/observaciones/text()', dataxml))[1]::text,'')::text; 
	tipo_cita := (xpath('//document/tipo_cita/text()', dataxml))[1]; 
	usuario := coalesce((xpath('//document/usuario/text()', dataxml))[1]::text,'')::text;
 	tipo_operacion := ((xpath('//document/tipo_operacion/text()', dataxml))[1]::text)::integer; 

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
			raise exception 'El sistema no deja dar de alta una cita para otro asesor de Telemarketing ';
		end if;
	else 
			raise exception 'S lo Asesores TMKT o con privilegios pueden crear, modificar o cancelar citas';
	end if;
	
	--Si es un alta o modificacion
	if tipo_operacion <> 2 then
		if inventario is null then
			raise exception 'Es necesario especificar un No. de inventario';
		end if;
		if fecha_cita is null or hora_cita is null then
			raise exception 'Debe llenar fecha y hora de la cita';
		end if;
		if persona_evento is null then
			raise exception 'Falta el nombre de la persona que asistira al evento';
		end if;
		if clave_cliente is null then
			raise exception 'Falta la clave del cliente';
		end if;
	
		if serie is null then
			raise exception 'Falta el No. serie';
		end if;
		if (substring(trim(inventario),8,1)='N') then
			if marca is null or modelo is null then
				raise exception 'Debe llenar marca y modelo';
			end if;
		end if;
		--valida fecha
		if fecha_cita < fecha_captura_cita then
			raise exception 'La cita tiene que tener una Fecha igual o posterior al dia de su captura';	
		end if;
		
		--valida hora	
		if fecha_cita = fecha_captura_cita then
			if hora_cita < hora_captura_cita then
				raise exception 'La hora de la cita no puede ser antes que la de captura';	
			end if;
		end if;
	
		if medio_preferido ='' and num_preferido ='' then 
			raise exception 'Falta especificar el medio y/o el numero preferido de contacto';	
		end if;
		--si es un alta obten folio
		if tipo_operacion = 0 then 
			--obtener folio nuevo 
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('CITAS.', sucursal_id),0,0, dataxml);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
			folio_cita := get_mensaje;
		else 
			folio_cita := fol_cita_modificar;
		end if;
		select c7 into concesionario from keplersc.kdcfdconfig where c1=sucursal_id;
		--guardar cita  
		select count(*) into totReg from keplersc.kdctasbienvser where c15=inventario;
	--raise notice 'inv:% totReg:% foliocita:%', inventario,totReg,folio_cita;
		if totReg = 0 then
			insert into keplersc.kdctasbienvser(
				c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,
				c16,c17,c18,c19,c20,
				c21,c22,c23,c24,c25,
				c29,c30,c31,c32) 
				values(
				sucursal_id,folio_cita,Asesor_TMKT,clave_cliente,placas,
				right(serie,8),marca,modelo,serie,anio,
				kms::numeric,fecha_cita,LEFT(hora_cita::text,5),color,inventario,
				now(),vendedor,persona_evento,'N',0,
				tipo_snack,desc_snack,tipo_bebida,desc_bebida,cve_asistir,
				concesionario,observaciones,medio_preferido,num_preferido);
		else 
			update keplersc.kdctasbienvser 
				set
				c2=folio_cita,
				c3=Asesor_TMKT,
				c5=placas,
				c11=kms::numeric,
				c12=fecha_cita,
				c13=LEFT(hora_cita::text,5),
				c16=now(),
				c18=persona_evento,
				c19='N',
				c20=0,
				c21=tipo_snack,
				c22=desc_snack,
				c23=tipo_bebida,
				c24=desc_bebida,
				c25=cve_asistir,
				c29=concesionario,
				c30=observaciones,
				c31=medio_preferido,
				c32=num_preferido
				where c1=sucursal_id and c15=inventario;
				mensaje := 'Cita guardada correctamente'|| folio_cita;
		end if;	
	else
		--cancelacion
		update keplersc.kdctasbienvser set c20=40 where c1=sucursal_id and c15=inventario;
	
		mensaje := 'cita cancelada';
	
	end if;
raise notice 'Termino de ins o up';
	
	--GUARDA TMKT
	if tipo_operacion = 0 then
		select c18,c19 into tipo_servicio,tipo_trabajo from keplersc.kdtmktser2
		where c1=sucursal_id and c2=folio_tmkt;
	else 
		select c2,c18,c19 into folio_tmkt,tipo_servicio,tipo_trabajo from keplersc.kdtmktser2 
		where c1=sucursal_id and c15=fol_cita_modificar order by c2 desc limit 1;		
	end if;
	

	if folio_tmkt <> '' then 
		--si es una alta 
		if tipo_operacion = 0 then
		--Actualizacion de contacto base de la cita(Se agendo cita)
			--Esperar a que cliente se presente a Cita
			accion_tmkt = 30;
			
			update keplersc.kdtmktser2 
			set c4=10, c8=40, c9=accion_tmkt, c10=now(), c11=coalesce(observaciones,''), c15= folio_cita, c27=Asesor_TMKT
			where c1=sucursal_id and c2=folio_tmkt;
		
			if to_char(fecha_cita, 'dy') = 'mon' then
					fecha_confirmacion = fecha_cita - 2;
				else 	
					fecha_confirmacion = fecha_cita - 1;
			end if;
		
		/*		--Solo en caso de que exista confirmacion de cita
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
					c20,c23) 
				values(sucursal_id,folio_tmkt,Asesor_TMKT,fecha_confirmacion,10,
					30,vin,folio_cita,tipo_servicio,tipo_trabajo, 
					clave_cliente,0);	
			else
				if (fecha_cita = current_date + 1) and extract(hour from now())<16 then
				
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('TMKT.', sucursal_id),0,0, dataxml);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;
					folio_tmkt := get_mensaje; 
					--Crear contacto solo si la cita es para ma ana y la hora < a las 4
					insert into keplersc.kdtmktser2
						(c1,c2,c3,c5,c6,
						c7,c14,c15,c18,c19,
						c20,c23) 
					values(sucursal_id,folio_tmkt,Asesor_TMKT,fecha_confirmacion,10,
						30,vin,folio_cita,tipo_servicio,tipo_trabajo, 
						clave_cliente,0);	
				
				end if;
			end if;
		*/		
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
		mensaje := 'cita_bienvcrud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
