CREATE OR REPLACE FUNCTION keplersc.registroriginalreemplazos()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: Actualiza el registro de originales y reemplazos
--Autor: Miriam Santana
--Fecha: 13/02/2024
--Bitacora de cambios
declare
totReg int;
fecha_operacion date;
rec record;
rec_cadena record;
tmpCadena text='';
folio_anulacion text;
cont int=0;
i int =0;
cadena_totales int=0;
original text;
cuenta int=0;
arraycadena text[];
string text='';
existe text='';

cantentradas decimal=0.00;
cantsalidas decimal=0.00;
totentradas decimal=0.00;
totsalidas decimal=0.00;
ultcosto decimal=0.00;
penultcosto decimal=0.00;
fec_ultventa date='1800-01-01 00:00:00';
fec_ultcompra date='1800-01-01 00:00:00';
fec_penultventa date='1800-01-01 00:00:00';
fec_penultcompra date='1800-01-01 00:00:00';
revisar text='';

o_cantentradas decimal=0.00;
o_cantsalidas decimal=0.00;
o_totentradas decimal=0.00;
o_totsalidas decimal=0.00;
o_ultcosto decimal=0.00;
o_penultcosto decimal=0.00;
o_fec_ultventa date='1800-01-01 00:00:00';
o_fec_ultcompra date='1800-01-01 00:00:00';
o_fec_penultventa date='1800-01-01 00:00:00';
o_fec_penultcompra date='1800-01-01 00:00:00';

cantEene decimal=0.00; cantEfeb decimal=0.00; cantEmar decimal=0.00; cantEabr decimal=0.00; cantEmay decimal=0.00; cantEjun decimal=0.00;
cantEjul decimal=0.00; cantEago decimal=0.00; cantEsep decimal=0.00; cantEoct decimal=0.00; cantEnov decimal=0.00; cantEdic decimal=0.00; 					
montEene decimal=0.00; montEfeb decimal=0.00; montEmar decimal=0.00; montEabr decimal=0.00; montEmay decimal=0.00; montEjun decimal=0.00; 					
montEjul decimal=0.00; montEago decimal=0.00; montEsep decimal=0.00; montEoct decimal=0.00; montEnov decimal=0.00; montEdic decimal=0.00; 					
cantSene decimal=0.00; cantSfeb decimal=0.00; cantSmar decimal=0.00; cantSabr decimal=0.00; cantSmay decimal=0.00; cantSjun decimal=0.00; 					
cantSjul decimal=0.00; cantSago decimal=0.00; cantSsep decimal=0.00; cantSoct decimal=0.00; cantSnov decimal=0.00; cantSdic decimal=0.00; 					
montSene decimal=0.00; montSfeb decimal=0.00; montSmar decimal=0.00; montSabr decimal=0.00; montSmay decimal=0.00; montSjun decimal=0.00; 
montSjul decimal=0.00; montSago decimal=0.00; montSsep decimal=0.00; montSoct decimal=0.00; montSnov decimal=0.00; montSdic decimal=0.00; 
						


