CREATE OR REPLACE FUNCTION keplersc.invlib_sumas_inv(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: SUMAS_INV - se adapta la funcion ISAN_INV dentro de esta funcion
--Autor: Saltiel Rc
--Fecha: 27/09/2022

declare
	v_sucursal_id text = ''; 
	v_consecutivo text = '';	
	v_contador numeric = 0;
	v_inventario text ='';
	genero text;
	naturaleza text;
	grupo text;
	tipo_clave text;
	---se asume que las variables h pertenecen a KDLINV
	v_entradas_unidades numeric = 0;
	v_salidas_unidades numeric = 0;
	v_entradas_en_monto numeric = 0;
	v_salidas_en_monto numeric = 0;
	v_ultimo_costo numeric = 0;
	v_ultimo_iva numeric = 0;
	v_B7040_Costo numeric = 0;
	v_B7041_PorcIVA numeric = 0;
	
	v_ISAN numeric = 0; --ISAN valor retorno
	v_IVA numeric = 0; -- IVA
	v_ISAN_Ant numeric =0;
	
	v_B7012_ImporteUnidad numeric = 0;
	v_B7013_TasaIVA numeric = 0;
	v_B7014_ImporteUnidad numeric = 0;
	v_B7015_TipoOper numeric = 0;
	---se asume que las variables h pertenecen a KDINF
	v_limite_superior numeric = 0;
	v_porcentaje numeric = 0;
	v_limite_inferior numeric = 0;
	v_tarifa numeric = 0;
	v_porcentaje_reduccion numeric = 0;
	v_cuota_de_excedente numeric = 0;
	v_restador numeric = 0;
	
	----j asume la tabla KDINF
	v_clave_del_vehiculo  text = '';
	v_nuevo_o_usado text = '';
	--valor de la tabla KDMM
	v_m16 numeric = 0 ;
	v_m16_1 text ='';
	-- valores para KDIV
	v_k_c6 text = '';
	v_B7020_PorcISAN decimal = 0;
	v_B7021_PorcReduccion decimal = 0;
	v_B7023 decimal = 0;
	v_B7025 decimal = 0;
	v_B7026 decimal = 0;
	v_B7027 decimal = 0;
	v_B7028 decimal= 0;
	v_B7029 decimal = 0;
	
	
	resultado text= '';
	mensaje text = '0';
	adicionales text = '';
	totreg int = 0;
	v_nocatalogo text =''; 
	get_resultado text ='';
	get_mensaje text ='';

begin
	v_sucursal_id := upper((xpath('//document/k_sucn/r1/text()', dataxml))[1]::text); --
	v_inventario := upper((xpath('//document/k_inventario/text()', dataxml))[1]::text);
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];			
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];	
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];	
	v_B7012_ImporteUnidad:= (xpath('//document/k_b7012/text()', dataxml))[1];	
	v_B7012_ImporteUnidad:= v_B7012_ImporteUnidad::numeric;	
	v_B7014_ImporteUnidad:= (xpath('//document/k_b7014/text()', dataxml))[1];	
	v_B7014_ImporteUnidad:= v_B7014_ImporteUnidad::numeric;	
	--raise notice 'v_B7014_ImporteUnidad %',v_B7014_ImporteUnidad;
	v_B7015_TipoOper:= (xpath('//document/k_b7015/text()', dataxml))[1];	
	v_B7015_TipoOper:=v_B7015_TipoOper::numeric;	

	select count(*) into totreg from keplersc.kdmm 
		where col_sucursal=v_sucursal_id and c1 = genero and c2 = naturaleza and c3 = grupo::numeric  and c4 = tipo_clave::numeric;
	if totReg>0 then 
		v_m16:=(select c16 from keplersc.kdmm where col_sucursal=v_sucursal_id and c1 = genero and c2 = naturaleza and c3 = grupo::numeric  and c4 = tipo_clave::numeric)::numeric;
	else
		v_m16:=16;
	end if;
	v_B7013_TasaIVA = v_m16;
			
	select c3,c21 into v_clave_del_vehiculo,v_nuevo_o_usado from keplersc.KDINF where c1 = v_sucursal_id and c2 = v_inventario;
	if((select count(*)  from keplersc.KDLINV where c1 = v_sucursal_id and c2 = v_inventario) > 0 and 
	   (select count(*) from keplersc.kdinf where c1 = v_sucursal_id and c2 = v_inventario) > 0 )
	   then 
		--H			   
		select c3,c4,c5,c6,c8,c9 
			into v_entradas_unidades,v_salidas_unidades,v_entradas_en_monto,v_salidas_en_monto,v_ultimo_costo,v_ultimo_iva  
			from keplersc.KDLINV where c1 = v_sucursal_id and c2 = v_inventario;
		if (v_entradas_unidades - v_salidas_unidades) = 0 then 
			v_B7040_Costo = v_ultimo_costo;
		else	
			v_B7040_Costo = ((v_entradas_en_monto - v_salidas_en_monto) / (v_entradas_unidades-v_salidas_unidades)); --COSTO
		end if;
		--raise notice 'v_B7040_Costo %',v_B7040_Costo;
		if v_B7040_Costo = 0 then 
			v_B7040_Costo = v_ultimo_costo;
		end if;
		v_B7041_PorcIVA = (v_ultimo_iva /v_ultimo_costo) * 100; --IVA
		v_B7041_PorcIVA = (select ABS(v_B7041_PorcIVA-v_m16));
		--v_B7041_PorcIVA = (select Round(v_B7041_PorcIVA));--16
