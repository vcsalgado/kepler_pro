CREATE OR REPLACE FUNCTION keplersc.obtener_folio_documento(folio_id text, val_c2 integer, val_c3 integer, dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, valores text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: obtiene folio documento
--Autor: Luis Leal
--Fecha: 02/12/2022
--Bitacora de cambios
declare 
	folio_operacion text;
	intValor int;
	strValor text;
	tabla text;
	campo_folio text;
	strPrefijo text;
	expSql text;
	xmlResultado xml;
	uen text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_clave text;
	letras_sat text;
	lenFolio int = 0;
	retorno_sql xml = '';
	ctd_folio_repetido int;
	sql_folio_repetido text;
	consecutivo_folio text;
	genera_cfd text;
	sucursal_id text;

	--Variables de retorno
	resultado text;
	mensaje text;
	valores text;

begin
	strPrefijo = '';
	
	uen := coalesce((xpath('//document/ambiente/uen/text()', dataxml))[1]::text,'X')::text;
	genero := coalesce((xpath('//document/k_tipon/r1/text()', dataxml))[1]::text,'')::text;
	naturaleza := coalesce((xpath('//document/k_tipon/r2/text()', dataxml))[1]::text,'')::text;
	grupo := coalesce((xpath('//document/k_tipon/r3/text()', dataxml))[1]::text,'')::text;
	tipo_clave := coalesce((xpath('//document/k_tipon/r4/text()', dataxml))[1]::text,'')::text;
	sucursal_id := split_part(folio_id, '.', 2);
	folio_id := split_part(folio_id, '.', 1);
	--Realizar un UPDATE para tomar la tabla como exclusiva mientras se calcula el nuevo folio
	update keplersc.sqliov set c4 = c4
	where col_sucursal = sucursal_id and c1 = folio_id and c2=val_c2 and c3=val_c3;

	select concat(c4 ,'|', c5 ,'|', c6) into strValor from keplersc.sqliov WHERE col_sucursal = sucursal_id and c1 = folio_id and c2=val_c2 and c3=val_c3;

	if(strValor is null) then
		--TODO, crear folio automatico
		raise exception 'Folio no encontrado %, %, %', folio_id, val_c2, val_c3;
	end if;

	tabla := split_part(strValor, '|', 2);
	campo_folio := split_part(strValor, '|', 3);
	consecutivo_folio := split_part(strValor, '|', 1);
	lenFolio = length(consecutivo_folio);
	consecutivo_folio := consecutivo_folio::int + 1;
	strValor := lpad(consecutivo_folio,lenFolio,'0');	

	update keplersc.sqliov set c4 = strValor
	where col_sucursal = sucursal_id and c1=folio_id and c2=val_c2 and c3=val_c3;

	if genero <> '' and naturaleza <> '' and grupo <> '' and tipo_clave <> '' then 
		if lenFolio <> 7 then
			raise exception '%' , 'La longitud del folio debe ser de 7 caracteres.';
		else
			select c80 into genera_cfd from keplersc.kdmm where col_sucursal=sucursal_id and c1=genero and c2=naturaleza and c3=grupo::numeric  and c4=tipo_clave::numeric;
			if genera_cfd = 'S' then
				select c6 into letras_sat from keplersc.kdcfdsersucdoc where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::numeric and c5=tipo_clave::numeric;
				if not found then
					letras_sat := 'XX';
				end if;		
			else
				letras_sat := 'XX';
			end if;
			strValor := concat(substring(uen, 1,1), letras_sat ,strValor);
		end if;
	else
		if lenFolio <> 10 then
			raise exception '%' , 'La longitud del folio debe ser de 10 caracteres.';
		end if;
	end if;

	folio_operacion:=strValor;

	--Buscar si no existe folio repetido en tabla del documento 
	if tabla <>'' then		--MSS: Sin validar folio repetido, no hay tabla donde validar
		if tabla='kdm1' then
			sql_folio_repetido :=  format('select count(*) as ctd_folio_repetido from keplersc.%1$s where %2$s=%3$L 
				and c2=%4$L and c3=%5$L and c4=%6$s and c5=%7$s and c1=%8$L', 
				tabla, campo_folio , folio_operacion, genero,naturaleza,grupo,tipo_clave,sucursal_id);
		else
			expSql=format('select count(*) as ctd_folio_repetido from keplersc.%1$s where %2$s=%3$L and c1=%4$L', 
				tabla, campo_folio , folio_operacion,sucursal_id );
			sql_folio_repetido := expSql;
		end if;
raise notice 'sucursal_id:% folio_id:% val_c2:% val_c3:% folio_operacion:%',sucursal_id,folio_id,val_c2,val_c3,folio_operacion ;
raise notice 'expSql:% ',expSql;
		select query_to_xml(sql_folio_repetido, false, true, '' ) :: xml into retorno_sql ;
	
		intValor := ((xpath('//row/ctd_folio_repetido/text()', retorno_sql))[1]::text)::int;
		ctd_folio_repetido:=intValor;
	
		if  tabla <> 'kdm1' then
			if ctd_folio_repetido > 0 then
				raise exception '%: %' , 'El folio ingresado ya esta utilizado.', ctd_folio_repetido;
			end if;
		end if;
	
		while ctd_folio_repetido > 0 loop
			
			raise notice 'folio repetido: %', folio_operacion;
		
			consecutivo_folio := consecutivo_folio::int + 1;
			strValor := lpad(consecutivo_folio,lenFolio,'0');
			--Actualiza con el ultimo consecutivo obtenido
			update keplersc.sqliov set c4 = strValor where c1=folio_id and c2=val_c2 and c3=val_c3;
			
			if tabla='kdm1' then
				folio_operacion := concat(substring(uen, 1, 1), letras_sat ,strValor);
				sql_folio_repetido :=  format('select count(*) as ctd_folio_repetido from keplersc.%1$s where %2$s=%3$L 
					and c2=%4$L and c3=%5$L and c4=%6$s and c5=%7$s', tabla, campo_folio , folio_operacion, genero,naturaleza,grupo,tipo_clave);
			else
				/*folio_operacion := strValor;
				sql_folio_repetido :=  format('select count(*) as ctd_folio_repetido from keplersc.%1$s where %2$s=%3$L', 
					tabla, campo_folio , folio_operacion );*/
			end if;
			
			select query_to_xml(sql_folio_repetido, false, true, '' ) :: xml into retorno_sql ;
	
			intValor := ((xpath('//row/ctd_folio_repetido/text()', retorno_sql))[1]::text)::int;
			ctd_folio_repetido:=intValor;
			
		end loop;
	end if;	
	--Retorno tipo tabla
	resultado := '1';
	mensaje := folio_operacion;
	valores:= '';

	return query select resultado, mensaje, valores;

EXCEPTION
	WHEN others then
		--Retorno tipo tabla
		resultado := '0';
		mensaje := 'obtener_folio_documento(): ' || sqlerrm;
		valores:= '';
		return query select resultado, mensaje, valores;
end;
$function$
