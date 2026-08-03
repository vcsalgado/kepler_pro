CREATE OR REPLACE FUNCTION keplersc.calcula_precio_ref(clave_refaccion text, catalogo integer, metodo_calculo integer, utilidad_base numeric, iva numeric, ult_costo numeric, costo_prom numeric)
 RETURNS TABLE(precio numeric)
 LANGUAGE plpgsql
AS $function$
--Descripcion: calcula precio refaccion
--Autor: Luis Leal
--Fecha: 26/05/2022
--Bitacora de cambios
declare 
	precio_con_iva decimal = 0.00;
	costo_distribuidor decimal = 0.00;
	unidad_de_empaque int = 0;
	precio_publico decimal = 0.00;

	--Variables de retorno
	precio decimal = 0.00;

begin
	--VCSS 28 jun 2026, si no se tiene costo promedio por no haber existencias, manejar último costo.
	if costo_prom = 0 then
		costo_prom = ult_costo; 
	end if; 
	--SUB CALCULA_PRECIO_PAQ_GM
	if catalogo = 1 then
		if metodo_calculo = 1 or metodo_calculo = 2 then
			precio := costo_prom * (1+utilidad_base/100);
		end if;
		if  metodo_calculo = 3 then
			select c7 into precio_con_iva from keplersc.kdigm where c1=clave_refaccion;
			if found then
				precio := precio_con_iva/(1+iva/100);
			else
				precio := costo_prom * (1+utilidad_base/100);
			end if;
		end if;
		--costo de planta mas margen
		if metodo_calculo = 4 then
			select c5,c13 into costo_distribuidor,unidad_de_empaque from keplersc.kdigm where c1=clave_refaccion;
			if found then
				precio := (costo_distribuidor/unidad_de_empaque)*(1+utilidad_base/100);
			else
				precio := costo_prom * (1+utilidad_base/100);
			end if;
		end if;	
	 end if;
		
	--SUB CALCULA_PRECIO_PAQ_TOYOTA
	if catalogo = 3 then
		if metodo_calculo = 1 then 
			precio := ult_costo * (1+utilidad_base/100);
		end if;
		if metodo_calculo = 2 then
			precio := costo_prom * (1+utilidad_base/100);
		end if;
		if metodo_calculo = 3 then
			select c8 into precio_publico from keplersc.kdtvr2 where c1=clave_refaccion;
			if found then
				precio := precio_publico;
			else
				precio := ult_costo * (1+utilidad_base/100);
			end if;
		end if;
		if metodo_calculo = 4 then
			select c6 into costo_distribuidor from keplersc.kdtvr2 where c1=clave_refaccion;
			if found then
				precio := costo_distribuidor * (1+utilidad_base/100);
			else 
				precio := ult_costo * (1+utilidad_base/100);
			end if;
		end if;
		if metodo_calculo = 5 then
			select c8 into precio_publico from keplersc.kdtvr2 where c1=clave_refaccion;
			if found then
				precio := precio_publico * (1+utilidad_base/100);
			else 
				precio := ult_costo * (1+utilidad_base/100);
			end if;
		end if;
	end if; 


	--LGLG 27/06/24 GWM precios
	if catalogo = 4 then
	
		if metodo_calculo = 1 then
		
			select c11 into precio_publico from keplersc.kdini where c1=clave_refaccion;
			if found then
				precio := precio_publico;
			else			
				precio := costo_prom * (1+utilidad_base/100);
			end if;
		
		end if ;
	
	end if;
	
	precio := round(precio::decimal,2);
	return query select precio;

end;
$function$
