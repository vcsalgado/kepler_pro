CREATE OR REPLACE FUNCTION keplersc.rep_comisiones_coaches(dataxml xml)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
--Descripcion: Reporte de las comisiones de un coach (SUBARU)
--Autor: Luis Leal
--Fecha: 15/11/2022
--Bitacora de cambios
declare
	--Variables principales
	sucursal_id text = '';
	mes text = '';
	anio text = '';
	coach text = '';
	fecha_inicial timestamp;
	fecha_final timestamp;
	str_date text;
	ultimo_dia_mes text;

	--Variables de Objetivos(kdobjgv)
 	primer_obj_entregas_nuevos numeric = 0;
 	segundo_obj_entregas_nuevos numeric = 0;
 	obj_margen_utilidad numeric = 0;
	obj_entregas_financiera_1 numeric = 0;
	obj_entregas_financiera_2 numeric = 0;
	obj_1_csi numeric = 0;
	obj_2_csi numeric = 0;
	obj_dias_atraso_max_autos_nuevos numeric = 0;
	obj_dias_atraso_max_autos_seminuevos numeric = 0;
	obj_facturacion_autos_nuevos numeric = 0;
	obj_toma_autos_seminuevos numeric = 0;
	obj_entregas_garantia_extendida numeric = 0;
	obj_utilidad_bruta_accesorios numeric = 0;
	obj_seguros_contado numeric = 0;
	libre  numeric = 0;
	obj_facturacion_seminuevos numeric = 0;
	primer_obj_entregas_seminuevos numeric = 0;
	segundo_obj_entregas_seminuevos numeric = 0;
	obj_entregas_financiera_1_seminuevos numeric = 0;
	obj_entregas_financiera_2_seminuevos numeric = 0;

	--Variables loop (kdcomismov) 
	inventario text;
	descuento numeric = 0;
	seguro numeric = 0;
 	accesorios numeric = 0;
	garantia_extendida numeric = 0;
	isan numeric = 0;
	iva numeric = 0;
	importe numeric = 0;
	costo numeric = 0;
	alta_baja text;
	tipo_operacion text;
	--Variables loop (kdcomisadis)
	subsidio numeric ;
	cargos_bonificaciones numeric;
	abonos_bonificaciones numeric;
	cargo_al_costo_de_accesorios numeric;
	abono_al_costo_de_accesorios numeric;
	cargo_al_costo_de_unidades numeric;
	abono_al_costo_de_unidades numeric;
	--Variables loop (kdtop)
	operacion_gmac text;
	--Variables Loop (kdm1)
	estatus_doc text;


	--Variables extras loop
	venta_garantia_extendida numeric = 0;
	utilidad_bruta_autos_nuevos_sin_pva numeric = 0;
	utilidad_bruta_autos_seminuevos_sin_pva numeric = 0;
	utilidad numeric = 0;
	utilidad_accesorios numeric = 0;
	monto_seguro numeric;
	entregas_financiera numeric = 0;
	comision_obj_seguros_contado numeric = 0;
 	utilidad_quitando_impuestos_total numeric = 0;
 	utilidad_quitando_impuestos numeric = 0;
 	fecha_com date;
 	estatus_com text;

	--Variables de los resultados reales de las ventas
	real_entregas_nuevos numeric = 0;
	real_entregas_financiera_nuevos numeric = 0;
	real_entregas_seminuevos numeric = 0;
	real_entregas_financiera_seminuevos numeric = 0;
	real_utilidad_bruta_accesorios numeric = 0;
	real_seguros_contado numeric = 0;
	real_entregas_garantia_extendida numeric = 0;

	--Variables (kdventas)
	nuevo_usado text;
	flotilla text;

	--Variables de porcentajes(p) de bonos y descuentos (kdesqgv)
	esquema text;
	p_primer_obj_entregas_nuevos numeric;
	p_segundo_obj_entregas_nuevos  numeric;
	p_obj_margen_utilidad  numeric;
	p_obj_share_financiera_1 numeric;
	p_obj_share_financiera_2 numeric;
	p_obj_1_csi numeric;
	p_obj_2_csi  numeric;
	p_descuento_unidades_atrasadas_nuevos numeric;
	p_descuento_unidades_atrasadas_seminuevos numeric;
	p_combinado numeric;
	p_obj_fact_nuevos numeric;
	p_obj_tomas numeric;
	p_obj_venta_garantia_extendida numeric;
	p_obj_entregas_trimestrales numeric;
	p_obj_accesorios numeric;
	p_obj_seguros_contado numeric;
	p_combinado_seminuevos numeric;
	p_facturacion_seminuevos numeric;
	p_primer_obj_entregas_seminuevos numeric;
	p_segundo_obj_entregas_seminuevos numeric;
	p_primer_obj_financiera_seminuevos numeric;
	p_segundo_obj_financiera_seminuevos numeric;
	pagar_flotillas text;

	--Variables descuentos
	d_unidades_atrasadas_nuevos numeric;
	d_unidades_atrasadas_seminuevos numeric;
	descuento_total_nuevos numeric;
	descuento_total_seminuevos numeric;

	--Variables de bonos 
	b_primer_obj_entregas_nuevos numeric = 0;
	b_segundo_obj_entregas_nuevos  numeric  = 0;
	b_obj_margen_utilidad  numeric  = 0;
	b_obj_share_financiera_1 numeric  = 0;
	b_obj_share_financiera_2 numeric  = 0;
	b_obj_1_csi numeric  = 0;
	b_obj_2_csi  numeric  = 0;
	b_combinado numeric = 0;
	b_obj_fact_nuevos numeric  = 0;
	b_obj_tomas numeric = 0;
	b_obj_venta_garantia_extendida numeric = 0;
	b_obj_entregas_trimestrales numeric = 0;
	b_obj_accesorios numeric = 0;
	b_obj_seguros_contado numeric  = 0;
	b_combinado_seminuevos numeric = 0;
	b_facturacion_seminuevos numeric = 0;
	b_primer_obj_entregas_seminuevos numeric = 0;
	b_segundo_obj_entregas_seminuevos numeric = 0;
	b_primer_obj_financiera_seminuevos numeric = 0;
	b_segundo_obj_financiera_seminuevos numeric = 0;
	total_bonos numeric = 0;

	--Variables de comisiones 
	c_primer_obj_entregas_nuevos numeric = 0;
	c_segundo_obj_entregas_nuevos  numeric = 0;
	c_obj_margen_utilidad  numeric = 0;
	c_obj_share_financiera_1 numeric = 0;
	c_obj_share_financiera_2 numeric = 0;
	c_obj_1_csi numeric = 0;
	c_obj_2_csi  numeric = 0;
	c_combinado numeric = 0;
	c_obj_fact_nuevos numeric = 0;
	c_obj_tomas numeric = 0;
	c_obj_venta_garantia_extendida numeric = 0;
	c_obj_entregas_trimestrales numeric = 0;
	c_obj_accesorios numeric = 0;
	c_obj_seguros_contado numeric = 0;
	c_combinado_seminuevos numeric = 0;
	c_facturacion_seminuevos numeric = 0;
	c_primer_obj_entregas_seminuevos numeric = 0;
	c_segundo_obj_entregas_seminuevos numeric = 0;
	c_primer_obj_financiera_seminuevos numeric = 0;
	c_segundo_obj_financiera_seminuevos numeric = 0;
	total_comisiones numeric = 0;

	--Variables loop 2 (kdicom)
	status_compra numeric;
	tipo_compra text;
	real_toma_unidades_seminuevas numeric = 0;


	--Variables loop 3 (kdventas)
	status_venta numeric;
	tipo_venta text;
	real_venta_unidades_nuevas numeric = 0;
	real_venta_unidades_seminuevas numeric = 0;
	real_margen_utilidad numeric = 0;

	--Variables loop 4 
	num_inv text;
	tipo_inv text;
	int_valor numeric;
	fecha_compra date;
	subtotal_compra numeric;
	diferencia_fechas numeric;
	num_dias_atrasados_nuevos numeric = 120;
	descuento_dias_atrasados_nuevos numeric = 0;
	num_dias_atrasados_seminuevos numeric = 90;
	descuento_dias_atrasados_seminuevos numeric = 0;

	--Variables (kdvcsi)
	real_csi numeric;
	csi_planta numeric;	

	--Variables loop 5(kdvargv)
	contador_obj_extras numeric = 0;
	tipo_auto text;
	porcentaje_comsion numeric;
	objetivo_variable numeric;
	resultado numeric;
	comision_variable numeric;
	bono_variable numeric;
	desc_objetivo text;


	--Variables loop 6
	linea text;
	objetivo_linea numeric;
	bono_linea numeric;
	comision_linea numeric;
	clave_version text;
	tipo_mov text;
	ventas_por_linea numeric;

	--Variables de uso general 
	xmlResultado text = '';

