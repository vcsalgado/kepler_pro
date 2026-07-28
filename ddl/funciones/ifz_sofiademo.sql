CREATE OR REPLACE FUNCTION keplersc.ifz_sofiademo(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Funcion CRUD para interfaz Sofia Demo
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

	
	k_demo_vin text;
	k_demo_consec int;
	k_demo_idcliente int;
	k_demo_estatus text;
	k_demo_notransaccion int;
	k_demo_idoperacion int;
	k_demo_origenope text;
	k_demo_evento text;
	k_demo_resultado text;
	k_demo_resdescrip text;
	k_demo_fechact text;
	k_demo_horaact text;
	k_demo_cveusu text;
	k_demo_valorunidad int;
	k_demo_ivaaplicable int;

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
	
	k_demo_vin := coalesce((xpath('//document/demo_vin/text()', dataxml))[1], '');
    k_demo_consec := coalesce((xpath('//document/demo_consec/text()', dataxml))[1]::text,'0')::int;
	k_demo_idcliente := coalesce((xpath('//document/demo_idcliente/text()', dataxml))[1]::text,'0')::int;
    k_demo_estatus := coalesce((xpath('//document/demo_estatus/r1/text()', dataxml))[1], '')::text;
	k_demo_notransaccion := coalesce((xpath('//document/demo_notransaccion/text()', dataxml))[1]::text,'0')::int;
    k_demo_idoperacion := coalesce((xpath('//document/demo_idoperacion/text()', dataxml))[1]::text,'0')::int;
    k_demo_origenope := coalesce((xpath('//document/demo_origenope/text()', dataxml))[1], '');
    k_demo_evento    := coalesce((xpath('//document/demo_evento/text()', dataxml))[1], '');
    k_demo_resultado := coalesce((xpath('//document/demo_resultado/text()', dataxml))[1], '');
    k_demo_resdescrip:= coalesce((xpath('//document/demo_resdescrip/text()', dataxml))[1], '');
    k_demo_fechact   := to_char(to_date(coalesce((xpath('//document/demo_fechact/text()', dataxml))[1]::text, ''), 'YYYY-MM-DD'), 'DD/MM/YYYY');
    k_demo_horaact   := coalesce((xpath('//document/demo_horaact/text()', dataxml))[1], '');
    k_demo_cveusu    := coalesce((xpath('//document/demo_cveusu/text()', dataxml))[1], '');
    k_demo_valorunidad := coalesce((xpath('//document/demo_valorunidad/text()', dataxml))[1]::text,'0')::int;
    k_demo_ivaaplicable := coalesce((xpath('//document/demo_ivaaplicable/text()', dataxml))[1]::text,'0')::int;

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


	if k_movto_sofia = 'Demo' then
		-- Validar si ya existe una notificación registrada
	    if exists (
	        select 1 from keplersc.ifz_sofia_notif t
	        where
	            t.serie = k_serie and
	            t.demo_vin = k_demo_vin and
	            t.demo_consec = k_demo_consec and
	            t.demo_estatus = k_demo_estatus
	    ) then
	        resultado := '0';
	        mensaje := 'La notificación a Sofía ya está registrada.';
	        adicionales := '';
	        return query select resultado, mensaje, adicionales;
	    else
	
			insert
				into keplersc.ifz_sofia_notif
	    	(   serie, sucursal, genero, naturaleza, grupo, tipo, folio, movto_sofia, 
				demo_vin, demo_consec, demo_idcliente, demo_estatus, demo_notransaccion,
				demo_idoperacion, demo_origenope, demo_evento, demo_resultado, demo_resdescrip,
				demo_fechact, demo_horaact, demo_cveusu, demo_valorunidad, demo_ivaaplicable)
			values( k_serie, k_sucursal, k_genero, k_naturaleza, k_grupo, k_tipo, k_folio, k_movto_sofia, 
				k_demo_vin, k_demo_consec, k_demo_idcliente, k_demo_estatus, k_demo_notransaccion,
				k_demo_idoperacion, k_demo_origenope, k_demo_evento, k_demo_resultado, k_demo_resdescrip,
				k_demo_fechact, k_demo_horaact, k_demo_cveusu, k_demo_valorunidad, k_demo_ivaaplicable );
			
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
		mensaje := 'ifz_sofiademo() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
