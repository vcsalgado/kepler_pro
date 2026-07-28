CREATE OR REPLACE FUNCTION keplersc.invr_alta_vencom(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	no_partidas int = 0;
	cantidad_unidades text = '';
	clave_producto text = '';
	unidad text = '';
	sucursal_id text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo_clave text = '';
--	fecha_movto text = '';
	fecha_operacion text = '';
	tipo_movto text = '';
	hora_movto text = '';
	clave_cteprov text = '';
	clave_vendedor text = '';
	--subtotal text = '0';
	monto_iva text = '0';
	monto_total text = '0';

	--Variables de uso general 
	var_value decimal = 0.00;
	periodo_obsoleto decimal = 0.00; -- var en K75 : B10014
   sumcosto_partidas decimal = 0.00;
	decmonto_partida decimal = 0.00; -- var en K75 :  B10011
	deccantidad_partida decimal = 0.00;
   monto_partida text = '';
   cantida_partida text = '';
  	penultima_venta date;
  	ultima_compra date;
  	penultima_venta_calc int = 0;
   ultima_compra_calc int = 0;	   
  
	strValor text = '';
	intValor int = 0;
	intCont int = 0;
	decValor decimal = 0.00;
	cantidadTotal int = 0;
	promCantidadPartida decimal = 0;
	xmlCadena xml;
	numero_partida int = 0;
	importeFinalPartida decimal = 0.00;
	entradaSalida text = '';
	reqcostoxml xml = '';
	totReg int = 0;
	var_A19 decimal = 0; 
	var_A140 text = '';
	var_comisionable text = '';
	comisionable text = '';

	porc_iva text = '';
	iva_partida_calc decimal = 0.00;
	importe_partida text = '';
	importe_partida_calc decimal = 0.00;


	kdinm_suc text = '';
	kdinm_prod text = '';
	kdinm_monto decimal = 0.00;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	--Resuelve INVRLIB.ALTA_VENCOM 

	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	--tipo_movto := (xpath('//document/tipo_movto/text()', dataxml))[1];
	--Movimiento

	--	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
	 --	fecha_movto := (xpath('//document/movimiento/fecha/text()',dataxml))[1];
	hora_movto := (xpath('//document/movimiento/hora/text()',dataxml))[1];

	porc_iva := coalesce((xpath('//document/k_tipon/r6/text()', dataxml))[1]::text,'0');

	--Totales
	--subtotal := coalesce((xpath('//document/subt/text()',dataxml))[1]::text,'0')::text;
	monto_iva := coalesce((xpath('//document/k_iva/text()',dataxml))[1]::text,'0')::text;
	monto_total := coalesce((xpath('//document/k_monto/text()',dataxml))[1]::text,'0')::text;

	clave_cteprov := coalesce((xpath('//document/k_clave/text()', dataxml))[1]::text,'0')::text;

	clave_vendedor := coalesce((xpath('//document/k_vendedor/text()', dataxml))[1]::text,'')::text;

	-- Se inicializo var_A19 = [clave_vendedor] debido a las asignaciones con algunas tablas asociadas a esta variable en esta funcion;
	if length(clave_vendedor) > 0 then  
		var_A19 := clave_vendedor::decimal; -- 0; -- Num Var basado en K75
	else
		var_A19 := 0;
	end if;
	var_A140 := ''; -- Num Var basado en K75


	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;

	-- Calcula el valor de la variable para comparación del periodo obsoleto (sin operaciones)
	select c3 into var_value from keplersc.kdconfgenref;
	periodo_obsoleto := coalesce(var_value,0) * 30;  

	sumcosto_partidas := 0;

	numero_partida := 0;

	for intCont in 0..no_partidas - 1 loop

		deccantidad_partida := 0;
		cantidad_unidades := (xpath('//document/k_mov/r'||intCont||'/k_q/text()',dataxml))[1];
		deccantidad_partida := cantidad_unidades::decimal;
	
		if deccantidad_partida > 0 then
			
			numero_partida := numero_partida + 1;
			
			clave_producto := (xpath('//document/k_mov/r' ||intCont||'/k_parte/text()',dataxml))[1];
			importe_partida := (xpath('//document/k_mov/r' ||intCont||'/k_monto/text()',dataxml))[1];
			unidad := (xpath('//document/k_mov/r' ||intCont||'/k_unidad/text()',dataxml))[1];
		
		
			importe_partida_calc := 0;
			importe_partida_calc := importe_partida::decimal * (1+(porc_iva::decimal/100)) * (1-(var_A19/100)); --K75 usa var A19 pero no tiene valor en la corrida OODA
			
			iva_partida_calc := 0;
			iva_partida_calc := importe_partida::decimal * (porc_iva::decimal/100) * (1-(var_A19/100)); --K75 usa var A19 pero no tiene valor en la corrida OODA
			
			totReg := 0;
			select count(*) into totReg from keplersc.kdinm where c1 = sucursal_id and c5 = genero 
				and c6 = naturaleza and c7 = grupo::integer and c8 = tipo_clave::integer and c9 = folio_operacion and c10 = numero_partida;
			if totReg = 0 then
				raise exception '%', 'No se encontro el Registro en la Tabla KDINM.' || '['|| 'sub_invr_alta_vencom()' || '] ';	
			end if;
	
			select c1, c2, c12 into kdinm_suc, kdinm_prod, kdinm_monto from keplersc.kdinm 
			where c1 = sucursal_id and c5 = genero and c6 = naturaleza and c7 = grupo::integer  
				and c8 = tipo_clave::integer and c9 = folio_operacion and c10 = numero_partida;
	
			if kdinm_suc is null or kdinm_prod is null or kdinm_monto is null then
				raise exception '%', 'Valor(es) No Valido(s) en la Tabla KDINM.' || '['|| 'sub_invr_alta_vencom()' || '] ';
			end if; 
		
			sumcosto_partidas := sumcosto_partidas + kdinm_monto;
		   
			insert into keplersc.kdvcm(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16)
			values(sucursal_id, genero, naturaleza, grupo::integer, tipo_clave::integer, folio_operacion, numero_partida, to_date(fecha_operacion,'YYYY-MM-DD')  
				, deccantidad_partida, unidad, importe_partida_calc, iva_partida_calc, kdinm_monto, '', kdinm_prod, clave_producto); 	
	
			
			totReg := 0;
			select count(*) into totReg from keplersc.kdinl where c1 = kdinm_suc and c2 = kdinm_prod;
			if totReg = 0 then
				raise exception '%', 'No se encontro el Registro en la Tabla KDINL.' || '['|| 'sub_invr_alta_vencom()' || '] ';	
			end if;
	
			select c17, c12 into penultima_venta, ultima_compra from keplersc.kdinl 
			where c1 = kdinm_suc and c2 = kdinm_prod;
	
			ultima_compra_calc := current_date - ultima_compra; --- to_date('2021-05-03','YYYY-MM-DD')
			penultima_venta_calc := current_date - penultima_venta;
		
			if penultima_venta_calc > periodo_obsoleto and ultima_compra_calc > periodo_obsoleto then
				-- Insert to KDVOBS
				insert into keplersc.kdvobs(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17)
				values(sucursal_id, genero, naturaleza, grupo::integer, tipo_clave::integer, folio_operacion, numero_partida, to_date(fecha_operacion,'YYYY-MM-DD')  
				, penultima_venta, ultima_compra, clave_vendedor, kdinm_prod, deccantidad_partida, unidad, importe_partida_calc, iva_partida_calc, kdinm_monto); 	
	
			else 
				if ultima_compra_calc > periodo_obsoleto then
					-- Insert to KDVOBS 
					insert into keplersc.kdvobs(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17)
					values(sucursal_id, genero, naturaleza, grupo::integer, tipo_clave::integer, folio_operacion, numero_partida, to_date(fecha_operacion,'YYYY-MM-DD')  
					, penultima_venta, ultima_compra, clave_vendedor, kdinm_prod, deccantidad_partida, unidad, importe_partida_calc, iva_partida_calc, kdinm_monto); 	
				end if;
			end if;

		end if;  --if deccantidad_partida > 0
	
		--raise notice 'PASO 42';			
	
	end loop;

	
	if numero_partida > 0 then -- Si por lo menos procesó a una partida 

		-- Insert to KDVCK  
		insert into keplersc.kdvck(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13)
		values(sucursal_id, genero, naturaleza, grupo::integer, tipo_clave::integer, folio_operacion, to_date(fecha_operacion,'YYYY-MM-DD')
		, monto_total::decimal, monto_iva::decimal, sumcosto_partidas, '', clave_cteprov, clave_vendedor); 	

		-- Hacer las busquedas en I{kdvenref}, H{kdicatprecio}, M91{kdmm} 
		-- NO SE TIENE REFERENCIA AL MOMENTO PARA LA VARIABLE {A140} ;  {A12} esta asociada con la [clave_vendedor] 
	   -- Se presume que A140 es un codigo para acceder a la tabla de PARAMs KDICATPRECIO para ver si es Comisionable 
	   -- Por ello usa la condicion : H7 {kdicatprecio.comisionable} = "S" ;
		-- Igualmente el campo M91 {kdmm) = "S" esta asociado a si Paga comisiones refacciones ;
		-- NO APLICA PARA : OODA ... ; 
	   -- Se programará con los datos que se tienen al momento ; 
		/*
		--open(H,KDICATPRECIO,I,KDVENREF,J,KDINVRCOMIS,K,KDVCK) ...
		if genero = "U" and BUS(I,1,0,A12)>0 and BUS(H,1,0,A140)>0 and H7="S" and M91 = "S" then
	        INS(J,A1,A3...A6,A9,A16,A14,B10011,B10013,A12)
	   end if;
		*/
		if genero = 'U' and var_A19::text <> '' then
			var_comisionable = '';
			comisionable = '';
			select c91 into var_comisionable from keplersc.kdmm 
			where c1 = genero and c2 = naturaleza and c3 = grupo::integer and c4 = tipo_clave::integer;
			comisionable := coalesce(var_comisionable,'');
			if upper(comisionable) = 'S' then
				totReg := 0;
				select count(*) into totReg from keplersc.kdvenref where c4 = sucursal_id and c1 = var_A19::text;
				if totReg > 0 then
					select count(*) into totReg from keplersc.kdicatprecio where c1 = var_A140;
					if totReg > 0 then
						var_comisionable = '';
						comisionable = '';
						select c7 into var_comisionable from keplersc.kdicatprecio where c1 = var_A140;
						comisionable := coalesce(var_comisionable'');
						if upper(comisionable) = 'S' then
							insert into keplersc.kdinvrcomis(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11)
							values(sucursal_id, naturaleza, grupo::integer, tipo_clave::integer, folio_operacion, to_date(fecha_operacion,'YYYY-MM-DD')
							, monto_total::decimal, monto_iva::decimal, sumcosto_partidas, ultima_compra_calc, clave_vendedor); 	
						end if;
					end if;		
				end if;
			end if;
		end if;

	end if;
	
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	


exception
	when others then
		resultado := 0;
		mensaje := 'invr_alta_vencom() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	

end;
$function$
