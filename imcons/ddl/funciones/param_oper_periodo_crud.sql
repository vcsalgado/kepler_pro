CREATE OR REPLACE FUNCTION keplersc.param_oper_periodo_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud a la tabla param_oper_periodo
--Autor: Miriam Santana
--Fecha: 24/07/2024
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';	
	stranio text='';
	strmes text='';
	strparametro text='';
	strvalor text='';
	
    --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
   	
begin 
	sucursal_id := (xpath('//document/sucursal/text()', dataxml))[1];
	stranio := (xpath('//document/anio/text()', dataxml))[1];
	strmes := (xpath('//document/mes/text()', dataxml))[1];
	strparametro := (xpath('//document/parametro/text()', dataxml))[1];
	strvalor := (xpath('//document/valor/text()', dataxml))[1];
	
	--Validacion de datos
	if sucursal_id = '' then
		raise exception 'Falta especificar la sucursal';
	end if;
	if stranio = '' then
		raise exception 'Falta especificar el a�o';
	end if;
	if strmes = '' then
		raise exception 'Falta especificar el mes';
	end if;
	if strparametro = '' then
		raise exception 'Falta especificar nombre del parametro';
	end if;
	if strvalor = '0' then
		raise exception 'El valor de % no puede ser 0',parametro;
	end if;



	delete from keplersc.param_oper_periodo 
		where sucursal=sucursal_id and anio=stranio and mes=strmes and parametro=strparametro;
		
	insert into keplersc.param_oper_periodo
			(sucursal,anio,mes,parametro,valor) 
		values(
			sucursal_id,stranio,strmes,strparametro,strvalor);


	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'configurapresupuesto_alta() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
