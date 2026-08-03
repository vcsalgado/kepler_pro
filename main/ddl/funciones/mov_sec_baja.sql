CREATE OR REPLACE FUNCTION keplersc.mov_sec_baja(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Elimina partidas de documentos en KDM2
--Autor: Miriam Santana
--Fecha: 19/08/2022
--Bitacora de cambios
				  
declare
	--Variables de definicion de documento
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_compuesto text;
	tipo_clave text;
	
	--variables de uso general
	strValor text;
	intValor int;
	totalReg int;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	
begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];

	--Tipo de documento
	tipo_desc := (xpath('//document/k_tipon/r0/text()', dataxml))[1]; 
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	

	select count(*) into totalReg from keplersc.kdm2	
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer 
			and c5=tipo_clave::integer and c6=folio_operacion::text;
	if totalReg > 0 then	
		delete from keplersc.kdm2
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer 
			and c5=tipo_clave::integer and c6=folio_operacion::text;
		resultado := 1;
	
	else
			mensaje := 'No se encuentra el movimiento';
			resultado := 0;
	end if;

	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'mov_prim_baja() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
