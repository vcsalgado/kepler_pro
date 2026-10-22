CREATE OR REPLACE FUNCTION keplersc.notif_registrar_movto_gwm(p_new record, p_entidad text, p_operacion text)
 RETURNS TABLE(procesar text, api_id text, datos_interfaz jsonb)
 LANGUAGE plpgsql
AS $function$
DECLARE
    sucursal_id text;
    estatus text;
    strApi_id text;
    intTransaction int;
BEGIN
    procesar := 'N';
    api_id := '';
    datos_interfaz := '{}'::jsonb;

    IF p_entidad='KDORD' THEN
        sucursal_id := p_new.c1;
        strApi_id := 'interfaces_gwm';

        IF p_operacion='INSERT' THEN
            estatus := 'W';
            procesar := 'S';
        ELSIF p_operacion='UPDATE' THEN
            if old.c7 <> new.c7 and new.c7=10 then --Orden cambia a cerrada
					estatus:='C';
					procesar:='S';	
			end if;

        ELSIF p_operacion='DELETE' THEN
            procesar := 'N';
        END IF;

        IF procesar='S' THEN
            -- Construir JSON con datos de la orden
            datos_interfaz := jsonb_build_object(
                'sucursal_id', sucursal_id,
                'tipo_orden', p_new.c2,
                'orden', p_new.c3
            );

            -- Obtener consecutivo
/*
            SELECT COALESCE(MAX(id_transaccion),0)+1
            INTO intTransaction
            FROM keplersc.notif_api_control_envios;
*/
			select id_notif into intTransaction from keplersc.obtener_folio_notif();
            -- devolver API_ID para quien llame la funci�n
            api_id := strApi_id;
        END IF;
    
	ELSIF p_entidad = 'KDINM' then
		sucursal_id := p_new.c1;
        strApi_id := 'interfaces_gwm';
       
        IF p_operacion = 'INSERT' THEN
       		IF new.c5 = 'U' AND new.c6 = 'D' AND new.c7 = 22 AND c8 IN (1,2) AND new.c13 = 1 THEN
				estatus = 'N';
				procesar = 'S';
			END IF;
		END IF;
		IF procesar = 'S' THEN
				datos_interfaz := jsonb_build_object(
					'sucursal_id',  sucursal_id,
					'gen', new.c5,
					'nat', new.c6,
					'gpo', new.c7,
					'tipo', new.c8,
					'folio', new.c9
				);
			
		 		-- Obtener consecutivo
/*
	            SELECT COALESCE(MAX(id_transaccion),0)+1
	            INTO intTransaction
	            FROM keplersc.notif_api_control_envios;
*/
				select id_notif into intTransaction from keplersc.obtener_folio_notif();	
	            api_id := strApi_id;
	     END IF;
				
    END IF;

    RETURN NEXT;
END;
$function$