--raise notice 'v_B7041_PorcIVA %',v_B7041_PorcIVA;
		if(v_B7041_PorcIVA > 1) then --SI EL IVA DE COMPRA ES IGUAL A 0 CALCULA EL IVA SOBRE LA UTILIDAD ENTRE EL IMPORTE DE LA UNIDAD Y EL COSTO
			v_IVA = (v_B7012_ImporteUnidad-v_B7040_Costo)*v_B7013_TasaIVA/100/(1+v_B7013_TasaIVA/100);				   
			if(v_IVA<0) then	
				v_IVA = 0; 
			end if;
			v_IVA = v_IVA + ( (v_B7014_ImporteUnidad-v_B7012_ImporteUnidad)-((v_B7014_ImporteUnidad-v_B7012_ImporteUnidad)/(1+v_B7013_TasaIVA/100)) );
			--raise notice '2 v_IVA %',v_IVA;	
		--raise notice '1 v_IVA %',v_IVA;
		else --SI EL IVA DE COMPRA ES MAYOR A 0 CALCULA EL IVA SOBRE EL IMPORTE DE LA FACTURA QUE PUEDE INCLUIR PVAS
			v_IVA= v_B7014_ImporteUnidad-(v_B7014_ImporteUnidad/(1+v_B7013_TasaIVA/100));
			--raise notice '2 v_IVA %',v_IVA;
		end if;
--raise notice 'v_IVA %',v_IVA;
		--raise notice 'INICIA ciclo';
		if(v_nuevo_o_usado = 'NUEVO' and v_B7015_TipoOper = 1 ) then 
			--call ISAN_INV
			if((select count(*) from keplersc.kdiv where c1 = v_clave_del_vehiculo) > 0) then 
				v_ISAN = 0;	
			v_ISAN_Ant = 0;
			for v_limite_inferior,v_limite_superior,v_porcentaje,v_tarifa,v_porcentaje_reduccion,v_cuota_de_excedente,v_restador in select c4,c5,c6,c7,c8,c9,c10  from  keplersc.KDISAN where C1 = (select distinct(c6) from keplersc.kdiv where c1 = v_clave_del_vehiculo )
				loop 					
--raise notice '****** Evaluando registro KDISAN'; 
--raise notice 'lim. inf. %; lim. sup. %; porcentaje %; tarifa %; porc. reduccion %; cuota excedente %; restador %'
--,v_limite_inferior,v_limite_superior,v_porcentaje,v_tarifa,v_porcentaje_reduccion,v_cuota_de_excedente,v_restador;
					v_contador =v_contador +1;
					 v_B7020_PorcISAN=v_porcentaje / 100;--PORCENTAJE DE ISAN
--raise notice 'Porc. ISAN (B7020) %', v_B7020_PorcISAN;
				     v_B7021_PorcReduccion=v_porcentaje_reduccion / 100;--PORCENTAJE DE REDUCCION EN CASO DE SER MAYOR A EXCEDENTE
--raise notice 'Porc. Reduccion (B7021) %', v_B7021_PorcReduccion;
				     v_B7023=v_B7014_ImporteUnidad-v_IVA;--'IMPORTE MENOS IVA
--raise notice 'Importe sin Iva (B7023) %', v_B7023;
				     v_B7025= ((v_B7023-v_restador)*v_B7020_PorcISAN)+v_tarifa;--'[(<IMPORTE MENOS IVA> MENOS <RESTADOR>) POR <PORCENTAJE DE ISAN>] MAS LA TARIFA
--raise notice '(Importe sin IVA - Restador)*PorcISAN + Tarifa (B7025) %' , v_B7025;
				     v_B7026= (v_B7023-v_cuota_de_excedente) * v_B7021_PorcReduccion;--'(<IMPORTE MENOS IVA> MENOS <EXCEDENTE>) POR <PORCENTAJE DE REDUCCION>
--raise notice 'Importe sin IVA - cuota_excedente * PorcReduccion (B7026) %', v_B7026;
				     v_B7027= 1 + v_B7020_PorcISAN - v_B7021_PorcReduccion;
--raise notice 'PorcISAN + 1 - Porc. reduccion (B7027) %', v_B7027;
				     v_B7028= (v_B7025-v_B7026)/v_B7027 ;--'(<ISAN> - <REDUCCION POR EXCEDENTE>) ENTRE
--raise notice 'ISAN (v_B7028) %', v_B7028;
				     v_B7029= v_B7014_ImporteUnidad-v_IVA-v_B7028;
--raise notice 'Importe unidad - IVA- ISAN (v_B7029) % ', v_B7029;
--raise notice 'Evalua B7029 (%)>=lim. inf.(%) and B7029(%)<=lim. sup.(%) ',v_B7029,v_limite_inferior,v_B7029,v_limite_superior;
				     if v_B7029 >= v_limite_inferior AND v_B7029 <= v_limite_superior then
					      v_ISAN = v_B7028;
--raise notice 'SI, ISAN a aplicar %',v_ISAN;					     
					    exit;
					 else 
					 	--Validar que no sea el rango anterior
					 	if v_B7029 < v_limite_inferior then
					 		v_ISAN=v_ISAN_Ant;
--raise notice 'SI, ISAN anterior a aplicar %',v_ISAN;					 	
					 		exit;
					 	end if;
				     end if;
					v_ISAN_Ant = v_B7028;				    
--raise notice 'NO, ISAN a aplicar %',v_ISAN;
--raise notice '';
				end loop;
	
			end if;
		else 
			v_ISAN = 0;
		end if;
		
	end if;
				
	resultado ='1';
	mensaje = v_ISAN;-- ISAN
	adicionales = v_IVA; --IVA

return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;	
		mensaje := 'invlib_sumas_inv() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
END;
$function$
