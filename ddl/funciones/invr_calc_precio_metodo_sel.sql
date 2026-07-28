CREATE OR REPLACE FUNCTION keplersc.invr_calc_precio_metodo_sel(dataxml xml)
 RETURNS TABLE(precio numeric)
 LANGUAGE plpgsql
AS $function$
declare 
	--Variables de definicion de documento
	sucursal_id text = ''; 
	producto text = '';
	nombre_precio text = '';

	--Variables de proceso
	I3 int = 0; --Sub_regla / Tipo precio
	I4 decimal = 0.00;
	I5 decimal = 0.00;
	I6 int = 0; --Regla /Marca Auto
	factor_existencia decimal = 0.00;
	factor_valor decimal = 0.00;
	factor_3 decimal = 0.00;
	factor_utilidad_base decimal = 0.00;
	factor_iva decimal = 0.00;
	ultimo_costo decimal = 0.00;
	distribuidor_costo decimal = 0.00;
	distribuidor_precio_mayoreo decimal = 0.00;
	distribuidor_precio_publico decimal = 0.00;
	unidad_empaque decimal = 0.00;
	error text = '';
	xmlKDINL xml;
	xmlArmadora xml;
	expSql text = '';
	strValor text = '';
	regProveedor text = 'N';	
	contReg int = 0;

	--Variables de retorno
	precio decimal = 0.00;
begin
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	producto := (xpath('//document/producto/text()', dataxml))[1];
	nombre_precio := (xpath('//document/nombre_precio/text()', dataxml))[1];
	
	--Obtener detalle de precio en catalogo
	select c3,c4,c5,c6 into I3,I4,I5,I6 from keplersc.kdicatprecio where lower(c1) = lower(nombre_precio);
	--Obtener el factor Utilidad Base 
	factor_Utilidad_Base := (1+I4::decimal/100)::decimal;

	--Obtener resumen de moivimientos a inventario
	--Obtener resumen de moivimientos a inventario
	select count(*) into contReg from keplersc.kdinl where c1=sucursal_id and upper(c2)=upper(producto);

	--Si hsy estadistica del producto se obtiene el precio, de lo contario se regresara cero
	if contReg > 0 then --Definicion de regla encontrada
		expSql := format('select * from keplersc.kdinl where c1=%1$L and c2=%2$L',sucursal_id, producto);
		xmlKDINL := query_to_xml(expSql,false,false,'');
	
		--Calculo de posibles factores
		factor_valor :=
	((xpath('//table/row/c8/text()', xmlKDINL))[1]::text::decimal - (xpath('//table/row/c9/text()', xmlKDINL))[1]::text::decimal);
		factor_existencia := ((xpath('//table/row/c5/text()', xmlKDINL))[1]::text::decimal - (xpath('//table/row/c6/text()', xmlKDINL))[1]::text::decimal);
		factor_utilidad_base := (1+I4::decimal/100)::decimal;
		factor_iva := (1+I4::decimal/100)::decimal;
		ultimo_costo = (xpath('//table/row/c14/text()', xmlKDINL))[1]::text::decimal;	

