CREATE OR REPLACE FUNCTION keplersc.valida_operacion_devoluciones_compras(dataxml xml, ptipo_compra integer)
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
	folio_compra text = '';

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
	ptipo_compra := (xpath('//document/tipo_compra/text()', dataxml))[1];		
	folio_compra := (xpath('//document/folio_compra/text()', dataxml))[1];
	--Movimiento

--	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
--	fecha_movto := (xpath('//document/movimiento/fecha/text()',dataxml))[1];
	hora_movto := (xpath('//document/movimiento/hora/text()',dataxml))[1];

	referencia := coalesce((xpath('//document/k_refer/text()', dataxml))[1]::text,'')::text;
	clave_cteprov := coalesce((xpath('//document/k_clave/text()', dataxml))[1]::text,'0')::text;

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
	
		-- * * * En la Validacion No hay problema si la cabtidad es cero, pero si debe validar las DEVs Acumuladas 
		--if deccantidad_partida > 0 then
	
			-- Implementing DEVs Validation
		
		clave_producto := coalesce((xpath('//document/k_mov/r' ||intCont||'/k_partesel/text()',dataxml))[1],'');
		   
		var_suc := '';
	   	var_prod := '';
	   	var_dev := 0;
	   	var_ref = '';
		
	   	select
			tdm1.c1 /*as sucursal*/, tdm2.c8 /*as k_parte*/, coalesce(tDev.cantdev,0) /*as k_qd*/, tdm1.c11 /*as refer*/, coalesce(tdm2.c9,0) /*as k_qc*/  
			into var_suc, var_prod, var_dev, var_ref, var_cant  
			from keplersc.kdm1 tdm1 
				inner join keplersc.kdm2 tdm2 on tdm1.c1 = tdm2.c1 and tdm1.c6 = tdm2.c6 
					and tdm1.c2 = tdm2.c2 and tdm1.c3 = tdm2.c3 and tdm1.c4 = tdm2.c4 and tdm1.c5 = tdm2.c5
				inner join keplersc.kduxg tuxg on tdm1.c1 = tuxg.c1 and tdm1.c11 = tuxg.c4 and tdm1.c10 = tuxg.c3
				inner join keplersc.kduxe tuxe on tuxg.c1 = tuxe.c1 and tuxg.c4 = tuxe.c3 and tuxg.c3 = tuxe.c2
			 	   and tdm1.c2 = tuxe.c5 and tdm1.c3 = tuxe.c6 and tdm1.c4 = tuxe.c7 and tdm1.c5 = tuxe.c8
			   left join ( 
				   select tuxg.c1, tuxg.c3, tuxe.c3 as factura, tkdm2.c8 as devprod, sum(tkdm2.c9) as cantdev  
					from keplersc.kdm1 tdm1 
						inner join keplersc.kdm2 tkdm2 on tdm1.c1 = tkdm2.c1 and tdm1.c6 = tkdm2.c6 
						  and tdm1.c2 = tkdm2.c2 and tdm1.c3 = tkdm2.c3 and tdm1.c4 = tkdm2.c4 and tdm1.c5 = tkdm2.c5
						inner join keplersc.kduxe tuxe on tdm1.c1 = tuxe.c1 and tdm1.c6 = tuxe.c9 and tdm1.c10 = tuxe.c2 
						  and tdm1.c11 = tuxe.c3 
						  and tdm1.c2 = tuxe.c5 and tdm1.c3 = tuxe.c6 and tdm1.c4 = tuxe.c7 and tdm1.c5 = tuxe.c8 
						inner join keplersc.kduxg tuxg on tuxg.c1 = tuxe.c1 and tuxg.c4 = tuxe.c3 and tuxg.c3 = tuxe.c2 
					where tuxe.c5 = /*'X'*/genero and tuxe.c6 = /*'D'*/naturaleza and tuxe.c7 = /*40*/grupo::integer and tuxe.c8 = /*1*/tipo_clave::integer    
					and tuxg.c1 = sucursal_id   
					and tuxe.c3 = referencia   
					group by tuxg.c1, tuxg.c3, tuxe.c3, tkdm2.c8
				) tDev on tuxg.c1 = tDev.c1 and tuxg.c3 = tDev.c3 and tuxg.c4 = tDev.factura and tdm2.c8 = tDev.devprod 	
			where tdm1.c1 = sucursal_id and tdm1.c10 = clave_cteprov and tdm1.c11 = referencia  
				and tdm1.c2 = 'X' and tdm1.c3 = 'A' and tdm1.c4 = 4 and tdm1.c5 = ptipo_compra
				and tdm2.c8 = clave_producto;	
		
	raise notice 'clave_producto:% var_prod:% var_cant:% var_dev:% deccantidad_partida:%',clave_producto,var_prod,var_cant,var_dev,deccantidad_partida;	
			if (coalesce(var_prod,'') = '') or (coalesce(var_cant,-1) < 0) then
				msg_prod := msg_prod || clave_producto || ' Producto no encontrado o cantidad invalida ; ';
			else
				if var_cant - var_dev - deccantidad_partida < 0 then
					msg_prod := msg_prod || clave_producto || ' Excede la cantidad a devolver ; ';
				end if;
			end if;
	
		--end if;
	
	end loop;


	if length(msg_prod) > 0 then
		raise exception '%',msg_prod;
	else
		msg_prod := 'Sin problemas de Devolucion. ';
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
		mensaje := 'valida_operacion_devoluciones_compras() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
--*/
	
end;
$function$
