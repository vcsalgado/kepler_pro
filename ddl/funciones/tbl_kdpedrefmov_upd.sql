CREATE OR REPLACE FUNCTION keplersc.tbl_kdpedrefmov_upd(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	no_partidas int = 0;
	no_vacios int = 0;
	valor_get text = '';

	numero_partida int = 0;

	sucursal text = '';
	referencia text = '';
	estatus text = '';

	-- Campos Grid ...

	parte text = '';
	parteoriginal text = '';

	-- Campos Grid.Text
	pedesp_tx text = '';
	sugstck_tx text = '';
	surtstck_tx text = '';
	cantped_tx text = '';
	factor_tx text = '';
	mip_tx text = '';
	inv_tx text = '';
	bckord_tx text = '';
	citas_tx text = '';
	h11_tx text = '';
	h12_tx text = '';

	-- Campos Grid.Numbers
	pedesp decimal = 0.00;
	sugstck decimal = 0.00;
	surtstck decimal = 0.00;
	cantped decimal = 0.00;
	factor decimal = 0.00;
	mip decimal = 0.00;
	inv decimal = 0.00;
	bckord decimal = 0.00;
	citas decimal = 0.00;
	h11 decimal = 0.00;
	h12 decimal = 0.00;
	
	list_items_err text = '';
	flag_items int = 0;
	flag_item int = 0;

	--Variables Validacion
	v_N1 decimal = 0.00;
	v_N2 decimal = 0.00;
	v_H11 decimal = 0.00;
	v_H12 decimal = 0.00;
	v_H13 decimal = 0.00;
	v_A5 decimal = 0.00;
	v_A6 decimal = 0.00;

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
	
	--Resuelve opciones UPD TBL KDPEDREFMOV (Pedido Sugerido Detalle) 

 	--  * * *  Validando datos mandatorios ...

	no_vacios := 0;
	
	sucursal := coalesce((xpath('//document/c_suc/text()',dataxml))[1],'');
	referencia := coalesce((xpath('//document/c_ref/text()',dataxml))[1],'');
	estatus := coalesce((xpath('//document/c_st/text()',dataxml))[1],'');

	if length(sucursal) = 0 then no_vacios := no_vacios + 1; end if;
	if length(referencia) = 0 then no_vacios := no_vacios + 1; end if;
	if length(estatus) = 0 then no_vacios := no_vacios + 1; end if;

	if no_vacios > 0 then 
		mensaje := 'Se tienen datos mandatorios incompletos ...';
		raise exception '%', mensaje;	
	end if;
	
	totReg := 0;
	select count(c1) into totReg from keplersc.kdms where c1 = sucursal;
	if totReg = 0 then
		mensaje := 'No se encontro el Registro en la Tabla Kdms [Sucursales], sucursal [' || sucursal || ']';
		raise exception '%', mensaje;
	end if;

	if estatus <> '10' then
		mensaje := 'Estatus de la Referencia <> 10 ...';
		raise exception '%', mensaje;
	end if;

	--Partidas
	strValor := coalesce((xpath('//document/k_mov/no_partidas/text()',dataxml))[1]::text,'0');
	no_partidas := strValor::integer;

	if no_partidas <= 0 then
		mensaje := 'No hay partidas a Procesar ...';
		raise exception '%', mensaje;	
	end if;

	/*
	valor_get := '';
	select c1 into valor_get from keplersc.kdiv where c1 = modelo;
	modelo_get := coalesce(valor_get, '');
	if length(modelo_get) = 0 then
		mensaje := 'No se encontro el Registro en la Tabla kdiv [Vehiculos], modelo [' || modelo || ']';
		raise exception '%', mensaje;
	end if;	
	*/

	--  * * *  Validando Partidas ...
	
	numero_partida := 0;

	for intCont in 0..no_partidas /*- 1*/ loop

		no_vacios := 0;
		
		parte := coalesce((xpath('//document/k_mov/r'||intCont||'/k_parte/text()',dataxml))[1],'');
		pedesp_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_pedesp/text()',dataxml))[1],'');
		sugstck_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_sugstck/text()',dataxml))[1],'');
		surtstck_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_surtstck/text()',dataxml))[1],'');
		cantped_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_cantped/text()',dataxml))[1],'');
		factor_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_factor/text()',dataxml))[1],'');
		mip_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_mip/text()',dataxml))[1],'');
		inv_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_inv/text()',dataxml))[1],'');
		bckord_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_bckord/text()',dataxml))[1],'');
		citas_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_citas/text()',dataxml))[1],'');
		h11_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_h11/text()',dataxml))[1],'');
		h12_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_h12/text()',dataxml))[1],'');
		parteoriginal := coalesce((xpath('//document/k_mov/r'||intCont||'/k_parteoriginal/text()',dataxml))[1],'');
		
		if length(parte) > 0 then no_vacios := no_vacios + 1; end if;
		if length(pedesp_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(sugstck_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(surtstck_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(cantped_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(factor_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(mip_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(inv_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(bckord_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(citas_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(h11_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(h12_tx) > 0 then no_vacios := no_vacios + 1; end if;
	
		if no_vacios < 12 and no_vacios > 0 then 
			mensaje := 'Partidas con datos incompletos ...';
			raise exception '%', mensaje;	
		end if;
	
		if no_vacios > 0 then
			-- Validar datos de catalogos ...
		
			totReg := 0;
			select count(c1) into totReg from keplersc.kdini where c1 = parte;
			if totReg = 0 then
				--Buscar como reemplazo
				select count(*) into totReg from keplersc.kdinr where c1=parte;
				if totReg = 0 then
					mensaje := 'No se encontro la parte como original o reemplazo [Kdini, Kdinr], [' || parte || ']';
					raise exception '%', mensaje;
				end if;
			end if;	
	
			numero_partida := numero_partida + 1;
		
		end if;
		
	end loop;	

	if numero_partida = 0 then
		mensaje := 'Despues de validar la INFO, No se encontraron partidas a Procesar ...';
		raise exception '%', mensaje; 
	end if; 
	

	--  * * *  Procesando Partidas ...

	numero_partida := 0;

	list_items_err := '';
	flag_items := 0;
	
	for intCont in 0..no_partidas /*- 1*/ loop

		no_vacios := 0;
	
		parte := coalesce((xpath('//document/k_mov/r'||intCont||'/k_parte/text()',dataxml))[1],'');
		pedesp_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_pedesp/text()',dataxml))[1],'');
		sugstck_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_sugstck/text()',dataxml))[1],'');
		surtstck_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_surtstck/text()',dataxml))[1],'');
		cantped_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_cantped/text()',dataxml))[1],'');
		factor_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_factor/text()',dataxml))[1],'');
		mip_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_mip/text()',dataxml))[1],'');
		inv_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_inv/text()',dataxml))[1],'');
		bckord_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_bckord/text()',dataxml))[1],'');
		citas_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_citas/text()',dataxml))[1],'');
		h11_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_h11/text()',dataxml))[1],'');
		h12_tx := coalesce((xpath('//document/k_mov/r'||intCont||'/k_h12/text()',dataxml))[1],'');
		parteoriginal := coalesce((xpath('//document/k_mov/r'||intCont||'/k_parteoriginal/text()',dataxml))[1],'');
		
		if length(parte) > 0 then no_vacios := no_vacios + 1; end if;
		if length(pedesp_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(sugstck_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(surtstck_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(cantped_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(factor_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(mip_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(inv_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(bckord_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(citas_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(h11_tx) > 0 then no_vacios := no_vacios + 1; end if;
		if length(h12_tx) > 0 then no_vacios := no_vacios + 1; end if;
		
		-- Si no es un renglon vacio procesa la Info 
		if no_vacios > 0 then 
					
			pedesp := pedesp_tx::decimal;
			sugstck := sugstck_tx::decimal;
			surtstck := surtstck_tx::decimal;
			cantped := cantped_tx::decimal;
			factor := factor_tx::decimal;
			mip := mip_tx::decimal;
			inv := inv_tx::decimal;
			bckord := bckord_tx::decimal;
			citas := citas_tx::decimal;
			h11 := h11_tx::decimal;
			h12 := h12_tx::decimal;
			
			-- Validacion Calculos    
			v_N1 := 0;
			v_N2 := 0;
			v_H11 := 0;
			v_H12 := 0;
			v_H13 := 0;
			v_A5 := 0;
			v_A6 := 0;
		
			v_H11 := h11;
			v_H12 := h12;
			v_H13 := factor;

			v_A5 = surtstck;
			v_A6 = cantped; 	
		
			v_N1 = v_H11 + v_A5; 
			v_N2 = v_H11 + v_H12;
				
			if ( v_A5 < 0 ) then
				flag_items := flag_items + 1;
				list_items_err := list_items_err || ' [' || parte || '] Cantidad Negativa ,';
			end if;
				
			if ( v_H13 > 0 ) then
				v_N1 = ceiling((v_N1 / v_H13)); 
				v_N1 = v_H13 * v_N1;
				v_N2 = ceiling((v_N2 / v_H13));
				v_N2 = v_N2 * v_H13;
			end if;	
			
			if ( v_N1 > v_N2 ) then
				flag_items := flag_items + 1;
				list_items_err := list_items_err || ' [' || parte || '] > Sugerido Sistema ,';
			else
				-- OK
			end if;
			
			-- END Validacion Calculos
			
			if flag_items = 0 then
				if parteoriginal = '' then --VCSS 24 Mar 2026 Actualizacion de parte sugerida por un reemplazo
--raise exception 'PASO 1 ';
					update keplersc.kdpedrefmov  
					set 
						c17 = v_A5, /*surtstck*/
						c18 = v_A6 /*cantped*/
					where c1 = sucursal and c2 = referencia and c3 = parte;
				else 
--raise exception 'PASO 2 parte %; original %',parte,parteoriginal ;
					update keplersc.kdpedrefmov  
					set 
						c3=parte,
						c17 = v_A5, /*surtstck*/
						c18 = v_A6 /*cantped*/
					where c1 = sucursal and c2 = referencia and c3 = parteoriginal;
				end if;
				numero_partida := numero_partida + 1; 
			
			end if;

		end if;
		
	end loop;


	if length(list_items_err) > 0 then
		list_items_err := left(list_items_err, length(list_items_err) - 1); 
		list_items_err := trim(list_items_err);
		resultado := 0;
		mensaje := 'Errores al Procesar los Registros : ' || list_items_err;
		raise exception '%', mensaje;
	end if;

	--if numero_partida <> no_partidas then
	if numero_partida <> (no_partidas + 1) then
		resultado := 0;
		totReg := no_partidas - numero_partida;
		mensaje := 'Errores al Procesar ' || totReg::text || ' Registros : ';
		raise exception '%', mensaje;
	end if;

	--mensaje := 'Opcion en Construccion ...';
	resultado := 1;
	mensaje := 'Los Datos se Actualizaron Satisfactoriamente ...';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

	/*
	mensaje := 'Opcion en pruebas operativas ...';
	--cmnt(1).free4eg by JMM
	raise exception '%', mensaje;
	*/

exception
	when others then
		resultado := 0;
		mensaje := 'tbl_kdpedrefmov_upd(); ' || '['|| sqlstate || '] ' || sqlerrm ;
		if length(list_items_err) > 0 and length(adicionales) = 0 then
			adicionales := list_items_err;
		else
			adicionales := '';
		end if;
		return query select resultado, mensaje, adicionales;	

end;
$function$
