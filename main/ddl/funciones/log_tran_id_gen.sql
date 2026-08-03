CREATE OR REPLACE FUNCTION keplersc.log_tran_id_gen()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare 
	strValor text;
	tran_id text;
	begin
		tran_id = 0;
		strValor := substring(EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::text,3,2) ||
			lpad(EXTRACT(month FROM CURRENT_TIMESTAMP)::text,2,'0') || 
			lpad(EXTRACT(day FROM CURRENT_TIMESTAMP)::text,2,'0') || 
			lpad(EXTRACT(hours FROM CURRENT_TIMESTAMP)::text,2,'0') || 
			lpad(EXTRACT(minutes FROM CURRENT_TIMESTAMP)::text,2,'0') || 
			lpad(EXTRACT(seconds FROM CURRENT_TIMESTAMP)::text,2,'0');
		tran_id := strValor::text;
		return tran_id;		
	END;
$function$
