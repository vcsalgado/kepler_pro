CREATE OR REPLACE FUNCTION keplersc.cfd_valid_pedimento(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado_valid_pedimento text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: cfd_valid_pedimento
--Autor: Luis Leal
--Fecha: 13/12/2021
--Bitacora de cambios
declare
	no_partidas int;
	numero_partida text;
	sucursal_id text;
	clave_producto text;
	c65 text;
	c88 text;
	pedimento_producto text;

	año_operacion text;
	aduana text;
	patente_aduanal text;
	folio_pedimento text;
	c4_folio_pedi text;
	resultado_valid_pedimento text;
	strValor text;


begin
	
	resultado_valid_pedimento = '0';

	c65 := xpath('//row/c65/text()', xmlKDMM);
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];

	c88 := xpath('//row/c65/text()', xmlKDMM);

	if c88='V' and c65 = '30' or c65 = '80' then
	
		strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
		no_partidas := strValor::integer;	
		--Procesar detalle de partidas a kdm2 (ALTA_MOV_SEC)
		for cont in 0..no_partidas - 1 loop
	
			clave_producto := (xpath('//document/k_mov/r' ||cont||'/k_parte/text()',dataxml))[1];
			select c26 into pedimento_producto from keplersc.kdinf where c1=sucursal_id and c2=clave_producto;
	
			año_operacion := substring(pedimento_producto, 1, 2);
			aduana := substring(pedimento_producto, 3, 2);
			patente_aduanal := substring(pedimento_producto, 5, 4);
			folio_pedimento := substring(pedimento_producto, 10, 6);
			
			if año_operacion_y_aduana <> '' then
				select c4 into c4_folio_pedi from keplersc.kdf3pedi where c7 = año_operacion and c1 = aduana and c2 = patente_aduanal order by timestamp desc limit 1;
				if not found or folio_pedimento::numeric > c4_folio_pedi::numeric then
					raise exception 'El pedimento del Vehiculo es Invalido';
				end if;
			end if;
			
		end loop;	
	end if;


	resultado_valid_pedimento = '1';
	return query select resultado_valid_pedimento;	

end;

$function$
