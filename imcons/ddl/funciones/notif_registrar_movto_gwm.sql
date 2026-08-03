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

        strApi_id := 'APIDMSServicio';

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
                'tipo', p_new.c2,
                'orden', p_new.c3
            );

            -- Obtener consecutivo
            SELECT COALESCE(MAX(id_transaccion),0)+1
            INTO intTransaction
            FROM keplersc.notif_api_control_envios;

            -- devolver API_ID para quien llame la función
            api_id := strApi_id;
        END IF;
    END IF;

    RETURN NEXT;
END;
$function$
