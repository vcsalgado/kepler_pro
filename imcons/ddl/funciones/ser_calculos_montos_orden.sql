CREATE OR REPLACE FUNCTION keplersc.ser_calculos_montos_orden(dataxml xml)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
--Descripcion: Calculos Orden
--Autor: Luis Leal
--Fecha: 06/12/2022
--Bitacora de cambios
--Miriam Santana: 5/02/23 Obtener los totales de las columnas nuevas subtotal e iva de las tablas KDREF,KDHORAS,KDTOT,KDCAR 
--				  para eliminar los calculos en CFDI
--Miriam Santana: 04/10/24 No permitir costo de mano de obra negativo
--Luis Leal: 23/10/24 Programa Lealtad
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	tipo_orden text = '';
	folio_orden text = '';
	numero_punto numeric ;
	clave_paquete text;
	tipo_punto text;

	--kdmargen
	costo_por_hora_default numeric;
	iva_default numeric ;

	costo_por_hora numeric ;
	partida numeric ;
	costo numeric = 0;
	importe numeric = 0;
	hrs_a_pagar  numeric = 0;
	precio_paquete numeric = 0;
	hrs numeric = 0;


	--Calculos
	importe_refs_punto numeric = 0;
	importe_total_refs numeric = 0;
	subtotal_total_refs numeric = 0;
	iva_total_refs numeric = 0;
	subtotal_refs_punto numeric = 0;
	iva_refs_punto numeric = 0;
	subtotal_refs_descto_punto numeric = 0;
	subtotal_total_refs_descto numeric = 0;
	ref_descto numeric= 0;
	importe_descto_refs_punto numeric = 0;

	importe_tots_punto numeric = 0;
	importe_total_tots numeric = 0;
	subtotal_total_tots numeric = 0;
	iva_total_tots numeric = 0;
	subtotal_tots_punto numeric = 0;
	iva_tots_punto numeric = 0;
	subtotal_total_tots_descto numeric = 0;

	importe_car_punto numeric = 0;
	subtotal_total_car numeric = 0;
	importe_total_car numeric = 0;
	iva_total_car numeric = 0;
	subtotal_car_punto numeric = 0;
	iva_car_punto numeric = 0;
	subtotal_total_otros_descto numeric = 0;

	importe_horas_punto numeric = 0;
	importe_total_horas numeric = 0;
	subtotal_total_horas numeric = 0;
	iva_total_horas numeric = 0;
	subtotal_horas_punto numeric = 0;
	iva_horas_punto numeric = 0;
	subtotal_total_mo_descto numeric = 0;
	mo_descto numeric = 0;
	importe_descto_mo_punto numeric = 0;

	suma_mo_ref_descto numeric=0;
--cfdi no cálculo
	subt numeric = 0;
	iva numeric = 0;

	msgErr text ='';
--cfdi no cálculo
	--resultados
	subtotal numeric = 0;
	iva_total numeric = 0;
	importe_total numeric = 0;


	--LGLG 23/10/24 Programa Lealtad---
	fol_tarjeta_lealtad text;
	vin text;
	totReg numeric(1);
	programa_lealtad text;
	cliente_agencia text;
	porcentaje_1 numeric = 0;
	porcentaje_2 numeric = 0;
	porcentaje_3 numeric = 0;
	porcentaje_4 numeric = 0;
	descuento numeric = 0;
	desc_agencia numeric = 0;
	desc_otra_agencia numeric = 0;
	desc_mano_obra_punto numeric = 0;
	desc_refs_punto numeric = 0;
	desc_refs numeric = 0;



 	ctd numeric = 0;
	desc_tots_punto numeric = 0;
	desc_tots numeric = 0;	
	desc_car_punto numeric = 0;
	desc_car numeric = 0;	
	subtotal_descuento numeric = 0;
	iva_descuento numeric = 0;
	importe_total_descuento numeric = 0;
	descuento_punto_QM text = 'N';
	descuento_punto_Otros text = 'N';

	gen_mov text = '';
	nat_mov text = '';
	gpo_mov numeric = 0;
	tipo_mov numeric =0;
	folio_mov text = '';

	--Variables de uso general 
	intValor int = 0;
	xmlResultado text;
	expSql text = '';
	aplicar_iva text = 'S';