begin
/*
--1.Originales
--select * from keplersc.kdini k where c1='0446542180' or c1='0446542150'
--Solo dejar registro de originales
--Barrer la tabla y buscar reemplazos o cadena de reemplazos y por cada uno buscar en kdini y poner una marca en c3 para saber que seran eliminados y revisarlos, despues eliminarlos, solo dejar originales

raise notice 'Proceso Originales';
	for rec in select * from keplersc.kdini order by c1 asc
	loop 
		cuenta:=cuenta+1;
		raise notice 'rec.c1:% %',cuenta,rec.c1;
		if rec.c1 = '' or rec.c1 is null then
			continue;
		else
			select * into original from keplersc.prod_obtener_original(rec.c1);
			if original<>rec.c1 then		--solo si es reemplazo
				for rec_cadena in select * from keplersc.prod_consulta_lista('01',rec.c1,'CLAVE') where clave_actual=rec.c1 limit 1
				loop
					if rec_cadena.cadena_reemplazo ='' or rec_cadena.cadena_reemplazo is null then
					
					else
						--119571|121732|122727	
						raise notice 'Cadena reemplazo:%',coalesce(rec_cadena.cadena_reemplazo,'Sin cadena');
					
						arraycadena := string_to_array(rec_cadena.cadena_reemplazo,'|');
						
					raise notice 'arraycadena:% ',arraycadena;
	
						for cont in array_lower(arraycadena,1) .. array_upper(arraycadena,1)loop
							tmpCadena := split_part(rec_cadena.cadena_reemplazo, '|', cont);
							raise notice 'Split cadena:%',tmpCadena;
							--Valida que es un original
						raise notice 'original:% tmpCadena:%', original,tmpCadena;
							if original=tmpCadena then
								raise notice 'Es original:%',tmpCadena;
								continue;
							else
								--Es reemplazo
									select c1 into existe from keplersc.kdini
										where c1=tmpCadena and c3='';
									if found then
									raise notice 'Es reemplazo y se marca con R:%, para revisar y borrar despues',tmpCadena;
--										update keplersc.kdini set c3='R'
--											where c1=tmpCadena and c3='';
									end if;								
							end if;
							cadena_totales=cadena_totales+1;
						
							
						end loop;
						raise notice '% cadena totales:% ',rec.c1,cadena_totales+1;
						cadena_totales := 0;
					end if;
				end loop;
			end if;
		end if;
		original := '';
	end loop;
*/


/*	
---------------------------------------
--2. Reemplazos
--select * from keplersc.kdinr k where c1='0446542180' or c1='0446542150'
--Por cada registro buscar su original y buscarlo en c1 para saber si hay algun original como reemplazo

raise notice 'Proceso Reemplazos';
	original:='';
	cuenta:=0;
	for rec in select * from keplersc.kdinr order by c1 asc
	loop 
		cuenta:=cuenta+1;
		raise notice 'rec.c1:% %',cuenta,rec.c1;
		if rec.c1 = '' or rec.c1 is null then
			continue;
		else
			select * into original from keplersc.prod_obtener_original(rec.c1);
		
			raise notice 'Original:%',original;
		
			select c1 into string from keplersc.kdinr 
				where c1=original;
			if found then
				raise notice 'El original:% esta como reemplazo en KDINR',original;
			
			end if;
		end if;
	end loop;
*/


