CREATE OR REPLACE FUNCTION keplersc.alta_doc_sec(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserción de movimientos en KDM5
--Autor: Luis Leal
--Fecha: 18/10/22
declare
	--Variables de definicion de documento
	sucursal_desc text;
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text; 
	tipo_clave text;

	--Variables Loop
	no_partidas int;
	numero_partida int;
	factura text;
	num_docto text;
	monto text;
	iva text;
	vence text;

	--Variables de uso general 
	strValor text;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;


begin
	sucursal_desc := (xpath('//document/k_sucn/r0/text()', dataxml))[1];
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];

	--Tipo de documento
	tipo_desc := (xpath('//document/k_tipon/r0/text()', dataxml))[1]; 
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	

	numero_partida := 0;

	for cont in 0..no_partidas - 1 loop
		
		factura := (xpath('//document/k_mov/r' ||cont||'/k_factura/text()',dataxml))[1];

		if factura <> '' or factura is not null then
			numero_partida := numero_partida + 1;
		
			monto := (xpath('//document/k_mov/r' ||cont||'/k_monto_factura/text()',dataxml))[1];
			num_docto := coalesce((xpath('//document/k_mov/r' ||cont||'/k_documento/text()',dataxml))[1]::text,'1');
			iva := (xpath('//document/k_mov/r' ||cont||'/k_iva_factura/text()',dataxml))[1];
			vence := coalesce((xpath('//document/k_mov/r' ||cont||'/k_vencimiento_factura/text()',dataxml))[1]::text,'1990-01-01')::text;

			insert into keplersc.kdm5 (c1,c2,c3,c4,c5,c6,c7,c11,c12,c13,c14, c15, c16)
			values(sucursal_id,genero,naturaleza,grupo::integer,tipo_clave::integer,
				folio_operacion,numero_partida,'1', monto::numeric,iva::numeric,factura, vence::date, num_docto::numeric);
		end if;	
	end loop ;	
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_doc_sec() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