begin

	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	tipo_orden := (xpath('//document/tipo_orden/text()', dataxml))[1];
	folio_orden := (xpath('//document/folio_orden/text()', dataxml))[1];

	--Validar que la orden no esta cerrada
	select count(*) into totReg from keplersc.kdord where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c7=0;
	if totReg = 0 then
		raise exception 'La Orden esta cerrada.';
	end if;

	select c4, c11 into costo_por_hora_default, iva_default from keplersc.kdmargen where c1=tipo_orden;
	
	aplicar_iva = 'S';
	if tipo_orden = 'I' or tipo_orden='P' then 
		aplicar_iva='N';
		iva_default=0;
	end if;

	---LGLG 23/10/24 VALIDA PROGRAMA LEALTAD----------------------

	programa_lealtad := 'N';
	cliente_agencia = 'N';

	select le.c1,le.c2 into vin, fol_tarjeta_lealtad from keplersc.kdord as ord  
	inner join keplersc.kdserie as ser on ord.c6=ser.c1 
	inner join keplersc.kdfoliotarjetalealtad as le on le.c1=ser.c4
	where ord.c1=sucursal_id and ord.c2=tipo_orden and ord.c3=folio_orden;
	if found then 
	
		if tipo_orden <> 'I' and tipo_orden <> 'P' then 
		
			select count(*) into totReg from keplersc.kdinf where c1=sucursal_id and c5=vin;
			if totReg > 0 then
				cliente_agencia = 'S';
			end if;
		
			select c3,c4,c5,c6 into porcentaje_1, porcentaje_2, porcentaje_3, porcentaje_4
			from keplersc.kdconflealtad where c2=sucursal_id order by c1 desc limit 1;
			if found then 
		
				delete from keplersc.kdlealtadmov where c1=sucursal_id and c2=tipo_orden and c3=folio_orden;
				delete from keplersc.kdlealtadmovs where c1=sucursal_id and c2=tipo_orden and c3=folio_orden;
	
				programa_lealtad := 'S';
			
			end if;
		
		end if;
	
	end if;
raise notice 'cliente_agencia: %, programa_lealtad: %',cliente_agencia, programa_lealtad;
	------------------------------------------------------------------------

raise notice 'Orden:% Costohrxdef%',folio_orden,costo_por_hora_default;
	for numero_punto,clave_paquete, tipo_punto in select c4, c5, c6 from keplersc.kdpun 
		where c1=sucursal_id and c2=tipo_orden and c3=folio_orden
	loop
raise notice 'Inicia punto:%',numero_punto;
		--16 subtotal; 21 iva; 22 total
		subt:=0; iva:=0; importe:=0; descuento:=0; 

		--LGLG 23/10/24 OBTENER DESCUENTOS LEALTAD----
		if programa_lealtad = 'S' then
			if tipo_punto <> 'N' and tipo_punto <> 'L' then 
				if tipo_punto = 'F' then 
					if cliente_agencia = 'S' then 
						descuento := (1-(porcentaje_1/100));
					else 
						descuento := (1-(porcentaje_2/100));
					end if;
				elsif tipo_punto = 'H' then 
					if cliente_agencia = 'S' then 
						descuento := (1-(porcentaje_3/100));
					else 
						descuento := (1-(porcentaje_4/100));
					end if;					
				elsif tipo_punto = 'S' then 
					select c2,c3 into desc_agencia ,desc_otra_agencia  
					from keplersc.kdcatpaqlealtad where c1=clave_paquete;
					if found then
						if cliente_agencia = 'S' then 
							descuento := (1-(desc_agencia/100));
						else 
							descuento := (1-(desc_otra_agencia/100));
						end if;
					end if;
				end if;
			end if;
		
			insert into keplersc.kdlealtadmov (c1,c2,c3,c4,c5,c6,c7,c8) 
			values(sucursal_id,tipo_orden, folio_orden, numero_punto,
			tipo_punto, clave_paquete, current_date, descuento);
		end if;