/*
---------------------------------------	
--3. Existencias
--select * from keplersc.kdinl k where c2='0446542180' or c2='0446542150'	--150 es original

--Buscar la cadena de reemplazos y por cada uno buscar en kdini si hay reemplazos como originales marcados con R, si si sumar y dejarlos en el registro del original
--sumar al original c5
--Sumar sumar al original c6
--Sumar sumar al original c8
--Sumar sumar al original c9 
--Sumar sumar al original c14
--Sumar sumar al original c15
--c11 ultima venta y c12 ultima compra dejar la mas actual en cada columna
--c17 penultima venta y c18 penultima compra dejar la mas actual en cada columna	

raise notice 'Proceso Existencias';
	original='';
	cuenta:=0;
	cont:=0;
	for rec in select * from keplersc.kdinl order by c2 asc
	loop 
		cuenta:=cuenta+1;
		raise notice 'rec.c2(Producto):% %',cuenta,rec.c2;
		if rec.c2 = '' or rec.c2 is null then
			continue;
		else
			original := '';
			select * into original from keplersc.prod_obtener_original(rec.c2);
			if original<>rec.c2 then		--solo si es reemplazo
				cantentradas:=0.00;
				cantsalidas:=0.00;
				totentradas:=0.00;
				totsalidas:=0.00;
				ultcosto:=0.00;
				penultcosto:=0.00;
				fec_ultventa:='1800-01-01 00:00:00';
				fec_ultcompra:='1800-01-01 00:00:00';
				fec_penultventa:='1800-01-01 00:00:00';
				fec_penultcompra:='1800-01-01 00:00:00';
				revisar := '';
			
				select c5,c6,c8,c9,c14,
					c15,c11,c12,c17,c18 
					into cantentradas,cantsalidas,totentradas,totsalidas,ultcosto,
					penultcosto,fec_ultventa,fec_ultcompra,fec_penultventa,fec_penultcompra
					from keplersc.kdinl
					where c1=rec.c1 and c2=rec.c2;
				
				select c5,c6,c8,c9,c14,
					c15,c11,c12,c17,c18 
					into o_cantentradas,o_cantsalidas,o_totentradas,o_totsalidas,o_ultcosto,
					o_penultcosto,o_fec_ultventa,o_fec_ultcompra,o_fec_penultventa,o_fec_penultcompra
					from keplersc.kdinl
					where c1=rec.c1 and c2=original;
				if found then
					raise notice 'REEMPLAZO cantentradas:%, cantsalidas:%, totentradas:%, totsalidas:%, ultcosto:%, penultcosto:%, fec_ultventa:%, fec_ultcompra:%, fec_penultventa:%, fec_penultcompra:%',
								cantentradas,cantsalidas,totentradas,totsalidas,ultcosto,penultcosto,fec_ultventa,fec_ultcompra,fec_penultventa,fec_penultcompra;
					raise notice 'ORIGINAL o_cantentradas:%, o_cantsalidas:%, o_totentradas:%, o_totsalidas:%, o_ultcosto:%, o_penultcosto:%, o_fec_ultventa:%, o_fec_ultcompra:%, o_fec_penultventa:%, o_fec_penultcompra:%',
								o_cantentradas,o_cantsalidas,o_totentradas,o_totsalidas,o_ultcosto,o_penultcosto,o_fec_ultventa,o_fec_ultcompra,o_fec_penultventa,o_fec_penultcompra;
					if cantentradas > 0 then			--Los datos son del reemplazo
						cantentradas := cantentradas;
						totentradas := totentradas;
						ultcosto := ultcosto;
						penultcosto := penultcosto;
					else 								--Los datos son del original
						cantentradas := o_cantentradas;
						totentradas := o_totentradas;
						ultcosto := o_ultcosto;
						penultcosto := o_penultcosto;
					end if;
					
					if cantsalidas > 0 then				--Los datos son del reemplazo
						cantsalidas := cantsalidas;
						totsalidas := totsalidas;
					else								--Los datos son del original
						cantsalidas := o_cantsalidas;
						totsalidas := o_totsalidas;
					
					end if;
					
					if 	fec_ultventa>o_fec_ultventa then
						fec_ultventa := fec_ultventa;
					else
						fec_ultventa := o_fec_ultventa;
					end if;
					if 	fec_ultcompra>o_fec_ultcompra then
						fec_ultcompra := fec_ultcompra;
					else
						fec_ultcompra := o_fec_ultcompra;
					end if;
					if 	fec_penultventa>o_fec_penultventa then
						fec_penultventa := fec_penultventa;
					else
						fec_penultventa := o_fec_penultventa;
					end if;
					if 	fec_penultcompra>o_fec_penultcompra then
						fec_penultcompra := fec_penultcompra;
					else
						fec_penultcompra := o_fec_penultcompra;
					end if;
					if ultcosto <> o_ultcosto then
						--ultcosto := o_ultcosto;		--Si en diferente el ultimo costo de reemplazo y original dejar el ultimo costo de original
						revisar :='*';
					end if;
					if penultcosto <> o_penultcosto then
						--penultcosto := o_penultcosto;	--Si en diferente el penultimo costo de reemplazo y original dejar el penultimo costo de original
						revisar :='*';
					end if;
					raise notice 'ACTUALIZA ORIGINAL:% cantentradas:%, cantsalidas:%, totentradas:%, totsalidas:%, ultcosto:%, penultcosto:%, revisar:%, fec_ultventa:%, fec_ultcompra:%, fec_penultventa:%, fec_penultcompra:%',
								original,cantentradas,cantsalidas,totentradas,totsalidas,ultcosto,penultcosto,revisar,fec_ultventa,fec_ultcompra,fec_penultventa,fec_penultcompra;
									
--					update keplersc.kdinl set
--						c5 = cantentradas,		--total de entradas del reemplazo tiene contenidas las del original mas las del reemplazo
--						c6 = cantsalidas,
--						c8 = totentradas,
--						c9 = totsalidas,
--	 					c14 = ultcosto,
--						c15 = penultcosto,
--						c16 = revisar,		
--						c11 = fec_ultventa,
--						c12 = fec_ultcompra,
--						c17 = fec_penultventa,
--						c18 = fec_penultcompra
--						where c1=rec.c1 and c2=original;

					raise notice 'Se marca reemplazo:% con R, para revisar y borrar despues',rec.c2;		


--					update keplesc.kdinl set
--						c3='R'
--						where c1=rec.c1 and c2=rec.c2;
						
				end if;
				
			end if;
		end if;
		
	end loop;
*/


