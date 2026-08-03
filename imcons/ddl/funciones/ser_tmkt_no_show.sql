CREATE OR REPLACE PROCEDURE keplersc.ser_tmkt_no_show(dataxml xml)
 LANGUAGE plpgsql
AS $procedure$
	declare 
	--Descripcion: rutina para crear contactos por no show
	--Autor: Luis Leal
	--Fecha: 24/10/2023
	--Bitacora de cambios
	--LGLG 14/05/2024 SE AGREGO recordatorio_post_3 
	--Fecha: 14/08/2022
	--LGLG Se agrego sucursal ventas

	sucursal text;
	sucursal_ventas text;
	folio_cita text;
	serie text;
	fecha_cita date;
	clave_cliente text;

	agregar_contacto text;
	fecha_contacto date;
	ultimo_accion_tmkt numeric;
	orden_activa text;
	recordatorio_post_1 numeric;
	recordatorio_post_2 numeric;
	recordatorio_post_3 numeric;
	fecha_programacion date;
	nombre_dia text;
	folio_contacto_nvo text;
	fecha_N date;
	tipo_N numeric;
	fecha_val_salida_ult_srv date;
	tipo_servicio_tmkt numeric;
	asesor_tmkt text;

	observacion1 text;
	motivo_contacto numeric;
	strValor text;
	
	get_resultado text;
	get_mensaje text; 
	get_adicionales text;
					 
	
	begin 
	
	 sucursal := (xpath('//k_sucn/text()', dataxml))[1];
	
 	 select c25,c26,c28,col_suc_ventas into recordatorio_post_1, recordatorio_post_2, recordatorio_post_3, sucursal_ventas
 	 from keplersc.kdtmktserconf where c1=sucursal;
	 
	 for folio_cita, serie, fecha_cita, clave_cliente,asesor_tmkt in select ct1.c2,ct1.c6,ct1.c12,ct1.c4,ct1.c3 
	 from keplersc.kdctasser as ct1 where ct1.c1=sucursal and ct1.c12 >= current_date - 5
	 and ct1.c12 < current_date  and (ct1.c20=0 or ct1.c20=10) and ct1.c2 = (select max(ct2.c2) 
	 from keplersc.kdctasser as ct2 where ct2.c1=ct1.c1 and ct2.c6=ct1.c6)
	 order by ct1.c2
	 loop 
		 
		 agregar_contacto := 'Si';
			
		--busca si ya se creo un contacto tmkt	
		select c5,c9 into fecha_contacto, ultimo_accion_tmkt from keplersc.kdtmktser2
		where c1=sucursal and c14=serie order by c2 desc limit 1;
		if found then	
			if fecha_contacto < current_date then
				if ultimo_accion_tmkt = 20 then
					agregar_contacto := 'No';
				end if;
			else 
				agregar_contacto := 'No';
			end if;
		end if;
	
		--checa que si no hay una orden activa en el taller
		select c3 into orden_activa from keplersc.kdord 
		where c1=sucursal and c2='S' and c6=serie and c8 <> 50;
		if found then 
			agregar_contacto := 'No';	
		end if;
	
		if agregar_contacto = 'Si' then
		
			fecha_programacion := fecha_cita;
			
			--LGLG 14/05/24, OBSOLETO 
			/*SELECT to_char(fecha_programacion, 'Day') into nombre_dia;
			nombre_dia := trim(nombre_dia);
			if nombre_dia = 'Sunday' then
				fecha_programacion := fecha_programacion + 1;
				recordatorio_post_1 := recordatorio_post_1 - 1;
				recordatorio_post_2 := recordatorio_post_2 - 1;
			end if;*/
		
			tipo_servicio_tmkt := 0;
			select max(c11) into fecha_val_salida_ult_srv
			from keplersc.kdvntall where c1=sucursal and c14=serie;
			if fecha_val_salida_ult_srv is null then
			
				select max(com.c7) into fecha_val_salida_ult_srv from keplersc.kdinf as inf 
				inner join keplersc.kdcomismov as com on inf.c1=com.c1 and inf.c2=com.c8
				where inf.c1=sucursal_ventas and inf.c7=serie;
				tipo_servicio_tmkt := 10;
			
				if fecha_val_salida_ult_srv is null then
				
					select * into strValor from keplersc.kdserie where c1=serie;
					if found then						
						fecha_val_salida_ult_srv = '1800-01-01';
						tipo_servicio_tmkt := 0;
					else
						continue;
					end if;
				
				end if;
				
			end if;
					
			motivo_contacto	:= 40;
			observacion1 := concat('El cliente falto a su ultima cita agendada para el dia: ', fecha_cita::text,' con folio: ' ,folio_cita::text, '.') ;
		
			--cambiar status de cita a no show
			update keplersc.kdctasser set c20=50 where c1=sucursal and c2=folio_cita;
		
			for i in 1..3 loop
				
				select * into get_resultado, get_mensaje, get_adicionales
				from keplersc.obtener_folio_documento(concat('TMKT.', sucursal),0,0, dataxml);
				
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
				folio_contacto_nvo := get_mensaje; 
						
				if i = 1 then
					fecha_N := fecha_programacion + recordatorio_post_1::int;
					tipo_N := recordatorio_post_1;
				elsif i = 2 then
					fecha_N := fecha_programacion + recordatorio_post_2::int;
					tipo_N := recordatorio_post_2;
				elsif i = 3 then
					fecha_N := fecha_programacion + recordatorio_post_3::int;
					tipo_N := recordatorio_post_3;
				end if;
			
				--LGLG 14/05/24 
				SELECT to_char(fecha_N, 'Day') into nombre_dia;
				nombre_dia := trim(nombre_dia);
				if nombre_dia = 'Sunday' then
					fecha_N := fecha_N + 1;
				end if;
				
				insert into keplersc.kdtmktser2(c1,c2,c3,c4,c5,c6,c7,c8,c9,c11,c14,c15,c18,c19,c20,c22,c23,c24,c25,c26,c28) 
				values(sucursal,folio_contacto_nvo,asesor_tmkt,10,fecha_N , 10, motivo_contacto,0,0,observacion1,serie,folio_cita,
				tipo_servicio_tmkt, 'P', clave_cliente, concat('N+',tipo_N),0, current_date,'A',fecha_val_salida_ult_srv,0);
			
			end loop;
			
		 end if;

	end loop;
		

	EXCEPTION
		WHEN others THEN
			ROLLBACK;
			raise exception '%', SQLERRM;
		    
	end;
$procedure$
