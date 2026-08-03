CREATE OR REPLACE FUNCTION keplersc.ser_tmkt_reasigna_serie_asesor(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Reasignar los contactos de una serie a otro asesor
--Autor: Miriam Santana
--Fecha: 12/09/2023
--Bitacora de cambios
declare 
	--Variables de definicion de documento
	sucursal_id text = '';
	folio_tmkt  text = '';
	asesor_nuevo text = '';
	
	--Variables de proceso
	error text = '';
	totReg int = 0;
	sqlExp text = '';

	strAsesores text ='';
	strValor text;
	no_rengContactos int=0;
	no_regSeleccionados int=0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	asesor_nuevo := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
	--No registros contactos
	strValor := (xpath('//document/tbl_asignados/no_partidas/text()',dataxml))[1];
	no_rengContactos := strValor::integer;	
	
	if no_rengContactos > 0 then
		for cont in 0..no_rengContactos - 1 loop
			folio_tmkt := (xpath('//document/tbl_asignados/r' ||cont||'/folio_tmkt/text()',dataxml))[1];
			if folio_tmkt <> '' then
				--raise notice 'suc:% , folio:%, asesor_nuevo:%',sucursal_id,folio_tmkt,asesor_nuevo;
				--Actualiza folios pendientes y generados de forma automática
				update keplersc.kdtmktser2 
					set c3=asesor_nuevo
				where c1=sucursal_id and c2=folio_tmkt and c23=0 and c8=0 and c25='A';
				
			end if;
		end loop;	
	end if;
	
	resultado := '1';
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := '0';
		mensaje := 'ser_tmkt_reasigna_serie_asesor() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
