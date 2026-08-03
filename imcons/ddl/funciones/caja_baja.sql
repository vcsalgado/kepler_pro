CREATE OR REPLACE FUNCTION keplersc.caja_baja(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Función para baja de caja, incorpora BAJA_CAJA y BAJA_K_CAJA
--Autor: Saltiel Cruz
--Fecha: 27/10/2022
--actualizado 08/Dic/22
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	clave_cteprov text;
	forma_pago text;
	cuenta text;
	fecha_operacion text;
	anticipo text;
	movto_caja text;
	importe text;

	--Variables de uso general
	expSql text;
	totalReg int;
	mesValor int;
	anioValor int;
	strCol text;
	strValor text;
	strPlus text = '+';
	columna_caja text;
	ingreso_caja decimal = 0;
	egreso_caja decimal = 0;
	importe_caja decimal;
 	v_anio text = '';
	v_mes text = '';
 	v_fecha_ingreso text = '';
	v_monto numeric = 0;
	v_ingresoEgreso text = '';
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	--Valores de XML
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	clave_cteprov := (xpath('//document/k_clave/text()', dataxml))[1];
	forma_pago := (xpath('//document/k_f_pago/r1/text()', dataxml))[1];
	cuenta := (xpath('//document/k_cuenta/text()', dataxml))[1];
	fecha_operacion := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
	anticipo := coalesce((xpath('//document/k_montoanticipo/text()', dataxml))[1]::text,'0');
	movto_caja := (xpath('//row/c51/text()', xmlKDMM))[1]::text;
	importe := (xpath('//document/k_monto/text()', dataxml))[1];	
	importe_caja := importe::decimal - anticipo::decimal;
	cuenta := (xpath('//document/k_cuenta/text()', dataxml))[1];
	v_fecha_ingreso := (xpath('//document/k_fecha/r1/text()', dataxml))[1];
		--BAJA_CAJA
	select coalesce((extract(year from (c9)))::text,'0'),coalesce((extract(month from (c9)))::text,'0'),c10,c2 
		into v_anio,v_mes,v_monto,v_ingresoEgreso
	from keplersc.KDECAJA where c1 = sucursal_id and c3 = genero and c4 = naturaleza and c5=grupo::numeric and c6 = tipo::numeric and c7 = folio_operacion;
		
	if v_anio <> '0' or v_anio <> '' then --se valida que contenga el valor del año
		if (select COUNT(*) from keplersc.KDKCAJA where c1 = sucursal_id  and c2 = v_anio) = 0 then 
			insert into keplersc.KDKCAJA (c1,c2) values (sucursal_id,v_anio);
		end if;
		if (select count(*) from keplersc.KDCAJDEP where c1 = v_fecha_ingreso::timestamp) = 0 then 
			insert into keplersc.KDCAJDEP (c1) values (v_fecha_ingreso::timestamp);
		end if;
			
		if v_ingresoEgreso = 'I' then 
			if v_mes = 1 then 
			update keplersc.KDKCAJA set c10 = (c10 - v_monto) where c1 = sucursal_id and c2 = v_anio;			
				end if;
			if v_mes = 2 then 
			update keplersc.KDKCAJA set c11 = (c11 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 3 then 
			update keplersc.KDKCAJA set c12 = (c12 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 4 then 
			update keplersc.KDKCAJA set c13 = (c13 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 5 then 
			update keplersc.KDKCAJA set c14 = (c14 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 6 then 
			update keplersc.KDKCAJA set c15 = (c15 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 7 then 
			update keplersc.KDKCAJA set c16 = (c16 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 8 then 
			update keplersc.KDKCAJA set c17 = (c17 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 9 then 
			update keplersc.KDKCAJA set c18 = (c18 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 10 then 
			update keplersc.KDKCAJA set c19 = (c19 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 11 then 
			update keplersc.KDKCAJA set c20 = (c20 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 12 then 
			update keplersc.KDKCAJA set c21 = (c21 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			update keplersc.KDCAJDEP set c2 = (c2 - v_monto) where c1 = v_fecha_ingreso::timestamp;
		
		else -- E
			if v_mes = 1 then 
			update keplersc.KDKCAJA set c25 = (c25 - v_monto) where c1 = sucursal_id and c2 = v_anio;			
				end if;
			if v_mes = 2 then 
			update keplersc.KDKCAJA set c26 = (c26 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 3 then 
			update keplersc.KDKCAJA set c27 = (c27 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 4 then 
			update keplersc.KDKCAJA set c28 = (c28 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 5 then 
			update keplersc.KDKCAJA set c29 = (c29 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 6 then 
			update keplersc.KDKCAJA set c30 = (c30 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 7 then 
			update keplersc.KDKCAJA set c31 = (c31 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 8 then 
			update keplersc.KDKCAJA set c32 = (c32 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 9 then 
			update keplersc.KDKCAJA set c33 = (c33 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 10 then 
			update keplersc.KDKCAJA set c34 = (c34 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 11 then 
			update keplersc.KDKCAJA set c35 = (c35 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			if v_mes = 12 then 
			update keplersc.KDKCAJA set c36 = (c36 - v_monto) where c1 = sucursal_id and c2 = v_anio;
				end if;
			update keplersc.KDCAJDEP set c3 = (c3 - v_monto) where c1 = v_fecha_ingreso::timestamp;
		end if;
	
		
		delete from keplersc.KDECAJA 
		where c1 = sucursal_id and c3 = genero and c4 = naturaleza and c5=grupo and c6 = tipo and c7 = folio_operacion;	
	
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'Baja_Caja() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
