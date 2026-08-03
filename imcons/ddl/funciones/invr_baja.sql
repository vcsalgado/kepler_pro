CREATE OR REPLACE FUNCTION keplersc.invr_baja(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: baja inventario refacciones
--Autor: Luis Leal
--Fecha: 26/07/2023
--Bitacora de cambios
				  
declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_clave text;
	producto text;
	partida numeric;
	cantidad numeric;
	monto numeric;
	strValor text;
	xmlCadena xml;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	
begin
	
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	--Tipo de documento
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];


	for producto,partida, cantidad, monto in select c2,c10,c11,c12 from keplersc.kdinm where c1=sucursal_id 
	and c5=genero and c6=naturaleza and c7=grupo::numeric and c8=tipo_clave::numeric and c9=folio_operacion
	loop 
		
		insert into keplersc.kdinm(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) 
		values(sucursal_id, producto, current_date,left(current_time::text, 5), genero, naturaleza,
		grupo::numeric, tipo_clave::numeric, folio_operacion, partida, cantidad * -1, monto * -1, 0);
	
		--Registro de estadisticas
		select xmlforest(sucursal_id as sucursal, genero as genero, naturaleza as naturaleza,
		grupo as grupo, tipo_clave as tipo_clave,
		producto as clave_producto, current_date as fecha, 'S' as entradaSalida,
		monto::text as monto, cantidad as cantidad):: text into strValor;
				
		select '<document>'||strValor||'</document>' into strValor;
		xmlCadena := strValor::xml;
	
		select * into resultado, mensaje, adicionales from keplersc.invr_estadis_alta(xmlCadena);
		if resultado = '0' then
			raise exception '%',mensaje;
		end if;	
		
	end loop;


	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'invr_baja() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