raise notice 'Descuento a aplicar:%',descuento;
	
		--Procesar Refacciones
		subtotal_refs_punto:=0;iva_refs_punto:=0;importe_refs_punto := 0;desc_refs_punto:=0;
		subtotal_refs_descto_punto := 0;
		for subt,iva,importe, partida, ctd,gen_mov,nat_mov,gpo_mov,tipo_mov,folio_mov in select coalesce(c16,0),coalesce(c21,0),coalesce(c22,0), c10, c13,
			c5,c6,c7,c8,c9
			from keplersc.kdref where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto
		loop
			if aplicar_iva='N' then 
				importe = importe-iva;
				iva=0;
			end if;
		
			--LGLG 23/10/24
			if programa_lealtad = 'S' then
				if descuento > 0 then
					desc_refs := coalesce(subt * descuento,0);
					desc_refs_punto :=  desc_refs_punto + desc_refs;
					--VCSS 18 Jul 2025, el descuento de las refacciones se acumula al de la mo, en kdlealtad movs se registra el importe sin descto
					--y el descuento se va acumulando para al final sumarlo al de la mano de obra 
					insert into keplersc.kdlealtadmovs (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,
						precio_original_sin_iva,clave_descuento,importe_descuento,base_descuento,
						gen,nat,gpo,tipo,folio)
					values(sucursal_id, tipo_orden, folio_orden, numero_punto, tipo_punto, 
					clave_paquete, 'R', partida, subt, subt/ctd, subt,'proglealtad',0,subt-desc_refs,
					gen_mov,nat_mov,gpo_mov,tipo_mov,folio_mov);
--					insert into keplersc.kdlealtadmovs (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10)
--					values(sucursal_id, tipo_orden, folio_orden, numero_punto, tipo_punto, 
--					clave_paquete, 'R', partida, desc_refs, desc_refs/ctd );
				else
					desc_refs := subt;
					desc_refs_punto :=  desc_refs_punto + desc_refs;
				end if;
			end if;
		
			subtotal_refs_punto := subtotal_refs_punto + subt;
			iva_refs_punto := iva_refs_punto + iva;
			importe_refs_punto := importe_refs_punto + importe;			
			subt:=0; iva:=0; importe:=0;
		
		end loop; --Fin loop Refacciones
		--Acumulacion sin descuento a nivel orden
		subtotal_total_refs := subtotal_total_refs + subtotal_refs_punto;
		iva_total_refs := iva_total_refs + iva_refs_punto;
		importe_total_refs := importe_total_refs + importe_refs_punto;

		--Acumulacion con descuento
		subtotal_refs_descto_punto:=subtotal_refs_descto_punto + desc_refs_punto;
		subtotal_total_refs_descto := subtotal_total_refs_descto + desc_refs_punto;
		--Fin procesar refaciones

raise notice 'Refacciones al 100---subt:% iva:% tot:%; Subt C/Descuento:% ',subtotal_total_refs,iva_total_refs,importe_total_refs,desc_refs_punto;
		--16 subtotal 	--18 iva  	--19 total
		subt:=0; iva:=0; importe:=0;
		subtotal_tots_punto:=0; iva_total_tots:=0; importe_tots_punto := 0;
		desc_tots_punto:=0; --MSS 30062025 No acumule el descuento en los siguientes puntos
		--subtotal_total_tots_descto := 0;
		--Procesar TOTS
		for subt,iva,importe, partida in select coalesce(c16,0),coalesce(c18,0),coalesce(c19,0), c15 
			from keplersc.kdtot where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto
		loop
			if aplicar_iva='N' then 
				importe = importe-iva;
				iva=0;
			end if;
		
			--LGLG 23/10/24
			if programa_lealtad = 'S' then
			
				if descuento > 0 then
					desc_tots := coalesce(subt * descuento,0);
					desc_tots_punto :=  desc_tots_punto + desc_tots;
				
					insert into keplersc.kdlealtadmovs (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,
						precio_original_sin_iva,clave_descuento,importe_descuento,base_descuento)
					values(sucursal_id, tipo_orden, folio_orden, numero_punto, tipo_punto, 
					clave_paquete, 'T', partida, desc_tots, desc_tots,
					subt,'proglealtad', subt-desc_tots_punto,subt-desc_tots_punto);
				else
					desc_tots := subt;
					desc_tots_punto :=  desc_tots_punto + desc_tots;
				end if;
			end if;
		
		
			subtotal_tots_punto := subtotal_tots_punto + subt;
			iva_tots_punto := iva_tots_punto + iva;
			importe_tots_punto := importe_tots_punto + importe;		
			subt:=0; iva:=0; importe:=0;
		end loop;
		--Acumulacion sin descuento
		subtotal_total_tots := subtotal_total_tots + subtotal_tots_punto;
		iva_total_tots := iva_total_tots + iva_tots_punto;
		importe_total_tots := importe_total_tots + importe_tots_punto;

		--Acumulacion con descuento
		subtotal_total_tots_descto := subtotal_total_tots_descto + desc_tots_punto;
		-- Fin procesar TOTS
