CREATE OR REPLACE FUNCTION keplersc.altapedido_pedidoextras(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare

	no_partidas int = 0;
	cantidad_unidades text = '';	
	
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
---variables agregadas para kdpedidoextras
	v_inventario text = '';
	v_clave_sat text = '';
	v_descripcion text = '';
	v_unidad text = '';
	v_ctd text = '';
	v_unitario text = '';
	v_importe text = '';

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

	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];	
	v_inventario := (xpath('//document/k_inventario/text()', dataxml))[1];

	if(strValor::integer = 0)
		then  
			resultado := 1;
			mensaje := 'Sin partidas, proceso finalizado';
			adicionales := '';
		return query select resultado, mensaje, adicionales;		
	end if;

	no_partidas := strValor::integer;		
	numero_partida := 0;
	for intCont in 0..no_partidas - 1 loop		
			numero_partida := numero_partida + 1;
			if genero = 'U' then 
				--TO DO: Desarrollar condicion INVRLIB.ALTA_INVR
				if naturaleza='D' then
					v_clave_sat :=  (xpath('//document/k_mov/r' ||intCont||'/c4/text()',dataxml))[1];
					v_descripcion := (xpath('//document/k_mov/r' ||intCont||'/c5/text()',dataxml))[1];
					v_unidad := (xpath('//document/k_mov/r' ||intCont||'/c6/text()',dataxml))[1];
					v_ctd := (xpath('//document/k_mov/r' ||intCont||'/c7/text()',dataxml))[1];
					v_unitario := (xpath('//document/k_mov/r' ||intCont||'/c8/text()',dataxml))[1];
					v_importe:= (xpath('//document/k_mov/r' ||intCont||'/c9/text()',dataxml))[1];						
					
					if(select count(*) from keplersc.KDPEDIDOEXTRAS where c1 =sucursal_id and c2 = v_inventario and c4 = v_clave_sat) > 0 
						then 
							delete from keplersc.KDPEDIDOEXTRAS where c1 =sucursal_id and c2 = v_inventario and c4 = v_clave_sat;
					end if;
					insert into keplersc.KDPEDIDOEXTRAS (c1,c2,c3,c4,c5,c6,c7,c8,c9) 
						values (sucursal_id,
								v_inventario,
								numero_partida,
								v_clave_sat,
								v_descripcion,
								v_unidad,
								v_ctd::numeric,
								v_unitario::numeric, 
								v_importe::numeric);
				end if;			
			end if;
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'altapedido_pedidoextras() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
