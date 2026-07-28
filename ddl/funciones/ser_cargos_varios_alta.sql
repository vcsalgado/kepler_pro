CREATE OR REPLACE FUNCTION keplersc.ser_cargos_varios_alta(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Realiza inserción de cargos varios en KDCAR
--Autor: Miriam Santana
--Fecha: 09/08/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text;
	fecha_operacion text; --yyyy-mm-dd
	tipo_orden text;
	num_orden text;
	punto text;
	cargo text;
	descripcion text;
	precio decimal = 0.00;
	numero_partida int = 0;
	decprecio_partida decimal = 0.00;
	tipo_operacion text;
	strValor text;
	strPrecio text;
	strPartidas text;
	no_partidas int;

	iva_cte decimal = 0.00;		--cfdi no calculos
	total_cte decimal = 0.00;	--cfdi no calculos
	iva_default decimal = 0.00; --cfdi no calculos
begin
	sucursal_id := (xpath('//document/k_sucursal/text()', dataxml))[1];

	--Tipo operacion
	tipo_operacion := (xpath('//document/operacion/text()', dataxml))[1];
	
	--Partidas
	strPartidas := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strPartidas::integer;
	
	tipo_orden := (xpath('//document/k_tipo/text()',dataxml))[1];
	num_orden := (xpath('//document/k_folio/text()',dataxml))[1];
	punto := (xpath('//document/k_punto_rel/text()',dataxml))[1];		--Num de punto que corresponden los datos a grabar
	
	--Obtiene %Iva
	select c11 into iva_default from keplersc.kdmargen where c1=tipo_orden;
	--Elimina registros de KDCAR
	delete from keplersc.kdcar
		where c1=sucursal_id and c2=tipo_orden and c3=num_orden and c4 = punto::integer;
			
	--Procesar alta detalle de cargos varios a KDCAR
	for cont in 0..no_partidas - 1 loop
		decprecio_partida := 0;
		cargo := (xpath('//document/k_mov/r'||cont||'/k_cve_cargo/text()',dataxml))[1];
		descripcion := (xpath('//document/k_mov/r'||cont||'/k_descripcion/text()',dataxml))[1];
		strPrecio := coalesce((xpath('//document/k_mov/r'||cont||'/k_importe/text()',dataxml))[1]::text,'0')::text;
		precio := strPrecio::decimal; 
		decprecio_partida := precio;
		--Sólo realiza la inserción si tiene precio la partida
		if decprecio_partida > 0 then		
			numero_partida := numero_partida + 1;
			--cfdi no cálculos
			iva_cte := 0; total_cte := 0;
			iva_cte := precio * (iva_default/100);
			total_cte := precio + iva_cte;
			--En el insert c11 y c12
			insert into keplersc.kdcar
				(c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12)
				values(sucursal_id,tipo_orden,num_orden,punto::integer,numero_partida,
				cargo,descripcion,0,0,precio,
				iva_cte,total_cte);
	
		end if;
	end loop;	
		
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_cargos_varios_alta() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
		
end;
$function$
