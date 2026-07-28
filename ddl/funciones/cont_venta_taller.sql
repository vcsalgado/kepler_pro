CREATE OR REPLACE FUNCTION keplersc.cont_venta_taller(xmlkdm1 xml, xmlkdmm xml, dato text)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Obtiene información de cuentas y montos de 
--Autor: Miriam Santana
--Fecha: 25/Oct/22
--Bitacora de cambios

	--Variables de definicion de documento
	sucursal_id text = '';
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	folio text;
	tipo_orden text;
	num_orden text;
	fecha_operacion text;
	cve_cteprov text;

	--Variables de uso general 
	tipo_poliza text;
	anio_en_curso text;
	tipo_asientoA text;
	tipo_asientoC text;
	cuenta_mo text;
	cuenta_refacc text;
	cuenta_tots text;
	cuenta_cargos text;
	cuenta_costo_refacc text;
	cuenta_costo_tots text;
	cuenta_inv_refacc text;
	cuenta_puente_tots text;

	costo_refacc decimal=0;
	costo_refacc_x decimal=0;
	costo_cargos decimal=0;
	subt_tots decimal=0;
	subt_tots_x decimal=0;
	costo_horas decimal=0;
	costo_horas_x decimal=0;
	importe_refacc decimal=0;
	importe_refacc_x decimal=0;
	precio_ctetot decimal=0;
	precio_ctetot_x decimal=0;
	precio_cargos decimal=0;
	precio_cargos_x decimal=0;

	costo_refacc_pto decimal=0;
	costo_refacc_x_pto decimal=0;
	costo_cargos_pto decimal=0;
	subt_tots_pto decimal=0;
	subt_tots_x_pto decimal=0;
	costo_horas_pto decimal=0;
	costo_horas_x_pto decimal=0;
	importe_refacc_pto decimal=0;
	importe_refacc_x_pto decimal=0;
	precio_ctetot_pto decimal=0;
	precio_ctetot_x_pto decimal=0;
	precio_cargos_pto decimal=0;
	precio_cargos_x_pto decimal=0;

	mano_obra_fac text;
	refacciones_fac text;
	tots_fac text;
	cargos_fac text;
	total_mano_obra decimal=0;
	total_refacc decimal=0;
	total_tots decimal=0;
	total_cargos decimal=0;
	total_trabajos decimal=0;
	desc_partida text = '';
	desc_cuenta text = '';
	total_taller decimal=0;
	total_trabajos_fact decimal=0;
	tipo_trabajo text;
	tabla_polizas text;
	nPartida int = 0;
	error text = '0';
	expSql text;
	strValor text;
	rec record;
	recTipOrden record;
	strCuentaSist text='Cuenta creada por el sistema';
	--arrTipOrden array['S','F','H','G','I','Q','R','P']; 
	arrTipOrden text[]; 
	tmpXml xml;
	
	--Variables de retorno
	xmlPartidas text='';
	xmlPoliza text='';

begin
	sucursal_id := (xpath('//row/c1/text()',xmlKDM1))[1];
	genero := (xpath('//row/c2/text()',xmlKDM1))[1];
	naturaleza := (xpath('//row/c3/text()',xmlKDM1))[1];
	grupo := (xpath('//row/c4/text()',xmlKDM1))[1];
	tipo := (xpath('//row/c5/text()',xmlKDM1))[1];
	fecha_operacion := (xpath('//row/c9/text()',xmlKDM1))[1];
	tipo_orden := (xpath('//row/c121/text()',xmlKDM1))[1];
	num_orden := (xpath('//row/c122/text()',xmlKDM1))[1];
	mano_obra_fac := coalesce((xpath('//row/c51/text()',xmlKDM1))[1]::text,'0')::text;
	refacciones_fac := coalesce((xpath('//row/c52/text()',xmlKDM1))[1]::text,'0')::text;
	tots_fac := coalesce((xpath('//row/c53/text()',xmlKDM1))[1]::text,'0')::text;
	cargos_fac := coalesce((xpath('//row/c54/text()',xmlKDM1))[1]::text,'0')::text;
	cve_cteprov := (xpath('//row/c10/text()',xmlKDM1))[1];
	arrTipOrden := array['S','F','H','G','I','Q','R','P']; 

	if naturaleza = 'D' then
		tipo_asientoA := 'A';
		tipo_asientoC := 'C';
	else
		tipo_asientoA := 'C';
		tipo_asientoC := 'A';
	end if;
	
	anio_en_curso := substring(fecha_operacion,3,2);
	tabla_polizas := 'keplersc.kdc1' || anio_en_curso;
