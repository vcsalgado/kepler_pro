CREATE OR REPLACE FUNCTION keplersc.cat_cuentas_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de líneas KDIVL
--Autor: Victor Salgado
--Fecha: 16/03/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	anio text = '';
	clave text = '';
	descripcion text = '';
	tipo_movto text = '';
	saldo text = '';
	
	--Variables de de uso general
	nombre_tabla text = '';
	sqlExp text = '';
	strValor text = '';
	intValor int = 0;

   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin
	anio := (xpath('//document/k_anio/text()', dataxml))[1];
	clave := (xpath('//document/k_clave/text()', dataxml))[1];
	descripcion := coalesce((xpath('//document/k_descripcion/text()', dataxml))[1],'');
	saldo := coalesce((xpath('//document/k_saldo/text()', dataxml))[1],'');	
	tipo_movto := (xpath('//document/k_movto/text()', dataxml))[1];

	if tipo_movto <> 'ELIMINAR' then
		if anio is null then 
			raise exception 'No se proporcionó año de la cuenta.';
		end if;	
		if clave is null then 
			raise exception 'No se proporcionó la cuenta';
		end if;
		if descripcion is null then 
			raise exception 'No se proporcionó descripción de la cuenta';
		end if;
	end if; 

	nombre_tabla = concat('keplersc.kdc1',anio); 

	if tipo_movto = 'NUEVO' then
		--Validar que la cuenta no tenga un padre con movimientos
		intValor:= (select * from keplersc.verify_cuenta_movtos_padre(clave));
		if intValor > 0 then
			raise exception 'La cuenta % tiene % movimientos en alguna de las cuentas de las que depende.',clave,intValor::text;
		end if;
	
		--Validar que la cuenta no tenga hijos con movimientos	
		intValor:= (select * from keplersc.verify_cuenta_movtos_hijos(clave));
		if intValor > 0 then
			raise exception 'La cuenta % tiene % movimientos en alguna de las cuentas dependen de esta.',clave,intValor::text;
		end if;	
		
		--Validar que la cuenta no tenga hijos con saldos
		intValor:= (select * from keplersc.verify_cuenta_saldo_hijos(clave));
		if intValor > 0 then
			raise exception 'La cuenta % tiene % cuenta(s) dependiente(s) con saldo(s) inicial(es).',clave,intValor::text;
		end if;		

		sqlExp=format('insert into %1$s (c1,c2) values(%2$L,%3$L)',nombre_tabla,clave,descripcion);
		execute sqlExp;
	end if;

	if tipo_movto = 'MODIFICAR' then
		sqlExp=format('update %1$s set c2=%2$L where c1=%3$L',nombre_tabla,descripcion,clave);
		execute sqlExp;	
	end if;

	if tipo_movto = 'ELIMINAR' then
		--Validar que la cuenta no tenga movimientos
		strValor:=anio;
		select count(*) into intValor from keplersc.kdc2_view kdc2 where c3=clave and kdc2.anio=strValor;
		if intValor>0 then
			raise exception 'La cuenta % tiene % movimientos contables.',clave,intValor::text;		
		end if;
		sqlExp=format('delete from %1$s where c1=%2$L',nombre_tabla,clave);
		execute sqlExp;	
	end if;

	if tipo_movto = 'SALDO' then
		--Verificar que la cuenta es de ultimo nivel
		select * into resultado,mensaje,adicionales from keplersc.verify_cuenta_ult_nivel(clave,anio);
		intValor:= resultado::int;
		if intValor=0 then --no es de ultimo nivel
			raise exception 'La cuenta % no es de último nivel.',clave;
		end if;

		sqlExp=format('update %1$s set c%2$s = c%2$s + %3$s where position(c1 in %4$L) = 1
		returning 1::text ',nombre_tabla, '14', saldo, clave);	
		execute sqlExp into strValor;
		if strValor is null then
			raise exception 'No se acumularon saldos en las cuentas %.',cuenta ;
		end if;	
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_cuentas_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
