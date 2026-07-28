CREATE OR REPLACE FUNCTION keplersc.tmkt_actualiza_cliente()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$

declare
	estado_movto text;

	--Variables Loop
	cve_cliente text='';
	cve_cliente2 text ='';
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	intValor int = 0;

	rec record;
begin
	/*
si c8 <>0 y el c20 is null
si tiene cita con el c15 en kdctasser traigo la clave de cliente select into y la actualizo
else
si no tiene cita en kdtkmtser2 busco la serie y si el c20 no es null lo select into y actualizo
si es null el c20 de la serie busco la serie en kd ord y me traigo el ultimo

y tambien para los c8=0 y c20 is null
*/
raise notice 'Inicio';
		for rec in select * from keplersc.kdtmktser2 where c8<>0 and c20 is null
		loop
			raise notice '1.Folio:%, Cliente:%',rec.c2,rec.c20;
			select c20 into cve_cliente from keplersc.kdtmktser2 where c14=rec.c14 and c20 is not null limit 1;
				if found then 
					--actualizo
					raise notice 'CON Cliente tmktser2 (KDTMKTSER2):%',cve_cliente;
					update keplersc.kdtmktser2 set c20=cve_cliente
						where c1=rec.c1 and c2=rec.c2;
				else 
					select c10 into cve_cliente from keplersc.kdord where c6=rec.c14 order by c4 desc limit 1;
						if found then
							raise notice 'Sin Cliente en tmktser2 (KDORD):%',cve_cliente;
							update keplersc.kdtmktser2 set c20=cve_cliente
								where c1=rec.c1 and c2=rec.c2;
						end if;
				end if;
			
			cve_cliente :='';
		cve_cliente2:='';
		end loop;
		for rec in select * from keplersc.kdtmktser2 where c8=0 and c20 is null
		loop
			raise notice '2.Folio:%, Cliente:%',rec.c2,rec.c20;
			select c20 into cve_cliente from keplersc.kdtmktser2 where c14=rec.c14 and c20 is not null limit 1;
			if found then 
				--actualizo
				raise notice 'CON Cliente tmktser2 (KDTMKTSER2):%',cve_cliente;
				update keplersc.kdtmktser2 set c20=cve_cliente
					where c1=rec.c1 and c2=rec.c2;
			else 
				select c10 into cve_cliente from keplersc.kdord where c6=rec.c14 order by c4 desc limit 1;
				if found then
				raise notice 'Sin Cliente en tmktser2 (KDORD):%',cve_cliente;
					update keplersc.kdtmktser2 set c20=cve_cliente
						where c1=rec.c1 and c2=rec.c2;
				end if;
			end if;
		cve_cliente :='';
		cve_cliente2:='';
		end loop;
return 1;

end;
$function$