--raise notice 'FV %', factor_valor;
--raise notice 'FE %', factor_existencia;
--raise notice 'FUB %, %, :%',I4 , nombre_precio, factor_Utilidad_Base;
--raise notice 'UC %', ultimo_costo;	
raise notice 'I6=%, I3=%',I6,I3;
		precio := 0;
		case 
			when I6 = 1 then ---Resuelve OIS.CALCULA_PRECIO_INVR_GM
				--Obtener parametros individuales
				expSql := format('select * from keplersc.kdigm where c1=%1$L',producto);			
				xmlArmadora := query_to_xml(expSql,false,false,'');
				strValor := (xpath('//table/row/c1/text()', xmlArmadora))[1];
				if strValor is not null then
					regProveedor = 'S';
					distribuidor_costo = (xpath('//table/row/c5/text()', xmlArmadora))[1]::text::decimal;
					distribuidor_precio_mayoreo = (xpath('//table/row/c6/text()', xmlArmadora))[1]::text::decimal;
					distribuidor_precio_publico = (xpath('//table/row/c7/text()', xmlArmadora))[1]::text::decimal;
					unidad_empaque = (xpath('//table/row/c13/text()', xmlArmadora))[1]::text::decimal;
				else
					regProveedor = 'N';
				end if;	
				case
					when I3 = 1 then --'ULTIMO COSTO + MARGEN DE UTILIDAD
						--A(B10041)=(K8-K9)/(K5-K6)*(1+I4/100)
						if factor_existencia > 0 then
							precio:= factor_valor/factor_existencia * factor_Utilidad_Base;
						end if;
					when I3 = 2 then --'COSTO PROMEDIO + MARGEN DE UTILIDAD
						--A(B10041)=(K8-K9)/(K5-K6)*(1+I4/100)
						if factor_existencia > 0 then
							precio:= factor_valor/factor_existencia * factor_Utilidad_Base;
						end if;
						--TO DO: Verificar esta validacion en el origina para es la misma
						--precio:=factor_valor / factor_existencia * factor_Utilidad_Base; 
						--if precio = 0 then
							--A(B10041)=(K8-K9)/(K5-K6)*(1+I4/100)
							--precio:=factor_valor / factor_existencia * factor_Utilidad_Base; 
						--end if;
					when I3 = 3 then --'PRECIO PUBLICO DE PLANTA					
						if regProveedor = 'S' then
							--A(B10041)=J7/(1+I5/100)
							if factor_iva > 0 then
								precio := distribuidor_precio_publico/factor_iva;
							end if;	
						else
							--A(B10041)=(K8-K9)/(K5-K6)*(1+I4/100)
							if factor_existencia > 0 then
								precio:=factor_valor / factor_existencia * factor_Utilidad_Base;
							end if;	 						
						end if;						
					when I3 = 4 then --'COSTO DE PLANTA + MARGEN
						if regProveedor = 'S' then
							--A(B10041)=(J5/J13)*(1+I4/100)
							if factor_existencia > 0 then
								precio:=distribuidor_costo / unidad_empaque * factor_Utilidad_Base;
							end if;	
						else
							--A(B10041)=(K8-K9)/(K5-K6)*(1+I4/100)
							if factor_existencia > 0 then
								precio:=factor_valor / factor_existencia * factor_Utilidad_Base;
							else
								precio := ultimo_costo * factor_Utilidad_Base;
							end if;	
						end if;
					when I3 = 5 then --'PRECIO DE PLANTA + MARGEN
						if regProveedor = 'S' then
							--A(B10041)=J7/(1+I5/100)/(1+I4/100)
							if factor_iva > 0 and factor_utilidad_base > 0 then
								precio:=distribuidor_precio_publico/factor_iva/factor_utilidad_base;
							end if;
						else
							--A(B10041)=(K8-K9)/(K5-K6)*(1+I4/100)
							if factor_existencia > 0 then
								precio:=factor_valor / factor_existencia * factor_Utilidad_Base;
							end if;	
						end if;
					else
						precio := 0.00;
				end case;

			when I6 = 2 then ---Resuelve OIS.CALCULA_PRECIO_INVR_SEAT
				--TO DO: Desarrollar	
				precio := 0.00;
			when I6 = 3 then --Resuelve OIS.CALCULA_PRECIO_INVR_TOYOTA
				--Obtener parametros individuales
				expSql := format('select * from keplersc.kdtvr2 where c1=%1$L',producto);			
raise notice 'expSql=%', expSql;				
				xmlArmadora := query_to_xml(expSql,false,false,'');
				strValor := (xpath('//table/row/c1/text()', xmlArmadora))[1];
				if strValor is not null then
					regProveedor = 'S';
					distribuidor_costo = (xpath('//table/row/c6/text()', xmlArmadora))[1]::text::decimal;
					distribuidor_precio_mayoreo = (xpath('//table/row/c7/text()', xmlArmadora))[1]::text::decimal;
					distribuidor_precio_publico = (xpath('//table/row/c8/text()', xmlArmadora))[1]::text::decimal;
				else
					regProveedor = 'N';
				end if;		
				case
					when I3 = 1 then --'ULTIMO COSTO + MARGEN DE UTILIDAD
						--A(B10041)=K14*(1+I4/100)
						precio:= ultimo_costo * factor_Utilidad_Base;
					when I3 = 2 then --'COSTO PROMEDIO + MARGEN DE UTILIDAD
						--A(B10041)=(K8-K9)/(K5-K6)*(1+I4/100)
						if factor_existencia > 0 then
							precio:= factor_valor/factor_existencia*factor_Utilidad_Base;	
						end if;	
					when I3 = 3 then --'PRECIO PUBLICO DE PLANTA					
						if regProveedor = 'S' then
							--A(B10041)=J8
							precio := distribuidor_precio_publico;
						else
							--A(B10041)=K14*(1+I4/100)
							precio := ultimo_costo * factor_Utilidad_Base;
						end if;

					when I3 = 4 then --'COSTO DE PLANTA + MARGEN
						if regProveedor = 'S' then
							--A(B10041)=J6*(1+I4/100)
							precio := distribuidor_costo * factor_Utilidad_Base;
						else
							--A(B10041)=K14*(1+I4/100)
							precio := ultimo_costo * factor_Utilidad_Base;
						end if;					
					when I3 = 5 then --'PRECIO DE PLANTA + MARGEN
						if regProveedor = 'S' then
							--A(B10041)=J8*(1+I4/100)
							precio := distribuidor_precio_publico * factor_Utilidad_Base;
						else
							--A(B10041)=K14*(1+I4/100)
							precio := ultimo_costo * factor_Utilidad_Base;
						end if;
					else
						precio := 0.00;
				end case;
			when I6 = 4 then --Resuelve OIS.CALCULA_PRECIO_INVR_FIAT
				--TO DO: Desarrollar
				precio := 0.00;
			when I6 = 5 then --Resuelve OIS.CALCULA_PRECIO_INVR_HINO
				--TO DO: Desarrollar
				precio := 0.00;			
			else
				--TO DO: Desarrollar
				precio := 0.00;
		end case;
	end if;	

	precio := round(precio::decimal,2);
	return query select precio;

end;
$function$
