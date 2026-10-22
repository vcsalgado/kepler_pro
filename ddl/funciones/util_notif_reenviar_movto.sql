CREATE OR REPLACE FUNCTION keplersc.util_notif_reenviar_movto()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
    intTransaction int;
	config_key text;
    json_notif jsonb;
    expSql text;
	nombre_notify text;

BEGIN
	intTransaction:=117860;
	config_key:='CRM_WEB_TYT_CITA_CREAR_WF';
	nombre_notify:='notify interfaces_toyota';

    json_notif := jsonb_build_object(
        'schema_version','1.0',
        'cirdan_metadata', jsonb_build_object('id_transaccion', intTransaction),
        'target_workflow', jsonb_build_object('config_key', config_key),
        'initial_context', jsonb_build_object('params', 'CRM')
    );
    
    expSql := format('notify interfaces_toyota, %L', json_notif::text);
    EXECUTE expSql;
    RAISE NOTICE 'JSON enviado: %', json_notif;

    RETURN expSql;
END;
$function$
