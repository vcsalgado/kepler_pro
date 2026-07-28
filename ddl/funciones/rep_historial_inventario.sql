CREATE OR REPLACE FUNCTION keplersc.rep_historial_inventario(dataxml xml)
 RETURNS TABLE(datos_inv xml, datos_facturas_compra xml, datos_pedido xml, datos_facturas_venta xml, datos_facturas_pva xml, datos_notas_descuento xml, datos_notas_credito xml, datos_vales_salida xml, datos_operaciones_credito xml, datos_movimimientos_inv xml, datos_cargos_costo xml)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Reporte del historial de un inventario
--Autor: Luis Leal
--Fecha: 23/11/2022
--Bitacora de cambios
declare
	--Variables principales
	sucursal_id text = '';	
	inventario text = '';	
	serie text = '';

	--Variables generales Loops
	contador numeric;
	contador_2 numeric;
	folio text;
	tipo_mov text;
	partida numeric;
	fecha date;
	clave_cli text;
	nombre_cli text;
	calle_cli text;
	colonia_cli text; 
	poblacion_cli text;
	rfc_cli text;
	importe numeric;
	isan numeric;
	iva numeric;
	total numeric;
	xml_str text;
 	cargos_totales numeric = 0.00;
 	abonos_totales numeric = 0.00;
 	saldo_total numeric = 0.00;
	tipo text;
	genero text;
	naturaleza text;
	costo numeric;
	cargo numeric;
	abono numeric;


	--Variables loop 1
	numero_cdo numeric ;
	clave_prov text;
	nombre_prov text; 
	calle_prov text;
	colonia_prov text;
	poblacion_prov text; 
	rfc_prov text;
	costo_factura_compra text;
	hold_back text;

	--Variables loop 3
	gastos_adm numeric;
	accesorios_pva numeric;
	garantia_extendida_pva numeric;
	intereses_pva numeric;
	cobranza_pva numeric;

	--Variables loop 6
	factura text;
	cargos_xg numeric = 0.00;
	abonos_xg numeric = 0.00;
	estatus numeric;
	fecha_expedicion date;
	fecha_vencimiento date;
	saldo_vencido numeric = 0.00;
 	cargo_xe numeric = 0.00;
 	abono_xe numeric = 0.00;

	--Variables loop 7
	entrada_mov_inv text;
	salida_mov_inv text;

	--Variables loop 8
	tipo_costo text;
	suc text;

	--sql
	sql_datos_inv text = '';
	sql_pedido text = '';


