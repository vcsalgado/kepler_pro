CREATE OR REPLACE FUNCTION keplersc.cxcp_kduxe_baja(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Realiza baja de Cuentas por Cobara y/o Pagar en kduxe
--Autor: Miriam Santana
--Fecha: 22/08/2022
--Bitacora de cambios
-- Fecha : 20240517 , JMM
-- Actualizada para los Contrarecibos del Nuevo SCH de Gastos


	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_clave text;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	strValor text;
	intValor int;
	totalReg int;

	-- Added by JMM 20240517 
	flag_contrarec text = '';

begin
	--Valores de XML
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	-- Added by JMM 20240517	
	flag_contrarec = '';
	if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
		flag_contrarec := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
	end if;
		
	if upper(flag_contrarec) = 'CXP_CONTR_REC' then  /*Condition Added by JMM 20240517*/
	
		-- No Borrara XDUXE para los Contrarecibos 
		-- For Testing 
		/*raise exception '%','Es Contrarecibo ...';*/
		
		-- Al Final se esta verificando si se borraran registros ...
		update keplersc.kduxe 
			set fecha_rollback = current_date,
				monto_rollback = c13, 
				iva_rollback = c14,
				c13 = 0, c14 = 0
			where c1 = sucursal_id and c5 = genero and c6 = naturaleza and c7 = grupo::int and c8 = tipo_clave::int
				and c9 = folio_operacion;
	
	else

		-- CODIGO ORIGINAL ... 20240517 
		--Resuelve K75:BAJA_CXCP que es una baja de una CXCP_ALTA_SINMOV y CXCP_ALTA_CONMOV
		delete from keplersc.kduxe 
			where c1=sucursal_id and c5=genero and c6=naturaleza and c7=grupo::integer and c8=tipo_clave::integer and c9=folio_operacion::text;
		
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cxcp_kduxe_baja() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
