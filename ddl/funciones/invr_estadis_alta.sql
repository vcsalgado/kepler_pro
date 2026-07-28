CREATE OR REPLACE FUNCTION keplersc.invr_estadis_alta(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Función que actualiza de la estadistica de un producto, se asume que el valor 
	--monto en el xml ya es el promedio en el caso de las salidas.
	--Variables de definicion de documento
	sucursal_id text = '';	
	clave_producto text = '';
	fecha_operacion text = '';
	entradaSalida text ='';
	monto text = '';
	cantidad text = '';
	genero text = '';
	naturaleza text = '';

	-- Added by JMM 20220711 
	grupo text = '';
	tipo_clave text = '';

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	totReg int = 0;
	anio_en_curso text = '';
	mes_en_curso text = '';
	campo_monto text = '';
	campo_cantidad text = '';
	campo_cantidad_base_entradas int = 10;
	campo_monto_base_entradas int = 22;
	campo_cantidad_base_salidas int = 40;
	campo_monto_base_salidas int = 52;
	expSql text  = '';
	tabla_upd text = '';
	decCantidad decimal =0.00;
	decMonto decimal = 0.00;
	decCostoPromedio decimal = 0.00;
	cadenaXml xml;

	--Variables relacionadas con estaditicas
	anio text = ''; 
	_cant_ent_total numeric = 0.00; 
	_cant_sal_total numeric = 0.00;
	_monto_ent_total numeric = 0.00;
	_monto_sal_total numeric = 0.00;
	_ultimo_costo numeric = 0.00;
	_penultimo_costo numeric = 0.00;
	_costo_prom_total numeric = 0.00; 
	_minimo_reorden numeric = 0.00;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	--Resuelve INVRLIB.ALTA_K
	sucursal_id := (xpath('//document/sucursal/text()', dataxml))[1];
	genero := (xpath('//document/genero/text()',dataxml))[1]::text;
	naturaleza := (xpath('//document/naturaleza/text()',dataxml))[1]::text;
	clave_producto := (xpath('//document/clave_producto/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/fecha/text()', dataxml))[1]; --aaaa/mm/dd
	entradaSalida := (xpath('//document/entradasalida/text()', dataxml))[1];  --[E]Entrada, [S]Salida	
	monto := (xpath('//document/monto/text()', dataxml))[1];  
	cantidad := (xpath('//document/cantidad/text()', dataxml))[1];
--raise exception 'dataxml %',dataxml;	
	-- Added by JMM 20220711 
	grupo := (xpath('//document/grupo/text()', dataxml))[1];
	tipo_clave := (xpath('//document/tipo_clave/text()', dataxml))[1];

	decMonto :=  monto::decimal;
	decCantidad := cantidad::decimal;

	anio_en_curso := substring(fecha_operacion,1,4);
	mes_en_curso := substring(fecha_operacion,6,2);

	--Obtener la informacion actual de estadistica
	cadenaXml=xmlforest(sucursal_id AS sucursal, clave_producto AS clave_producto,substr(fecha_operacion,1,4) as anio,substr(fecha_operacion,6,2) as mes);
	strValor=cadenaXml::text;
	strValor=concat('<document>',cadenaXml,'</document>');
	cadenaXml=strValor::xml; 

	select cant_ent_total, cant_sal_total, monto_ent_total, monto_sal_total, ultimo_costo, penultimo_costo, costo_prom_total, minimo_reorden 
		into _cant_ent_total, _cant_sal_total, _monto_ent_total, _monto_sal_total, _ultimo_costo, _penultimo_costo, _costo_prom_total, _minimo_reorden 
		from keplersc.invr_obtener_costo_promedio(cadenaXml);


/*
raise exception '_cant_ent_total:%, _cant_sal_total:%, _monto_ent_total:%, _monto_sal_total:%, _ultimo_costo:%, _penultimo_costo:%, _costo_prom_total:%, _minimo_reorden:% decMonto:% decCantidad:%',
_cant_ent_total, _cant_sal_total, _monto_ent_total, _monto_sal_total, _ultimo_costo, _penultimo_costo, _costo_prom_total, _minimo_reorden, decMonto, decCantidad;
*/
	--Verificar que el movimiento no vaya a dejar saldos negativos
	if entradaSalida ='S' then
		if _cant_ent_total - _cant_sal_total - decCantidad < 0 then 
			raise exception 'La salida de la refacción % dejaría el inventario en negativo, existencias actuales: %.',clave_producto,_cant_ent_total - _cant_sal_total;
		end if;
	end if;

	--KDKINK
	if entradaSalida = 'E' then --ENTRADAS
		intValor := mes_en_curso::int;
		intValor := campo_monto_base_entradas + intValor - 1;
		campo_monto := intValor::text;
	
		intValor := mes_en_curso::int;
		-- Updated by JMM 20220711, remove ::int 
		--intValor := campo_cantidad_base_entradas + intValor::int - 1;
	   intValor := campo_cantidad_base_entradas + intValor - 1;
		campo_cantidad := intValor::text;
	else --SALIDAS
	
		intValor := mes_en_curso::int;
	   -- Updated by JMM 20220711, remove ::int
		--intValor := campo_monto_base_salidas + intValor::int - 1;
		intValor := campo_monto_base_salidas + intValor - 1;
		campo_monto := intValor::text;
	
		intValor := mes_en_curso::int;
		-- Updated by JMM 20220711, remove ::int
		--intValor := campo_cantidad_base_salidas + intValor::int - 1;
		intValor := campo_cantidad_base_salidas + intValor - 1;
		campo_cantidad := intValor::text;
	end if;

	
	
	--KDINL Calc. de valores estadisticos
	if entradaSalida = 'E' then --ENTRADAS
		_cant_ent_total = _cant_ent_total + decCantidad;
		_monto_ent_total = _monto_ent_total + decMonto;
		_penultimo_costo = _ultimo_costo;
		_ultimo_costo = decMonto/decCantidad;
	else	
		_cant_sal_total = _cant_sal_total + decCantidad;
		if genero='N' and naturaleza='D' and (grupo = '05' or grupo='5') then
			_monto_sal_total = _monto_sal_total + decMonto;
			_penultimo_costo = _ultimo_costo;
			if decCantidad<>0  then
				_ultimo_costo = decMonto/decCantidad;
			else
				_ultimo_costo = decMonto;
			end if;
--raise exception '1 _cant_sal_total: %; , _monto_sal_total: %;, decMonto: %;, _ultimo_costo: %; monto:%',_cant_sal_total, _monto_sal_total, decMonto, _ultimo_costo, monto;
		else
			_monto_sal_total = _monto_sal_total + (_costo_prom_total * decCantidad);
			_penultimo_costo = _ultimo_costo;
			_ultimo_costo = _costo_prom_total;
--raise exception '2 _cant_sal_total: %; , _monto_sal_total: %;, decMonto: %;, _ultimo_costo: %; monto:%',_cant_sal_total, _monto_sal_total, decMonto, _ultimo_costo, monto;
		end if;		
	end if;
	--Buscar Sucursal, producto y Anio
	select count(*) into totReg from keplersc.kdink where c1=sucursal_id and c2=clave_producto and c3=anio_en_curso;
raise notice 'Encontrados:% ',totReg;	
	if totReg = 0 then
		insert into keplersc.kdink (c1,c2,c3) values(sucursal_id, clave_producto, anio_en_curso);
	end if;

	--Actualizar kdink
	tabla_upd = 'keplersc.kdink';
   if upper(genero) = upper('X') and  upper(naturaleza) = upper('D') and grupo = '40' and tipo_clave = '1' then  
 		-- New code by JMM 20220711 / for specific doc 
      -- segun mi mapeo no aplica asignar aqui el valor del calculo : 
      -- _monto_sal_total = _monto_sal_total + (_costo_prom_total * decCantidad); 
   
   		--raise notice 'fun.invr_estadis_alta % ','Entro al Concat.UPD.X.D.40.1';
   
   		expSql=concat('update ', tabla_upd, ' set c', campo_monto, ' = c',campo_monto, ' + ', decMonto/*monto*/::text ,
   			', c', campo_cantidad, ' = c', campo_cantidad, ' + ', cantidad::text, 
   				' WHERE c1 = ', E'\'', sucursal_id,  E'\' ', ' and c2 = ', E'\'', clave_producto, E'\' ',
  			    ' and c3 = ', E'\'', anio_en_curso, E'\' returning c2 ');
  			  
  		--raise notice 'fun.invr_estadis_alta [Concat expSql] % ', expSql;
   else
   	-- Original por VCSS
   	expSql := concat('update ', tabla_upd, ' SET c', campo_monto, '= c', campo_monto, ' + ', monto,
	   	', c', campo_cantidad,  '= c', campo_cantidad, ' + ', cantidad::text,
		   ' WHERE c1=', E'\'', sucursal_id, E'\' ', ' and c2=', E'\'', clave_producto, E'\' ',
		   ' and c3=', E'\'', anio_en_curso, E'\' returning c2 ');
	end if;
	execute expSql into strValor;
	if strValor is null then
		raise exception 'No se puede actualizar kdink producto %.',clave_producto ;
	end if;

	--KDINL
	select count(*) into totReg from keplersc.kdinl where c1=sucursal_id and c2=clave_producto;
	if totReg = 0 then
		insert into keplersc.kdinl (c1,c2) values(sucursal_id, clave_producto);
	end if;	

	if entradaSalida = 'E' then --ENTRADAS
		update keplersc.kdinl set c5=_cant_ent_total, c8=_monto_ent_total, 
		c15=_penultimo_costo, c14=_ultimo_costo, c18=c12, c12=to_date(fecha_operacion,'YYYY-MM-DD')
		where c1=sucursal_id and c2=clave_producto returning c1 into strValor;
	else
	
		-- New condition by JMM, se tuvieron a parte que pasar parámetros adicionales
		-- en el XML de entrada : grupo, tipo_clave  
	   -- segun mi mapeo no aplica asignar aqui el valor del calculo :
	   -- _monto_sal_total = _monto_sal_total + (_costo_prom_total * decCantidad); 
		if upper(genero) = upper('X') and  upper(naturaleza) = upper('D') and grupo = '40' and tipo_clave = '1' then 
			-- (?) en K75 Las toma de la kdini.11 y kdini.12 
			--update keplersc.kdinl set c6=_cant_sal_total, c9=_monto_sal_total
			update keplersc.kdinl set c6 = c6 + decCantidad, c9 = c9 + decMonto 
			where c1=sucursal_id and c2=clave_producto returning c1 into strValor;	
		
		else
		
			-- Original por VCSS 
			update keplersc.kdinl set c6=_cant_sal_total, c9=_monto_sal_total,
			c15=_penultimo_costo, c14=_ultimo_costo, c17=c11, c11=to_date(fecha_operacion,'YYYY-MM-DD')
			where c1=sucursal_id and c2=clave_producto returning c1 into strValor;
		
		end if;
	
	end if; 

	if strValor is null then
		raise exception 'No se puede actualizar kdinl producto %.',clave_producto ;
	end if;


	--KDREFLASTMOV
	select count(*)	into totReg from keplersc.kdreflastmov where c1=sucursal_id and c2=clave_producto;
	if totReg = 0 then
		insert into keplersc.kdreflastmov (c1,c2,c3) values(sucursal_id,clave_producto,to_date(fecha_operacion,'YYYY-MM-DD'));
		strValor := sucursal_id;
	else
		update keplersc.kdreflastmov set c3 = to_date(fecha_operacion,'YYYY-MM-DD') 
			where c1=sucursal_id and c2=clave_producto returning c1 into strValor; 
	end if;

	if strValor is null then
		raise exception 'No se actualizo kdreflastmov %.',clave_producto ;
	end if; 


	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'invr_estadis_alta() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
