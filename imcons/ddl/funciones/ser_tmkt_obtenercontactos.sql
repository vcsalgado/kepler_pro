CREATE OR REPLACE FUNCTION keplersc.ser_tmkt_obtenercontactos(dataxml xml)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
--Descripcion: Esta funcion obtiene los contactos de telemarketing
--   y regresa el registro.
--Autor: Miriam Santana
--Fecha: 21/08/2023
--Bitacora de cambios
declare 
	--Variables de documento
	sucursal_id text ='';
	asesor text =''; 
	contactos text ='';
	motivo text ='';
	fec_prog_ini text ='';
	fec_prog_fin text ='';
	fecha_valeserv_ini text ='';
	fecha_valeserv_fin text ='';
	tipo_n text ='';

	--Variables de proceso
	xmlResultado xml;
	error text = '';
	totReg int = 0;
	sigFolio text ='';
	sqlExp text = '';
	serie text = '';

begin
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	asesor := (xpath('//document/asesor/text()', dataxml))[1]; 
	contactos := (xpath('//document/contactos/text()', dataxml))[1]; 
	motivo := (xpath('//document/motivo/text()', dataxml))[1]; 
	fec_prog_ini := (xpath('//document/fec_prog_ini/text()', dataxml))[1]; 
	fec_prog_fin := (xpath('//document/fec_prog_fin/text()', dataxml))[1]; 
	fecha_valeserv_ini := (xpath('//document/fecha_valeserv_ini/text()', dataxml))[1]; 
	fecha_valeserv_fin := (xpath('//document/fecha_valeserv_fin/text()', dataxml))[1]; 
	tipo_n := (xpath('//document/tipo_n/text()', dataxml))[1]; 
 
raise notice 'suc:% , asesor:%,contactos:%, fec_ini:%,fec_fin:% fecvaleini:%, fecvalefin:%, tipo_n:%',sucursal_id,asesor,contactos,fec_prog_ini,fec_prog_fin,fecha_valeserv_ini,fecha_valeserv_fin,tipo_n;
	--kdserie.c34 medio prederido del contacto resp mantto?
	sqlExp := 'select tmkt.c2 as folio_tmkt,to_char(tmkt.c5, ''DD/MM/YYYY'') as fecha,substring(tmkt.c5::text,12,5) as hora,''[''||tmkt.c20||''] ''||ud.c3 as cliente, 
			tmkt.c14 as serie,motivo.descripcion as motivo, tmkt.c3 as asesor, tmkt.c22 as tipo_n, to_char(tmkt.c26, ''DD/MM/YYYY'') as vale_salida_ult_srv, ''XXXX''as medio,
			case when tmkt.c8 = 0 then ''Sin atender''
			when tmkt.c8 <> 0 then ''Atendido'' end as estatus,
			resultado.descripcion as resultado, accion.descripcion as accion
			from keplersc.kdtmktser2 tmkt
			inner join keplersc.kdud ud on ud.c2=tmkt.c20 
			inner join keplersc.kdtmktmotivo motivo on motivo.motivo_id = tmkt.c7 
			inner join keplersc.kdtmktresult resultado on resultado.resultado_id = tmkt.c8 
			inner join keplersc.kdtmktaccion accion on accion.accion_id = tmkt.c9
			where tmkt.c1=%1$L and tmkt.c8 = 0';
raise notice '1: %', sqlExp;	
	
	if (contactos <> '') then
		if contactos = 'A' then
			sqlExp = sqlExp || ' and tmkt.c3 <> '''' and tmkt.c3 <>''SA''';
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
	if (fecha_valeserv_ini <> '') then
		sqlExp = sqlExp || ' and tmkt.c26 >= %6$L';
	end if;	
	if (fecha_valeserv_fin <> '') then
		sqlExp = sqlExp || ' and tmkt.c26 <= %7$L';
	end if;
	if (tipo_n <> '') then
		sqlExp = sqlExp || ' and tmkt.c22 = %8$L';
	end if;

	sqlExp = format(sqlExp||' order by tmkt.c5, motivo, asesor',sucursal_id,asesor,fec_prog_ini,fec_prog_fin,motivo,fecha_valeserv_ini,fecha_valeserv_fin,tipo_n);	
raise notice '2: %', sqlExp;	
	select query_to_xml(sqlExp,false,true,'') into xmlResultado;
	return xmlResultado;

exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
