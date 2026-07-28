CREATE OR REPLACE FUNCTION keplersc.notif_registrar_movto_toyota(p_new record, p_entidad text, p_operacion text)
 RETURNS TABLE(procesar text, api_id text, datos_interfaz jsonb, interfaz text)
 LANGUAGE plpgsql
AS $function$
DECLARE
    sucursal_id text;
    agencia text;
	folio text; --RHFC Se incluye para la obtención delfolio en kdm1

	intTransaction int;
	expSql text;
BEGIN
    procesar := 'N';
    api_id := '';
    datos_interfaz := '{}'::jsonb;
	interfaz := '';

    SELECT c2 INTO agencia FROM keplersc.kdcfdconfig LIMIT 1;

---------------------------------------------------------------------------------------------------
--          INTERFAZ DDOA
---------------------------------------------------------------------------------------------------
	-- REPAIR ORDER DDOA_ROR
    -- ===================== KDVNTALL =====================
    IF p_entidad='KDVNTALL' THEN
        sucursal_id := p_new.c1;
        IF p_operacion='INSERT' AND p_new.c5=0 THEN
			IF (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'TOY_RepairOrder')) = 'S' THEN
	            procesar:='S';
				interfaz:='DDOA';
	            api_id := 'DDOA_ROR';
	            datos_interfaz := jsonb_build_object(
	                'sucursal',sucursal_id,
	                'tipo_orden',p_new.c2,
	                'orden',p_new.c3,
	               	'agencia',agencia
	                );
			END IF;
        END IF;
    END IF;

    -- RETAIL DELIVERY REPORTING DDOA_RDR
	-- ===================== IFZ_DDOA_RDR_NOTIF =====================
	IF p_entidad='IFZ_DDOA_RDR_NOTIF' THEN
		IF p_new.sucursal = p_new.sucursal	and p_new.genero = 'U' and p_new.naturaleza = 'D'
		and p_new.grupo = 6 and p_new.tipo = 1 THEN
			sucursal_id := p_new.sucursal;
			folio := p_new.folio;
        	IF p_operacion='INSERT' THEN
            	procesar:='S';
				interfaz:='DDOA';
            	api_id := 'DDOA_RDR';
            	datos_interfaz := jsonb_build_object(
                	'sucursal',sucursal_id,
					'genero',p_new.genero,
					'naturaleza',p_new.naturaleza,
					'grupo',p_new.grupo,
                	'tipo',p_new.tipo,
                	'folio',folio,
                	'agencia',agencia
            	);
        	END IF;
		END IF;	
	END IF;


	--COMPRA DE VEHICULOS NUEVOS
	-- ===================== KDICOM =====================
	IF p_entidad='KDICOM' THEN
		IF p_new.c4 = 'X' and p_new.c5 = 'A'
		and p_new.c6 = 6 and p_new.c7 = 1 and p_new.c12 = 0 THEN
			sucursal_id := p_new.c1;
			folio := p_new.c8;
        	IF p_operacion='INSERT' THEN
				IF (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'TOY_CompraVehiculosNuevos')) = 'S' THEN
	            	procesar:='S';
					interfaz:='DDOA';
	            	api_id := 'DDOA_VIAI';
	            	datos_interfaz := jsonb_build_object(
	                	'agencia',agencia,
	                	'inventario',p_new.c2
	            	);
				END IF;
        	END IF;
		END IF;	
	END IF;


	-- PARTS ORDER DDOA_PO
	-- ===================== KDPEDREF =====================
    IF p_entidad='KDPEDREF' THEN
        sucursal_id := p_new.c1;
		SELECT c6 INTO folio FROM keplersc.kdm1 
		WHERE 
		c1 = sucursal_id --Sucrusal
		and c2 = 'N' --Genero
		and c3 = 'D' --Naturaleza
		and c4 = 21 --Grupo
		and c5 = 1 --Tipo
		and c11 = p_new.c2 --Referencia del Pedido Sugerido
		LIMIT 1;
        IF p_operacion='UPDATE' AND p_new.c4=20 THEN
			IF (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'TOY_PartsOrder')) = 'S' THEN
	            procesar:='S';
				interfaz:='DDOA';
	            api_id := 'DDOA_PO';
	            datos_interfaz := jsonb_build_object(
	                'sucursal',sucursal_id,
	                'tipo',1,
	                'pedido',folio,
	                'agencia',agencia
	            );
			END IF;
        END IF;
    END IF;


