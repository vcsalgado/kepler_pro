CREATE OR REPLACE FUNCTION keplersc.ifz_sofiainvoicenotification(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Funcion CRUD para interfaz Sofia Invoice Notification
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


	invnot_dealerbac int;
	invnot_secondarydealernumberid int;
	invnot_dealerid int;
	invnot_identificadordocumento int;
	invnot_fechafactura text;
	invnot_cadenaoriginaltimbre text;
	invnot_idsofia text;
	invnot_rfc text;
	invnot_idcliente int;
	invnot_numeroidentificacion text;
	invnot_tipocliente text;
	invnot_codigoactividadeconomica text;
	invnot_curp text;
	invnot_nombre text;
	invnot_apellidopaterno text;
	invnot_apellidomaterno text;
	invnot_nombrecompleto text;
	invnot_titulo text;
	invnot_sexo text;
	invnot_fechanacimiento text;
	invnot_calle text;
	invnot_numeroexterior text;
	invnot_numerointerior text;
	invnot_entrecalles text;
	invnot_codigoasentamiento text;
	invnot_colonia text;
	invnot_codigomunicipio text;
	invnot_municipio text;
	invnot_codigopostal text;
	invnot_codigoestado text;
	invnot_ladatelefono text;
	invnot_telefono text;
	invnot_ladatelefonooficina text;
	invnot_telefonooficina text;
	invnot_ladatelefonocelular text;
	invnot_telefonocelular text;
	invnot_email text;
	invnot_permitecontacto text;
	invnot_nombreconductor text;
	invnot_apellidopaternoconductor text;
	invnot_apellidomaternoconductor text;
	invnot_ladatelefonoconductor text;
	invnot_telefonoconductor text;
	invnot_ladatelefonooficinaconductor text;
	invnot_telefonooficinaconductor text;
	invnot_ladatelefonocelularconductor text;
	invnot_telefonocelularconductor text;
	invnot_emailconductor text;
	invnot_permitecontactoconductor text;
	invnot_rfcvendedor text;
	invnot_tipodistribuidor text;
	invnot_identificadorvendedor text;
	invnot_nombrevendedor text;
	invnot_apellidopaternovendedor text;
	invnot_apellidomaternovendedor text;
	invnot_tipopago text;
	invnot_tasa decimal;
	invnot_plazo int;
	invnot_numeroautorizacionfinanciamiento text;
	invnot_importeventatotal decimal;
	invnot_enganche decimal;
	invnot_saldopendiente decimal;
	invnot_tipoiva text;
	invnot_isan decimal;
	invnot_porcentajeiva decimal;
	invnot_importeiva decimal;
	invnot_codigoincentivo text;
	invnot_codigotipoventa text;
	invnot_numeroserie text;
	invnot_codigofan text;
	invnot_tipoflotilla text; 

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

	invnot_dealerbac := coalesce((xpath('//document/invnot_dealerbac/text()', dataxml))[1], '0')::text::int;
	invnot_secondarydealernumberid := coalesce((xpath('//document/invnot_secondarydealernumberid/text()', dataxml))[1], '0')::text::int;
	invnot_dealerid := coalesce((xpath('//document/invnot_dealerid/text()', dataxml))[1], '0')::text::int;
	invnot_identificadordocumento := coalesce((xpath('//document/invnot_identificadordocumento/text()', dataxml))[1], '0')::text::int;
	invnot_fechafactura := to_char(to_date(coalesce((xpath('//document/invnot_fechafactura/text()', dataxml))[1]::text, ''), 'YYYY-MM-DD'), 'DD/MM/YYYY');
	invnot_cadenaoriginaltimbre := coalesce((xpath('//document/invnot_cadenaoriginaltimbre/text()', dataxml))[1], '');
	invnot_idsofia := coalesce((xpath('//document/invnot_idsofia/text()', dataxml))[1], '');
	invnot_rfc := coalesce((xpath('//document/invnot_rfc/text()', dataxml))[1], '');
	invnot_idcliente := coalesce((xpath('//document/invnot_idcliente/text()', dataxml))[1], '0')::text::int;
	invnot_numeroidentificacion := coalesce((xpath('//document/invnot_numeroidentificacion/text()', dataxml))[1],'');
	invnot_tipocliente := coalesce((xpath('//document/invnot_tipocliente/r1/text()', dataxml))[1], '');
	invnot_codigoactividadeconomica := coalesce((xpath('//document/invnot_codigoactividadeconomica/text()', dataxml))[1],'');
	invnot_curp := coalesce((xpath('//document/invnot_curp/text()', dataxml))[1],'');
	invnot_nombre := coalesce((xpath('//document/invnot_nombre/text()', dataxml))[1], '');
	invnot_apellidopaterno := coalesce((xpath('//document/invnot_apellidopaterno/text()', dataxml))[1], '');
	invnot_apellidomaterno := coalesce((xpath('//document/invnot_apellidomaterno/text()', dataxml))[1], '');
	invnot_nombrecompleto := coalesce((xpath('//document/invnot_nombrecompleto/text()', dataxml))[1], '');
	invnot_titulo := coalesce((xpath('//document/invnot_titulo/text()', dataxml))[1], '');
	invnot_sexo := coalesce((xpath('//document/invnot_sexo/r1/text()', dataxml))[1], '');
	invnot_fechanacimiento := to_char(to_date(coalesce((xpath('//document/invnot_fechanacimiento/text()', dataxml))[1]::text, ''), 'YYYY-MM-DD'), 'DD/MM/YYYY');
	invnot_calle := coalesce((xpath('//document/invnot_calle/text()', dataxml))[1], '');
	invnot_numeroexterior := coalesce((xpath('//document/invnot_numeroexterior/text()', dataxml))[1], '');
	invnot_numerointerior := coalesce((xpath('//document/invnot_numerointerior/text()', dataxml))[1],'');
	invnot_entrecalles := coalesce((xpath('//document/invnot_entrecalles/text()', dataxml))[1], '');
	invnot_codigoasentamiento := coalesce((xpath('//document/invnot_codigoasentamiento/text()', dataxml))[1],'');
	invnot_colonia := coalesce((xpath('//document/invnot_colonia/text()', dataxml))[1], '');
	invnot_codigomunicipio := coalesce((xpath('//document/invnot_codigomunicipio/text()', dataxml))[1],'');
	invnot_municipio := coalesce((xpath('//document/invnot_municipio/text()', dataxml))[1], '');
	invnot_codigopostal := coalesce((xpath('//document/invnot_codigopostal/text()', dataxml))[1],'');
	invnot_codigoestado := coalesce((xpath('//document/invnot_codigoestado/text()', dataxml))[1], '');
	invnot_ladatelefono := coalesce((xpath('//document/invnot_ladatelefono/text()', dataxml))[1],'');
	invnot_telefono := coalesce((xpath('//document/invnot_telefono/text()', dataxml))[1],'');
	invnot_ladatelefonooficina := coalesce((xpath('//document/invnot_ladatelefonooficina/text()', dataxml))[1],'');
	invnot_telefonooficina := coalesce((xpath('//document/invnot_telefonooficina/text()', dataxml))[1],'');
	invnot_ladatelefonocelular := coalesce((xpath('//document/invnot_ladatelefonocelular/text()', dataxml))[1],'');
	invnot_telefonocelular := coalesce((xpath('//document/invnot_telefonocelular/text()', dataxml))[1],'');
	invnot_email := coalesce((xpath('//document/invnot_email/text()', dataxml))[1], '');
	invnot_permitecontacto := coalesce((xpath('//document/invnot_permitecontacto/r1/text()', dataxml))[1],'');
	invnot_nombreconductor := coalesce((xpath('//document/invnot_nombreconductor/text()', dataxml))[1],'');
	invnot_apellidopaternoconductor := coalesce((xpath('//document/invnot_apellidopaternoconductor/text()', dataxml))[1],'');
	invnot_apellidomaternoconductor := coalesce((xpath('//document/invnot_apellidomaternoconductor/text()', dataxml))[1],'');
	invnot_ladatelefonoconductor := coalesce((xpath('//document/invnot_ladatelefonoconductor/text()', dataxml))[1],'');
	invnot_telefonoconductor := coalesce((xpath('//document/invnot_telefonoconductor/text()', dataxml))[1],'');
	invnot_ladatelefonooficinaconductor := coalesce((xpath('//document/invnot_ladatelefonooficinaconductor/text()', dataxml))[1],'');
	invnot_telefonooficinaconductor := coalesce((xpath('//document/invnot_telefonooficinaconductor/text()', dataxml))[1],'');
	invnot_ladatelefonocelularconductor := coalesce((xpath('//document/invnot_ladatelefonocelularconductor/text()', dataxml))[1],'');
	invnot_telefonocelularconductor := coalesce((xpath('//document/invnot_telefonocelularconductor/text()', dataxml))[1],'');
	invnot_emailconductor := coalesce((xpath('//document/invnot_emailconductor/text()', dataxml))[1],'');
	invnot_permitecontactoconductor := coalesce((xpath('//document/invnot_permitecontactoconductor/r1/text()', dataxml))[1],'');
	invnot_rfcvendedor := coalesce((xpath('//document/invnot_rfcvendedor/text()', dataxml))[1],'');
	invnot_tipodistribuidor := coalesce((xpath('//document/invnot_tipodistribuidor/r1/text()', dataxml))[1], '');
	invnot_identificadorvendedor := coalesce((xpath('//document/invnot_identificadorvendedor/text()', dataxml))[1], '');
	invnot_nombrevendedor := coalesce((xpath('//document/invnot_nombrevendedor/text()', dataxml))[1], '');
	invnot_apellidopaternovendedor := coalesce((xpath('//document/invnot_apellidopaternovendedor/text()', dataxml))[1], '');
	invnot_apellidomaternovendedor := coalesce((xpath('//document/invnot_apellidomaternovendedor/text()', dataxml))[1], '');
	invnot_tipopago := coalesce((xpath('//document/invnot_tipopago/r1/text()', dataxml))[1], '');
	invnot_tasa := coalesce((xpath('//document/invnot_tasa/text()', dataxml))[1], '0')::text::decimal;
	invnot_plazo := coalesce((xpath('//document/invnot_plazo/text()', dataxml))[1], '0')::text::int;
	invnot_numeroautorizacionfinanciamiento := coalesce((xpath('//document/invnot_numeroautorizacionfinanciamiento/text()', dataxml))[1], '');
	invnot_importeventatotal := coalesce((xpath('//document/invnot_importeventatotal/text()', dataxml))[1], '0')::text::decimal;
	invnot_enganche := coalesce((xpath('//document/invnot_enganche/text()', dataxml))[1], '0')::text::decimal;
	invnot_saldopendiente := coalesce((xpath('//document/invnot_saldopendiente/text()', dataxml))[1], '0')::text::decimal;
	invnot_tipoiva := coalesce((xpath('//document/invnot_tipoiva/r1/text()', dataxml))[1], '');
	invnot_isan := coalesce((xpath('//document/invnot_isan/text()', dataxml))[1], '0')::text::decimal;
	invnot_porcentajeiva := coalesce((xpath('//document/invnot_porcentajeiva/text()', dataxml))[1], '0')::text::decimal;
	invnot_importeiva := coalesce((xpath('//document/invnot_importeiva/text()', dataxml))[1], '0')::text::decimal;
	invnot_codigoincentivo := coalesce((xpath('//document/invnot_codigoincentivo/text()', dataxml))[1],'');
	invnot_codigotipoventa := coalesce((xpath('//document/invnot_codigotipoventa/r1/text()', dataxml))[1], '');
	invnot_numeroserie := coalesce((xpath('//document/invnot_numeroserie/text()', dataxml))[1], '');
	invnot_codigofan := coalesce((xpath('//document/invnot_codigofan/text()', dataxml))[1],'');
	invnot_tipoflotilla := coalesce((xpath('//document/invnot_tipoflotilla/r1/text()', dataxml))[1],'');


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
	

	if k_movto_sofia = 'Invoice Notification' then
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
	    	(   serie, sucursal, genero, naturaleza, grupo, tipo, folio, movto_sofia, invnot_dealerbac,
				invnot_secondarydealernumberid, invnot_dealerid, invnot_identificadordocumento, invnot_fechafactura,
				invnot_cadenaoriginaltimbre, invnot_idsofia, invnot_rfc, invnot_idcliente, invnot_numeroidentificacion,
				invnot_tipocliente, invnot_codigoactividadeconomica, invnot_curp, invnot_nombre, invnot_apellidopaterno,
				invnot_apellidomaterno, invnot_nombrecompleto, invnot_titulo, invnot_sexo, invnot_fechanacimiento, invnot_calle,
				invnot_numeroexterior, invnot_numerointerior, invnot_entrecalles, invnot_codigoasentamiento, invnot_colonia,
				invnot_codigomunicipio, invnot_municipio, invnot_codigopostal, invnot_codigoestado,	invnot_ladatelefono, 
				invnot_telefono, invnot_ladatelefonooficina, invnot_telefonooficina, invnot_ladatelefonocelular, invnot_telefonocelular,
				invnot_email, invnot_permitecontacto, invnot_nombreconductor, invnot_apellidopaternoconductor,
				invnot_apellidomaternoconductor, invnot_ladatelefonoconductor, invnot_telefonoconductor, invnot_ladatelefonooficinaconductor,
				invnot_telefonooficinaconductor, invnot_ladatelefonocelularconductor, invnot_telefonocelularconductor,
				invnot_emailconductor, invnot_permitecontactoconductor, invnot_rfcvendedor, invnot_tipodistribuidor, 
				invnot_identificadorvendedor, invnot_nombrevendedor, invnot_apellidopaternovendedor, invnot_apellidomaternovendedor,
				invnot_tipopago, invnot_tasa, invnot_plazo, invnot_numeroautorizacionfinanciamiento, invnot_importeventatotal,
				invnot_enganche, invnot_saldopendiente, invnot_tipoiva, invnot_isan, invnot_porcentajeiva, invnot_importeiva,
				invnot_codigoincentivo, invnot_codigotipoventa, invnot_numeroserie, invnot_codigofan, invnot_tipoflotilla)
			     values( k_serie, k_sucursal, k_genero, k_naturaleza, k_grupo, k_tipo, k_folio, k_movto_sofia, invnot_dealerbac,
				invnot_secondarydealernumberid, invnot_dealerid, invnot_identificadordocumento, invnot_fechafactura,
				invnot_cadenaoriginaltimbre, invnot_idsofia, invnot_rfc, invnot_idcliente, invnot_numeroidentificacion,
				invnot_tipocliente, invnot_codigoactividadeconomica, invnot_curp, invnot_nombre, invnot_apellidopaterno,
				invnot_apellidomaterno, invnot_nombrecompleto, invnot_titulo, invnot_sexo, invnot_fechanacimiento, invnot_calle,
				invnot_numeroexterior, invnot_numerointerior, invnot_entrecalles, invnot_codigoasentamiento, invnot_colonia,
				invnot_codigomunicipio, invnot_municipio, invnot_codigopostal, invnot_codigoestado,	invnot_ladatelefono, 
				invnot_telefono, invnot_ladatelefonooficina, invnot_telefonooficina, invnot_ladatelefonocelular, invnot_telefonocelular,
				invnot_email, invnot_permitecontacto, invnot_nombreconductor, invnot_apellidopaternoconductor,
				invnot_apellidomaternoconductor, invnot_ladatelefonoconductor, invnot_telefonoconductor, invnot_ladatelefonooficinaconductor,
				invnot_telefonooficinaconductor, invnot_ladatelefonocelularconductor, invnot_telefonocelularconductor,
				invnot_emailconductor, invnot_permitecontactoconductor, invnot_rfcvendedor, invnot_tipodistribuidor, 
				invnot_identificadorvendedor, invnot_nombrevendedor, invnot_apellidopaternovendedor, invnot_apellidomaternovendedor,
				invnot_tipopago, invnot_tasa, invnot_plazo, invnot_numeroautorizacionfinanciamiento, invnot_importeventatotal,
				invnot_enganche, invnot_saldopendiente, invnot_tipoiva, invnot_isan, invnot_porcentajeiva, invnot_importeiva,
				invnot_codigoincentivo, invnot_codigotipoventa, invnot_numeroserie, invnot_codigofan, invnot_tipoflotilla );
			
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
		mensaje := 'ifz_sofiainvoicenotification() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
