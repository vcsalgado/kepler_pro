CREATE OR REPLACE FUNCTION keplersc.util_actualiza_precio_paquetes_locales_gm()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
--Descripcion: Actualiza precio de paquetes locales
--Autor: Victor Salgado
--Fecha: 27/06/2026

declare 
	clave_refaccion text = '';
	catalogo integer = 0; 
	metodo_calculo integer =0;
	utilidad_base numeric = 0.00; 
	iva numeric = 0.16; 
	cant_ent numeric = 0.00;
	cant_sal numeric = 0.00;
	tot_cant numeric = 0.00;
	monto_ent numeric = 0.00;
	monto_sal numeric = 0.00;
	tot_monto numeric = 0.00;
	ult_costo numeric = 0.00;  
	costo_prom numeric = 0.00;
	monto_ref numeric = 0.00;
	tot_monto_ref_sin_iva numeric = 0.00;
	tot_monto_mo_sin_iva numeric = 0.00;
	costo_minimo_mo numeric=0.00;

	precio_sin_iva decimal = 0.00;
	precio_planta_con_iva decimal = 0.00;
	costo_distribuidor decimal = 0.00;
	unidad_de_empaque int = 0;
	precio_publico decimal = 0.00;

	tot_paquete_sin_iva decimal = 0.00;
	tot_paquete_con_iva decimal = 0.00;

	--Variables de retorno
	precio decimal = 0.00;

	rpaq record;
	rrefpaq record;
	rrefgm record;

	sucursal text = '01';
begin
	
	--Obtener utilidad base para refacciones
	select c4 into utilidad_base from keplersc.kdicatprecio where c1='PAQ';
 	if not found then
		utilidad_base = 50;
	end if;

	--Obtener el minimo en mano de obra
	select valor into costo_minimo_mo from keplersc.param_oper where parametro='minimo horas mano obra';
	if not found then
		raise exception 'No se tienen configurado el minimo de mano de obra';
		costo_minimo_mo = 0;
	end if;

    for rpaq in select * from keplersc.kdspaq where c4 not like 'S%' --and c1='CHEVR' and c2='AVEONG' and c4='ACAYF'
	loop
        raise notice 'procesando marca:%; modelo: %; paquete:% ', rpaq.c1, rpaq.c2, rpaq.c4;
		monto_ref=0.00;
		tot_monto_ref_sin_iva = 0.00;
		--Refacciones
		for rrefpaq in select * from keplersc.kdspaqm where c1=rpaq.c1 and c2=rpaq.c2 and c4=rpaq.c4 
		loop
--        	raise notice 'procesando marca:%; modelo: %; paquete:%; refaccion;% ', rrefpaq.c1, rrefpaq.c2, rrefpaq.c4, rrefpaq.c6;
			costo_prom=0.00;
			ult_costo=0.00;
			--Obtener costo promedio, ultimo costo
			select c5,c6,c8,c9,c14 into cant_ent,cant_sal,monto_ent,monto_sal,ult_costo from keplersc.kdinl where c1=sucursal and c2=rrefpaq.c6;
			if found then

				tot_monto=monto_ent-monto_sal;
				tot_cant=cant_ent-cant_sal;
				if tot_cant > 0 then
					if tot_monto > 0 then
						costo_prom=tot_monto/tot_cant;
					end if;
	 			end if;
				if costo_prom=0 then
					costo_prom=ult_costo; --Si no hay datos para calcular costo promedio
				end if;
			end if;
--raise notice 'PASO 7';
			--Obtener precio de planta
			select c7 into precio_planta_con_iva from keplersc.kdigm where c1=rrefpaq.c6;
			if not found then
				precio_planta_con_iva=0.00;
			end if;

			if precio_planta_con_iva > 0 then  --Es parte de planta
				precio_sin_iva := precio_planta_con_iva/(1+iva);
			else
				precio_sin_iva := costo_prom * (1+utilidad_base/100); --Si no hay costo promedio, resultado es cero
			end if;
--Utilizar el costo promedio
			precio_sin_iva := costo_prom * (1+utilidad_base/100); --Si no hay costo promedio, resultado es cero
 			precio_sin_iva:=round(precio_sin_iva,2);

	       	raise notice 'procesando marca:%; modelo: %; paquete:%; refaccion:%; costo_prom:%; precio_sin_iva:% ', rrefpaq.c1, rrefpaq.c2, rrefpaq.c4, rrefpaq.c6,costo_prom,precio_sin_iva;
			monto_ref=rrefpaq.c7*precio_sin_iva;
			tot_monto_ref_sin_iva = tot_monto_ref_sin_iva + monto_ref;
		end loop;

		--Mano de obra
		tot_monto_mo_sin_iva = costo_minimo_mo * rpaq.c9;

		tot_paquete_sin_iva = tot_monto_ref_sin_iva + tot_monto_mo_sin_iva;
		
		tot_paquete_con_iva = tot_paquete_sin_iva * (1+iva);

		--Actualizar registro de paquete
		update keplersc.kdspaq set c6=tot_monto_mo_sin_iva, c7=tot_monto_ref_sin_iva, c10=tot_paquete_con_iva 
			where c1=rpaq.c1 and c2=rpaq.c2 and c4=rpaq.c4;

        raise notice 'Refacciones:%, MO:%, Sub_total:%, IVA:%, Total:% ', tot_monto_ref_sin_iva, tot_monto_mo_sin_iva, tot_paquete_sin_iva, tot_paquete_sin_iva * iva, tot_paquete_con_iva;
    end loop;
	
	return 'TERMINADO';

end;
$function$
