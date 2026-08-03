CREATE OR REPLACE FUNCTION keplersc.tbl_kdinf_upd(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Bitacora de cambios
--27/03/2025 Miriam Santana : Escapar las "
--23/05/2025 Victor Salgado : Se agrega auto demo en campo c22
declare
	--Variables de definicion de documento
	no_partidas int = 0;
	no_vacios int = 0;
	valor_get text = '';
	modelo_get text = '';

	--operacion text = '';
	--fecha_operacion text = '';

	sucursal text = '';
	modelo text = '';
	cve_invent text = '';
	anio text = '';
	descrip text = '';
	tipo_auto text = '';
	
	color text = '';
	vest text = '';
	serie text = '';
	marca text = '';
	clase text = '';

	-- Added 20221221 by JMM (based on request of ESANTANA)
	color_desc text = '';
	vest_desc text = '';

	inventant text = '';
	motor text = '';
	transmision text = '';
	cveveh text = '';
	regfed text = '';
	eje text = '';

	pedimento text = '';
	pedimento_fecha text = '';
	pedimento_lugar text = '';
	procedencia text = '';
	combustible text = '';
	ocupantes int;
	cilindros int;
	puertas int;
	demo text = '';

	pq01 text = '';
	pq02 text = '';
	pq03 text = '';
	pq04 text = '';
	pq05 text = '';
	pq06 text = '';
	pq07 text = '';
	pq08 text = '';
	pq09 text = '';
	pq10 text = '';
	pq11 text = '';
	pq12 text = '';
	pq13 text = '';
	pq14 text = '';
	pq15 text = '';
	pq16 text = '';
	pq17 text = '';
	pq18 text = '';
	pq19 text = '';
	pq20 text = '';
	pq21 text = '';
	
	--fecha text = '';
	--num_inventario text = '';

	list_series_err text = '';
	flag_serie int = 0;

	valor_get_dig_id text = '';
	valor_get_dig_mod text = '';
	valor_get_n_u text = '';
	valor_get_clase text = '';
	valor_get_marca text = '';
	valor_get_codisan text = '';
	valor_get_n_u_calc text = '';

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
	
	--Resuelve opciones UPD TBL KDINF (Inventario de Vehiculos) 

 	--  * * *  Validando datos mandatorios ...

	no_vacios := 0;
	
	sucursal := coalesce((xpath('//document/c_suc/text()',dataxml))[1],'');
	cve_invent := coalesce((xpath('//document/c_invent/text()',dataxml))[1],'');
	modelo := coalesce((xpath('//document/c_modelo/text()',dataxml))[1],'');
	descrip := coalesce((xpath('//document/k_descrip/text()',dataxml))[1],'');
	anio := coalesce((xpath('//document/c_anio/text()',dataxml))[1],'');
	tipo_auto := coalesce((xpath('//document/k_tipo_auto/text()',dataxml))[1],'');	
	
	
	color := coalesce((xpath('//document/c_color_ext/text()',dataxml))[1],'');
	vest := coalesce((xpath('//document/c_color_vest/text()',dataxml))[1],'');
	serie := coalesce((xpath('//document/c_serie/text()',dataxml))[1],'');
	marca := coalesce((xpath('//document/c_marca/text()',dataxml))[1],'');
	clase := coalesce((xpath('//document/c_clase/text()',dataxml))[1],'');
		
		
	if length(sucursal) = 0 then no_vacios := no_vacios + 1; end if;
	if length(cve_invent) = 0 then no_vacios := no_vacios + 1; end if;
	if length(modelo) = 0 then no_vacios := no_vacios + 1; end if;
	if length(descrip) = 0 then no_vacios := no_vacios + 1; end if;
	if length(anio) = 0 then no_vacios := no_vacios + 1; end if;
	if length(tipo_auto) = 0 then no_vacios := no_vacios + 1; end if;

	-- Se forzara su registro en base a la sugerencia revisada con VSS (JMM)
	if length(color) = 0 then no_vacios := no_vacios + 1; end if;
	if length(vest) = 0 then no_vacios := no_vacios + 1; end if;
	if length(serie) = 0 then no_vacios := no_vacios + 1; end if;
		
		
	if no_vacios > 0 then 
		mensaje := 'Se tienen datos mandatorios incompletos ... revisa los colores, la descripcion y/o la serie.';
		raise exception '%', mensaje;	
	end if;
	
	--  * * *  Validar datos de catalogos ...

	totReg := 0;
	select count(c1) into totReg from keplersc.kdms where c1 = sucursal;
	if totReg = 0 then
		mensaje := 'No se encontro el Registro en la Tabla Kdms [Sucursales], sucursal [' || sucursal || ']';
		raise exception '%', mensaje;
	end if;	

	valor_get := '';
	select c1 into valor_get from keplersc.kdiv where c1 = modelo;
	modelo_get := coalesce(valor_get, '');
	if length(modelo_get) = 0 then
		mensaje := 'No se encontro el Registro en la Tabla kdiv [Vehiculos], modelo [' || modelo || ']';
		raise exception '%', mensaje;
	end if;	

	/*
	valor_get := '';
	select i.C3 into valor_get from keplersc.kddinv i inner join keplersc.kdiv k on k.c8 = i.c7 and k.c1 = modelo_get 
		where i.c1 = cve_invent;
	if anio <> coalesce(valor_get, '') then 
		mensaje := 'No se encontro el Registro en la Tabla kddinv [Inventarios], partida [' || intCont::text || ']';
		raise exception '%', mensaje;
	end if;	
	*/

	-- Se forzara su registro en base a la sugerencia revisada con VSS (JMM)
	--if length(color) > 0 then
		totReg := 0;
		select count(c3) into totReg from keplersc.kdice2 where c1 = modelo_get and c3 = color; 
		if totReg = 0 then
			mensaje := 'No se encontro el Registro en la Tabla Kdice2 [Colores EXT], Color_Ext [' || color || ']';
			raise exception '%', mensaje;
		
		--New code 20221221
		else
			color_desc := '';
			select c4 into color_desc from keplersc.kdice2 where c1 = modelo_get and c3 = color;
			color_desc := coalesce(color_desc,'');	
		
		end if;	
	--end if;

	-- Se forzara su registro en base a la sugerencia revisada con VSS (JMM)
	--if length(vest) > 0 then
		totReg := 0;
		select count(c3) into totReg from keplersc.kdice3 where c1 = modelo_get and c3 = vest; 
		if totReg = 0 then
			mensaje := 'No se encontro el Registro en la Tabla Kdice3 [Colores VESTIDURAS], Color_Vest [' || vest || ']';
			raise exception '%', mensaje; 
		
		--New code 20221221
		else
			vest_desc := '';
			select c4 into vest_desc from keplersc.kdice3 where c1 = modelo_get and c3 = vest;
			vest_desc := coalesce(vest_desc,'');
		
		end if;		
	--end if;

	if length(clase) > 0 then
		totReg := 0;
		select count(c1) into totReg from keplersc.kdic where c1 = clase;
		if totReg = 0 then
			mensaje := 'No se encontro el Registro en la Tabla Kdic [Clases], clase [' || clase || ']';
			raise exception '%', mensaje;
		end if;		
	end if;

	if length(marca) > 0 then
		totReg := 0;
		select count(c1) into totReg from keplersc.Kdmarca where c1 = marca;
		if totReg = 0 then
			mensaje := 'No se encontro el Registro en la Tabla Kdmarca [Marcas], marca [' || marca || ']';
			raise exception '%', mensaje;
		end if;	
	end if;

	--  * * *  Procesando Registros ...

	list_series_err := '';

	inventant := coalesce((xpath('//document/c_inventant/text()', dataxml))[1]::text,'');
	motor := coalesce((xpath('//document/c_motor/text()', dataxml))[1]::text,'');
	transmision := coalesce((xpath('//document/c_transmision/text()', dataxml))[1]::text,'');
	cveveh := coalesce((xpath('//document/c_cveveh/text()', dataxml))[1]::text,'');
	regfed := coalesce((xpath('//document/c_regfed/text()', dataxml))[1]::text,'');
	eje := coalesce((xpath('//document/c_eje/text()', dataxml))[1]::text,'');

	pedimento := coalesce((xpath('//document/c_pedimento/text()', dataxml))[1]::text,'');
	pedimento_fecha := coalesce((xpath('//document/c_fecha/text()', dataxml))[1]::text,'');
	pedimento_lugar := coalesce((xpath('//document/c_lugarped/text()', dataxml))[1]::text,'');

	procedencia := coalesce((xpath('//document/v_procedencia/r1/text()', dataxml))[1]::text,'');
	combustible := coalesce((xpath('//document/v_combustible/text()', dataxml))[1]::text,'');
	ocupantes := coalesce((xpath('//document/v_ocupantes/text()', dataxml))[1]::text,'0');
	cilindros := coalesce((xpath('//document/v_cilindros/text()', dataxml))[1]::text,'0');
	puertas := coalesce((xpath('//document/v_puertas/text()', dataxml))[1]::text,'0');
	demo := coalesce((xpath('//document/c_demo/text()', dataxml))[1]::text,'');
	if demo='0' then
		demo:='';
	end if;	

	pq01 := coalesce((xpath('//document/c_pq01/text()', dataxml))[1]::text,'');
	pq02 := coalesce((xpath('//document/c_pq02/text()', dataxml))[1]::text,'');
	pq03 := coalesce((xpath('//document/c_pq03/text()', dataxml))[1]::text,'');
	pq04 := coalesce((xpath('//document/c_pq04/text()', dataxml))[1]::text,'');
	pq05 := coalesce((xpath('//document/c_pq05/text()', dataxml))[1]::text,'');
	pq06 := coalesce((xpath('//document/c_pq06/text()', dataxml))[1]::text,'');
	pq07 := coalesce((xpath('//document/c_pq07/text()', dataxml))[1]::text,'');
	pq08 := coalesce((xpath('//document/c_pq08/text()', dataxml))[1]::text,'');
	pq09 := coalesce((xpath('//document/c_pq09/text()', dataxml))[1]::text,'');
	pq10 := coalesce((xpath('//document/c_pq10/text()', dataxml))[1]::text,'');
	pq11 := coalesce((xpath('//document/c_pq11/text()', dataxml))[1]::text,'');
	pq12 := coalesce((xpath('//document/c_pq12/text()', dataxml))[1]::text,'');
	pq13 := coalesce((xpath('//document/c_pq13/text()', dataxml))[1]::text,'');
	pq14 := coalesce((xpath('//document/c_pq14/text()', dataxml))[1]::text,'');
	pq15 := coalesce((xpath('//document/c_pq15/text()', dataxml))[1]::text,'');
	pq16 := coalesce((xpath('//document/c_pq16/text()', dataxml))[1]::text,'');
	pq17 := coalesce((xpath('//document/c_pq17/text()', dataxml))[1]::text,'');
	pq18 := coalesce((xpath('//document/c_pq18/text()', dataxml))[1]::text,'');
	pq19 := coalesce((xpath('//document/c_pq19/text()', dataxml))[1]::text,'');
	pq20 := coalesce((xpath('//document/c_pq20/text()', dataxml))[1]::text,'');
	pq21 := coalesce((xpath('//document/c_pq21/text()', dataxml))[1]::text,'');
	
	valor_get := '';
	-- 1.- Se comento la sucursal debido a como estan los registros en K75
	-- 2.- Se hizo una diferenciacion para Autos Nuevos y Usados y se cambio la diferenciacion de Estatus
	--     en Usados ... 20230213 (se agrego la 2da linea)
	if  upper(tipo_auto) = upper('NUEVO') then
		select max(c2) into valor_get from keplersc.kdinf where c5 = serie and c2 <> cve_invent and c31 <> 0 /*and c1 = sucursal*/ 
			and c2 not in (select c2 from keplersc.kdinf where c31 = 20 and c32 = 70);
	else
		select max(c2) into valor_get from keplersc.kdinf where c5 = serie and c2 <> cve_invent and ( c31 = 10 or ( c31 > 0 and c32 < 60 ) ) /*c31 <> 0*/ /*and c1 = sucursal*/;
	end if;

	intValor := coalesce(left(valor_get,4), '0')::integer;

	flag_serie := 0;

	/*
	valor_get_dig_id := '';
	valor_get_dig_mod := '';
	valor_get_n_u := '';

	select i.c4, i.c5, i.c7 into valor_get_dig_id, valor_get_dig_mod, valor_get_n_u from keplersc.kddinv i 
	inner join keplersc.kdiv k on k.c8 = i.c7 and k.c1 = modelo 
	where i.c1 = cve_invent;

	if length(coalesce(valor_get_dig_id, '')) = 0 or length(coalesce(valor_get_dig_mod, '')) = 0 or length(coalesce(valor_get_n_u, '')) = 0 then 
		mensaje := 'No se encontro INFO suficiente para armar el numero de inventario, partida [' || intCont::text || ']';
		raise exception '%', mensaje;
	end if;

	if intValor > 0 then
		if upper(valor_get_n_u) = upper('N') then
			flag_serie := 1;
			list_series_err := list_series_err || 'Serie : ' || serie || ' [' || valor_get || '] ' || '|'; 	
		end if;
	end if;
	*/

	if intValor > 0 then
		if upper(tipo_auto) = upper('NUEVO') then
			flag_serie := 1;
			list_series_err := list_series_err || 'Serie en otro Inventario : ' || serie || ' [' || valor_get || '] ' || '|';
			mensaje := list_series_err;
			raise exception '%', mensaje;
		end if;
	end if;
--raise exception 'Ocupantes: %, flag_serie: %',ocupantes,flag_serie;
	if flag_serie = 0 then
		--Para autos nuevos los siguientes campos no se deben actualizar
		if upper(tipo_auto) = upper('NUEVO') then
--raise exception 'Rec. datos nuevo'; 
			select c90,c91,c92,c93,c94 into procedencia, ocupantes,cilindros,puertas,combustible
			from keplersc.kdinf where c1=sucursal and c2=cve_invent and c3=modelo and c15=anio;
		end if;
		update keplersc.kdinf 
		set 
			c4 = regexp_replace(descrip,'\\"','"','gi'),			--MSS 27032025 Escapar las "
			c5 = serie,
			c6 = motor,
			c7 = coalesce(right(serie,8),''),
			c8 = transmision,
			c10 = color,
			c11 = vest,
			c12 = eje,
			c13 = cveveh,
			c14 = regfed,
			c17 = marca,
			c18 = clase,
			c22 = demo,
			c26 = pedimento,
			c27 = case when length(pedimento_fecha) > 0 then to_date(pedimento_fecha,'YYYY-MM-DD') else to_date('1900-01-01','YYYY-MM-DD') /*null*/ /*c27*/ end,
			c28 = pedimento_lugar,
			c40 = pq01, c41 = pq02, c42 = pq03, c43 = pq04, c44 = pq05, c45 = pq06, c46 = pq07,
			c47 = pq08, c48 = pq09, c49 = pq10, c50 = pq11, c51 = pq12, c52 = pq13, c53 = pq14,
			c54 = pq15, c55 = pq16, c56 = pq17, c57 = pq18, c58 = pq19, c59 = pq20, c60 = pq21 
			, c34 = color_desc, c35 = vest_desc, 
			c90=procedencia, 
			c91=ocupantes,
			c92=cilindros,
			c93=puertas,
			c94=combustible
		where c1 = sucursal and c2 = cve_invent and c3 = modelo and c15 = anio and (c31 = 10 or c31=20);
		
		update keplersc.kdasig 
			set 
				c4 = regexp_replace(descrip,'\\"','"','gi'),			--MSS 27032025 Escapar las "
				c8 = coalesce(serie,''),
				c5 = coalesce(color,''), 
				c6 = coalesce(vest,'')
		where c1 = sucursal and c2 = cve_invent and c3 = modelo and c7 = anio and c11 = 10;
	
		/*
		-- ACORDADO CON VCSS, No se hara por temas de normalizacion de la INFO 
		-- Included 20220927, After final review of opc kdinfgen.WIND 
		update keplersc.kdiv 
			set
				-- Es como yo lo haria por temas de integridad de datos
				/*
				c4 = case when length(clase) > 0 then clase else c4 end,
				c5 = case when length(marca) > 0 then marca else c5 end 
				*/
				-- Se dejo como esta en K75
				--/* 
				c4 = clase,
				c5 = marca 
				--*/
		where c1 = modelo;
		*/
		
	end if;
	
	
	/*
	mensaje := 'Opcion en pruebas operativas ...';
	--cmnt(1).free4eg by JMM
	raise exception '%', mensaje;
	*/

	--mensaje := 'Opcion en Construccion ...';
	resultado := 1;
	mensaje := 'Los Datos se Actualizaron Satisfactoriamente ...';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	


exception
	when others then
		resultado := 0;
		mensaje := 'tbl_kdinf_upd(); ' || '['|| sqlstate || '] ' || sqlerrm ;
		if length(list_series_err) > 0 and length(adicionales) = 0 then
			adicionales := list_series_err;
		else
			adicionales := '';
		end if;
		return query select resultado, mensaje, adicionales;	

end;
$function$