/*
---------------------------------------	
--4.Resumen mensual de movimientos
--select * from keplersc.kdink k where c2='0446542180' or c2='0446542150'

--Buscar por cada uno en kdink si hay reemplazos como originales 
-- por cada año y sumar cada mes y dejarlo en el registro del mes correspondiente del original
 
--Si no hay año para el original que le corresponde al reemplazo cambiar el registro c2=cve original, si si hay siempre acumulando el valor por si hay otro reemplazo
raise notice 'Resumen mensual de movimientos';
	original='';
	cuenta:=0;
	cont:=0;
	for rec in select * from keplersc.kdink order by c2 asc
	loop 
		cuenta:=cuenta+1;
		raise notice 'rec.c2(Producto):% %',cuenta,rec.c2;
		if rec.c2 = '' or rec.c2 is null then
			continue;
		else
			original := '';
			select * into original from keplersc.prod_obtener_original(rec.c2);
			if original<>rec.c2 then		--solo si es reemplazo
				cantEene:=0; cantEfeb:=0; cantEmar:=0; cantEabr:=0; cantEmay:=0; cantEjun:=0; 
				cantEjul:=0; cantEago:=0; cantEsep:=0; cantEoct:=0; cantEnov:=0; cantEdic:=0; 					
				montEene:=0; montEfeb:=0; montEmar:=0; montEabr:=0; montEmay:=0; montEjun:=0; 					
				montEjul:=0; montEago:=0; montEsep:=0; montEoct:=0; montEnov:=0; montEdic:=0; 					
				cantSene:=0; cantSfeb:=0; cantSmar:=0; cantSabr:=0; cantSmay:=0; cantSjun:=0; 					
				cantSjul:=0; cantSago:=0; cantSsep:=0; cantSoct:=0; cantSnov:=0; cantSdic:=0; 					
				montSene:=0; montSfeb:=0; montSmar:=0; montSabr:=0; montSmay:=0; montSjun:=0; 
				montSjul:=0; montSago:=0; montSsep:=0; montSoct:=0; montSnov:=0; montSdic:=0; 
						
				select c10,c11,c12,c13,c14,c15,
					c16,c17,c18,c19,c20,c21,
					c22,c23,c24,c25,c26,c27,
					c28,c29,c30,c31,c32,c33,
					c40,c41,c42,c43,c44,c45,
					c46,c47,c48,c49,c50,c51,
					c52,c53,c54,c55,c56,c57,
					c58,c59,c60,c61,c62,c63
					into cantEene,cantEfeb,cantEmar,cantEabr,cantEmay,cantEjun,
					cantEjul,cantEago,cantEsep,cantEoct,cantEnov,cantEdic,					
					montEene,montEfeb,montEmar,montEabr,montEmay,montEjun,					
					montEjul,montEago,montEsep,montEoct,montEnov,montEdic,					
					cantSene,cantSfeb,cantSmar,cantSabr,cantSmay,cantSjun,					
					cantSjul,cantSago,cantSsep,cantSoct,cantSnov,cantSdic,					
					montSene,montSfeb,montSmar,montSabr,montSmay,montSjun,
					montSjul,montSago,montSsep,montSoct,montSnov,montSdic
					from keplersc.kdink
					where c1=rec.c1 and c2=original and c3=rec.c3;
				if found then
				 raise notice 'Se actualiza original:% año:%,
					c10=%+%, c11=%+%, c12=%+%, c13=%+%, c14=%+%, c15=%+%,
					c16=%+%, c17=%+%, c18=%+%, c19=%+%, c20=%+%, c21=%+%,
					c22=%+%, c23=%+%, c24=%+%, c25=%+%, c26=%+%, c27=%+%,
					c28=%+%, c29=%+%, c30=%+%, c31=%+%, c32=%+%, c33=%+%,
					c40=%+%, c41=%+%, c42=%+%, c43=%+%, c44=%+%, c45=%+%,
					c46=%+%, c47=%+%, c48=%+%, c49=%+%, c50=%+%, c51=%+%,
					c52=%+%, c53=%+%, c54=%+%, c55=%+%, c56=%+%, c57=%+%,
					c58=%+%, c59=%+%, c60=%+%, c61=%+%, c62=%+%, c63=%+%',original,rec.c3,
					cantEene,rec.c10, cantEfeb,rec.c11, cantEmar,rec.c12, cantEabr,rec.c13, cantEmay,rec.c14, cantEjun,rec.c15,
					cantEjul,rec.c16, cantEago,rec.c17, cantEsep,rec.c18, cantEoct,rec.c19, cantEnov,rec.c20, cantEdic,rec.c21,
					montEene,rec.c22, montEfeb,rec.c23, montEmar,rec.c24, montEabr,rec.c25, montEmay,rec.c26, montEjun,rec.c27,
					montEjul,rec.c28, montEago,rec.c29, montEsep,rec.c30, montEoct,rec.c31, montEnov,rec.c32, montEdic,rec.c33,
					cantSene,rec.c40, cantSfeb,rec.c41, cantSmar,rec.c42, cantSabr,rec.c43, cantSmay,rec.c44, cantSjun,rec.c45,
					cantSjul,rec.c46, cantSago,rec.c47, cantSsep,rec.c48, cantSoct,rec.c49, cantSnov,rec.c50, cantSdic,rec.c51,
					montSene,rec.c52, montSfeb,rec.c53, montSmar,rec.c54, montSabr,rec.c55, montSmay,rec.c56, montSjun,rec.c57,
					montSjul,rec.c58, montSago,rec.c59, montSsep,rec.c60, montSoct,rec.c61, montSnov,rec.c62, montSdic,rec.c63;

--					update keplersc.kdink set
--						c10=c10+rec.c10, c11=c11+rec.c11, c12=c12+rec.c12, c13=c13+rec.c13, c14=c14+rec.c14, c15=c15+rec.c15,
--						c16=c16+rec.c16, c17=c17+rec.c17, c18=c18+rec.c18, c19=c19+rec.c19, c20=c20+rec.c20, c21=c21+rec.c21,
--						c22=c22+rec.c22, c23=c23+rec.c23, c24=c24+rec.c24, c25=c25+rec.c25, c26=c26+rec.c26, c27=c27+rec.c27,
--						c28=c28+rec.c28, c29=c29+rec.c29, c30=c30+rec.c30, c31=c31+rec.c31, c32=c32+rec.c32, c33=c33+rec.c33,
--						c40=c40+rec.c40, c41=c41+rec.c41, c42=c42+rec.c42, c43=c43+rec.c43, c44=c44+rec.c44, c45=c45+rec.c45,
--						c46=c46+rec.c46, c47=c47+rec.c47, c48=c48+rec.c48, c49=c49+rec.c49, c50=c50+rec.c50, c51=c51+rec.c51,
--						c52=c52+rec.c52, c53=c53+rec.c53, c54=c54+rec.c54, c55=c55+rec.c55, c56=c56+rec.c56, c57=c57+rec.c57,
--						c58=c58+rec.c58, c59=c59+rec.c59, c60=c60+rec.c60, c61=c61+rec.c61, c62=c62+rec.c62, c63=c63+rec.c63
--					where c1=rec.c1 and c2=original and c3=rec.c3;

					raise notice 'Se marca reemplazo:% con R, para revisar y borrar despues',rec.c2;		

--					update keplersc.kdink set
--						c4='R'
--						where c1=rec.c1 and c2=rec.c2 and c3=rec.c3;

				else
					if original<>'0' then	
						raise notice 'No existe original:% a o:%, se actualiza registro de reemplazo:% por original c2=%',original,rec.c3,rec.c2,original; 

--						update keplersc.kdink set
--							c2=original
--							where c1=rec.c1 and c2=rec.c2 and c3=rec.c3;
					else
						raise notice 'NO HAY REGISTRO EN KDINI DE ORIGINAL=0';

--						update keplersc.kdink set
--							c16='N'
--							where c1=rec.c1 and c2=rec.c2 and c3=rec.c3;
	
					end if;
				end if;
			end if;
		end if;		
	end loop;
*/

	

