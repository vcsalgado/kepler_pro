CREATE OR REPLACE FUNCTION keplersc.gastos_baja_compra(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: da de baja compra
--Autor: Luis Leal
--Fecha: 23/02/23
declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text; 
	tipo_clave text;

	--mov orden de compra--
 	genero_ocompra text;
 	naturaleza_ocompra text;
 	grupo_ocompra text;
 	tipo_clave_ocompra text;
	--loop--
	folio_compra text;
	partida_compra text;

	--Variables de uso general 
	numero_partida int;
	strValor text;
	no_partidas int;

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
	
	for genero_ocompra, naturaleza_ocompra, grupo_ocompra,
	tipo_clave_ocompra,folio_compra, partida_compra in select c8,c9,c10,c11,c12,c13 
	from keplersc.kdgcompradet 
	where c1=sucursal_id and c2=genero and c3=naturaleza
	and c4=grupo::int and c5=tipo_clave::int and c6=folio_operacion
	loop
		
		update keplersc.kdgocompradet set c11=0 where c1=sucursal_id
		and c2=genero_ocompra and c3=naturaleza_ocompra and c4=grupo_ocompra::int
		and c5=tipo_clave_ocompra::int and c6=folio_compra and c7=partida_compra::int;
		
	end loop;
	
	delete from keplersc.kdgcompradet where c1=sucursal_id and c2=genero and c3=naturaleza
	and c4=grupo::int and c5=tipo_clave::int and c6=folio_operacion;


	delete from keplersc.kdgcompra where c1=sucursal_id and c2=genero and c3=naturaleza
	and c4=grupo::int and c5=tipo_clave::int and c6=folio_operacion;

	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'gastos_baja_compra() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
