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
	importe_tots_punto numeric = 0;
	importe_total_tots numeric = 0;
	importe_car_punto numeric = 0;
	importe_total_car numeric = 0;
	importe_horas_punto numeric = 0;
	importe_total_horas numeric = 0;

--cfdi no calculo
	subt numeric = 0;
	iva numeric = 0;
	subtotal_total_refs numeric = 0;
	subtotal_total_tots numeric = 0;
	subtotal_total_car numeric = 0;
	subtotal_total_horas numeric = 0;
	iva_total_refs numeric = 0;
	iva_total_tots numeric = 0;
	iva_total_car numeric = 0;
	iva_total_horas numeric = 0;

	subtotal_refs_punto numeric = 0;
	subtotal_tots_punto numeric = 0;
	subtotal_car_punto numeric = 0;
	subtotal_horas_punto numeric = 0;
	iva_refs_punto numeric = 0;
	iva_tots_punto numeric = 0;
	iva_car_punto numeric = 0;
	iva_horas_punto numeric = 0;
	msgErr text ='';
--cfdi no calculo
	--resultados
	subtotal numeric = 0;
	iva_total numeric = 0;
	importe_total numeric = 0;

	--Variables de uso general 
	intValor int = 0;
	xmlResultado text;
	expSql text = '';
	aplicar_iva text = 'S';
begin

	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	tipo_orden := (xpath('//document/tipo_orden/text()', dataxml))[1];
	folio_orden := (xpath('//document/folio_orden/text()', dataxml))[1];

	select c4, c11 into costo_por_hora_default, iva_default from keplersc.kdmargen where c1=tipo_orden;
	
	aplicar_iva = 'S';
	if tipo_orden = 'I' or tipo_orden='P' then 
		aplicar_iva='N';
		iva_default=0;
	end if;

