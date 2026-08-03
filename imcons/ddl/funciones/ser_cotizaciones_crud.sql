CREATE OR REPLACE FUNCTION keplersc.ser_cotizaciones_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: crud para cotizacion de Ordenes de servicio
--Autor: Luis Leal
--Fecha: 16/10/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal text = '';
	folio_cotizacion text = '';
	folio_orden text = '';
	tipo_orden text = '';
	operario text = '';
	asesor text = '';
	cliente text = '';
	nombre_cli text = '';
	crud text = '';
	no_puntos numeric;
	modulo text = '';
	folio_cotizacion_nuevo text = '';
	num_punto numeric;
	punto numeric;
	descripcion text;
	clave text = '';
	ctd numeric;
	precio numeric;
	importe numeric;
	autorizacion numeric;
	razon text = '';
	fecha date;
	hora text = '';
			
	tipo text = '';
	stock text = '';

	strValor text = '';
  	get_resultado text = '';
  	get_mensaje text = '';
  	get_adicionales text = '';
 

	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	crud:=dataxml::text;
	crud:=replace(crud,'\&quot;','"');

	dataxml:=crud::xml;
	
	sucursal := upper((xpath('//document/k_sucN/r1/text()', dataxml))[1]::text);
	folio_cotizacion := upper(coalesce((xpath('//document/folio/text()', dataxml))[1]::text,'')::text);
	folio_orden := upper(coalesce((xpath('//document/folio_orden/text()', dataxml))[1]::text,'')::text);
	tipo_orden := upper(coalesce((xpath('//document/tipo_orden/r1/text()', dataxml))[1]::text,'')::text);
	operario := upper(coalesce((xpath('//document/operario/r1/text()', dataxml))[1]::text,'')::text);
	asesor := upper(coalesce((xpath('//document/asesor/r1/text()', dataxml))[1]::text,'')::text);
	cliente := upper(coalesce((xpath('//document/cliente/text()', dataxml))[1]::text,'')::text);
	nombre_cli := upper(coalesce((xpath('//document/nombre_cli/text()', dataxml))[1]::text,'')::text);
	punto := upper(coalesce((xpath('//document/num_punto/text()', dataxml))[1]::text,'0')::text);
	modulo := upper(coalesce((xpath('//document/modulo/text()', dataxml))[1]::text,'')::text);

	crud := (xpath('//document/crud/text()', dataxml))[1];

	if folio_orden = '' or tipo_orden = '' or  operario = '' or asesor = '' or cliente = '' then
		raise exception '%', 'Faltan datos por llenar';
	end if;

	if crud = 'Nuevo' then
	
		if modulo = 'SOLICITA' then
				
			--obtener folio nuevo 
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('COTIZACIONES.', sucursal),0,0, dataxml);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
			folio_cotizacion_nuevo := get_mensaje; 
			
			insert into keplersc.kdsercot(c1,c2, c3,c4,c12,c13, c21, c22, c30, c31) 
			values(sucursal, folio_cotizacion_nuevo, current_date, left(current_time::text, 8),
			tipo_orden, folio_orden, operario, asesor, cliente, nombre_cli);
		
			strValor := (xpath('//document/ctd_puntos/text()',dataxml))[1];
			no_puntos := strValor::integer;	
		
			for cont in 0..no_puntos - 1 loop
		
				num_punto := coalesce((xpath('//document/tabla/r' ||cont||'/num_punto/text()',dataxml))[1]::text,'');
				descripcion := coalesce((xpath('//document/tabla/r' ||cont||'/desc/text()',dataxml))[1]::text,'');

				insert into keplersc.kdsercotdet(c1,c2,c3,c4)
				values(sucursal, folio_cotizacion_nuevo, num_punto, descripcion);
			
			end loop;
		
			folio_cotizacion := folio_cotizacion_nuevo;
		
			mensaje := concat('La Cotizacion se dio de alta exitosamente con el Folio: ' ,folio_cotizacion);
			
		
		end if;

	
	end if;

	if crud = 'Modifica' then	
	
		if modulo = 'SOLICITA' then
		
			update keplersc.kdsercot set c12=tipo_orden, c13=folio_orden, c21=operario, c22=asesor,
			c30=cliente, c31=nombre_cli where c1=sucursal and c2=folio_cotizacion;
						
			strValor := (xpath('//document/ctd_puntos/text()',dataxml))[1];
			no_puntos := strValor::integer;	
		
			for cont in 0..no_puntos - 1 loop
		
				num_punto := coalesce((xpath('//document/tabla/r' ||cont||'/num_punto/text()',dataxml))[1]::text,'0');
				descripcion := coalesce((xpath('//document/tabla/r' ||cont||'/desc/text()',dataxml))[1]::text,'');

				if num_punto <> 0 and descripcion <> '' then 
					if cont = 0 then
						delete from keplersc.kdsercotdet where c1=sucursal and c2=folio_cotizacion;
						mensaje := concat('La Cotizacion con el Folio ' ,folio_cotizacion, ' se modifico correctamente.');
					end if;
				else 
					continue;
				end if;
			
				insert into keplersc.kdsercotdet(c1,c2,c3,c4)
				values(sucursal, folio_cotizacion, num_punto, descripcion);
			
			end loop;
							
		end if;
	
	
		if modulo = 'GENERA' then
		
			update keplersc.kdsercot set c6=current_date , c7= left(current_time::text, 8), 
			c12=tipo_orden, c13=folio_orden, c24=operario, c25=asesor,
			c30=cliente, c31=nombre_cli where c1=sucursal and c2=folio_cotizacion;
		
			if punto = 0 then
				raise exception '%', 'Error debes seleccionar un punto';
			end if;
					
			strValor := (xpath('//document/ctd_puntos/text()',dataxml))[1];
			no_puntos := strValor::integer;	
			
			for cont in 0..no_puntos - 1 loop
		
				clave := coalesce((xpath('//document/k_mov/r' ||cont||'/k_parte/text()',dataxml))[1]::text,'');
				descripcion := coalesce((xpath('//document/k_mov/r' ||cont||'/desc/text()',dataxml))[1]::text,'');
				ctd := coalesce((xpath('//document/k_mov/r' ||cont||'/ctd/text()',dataxml))[1]::text,'0');
				precio := coalesce((xpath('//document/k_mov/r' ||cont||'/precio/text()',dataxml))[1]::text,'0');
				importe := coalesce((xpath('//document/k_mov/r' ||cont||'/importe/text()',dataxml))[1]::text,'0');
				tipo := coalesce((xpath('//document/k_mov/r' ||cont||'/tipo/text()',dataxml))[1]::text,'');
				stock := coalesce((xpath('//document/k_mov/r' ||cont||'/stock/text()',dataxml))[1]::text,'');
			
				if clave <> '' and descripcion <> '' and ctd <> 0 and precio <> 0 
				and importe <> 0 and tipo <> '' and stock <> '' then 
					if cont = 0 then
						delete from keplersc.kdsercotref where c1=sucursal and c2=folio_cotizacion and c3=punto;
						mensaje := concat('La Cotizacion se genero correctamente para el punto ' , punto::text);
					end if;
				else
					continue;
				end if;
			
				insert into keplersc.kdsercotref(c1,c2,c3,c4,c5,c6,c7,c8,c9,c14)
				values(sucursal, folio_cotizacion, punto, clave, descripcion,
				ctd, precio, importe,tipo, stock);
			
			end loop;
				
		
		end if;
	
	
		if modulo = 'APRUEBA' then
		
			update keplersc.kdsercot set c9=current_date , c10= left(current_time::text, 8), 
			c12=tipo_orden, c13=folio_orden, c27=operario, c28=asesor,
			c30=cliente, c31=nombre_cli where c1=sucursal and c2=folio_cotizacion;
				
			if punto = 0 then
				raise exception '%', 'Error debes seleccionar un punto';
			end if;
					
			strValor := (xpath('//document/ctd_puntos/text()',dataxml))[1];
			no_puntos := strValor::integer;	
			
			for cont in 0..no_puntos - 1 loop
		
				clave := coalesce((xpath('//document/k_mov/r' ||cont||'/k_parte/text()',dataxml))[1]::text,'');
				descripcion := coalesce((xpath('//document/k_mov/r' ||cont||'/desc/text()',dataxml))[1]::text,'');
				importe := coalesce((xpath('//document/k_mov/r' ||cont||'/importe/text()',dataxml))[1]::text,'0');
				autorizacion := coalesce((xpath('//document/k_mov/r' ||cont||'/autorizacion/text()',dataxml))[1]::text,'0');
				razon := coalesce((xpath('//document/k_mov/r' ||cont||'/razon/text()',dataxml))[1]::text,'');
				fecha := coalesce((xpath('//document/k_mov/r' ||cont||'/fecha/text()',dataxml))[1]::text,'1990-01-01');
				hora := coalesce((xpath('//document/k_mov/r' ||cont||'/hora/text()',dataxml))[1]::text,'');
				stock := coalesce((xpath('//document/k_mov/r' ||cont||'/stock/text()',dataxml))[1]::text,'');
						

				if clave <> '' and descripcion <> '' and importe <> 0 then 
					mensaje := concat('La Cotizacion se aprobo correctamente para el punto ' , punto::text);
				end if;
						
				update keplersc.kdsercotref set c11=autorizacion, c10=razon, c12=fecha, c13=hora, c14=stock where 
				c1=sucursal and c2=folio_cotizacion and c3=punto and c4=clave and c5=descripcion and c8=importe;		

			end loop;
				
		
		end if;
	
	end if;

	resultado := 1;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
	
		mensaje := 'ser_cotizaciones_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		

		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
