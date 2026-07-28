CREATE OR REPLACE FUNCTION keplersc.notif_registrar_movto_gm_sofia(p_new record, p_entidad text, p_operacion text)
 RETURNS TABLE(procesar text, api_id text, datos_interfaz jsonb)
 LANGUAGE plpgsql
AS $function$
DECLARE
    sucursal_id text;
    agencia text;
BEGIN
    procesar := 'N';
    api_id := '';
    datos_interfaz := '{}'::jsonb;

    SELECT c2 INTO agencia FROM keplersc.kdcfdconfig LIMIT 1;

    -- ===================== IFZ_SOFIA_NOTIF =====================
    IF p_entidad='IFZ_SOFIA_NOTIF' THEN
        sucursal_id := p_new.sucursal;
        IF p_new.movto_sofia='Invoice Notification' THEN
            procesar:='S';
            api_id := 'SofiaInvoiceNotification/';
			-- api_id := 'SOFIA_INV';
        ELSIF p_new.movto_sofia='Invoice Cancelled' AND p_new.grupo IN (60,70) THEN
            procesar:='S';
            api_id := 'SofiaInvoiceCancelled/';
			-- api_id := 'SOFIA_INVCANC';
        ELSIF p_new.movto_sofia='Delivery Notification' THEN
            procesar:='S';
            api_id := 'SofiaDeliveryNotification/';
			-- api_id := 'SOFIA_DELI';
        ELSIF p_new.movto_sofia='Return Delivery' THEN
            procesar:='S';
            api_id := 'SofiaReturnDelivery/';
			-- api_id := 'SOFIA_RETDELI';
        ELSIF p_new.movto_sofia='Demo' THEN
            procesar:='S';
            api_id := 'SofiaDemo/';
			-- api_id := 'SOFIA_DEMO';
            datos_interfaz := jsonb_build_object(
                'vin',p_new.demo_vin,
                'consecutivo',p_new.demo_consec,
                'demoEstatus',p_new.demo_estatus,
                'agencia',agencia
            );
            RETURN NEXT;
        END IF;

        IF datos_interfaz='{}'::jsonb THEN
            datos_interfaz := jsonb_build_object(
                'sucursal',sucursal_id,
                'genero',p_new.genero,
                'naturaleza',p_new.naturaleza,
                'grupo',p_new.grupo,
                'tipo',p_new.tipo,
                'folio',p_new.folio,
                'agencia',agencia
            );
        END IF;
    END IF;

    RETURN NEXT;
END;
$function$
