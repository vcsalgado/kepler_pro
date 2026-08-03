CREATE OR REPLACE FUNCTION keplersc.baja_backorder(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Esta funcion resuelve BAJA_BACKORDER UEN REF  
	--Parametros de entrada en xml:
	-- dataXml--> Datos del movimiento;  
	--Parametros de salida tabla: campos resultado, mensaje y adicionales.
	--Author: Jose Mendoza 
	--Fecha: 3/11/2023
	--Bitacora de cambios:
	-- Fecha: 5/11/2023 , se termino el desarrollo de la version 1.0 (Baja BackOrder)
	
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
   	st text;
   
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

	doc_fol text; 
	doc_st text; 
	doc_ref text; 
	doc_regs int; 
	ped_st int; 
	cm_regs int;

	v_ent decimal;
	v_sal decimal;
   
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
	folio := (xpath('//document/k_folio/text()', dataxml))[1];

	refer := (xpath('//document/k_refer/text()', dataxml))[1];

	-- Added 20231106, to solved updated of kmd1.c43 done in functions run before ... 
	st := coalesce((xpath('//document/c_st/text()', dataxml))[1],'');

    --folio := p_folio_operacion; 
    
   	-- k_fecha
    fecha := coalesce((xpath('//document/movimiento/fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
   
   	-- k_hora
   	hora := coalesce((xpath('//document/movimiento/hora/text()', dataxml))[1]::text,'00:00:00')::text;
   
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


	-- Validaciones para Verificar si la Operacion es Valida para el DOC ... 

	mensaje := '';

	totReg := 0;
	select count(c6) into totReg from keplersc.kdbom 
	where c1 = suc and c2 = gen and c3 = nat and c4 = gpo::int and c5 = tipo::int and c6 = folio;
	if totReg = 0 then
		mensaje := 'No se encontraron el Registros en la Tabla Kdbom [Folio], [' || folio || ']';
		raise exception '%', mensaje;
	else
		if totReg <> no_partidas then
			mensaje := 'Existen Discrepancias entre el Numero Registros de las Tablas Kdbom [BackOrder] VS Kdm2...';
			raise exception '%', mensaje;
		end if;
	end if;	


	totReg := 0;
	select count(c6) into totreg from keplersc.kdm1 
	where c1 = suc and c2 = gen and c3 = nat and c4 = gpo::int and c5 = tipo::int and c6 = folio;
	if totReg = 0 then
		mensaje := 'El Pedido No existe ... [Folio], [' || folio || ']';
		raise exception '%', mensaje;
	end if;


	select 
		coalesce(k.c6,'') doc_fol, k.c43 doc_st, k.c11 doc_ref, coalesce(k2.k2_regs,0) doc_regs, coalesce(p.c4,-1) ped_st, coalesce(cm.cm_regs,0) cm_regs 
		into doc_fol, doc_st, doc_ref, doc_regs, ped_st, cm_regs 
	from keplersc.kdm1 k 
	left join keplersc.kdpedref p on p.c1 = k.c1 and p.c2 = k.c11 
	left join (select c1, c2, c3, c4, c5, c6, count(*) as k2_regs from keplersc.kdm2 
		where c1 = suc and c2 = gen and c3 = nat and c4 = gpo::int and c5 = tipo::int  
		group by c1, c2, c3, c4, c5, c6) k2 
		on k2.c1 = k.c1 and k2.c2 = k.c2 and k2.c3 = k.c3 and k2.c4 = k.c4 and k2.c5 = k.c5 and k2.c6 = k.c6 
	left join (select c1, c2, c3, c4, c5, c6, count(*) as cm_regs from keplersc.kdpedrefcom  
		where c1 = suc and c2 = gen and c3 = nat and c4 = gpo::int and c5 = tipo::int   
		group by c1, c2, c3, c4, c5, c6) cm  
		on cm.c1 = k.c1 and cm.c2 = k.c2 and cm.c3 = k.c3 and cm.c4 = k.c4 and cm.c5 = k.c5 and cm.c6 = k.c6  
	where k.c1 = suc and k.c2 = gen and k.c3 = nat and k.c4 = gpo::int and k.c5 = tipo::int and k.c6 = folio; 

	--raise notice '%''%''%''%''%''%''%',('st_k80:' || st),('doc_fol:' || doc_fol),('doc_st:' || doc_st),('doc_ref:' || doc_ref),('doc_regs:' || doc_regs),('ped_st:' || ped_st),('cm_regs:' || cm_regs);
	
	if length(doc_fol) = 0 then
		mensaje := 'El Pedido No existe, o No se pudo verificar la Informacion ... [Folio], [' || folio || ']';
		raise exception '%', mensaje;
	end if;

	if ped_st < 0 then
		mensaje := 'Referencia del Pedido Sugerido No Existe ...';
		raise exception '%', mensaje;
	end if;
	if ped_st = 0 then
		mensaje := 'El Pedido Sugerido ya ha sido eliminado previamente ...';
		raise exception '%', mensaje;
	end if;
	if ped_st = 10 then
		mensaje := 'El Pedido Sugerido esta como Editable, No se puede realizar esta opcion ...';
		raise exception '%', mensaje;
	end if;
	if ped_st <> 20 then
		mensaje := 'El Estatus del Pedido No es Valido, No se puede realizar esta opcion ...';
		raise exception '%', mensaje;
	end if;	

	if doc_regs = 0 then
		mensaje := 'El Pedido No tiene Partidas o ha sido Cancelado ...';
		raise exception '%', mensaje;
	end if;

	-- En lugar de obtenerlo por Query se tuvo que mandar en el XML ya que al correr la funcion 
	-- que hace las actualizaciones en la kdm1, este dato se pone en "C" 
	if upper(/*doc_st*/st) = 'C' then
		mensaje := 'El Pedido esta con Estatus Cancelado ...';
		raise exception '%', mensaje;
	end if;
	

	if cm_regs > 0 then
		mensaje := 'El Pedido ya tiene Compras Asociadas ...';
		raise exception '%', mensaje;
	end if;

	--raise notice '%','Paso Validaciones de Verificacion ...';

	-- End ... Validaciones de Verificacion de la Info 


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
	
		if no_vacios > 0 then
			-- Validar datos de catalogos ...
		
			totReg := 0;
			select count(c1) into totReg from keplersc.kdini where c1 = parte;
			if totReg = 0 then
				mensaje := 'No se encontro el Registro en la Tabla Kdini [Productos], [' || parte || ']';
				raise exception '%', mensaje;
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
			cant_d := cant_d * -1;  -- Es el efecto de la baja 20231103 
			
			-- Implementado por JM basado en la logica de la operacion y la afectacion que hara en la kdbol 
			-- segun la naturaleza, restara ENTR {A} o SAL {NOT A} 
			if gen = 'N' then
				if nat = 'A' then
					-- Restaria/Afectaria Salidas, osea aumentara las existencias
					if existencias - cant_d < 0 then
						mensaje := 'No puede manejar existencias negativas ... al disminuir Salidas, item [' || parte || ']';
						raise exception '%', mensaje;
					end if;
				else
					-- Restaria/Afectaria Entradas osea disminuira las existencias
					if existencias + cant_d < 0 then
						mensaje := 'No puede manejar existencias negativas ... al disminuir Entradas, item [' || parte || ']';
						raise exception '%', mensaje;
					end if;
				end if;
			end if;
		
			-- En este proceso no hace este tipo de validaciones, JM solo implemento algunas partes
			-- para validar no caer en existencias negativas ... solo se valida para kdbol (existencias globales)
			/*
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
			*/
		
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
	
		-- Cantidad debe ser > 0  
		if cant_d <= 0 then 
			mensaje := 'Cantidad debe ser > 0 , [' || parte || ']';
			raise exception '%', mensaje; 		
		else
		
			cant_d := cant_d * -1;  -- Es el efecto de la baja 20231103 
		
			numero_partida := numero_partida + 1; 		
		
			--raise notice '%','Entro al INSERT de la kdbom ...';
			
			-- INS {kdbom} 
		   	insert into keplersc.kdbom ( c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12 )
			values (
				suc, gen, nat, gpo::integer, tipo::integer, folio
				, numero_partida, parte, cant_d
				, to_date(fecha,'YYYY-MM-DD'), hora, 0 /*1*/
			);
			
			--raise notice '%','Salio del INSERT de la kdbom ...';
		
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
				-- Debe Existir el Registro, No se puede dar de Baja algo que No ha sido dado de Alta Primero 
				/*
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
				*/
				mensaje := 'No existen registros del item [' || parte || '] en la Tabla Kdbol, No se puede realizar la Baja.';
				raise exception '%', mensaje; 
				---- ME QUEDE AQUI .... 20231103 23:21 
			else
			
				v_ent := 0;
				v_sal := 0;
				existencias := 0;
			
				select c3, c4 into v_ent, v_sal from keplersc.kdbol 
				where c1 = suc and c2 = parte;
				v_ent := coalesce(v_ent, 0);
				v_sal := coalesce(v_sal, 0);
				if nat <> 'A' then
					v_sal := v_sal + cant_d; 
				else
					v_ent := v_ent + cant_d;
				end if;
				existencias := v_ent - v_sal;
				if existencias < 0 then
					mensaje := 'No puede manejar existencias negativas, item [' || parte || ']';
					raise exception '%', mensaje; 
				end if;
				
				if nat <> 'A' then
					update keplersc.kdbol  
					set c3 = coalesce(c3,0) + cant_d 
					where c1 = suc and c2 = parte;
				else
					update keplersc.kdbol  
					set c4 = coalesce(c4,0) + cant_d 
					where c1 = suc and c2 = parte;
				end if;
			end if;	
		
			--raise notice '%','Paso TRN kdbol ';
		
		end if;
		
	end loop;

	--raise notice '%','Paso For Loop Transacciones ';

	--raise exception '%','Se procesarian los cambios ... [Baja Bacorder]'; /*for testing*/

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	


exception
	when others then
		resultado := 0;
		mensaje := 'baja_backoder() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
