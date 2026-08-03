CREATE OR REPLACE FUNCTION keplersc.invlib_traspaso(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Autor: Luis Leal 27/12/2022
	
	v_sucursal_id text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo_clave text = '';
	fecha_operacion text = '';
	v_inventario text ='';
	clave_cli text ='';
	v_iva text = '';
	v_importe text = '';

	ult_partida int = 0;
	partida int = 1;
 	entradas_en_unidades numeric;
 	salidas_en_unidades numeric;
 	entradas_en_monto numeric;
 	salidas_en_monto numeric;
 	dif_unidades numeric;
 	fecha_compra date;
	ultimo_costo numeric;
 	costo_promedio numeric;
	estatus numeric;

	--Auto
	clave_vehiculo text;
	color_ext text;
	vestiduras text;
	anio text;
	marca text;
	modelo text;
	tipo_auto text;

	--Vars Added by JMM 20230107
	tot_reg_1 numeric;
	tot_reg_2 numeric;

	resultado text;
	mensaje text;
	adicionales text;
begin
	--Resuelve INV_TRASPASO
	v_sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	v_inventario := upper((xpath('//document/k_inventario/text()', dataxml))[1]::text);	
	clave_cli := coalesce((xpath('//document/k_clave/text()', dataxml))[1]::text,'0')::text;
	v_iva := coalesce((xpath('//document/k_iva/text()',dataxml))[1]::text,'0')::text;
	v_importe := coalesce((xpath('//document/k_monto/text()',dataxml))[1]::text,'0')::text;
	
	--------------------------------------------------------------
	------------- TRASPASO
	--------------------------------------------------------------
	if genero = 'U' then 
	
		-- code added by JMM 202230107 
		partida := 1;
	
		select c3 into ult_partida from keplersc.kdventas where c1=v_sucursal_id and c2=v_inventario order by c3 desc limit 1;
		if found then
			partida := ult_partida + 1;
		end if;	
	
		if naturaleza = 'D' then --FACTURA
			estatus= 0;
		else                     --NOTA DE CREDITO
			estatus= 10;
		end if;
	
	
		select c3,c4,c5,c6,c7,c8 into entradas_en_unidades,salidas_en_unidades, 
		entradas_en_monto, salidas_en_monto, fecha_compra, ultimo_costo
		from keplersc.kdlinv where c1=v_sucursal_id and c2=v_inventario;
	

		dif_unidades := entradas_en_unidades- salidas_en_unidades;
	
		if dif_unidades = 0 then
			dif_unidades := 1; 
		end if;
	
		costo_promedio := (entradas_en_monto - salidas_en_monto)/dif_unidades;
	
		if costo_promedio <= 0 then
			 costo_promedio := ultimo_costo;
		end if;
	

		select inf.c3,inf.c10,inf.c11,inf.c15,inf.c17,iv.c7,inf.c21 into clave_vehiculo, color_ext, vestiduras,anio, marca,modelo,tipo_auto
		from keplersc.kdinf as inf inner join keplersc.kdiv as iv on inf.c3=iv.c1
		where inf.c1=v_sucursal_id and inf.c2=v_inventario;	
		
		-- Code Added by JMM 20230107 
		tot_reg_1 = 0;
		tot_reg_2 = 0;
	
		tot_reg_1 := 0;
		select count(c1) into tot_reg_1 from keplersc.kdinf 
			where c1 = v_sucursal_id and c2 = v_inventario;
		/* -- TO DO : Validar si es mejor enviar excepcion
		if tot_reg_1 = 0 then
			mensaje := 'No se encontro el Registro en la Tabla Kdinf [Inventarios].';
			raise exception '%', mensaje;
		end if;	
		*/

		tot_reg_2 := 0;
		select count(c1) into tot_reg_2 from keplersc.kdlinv  
			where c1 = v_sucursal_id and c2 = v_inventario;
		/* -- TO DO : Validar si es mejor enviar excepcion
		if tot_reg_2 = 0 then
			mensaje := 'No se encontro el Registro en la Tabla kdlinv ...';
			raise exception '%', mensaje;
		end if;	
		*/
		
		if tot_reg_1 > 0 and tot_reg_2 > 0 then
		
			-- Codigo Original ... condicionado por JMM en base a revision con VCSS 
			insert into keplersc.kdventas (c1,c2,c3,c4,c5,c6,c7,c8,c9, c10, c11, c13, c14, c15, 
			c16, c17, c18, c19, c20, c21, c22, c23,c24, c25, c26, c27,c28, c29, c30) 
			values(v_sucursal_id,v_inventario,partida,genero,naturaleza, grupo::numeric,
			tipo_clave::numeric,folio_operacion,current_date, estatus, clave_cli,
			'TRAS',clave_vehiculo, 'TRAS','TRAS','TRAS', marca, tipo_auto, anio, modelo,color_ext,
			vestiduras, 0,v_iva::numeric, v_importe::numeric, '', 'N', costo_promedio, fecha_compra );	

		end if;
		
		--call invlib_inv_status(:dataxml, :xmlkdmm) 			
		select * into resultado, mensaje, adicionales from keplersc.invlib_inv_status(dataxml,xmlkdmm);
		--CALL invlib_inv_alta 
		select * into resultado, mensaje, adicionales from keplersc.invlib_inv_alta(dataxml,xmlkdmm,folio_operacion); 	
	
	end if;
		
	
	--------------------------------------------------------------
	------------- END TRASPASO 
	--------------------------------------------------------------
	raise notice 'END TRASPASO';
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'invlib_traspaso() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