begin

	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	inventario := (xpath('//document/inventario/text()', dataxml))[1];
	serie := (xpath('//document/serie/text()', dataxml))[1];

	--DATOS INVENTARIO
	if (substring(trim(inventario),8,1)='N') then
		sql_datos_inv := format('select inv.c3 as vehiculo, inv.c4 as vehiculo_desc,
		inv.c5 as serie, inv.c6 as motor, inv.c8 as transmision,inv.c9 as inventario_anterior, 
		inv.c10 as color_exterior, color_ext.c4 as color_exterior_desc, inv.c13 as clave_vehicular,
		inv.c11 as vestiduras, color_int.c4 as vestiduras_desc, inv.c15 as anio_modelo, 
		inv.c12 as eje_trasero, inv.c14 as rfv,inv.c17 as marca, marca.c2 as marca_desc,
 		iv.c54 as num_puertas, iv.c50 as num_cilindros,iv.c51 as num_pasajeros,
		inv.c18 as clase, clase.c2 as clase_desc, inv.c21 as tipo_v, inv.c26 as pedimento,
		inv.c27::date as fecha_pedimento, inv.c28 as lugar_pedimento, inv.c73 as monto_financiamiento,
		inv.c74 as interes_financiamiento, inv.c75 plazo_financiamiento, 
		inv.c77 as cobranza_financiamiento,inv.c78 as doctos_generados,
		inv.c80 as nombre_aval, inv.c81 as direccion_aval, inv.c82 as colonia_aval,
		inv.c83 as poblacion_aval,inv.c84 as rfc_aval from keplersc.kdinf as inv
		left outer join keplersc.kdice2 as color_ext on inv.c3=color_ext.c1 and inv.c10=color_ext.c3
		left outer join keplersc.kdice3 as color_int on inv.c3=color_int.c1 and inv.c11=color_int.c3 
		left outer join keplersc.kdmarca as marca on inv.c17=marca.c1
		left outer join keplersc.kdic as clase on inv.c18=clase.c1
		left outer join keplersc.kdiv as iv on inv.c3=iv.c1
		where inv.c1=%1$L and inv.c2=%2$L and inv.c5=%3$L',sucursal_id, inventario, serie );
	else 
		if substring(trim(inventario),8,1)='U' then
		sql_datos_inv := format('select inv.c3 as vehiculo, upper(inv.c4) as vehiculo_desc,
		inv.c5 as serie, inv.c6 as motor, inv.c8 as transmision,inv.c9 as inventario_anterior, 
		inv.c10 as color_exterior, color_ext.c4 as color_exterior_desc, inv.c13 as clave_vehicular,
		inv.c11 as vestiduras, color_int.c4 as vestiduras_desc, inv.c87 as anio_modelo, 
		inv.c12 as eje_trasero, inv.c14 as rfv,'''' as marca, upper(inv.c85) as marca_desc, 
		inv.c93 as num_puertas, inv.c92 as num_cilindros,inv.c91 as num_pasajeros,
		inv.c18 as clase, clase.c2 as clase_desc, inv.c21 as tipo_v, inv.c26 as pedimento,
		inv.c27::date as fecha_pedimento, inv.c28 as lugar_pedimento, inv.c73 as monto_financiamiento,
		inv.c74 as interes_financiamiento, inv.c75 plazo_financiamiento, 
		inv.c77 as cobranza_financiamiento,inv.c78 as doctos_generados,
		inv.c80 as nombre_aval, inv.c81 as direccion_aval, inv.c82 as colonia_aval,
		inv.c83 as poblacion_aval,inv.c84 as rfc_aval from keplersc.kdinf as inv
		left outer join keplersc.kdice2 as color_ext on inv.c3=color_ext.c1 and inv.c10=color_ext.c3
		left outer join keplersc.kdice3 as color_int on inv.c3=color_int.c1 and inv.c11=color_int.c3 
		left outer join keplersc.kdmarca as marca on inv.c17=marca.c1
		left outer join keplersc.kdic as clase on inv.c18=clase.c1
		where inv.c1=%1$L and inv.c2=%2$L and inv.c5=%3$L',sucursal_id, inventario, serie );

		end if;
	end if;
raise notice '%',sql_datos_inv;
	select query_to_xml(sql_datos_inv, false, true, '' ) :: xml into datos_inv;
	
	--DATOS FACTURAS COMPRA
	for partida, folio, tipo_mov, fecha,numero_cdo, clave_prov, nombre_prov, calle_prov,
	colonia_prov, poblacion_prov, rfc_prov, costo_factura_compra, iva, hold_back, importe
	in select com.c3 , com.c4 || com.c5 || lpad(com.c6::text, 2, '0')  || lpad(com.c7::text, 3, '0')
	|| '-' || com.c8 , case when com.c12=0 then 'ALTA' else 'BAJA' end, com.c9 , com.c11 , mov.c10 ,  
	mov.c32, mov.c33,  mov.c34, mov.c35, mov.c22, com.c31, com.c32,  com.c33 , com.c37 from keplersc.kdicom as com  
	inner join keplersc.kdm1 as mov on com.c1=mov.c1 and com.c4=mov.c2  and com.c5=mov.c3 and com.c6=mov.c4 
	and com.c7=mov.c5 and com.c8=mov.c6 where com.c1=sucursal_id and com.c2=inventario order by com.c3
	loop
			
		datos_facturas_compra := concat(datos_facturas_compra, format('
		<r%1$s>
			<folio_compra>%2$s</folio_compra>
			<tipo_mov_compra>%3$s</tipo_mov_compra>
			<fecha_factura_compra>%4$s</fecha_factura_compra>
			<numero_cdo>%5$s</numero_cdo>
			<clave_prov>%6$s</clave_prov>
			<nombre_prov>%7$s</nombre_prov>
			<calle_prov>%8$s</calle_prov>
			<colonia_prov>%9$s</colonia_prov>
			<poblacion_prov>%10$s</poblacion_prov>
			<rfc_prov>%11$s</rfc_prov>
			<costo_factura_compra>%12$s</costo_factura_compra>
			<iva_factura_compra>%13$s</iva_factura_compra>
			<hold_back>%14$s</hold_back>
			<importe_compra>%15$s</importe_compra>
		</r%1$s>', partida, folio, tipo_mov, fecha,numero_cdo, 
		clave_prov, replace(nombre_prov,'&',''), calle_prov,colonia_prov, poblacion_prov, rfc_prov, 
		costo_factura_compra, iva, hold_back, importe));
	
	end loop;


	--DATOS PEDIDO
	sql_pedido := format('select ped.c3 || ped.c4 || lpad(ped.c5::text, 2, ''0'')  ||  lpad(ped.c6::text, 3, ''0'')||
	 ''-'' || ped.c7 as folio_pedido, ped.c8::date as fecha_pedido, ped.c10 as clave_vendedor , ven.c3 as nombre_vendedor , 
	ped.c11 as tipo_operacion, op.c2 as tipo_operacion_desc , mov.c99 as impresion, mov.c10 as clave_cli , 
	mov.c32 as nombre_cli, mov.c33 as calle_cli, mov.c34 as colonia_cli, mov.c35 as poblacion_cli, mov.c22 as rfc_cli,
	ped.c15 as subsidio, ped.c16 as bonificacion, ped.c18 as accesorios, ped.c19 as garantia_extendida,
	ped.c20 as seguro from keplersc.kdpedido as ped inner join keplersc.kdm1 as mov on ped.c1=mov.c1 
	and ped.c3=mov.c2  and ped.c4=mov.c3 and ped.c5=mov.c4 and ped.c6=mov.c5 and ped.c7=mov.c6 left outer join keplersc.kduv as ven 
	on ped.c1=ven.c1 and ped.c10=ven.c2 left outer join keplersc.kdtop as op on ped.c11=op.c1 
	where ped.c1=%1$L and ped.c2=%2$L',sucursal_id,  inventario);
	select query_to_xml(sql_pedido, false, true, '' ) :: xml into datos_pedido;



	--DATOS FACTURAS VENTA
	for partida, folio, tipo_mov, fecha, clave_cli, nombre_cli, calle_cli, colonia_cli, 
	poblacion_cli, rfc_cli, importe, iva, isan
	in select ven.c3, ven.c4 || ven.c5 || lpad(ven.c6::text, 2, '0')  
	|| lpad(ven.c7::text, 3, '0') || '-' || ven.c8 , case when ven.c10=0 then 'ALTA' else 'BAJA' end ,
	ven.c9, mov.c10 , mov.c32,  mov.c33, mov.c34,  mov.c35, mov.c22, ven.c26 , ven.c25 ,ven.c24
	from keplersc.kdventas as ven inner join keplersc.kdm1 as mov on ven.c1=mov.c1 and ven.c4=mov.c2  
	and ven.c5=mov.c3 and ven.c6=mov.c4 and ven.c7=mov.c5 and ven.c8=mov.c6 where ven.c1=sucursal_id 
	and ven.c2=inventario
	loop 
		
		datos_facturas_venta:= concat(datos_facturas_venta, format('
		<r%1$s>
			<folio_factura>%2$s</folio_factura>
			<tipo_mov_factura>%3$s</tipo_mov_factura>
			<fecha_factura>%4$s</fecha_factura>
			<clave_cli_factura>%5$s</clave_cli_factura>
			<nombre_cli_factura>%6$s</nombre_cli_factura>
			<calle_cli_factura>%7$s</calle_cli_factura>
			<colonia_cli_factura>%8$s</colonia_cli_factura>
			<poblacion_cli_factura>%9$s</poblacion_cli_factura>
			<rfc_cli_factura>%10$s</rfc_cli_factura>
			<importe_factura>%11$s</importe_factura>
			<isan_factura>%12$s</isan_factura>
			<iva_factura>%13$s</iva_factura>
			<total>%14$s</total>
		</r%1$s>', partida, folio, tipo_mov, fecha,
		clave_cli, replace(nombre_cli,'&',''), calle_cli, colonia_cli, 
		poblacion_cli, rfc_cli, (importe -iva-isan), 
		isan,iva, importe));
		
	end loop;



	--DATOS FACTURAS PVA
	for partida, folio, tipo_mov ,fecha ,clave_cli, nombre_cli, calle_cli, 
	colonia_cli, poblacion_cli, rfc_cli,gastos_adm,accesorios_pva,garantia_extendida_pva, intereses_pva,
	cobranza_pva, iva, total in select pva.c3, pva.c4 || pva.c5 || lpad(pva.c6::text, 2, '0')  
	|| lpad(pva.c7::text, 3, '0') || '-' || pva.c8 ,case when pva.c10=0 then 'ALTA' else 'BAJA' end ,pva.c9, 
	mov.c10 , mov.c32,  mov.c33, mov.c34,  mov.c35, mov.c22, pva.c24,pva.c25,pva.c26, pva.c27, pva.c28, pva.c29, pva.c30
	from keplersc.kdipva as pva inner join keplersc.kdm1 as mov on pva.c1=mov.c1 and pva.c4=mov.c2  
	and pva.c5=mov.c3 and pva.c6=mov.c4 and pva.c7=mov.c5 and pva.c8=mov.c6 where pva.c1=sucursal_id and pva.c2=inventario
	loop 
		
		
		datos_facturas_pva:= concat(datos_facturas_pva, format('
		<r%1$s>
			<folio_factura_pva>%2$s</folio_factura_pva>
			<tipo_mov_factura_pva>%3$s</tipo_mov_factura_pva>
			<fecha_factura_pva>%4$s</fecha_factura_pva>
			<clave_cli_pva>%5$s</clave_cli_pva>
			<nombre_cli_pva>%6$s</nombre_cli_pva>
			<calle_cli_pva>%7$s</calle_cli_pva>
			<colonia_cli_pva>%8$s</colonia_cli_pva>
			<poblacion_cli_pva>%9$s</poblacion_cli_pva>
			<rfc_cli_pva>%10$s</rfc_cli_pva>
			<gastos_adm>%11$s</gastos_adm>
			<accesorios_pva>%12$s</accesorios_pva>
			<garantia_extendida_pva>%13$s</garantia_extendida_pva>
			<intereses_pva>%14$s</intereses_pva>
			<cobranza_pva>%15$s</cobranza_pva>
			<iva_pva>%16$s</iva_pva>
			<total_pva>%17$s</total_pva>
		</r%1$s>', partida, folio, tipo_mov ,fecha,
		clave_cli, replace(nombre_cli,'&',''), calle_cli, colonia_cli, poblacion_cli,
		rfc_cli,gastos_adm,accesorios_pva,garantia_extendida_pva, intereses_pva,
		cobranza_pva, iva, total));
		
	end loop;

	contador = 0;
	--DATOS NOTAS DESCUENTO 
	for folio, fecha,clave_cli, nombre_cli, calle_cli, colonia_cli, poblacion_cli, rfc_cli, iva, total
	in select  dsc.c3 || dsc.c4 || lpad(dsc.c5::text, 2, '0')  || lpad(dsc.c6::text, 3, '0')
	|| '-' || dsc.c7, dsc.c8, mov.c10 , mov.c32,  mov.c33, mov.c34,  mov.c35, mov.c22, dsc.c9, dsc.c10
	from keplersc.kdncred as dsc inner join keplersc.kdm1 as mov on dsc.c1=mov.c1 and dsc.c3=mov.c2 
	and dsc.c4=mov.c3 and dsc.c5=mov.c4 and dsc.c6=mov.c5 and dsc.c7=mov.c6 
	where dsc.c1=sucursal_id and dsc.c2=inventario 
	loop 
		
		contador :=  contador + 1;
		datos_notas_descuento := concat(datos_notas_descuento, format('
		<r%1$s>
			<folio_nota_desc>%2$s</folio_nota_desc>
			<fecha_nota_desc>%3$s</fecha_nota_desc>
			<clave_cli_nota_desc>%4$s</clave_cli_nota_desc>
			<nombre_cli_nota_desc>%5$s</nombre_cli_nota_desc>
			<calle_cli_nota_desc>%6$s</calle_cli_nota_desc>
			<colonia_cli_nota_desc>%7$s</colonia_cli_nota_desc>
			<poblacion_cli_nota_desc>%8$s</poblacion_cli_nota_desc>
			<rfc_cli_nota_desc>%9$s</rfc_cli_nota_desc>
			<subtotal_nota_desc>%10$s</subtotal_nota_desc>
			<iva_nota_desc>%11$s</iva_nota_desc>
			<total_nota_desc>%12$s</total_nota_desc>
		</r%1$s>', contador, folio, fecha,clave_cli, replace(nombre_cli,'&',''), calle_cli,
		colonia_cli, poblacion_cli, rfc_cli, total-iva, iva, total));
		
	end loop;



	contador = 0;
	--DATOS NOTAS DE CREDITO 
	for folio, fecha,clave_cli, nombre_cli, calle_cli, colonia_cli, poblacion_cli, rfc_cli, isan, iva, total
	in select  ncred.c3 || ncred.c4 || lpad(ncred.c5::text, 2, '0')  || lpad(ncred.c6::text, 3, '0')
	|| '-' || ncred.c7, ncred.c8, mov.c10 , mov.c32,  mov.c33, mov.c34,  mov.c35, mov.c22, ncred.c9, ncred.c10, ncred.c11
	from keplersc.kdnotacred as ncred inner join keplersc.kdm1 as mov on ncred.c1=mov.c1 and ncred.c3=mov.c2 
	and ncred.c4=mov.c3 and ncred.c5=mov.c4 and ncred.c6=mov.c5 and ncred.c7=mov.c6 
	where ncred.c1=sucursal_id and ncred.c2=inventario 
	loop 
		
		contador :=  contador + 1;
		datos_notas_credito := concat(datos_notas_credito, format('
		<r%1$s>
			<folio_nota_cred>%2$s</folio_nota_cred>
			<fecha_nota_cred>%3$s</fecha_nota_cred>
			<clave_cli_nota_cred>%4$s</clave_cli_nota_cred>
			<nombre_cli_nota_cred>%5$s</nombre_cli_nota_cred>
			<calle_cli_nota_cred>%6$s</calle_cli_nota_cred>
			<colonia_cli_nota_cred>%7$s</colonia_cli_nota_cred>
			<poblacion_cli_nota_cred>%8$s</poblacion_cli_nota_cred>
			<rfc_cli_nota_cred>%9$s</rfc_cli_nota_cred>
			<importe_nota_cred>%10$s</importe_nota_cred>
			<isan_nota_cred>%11$s</isan_nota_cred>
			<iva_nota_cred>%12$s</iva_nota_cred>
			<total_nota_cred>%13$s</total_nota_cred>
		</r%1$s>', contador, folio, fecha,clave_cli, replace(nombre_cli,'&',''), calle_cli,
		colonia_cli, poblacion_cli, rfc_cli, total-iva-isan,isan, iva, total));
		
	end loop;
	

	contador = 0;
	--DATOS VALES DE SALIDA 
	for folio, tipo_mov, fecha in select  c2 || c3 || lpad(c4::text, 2, '0')  || lpad(c5::text, 3, '0') || '-' || c6, 
	case when c10='0' then 'ALTA' else 'BAJA' end,c7 from keplersc.kdcomismov where c1=sucursal_id and c8=inventario 
	loop 
		
		contador :=  contador + 1;
		datos_vales_salida:= concat(datos_vales_salida, format('
		<r%1$s>
			<folio_vale_salida>%2$s</folio_vale_salida>
			<tipo_mov_vale_salida>%3$s</tipo_mov_vale_salida>
			<fecha_vale_salida>%4$s</fecha_vale_salida>
		</r%1$s>', 
		contador, folio, tipo_mov, fecha));
		
	end loop;


	contador = 0; xml_str = '';
	--DATOS OPERACIONES DE CREDITO
	for clave_cli, factura, partida, cargos_xg, abonos_xg , estatus, fecha_vencimiento 
	in select xg.c3,xg.c4,xg.c5,xg.c6,xg.c7,xg.c10,xg.c12 from keplersc.kdventas as ven 
	inner join keplersc.kduxg as xg on ven.c1=xg.c1 and ven.c4=xg.c2 and ven.c11=xg.c3 
	and ven.c8=xg.c4 where ven.c1=sucursal_id and ven.c2=inventario and ven.c4='U' and ven.c10=0
	loop 
	
		if estatus = 0 and fecha_vencimiento < current_date then 
			saldo_vencido := cargos_xg - abonos_xg;
		end if;
	
	
		contador_2 := 0; xml_str = '';
		for folio, tipo ,naturaleza, fecha_expedicion, fecha_vencimiento, importe  in select xe.c5 || xe.c6 || 
		lpad(xe.c7::text, 2, '0') || lpad(xe.c8::text, 3, '0') || '-' || xe.c9, mm.c5, xe.c6, xe.c11, xe.c12, xe.c13
		from keplersc.kduxe as xe inner join keplersc.kdmm as mm on xe.c1=mm.col_sucursal and xe.c5=mm.c1 and xe.c6=mm.c2 and xe.c7=mm.c3 and xe.c8=mm.c4
		where xe.c1=sucursal_id and xe.c2=clave_cli and xe.c3=factura and xe.c4=partida order by xe.c11
		loop 
			
			
			cargo_xe := 0.00 ; abono_xe := 0.00;
			if naturaleza = 'D' then 
				cargo_xe := importe;
				cargos_totales := cargos_totales + cargo_xe;
				saldo_total := saldo_total + cargo_xe;
			else 
				abono_xe := importe;
				abonos_totales := abonos_totales + abono_xe;
				saldo_total := saldo_total - abono_xe;
			end if;
		
			contador_2 :=  contador_2 + 1;
			xml_str := concat(xml_str, format('
			<r%1$s>
				<folio_xe_ven>%2$s</folio_xe_ven>
				<tipo_xe_ven>%3$s</tipo_xe_ven>
				<fecha_expedicion_xe_ven>%4$s</fecha_expedicion_xe_ven>				
				<fecha_vencimiento_xe_ven>%5$s</fecha_vencimiento_xe_ven>
				<cargo_xe_ven>%6$s</cargo_xe_ven>
				<abono_xe_ven>%7$s</abono_xe_ven>
				<saldo_xe_ven>%8$s</saldo_xe_ven>
			</r%1$s>', 
			contador_2 , folio, tipo , fecha_expedicion, fecha_vencimiento, cargo_xe, abono_xe, saldo_total));
			
		end loop;
	
		contador :=  contador + 1;
		datos_operaciones_credito := concat(datos_operaciones_credito, format('
		<r%1$s>
			<movimientos_xe_ven>%2$s</movimientos_xe_ven>
			<cargos_totales_xe_ven>%3$s</cargos_totales_xe_ven>
			<abonos_totales_xe_ven>%4$s</abonos_totales_xe_ven>
			<saldo_total_xe_ven>%5$s</saldo_total_xe_ven>
			<saldo_vencido_xe_ven>%6$s</saldo_vencido_xe_ven>
		</r%1$s>', contador, xml_str, cargos_totales, abonos_totales, saldo_total, saldo_vencido));
	
	end loop;

	

	contador = 0;
	--MOVIMIENTOS DEL INVENTARIO 
	for folio, tipo, fecha, costo, tipo_mov in select  inv.c5 || inv.c6 || lpad(inv.c7::text, 2, '0')  || lpad(inv.c8::text, 3, '0') || '-' || inv.c9, 
	mm.c5,inv.c10, inv.c11, inv.c4 from keplersc.kdeinv as inv
	left outer join keplersc.kdmm as mm on inv.c1=mm.col_sucursal and inv.c5=mm.c1 and inv.c6=mm.c2 and inv.c7=mm.c3 and inv.c8=mm.c4
	where inv.c1=sucursal_id and inv.c2=inventario 
	loop 
		
		if tipo_mov = '0' then 
			entrada_mov_inv :=  costo;
			salida_mov_inv :=  '';

		else
			salida_mov_inv :=  costo;
			entrada_mov_inv :=  '';
		end if;
		
		contador :=  contador + 1;
		datos_movimimientos_inv:= concat(datos_movimimientos_inv, format('
		<r%1$s>
			<folio_mov_inv>%2$s</folio_mov_inv>
			<tipo_mov_inv>%3$s</tipo_mov_inv>
			<fecha_mov_inv>%4$s</fecha_mov_inv>
			<entrada_mov_inv>%5$s</entrada_mov_inv>
			<salida_mov_inv>%6$s</salida_mov_inv>
		</r%1$s>', 
		contador, folio, tipo, fecha, entrada_mov_inv, salida_mov_inv));
		
	end loop;


	contador = 0;  cargos_totales = 0; abonos_totales = 0; saldo_total = 0; xml_str = '';
	--CARGOS AL COSTO  
	for folio , tipo, fecha, tipo_costo, genero, naturaleza, costo  in select cst.c2 || cst.c3 || lpad(cst.c4::text, 2, '0')  
	|| lpad(cst.c5::text, 3, '0') || '-' || cst.c6, mm.c5, mov.c9, case when cst.c9 ='A' then 'ACCESORIOS' else 'COSTO DE UNIDAD' end,
	cst.c2, cst.c3, cst.c10 from keplersc.kdsunicosto as cst left outer join keplersc.kdmm as mm on cst.c1=mm.col_sucursal and cst.c2=mm.c1 and cst.c3=mm.c2 
	and cst.c4=mm.c3 and cst.c5=mm.c4 left outer join keplersc.kdm1 as mov on cst.c1=mov.c1 and cst.c2=mov.c2 
	and cst.c3=mov.c3 and cst.c4=mov.c4 and cst.c5=mov.c5 and cst.c6=mov.c6 where cst.c7=sucursal_id and cst.c8=inventario order by cst.c1, mov.c9 
	loop 
				
		cargo := 0; abono := 0;
		if (genero = 'U' and naturaleza = 'D') or (genero = 'X' and naturaleza = 'A') then 
		cargo := costo;
		cargos_totales := cargos_totales + 	cargo;
		saldo_total := saldo_total + cargo;
		end if;
	
		if (genero = 'U' and naturaleza = 'A') or (genero = 'X' and naturaleza = 'D') then 
		abono := costo;
		abonos_totales := abonos_totales + 	abono;
		saldo_total := saldo_total - abono;
		end if;
		
		contador :=  contador + 1;
		xml_str:= concat(xml_str, format('
		<r%1$s>
			<folio_cc>%2$s</folio_cc>
			<tipo_cc>%3$s</tipo_cc>
			<fecha_cc>%4$s</fecha_cc>
			<cargo_cc>%5$s</cargo_cc>
			<abono_cc>%6$s</abono_cc>
			<saldo_cc>%7$s</saldo_cc>
			<tipo_costo_cc>%8$s</tipo_costo_cc>
		</r%1$s>', 
		contador,folio, tipo, fecha, cargo, abono, saldo_total, tipo_costo));
		
	end loop;

	if xml_str <> '' then
		datos_cargos_costo :=  format('
			<cargos_al_costo>%1$s</cargos_al_costo>
			<cargos_totales_cc>%2$s</cargos_totales_cc>
			<abonos_totales_cc>%3$s</abonos_totales_cc>
			<saldo_total_cc>%4$s</saldo_total_cc>
		', xml_str, cargos_totales, abonos_totales, saldo_total);
	end if;
		
	return query
	select datos_inv, datos_facturas_compra, datos_pedido, datos_facturas_venta, datos_facturas_pva, datos_notas_descuento, 
	datos_notas_credito, datos_vales_salida,datos_operaciones_credito, datos_movimimientos_inv, datos_cargos_costo;

exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
