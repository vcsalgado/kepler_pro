CREATE OR REPLACE FUNCTION keplersc.invr_generar_marbetes(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Descripcion: Crea los registros para la impresion de marbetes
	--Autor:Victor Salgado
	--Fecha: 08 Nov 2023
	--Ejemplo de llamado
	--select * from keplersc.invr_generar_marbetes('<document><sucursal_id>01</sucursal_id></document>');
	
	--Variables de definicion de documento
	sucursal_id text = '';
	parte text = '';

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin

	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	parte:= coalesce((xpath('//document/parte/text()', dataxml))[1],'');

	if parte='GENERARMARBETES' then
		--Inicia la tabla de marbetes
		delete from keplersc.kdmarbe where col_sucursal=sucursal_id;
		delete from keplersc.kdifis where c1=sucursal_id;
	
		--Se seleccionan aquellos que traen movimientos
		insert into keplersc.kdmarbe 
		select row_number() over(order by ini.c32, ini.c1) as c1,
		ini.c1 as c2, ini.c2 as c3, ini.c4 as c4, ini.c5 as c5,
		ini.c6 as c6, ini.c19 as c7,sucursal_id from keplersc.kdini ini 
		inner join keplersc.kdinl inl on inl.c1=sucursal_id and inl.c2=ini.c1 
		where inl.c5-inl.c6<>0 or inl.c8-inl.c9<>0;	
	else
		--Validar que el producto existe
		select count(*) into intValor from keplersc.kdini where c1=parte;
		if intValor = 0 then
			raise exception 'El producto % no existe.', producto;
		end if;
		--Validar que el producto no esté como marbete
--raise exception 'PASO 1';
		select count(*) into intValor from keplersc.kdmarbe where c2=parte and col_sucursal=sucursal_id;
		if intValor > 0 then
			raise exception 'El producto % ya está en marbetes.', parte;
		end if;	
--raise exception 'PASO 2';
		--Insertar registro
		insert into keplersc.kdmarbe 
		select row_number() over() + (select max(c1) from keplersc.kdmarbe where col_sucursal=sucursal_id) as c1,
		ini.c1 as c2, ini.c2 as c3, ini.c4 as c4, ini.c5 as c5,
		ini.c6 as c6, ini.c19 as c7,sucursal_id from keplersc.kdini ini 
		where ini.c1=parte;	
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'invr_generar_marbetes() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
