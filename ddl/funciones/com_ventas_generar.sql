CREATE OR REPLACE FUNCTION keplersc.com_ventas_generar(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	sucursal_id text = '';	
	anio text ='';
	mes text = '';


	--Variables de uso general 
	strValor text='';
	intValor int=0;
--	dateValor date;
	dateValor timestamp;
	totReg int=0;

	rec_F_UV record; --Registro vendedores
	rec_H_VESQ record; --Registro de esquema por vendedor
	rec_G_TOP record; --Registro de tipo de operacion
	rec_K_COMISMOV record; --Registro de Comisiones
	rec_ZM_COMISVENTAS record;
	rec_ZQ_COMISQUINCENA record;
	rec_E_INF record;
	rec_I_VESQVEH record;
	rec_J_PORCENTAJES record;
	rec_L_TIPOCOMIS record;
	rec_P_COMISADIS record;
	rec_T_ICOM record;
	rec_U_IV record;
	rec_M_VOBJLINEA	record;
	rec_V_COMISMOV2 record;
	rec_X_COMISMOV2 record;
	rec_Y_KDCONFIGCC record;


	B1_UtilidadBruta numeric(10,2) = 0;
	B2_GastosAdmin numeric(10,2) = 0;
	B3_Seguro numeric(10,2) = 0;
	B4_GarantiaExtendida numeric(10,2) = 0;
	B5_NotaDescuento numeric(10,2) = 0;
	B6_Subsidio numeric(10,2) = 0;
	B7_UtilidadBrutaAccesorios numeric(10,2) = 0;

	B11_ComisionSinBonos numeric(10,2) = 0;
	B12_GastosAdmin numeric(10,2) = 0;
 	B13_Seguro numeric(10,2) = 0;
 	B14_Garantia numeric(10,2) = 0;
 
 	B17_Accesorios numeric(10,2) = 0;
	B18_ComisionEdad numeric(10,2) = 0;
	B19_Linea numeric(10,2) = 0;
	B20_Traslado numeric(10,2) = 0;
	B21_BonoSemanal numeric(10,2) = 0;
	B22_ComisAntesTmkt numeric(10,2) = 0;
	B23_DescuentoAsesorTmkt numeric(10,2) = 0;
	B24_ComisionTotal numeric(10,2) = 0;

	/*
	A2_fechaIniMes date;
	A3_fechaFinMes	date;
	D3_fechaPrimCorte date;
	D4_fechaSegCorte date;
	*/
	A2_fechaIniMes timestamp;
	A3_fechaFinMes	timestamp;
	D3_fechaPrimCorte timestamp;
	D4_fechaSegCorte timestamp;
	B2_SueldoBase decimal(12,2) = 0.00;

	N1 numeric =0;
	N3 int = 0; --Esquema
	N4 int =0;
	N5 int =0;
	N6 int =0;
	N8_Consecutivo numeric;
	N9 int=0;
	N12_EdadInventario numeric;
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	sucursal_id := (xpath('//document/k_sucn/text()', dataxml))[1];
	mes := (xpath('//document/mes/text()', dataxml))[1];
	anio := (xpath('//document/anio/text()', dataxml))[1];
	mes:=mes::int::text;
	anio:=anio::int::text;

	--strValor:= '01' || '-' || lpad(mes,2,'0') || '-' || '20' || lpad(anio,2,'0');
	strValor:= concat('01','-',lpad(mes,2,'0'),'-','20',lpad(anio,2,'0'), ' 00:00:00');

--	A2_fechaIniMes:=to_date(strValor,'dd-mm-yyyy');
	A2_fechaIniMes:=to_timestamp(strValor,'dd-mm-yyyy HH24:MI:SS');
	A3_fechaFinMes:=A2_fechaIniMes + interval '1 month';
	A3_fechaFinMes:=A3_fechaFinMes - interval '1 day';
	A3_fechaFinMes:=A3_fechaFinMes + interval '23 hours 59 minutes 59 seconds';
	D3_fechaPrimCorte:=A2_fechaIniMes + interval '15 day';
	D4_fechaSegCorte:=A3_fechaFinMes;

	--LIMPIA_COMISIONES
	delete from keplersc.kdcomisventas where c1=sucursal_id and c2=anio and c3=mes;
	delete from keplersc.kdcomisquincena where c1=sucursal_id and c2=anio and c3=mes;

	for rec_F_UV in select * from keplersc.kduv /*where c2='R0H'*/ order by c1,c2--INI Loop sobre vendedores Alias F en K75, VIEW(F)
	loop
--raise notice 'Inicia Vendedor: %', rec_F_UV.c2;
		--Reinicia variables de proceso
		rec_H_VESQ:=null;
		--INI ESTABLECE_FECHAS K75, las fechas se establecieron al inicio de la funcion
		--Se calcula el valor del sueldo base + Adicionales 1 y Adicionales 2
		--Buscar el esquema del vendedor
		select count(*) into totReg from keplersc.kdvesq where c1=rec_F_UV.c8;
		if totReg > 0 then
			select * into rec_H_VESQ from keplersc.kdvesq where c1=rec_F_UV.c8;
			B2_SueldoBase:=rec_H_VESQ.c3+rec_H_VESQ.c4+rec_H_VESQ.c5; --Sueldo base + adicionales
		else 
--raise notice 'Esquema nulo para: %', rec_F_UV.c2;
			continue;
			--B2_SueldoBase:=0;
		end if;
		--FIN ESTABLECE_FECHAS K75	
	
		for rec_G_TOP in select * from keplersc.kdtop --INI Loop tipo de Operacion Alias G en K75 Tipo Operacion
		loop
			if rec_G_TOP.c1 = 'TRAS' then --Clave de Operacion dif Traspaso otras agencias, IF G1><"TRAS" 
--raise notice 'Operacion TRAS para: %', rec_F_UV.c2;			
				continue;
			end if;

			for N5 in 3..4 loop --Quincena, Mes
--raise notice 'Ciclo for: Vendedor:%, Tipo Oper:%, N5:%',rec_F_UV.c2,rec_G_TOP.c1,N5;	
				/*
				--CUENTA_ENTREGAS_POR_VENDEDOR K75
				SUB CUENTA_ENTREGAS_POR_VENDEDOR
				 N1=0
				 VIEW(K,5) WHILE K1=A1 AND K9=F2 AND K7>=A2 AND K7<=D(N5)
				  IF K10=0 THEN
				   N1+=1
				  ELSE
				   N1-=1
				  ENDIF
				 LOOP
				ENDSUB				
				*/
				N1:=0; 
				if N5=3 then --Se valida primer corte
					dateValor:=D3_fechaPrimCorte;
				else --Se valida segundo corte
					dateValor:=D4_fechaSegCorte;
				end if;
				for intValor in select c10 from keplersc.kdcomismov 
					where c1=sucursal_id and c9=rec_F_UV.c2 and c7>=A2_fechaIniMes and c7<=dateValor --Sucursal,Vendedor,Dentro de rango fecha
				loop
					if intValor=0 then -- 0 Alta
						N1:=N1+1;
					else -- Baja 
						N1:=N1-1;
					end if;
				end loop;

				--VIEW(K,2) WHILE K1=A1 AND K9=F2 AND K11=G1 AND K7>=A2 AND K7<=D(N5)
				for rec_K_COMISMOV in select * from keplersc.kdcomismov k --INI Loop por ventas a comisionar
					where k.c1=sucursal_id and k.c9=rec_F_UV.c2 and k.c11=rec_G_TOP.c1 and k.c7>=A2_fechaIniMes and k.c7<=dateValor
					order by k.c1, k.c8
					--Sucursal,Vendedor,Tipo de Operacion, Dentro de rango fecha: VIEW(K,2) WHILE K1=A1 AND K9=F2 AND K11=G1 AND K7>=A2 AND K7<=D(N5)					
				loop
raise notice 'Ciclo for: Vendedor:%, Tipo Oper:%, N5:% Vtas. comisionar:%, FecIni:%, FecFin:%',rec_F_UV.c2,rec_G_TOP.c1,N5,rec_K_COMISMOV.c8,A2_fechaIniMes,dateValor;					
					--SET(0,N2,B31...B49)
					B11_ComisionSinBonos = 0;
					B12_GastosAdmin = 0;
				 	B13_Seguro = 0;
				 	B14_Garantia = 0;
				 	B17_Accesorios = 0;
					B18_ComisionEdad = 0;
					B19_Linea = 0;
					B20_Traslado = 0;
					B21_BonoSemanal = 0;
					B22_ComisAntesTmkt = 0;
					B23_DescuentoAsesorTmkt = 0;
					B24_ComisionTotal = 0;							
					--Iniciar registro para insercion en ventas mensualees y quincenales
					select * into rec_ZM_COMISVENTAS from keplersc.kdcomisventas where c1='99' and c2='99' and c3='99';
					select * into rec_ZQ_COMISQUINCENA from keplersc.kdcomisquincena where c1='99' and c2='99' and c3='99' and c4='99';
					
					--Busca inventario
					--IF BUS(E,1,0,K1,K8)>0 AND ENCUENTRA_ESQUEMA>0 THEN
					select * into rec_E_INF from keplersc.kdinf where c1=rec_K_COMISMOV.c1 and c2=rec_K_COMISMOV.c8 ;
					if not found then 
						continue;
					end if;
--raise notice 'Esquema';
					/*
					SUB ENCUENTRA_ESQUEMA
					 'ENCUENTRA EL ESQUEMA ADECUADO PARA LA OPERACION
					 N3=0
					 IF BUS(I,1,0,A1,F8,K11,K14)>0 THEN
					  VIEW(J) WHILE J1=I5 AND J2<=N1 AND J3>=N1
					   IF N3=0 THEN N3=1: EXIT: ENDIF
					  LOOP
					 ENDIF
					 RETURN N3
					ENDSUB
					*/
					rec_I_VESQVEH:=null;
					select * into rec_I_VESQVEH from keplersc.kdvesqveh 
						where c1=sucursal_id and c2=rec_F_UV.c8 and c3=rec_K_COMISMOV.c11 and c4=rec_K_COMISMOV.c14;
						--Sucursal, Tipo Auto, Esquema, Operacion; BUS(I,1,0,A1,F8,K11,K14)>0
					if not found then
						continue;
					end if;
			
					select * into rec_J_PORCENTAJES from keplersc.kdporcentajes j 
						where j.c1=rec_I_VESQVEH.c5 and j.c2<=N1 and j.c3>=N1;
						--c1-Tipo Comision, c2-Limite inferior, c3-Limite superior; VIEW(J) WHILE J1=I5 AND J2<=N1 AND J3>=N1
					if not found then
						continue;
					end if;

--raise notice 'Base';
					/*
					SUB ENCUENTRA_BASE
					 'SACA LA BASE SOBRE LA CUAL SE VAN A CALCULAR LAS COMISIONES
					 B1=0
					 IF BUS(L,1,0,I5)>0 THEN
					   B1=K22-K21-K20-K23
					   IF BUS(P,1,0,K1...K6,K10)>0 THEN 'BUSCANDO LOS COSTOS ADICIONALES QUE PUDIERA TRAER LA UNIDAD Y LAS BONIFICACIONES
					    B1+=(-P13+P14+P9-P10)
					   ENDIF
					   B5=0: B5=K15'NOTA DE DESCUENTO
					   B6=0: IF BUS(P,1,0,K1...K6,K10)>0 THEN B6=P8: ENDIF'SUBSIDIO
					   B1-=(B5+B6)'UTILIDAD BRUTA FINAL
					 ENDIF
					 IF B1<0 THEN B1=0: ENDIF
					 IF K10=1 THEN B1=-B1: B5=-B5: B6=-B6: ENDIF
					
					ENDSUB
					*/
					B1_UtilidadBruta:=0;
					B5_NotaDescuento =0;
					B6_Subsidio = 0;
					rec_L_TIPOCOMIS:=null;
					select * into rec_L_TIPOCOMIS from keplersc.kdtipocomis 
						where c1 = rec_I_VESQVEH.c5; --Clasif de Comision
					if found then
						B1_UtilidadBruta:=rec_K_COMISMOV.c22-rec_K_COMISMOV.c21-rec_K_COMISMOV.c20-rec_K_COMISMOV.c23;	
						--UtilBruta=Importe-IVA-ISAN-Costo
						--COSTOS ADICIONALES Y SUBSIDIOS
						rec_P_COMISADIS:=null;
						select * into rec_P_COMISADIS from keplersc.kdcomisadis
							where c1=rec_K_COMISMOV.c1 and c2=rec_K_COMISMOV.c2 and c3=rec_K_COMISMOV.c3 and 
							c4=rec_K_COMISMOV.c4 and c5=rec_K_COMISMOV.c5 and c6=rec_K_COMISMOV.c6 and c7=rec_K_COMISMOV.c10 limit 1;
						if found then
							B1_UtilidadBruta:=B1_UtilidadBruta
								-rec_P_COMISADIS.c13 --Cargo al Costo de Unidades
								+rec_P_COMISADIS.c14 --Abono al Costo de Unidades
								+rec_P_COMISADIS.c9  --Cargos de Bonificaciones
								-rec_P_COMISADIS.c10; --Abonos de Bonificaciones
							B6_Subsidio = rec_P_COMISADIS.c8;
						end if;
					
						--NOTAS DE DESCUENTO
						B5_NotaDescuento = rec_K_COMISMOV.c15; --Descuento
						--UTILIDAD BRUTA FINAL
						B1_UtilidadBruta=B1_UtilidadBruta-B5_NotaDescuento-B6_Subsidio;
					end if;
					if 	B1_UtilidadBruta < 0 then
						B1_UtilidadBruta:=0;
					end if;
					--IF K10=1 THEN B1=-B1: B5=-B5: B6=-B6: ENDIF
					if rec_K_COMISMOV.c10='1' then--Tipo = Baja
						B1_UtilidadBruta:=B1_UtilidadBruta * -1;
						B5_NotaDescuento:=B5_NotaDescuento * -1;
						B6_Subsidio:=B6_Subsidio * -1;
					end if;

--raise notice 'Calcula comision base';				
					/*
					SUB CALCULA_COMISION_BASE
					 IF L3><30 THEN
					  B11=J4*B1/100
					 ELSE
					  B11=J4
					  IF K10=1 THEN B11=-B11: ENDIF
					 ENDIF
					ENDSUB
					*/
					if rec_L_TIPOCOMIS.c3<>30 then --no es Tipo Cuota Fija
						B11_ComisionSinBonos:=rec_J_PORCENTAJES.c4 * B1_UtilidadBruta / 100; --C4=Cuota; B11=J4*B1/100
					else
						B11_ComisionSinBonos:=rec_J_PORCENTAJES.c4;
						if rec_K_COMISMOV.c10='1' then --Estatus Baja
							B11_ComisionSinBonos = B11_ComisionSinBonos * -1;	
						end if;
					end if;

--raise notice 'Bono por edad';				
					/*
					SUB CALCULA_BONO_POR_EDAD
					 N12=K7-K24
					 IF N12<=L4 THEN
					   B18=J5
					 ELSE
					  IF N12<=L5 THEN
					    B18=J6
					  ELSE
					   IF N12<=L6 THEN
					     B18=J7
					   ELSE
					     B18=J8
					   ENDIF
					  ENDIF
					 ENDIF
					 IF L3><30 THEN
					  B18=B18*B1/100
					 ELSE
					  IF K10=1 THEN B18=-B18: ENDIF
					 ENDIF
					ENDSUB
					 */
					B18_ComisionEdad = 0;
					N12_EdadInventario:=date_part('day',rec_K_COMISMOV.c7-rec_K_COMISMOV.c24);
					if N12_EdadInventario <= rec_L_TIPOCOMIS.c4 then --Lim superior edad
						B18_ComisionEdad = rec_J_PORCENTAJES.c5; --Porcentaje o Cuota edad 1
					else
						if N12_EdadInventario <= rec_L_TIPOCOMIS.c5 then --Lim superior edad
							B18_ComisionEdad = rec_J_PORCENTAJES.c6; --Porcentaje o Cuota edad 2						
						else
							if N12_EdadInventario <= rec_L_TIPOCOMIS.c6 then --Lim superior edad
								B18_ComisionEdad = rec_J_PORCENTAJES.c7; --Porcentaje o Cuota edad 3						
							else
								B18_ComisionEdad = rec_J_PORCENTAJES.c8; --Porcentaje o Cuota edad 4
							end if;
						end if;
					end if;
					if rec_L_TIPOCOMIS.c3<>30 then
						B18_ComisionEdad:=B18_ComisionEdad * B1_UtilidadBruta/100;
					else
						if rec_K_COMISMOV.c10='1' then --Estatus Baja
							B18_ComisionEdad:=B18_ComisionEdad * -1;
						end if;
					end if;

--raise notice 'Comisiones FI';				
					/*
					SUB CALCULA_COMISIONES_F&I
					 B2=K16'GASTOS ADMINISTRATIVOS
					 B3=K17'SEGURO
					 B4=K19'GARANTIA EXTENDIDA
					 IF BUS(P,1,0,K1...K6,K10)>0 THEN 'BUSCANDO EL COSTO DE LOS ACCESORIOS
					  B7=K18-P11+P12'UTILIDAD BRUTA DE ACCESORIOS
					 ENDIF
					 IF B7<0 THEN B7=0: ENDIF
					 IF K10=1 THEN
					  B2=-B2
					  B3=-B3
					  B4=-B4
					  B7=-B7
					 ENDIF
					
					 B12=J10*B2/100'GASTOSADMON
					 B13=J11*B3/100'SEGURO
					 B14=J13*B4/100'GARANTIA
					
					 B17=J12*B7/100'ACCESORIOS
					
					ENDSUB
					 */
				
					B2_GastosAdmin:=rec_K_COMISMOV.c16; --Gastos administrativos
					B3_Seguro:=rec_K_COMISMOV.c17; --Seguro
					B4_GarantiaExtendida:=rec_K_COMISMOV.c19; --Garantía extendida				
					
					B7_UtilidadBrutaAccesorios:=0;
					--El registro ya se trae en memoria desde una busqueda anterior, seccion COSTOS ADICIONALES Y SUBSIDIOS
					if rec_P_COMISADIS is not null then
						--TO VER: Se esta haciendo una diferencia entre importes y porcentajes
						B7_UtilidadBrutaAccesorios:=rec_K_COMISMOV.c18 - rec_P_COMISADIS.c11 + rec_P_COMISADIS.c12; --Accesorios-Porc Seg - Porc Accesorios 
					end if;
					if B7_UtilidadBrutaAccesorios<0 then
						B7_UtilidadBrutaAccesorios = 0;
					end if;
					if rec_K_COMISMOV.c10='1' then --Estatus Baja
						B2_GastosAdmin:=B2_GastosAdmin * -1;
						B3_Seguro:=B3_Seguro * -1;
						B4_GarantiaExtendida:=B4_GarantiaExtendida * -1;
						B7_UtilidadBrutaAccesorios:=B7_UtilidadBrutaAccesorios * -1;
					end if;
				
					B12_GastosAdmin := rec_J_PORCENTAJES.c10 * B2_GastosAdmin/100;
				 	B13_Seguro := rec_J_PORCENTAJES.c11 * B3_Seguro/100;
				 	B14_Garantia := rec_J_PORCENTAJES.c13 * B4_GarantiaExtendida/100;
				 	B17_Accesorios := rec_J_PORCENTAJES.c12 * B7_UtilidadBrutaAccesorios/100;

--raise notice 'Descto traspaso';
					/*
					SUB CALCULA_DESCUENTO_TRASPASO
					 B20=B11*H8/100
					 IF BUS(T,1,0,K1,K8,ULT)>0 AND T39><"N" THEN
					  B20=-B11*H7/100
					 ENDIF
					ENDSUB
					*/
					B20_Traslado:=B11_ComisionSinBonos*rec_H_VESQ.c8/100; --c8=Aumento por unidad de invent
					select * into rec_T_ICOM from keplersc.kdicom
						where c1=rec_K_COMISMOV.c1 and c2=rec_K_COMISMOV.c8 order by c3 desc limit 1;  
					if found then
						if rec_T_ICOM.c39 <> 'S' then
							B20_Traslado:=(B11_ComisionSinBonos*rec_H_VESQ.c7/100) * -1; --c7=descuento por traspaso
						end if;
					end if;
						--Sucursal, inventario, partida

					/*
					SUB CALCULA_BONO_POR_LINEA
					 B19=0
					 IF BUS(L,1,0,I5)>0 AND L3=10 AND BUS(U,1,0,K12)>0 AND BUS(M,1,0,A1,F8,RIGHT("00000"+A7,2),RIGHT("00000"+A6,2),U7)>0 THEN 'BUSCANDO POR LINEA DEL VEHICULO
					   B19=(M6*B1/100)
					 ENDIF
					 IF BUS(L,1,0,I5)>0 AND L3=10 AND BUS(M,1,0,A1,F8,RIGHT("00000"+A7,2),RIGHT("00000"+A6,2),K12)>0 THEN 'BUSCANDO POR MODELO DEL VEHICULO
					   B19=(M6*B1/100)
					 ENDIF
					ENDSUB 
					 */				
				
					B19_Linea:=0;
					rec_M_VOBJLINEA := null;
					if rec_L_TIPOCOMIS is not null then --Obtenido anteriormente en base
						if rec_L_TIPOCOMIS.c3=10 then --c10=tipo=[10]Utilidad
							select * into rec_U_IV from keplersc.kdiv 
								where c1=rec_K_COMISMOV.c12 limit 1; --c1=Clave del vehiculo, k.c12= modelo
							if found then
								select * into rec_M_VOBJLINEA from keplersc.kdvobjlinea
									where c1=sucursal_id and c2=rec_F_UV.c8 and c3=lpad(anio,2,'0') and c4=lpad(mes,2,'0') and c5=rec_U_IV.c7 limit 1;
									--Sucursal, Esquema, Anio, Mes, Linea; BUS(M,1,0,A1,F8,RIGHT("00000"+A7,2),RIGHT("00000"+A6,2),U7)>0 THEN 'BUSCANDO POR LINEA DEL VEHICULO
								if found then
									B19_Linea:= rec_M_VOBJLINEA.c6 * B1_UtilidadBruta/100; --m.c6=Bono
								end if;
							end if;
						end if;
					end if;						

--raise notice 'Boni linea';				
					--CALCULA_BONO_POR_LINEA, BUSCANDO POR MODELO DEL VEHICULO
					if rec_L_TIPOCOMIS is not null then --Obtenido anteriormente en base
						if rec_L_TIPOCOMIS.c3=10 then --c10=tipo=[10]Utilidad
							select * into rec_M_VOBJLINEA from keplersc.kdvobjlinea
								where c1=sucursal_id and c2=rec_F_UV.c8 and c3=lpad(anio,2,'0') and c4=lpad(mes,2,'0') and c5=rec_K_COMISMOV.c12;
								--Sucursal, Esquema, Anio, Mes, Linea; BUS(M,1,0,A1,F8,RIGHT("00000"+A7,2),RIGHT("00000"+A6,2),K12)>0 THEN 'BUSCANDO POR MODELO DEL VEHICULO
							if found then
								B19_Linea:= rec_M_VOBJLINEA.c6 * B1_UtilidadBruta/100; --m.c6=Bono
							end if;
						end if;
					end if;
				
--raise notice 'Bono semanal';				
					/*
					SUB CALCULA_BONO_SEMANAL
					 B21=0
					 IF K7<=D3 THEN B21=H25: ENDIF'PRIMERA SEMANA
					 IF K7>D3 AND K7<=D4 THEN B21=H26: ENDIF'SEGUNDA SEMANA
					 IF K7>D4 AND K7<=D5 THEN B21=H27: ENDIF'TERCERA SEMANA
					 IF K7>D5 AND K7<=D6 THEN B21=H28: ENDIF'CUARTA SEMANA
					 B21=B21*B1/100
					ENDSUB
					 */				
					B21_BonoSemanal:=0;
					if rec_K_COMISMOV.c7 <= D3_fechaPrimCorte then
						B21_BonoSemanal:=rec_H_VESQ.c25;
					end if;
					if rec_K_COMISMOV.c7 > D3_fechaPrimCorte and rec_K_COMISMOV.c7 <= D4_fechaSegCorte then
						B21_BonoSemanal:=rec_H_VESQ.c26;
					end if;
					--TO VER D5 y D6 estan en K75, pero no estan definidas, el calculo es quincenal no semanal
					B21_BonoSemanal := B21_BonoSemanal * B1_UtilidadBruta/100;

--raise notice 'Comis TMKT';
					/*
					SUB CALCULA_COMISION_TMKT
					 B22=SUM(B11...B21)
					 B23=0
					 IF BUS(V,1,0,K1...K6,K10)>0 AND V9><"SA" THEN
					   B23=-B22*Y2/100'COMISION DEL ASESOR DE TMKT
					 ENDIF
					 B24=B22+B23
					ENDSUB 
					 */				
					B22_ComisAntesTmkt:= B11_ComisionSinBonos +	B12_GastosAdmin+
 						B13_Seguro + B14_Garantia + B17_Accesorios +
						B18_ComisionEdad + B19_Linea + B20_Traslado + B21_BonoSemanal;
				
					B23_DescuentoAsesorTmkt:=0;
					rec_V_COMISMOV2:=null;
					--TO VER Tabla de KDCONFIGCC en Subaru esta vacia, validar registros
					/*
					select * into rec_V_COMISMOV2 from keplersc.kdcomismov2 
						where c1=rec_K_COMISMOV.c1 and c2=rec_K_COMISMOV.c2 and c3= rec_K_COMISMOV.c3 and 
						c4=rec_K_COMISMOV.c4 and c5=rec_K_COMISMOV.c5 and c6=rec_K_COMISMOV.c6 	and 
						c10=rec_K_COMISMOV.c10;
						--Sucursal,Genero,Naturaleza,Grupo,Tipo,Folio,Tipo						
					if found then
						if rec_V_COMISMOV2.c9 <> 'SA' then --Contacto asignado
							B23_DescuentoAsesorTmkt:=B22_ComisAntesTmkt*
						end if;
					end if;
					
					*/
					B24_ComisionTotal:=B22_ComisAntesTmkt-B23_DescuentoAsesorTmkt;
					
					--INGRESANDO LAS COMISIONES DE TODO EL MES
--raise notice 'Valida guardar Mensual';
					if N5=4 then
--raise notice 'Calcs previos Mensual';					
						--IF BUS(Z,1,0,A1,A7,A6,F2,0,K8,ULT)>0 THEN N8=Z7+1: ENDIF					
						select max(c7) into N8_Consecutivo from keplersc.kdcomisventas 
							where c1=sucursal_id and c2=lpad(anio,2,'0') and c3=mes --c3=lpad(mes,2,'0') 
							and c4=rec_F_UV.c2 and c5=0 and c6=rec_K_COMISMOV.c8;
						if N8_Consecutivo is not null then
							N8_Consecutivo:=N8_Consecutivo + 1;
						else
							N8_Consecutivo:=1;
						end if;
					
						--Asignar valores de registros
						rec_ZM_COMISVENTAS.c15:='';
						rec_ZM_COMISVENTAS.c18:='';
						if rec_M_VOBJLINEA is not null then
							rec_ZM_COMISVENTAS.c15:=rec_M_VOBJLINEA.c5;
						end if;
						if rec_V_COMISMOV2 is not null then
							rec_ZM_COMISVENTAS.c18:=rec_V_COMISMOV2.c9;
						end if;
--raise notice 'Inserta Mensual';					
				        --INS(Z,A1,A7,A6,F2,0,
				        --K8,N8,K10,K7,K11,
				        --K12,E4,E21,K25,M5,
				        --T39,N12,V9,
				        --B1...B7,B11,B20,B18,B19,B12,B13,B14,B17,B21...B24)
				
--raise notice 'INI Inserta Mensual ciclo n5: %, asesor: %',N5,rec_F_UV.c2;					
						insert into keplersc.kdcomisventas(c1,c2,c3,c4,c5,
						c6,c7,c8,c9,c10,
						c11,c12,c13,c14,c15,
						c16,c17,c18,
						c19,c20,
						c21,c22,c23,c24,c25,
						c26,c27,c28,c29,c30,
						c31,c32,c33,c34,c35,
						c36,c37) values(sucursal_id,anio,mes,rec_F_UV.c2,0,
						rec_K_COMISMOV.c8,N8_Consecutivo,rec_K_COMISMOV.c10::int,rec_K_COMISMOV.c7,rec_K_COMISMOV.c11,
						rec_K_COMISMOV.c12,substring(rec_E_INF.c4,1,30),rec_E_INF.c21,rec_K_COMISMOV.c25,rec_ZM_COMISVENTAS.c15,
						rec_T_ICOM.c39,N12_EdadInventario,rec_ZM_COMISVENTAS.c18,
						B1_UtilidadBruta,B2_GastosAdmin,
						B3_Seguro,B4_GarantiaExtendida,B5_NotaDescuento,B6_Subsidio,B7_UtilidadBrutaAccesorios,
						B11_ComisionSinBonos,B20_Traslado,B18_ComisionEdad,B19_Linea,B12_GastosAdmin,
		 				B13_Seguro,B14_Garantia,B17_Accesorios,B21_BonoSemanal,	B22_ComisAntesTmkt,
						B23_DescuentoAsesorTmkt,B24_ComisionTotal);	
--raise notice 'FIN Inserta Mensual ciclo n5: %, asesor: %',N5,rec_F_UV.c2;

						--INSERTANDO EL MOVIMIENTO CUANDO HAY ASESOR DE TELEMARKETING INVOLUCRADO
						if rec_V_COMISMOV2 is not null then
							--TO DO Completar esquema cuando hay asesor TMKT, validar con K57
							if rec_V_COMISMOV2.c9<>'SA' then --IF V9><"SA"
								N8_Consecutivo:=N8_Consecutivo + 1;
								--INS(Z,A1,A7,A6,V9,30,K8,N8,K10,K7,K11,K12,E4,E21,K25,M5,T39,N12,F2,B1...B7,B11,B20,B18,B19,B12,B13,B14,B17,B21,B22,-B24,-B23)							
							end if;
						end if ;
					end if; --Fin N5 = 4
					N6:=0;
--raise notice 'Valida guardar Quincenal';				
					if N5<5 then 
--raise notice 'Calcs previos quincenal';					
						N6:=N5-2; --N6=N5-2'QUINCENA
						--IF BUS(Z,1,0,A1,A7,A6,N6,F2,0,K8,ULT)>0 THEN N8=Z8+1: ENDIF
--raise notice 'INI A mes:%',mes;
						select max(c8) into N8_Consecutivo from keplersc.kdcomisquincena
							where c1=sucursal_id and c2=lpad(anio,2,'0') and c3=mes -- c3=lpad(mes,2,'0') 
							and c4=N6 and c5=rec_F_UV.c2 and c6=0 and c7=rec_K_COMISMOV.c8;
--raise notice 'Calcs previos quincenal 0';						
						if N8_Consecutivo is not null then
							N8_Consecutivo:=N8_Consecutivo + 1;
						else
							N8_Consecutivo:=1;
						end if;

						rec_ZQ_COMISQUINCENA.c16:='';					
						rec_ZQ_COMISQUINCENA.c19:='';
--raise notice 'Calcs previos quincenal A';					
						if rec_M_VOBJLINEA is not null then
							rec_ZQ_COMISQUINCENA.c16:=rec_M_VOBJLINEA.c5;
						end if;			
--raise notice 'Calcs previos quincenal B';
						if rec_V_COMISMOV2 is not null then
							rec_ZQ_COMISQUINCENA.c19:=rec_V_COMISMOV2.c9;
						end if;	
--raise notice 'Calcs previos quincenal C';					
        				--INS(Z,A1,A7,A6,N6,F2,0,
        				--K8,N8,K10,K7,K11,
        				--K12,E4,E21,K25,M5,
        				--T39,N12,V9,B1...B7,B11,B20,B18,B19,B12,B13,B14,B17,B21...B24)

--raise notice 'INI Inserta Quincenal  for: Vendedor:%, Tipo Oper:%, N5:% Vtas. comisionar:%',rec_F_UV.c2,rec_G_TOP.c1,N5,rec_K_COMISMOV.c8;
						insert into keplersc.kdcomisquincena(c1,c2,c3,c4,c5,c6,
						c7,c8,c9,c10,c11,
						c12,c13,c14,c15,c16,
						c17,c18,c19,c20,c21,
						c22,c23,c24,c25,c26,
						c27,c28,c29,c30,c31,
						c32,c33,c34,c35,c36,
						c37,c38) values(sucursal_id,anio,mes,N6,rec_F_UV.c2,0,
						rec_K_COMISMOV.c8,N8_Consecutivo,rec_K_COMISMOV.c10::int,rec_K_COMISMOV.c7,rec_K_COMISMOV.c11,
						rec_K_COMISMOV.c12,substring(rec_E_INF.c4,1,30),rec_E_INF.c21,rec_K_COMISMOV.c25,rec_ZQ_COMISQUINCENA.c16,
						rec_T_ICOM.c39,N12_EdadInventario,rec_ZQ_COMISQUINCENA.c19,B1_UtilidadBruta,B2_GastosAdmin,
						B3_Seguro,B4_GarantiaExtendida,B5_NotaDescuento,B6_Subsidio,B7_UtilidadBrutaAccesorios,
						B11_ComisionSinBonos,B20_Traslado,B18_ComisionEdad,B19_Linea,B12_GastosAdmin,
		 				B13_Seguro,B14_Garantia,B17_Accesorios,B21_BonoSemanal,	B22_ComisAntesTmkt,
						B23_DescuentoAsesorTmkt,B24_ComisionTotal);	
--raise notice 'FIN Inserta Quincenal  for: Vendedor:%, Tipo Oper:%, N5:% Vtas. comisionar:%',rec_F_UV.c2,rec_G_TOP.c1,N5,rec_K_COMISMOV.c8;
--raise notice 'FIN A mes:%',mes;
												--INSERTANDO EL MOVIMIENTO CUANDO HAY ASESOR DE TELEMARKETING INVOLUCRADO
						if rec_V_COMISMOV2 is not null then
							--TO DO Completar esquema cuando hay asesor TMKT, validar con K57
							if rec_V_COMISMOV2.c9<>'SA' then --IF V9><"SA"
								N8_Consecutivo:=N8_Consecutivo + 1;
								--INS(Z,A1,A7,A6,V9,30,K8,N8,K10,K7,K11,K12,E4,E21,K25,M5,T39,N12,F2,B1...B7,B11,B20,B18,B19,B12,B13,B14,B17,B21,B22,-B24,-B23)							
							end if;
						end if ;					
					end if; --Fin N5<5
				end loop; --FIN Loop por ventas a comisionar rec_K_COMISMOV
   			end loop; --FIN Loop for N5 in 3..4 
		end loop; --FIN Loop tipo de Operacion
--raise notice 'FIN LOOP 1';

		for N5 in 3..4 loop --Quincena, Mes TOMAS
			/*
			SUB BONO_POR_TOMAS
			 VIEW(T,6) WHILE T1=A1 AND T41=F2 AND T9>=A2 AND T9<=D(N5)
			  IF BUS(E,1,0,T1,T2)>0 THEN
			   B11=H10
			   IF E3=H14 THEN
			    B11+=H15
			   ENDIF
			   N9=0: IF T12=10 THEN N9=1: B11=-B11: ENDIF'TRANSFORMANDO LAS BAJAS PARA QUE ESTEN EQUIVALENTES
			   IF N5=4 THEN 'INGRESANDO LAS COMISIONES DE TODO EL MES
			     OPEN(Z,KDCOMISVENTAS)
			     N8=1: IF BUS(Z,1,0,A1,A7,A6,F2,10,K8,ULT)>0 THEN N8=Z7+1: ENDIF
			     INS(Z,A1,A7,A6,F2,10,T2,N8,N9,T9,"",E3,E4,E21,E15,F7,"",0,"",0,0,0,0,0,0,0,B11,0,0,0,0,0,0,0,0,B11,0,B11)
			     CLOSE(Z)
			   ENDIF
			   OPEN(Z,KDCOMISQUINCENA)
			   N6=N5-2'QUINCENA
			   N8=1: IF BUS(Z,1,0,A1,A7,A6,N6,F2,10,K8,ULT)>0 THEN N8=Z8+1: ENDIF
			   INS(Z,A1,A7,A6,N6,F2,10,T2,N8,N9,T9,"",E3,E4,E21,E15,F7,"",0,"",0,0,0,0,0,0,0,B11,0,0,0,0,0,0,0,0,B11,0,B11)
			   CLOSE(Z)
			  ENDIF
			 LOOP
			ENDSUB
			 */
			if N5=3 then 
				dateValor:= D3_fechaPrimCorte;
			else
				dateValor:=D4_fechaSegCorte;
			end if;

			--VIEW(T,6) WHILE T1=A1 AND T41=F2 AND T9>=A2 AND T9<=D(N5)
			for rec_T_ICOM in select * from keplersc.kdicom --INI Loop BONO TOMAS			
				where c1=sucursal_id and c41=rec_F_UV.c2 and c9>=A2_fechaIniMes and c9<=dateValor
				order by c1,c41,c9
			loop
--raise notice 'PASO TOMAS 1';
				--IF BUS(E,1,0,T1,T2)>0 THEN Sucursl_id, Inventario
				select * into rec_E_INF from keplersc.kdinf where c1=rec_T_ICOM.c1	and c2=rec_T_ICOM.c2 limit 1;
				if found then
					B11_ComisionSinBonos:=rec_H_VESQ.c10; --B11=H10 Bono por toma
					if rec_E_INF.c3=rec_H_VESQ.c14 then  --IF E3=H14 then Clave vehiculo
						B11_ComisionSinBonos:=B11_ComisionSinBonos + rec_H_VESQ.c15; --Bono seminuevos certificados
					end if;
					N9:=0;
					if rec_T_ICOM.c12=10 then
						N9:=1;
						B11_ComisionSinBonos:=B11_ComisionSinBonos * -1;
					end if; --TRANSFORMANDO LAS BAJAS PARA QUE ESTEN EQUIVALENTES
					if N5=4 then
						--INGRESANDO LAS COMISIONES DE TODO EL MES
						N8_Consecutivo:=1;
						--BUS(Z,1,0,A1,A7,A6,F2,10,K8,ULT)
					
						select max(c7) into N8_Consecutivo from keplersc.kdcomisventas
							where c1=sucursal_id and c2=lpad(anio,2,'0') and c3=mes --c3=lpad(mes,2,'0') 
							and c4=rec_F_UV.c2 and c5=10 and c6=rec_T_ICOM.c2;
						if N8_Consecutivo is not null then
							N8_Consecutivo:=N8_Consecutivo + 1;
						else
							N8_Consecutivo:=1;
						end if;
						--INS(Z,A1,A7,A6,F2,10,
						--T2,N8,N9,T9,"",
						--E3,E4,E21,E15,F7,
						--"",0,"",0,0,
						--0,0,0,0,0,
						--B11,0,0,0,0,
						--0,0,0,0,B11,
						--0,B11)					
						insert into keplersc.kdcomisventas(c1,c2,c3,c4,c5,
						c6,c7,c8,c9,c10,
						c11,c12,c13,c14,c15,
						c16,c17,c18,c19,c20,
						c21,c22,c23,c24,c25,
						c26,c27,c28,c29,c30,
						c31,c32,c33,c34,c35,
						c36,c37) values(sucursal_id,anio,mes,rec_F_UV.c2,10,
						rec_T_ICOM.c2,N8_Consecutivo,N9,rec_T_ICOM.c9,'',
						rec_E_INF.c3,substring(rec_E_INF.c4,1,30),rec_E_INF.c21,rec_E_INF.c15,rec_E_INF.c7,
						'',0,'',0,0,
						0,0,0,0,0,
						B11_ComisionSinBonos,0,0,0,0,
		 				0,0,0,0,B11_ComisionSinBonos,
						0,B11_ComisionSinBonos);						
					end if;
				

					N6:=N5-2;
					--BUS(Z,1,0,A1,A7,A6,N6,F2,10,K8,ULT)>0
--raise notice 'B mes:%',mes;
--raise notice 'Sucursal:%, Anio:% Mes:%, c4(N6):%, c5(rec_F_UV.c2):%, c6:%, c7:%',
--	sucursal_id,anio,mes,N6,rec_F_UV.c2,10,rec_T_ICOM.c2;
					select max(c8) into N8_Consecutivo from keplersc.kdcomisquincena
						where c1=sucursal_id and c2=lpad(anio,2,'0') and c3=mes --c3=lpad(mes,2,'0') 
						and c4=N6 and c5=rec_F_UV.c2 and c6=10 and c7=rec_T_ICOM.c2;
--raise notice 'Consec max:%',N8_Consecutivo;					
					if N8_Consecutivo is not null then
						N8_Consecutivo:=N8_Consecutivo + 1;
					else
						N8_Consecutivo:=1;
					end if;	
					--INS(Z,A1,A7,A6,N6,F2,10,
					--T2,N8,N9,T9,"",
					--E3,E4,E21,E15,F7,
					--"",0,"",0,0,
					--0,0,0,0,0,
					--B11,0,0,0,0,
					--0,0,0,0,B11,
					--0,B11)
					insert into keplersc.kdcomisquincena(c1,c2,c3,c4,c5,c6,
					c7,c8,c9,c10,c11,
					c12,c13,c14,c15,c16,
					c17,c18,c19,c20,c21,
					c22,c23,c24,c25,c26,
					c27,c28,c29,c30,c31,
					c32,c33,c34,c35,c36,
					c37,c38) values(sucursal_id,anio,mes,N6,rec_F_UV.c2,10,
					rec_T_ICOM.c2,N8_Consecutivo,N9,rec_T_ICOM.c9,'',
					rec_E_INF.c3,substring(rec_E_INF.c4,1,30),rec_E_INF.c21,rec_E_INF.c15,rec_E_INF.c7,
					'',0,'',0,0,
					0,0,0,0,0,
					B11_ComisionSinBonos,0,0,0,0,
	 				0,0,0,0,B11_ComisionSinBonos,
					0,B11_ComisionSinBonos);				
				end if;
--raise notice 'FIN B mes:%',mes;
			end loop; --FIN BONO TOMAS rec_T_ICOM	
		
			/*
			SUB BONO_POR_TOMAS_VENDIDAS
			 SET(0,N4)
			 VIEW(V,4) WHILE V1=A1 AND V12=F2 AND V7>=A2 AND V7<=D(N5)
			  IF BUS(T,1,0,V1,V8,ULT)>0 AND BUS(X,3,1,V1,V8)>0 THEN
			   N4=X7-T9
			   IF N4<=H11 THEN
			    B11=H12: IF V10><0 THEN B11=-H12: ENDIF
			    IF N5=4 THEN 'INGRESANDO LAS COMISIONES DE TODO EL MES
			     OPEN(Z,KDCOMISVENTAS)
			     N8=1: IF BUS(Z,1,0,A1,A7,A6,F2,20,K8,ULT)>0 THEN N8=Z7+1: ENDIF
			     INS(Z,A1,A7,A6,F2,20,V8,N8,V10,V7,V11,E3,E4,E21,E15,F7,"",0,"",0,0,0,0,0,0,0,B11,0,0,0,0,0,0,0,0,B11,0,B11)
			     CLOSE(Z)
			    ENDIF
			    OPEN(Z,KDCOMISQUINCENA)
			    N6=N5-2'QUINCENA
			    N8=1: IF BUS(Z,1,0,A1,A7,A6,N6,F2,20,K8,ULT)>0 THEN N8=Z8+1: ENDIF
			    INS(Z,A1,A7,A6,N6,F2,20,V8,N8,V10,V7,V11,E3,E4,E21,E15,F7,"",0,"",0,0,0,0,0,0,0,B11,0,0,0,0,0,0,0,0,B11,0,B11)
			    CLOSE(Z)
			   ENDIF
			  ENDIF
			 LOOP
			ENDSUB
			 */

			N4:=0;
			--VIEW(V,4) WHILE V1=A1 AND V12=F2 AND V7>=A2 AND V7<=D(N5)
--raise notice 'BONO TOMAS Vendidas Sucursal:%, c41:% A2_fechaIniMes:%, dateValor:%',sucursal_id,rec_F_UV.c2,A2_fechaIniMes,dateValor;		
			for rec_V_COMISMOV2 in select * from keplersc.kdcomismov2 k  --INI Loop 
				where c1=sucursal_id and c12=rec_F_UV.c2 and c7>=A2_fechaIniMes and c7<=dateValor
				order by c1,c12,c7
			loop
--raise notice 'PASO 1, rec_V_COMISMOV2.c1:%, rec_V_COMISMOV2.c8:% ',rec_V_COMISMOV2.c1, rec_V_COMISMOV2.c8;
				select * into rec_T_ICOM from keplersc.kdicom k2  --IF BUS(T,1,0,V1,V8,ULT)>0 AND BUS(X,3,1,V1,V8)>0 then
					where c1=rec_V_COMISMOV2.c1 and c2=rec_V_COMISMOV2.c8 limit 1;
				if found then
					select * into rec_E_INF from keplersc.kdinf where c1=rec_T_ICOM.c1	and c2=rec_T_ICOM.c2 limit 1;
					if not found then
						continue;
					end if;
--raise notice 'PASO 2, rec_V_COMISMOV2.c1:%, rec_V_COMISMOV2.c8:%',rec_V_COMISMOV2.c1,rec_V_COMISMOV2.c8;				
					--TO VER: Validar que el registro obtenido corresponda al del k75 esperado
					select * into rec_X_COMISMOV2 from keplersc.kdcomismov2 k 
						where c1=rec_V_COMISMOV2.c1 and c8=rec_V_COMISMOV2.c8
						order by c1,c8,c2,c3,c4,c5,c6,c10 limit 1; --Obtiene el registro mas reciente
					if found then
						N4:=date_part('day',rec_X_COMISMOV2.c7-rec_T_ICOM.c9); --N4=X7-T9
--raise notice 'PASO 3, rec_X_COMISMOV2.c7:%, rec_T_ICOM.c9:%, Dif(N4):%',rec_X_COMISMOV2.c7,rec_T_ICOM.c9,N4 ;						
						--N4:=rec_X_COMISMOV2.c7-rec_T_ICOM.c9; --N4=X7-T9
--raise notice 'PASO 4 N4:%, rec_H_VESQ.c11:%', N4, rec_H_VESQ.c11;
						if N4<=rec_H_VESQ.c11 then --IF N4<=H11 then
					
							--NGRESANDO LAS COMISIONES DE TODO EL MES
							B11_ComisionSinBonos:=rec_H_VESQ.c12; --B11=H12:
--raise notice 'PASO 5';								
							if rec_V_COMISMOV2.c10 <> '0' then  --IF V10><0 then
						
								B11_ComisionSinBonos:=rec_H_VESQ.c12 * -1; --B11=-H12:
							end if;
	
							if N5=4 then --TODO EL MES
--raise notice 'PASO 7';							
								N8_Consecutivo=1;
								--BUS(Z,1,0,A1,A7,A6,F2,20,K8,ULT)>0
								select max(c7) into N8_Consecutivo from keplersc.kdcomisventas
									where c1=sucursal_id and c2=lpad(anio,2,'0') and c3=mes  --c3=lpad(mes,2,'0') 
									and c4=rec_F_UV.c2 and c5=20 and c6=rec_V_COMISMOV2.c8;
								if N8_Consecutivo is not null then
									N8_Consecutivo:=N8_Consecutivo + 1;
								else
									N8_Consecutivo:=1;
								end if;	
     							--INS(Z,A1,A7,A6,F2,20,
     							--V8,N8,V10,V7,V11,
     							--E3,E4,E21,E15,F7,
     							--"",0,"",0,0,
     							--0,0,0,0,0,
     							--B11,0,0,0,0,
     							--0,0,0,0,B11,
     							--0,B11)     														
								insert into keplersc.kdcomisventas(c1,c2,c3,c4,c5,
								c6,c7,c8,c9,c10,
								c11,c12,c13,c14,c15,
								c16,c17,c18,c19,c20,
								c21,c22,c23,c24,c25,
								c26,c27,c28,c29,c30,
								c31,c32,c33,c34,c35,
								c36,c37) values(sucursal_id,anio,mes,rec_F_UV.c2,20,
								rec_V_COMISMOV2.c8,N8_Consecutivo,rec_V_COMISMOV2.c10::int,rec_V_COMISMOV2.c7,rec_V_COMISMOV2.c11,
								rec_E_INF.c3,substring(rec_E_INF.c4,1,30),rec_E_INF.c21,rec_E_INF.c15,rec_E_INF.c7,
								'',0,'',0,0,
								0,0,0,0,0,
								B11_ComisionSinBonos,0,0,0,0,
				 				0,0,0,0,B11_ComisionSinBonos,
								0,B11_ComisionSinBonos);
							end if; --N5=4
					
							N6:=N5-2;
							N8_Consecutivo:=1;
							--BUS(Z,1,0,A1,A7,A6,N6,F2,20,K8,ULT)>0
--raise notice 'INI C mes:%',mes;
							select max(c8) into N8_Consecutivo from keplersc.kdcomisquincena
								where c1=sucursal_id and c2=lpad(anio,2,'0') and c3=mes --c3=lpad(mes,2,'0') 
								and c4=N6 and c5=rec_F_UV.c2 and c6=20 and c7=rec_V_COMISMOV2.c8;
							if N8_Consecutivo is not null then
								N8_Consecutivo:=N8_Consecutivo + 1;
							else
								N8_Consecutivo:=1;
							end if;
							--INS(Z,A1,A7,A6,N6,F2,20,
							--V8,N8,V10,V7,V11,
							--E3,E4,E21,E15,F7,
							--"",0,"",0,0,
							--0,0,0,0,0,
							--B11,0,0,0,0,
							--0,0,0,0,B11,
							--0,B11)
							insert into keplersc.kdcomisquincena(c1,c2,c3,c4,c5,c6,
							c7,c8,c9,c10,c11,
							c12,c13,c14,c15,c16,
							c17,c18,c19,c20,c21,
							c22,c23,c24,c25,c26,
							c27,c28,c29,c30,c31,
							c32,c33,c34,c35,c36,
							c37,c38) values(sucursal_id,anio,mes,N6,rec_F_UV.c2,20,
							rec_V_COMISMOV2.c8,N8_Consecutivo,rec_V_COMISMOV2.c10::int,rec_V_COMISMOV2.c7,rec_V_COMISMOV2.c11,
							rec_E_INF.c3,substring(rec_E_INF.c4,1,30),rec_E_INF.c21,rec_E_INF.c15,rec_E_INF.c7,
							'',0,'',0,0,
							0,0,0,0,0,
							B11_ComisionSinBonos,0,0,0,0,
			 				0,0,0,0,B11_ComisionSinBonos,
							0,B11_ComisionSinBonos);
--raise notice 'INI C mes:%',mes;						
						end if;-- end if N4<=rec_H_VESQ.c11 
					end if; --found en rec_X_COMISMOV2
				end if; --found en rec_T_ICOM
			end loop; -- loop en rec_V_COMISMOV2		
		end loop; --FIN loop Quincena mes TOMAS
	end loop; --FIN Loop sobre vendedores, rec_F_UV
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

/*
exception

	when others then
		resultado := 0;
		mensaje := 'com_ventas_generar() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
*/		
end;
/*
(E,KDINF,F,KDUV,G,KDTOP,H,KDVESQ,I,KDVESQVEH,J,KDPORCENTAJES,
 K,KDCOMISMOV,L,KDTIPOCOMIS,M,KDVOBJLINEA,S,KDMS,O,KDNCRED,
 P,KDCOMISADIS,Q,KDPEDIDO,T,KDICOM,U,KDIV,V,KDCOMISMOV2,
 X,KDCOMISMOV2,Y,KDCONFIGCC)
 
	rec_F_UV record; --Registro vendedores
	rec_H_VESQ record; --Registro de esquema por vendedor
	rec_G_TOP record; --Registro de tipo de operacion
	rec_K_COMISMOV record; --Registro de Comisiones
	rec_Z_COMISVENTAS record;
	rec_E_INF record;
	rec_I_VESQVEH record;
	rec_J_PORCENTAJES record;
	rec_L_TIPOCOMIS record;
	rec_P_COMISADIS record;
	rec_T_ICOM record;
	rec_U_IV record;
	rec_M_VOBJLINEA	record;
	rec_V_COMISMOV2 record
*/
$function$
