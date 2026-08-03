CREATE OR REPLACE FUNCTION keplersc.ventas_caidas(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Esta funcion resuelve VENTAS CAIDAS UEN REF (K75 1.GUARDA_REFACCIONES , 2.AJUSTA_RESUMEN_VENTAS_CAIDAS)  
	--Parametros de entrada en xml:
	-- dataXml--> Datos del movimiento;  
	--Parametros de salida tabla: campos resultado, mensaje y adicionales.
	--Author: Jose Mendoza 
	--Fecha: 5/10/2023
	--Bitacora de cambios:
	-- Fecha: X , Dscr Change
	
	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
   
    campo text = '';
   	valor text = '';
   
    suc text;
   	tipo text;
    folio text;
   	fecha text;
   	origen text;
   
   	hora text;
   
    mes_tx text;
   	anio_tx text;
    mes int;
    anio int;
   
    no_partidas int;
    numero_partida int;
    no_vacios int;
   
    intCont int;
    totReg int;
    cantReg decimal = 0.00;
    existencias decimal = 0.00;
    
    prod text = '';
    descr text = '';
    cant text = '';
    pu text = '';
    monto text = '';
    motivo text = '';
   
    cant_d decimal = 0.00;
	pu_d decimal = 0.00;
	monto_d decimal = 0.00;

	fecha_d date;

	fprod text = '';
	fcant decimal = 0.00;

	suc_alt text = '';
   
	--Variables de retorno
	resultado text;
	mensaje text; --Se asigna el valor esperado de la cuenta
	adicionales text;

begin
	
	suc := coalesce((xpath('//document/k_sucn/r1/text()', dataxml))[1]::text,'');

	-- 4 Local & Test Environment
	--suc_alt := '02'; 
	suc_alt := suc;

	origen := coalesce((xpath('//document/cmb_orig/r1/text()', dataxml))[1]::text,'');
	tipo := coalesce((xpath('//document/k_tipon/r1/text()', dataxml))[1]::text,'');
	folio := coalesce((xpath('//document/k_folio/text()', dataxml))[1]::text,'');
   
    fecha := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
   
   	--hora := coalesce((xpath('//document/k_hora/text()', dataxml))[1]::text,'00:00:00')::text;
   
    mes := extract(month from to_date(fecha,'YYYY-MM-DD') );
    anio := extract(year from to_date(fecha,'YYYY-MM-DD') );
    mes_tx := mes::text;
    anio_tx := anio:: text;
   
    if length(mes_tx) = 1 then
    	mes_tx := '0' || mes_tx;
    end if;
   
    if length(anio_tx) <> 4 or length(mes_tx) <> 2 then 
    	raise exception '%', 'No se pudieron determinar el Anio y/o Mes de la operacion Ventas Caidas.';
    end if;

    -- * * * Validar Datos Generales  
   
   	if length(suc) = 0 then
   	   	mensaje := 'La Sucursal No puede estar Vacia ...';
		raise exception '%', mensaje;	
   	else
   		totReg := 0;
		select count(c1) into totReg from keplersc.kdms  
		where c1 = suc;
		if totReg = 0 then
		 	mensaje := 'La Sucursal No es Valida ...';
			raise exception '%', mensaje;	
		end if;
   	end if;
   
   	origen := upper(origen);
   
   	if length(origen) = 0 or (origen <> 'R' and origen <> 'S') then
   		mensaje := 'El Origen No es Valido ...';
		raise exception '%', mensaje;		
   	end if;
   
   	if origen = 'S' then
   		if length(tipo) = 0 or length(folio) = 0 then
   		   	mensaje := 'Datos Incompletos para Verificar Orden de Referencia ...';
			raise exception '%', mensaje;	
   		else
   			
   			--raise notice '%''%''%', suc, tipo, folio;	
   		
   			totReg := 0;
			select count(c1) into totReg from keplersc.kdord 
			where c1 = suc_alt/*suc*/ and c2 = tipo and c3 = folio;  -- change this 4 productive environment 
			if totReg = 0 then
			 	mensaje := 'La Orden No es Valida ...';
				raise exception '%', mensaje;	
			end if;
		
   		end if;
   	else
   		tipo := '';
   		folio := '';
   	end if;
   
   	if to_date(fecha,'YYYY-MM-DD') <> current_date then
   		mensaje := 'La Fecha No es Valida ...';
		raise exception '%', mensaje;
   	end if;
      
   	fecha_d := to_date(fecha,'YYYY-MM-DD');
   
   	-- 4 Testing 
   	/*
    mensaje := 'Validacion de Encabezado OK, (DEV in Process) ...';
	raise exception '%', mensaje;
    */
   
   
   	-- * * * Partidas
    no_partidas := 0;
	strValor := coalesce((xpath('//document/k_mov/no_partidas/text()',dataxml))[1]::text,'0');
	no_partidas := strValor::integer;

	if no_partidas <= 0 then
		mensaje := 'No hay partidas a Procesar ...';
		raise exception '%', mensaje;	
	end if;

	numero_partida = 0;

	for intCont in 0..no_partidas - 1 loop
		
		no_vacios := 0;
		
		prod := coalesce((xpath('//document/k_mov/r'||intCont||'/prod/text()',dataxml))[1],'');
		descr := coalesce((xpath('//document/k_mov/r'||intCont||'/dscr/text()',dataxml))[1],'');
		cant := coalesce((xpath('//document/k_mov/r'||intCont||'/cant/text()',dataxml))[1],'');
		pu := coalesce((xpath('//document/k_mov/r'||intCont||'/pu/text()',dataxml))[1],'');
		monto := coalesce((xpath('//document/k_mov/r'||intCont||'/monto/text()',dataxml))[1],'');
		motivo := coalesce((xpath('//document/k_mov/r'||intCont||'/motivo/text()',dataxml))[1],'');
	
		if length(prod) > 0 then no_vacios := no_vacios + 1; end if;
		if length(descr) > 0 then no_vacios := no_vacios + 1; end if;
		if length(cant) > 0 then no_vacios := no_vacios + 1; end if;
		if length(pu) > 0 then no_vacios := no_vacios + 1; end if;
		if length(monto) > 0 then no_vacios := no_vacios + 1; end if;
		if length(motivo) > 0 then no_vacios := no_vacios + 1; end if;
	
		if no_vacios < 6 /*and no_vacios > 0*/ then 
			mensaje := 'Partidas con datos incompletos ...';
			raise exception '%', mensaje;	
		end if;
	
		if no_vacios > 0 then
			-- Validar datos de catalogos ...
		
			totReg := 0;
			select count(c1) into totReg from keplersc.kdini where c1 = prod;
			if totReg = 0 then
				mensaje := 'No se encontro el Registro en la Tabla Kdini [Productos], Partida [' || (intCont+1)::text /*prod*/ || ']';
				raise exception '%', mensaje;
			end if;	
		
			motivo := upper(motivo);
		
			if motivo <> 'P' and motivo <> 'E' and motivo <> 'C' then 
				mensaje := 'Motivo No Valido, Partida [' || (intCont+1)::text /*prod*/ || ']';
				raise exception '%', mensaje;
			end if; 
		
			numero_partida := numero_partida + 1;
		
		end if;
	
	end loop;	

	if numero_partida = 0 then
		mensaje := 'Despues de validar la INFO, No se encontraron partidas a Procesar ...';
		raise exception '%', mensaje; 
	end if; 



	-- Ciclo de Descuento de Registros Existentes ...

	if ( (select count(*) from keplersc.kdvencaidas where c1 = suc and c2 = fecha_d and c10 = origen and c11 = tipo and c12 = folio) > 0 ) then   
	
		for fprod, fcant in select c4, c6 from keplersc.kdvencaidas where c1 = suc and c2 = fecha_d and c10 = origen and c11 = tipo and c12 = folio order by c3 
		loop
			
			-- Seccion P/ Validar Cantidades de Estadisticas  
			
			cantReg := 0;
			select c5 into cantReg from keplersc.kdvencaires  
			where c1 = suc and c2 = fprod and c3 = anio_tx and c4 = mes_tx;
			if cantReg is null then
				-- No hay registros previos en el periodo
				mensaje := 'No existe registro en las Estadicticas, item [' || fprod || ']';
				raise exception '%', mensaje;
			else
				if fcant is null or fcant <= 0 then 
					mensaje := 'Cantidad de Registro Historico No es Valida, item [' || fprod || ']';
					raise exception '%', mensaje;
				else
					if cantReg - fcant < 0 then
						mensaje := 'Las Estadisticas No pueden manejar Cantidades Negativas, item [' || fprod || ']';
						raise exception '%', mensaje;
					else
					
						update keplersc.kdvencaires 
						set c5 = c5 - fcant
						where c1 = suc and c2 = fprod and c3 = anio_tx and c4 = mes_tx;
						
					end if;
				end if;
			end if;
		
			-- [End] Seccion P/ Validar Cantidades de Estadisticas
				
		end loop;
	
		delete from keplersc.kdvencaidas 
		where c1 = suc and c2 = fecha_d and c10 = origen and c11 = tipo and c12 = folio; 
		
	end if; -- End, If Records Found  

	-- [END] , Ciclo de Descuento de Registros Existentes ...	
	
	
	-- 4 Testing 
	/*
    mensaje := 'Procesamiento de Ciclo de Descuento Registros Historicos Completado OK, (DEV in Process) ...';
	raise exception '%', mensaje;
	*/
	
	numero_partida := 0;

	for intCont in 0..no_partidas - 1 loop 
		
		--raise notice '% %', intCont, no_partidas;

		prod := coalesce((xpath('//document/k_mov/r'||intCont||'/prod/text()',dataxml))[1],'');
		descr := coalesce((xpath('//document/k_mov/r'||intCont||'/dscr/text()',dataxml))[1],'');
		cant := coalesce((xpath('//document/k_mov/r'||intCont||'/cant/text()',dataxml))[1],'0');
		pu := coalesce((xpath('//document/k_mov/r'||intCont||'/pu/text()',dataxml))[1],'0');
		monto := coalesce((xpath('//document/k_mov/r'||intCont||'/monto/text()',dataxml))[1],'0');
		motivo := coalesce((xpath('//document/k_mov/r'||intCont||'/motivo/text()',dataxml))[1],'');
	
		cant_d := cant::decimal;
		pu_d := pu::decimal;
		monto_d := monto::decimal;
		 
		-- Cantidad debe ser > 0  
		if cant_d <= 0 then 
			mensaje := 'Cantidad debe ser > 0 , [' || prod || ']';
			raise exception '%', mensaje; 		
		end if;
		
		-- Precio Unitario debe ser > 0  
		if pu_d <= 0 then 
			mensaje := 'Precio Unitario debe ser > 0 , [' || prod || ']';
			raise exception '%', mensaje; 		
		end if;
	
		-- Importe debe ser > 0  
		if monto_d <= 0 then 
			mensaje := 'Importe debe ser > 0 , [' || prod || ']';
			raise exception '%', mensaje; 		
		end if;
	
		motivo := upper(motivo);
		
		if motivo <> 'P' and motivo <> 'E' and motivo <> 'C' then 
			mensaje := 'Motivo No Valido, Partida [' || (intCont+1)::text /*prod*/ || ']';
			raise exception '%', mensaje;
		end if; 
		
		numero_partida := numero_partida + 1; 		
		
		-- INS {kdbom} 
	   	insert into keplersc.kdvencaidas ( c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12 )
		values (
			suc, fecha_d, numero_partida, prod, descr, cant_d, pu_d, monto_d, motivo 
			, origen, tipo, folio
		);
		
	
		--raise notice '%','Paso TRN kdvencaidas ';
	
	
		-- * * * Registro de Estadisticas ... 
	
		cantReg := 0;
		select c5 into cantReg from keplersc.kdvencaires  
		where c1 = suc and c2 = prod and c3 = anio_tx and c4 = mes_tx;
		existencias := coalesce(cantReg, -1);
		if existencias < 0 or cantReg is null then
		
		   	insert into keplersc.kdvencaires ( c1, c2, c3, c4, c5 ) 
			values ( suc, prod, anio_tx, mes_tx, cant_d );
			
		else
		
			update keplersc.kdvencaires 
			set c5 = c5 + cant_d
			where c1 = suc and c2 = prod and c3 = anio_tx and c4 = mes_tx;	
		
		end if;
	
		--raise notice '%','Paso TRN kdvencaires ';

	
		cantReg := 0;
		select count(*) into cantReg from keplersc.kdreflastmov   
		where c1 = suc and c2 = prod;
		if cantReg = 0 or cantReg is null then
		
		   	insert into keplersc.kdreflastmov ( c1, c2, c3 ) 
			values ( suc, prod, fecha_d );
			
		else
		
			update keplersc.kdreflastmov 
			set c3 = fecha_d 
			where c1 = suc and c2 = prod;	
		
		end if;
	
		--raise notice '%','Paso TRN kdreflastmov ';
		
	end loop;

	--raise notice '%','Paso For Loop Transacciones ';

	-- 4 Testing 
	/*
    mensaje := 'Proceso Transaccional Completado OK, (DEV in Process) ...';
	raise exception '%', mensaje;
	*/


	resultado := 1;
	mensaje := 'Registros Cargados Exitosamente ...';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	


exception
	when others then
		resultado := 0;
		mensaje := 'ventas_caidas() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
