CREATE OR REPLACE FUNCTION keplersc.actualizamovtoscaja(sucursal_id text, genero text, naturaleza text, grupo integer, tipo integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: Actualiza el registro de los pagos cuando tiene una susutitucion o anulacion
--Autor: Miriam Santana
--Fecha: 12/03/2026
--Bitacora de cambios
declare
	expSql text = '';
	estatus_actual text;
	xmlKDMM xml;

	--Variables Loop
	strValor text ='';
	varXml xml;
	strError text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	intValor int = 0;

	rec record;
begin
	/*
Paso1
Configurar caja del movto en kdmm.c14='S' kdmm.c51='I'
Leer los UD1003
Armar xml
Enviar reg kdmm
Ejecutar funcion

**/
raise notice 'Inicio';
		
		expSql = 'select * from keplersc.kdmm where col_sucursal='|| E'\'' || sucursal_id || E'\'' || ' and c1='  || E'\'' || genero || E'\'' ||
					' and c2=' || E'\'' || naturaleza || E'\'' || ' and c3=' || grupo || ' and c4=' || tipo;		

		for rec in select * from keplersc.kdm1 where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo and c5 = tipo		--Movtos que no generaron caja
		loop
			select query_to_xml(expSql, true, false, '') into xmlKDMM;
			--raise notice '%',xmlKDMM;
			select xmlforest(xmlforest(rec.c1 as r1) as k_sucn, xmlforest(rec.c2 as r1, rec.c3 as r2, rec.c4 as r3, rec.c5 as r4) as k_tipon,
				 rec.c9 as k_fecha, rec.c6 as folio_operacion, rec.c16 as k_monto, '0' as k_montoanticipo)::text into strValor;					  
			select '<document>'||strValor||'</document>' into strValor;
			varXml := strValor::xml;

			raise notice '%',varXml;
		
			select * into resultado, mensaje, adicionales from keplersc.caja_alta(varXml, xmlKDMM, rec.c6);
			if resultado = '0' then
				strError := strError || rec.c6 || ',';
				continue;
			end if;
			
		end loop;
--raise exception 'Alto manual';
		raise notice 'Errores:%',strError; 
return 1;

end;
$function$
