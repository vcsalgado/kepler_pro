CREATE OR REPLACE FUNCTION keplersc.invr_fisico_ajuste(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion:  inventario fisico ajuste 
--Autor: Luis Leal
--Fecha: 09/11/2023
--Bitacora de cambios
declare
		sucursal_id text;
		tipo_ope text;
		mes text;
		anio text;

		gen_mov text;
		nat_mov text;
		gpo_mov numeric;
		tipo_mov numeric;	
	
		comentarios text;
		producto text;
		existencia_real numeric;
		costo_prom_real numeric;
		rec_kdink record ;
		ctd_entradas numeric = 0;
		ctd_salidas numeric = 0;
		costo_entradas numeric = 0;
		costo_salidas numeric = 0;
		costo numeric = 0;
		partida numeric = 1;
		cantidad numeric = 0;
		col_estatus text = '';
	
		naturaleza text;
		ctd_mes_actual numeric;
		monto_mes_actual numeric;
	
		ajuste_de_existencia numeric;
		costo_del_fisico numeric;
		ajuste_del_costo numeric;
		importe numeric = 0;
		entradaSalida text;	
		contador int = 0;
		xmlResultado text = '';
		anio_en_curso text;
		mes_en_curso text;
		tipo_asiento_1 text; 
		tipo_asiento_2 text;
		folio_poliza text;
		tipo_poliza_kdmm text;
		accion_poliza_kdc text;
		numero_partida int = 0;
		cuenta_cargo text;
		cuenta_abono text;
		fecha_proceso timestamp;
		fecha_recover timestamp;
	
		varcont xml;
		xmlCadena xml;
		strValor text;
		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
   
begin 
	
		sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1]; 
		gen_mov := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
		nat_mov := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
		gpo_mov := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
		tipo_mov := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
		tipo_ope := (xpath('//document/operacion/text()', dataxml))[1]; 
		comentarios := (xpath('//document/k_coment/text()', dataxml))[1]; 

		SELECT date_part('month', (SELECT current_timestamp)) into mes;
		SELECT date_part('year', (SELECT current_timestamp)) into anio ; 
	
		fecha_proceso := current_timestamp;

		if tipo_ope = 'Baja' then
			--Obtener la fecha de operacion del movimiento
			select c3 into fecha_recover from keplersc.kdinm where c1=sucursal_id and c5=gen_mov and c6=nat_mov 
			and c7=gpo_mov::numeric and c8=tipo_mov::numeric and c9=folio_operacion;

			--Validar factibilidad para el proceso de la baja del movimiento
			select max(c3) into fecha_proceso from keplersc.kdinm;
			if fecha_proceso > fecha_recover then
				raise exception 'No se puede realizar el proceso porque se tienen movimientos posteriores.';
			end if;
			importe := (xpath('//document/k_monto/text()', dataxml))[1]; 

			--Eliminar movimientos en kdinm
			delete from keplersc.kdinm where c1=sucursal_id and c5=gen_mov and c6=nat_mov 
			and c7=gpo_mov::numeric and c8=tipo_mov::numeric and c9=folio_operacion;	

			--Eliminar movimiento de kdinvrdif
			delete from keplersc.kdinvrdif where c1=sucursal_id and c2=gen_mov and c3=nat_mov 
			and c4=gpo_mov::numeric and c5=tipo_mov::numeric and c6=folio_operacion;

			--Restaurar registros de estadisticas desde el ultimo punto de recuperacion
			delete from  keplersc.kdinl where c1=sucursal_id;
			insert into keplersc.kdinl select c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,c16,c17,c18,c19,c20 from keplersc.kdinl_rec 
				where c1=sucursal_id and fecha_rec = fecha_recover;
			
			delete from keplersc.kdink where c1=sucursal_id;
			insert into keplersc.kdink select c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,
				c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,
				c31,c32,c33,c34,c35,c36,c37,c38,c39,c40,
				c41,c42,c43,c44,c45,c46,c47,c48,c49,c50,
				c51,c52,c53,c54,c55,c56,c57,c58,c59,c60,
				c61,c62,c63 from keplersc.kdink_rec 
				where c1=sucursal_id and fecha_rec=fecha_recover;
--raise exception 'Se elimino movimiento, fecha recover:%',fecha_recover;
		else
			
