CREATE OR REPLACE FUNCTION keplersc.alta_cont_sec(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserción de movimientos contables en KDM6
--Autor: Luis Leal
--Fecha: 07/10/22
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
	clave_cuenta text;
	descr_cuenta text;
	cargo text;
	abono text;	
	monto numeric = 0;
	cargo_abono text;
	inventario text;

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
		
			clave_cuenta := coalesce((xpath('//document/k_mov/r' ||cont||'/k_cuenta/text()',dataxml))[1], '');
			if clave_cuenta = '' then
				continue;
			end if;
			numero_partida := numero_partida + 1;
			descr_cuenta := (xpath('//document/k_mov/r' ||cont||'/k_cuentadesc/text()',dataxml))[1];
			cargo := (xpath('//document/k_mov/r' ||cont||'/k_cargo/text()',dataxml))[1];
			abono := (xpath('//document/k_mov/r' ||cont||'/k_abono/text()',dataxml))[1];		
			inventario := coalesce((xpath('//document/k_mov/r' ||cont||'/k_inventario/text()',dataxml))[1],'');	

			if cargo <> '' then
				monto := cargo::numeric;
				cargo_abono:= 'C';
			else
				monto := abono::numeric;
				cargo_abono:= 'A';
			end if;
		
			insert into keplersc.kdm6 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c13)
			values(sucursal_id,genero,naturaleza,grupo::integer,tipo_clave::integer,
				folio_operacion,numero_partida, clave_cuenta, descr_cuenta, cargo_abono, monto, inventario);
			
	end loop ;	
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_cont_sec() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