---------------------------------------	
--5.Movimientos de inventario
-- select * from keplersc.kdinm k where c2='0446542180' or c2='0446542150'

--Buscar por cada uno en kdinm si hay reemplazos como originales y realizar lo siguiente:
 
 --Kdm2 ok se registro correctamente con la clave reemplazo en c8 p.e. 0446542180
--Solo actualizar c28 con la cve original de c8 para inm.c1=dm2.c1 and inm.c5(gen)=dm2.c2 and inm.c6(nat)=dm2.c3 and inm.c7(gpo)=dm2.c4 and inm.c8(tipo)=dm2.c5 and inm.c9(folio)=dm2.c6 and inm.c10(partida)=dm2.c7 and inm.c2(producto)=dm2.c8
 
 --kdvcm
 --Actualizar c15=original de c16(reemplazo) para inm.c1(suc)=vcm.c1 and inm.c5(gen)=vcm.c2 and inm.c6(nat)=vcm.c3 and inm.c7(gpo)=vcm.c4 and inm.c8(tipo)=vcm.c5 and inm.c9(folio)=vcm.c6 and inm.c10(partida)=vcm.c7
 
 
 --Y por cada uno buscar el original de inm.c2 y actualizar inm.c2 con la clave original

 --Detalle de ventas, se actualizara en el registro de kdinm