begin

	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	mes := (xpath('//document/mes/text()', dataxml))[1];
	anio:= (xpath('//document/anio/text()', dataxml))[1];
	coach := (xpath('//document/coach/text()', dataxml))[1];

	str_date := concat(anio, '/', mes, '/', '14');
	select date_part('days', (date_trunc('month', str_date::date ) + interval '1 month - 1 day')) into ultimo_dia_mes;

	str_date :=  concat(anio, '-', mes, '-', '01', ' ', '00:00:00') ;
	fecha_inicial := to_timestamp(str_date, 'yyyy-mm-dd HH24:MI:SS');

	str_date := concat(anio, '-', mes, '-', ultimo_dia_mes, ' ', '23:59:59');
	fecha_final := to_timestamp(str_date, 'yyyy-mm-dd HH24:MI:SS');

	anio := substring(anio,3,2);

	xmlResultado :=   format('<fecha_inicial>%1$s</fecha_inicial><fecha_final>%2$s</fecha_final>',left(fecha_inicial::text, 10), left(fecha_final::text, 10));

	select c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22,c23,c24
	into primer_obj_entregas_nuevos,segundo_obj_entregas_nuevos, obj_margen_utilidad, 
	obj_entregas_financiera_1,obj_entregas_financiera_2, obj_1_csi, obj_2_csi, 
	obj_dias_atraso_max_autos_nuevos, obj_dias_atraso_max_autos_seminuevos
	,obj_facturacion_autos_nuevos, obj_toma_autos_seminuevos, obj_entregas_garantia_extendida,
	obj_utilidad_bruta_accesorios, obj_seguros_contado, libre, obj_facturacion_seminuevos,
	primer_obj_entregas_seminuevos, segundo_obj_entregas_seminuevos
	,obj_entregas_financiera_1_seminuevos, obj_entregas_financiera_2_seminuevos
	from keplersc.kdobjgv where c1=sucursal_id and c2=coach and c3=mes and c4=anio;

	num_dias_atrasados_nuevos = obj_dias_atraso_max_autos_nuevos;
	num_dias_atrasados_seminuevos = obj_dias_atraso_max_autos_seminuevos;

	--OBTENER PORCENTAJES(p) DE BONOS y DESCUENTOS (kdesqgv)
	select  cat.c6, qgv.c2,qgv.c3,qgv.c4,qgv.c5,qgv.c6,qgv.c7,qgv.c8,qgv.c9,qgv.c10, qgv.c11, qgv.c12, qgv.c13, qgv.c14, qgv.c15,
	qgv.c16, qgv.c17,qgv.c18, qgv.c19,qgv.c20, qgv.c21, qgv.c22, qgv.c23,qgv.c24 into esquema, p_primer_obj_entregas_nuevos,
	p_segundo_obj_entregas_nuevos,  p_obj_margen_utilidad, p_obj_share_financiera_1,
	p_obj_share_financiera_2, p_obj_1_csi, p_obj_2_csi,p_descuento_unidades_atrasadas_nuevos ,p_descuento_unidades_atrasadas_seminuevos,p_combinado,
	p_obj_fact_nuevos, p_obj_tomas, p_obj_venta_garantia_extendida, p_obj_entregas_trimestrales, p_obj_accesorios, p_obj_seguros_contado,
	p_combinado_seminuevos, p_facturacion_seminuevos,p_primer_obj_entregas_seminuevos, p_segundo_obj_entregas_seminuevos,
	p_primer_obj_financiera_seminuevos, p_segundo_obj_financiera_seminuevos, pagar_flotillas
	from keplersc.kdesqgv as qgv inner join keplersc.kdcatcoach as cat on qgv.c1=cat.c6 where cat.c1=coach;
		
	--SUB CALCULA_RESULTADOS
	for inventario,alta_baja, tipo_operacion, descuento,seguro, accesorios,garantia_extendida,isan,iva,importe,costo,subsidio,cargos_bonificaciones,abonos_bonificaciones,
	cargo_al_costo_de_accesorios, abono_al_costo_de_accesorios,cargo_al_costo_de_unidades,abono_al_costo_de_unidades, operacion_gmac, estatus_doc
	in select mov.c8,mov.c10,mov.c11,mov.c15,mov.c17, mov.c18,mov.c19,mov.c20,mov.c21,mov.c22,mov.c23,adis.c8,adis.c9,adis.c10,adis.c11,adis.c12,adis.c13,adis.c14, top.c3,km1.c43
	from keplersc.kdcomismov as mov inner join keplersc.kdcomisadis as adis on mov.c1=adis.c1 and mov.c2=adis.c2 
	and mov.c3=adis.c3 and mov.c4=adis.c4 and mov.c5=adis.c5 and mov.c6=adis.c6 and mov.c10=adis.c7
	inner join keplersc.kdm1 as km1 on mov.c1=km1.c1 and mov.c2=km1.c2 and mov.c3=km1.c3 and mov.c4=km1.c4 and mov.c5=km1.c5 and mov.c6=km1.c6
	left outer join keplersc.kdtop as top on mov.c11=top.c1
	where mov.c1=sucursal_id and mov.c26=coach and mov.c7 between fecha_inicial and fecha_final 
	loop 
		
		select c19,c28 into nuevo_usado, flotilla from keplersc.kdventas
		where c1=sucursal_id and c2=inventario order by c3 desc limit 1;
		if found then
								
				if flotilla <> 'S'  or pagar_flotillas = 'S' then  
									
					utilidad  := importe - iva - isan - costo - subsidio - (cargo_al_costo_de_unidades - abono_al_costo_de_unidades) ;
					utilidad := utilidad - descuento + (cargos_bonificaciones - abonos_bonificaciones );	
					utilidad_quitando_impuestos = importe - iva - isan;
					utilidad_accesorios = accesorios - cargo_al_costo_de_accesorios + abono_al_costo_de_accesorios;
									
					monto_seguro := 0;
					entregas_financiera := 0;
				

					if operacion_gmac is not null then 
						if operacion_gmac <> 'S' then
							monto_seguro := seguro;
						else
							entregas_financiera := entregas_financiera + 1;
						end if;
					end if; 
					
					venta_garantia_extendida := 0;
					if garantia_extendida > 0 then
						venta_garantia_extendida := venta_garantia_extendida + 1;
					end if;
				
					if alta_baja = '0' then
					
						if nuevo_usado = 'NUEVO' then
						
							utilidad_bruta_autos_nuevos_sin_pva := utilidad_bruta_autos_nuevos_sin_pva + utilidad;
							real_entregas_nuevos := real_entregas_nuevos + 1;
							real_entregas_financiera_nuevos := real_entregas_financiera_nuevos + entregas_financiera;
						
						else
						
							utilidad_bruta_autos_seminuevos_sin_pva := utilidad_bruta_autos_seminuevos_sin_pva + utilidad;
							real_entregas_seminuevos :=  real_entregas_seminuevos + 1;
							real_entregas_financiera_seminuevos := real_entregas_financiera_seminuevos + entregas_financiera;

						end if;
					
						utilidad_quitando_impuestos_total := utilidad_quitando_impuestos_total + utilidad_quitando_impuestos;
						real_utilidad_bruta_accesorios := real_utilidad_bruta_accesorios + utilidad_accesorios;
						real_seguros_contado := real_seguros_contado + monto_seguro;
						real_entregas_garantia_extendida := real_entregas_garantia_extendida + venta_garantia_extendida;
						
					else
						
						if nuevo_usado = 'NUEVO' then
						
							utilidad_bruta_autos_nuevos_sin_pva := utilidad_bruta_autos_nuevos_sin_pva - utilidad;
							real_entregas_nuevos := real_entregas_nuevos - 1;
							real_entregas_financiera_nuevos := real_entregas_financiera_nuevos - entregas_financiera;
						
						else
						
							utilidad_bruta_autos_seminuevos_sin_pva := utilidad_bruta_autos_seminuevos_sin_pva - utilidad;
							real_entregas_seminuevos :=  real_entregas_seminuevos - 1;
							real_entregas_financiera_seminuevos := real_entregas_financiera_seminuevos - entregas_financiera;

						end if;
					
						utilidad_quitando_impuestos_total := utilidad_quitando_impuestos_total - utilidad_quitando_impuestos;
						real_utilidad_bruta_accesorios := real_utilidad_bruta_accesorios - utilidad_accesorios;
						real_seguros_contado := real_seguros_contado - monto_seguro;
						real_entregas_garantia_extendida := real_entregas_garantia_extendida - venta_garantia_extendida;
					
					end if;
				
				end if;	
									
		end if;
		
	end loop;

	xmlResultado :=  concat(xmlResultado, format('<utilidad_bruta_autos_nuevos_sin_pva>%1$s</utilidad_bruta_autos_nuevos_sin_pva>
	<utilidad_bruta_autos_seminuevos_sin_pva>%2$s</utilidad_bruta_autos_seminuevos_sin_pva>',
	utilidad_bruta_autos_nuevos_sin_pva, utilidad_bruta_autos_seminuevos_sin_pva));
