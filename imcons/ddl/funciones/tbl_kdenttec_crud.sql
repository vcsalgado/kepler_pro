CREATE OR REPLACE FUNCTION keplersc.tbl_kdenttec_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	no_partidas int = 0;
	no_vacios int = 0;
	valor_get text = '';
	folio int;
	--modelo_get text = '';

	operacion text = '';
	--fecha_operacion text = '';

	sucursal text = '';
	tipo text = '';
	k_folio text = '';

	k_asesor text = '';
	k_fecha text = '';
	k_hora_i text = '';
	k_hora_f text = '';
	k_orden text = '';
	c_vin text = '';

	c_dscr1 text = '';
	c_dscr2 text = '';
	c_dscr3 text = '';
	c_dscr4 text = '';
	c_dscr5 text = '';

	c_nuevo text = '';
	c_km text = '';
	c_fecha text = '';
	c_frecuencia text = '';
	c_otros1 text = '';
	c_otros2 text = '';
				
	c_vel_rango text = '';
	c_cond_clima text = '';
	c_vel_motor text = '';
	c_temp_ext text = '';
	c_pos_trans text = '';
	c_peso_carga text = '';
	c_peso_arrastre text = '';
	c_num_pasajeros text = '';
	c_recto text = '';
	c_giroi text = '';
	c_girod text = '';
	c_pilotoa text = '';
	c_acelera text = '';
	c_frena text = '';
	c_subir text = '';
	c_bajar text = '';
				
	c_ac_recirculacion text = '';
	c_ac_ventilador text = '';
	c_ac_temp text = '';

	c_audio_estacion text = '';
	c_audio_sonido text = '';
				
	c_ruido_tipo text = '';
	c_ruido_ubica text = '';			
		
	c_cmnt_1 text = '';
	c_cmnt_2 text = '';
	c_cmnt_3 text = '';		
	
	k_hora_i_conf text = '';
	k_hora_f_conf text = '';
	c_sint_conf text = '';	
	c_sint_dscr text = '';
	
	c_info_1 text = '';
	c_info_2 text = '';
	c_info_3 text = '';	

	k_hora_i_expl text = '';
	k_hora_f_expl text = '';


	--Variables de uso general 
	var_value decimal = 0.00;
	totReg int = 0;
	cadena_datos text = '';
   
	strValor text = '';
	intValor int = 0;
	intCont int = 0;
	xmlCadena xml;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	
	--Resuelve opciones NEW & UPD TBL KDENTTEC (Entrevista Tecnica) 

 	--  * * *  Validando datos mandatorios ...

	no_vacios := 0;

	operacion := coalesce((xpath('//document/operacion/text()', dataxml))[1],'');
	--sucursal := coalesce((xpath('//document/c_suc/text()',dataxml))[1],'');
	sucursal := coalesce((xpath('//document/k_sucn/r1/text()', dataxml))[1],'');
	tipo := coalesce((xpath('//document/k_tipon/r1/text()', dataxml))[1],'');

	if upper(operacion) <> 'ALTA' and upper(operacion) <> 'MODIFICACION' then 
		mensaje := 'Operacion No Valida ...';
		raise exception '%', mensaje;
	else
		if upper(operacion) = 'ALTA' then 
			folio := -1;
			select coalesce(max(c2),0) into folio from keplersc.kdenttec k where c1 = sucursal;
			if folio < 0 then
				mensaje := 'No se pudo determinar el siguiente Folio de la Encuesta ...';
				raise exception '%', mensaje;
			end if;	
			folio := folio + 1;
			k_folio := folio::text;
		end if;
		if upper(operacion) = 'MODIFICACION' then
			k_folio := coalesce((xpath('//document/k_folio/text()',dataxml))[1],'');
		end if;
	end if;

	k_fecha := coalesce((xpath('//document/k_fecha/text()',dataxml))[1],'');
	k_orden := coalesce((xpath('//document/k_orden/text()',dataxml))[1],'');
	c_vin := coalesce((xpath('//document/c_vin/text()',dataxml))[1],'');
	
	if length(sucursal) = 0 then no_vacios := no_vacios + 1; end if;
	if length(tipo) = 0 then no_vacios := no_vacios + 1; end if;
	if length(k_folio) = 0 then no_vacios := no_vacios + 1; end if;
	if length(k_fecha) = 0 then no_vacios := no_vacios + 1; end if;
	if length(k_orden) = 0 then no_vacios := no_vacios + 1; end if;
	if length(c_vin) = 0 then no_vacios := no_vacios + 1; end if;

	if no_vacios > 0 then 
		mensaje := 'Se tienen datos mandatorios incompletos ... revisa la sucursal, folio, fecha, tipo, orden, vin.';
		raise exception '%', mensaje;	
	end if;
	

	k_asesor := coalesce((xpath('//document/k_asesor/text()', dataxml))[1]::text,'');
	k_hora_i := coalesce((xpath('//document/k_hora_i/text()', dataxml))[1]::text,'');
	k_hora_f := coalesce((xpath('//document/k_hora_f/text()', dataxml))[1]::text,'');

	c_dscr1 := coalesce((xpath('//document/c_dscr1/text()', dataxml))[1]::text,'');
	c_dscr2 := coalesce((xpath('//document/c_dscr2/text()', dataxml))[1]::text,'');
	c_dscr3 := coalesce((xpath('//document/c_dscr3/text()', dataxml))[1]::text,'');
	c_dscr4 := coalesce((xpath('//document/c_dscr4/text()', dataxml))[1]::text,'');
	c_dscr5 := coalesce((xpath('//document/c_dscr5/text()', dataxml))[1]::text,'');

	c_nuevo := coalesce((xpath('//document/c_nuevo/text()', dataxml))[1]::text,'');
	c_km := coalesce((xpath('//document/c_km/text()', dataxml))[1]::text,'');
	c_fecha := coalesce((xpath('//document/c_fecha/text()', dataxml))[1]::text,'');
	c_frecuencia := coalesce((xpath('//document/c_frecuencia/text()', dataxml))[1]::text,'');
	c_otros1 := coalesce((xpath('//document/c_otros1/text()', dataxml))[1]::text,'');
	c_otros2 := coalesce((xpath('//document/c_otros2/text()', dataxml))[1]::text,'');

	c_vel_rango := coalesce((xpath('//document/c_vel_rango/text()', dataxml))[1]::text,'');
	c_cond_clima := coalesce((xpath('//document/c_cond_clima/text()', dataxml))[1]::text,'');
	c_vel_motor := coalesce((xpath('//document/c_vel_motor/text()', dataxml))[1]::text,'');
	c_temp_ext := coalesce((xpath('//document/c_temp_ext/text()', dataxml))[1]::text,'');
	c_pos_trans := coalesce((xpath('//document/c_pos_trans/text()', dataxml))[1]::text,'');
	c_peso_carga := coalesce((xpath('//document/c_peso_carga/text()', dataxml))[1]::text,'');
	c_peso_arrastre := coalesce((xpath('//document/c_peso_arrastre/text()', dataxml))[1]::text,'');
	c_num_pasajeros := coalesce((xpath('//document/c_num_pasajeros/text()', dataxml))[1]::text,'');
	c_recto := coalesce((xpath('//document/c_recto/text()', dataxml))[1]::text,'');
	c_giroi := coalesce((xpath('//document/c_giroi/text()', dataxml))[1]::text,'');
	c_girod := coalesce((xpath('//document/c_girod/text()', dataxml))[1]::text,'');
	c_pilotoa := coalesce((xpath('//document/c_pilotoa/text()', dataxml))[1]::text,'');
	c_acelera := coalesce((xpath('//document/c_acelera/text()', dataxml))[1]::text,'');
	c_frena := coalesce((xpath('//document/c_frena/text()', dataxml))[1]::text,'');
	c_subir := coalesce((xpath('//document/c_subir/text()', dataxml))[1]::text,'');
	c_bajar := coalesce((xpath('//document/c_bajar/text()', dataxml))[1]::text,'');

	c_ac_recirculacion := coalesce((xpath('//document/c_ac_recirculacion/text()', dataxml))[1]::text,'');
	c_ac_ventilador := coalesce((xpath('//document/c_ac_ventilador/text()', dataxml))[1]::text,'');
	c_ac_temp := coalesce((xpath('//document/c_ac_temp/text()', dataxml))[1]::text,'');

	c_audio_estacion := coalesce((xpath('//document/c_audio_estacion/text()', dataxml))[1]::text,'');
	c_audio_sonido := coalesce((xpath('//document/c_audio_sonido/text()', dataxml))[1]::text,'');

	c_ruido_tipo := coalesce((xpath('//document/c_ruido_tipo/text()', dataxml))[1]::text,'');
	c_ruido_ubica := coalesce((xpath('//document/c_ruido_ubica/text()', dataxml))[1]::text,'');

	c_cmnt_1 := coalesce((xpath('//document/c_cmnt_1/text()', dataxml))[1]::text,'');
	c_cmnt_2 := coalesce((xpath('//document/c_cmnt_2/text()', dataxml))[1]::text,'');
	c_cmnt_3 := coalesce((xpath('//document/c_cmnt_3/text()', dataxml))[1]::text,'');

	k_hora_i_conf := coalesce((xpath('//document/k_hora_i_conf/text()', dataxml))[1]::text,'');
	k_hora_f_conf := coalesce((xpath('//document/k_hora_f_conf/text()', dataxml))[1]::text,'');
	c_sint_conf := coalesce((xpath('//document/c_sint_conf/text()', dataxml))[1]::text,'');
	c_sint_dscr := coalesce((xpath('//document/c_sint_dscr/text()', dataxml))[1]::text,'');

	c_info_1 := coalesce((xpath('//document/c_info_1/text()', dataxml))[1]::text,'');
	c_info_2 := coalesce((xpath('//document/c_info_2/text()', dataxml))[1]::text,'');
	c_info_3 := coalesce((xpath('//document/c_info_3/text()', dataxml))[1]::text,'');

	k_hora_i_expl := coalesce((xpath('//document/k_hora_i_expl/text()', dataxml))[1]::text,'');
	k_hora_f_expl := coalesce((xpath('//document/k_hora_f_expl/text()', dataxml))[1]::text,'');


	--  * * *  Validar datos de catalogos ...

	totReg := 0;
	select count(c1) into totReg from keplersc.kdms where c1 = sucursal;
	if totReg = 0 then
		mensaje := 'No se encontro el Registro en la Tabla kdms [Sucursales], sucursal [' || sucursal || ']';
		raise exception '%', mensaje;
	end if;	

	totReg := 0;
	select count(c1) into totReg from keplersc.kdmargen where c1 = tipo;
	if totReg = 0 then
		mensaje := 'No se encontro el Registro en la Tabla kdmargen, tipo [' || tipo || ']';
		raise exception '%', mensaje;
	end if;	

	totReg := 0;
	select count(c1) into totReg from keplersc.kdord where c1 = /*'02'*/sucursal and c2 = tipo and c3 = k_orden;
	if totReg = 0 then
		mensaje := 'No se encontro el Registro en la Tabla kdord, tipo : orden [' || tipo || '] : ' || k_orden;
		raise exception '%', mensaje;
	end if;	

	if length(k_asesor) > 0 then
		totReg := 0;
		select count(c1) into totReg from keplersc.kdcatasesortec where c1 = k_asesor;
		if totReg = 0 then
			mensaje := 'No se encontro el Registro en la Tabla kdcatasesortec, asesor [' || k_asesor || ']';
			raise exception '%', mensaje;
		end if;
	end if;


	--  * * *  Procesando Registros ...

	if length(trim(c_fecha)) = 0 then
		c_fecha = '1900-01-01';
	end if;

	-- OPERACION ALTA ... 
	if upper(operacion) = 'ALTA' then
	
		insert into keplersc.kdenttec (
		c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, 
		c11, c12, c13, c14, c15, c16, c17, c18, c19, c20, 
		c21, c22, c23, c24, c25, c26, c27, c28, c29, c30, 
		c31, c32, c33, c34, c35, c36, c37, c38, c39, c40, 
		c41, c42, c43, c44, c45, c46, c47, c48, c49, c50, 
		c51, c52, c53, c54, c55 
		)
		values (
		sucursal, k_folio::int, c_vin, k_asesor, tipo, k_orden, to_date(k_fecha,'YYYY-MM-DD'), k_hora_i, k_hora_f, c_dscr1,
		c_dscr2, c_dscr3, c_dscr4, c_dscr5, c_nuevo, c_km::int, to_date(c_fecha,'YYYY-MM-DD'), c_frecuencia, c_otros1, c_otros2,
		c_vel_rango, c_vel_motor, c_pos_trans, c_cond_clima, c_num_pasajeros::int, c_peso_carga::int, c_peso_arrastre::int, c_temp_ext::int, c_recto, c_acelera, 
		c_giroi, c_girod, c_subir, c_bajar, c_frena, c_pilotoa, c_ac_recirculacion, c_ac_ventilador, c_ac_temp, c_audio_estacion, 
		c_audio_sonido, c_ruido_tipo, c_ruido_ubica, c_cmnt_1, c_cmnt_2, c_cmnt_3, k_hora_i_conf, k_hora_f_conf, c_sint_conf, c_sint_dscr,  
		c_info_1, c_info_2, c_info_3, k_hora_i_expl, k_hora_f_expl  
		);
	
	else
	
		update keplersc.kdenttec  
		set 
			/*c1 = sucursal, c2 = k_folio::int, c5 = tipo,*/ -- No Aplica para el UPD
			c3 = c_vin,
			c4 = k_asesor, 
			c6 = k_orden, 
			c7 = to_date(k_fecha,'YYYY-MM-DD'), 
			c8 = k_hora_i, 
			c9 = k_hora_f, 
			c10 = c_dscr1, 
			c11 = c_dscr2, 
			c12 = c_dscr3, 
			c13 = c_dscr4, 
			c14 = c_dscr5, 
			c15 = c_nuevo, 
			c16 = c_km::int, 
			c17 = to_date(c_fecha,'YYYY-MM-DD'), 
			c18 = c_frecuencia, 
			c19 = c_otros1, 
			c20 = c_otros2, 
			c21 = c_vel_rango, 
			c22 = c_vel_motor, 
			c23 = c_pos_trans, 
			c24 = c_cond_clima, 
			c25 = c_num_pasajeros::int, 
			c26 = c_peso_carga::int, 
			c27 = c_peso_arrastre::int, 
			c28 = c_temp_ext::int, 
			c29 = c_recto, 
			c30 = c_acelera, 
			c31 = c_giroi, 
			c32 = c_girod, 
			c33 = c_subir, 
			c34 = c_bajar, 
			c35 = c_frena, 
			c36 = c_pilotoa, 
			c37 = c_ac_recirculacion, 
			c38 = c_ac_ventilador, 
			c39 = c_ac_temp, 
			c40 = c_audio_estacion, 
			c41 = c_audio_sonido, 
			c42 = c_ruido_tipo, 
			c43 = c_ruido_ubica, 
			c44 = c_cmnt_1, 
			c45 = c_cmnt_2, 
			c46 = c_cmnt_3, 
			c47 = k_hora_i_conf, 
			c48 = k_hora_f_conf, 
			c49 = c_sint_conf, 
			c50 = c_sint_dscr, 
			c51 = c_info_1, 
			c52 = c_info_2, 
			c53 = c_info_3, 
			c54 = k_hora_i_expl, 
			c55 = k_hora_f_expl
		where c1 = sucursal and c2 = k_folio::int;
		
	end if;
	
	/*
	mensaje := 'Opcion en pruebas operativas ...';
	--cmnt(1).free4eg by JMM
	raise exception '%', mensaje;
	*/

	--mensaje := 'Opcion en Construccion ...';
	resultado := 1;
	if upper(operacion) = 'ALTA' then
		--mensaje := 'Se Registro la Encuesta ' || k_folio;
		mensaje := 'Se Registro la Encuesta ';
		adicionales := k_folio;
	else
		mensaje := 'Los Datos se Actualizaron Satisfactoriamente ...';
		adicionales := '';
	end if;
	
	return query select resultado, mensaje, adicionales;	


exception
	when others then
		resultado := 0;
		mensaje := 'tbl_kdenttec_crud(); ' || '['|| sqlstate || '] ' || sqlerrm ;
		return query select resultado, mensaje, adicionales;	

end;
$function$
