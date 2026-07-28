CREATE OR REPLACE FUNCTION keplersc.verify_cxcp_baja(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare 
--Descripcion: Realiza validacion de cxcp para una baja
--Autor: Miriam Santana
--Fecha: 22/08/2022
--Bitacora de cambios
--13/05/2024 Miriam Santana: Validaciones para baja de contrarecibo con manejo de schema(tag)

	--Variables de definicion de documento
	no_partidas int = 0;
	clave_producto text = '';
	sucursal_id text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo_clave text = '';
	fecha_operacion text = '';
	referencia text = '';
	clave_cteprov text = '';
	monto_total text = '';
	folio text = '';
	flag_gastos text = '';
	
	--Variables de uso general
	cargos decimal;
	abonos decimal;
   	var_monto decimal;
 	strValor text = '';
 	st_comprobar text = '';

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
	monto_total := (xpath('//document/k_monto/text()', dataxml))[1];
	referencia := (xpath('//document/k_refer/text()', dataxml))[1];
	clave_cteprov := (xpath('//document/k_clave/text()', dataxml))[1];
	folio := (xpath('//document/k_folio/text()', dataxml))[1]; 

	if genero = 'X' and naturaleza = 'A' then
		flag_gastos = '';
		if xpath_exists('//document/ambiente/schema/text()', dataxml) = true then 
			flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
		end if;
		if upper(flag_gastos) = 'CXP_CONTR_REC' then
			select st_x_comprobar into st_comprobar from keplersc.kdm1
				where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo_clave::integer and c6=folio;
			if upper(st_comprobar) = 'X' then
				raise exception 'No puede dar de baja un Contrarecibo que ya ha sido comprobado';
			end if;
		end if;	
		select c6,c7 into cargos, abonos from keplersc.kduxg k
			where c1=sucursal_id and c2=genero and c3=clave_cteprov and c4=referencia and C5=1;
		var_monto := abonos - cargos - monto_total::decimal;
		if var_monto < 0 then
			raise exception 'No puede dar de baja una cuenta por Pagar que ya tiene movimientos de Cargo';
		end if;
		
	end if;
	
	--TO DO: Tomar el dato B8303="SR" de IF M1="U" AND M2="D" AND B8303="SR" en K75
	if genero = 'U' and naturaleza = 'D' and strValor ='SR' then
		select c6,c7 into cargos, abonos from keplersc.kduxg k
			where c1=sucursal_id and c2=genero and c3=clave_cteprov and c4=referencia and C5=1;
		var_monto := cargos - abonos - monto_total::decimal;
		if var_monto < 0 then
			raise exception 'No puede dar de baja una cuenta por Cobrar que ya tiene movimientos de Abono';
		end if;
		
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	--*/

	return query select resultado, mensaje, adicionales;


exception
	when others then
		resultado := '0';
		mensaje := 'verify_cxcp_baja() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;

	
end;
$function$
