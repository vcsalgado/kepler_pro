CREATE OR REPLACE FUNCTION keplersc.notif_registrar_movto()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    strOem text;
    intTransaction int;
    resultado record;
    json_notif jsonb;
    expSql text;

    --RHFC variables para extraer sucursal y folio del json
    extracted_sucursal text;
    extracted_folio text;
   
    --variables trigger
    entidad text = '';
    operacion text = '';
    p_new record = NEW;

BEGIN
    entidad:=upper(TG_TABLE_NAME);
    operacion:=upper(TG_OP);

    SELECT oem INTO strOem FROM keplersc.notif_api_config LIMIT 1;

    
    IF strOem = 'GWM' then
        SELECT * INTO resultado FROM keplersc.notif_registrar_movto_gwm(NEW, entidad, operacion);
    ELSIF strOem = 'GM' THEN
        IF entidad = 'IFZ_SOFIA_NOTIF' THEN
            SELECT * INTO resultado FROM keplersc.notif_registrar_movto_gm_sofia(NEW, entidad, operacion);
        ELSE
            SELECT * INTO resultado FROM keplersc.notif_registrar_movto_gm_crm(NEW, entidad, operacion);
        END IF;
        
    --RHFC INICIO
    ELSIF strOem = 'TOY' THEN
        SELECT * INTO resultado FROM keplersc.notif_registrar_movto_toyota(NEW, entidad, operacion);
    --RHFC FIN
    ELSE
        RAISE NOTICE 'OEM % no soportado', strOem;
        RETURN NEW;
    END IF;
   
    IF resultado.procesar = 'S' THEN
        SELECT coalesce(max(id_transaccion),0)+1
          INTO intTransaction
          FROM keplersc.notif_api_control_envios;

        --Json para cirdan (global)
        json_notif := jsonb_build_object(
            'schema_version','1.0',
            'cirdan_metadata', jsonb_build_object('id_transaccion', intTransaction),
            'target_workflow', jsonb_build_object('config_key', resultado.api_id),
            'initial_context', jsonb_build_object('params', resultado.datos_interfaz)
        );
        --RHFC Se incluye el primer IF y se incluye entidad KDVENTAS
        IF strOem = 'TOY' THEN
            SELECT resultado.datos_interfaz->>'sucursal' INTO extracted_sucursal;
            SELECT resultado.datos_interfaz->>'folio' INTO extracted_folio;
            
            IF entidad = 'KDPEDREF' THEN
                INSERT INTO keplersc.notif_api_control_envios (id_transaccion, api_id, datos_interfaz, sucursal, genero, naturaleza, grupo, tipo, folio)
                VALUES (intTransaction, resultado.api_id, resultado.datos_interfaz, extracted_sucursal,'N','D',21,1,extracted_folio);    
            ELSIF entidad = 'IFZ_DDOA_RDR_NOTIF' THEN
                INSERT INTO keplersc.notif_api_control_envios (id_transaccion, api_id, datos_interfaz, sucursal, genero, naturaleza, grupo, tipo, folio)
                VALUES (intTransaction, resultado.api_id, resultado.datos_interfaz, extracted_sucursal,'U','D',6,1,extracted_folio);
            ELSE
                INSERT INTO keplersc.notif_api_control_envios (id_transaccion, api_id, datos_interfaz)
                VALUES (intTransaction, resultado.api_id, resultado.datos_interfaz);
            END IF;

            IF resultado.interfaz = 'DDOA' THEN
                expSql := format('notify interfaces_toyota, %L', json_notif::text);
                EXECUTE expSql;
                RAISE NOTICE 'JSON enviado a Toyota: %', json_notif;
            ELSE
                expSql := format('notify interfaces_toyota, ''%s''', intTransaction);
                EXECUTE expSql;
                RAISE NOTICE 'notify interfaces_toyota enviado: %', intTransaction;
            END IF;

        ELSIF strOem = 'GM' THEN
            IF entidad = 'IFZ_SOFIA_NOTIF' THEN
                INSERT INTO keplersc.notif_api_control_envios (id_transaccion, api_id, datos_interfaz, id_sofia_notif)
                VALUES (intTransaction, resultado.api_id, resultado.datos_interfaz, p_new.id_sofia_notif);
            ELSE
                INSERT INTO keplersc.notif_api_control_envios (id_transaccion, api_id, datos_interfaz)
                VALUES (intTransaction, resultado.api_id, resultado.datos_interfaz);
               
                expSql := format('notify interfaces_otros, %L', json_notif::text);
                EXECUTE expSql;
                RAISE NOTICE 'JSON enviado a Otros (GM): %', json_notif;
            END IF;

--            expSql := format('notify interfaces_gm, ''%s''', intTransaction);
--            EXECUTE expSql;

        ELSE
            INSERT INTO keplersc.notif_api_control_envios (id_transaccion, api_id, datos_interfaz)
            VALUES (intTransaction, resultado.api_id, resultado.datos_interfaz);
    
            expSql := format('notify interfaces_otros, %L', json_notif::text);
            EXECUTE expSql;
            RAISE NOTICE 'JSON enviado a Otros (Generico): %', json_notif;
        END IF;
    END IF;

    RETURN NEW;
END;
$function$
