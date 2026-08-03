CREATE OR REPLACE FUNCTION keplersc.ifz_sofiadeliverynotification(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Funcion CRUD para interfaz Sofia Delivery Notification
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

	
	delnot_dealerbac int;
	delnot_identificadordocumento int;
	delnot_nombreclienterecibe text;
	delnot_apellidopaternoclienterecibe text;
	delnot_apellidomaternoclienterecibe text;
	delnot_ladatelefonoclienterecibe text;
	delnot_telefonoclienterecibe text;
	delnot_ladatelefonooficinaclienterecibe text;
	delnot_telefonooficinaclienterecibe text;
	delnot_ladatelefonocelularclienterecibe text;
	delnot_telefonocelularclienterecibe text;
	delnot_emailclienterecibe text;
	delnot_permitecontactoclienterecibe text;
	delnot_numeroserie text;
	delnot_fechaentrega text;
	delnot_folioentrega text;

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
	
	delnot_dealerbac := coalesce((xpath('//document/delnot_dealerbac/text()', dataxml))[1], '0')::text::int;
	delnot_identificadordocumento := coalesce((xpath('//document/delnot_identificadordocumento/text()', dataxml))[1], '0')::text::int;
	delnot_nombreclienterecibe := coalesce((xpath('//document/delnot_nombreclienterecibe/text()', dataxml))[1], '');
	delnot_apellidopaternoclienterecibe := coalesce((xpath('//document/delnot_apellidopaternoclienterecibe/text()', dataxml))[1], '');
	delnot_apellidomaternoclienterecibe := coalesce((xpath('//document/delnot_apellidomaternoclienterecibe/text()', dataxml))[1], '');
	delnot_ladatelefonoclienterecibe := coalesce((xpath('//document/delnot_ladatelefonoclienterecibe/text()', dataxml))[1], '');
	delnot_telefonoclienterecibe := coalesce((xpath('//document/delnot_telefonoclienterecibe/text()', dataxml))[1], '');
	delnot_ladatelefonooficinaclienterecibe := coalesce((xpath('//document/delnot_ladatelefonooficinaclienterecibe/text()', dataxml))[1], '');
	delnot_telefonooficinaclienterecibe := coalesce((xpath('//document/delnot_telefonooficinaclienterecibe/text()', dataxml))[1], '');
	delnot_ladatelefonocelularclienterecibe := coalesce((xpath('//document/delnot_ladatelefonocelularclienterecibe/text()', dataxml))[1], '');
	delnot_telefonocelularclienterecibe := coalesce((xpath('//document/delnot_telefonocelularclienterecibe/text()', dataxml))[1], '');
	delnot_emailclienterecibe := coalesce((xpath('//document/delnot_emailclienterecibe/text()', dataxml))[1], '');
	delnot_permitecontactoclienterecibe := coalesce((xpath('//document/delnot_permitecontactoclienterecibe/r1/text()', dataxml))[1], '');
	delnot_numeroserie := coalesce((xpath('//document/delnot_numeroserie/text()', dataxml))[1], '');
	delnot_fechaentrega := to_char(to_date(coalesce((xpath('//document/delnot_fechaentrega/text()', dataxml))[1]::text, ''), 'YYYY-MM-DD'), 'DD/MM/YYYY');
	delnot_folioentrega := coalesce((xpath('//document/delnot_folioentrega/text()', dataxml))[1], '');

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


	if k_movto_sofia = 'Delivery Notification' then
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
	    	(   serie, sucursal, genero, naturaleza, grupo, tipo, folio, movto_sofia, delnot_dealerbac,
				delnot_identificadordocumento, delnot_nombreclienterecibe, delnot_apellidopaternoclienterecibe,
				delnot_apellidomaternoclienterecibe, delnot_ladatelefonoclienterecibe, delnot_telefonoclienterecibe,
				delnot_ladatelefonooficinaclienterecibe, delnot_telefonooficinaclienterecibe,
				delnot_ladatelefonocelularclienterecibe, delnot_telefonocelularclienterecibe,
				delnot_emailclienterecibe, delnot_permitecontactoclienterecibe, delnot_numeroserie,
				delnot_fechaentrega, delnot_folioentrega)
			values( k_serie, k_sucursal, k_genero, k_naturaleza, k_grupo, k_tipo, k_folio, k_movto_sofia, delnot_dealerbac,
				delnot_identificadordocumento, delnot_nombreclienterecibe, delnot_apellidopaternoclienterecibe,
				delnot_apellidomaternoclienterecibe, delnot_ladatelefonoclienterecibe, delnot_telefonoclienterecibe,
				delnot_ladatelefonooficinaclienterecibe, delnot_telefonooficinaclienterecibe,
				delnot_ladatelefonocelularclienterecibe, delnot_telefonocelularclienterecibe,
				delnot_emailclienterecibe, delnot_permitecontactoclienterecibe, delnot_numeroserie,
				delnot_fechaentrega, delnot_folioentrega );
		
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
		mensaje := 'ifz_sofiadeliverynotification() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