--raise notice 'tabla_polizas:%',tabla_polizas;
--raise notice 'tipo_orden:%',tipo_orden;
--raise notice 'num_orden:%',num_orden;
--raise notice 'sucursal_id:%',sucursal_id;
--raise notice 'mano_obra_fac:%',mano_obra_fac;
--raise notice 'refacciones_fac:%',refacciones_fac;
--raise notice 'tots_fac:%',tots_fac;
--raise notice 'cargos_fac:%',cargos_fac;

	select left(c3,40) 
		into desc_partida 
		from keplersc.kdud 
		where c2=cve_cteprov;
	desc_partida:=replace(desc_partida,'amp;','');	
	desc_partida:=replace(desc_partida,'&','&amp;');
-- raise notice 'desc_poartida: %',	desc_partida;

--FGHILPQRST		cuentas para tipos de orden en tabla kdtallcont, es por tipo de punto
 
	for i in array_lower(arrTipOrden,1) .. array_upper(arrTipOrden,1)
	loop
		--raise notice 'valor de arrTipOrden[i]; %',arrTipOrden[i];
		costo_horas:=0;	costo_horas_x:=0; costo_horas_pto:=0; costo_horas_x_pto:=0;
		importe_refacc:=0; importe_refacc_x:=0; costo_refacc_x:=0; importe_refacc_pto:=0; importe_refacc_x_pto:=0; costo_refacc_x_pto:=0;
		precio_ctetot:=0; precio_ctetot_x :=0; subt_tots_x:=0; precio_ctetot_pto:=0; precio_ctetot_x_pto:=0; subt_tots_x_pto:=0;
		precio_cargos:=0; precio_cargos_x:=0; precio_cargos_pto:=0; precio_cargos_x_pto:=0;
		total_mano_obra:=0; total_refacc:=0; total_tots:=0; total_cargos:=0;
		total_trabajos:=0;
		select c5,c6,c7,c8,c11,c12,c16,c17 
			into cuenta_mo,cuenta_refacc,cuenta_tots,cuenta_cargos,cuenta_costo_refacc,
			cuenta_costo_tots,cuenta_inv_refacc,cuenta_puente_tots
			from keplersc.kdtallcont 
			where c1=arrTipOrden[i] and c2=sucursal_id and c3=anio_en_curso;
