CREATE OR REPLACE FUNCTION keplersc.gastos_alta_compra(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: guarda compra
--Autor: Luis Leal
--Fecha: 23/02/23
declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text; 
	tipo_clave text;
	referencia text = '';
	nombre_prov text = '';

	--mov orden de compra--
 	genero_ocompra text;
 	naturaleza_ocompra text;
 	grupo_ocompra text;
 	tipo_clave_ocompra text;

	--montos--
	iva text;
	retencion_iva text;
	retencion_isr text;
	monto text;

	--loop--
	folio_compra text;
	partida_compra text;
	ctd_orden_compra int;

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
	referencia := (xpath('//document/k_refer/text()', dataxml))[1];
	nombre_prov := (xpath('//document/k_clave/text()', dataxml))[1];

	iva := coalesce((xpath('//document/k_iva/text()', dataxml))[1]::text,'0.00')::text; 
	retencion_iva := coalesce((xpath('//document/k_retencion_iva/text()', dataxml))[1]::text,'0.00')::text; 
	retencion_isr := coalesce((xpath('//document/k_retencion_isr/text()', dataxml))[1]::text,'0.00')::text; 
	monto := coalesce((xpath('//document/k_monto/text()', dataxml))[1]::text,'0.00')::text; 

	select c2,c3,c4,c5 into genero_ocompra, naturaleza_ocompra, 
	grupo_ocompra, tipo_clave_ocompra from keplersc.kdgconf;

	insert into keplersc.kdgcompra (c1,c2,c3,c4,c5,c6,c7,c8,c9, c10, c11, c12,c13)
	values(sucursal_id,genero,naturaleza,grupo::int,tipo_clave::int,folio_operacion,
	referencia,nombre_prov,  iva::numeric,retencion_iva::numeric, retencion_isr::numeric, monto::numeric, 0);

	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	

	numero_partida := 0;

	for cont in 0..no_partidas - 1 loop
		
		folio_compra := coalesce((xpath('//document/k_mov/r' ||cont||'/k_folio_compra/text()',dataxml))[1], '');
		partida_compra := coalesce((xpath('//document/k_mov/r' ||cont||'/k_partida_compra/text()',dataxml))[1], '');
			
		select count(*) into ctd_orden_compra from keplersc.kdgocompradet where c1=sucursal_id
		and c2=genero_ocompra and c3=naturaleza_ocompra and c4=grupo_ocompra::int
		and c5=tipo_clave_ocompra::int and c6=folio_compra and c7=partida_compra::int;
		
		if ctd_orden_compra > 0 then
		
			insert into keplersc.kdgcompradet (c1,c2,c3,c4,c5,c6,c7, c8,c9, c10,c11,c12,c13)
			values(sucursal_id,genero,naturaleza,grupo::int,tipo_clave::int,folio_operacion,cont + 1,
			genero_ocompra, naturaleza_ocompra, grupo_ocompra::int, tipo_clave_ocompra::int, folio_compra, partida_compra::int);
		
			update keplersc.kdgocompradet set c11=10 where c1=sucursal_id
			and c2=genero_ocompra and c3=naturaleza_ocompra and c4=grupo_ocompra::int
			and c5=tipo_clave_ocompra::int and c6=folio_compra and c7=partida_compra::int;
		
		else
			raise exception 'Orden de compra con Folio: % y Partida: % no encontrada' , folio_compra, partida_compra;
		end if;
		
	end loop ;	
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'gastos_alta_compra() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
