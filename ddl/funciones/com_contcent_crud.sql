CREATE OR REPLACE FUNCTION keplersc.com_contcent_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud en KDCONFOGCC
--Autor: Miriam Santana
--Fecha: 19/01/2023
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	porcasesorcc text = '';
	consecutivo int;

   --Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	porcasesorcc := (xpath('//document/k_porcasesorcc/text()', dataxml))[1];
	consecutivo := 1; 
	
	if porcasesorcc ='' or porcasesorcc is null then
		raise exception 'Falta especificar el Porcentaje del Asesor Contact Center';
	end if;
	
   	--Eliminar registros del la configuración Contact Centar
	delete from keplersc.kdconfigcc 
		where c1=consecutivo and c3=sucursal_id;

	--Insertar nuevos registros
	insert into keplersc.kdconfigcc (
		c1,c2,c3)
	values(
		consecutivo,porcasesorcc::decimal,sucursal_id);		
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'com_contcent_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