--mensaje:=concat(mensaje,'tipo_ope:',tipo_ope,'INICIAL: ',fecha_proceso, '-' ,fecha_texto);

			if tipo_ope = 'Alta' or tipo_ope = 'Baja' then
				--Crear respaldo de tablas de estadisticas para tener un punto de recuperacion de ser necesario
				insert into keplersc.kdinl_rec select fecha_proceso, * from keplersc.kdinl;
				insert into keplersc.kdink_rec select fecha_proceso, * from keplersc.kdink;
			end if;

--mensaje:=concat(mensaje,'DESPUES REC : ',fecha_proceso, '-' ,fecha_texto);
			for producto, existencia_real, costo_prom_real,col_estatus in select c2,c6,c7,estatus from keplersc.kdifis where c1=sucursal_id --and c2='044950K120'
			loop
							
				if producto = '' then
					continue;
				end if;
			
				cantidad := 0;
				costo := 0;
			
				for rec_kdink in select * from keplersc.kdink where c1=sucursal_id and c2=producto and c3<=anio order by c2
				loop 
									
					if rec_kdink.c3 < anio then
					
						ctd_entradas := rec_kdink.c10 + rec_kdink.c11 + rec_kdink.c12 + 
						rec_kdink.c13 + rec_kdink.c14 + rec_kdink.c15 + rec_kdink.c16 + rec_kdink.c17 
						+ rec_kdink.c18 + rec_kdink.c19 + rec_kdink.c20 + rec_kdink.c21;
					
						ctd_salidas := rec_kdink.c40 + rec_kdink.c41 + rec_kdink.c42 + rec_kdink.c43
						+ rec_kdink.c44 + rec_kdink.c45 + rec_kdink.c46 + rec_kdink.c47 + rec_kdink.c48 +
						rec_kdink.c49 + rec_kdink.c50 + rec_kdink.c51;
					
						cantidad := cantidad + (ctd_entradas - ctd_salidas);
					
					
						costo_entradas := rec_kdink.c22 + rec_kdink.c23 + rec_kdink.c24 + rec_kdink.c25 
						+ rec_kdink.c26 + rec_kdink.c27 + rec_kdink.c28 + rec_kdink.c29
						+ rec_kdink.c30 + rec_kdink.c31 + rec_kdink.c32 + rec_kdink.c33;
					
						costo_salidas := rec_kdink.c52 + rec_kdink.c53 + rec_kdink.c54 + rec_kdink.c55
						+ rec_kdink.c56 + rec_kdink.c57 + rec_kdink.c58 + rec_kdink.c59 + rec_kdink.c60 +
						rec_kdink.c61 + rec_kdink.c62 + rec_kdink.c63;
					
						costo := costo + (costo_entradas - costo_salidas);
									
					else
					
						ctd_entradas := 0;
						ctd_salidas := 0;
						costo_entradas := 0;
						costo_salidas := 0;
					
						for i in 1..mes::int  loop
													
							if i = 1 then
								ctd_entradas := ctd_entradas + rec_kdink.c10;
								ctd_salidas := ctd_salidas + rec_kdink.c40;
								costo_entradas := costo_entradas + rec_kdink.c22;
								costo_salidas := costo_salidas + rec_kdink.c52;
							elsif i = 2 then
								ctd_entradas := ctd_entradas + rec_kdink.c11;
								ctd_salidas := ctd_salidas + rec_kdink.c41;
								costo_entradas := costo_entradas + rec_kdink.c23;
								costo_salidas := costo_salidas + rec_kdink.c53;
							elsif i = 3 then
								ctd_entradas := ctd_entradas + rec_kdink.c12;
								ctd_salidas := ctd_salidas + rec_kdink.c42;
								costo_entradas := costo_entradas + rec_kdink.c24;
								costo_salidas := costo_salidas + rec_kdink.c54;
							elsif i = 4 then
								ctd_entradas := ctd_entradas + rec_kdink.c13;
								ctd_salidas := ctd_salidas + rec_kdink.c43;
								costo_entradas := costo_entradas + rec_kdink.c25;
								costo_salidas := costo_salidas + rec_kdink.c55;
							elsif i = 5 then
								ctd_entradas := ctd_entradas + rec_kdink.c14;
								ctd_salidas := ctd_salidas + rec_kdink.c44;
								costo_entradas := costo_entradas + rec_kdink.c26;
								costo_salidas := costo_salidas + rec_kdink.c56;
							elsif i = 6 then
								ctd_entradas := ctd_entradas + rec_kdink.c15;
								ctd_salidas := ctd_salidas + rec_kdink.c45;
								costo_entradas := costo_entradas + rec_kdink.c27;
								costo_salidas := costo_salidas + rec_kdink.c57;
							elsif i = 7 then
								ctd_entradas := ctd_entradas + rec_kdink.c16;
								ctd_salidas := ctd_salidas + rec_kdink.c46;
								costo_entradas := costo_entradas + rec_kdink.c28;
								costo_salidas := costo_salidas + rec_kdink.c58;
							elsif i = 8 then
								ctd_entradas := ctd_entradas + rec_kdink.c17;
								ctd_salidas := ctd_salidas + rec_kdink.c47;
								costo_entradas := costo_entradas + rec_kdink.c29;
								costo_salidas := costo_salidas + rec_kdink.c59;
							elsif i = 9 then
								ctd_entradas := ctd_entradas + rec_kdink.c18;
								ctd_salidas := ctd_salidas + rec_kdink.c48;
								costo_entradas := costo_entradas + rec_kdink.c30;
								costo_salidas := costo_salidas + rec_kdink.c60;
							elsif i = 10 then
								ctd_entradas := ctd_entradas + rec_kdink.c19;
								ctd_salidas := ctd_salidas + rec_kdink.c49;
								costo_entradas := costo_entradas + rec_kdink.c31;
								costo_salidas := costo_salidas + rec_kdink.c61;
							elsif i = 11 then
								ctd_entradas := ctd_entradas + rec_kdink.c20;
								ctd_salidas := ctd_salidas + rec_kdink.c50;
								costo_entradas := costo_entradas + rec_kdink.c32;
								costo_salidas := costo_salidas + rec_kdink.c62;
							elsif i = 12 then
								ctd_entradas := ctd_entradas + rec_kdink.c21;
								ctd_salidas := ctd_salidas + rec_kdink.c51;
								costo_entradas := costo_entradas + rec_kdink.c33;
								costo_salidas := costo_salidas + rec_kdink.c63;
							end if;
						
						end loop;
					
						cantidad := cantidad + (ctd_entradas - ctd_salidas);
										
						costo := costo + (costo_entradas - costo_salidas);					
			
					end if;
				
				end loop;

				costo_del_fisico := existencia_real * costo_prom_real;
						
				ajuste_de_existencia := existencia_real - cantidad;
			
				ajuste_del_costo := costo_del_fisico - costo;
			
				if ajuste_de_existencia = 0 and ajuste_del_costo = 0 then
					continue;
				end if;
			
				importe := importe + ajuste_del_costo;
			
				if tipo_ope = 'Alta' then								
					insert into keplersc.kdinvrdif(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14)
					values(sucursal_id, gen_mov, nat_mov, gpo_mov::numeric, tipo_mov::numeric, folio_operacion, partida,
					producto, cantidad, costo, existencia_real, costo_del_fisico,ajuste_de_existencia, ajuste_del_costo);
				
					entradaSalida := 'E';
					if nat_mov = 'D' then
						ajuste_de_existencia := ajuste_de_existencia * -1;
						ajuste_del_costo := ajuste_del_costo * -1;
						entradaSalida := 'S';
					end if;	
