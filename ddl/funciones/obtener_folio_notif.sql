CREATE OR REPLACE FUNCTION keplersc.obtener_folio_notif()
 RETURNS TABLE(id_notif integer)
 LANGUAGE plpgsql
AS $function$
declare 
	id_nofif int;

begin
--	select coalesce(max(id_transaccion),0) + 1 into id_nofif from keplersc.notif_api_control_envios;
	select nextval('keplersc.notif_api_control_envios_seq') into id_nofif;	
	return query select id_nofif;

end;
$function$
