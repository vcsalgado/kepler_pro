CREATE OR REPLACE FUNCTION keplersc.ser_calculos_pago_ope(dataxml xml)
 RETURNS TABLE(nomina numeric, horas_reales_trabajadas numeric, nomina_por_operarios xml)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Calula pago a operarios
--Autor: Luis Leal
--Fecha: 02/09/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	fecha_inicial date;
	fecha_final date;

	tarifa_por_hora numeric;
	sueldo_base numeric;
	horas_base numeric;
 	escalon_1 numeric;
 	tarifa_escalon_2 numeric;
 	escalon_2 numeric; 
 	tarifa_escalon_3 numeric;
 	escalon_3 numeric;
 	tarifa_ultimo_escalon numeric;
 
 	porcentaje numeric;
	normales numeric; 
	garantias numeric; 
	internas numeric; 
	previas numeric;
	reclamaciones numeric;
 
 	comisiones numeric;
 	ctd_hrs_encontradas numeric;
 	total numeric = 0;
	horas_tabuladas numeric;
	horas_tabuladas_ayudante numeric;
	horas numeric;
	costo_por_hora numeric;

	tipo_orden text;
	fol_orden text;
	num_punto text;
	mano_de_obra numeric;
	tipo_trabajo text;
	alta_baja numeric;

	clave_ope text;
	tipo_ope text;
	nombre_ope text;
	estatus_ope text;
	tipo_pago text;
	ayudante text;
	ctd_hrs_ayudante int;
	nomina numeric = 0;
	horas_reales_trabajadas numeric = 0;
	renglon_num numeric = 0;
	xml_nomina_por_operarios text;

	intValor int=0;

