CREATE OR REPLACE FUNCTION keplersc.valida_operacion_inventarios(dataxml xml)
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

	--Variables de uso general 
	deccantidad_partida decimal = 0.00;
   cantida_partida text = '';

   sqlStr text;
  
   var_suc text;
   var_prod text;
   var_exist decimal;
	msg_prod text;
  
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

	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;

	msg_prod := '';
  
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
		deccantidad_partida := cantida_partida::decimal;
	
		if upper(entradaSalida) = 'E' then 
			numero_partida := intCont + 1;
		else
			if deccantidad_partida > 0 then
				numero_partida := numero_partida + 1;
			end if;
		end if;	
	
		-- NEW 20220724 ; MANDATORY TO CHECK with VCSS : Por el tema de las partidas con Catidad = 0 
	   -- el cual es un escenario presentado en los Grids (Tabla-Ambiente Grafico) debido a que todas 
		-- las partidas de la Compra se precargan, pero no necesariamente todas se utilizan en la 
		-- Devolucion; sin embargo se incluyen en el XML que se envia como parametro al Docdis, por la 
		-- La funcion que Carga el Ambiente Grafico al XML de envio 
	
		-- * * * En la Validacion No hay problema si la cabtidad es cero, pero si valida las DEVs Acumuladas 
		--if deccantidad_partida > 0 then
	
			-- Implementing Inventory Validation 
			clave_producto := coalesce((xpath('//document/k_mov/r' ||intCont||'/k_parte/text()',dataxml))[1],'');
		   
			var_suc := '';
	   	var_prod := '';
	   	var_exist := 0;
		
		  	select Q1.sucursal, Q1.producto, coalesce(sum(Q1.cantent),0) - coalesce(sum(Q1.cantsal),0) existencias 
			into var_suc, var_prod, var_exist  from  
				(select tinm.c1 as sucursal, tinm.c2 as producto, 
					case when (tinm.c5='U' and tinm.c6='A') or (tinm.c5='X' and tinm.c6='A') or (tinm.c5='N' and tinm.c6='A') then sum(tinm.c11) end as cantent,
					case when (tinm.c5='U' and tinm.c6='D') or (tinm.c5='X' and tinm.c6='D') or (tinm.c5='N' and tinm.c6='D') then sum(tinm.c11) end as cantsal 
		 		from keplersc.kdinm tinm
		 		where tinm.c1 = sucursal_id and  tinm.c2 = clave_producto 
	 	 		group by tinm.c1, tinm.c2, tinm.c5, tinm.c6, tinm.c11) as Q1
			Group by Q1.sucursal, Q1.producto;
	
			if (coalesce(var_prod,'') = '') or (coalesce(var_exist,-1) < 0) then
				msg_prod := msg_prod || clave_producto || ' Not found or Quantity Issue ; ';
			else
				if var_exist - deccantidad_partida < 0 then
					msg_prod := msg_prod || clave_producto || ' Not enough inventory ; ';
				end if;
			end if;
	
		--end if;
		
	end loop;


	if length(msg_prod) > 0 then
		raise exception '%',msg_prod;
	else
		msg_prod := 'Sin problemas de Inventario. ';
	end if;
	

	--/*
	resultado := '1';
	mensaje := msg_prod;
	adicionales := '';
	--*/

	return query select resultado, mensaje, adicionales;

--/*
exception
	when others then
		resultado := '0';
		mensaje := 'valida_operacion_inventarios() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
--*/
	
end;
$function$
