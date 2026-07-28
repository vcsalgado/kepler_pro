CREATE OR REPLACE FUNCTION keplersc.autos_com_asig_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	no_partidas int = 0;
	no_vacios int = 0;
	valor_get text = '';
	modelo_get text = '';

	operacion text = '';
	fecha_operacion text = '';
	flag_oper int = 0;

	sucursal text = '';
	modelo text = '';
	cve_invent text = '';
	anio text = '';
	descrip text = '';
	color text = '';
	vest text = '';
	serie text = '';
	refer text = '';
	fecha text = '';
	borrar text = '';
	-- Added 20221221 by JMM (based on request of ESANTANA)
	color_desc text = '';
	vest_desc text = '';

	-- 4 Usados
	c_marca text = '';
	c_modelo text = '';
	c_anio text = '';
	c_version text = '';
	c_descrip text = '';

	-- To Implement when ESantana Complete hes option
	--/*
	-- 4 Usados added 20221217 0035 ... Se incluyeron los defaults definidos x ESantana
	c_procedencia text = '';
	c_ocupantes text = '';
	c_cilindros text = '';
	c_puertas text = '';
	c_combustible text = '';
	--*/

	num_inventario text = '';
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
	numero_partida int = 0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	--Resuelve opciones de Autos_Compras_Asignacion(Alta, Baja) 
	
    strValor = dataxml::text;
    strValor := replace(strValor, '\&quot;', '"');
    dataxml = strValor::xml;
	
	operacion := coalesce((xpath('//document/operacion/text()', dataxml))[1],'');

	if length(operacion) = 0 then 
		mensaje := 'Datos insuficientes para procesar la Informacion [Operacion] ...';
		raise exception '%', mensaje;		
	end if;

	--Partidas
	strValor := coalesce((xpath('//document/k_mov/no_partidas/text()',dataxml))[1]::text,'0');
	no_partidas := strValor::integer;

	if no_partidas <= 0 then
		mensaje := 'No hay partidas a procesar ...';
		raise exception '%', mensaje;	
	end if;



	if upper(left(trim(operacion),4)) = upper('ALTA') then

		fecha_operacion := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'');
	
		if length(fecha_operacion) = 0 then 
			mensaje := 'Datos insuficientes para procesar la Informacion [Fecha] ...';
			raise exception '%', mensaje;		
		end if;

		
		select position('USADOS' in upper(operacion)) into flag_oper;
	
		if flag_oper = 0 then
		
			-- * * * * *  START : Operacion ALTA - NUEVOS 
			--mensaje := 'Se Procesaran Registros - Operacion Alta Nuevos ...';
			--raise exception '%', mensaje;
		
		
			--  * * *  Validando Partidas ...
			
			numero_partida := 0;
	
			for intCont in 0..no_partidas - 1 loop
		
				no_vacios := 0;
				
				sucursal := coalesce((xpath('//document/k_mov/r'||intCont||'/suc/text()',dataxml))[1],'');
				modelo := coalesce((xpath('//document/k_mov/r'||intCont||'/modelo/text()',dataxml))[1],'');
				cve_invent := coalesce((xpath('//document/k_mov/r'||intCont||'/invent/text()',dataxml))[1],'');
				anio := coalesce((xpath('//document/k_mov/r'||intCont||'/anio/text()',dataxml))[1],'');
				descrip := coalesce((xpath('//document/k_mov/r'||intCont||'/descrip/text()',dataxml))[1],'');
				color := coalesce((xpath('//document/k_mov/r'||intCont||'/color/text()',dataxml))[1],'');
				vest := coalesce((xpath('//document/k_mov/r'||intCont||'/vest/text()',dataxml))[1],'');
				serie := coalesce((xpath('//document/k_mov/r'||intCont||'/serie/text()',dataxml))[1],'');
				refer := coalesce((xpath('//document/k_mov/r'||intCont||'/ref/text()',dataxml))[1],'');
				
				if length(sucursal) > 0 then no_vacios := no_vacios + 1; end if;
				if length(modelo) > 0 then no_vacios := no_vacios + 1; end if;
				if length(cve_invent) > 0 then no_vacios := no_vacios + 1; end if;
				if length(anio) > 0 then no_vacios := no_vacios + 1; end if;
				if length(descrip) > 0 then no_vacios := no_vacios + 1; end if;
				if length(color) > 0 then no_vacios := no_vacios + 1; end if;
				if length(vest) > 0 then no_vacios := no_vacios + 1; end if;
				if length(serie) > 0 then no_vacios := no_vacios + 1; end if;
				if length(refer) > 0 then no_vacios := no_vacios + 1; end if;
			
				if no_vacios < 9 and no_vacios > 0 then 
					mensaje := 'Partidas con datos incompletos ...';
					raise exception '%', mensaje;	
				end if;
			
				if no_vacios > 0 then
					-- Validar datos de catalogos ...
				
					totReg := 0;
					select count(c1) into totReg from keplersc.kdms where c1 = sucursal;
					if totReg = 0 then
						mensaje := 'No se encontro el Registro en la Tabla Kdms [Sucursales], partida [' || intCont::text || ']';
						raise exception '%', mensaje;
					end if;	
				
					valor_get := '';
					select c1 into valor_get from keplersc.kdiv where c1 = modelo;
					modelo_get := coalesce(valor_get, '');
					if length(modelo_get) = 0 then
						mensaje := 'No se encontro el Registro en la Tabla kdiv [Vehiculos], partida [' || intCont::text || ']';
						raise exception '%', mensaje;
					end if;	
				
					valor_get := '';
					select i.C3 into valor_get from keplersc.kddinv i inner join keplersc.kdiv k on k.c8 = i.c7 and k.c1 = modelo_get 
		 				where i.c1 = cve_invent;
					if anio <> coalesce(valor_get, '') then 
						mensaje := 'No se encontro el Registro en la Tabla kddinv [Inventarios], partida [' || intCont::text || ']';
						raise exception '%', mensaje;
					end if;	
				
					totReg := 0;
					select count(c3) into totReg from keplersc.kdice2 where c1 = modelo_get and c3 = color; 
					if totReg = 0 then
						mensaje := 'No se encontro el Registro en la Tabla Kdice2 [Colores EXT], partida [' || intCont::text || ']';
						raise exception '%', mensaje;
					
					--New code 20221221
					else
						color_desc := '';
						select c4 into color_desc from keplersc.kdice2 where c1 = modelo_get and c3 = color;
						color_desc := coalesce(color_desc,'');
	
					end if;	
			
					totReg := 0;
					select count(c3) into totReg from keplersc.kdice3 where c1 = modelo_get and c3 = vest; 
					if totReg = 0 then
						mensaje := 'No se encontro el Registro en la Tabla Kdice3 [Colores VESTIDURAS], partida [' || intCont::text || ']';
						raise exception '%', mensaje; 
					
					--New code 20221221
					else
						vest_desc := '';
						select c4 into vest_desc from keplersc.kdice3 where c1 = modelo_get and c3 = vest;
						vest_desc := coalesce(vest_desc,'');
											
					end if;		
			
					numero_partida := numero_partida + 1;
				
				end if;
				
			end loop;	
	
			if numero_partida = 0 then
				mensaje := 'Despues de validar la INFO, No se encontraron partidas a procesar ...';
				raise exception '%', mensaje; 
			end if; 
			
			--  * * *  Procesando Partidas ...
	
			numero_partida := 0;
			list_series_err := '';
		
			for intCont in 0..no_partidas - 1 loop
		
				no_vacios := 0;
			
				sucursal := coalesce((xpath('//document/k_mov/r'||intCont||'/suc/text()',dataxml))[1],'');
				modelo := coalesce((xpath('//document/k_mov/r'||intCont||'/modelo/text()',dataxml))[1],'');
				cve_invent := coalesce((xpath('//document/k_mov/r'||intCont||'/invent/text()',dataxml))[1],'');
				anio := coalesce((xpath('//document/k_mov/r'||intCont||'/anio/text()',dataxml))[1],'');
				descrip := coalesce((xpath('//document/k_mov/r'||intCont||'/descrip/text()',dataxml))[1],'');
				color := coalesce((xpath('//document/k_mov/r'||intCont||'/color/text()',dataxml))[1],'');
				vest := coalesce((xpath('//document/k_mov/r'||intCont||'/vest/text()',dataxml))[1],'');
				serie := coalesce((xpath('//document/k_mov/r'||intCont||'/serie/text()',dataxml))[1],'');
				refer := coalesce((xpath('//document/k_mov/r'||intCont||'/ref/text()',dataxml))[1],'');
				
			
				if length(sucursal) > 0 then no_vacios := no_vacios + 1; end if;
				if length(modelo) > 0 then no_vacios := no_vacios + 1; end if;
				if length(cve_invent) > 0 then no_vacios := no_vacios + 1; end if;
				if length(anio) > 0 then no_vacios := no_vacios + 1; end if;
				if length(descrip) > 0 then no_vacios := no_vacios + 1; end if;
				if length(color) > 0 then no_vacios := no_vacios + 1; end if;
				if length(vest) > 0 then no_vacios := no_vacios + 1; end if;
				if length(serie) > 0 then no_vacios := no_vacios + 1; end if;
				if length(refer) > 0 then no_vacios := no_vacios + 1; end if;	
				
				-- Si no es un renglon vacio procesa la Info 
				if no_vacios > 0 then 
			
					valor_get := '';
					-- 1. Se comento la sucursal debido a como estan los registros en K75
					-- 2. Faltaba considerar estatus 0 para discriminar registros ... Ya quedo 
					-- 3.- Se hizo una diferenciacion para Autos Nuevos ... 20230213 (se agrego la 2da linea)
					select max(c2) into valor_get from keplersc.kdinf where c5 = serie and c31 <> 0 /*and c1 = sucursal*/ 
						and c2 not in (select c2 from keplersc.kdinf where c31 = 20 and c32 = 70);
				
					intValor := coalesce(left(valor_get,4), '0')::integer;
			
					flag_serie := 0;
		
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
		
					-- En K75 No se validaba la Serie (including in other) para los Usados
		 			-- Aqui se esta Implementando la validacion logica que No puede se puede asignar la Serie 
		 			-- ... si ya esta asignada y viva (Estatus c31 = 10)
					-- Por la diferencia en la validacion de inclusion de las Series entre autos nuevos y usados 
					-- ... se incluye una validacion que valida el tipo de auto para las Operaciones : Alta
					if upper(valor_get_n_u) <> upper('N') then
						mensaje := 'Tipo de Auto : ' || upper(valor_get_n_u) || ' , fuera de Operacion.  Partida [' || intCont::text || ']';
						raise exception '%', mensaje;				
					end if;
				
		 			if intValor > 0 then
						--if upper(valor_get_n_u) = upper('N') then
							flag_serie := 1;
							list_series_err := list_series_err || 'Serie : ' || serie || ' [' || valor_get || '] ' || '|'; 	
						--end if;
					end if;
			
					if flag_serie = 0 then
				
						num_inventario := '';
				
						valor_get := '';
						-- Se comento la sucursal debido a como estan los registros en K75
						select max(c2) into valor_get from keplersc.kdinf where c19 = cve_invent /*and c1 = sucursal*/;
				
						intValor := coalesce(left(valor_get,4), '0')::integer;
				
						intValor = intValor + 1;
						num_inventario := lpad(intValor::text, 4, '0') || '-' || valor_get_dig_id || valor_get_dig_mod;
				
						if upper(valor_get_n_u) = upper('N') then
							valor_get_n_u_calc = 'NUEVO';
						else
							valor_get_n_u_calc = 'USADO';
						end if;
				
						select k.c4 as clase, k.c5 as marca, k.c6 as codISAN /*, k.c8 as tipo_auto*/ 
						into valor_get_clase, valor_get_marca, valor_get_codisan from keplersc.kdiv k 
							left join keplersc.kdic tcl on k.c4 = tcl.c1 
							left join keplersc.kdmarca tmr on k.c5 = tmr.c1 
							left join keplersc.kdtisan tis on k.c6 = tis.c1  
						where k.c1 = modelo;	
				
						insert into keplersc.kdinf(c1,c2,c3,c4,c5,c7,c9,c10,c11,c15,c17,c18,c19,c20,c21,c24,c31
							,c34,c35)
						values(sucursal, num_inventario, modelo, descrip, serie, right(serie,8), num_inventario, color, vest, anio 
							, coalesce(valor_get_marca,''), coalesce(valor_get_clase,''), cve_invent, coalesce(valor_get_codisan,'')
							, valor_get_n_u_calc, to_date(fecha_operacion,'YYYY-MM-DD'), 10
							,color_desc,vest_desc); 
		
						insert into keplersc.kdasig(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11)
						values(sucursal, num_inventario, modelo, descrip, color, vest, anio, serie, to_date(fecha_operacion,'YYYY-MM-DD')
							, valor_get_n_u_calc, 10); 
						
						numero_partida := numero_partida + 1; 
		
					end if;
				
				end if;
				
			end loop;
	
			if length(list_series_err) > 0 then
				list_series_err := left(list_series_err, length(list_series_err) - 1); 
			end if;
	
			/*
			mensaje := 'Opcion en pruebas operativas ...';
			--cmnt(1).free4eg by JMM
			raise exception '%', mensaje;
			*/
		
			-- * * * * *  END : Operacion ALTA - NUEVOS
		
		else
		
			-- * * * * *  START : Operacion ALTA - USADOS
			--mensaje := 'Se Procesaran Registros - Operacion Alta Usados ... Opcion en Desarrollo';
			--raise exception '%', mensaje;	
		
		
			--  * * *  Validando Partidas ...
			
			numero_partida := 0;
	
			for intCont in 0..no_partidas - 1 loop
		
				no_vacios := 0;
				
				sucursal := coalesce((xpath('//document/k_mov/r'||intCont||'/suc/text()',dataxml))[1],'');
				modelo := coalesce((xpath('//document/k_mov/r'||intCont||'/modelo/text()',dataxml))[1],'');
				cve_invent := coalesce((xpath('//document/k_mov/r'||intCont||'/invent/text()',dataxml))[1],'');
				anio := coalesce((xpath('//document/k_mov/r'||intCont||'/anio/text()',dataxml))[1],'');
				descrip := coalesce((xpath('//document/k_mov/r'||intCont||'/descrip/text()',dataxml))[1],'');
				color := coalesce((xpath('//document/k_mov/r'||intCont||'/color/text()',dataxml))[1],'');
				vest := coalesce((xpath('//document/k_mov/r'||intCont||'/vest/text()',dataxml))[1],'');
				serie := coalesce((xpath('//document/k_mov/r'||intCont||'/serie/text()',dataxml))[1],'');
				refer := coalesce((xpath('//document/k_mov/r'||intCont||'/ref/text()',dataxml))[1],'');
				
				c_marca := coalesce((xpath('//document/k_mov/r'||intCont||'/c_marca/text()',dataxml))[1],'');
				c_modelo := coalesce((xpath('//document/k_mov/r'||intCont||'/c_modelo/text()',dataxml))[1],'');
				c_anio := coalesce((xpath('//document/k_mov/r'||intCont||'/c_anio/text()',dataxml))[1],'');
				c_version := coalesce((xpath('//document/k_mov/r'||intCont||'/c_version/text()',dataxml))[1],'');
				c_descrip := coalesce((xpath('//document/k_mov/r'||intCont||'/c_descrip/text()',dataxml))[1],'');
			
				-- To Implement when ESantana Complete hes option
				--/*
				c_procedencia := coalesce((xpath('//document/k_mov/r'||intCont||'/c_procedencia/text()',dataxml))[1],'');
				c_ocupantes := coalesce((xpath('//document/k_mov/r'||intCont||'/c_ocupantes/text()',dataxml))[1],'4');
				c_cilindros := coalesce((xpath('//document/k_mov/r'||intCont||'/c_cilindros/text()',dataxml))[1],'4');
				c_puertas := coalesce((xpath('//document/k_mov/r'||intCont||'/c_puertas/text()',dataxml))[1],'4');
				c_combustible := coalesce((xpath('//document/k_mov/r'||intCont||'/c_combustible/text()',dataxml))[1],'GASOLINA');
				--*/
			
				if length(sucursal) > 0 then no_vacios := no_vacios + 1; end if;
				if length(modelo) > 0 then no_vacios := no_vacios + 1; end if;
				if length(cve_invent) > 0 then no_vacios := no_vacios + 1; end if;
				if length(anio) > 0 then no_vacios := no_vacios + 1; end if;
				if length(descrip) > 0 then no_vacios := no_vacios + 1; end if;
				if length(color) > 0 then no_vacios := no_vacios + 1; end if;
				if length(vest) > 0 then no_vacios := no_vacios + 1; end if;
				if length(serie) > 0 then no_vacios := no_vacios + 1; end if;
				if length(refer) > 0 then no_vacios := no_vacios + 1; end if;
			
				if length(c_marca) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_modelo) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_anio) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_version) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_descrip) > 0 then no_vacios := no_vacios + 1; end if;
			
				-- To Implement when ESantana Complete hes option
				--/*
				if length(c_procedencia) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_ocupantes) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_cilindros) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_puertas) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_combustible) > 0 then no_vacios := no_vacios + 1; end if;
				--*/
			
				-- Commented Code is pending to Implement when ESantana complete hes option
				if no_vacios < 19/*14*//*9*/ and no_vacios > 0 then 
					mensaje := 'Partidas con datos incompletos ...';
					raise exception '%', mensaje;	
				end if;
			
				if no_vacios > 0 then
					-- Validar datos de catalogos ...
				
					totReg := 0;
					select count(c1) into totReg from keplersc.kdms where c1 = sucursal;
					if totReg = 0 then
						mensaje := 'No se encontro el Registro en la Tabla Kdms [Sucursales], partida [' || intCont::text || ']';
						raise exception '%', mensaje;
					end if;	
				
					valor_get := '';
					select c1 into valor_get from keplersc.kdiv where c1 = modelo;
					modelo_get := coalesce(valor_get, '');
					if length(modelo_get) = 0 then
						mensaje := 'No se encontro el Registro en la Tabla kdiv [Vehiculos], partida [' || intCont::text || ']';
						raise exception '%', mensaje;
					end if;	
				
					valor_get := '';
					select i.C3 into valor_get from keplersc.kddinv i inner join keplersc.kdiv k on k.c8 = i.c7 and k.c1 = modelo_get 
		 				where i.c1 = cve_invent;
					if anio <> coalesce(valor_get, '') then 
						mensaje := 'No se encontro el Registro en la Tabla kddinv [Inventarios], partida [' || intCont::text || ']';
						raise exception '%', mensaje;
					end if;	
				
					totReg := 0;
					select count(c3) into totReg from keplersc.kdice2 where c1 = modelo_get and c3 = color; 
					if totReg = 0 then
						mensaje := 'No se encontro el Registro en la Tabla Kdice2 [Colores EXT], partida [' || intCont::text || ']';
						raise exception '%', mensaje;
					
					--New code 20221221
					else
						color_desc := '';
						select c4 into color_desc from keplersc.kdice2 where c1 = modelo_get and c3 = color;
						color_desc := coalesce(color_desc,'');
					
					end if;	
			
					totReg := 0;
					select count(c3) into totReg from keplersc.kdice3 where c1 = modelo_get and c3 = vest; 
					if totReg = 0 then
						mensaje := 'No se encontro el Registro en la Tabla Kdice3 [Colores VESTIDURAS], partida [' || intCont::text || ']';
						raise exception '%', mensaje; 
					
					--New code 20221221
					else
						vest_desc := '';
						select c4 into vest_desc from keplersc.kdice3 where c1 = modelo_get and c3 = vest;
						vest_desc := coalesce(vest_desc,'');			
					
					end if;		
				
					totReg := 0;
					select count(k.*) into totReg from keplersc.kdinfvus k where k.c6 <> 1 and 
						k.c1 = c_marca and k.c2 = c_modelo and k.c3 = c_anio and k.c4 = c_version;
					if totReg = 0 then
						mensaje := 'No se encontro coincidencia con el Registro en la Tabla Kdinfvus [Marca, Modelo, Anio, Version], partida [' || intCont::text || ']';
						raise exception '%', mensaje; 
					end if;	
					
					totReg := 0;
					select count(k.*) into totReg from keplersc.kdinfvus k where k.c6 <> 1 and 
						k.c1 = c_marca and k.c2 = c_modelo and k.c3 = c_anio and k.c4 = c_version and k.c5 = serie;
					if totReg = 0 then
						mensaje := 'No se encontro el Registro en la Tabla Kdinfvus [Serie], partida [' || intCont::text || ']';
						raise exception '%', mensaje; 
					end if;	
					
			
					numero_partida := numero_partida + 1;
				
				end if;
				
			end loop;	
	
			if numero_partida = 0 then
				mensaje := 'Despues de validar la INFO, No se encontraron partidas a procesar ...';
				raise exception '%', mensaje; 
			end if; 
			
			--  * * *  Procesando Partidas ...
	
			numero_partida := 0;
			list_series_err := '';
		
			for intCont in 0..no_partidas - 1 loop
		
				no_vacios := 0;
			
				sucursal := coalesce((xpath('//document/k_mov/r'||intCont||'/suc/text()',dataxml))[1],'');
				modelo := coalesce((xpath('//document/k_mov/r'||intCont||'/modelo/text()',dataxml))[1],'');
				cve_invent := coalesce((xpath('//document/k_mov/r'||intCont||'/invent/text()',dataxml))[1],'');
				anio := coalesce((xpath('//document/k_mov/r'||intCont||'/anio/text()',dataxml))[1],'');
				descrip := coalesce((xpath('//document/k_mov/r'||intCont||'/descrip/text()',dataxml))[1],'');
				color := coalesce((xpath('//document/k_mov/r'||intCont||'/color/text()',dataxml))[1],'');
				vest := coalesce((xpath('//document/k_mov/r'||intCont||'/vest/text()',dataxml))[1],'');
				serie := coalesce((xpath('//document/k_mov/r'||intCont||'/serie/text()',dataxml))[1],'');
				refer := coalesce((xpath('//document/k_mov/r'||intCont||'/ref/text()',dataxml))[1],'');

				c_marca := coalesce((xpath('//document/k_mov/r'||intCont||'/c_marca/text()',dataxml))[1],'');
				c_modelo := coalesce((xpath('//document/k_mov/r'||intCont||'/c_modelo/text()',dataxml))[1],'');
				c_anio := coalesce((xpath('//document/k_mov/r'||intCont||'/c_anio/text()',dataxml))[1],'');
				c_version := coalesce((xpath('//document/k_mov/r'||intCont||'/c_version/text()',dataxml))[1],'');
				c_descrip := coalesce((xpath('//document/k_mov/r'||intCont||'/c_descrip/text()',dataxml))[1],'');

				-- To Implement when ESantana Complete hes option
				--/*
				c_procedencia := coalesce((xpath('//document/k_mov/r'||intCont||'/c_procedencia/text()',dataxml))[1],'');
				c_ocupantes := coalesce((xpath('//document/k_mov/r'||intCont||'/c_ocupantes/text()',dataxml))[1],'4');
				c_cilindros := coalesce((xpath('//document/k_mov/r'||intCont||'/c_cilindros/text()',dataxml))[1],'4');
				c_puertas := coalesce((xpath('//document/k_mov/r'||intCont||'/c_puertas/text()',dataxml))[1],'4');
				c_combustible := coalesce((xpath('//document/k_mov/r'||intCont||'/c_combustible/text()',dataxml))[1],'GASOLINA');
				--*/
			
				if length(sucursal) > 0 then no_vacios := no_vacios + 1; end if;
				if length(modelo) > 0 then no_vacios := no_vacios + 1; end if;
				if length(cve_invent) > 0 then no_vacios := no_vacios + 1; end if;
				if length(anio) > 0 then no_vacios := no_vacios + 1; end if;
				if length(descrip) > 0 then no_vacios := no_vacios + 1; end if;
				if length(color) > 0 then no_vacios := no_vacios + 1; end if;
				if length(vest) > 0 then no_vacios := no_vacios + 1; end if;
				if length(serie) > 0 then no_vacios := no_vacios + 1; end if;
				if length(refer) > 0 then no_vacios := no_vacios + 1; end if;	
			
				if length(c_marca) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_modelo) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_anio) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_version) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_descrip) > 0 then no_vacios := no_vacios + 1; end if;
		
				-- To Implement when ESantana Complete hes option
				--/* 
				if length(c_procedencia) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_ocupantes) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_cilindros) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_puertas) > 0 then no_vacios := no_vacios + 1; end if;
				if length(c_combustible) > 0 then no_vacios := no_vacios + 1; end if;
				--*/
			
			
				-- Si no es un renglon vacio procesa la Info 
				if no_vacios > 0 then 
			
					valor_get := '';
					-- 1.- Se comento la sucursal debido a como estan los registros en K75
					-- 2.- Faltaba considerar estatus 0 para discriminar registros ... Ya quedo 
					-- 3.- Se cambio la diferenciacion de Estatus en Usados ... 20230213 
					select max(c2) into valor_get from keplersc.kdinf where c5 = serie and ( c31 = 10 or ( c31 > 0 and c32 < 60 ) ) /*and c31 = 10*/ /*<> 0*/ /*and c1 = sucursal*/;
				
					intValor := coalesce(left(valor_get,4), '0')::integer;
			
					flag_serie := 0;
		
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
		
				 	-- En K75 No se validaba la Serie (including in other) para los Usados
		 			-- Aqui se esta Implementando la validacion logica que No puede se puede asignar la Serie 
		 			-- ... si ya esta asignada y viva (Estatus c31 = 10)
					-- Por la diferencia en la validacion de inclusion de las Series entre autos nuevos y usados 
					-- ... se incluye una validacion que valida el tipo de auto para las Operaciones : Alta
					if upper(valor_get_n_u) = upper('N') then
						mensaje := 'Tipo de Auto : ' || upper(valor_get_n_u) || ' , fuera de Operacion.  Partida [' || intCont::text || ']';
						raise exception '%', mensaje;				
					end if;
				
		 			if intValor > 0 then
						--if upper(valor_get_n_u) = upper('N') then
							flag_serie := 1;
							list_series_err := list_series_err || 'Serie : ' || serie || ' [' || valor_get || '] ' || '|'; 	
						--end if;
					end if;
			
					if flag_serie = 0 then
				
						num_inventario := '';
				
						valor_get := '';
						-- Se comento la sucursal debido a como estan los registros en K75
						select max(c2) into valor_get from keplersc.kdinf where c19 = cve_invent /*and c1 = sucursal*/;
				
						intValor := coalesce(left(valor_get,4), '0')::integer;
				
						intValor = intValor + 1;
						num_inventario := lpad(intValor::text, 4, '0') || '-' || valor_get_dig_id || valor_get_dig_mod;
				
						if upper(valor_get_n_u) = upper('N') then
							valor_get_n_u_calc = 'NUEVO';
						else
							valor_get_n_u_calc = 'USADO';
						end if;
				
						select k.c4 as clase, k.c5 as marca, k.c6 as codISAN /*, k.c8 as tipo_auto*/ 
						into valor_get_clase, valor_get_marca, valor_get_codisan from keplersc.kdiv k 
							left join keplersc.kdic tcl on k.c4 = tcl.c1 
							left join keplersc.kdmarca tmr on k.c5 = tmr.c1 
							left join keplersc.kdtisan tis on k.c6 = tis.c1  
						where k.c1 = modelo;	
				
						-- Commented Code is pending to Implement when ESantana complete hes option
						insert into keplersc.kdinf(c1,c2,c3,c4,c5,c7,c9,c10,c11,c15,c17,c18,c19,c20,c21,c24,c31
							,c85,c86,c87,c88,c89
							,c34,c35
							,c90,c91,c92,c93,c94)
						values(sucursal, num_inventario, modelo, c_descrip /*descrip*/, serie, right(serie,8), num_inventario, color, vest, anio 
							, coalesce(valor_get_marca,''), coalesce(valor_get_clase,''), cve_invent, coalesce(valor_get_codisan,'')
							, valor_get_n_u_calc, to_date(fecha_operacion,'YYYY-MM-DD'), 10
							, c_marca, c_modelo, c_anio, c_version, serie
							,color_desc,vest_desc
							, c_procedencia, c_ocupantes::int, c_cilindros::int, c_puertas::int, c_combustible); 
		
						insert into keplersc.kdasig(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11)
						values(sucursal, num_inventario, modelo, c_descrip /*descrip*/, color, vest, anio, serie, to_date(fecha_operacion,'YYYY-MM-DD')
							, valor_get_n_u_calc, 10); 
			
						-- New TBL Intermedia only 4 Used Cars
						update keplersc.kdinfvus set c6 = 1 where c6 <> 1 and 
							c1 = c_marca and c2 = c_modelo and c3 = c_anio and c4 = c_version and c5 = serie;
						
						numero_partida := numero_partida + 1; 
		
					end if;
				
				end if;
				
			end loop;
	
			if length(list_series_err) > 0 then
				list_series_err := left(list_series_err, length(list_series_err) - 1); 
			end if;
	
			/*
			mensaje := 'Opcion en pruebas operativas ...';
			--cmnt(1).free4eg by JMM
			raise exception '%', mensaje;
			*/
		
			-- * * * * *  END : Operacion ALTA - USADOS
		
		end if;
	
	
	else 
	
		-- * * * * *  START : Operacion BAJA (Nuevos / Usados) 4 conditions exceptions 
	
		--  * * *  Validando Partidas ...
		
		numero_partida := 0;

		for intCont in 0..no_partidas - 1 loop
	
			no_vacios := 0;
			
			sucursal := coalesce((xpath('//document/k_mov/r'||intCont||'/suc/text()',dataxml))[1],'');
			modelo := coalesce((xpath('//document/k_mov/r'||intCont||'/modelo/text()',dataxml))[1],'');
			cve_invent := coalesce((xpath('//document/k_mov/r'||intCont||'/invent/text()',dataxml))[1],'');
			anio := coalesce((xpath('//document/k_mov/r'||intCont||'/anio/text()',dataxml))[1],'');
			descrip := coalesce((xpath('//document/k_mov/r'||intCont||'/descrip/text()',dataxml))[1],'');
			color := coalesce((xpath('//document/k_mov/r'||intCont||'/color/text()',dataxml))[1],'');
			vest := coalesce((xpath('//document/k_mov/r'||intCont||'/vest/text()',dataxml))[1],'');
			serie := coalesce((xpath('//document/k_mov/r'||intCont||'/serie/text()',dataxml))[1],'');
			fecha := coalesce((xpath('//document/k_mov/r'||intCont||'/fech/text()',dataxml))[1],'');
			borrar := coalesce((xpath('//document/k_mov/r'||intCont||'/borrar/text()',dataxml))[1],'');

			if length(sucursal) > 0 then no_vacios := no_vacios + 1; end if;
			if length(modelo) > 0 then no_vacios := no_vacios + 1; end if;
			if length(cve_invent) > 0 then no_vacios := no_vacios + 1; end if;
			if length(anio) > 0 then no_vacios := no_vacios + 1; end if;
			if length(descrip) > 0 then no_vacios := no_vacios + 1; end if;
			if length(color) > 0 then no_vacios := no_vacios + 1; end if;
			if length(vest) > 0 then no_vacios := no_vacios + 1; end if;
			if length(serie) > 0 then no_vacios := no_vacios + 1; end if;
			if length(fecha) > 0 then no_vacios := no_vacios + 1; end if;
		
			if no_vacios < 9 and no_vacios > 0 then 
				mensaje := 'Partidas con datos incompletos ...';
				raise exception '%', mensaje;	
			end if;
		
			if no_vacios > 0 and upper(borrar) = upper('X') then
				-- Validar datos  ...
			
				totReg := 0;
				select count(*) into totReg from keplersc.kdinf 
				where c1 = sucursal and c2 = cve_invent and c3 = modelo and c5 = serie and c15 = anio and c31 = 10;
				if totReg = 0 then
					mensaje := 'No se encontro el Registro a Cancelar en la Tabla Kdms [KdInf], partida [' || intCont::text || ']';
					raise exception '%', mensaje;
				end if;	

				totReg := 0;
				select count(*) into totReg from keplersc.kdasig 
				where c1 = sucursal and c2 = cve_invent and c3 = modelo and c8 = serie and c7 = anio and c11 = 10;

				if totReg = 0 then
					mensaje := 'No se encontro el Registro a Cancelar en la Tabla Kdms [KdAsig], partida [' || intCont::text || ']';
					raise exception '%', mensaje;
				end if;	
		
				numero_partida := numero_partida + 1;
			
			end if;
			
		end loop;	

		if numero_partida = 0 then
			mensaje := 'Despues de validar la INFO, No se encontraron partidas a procesar ...';
			raise exception '%', mensaje; 
		end if; 
	
	
		--  * * *  Procesando Partidas ...

		numero_partida := 0;
		list_series_err := '';
	
		for intCont in 0..no_partidas - 1 loop
	
			no_vacios := 0;
		
			sucursal := coalesce((xpath('//document/k_mov/r'||intCont||'/suc/text()',dataxml))[1],'');
			modelo := coalesce((xpath('//document/k_mov/r'||intCont||'/modelo/text()',dataxml))[1],'');
			cve_invent := coalesce((xpath('//document/k_mov/r'||intCont||'/invent/text()',dataxml))[1],'');
			anio := coalesce((xpath('//document/k_mov/r'||intCont||'/anio/text()',dataxml))[1],'');
			descrip := coalesce((xpath('//document/k_mov/r'||intCont||'/descrip/text()',dataxml))[1],'');
			color := coalesce((xpath('//document/k_mov/r'||intCont||'/color/text()',dataxml))[1],'');
			vest := coalesce((xpath('//document/k_mov/r'||intCont||'/vest/text()',dataxml))[1],'');
			serie := coalesce((xpath('//document/k_mov/r'||intCont||'/serie/text()',dataxml))[1],'');
			fecha := coalesce((xpath('//document/k_mov/r'||intCont||'/fech/text()',dataxml))[1],'');
			borrar := coalesce((xpath('//document/k_mov/r'||intCont||'/borrar/text()',dataxml))[1],'');
	
			c_marca := coalesce((xpath('//document/k_mov/r'||intCont||'/c_marca/text()',dataxml))[1],'');
			c_modelo := coalesce((xpath('//document/k_mov/r'||intCont||'/c_modelo/text()',dataxml))[1],'');
			c_anio := coalesce((xpath('//document/k_mov/r'||intCont||'/c_anio/text()',dataxml))[1],'');
			c_version := coalesce((xpath('//document/k_mov/r'||intCont||'/c_version/text()',dataxml))[1],'');
			c_descrip := coalesce((xpath('//document/k_mov/r'||intCont||'/c_descrip/text()',dataxml))[1],'');
		
			if length(sucursal) > 0 then no_vacios := no_vacios + 1; end if;
			if length(modelo) > 0 then no_vacios := no_vacios + 1; end if;
			if length(cve_invent) > 0 then no_vacios := no_vacios + 1; end if;
			if length(anio) > 0 then no_vacios := no_vacios + 1; end if;
			if length(descrip) > 0 then no_vacios := no_vacios + 1; end if;
			if length(color) > 0 then no_vacios := no_vacios + 1; end if;
			if length(vest) > 0 then no_vacios := no_vacios + 1; end if;
			if length(serie) > 0 then no_vacios := no_vacios + 1; end if;
			if length(fecha) > 0 then no_vacios := no_vacios + 1; end if;	
			
			-- Si no es un renglon vacio procesa la Info 
			if no_vacios > 0 and upper(borrar) = upper('X') then 
		
				intValor := 0;
				select c31 into intValor from keplersc.kdinf 
				where c1 = sucursal and c2 = cve_invent and c3 = modelo and c5 = serie and c15 = anio /*and c31 = 10*/;			
			
				flag_serie := 0;
			
				if coalesce(intValor,0) = 10 then
					update keplersc.kdinf set c31 = 0 
				    where c1 = sucursal and c2 = cve_invent and c3 = modelo and c5 = serie and c15 = anio and c31 = 10;
				else
					flag_serie := 1;
					list_series_err := list_series_err || 'Serie : ' || serie || ' [' || cve_invent || '] .ST = ' || intValor::text || '|'; 	
				end if;
				
				if flag_serie = 0 then
				
					intValor := 0;
					select c11 from keplersc.kdasig into intValor  
					where c1 = sucursal and c2 = cve_invent and c3 = modelo and c8 = serie and c7 = anio /*and c11 = 10*/;
				
					if coalesce(intValor,0) = 10 then
						update keplersc.kdasig set c11 = 0 
				    	where c1 = sucursal and c2 = cve_invent and c3 = modelo and c8 = serie and c7 = anio and c11 = 10;
					else
						mensaje := 'Error Discrepancia de Datos Tablas KdInf y KdAsig , Serie : ' || serie || ' [' || cve_invent || '] ';
						raise exception '%', mensaje;
					end if;
				
					if length(c_marca) > 0 and length(c_modelo) > 0 and length(c_anio) > 0 and length(c_version) > 0 then
					
						totReg := 0;
						select count(k.*) into totReg from keplersc.kdinfvus k where k.c6 /*<>*/ = 1 and 
							k.c1 = c_marca and k.c2 = c_modelo and k.c3 = c_anio and k.c4 = c_version and k.c5 = serie;
						if totReg = 0 then
							mensaje := 'No se encontro un Registro Valido en la Tabla Kdinfvus [ Serie & CAT Campos.IDs ], partida [ ' || intCont::text || ' ]';
							raise exception '%', mensaje; 
						end if;	
					
						update keplersc.kdinfvus set c6 = 0 where c6 /*<>*/ = 1 and 
							c1 = c_marca and c2 = c_modelo and c3 = c_anio and c4 = c_version and c5 = serie;
						
					end if;
				
					numero_partida := numero_partida + 1;
				
				end if;
			
			end if;
			
		end loop;	
	
	
		if length(list_series_err) > 0 then
			list_series_err := left(list_series_err, length(list_series_err) - 1); 
		end if;
	
		/*
		mensaje := 'Opcion en Construccion ...';
		--cmnt(1).free4eg by JMM
		raise exception '%', mensaje;
		*/
	
		-- * * * * *  END : Operacion BAJA (Nuevos / Usados)

	end if;

	--resultado := 1;
	if length(list_series_err) > 0 then
		resultado := 2;
		if upper(left(trim(operacion),4)) = upper('ALTA') then 
			if numero_partida >= 1 then
				mensaje := 'Las partidas han sido registradas parcialmente ...';
			else
				mensaje := 'No se ha registrado ninguna partida, ver las excepciones ...';
			end if;
		else
			if numero_partida >= 1 then
				mensaje := 'Las partidas han sido canceladas parcialmente ...';
			else
				mensaje := 'No se ha cancelado niguna partida, ver las excepciones ...';
			end if;
		end if;
		adicionales := list_series_err;
	else
		resultado := 1;
		if upper(left(trim(operacion),4)) = upper('ALTA') then
			mensaje := 'Las partidas han sido registradas exitosamente ...';
		else
			mensaje := 'Las partidas han sido canceladas exitosamente ...';
		end if;
		adicionales := '';
	end if;
	return query select resultado, mensaje, adicionales;	


exception
	when others then
		resultado := 0;
		mensaje := 'autos_com_asig_crud (' || operacion || ');  ' || '['|| sqlstate || '] ' || sqlerrm ;
		--adicionales := '';
		adicionales := num_inventario;
		return query select resultado, mensaje, adicionales;	

end;
$function$
