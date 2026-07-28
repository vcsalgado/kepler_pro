CREATE OR REPLACE FUNCTION keplersc.rep_refinventariodia_xml(dataxml xml)
 RETURNS TABLE(v_resultadoxml xml)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Reporte del día por día de los inventarios
--Autor: Desconocido
--Fecha: 10/ENE/2023
--Fecha Mod: 12-Ene-23'
--Reportes Gerenciales
declare
	sucursal_id text = ''; 
	sucursal_criterio text = '';

	resultado text= '';
	mensaje text = '0';
	adicionales text = '';
	totreg int = 0;
	strtTexto text ='';
	
	v_clave_vehiculo text = '';
	v_descripcion_vehiculo text = '';
	v_inventario text = '';
	v_entradas_unidades text = '';
	v_salidas_unidades text = '';
	v_entradas_monto text = '';
	v_salidas_monto text = '';
	v_primera_fecha text = '';
	v_primera_fecha_aux text = '';
	v_color_exterior text = '';
	v_vestiduras text = '';
	v_nuevo_usado text = '';
	v_resultado_unidades decimal = 0;
	v_resultado_monto decimal = 0;
	v_resultado_fecha int;
	
	v_resultado decimal = 0;
	v_descripcion_color text = '';
	v_vestiduras_color text = '';
	v_accesorios text = '';
	v_suma_costos decimal = 0;
	v_dias int = 0;
	v_fecha_asignacion timestamp;
	v_sucursal_aux text = '';
	v_inventario_aux text = '';
	v_clave_vehiculo_aux text = '';
	v_color_exterior_aux text = '';
	v_vestiduras_color_aux text = '';
	v_costos_ventas text = '';
	v_anio_modelo text ='';
	v_anio_modelo_aux text ='';
	v_serie text = '';
	v_apartado text = '';
	v_asesor text = '';
	v_sino text = '';
	v_imprime int;
	v_total_modelo int ;
	v_total_modelo_aux int ;
	v_suma_costos_aux decimal = 0;
	v_clave_vehiculo_d text = '';
	v_descripcion_vehiculo_d text = '';
	v_suma_resultado_fecha int ;
	v_suma_resultado_fecha_aux int ;
	
	v_resultadoXML xml;
	expSql text = '';
	v_contador_inicial int;
	v_contador int;
	v_contador_modelo int;
	v_total_modelos int;
	v_unidades_pendientes text = '';
	v_fechafactura_a int;
	v_fechafactura_b int;
	v_fecha_factura date;
	v_fecha_factura_alerta int;
BEGIN
	sucursal_criterio := upper((xpath('//document/k_sucn/r1/text()', dataxml))[1]::text);
	v_unidades_pendientes := upper((xpath('//document/k_unidades_pendientes/text()', dataxml))[1]::text);	
	strtTexto:= (xpath('//document/k_fechafactura_a/text()', dataxml))[1];
	v_fechafactura_a :=  strtTexto::int;
	strtTexto := (xpath('//document/k_fechafactura_b/text()', dataxml))[1];
	v_fechafactura_b :=  strtTexto::int;	
	
	v_contador_inicial = 0;
	v_total_modelo = 0;
	v_total_modelo_aux = 0 ;
	v_total_modelos = 0;
	v_contador = 0;

