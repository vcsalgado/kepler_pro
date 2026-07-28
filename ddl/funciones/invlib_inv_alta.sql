CREATE OR REPLACE FUNCTION keplersc.invlib_inv_alta(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 

	--Debe ser llamada con los parametros dataXml y xmlKDMM)	
	--Autor: Saltiel Cruz
	--Fecha: 17 Oct 2022
	--actualizado:07/Dic/2022
	--Bitacora de cambios
	--28/11/25 Miriam Santana: Agregue la sucursal en el where de los select a KDM1

	--Variables para xml
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_clave text;
	v_inventario text ='';
	v_partida numeric = 0;	
	v_h_c10_mes numeric =0;
	v_h_c10_anio numeric = 0;
	v_h_c10 timestamp;
	v_costo numeric = 0;
	v_iva numeric = 0;
	--xml Movimiento
	xmlKDM1 xml;
	xmlKDM1_c3 text = '';
	v_Entrada_Salida numeric = 0;
	v_num_partida numeric = 0;
	v_entradas_unidades numeric = 0;
	v_salidas_unidades numeric = 0;
	v_entradas_en_monto numeric = 0;
	v_salidas_en_monto numeric = 0;
	v_entradas_en_iva numeric = 0;
	v_salidas_en_iva numeric = 0;
	v_ultimo_costo numeric = 0;
	v_ultimo_iva numeric = 0;
	v_k_c7 timestamp;
	v_k_c13 numeric = 0;	

	-- Adde by JMM 20230108
	v_fecha date;
	v_modelo text;
	v_color text;
	v_vestiduras text;
	v_nvousd text;
	tot_regs numeric;
	
	xmlKDM1_c65 text = '';
	--Variables de uso general
	mensajeError text;
		
	--commented by JMM 20230108 ... to fix Saltielazo 
	--folio_operacion text;

	xmlResultado xml;
			
	--Variables de retorno desde funciones externas
	get_resultado text; --retorno
	get_mensaje text; --retorno
	get_adicionales text; --retorno
	

