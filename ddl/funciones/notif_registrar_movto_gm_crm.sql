CREATE OR REPLACE FUNCTION keplersc.notif_registrar_movto_gm_crm(p_new record, p_entidad text, p_operacion text)
 RETURNS TABLE(procesar text, api_id text, datos_interfaz text)
 LANGUAGE plpgsql
AS $function$
DECLARE
    sucursal_id text;
    agencia text;

	intTransaction int;
	expSql text;
BEGIN
    procesar := 'N';
    api_id := '';
    --datos_interfaz := '{}'::jsonb;
	datos_interfaz := '';

    SELECT c2 INTO agencia FROM keplersc.kdcfdconfig LIMIT 1;

    --Procedimientos de Crear y Cerrar orden (Facturar)
	if p_entidad='KDORD' then
		sucursal_id:=p_new.c1;
		IF EXISTS (
			SELECT 1
			FROM keplersc.kdserie v
			WHERE v.c1 = p_new.c6
			  AND v.c2 LIKE '%CHEVR%'
			  AND (
					CASE
						WHEN COALESCE(v.c11, 'NA') ~ '^[0-9\.]+$' = false THEN 0
						ELSE v.c11::INTEGER
					END
			  ) >= 2010
			) THEN
	
				if p_operacion='INSERT' then
					if p_new.c9='A' then
						if (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'GM_CrearOrden')) = 'S' then
							procesar:='S';
							api_id := 'ifz_gm_bp/get_gm_orden_crear_od/';
						--elsif p_new.c9 = 'M' and p_new.c8 = 50 then --OJO NUNCA VA ENTRAR
							--procesar:='S';
						end if;
					end if;
				end if;
				if p_operacion='UPDATE' then
					if (p_new.c9 = 'A' or p_new.c9 = 'M') and p_new.c8 = 50 then
						if (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'GM_CerrarOrden')) = 'S' then
							procesar:='S';
							api_id := 'ifz_gm_bp/get_gm_orden_cerrar_od/';
						end if;
					end if;
				end if;
		end if;
		
		--Crear cadena con datos de registro de orden
		datos_interfaz:=concat('{"sucursal":"',sucursal_id,'",','"tipo_orden":"',p_new.c2,'",','"folio_orden":"',p_new.c3,'",','"agencia":"',agencia,'"}');
	end if;

	--Se procesan las ordenes para evitar conflictos en caso de que se elimine la factura y la orden regrese al estado 40.
	--OJO CHECAR: SE QUIERE PROCESAR 2 PETICIONES ifz_gm_bp/delete_gm_orden_eliminar_od/ Y ifz_gm_bp/get_gm_orden_crear_od/
	if p_entidad='KDVNTALL' then
		sucursal_id:=p_new.c1;
		IF EXISTS (
			SELECT 1
			FROM keplersc.ifz_bp_ordenes b
			WHERE b.sucursal = p_new.c1
			and b.folio_orden = (p_new.c2 || p_new.c3)
			--WHERE b.folio_orden = p_new.c3
			) then
				if p_operacion='INSERT' then
					if p_new.c5 = 10 then
						--Se elimina la orden en el sistema de bp
						if (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'GM_EliminarOrden')) = 'S' then
							api_id := 'ifz_gm_bp/delete_gm_orden_eliminar_od/';
							datos_interfaz:=concat('{"sucursal":"',sucursal_id,'",','"tipo_orden":"',p_new.c2,'",','"folio_orden":"',p_new.c3,'",','"agencia":"',agencia,'"}');
							select coalesce(max(id_transaccion),0) + 1 into intTransaction from keplersc.notif_api_control_envios;
							insert into keplersc.notif_api_control_envios (id_transaccion,api_id,datos_interfaz) values(intTransaction,api_id,datos_interfaz);
							--Execute sin CIRDAN
							expSql := format('notify gm, ''%s''', intTransaction);
		        			EXECUTE expSql;
							RAISE NOTICE 'notify gm enviado: %', intTransaction;
						end if;
						--Se vuelve a crear la orden en el sistema de bp
						if (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'GM_CrearOrden')) = 'S' then
							api_id := 'ifz_gm_bp/get_gm_orden_crear_od/';
							datos_interfaz:=concat('{"sucursal":"',sucursal_id,'",','"tipo_orden":"',p_new.c2,'",','"folio_orden":"',p_new.c3,'",','"agencia":"',agencia,'"}');
							select coalesce(max(id_transaccion),0) + 1 into intTransaction from keplersc.notif_api_control_envios;
							insert into keplersc.notif_api_control_envios (id_transaccion,api_id,datos_interfaz) values(intTransaction,api_id,datos_interfaz);
							--Execute sin CIRDAN
							expSql := format('notify gm, ''%s''', intTransaction);
		        			EXECUTE expSql;
							RAISE NOTICE 'notify gm enviado: %', intTransaction;
						end if;
					end if;
				end if;
		end if;
	end if;
	
	--Procedimiento de eliminar orden
	if p_entidad='KDORDCEROS' then
		sucursal_id:=p_new.c1;
		IF EXISTS (
			SELECT 1
			FROM keplersc.ifz_bp_ordenes b
			WHERE b.sucursal = p_new.c1
			and b.folio_orden = (p_new.c2 || p_new.c3)
			) then

			if p_operacion='INSERT' then
				if (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'GM_EliminarOrden')) = 'S' then
					procesar:='S';
					api_id := 'ifz_gm_bp/delete_gm_orden_eliminar_od/';
				end if;
			end if;
		
			--Crear cadena con datos de registro de orden eliminada
			datos_interfaz:=concat('{"sucursal":"',sucursal_id,'",','"tipo_orden":"',p_new.c2,'",','"folio_orden":"',p_new.c3,'",','"agencia":"',agencia,'"}');

		end if;
	end if;
	
	--Procedimiento para crear y cambiar estatus de cita
	if p_entidad='KDCTASSER' then
		sucursal_id:=p_new.c1;
		IF EXISTS (
			SELECT 1
			FROM keplersc.kdserie v
			WHERE v.c4 = p_new.c9
			  AND v.c2 LIKE '%CHEVR%'
			  AND (
					CASE
						WHEN COALESCE(v.c11, 'NA') ~ '^[0-9\.]+$' = false THEN 0
						ELSE v.c11::INTEGER
					END
			  ) >= 2010
			) then
				if p_operacion='INSERT' and p_new.origen = 'K80' then
					if p_new.c20 = 0 and p_new.c19 = 'A' then
					-- Pendiente
						if (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'GM_CrearCita')) = 'S' then
							procesar:='S';
							api_id := 'ifz_gm_bp/get_gm_cita_crear_od/';
						end if;
					elsif p_new.c19 = 'M'	then
						if (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'GM_CrearCita')) = 'S' then
							procesar := 'S';
							api_id := 'ifz_gm_bp/get_gm_cita_crear_od/'; --Checar con Pepe
						end if;
					end if;
				end if;
				
				if p_operacion = 'UPDATE' then
					if p_new.c20 in (30,40) then
					--Eliminada
						if (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'GM_EliminarCita')) = 'S' then
							procesar:='S';
							api_id := 'ifz_gm_bp/delete_gm_cita_eliminar_od/';
						end if;
					elsif p_new.c20 = 20 then
					-- Realizada
						if (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'GM_CitaRealizada')) = 'S' then
							procesar:='S';
							api_id := 'ifz_gm_bp/get_gm_cita_realizada_od/';
						end if;
					elsif p_new.c20 = 50 then
					--No show
						if (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'GM_CitaNoRealizada')) = 'S' then
							procesar:='S';
							api_id := 'ifz_gm_bp/get_gm_cita_norealizada_od/';
						end if;
					end if;
				end if;
		end if;		
	
		--Crear cadena con datos de registro de la cita
		datos_interfaz:=concat('{"sucursal":"',sucursal_id,'",','"folio_cita":"',p_new.c2,'",','"agencia":"',agencia,'"}');
	end if;
	
    RETURN NEXT;
END;
$function$
