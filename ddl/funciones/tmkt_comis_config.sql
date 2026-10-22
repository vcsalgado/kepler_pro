CREATE OR REPLACE FUNCTION keplersc.tmkt_comis_config(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Crud para configurar la tablas de comisiones de tmkt
--Autor: Victor Salgado
--Fecha: 14/09/2026
--Bitacora de cambios
declare
	lim_inf text = '';
	lim_sup text = '';
	comision text = '';
	paquete text='';
	no_partidas int = 0;
	strValor text = '';
	cont int = 0;

	limite_inferior numeric=0.00;
	limite_superior numeric=0.00;
	ult_limite_inferior numeric=0.00;
	ult_limite_superior numeric=0.00;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin

	--Comisiones proactivas

	strValor:=coalesce((xpath('//document/k_partidas_pro/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;
	no_partidas:=no_partidas-1;
--raise exception 'no_partidas:%',no_partidas;
	--Eliminar registrados asociados con el tipo de comision seleccionado
	delete from keplersc.kdctascomis;

	for cont in 0..no_partidas loop
		lim_inf:=coalesce((xpath('//document/k_comis_pro/r' ||cont||'/lim_inf/text()',dataxml))[1],'0');
		lim_sup:=coalesce((xpath('//document/k_comis_pro/r' ||cont||'/lim_sup/text()',dataxml))[1],'0');
		comision:=coalesce((xpath('//document/k_comis_pro/r' ||cont||'/comis_pro/text()',dataxml))[1],'0');
		limite_inferior:=lim_inf::numeric;
		limite_superior:=lim_sup::numeric;
		
		if limite_inferior = 0 and limite_superior = 0 then
			raise exception 'Debe escoger un límite inferior y superior para el registro %' ,  cont + 1; 
		end if;
	
		if limite_inferior > limite_superior then
			raise exception 'El límite inferior del registro % no puede ser mayor que el limite superior' ,  cont + 1; 
		end if;
	
		if ult_limite_inferior <> 0 and ult_limite_superior <> 0 then 
			if limite_inferior <= ult_limite_inferior or limite_inferior <= ult_limite_superior or 
			limite_superior <= ult_limite_inferior or limite_superior <= ult_limite_superior then 
				raise exception 'Los límites inferiores y superiores del registro % deben ser mayores que los límites del registro anterior' ,  cont + 1; 
			end if;
		end if;
	
		insert into keplersc.kdctascomis(c1,c2,c3)
		values(limite_inferior,limite_superior,comision::numeric);
		ult_limite_inferior := limite_inferior;
		ult_limite_superior := limite_superior;
	end loop;


	--Comisiones pasivas
	strValor:=coalesce((xpath('//document/k_partidas_pas/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;
	no_partidas:=no_partidas-1;

	--Eliminar registrados asociados con el tipo de comision seleccionado
	delete from keplersc.kdctascomispasivas;

	comision:=coalesce((xpath('//document/k_comis_pas/r' ||cont||'/comis_pas/text()',dataxml))[1],'0');
	insert into keplersc.kdctascomispasivas(c1,c2)
	values(1,comision::numeric);


	--Comisiones Paquetes
	strValor:=coalesce((xpath('//document/k_partidas_paq/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;
	no_partidas:=no_partidas-1;

	--Eliminar registrados
	delete from keplersc.kdctascomispaq;

	for cont in 0..no_partidas loop
		paquete:=coalesce((xpath('//document/k_comis_paq/r' ||cont||'/paquete/text()',dataxml))[1],'0');
		comision:=coalesce((xpath('//document/k_comis_paq/r' ||cont||'/comis_paq/text()',dataxml))[1],'0');

		insert into keplersc.kdctascomispaq(c1,c2)
		values(paquete, comision::numeric) on conflict do nothing;
	end loop;


	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'tmkt_comis_config() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
