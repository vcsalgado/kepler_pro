CREATE OR REPLACE FUNCTION keplersc.cont_ajusta_poliza(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Bitacora de cambios
--29/08/2025 Miriam Santana: Ajusta poliza con diferencia
DECLARE 
	--Variables para xml
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	fecha_operacion text;

	--xml documento
	xmlKDM1 xml;

	--xml Bitacora usuario
	xmlUsr xml;	

	--Variables de uso general
	anio_en_curso text = '';
	mes_en_curso text = '';
	tabla_polizas text = '';
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
	status_poliza text = '';
	tipo_ajuste text = '';
	contrapartida text = '';

	t_n_poliza text ='';
	t_tipo text = '';
	t_fecha date;
	t_folio text = '';
	t_referencia text = '';
	t_cargos decimal;
	t_abonos decimal;
	t_diferencia decimal;
	upd_diferencia decimal;
	rec record;

	--Variables de retorno desde funciones externas
	get_resultado text; --retorno
	get_mensaje text; --retorno
	get_adicionales text; --retorno
	
begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];

	--Obtener nombres de tablas y campos del anio-mes contable en curso
	anio_en_curso := substring(fecha_operacion,3,2);
	mes_en_curso := substring(fecha_operacion,6,2);
	
	tabla_polizas := 'keplersc.kdc2' || anio_en_curso || mes_en_curso;
	
	if (xpath('//row/c6/text()', xmlKDMM))[1]::text = 'S' then 			--Afecta contabilidad
		--Auditar la poliza Suma los cargos y abonos y sacar diferencia de la poliza generada para el folio del movto
		expSql = format('select n_poliza, tipo_l, fecha, folio, referencia, 
							coalesce (sum(cargo_total),0), coalesce (sum(abono_total),0),
							abs(coalesce (coalesce(sum(sel.cargo_total),0)-coalesce(sum(sel.abono_total),0),0))
						from (select c1 as n_poliza, c8 as tipo_l,c2 as fecha,c7 as referencia, c14 as sucursal,
								c15 as genero, c16 as naturaleza, c17 as grupo, c18 as tipo,c19 as folio, c4 as cargo_abono,
								case when c4 =''A'' then sum(c5) end abono_total, 
								case when c4 =''C'' then sum(c5) end cargo_total 
							  from %1$s 
							  where c14 = %2$L 
							  and c15 = %3$L and c16 = %4$L and c17 = %5$s and c18 = %6$s and c19= %7$L 
							  group  by c1, c4, c8, c14, c15 , c16, c17, c18,c19 , c2, c7
							  order by c1) as sel
						group by n_poliza, tipo_l, fecha, referencia,folio,sucursal,genero,naturaleza,grupo,tipo', tabla_polizas, sucursal_id, genero, naturaleza, grupo, tipo, folio_operacion);
		--raise notice 'Auditar poliza:%',expSql;
		execute expSql into t_n_poliza, t_tipo, t_fecha, t_folio, t_referencia, t_cargos, t_abonos, t_diferencia;
		--raise notice 't_diferencia:% t_cargos:% t_abonos:%', t_diferencia, t_cargos, t_abonos;
		if t_diferencia <> 0 then 			 
			--Ajustar la diferencia 
			if t_diferencia =0.01 then 
				--Checar en donde esta la diferencia en cargos o abonos
				if  t_cargos > t_abonos then		--sumar  t_diferencia a los abonos
					tipo_ajuste :='A';
					contrapartida := 'C';
					--raise notice 'Cargos > Abonos Ajuste en Abonos';				
				else
					tipo_ajuste ='C';
					contrapartida := 'A';
					--raise notice 'Cargos < Abonos Ajuste en Cargos';				
				end if;
				--Busco paartida con importe 0
				expSql = format('select count(*) from %1$s 
							  where c14 = %2$L 
							  and c15 = %3$L and c16 = %4$L and c17 = %5$s and c18 = %6$s and c19= %7$L and c4=%8$L and c5=0'
							, tabla_polizas, sucursal_id, genero, naturaleza, grupo, tipo, folio_operacion, tipo_ajuste);
				execute expSql into totalReg;
				--raise notice 'Busco partida con importe 0';
				--raise notice '%',expSql;			
				if totalReg = 0 then
					--recorrer los registros y buscar su monto igual en la partida contraria, en este caso buscar el monto de abono  i gual en el monto de cargo, y si encuentro uno diferente a 
					--al primero le sumo la diferencia
					expSql = format('select * from %1$s 
								where c14 = %2$L 
							  	and c15 = %3$L and c16 = %4$L and c17 = %5$s and c18 = %6$s and c19= %7$L and c4=%8$L'
								, tabla_polizas, sucursal_id, genero, naturaleza, grupo, tipo, folio_operacion, tipo_ajuste);
					--raise notice 'No existe partida en 0';
					--raise notice '%',expSql;							  
					for rec in execute expSql
					loop
						--raise notice 'Registro actual de abonos:%',rec;							  							
						--Busco contrapartida exacta
						expSql = format('select count(*) from %1$s 
										where c14 = %2$L 
									  	and c15 = %3$L and c16 = %4$L and c17 = %5$s and c18 = %6$s and c19= %7$L and c8 = %8$L and c1 = %9$s and c4=%10$L and c5=%11$s'
										, tabla_polizas, sucursal_id, genero, naturaleza, grupo, tipo, folio_operacion, rec.c8, rec.c1, contrapartida, rec.c5);
						execute expSql into totalReg;
						--raise notice 'Buscar contrapartida exacta';
						--raise notice '%',expSql;							  							
						if totalReg = 1 then		--Existe contrapartida de rec abono como cargo
							continue;
							--raise notice 'Si existe partida exacta, pasa al sig. registro';
						else 						--No existe contrapartida exacta y actualizo
							expSql = format('update %1$s set c5 = c5 + %12$s
										where c14 = %2$L 
										and c15 = %3$L and c16 = %4$L and c17 = %5$s and c18 = %6$s and c19= %7$L and c8 = %8$L and c1 = %9$s and c10 = %10$s and c4 = %11$L'
										, tabla_polizas, rec.c14, rec.c15, rec.c16, rec.c17, rec.c18, rec.c19, rec.c8, rec.c1, rec.c10, tipo_ajuste, t_diferencia);
							execute expSql;
							upd_diferencia := t_diferencia;
							--raise notice 'No existe partida exacta y actualiza el registro actual del rec';
							--raise notice '%',expSql;
							exit;
						end if;			
					end loop;
				else																								--***Probado 1 partida en 0 Abonos y Cargos
					if totalReg = 1 then			--Si existe sólo una partida en 0, se actualiza la diferecia
						expSql = format('update %1$s set c5 = C5 + %9$s
									where c14 = %2$L 
									and c15 = %3$L and c16 = %4$L and c17 = %5$s and c18 = %6$s and c19= %7$L and c4=%8$L and c5=0'
									, tabla_polizas, sucursal_id, genero, naturaleza, grupo, tipo, folio_operacion, tipo_ajuste, t_diferencia);
						execute expSql;
						upd_diferencia := t_diferencia;
						--raise notice 'Existe 1 partida en 0 y actualiza';
						--raise notice '%',expSql;							  						
								
					else																							--***Probado mas de 1 partida en 0 Abonos y Cargos
						--Recorrer y actualizar el primer registro en 0 con la diferencia
						expSql = format('select * from %1$s 
								where c14 = %2$L 
							  	and c15 = %3$L and c16 = %4$L and c17 = %5$s and c18 = %6$s and c19= %7$L and c4=%8$L and c5=0'
								, tabla_polizas, sucursal_id, genero, naturaleza, grupo, tipo, folio_operacion, tipo_ajuste);
						for rec in execute expSql
						loop
							--raise notice 'Existe mas de 1 partida en 0 y recorre';
							--raise notice '%',expSql;
							--raise notice 'Rec actual mas de 1 partida en 0:%',rec;
							--recorro y actualizo la primer partida en 0						
							expSql = format('update %1$s set c5 = C5 + %12$s
									where c14 = %2$L 
									and c15 = %3$L and c16 = %4$L and c17 = %5$s and c18 = %6$s and c19 = %7$L and c8 = %8$L and c1 = %9$s and c10 = %10$s and c4 = %11$L'
									, tabla_polizas, rec.c14, rec.c15, rec.c16, rec.c17, rec.c18, rec.c19, rec.c8, rec.c1, rec.c10, tipo_ajuste, t_diferencia);
							execute expSql;
							upd_diferencia := t_diferencia;
							--raise notice 'Actualiza prtimer registro y sale del loop';
							--raise notice '%',expSql;							  						
							exit;
						end loop;
					end if;		--Existe solo una partida en 0
				end if;		--Existe partida en 0
				--Revisar que este cuadrada la poliza
				expSql = format('select n_poliza, tipo_l, fecha, folio, referencia, 
								coalesce (sum(cargo_total),0), coalesce (sum(abono_total),0),
								abs(coalesce (coalesce(sum(sel.cargo_total),0)-coalesce(sum(sel.abono_total),0),0))
							from (select c1 as n_poliza, c8 as tipo_l,c2 as fecha,c7 as referencia, c14 as sucursal,
									c15 as genero, c16 as naturaleza, c17 as grupo, c18 as tipo,c19 as folio, c4 as cargo_abono,
									case when c4 =''A'' then sum(c5) end abono_total, 
									case when c4 =''C'' then sum(c5) end cargo_total 
								  from %1$s 
								  where c14 = %2$L 
								  and c15 = %3$L and c16 = %4$L and c17 = %5$s and c18 = %6$s and c19= %7$L 
								  group  by c1, c4, c8, c14, c15 , c16, c17, c18,c19 , c2, c7
								  order by c1) as sel
							group by n_poliza, tipo_l, fecha, referencia,folio,sucursal,genero,naturaleza,grupo,tipo', tabla_polizas, sucursal_id, genero, naturaleza, grupo, tipo, folio_operacion);
	
				execute expSql into t_n_poliza, t_tipo, t_fecha, t_folio, t_referencia, t_cargos, t_abonos, t_diferencia;	
				if t_diferencia <> 0 then 
					status_poliza := 'Poliza descuadrada por: '|| t_diferencia;
				elseif t_diferencia = 0 then
					status_poliza := 'Ajuste de poliza por: ' ||upd_diferencia;
				end if;
				--raise notice 'Ejecuta auditoria final: %',status_poliza;
			end if;  --0.01
			
		end if;		----<>0
	end if;	  --Afecta cont

	resultado := 1;
	mensaje := '';
	adicionales := status_poliza;
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cont_ajusta_poliza() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
