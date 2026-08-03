CREATE OR REPLACE FUNCTION keplersc.configuractasppto(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud de los rangos de cuentas de presupuesto en la tabla CAT_CTAS_PPTO
--Autor: Miriam Santana
--Fecha: 15/08/2024
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';	--col_sucursal
	stranio text='';
	
	rango_inicial text='';
	rango_final text='';
	
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
	operacion := (xpath('//document/operacion/text()', dataxml))[1];
	usuario := (xpath('//document/movimiento/usuario/text()', dataxml))[1];
	
	--Partidas
	strValor := (xpath('//document/results/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	
raise notice 'aqui 1';	
	if no_partidas > 1 then
		--Procesar detalle
		delete from keplersc.cat_ctas_ppto where sucursal =sucursal_id and anio=stranio;
		for cont in 0..no_partidas - 1 loop
			--Tipo de documento
			rango_inicial := coalesce((xpath('//document/results/r' ||cont||'/rango_ini/text()',dataxml))[1],'');
			rango_final := coalesce((xpath('//document/results/r' ||cont||'/rango_fin/text()',dataxml))[1],'');	
			--Validaciones por partida
			if rango_inicial <> '' and rango_final <> '' then
	/*
				if rango_inicial = '' then
					raise exception 'El rango inicial no puede estar en blanco. Verifique';
				end if;
				if rango_final = '' then
					raise exception 'El rango final no puede estar en blanco. Verifique';
				end if;
	*/			
raise notice 'aqui 2';			
									
				insert into keplersc.cat_ctas_ppto (sucursal,anio,rango_ini,rango_fin)
					values(sucursal_id,stranio,rango_inicial,rango_final);		
raise notice 'aqui 3';
			end if;
		end loop ;	
	
		--Registro del movimiento en bitacora
		fecha_movto :=  current_date::text;
		hora_movto := left(current_time::text, 8);
		strBitacora := 'REGISTRO RANGOS CTAS PRESUPUESTO A�O: '||stranio;
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
		raise exception 'No hay rangos de cuentas por registrar. Verifique';
	end if;
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'configuractasppto() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
