CREATE OR REPLACE FUNCTION keplersc.ven_seleccion_anticipos(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Realiza la seleccion de anticipos en KDF3NCANT
--Autor: Miriam Santana
--Fecha: 04/03/2025
--Bitacora de cambios
--22/04/2026 Miriam Santana: Seleccion de anticipos de una factura de autos, servicio o refacciones para relacionarlos en el CFDI (cve_seleccion)

declare
	--Variables de definicion de documento
	sucursal_id text;
	sel text;
	tipo_operacion text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	folio text;
	cve_seleccion text;
	origen text;
	origenMov text;
	
	--Variables de uso general
	totReg int;
	strValor text;
	strPartidas text;
	no_partidas int;
	msg text='';

	--Variables de retorno
	resultado text='';
	mensaje text='';
	adicionales text='';


begin
	sucursal_id := (xpath('//document/k_sucursal/text()', dataxml))[1];
	cve_seleccion := coalesce((xpath('//document/k_seleccion/text()', dataxml))[1]::text,'')::text;
	origen := coalesce((xpath('//document/origen/text()', dataxml))[1]::text,'')::text;
	origenMov := coalesce((xpath('//document/origenmov/text()', dataxml))[1]::text,'')::text;

	--Tipo operacion
	tipo_operacion := (xpath('//document/tip_ope/text()', dataxml))[1];
	
	--Partidas
	strPartidas := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strPartidas::integer;

	if (tipo_operacion='0' or tipo_operacion='A') or (tipo_operacion='1' or tipo_operacion='C' and origen='AUTOS' and origenMov='PEDIDO') then	
		--Procesar alta detalle de seleccion de anticipos
		for cont in 0..no_partidas - 1 loop
			sel := (xpath('//document/k_mov/r'||cont||'/sel/text()',dataxml))[1];
			genero := (xpath('//document/k_mov/r'||cont||'/gen_anticipo/text()',dataxml))[1];
			naturaleza := (xpath('//document/k_mov/r'||cont||'/nat_anticipo/text()',dataxml))[1];
			grupo := (xpath('//document/k_mov/r'||cont||'/gpo_anticipo/text()',dataxml))[1];
			tipo := (xpath('//document/k_mov/r'||cont||'/tpo_anticipo/text()',dataxml))[1];
			folio := (xpath('//document/k_mov/r'||cont||'/folio/text()',dataxml))[1];

			--Sólo realiza la actualizacion de la seleccion de anticipo si tiene esta seleccionado
			if sel = 'S' then	
--raise exception 'suc:%, inv:%, sel:%, g:%, n:%, gp:%, tp:%, folio:%',sucursal_id, seleccion, sel, genero, naturaleza, grupo, tipo, folio;
				if cve_seleccion='' then
					select case when origen='AUTOS' then 'No. Inventario'
					when origen='SERVICIO' then 'Tipo y No. Orden'
					when origen='REFACCIONES' then 'No. Serie'
					end into msg;
					raise exception 'Verifique falta el %',msg;
				else
					update keplersc.kdf3ncant set
						folio_relacionado = cve_seleccion				
						where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio;
				end if; 	
			else
				update keplersc.kdf3ncant set
					folio_relacionado = ''				
					where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio;
			
			end if;
		end loop;
	end if;
	resultado := 1;
	mensaje := 'Anticipos actualizados';
	adicionales := '';
	
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ven_seleccion_anticipos() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
		
end;
$function$