begin
	
	-- Inicializacion de variables
	--commented by JMM 20230108 ... to fix Saltielazo 
	--folio_operacion := 0;
	get_resultado := '';
	get_adicionales := '';

	--Documento
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r5/text()', dataxml))[1];	
	v_inventario := upper((xpath('//document/k_inventario/text()', dataxml))[1]::text);
	
	xmlKDM1_c3 := naturaleza;  

	if xmlKDM1_c3 = 'D' then 
		v_Entrada_Salida = 10;--SALIDA DEL INVENTARIO
	else
		v_Entrada_Salida = 0; --ENTRADA AL INVENTARIO
	end if;

 	v_num_partida = 1;
 	select count(*) into v_partida from keplersc.kdeinv where  c1 = sucursal_id and C2 = v_inventario;
 	if v_partida > 0 then ---revisar si funcionará de esta forma
 		v_num_partida = v_partida + 1;	 	
 	end if;
 
	select c3,c4,c5,c6,c10,c11,c8,c9 
		into v_entradas_unidades,v_salidas_unidades,v_entradas_en_monto,v_salidas_en_monto
		,v_entradas_en_iva,v_salidas_en_iva,v_ultimo_costo,v_ultimo_iva 
	from keplersc.kdlinv where c1 = sucursal_id and C2 = v_inventario;
 	
	if genero = 'X' then --W2="X"
	
		 -- Updated by JMM 20230108 ... El Inventario puede estar en varios registros,
		 -- ... por eso debe usarse el Folio 
	 	 --select (c16-c54-c14) as c16, c14 into v_costo,v_iva  from keplersc.kdm1 where c2 = genero and c3 = naturaleza and c4= grupo::numeric and c5 = tipo::numeric and c100 = v_inventario;
		 --MSS 28112025 Agregue la sucursal al where del select a kdm1
		 select (c16-c54-c14) as c16, c14 into v_costo,v_iva  from keplersc.kdm1 where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4= grupo::numeric and c5 = tipo::numeric and c6 = folio_operacion;
		
	else 
	
		v_costo = 0;	 	 
	    v_iva = 0;
	    
	  	if(select count(*) from keplersc.kdlinv where c1 = sucursal_id and C2 = v_inventario) > 0 then 		  	 
	  		
			if(v_entradas_unidades - v_salidas_unidades) = 0 then
				 v_costo = 0;	 	 
			     v_iva = 0;
			else
				 v_costo = (v_entradas_en_monto-v_salidas_en_monto) / (v_entradas_unidades - v_salidas_unidades);	 	 
			     v_iva = (v_entradas_en_iva - v_salidas_en_iva) / (v_entradas_unidades - v_salidas_unidades);
			end if;
	  	else 
		  	if genero = 'N' then --W2="N"	
		  	
		  		-- Updated by JMM 20230108 ... El Inventario puede estar en varios registros,
	 			-- ... por eso debe usarse el Folio 		 	 
				--select (c16-c54-c14) as c16,c14 into v_costo, v_iva from keplersc.kdm1 where c2 = genero and c3 = naturaleza and c4= grupo::numeric and c5 = tipo::numeric and c100 = v_inventario;
				--MSS 28112025 Agregue la sucursal al where del select a kdm1
		  		select (c16-c54-c14) as c16,c14 into v_costo, v_iva from keplersc.kdm1 where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4= grupo::numeric and c5 = tipo::numeric and c6 = folio_operacion;
		  	
			end if;
	  	end if;
		  
	    -- UPD by JMM 20230108 ... to review w/VCSS
	 	--if v_costo = 0 then
	    if v_costo <= 0 then
			v_costo = v_ultimo_costo;
	 	end if;
		
	 	-- UPD by JMM 20230108 ... to review w/VCSS
	 	--if v_iva = 0 then
	 	if v_iva <= 0 then
			v_iva = v_ultimo_iva;
	 	end if;
		
	end if;	
	
	-- Code Added by JMM 20230108
	--MSS 28112025 Agregue la sucursal al where del select a kdm1
	select c9 into v_fecha 
	from keplersc.kdm1 where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::numeric and c5 = tipo::numeric and c6 = folio_operacion;
	v_modelo = '';
	v_color = '';
	v_vestiduras = '';
	v_nvousd = '';

	select c3, c10, c11, c21 into v_modelo, v_color, v_vestiduras, v_nvousd 
	from keplersc.kdinf where c1 = sucursal_id and C2 = v_inventario;
	
	/*
	insert into keplersc.kdeinv (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) 
	values (sucursal_id,v_inventario,v_num_partida,v_Entrada_Salida,genero,
			naturaleza,grupo::numeric,tipo::numeric,
			folio_operacion,
			-- Commented by JMM 20230108 
			/*
			(select now())::timestamp, 
			--(select c9 from keplersc.kdm1 where c2 = genero and c3 = naturaleza and c4= grupo::numeric and c5 = tipo::numeric and c100 = v_inventario)
			*/
			v_fecha, 
			v_costo, v_iva,
			-- Commented by JMM 20230108
			/*
			(select c3 from keplersc.kdinf where c1 = sucursal_id and C2 = v_inventario)::text
			*/
			v_modelo);
		--raise notice 'inv_alta()  insert KDEINV';
	*/

	-- code Adapted by JMM 20230108
	insert into keplersc.kdeinv (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) 
	values (sucursal_id,v_inventario,v_num_partida,v_Entrada_Salida,genero,
			naturaleza,grupo::numeric,tipo::numeric,
			folio_operacion, v_fecha, v_costo, v_iva, v_modelo);
	
	-- code Added by JMM 20230108 ... this valition is because insert wasnt done
	tot_regs = 0;
	select count(c1) into tot_regs from keplersc.kdeinv 
	where c1 = sucursal_id and c5 = genero and c6 = naturaleza and c7 = grupo::numeric 
		and c8 = tipo::numeric and c9 = folio_operacion; 
	if tot_regs = 0 then
		mensaje = '[JMM] Paso por todas las Funciones de Invetarios, se Procedera con el Registro.';
		raise exception '%', mensaje;
	end if;
		
	--raise notice 'inv_alta()  insert KDEINV';

		