--mensaje:=concat(mensaje,'ANTES KDINM: ',fecha_proceso, '-' ,fecha_texto);							
		
					insert into keplersc.kdinm(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13)
					values(sucursal_id, producto, fecha_proceso, substring(fecha_proceso::text, 12,8),gen_mov ,nat_mov,
					gpo_mov,tipo_mov, folio_operacion, partida, ajuste_de_existencia, ajuste_del_costo, 1);
--mensaje:=concat(mensaje,'DESPUES KDINM: ',fecha_proceso, '-' ,fecha_texto);							
					--mejor se ejecuta invr_actualizar_estadistica al final
					/*if ajuste_de_existencia > 0 then
						entradaSalida := 'E';
					else						
						entradaSalida := 'S';
					end if;
					*/
					--Registro de estadisticas
					select xmlforest(sucursal_id as sucursal, gen_mov as genero, nat_mov as naturaleza,
					gpo_mov as grupo, tipo_mov as tipo_clave,
					producto as clave_producto, current_date as fecha, entradaSalida as entradaSalida,
					ajuste_del_costo::text as monto, ajuste_de_existencia as cantidad, 'ifis' as proceso):: text into strValor;
							
					select '<document>'||strValor||'</document>' into strValor;
					xmlCadena := strValor::xml;
