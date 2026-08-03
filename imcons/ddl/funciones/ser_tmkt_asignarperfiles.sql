CREATE OR REPLACE FUNCTION keplersc.ser_tmkt_asignarperfiles(sucursal_id text, folio text, asesor text)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
--Descripcion: Esta funcion obtiene los perfiles registrados para una serie de un evento asignado de telemarketing
--   y regresa el registro.
--Autor: Miriam Santana
--Fecha: 16/08/2023
--Bitacora de cambios
declare 
	--Variables de proceso
	xmlResultado xml;
	error text = '';
	totReg int = 0;
	sigFolio text ='';
	sqlExp text = '';
	serie text = '';
	inventario text ='';

begin
	--Determinar si el registro contiene serie 
	--raise exception 'suc:% , folio:% , asesor:%',sucursal_id,folio,asesor;
	select coalesce(tmkt.c14,'') into serie from keplersc.kdtmktser2 tmkt where tmkt.c1=sucursal_id and tmkt.c2=folio;
	select coalesce(c15,'') into inventario from keplersc.kdctasbienvser where c1=sucursal_id and c6=serie;
	if serie <> '' then	
		if inventario = '' or inventario is null then		--Normal anterior
	/*  anterior repetido con el propietario
	 select case when cte.c2 is null then null else ''ADQUISICION'' end as perfil, cte.c2 as cliente_id, cte.c3 as cliente_nombre, cte.c4 as cliente_calle, cte.c45 as cliente_ext, cte.c46 as cliente_int,
			cte.c5 as cliente_colonia, cte.c6 as cliente_poblacion, cte.c47 as cliente_municipio, cte.c48 as cliente_estado,
			cte.c49 as cliente_pais, cte.c27 as cliente_cp, cte.c11 as cliente_correo, cte.c7 as cliente_tcasa, cte.c8 as cliente_toficina, 
			cte.c9 as cliente_tmovil, '''' as medio_preferido
			from keplersc.kdtmktser2 tmkt 
			left outer join keplersc.kdserie ser on ser.c1 = tmkt.c14 
			left outer join keplersc.kdud cte on cte.c2 = ser.c9 
			where tmkt.c1=%1$L and tmkt.c2=%2$L and upper(tmkt.c3)=upper(%3$L)
	 */
			sqlExp = format('select case when cte.c2 is null then null else ''ADQUISICION'' end as perfil, cte.c2 as cliente_id, 
				cte.c3 as cliente_nombre, cte.c4 as cliente_calle, cte.c45 as cliente_ext, cte.c46 as cliente_int,
				cte.c5 as cliente_colonia, cte.c6 as cliente_poblacion, cte.c47 as cliente_municipio, cte.c48 as cliente_estado,
				cte.c49 as cliente_pais, cte.c27 as cliente_cp, cte.c11 as cliente_correo, cte.c7 as cliente_tcasa, cte.c8 as cliente_toficina, 
				cte.c9 as cliente_tmovil, '''' as medio_preferido
				from keplersc.kdtmktser2 tmkt 
				left outer join keplersc.kdud cte on cte.c2 =(select c11 from keplersc.kdventas k 
				where c1=tmkt.c1 and c2=(select c2 from keplersc.kdinf where right(c5,8)=tmkt.c14 
				and c1=tmkt.c1 order by c24 desc limit 1)
				and c10=0 order by c3 desc limit 1)	
				where tmkt.c1=%1$L and tmkt.c2=%2$L and upper(tmkt.c3)=upper(%3$L)
				union 
				select case when ser.c1 is null then null else ''RESP. MANTTO'' end as perfil, '''' as cliente_id, trim(ser.c22)||'' ''||trim(ser.c27)||'' ''||trim(ser.c28) as cliente_nombre, '''' as cliente_calle, '''' as cliente_ext, '''' as cliente_int,
					'''' as cliente_colonia, '''' as cliente_poblacion, '''' as cliente_municipio, '''' as cliente_estado,
					'''' as cliente_pais, '''' as cliente_cp, ser.c29 as cliente_correo, ser.c23 as cliente_tcasa, '''' as cliente_toficina, 
					ser.c35 as cliente_tmovil, ser.c34 as medio_preferido
				from keplersc.kdtmktser2 tmkt 
				left outer join keplersc.kdserie ser on ser.c1 = tmkt.c14 
				where tmkt.c1=%1$L and tmkt.c2=%2$L and upper(tmkt.c3)=upper(%3$L)
				union 
				select case when ser.c1 is null then null else ''CONDUCTOR'' end as perfil, '''' as cliente_id, trim(ser.c20)||'' ''||trim(ser.c24)||'' ''||trim(ser.c25) as cliente_nombre, '''' as cliente_calle, '''' as cliente_ext, '''' as cliente_int,
					'''' as cliente_colonia, '''' as cliente_poblacion, '''' as cliente_municipio, '''' as cliente_estado,
					'''' as cliente_pais, '''' as cliente_cp, ser.c26 as cliente_correo, ser.c21 as cliente_tcasa, '''' as cliente_toficina, 
					ser.c33 as cliente_tmovil, ser.c32 as medio_preferido
				from keplersc.kdtmktser2 tmkt 
				left outer join keplersc.kdserie ser on ser.c1 = tmkt.c14  
				where tmkt.c1=%1$L and tmkt.c2=%2$L and upper(tmkt.c3)=upper(%3$L)
				union 
				select case when cte.c2 is null then null else ''PROPIETARIO'' end as perfil, cte.c2 as cliente_id, cte.c3 as cliente_nombre, cte.c4 as cliente_calle, cte.c45 as cliente_ext, cte.c46 as cliente_int,
					cte.c5 as cliente_colonia, cte.c6 as cliente_poblacion, cte.c47 as cliente_municipio, cte.c48 as cliente_estado,
					cte.c49 as cliente_pais, cte.c27 as cliente_cp, cte.c11 as cliente_correo, cte.c7 as cliente_tcasa, cte.c8 as cliente_toficina, 
					cte.c9 as cliente_tmovil, '''' as medio_preferido
				from keplersc.kdtmktser2 tmkt 
				left outer join keplersc.kdserie ser on ser.c1 = tmkt.c14 
				left outer join keplersc.kdud cte on cte.c2 = ser.c9 
				where tmkt.c1=%1$L and tmkt.c2=%2$L and upper(tmkt.c3)=upper(%3$L)
				order by cliente_id, perfil desc',sucursal_id,folio,asesor);
			
			raise NOTICE '1: %', sqlExp;
		else
			sqlExp = format('select case when cte.c2 is null then null else ''ADQUISICION'' end as perfil,
			cte.c2 as cliente_id, cte.c3 as cliente_nombre, cte.c4 as cliente_calle, cte.c45 as cliente_ext, cte.c46 as cliente_int,
			cte.c5 as cliente_colonia, cte.c6 as cliente_poblacion, cte.c47 as cliente_municipio, cte.c48 as cliente_estado,
			cte.c49 as cliente_pais, cte.c27 as cliente_cp, cte.c11 as cliente_correo, cte.c7 as cliente_tcasa, cte.c8 as cliente_toficina, 
			cte.c9 as cliente_tmovil, case when cte.c2 is null then null else '''' end as medio_preferido			
 			from keplersc.kdtmktser2 tmkt  
			inner join keplersc.kdud cte on cte.c2=tmkt.c20
			where tmkt.c1=%L and tmkt.c2=%L and upper(tmkt.c3)=upper(%3$L)',sucursal_id,folio,asesor);	
		raise NOTICE 'con inventario: %', sqlExp;
		end if;
	else
		sqlExp = format('select case when cte.c2 is null then null else ''ADQUISICION'' end as perfil,
			cte.c2 as cliente_id, cte.c3 as cliente_nombre, cte.c4 as cliente_calle, cte.c45 as cliente_ext, cte.c46 as cliente_int,
			cte.c5 as cliente_colonia, cte.c6 as cliente_poblacion, cte.c47 as cliente_municipio, cte.c48 as cliente_estado,
			cte.c49 as cliente_pais, cte.c27 as cliente_cp, cte.c11 as cliente_correo, cte.c7 as cliente_tcasa, cte.c8 as cliente_toficina, 
			cte.c9 as cliente_tmovil, case when cte.c2 is null then null else ''XXXXX'' end as medio_preferido			
 			from keplersc.kdtmktser2 tmkt  
			inner join keplersc.kdud cte on cte.c2=tmkt.c20  
			where tmkt.c1=%L and tmkt.c2=%L and upper(tmkt.c3)=upper(%3$L)',sucursal_id,folio,asesor);	
		raise NOTICE '2: %', sqlExp;	
	end if;
	select query_to_xml(sqlExp,false,true,'') into xmlResultado;
	return xmlResultado;

exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
