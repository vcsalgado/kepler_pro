CREATE OR REPLACE FUNCTION keplersc.configurapresupuesto_alta(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Registra los importe de presupuestos por concepto
--Autor: Miriam Santana
--Fecha: 17/07/2024
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';	--col_sucursal
	stranio text='';
	strmes text='';
	limite_ppto text='';
	clave text='';
	importe_ppto text='';
	ppto_inicial text='';
	importe_gast  text='';
	total_ppto  text='';
	operacion text = '';
	usuario text = '';

	--Variables Loop
	no_partidas int;
	numero_partida int;
	
	--Variables de uso general
	strValor text;	
	xmlUsr xml;
	strBitacora text;
	fecha_movto text;
	hora_movto text;
	valReg decimal;

    --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
   	get_resultado text;
	get_mensaje text; 
	get_adicionales text;
	
begin 
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	stranio := (xpath('//document/k_anio/r0/text()', dataxml))[1];
	strmes := (xpath('//document/k_mes/r0/text()', dataxml))[1];
	limite_ppto := (xpath('//document/lim_presupuesto/text()', dataxml))[1];
	total_ppto := (xpath('//document/tot_presupuesto/text()', dataxml))[1];
	operacion := (xpath('//document/operacion/text()', dataxml))[1];
	usuario := (xpath('//document/movimiento/usuario/text()', dataxml))[1];
	
	--Validacion de datos minimos
	if limite_ppto::decimal = 0 then
		raise exception 'Falta Limite de presupuesto mensual, no puede ser 0';
	else
		select valor into valReg from keplersc.param_oper_periodo
			where sucursal=sucursal_id and anio=stranio and mes=strmes and lower(parametro)='limite presupuesto';
		if not found then
			raise exception 'Falta Limite de presupuesto mensual en tbl-param_oper_periodo';
		else
			if limite_ppto::decimal <> valReg then
				raise exception 'El Limite de presupuesto mensual de tbl-param_oper_periodo no corresponde al capturado en la pantalla. Registrelo nuevamente';
			end if;
		end if;
	end if;
	if limite_ppto::decimal - total_ppto::decimal < 0 then
		raise exception 'El Total de presupuesto rebasa Limite de presupuesto mensual';
	end if;
	--Partidas
	strValor := (xpath('//document/results/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	
	
	if no_partidas > 1 then
		--Procesar detalle
		for cont in 0..no_partidas - 1 loop
			--Tipo de documento
			clave := (xpath('//document/results/r' ||cont||'/clave/text()',dataxml))[1];
			importe_ppto := (xpath('//document/results/r' ||cont||'/imp_presupuesto/text()',dataxml))[1];
			ppto_inicial := (xpath('//document/results/r' ||cont||'/Ppto_ini/text()',dataxml))[1];
			importe_gast := (xpath('//document/results/r' ||cont||'/imp_gastado/text()',dataxml))[1];
			
			--Validaciones por partida
			if importe_ppto::decimal > 0 then
				if importe_ppto::decimal < importe_gast::decimal then
					raise exception 'El Importe presupuesto no puede ser menor al Importe gastado en la clave %',clave;
				end if;
					
				delete from keplersc.kdpresupuestos where sucursal =sucursal_id and anio=stranio and mes=strmes and cve_concepto =clave;
				
				insert into keplersc.kdpresupuestos (sucursal,anio,mes,cve_concepto,importe)
					values(sucursal_id,stranio,strmes,clave,importe_ppto::decimal);		
			else 
				if importe_ppto::decimal < 0 then
					raise exception 'El Importe presupuesto no puede ser menor a 0 en la clave %',clave;
				end if;
			end if;
		end loop ;	
	
		--Registro del movimiento en bitacora
		fecha_movto :=  current_date::text;
		hora_movto := left(current_time::text, 8);
		strBitacora := 'PRESUPUESTO A�O: '||stranio||' MES: '||strmes;
		select xmlforest(usuario, fecha_movto as fecha, hora_movto as hora,sucursal_id as sucursal, ' ' as genero, ' ' as naturaleza, 
						0 as grupo, 0 as tipo, 'PPTO' as folio,
						operacion as tipo_movto, strBitacora as detalle_movto) :: text into strValor;		
						select '<document>'||strValor||'</document>' into strValor;
		xmlUsr := strValor::xml;
		--raise notice 'Bitacora:%',xmlUsr;
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;	
	else
		raise exception 'No hay detalle de presupuesto. Verifique';
	end if;
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'configurapresupuesto_alta() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