--***************************************-----------------------------INV_ALTA_K
	v_costo = 0;
	v_iva = 0;
	
	-- Fixed By JMM 20230108 ... Esta Erronea
	--select c10,EXTRACT(month FROM c10),EXTRACT(month FROM c10),c11,c12 into v_h_c10,v_h_c10_mes,v_h_c10_anio,v_costo,v_iva from keplersc.KDEINV where  c1 = sucursal_id and C2 = v_inventario;
	select c10, extract(month from c10), right(extract(year from c10)::text,2), c11, c12 
	into v_h_c10, v_h_c10_mes, v_h_c10_anio, v_costo, v_iva 
	from keplersc.kdeinv where c1 = sucursal_id and C2 = v_inventario 
		-- Code Added by JMM 20030108
		and c5 = genero and c6 = naturaleza and c7 = grupo::numeric and c8 = tipo::numeric and c9 = folio_operacion;
	
	if (select count(*) from keplersc.kdinf where c1 = sucursal_id and C2 = v_inventario) > 0 then 	
	
			if (select count(*) from keplersc.kdginv where c1 = sucursal_id and C2 = v_inventario and c3 = v_h_c10_mes and c4 = v_h_c10_anio) = 0 then
			
				insert into keplersc.kdginv (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10)
				values (sucursal_id,v_inventario,v_h_c10_mes,v_h_c10_anio,
						0,0,
						-- Commented by JMM 202030108 
						/*
						(select c3 from keplersc.kdinf where c1 = sucursal_id and C2 = v_inventario),
						(select c10 from keplersc.kdinf where c1 = sucursal_id and C2 = v_inventario),
						(select c11 from keplersc.kdinf where c1 = sucursal_id and C2 = v_inventario),
						(select c21 from keplersc.kdinf where c1 = sucursal_id and C2 = v_inventario)
						*/
						-- Added by JMM 202030108
						v_modelo, v_color, v_vestiduras, v_nvousd );
					
			end if;	
		
			-- K KDLINV
			if (select count(*) from keplersc.kdlinv where c1 = sucursal_id and C2 = v_inventario) = 0 then 
			
				insert into keplersc.kdlinv (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15)
				values (sucursal_id,v_inventario,0,0,0,0,(select now()),0,0,0,0,
						-- Commented by JMM 202030108 
						/*(select c3 from keplersc.kdinf where c1 = sucursal_id and C2 = v_inventario),*/
						v_modelo, 0,  
						-- Commented by JMM 202030108 
						/*
						(select c10 from keplersc.kdinf where c1 = sucursal_id and C2 = v_inventario),
						(select c11 from keplersc.kdinf where c1 = sucursal_id and C2 = v_inventario))
						*/
						v_color, v_vestiduras ); 
					
			end if;
			
			select c7 into v_k_c7 from keplersc.kdlinv where c1 = sucursal_id and C2 = v_inventario;
		
			--ENTRADA
		  	if v_Entrada_Salida = 0 then
		  	
				update keplersc.kdginv				
				set c5 = c5 + 1,
					c11 = c11 + v_costo,
					--Fixed by JMM 20230108
					--c12 = c12 + v_iva
					c13 = c13 + v_iva
				where c1 = sucursal_id and c2 = v_inventario and 
					  c3 = v_h_c10_mes and c4 = v_h_c10_anio;
					 
				update keplersc.kdlinv
				set c3 = c3 + 1,
					c5 = c5 + v_costo,
					c10 = c10 + v_iva
				WHERE c1 = sucursal_id and C2 = v_inventario;
			
				--CAMBIANDO LA PRIMERA FECHA
				if (genero = 'X' or genero = 'N') and naturaleza = 'A' then 
				
					if v_h_c10 < v_k_c7 then 
						update keplersc.kdlinv
						set c7 = v_h_c10
						where c1 = sucursal_id and C2 = v_inventario;
					end if;
				
					update keplersc.kdlinv
					set c8 = v_costo,
						c9 = v_iva
					where c1 = sucursal_id and C2 = v_inventario;
				
				end if;
			
		 	-- SALIDA
		    else 
		    
			    update keplersc.kdginv
				set c6 = c6 + 1,
					c12 = c12 + v_costo,
					c14 = c14 + v_iva
				where c1 = sucursal_id and c2 = v_inventario and 
					  c3 = v_h_c10_mes and c4 = v_h_c10_anio;
					 
				update keplersc.kdlinv
				set c4 = c4 + 1,
					c6 = c6 + v_costo,
					c11 = c11 + v_iva
				where c1 = sucursal_id and C2 = v_inventario;
			
  		    end if;--end SALIDA
  		    
  		    select c3, c4 into v_entradas_unidades, v_salidas_unidades from keplersc.kdlinv  
  		    where c1 = sucursal_id and C2 = v_inventario;
			if v_entradas_unidades <= v_salidas_unidades  then
				v_k_c13 = 10;
			else
				v_k_c13 = 0;
			end if;		
		
			update keplersc.kdlinv 
			set c13 = v_k_c13
			where c1 = sucursal_id and C2 = v_inventario;
			
	end if;		
	-------------------------------end inv_alta_k			
	--raise notice 'terminado';

	get_resultado := 1 ;
	get_mensaje := folio_operacion;
	return query select get_resultado, get_mensaje, get_adicionales;
/*
exception
	when others then
		resultado := 0;
		mensaje := 'invlib_inv_alta() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		raise notice 'err sqlState %',mensaje ;
		return query select resultado, mensaje, adicionales;
*/	
end;
$function$