raise notice 'Tots al 100 ---subt:% iva:% tot:%; Subt C/Descuento:%',subtotal_total_tots,iva_total_tots,importe_total_tots,desc_tots_punto;	

		--10 subtotal --11 iva  --12 total
		subt:=0; iva:=0; importe:=0;	
		subtotal_car_punto:=0; iva_car_punto:=0; importe_car_punto := 0;
		desc_car_punto:=0; --MSS 30062025 No acumule el descuento en los siguientes puntos
		subtotal_total_otros_descto:=0;
		--Procesar Cargo Varios
		for subt,iva,importe,partida in select coalesce(c10,0),coalesce(c11,0),coalesce(c12,0), c5 
			from keplersc.kdcar where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto
		loop
			if aplicar_iva='N' then 
				importe = importe-iva;
				iva=0;
			end if;
		
			--LGLG 23/10/24
			if programa_lealtad = 'S' then
				if descuento > 0 then			
					desc_car := coalesce(subt * descuento,0);
					desc_car_punto :=  desc_car_punto + desc_car;
		
					insert into keplersc.kdlealtadmovs (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,
						precio_original_sin_iva,clave_descuento,importe_descuento,base_descuento)
					values(sucursal_id, tipo_orden, folio_orden, numero_punto, tipo_punto, 
					clave_paquete, 'C', partida, desc_car,desc_car,
					subt,'proglealtad',subt-desc_car,subt-desc_car);
				else
					desc_car := subt;
					desc_car_punto :=  desc_car_punto + desc_car;
				end if;
			end if;
		
			subtotal_car_punto := subtotal_car_punto + subt;
			iva_car_punto := iva_car_punto + iva;
			importe_car_punto := importe_car_punto + importe;			
			subt:=0; iva:=0; importe:=0;
		end loop;
		--Acumulacion sin descuento
		subtotal_total_car := subtotal_total_car + subtotal_car_punto;
		iva_total_car := iva_total_car + iva_car_punto;
		importe_total_car := importe_total_car + importe_car_punto;

		--Acumulacion con descuento
		subtotal_total_otros_descto := subtotal_total_otros_descto + desc_car_punto;
		--Fin procesar Cargos Varios

raise notice 'Cargos al 100---subt:% iva:% tot:%; Subt C/Descuento:%',subtotal_total_car,iva_total_car,importe_total_car,desc_car_punto;		
		--17 subtotal	=hrs*costoxhr; 	--18 iva --19 total
		subt:=0; iva:=0; importe:=0;
		subtotal_horas_punto:=0; iva_horas_punto:=0; importe_horas_punto := 0;
		desc_mano_obra_punto:=0; --MSS 30062025 No acumule el descuento en los siguientes puntos

		/********************
		--Porcesa MO
		*********************/
		importe_descto_refs_punto := subtotal_refs_punto - subtotal_refs_descto_punto;
		for partida, hrs in select c5, coalesce(c8,0) 
			from keplersc.kdhoras where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto
		loop
			if aplicar_iva='N' then 
				importe = importe-iva;
				iva=0;
			end if;
			if tipo_punto <> 'S' then 
				if tipo_punto <> 'L' then 
					costo_por_hora := costo_por_hora_default;
				else 
					costo_por_hora := 0;
				end if;
			
			else 
				--ES UN PAQUETE
				select paq.c9 ,paq.c10 into hrs_a_pagar, precio_paquete from keplersc.kdord as ord inner join keplersc.kdserie as ser on ord.c6=ser.c1
				inner join keplersc.kdspaq as paq on ser.c2=paq.c1 and ser.c3=paq.c2
				where ord.c1=sucursal_id and ord.c2=tipo_orden and ord.c3=folio_orden and paq.c4=clave_paquete;
			
				costo_por_hora := (precio_paquete/(1+(iva_default/100)) - subtotal_refs_punto - subtotal_car_punto);
			
				if hrs_a_pagar > 0 then
					costo_por_hora := costo_por_hora/hrs_a_pagar;
				end if;
						
			end if;
			
			if precio_paquete is null then
