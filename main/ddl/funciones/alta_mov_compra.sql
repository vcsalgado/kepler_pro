CREATE OR REPLACE FUNCTION keplersc.alta_mov_compra(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserción de conceptos de compras en KDM6
--Autor: Luis Leal
--Fecha: 20/02/23
declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text; 
	tipo_clave text;

	--Variables Loop
	folio_compra text;
	partida_compra text;
	clave_gasto text;
	desc_gasto text;
	monto_gasto text;

	--Variables de uso general 
	numero_partida int;
	strValor text;
	no_partidas int;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	--Resuelve k75 ALTA_MOV_COMPRA
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];

	--Tipo de documento
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	

	numero_partida := 0;

	for cont in 0..no_partidas - 1 loop
		
		folio_compra := coalesce((xpath('//document/k_mov/r' ||cont||'/k_folio_compra/text()',dataxml))[1], '');
		partida_compra := coalesce((xpath('//document/k_mov/r' ||cont||'/k_partida_compra/text()',dataxml))[1], '');
		clave_gasto := coalesce((xpath('//document/k_mov/r' ||cont||'/k_clave_gasto/text()',dataxml))[1], '');
		desc_gasto := coalesce((xpath('//document/k_mov/r' ||cont||'/k_desc_gasto/text()',dataxml))[1], '');
		monto_gasto := coalesce((xpath('//document/k_mov/r' ||cont||'/k_monto_gasto/text()',dataxml))[1], '');
	
		numero_partida := numero_partida + 1;

		if folio_compra = '' or partida_compra = '' or 
		clave_gasto = '' or desc_gasto = '' or monto_gasto = '' then
			raise exception 'Faltan datos para la partida numero: %' , numero_partida;
		end if;
		
		insert into keplersc.kdm6 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13)
		values(sucursal_id,genero,naturaleza,grupo::integer,tipo_clave::integer,
		folio_operacion,numero_partida,clave_gasto, desc_gasto , 'C', 
		monto_gasto::numeric, folio_compra, partida_compra);
			
	end loop ;	
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_mov_compra() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
