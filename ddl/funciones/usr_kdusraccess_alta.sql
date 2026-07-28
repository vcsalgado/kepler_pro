CREATE OR REPLACE FUNCTION keplersc.usr_kdusraccess_alta(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	usuario text = '';	
	fecha text = '';
	hora text = '';
	sucursal text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo text = '';
	folio text = '';
	tipo_movto text = '';
	detalle_movto text = '';

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	usuario := (xpath('//document/usuario/text()', dataxml))[1];
	fecha := (xpath('//document/fecha/text()', dataxml))[1];
	hora := (xpath('//document/hora/text()', dataxml))[1];
	sucursal := (xpath('//document/sucursal/text()', dataxml))[1];
	genero := (xpath('//document/genero/text()', dataxml))[1];
	naturaleza := (xpath('//document/naturaleza/text()', dataxml))[1];
	grupo := (xpath('//document/grupo/text()', dataxml))[1];
	tipo := (xpath('//document/tipo/text()', dataxml))[1];
	folio := (xpath('//document/folio/text()', dataxml))[1];
	tipo_movto := (xpath('//document/tipo_movto/text()', dataxml))[1];
	detalle_movto:= coalesce((xpath('//document/detalle_movto/text()', dataxml))[1]::text,'');

	insert into keplersc.kdusraccess (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11)
		values(usuario,to_date(fecha,'YYYY-MM-DD'),hora,sucursal,genero,naturaleza,
			grupo::int,tipo::int,folio,tipo_movto,left(detalle_movto,2000));
		
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'usr_kdusraccess_alta() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
