CREATE OR REPLACE FUNCTION keplersc.ser_precios_xpaquete_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Realiza actualización de precio por paquete en la tabla KDSPAQ
--Autor: Miriam Santana
--Fecha: 02/Feb/23
--Bitacora de cambios

	--Variables de definicion de documento
	paquete_id text;
	marca_id text;
	modelo_id text;
	
	varios text;
	horas text;
	precio text;
	no_partidas int = 0;
	
	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	get_resultado text;
	get_mensaje text; 
	get_adicionales text;
	varXml xml;
begin
	paquete_id := (xpath('//document/k_paquete/text()', dataxml))[1];
	marca_id := (xpath('//document/k_marca/text()', dataxml))[1];
	modelo_id := (xpath('//document/k_modelo/text()',dataxml))[1];
	strValor:=coalesce((xpath('//document/k_partidas/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;

	if paquete_id is null then
		raise exception 'Falta seleccionar el paquete';
	end if;
			
	--Actualizar registros
	for cont in 0..no_partidas-1 loop
		marca_id:= (xpath('//document/k_mov/r' ||cont||'/k_marca/text()',dataxml))[1];
		modelo_id:= (xpath('//document/k_mov/r' ||cont||'/k_modelo/text()',dataxml))[1];
		varios:= coalesce((xpath('//document/k_mov/r' ||cont||'/k_varios/text()',dataxml))[1],'0');
		horas:=coalesce((xpath('//document/k_mov/r' ||cont||'/k_horas/text()',dataxml))[1],'0');
		precio:=coalesce((xpath('//document/k_mov/r' ||cont||'/k_precio/text()',dataxml))[1],'0');

		if (marca_id is not null or marca_id <> '') and (modelo_id is not null or modelo_id <> '') then			
			update keplersc.kdspaq set
				c8=varios::decimal,
				c9=horas::decimal,
				c10=precio::decimal
			where c1=marca_id and c2=modelo_id and c4=paquete_id;
		end if;
	end loop;
/*
	select xmlforest(usuario_movto as usuario, current_date as fecha, TO_CHAR(NOW(), 'HH24:MI:SS') as hora, 
			'00' as sucursal, ' ' as genero, ' ' as naturaleza, 0 as grupo, 0 as tipo, 'X' as folio,
			'ACTUALIZACION DE PAQUETE PRECIOS X PAQUETE' as tipo_movto, marca || '-' || modelo || '-' || paquete as detalle_movto) :: text into strValor;
		
	select '<document>'||strValor||'</document>' into strValor;
	varXml := strValor::xml;
					
	select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(varXml);
	if get_resultado = '0' then
		raise exception '%',get_mensaje;
	end if;
*/
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_precios_xpaquete_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