begin
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	fecha_inicial := (xpath('//document/fecha_inicial/text()', dataxml))[1];
	fecha_final := (xpath('//document/fecha_final/text()', dataxml))[1];


	if fecha_inicial is null or fecha_final is null then 
		raise exception 'Debe seleccionar un rango de fechas.'; 
	end if;

	
	for clave_ope,tipo_ope,nombre_ope,estatus_ope,tipo_pago,ayudante in select c1,c2,c3,c12,c17,c22 
		from keplersc.kdoper where c12='S' and c18='S' 
	loop 
				
		comisiones:=0;
		horas_tabuladas:=0;
		horas_base:=0;
		tarifa_por_hora:=0; 
		sueldo_base:=0; 
		normales:=0; 
		garantias:=0; 
		internas:=0; 
		previas:=0;
		reclamaciones:=0;
		escalon_1:=0;
		tarifa_escalon_2:=0;
		escalon_2:=0;
		tarifa_escalon_3:=0;
		escalon_3:=0;
		tarifa_ultimo_escalon:=0;
		
		select count(*) into intValor from keplersc.kdclaspag where c1=tipo_pago;
		if intValor=1 then
			select coalesce(c3::numeric,0), coalesce(c4::numeric,0), coalesce(c5::numeric,0),
				coalesce(c6::numeric,0), coalesce(c7::numeric,0), coalesce(c8::numeric,0), 
				coalesce(c9::numeric,0), coalesce(c10::numeric,0), coalesce(c11::numeric,0), 
				coalesce(c12::numeric,0), coalesce(c13::numeric,0), coalesce(c14::numeric,0), 
				coalesce(c15::numeric,0), coalesce(c16::numeric,0) 
			into horas_base, tarifa_por_hora, sueldo_base, normales, garantias, internas, previas , reclamaciones,
			escalon_1 , tarifa_escalon_2, escalon_2,tarifa_escalon_3, escalon_3, tarifa_ultimo_escalon
			from keplersc.kdclaspag where c1=tipo_pago;
		end if;
		--LGLG 10/07/24 OBSOLETO
		--if tarifa_por_hora <> 0 then
		
			select coalesce(sum(c14),0) into horas_tabuladas from keplersc.kdhorpag where c1=sucursal_id 
		 	and c13= clave_ope and c5=0 and c11>=fecha_inicial and c11<=fecha_final;

			if horas_tabuladas is null then
				horas_tabuladas := 0;
			end if;
		 
		 	if 	horas_tabuladas is not null then
		 		horas_reales_trabajadas := horas_reales_trabajadas + horas_tabuladas;
		 	end if;
		 
			if ayudante <> '' then
		
				select coalesce(sum(c14),0) into horas_tabuladas_ayudante from keplersc.kdhorpag where c1= sucursal_id
				and c13=ayudante and c5=0 and c11>=fecha_inicial and c11<=fecha_final;
			
				if horas_tabuladas_ayudante > 0 then
					horas_tabuladas := horas_tabuladas + horas_tabuladas_ayudante;
				end if;	
			
			end if;
		

										
			if horas_tabuladas <= escalon_1 then 
				comisiones := (horas_tabuladas - horas_base) * tarifa_por_hora;
			else
				if horas_tabuladas > escalon_1 and  horas_tabuladas <= escalon_2  then 
					comisiones := (horas_tabuladas - horas_base) * tarifa_escalon_2;
				else 
					if horas_tabuladas > escalon_2 and  horas_tabuladas <= escalon_3  then 
						comisiones := (horas_tabuladas - horas_base) * tarifa_escalon_3;
					else 
						if horas_tabuladas > escalon_3 then 
							comisiones := (horas_tabuladas - horas_base) * tarifa_ultimo_escalon;
						end if;
					end if;
				end if;
			end if;

			if comisiones < 0 then
				comisiones := 0;
			end if;
		
		--LGLG 10/07/24 10/07/24 OBSOLETO
		/*else
		
		
			for tipo_orden, fol_orden,alta_baja, num_punto, mano_de_obra,tipo_trabajo , horas
			in select pun.c2,pun.c3,pun.c5::numeric,pun.c11,pun.c18::numeric,m.c2,hrs.c14 from keplersc.kdvnpun as pun 
			inner join keplersc.kdmargen as m on m.c1=pun.c2 inner join keplersc.kdhorpag as hrs on hrs.c1=pun.c1 
			and hrs.c2=pun.c2 and hrs.c3=pun.c3 and hrs.c4=pun.c11 where pun.c1=sucursal_id 
			and hrs.c13=clave_ope and hrs.c5=0 and pun.c12 >= fecha_inicial and pun.c12 <= fecha_final
			loop

				if tipo_trabajo = 'N' then 
					porcentaje := normales;
				end if;
				if tipo_trabajo = 'G' then 
					porcentaje := garantias;
				end if;
				if tipo_trabajo = 'I' then 
					porcentaje := internas;
				end if;
				if tipo_trabajo = 'Q' then 
					porcentaje := previas;
				end if;
				if tipo_trabajo = 'R' then 
					porcentaje := reclamaciones;
				end if;
				
				if alta_baja = 0 then
					comisiones := comisiones +  (mano_de_obra * porcentaje)/100;
					horas_tabuladas := horas_tabuladas + horas;
				else 
					comisiones := comisiones -  (mano_de_obra * porcentaje)/100;
					horas_tabuladas := horas_tabuladas - horas;
				end if ;
			
			end loop;
		
		end if ;*/
raise notice 'clave_ope %; comisiones %; horas_tabuladas %; horas_base %; sueldo_base %;',
clave_ope,comisiones,horas_tabuladas,horas_base,sueldo_base;
		
		if horas_tabuladas < horas_base then 
			total := sueldo_base;
		else 
			total := comisiones + sueldo_base;
		end if;
	
		if horas_tabuladas = 0 then
--			continue;
		end if;
		
		nomina := nomina + total;	
	
		if horas_tabuladas - horas_base > 0 then
			costo_por_hora := comisiones/(horas_tabuladas - horas_base);
		else 
			costo_por_hora :=0;
		end if;

		xml_nomina_por_operarios := concat( xml_nomina_por_operarios , format('<r%1$s>
					<clave_ope>%2$s</clave_ope><nombre_ope>%3$s</nombre_ope>
					<horas_tabuladas>%4$s</horas_tabuladas><horas_base>%5$s</horas_base>
					<costo_por_hora>%6$s</costo_por_hora><sueldo_base>%7$s</sueldo_base>
					<comisiones>%8$s</comisiones><total>%9$s</total><ayudante>%10$s</ayudante></r%1$s>',
					renglon_num, clave_ope, nombre_ope, horas_tabuladas, 
					horas_base, costo_por_hora,sueldo_base,comisiones, total, ayudante));
				
		renglon_num := renglon_num + 1;
	end loop;	


	return query
	select nomina, horas_reales_trabajadas, xml_nomina_por_operarios::xml ;


exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
