CREATE OR REPLACE FUNCTION keplersc.cat_param_oper_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de esquemas de asesores
--Autor: Victor Salgado
--Fecha: 01/09/2025
--Bitacora de cambios
declare
	--Variables de definicion de documento
    k_sucursal text = '';
	k_parametro text = '';
	k_valor_actual text = '';
    k_nuevo_valor text = '';
	k_usuario text = '';
	
	strValor text = '';
	xmlUsr xml;
	get_resultado text = '';
	get_mensaje text = '';
	get_adicionales text = '';

   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
    k_sucursal := (xpath('//document/k_sucursal/text()', dataxml))[1];
	k_parametro := (xpath('//document/k_parametro/text()', dataxml))[1];
	k_valor_actual := coalesce((xpath('//document/k_valor_actual/text()', dataxml))[1],'');
	k_nuevo_valor := (xpath('//document/k_valor_nuevo/text()', dataxml))[1];
	k_usuario := coalesce((xpath('//document/k_usuario/text()', dataxml))[1],'');

--raise exception '% % % % %',k_sucursal,k_parametro,k_valor_actual,k_nuevo_valor,k_usuario;
	--Actuliza registro
	update keplersc.param_oper set valor=k_nuevo_valor 
		where sucursal=k_sucursal and parametro=k_parametro and valor=k_valor_actual;

	select xmlforest(k_usuario as usuario, current_date as fecha, substring(current_time::text,1,8) as hora, 
	k_sucursal as sucursal, 'X' as genero, 'X' as naturaleza, 0 as grupo, 0 as tipo, 
	'X'  as folio,
	'Actualizacion de parametro' as tipo_movto, k_parametro || ' ' || 'Valor anterior:' || k_valor_actual || ' Nuevo valor: ' || k_nuevo_valor as detalle_movto) :: text into strValor;

	select '<document>'||strValor||'</document>' into strValor;
	xmlUsr := strValor::xml;
--raise exception '%',xmlUsr;
	
	select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);

--raise exception '% % %',get_resultado, get_mensaje, get_adicionales;

	resultado := 1;
	mensaje := 'Registro actualizado';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_param_oper_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
