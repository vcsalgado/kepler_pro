CREATE OR REPLACE FUNCTION keplersc.genera_montos_cfdi()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: Genera los cálculos requeridos para que en proceso de CFDI no realice ningún cálculo y actualiza
--las tablas KDTOT,KDCAR,KDREF,KDHORAS Y KDORD
--Autor: Miriam Santana
--Fecha: 23/01/2023
--Bitacora de cambios
declare
	iva_default decimal ;

	costo_por_hora decimal ;
	partida decimal ;
	costo decimal = 0;
	importe decimal = 0;
	hrs_a_pagar  decimal = 0;
	precio_paquete decimal = 0;
	hrs decimal = 0;

	--Calculos
	importe_refs_punto decimal = 0;
	importe_total_refs decimal = 0;
	importe_tots_punto decimal = 0;
	importe_total_tots decimal = 0;
	importe_car_punto decimal = 0;
	importe_total_car decimal = 0;
	importe_horas_punto decimal = 0;
	importe_total_horas decimal = 0;

	--resultados
	mano_obra text;
	refacciones text;
	tots text;
	cargos_varios text;
	
	subtotal decimal = 0;
	iva_total decimal = 0;
	importe_total decimal = 0;

	--Variables de uso general 
	intValor int = 0;
	xmlResultado text;
	expSql text = '';
	xmlOrden xml;
	rec record;
begin
	iva_default:= 16;
raise notice 'Inicio';

--TOTS

		for rec in select * from keplersc.kdtot 
		loop
			iva_total := 0;
			importe_total := 0;
			iva_total := rec.c16 * (iva_default/100);
			importe_total := rec.c16 + iva_total;
			update keplersc.kdtot 
				set c18=iva_total,
					c19=importe_total
			where c1=rec.c1 and c2=rec.c2 and c3=rec.c3 and c4=rec.c4 and c9=rec.c9;	
		end loop;
	
raise notice 'TOTs';
--Cargos
		for rec in select * from keplersc.kdcar
		loop
			select c11 into iva_default from keplersc.kdmargen where c1=rec.c2;
			iva_total := 0;
			importe_total := 0;
			if rec.c10 > 0 then 
				iva_total := rec.c10 * (iva_default/100);
				importe_total := rec.c10 + iva_total;
				update keplersc.kdcar 
					set c11=iva_total,
						c12=importe_total
				where c1=rec.c1 and c2=rec.c2 and c3=rec.c3 and c4=rec.c4 and c5=rec.c5;
			end if;
		end loop;
raise notice 'Cargos';	
--Ref
		for rec in select * from keplersc.kdref
		loop
			select c11 into iva_default from keplersc.kdmargen where c1=rec.c2;
			iva_total := 0;
			importe_total := 0;
			if rec.c16 > 0 then 
				iva_total := rec.c16 * (iva_default/100);
				importe_total := rec.c16 + iva_total;
				update keplersc.kdref
					set c21=iva_total,
						c22=importe_total
				where c1=rec.c1 and c2=rec.c2 and c3=rec.c3 and c4=rec.c4 and c5=rec.c5 and c6=rec.c6 and c7=rec.c7 and c8=rec.c8 and c9=rec.c9 and c10=rec.c10;	
			end if;
		end loop;

raise notice 'Refacc';

--Horas
		for rec in select * from keplersc.kdhoras
		loop
			select c11 into iva_default from keplersc.kdmargen where c1=rec.c2;
			iva_total := 0;
			importe_total := 0;
			subtotal := 0;
		
			if rec.c8 > 0 and rec.c8 is not null and rec.c14 > 0 and rec.c14 is not null then 
				subtotal := rec.c14*rec.c8;
				iva_total := subtotal * (iva_default/100);
				importe_total := subtotal + iva_total;
			
				update keplersc.kdhoras
					set c17=subtotal,
						c18=iva_total,
						c19=importe_total
				where c1=rec.c1 and c2=rec.c2 and c3=rec.c3 and c4=rec.c4 and c5=rec.c5 and c6=rec.c6;
			end if;
		end loop;
raise notice 'Horas';

--Orden
raise notice 'Inicio Orden';
	--	for rec in select * from keplersc.kdord where c7=10 and c8=40  and c61 =0 and c62=0 and c63=0	--status de orden cerrada c7:flujo admon=10 y c8:flujo servicio=40
		for rec in select * from keplersc.kdord ord
			inner join (select distinct c1,c2,c3 from keplersc.kdordfact) as fact on fact.c1=ord.c1 and fact.c2=ord.c2 and fact.c3=ord.c3 
		loop															--Tiene factura en kdordfact
			iva_total := 0;	importe_total := 0; subtotal := 0;
			mano_obra :=0; refacciones :=0; tots :=0; cargos_varios :=0;
		
			if rec.c30=0 and rec.c31=0 and rec.c32=0 and rec.c33=0 then	
				continue;
			end if;
				expSql:=format(
							'<document>
								<sucursal_id>%1$s</sucursal_id>
								<tipo_orden>%2$s</tipo_orden>
								<folio_orden>%3$s</folio_orden>
							</document>',
					         	rec.c1,rec.c2,rec.c3);
				xmlOrden:=expSql::xml;	         
				select * into xmlresultado from keplersc.ser_calculos_montos_orden(xmlOrden);
			raise notice 'xmlresultado:%',xmlresultado;
				xmlOrden:= concat('<document>',xmlresultado,'</document>')::xml;
				--tomar datos y actualizar kdord con subt, iva y total
				raise notice 'xmlOrden:%',xmlOrden;		  				  	
			  	subtotal := coalesce((xpath('//subtotal/text()', xmlOrden))[1]::text,'0.00')::text; 
			  	iva_total := coalesce((xpath('//iva_total/text()', xmlOrden))[1]::text,'0.00')::text; 
			  	importe_total := coalesce((xpath('//importe_total/text()', xmlOrden))[1]::text,'0.00')::text; 
			  	
				update keplersc.kdord set 
					c61=subtotal::decimal, c62=iva_total::decimal, c63=importe_total::decimal
					where c1=rec.c1 and c2=rec.c2 and c3=rec.c3;
			
				xmlOrden:='';
				intValor := intValor+1;
			raise notice '%',intValor;
		end loop;

return 1;

end;
$function$
