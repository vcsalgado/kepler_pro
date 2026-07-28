CREATE OR REPLACE FUNCTION keplersc.ser_registro_calidad(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Realiza inserción y actualizacion del registro de calidad de una orden en KDPUNRES
--Autor: Miriam Santana
--Fecha: 04/11/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text;
	fecha_operacion text; --yyyy-mm-dd
	tipo_orden text;
	num_orden text;
	punto text;
	revisado text;
	reparado text;
	reportec text;
	garantia text;
	tipo_orden_garantia text;
	num_orden_garantia text;
	comentarios text;
	observaciones text;
	recomendaciones text;
	usuario text;
	serie text;
	operacion text;

	--Variables de uso general
	tiempo_transcurrido decimal;
	fec_orden date; 
	hora_recepcion text;
	strValor text;
	intValor int;
	strPartidas text;
	no_partidas int;
	totReg int;
begin
	sucursal_id := (xpath('//document/k_sucursal/text()', dataxml))[1];
	tipo_orden := (xpath('//document/k_tipo/text()',dataxml))[1];
	num_orden := (xpath('//document/k_folio/text()',dataxml))[1];
	punto := (xpath('//document/k_punto_rel/text()',dataxml))[1];		--Num de punto que corresponden los datos a grabar
	serie := (xpath('//document/k_serie/text()',dataxml))[1];
	revisado := (xpath('//document/k_revisado/text()',dataxml))[1];
	reparado := (xpath('//document/k_reparado/text()',dataxml))[1];
	reportec := (xpath('//document/k_reportec/text()',dataxml))[1];
	garantia := (xpath('//document/k_garantia/text()',dataxml))[1];
	tipo_orden_garantia := (xpath('//document/k_tipo_orden_garantia/text()',dataxml))[1];
	num_orden_garantia := (xpath('//document/k_num_orden_garantia/text()',dataxml))[1];
	comentarios := (xpath('//document/k_comentarios/text()',dataxml))[1];
	observaciones := (xpath('//document/k_observaciones/text()',dataxml))[1];
	recomendaciones := (xpath('//document/k_recomendaciones/text()',dataxml))[1];
	usuario := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
	operacion := (xpath('//document/operacion/text()',dataxml))[1];
	
	if operacion = 'ALTA' then
		select c4,c5 into fec_orden, hora_recepcion
			from keplersc.kdord
			where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
		select (current_date-fec_orden) into intValor;
		tiempo_transcurrido := intValor*24*60;

		select count(*) into totReg from keplersc.kdpunres
			where c1=sucursal_id and c2=tipo_orden and c3=num_orden and c4=punto::integer;
		if totReg=0 then
			insert into keplersc.kdpunres (
				c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11)
			values(
				sucursal_id,tipo_orden,num_orden,punto::integer,30,
				fec_orden,hora_recepcion,current_date,substring(current_time::text,1,8),tiempo_transcurrido,
				'TRABAJO TERMINADO');	
		end if;
		update keplersc.kdpunres set
			c5=30,
			c12=coalesce(revisado,''),
			c13=coalesce(reparado,''),
			c14=comentarios,
			c15=observaciones,
			c16=recomendaciones,
			c18=usuario,
			c21=coalesce(reportec,''),
			c22=coalesce(garantia,''),
			c23=coalesce(tipo_orden_garantia,''),
			c24=coalesce(num_orden_garantia,''),
			c25=serie
		where c1=sucursal_id and c2=tipo_orden and c3=num_orden and c4=punto::integer;
	end if;
	if operacion = 'BAJA' then
		update keplersc.kdpunres set
			c5=20,
			c12='',
			c13='',
			c14='',
			c15='',
			c16='',
			c18=usuario,
			c21='',
			c22='',
			c23='',
			c24='',
			c25='',
			c26='',
			c27='',
			c28='',
			c29='',
			c30='',
			c31=''
		where c1=sucursal_id and c2=tipo_orden and c3=num_orden and c4=punto::integer;
	end if;
--raise exception 'Alto manual para pruebas';	

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_registro calidad() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
		
end;
$function$