--				raise exception 'Sin precio de paquete:% , orden:%',clave_paquete,folio_orden;	--Debe ser un raise exception
				continue;
			end if;
			subt := hrs * costo_por_hora;
		
			--LGLG 23/10/24
			if programa_lealtad = 'S' then
				if descuento > 0 then														
					--A10+=(L8*L14*B10)
					desc_mano_obra_punto := coalesce(desc_mano_obra_punto + (hrs * costo_por_hora * descuento), 0); 
					--VCSS 18 Jul 2025, el descuento de las refacciones se acumula al de la mo y se registra en la mo
					--por esto, el descuento por refacciones se convierte a horas 					
--					insert into keplersc.kdlealtadmovs (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10)
--					values(sucursal_id, tipo_orden, folio_orden, numero_punto, tipo_punto, 
--					clave_paquete, 'H', partida, coalesce((costo_por_hora * descuento),0), coalesce((subt * descuento), 0 ) );
					insert into keplersc.kdlealtadmovs (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,
						precio_original_sin_iva,clave_descuento,importe_descuento,base_descuento)
					values(sucursal_id, tipo_orden, folio_orden, numero_punto, tipo_punto, 
					clave_paquete, 'H', partida,
					coalesce((subt * descuento), 0 ) - importe_descto_refs_punto, 
					(coalesce((subt * descuento),0) - importe_descto_refs_punto)/hrs,
					subt,'proglealtad',subt-(coalesce((subt * descuento), 0 )) + importe_descto_refs_punto,subt-(coalesce((subt * descuento), 0 )));
				else
					desc_mano_obra_punto :=subt;
				end if; 
			end if;
			
			--2dec subt := hrs * round(costo_por_hora,2);
			iva := subt * (iva_default/100);
			importe := subt + iva;
			--MSS 04102024 No permitir costo de mano de obra negativo
			if subt < 0 then
--				subt = 0;
--				raise exception 'El costo de la Mano de Obra no puede negativo, punto:%',numero_punto;
			end if;
			if desc_mano_obra_punto < 0 then
--				desc_mano_obra_punto = 0;
--				raise exception 'El costo de la Mano de Obra no puede negativo, punto:%',numero_punto;
			end if;
raise notice 'Horas-pto al 100---hr:% cost:% subt:% iva:% tot:%; Subt C/Descuento:%',hrs,costo_por_hora,subt,iva,importe, desc_mano_obra_punto;	
			update keplersc.kdhoras set c14=costo_por_hora,c17=coalesce(subt,0),c18=coalesce(iva,0),c19=coalesce(importe,0) 
				where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto and c5=partida;
			--Acumulacion sin descuento
			subtotal_horas_punto := subtotal_horas_punto + subt;
			iva_horas_punto := iva_horas_punto + iva;
			importe_horas_punto := importe_horas_punto + importe;

			--Fion Procesar MO
			subt:=0; iva:=0; importe:=0;

		end loop;
		--Acumulacion de totales sin descuento
		subtotal_total_horas := subtotal_total_horas + subtotal_horas_punto;
		iva_total_horas := iva_total_horas + iva_horas_punto;
		importe_total_horas := importe_total_horas + importe_horas_punto;

		--Acumulacion con descuento
		subtotal_total_mo_descto := subtotal_total_mo_descto + desc_mano_obra_punto; 

raise notice 'TOTAL PUNTO al 100:% = importe_refs_punto:=%; importe_tots_punto:=%; importe_total_car:=%; importe_horas_punto',importe_refs_punto+importe_tots_punto+importe_total_car + importe_horas_punto,importe_refs_punto,importe_tots_punto,importe_total_car;	
raise notice 'TOTAL PUNTO C/Descuentos:% = desc_refs_punto:=%; desc_tots_punto:=%; desc_car_punto:=%; desc_mano_obra_punto:=%',
	desc_refs_punto+desc_tots_punto+desc_car_punto+desc_mano_obra_punto,
	desc_refs_punto,desc_tots_punto,desc_car_punto,desc_mano_obra_punto;	
