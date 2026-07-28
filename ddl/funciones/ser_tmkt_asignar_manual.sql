CREATE OR REPLACE FUNCTION keplersc.ser_tmkt_asignar_manual(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Asigna los contactos de acuerdo a la configuración del factor cantidad, porcentaje o balanceado
--Autor: Miriam Santana
--Fecha: 24/08/2023
--Bitacora de cambios
declare 
	--Variables de definicion de documento
	sucursal_id text = '';
	sel_contacto  text = '';
	folio_tmkt  text = '';
	asesor_nuevo text = '';
	accion text = '';
	
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
	--No registros contactos
	strValor := (xpath('//document/tbl_paso/no_partidas/text()',dataxml))[1];
	no_rengContactos := strValor::integer;	
	--No registros seleccionados
	strValor := (xpath('//document/inp_contactos_sel/text()',dataxml))[1];
	no_regSeleccionados := strValor::integer;
	accion := (xpath('//document/cmb_accion/r1/text()',dataxml))[1];
	
	if no_regSeleccionados > 0 then
		if accion = 'R' then		--Reasignar
			for cont in 0..no_rengContactos - 1 loop
				sel_contacto := (xpath('//document/tbl_paso/r' ||cont||'/Sel/text()',dataxml))[1];
				if sel_contacto = 'S' then
					folio_tmkt := (xpath('//document/tbl_paso/r' ||cont||'/folio_tmkt/text()',dataxml))[1];
					asesor_nuevo := (xpath('//document/tbl_paso/r' ||cont||'/asesor_nuevo/text()',dataxml))[1];
				--raise exception 'suc:% , folio:%',sucursal_id,folio_tmkt;
					update keplersc.kdtmktser2 
						set c3=asesor_nuevo
					where c1=sucursal_id and c2=folio_tmkt;
				end if;
			end loop;	
		end if;
		if accion = 'D' then		--Desasignar
			for cont in 0..no_rengContactos - 1 loop
				sel_contacto := (xpath('//document/tbl_paso/r' ||cont||'/Sel/text()',dataxml))[1];
				folio_tmkt := (xpath('//document/tbl_paso/r' ||cont||'/folio_tmkt/text()',dataxml))[1];
				if sel_contacto = 'S' then
					update keplersc.kdtmktser2 
						set c3='SA'
					where c1=sucursal_id and c2=folio_tmkt;
				end if;
			end loop;	
		end if;
	else
		raise exception 'No hay seleccion de contactos';
	end if;
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_tmkt_asignar_manual() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
