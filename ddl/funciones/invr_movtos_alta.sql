CREATE OR REPLACE FUNCTION keplersc.invr_movtos_alta(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	no_partidas int = 0;
	cantidad_unidades text = '';
	strA51 text = '';
	strA52 text = '';
	strA53 text = '';
	total50s decimal = 0.00;
	clave_producto text = '';
	sucursal_id text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo_clave text = '';
	importe_partida text = '';
--	fecha_movto text = '';
	fecha_operacion text = '';
	tipo_movto text = '';
	hora_movto text = '';

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	intCont int = 0;
	decValor decimal = 0.00;
	cantidadTotal int = 0;
	promCantidadPartida decimal = 0;
	xmlCadena xml;
	numero_partida int = 0;
	importeFinalPartida decimal = 0.00;
	entradaSalida text = '';
	reqcostoxml xml = '';
	fecha_registro timestamp;

	deccantidad_partida decimal = 0.00;
	cant_ent_total decimal = 0.00;
	cant_sal_total decimal = 0.00;
	monto_ent_total decimal = 0.00;
	monto_sal_total decimal = 0.00;
	ultimo_costo decimal = 0.00;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	--Resuelve INVRLIB.ALTA_INVR

	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	tipo_movto := (xpath('//document/tipo_movto/text()', dataxml))[1];
	--Movimiento

--	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
--	fecha_movto := (xpath('//document/movimiento/fecha/text()',dataxml))[1];
	hora_movto := (xpath('//document/movimiento/hora/text()',dataxml))[1];
	
	--VCSS 30-Ago-2024 Para efecto de inventarios, siempre se debe de registrar la fecha del movimiento
	fecha_registro:=now();
	fecha_operacion := to_char(fecha_registro, 'YYYY-MM-DD');
	hora_movto := to_char(fecha_registro, 'HH24:MI');


	if length(hora_movto)<5 then
		--Rectificar la hora por si faltan ceros en horas o minutos
		strValor:=lpad(substring(hora_movto,1,position(':' in hora_movto)-1),2,'0') || ':' || lpad(substring(hora_movto,position(':' in hora_movto)+1),2,'0');
		hora_movto:=strValor;
	end if;
	
	--TO DO: Definir el origen de las variables 51..53, INVRLIB: TE PONDERA AUTOMATICAMENTE LOS CAMPOS A51...A53
	strA51 := coalesce((xpath('//document/info_50s/str51/text()', dataxml))[1],'0');
	strA52 := coalesce((xpath('//document/info_50s/str52/text()', dataxml))[1],'0');
	strA53 := coalesce((xpath('//document/info_50s/str53/text()', dataxml))[1],'0');
	total50s := strA51::decimal + strA52::decimal + strA53::decimal;
--	total50s := 0;
	--Partidas
	strValor := coalesce((xpath('//document/k_mov/no_partidas/text()', dataxml))[1],'0');
	

	if(strValor::integer = 0)
		then  
			resultado := 1;
			mensaje := 'Numero de partidas = 0';
			adicionales := '';
		return query select resultado, mensaje, adicionales;		
	end if;

	no_partidas := strValor::integer;	
	for intCont in 0..no_partidas - 1 loop
		cantidad_unidades := (xpath('//document/k_mov/r'||intCont||'/k_q/text()',dataxml))[1];
		select cast(cantidad_unidades::numeric*1 as integer) into cantidad_unidades;
		intValor := cantidad_unidades::int;
		cantidadTotal := cantidadTotal + intValor;
	end loop;
	
	if cantidadTotal>0 then
		promCantidadPartida := total50s / cantidadTotal::decimal;
	else
		promCantidadPartida:=0;
	end if;

	numero_partida := 0;
	for intCont in 0..no_partidas - 1 loop
		
		--updated by JMM 220729 
		--numero_partida := intCont + 1;
		deccantidad_partida := 0;
		cantidad_unidades := (xpath('//document/k_mov/r'||intCont||'/k_q/text()',dataxml))[1];
		deccantidad_partida := cantidad_unidades::decimal;		

		clave_producto := (xpath('//document/k_mov/r' ||intCont||'/k_parte/text()',dataxml))[1];
		importe_partida := (xpath('//document/k_mov/r' ||intCont||'/k_monto/text()',dataxml))[1];
		importeFinalPartida := importe_partida::decimal;
	
		if deccantidad_partida > 0 or importeFinalPartida > 0 then
	
			numero_partida := numero_partida + 1;	
		
			select xmlforest(clave_producto as clave_producto)::text into strValor;
			select '<document>'||strValor||'</document>' into strValor;
			xmlCadena := strValor::xml;		
			--TO DO: Verificar que el siguiente paso sea necesario, ya que solo valida que el producto exista pero no 
			--       cambia el producto reemplazo por el original
			select * into resultado, mensaje, adicionales from keplersc.prod_busca_producto(xmlCadena);
			if resultado = '0' then
				raise exception '%',mensaje;
			end if;
		
			if genero = 'X' or genero = 'N' then 
				importeFinalPartida := importeFinalPartida + (promCantidadPartida * cantidad_unidades::decimal);
			end if;
			if genero = 'U' then 
--MSS			
				select c5,c6,c8,c9,c14 into cant_ent_total, cant_sal_total, monto_ent_total, monto_sal_total, ultimo_costo
					from keplersc.kdinl 
					where c1=sucursal_id and c2=clave_producto;	
				if found then
					if cant_ent_total > cant_sal_total then
						importeFinalPartida := ((monto_ent_total-monto_sal_total)/(cant_ent_total-cant_sal_total))*cantidad_unidades::decimal;
					else
						importeFinalPartida :=0;
					end if;
					if importeFinalPartida = 0 then
						importeFinalPartida := ultimo_costo*cantidad_unidades::decimal;			--EN EL CASO DE VENTAS O DEVOLUCIONES Y QUE COSTO PROMEDIO SEA 0 LOS INGRESA CON ULTIMO COSTO
					end if;
				else
					importeFinalPartida := 0;
				end if;				
			end if;
			--Definir el costo a aplicar dependiendo del tipo de movimiento
			if genero ='X' then
				if naturaleza='A' then
					entradaSalida = 'E';
				else
					entradaSalida = 'S';
				end if;
			else --Genero 'D'
				if naturaleza='A' then
					entradaSalida = 'E';
				else
					entradaSalida = 'S';
				end if;	
			end if;		
		
		
			if entradaSalida = 'S' then
				reqcostoxml = xmlforest(sucursal_id AS sucursal, clave_producto AS clave_producto,substr(fecha_operacion,1,4) as anio,substr(fecha_operacion,6,2) as mes);
				strValor = reqcostoxml::text;
				strValor = concat('<document>',strValor,'</document>');
				reqcostoxml = strValor::xml;
				select costo_prom_total into decValor from keplersc.invr_obtener_costo_promedio(reqcostoxml);
				-- condition implemented by JMM 20220711 ...
			   if (upper(genero) = upper('X') and  upper(naturaleza) = upper('D') and grupo = '40' and tipo_clave = '1') 
					or 	(upper(genero) = 'N' and  upper(naturaleza) = 'D' and (grupo = '05' or grupo = '5')) --VCSS 23 05 2025 Para ajustes de salida, se toma el costo ingresado
				then 
			   	-- No debe modificar el campo : importeFinalPartida, para este DOC por lo pronto 
			   	importeFinalPartida = importeFinalPartida;
				else
					if decValor <> 0 then
						importeFinalPartida = decValor * cantidad_unidades::decimal;
					end if;
				end if;
			end if;
		
--raise exception 'KDINM Prod% cant% precio% Oper%',clave_producto,cantidad_unidades,importeFinalPartida,folio_operacion;
			-- Orinal VCSS
		   insert into keplersc.kdinm(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13)
			values(sucursal_id,clave_producto,fecha_registro,hora_movto,
			genero,naturaleza,grupo::int,tipo_clave::int,folio_operacion,numero_partida,
			cantidad_unidades::decimal,importeFinalPartida,1); --c13=1 = Alta
				
			
			--Registro de estadisticas
			-- UPD JMM (updated 20220711 by JMM, se agregan 2 campos al XML : grupo, tipo_clave)
			-- para IFs que se usaran en la funcion : invr_estadis_alta 
			select xmlforest(sucursal_id as sucursal, genero as genero, naturaleza as naturaleza,
			grupo as grupo, tipo_clave as tipo_clave,
			clave_producto as clave_producto, fecha_operacion as fecha, entradaSalida as entradaSalida,
			importeFinalPartida::text as monto, cantidad_unidades as cantidad):: text into strValor;
					
			select '<document>'||strValor||'</document>' into strValor;
			xmlCadena := strValor::xml;
	
			select * into resultado, mensaje, adicionales from keplersc.invr_estadis_alta(xmlCadena);
			if resultado = '0' then
				raise exception '%',mensaje;
			end if;			

		end if;  -- if deccantidad_partida > 0 
	
--raise notice 'PASO 42';			

	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'invr_movtos_alta() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
