CREATE OR REPLACE FUNCTION keplersc.sch_expenses_data_convert(p_suc text, p_fix_kdm5 integer)
 RETURNS TABLE(resultado text, mensaje text)
 LANGUAGE plpgsql
AS $function$
DECLARE 
	-- Funcion para corregir y actualizar el proveedor de pago de KDM5
	-- Autor: Jose Mendoza , 11 Mayo 2024
	-- * * * Control de Cambios :
	-- Se incluiran otras tablas a modificar para que en el mismo 
    -- proceso haga todas las modificaciones 

	--Variables para xml
	sucursal_id text;
	prov_oper text;
	prov_pago text;

	rec5 record;

	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;

	--Variables de retorno desde funciones externas
	resultado text; --retorno
	mensaje text; --retorno
	--adicionales text; --retorno
	
	--Added by JMM 20240516
	totalRegk5 int;

	--Added by JMM 20240517
	v_fix int;
	totalFixed int;
	k1 int;
	ke int;
	kg int;
	
begin
	
	-- Inicializacion de variables
	resultado := '';
	mensaje := '';
	--adicionales := '';

	sucursal_id := p_suc;
	v_fix := p_fix_kdm5;


	--- Start : Section UPD all records of main tables - sch expenses

	k1 := 0;  ke := 0;  kg := 0;

	WITH rows AS (
		update keplersc.kdm1 set cve_prov_pago = c10 
		where c1 = sucursal_id and length(coalesce(cve_prov_pago)) = 0 and length(coalesce(c10)) > 0
		returning 1
	)
	SELECT count(*) into k1 FROM rows;

	raise notice '% Records Updated {kdm1} ', k1;

	WITH rows AS (
		update keplersc.kduxg set cve_prov_pago = c3 
		where c1 = sucursal_id and length(coalesce(cve_prov_pago)) = 0 and length(coalesce(c3)) > 0
		returning 1
	)
	SELECT count(*) into kg FROM rows;

	raise notice '% Records Updated {kduxg} ', kg;
	
	WITH rows AS (
		update keplersc.kduxe set cve_prov_pago = c2 
		where c1 = sucursal_id and length(coalesce(cve_prov_pago)) = 0 and length(coalesce(c2)) > 0
		returning 1
	)
	SELECT count(*) into ke FROM rows;
	
	raise notice '% Records Updated {kduxe} ', ke;

	--- End : Section UPD all records of main tables - sch expenses


	totalReg := 0; 	totalRegk5 := 0;  totalFixed := 0;
	
	for rec5 in 
		select * from keplersc.kdm5 
		where c1 = sucursal_id 
	loop
		
		totalRegk5 := totalRegk5 + 1;
	
		prov_oper := '';  prov_pago := '';
		
		-- * * * UPD KDM5 SINCE KDUXE
		select c2, cve_prov_pago into prov_oper, prov_pago from keplersc.kduxe 
		where c1 = rec5.c1 and c5 = rec5.c2 and c6 = rec5.c3 and c7 = rec5.c4::int and c8 = rec5.c5::int
			and c9 = rec5.c6 and (c3 = rec5.c14 or doc_refer_compl = rec5.c14);
		if not found then
		
			totalReg := totalReg + 1;
			/*
			mensajeError := 'C x P {kduxe} de la Partida a Procesar en {kdm5} No encontrado ...' 
				|| (rec5.c1||rec5.c2||rec5.c3||rec5.c4::text||rec5.c5::text||rec5.c6||'.'||rec5.c7::text||'.'||rec5.c14||'-' 
				||rec5.cve_prov_oper||'-' ||rec5.cve_prov_pago);
			raise exception '%',mensajeError;	
			*/
		
			-- Limpia Campos de Proveedor OPER & PAGO en KDM5 si tiene parametro FIX.KDM5 = 1 sino los deja como estan de Origen
			-- Esta opcion No debe aplicarse en procesos normales de conversion de datos, esto debe correrse {fix = 1} si se presume 
			-- Que hay inconsistencias en KDM5 
			if v_fix = 1 then  
			
				totalFixed := totalFixed + 1;
				
				update keplersc.kdm5 
				set cve_prov_oper = '', 
					cve_prov_pago = ''
				where c1 = rec5.c1 and c2 = rec5.c2 and c3 = rec5.c3 and c4 = rec5.c4::int and c5 = rec5.c5::int
					and c6 = rec5.c6 and c7 = rec5.c7 and c14 = rec5.c14;
				
			end if;
		
		else
		
			prov_oper := coalesce(prov_oper,'');
			prov_pago := coalesce(prov_pago,'');
			
			update keplersc.kdm5 
			set cve_prov_oper = prov_oper, 
				cve_prov_pago = prov_pago
			where c1 = rec5.c1 and c2 = rec5.c2 and c3 = rec5.c3 and c4 = rec5.c4::int and c5 = rec5.c5::int
				and c6 = rec5.c6 and c7 = rec5.c7 and c14 = rec5.c14  
				/*and cve_prov_oper = prov_oper and cve_prov_pago = prov_pago*/;
			
		end if;
		-- * * * END : UPD KDM5 SINCE KDUXE
	
	end loop;

	-- For Testing ...
	/*raise exception '%','Los Registros seran Procesados ... ' || 'Regs Found ' || (totalRegk5 - totalReg)::text || ' of ' || totalRegk5::text;*/


	resultado := 1;

	mensaje := 'Total Records {kdm5} ... ' || totalRegk5::text || ' ;  Updated ' || (totalRegk5 - totalReg)::text || ' ;  Not Found ' || totalReg::text;
	if v_fix = 1 then
		mensaje := mensaje || ' ;  Fixed ' || totalFixed::text;
	end if;
	raise notice '%', mensaje;

	--adicionales := '';

	return query select resultado, mensaje/*, adicionales*/;

exception
	when others then
		resultado := 0;
		mensaje := 'fix_kdm5() ' || '['|| sqlstate || '] ' || sqlerrm;
		--adicionales := '';
		return query select resultado, mensaje/*, adicionales*/;

END;
$function$
