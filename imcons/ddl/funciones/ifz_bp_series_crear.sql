CREATE OR REPLACE FUNCTION keplersc.ifz_bp_series_crear(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: crea series nuevas enviadas desde los webhooks de business pro ( BP or BPR )
--Autor: Jose Mendoza
--Fecha: 2025-05-23 
--Bitacora de cambios

declare

	clave_cliente text;
	vin text;
	serie text;
	placas text;
	marca text;
	modelo text;
	anio text;
	kms text;
	origen text;

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

	vin := coalesce((xpath('//document/vin/text()', dataxml))[1]::text,'')::text; 
	serie := coalesce((xpath('//document/serie/text()', dataxml))[1]::text,'')::text; 
 	marca := (xpath('//document/marca/text()', dataxml))[1];
	modelo := (xpath('//document/modelo/text()', dataxml))[1];
	anio := coalesce((xpath('//document/anio/text()', dataxml))[1]::text,'')::text; 
	clave_cliente := (xpath('//document/cliente_id/text()', dataxml))[1]; 
	placas := coalesce((xpath('//document/placas/text()', dataxml))[1]::text,'')::text;
	kms := coalesce((xpath('//document/kms/text()', dataxml))[1]::text,'0.00')::text; 
	origen := coalesce((xpath('//document/origen/text()', dataxml))[1]::text,'')::text;

	select count(*) into totReg from keplersc.kdserie where c4 = Serie;

	if totReg > 0 then
	
		raise exception 'No es posible realizar el Alta. La Serie ya existe ...';
	
	else
	
		insert into keplersc.kdserie(c1, c2, c3, c4, c8, c9, c11, c12, origen)
		values(vin, marca, modelo, serie, placas, clave_cliente, anio, kms::numeric, origen);
		
	end if;

	resultado := 1;
	mensaje := 'Serie Agregada :' || serie;
	adicionales := '';

	return query select resultado, mensaje, adicionales;	

exception
	when others then

		resultado := 0;
		mensaje := 'ifz_bp_series() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';

		return query select resultado, mensaje, adicionales;	
	
end;
$function$