--select * from keplersc.kdvcm where c15='0446542180'
 raise notice 'Movimientos de inventario';

	original='';
	cuenta:=0;
	cont:=0;
	for rec in select * from keplersc.kdinm order by c2 asc
	loop 
		cuenta:=cuenta+1;
		raise notice 'rec.c2(Producto):% %',cuenta,rec.c2;
		if rec.c2 = '' or rec.c2 is null then
			continue;
		else
			original := '';
			totReg=0;
			select * into original from keplersc.prod_obtener_original(rec.c2);
			if original<>rec.c2 then		--solo si es reemplazo
				--kdm2 actualizar original en c28
				select count(*) into totReg
					from keplersc.kdm2 
					where c1=rec.c1 and c2=rec.c5 and c3=rec.c6 and c4=rec.c7 and c5=rec.c8 and c6=rec.c9 and c7=rec.c10 and c8=rec.c2;
				if totReg > 0 then
					if original <> '0' then
						raise notice 'Actualizar % reg kdm2.c28(original):% G:% N:% GP:% T:% Fol:% Part:% Producto:%',totReg,original,rec.c5,rec.c6,rec.c7,rec.c8,rec.c9,rec.c10,rec.c2;
--						update keplersc.kdm2 set
--							c28=original
--							where c1=rec.c1 and c2=rec.c5 and c3=rec.c6 and c4=rec.c7 and c5=rec.c8 and c6=rec.c9 and c7=rec.c10 and c8=rec.c2;
					else 
						raise notice 'Original=0, NO ACTUALIZA ORIGINAL: %',original;
					end if;		
				end if;
				--kdvcm actualizar original en c15
				totReg=0;
				select count(*) into totReg
					from keplersc.kdvcm 
					where c1=rec.c1 and c2=rec.c5 and c3=rec.c6 and c4=rec.c7 and c5=rec.c8 and c6=rec.c9 and c7=rec.c10;
				if totReg > 0 then
					if original <> '0' then
						raise notice 'Actualizar % reg kdvcm.c15(original):%',totReg,original;