raise notice 'Orden:% Costohrxdef%',folio_orden,costo_por_hora_default;
	for numero_punto,clave_paquete, tipo_punto in select c4, c5, c6 from keplersc.kdpun where c1=sucursal_id and c2=tipo_orden and c3=folio_orden
	loop
		raise notice 'punto:%',numero_punto;
		--16 subtotal
		--21 iva
		--22 total
		subt:=0; iva:=0; importe:=0;
		subtotal_refs_punto:=0;iva_refs_punto:=0;importe_refs_punto := 0;
		for subt,iva,importe in select coalesce(c16,0),coalesce(c21,0),coalesce(c22,0)
			from keplersc.kdref where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto
		loop
			if aplicar_iva='N' then 
				importe = importe-iva;
				iva=0;
			end if;
		
			subtotal_refs_punto := subtotal_refs_punto + subt;
			iva_refs_punto := iva_refs_punto + iva;
			importe_refs_punto := importe_refs_punto + importe;			
			subt:=0; iva:=0; importe:=0;
		end loop;
		subtotal_total_refs := subtotal_total_refs + subtotal_refs_punto;
		iva_total_refs := iva_total_refs + iva_refs_punto;
		importe_total_refs := importe_total_refs + importe_refs_punto;
		raise notice 'Refacc---subt:% iva:% tot:%',subtotal_total_refs,iva_total_refs,importe_total_refs;
		--16 subtotal
		--18 iva
		--19 total
		subt:=0; iva:=0; importe:=0;
		subtotal_tots_punto:=0; iva_total_tots:=0; importe_tots_punto := 0;
		for subt,iva,importe in select coalesce(c16,0),coalesce(c18,0),coalesce(c19,0) 
			from keplersc.kdtot where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto
		loop
			if aplicar_iva='N' then 
				importe = importe-iva;
				iva=0;
			end if;
			subtotal_tots_punto := subtotal_tots_punto + subt;
			iva_tots_punto := iva_tots_punto + iva;
			importe_tots_punto := importe_tots_punto + importe;		
			subt:=0; iva:=0; importe:=0;
		end loop;
		subtotal_total_tots := subtotal_total_tots + subtotal_tots_punto;
		iva_total_tots := iva_total_tots + iva_tots_punto;
		importe_total_tots := importe_total_tots + importe_tots_punto;
	raise notice 'Tots---subt:% iva:% tot:%',subtotal_total_tots,iva_total_tots,importe_total_tots;	
		--10 subtotal
		--11 iva
		--12 total
		subt:=0; iva:=0; importe:=0;	
		subtotal_car_punto:=0; iva_car_punto:=0; importe_car_punto := 0;
		for subt,iva,importe in select coalesce(c10,0),coalesce(c11,0),coalesce(c12,0) 
			from keplersc.kdcar where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto
		loop
			if aplicar_iva='N' then 
				importe = importe-iva;
				iva=0;
			end if;
			subtotal_car_punto := subtotal_car_punto + subt;
			iva_car_punto := iva_car_punto + iva;
			importe_car_punto := importe_car_punto + importe;			
			subt:=0; iva:=0; importe:=0;
		end loop;
		subtotal_total_car := subtotal_total_car + subtotal_car_punto;
		iva_total_car := iva_total_car + iva_car_punto;
		importe_total_car := importe_total_car + importe_car_punto;
	raise notice 'Cargos---subt:% iva:% tot:%',subtotal_total_car,iva_total_car,importe_total_car;		
		--17 subtotal	=hrs*costoxhr
		--18 iva
		--19 total
		subt:=0; iva:=0; importe:=0;
		subtotal_horas_punto:=0; iva_horas_punto:=0; importe_horas_punto := 0;
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
				raise exception 'Sin precio de paquete:% , orden:%',clave_paquete,folio_orden;	--Debe ser un raise exception
				continue;
			end if;
			subt := hrs * costo_por_hora;
			--2dec subt := hrs * round(costo_por_hora,2);
			iva := subt * (iva_default/100);
			importe := subt + iva;
			--MSS 04102024 No permitir costo de mano de obra negativo
			if subt < 0 then
				raise exception 'El costo de la Mano de Obra no puede negativo, punto:%',numero_punto;
			end if;
		raise notice 'Horas-pto---hr:% cost:% subt:% iva:% tot:%',hrs,costo_por_hora,subt,iva,importe;	
			update keplersc.kdhoras set c14=costo_por_hora,c17=coalesce(subt,0),c18=coalesce(iva,0),c19=coalesce(importe,0) 
				where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto and c5=partida;
			
			subtotal_horas_punto := subtotal_horas_punto + subt;			
			iva_horas_punto := iva_horas_punto + iva;
			importe_horas_punto := importe_horas_punto + importe;	
			subt:=0; iva:=0; importe:=0;
		
		end loop;
	
		subtotal_total_horas := subtotal_total_horas + subtotal_horas_punto;
		iva_total_horas := iva_total_horas + iva_horas_punto;
		importe_total_horas := importe_total_horas + importe_horas_punto;
	raise notice 'Horas---subt:% iva:% tot:%',subtotal_total_horas,iva_total_horas,importe_total_horas;		
	end loop;

	subtotal :=  subtotal_total_refs + subtotal_total_tots + subtotal_total_car + subtotal_total_horas;
	iva_total := iva_total_refs + iva_total_tots + iva_total_car + iva_total_horas;
	importe_total := importe_total_refs + importe_total_tots + importe_total_car + importe_total_horas;

	--raise notice 'Total---subt:% iva:% tot:%',subtotal,iva_total,importe_total;		
	--Enviar subtotales con etiqueta de importe_total... para no modificar programas
	select xmlforest(round(subtotal_total_refs,6) as importe_total_refs, round(subtotal_total_tots,6) as importe_total_tots, round(subtotal_total_car,6) as importe_total_car, 
		   round(subtotal_total_horas,6) as importe_total_horas, round(subtotal,6) as subtotal, round(iva_total,6) as iva_total, round(importe_total,2) as importe_total) :: text into xmlResultado;
	
		
	return xmlResultado;

exception
	when others then
		msgErr:= '['|| sqlstate || '] ' || sqlerrm ;
		raise exception '%', 'Sin Resultados. ' || msgErr;	--Le concatene el error xq no se mostraba
		
end;
$function$