---------------------------------------------------------------------------------------------------
--          INTERFAZ CRM
---------------------------------------------------------------------------------------------------
	--Procedimientos de Crear y Cerrar orden (Facturar)
	if p_entidad='KDORD' then
		sucursal_id:=p_new.c1;
		IF EXISTS (
			SELECT 1
			FROM keplersc.kdserie v
			WHERE v.c1 = p_new.c6
			  AND v.c2 LIKE '%TOY%'
			  AND (
					CASE
						WHEN COALESCE(v.c11, 'NA') ~ '^[0-9\.]+$' = false THEN 0
						ELSE v.c11::INTEGER
					END
			  ) >= 2010
			) THEN
	
				if p_operacion='INSERT' then
					if p_new.c9='A' then
						IF (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'TOY_CrearOrden')) = 'S' THEN
							procesar:='S';
							interfaz:='CRM';
							api_id := 'ifz_toy_bp/get_ty_orden_crear_od/';
						--elsif p_new.c9 = 'M' and p_new.c8 = 50 then --OJO NUNCA VA ENTRAR
							--procesar:='S';
						END IF;
					end if;
				end if;
				if p_operacion='UPDATE' then
					if (p_new.c9 = 'A' or p_new.c9 = 'M') and p_new.c8 = 50 then
						IF (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'TOY_CerrarOrden')) = 'S' THEN
							procesar:='S';
							interfaz:='CRM';
							api_id := 'ifz_toy_bp/get_ty_orden_cerrar_od/';
						END IF;
					end if;
				end if;
		end if;
		
		--Crear cadena con datos de registro de orden
		datos_interfaz:=concat('{"sucursal":"',sucursal_id,'",','"tipo_orden":"',p_new.c2,'",','"orden":"',p_new.c3,'",','"agencia":"',agencia,'"}');
	end if;

	--Se procesan las ordenes para evitar conflictos en caso de que se elimine la factura y la orden regrese al estado 40.
	--OJO CHECAR: SE QUIERE PROCESAR 2 PETICIONES ifz_toy_bp/delete_ty_orden_eliminar_od/ Y ifz_toy_bp/get_ty_orden_crear_od/
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
						IF (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'TOY_EliminarOrden')) = 'S' THEN
							api_id := 'ifz_toy_bp/delete_ty_orden_eliminar_od/';
							datos_interfaz:=concat('{"sucursal":"',sucursal_id,'",','"tipo_orden":"',p_new.c2,'",','"orden":"',p_new.c3,'",','"agencia":"',agencia,'"}');
							select coalesce(max(id_transaccion),0) + 1 into intTransaction from keplersc.notif_api_control_envios;
							insert into keplersc.notif_api_control_envios (id_transaccion,api_id,datos_interfaz) values(intTransaction,api_id,datos_interfaz);
							--Execute sin CIRDAN
							expSql := format('notify interfaces_toyota, ''%s''', intTransaction);
		        			EXECUTE expSql;
							RAISE NOTICE 'notify interfaces_toyota enviado: %', intTransaction;
						END IF;
						--Se vuelve a crear la orden en el sistema de bp
						IF (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'TOY_CrearOrden')) = 'S' THEN
							api_id := 'ifz_toy_bp/get_ty_orden_crear_od/';
							datos_interfaz:=concat('{"sucursal":"',sucursal_id,'",','"tipo_orden":"',p_new.c2,'",','"orden":"',p_new.c3,'",','"agencia":"',agencia,'"}');
							select coalesce(max(id_transaccion),0) + 1 into intTransaction from keplersc.notif_api_control_envios;
							insert into keplersc.notif_api_control_envios (id_transaccion,api_id,datos_interfaz) values(intTransaction,api_id,datos_interfaz);
							--Execute sin CIRDAN
							expSql := format('notify interfaces_toyota, ''%s''', intTransaction);
		        			EXECUTE expSql;
							RAISE NOTICE 'notify interfaces_toyota enviado: %', intTransaction;
						END IF;
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
				IF (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'TOY_EliminarOrden')) = 'S' THEN
					procesar:='S';
					interfaz:='CRM';
					api_id := 'ifz_toy_bp/delete_ty_orden_eliminar_od/';
				END IF;
			end if;
		
			--Crear cadena con datos de registro de orden eliminada
			datos_interfaz:=concat('{"sucursal":"',sucursal_id,'",','"tipo_orden":"',p_new.c2,'",','"orden":"',p_new.c3,'",','"agencia":"',agencia,'"}');

		end if;
	end if;
	
	--Procedimiento para crear y cambiar estatus de cita
	if p_entidad='KDCTASSER' then
		sucursal_id:=p_new.c1;
		IF EXISTS (
			SELECT 1
			FROM keplersc.kdserie v
			WHERE v.c4 = p_new.c9
			  AND v.c2 LIKE '%TOY%'
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
						IF (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'TOY_CrearCita')) = 'S' THEN
							procesar:='S';
							interfaz:='CRM';
							api_id := 'ifz_toy_bp/get_ty_cita_crear_od/';
						END IF;
					elsif p_new.c19 = 'M'	then
						IF (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'TOY_CrearCita')) = 'S' THEN
							procesar := 'S';
							interfaz:='CRM';
							api_id := 'ifz_toy_bp/get_ty_cita_crear_od/'; --Checar con Pepe
						END IF;
					end if;
				end if;
				
				if p_operacion = 'UPDATE' then
					if p_new.c20 in (30,40) then
					--Eliminada
						IF (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'TOY_EliminarCita')) = 'S' THEN
							procesar:='S';
							interfaz:='CRM';
							api_id := 'ifz_toy_bp/delete_ty_cita_eliminar_od/';
						END IF;
					elsif p_new.c20 = 20 then
					-- Realizada
						IF (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'TOY_CitaRealizada')) = 'S' THEN
							procesar:='S';
							interfaz:='CRM';
							api_id := 'ifz_toy_bp/get_ty_cita_realizada_od/';
						END IF;
					elsif p_new.c20 = 50 then
					--No show
						IF (SELECT * FROM keplersc.ifz_habilita(sucursal_id, 'TOY_CitaNoRealizada')) = 'S' THEN
							procesar:='S';
							interfaz:='CRM';
							api_id := 'ifz_toy_bp/get_ty_cita_norealizada_od/';
						END IF;
					end if;
				end if;
		end if;		
	
		--Crear cadena con datos de registro de la cita
		datos_interfaz:=concat('{"sucursal":"',sucursal_id,'",','"folio_cita":"',p_new.c2,'",','"agencia":"',agencia,'"}');
	end if;

    RETURN NEXT;
END;
$function$
