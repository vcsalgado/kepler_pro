CREATE OR REPLACE FUNCTION keplersc.ifz_sofiainvoicecancelled(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Funcion CRUD para interfaz Sofia Invoice Cancelled
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

	invcan_dealerbac int;
	invcan_secondarydealernumberid int;
	invcan_codigorazoncancelacion text;
	invcan_numeronotacredito int;
	invcan_codigodistribuidor int;
	invcan_identificadordocumento int;
	invcan_fechacancelacionfactura text;
	invcan_cadenaoriginaltimbre text;
	invcan_numeroserie text;

	campos_faltantes text;

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
	
	invcan_dealerbac := coalesce((xpath('//document/invcan_dealerbac/text()', dataxml))[1], '0')::text::int;	
	invcan_secondarydealernumberid := coalesce((xpath('//document/invcan_secondarydealernumberid/text()', dataxml))[1], '0')::text::int;
	invcan_codigorazoncancelacion := coalesce((xpath('//document/invcan_codigorazoncancelacion/r1/text()', dataxml))[1], '');
	invcan_numeronotacredito := coalesce((xpath('//document/invcan_numeronotacredito/text()', dataxml))[1], '0')::text::int;
	invcan_codigodistribuidor := coalesce((xpath('//document/invcan_codigodistribuidor/text()', dataxml))[1], '0')::text::int;
	invcan_identificadordocumento := coalesce((xpath('//document/invcan_identificadordocumento/text()', dataxml))[1], '0')::text::int;
	invcan_fechacancelacionfactura := to_char(to_date(coalesce((xpath('//document/invcan_fechacancelacionfactura/text()', dataxml))[1]::text, ''), 'YYYY-MM-DD'), 'DD/MM/YYYY');
	invcan_cadenaoriginaltimbre := coalesce((xpath('//document/invcan_cadenaoriginaltimbre/text()', dataxml))[1], '');
	invcan_numeroserie := coalesce((xpath('//document/invcan_numeroserie/text()', dataxml))[1], '');

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

	if k_movto_sofia = 'Invoice Cancelled' then
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
	   
			insert
				into keplersc.ifz_sofia_notif
	    	(   serie, sucursal, genero, naturaleza, grupo, tipo, folio, movto_sofia, invcan_dealerbac,
				invcan_secondarydealernumberid, invcan_codigorazoncancelacion, invcan_numeronotacredito, 
				invcan_codigodistribuidor, invcan_identificadordocumento, invcan_fechacancelacionfactura, 
				invcan_cadenaoriginaltimbre, invcan_numeroserie)
			     values( k_serie, k_sucursal, k_genero, k_naturaleza, k_grupo, k_tipo, k_folio, k_movto_sofia, invcan_dealerbac,
				invcan_secondarydealernumberid, invcan_codigorazoncancelacion, invcan_numeronotacredito, 
				invcan_codigodistribuidor, invcan_identificadordocumento, invcan_fechacancelacionfactura, 
				invcan_cadenaoriginaltimbre, invcan_numeroserie );
			
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
		mensaje := 'ifz_sofiainvoicecancelled() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