--						update keplersc.kdvcm set
--							c15=original
--							where c1=rec.c1 and c2=rec.c5 and c3=rec.c6 and c4=rec.c7 and c5=rec.c8 and c6=rec.c9 and c7=rec.c10;
					else 
						raise notice 'Original=0, NO ACTUALIZA ORIGINAL: %',original;
					end if;
				end if;	
 
 --Y por cada uno buscar el original de inm.c2 y actualizar inm.c2 con la clave original
				--Actualizar el reemplazo con el original
				totReg=0;
				select count(*) into totReg
					from keplersc.kdinm 
					where c1=rec.c1 and c2=rec.c2 and c5=rec.c5 and c6=rec.c6 and c7=rec.c7 and c8=rec.c8 and c9=rec.c9 and c10=rec.c10;	
				if totReg > 0 then
					if original <> '0' then
						raise notice 'Actualizar % reg kdinm.c2(original):% Cantidad Movto:% Monto:% G:% N:% Gp:% T:% Fol:% Part:% Fecha:%',totReg,original,rec.c11,rec.c12,rec.c5,rec.c6,rec.c7,rec.c8,rec.c9,rec.c10,rec.c3;
--						update keplersc.kdinm set
--							c2=original
--							where c1=rec.c1 and c2=rec.c2 and c5=rec.c5 and c6=rec.c6 and c7=rec.c7 and c8=rec.c8 and c9=rec.c9 and c10=rec.c10;
					else 
						raise notice 'Original=0, NO ACTUALIZA ORIGINAL: %',original;
					end if;	
				end if;
			end if;
		end if;		
	end loop;



--/*
--6. Refacciones
 raise notice 'Carga de Refacciones';

	original='';
	cuenta:=0;
	cont:=0;
	for rec in select * from keplersc.kdref order by c11 asc
	loop 
		cuenta:=cuenta+1;
		raise notice 'rec.c11(Producto):% %',cuenta,rec.c11;
		if rec.c11 = '' or rec.c11 is null then
			continue;
		else
			original := '';
			totReg=0;
			select * into original from keplersc.prod_obtener_original(rec.c11);
			if original<>rec.c11 then		--solo si es reemplazo
				raise notice 'Es reemplazo:% de original:%',rec.c11,original;
			end if;
		end if;		
	end loop;
--*/
	
	
/*	
--7. Paquetes
 raise notice 'Configuracion de Paquetes';

	original='';
	cuenta:=0;
	cont:=0;
	for rec in select * from keplersc.kdspaqm order by c6 asc
	loop 
		cuenta:=cuenta+1;
		raise notice 'rec.c6(Producto):% %',cuenta,rec.c6;
		if rec.c6 = '' or rec.c6 is null then
			continue;
		else
			original := '';
			totReg=0;
			select * into original from keplersc.prod_obtener_original(rec.c6);
			if original<>rec.c6 then		--solo si es reemplazo
				raise notice 'Es reemplazo:% de original:%',rec.c6,original;
			end if;
		end if;		
	end loop;
*/


/*	
--8. KDREFLASTMOV
 raise notice 'Registro ultimo movto refacciones';

	original='';
	cuenta:=0;
	cont:=0;
	for rec in select * from keplersc.kdreflastmov order by c1,c2 asc
	loop 
		cuenta:=cuenta+1;
		raise notice 'rec.c2(Producto):% %',cuenta,rec.c2;
		if rec.c2 = '' or rec.c2 is null then
			continue;
		else
			original := '';
			totReg=0;
			select * into original from keplersc.prod_obtener_original(rec.c2);
			if original<>rec.c2 then		--solo si es reemplazo
				raise notice 'Es reemplazo:% de original:%',rec.c2,original;
			end if;
		end if;		
	end loop;
*/

-----------------------------
--raise notice 'Eliminar registro de reemplazos de KDINI';
--Por ultimo despues de revisar los registros de reemplazos como originales en kdini, eliminarlos

-----------------------------
--return 1;
raise exception 'ALTO MANUAL PARA PRUEBAS';

end;
$function$
