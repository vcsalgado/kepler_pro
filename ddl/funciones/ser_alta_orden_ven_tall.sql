CREATE OR REPLACE FUNCTION keplersc.ser_alta_orden_ven_tall(dataxml xml, xmlkdm1 xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: . Resuelve ALTA_ORDEN_VEN_TALL  
--Autor: Miriam Santana
--Fecha: 18/10/2022
	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	usuario text;
	fecha_operacion text;
	tipo_orden text;
	num_orden text;
	cliente text;
	recepcionista text;
	mano_obra_fac text;
	refacciones_fac text;
	tots_fac text;
	cargos_fac text;	
	monto_iva text;
	monto_total text;

	--Variables de uso general
	partida int;
	status int;
	serie text;
	marca text;
	modelo text;
	kilometraje text;
	horas decimal=0;
	costo_refacc decimal=0;
	costo_cargos decimal=0;
	subt_tots decimal=0;
	costo_horas decimal=0;
	importe_refacc decimal=0;
	precio_ctetot decimal=0;
	precio_cargos decimal=0;
		
	rec record;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	--Tipo de documento
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	
	fecha_operacion := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
	tipo_orden := (xpath('//document/k_tipo_orden/r1/text()',dataxml))[1];
	num_orden := (xpath('//document/k_orden/text()',dataxml))[1];
	cliente := (xpath('//document/k_clave/text()',dataxml))[1];
	recepcionista := (xpath('//document/k_vendedor/text()',dataxml))[1];		--recepcionista
	mano_obra_fac := coalesce((xpath('//document/k_montoext1/text()',dataxml))[1]::text,'0')::text;
	refacciones_fac := coalesce((xpath('//document/k_montoext2/text()',dataxml))[1]::text,'0')::text;
	tots_fac := coalesce((xpath('//document/k_montoext3/text()',dataxml))[1]::text,'0')::text;
	cargos_fac := coalesce((xpath('//document/k_montoext4/text()',dataxml))[1]::text,'0')::text;
	monto_iva := coalesce((xpath('//document/k_iva/text()',dataxml))[1]::text,'0')::text;
	monto_total := coalesce((xpath('//document/k_monto/text()',dataxml))[1]::text,'0')::text;
	
	if (xpath('//row/c11/text()', xmlKDMM))[1]::text = 'S' and genero='U' then
		select ord.c6,ser.c2,ser.c3,ord.c20 into serie,marca,modelo,kilometraje 
			from keplersc.kdord ord  
			inner join keplersc.kdserie ser on ser.c1 = ord.c6
			where ord.c1=sucursal_id  and ord.c2=tipo_orden and ord.c3=num_orden;
	
		if found then
			partida := 1;
			select c4 into partida from keplersc.kdvntall
				where c1=sucursal_id  and c2=tipo_orden and c3=num_orden
				order by c4 desc limit 1;
			if found and partida is not null then
				partida := coalesce(partida,0)+1;
			else
				partida:= 1;
			end if;
			status := 0;		--Alta
			if (xpath('//row/c2/text()', xmlKDMM))[1]::text = 'A' then
				status := 10;	--Baja
			end if;
			insert into keplersc.kdvntall (
				c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,
				c16,c17,c18,c19,c20,
				c21,c22,c23,c24,c25,
				c26) 
			values(
				sucursal_id,tipo_orden,num_orden,partida,status,
				genero,naturaleza,grupo::integer,tipo::integer,folio_operacion,
				to_date(fecha_operacion,'YYYY-MM-DD'),cliente,recepcionista,serie,marca,
				modelo,kilometraje::decimal,'','',coalesce(mano_obra_fac,'0')::decimal,
				coalesce(refacciones_fac,'0')::decimal,coalesce(tots_fac,'0')::decimal,coalesce(cargos_fac,'0')::decimal,'',monto_iva::decimal,
				monto_total::decimal);
		
			select sum(c8) into horas from keplersc.kdhoras where c1=sucursal_id  and c2=tipo_orden and c3=num_orden;
			select sum(c19) into costo_refacc from keplersc.kdref where c1=sucursal_id  and c2=tipo_orden and c3=num_orden;
			select sum(c11) into subt_tots  from keplersc.kdtot where c1=sucursal_id  and c2=tipo_orden and c3=num_orden;
			select sum(c8) into costo_cargos from keplersc.kdcar where c1=sucursal_id  and c2=tipo_orden and c3=num_orden;
			insert into keplersc.kdcosttall (
				c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11) 
			values(sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
				folio_operacion,'',coalesce(horas,0),coalesce(costo_refacc,0),coalesce(subt_tots,0),coalesce(costo_cargos,0));

			for rec in select * from keplersc.kdpun
				where c1=sucursal_id  and c2=tipo_orden and c3=num_orden
			loop
				if rec.c6<>'N' then
				costo_horas:=0; horas:=0;
				importe_refacc:=0; costo_refacc:=0;
				precio_ctetot:=0; subt_tots:=0;
				precio_cargos:=0; costo_cargos:=0;
				monto_iva:=0;
				monto_total:=0;
					select sum(c8*c14),sum(c8) into costo_horas,horas from keplersc.kdhoras where c1=sucursal_id  and c2=tipo_orden and c3=num_orden and c4=rec.c4;
					select sum(c16),sum(c19) into importe_refacc,costo_refacc from keplersc.kdref where c1=sucursal_id  and c2=tipo_orden and c3=num_orden and c4=rec.c4;
					select sum(c16),sum(c11) into precio_ctetot,subt_tots  from keplersc.kdtot where c1=sucursal_id  and c2=tipo_orden and c3=num_orden and c4=rec.c4;
					select sum(c10),sum(c8) into precio_cargos,costo_cargos from keplersc.kdcar where c1=sucursal_id  and c2=tipo_orden and c3=num_orden and c4=rec.c4;
					if costo_horas > 0 or importe_refacc > 0 or precio_ctetot > 0 or precio_cargos > 0 or rec.c6 ='L' then 
						monto_iva := (coalesce(costo_horas,0)+coalesce(importe_refacc,0)+coalesce(precio_ctetot,0)+coalesce(precio_cargos,0))*monto_iva::decimal/(coalesce(mano_obra_fac,'0')::decimal+coalesce(refacciones_fac,'0')::decimal+coalesce(tots_fac,'0')::decimal+coalesce(cargos_fac,'0')::decimal);
						monto_total := coalesce(costo_horas,0)+coalesce(importe_refacc,0)+coalesce(precio_ctetot,0)+coalesce(precio_cargos,0)+monto_iva::decimal;
						
						insert into keplersc.kdvnpun (
							c1,c2,c3,c4,c5,
							c6,c7,c8,c9,c10,
							c11,c12,c13,c14,c15,
							c16,c17,c18,c19,c20,
							c21,c22,c23,c24)
						values (
							sucursal_id,tipo_orden,num_orden,partida,status,
							genero,naturaleza,grupo::integer,tipo::integer,folio_operacion,
							rec.c4,to_date(fecha_operacion,'YYYY-MM-DD'),rec.c6,recepcionista,rec.c5,
							'','',coalesce(costo_horas,0),coalesce(importe_refacc,0),coalesce(precio_ctetot,0),
							coalesce(precio_cargos,0),'',monto_iva::decimal,monto_total::decimal);

						insert into keplersc.kdcostpun (
							c1,c2,c3,c4,c5,
							c6,c7,c8,c9,c10,
							c11)
						values (
							sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
							folio_operacion,rec.c4,coalesce(horas,0),coalesce(costo_refacc,0),coalesce(subt_tots,0),
							coalesce(costo_cargos,0));
					end if;
				end if;
			end loop;
			
		end if;
	
	end if;	

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_alta_orden_ven_tall() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
