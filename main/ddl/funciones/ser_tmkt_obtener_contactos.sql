CREATE OR REPLACE FUNCTION keplersc.ser_tmkt_obtener_contactos(sucursal_id text, asesor text, contactos text, motivo text, fec_prog_ini text, fec_prog_fin text)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
--Descripcion: Esta funcion obtiene los contactos de telemarketing
--   y regresa el registro.
--Autor: Miriam Santana
--Fecha: 21/08/2023
--Bitacora de cambios
declare 
	--Variables de proceso
	xmlResultado xml;
	error text = '';
	totReg int = 0;
	sigFolio text ='';
	sqlExp text = '';
	serie text = '';

begin
	
	--raise exception 'suc:% , asesor:%,contactos:%, fec_ini:%,fec_fin:% ',sucursal_id,asesor,contactos,fec_prog_ini,fec_prog_fin;
	--kdserie.c34 medio prederido del contacto resp mantto?
	sqlExp := 'select tmkt.c2 as folio_tmkt,tmkt.c5::date as fecha,substring(tmkt.c5::text,12,5) as hora,''[''||tmkt.c20||''] ''||ud.c3 as cliente, 
			tmkt.c14 as serie,motivo.descripcion as motivo, tmkt.c3 as asesor, ''XXXX''as medio,
			case when tmkt.c10 = ''1800-01-01 00:00:00.000'' or (tmkt.c27 = '''' or tmkt.c27 is null) then ''Sin atender''
			when tmkt.c10 <> ''1800-01-01 00:00:00.000'' and (tmkt.c27 <> '''' or tmkt.c27 is not null) then ''Atendido'' end as estatus,
			resultado.descripcion as resultado, accion.descripcion as accion
			from keplersc.kdtmktser2 tmkt
			inner join keplersc.kdud ud on ud.c1=tmkt.c1 and ud.c2=tmkt.c20 
			inner join keplersc.kdtmktmotivo motivo on motivo.motivo_id = tmkt.c7 
			inner join keplersc.kdtmktresult resultado on resultado.resultado_id = tmkt.c8 
			inner join keplersc.kdtmktaccion accion on accion.accion_id = tmkt.c9
			where tmkt.c1=%1$L and (tmkt.c10 = ''1800-01-01 00:00:00.000'' or (tmkt.c27 = '''' or tmkt.c27 is null))';
	--raise exception '1: %', sqlExp;	
	
	if (contactos <> '') then
		if contactos = 'A' then
			sqlExp = sqlExp || ' and tmkt.c3 <> '''' and tmkt.c3 ''SA''';
		end if;
		if contactos = 'SA' then
			sqlExp = sqlExp || ' and (tmkt.c3 ='''' or tmkt.c3 is null or tmkt.c3 =''SA'')';
		end if;
	end if;
	if (asesor <> '') then
		sqlExp = sqlExp || ' and tmkt.c3 =%2$L';
	end if;
	if (motivo <> '') then
		sqlExp = sqlExp || ' and tmkt.c7 =%5$L';
	end if;
	if (fec_prog_ini <> '') then
		sqlExp = sqlExp || ' and tmkt.c5 >= %3$L';
	end if;	
	if (fec_prog_fin <> '') then
		sqlExp = sqlExp || ' and tmkt.c5 <= %4$L';
	end if;

	sqlExp = format(sqlExp||' order by tmkt.c5, motivo, asesor',sucursal_id,asesor,fec_prog_ini,fec_prog_fin,motivo);	
--raise exception '2: %', sqlExp;	
	select query_to_xml(sqlExp,false,true,'') into xmlResultado;
	return xmlResultado;

exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
