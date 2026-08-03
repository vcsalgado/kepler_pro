CREATE OR REPLACE FUNCTION keplersc.verify_bonificacion(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text)
 LANGUAGE plpgsql
AS $function$
declare 
--Descripcion: Realiza validacion de la alta de bonificacion.
--			   Resuelve VERIFY_BONIF
--Autor: Miriam Santana
--Fecha: 29/12/2022

	--Variables de definicion de documento
	sucursal_id text = '';
	uen text ='';
	cve_inventario text ='';
	monto text ='';
	strPartidas text;
	no_partidas int;
	estado_vta int;
	
	--varibales de uso general
	tipo_trabajo text;
	tipo_orden text;
	privilegios_conta text;
	
	resultado text;

begin
	resultado := 0;
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	uen := coalesce((xpath('//document/ambiente/uen/text()',dataxml))[1],'');
	--Partidas
	strPartidas := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strPartidas::integer;

	if uen='VEN' and ((xpath('//row/c66/text()', xmlKDMM))[1]::text = 'C' or (xpath('//row/c66/text()', xmlKDMM))[1]::text = 'V') then	
		for cont in 0..no_partidas - 1 loop		
			cve_inventario := (xpath('//document/k_mov/r'||cont||'/k_factura/text()',dataxml))[1];
			monto := (xpath('//document/k_mov/r'||cont||'/k_monto_factura/text()',dataxml))[1];
			if cve_inventario <> '' and monto <> '' then
				select c32 into estado_vta from keplersc.kdinf
				where c1=sucursal_id and c2=cve_inventario;
				if found then
				 	if estado_vta>=20 and (xpath('//row/c66/text()', xmlKDMM))[1]::text = 'C' then
				 		raise exception 'El inventario: % ya está facturado. Imposible registrar la bonificacion a la compra',cve_inventario;   
				 	end if;
				 	if estado_vta<20 and (xpath('//row/c66/text()', xmlKDMM))[1]::text = 'V' then
				 		raise exception 'El inventario: % NO está facturado. Imposible registrar la bonificacion a la venta',cve_inventario;   
				 	end if;
				 	if estado_vta>=60 then
				 		raise exception 'El inventario: % ya está entregado. Imposible registrar la bonificacion a la Venta o a la Compra',cve_inventario;   
				 	end if;
				 else
				 	raise exception 'El inventario: % no existe',cve_inventario;   
				end if;
			end if;
		end loop;
	end if;

	resultado := 1;
	
	return query select resultado;	

end;
$function$
