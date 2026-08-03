CREATE OR REPLACE FUNCTION keplersc.carga_refacciones_insert(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: carga_refacciones_insert
--Autor: Luis Leal
--Fecha: 26/01/2022
--Bitacora de cambios
--08/Ago/2024 Miriam Santana: Registrar en bitacora movimientos autorizados con precio menor al calculado
--30/Dic/2025 Miriam Santana: Registrar en bitacora movimientos con modificacion en las refacciones del paquete
declare

	sucursal_id text;
	genero text;
	naturaleza text;
	grupo integer;
	tipo integer;

	fecha_mov text;
	tipo_orden text;
	orden text;
	M67 text;

	--variables loop
	Codigo_requisicion integer;
	partida integer;
	producto text;
	descr text;
	cantidad numeric;
	unidad text;
	unitario numeric;
	importe numeric; 
	monto numeric;

	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
   
   	iva_cte decimal = 0.00;		--cfdi no calculos
	total_cte decimal = 0.00;	--cfdi no calculos
	iva_default decimal = 0.00; --cfdi no calculos
	
	--MSS 080824 Registro en bitacora precio menor al calculado
	usuario text = '';
	fecha_movto text = '';
	hora_movto text = '';
	strBitacora text = '';
	operacion text = '';
	strValor text = '';
	cantidad_unidades text = '';
	importe_partida text = '';
	parte text = '';
	autorizado text = '';
	get_resultado text = '';
	get_mensaje text = '';
	get_adicionales text = '';	
	deccantidad_partida decimal = 0.00;
	no_partidas integer;
	precio_ini decimal = 0.00;
	precio decimal = 0.00;
	xmlUsr xml;

	--MSS 30122025 Registro en bitacora movimientos con cambios en las refacciones del paquete
	mod_refacc_paquete text = '';
	tipo_mod_paquete text = '';
	
begin 

	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	mod_refacc_paquete := (xpath('//document/mod_paquete/text()', dataxml))[1];
	tipo_mod_paquete := (xpath('//document/tipo_mod_paquete/text()', dataxml))[1];
	
	select m1.c9,m1.c121,m1.c122,mm.c67 into fecha_mov,tipo_orden,orden,M67 from keplersc.kdm1 as m1
	inner join keplersc.kdmm as mm on mm.col_sucursal=m1.c1 and mm.c1= m1.c2 and  mm.c2= m1.c3 and mm.c3= m1.c4 and mm.c4= m1.c5 
	where m1.c1=sucursal_id and m1.c2=genero and m1.c3=naturaleza and m1.c4=grupo and m1.c5=tipo 
	and m1.c6=folio_operacion;
	
	if found then
	--cfdi no calculos 
		--Obtiene %Iva
		select c11 into iva_default from keplersc.kdmargen where c1=tipo_orden;
	--
		for Codigo_requisicion,partida,producto,descr,cantidad,unidad,unitario,importe 
		in select c27,c7,c8,c10,c9,c11,c12,c13 from keplersc.kdm2 where c1=sucursal_id and c2=genero 
		and c3=naturaleza and c4=grupo and c5=tipo and c6=folio_operacion
		loop
								
			monto := importe;
			if M67 = 'S' then 
			
				select c12 into monto from keplersc.kdinm where c1=sucursal_id and c5=genero
				and c6=naturaleza and c7=grupo and c8=tipo and c9=folio_operacion and c10=partida;
				if not found then
				
					monto := importe;
				
				end if;

			end if;		
		--cfdi no cálculos
			iva_cte := 0; total_cte := 0;
			iva_cte := importe * (iva_default/100);
			total_cte := importe + iva_cte;
		--En el insert c21,c22			
			insert into keplersc.kdref (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,
			c16,c17,c18,c19,c20,c21,c22) values(sucursal_id,tipo_orden, orden,Codigo_requisicion,genero,
			naturaleza,grupo,tipo,folio_operacion,partida,producto,descr,cantidad,unidad,unitario,
			importe,0.00,'I',monto,to_date(fecha_mov,'YYYY-MM-DD'),iva_cte,total_cte);
		
		end loop;

		--MSS 080824 
		--Registro en bitacora precio menor al calculado
		strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
		usuario := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
		no_partidas := strValor::integer;	
		operacion = 'AUT PRECIO';
		for cont in 0..no_partidas - 1 loop
			deccantidad_partida := 0;
			
			cantidad_unidades := coalesce((xpath('//document/k_mov/r'||cont||'/k_q/text()',dataxml))[1],
									  (xpath('//document/k_mov/r'||cont||'/k_Q/text()',dataxml))[1]);
			deccantidad_partida := cantidad_unidades::decimal;
			importe_partida := (xpath('//document/k_mov/r' ||cont||'/k_monto/text()',dataxml))[1];
			parte := (xpath('//document/k_mov/r'||cont||'/k_parte/text()',dataxml))[1];
			autorizado := (xpath('//document/k_mov/r'||cont||'/k_autoriza/text()',dataxml))[1];
			precio_ini := (xpath('//document/k_mov/r'||cont||'/k_precio_ini/text()',dataxml))[1];
			precio := (xpath('//document/k_mov/r'||cont||'/k_precio/text()',dataxml))[1];
			if deccantidad_partida > 0 or importe_partida::decimal > 0 then	
				if autorizado = '1' then
					strBitacora = 'AUTORIZACION PRECIO MENOR ORDEN: ' || tipo_orden || '-' || orden || ' REFACC: ' || parte || ' P.CALC: ' || precio_ini || ' P.AUT: ' || precio;
					fecha_movto :=  current_date::text;
					hora_movto := left(current_time::text, 8);
					select xmlforest(usuario, fecha_movto as fecha, hora_movto as hora,sucursal_id as sucursal, genero, naturaleza, 
									grupo, tipo, folio_operacion as folio,
									'AUT PRECIO' as tipo_movto, strBitacora as detalle_movto) :: text into strValor;		
									select '<document>'||strValor||'</document>' into strValor;
					xmlUsr := strValor::xml;
					--raise notice 'Bitacora:%',xmlUsr;
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;	
				
				end if;
			end if;
		end loop;
		--MSS 30122025 Registro en bitacora movimientos con cambios en las refacciones del paquete	
		if mod_refacc_paquete = 'S' then
			strBitacora = tipo_mod_paquete || ' ' ||' EN PAQUETE MODIFICADAS DE LA ORDEN: ' || tipo_orden || '-' || orden;
			fecha_movto :=  current_date::text;
			hora_movto := left(current_time::text, 8);
			select xmlforest(usuario, fecha_movto as fecha, hora_movto as hora,sucursal_id as sucursal, genero, naturaleza, 
							grupo, tipo, folio_operacion as folio,
							'MODIF REFACC PAQ' as tipo_movto, strBitacora as detalle_movto) :: text into strValor;		
			select '<document>'||strValor||'</document>' into strValor;
			xmlUsr := strValor::xml;
			--raise notice 'Bitacora:%',xmlUsr;
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;	
			
		end if;
	end if;

	resultado := 1;
	mensaje := 'Guardado: ' || folio_operacion;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
	
		mensaje := 'carga_refacciones_insert() ' || '['|| sqlstate || '] ' || sqlerrm ;		

		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
