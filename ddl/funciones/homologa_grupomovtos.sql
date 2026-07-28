CREATE OR REPLACE FUNCTION keplersc.homologa_grupomovtos(genero text, naturaleza text, grupo_ant integer, grupo_nvo integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: Homologa grupo de movimientos de k75 a k80 en tablas de contabilidad
--Autor: Miriam Santana
--Fecha: 13/01/2023
--Bitacora de cambios
declare
	tabla_polizas text;
	expsql text;
	rec record;

	--Variables de retorno
	resultado int = 0;
	
begin
raise notice 'Inicio';
/*
--UD12 POR UD7
--XA5 POR XA4
	genero = 'U';
	naturaleza = 'D';
	grupo_ant = 12;
	grupo_nvo = 7;
*/	
	for rec in select distinct anio,mes from keplersc.kdc2_view
	loop
	--armar la tabla Polizas
		tabla_polizas := 'keplersc.kdc2' || rec.anio || rec.mes;
		
		expSql = format('update %1$s set c17=%2$s where c15=%3$L and c16=%4$L and c17=%5$s',
				 tabla_polizas,grupo_nvo,genero,naturaleza,grupo_ant);
			
		raise notice '%;', expSql;
--		execute expSql;
	
	end loop;
	raise exception 'Alto manual';	
		resultado := 1;
		return resultado;
exception
	when others then
		resultado := 0;
		return resultado;
end;
$function$
