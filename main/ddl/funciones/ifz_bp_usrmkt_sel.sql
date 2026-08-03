CREATE OR REPLACE FUNCTION keplersc.ifz_bp_usrmkt_sel(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: crea series nuevas enviadas desde los webhooks de business pro ( BP or BPR )
--Autor: Jose Mendoza
--Fecha: 2025-05-23 
--Bitacora de cambios

declare

	clave text;
	sucursal text;

	get_resultado text;
	get_mensaje text; 
	get_adicionales text;

	expSql text;
	strValor text;
	valor text;
	totReg int;

	resultado text = '';
	mensaje text = '';
    adicionales text = '';
   
begin 

	clave := coalesce((xpath('//document/clave/text()', dataxml))[1]::text,'')::text; 
	sucursal := coalesce((xpath('//document/sucursal/text()', dataxml))[1]::text,'')::text; 

	select c3 into strValor from keplersc.kdsercattmkt where upper(c1) = upper(clave);

	if not found then
	
		raise exception 'El Usuario MKT no existe ...';
	
	else
	
		strValor = coalesce(strValor,'');
	
		if upper(strValor) <> 'A' then
			raise exception 'El Usuario MKT no esta activo ...';
		end if;

	end if;


	resultado := 1;
	mensaje := 'Usuario Validado :' || clave;
	adicionales := '';

	return query select resultado, mensaje, adicionales;	

exception
	when others then

		resultado := 0;
		mensaje := 'ifz_bp_usrmkt_sel() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';

		return query select resultado, mensaje, adicionales;	
	
end;
$function$
