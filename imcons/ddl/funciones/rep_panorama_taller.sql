CREATE OR REPLACE FUNCTION keplersc.rep_panorama_taller(dataxml xml)
 RETURNS TABLE(ords_pendientes text, ords_activas text, ords_suspendidas text, ords_terminadas text, ords_cerradas text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Genera la informacion para el reporte de Panorama Taller
--Autor: Luis Leal
--Fecha: 16/08/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	fecha_orden date;
	folio_orden text;
	tipo_orden text;
	flujo_srv numeric;
	nombre_cli text;
	asesor text;

	refacciones numeric;
	tots numeric;
	cargos_varios numeric;
	mano_de_obra numeric ;
	subtotal numeric;
	iva numeric;
	total numeric;
	dias numeric;
	xml_ords text;
	contador_ords int = 0;

	xml_str text;
	xml_ords_pendientes text ;
	contador_ords_pendientes int = 0;
	xml_ords_activas text ;
	contador_ords_activas int = 0;
	xml_ords_suspendidas text ;
	contador_ords_suspendidas int = 0;
	xml_ords_terminadas text ;
	contador_ords_terminadas int = 0;
	xml_ords_cerradas text ;
	contador_ords_cerradas int = 0;

	xmlResultado xml;


	--Variables de retorno

begin
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];

	xml_str := '<r%1$s><fecha_orden>%2$s</fecha_orden><folio_orden>%3$s</folio_orden><nombre_cli>%4$s</nombre_cli>
			<mano_de_obra>%5$s</mano_de_obra><refacciones>%6$s</refacciones><tots>%7$s</tots><cargos_varios>%8$s</cargos_varios>
			<subtotal>%9$s</subtotal><iva>%10$s</iva><total>%11$s</total><dias>%12$s</dias><asesor>%13$s</asesor></r%1$s>';

	for tipo_orden,folio_orden,fecha_orden,flujo_srv, nombre_cli, asesor in select c2,c3,c4::date,c8::numeric,c11,c22 from keplersc.kdord 
	where c1=sucursal_id --and c4 >= current_date - 365
	loop 
		
		select sum(hrs.c8 * hrs.c14) into mano_de_obra from keplersc.kdhoras as hrs where hrs.c1=sucursal_id and hrs.c2=tipo_orden and hrs.c3=folio_orden;
		if mano_de_obra is null then
			mano_de_obra := 0.00;
		end if;	
	
		select sum(c16) into refacciones from keplersc.kdref where c1=sucursal_id and c2=tipo_orden and c3=folio_orden;
		if refacciones is null then
			refacciones := 0.00;
		end if;
	
		select sum(c16) into tots from keplersc.kdtot where c1=sucursal_id and c2=tipo_orden and c3=folio_orden;
		if tots is null then
			tots := 0.00;
		end if;
	
		select sum(c10) into cargos_varios from keplersc.kdcar where c1=sucursal_id and c2=tipo_orden and c3=folio_orden;
		if cargos_varios is null then
			cargos_varios := 0.00;
		end if;
		
		subtotal := refacciones + tots + cargos_varios + mano_de_obra;
	
		iva := subtotal * (0.16);
	
		total := subtotal + iva; 
			
		dias := current_date - fecha_orden;		
	
		if flujo_srv = 0 then
			xml_ords_pendientes :=  concat(xml_ords_pendientes,format( xml_str, contador_ords_pendientes ,fecha_orden,concat(tipo_orden, ' ', folio_orden), 
			nombre_cli,mano_de_obra,refacciones,tots,cargos_varios, subtotal, iva, total, dias, asesor));	
			contador_ords_pendientes := contador_ords_pendientes + 1;
		end if;
	
		if flujo_srv = 10 then
			xml_ords_activas :=  concat(xml_ords_activas,format( xml_str, contador_ords_activas ,fecha_orden,concat(tipo_orden, ' ', folio_orden), 
			nombre_cli,mano_de_obra,refacciones,tots,cargos_varios, subtotal, iva, total, dias, asesor));	
			contador_ords_activas := contador_ords_activas + 1;
		end if;
	
		if flujo_srv = 20 then
			xml_ords_suspendidas :=  concat(xml_ords_suspendidas,format( xml_str, contador_ords_suspendidas ,fecha_orden,concat(tipo_orden,' ', folio_orden), 
			nombre_cli,mano_de_obra,refacciones,tots,cargos_varios, subtotal, iva, total, dias, asesor));	
			contador_ords_suspendidas := contador_ords_suspendidas + 1;
		end if;
	
		if flujo_srv = 30 then
			xml_ords_terminadas :=  concat(xml_ords_terminadas,format( xml_str, contador_ords_terminadas ,fecha_orden,concat(tipo_orden,' ', folio_orden), 
			nombre_cli,mano_de_obra,refacciones,tots,cargos_varios, subtotal, iva, total, dias, asesor));	
			contador_ords_terminadas := contador_ords_terminadas + 1;
		end if;
	
		if flujo_srv = 40 then
			xml_ords_cerradas :=  concat(xml_ords_cerradas,format( xml_str, contador_ords_cerradas ,fecha_orden,concat(tipo_orden,' ', folio_orden), 
			nombre_cli,mano_de_obra,refacciones,tots,cargos_varios, subtotal, iva, total, dias, asesor));	
			contador_ords_cerradas := contador_ords_cerradas + 1;
		end if;
	
	end loop;
	
	return query
	select xml_ords_pendientes, xml_ords_activas, xml_ords_suspendidas, xml_ords_terminadas, xml_ords_cerradas;

	

exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
