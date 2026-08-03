CREATE OR REPLACE FUNCTION keplersc.ser_tots_crud(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Realiza inserción y baja de TOTs en KDTOT
--Autor: Miriam Santana
--Fecha: 09/08/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_desc text;
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	fecha_operacion text; --yyyy-mm-dd
	tipo_clave text;
	tipo_orden text;
	num_orden text;
	punto text;
	descripcion text;
	costo decimal;
	iva decimal = 0.00;
	porc_iva decimal = 0.00;
	total decimal = 0.00;
	precio decimal = 0.00;
	margen_util int;
	numero_partida int = 0;
	deccosto_partida decimal = 0.00;
	tipo_operacion text;
	strValor text;
	strCosto text;
	strPartidas text;
	no_partidas int;
	
	iva_cte decimal = 0.00;		--cfdi no calculos
	total_cte decimal = 0.00;	--cfdi no calculos

	begin
		sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
		--Tipo de documento
		tipo_desc := (xpath('//document/k_tipon/r0/text()', dataxml))[1]; 
		genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
		naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
		grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
		tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
		strValor := (xpath('//document/k_tipon/r6/text()', dataxml))[1];
		porc_iva := strValor::decimal;
		--Tipo operacion
		tipo_operacion := (xpath('//document/operacion/text()', dataxml))[1];
		fecha_operacion := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
		--Partidas
		strPartidas := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
		no_partidas := strPartidas::integer;
		--Procesar alta detalle de TOTs a KDTOT (GUARDA TOT)
		if tipo_operacion = 'ALTA' then	
			for cont in 0..no_partidas - 1 loop
				deccosto_partida := 0;
				tipo_orden := (xpath('//document/k_mov/r'||cont||'/k_tipo_orden/text()',dataxml))[1];
				num_orden := (xpath('//document/k_mov/r'||cont||'/k_num_orden/text()',dataxml))[1];
				punto := (xpath('//document/k_mov/r'||cont||'/k_punto/text()',dataxml))[1];
				descripcion := (xpath('//document/k_mov/r'||cont||'/k_descriptot/text()',dataxml))[1];
				strCosto := coalesce((xpath('//document/k_mov/r'||cont||'/k_costo/text()',dataxml))[1]::text,'0')::text;
				costo := strCosto::decimal;
				iva := costo * (porc_iva/100);
				total := costo * (1+porc_iva/100);
				deccosto_partida := costo::decimal;
				--precio := (xpath('//document/k_mov/r'||cont||'/k_precio/text()',dataxml))[1];
				select c6 into margen_util from keplersc.kdmargen where c1 = tipo_orden;
				--Sólo realiza la inserción si tiene costo la partida
				if deccosto_partida > 0 then
					if tipo_orden is null or tipo_orden ='' then
						raise exception 'Falta indicar el tipo de órden';
					end if;
					if num_orden is null or num_orden ='' then
						raise exception 'Falta indicar el número de órden';
					end if;
					if punto is null or punto ='' then
						raise exception 'Falta indicar el número de punto';
					end if;
					numero_partida := numero_partida + 1;
			--cfdi no cálculos
					strValor := 0; iva_cte := 0; total_cte := 0;
					strValor := (xpath('//document/k_mov/r'||cont||'/k_precio/text()',dataxml))[1];
					precio := strValor::decimal;
					iva_cte := precio * (porc_iva/100);
					total_cte := precio + iva_cte;
			--En el insert c18,c19
					insert into keplersc.kdtot
						(c1,c2,c3,c4,c5,
						c6,c7,c8,c9,c10,
						c11,c12,c13,c14,c15,
						c16,c17,c18,c19)
						values(sucursal_id,tipo_orden,num_orden,punto::integer,genero,
						naturaleza,grupo::integer,tipo_clave::integer,folio_operacion,descripcion,
						costo,iva,total,margen_util,numero_partida,
						precio,to_date(fecha_operacion,'YYYY-MM-DD'),iva_cte,total_cte);
						
				end if;
			end loop ;	
		else 
			--Procesar baja detalle de TOTs a KDTOT (GUARDA TOT)
			if tipo_operacion = 'BAJA' then	
				delete from keplersc.kdtot
					where C1=sucursal_id and C5=genero and c6=naturaleza and c7 = grupo::integer and c8= tipo_clave::integer and c9= folio_operacion::text;
			
			end if;
		end if;	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_tots_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
		
	end;
$function$
