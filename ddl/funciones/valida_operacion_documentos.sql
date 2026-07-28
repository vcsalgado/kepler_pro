CREATE OR REPLACE FUNCTION keplersc.valida_operacion_documentos(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare 

	--Variables de definicion de documento
	no_partidas int = 0;
	cantidad_unidades text = '';
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
	referencia text = '';
	clave_cteprov text = '';
	monto_total text = '';

	--Variables de uso general 
	deccantidad_partida decimal = 0.00;
   cantida_partida text = '';

   sqlStr text;
  
   var_suc text;
   var_prod text;
   var_exist decimal;
   var_dev decimal;
  	var_ref text;
  	var_cant decimal;
   msg_err text;
  
   afecta_inventario text;
  
	strValor text = '';
	intValor int = 0;
	intCont int = 0;

	numero_partida int = 0;
	no_partida_tx text;
	entradaSalida text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin 

	msg_err := '';
	
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	--tipo_movto := (xpath('//document/tipo_movto/text()', dataxml))[1];
	--Movimiento

--	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
--	fecha_movto := (xpath('//document/movimiento/fecha/text()',dataxml))[1];
	hora_movto := (xpath('//document/movimiento/hora/text()',dataxml))[1];

	referencia := coalesce((xpath('//document/k_refer/text()', dataxml))[1]::text,'')::text;
	clave_cteprov := coalesce((xpath('//document/k_clave/text()', dataxml))[1]::text,'0')::text;

	monto_total := coalesce((xpath('//document/k_monto/text()',dataxml))[1]::text,'0')::text;

	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;

	-- Copied of function : invr_movtos_alta , Validado con VCSS Analizando K75 : K_Alta y XLS KDMM (Doc Attr)
	if genero ='X' then
		if naturaleza='A' then
			entradaSalida = 'E';
		else
			entradaSalida = 'S';
		end if;
	else --Genero 'D'  ... JM : no hay Genero 'D', el Complemento de 'X' es 'U' o 'N' ;
		if naturaleza='A' then
			entradaSalida = 'E';
		else
			entradaSalida = 'S';
		end if;	
	end if;		

	numero_partida := 0;
	for intCont in 0..no_partidas - 1 loop
		--numero_partida := intCont + 1;
		--no_partida_tx := (xpath('//document/k_mov/r'||intCont||'/partida/text()',dataxml))[1];
		----numero_partida := no_partida_tx::integer;
		deccantidad_partida := 0;
		cantida_partida := coalesce((xpath('//document/k_mov/r'||intCont||'/k_q/text()',dataxml))[1],'0');
		if cantida_partida = '0' then
			cantida_partida := coalesce((xpath('//document/k_mov/r'||intCont||'/k_Q/text()',dataxml))[1],'0');
		end if;
	
		deccantidad_partida := cantida_partida::decimal;
	
		if upper(entradaSalida) = 'E' then 
			numero_partida := intCont + 1;
		else
			if deccantidad_partida > 0 then
				numero_partida := numero_partida + 1;
			end if;
		end if;

	
		clave_producto := coalesce((xpath('//document/k_mov/r' ||intCont||'/k_parte/text()',dataxml))[1],'');
	
		if upper(entradaSalida) = 'E' and deccantidad_partida <= 0 then
			msg_err := msg_err || 'Partida [' || numero_partida::text || '] Producto ' || clave_producto || ' [ERR] Cantidad <= 0 ;';	
		end if;
	
		clave_producto := btrim(clave_producto);
		if length(clave_producto) = 0 then
			msg_err := msg_err || 'Partida [' || numero_partida::text || '] , ' || ' [ERR] Sin Producto ;';
		end if;
	
	end loop;


	if monto_total::decimal <= 0 then
		msg_err := msg_err || 'Total Docto <= 0 ; ';
	end if;

	if no_partidas <= 0 then
		msg_err := msg_err || 'Num. Partidas <= 0 ; ';
	end if;

	referencia := btrim(referencia);
	clave_cteprov := btrim(clave_cteprov);
	
	if upper(genero) = 'X' and upper(naturaleza) = 'D' and grupo::integer = 40 and tipo_clave::integer = 1 then 
		if length(referencia) = 0 then
			msg_err := msg_err || 'Sin Referencia [ERR] ; ';
		end if;
		if length(clave_cteprov) = 0 then
			msg_err := msg_err || 'Sin Cliente/Proveedor [ERR] ; ';
		end if;
	end if;

	if upper(genero) = 'X' and upper(naturaleza) = 'A' and grupo::integer /*=*/ in (4,5) /*and tipo_clave::integer = 1*/ then 
		if length(referencia) = 0 then
			msg_err := msg_err || 'Sin Referencia [ERR] ; ';
		end if;
		if length(clave_cteprov) = 0 then
			msg_err := msg_err || 'Sin Cliente/Proveedor [ERR] ; ';
		end if;
	end if;


	-- Si encontro algun Error de Validacion lo lanza 
	if length(msg_err) > 0 then
		raise exception '%',msg_err;
	else
		msg_err := 'Sin problemas en Validacion de elementos del Documento. ';
	end if;


	--/*
	resultado := '1';
	mensaje := msg_err;
	adicionales := '';
	--*/

	return query select resultado, mensaje, adicionales;

--/*
exception
	when others then
		resultado := '0';
		mensaje := 'valida_operacion_documentos() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
--*/
	
end;
$function$