--raise exception 'ERROR 123 :% ', sucursal_criterio;	
	for v_clave_vehiculo, v_descripcion_vehiculo in select c1,c2 from keplersc.KDIV  --V
	loop
		v_contador_inicial = v_contador_inicial + 1 ;
		v_imprime = 0; 		 
		v_contador_modelo=0;
		
		for sucursal_id, v_inventario,v_entradas_unidades,v_salidas_unidades,v_entradas_monto,v_salidas_monto,v_primera_fecha
		in select c1,c2,c3,c4,c5,c6,c7 from keplersc.KDLINV  where c1 = sucursal_criterio and c13 = 0 and c12 = v_clave_vehiculo  --C
			loop				
				
  			 	select c3,c4,c5,c10,c11,c15,c21 into v_clave_vehiculo_d,v_descripcion_vehiculo_d,v_serie,v_color_exterior,v_vestiduras,v_anio_modelo,v_nuevo_usado  
  			 	from keplersc.KDINF  where c1 = sucursal_id and c2 = v_inventario;  --D
  			 	v_resultado_unidades := v_entradas_unidades::decimal - v_salidas_unidades::decimal; --N1
				v_resultado_monto := v_entradas_monto::decimal - v_salidas_monto::decimal; --B1			
				v_resultado_fecha := (select now()::date - v_primera_fecha::date); --N2	
				if v_resultado_unidades::decimal <> 0 then 
					v_resultado = v_resultado_monto / v_resultado_unidades::decimal; --B2
				end if;

				--if v_resultado_fecha >= 0 and v_resultado_fecha <= 1999 then 
				select c4 into v_descripcion_color from keplersc.KDICE2 where c1 = v_clave_vehiculo  and c3 = v_color_exterior; --F
				if v_descripcion_color is null or v_descripcion_color = '' then 
					v_descripcion_color = "NOT FOUND";
				end if;
				select c4 into v_vestiduras_color  from keplersc.KDICE3 where c1 = v_clave_vehiculo  and c3 = v_vestiduras; --G
				if v_vestiduras_color  is null or v_vestiduras_color = '' then 
					v_vestiduras_color = "NOT FOUND";
				end if;				
				v_descripcion_color = v_descripcion_color || v_vestiduras_color;			
				v_contador = v_contador + 1;
				if v_imprime = 0 then 
					--|raise notice ' inicia cont %',v_contador_inicial;
					v_resultadoXML := concat(v_resultadoXML,format(
							'<r_%14$s_%1$s>								
								<v1>%2$s</v1><v2>%3$s</v2><v3>%4$s</v3><v4>%5$s</v4><v5>%6$s</v5>
								<v6>%7$s</v6><v7>%8$s</v7><v8>%9$s</v8><v9>%10$s</v9><v10>%11$s</v10><v11>%12$s</v11><v12>%13$s</v12>															
							</r_%14$s_%1$s>',v_contador,'','','','','','','','','','','','',v_contador_inicial::text)); v_contador = v_contador + 1;
					--|raise notice 'v_resultadoXML %',v_resultadoXML;
					--|raise notice ' %,		%',v_clave_vehiculo,v_descripcion_vehiculo;
					v_resultadoXML := concat(v_resultadoXML,format(
							'<r_%14$s_%1$s>
								<v1>%2$s</v1><v2>%3$s</v2><v3>%4$s</v3><v4>%5$s</v4><v5>%6$s</v5>
								<v6>%7$s</v6><v7>%8$s</v7><v8>%9$s</v8><v9>%10$s</v9><v10>%11$s</v10><v11>%12$s</v11><v12>%13$s</v12>								
							</r_%14$s_%1$s>',v_contador,v_clave_vehiculo,'-','-','-',v_descripcion_vehiculo,'','','','','','','',v_contador_inicial)); v_contador = v_contador + 1;
					v_imprime = 1;
				end if;
				if v_nuevo_usado = 'USADO' then 
					--|raise notice 'v_clave_vehiculo_d %,v_descripcion_vehiculo_d %',v_clave_vehiculo_d,v_descripcion_vehiculo_d;
					v_resultadoXML := concat(v_resultadoXML,format(
							'<r_%14$s_%1$s>
								<v1>%2$s</v1><v2>%3$s</v2><v3>%4$s</v3><v4>%5$s</v4><v5>%6$s</v5>
								<v6>%7$s</v6><v7>%8$s</v7><v8>%9$s</v8><v9>%10$s</v9><v10>%11$s</v10><v11>%12$s</v11><v12>%13$s</v12>								
							</r_%14$s_%1$s>',v_contador,v_clave_vehiculo_d,'-','-','-',v_descripcion_vehiculo_d,'','','','','','','',v_contador_inicial)); v_contador = v_contador + 1;
					--|raise notice 'v_resultadoXML %'	, v_resultadoXML;
				end if;				
				select c6,case when c5 = 10 then 'SI' when c5 = 0 then 'NO' end as c5,c3,c4 
				into v_accesorios,v_sino,v_apartado, v_asesor from keplersc.KDINVADIC where c1 = sucursal_id and c2 = v_inventario;				
				v_total_modelo = v_total_modelo  + 1;--N11
				v_suma_costos = v_suma_costos + v_resultado::decimal;--B12
				v_suma_resultado_fecha = v_suma_resultado_fecha  + v_resultado_fecha;--N12
				v_total_modelo_aux = v_total_modelo_aux  + 1;--N21
				v_suma_costos_aux = v_suma_costos + v_resultado::decimal;--B22
				v_suma_resultado_fecha_aux = v_suma_resultado_fecha_aux  + v_resultado_fecha;--N22
				
				if v_sino is null or v_sino = '' then
					v_sino = 'NO';
				end if;
				if v_apartado is null or v_apartado = '' then 
					v_apartado = '0.00';
				end if;
				if v_asesor is null or v_asesor = '' then 
					v_asesor = '';
				end if;
				
				--|raise notice '%,%, %, %,%,%, %, %,%, %,%, %',
				--|v_primera_fecha::date, v_inventario, v_anio_modelo,v_nuevo_usado, v_serie,v_descripcion_color,v_resultado,v_resultado_fecha,v_apartado, v_asesor,v_accesorios, v_sino;				
				v_resultadoXML := concat(v_resultadoXML,format(
							'<r_%14$s_%1$s>
								<v1>%2$s</v1><v2>%3$s</v2><v3>%4$s</v3><v4>%5$s</v4><v5>%6$s</v5>
								<v6>%7$s</v6><v7>%8$s</v7><v8>%9$s</v8><v9>%10$s</v9><v10>%11$s</v10><v11>%12$s</v11><v12>%13$s</v12>								
							</r_%14$s_%1$s>',v_contador,v_primera_fecha::date, v_inventario, v_anio_modelo,v_nuevo_usado, v_serie,v_descripcion_color,v_resultado,v_resultado_fecha,v_apartado, v_asesor, v_sino,v_accesorios,v_contador_inicial)); v_contador = v_contador + 1;
						
		end loop;
		if v_total_modelo > 0 then 
			--| raise notice 'Total para el modelo %, Días Venta %,			%, %', v_total_modelo, v_dias,v_suma_costos,v_suma_resultado_fecha;
			v_total_modelos := (v_total_modelos + v_total_modelo);
			--| raise notice 'TOTAL CONSOLIDADO**** %',v_total_modelos;
			v_resultadoXML := concat(v_resultadoXML,format(
							'<r_%14$s_%1$s>
								<v1>%2$s</v1><v2>%3$s</v2><v3>%4$s</v3><v4>%5$s</v4><v5>%6$s</v5>
								<v6>%7$s</v6><v7>%8$s</v7><v8>%9$s</v8><v9>%10$s</v9><v10>%11$s</v10><v11>%12$s</v11><v12>%13$s</v12>								
							</r_%14$s_%1$s>',v_contador,'','Total para el modelo ' || v_total_modelo,'Días de',' Venta',v_dias,'','$'||v_suma_costos,'','','','',v_suma_resultado_fecha,v_contador_inicial)); v_contador = v_contador + 1;
			v_contador_modelo = v_contador_modelo + 1;			
		end if;
		
		v_imprime = 0;
		v_total_modelo=0;
		v_dias = 0;
		v_suma_costos = 0;
	 	v_inventario = '';
		 raise notice 'ciclo 2';
		for v_inventario,v_clave_vehiculo_d,v_descripcion_vehiculo_d,v_anio_modelo_aux,v_serie,v_fecha_asignacion,v_nuevo_usado 
		in select c2,c3,c4,c7,c8,c9,c10 from keplersc.KDASIG where c1 =sucursal_id and c11 = 10  and c3 = v_clave_vehiculo	 --- J	
			loop	
				
				if v_fecha_asignacion::date <= (select now()::date) then 
					select c4 into v_descripcion_color from keplersc.KDICE2 where c1 = v_clave_vehiculo  and c3 = v_color_exterior; --F	
					if v_descripcion_color is null or v_descripcion_color = '' then 
						v_descripcion_color = "NOT FOUND";
					end if;
					raise notice '1a';
					select c4 into v_vestiduras_color  from keplersc.KDICE3 where c1 = v_clave_vehiculo  and c3 = v_vestiduras; --G
					if v_vestiduras_color  is null or v_vestiduras_color = '' then 
						v_vestiduras_color = "NOT FOUND";
					end if;
					v_descripcion_color = v_descripcion_color || v_vestiduras_color;
					
					if v_imprime = 0 then						 
						v_resultadoXML := concat(v_resultadoXML,format(
							'<r_%14$s_%1$s>								
								<v1>%2$s</v1><v2>%3$s</v2><v3>%4$s</v3><v4>%5$s</v4><v5>%6$s</v5>
								<v6>%7$s</v6><v7>%8$s</v7><v8>%9$s</v8><v9>%10$s</v9><v10>%11$s</v10><v11>%12$s</v11><v12>%13$s</v12>															
							</r_%14$s_%1$s>',v_contador,v_clave_vehiculo,'-','-','-',v_descripcion_vehiculo,'','','','','','','',v_contador_inicial::text)); v_contador = v_contador + 1;		
						v_imprime = 1;
					end if;
					if v_nuevo_usado = 'USADO' then 
						--IMPRIME 21
					v_resultadoXML := concat(v_resultadoXML,format(
							'<r_%14$s_%1$s>								
								<v1>%2$s</v1><v2>%3$s</v2><v3>%4$s</v3><v4>%5$s</v4><v5>%6$s</v5>
								<v6>%7$s</v6><v7>%8$s</v7><v8>%9$s</v8><v9>%10$s</v9><v10>%11$s</v10><v11>%12$s</v11><v12>%13$s</v12>															
							</r_%14$s_%1$s>',v_contador,v_clave_vehiculo,'-','-','-',v_descripcion_vehiculo_d,'','','','','','','',v_contador_inicial::text)); v_contador = v_contador + 1;	
					
					end if;
					--IMPRIME 23
					v_resultadoXML := concat(v_resultadoXML,format(
							'<r_%14$s_%1$s>								
								<v1>%2$s</v1><v2>%3$s</v2><v3>%4$s</v3><v4>%5$s</v4><v5>%6$s</v5>
								<v6>%7$s</v6><v7>%8$s</v7><v8>%9$s</v8><v9>%10$s</v9><v10>%11$s</v10><v11>%12$s</v11><v12>%13$s</v12>															
							</r_%14$s_%1$s>',v_contador,v_fecha_asignacion::date,v_inventario,v_anio_modelo_aux,v_nuevo_usado,v_serie,v_descripcion_color,'0.00','0','ASIGNADO SIN','INGRESAR AL','INVENTARIO','',v_contador_inicial::text)); v_contador = v_contador + 1;				
					v_dias = v_dias + 1 ;
				end if;
		end loop;
	v_suma_costos = 0;
	v_resultado = 0;
	
	raise notice 'ciclo 3 _v_clave_vehiculo%',v_clave_vehiculo;
	if v_unidades_pendientes = 'S' then 		
		for v_sucursal_aux,v_inventario_aux,v_clave_vehiculo_aux,v_descripcion_vehiculo_d,v_serie,v_color_exterior_aux,v_vestiduras_color_aux,v_anio_modelo_aux,v_nuevo_usado 
		in select c1,c2,c3,c4,c5,c10,c11,c15,c21 from keplersc.KDINF  where c1 = sucursal_id AND c3 = v_clave_vehiculo AND c32 >= 20 AND c32 < 60 ---D
			loop 
				
				select c9,c29,c30 into v_fecha_factura,v_costos_ventas,v_primera_fecha_aux from keplersc.KDVENTAS where c1 = v_sucursal_aux and c2 = v_inventario_aux;
				v_resultado_fecha = (select now()::date - v_primera_fecha_aux::date); --N2
				raise notice 'v_resultado_fecha %',v_resultado_fecha;
				if v_resultado_fecha >= v_fechafactura_a and v_resultado_fecha <= v_fechafactura_b  then 
					select c4 into v_descripcion_color from keplersc.KDICE2 where c1 = v_clave_vehiculo_aux  and c3 = v_color_exterior_aux; --F				
					if v_descripcion_color is null or v_descripcion_color = '' then 
						v_descripcion_color = "NOT FOUND";
					end if;
					select c4 into v_vestiduras_color  from keplersc.KDICE3 where c1 = v_clave_vehiculo_aux  and c3 = v_vestiduras_color_aux; --G
					if v_vestiduras_color  is null or v_vestiduras_color = '' then 
						v_vestiduras_color = "NOT FOUND";
					end if;
					v_descripcion_color = v_descripcion_color || v_vestiduras_color;			
				
					select c6,case when c5 = 10 then 'SI' when c5 = 0 then 'NO' end as c5
					into v_accesorios,v_sino
					from keplersc.KDINVADIC where c1 = v_sucursal_aux and c2 = v_inventario_aux;
				v_resultado = v_costos_ventas;--B2
				v_resultado_fecha = (select now()::date - v_primera_fecha_aux::date); --N2
				
				if v_imprime = 0 then						 
						v_resultadoXML := concat(v_resultadoXML,format(
							'<r_%14$s_%1$s>								
								<v1>%2$s</v1><v2>%3$s</v2><v3>%4$s</v3><v4>%5$s</v4><v5>%6$s</v5>
								<v6>%7$s</v6><v7>%8$s</v7><v8>%9$s</v8><v9>%10$s</v9><v10>%11$s</v10><v11>%12$s</v11><v12>%13$s</v12>															
							</r_%14$s_%1$s>',v_contador,v_clave_vehiculo,'-','-','-',v_descripcion_vehiculo,'','','','','','','',v_contador_inicial::text)); v_contador = v_contador + 1;		
						v_imprime = 1;
				end if;
				
				if v_nuevo_usado = 'USADO' then 
						--IMPRIME 21
					v_resultadoXML := concat(v_resultadoXML,format(
							'<r_%14$s_%1$s>								
								<v1>%2$s</v1><v2>%3$s</v2><v3>%4$s</v3><v4>%5$s</v4><v5>%6$s</v5>
								<v6>%7$s</v6><v7>%8$s</v7><v8>%9$s</v8><v9>%10$s</v9><v10>%11$s</v10><v11>%12$s</v11><v12>%13$s</v12>															
							</r_%14$s_%1$s>',v_contador,v_clave_vehiculo_aux,'-','-','-',v_descripcion_vehiculo_d,'','','','','','','',v_contador_inicial::text)); v_contador = v_contador + 1;	
					
				end if;
				
				v_sino = '';
				v_fecha_factura_alerta = (select now()::date - v_fecha_factura::date) ;
				if v_fecha_factura_alerta > 15 then 
					v_sino = 'ALERTA';	
				end if;
				end if;
					v_suma_costos = v_costos_ventas;
					v_suma_costos = (v_suma_costos + v_resultado::decimal);
					v_dias = v_dias + 1;
				
				v_resultadoXML := concat(v_resultadoXML,format(
							'<r_%14$s_%1$s>
								<v1>%2$s</v1><v2>%3$s</v2><v3>%4$s</v3><v4>%5$s</v4><v5>%6$s</v5>
								<v6>%7$s</v6><v7>%8$s</v7><v8>%9$s</v8><v9>%10$s</v9><v10>%11$s</v10><v11>%12$s</v11><v12>%13$s</v12>								
							</r_%14$s_%1$s>',v_contador,v_primera_fecha_aux::date, 
														v_inventario_aux, 
														v_anio_modelo_aux,
														v_nuevo_usado, 
														v_serie,
														v_descripcion_color,
														v_resultado,
														v_resultado_fecha,
														v_sino,
														v_resultado_fecha, 
														'Días desde la facturación ', 
														v_accesorios,
														v_contador_inicial)); v_contador = v_contador + 1;
					
						
			end loop;
	 end if;
	end loop;
	v_resultadoXML := concat(v_resultadoXML,format('<total_modelo>%1$s</total_modelo>',v_contador));
	v_resultadoXML := concat(v_resultadoXML,format('<total>%1$s</total>',v_total_modelos));

	return	query 
	select v_resultadoXML;


--exception
--	when others then
--		raise notice ' error %', sqlstate || '] ' || sqlerrm ;
--		resultado := 0;	
--		mensaje := 'reporte_inventario_por_dia() ' || '['|| sqlstate || '] ' || sqlerrm ;
--		adicionales := '';
		--return query select resultado, mensaje, adicionales;
END;
$function$
