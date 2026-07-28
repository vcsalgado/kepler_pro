CREATE OR REPLACE FUNCTION keplersc.notif_registrar_movto_campanas(vin text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
    api_id text;
    intTransaction int;
    json_notif jsonb;
	datos_interfaz jsonb;
    expSql text;
   
   	sucursal_id text = '';
 	dealer text = '';
   
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	sucursal_id := split_part(vin,'.',2);		--sucursal
	vin := split_part(vin, '.', 1);				--vin
		
	select c5 into dealer from keplersc.kdms 
		where c1 = sucursal_id;
	
	datos_interfaz := '{}'::jsonb;
	api_id := 'DDOA_SSC';	 
 	select coalesce(max(id_transaccion),0)+1
    	into intTransaction
    	from keplersc.notif_api_control_envios;

	datos_interfaz := jsonb_build_object(
                'DealerID', dealer,'Vin',vin
            	);

    insert into keplersc.notif_api_control_envios
    	(id_transaccion, api_id, datos_interfaz)
    values
	    (intTransaction, api_id, datos_interfaz);

	json_notif := jsonb_build_object(
	            'schema_version','1.0',
	            'target_workflow', jsonb_build_object(
	                'config_key', api_id
	            ),
	            'initial_context', jsonb_build_object(
	                'body', jsonb_build_object(
                    'method', 'SpecialServicesCampaign', 'request', datos_interfaz
                  )
	            )
	);
	
    expSql := format('notify interfaces_toyota, %L', json_notif::text);
    execute expSql;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'notif_registrar_movto_campanas() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;   
   
end;
$function$
