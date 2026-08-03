CREATE OR REPLACE FUNCTION keplersc.ser_tmkt_upd(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	folio text = '';
	asesor text = '';
	resultado_contacto text = '';
	accion text = '';
	fecha_accion text = '';
	observaciones text = '';
	serie text = '';
	tipo_servicio text = '';
	motivo_original text = '';
	cliente_id text = '';
	nombre_atendio text = '';
	folio_cita text ='';
	coment_resultado text ='';
	fecha_vale date;

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	_crear_contacto text = '';
	_crear_motivo numeric = 0;
	nuevo_folio text = '';

	--Variables de retorno de folio
	get_resultado text;
	get_mensaje text; 
	get_adicionales text;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	folio := (xpath('//document/folio/text()', dataxml))[1];
	asesor := (xpath('//document/asesor/text()', dataxml))[1];
	resultado_contacto := (xpath('//document/resultado/text()', dataxml))[1];
	accion := (xpath('//document/accion/text()', dataxml))[1];
	fecha_accion := (xpath('//document/fecha_accion/text()', dataxml))[1];
	observaciones := (xpath('//document/observaciones/text()', dataxml))[1];
	serie := (xpath('//document/serie/text()', dataxml))[1];
	tipo_servicio := (xpath('//document/tipo_servicio/text()', dataxml))[1];
	motivo_original := (xpath('//document/motivo_original/text()', dataxml))[1];
	nombre_atendio := (xpath('//document/nombre_atendio/text()', dataxml))[1];
	folio_cita := (xpath('//document/folio_cita/text()', dataxml))[1];
	coment_resultado := (xpath('//document/coment_resultado/text()', dataxml))[1];

	--Obtener si accion implica nuevo registro de contacto
	select crear_contacto, crear_motivo into _crear_contacto, _crear_motivo 
		from keplersc.kdtmktaccion where accion_id = accion::numeric;
	select c20,c26 into cliente_id,fecha_vale 
		from keplersc.kdtmktser2 where c1=sucursal_id and c2=folio;
	--Actualizar registro de contacto
	--MSS:Actualizar el asesor real solamente
	update keplersc.kdtmktser2 
	set c4=10, c8=resultado_contacto::int, c9=accion::numeric, c10=now(),
		c11 = coalesce(observaciones,''),c21=nombre_atendio, c27=asesor, c29=coment_resultado
	where c1=sucursal_id and c2=folio;

	--Si se trata de una confirmacion, actualizar cita
	if resultado_contacto = '50' then		--Se confirma cita de servicio
		update keplersc.kdctasser set c20=10, c26 =current_date, c27=substring(current_time::text,1,5), c28=nombre_atendio
			where c1=sucursal_id and c2=folio_cita;
	end if;
	--Cancelar recordatorios posteriores 
		--c8=21 Cancelado, c9=50 Terminado
	if resultado_contacto = '41' then		--El cliente ya tiene cita 
		update keplersc.kdtmktser2 
			set c8=21, c9=50, c10=now(), c29='Se agendo previamente una cita'
		where c1=sucursal_id and c14=serie and c7<>30 and c5 > (select c5 from keplersc.kdtmktser2 where c1=sucursal_id and c2=folio);	
	end if;
	if resultado_contacto = '90' or resultado_contacto = '91' then	--Servicio realizado en otra agencia Toyota,Servicio realizado en otro taller
		update keplersc.kdtmktser2 
			set c8=21, c9=50, c10=now(), c29='Por resultado anterior'
		where c1=sucursal_id and c14=serie and c5 > (select c5 from keplersc.kdtmktser2 where c1=sucursal_id and c2=folio);			
	end if;
	if resultado_contacto = '100' then	--Servicio realizado
		update keplersc.kdtmktser2 
			set c8=21, c9=50, c10=now(), c29='Por resultado anterior'
		where c1=sucursal_id and c14=serie and c8=0;		
	end if;
	--Si la accion es No contactar mas cancelar sus contactos
	if accion = '20' then		--No contactar mas
		update keplersc.kdtmktser2 
			set c8=21, c9=20, c10=now(), c29='Por resultado anterior'
		where c1=sucursal_id and c14=serie and c8=0;		
	end if;
	if _crear_contacto='S' then
		--Definir el motivo del nuevo contacto
		if _crear_motivo=-1 then -- -1 indica crear cin motivo original
			_crear_motivo = motivo_original::int;
		end if;
		--Obtener siguiente folio
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('TMKT.', sucursal_id),0,0,dataxml);
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;
		nuevo_folio := get_mensaje; 
		--MSS:el asesor del nuevo contacto debe ser el base de kdserie, QUITAR COMENTARIO CUANDO YA TENGA DATOS EN KDSERIE.C26
		--select asesor_base_tmkt into asesor 
		--	from keplersc.kdserie where c1=serie;				
		insert into keplersc.kdtmktser2(c1,c2,c3,c5,c6,
		c7,c14,c18,c19,c20,c23,c24,c26) 
		values(sucursal_id,nuevo_folio,asesor,to_date(fecha_accion,'YYYY-MM-DD'),0,
		_crear_motivo,serie,tipo_servicio::numeric,'P',cliente_id,0,now(),fecha_vale);
		
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, nuevo_folio, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_tmkt_upd() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
