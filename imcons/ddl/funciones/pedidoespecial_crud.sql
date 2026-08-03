CREATE OR REPLACE FUNCTION keplersc.pedidoespecial_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	no_partidas int = 0;
	no_vacios int = 0;
	numero_partida int;
	valor_get text = '';
	folio int;
	--modelo_get text = '';

	operacion text = '';
	--fecha_operacion text = '';

	sucursal text = '';
	k_folio text = '';

	k_fecha text = '';

	k_vin text = '';
	k_tipo text = '';
	k_orden text = '';

	k_refer text = '';

	c_gen text = '';
	c_nat text = '';
	c_gpo text = '';
	c_tip text = '';

	k_client text = '';

	c_surtir int;
	c_entregar int;

	c_fecha text = '';

	vin_client text = '';
	ref_client text = '';

	ord_vin text = '';

	parte text = '';
    descr text = '';
    cant text = '';
    um text = '';
    eta text = '';
   	reemplazo text = '';
	original text = '';

	cant_d decimal = 0.00;

	client_enc text = '';
	item_part text = '';

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
	
	--Resuelve opciones NEW & DELETE TBL KDSERPED (Pedido Especial) 

 	--  * * *  Validando Datos Mandatorios ...

	no_vacios := 0;

	operacion := coalesce((xpath('//document/operacion/text()', dataxml))[1],'');

	sucursal := coalesce((xpath('//document/k_sucn/r1/text()', dataxml))[1],'');
	k_fecha := coalesce((xpath('//document/k_fecha/text()',dataxml))[1],'');

	if upper(operacion) <> 'ALTA' and upper(operacion) <> 'BAJA' then 
		mensaje := 'Operacion No Valida ...';
		raise exception '%', mensaje;
	else
		if upper(operacion) = 'ALTA' then 
			folio := -1;
			select coalesce(max(c2::int),0) into folio from keplersc.kdserped k where c1 = sucursal;
			if folio < 0 then
				mensaje := 'No se pudo determinar el siguiente Folio de el Pedido Especial ...';
				raise exception '%', mensaje;
			end if;	
			folio := folio + 1;
			k_folio := lpad(folio::text,10,'0');
		end if;
		if upper(operacion) = 'BAJA' then
			k_folio := coalesce((xpath('//document/k_folio/text()',dataxml))[1],'');
		end if;
	end if;

	
	k_vin := coalesce((xpath('//document/k_serie/text()',dataxml))[1],'');

	k_tipo := coalesce((xpath('//document/k_tipon/text()', dataxml))[1],'');
	k_orden := coalesce((xpath('//document/k_orden/text()',dataxml))[1],'');

	k_refer := coalesce((xpath('//document/k_refer/text()',dataxml))[1],'');

	c_gen := coalesce((xpath('//document/anticipo/gen_doc/text()',dataxml))[1],'');
	c_nat := coalesce((xpath('//document/anticipo/nat_doc/text()',dataxml))[1],'');
	c_gpo := coalesce((xpath('//document/anticipo/gpo_doc/text()',dataxml))[1],'');
	c_tip := coalesce((xpath('//document/anticipo/tip_doc/text()',dataxml))[1],'');

	k_client := coalesce((xpath('//document/c_clien/text()',dataxml))[1],'');
	
	
	if length(sucursal) = 0 then no_vacios := no_vacios + 1; end if;
	if length(k_folio) = 0 then no_vacios := no_vacios + 1; end if;
	if length(k_fecha) = 0 then no_vacios := no_vacios + 1; end if;
	if length(k_vin) = 0 then no_vacios := no_vacios + 1; end if;
	if length(k_client) = 0 then no_vacios := no_vacios + 1; end if;

	-- Validacion de los otros campos de referencia en base a condiciones 

	if length(K_tipo) = 0 and length(k_orden) > 0 then no_vacios := no_vacios + 1; end if;
	if length(K_tipo) > 0 and length(k_orden) = 0 then no_vacios := no_vacios + 1; end if;

	if length(k_refer) > 0 and (length(c_gen) = 0 or length(c_nat) = 0 or length(c_gpo) = 0 or length(c_tip) = 0) then no_vacios := no_vacios + 1; end if;
	
	if length(k_orden) = 0 and length(k_refer) = 0 then no_vacios := no_vacios + 1; end if;


	if no_vacios > 0 then 
		if upper(operacion) = 'ALTA' then
			mensaje := 'Se tienen datos mandatorios incompletos ... revisa la sucursal, fecha, vin, [tipo, orden] y/o [Anticipo]';
		else
			mensaje := 'Se tienen datos mandatorios incompletos ... revisa la sucursal, [folio], fecha, vin, [tipo, orden] y/o [Anticipo]';
		end if;
		raise exception '%', mensaje;	
	end if;


	--  * * *  Validar Datos - Encabezado ...

	totReg := 0;
	select count(c1) into totReg from keplersc.kdms where c1 = sucursal;
	if totReg = 0 then
		mensaje := 'No se encontro el Registro en la Tabla kdms [Sucursales], sucursal [' || sucursal || ']';
		raise exception '%', mensaje;
	end if;	

	totReg := 0;
	select count(c1) into totReg from keplersc.kdserie where c4 = k_vin;
	if totReg = 0 then
		mensaje := 'No se encontro el Registro en la Tabla kdserie, VIN [' || k_vin || ']';
		raise exception '%', mensaje;
	else
		-- GET DATA TO COMPARE
		valor_get := '';
		select c9 into valor_get from keplersc.kdserie where c1 = k_vin;
		vin_client := coalesce(valor_get,'');
	end if;	

	if length(k_tipo) > 0 then 
		totReg := 0;
		select count(c1) into totReg from keplersc.kdmargen where c1 = k_tipo;
		if totReg = 0 then
			mensaje := 'No se encontro el Registro en la Tabla kdmargen, tipo [' || k_tipo || ']';
			raise exception '%', mensaje;
		end if;	
	
		totReg := 0;
		select count(c1) into totReg from keplersc.kdord where c1 = sucursal and c2 = k_tipo and c3 = k_orden;
		if totReg = 0 then
			mensaje := 'No se encontro el Registro en la Tabla kdord, tipo : orden [' || k_tipo || '] : ' || k_orden;
			raise exception '%', mensaje;
		else
			-- GET DATA TO COMPARE
			valor_get := '';
			select h.c4 into valor_get from keplersc.kdord u
			inner join keplersc.kdserie h on h.c1 = u.c6
			where u.c1 = sucursal and u.c2 = k_tipo and u.c3 = k_orden; 
			ord_vin := coalesce(valor_get,'');
		end if;	
	end if;

	if length(k_refer) > 0 then
		totReg := 0;
		select count(m.c1) into totReg from keplersc.kdm1 m 
			where c1 = sucursal and m.c2 = c_gen and m.c3 = c_nat and m.c4 = c_gpo::int and m.c5 = c_tip::int   
			and m.c6 = k_refer;
		if totReg = 0 then
			mensaje := 'No se encontro el Registro en la Tabla kdm1, Anticipo [' || k_refer || ']';
			raise exception '%', mensaje;
		else
			-- GET DATA TO COMPARE
			valor_get := '';
			select c10 into valor_get from keplersc.kdm1 m 
				where c1 = sucursal and m.c2 = c_gen and m.c3 = c_nat and m.c4 = c_gpo::int and m.c5 = c_tip::int   
				and m.c6 = k_refer;
			ref_client := coalesce(valor_get,'');
		end if;
	end if;

	if upper(operacion) = 'BAJA' then
	
		totReg := 0;
		select count(c1) into totReg from keplersc.kdserped c where c1 = sucursal and c2 = k_folio; 
		if totReg = 0 then
			mensaje := 'No se encontro el Registro en la Tabla kdserped, Pedido Especial [ ' || K_folio || ' ] ';
			raise exception '%', mensaje;
		end if;
		
		totReg := 1000;
		select count(c1) into totReg from keplersc.kdserpedmov c where c1 = sucursal and c2 = k_folio
			and (c8 <> 0 or c10 <> 0); 
		if totReg > 0 then
			mensaje := 'El Pedido no se puede Eliminar, tiene piezas que ya estan surtidas o entregadas ...';
			raise exception '%', mensaje;
		end if;
	
	end if;
	
	-- Validacion de Datos Comunes entre Tablas ... 

	if upper(operacion) = 'ALTA' then

		if k_vin <> ord_vin then
			mensaje := 'Existe Discrepancia entre el VIN de kdserie [Series] y el VIN de kdord [Ordenes] ...';
			raise exception '%', mensaje;
		end if;
	
		if length(k_refer) > 0 then
			if ref_client <> vin_client then
				mensaje := 'Existe Discrepancia entre el Cliente [Contacto] kdserie y el Cliente de kdm1 [Anticipo] ...';
				raise exception '%', mensaje;
			end if; 
		end if;

	end if;

	-- Seleccion del Cliente basado en las distintas referencias ...
	if length(k_refer) > 0 then
		client_enc := ref_client;
	else
		client_enc := k_client;
	end if;
	

	--  * * *  Validar Datos - Partidas ...

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
		eta := coalesce((xpath('//document/k_mov/r'||intCont||'/k_eta/text()',dataxml))[1],'');
	
		reemplazo := coalesce((xpath('//document/k_mov/r'||intCont||'/c_reemplazo/text()',dataxml))[1],'');
		original := coalesce((xpath('//document/k_mov/r'||intCont||'/c_original/text()',dataxml))[1],'');
	
		if length(parte) > 0 then no_vacios := no_vacios + 1; end if;
		if length(descr) > 0 then no_vacios := no_vacios + 1; end if;
		if length(cant) > 0 then no_vacios := no_vacios + 1; end if;
		if length(um) > 0 then no_vacios := no_vacios + 1; end if;
		if length(eta) > 0 then no_vacios := no_vacios + 1; end if;
	
		if no_vacios < 5 /*6*/ and no_vacios > 0 then 
			mensaje := 'Partidas con datos incompletos ...';
			raise exception '%', mensaje;	
		end if;
	
		if no_vacios > 0 then
		
			-- Validar datos de catalogos & valores ...
		
			item_part := '';
			if length(reemplazo) > 0 and upper(operacion) = 'ALTA' then
				item_part := original;
				mensaje := 'No se encontro el Registro en la Tabla kdinr [Reemplazo] [' || parte || ']';
			else
				item_part := parte;
				mensaje := 'No se encontro el Registro en la Tabla Kdini [Producto] [' || parte || ']';
			end if;
		
			totReg := 0;
			select count(c1) into totReg from keplersc.kdini where c1 = item_part/*parte*/;
			if totReg = 0 then
				raise exception '%', mensaje;
			else
				mensaje := '';
			end if;	
			
			if eta::date < current_date and upper(operacion) = 'ALTA' then
				mensaje := 'La ETA No puede ser menor al dia de Hoy [Producto] [' || parte || '] , ETA [' || eta || ']';
				raise exception '%', mensaje;
			end if;
		
			numero_partida := numero_partida + 1;
		
		end if;
	
	end loop;	

	if numero_partida = 0 then
		mensaje := 'Despues de validar la INFO, No se encontraron partidas a Procesar ...';
		raise exception '%', mensaje; 
	end if; 
	

	--  * * *  Procesando Registros ...
	if length(trim(c_fecha)) = 0 then
		c_fecha = '1900-01-01';
	end if;


	-- OPERACION ALTA ... 
	if upper(operacion) = 'ALTA' then
	
		-- Encabezado
	
		insert into keplersc.kdserped (
		c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14
		)
		values (
		sucursal, k_folio, to_date(k_fecha,'YYYY-MM-DD'), k_vin, client_enc, 
		case when length(k_refer) > 0 then c_gen else '' end, 
		case when length(k_refer) > 0 then c_nat else '' end, 
		case when length(k_refer) > 0 then c_gpo::int else 0 end, 
		case when length(k_refer) > 0 then c_tip::int else 0 end, 
		k_refer, k_tipo, k_orden, 0, 0 
		);
		
		-- Partidas 
		
		numero_partida := 0;

		for intCont in 0..no_partidas - 1 loop 
			
			--raise notice '% %', intCont, no_partidas;
	
			parte := coalesce((xpath('//document/k_mov/r'||intCont||'/k_parte/text()',dataxml))[1],'');
			descr := coalesce((xpath('//document/k_mov/r'||intCont||'/k_descr/text()',dataxml))[1],'');
			cant := coalesce((xpath('//document/k_mov/r'||intCont||'/k_q/text()',dataxml))[1],'');
			um := coalesce((xpath('//document/k_mov/r'||intCont||'/k_unidad/text()',dataxml))[1],'');
			eta := coalesce((xpath('//document/k_mov/r'||intCont||'/k_eta/text()',dataxml))[1],'');
		
			reemplazo := coalesce((xpath('//document/k_mov/r'||intCont||'/c_reemplazo/text()',dataxml))[1],'');
			original := coalesce((xpath('//document/k_mov/r'||intCont||'/c_original/text()',dataxml))[1],'');
		
			cant_d := cant::decimal;
		
			item_part := '';
			if length(reemplazo) > 0 then
				item_part := original;
			else
				item_part := parte;
			end if;
			 
			-- Cantidad debe ser > 0  
			if cant_d <= 0 then 
				mensaje := 'Cantidad debe ser > 0 , [' || parte || ']';
				raise exception '%', mensaje; 		
			else
			
				numero_partida := numero_partida + 1; 		
				
				-- INS {kdserpedmov} 
			   	insert into keplersc.kdserpedmov ( c1, c2, c3, c4, c5, c6, c7, c8, c10 )
				values (
					sucursal, k_folio, numero_partida, item_part/*parte*/, cant_d, um
					, to_date(eta,'YYYY-MM-DD'), 0, 0 
					/*, to_date(fecha,'YYYY-MM-DD'), hora, 1*/
				);		
			
			end if;
			
		end loop;
	
	else
	
		delete from keplersc.kdserped where c1 = sucursal and c2 = k_folio;
	
		delete from keplersc.kdserpedmov where c1 = sucursal and c2 = k_folio;
	
		totReg := 1;
		select count(c1) into totReg from keplersc.kdserped c where c1 = sucursal and c2 = k_folio; 
		if totReg > 0 then
			mensaje := 'No se pudo Eliminar el Encabezado del Pedido Especial [ ' || K_folio || ' ] ';
			raise exception '%', mensaje;
		end if;
	
		totReg := 1;
		select count(c1) into totReg from keplersc.kdserpedmov c where c1 = sucursal and c2 = k_folio; 
		if totReg > 0 then
			mensaje := 'No se pudo Eliminar el Detalle del Pedido Especial [ ' || K_folio || ' ] ';
			raise exception '%', mensaje;
		end if;
		
		/*
		mensaje := 'Opcion [Pedido Especial].[BAJA] en Desarrollo ...';
		raise exception '%', mensaje;
		*/
	
	end if;


	/*
	mensaje := 'Opcion [Pedido Especial] en pruebas operativas ...';
	--cmnt(1).free4eg by JMM
	raise exception '%', mensaje;
	*/


	--mensaje := 'Opcion en Construccion ...';
	resultado := '1';
	if upper(operacion) = 'ALTA' then
		adicionales/*mensaje*/ := 'Se Registro el Pedido Especial [ ' || k_folio || ' ]  ...';
		mensaje/*adicionales*/ := k_folio;
	else
		if upper(operacion) = 'BAJA' then
			adicionales/*mensaje*/ := 'Se Elimino el Pedido Especial  [ ' || k_folio || ' ]  satisfactoriamente ...';
			mensaje/*adicionales*/ := k_folio;
		else
			mensaje := 'Operacion No valida ...';
			raise exception '%', mensaje;
		end if;
	end if;
	
	return query select resultado, mensaje, adicionales;	


exception
	when others then
		resultado := '0';
		mensaje := 'pedidoespecial_crud(); ' || '['|| sqlstate || '] ' || sqlerrm ;
		return query select resultado, mensaje, adicionales;	

end;
$function$