--raise notice '% % % % % % % %',cuenta_mo,cuenta_refacc,cuenta_tots,cuenta_cargos,cuenta_costo_refacc,
--			cuenta_costo_tots,cuenta_inv_refacc,cuenta_puente_tots;
		if found then
			for rec in select * from keplersc.kdpun
					where c1=sucursal_id  and c2=tipo_orden and c3=num_orden
			loop
				--HORAS
				select coalesce(sum(c8*c14),0) into costo_horas_pto 
					from keplersc.kdhoras 
					where c1=sucursal_id and c2=tipo_orden and c3=num_orden and c4=rec.c4;
				costo_horas:=coalesce(costo_horas,0)+coalesce(costo_horas_pto,0);
				if rec.c6=arrTipOrden[i] then
					select coalesce(sum(c8*c14),0) into costo_horas_x_pto
						from keplersc.kdhoras 
						where c1=sucursal_id and c2=tipo_orden and c3=num_orden and c4=rec.c4;
					costo_horas_x:=coalesce(costo_horas_x,0) + coalesce(costo_horas_x_pto,0);
				
				end if;
	--raise notice 'punto%',rec.c4;
	--raise notice 'costo_horaspto:%', costo_horas_pto;
	--raise notice 'costo_horas:%', costo_horas;
	--raise notice 'costo_horas_xpto:%', costo_horas_x_pto;
	--raise notice 'costo_horas_x:%', costo_horas_x;
				--REFACCIONES
				select coalesce(sum(c16),0) into importe_refacc_pto
					from keplersc.kdref 
					where c1=sucursal_id and c2=tipo_orden and c3=num_orden and c4=rec.c4;
				importe_refacc:=coalesce(importe_refacc,0) + coalesce(importe_refacc_pto,0);
				if rec.c6=arrTipOrden[i] then
					select coalesce(sum(c16),0),coalesce(sum(c19),0) into importe_refacc_x_pto,costo_refacc_x_pto
						from keplersc.kdref 
						where c1=sucursal_id and c2=tipo_orden and c3=num_orden and c4=rec.c4;
					importe_refacc_x:=coalesce(importe_refacc_x,0) + coalesce(importe_refacc_x_pto,0);
					costo_refacc_x:=coalesce(costo_refacc_x,0) + coalesce(costo_refacc_x_pto,0);
				end if;
	--raise notice 'importerefaccpto:%', importe_refacc_pto;
	--raise notice 'importerefacc:%', importe_refacc;
	--raise notice 'importerefacc_xpto:%', importe_refacc_x_pto;
	--raise notice 'importerefacc_x:%', importe_refacc_x;
	--raise notice 'costorefacc_xpto:%', costo_refacc_x_pto;
	--raise notice 'costorefacc_x:%', costo_refacc_x;
				--TOTS
				select coalesce(sum(c16),0) into precio_ctetot_pto 
					from keplersc.kdtot 
					where c1=sucursal_id and c2=tipo_orden and c3=num_orden and c4=rec.c4;
				precio_ctetot:=coalesce(precio_ctetot,0) + coalesce(precio_ctetot_pto,0);
				if rec.c6=arrTipOrden[i] then
					select coalesce(sum(c16),0),coalesce(sum(c13),0)-coalesce(sum(c12),0) into precio_ctetot_x_pto,subt_tots_x_pto  
						from keplersc.kdtot 
						where c1=sucursal_id and c2=tipo_orden and c3=num_orden and c4=rec.c4;
					precio_ctetot_x := coalesce(precio_ctetot_x,0) + coalesce(precio_ctetot_x_pto,0);
					subt_tots_x := coalesce(subt_tots_x,0) + coalesce(subt_tots_x_pto,0);
				end if;
	--raise notice 'precio_totspto:%', precio_ctetot_pto;
	--raise notice 'precio_tots:%', precio_ctetot;
	--raise notice 'costo_tots_Xpto:%', precio_ctetot_x_pto;
	--raise notice 'costo_tots_X:%', precio_ctetot_x;
	--raise notice 'subt_tots_Xpto:%', subt_tots_x_pto;
	--raise notice 'subt_tots_X:%', subt_tots_x;
				--CARGOS			
				select coalesce(sum(c10),0) into precio_cargos_pto
					from keplersc.kdcar 
					where c1=sucursal_id  and c2=tipo_orden and c3=num_orden and c4=rec.c4;
				precio_cargos:= coalesce(precio_cargos,0) + coalesce(precio_cargos_pto,0);
				if rec.c6=arrTipOrden[i] then
					select coalesce(sum(c10),0) into precio_cargos_x_pto
						from keplersc.kdcar 
						where c1=sucursal_id  and c2=tipo_orden and c3=num_orden and c4=rec.c4;	
					precio_cargos_x:=coalesce(precio_cargos_x,0) + coalesce(precio_cargos_x_pto,0);
				end if;
			end loop;
	
	--raise notice 'precio_cargos_pto:%', precio_cargos_pto;
	--raise notice 'precio_cargos:%', precio_cargos;
	--raise notice 'precio_cargos_x_pto:%', precio_cargos_x_pto;
	--raise notice 'precio_cargos_x:%', precio_cargos_x;
			total_trabajos := coalesce(costo_horas_x,0) + coalesce(importe_refacc_x,0) + coalesce(precio_ctetot_x,0) + coalesce(precio_cargos_x,0);
	--raise notice 'total_trabajos:%', total_trabajos;
			if total_trabajos <> 0 then
				if mano_obra_fac::decimal > 0 and costo_horas>0 and costo_horas_x>0 then
					total_mano_obra := round(mano_obra_fac::decimal/costo_horas*costo_horas_x,2);
				end if;
	--raise notice 'total_mano_obra:%', total_mano_obra;
				if refacciones_fac::decimal>0 and importe_refacc >0 and importe_refacc_x>0 then
					total_refacc := round(refacciones_fac::decimal/importe_refacc*importe_refacc_x,2);
				end if;
		
	--raise notice 'total_refacc:%', total_refacc;
				if tots_fac::decimal>0 and precio_ctetot>0 and precio_ctetot_x>0 then
					total_tots := round(tots_fac::decimal/precio_ctetot*precio_ctetot_x,2);
				end if;
		
	--raise notice 'total_tots:%', total_tots;
				if cargos_fac::decimal>0 and precio_cargos>0 and precio_cargos_x>0 then
					total_cargos := round(cargos_fac::decimal/precio_cargos*precio_cargos_x,2);
				end if;
				total_taller := total_taller+total_mano_obra+total_refacc+total_tots+total_cargos;			--B8109+=SUM(B8105...B8108)
	--raise notice 'total_taller:%', total_taller;	
	--raise notice '%', '2';			
				--CUENTA VENTAS MANO OBRA
				if total_mano_obra > 0 then
					desc_cuenta := '';
					expSql= format('select c2 from %1$s where c1=%2$L',
							tabla_polizas,cuenta_mo);	
					execute expSql into desc_cuenta;
					
					nPartida := nPartida+1;
					xmlPartidas := concat(xmlPartidas,format(
							'<partida_%5$s>
								<cuenta>%1$s</cuenta>
								<descripcion_cuenta>%4$s</descripcion_cuenta>
								<tipo_asiento>%2$s</tipo_asiento>
								<monto>%3$s</monto>
								<descripcion_partida>%6$s</descripcion_partida>
							</partida_%5$s>',
						    cuenta_mo,tipo_asientoA,total_mano_obra,coalesce(desc_cuenta,strCuentaSist),nPartida,desc_partida));
	--raise notice 'ventas mo%', xmlPartidas;					        
				end if;			        
				--CUENTA VENTAS REFACCIONES
				if total_refacc > 0 then
					desc_cuenta := '';
					expSql= format('select c2 from %1$s where c1=%2$L',
							tabla_polizas,cuenta_refacc);	
					execute expSql into desc_cuenta;
	--raise notice 'desc_cuenta:%', desc_cuenta;		
	--raise notice 'expSql:%', expSql;		
					
					nPartida := nPartida+1;
					xmlPartidas := concat(xmlPartidas,format(
							'<partida_%5$s>
								<cuenta>%1$s</cuenta>
								<descripcion_cuenta>%4$s</descripcion_cuenta>
								<tipo_asiento>%2$s</tipo_asiento>
								<monto>%3$s</monto>
								<descripcion_partida>%6$s</descripcion_partida>
							</partida_%5$s>',
						         cuenta_refacc,tipo_asientoA,total_refacc,coalesce(desc_cuenta,strCuentaSist),nPartida,desc_partida)); 
	--raise notice 'ventas ref%', xmlPartidas;						        
				end if;					        
				--CUENTA VENTAS TOTS
				if total_tots > 0 then
					desc_cuenta := '';	 
					expSql= format('select c2 from %1$s where c1=%2$L',
							tabla_polizas,cuenta_tots);	
					execute expSql into desc_cuenta;	
					
					nPartida := nPartida+1;
					xmlPartidas := concat(xmlPartidas,format(
							'<partida_%5$s>
								<cuenta>%1$s</cuenta>
								<descripcion_cuenta>%4$s</descripcion_cuenta>
								<tipo_asiento>%2$s</tipo_asiento>
								<monto>%3$s</monto>
								<descripcion_partida>%6$s</descripcion_partida>
							</partida_%5$s>',
					         	cuenta_tots,tipo_asientoA,total_tots,coalesce(desc_cuenta,strCuentaSist),nPartida,desc_partida));
	--raise notice 'ventas tots%', xmlPartidas;					         
				end if;				         
				--CUENTA VENTAS CARGOS VARIOS
				if total_cargos > 0 then
					desc_cuenta := '';
					expSql= format('select c2 from %1$s where c1=%2$L',
							tabla_polizas,cuenta_cargos);	
					execute expSql into desc_cuenta;	
					
					nPartida := nPartida+1;
					xmlPartidas := concat(xmlPartidas,format(
							'<partida_%5$s>
								<cuenta>%1$s</cuenta>
								<descripcion_cuenta>%4$s</descripcion_cuenta>
								<tipo_asiento>%2$s</tipo_asiento>
								<monto>%3$s</monto>
								<descripcion_partida>%6$s</descripcion_partida>
							</partida_%5$s>',
					         	cuenta_cargos,tipo_asientoA,total_cargos,coalesce(desc_cuenta,strCuentaSist),nPartida,desc_partida));
	--raise notice 'ventas cargos%', xmlPartidas;					         
				end if;				        
				--CUENTA COSTO REFACCIONES
				if cuenta_costo_refacc <>'' and costo_refacc_x > 0 then
					desc_cuenta := '';
					expSql= format('select c2 from %1$s where c1=%2$L',
							tabla_polizas,cuenta_costo_refacc);	
					execute expSql into desc_cuenta;	
					if desc_cuenta ='' then
						desc_cuenta='Cuenta creada por el sistema';
					end if;
					nPartida := nPartida+1;
					xmlPartidas := concat(xmlPartidas,format(
							'<partida_%5$s>
								<cuenta>%1$s</cuenta>
								<descripcion_cuenta>%4$s</descripcion_cuenta>
								<tipo_asiento>%2$s</tipo_asiento>
								<monto>%3$s</monto>
								<descripcion_partida>%6$s</descripcion_partida>
							</partida_%5$s>',
						    cuenta_costo_refacc,tipo_asientoC,costo_refacc_x,coalesce(desc_cuenta,strCuentaSist),nPartida,desc_partida));
	--raise notice 'costo refacc%', xmlPartidas;						        
				end if;		        
				--CUENTA COSTO TOTS
				if cuenta_costo_tots <>'' and subt_tots_x > 0 then
					desc_cuenta := '';
					expSql= format('select c2 from %1$s where c1=%2$L',
							tabla_polizas,cuenta_costo_tots);	
					execute expSql into desc_cuenta;	
					
					nPartida := nPartida+1;
					xmlPartidas := concat(xmlPartidas,format(
							'<partida_%5$s>
								<cuenta>%1$s</cuenta>
								<descripcion_cuenta>%4$s</descripcion_cuenta>
								<tipo_asiento>%2$s</tipo_asiento>
								<monto>%3$s</monto>
								<descripcion_partida>%6$s</descripcion_partida>
							</partida_%5$s>',
						    cuenta_costo_tots,tipo_asientoC,subt_tots_x,coalesce(desc_cuenta,strCuentaSist),nPartida,desc_partida));
	--raise notice 'costo tots%', xmlPartidas;					        
				end if;		
				--CUENTA PUENTE INVENTARIO REFACCIONES
				if cuenta_inv_refacc <>'' and costo_refacc_x > 0 then
					desc_cuenta := '';
					expSql= format('select c2 from %1$s where c1=%2$L',
							tabla_polizas,cuenta_inv_refacc);	
					execute expSql into desc_cuenta;	   
					if desc_cuenta ='' then
						desc_cuenta='Cuenta creada por el sistema';
					end if;
					nPartida := nPartida+1;
					xmlPartidas := concat(xmlPartidas,format(
							'<partida_%5$s>
								<cuenta>%1$s</cuenta>
								<descripcion_cuenta>%4$s</descripcion_cuenta>
								<tipo_asiento>%2$s</tipo_asiento>
								<monto>%3$s</monto>
								<descripcion_partida>%6$s</descripcion_partida>
							</partida_%5$s>',
						         cuenta_inv_refacc,tipo_asientoA,costo_refacc_x,coalesce(desc_cuenta,strCuentaSist),nPartida,desc_partida));
	--raise notice 'puente refacc_x%', xmlPartidas;					        
				end if;		
				--CUENTA PUENTE TOTS
				if cuenta_puente_tots <>'' and subt_tots_x > 0 then
					desc_cuenta := '';
					expSql= format('select c2 from %1$s where c1=%2$L',
							tabla_polizas,cuenta_puente_tots);	
					execute expSql into desc_cuenta;	   
					if desc_cuenta ='' then
						desc_cuenta='Cuenta creada por el sistema';
					end if;
					nPartida := nPartida+1;
					xmlPartidas := concat(xmlPartidas,format(
							'<partida_%5$s>
								<cuenta>%1$s</cuenta>
								<descripcion_cuenta>%4$s</descripcion_cuenta>
								<tipo_asiento>%2$s</tipo_asiento>
								<monto>%3$s</monto>
								<descripcion_partida>%6$s</descripcion_partida>
							</partida_%5$s>',
						         cuenta_puente_tots,tipo_asientoA,subt_tots_x,coalesce(desc_cuenta,strCuentaSist),nPartida,desc_partida));
	--raise notice 'puente tots%', xmlPartidas;					        
				end if; 
			end if;	
		else 
			raise exception 'No se encuentra la cuenta contable para el tipo de punto: %',arrTipOrden[i];
		end if;
	end loop;

	--AJUSTE DIFERENCIA TALLE
	total_trabajos_fact := mano_obra_fac::decimal+refacciones_fac::decimal+tots_fac::decimal+cargos_fac::decimal;
	total_trabajos_fact := total_trabajos_fact-total_taller;
	select c2 into tipo_trabajo from keplersc.kdmargen k 
		where c1=tipo_orden;
	if found then
		if tipo_trabajo ='N' then
			tipo_orden := 'S';
		else
			tipo_orden := tipo_trabajo;
		end if;
		if total_trabajos_fact <> 0 then
			select c5
				into cuenta_mo
				from keplersc.kdtallcont 
				where c1=tipo_orden and c2=sucursal_id and c3=anio_en_curso;
			if found then
				--CUENTA VENTAS MANO OBRA
				desc_cuenta := '';
				expSql= format('select c2 from %1$s where c1=%2$L',
						tabla_polizas,cuenta_mo);	
				execute expSql into desc_cuenta;	   
				
				nPartida := nPartida+1;
				xmlPartidas := concat(xmlPartidas,format(
						'<partida_%5$s>
							<cuenta>%1$s</cuenta>
							<descripcion_cuenta>%4$s</descripcion_cuenta>
							<tipo_asiento>%2$s</tipo_asiento>
							<monto>%3$s</monto>
							<descripcion_partida>%6$s</descripcion_partida>
						</partida_%5$s>',
				        	 cuenta_mo,tipo_asientoA,total_trabajos_fact,coalesce(desc_cuenta,strCuentaSist),nPartida,desc_partida));
--raise notice 'ajuste:%', xmlPartidas;				        	
			end if;
		end if;
	end if;
	if length(xmlPartidas)>0 then
		xmlPartidas := concat('<partidas>',xmlPartidas,'</partidas>');
		xmlPoliza := format('<poliza>
								<poliza_enc>
								  <monto_base_kdmm></monto_base_kdmm>
								  <descripcion_poliza></descripcion_poliza>
	        					  <referencia></referencia>
								  <error>%1$s</error>
								  <no_partidas>%2$s</no_partidas>
								</poliza_enc>%3$s</poliza>',
	        					error,nPartida,xmlPartidas);
	end if;  
--raise notice 'Termino OK';
	tmpXml:=xmlPoliza::xml;
--raise notice 'XML Poliza: %',tmpXml;
	return tmpXml;	

exception
	when others then
	--raise notice 'entro a exception%', error;
		error := 'keplersc.cont_venta_taller() ' || '['|| sqlstate || '] ' || sqlerrm ;
		raise exception '%', error;

end;
$function$