--raise exception '%',xmlCadena;			
					select * into resultado, mensaje, adicionales from keplersc.invr_estadis_alta(xmlCadena);
					if resultado = '0' then
						raise exception '%',mensaje;
					end if;
				
					partida := partida + 1;
				
				else 
			
					xmlResultado := concat(xmlResultado, format('<r%1$s><producto>%2$s</producto>
					<inv_teorico>%3$s</inv_teorico><costo_teorico>%4$s</costo_teorico>
					<inv_fisico>%5$s</inv_fisico><costo_fisico>%6$s</costo_fisico>
					<inv_dif>%7$s</inv_dif><costo_dif>%8$s</costo_dif><estatus>%9$s</estatus></r%1$s>',
					contador, producto, cantidad, costo, existencia_real, costo_del_fisico,
					ajuste_de_existencia, ajuste_del_costo,col_estatus));
					
					contador := contador + 1;

				end if;		
		
			end loop;
		
		end if;
--mensaje:=concat(mensaje,'FIN LOOP KDINM: ',fecha_proceso, '-' ,fecha_texto);							
--raise exception 'Rsultado:% ',mensaje;		
	
		if tipo_ope = 'Alta' or tipo_ope = 'Baja' then
	
			if importe <> 0 then
			
				select c19,c20 into cuenta_cargo, cuenta_abono from keplersc.kdmm where col_sucursal=sucursal_id and c1=gen_mov and c2=nat_mov and c3=gpo_mov and c4=tipo_mov;	
			
				tipo_poliza_kdmm := 'D';
				accion_poliza_kdc := 'NUEVAPOLIZA';
			
				if tipo_ope = 'Alta' then
			
					anio_en_curso := substring(current_date::text,3,2);
					mes_en_curso := substring(current_date::text,6,2);
					folio_poliza := 'POLIZA' || tipo_poliza_kdmm || anio_en_curso || mes_en_curso ;
					select * into resultado, mensaje, adicionales from keplersc.obtener_folio_poliza(folio_poliza);
					if resultado = '0' then
						raise exception '%',mensaje;
					end if;
					folio_poliza := mensaje::int;
				
				else
				
					select c1, c10 into folio_poliza, numero_partida from keplersc.kdc2_view where c14=sucursal_id 
					and c15=gen_mov and c16=nat_mov and c17=gpo_mov and c18=tipo_mov and c19=folio_operacion order by c10 desc limit 1;
													
				end if;
	
				if tipo_ope = 'Alta' then
					tipo_asiento_1 := 'C'; 
					tipo_asiento_2 := 'A';
				else
					tipo_asiento_1 := 'A'; 
					tipo_asiento_2 := 'C';
					comentarios := 'Baja movimiento';
				end if;
				
				if importe < 0 then
					importe := importe * -1;
				end if;
			
				numero_partida = numero_partida +  1;
				select xmlforest(current_date as fecha, cuenta_cargo as cuenta, tipo_asiento_1 as tipo_asiento, 
					importe as monto, comentarios as descrip, '' as refer, 
					tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
					sucursal_id as sucursal, gen_mov as genero, nat_mov as naturaleza, gpo_mov as grupo, tipo_mov as tipo_clave, folio_operacion,
					accion_poliza_kdc as accion_poliza, folio_poliza,numero_partida)::text into strValor;					  
				select '<varcont>'||strValor||'</varcont>' into strValor;
						
				varcont := strValor::xml;
				select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
				if resultado = '0' then
					raise exception '%',mensaje;
				end if;
			
				numero_partida = numero_partida +  1;
				select xmlforest(current_date as fecha, cuenta_abono as cuenta, tipo_asiento_2 as tipo_asiento, 
					importe as monto, comentarios as descrip, '' as refer, 
					tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
					sucursal_id as sucursal, gen_mov as genero, nat_mov as naturaleza, gpo_mov as grupo, tipo_mov as tipo_clave, folio_operacion,
					accion_poliza_kdc as accion_poliza, folio_poliza, numero_partida)::text into strValor;					  
				select '<varcont>'||strValor||'</varcont>' into strValor;
				varcont := strValor::xml;
				select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
				if resultado = '0' then
					raise exception '%',mensaje;
				end if;
			
			end if;
		
		end if;
	

	
		resultado := 1;
		mensaje := importe;
		adicionales := xmlResultado;
		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := 0;
			mensaje := 'invr_fisico_ajuste() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
 	
end;
$function$
