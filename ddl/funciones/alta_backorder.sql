CREATE OR REPLACE FUNCTION keplersc.alta_backorder(dataxml xml, p_folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Esta funcion resuelve ALTA_BACKORDER UEN REF  
	--Parametros de entrada en xml:
	-- dataXml--> Datos del movimiento;  
	-- folio_operacion --> Folio asignado a la transaccion
	--Parametros de salida tabla: campos resultado, mensaje y adicionales.
	--Author: Jose Mendoza 
	--Fecha: 3/09/2023
	--Bitacora de cambios:
	-- Fecha: 10/09/2023 , se Implemento la Baja (Alta de la Salida de BackOrder)
	
	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
   
    campo text = '';
   	valor text = '';
   
    suc text;
   	gen text;
   	nat text;
   	gpo text;
   	tipo text;
    folio text;
   	fecha text;
   	refer text;
   
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
    
    parte text = '';
    descr text = '';
    cant text = '';
    um text = '';
    pu text = '';
    monto text = '';
   
    cant_d decimal = 0.00;
	pu_d decimal = 0.00;
	monto_d decimal = 0.00;
   
	--Variables de retorno
	resultado text;
	mensaje text; --Se asigna el valor esperado de la cuenta
	adicionales text;

begin
	
	suc := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	gen := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	nat := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	gpo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	refer := (xpath('//document/k_refer/text()', dataxml))[1];

    folio := p_folio_operacion; 
    
    fecha := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
   
   	hora := coalesce((xpath('//document/k_hora/text()', dataxml))[1]::text,'00:00:00')::text;
   
    mes := extract(month from to_date(fecha,'YYYY-MM-DD') );
    anio := extract(year from to_date(fecha,'YYYY-MM-DD') );
    mes_tx := mes::text;
    anio_tx := anio:: text;
   
    if length(mes_tx) = 1 then
    	mes_tx := '0' || mes_tx;
    end if;
   
    if length(anio_tx) <> 4 or length(mes_tx) <> 2 then 
    	raise exception '%', 'No se pudieron determinar el Anio y/o Mes de la operacion Alta_BackOrder ' || '['|| refer || '] ';
    end if;

    
   	--Partidas
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
		
		parte := coalesce((xpath('//document/k_mov/r'||intCont||'/k_parte/text()',dataxml))[1],'');
		descr := coalesce((xpath('//document/k_mov/r'||intCont||'/k_descr/text()',dataxml))[1],'');
		cant := coalesce((xpath('//document/k_mov/r'||intCont||'/k_q/text()',dataxml))[1],'');
		um := coalesce((xpath('//document/k_mov/r'||intCont||'/k_unidad/text()',dataxml))[1],'');
		pu := coalesce((xpath('//document/k_mov/r'||intCont||'/k_precio/text()',dataxml))[1],'');
		monto := coalesce((xpath('//document/k_mov/r'||intCont||'/k_monto/text()',dataxml))[1],'');
	
		if length(parte) > 0 then no_vacios := no_vacios + 1; end if;
		if length(descr) > 0 then no_vacios := no_vacios + 1; end if;
		if length(cant) > 0 then no_vacios := no_vacios + 1; end if;
		if length(um) > 0 then no_vacios := no_vacios + 1; end if;
		if length(pu) > 0 then no_vacios := no_vacios + 1; end if;
		if length(monto) > 0 then no_vacios := no_vacios + 1; end if;
	
		if no_vacios < 6 and no_vacios > 0 then 
			mensaje := 'Partidas con datos incompletos ...';
			raise exception '%', mensaje;	
		end if;

		--VCSS manejo de reemplazo, manejar refaccion original en back order. 30 Marzo 2026
		SELECT coalesce(clave_original,'') into strValor FROM keplersc.prod_consulta_lista(suc, parte, 'CLAVE') LIMIT 1;

		if strValor <> '' then
			parte := strValor;
		end if;

		if no_vacios > 0 then
			-- Validar datos de catalogos ...
		
			totReg := 0;
			select count(c1) into totReg from keplersc.kdini where c1 = parte;
			if totReg = 0 then
				select count(c1) into totReg from keplersc.kdinr where c1 = parte; --VCSS Validacion reemplazo 30 Marzo 2026
				if totReg = 0 then
					mensaje := 'No se encontro el Registro de la refacción ' || parte || ' como original o reemplazo. ';
					raise exception '%', mensaje;
				end if;
			end if;	


	
			/*
			 *  ESTA SECCION RESUELVE VERIFY_BACKORDER_ALTA 
			*/			
		
			cantReg := 0;
			existencias := 0;
			select (c3 - c4) into cantReg from keplersc.kdbol 
			where c1 = suc and c2 = parte;
			existencias/*cantReg*/ := coalesce(cantReg, -1);
			if existencias/*cantReg*/ < 0 or cantReg is null then
				if nat = 'A' then
					if cantReg is null then 
						mensaje := 'No existe registro en el backorder, item [' || parte || ']';
					else
						mensaje := 'No puede manejar existencias negativas, item [' || parte || ']';
					end if;
					raise exception '%', mensaje;
				end if;
			else
				existencias := cantReg;
			end if;
		
			cant_d := cant::decimal;
		
			if gen = 'X' then
			
				if existencias <= 0 then
					mensaje := 'La refaccion no ha sido solicitada, item [' || parte || ']';
					raise exception '%', mensaje;
				end if;
			
				if existencias < cant_d then
					mensaje := 'Unicamente se espera la compra de ' || existencias::text || 'VS. ' || cant || ' para el item [' || parte || ']';
					raise exception '%', mensaje;
				end if;
			
			else
			
				if gen = 'N' and nat = 'A' then
				
					if existencias < cant_d then
						mensaje := 'No hay cantidad disponible suficiente para la salida, item [' || parte || ']';
						raise exception '%', mensaje;
					end if;
				
				end if;
				
			
			end if;
		
			/*
			 *  [END] SECCION VERIFY_BACKORDER_ALTA 
			*/	
		
			numero_partida := numero_partida + 1;
		
		end if;
	
	end loop;	

	if numero_partida = 0 then
		mensaje := 'Despues de validar la INFO, No se encontraron partidas a Procesar ...';
		raise exception '%', mensaje; 
	end if; 
	
	numero_partida := 0;

	for intCont in 0..no_partidas - 1 loop 
		
		--raise notice '% %', intCont, no_partidas;

		parte := coalesce((xpath('//document/k_mov/r'||intCont||'/k_parte/text()',dataxml))[1],'');
		descr := coalesce((xpath('//document/k_mov/r'||intCont||'/k_descr/text()',dataxml))[1],'');
		cant := coalesce((xpath('//document/k_mov/r'||intCont||'/k_q/text()',dataxml))[1],'');
		um := coalesce((xpath('//document/k_mov/r'||intCont||'/k_unidad/text()',dataxml))[1],'');
		pu := coalesce((xpath('//document/k_mov/r'||intCont||'/k_precio/text()',dataxml))[1],'');
		monto := coalesce((xpath('//document/k_mov/r'||intCont||'/k_monto/text()',dataxml))[1],'');
	
		cant_d := cant::decimal;
		pu_d := pu::decimal;
		monto_d := monto::decimal;

		--VCSS manejo de reemplazo, manejar refaccion original en back order. 30 Marzo 2026
		SELECT coalesce(clave_original,'') into strValor FROM keplersc.prod_consulta_lista(suc, parte, 'CLAVE') LIMIT 1;
		if strValor <> '' then
			parte := strValor;
		end if;

		-- Cantidad debe ser > 0  
		if cant_d <= 0 then 
			mensaje := 'Cantidad debe ser > 0 , [' || parte || ']';
			raise exception '%', mensaje; 		
		else
		
			numero_partida := numero_partida + 1; 		
			
			-- INS {kdbom} 
		   	insert into keplersc.kdbom ( c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12 )
			values (
				suc, gen, nat, gpo::integer, tipo::integer, folio
				, numero_partida, parte, cant_d
				, to_date(fecha,'YYYY-MM-DD'), hora, 1
			);
			

			--raise notice '%','Paso TRN kdbom ';
		
			/*
			 *  ESTA SECCION RESUELVE ALTA_BACKODER_K (ESTADISTICAS)
			 *  Se aprovecha el codigo por todas las validaciones que hace ...
			*/
		
			-- INS / UP {kdbok}
			totReg := 0;
			select count(c1) into totReg from keplersc.kdbok 
			where c1 = suc and c2 = parte and c3 = anio_tx and c4 = mes_tx;
			if totReg = 0 then
				if nat <> 'A' then 
					insert into keplersc.kdbok ( c1, c2, c3, c4, c5, c6 )
					values ( suc, parte, anio_tx, mes_tx, cant_d, 0 );				
				else
					insert into keplersc.kdbok ( c1, c2, c3, c4, c5, c6 )
					values ( suc, parte, anio_tx, mes_tx, 0, cant_d );
				end if;
			else
				if nat <> 'A' then
					update keplersc.kdbok  
					set 
						c5 = coalesce(c5,0) + cant_d 
					where c1 = suc and c2 = parte and c3 = anio_tx and c4 = mes_tx;
				else
					update keplersc.kdbok  
					set 
						c6 = coalesce(c6,0) + cant_d 
					where c1 = suc and c2 = parte and c3 = anio_tx and c4 = mes_tx;
				end if;
			end if;	

		
			--raise notice '%','Paso TRN kdbok ';
	
			-- INS / UP {kdbol}
			totReg := 0;
			select count(c1) into totReg from keplersc.kdbol 
			where c1 = suc and c2 = parte;
			if totReg = 0 then
				if nat <> 'A' then
					insert into keplersc.kdbol ( c1, c2, c3, c4 )
					values ( suc, parte, cant_d, 0 );
				else
					/*
					insert into keplersc.kdbol ( c1, c2, c3, c4 )
					values ( suc, parte, 0, cant_d );
					*/
					-- No debe permitir Salidas sino existen registros previos de Entrada
					mensaje := 'No existen registros del item [' || parte || '] , No se puede registrar la salida.';
					raise exception '%', mensaje; 	 
				end if;
			else
				if nat <> 'A' then
					update keplersc.kdbol  
					set 
						c3 = coalesce(c3,0) + cant_d 
					where c1 = suc and c2 = parte;
				else
					cantReg := -1;
					select (c3 - c4) into cantReg from keplersc.kdbol 
					where c1 = suc and c2 = parte;
					cantReg := coalesce(cantReg, -1);
					if cantReg < 0 or cant_d > cantReg then
						mensaje := 'No puede manejar existencias negativas, item [' || parte || ']';
						raise exception '%', mensaje; 	
					else
						update keplersc.kdbol  
						set 
							c4 = coalesce(c4,0) + cant_d 
						where c1 = suc and c2 = parte;
					end if;
				end if;
			end if;	
		
			--raise notice '%','Paso TRN kdbol ';
		
		end if;
		
	end loop;

	--raise notice '%','Paso For Loop Transacciones ';

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	


exception
	when others then
		resultado := 0;
		mensaje := 'alta_backoder() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