--raise notice 'PASO 1 xmlResultado:%',xmlResultado;
	real_margen_utilidad := (utilidad_bruta_autos_nuevos_sin_pva + utilidad_bruta_autos_seminuevos_sin_pva)/utilidad_quitando_impuestos_total*100;
		
	for status_compra, tipo_compra in select c12, c20 from keplersc.kdicom
	where c1=sucursal_id and c40=coach and c9 >=fecha_inicial and c9 <=fecha_final 
	loop 
		
		if tipo_compra = 'USADO' then 
			
			if status_compra = 0 then 
				real_toma_unidades_seminuevas := real_toma_unidades_seminuevas + 1;
			else 
				real_toma_unidades_seminuevas := real_toma_unidades_seminuevas - 1;
			end if;
		
		end if;
		
	end loop;

	for status_venta, tipo_venta in select ven.c10,ven.c19 from keplersc.kdventas as ven 
	inner join keplersc.kdinf as inv on ven.c1=inv.c1 and ven.c2=inv.c2
	where ven.c1=sucursal_id and ven.c13=coach and ven.c9 >=fecha_inicial and ven.c9 <=fecha_final
	loop
		
		if tipo_venta= 'NUEVO' then 
				
			if status_venta = 0 then 
				real_venta_unidades_nuevas := real_venta_unidades_nuevas + 1; 
			else 
				real_venta_unidades_nuevas := real_venta_unidades_nuevas - 1;
			end if;
			
		else
			
			if status_venta = 0 then 
				real_venta_unidades_seminuevas := real_venta_unidades_seminuevas + 1; 
			else 
				real_venta_unidades_seminuevas := real_venta_unidades_seminuevas - 1;
			end if;
			
		end if;
		
	end loop;


	--SUB CALCULA_OBJETIVO_ATRASADOS
	for num_inv, tipo_inv in select c2,c21 from keplersc.kdinf where c1=sucursal_id and c31=20 and c32<=60
	loop 
		
		select c7,c10 into fecha_com,estatus_com from keplersc.kdcomismov where c1=sucursal_id and c8=num_inv order by c6 desc,c7 desc limit 1;
		if estatus_com = '0' and fecha_com <= fecha_final then
			continue;
		else

			select c9,c31 into fecha_compra, subtotal_compra from keplersc.kdicom where c1=sucursal_id and c2=num_inv order by c8,c9 desc limit 1;
			if found then
				if fecha_final <= current_date then
					diferencia_fechas := fecha_final::date - fecha_compra;
				else
					diferencia_fechas := current_date - fecha_compra;
				end if;
			
				if diferencia_fechas < 1200 then
				
					if tipo_inv = 'NUEVO' and diferencia_fechas >= num_dias_atrasados_nuevos then --TODO PASAR PARAMETRO EN UNA CONF: num_dias_atrasados_nuevos
						descuento_dias_atrasados_nuevos := descuento_dias_atrasados_nuevos + subtotal_compra;
					end if;
				
					if tipo_inv = 'USADO'  and diferencia_fechas >= num_dias_atrasados_seminuevos then --TODO PASAR PARAMETRO EN UNA CONF: num_dias_atrasados_seminuevos
						descuento_dias_atrasados_seminuevos := descuento_dias_atrasados_seminuevos + subtotal_compra;
					end if;
			
				end if;
				
			end if;
				
		end if;

		
	end loop;


	select c5 into csi_planta from keplersc.kdvcsi where c1=sucursal_id and c2=anio and c3=mes;
	if found then
		real_csi := csi_planta;	
	end if;

	--SUB CALCULA_ALCANCE_OBJETIVOS
	if esquema is not null and esquema <> '' then 
	
		--BONOS(b)
		b_primer_obj_entregas_nuevos := p_primer_obj_entregas_nuevos * utilidad_bruta_autos_nuevos_sin_pva/100;
		b_segundo_obj_entregas_nuevos := p_segundo_obj_entregas_nuevos * utilidad_bruta_autos_nuevos_sin_pva/100;
		b_obj_margen_utilidad  := p_obj_margen_utilidad * (utilidad_bruta_autos_nuevos_sin_pva +  utilidad_bruta_autos_seminuevos_sin_pva)/100;
		b_obj_share_financiera_1 := p_obj_share_financiera_1 * utilidad_bruta_autos_nuevos_sin_pva/100 ;
		b_obj_share_financiera_2 := p_obj_share_financiera_2 *  utilidad_bruta_autos_nuevos_sin_pva/100 ;
		b_obj_1_csi := p_obj_1_csi * utilidad_bruta_autos_nuevos_sin_pva/100 ;
		b_obj_2_csi  := p_obj_2_csi * utilidad_bruta_autos_nuevos_sin_pva/100 ;
		b_combinado := p_combinado * utilidad_bruta_autos_nuevos_sin_pva/100 ;
		b_obj_fact_nuevos := p_obj_fact_nuevos * utilidad_bruta_autos_nuevos_sin_pva/100 ;
		b_obj_tomas := p_obj_tomas * (utilidad_bruta_autos_nuevos_sin_pva +  utilidad_bruta_autos_seminuevos_sin_pva)/100;
		b_obj_venta_garantia_extendida := p_obj_venta_garantia_extendida  * utilidad_bruta_autos_nuevos_sin_pva/100 ;
		b_obj_entregas_trimestrales := p_obj_entregas_trimestrales * utilidad_bruta_autos_nuevos_sin_pva/100 ;
		b_obj_accesorios := p_obj_accesorios * utilidad_bruta_autos_nuevos_sin_pva/100 ;
		b_obj_seguros_contado := p_obj_seguros_contado * utilidad_bruta_autos_nuevos_sin_pva/100 ;
		b_combinado_seminuevos := p_combinado_seminuevos * utilidad_bruta_autos_seminuevos_sin_pva/100;
		b_facturacion_seminuevos := p_facturacion_seminuevos * utilidad_bruta_autos_seminuevos_sin_pva/100;
		b_primer_obj_entregas_seminuevos := p_primer_obj_entregas_seminuevos * utilidad_bruta_autos_seminuevos_sin_pva/100;
		b_segundo_obj_entregas_seminuevos := p_segundo_obj_entregas_seminuevos * utilidad_bruta_autos_seminuevos_sin_pva/100;
		b_primer_obj_financiera_seminuevos := p_primer_obj_financiera_seminuevos * utilidad_bruta_autos_seminuevos_sin_pva/100;
		b_segundo_obj_financiera_seminuevos := p_segundo_obj_financiera_seminuevos * utilidad_bruta_autos_seminuevos_sin_pva/100;
	
	
		--Calcula Comisiones ,c=comision b=bono
		if real_entregas_nuevos >= primer_obj_entregas_nuevos and real_entregas_nuevos > 0 then
			c_primer_obj_entregas_nuevos := b_primer_obj_entregas_nuevos;
		end if;
	
		xmlResultado := concat(xmlResultado,  format('<resultados><r0><desc>Entregas</desc><objetivo>%1$s</objetivo>
		<real>%2$s</real><porcentaje>%3$s</porcentaje><bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r0>',
		primer_obj_entregas_nuevos, real_entregas_nuevos, p_primer_obj_entregas_nuevos, b_primer_obj_entregas_nuevos, 0,  c_primer_obj_entregas_nuevos));

		if real_entregas_nuevos >= segundo_obj_entregas_nuevos and real_entregas_nuevos > 0 then
			c_segundo_obj_entregas_nuevos := b_segundo_obj_entregas_nuevos;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r1><desc>Entregas 2</desc><objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r1>',
		segundo_obj_entregas_nuevos, real_entregas_nuevos, p_segundo_obj_entregas_nuevos, b_segundo_obj_entregas_nuevos, 0,  c_segundo_obj_entregas_nuevos));
	
		if real_margen_utilidad >= obj_margen_utilidad and real_margen_utilidad > 0 then
			c_obj_margen_utilidad := b_obj_margen_utilidad;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r2><desc>Margen de utilidad</desc><objetivo>%1$s</objetivo><real>%2$s</real>
		<porcentaje>%3$s</porcentaje><bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r2>',
		obj_margen_utilidad, real_margen_utilidad, p_obj_margen_utilidad, b_obj_margen_utilidad, 0,  c_obj_margen_utilidad));
		
		if real_entregas_financiera_nuevos >= obj_entregas_financiera_1 and real_entregas_financiera_nuevos > 0 then
			c_obj_share_financiera_1 := b_obj_share_financiera_1;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r3><desc>Entregas Financiera 1</desc><objetivo>%1$s</objetivo><real>%2$s</real>
		<porcentaje>%3$s</porcentaje><bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r3>',
		obj_entregas_financiera_1, real_entregas_financiera_nuevos, p_obj_share_financiera_1, b_obj_share_financiera_1, 0,  c_obj_share_financiera_1));
	
		if real_entregas_financiera_nuevos >= obj_entregas_financiera_2 and real_entregas_financiera_nuevos > 0 then
			c_obj_share_financiera_2 := b_obj_share_financiera_2;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r4><desc>Entregas Financiera 2</desc><objetivo>%1$s</objetivo>
		<real>%2$s</real><porcentaje>%3$s</porcentaje><bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r4>',
		obj_entregas_financiera_2, real_entregas_financiera_nuevos, p_obj_share_financiera_2, b_obj_share_financiera_2, 0,  c_obj_share_financiera_2));
	
		if real_csi >= obj_1_csi and real_csi > 0 then
			c_obj_1_csi :=  b_obj_1_csi;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r5><desc>CSI 1</desc><objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r5>',
		obj_1_csi, real_csi, p_obj_1_csi, b_obj_1_csi, 0,  c_obj_1_csi));
	
		if real_csi >= obj_2_csi and real_csi > 0 then
			c_obj_2_csi :=  b_obj_2_csi;
		end if;
		
		xmlResultado := concat(xmlResultado, format('<r6><desc>CSI 2</desc><objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r6>',
		obj_2_csi, real_csi, p_obj_2_csi, b_obj_2_csi, 0,  c_obj_2_csi));
	
		descuento_total_nuevos := -(descuento_dias_atrasados_nuevos * p_descuento_unidades_atrasadas_nuevos/100);
	
		xmlResultado := concat(xmlResultado, format('<r7><desc>Descuento por unidades Nuevas (valor: %7$s) con mas de </desc><objetivo>%1$s</objetivo>
		<real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r7>',
		num_dias_atrasados_nuevos, 0, p_descuento_unidades_atrasadas_nuevos, 0, descuento_total_nuevos,  descuento_total_nuevos, descuento_dias_atrasados_nuevos));
	
		descuento_total_seminuevos := -(descuento_dias_atrasados_seminuevos * p_descuento_unidades_atrasadas_seminuevos/100);
		
		xmlResultado := concat(xmlResultado, format('<r8><desc>Descuento por unidades Seminuevas (valor: %7$s) con mas de </desc>
		<objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r8>',
		num_dias_atrasados_seminuevos, 0, p_descuento_unidades_atrasadas_seminuevos, 0, descuento_total_seminuevos,  descuento_total_seminuevos, descuento_dias_atrasados_seminuevos));
	
	
		if real_venta_unidades_nuevas >= obj_facturacion_autos_nuevos and real_venta_unidades_nuevas > 0 then
			c_obj_fact_nuevos := b_obj_fact_nuevos;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r9><desc>Objetivo por Venta de Unidades Nuevas</desc><objetivo>%1$s</objetivo>
		<real>%2$s</real><porcentaje>%3$s</porcentaje> <bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r9>',
		obj_facturacion_autos_nuevos, real_venta_unidades_nuevas, p_obj_fact_nuevos, b_obj_fact_nuevos, 0,  c_obj_fact_nuevos));
	
		if real_toma_unidades_seminuevas >= obj_toma_autos_seminuevos and real_toma_unidades_seminuevas > 0 then
			c_obj_tomas := b_obj_tomas;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r10><desc>Objetivo por Toma de Unidades Seminuevas</desc>
		<objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r10>',
		obj_toma_autos_seminuevos, real_toma_unidades_seminuevas, p_obj_tomas, b_obj_tomas, 0,  c_obj_tomas));
	
		if real_entregas_garantia_extendida >= obj_entregas_garantia_extendida and real_entregas_garantia_extendida > 0 then
			c_obj_venta_garantia_extendida := b_obj_venta_garantia_extendida;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r11><desc>Objetivo Venta de Garantia Extendida</desc>
		<objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r11>',
		obj_entregas_garantia_extendida, real_entregas_garantia_extendida, p_obj_venta_garantia_extendida,
		b_obj_venta_garantia_extendida, 0,  c_obj_venta_garantia_extendida));
	
		--Combinado
		if c_primer_obj_entregas_nuevos > 0 and c_obj_share_financiera_1 > 0 and 
		c_obj_margen_utilidad > 0 and c_obj_fact_nuevos > 0 and c_obj_tomas > 0 then 
			c_combinado :=	b_combinado;
		end if; 
	
		xmlResultado := concat(xmlResultado, format('<r12><desc>Combinado Ventas, Entregas, Tomas, Share Margen de Utilidad Nuevos</desc>
		<objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r12>',
		0, 0, p_combinado, b_combinado, 0,  c_combinado));
	
		if real_utilidad_bruta_accesorios >= obj_utilidad_bruta_accesorios and real_utilidad_bruta_accesorios > 0 then
			c_obj_accesorios :=  b_obj_accesorios;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r13><desc>Objetivo Utilidad Bruta de Accesorios</desc>
		<objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r13>',
		obj_utilidad_bruta_accesorios, real_utilidad_bruta_accesorios, p_obj_accesorios,b_obj_accesorios, 0,  c_obj_accesorios));
			
		if real_seguros_contado >= obj_seguros_contado and real_seguros_contado > 0 then
			c_obj_seguros_contado := b_obj_seguros_contado;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r14><desc>Objetivo Venta de Seguros de Contado</desc>
		<objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r14>',
		obj_seguros_contado, real_seguros_contado, p_obj_seguros_contado,b_obj_seguros_contado, 0,  c_obj_seguros_contado));
			
		--seminuevos
		if real_venta_unidades_seminuevas >= obj_facturacion_seminuevos and real_venta_unidades_seminuevas > 0 then
			c_facturacion_seminuevos := b_facturacion_seminuevos;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r15><desc>Objetivo por Venta de Unidades Seminuevas</desc>
		<objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r15>',
		obj_facturacion_seminuevos, real_venta_unidades_seminuevas, p_facturacion_seminuevos,b_facturacion_seminuevos, 0,  c_facturacion_seminuevos));
	
		if real_entregas_seminuevos >= primer_obj_entregas_seminuevos and real_entregas_seminuevos > 0 then
			c_primer_obj_entregas_seminuevos := b_primer_obj_entregas_seminuevos;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r16><desc>1er objetivo Entregas Seminuevos</desc>
		<objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r16>',
		primer_obj_entregas_seminuevos, real_entregas_seminuevos, p_primer_obj_entregas_seminuevos
		,b_primer_obj_entregas_seminuevos, 0,  c_primer_obj_entregas_seminuevos));
	
		if real_entregas_seminuevos >= segundo_obj_entregas_seminuevos and real_entregas_seminuevos > 0 then
			c_segundo_obj_entregas_seminuevos := b_segundo_obj_entregas_seminuevos;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r17><desc>2do objetivo Entregas Seminuevos</desc>
		<objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r17>',
		segundo_obj_entregas_seminuevos, real_entregas_seminuevos, p_segundo_obj_entregas_seminuevos
		,b_segundo_obj_entregas_seminuevos, 0,  c_segundo_obj_entregas_seminuevos));
	
		if real_entregas_financiera_seminuevos >= obj_entregas_financiera_1_seminuevos and real_entregas_financiera_seminuevos > 0 then
			c_primer_obj_financiera_seminuevos := b_primer_obj_financiera_seminuevos;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r18><desc>1er objetivo Financiera Seminuevo</desc>
		<objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r18>',
		obj_entregas_financiera_1_seminuevos, real_entregas_financiera_seminuevos, p_primer_obj_financiera_seminuevos
		,b_primer_obj_financiera_seminuevos, 0,  c_primer_obj_financiera_seminuevos));
			
		if real_entregas_financiera_seminuevos >= obj_entregas_financiera_2_seminuevos and real_entregas_financiera_seminuevos > 0 then
			c_segundo_obj_financiera_seminuevos := b_segundo_obj_financiera_seminuevos;
		end if;
	
		xmlResultado := concat(xmlResultado, format('<r19><desc>2do objetivo Financiera Seminuevos</desc>
		<objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r19>',
		obj_entregas_financiera_2_seminuevos, real_entregas_financiera_seminuevos, p_segundo_obj_financiera_seminuevos
		,b_segundo_obj_financiera_seminuevos, 0,  c_segundo_obj_financiera_seminuevos));
	
		if c_facturacion_seminuevos > 0 and c_primer_obj_entregas_seminuevos > 0 and 
		c_obj_margen_utilidad > 0 and c_primer_obj_financiera_seminuevos > 0 and c_obj_tomas > 0 then 
			c_combinado_seminuevos :=	b_combinado_seminuevos;
		end if; 
	
		xmlResultado := concat(xmlResultado, format('<r20><desc>Combinado Ventas, Entregas, Tomas, Share Margen de Utilidad Seminuevos</desc>
		<objetivo>%1$s</objetivo><real>%2$s</real><porcentaje>%3$s</porcentaje>
		<bono>%4$s</bono><descuento>%5$s</descuento><comision>%6$s</comision></r20>',
		0, 0, p_combinado_seminuevos, b_combinado_seminuevos, 0,  c_combinado_seminuevos));
	
		total_bonos := b_primer_obj_entregas_nuevos + b_segundo_obj_entregas_nuevos  + b_obj_margen_utilidad +
		b_obj_share_financiera_1 + b_obj_share_financiera_2 + b_obj_1_csi + b_obj_2_csi  + b_combinado + b_obj_fact_nuevos +
		b_obj_tomas + b_obj_venta_garantia_extendida + b_obj_entregas_trimestrales + b_obj_accesorios + b_obj_seguros_contado +
		b_combinado_seminuevos + b_facturacion_seminuevos + b_primer_obj_entregas_seminuevos + b_segundo_obj_entregas_seminuevos +
		b_primer_obj_financiera_seminuevos + b_segundo_obj_financiera_seminuevos;
	
		total_comisiones :=  c_primer_obj_entregas_nuevos + c_segundo_obj_entregas_nuevos  + c_obj_margen_utilidad +
		c_obj_share_financiera_1  + c_obj_share_financiera_2 + c_obj_1_csi + c_obj_2_csi  + c_combinado + c_obj_fact_nuevos +
		c_obj_tomas + c_obj_venta_garantia_extendida + c_obj_entregas_trimestrales + c_obj_accesorios + c_obj_seguros_contado +
		c_combinado_seminuevos + c_facturacion_seminuevos + c_primer_obj_entregas_seminuevos + c_segundo_obj_entregas_seminuevos +
		c_primer_obj_financiera_seminuevos + c_segundo_obj_financiera_seminuevos + descuento_total_nuevos + descuento_total_seminuevos;
		
	end if;


	contador_obj_extras := 20;

	--SUB CALCULA_OBJETIVOS_VARIABLES 
	for tipo_auto,desc_objetivo,porcentaje_comsion,objetivo_variable, resultado in select c6,c7,c8,c9,c10 from keplersc.kdvargv 
	where c1=sucursal_id and c2=esquema and c3=mes and c4=anio
	loop 
		
		if tipo_auto = 'N' then 
			bono_variable := porcentaje_comsion * utilidad_bruta_autos_nuevos_sin_pva/100;
		else 
			bono_variable := porcentaje_comsion * utilidad_bruta_autos_seminuevos_sin_pva/100;
		end if;
	
		comision_variable := 0;
		if resultado >= objetivo_variable and resultado > 0 then
			comision_variable := bono_variable;
		end if;
	
		contador_obj_extras := contador_obj_extras + 1;

		xmlResultado := concat(xmlResultado, format('<r%1$s><desc>%2$s</desc>
		<objetivo>%3$s</objetivo><real>%4$s</real><porcentaje>%5$s</porcentaje>
		<bono>%6$s</bono><descuento>%7$s</descuento><comision>%8$s</comision></r%1$s>',contador_obj_extras,
		desc_objetivo, objetivo_variable, resultado, porcentaje_comsion ,bono_variable, 0,  comision_variable));

		
		total_bonos := total_bonos + bono_variable;
		total_comisiones := total_comisiones + comision_variable;
		
	end loop;

	--SUB CALCULA_OBJETIVO_POR_LINEA
	for linea in select c1 from keplersc.kdivl 
	loop
		select c6,c7 into objetivo_linea, bono_linea from keplersc.kdbonolineacoaches 
		where c1=sucursal_id and c2=esquema and c3=linea and c4=anio and c5=mes and c7>0;
		if found then
			
			--recorre las versiones de esa linea 
			ventas_por_linea := 0;
			for clave_version in select c1 from keplersc.kdiv where c7=linea
			loop 
				

				for tipo_mov in select c10 from keplersc.kdcomismov 
				where c1=sucursal_id and c12=clave_version and c26=coach
				and c7 >= fecha_inicial and c7 <=fecha_final 
				loop 
		
					if tipo_mov = '0' then 
						ventas_por_linea := ventas_por_linea + 1;
					else
						ventas_por_linea := ventas_por_linea - 1;
					end if;
				
				end loop;
				
			end loop;
			
			total_bonos := total_bonos + bono_linea;
	
			comision_linea := 0;
			if ventas_por_linea >= objetivo_linea and ventas_por_linea > 0 then 
				comision_linea := bono_linea;
			end if;
		
			total_comisiones := total_comisiones + comision_linea;
		
			contador_obj_extras := contador_obj_extras + 1;

			xmlResultado := concat(xmlResultado, format('<r%1$s><desc>%2$s</desc>
			<objetivo>%3$s</objetivo><real>%4$s</real><porcentaje>%5$s</porcentaje>
			<bono>%6$s</bono><descuento>%7$s</descuento><comision>%8$s</comision></r%1$s>',contador_obj_extras,
			linea, objetivo_linea, ventas_por_linea, '' ,bono_linea, 0,  comision_linea));

		end if;
	
	end loop;

	if total_comisiones < 0 then
		total_comisiones := 0 ;
	end if;

	xmlResultado := concat(xmlResultado, format('</resultados><totales><total_bonos>%1$s</total_bonos>
	<total_comisiones>%2$s</total_comisiones></totales>',total_bonos , total_comisiones));
raise notice 'PASO 2 xmlResultado:%',xmlResultado;		
	return xmlResultado::xml;

exception
	when others then
		raise exception '%', 'Sin Resultados';	
	
end;
$function$
