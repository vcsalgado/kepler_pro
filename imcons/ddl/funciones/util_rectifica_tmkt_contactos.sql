CREATE OR REPLACE PROCEDURE keplersc.util_rectifica_tmkt_contactos()
 LANGUAGE plpgsql
AS $procedure$
--Descripcion: Corrige los contactos reasignando NU y validando que no haya duplicados
--Autor: Victor Salgado
--Fecha: 26/10/2025
--Bitacora de cambios
declare 
	totReg numeric = 0;
	strValor text = '';
	recTmkt record;
	asesor text = '';
	contacto text = '';
	tipo text = '';
	cont int =0;
begin


	for recTmkt in select * from keplersc.kdtmktser2 where c22='NU' and c8 = 0  --NU pendientes
	loop 
		select c2,c3 into contacto, asesor from keplersc.kdtmktser2 
			where c14=recTmkt.c14 and c22 <> 'NU' and c3 <> 'SA' and c3 in('GBALDIT','MNANDHO','MSANCHEZ') --and c14='LT054966' 
			order by c24 desc limit 1;
		if recTmkt.c3 <> asesor and asesor <> '' then
			cont = cont + 1;
			--Actualizar registro
--			update keplersc.kdtmktser2 set c3=asesor where c2=recTmkt.c2;
--			commit;
			raise notice '% Rectificando serie:% contacto:% asesor actual NU:% por asesor:%',cont,recTmkt.c14,contacto,recTmkt.c3,asesor;
		end if;
	end loop;


/*
 --Reasignacion de VHERNANDEZ
	cont:=0;
	for recTmkt in select * from keplersc.kdtmktser2 where c22='N-7' and c8 = 0  and c3='VHERNANDEZ'
	loop 
		select c2,c3 into contacto, asesor from keplersc.kdtmktser2 
			where c14=recTmkt.c14  --and c3 <> 'SA' and c3 in('GBALDIT','MNANDHO','MSANCHEZ') --and c14='LT054966' 
			order by c24 desc;  -- limit 1;
--		if recTmkt.c3 <> asesor and asesor <> '' then
			cont = cont + 1;
			--Actualizar registro
--			update keplersc.kdtmktser2 set c3=asesor where c2=recTmkt.c2;
--			commit;
			raise notice '% Rectificando serie:% contacto:% asesor actual NU:% por asesor:%',cont,recTmkt.c14,contacto,recTmkt.c3,asesor;
--		end if;
	end loop;
*/

/*
--	Depurar duplicados
	for recTmkt in select * from keplersc.kdtmktser2 where c22='NU' and c8 = 0  --NU pendientes
	loop 
		select c2,c3 into contacto, asesor, tipo from keplersc.kdtmktser2 
			where c14=recTmkt.c14 and c22 <> 'NU' and c8 = 0 --and c14='LT054966' 
			order by c24 desc limit 1;

		cont = cont + 1;
			--Actualizar registro
--			update keplersc.kdtmktser2 set c3=asesor where c2=recTmkt.c2;
--			commit;
		raise notice '% Eliminando serie:% contacto:% asesor:% tipo:%',cont,recTmkt.c14,contacto,asesor,tipo;
	end loop;
*/

/*
--	Validando ya con cita programada y contactos pendientes
	for recTmkt in select * from keplersc.kdtmktser2 where c22='NU' and c8 = 0  --NU pendientes
	loop 
		select c2,c3 into contacto, asesor, tipo from keplersc.kdtmktser2 
			where c14=recTmkt.c14 and c15 <> '' 
			order by c24 desc limit 1;

		cont = cont + 1;
			--Actualizar registro
--			update keplersc.kdtmktser2 set c3=asesor where c2=recTmkt.c2;
--			commit;
		raise notice '% Eliminando serie:% contacto:% asesor:% tipo:%',cont,recTmkt.c14,contacto,asesor,tipo;
	end loop;
*/

end;
$procedure$