raise notice '************************************';	

		if programa_lealtad = 'S' then
			subtotal_descuento := subtotal_total_refs_descto + subtotal_total_tots_descto + subtotal_total_otros_descto + subtotal_total_mo_descto;
		end if;

	end loop;

raise notice 'Horas---subt:% iva:% tot:%',subtotal_total_horas,iva_total_horas,importe_total_horas;	
	subtotal :=  subtotal_total_refs + subtotal_total_tots + subtotal_total_car + subtotal_total_horas;
	iva_total := iva_total_refs + iva_total_tots + iva_total_car + iva_total_horas;
	importe_total := importe_total_refs + importe_total_tots + importe_total_car + importe_total_horas;

raise notice 'importe_total: %; importe_total_refs:%  importe_total_tots:%  importe_total_car:% importe_total_horas:%',
	importe_total,importe_total_refs,importe_total_tots,importe_total_car,importe_total_horas;

	--LGLG 23/10/24
	if programa_lealtad = 'S' then
--		subtotal_descuento := subtotal_total_refs_descto + subtotal_total_tots_descto + subtotal_total_otros_descto + subtotal_total_mo_descto;
		iva_descuento := subtotal_descuento * (iva_default/100);
		importe_total_descuento := subtotal_descuento + iva_descuento ;
	end if;

raise notice 'subtotal_descuento: % := desc_mano_obra_punto:% + desc_refs_punto:% + desc_tots_punto:% + desc_car_punto:%',
	subtotal_descuento,desc_mano_obra_punto,desc_refs_punto,desc_tots_punto,desc_car_punto;
raise notice 'importe_total_descuento:% subtotal_descuento:% iva_descuento:% ',importe_total_descuento,subtotal_descuento,iva_descuento;

	--raise notice 'Total---subt:% iva:% tot:%',subtotal,iva_total,importe_total;		
	--Enviar subtotales con etiqueta de importe_total... para no modificar programas

	--VCSS 15 Julio 2025 El descuento de refacciones se le aplica a la mano de obra
	if programa_lealtad = 'S' then
		mo_descto:=subtotal_total_horas - subtotal_total_mo_descto;
		ref_descto:=subtotal_total_refs - subtotal_total_refs_descto;
		subtotal_total_mo_descto:=subtotal_total_mo_descto - subtotal_total_refs + subtotal_total_refs_descto;
		subtotal_total_refs_descto:=subtotal_total_refs;
		suma_mo_ref_descto:=mo_descto + ref_descto;

		--VCSS 24 Ago 2025 ,se ajustan tots para eliminar descuentos a TOTs y Cargos Varios
		subtotal_total_tots_descto:=subtotal_total_tots;
		subtotal_total_otros_descto:=subtotal_total_car;
	end if;

	select xmlforest(round(subtotal_total_refs,6) as importe_total_refs, round(subtotal_total_tots,6) as importe_total_tots, round(subtotal_total_car,6) as importe_total_car, 
		   round(subtotal_total_horas,6) as importe_total_horas, round(subtotal,6) as subtotal, round(iva_total,6) as iva_total, round(importe_total,2) as importe_total,
		   fol_tarjeta_lealtad as tarjeta_lealtad, round(subtotal_total_mo_descto,6) as mano_obra_lealtad, round(subtotal_total_refs_descto,6) as refacciones_lealtad, 
		   round(subtotal_total_tots_descto,6) as tots_lealtad, round(subtotal_total_otros_descto,6) as cargos_varios_lealtad,round(subtotal_descuento,6) as subtotal_lealtad ,
		   round(iva_descuento,6) as iva_lealtad , round(importe_total_descuento,2) as importe_lealtad,
			round(ref_descto,6) as refacciones_descto,
			round(mo_descto,6) as mano_obra_descto,
			round(subtotal_total_tots - subtotal_total_tots_descto,6) as tots_descto,
			round(subtotal_total_car - subtotal_total_otros_descto,6) as cargos_descto,
			round(ref_descto+mo_descto,6) as total_moref_descto,
			cliente_agencia as es_cliente):: text into xmlResultado;

	return xmlResultado; 

exception
	when others then
		msgErr:= '['|| sqlstate || '] ' || sqlerrm ;
		raise exception '%', 'Sin Resultados. ' || msgErr;	--Le concatene el error xq no se mostraba
		
end;
$function$
