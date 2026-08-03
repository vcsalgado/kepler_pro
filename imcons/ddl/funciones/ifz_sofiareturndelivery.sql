CREATE OR REPLACE FUNCTION keplersc.ifz_sofiareturndelivery(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Funcion CRUD para interfaz Sofia Return Delivery
--Autor: Alejandra Morales	
--Fecha: 01/05/2025
declare
	--Variables de definicion de documento
	k_serie text; 
	k_sucursal text;
	k_genero text;
	k_naturaleza text;
	k_grupo int;
	k_tipo int;
	k_folio text;
	k_movto_sofia text;
	
	retdel_dealerbac int;
	retdel_foliodevolucionentrega text;
	retdel_identificadordocumento int;
	retdel_numerotransaccionentrega int;
	retdel_numeroserie text;
	retdel_folioentrega text;

	campos_faltantes text := '';
	
	--Variables auxiliares
	grupo_txt text;
	tipo_txt  text;
	
   	--Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	k_serie := (xpath('//document/serie/text()', dataxml))[1];
	k_sucursal := (xpath('//document/sucursal/text()', dataxml))[1];
	k_genero := (xpath('//document/genero/text()', dataxml))[1];
	k_naturaleza := (xpath('//document/naturaleza/text()', dataxml))[1];
	grupo_txt := (xpath('//document/grupo/text()', dataxml))[1];
	tipo_txt := (xpath('//document/tipo/text()', dataxml))[1];
	k_folio := (xpath('//document/folio/text()', dataxml))[1];
	k_movto_sofia := (xpath('//document/movto_sofia/text()', dataxml))[1]::text;
	
	retdel_dealerbac := coalesce((xpath('//document/retdel_dealerbac/text()', dataxml))[1], '0')::text::int;
	retdel_foliodevolucionentrega := coalesce((xpath('//document/retdel_foliodevolucionentrega/text()', dataxml))[1], '');
	retdel_identificadordocumento := coalesce((xpath('//document/retdel_identificadordocumento/text()', dataxml))[1], '0')::text::int;
	retdel_numerotransaccionentrega := coalesce((xpath('//document/retdel_numerotransaccionentrega/text()', dataxml))[1], '0')::text::int;
	retdel_numeroserie := coalesce((xpath('//document/retdel_numeroserie/text()', dataxml))[1], '');
	retdel_folioentrega := coalesce((xpath('//document/retdel_folioentrega/text()', dataxml))[1], '');

	-- Validación de variables vacías
		if k_serie = '' then campos_faltantes := campos_faltantes || 'serie, '; end if;
		if k_sucursal = '' then campos_faltantes := campos_faltantes || 'sucursal, '; end if;
		if k_genero = '' then campos_faltantes := campos_faltantes || 'genero, '; end if;
		if k_naturaleza = '' then campos_faltantes := campos_faltantes || 'naturaleza, '; end if;
		if grupo_txt is null or grupo_txt = '' then
		    campos_faltantes := campos_faltantes || 'grupo, ';
		else
		    k_grupo := grupo_txt::int;
	    end if;
		if tipo_txt is null or tipo_txt = '' then
		    campos_faltantes := campos_faltantes || 'tipo, ';
		else
		    k_tipo := tipo_txt::int;
		end if;
		if k_folio = '' then campos_faltantes := campos_faltantes || 'folio, '; end if;
		if k_movto_sofia = '' then campos_faltantes := campos_faltantes || 'movto_sofia, '; end if;
	
	if campos_faltantes <> '' then
		campos_faltantes := left(campos_faltantes, length(campos_faltantes) - 2);
		resultado := '0';
		mensaje := 'Campos requeridos faltantes: ' || campos_faltantes;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
	end if;


	if k_movto_sofia = 'Return Delivery' then
	    -- Validar si ya existe una notificación registrada
	    if exists (
	        select 1 from keplersc.ifz_sofia_notif t
	        where
	            t.serie = k_serie and
	            t.sucursal = k_sucursal and
	            t.genero = k_genero and
	            t.naturaleza = k_naturaleza and
	            t.grupo = k_grupo and
	            t.tipo = k_tipo and
	            t.folio = k_folio and
	            t.movto_sofia = k_movto_sofia
	    ) then
	        resultado := '0';
	        mensaje := 'La notificación a Sofía ya está registrada.';
	        adicionales := '';
	        return query select resultado, mensaje, adicionales;
	    else
		    -- Inserción de la notificación
		    insert into keplersc.ifz_sofia_notif (
		        serie, sucursal, genero, naturaleza, grupo, tipo, folio, movto_sofia,
		        retdel_dealerbac, retdel_foliodevolucionentrega, retdel_identificadordocumento,
		        retdel_numerotransaccionentrega, retdel_numeroserie, retdel_folioentrega
		    ) values (
		        k_serie, k_sucursal, k_genero, k_naturaleza, k_grupo, k_tipo, k_folio, k_movto_sofia,
		        retdel_dealerbac, retdel_foliodevolucionentrega, retdel_identificadordocumento,
		        retdel_numerotransaccionentrega, retdel_numeroserie, retdel_folioentrega
		    );
		   
		   	resultado := 1;
			mensaje := 'Registro agregado';
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
		end if;
		else
			resultado := '0';
			mensaje := 'El tipo de movimiento sofia no coincide con esta funcion';
			adicionales := '';
			return query select resultado, mensaje, adicionales;		
	end if;

exception
	when others then
		resultado := 0;
		mensaje := 'ifz_sofiareturndelivery() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
