CREATE OR REPLACE FUNCTION keplersc.ser_tmkt_cons_resultados_contactos(dataxml xml)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
--Descripcion: Obtiene información para reporte enviado a toyota
--Autor: Miriam Santana
--Fecha: 02/01/2024
--Bitacora de cambios
declare
	sucursal_id text;
	fecha_ini text;
	fecha_fin text;

	--variables para armar tabla
	folio_tmkt_n30 text= '';
	asesor_n30 text= '';
	fec_prog_n30 date;
	mot_n30 int;
	descmot_n30 text= '';
	tipo_n30 text= '';
	fec_contacto_n30 date;
	res_n30 int;
	descres_n30 text= '';
	acc_n30 int;
	descacc_n30 text= '';
	m_contacto_n30 text;
	obs_n30 text= '';
	fec_creacion_n30 date;
	folio_cita_n30 text= '';
	estatus_cita_n30 int;
	descestatus_cita_n30 text;
	tipo_orden_n30 text= '';
	folio_orden_n30 text= '';
	origen_n30 text= '';

	folio_tmkt_n15 text= '';
	asesor_n15 text= '';
	fec_prog_n15 date;
	mot_n15 int;
	descmot_n15 text= '';
	tipo_n15 text= '';
	fec_contacto_n15 date;
	res_n15 int;
	descres_n15 text= '';
	acc_n15 int;
	descacc_n15 text= '';
	m_contacto_n15 text;
	obs_n15 text= '';
	fec_creacion_n15 date;
	folio_cita_n15 text= '';
	estatus_cita_n15 int;
	descestatus_cita_n15 text;
	tipo_orden_n15 text= '';
	folio_orden_n15 text= '';
	origen_n15 text= '';

	folio_tmkt_n7 text= '';
	asesor_n7 text= '';
	fec_prog_n7 date;
	mot_n7 int;
	descmot_n7 text= '';
	tipo_n7 text= '';
	fec_contacto_n7 date;
	res_n7 int;
	descres_n7 text= '';
	acc_n7 int;
	descacc_n7 text= '';
	m_contacto_n7 text;
	obs_n7 text= '';
	fec_creacion_n7 date;
	folio_cita_n7 text= '';
	estatus_cita_n7 int;
	descestatus_cita_n7 text;
	tipo_orden_n7 text= '';
	folio_orden_n7 text= '';
	origen_n7 text= '';
	
	folio_tmkt_n3 text= '';
	asesor_n3 text= '';
	fec_prog_n3 date;
	mot_n3 int;
	descmot_n3 text= '';
	tipo_n3 text= '';
	fec_contacto_n3 date;
	res_n3 int;
	descres_n3 text= '';
	acc_n3 int;
	descacc_n3 text= '';
	m_contacto_n3 text;
	obs_n3 text= '';
	fec_creacion_n3 date;
	folio_cita_n3 text= '';
	estatus_cita_n3 int;
	descestatus_cita_n3 text;
	tipo_orden_n3 text= '';
	folio_orden_n3 text= '';
	origen_n3 text= '';

	folio_tmkt_n1 text= '';
	asesor_n1 text= '';
	fec_prog_n1 date;
	mot_n1 int;
	descmot_n1 text= '';
	tipo_n1 text= '';
	fec_contacto_n1 date;
	res_n1 int;
	descres_n1 text= '';
	acc_n1 int;
	descacc_n1 text= '';
	m_contacto_n1 text;
	obs_n1 text= '';
	fec_creacion_n1 date;
	folio_cita_n1 text= '';
	estatus_cita_n1 int;
	descestatus_cita_n1 text;
	tipo_orden_n1 text= '';
	folio_orden_n1 text= '';
	origen_n1 text= '';

	folio_tmkt_nu text= '';
	asesor_nu text= '';
	fec_prog_nu date;
	mot_nu int;
	descmot_nu text= '';
	tipo_nu text= '';
	fec_contacto_nu date;
	res_nu int;
	descres_nu text= '';
	acc_nu int;
	descacc_nu text= '';
	m_contacto_nu text;
	obs_nu text= '';
	fec_creacion_nu date;
	folio_cita_nu text= '';
	estatus_cita_nu int;
	descestatus_cita_nu text;
	tipo_orden_nu text= '';
	folio_orden_nu text= '';
	origen_nu text= '';

	vin_8 text= '';
	serie text= '';
	cve_cliente text= '';
	fec_vale_ultserv date;


	--Variables de retorno
	get_resultado text;
	get_mensaje text; 
	get_adicionales text;

	--Variables de proceso
	xmlResultado xml;
	sqlExp text = '';
	rec record;
begin
raise notice 'Inicio';

	drop table if exists tmpContactos;
	create temp table tmpContactos (
	vin_8 text,
	serie text,
	cve_cliente text,
	fec_vale_ultserv date,

	folio_tmkt_n30 text,
	asesor_n30 text,
	fec_prog_n30 date,
	mot_n30 int,
	descmot_n30 text,
	tipo_n30 text,
	fec_contacto_n30 date,
	res_n30 int,
	descres_n30 text,
	acc_n30 int,
	descacc_n30 text,
	m_contacto_n30 text,
	obs_n30 text,
	fec_creacion_n30 date,
	folio_cita_n30 text,
	estatus_cita_n30 int,
	descestatus_cita_n30 text,
	tipo_orden_n30 text,
	folio_orden_n30 text,
	origen_n30 text,

	folio_tmkt_n15 text,
	asesor_n15 text,
	fec_prog_n15 date,
	mot_n15 int,
	descmot_n15 text,
	tipo_n15 text,
	fec_contacto_n15 date,
	res_n15 int,
	descres_n15 text,
	acc_n15 int,
	descacc_n15 text,
	m_contacto_n15 text,
	obs_n15 text,
	fec_creacion_n15 date,
	folio_cita_n15 text,
	estatus_cita_n15 int,
	descestatus_cita_n15 text,
	tipo_orden_n15 text,
	folio_orden_n15 text,
	origen_n15 text,
	
	folio_tmkt_n7 text,
	asesor_n7 text,
	fec_prog_n7 date,
	mot_n7 int,
	descmot_n7 text,
	tipo_n7 text,
	fec_contacto_n7 date,
	res_n7 int,
	descres_n7 text,
	acc_n7 int,
	descacc_n7 text,
	m_contacto_n7 text,
	obs_n7 text,
	fec_creacion_n7 date,
	folio_cita_n7 text,
	estatus_cita_n7 int,
	descestatus_cita_n7 text,
	tipo_orden_n7 text,
	folio_orden_n7 text,
	origen_n7 text,
	
	folio_tmkt_n3 text,
	asesor_n3 text,
	fec_prog_n3 date,
	mot_n3 int,
	descmot_n3 text,
	tipo_n3 text,
	fec_contacto_n3 date,
	res_n3 int,
	descres_n3 text,
	acc_n3 int,
	descacc_n3 text,
	m_contacto_n3 text,
	obs_n3 text,
	fec_creacion_n3 date,
	folio_cita_n3 text,
	estatus_cita_n3 int,
	descestatus_cita_n3 text,
	tipo_orden_n3 text,
	folio_orden_n3 text,
	origen_n3 text,
	
	folio_tmkt_n1 text,
	asesor_n1 text,
	fec_prog_n1 date,
	mot_n1 int,
	descmot_n1 text,
	tipo_n1 text,
	fec_contacto_n1 date,
	res_n1 int,
	descres_n1 text,
	acc_n1 int,
	descacc_n1 text,
	m_contacto_n1 text,
	obs_n1 text,
	fec_creacion_n1 date,
	folio_cita_n1 text,
	estatus_cita_n1 int,
	descestatus_cita_n1 text,
	tipo_orden_n1 text,
	folio_orden_n1 text,
	origen_n1 text,
	
	folio_tmkt_nu text,
	asesor_nu text,
	fec_prog_nu date,
	mot_nu int,
	descmot_nu text,
	tipo_nu text,
	fec_contacto_nu date,
	res_nu int,
	descres_nu text,
	acc_nu int,
	descacc_nu text,
	m_contacto_nu text,
	obs_nu text,
	fec_creacion_nu date,
	folio_cita_nu text,
	estatus_cita_nu int,
	descestatus_cita_nu text,
	tipo_orden_nu text,
	folio_orden_nu text,
	origen_nu text
	);

	sucursal_id := ((xpath('//document/sucursal_id/text()', dataxml))[1]::text)::text;
	fecha_ini := ((xpath('//document/fecha_ini/text()', dataxml))[1]::text)::text;
	fecha_fin := ((xpath('//document/fecha_fin/text()', dataxml))[1]::text)::text;
	raise notice 'fecha_ini:% fecag_fin:%',fecha_ini,fecha_fin;
	--Folio tmkt con citas agendadtas
	for rec in select c1,c14,c20,c26 from keplersc.kdtmktser2 k 
		where c1=sucursal_id and c8<>21 /*cancelado*/ and c23 =0 /*Llamada */ and c7 <>30/*Confirmacion cita*/ and c7<>40/*Seguimiento No show*/ 
		and c5 >=fecha_ini::date and c5 <=fecha_fin::date
		group by c1,c14,c5,c20,c26
		order by c5 
		loop

			select c4 into serie from keplersc.kdserie where c1= rec.c14;
			cve_cliente := rec.c20;
			fec_vale_ultserv := rec.c26;
			vin_8 := rec.c14;
raise notice 'Paso1 vin_8:% serie:%, cliente:% fechaval/ultserv:%',rec.c14,serie,rec.c20,rec.c26;	

raise notice 'Paso n-30';
			--N-30	
			select tmkt.c2,tmkt.c3,tmkt.c5,tmkt.c7,mtv.descripcion,tmkt.c22,tmkt.c10,tmkt.c8, res.descripcion,
				tmkt.c9,acc.descripcion,medc.c2,
				concat(regexp_replace(tmkt.c11,'\r|\n',' ', 'g'),' ',regexp_replace(tmkt.c12,'\r|\n',' ', 'g'),' ',regexp_replace(tmkt.c13,'\r|\n',' ', 'g')),
				tmkt.c24, tmkt.c15, ctas.c20,
				case when ctas.c20=0 then 'Pendiente' 
					when ctas.c20=10 then 'Confirmada' 
					when ctas.c20=20 then 'Concretada' 
					when ctas.c20=30 then 'Reprogramada'
					when ctas.c20=40 then 'Cancelada'
					when ctas.c20=50 then 'No Show' end, 
				ctas.c21, ctas.c22,tmkt.c25
				into folio_tmkt_n30, asesor_n30, fec_prog_n30, mot_n30, descmot_n30, tipo_n30, fec_contacto_n30,res_n30, descres_n30,
				acc_n30, descacc_n30,m_contacto_n30, obs_n30,
				fec_creacion_n30, folio_cita_n30, estatus_cita_n30, descestatus_cita_n30, tipo_orden_n30, folio_orden_n30, origen_n30
				from keplersc.kdtmktser2 tmkt
				left join keplersc.kdctasser ctas on ctas.c2=tmkt.c15
				inner join keplersc.kdtmktmotivo as mtv on tmkt.c7=mtv.motivo_id
				inner join keplersc.kdtmktresult as res on tmkt.c8=res.resultado_id 
				inner join keplersc.kdtmktaccion as acc on tmkt.c9 = acc.accion_id 
				inner join keplersc.kdmediocontacto as medc on tmkt.c23=medc.c1 
				where  tmkt.c1=sucursal_id and tmkt.c14=rec.c14 and tmkt.c22='N-30' and tmkt.c8<>21 /*cancelado*/ and tmkt.c7 <>30/*Confirmacion cita*/ 
				and tmkt.c7<>40/*Seguimiento No show*/ and tmkt.c5 >=fecha_ini::date and tmkt.c5 <=fecha_fin::date  --c24-fecha_creacion o c5-fecha_contacto
				and (ctas.c20<> 40 and ctas.c20<> 30 or ctas.c20 is null)
				order by tmkt.c5 desc limit 1;

raise notice 'vin_8:%,serie:%,cve_cliente:%,fec_vale_ultserv:%,folio_tmkt_n30:%,
				asesor_n30:%,fec_prog_n30:%,mot_n30:%,descmot_n30:%,tipo_n30:%,
				fec_contacto_n30:%,res_n30:%,descres_n30:%,acc_n30:%,descacc_n30:%,
				m_contacto_n30:%,obs_n30:%,fec_creacion_n30:%,folio_cita_n30:%,estatus_cita_n30:%,
				descestatus_cita_n30:%,tipo_orden_n30:%,folio_orden_n30:%,origen_n30:%,'
				,vin_8,serie,cve_cliente,fec_vale_ultserv,folio_tmkt_n30,
				asesor_n30,fec_prog_n30,mot_n30,descmot_n30,tipo_n30,
				fec_contacto_n30,res_n30,descres_n30,acc_n30,descacc_n30,
				m_contacto_n30,obs_n30,fec_creacion_n30,folio_cita_n30,estatus_cita_n30,
				descestatus_cita_n15,tipo_orden_n30,folio_orden_n30,origen_n30;			
raise notice 'Paso n-15';
			--N-15	
			select tmkt.c2,tmkt.c3,tmkt.c5,tmkt.c7,mtv.descripcion,tmkt.c22,tmkt.c10,tmkt.c8, res.descripcion,
				tmkt.c9,acc.descripcion,medc.c2,
				concat(regexp_replace(tmkt.c11,'\r|\n',' ', 'g'),' ',regexp_replace(tmkt.c12,'\r|\n',' ', 'g'),' ',regexp_replace(tmkt.c13,'\r|\n',' ', 'g')),
				tmkt.c24, tmkt.c15, ctas.c20,
				case when ctas.c20=0 then 'Pendiente' 
					when ctas.c20=10 then 'Confirmada' 
					when ctas.c20=20 then 'Concretada' 
					when ctas.c20=30 then 'Reprogramada'
					when ctas.c20=40 then 'Cancelada'
					when ctas.c20=50 then 'No Show' end,  
				ctas.c21, ctas.c22,tmkt.c25
				into folio_tmkt_n15, asesor_n15, fec_prog_n15, mot_n15, descmot_n15, tipo_n15, fec_contacto_n15,res_n15, descres_n15,
				acc_n15, descacc_n15, m_contacto_n15, obs_n15,
				fec_creacion_n15, folio_cita_n15, estatus_cita_n15, descestatus_cita_n15, tipo_orden_n15, folio_orden_n15, origen_n15
				from keplersc.kdtmktser2 tmkt
				left join keplersc.kdctasser ctas on ctas.c2=tmkt.c15
				inner join keplersc.kdtmktmotivo as mtv on tmkt.c7=mtv.motivo_id
				inner join keplersc.kdtmktresult as res on tmkt.c8=res.resultado_id 
				inner join keplersc.kdtmktaccion as acc on tmkt.c9 = acc.accion_id 
				inner join keplersc.kdmediocontacto as medc on tmkt.c23=medc.c1 
				where  tmkt.c1=sucursal_id and tmkt.c14=rec.c14 and tmkt.c22='N-15' and tmkt.c8<>21 /*cancelado*/ and tmkt.c7 <>30/*Confirmacion cita*/ 
				and tmkt.c7<>40/*Seguimiento No show*/ and tmkt.c5 >=fecha_ini::date and tmkt.c5 <=fecha_fin::date 
				and (ctas.c20<> 40 and ctas.c20<> 30 or ctas.c20 is null)
				order by tmkt.c5 desc limit 1;
			
raise notice 'vin_8:%,serie:%,cve_cliente:%,fec_vale_ultserv:%,folio_tmkt_n15:%,
				asesor_n15:%,fec_prog_n15:%,mot_n15:%,descmot_n15:%,tipo_n15:%,
				fec_contacto_n15:%,res_n15:%,descres_n15:%,acc_n15:%,descacc_n15:%,
				m_contacto_n15:%,obs_n15:%,fec_creacion_n15:%,folio_cita_n15:%,estatus_cita_n15:%,
				descestatus_cita_n15:%,tipo_orden_n15:%,folio_orden_n15:%,origen_n15:%'
				,vin_8,serie,cve_cliente,fec_vale_ultserv,folio_tmkt_n15,
				asesor_n15,fec_prog_n15,mot_n15,descmot_n15,tipo_n15,
				fec_contacto_n15,res_n15,descres_n15,acc_n15,descacc_n15,
				m_contacto_n15,obs_n15,fec_creacion_n15,folio_cita_n15,estatus_cita_n15,
				descestatus_cita_n30,tipo_orden_n15,folio_orden_n15,origen_n15;	
raise notice 'Paso n-7';			
			--N-7	
			select tmkt.c2,tmkt.c3,tmkt.c5,tmkt.c7,mtv.descripcion,tmkt.c22,tmkt.c10,tmkt.c8, res.descripcion,
				tmkt.c9,acc.descripcion, medc.c2,
				concat(regexp_replace(tmkt.c11,'\r|\n',' ', 'g'),' ',regexp_replace(tmkt.c12,'\r|\n',' ', 'g'),' ',regexp_replace(tmkt.c13,'\r|\n',' ', 'g')),
				tmkt.c24, tmkt.c15, ctas.c20,
				case when ctas.c20=0 then 'Pendiente' 
					when ctas.c20=10 then 'Confirmada' 
					when ctas.c20=20 then 'Concretada' 
					when ctas.c20=30 then 'Reprogramada'
					when ctas.c20=40 then 'Cancelada'
					when ctas.c20=50 then 'No Show' end,  
				ctas.c21, ctas.c22,tmkt.c25
				into folio_tmkt_n7, asesor_n7, fec_prog_n7, mot_n7, descmot_n7, tipo_n7, fec_contacto_n7,res_n7, descres_n7, 
				acc_n7, descacc_n7, m_contacto_n7, obs_n7,
				fec_creacion_n7, folio_cita_n7, estatus_cita_n7, descestatus_cita_n7, tipo_orden_n7, folio_orden_n7, origen_n7
				from keplersc.kdtmktser2 tmkt
				left join keplersc.kdctasser ctas on ctas.c2=tmkt.c15
				inner join keplersc.kdtmktmotivo as mtv on tmkt.c7=mtv.motivo_id
				inner join keplersc.kdtmktresult as res on tmkt.c8=res.resultado_id 
				inner join keplersc.kdtmktaccion as acc on tmkt.c9 = acc.accion_id 
				inner join keplersc.kdmediocontacto as medc on tmkt.c23=medc.c1 
				where  tmkt.c1=sucursal_id and tmkt.c14=rec.c14 and tmkt.c22='N-7' and tmkt.c8<>21 /*cancelado*/ and tmkt.c7 <>30/*Confirmacion cita*/ 
				and tmkt.c7<>40/*Seguimiento No show*/ and tmkt.c5 >=fecha_ini::date and tmkt.c5 <=fecha_fin::date 
				and (ctas.c20<> 40 and ctas.c20<> 30 or ctas.c20 is null)
				order by tmkt.c5 desc limit 1;
			
raise notice 'vin_8:%,serie:%,cve_cliente:%,fec_vale_ultserv:%,folio_tmkt_n7:%,
				asesor_n7:%,fec_prog_n7:%,mot_n7:%,descmot_n7:%,tipo_n7:%,
				fec_contacto_n7:%,res_n7:%,descres_n7:%,acc_n7:%,descacc_n7:%,
				m_contacto_n7:%,obs_n7:%,fec_creacion_n7:%,folio_cita_n7:%,estatus_cita_n7:%,
				descestatus_cita_n7:%,tipo_orden_n7:%,folio_orden_n7:%,origen_n7:%'
				,vin_8,serie,cve_cliente,fec_vale_ultserv,folio_tmkt_n7,
				asesor_n7,fec_prog_n7,mot_n7,descmot_n7,tipo_n7,
				fec_contacto_n7,res_n7,descres_n7,acc_n7,descacc_n7,
				m_contacto_n7,obs_n7,fec_creacion_n7,folio_cita_n7,estatus_cita_n7,
				descestatus_cita_n7,tipo_orden_n7,folio_orden_n7,origen_n7;			
raise notice 'Paso n-3';			
			--N-3	
			select tmkt.c2,tmkt.c3,tmkt.c5,tmkt.c7,mtv.descripcion,tmkt.c22,tmkt.c10,tmkt.c8, res.descripcion,
				tmkt.c9,acc.descripcion, medc.c2,
				concat(regexp_replace(tmkt.c11,'\r|\n',' ', 'g'),' ',regexp_replace(tmkt.c12,'\r|\n',' ', 'g'),' ',regexp_replace(tmkt.c13,'\r|\n',' ', 'g')),
				tmkt.c24, tmkt.c15, ctas.c20,
				case when ctas.c20=0 then 'Pendiente' 
					when ctas.c20=10 then 'Confirmada' 
					when ctas.c20=20 then 'Concretada' 
					when ctas.c20=30 then 'Reprogramada'
					when ctas.c20=40 then 'Cancelada'
					when ctas.c20=50 then 'No Show' end,  
				ctas.c21, ctas.c22,tmkt.c25
				into folio_tmkt_n3, asesor_n3, fec_prog_n3, mot_n3, descmot_n3, tipo_n3, fec_contacto_n3,res_n3, descres_n3,
				acc_n3, descacc_n3, m_contacto_n3, obs_n3,
				fec_creacion_n3, folio_cita_n3, estatus_cita_n3, descestatus_cita_n3, tipo_orden_n3, folio_orden_n3, origen_n3
				from keplersc.kdtmktser2 tmkt
				left join keplersc.kdctasser ctas on ctas.c2=tmkt.c15
				inner join keplersc.kdtmktmotivo as mtv on tmkt.c7=mtv.motivo_id
				inner join keplersc.kdtmktresult as res on tmkt.c8=res.resultado_id 
				inner join keplersc.kdtmktaccion as acc on tmkt.c9 = acc.accion_id 
				inner join keplersc.kdmediocontacto as medc on tmkt.c23=medc.c1 
				where  tmkt.c1=sucursal_id and tmkt.c14=rec.c14 and tmkt.c22='N-3' and tmkt.c8<>21 /*cancelado*/ and tmkt.c7 <>30/*Confirmacion cita*/ 
				and tmkt.c7<>40/*Seguimiento No show*/ and tmkt.c5 >=fecha_ini::date and tmkt.c5 <=fecha_fin::date 
				and (ctas.c20<> 40 and ctas.c20<> 30 or ctas.c20 is null)
				order by tmkt.c5 desc limit 1;
			
raise notice 'vin_8:%,serie:%,cve_cliente:%,fec_vale_ultserv:%,folio_tmkt_n3:%,
				asesor_n3:%,fec_prog_n3:%,mot_n3:%,descmot_n3:%,tipo_n3:%,
				fec_contacto_n3:%,res_n3:%,descres_n3:%,acc_n3:%,descacc_n3:%,
				m_contacto_n3:%,obs_n3:%,fec_creacion_n3:%,folio_cita_n3:%,estatus_cita_n3:%,
				descestatus_cita_n3:%,tipo_orden_n3:%,folio_orden_n3:%,origen_n3:%'
				,vin_8,serie,cve_cliente,fec_vale_ultserv,folio_tmkt_n3,
				asesor_n3,fec_prog_n3,mot_n3,descmot_n3,tipo_n3,
				fec_contacto_n3,res_n3,descres_n3,acc_n3,descacc_n3,
				m_contacto_n3,obs_n3,fec_creacion_n3,folio_cita_n3,estatus_cita_n3,
				descestatus_cita_n3,tipo_orden_n3,folio_orden_n3,origen_n3;	

raise notice 'vin_8:%,serie:%,cve_cliente:%,fec_vale_ultserv:%,folio_tmkt_n3:%,
				asesor_n3:%,fec_prog_n3:%,mot_n3:%,descmot_n3:%,tipo_n3:%,
				fec_contacto_n3:%,res_n3:%,descres_n3:%,acc_n3:%,descacc_n3:%,
				m_contacto_n3:%,obs_n3:%,fec_creacion_n3:%,folio_cita_n3:%,estatus_cita_n3:%,
				descestatus_cita_n3:%,tipo_orden_n3:%,folio_orden_n3:%,origen_n3:%'
				,vin_8,serie,cve_cliente,fec_vale_ultserv,folio_tmkt_n3,
				asesor_n3,fec_prog_n3,mot_n3,descmot_n3,tipo_n3,
				fec_contacto_n3,res_n3,descres_n3,acc_n3,descacc_n3,
				m_contacto_n3,obs_n3,fec_creacion_n3,folio_cita_n3,estatus_cita_n3,
				descestatus_cita_n3,tipo_orden_n3,folio_orden_n3,origen_n3;				
			

raise notice 'Paso n-1';			
			--N-1		--Puede haber mas de 1 reg
			select tmkt.c2 ,tmkt.c3,tmkt.c5,tmkt.c7,mtv.descripcion,tmkt.c22,tmkt.c10,tmkt.c8, res.descripcion,
				tmkt.c9,acc.descripcion, medc.c2,
				concat(regexp_replace(tmkt.c11,'\r|\n',' ', 'g'),' ',regexp_replace(tmkt.c12,'\r|\n',' ', 'g'),' ',regexp_replace(tmkt.c13,'\r|\n',' ', 'g')),
				tmkt.c24, tmkt.c15, ctas.c20,
				case when ctas.c20=0 then 'Pendiente' 
					when ctas.c20=10 then 'Confirmada' 
					when ctas.c20=20 then 'Concretada' 
					when ctas.c20=30 then 'Reprogramada'
					when ctas.c20=40 then 'Cancelada'
					when ctas.c20=50 then 'No Show' end, 
				ctas.c21, ctas.c22,tmkt.c25
				into folio_tmkt_n1, asesor_n1, fec_prog_n1, mot_n1, descmot_n1, tipo_n1, fec_contacto_n1,res_n1, descres_n1,
				acc_n1, descacc_n1, m_contacto_n1, obs_n1,
				fec_creacion_n1, folio_cita_n1, estatus_cita_n1, descestatus_cita_n1,tipo_orden_n1, folio_orden_n1, origen_n1
				from keplersc.kdtmktser2 tmkt
				left join keplersc.kdctasser ctas on ctas.c2=tmkt.c15
				inner join keplersc.kdtmktmotivo as mtv on tmkt.c7=mtv.motivo_id
				inner join keplersc.kdtmktresult as res on tmkt.c8=res.resultado_id 
				inner join keplersc.kdtmktaccion as acc on tmkt.c9 = acc.accion_id 
				inner join keplersc.kdmediocontacto as medc on tmkt.c23=medc.c1 
				where  tmkt.c1=sucursal_id and tmkt.c14=rec.c14 and tmkt.c8<>21/*cancelado*/ and tmkt.c8=50 /*Se agendo cita*/and tmkt.c7 =30/*Confirmacion cita*/ 
				and tmkt.c7<>40/*Seguimiento No show*/ and tmkt.c5 >=fecha_ini::date and tmkt.c5 <=fecha_fin::date 
				and (ctas.c20<> 40 and ctas.c20<> 30 or ctas.c20 is null) /*No este cancelada o reprogramada*/ and ctas.c21 <> 'G'
				order by ctas.c15 desc limit 1;
			
raise notice 'vin_8:%,serie:%,cve_cliente:%,fec_vale_ultserv:%,folio_tmkt_n1:%,
				asesor_n1:%,fec_prog_n1:%,mot_n1:%,descmot_n1:%,tipo_n1:%,
				fec_contacto_n1:%,res_n1:%,descres_n1:%,acc_n1:%,descacc_n1:%,
				m_contacto_n1:%,obs_n1:%,fec_creacion_n1:%,folio_cita_n1:%,estatus_cita_n1:%,
				descestatus_cita_n1:%,tipo_orden_n1:%,folio_orden_n1:%,origen_n1:%'
				,vin_8,serie,cve_cliente,fec_vale_ultserv,folio_tmkt_n1,
				asesor_n1,fec_prog_n1,mot_n1,descmot_n1,tipo_n1,
				fec_contacto_n1,res_n1,descres_n1,acc_n1,descacc_n1,
				m_contacto_n1,obs_n1,fec_creacion_n1,folio_cita_n1,estatus_cita_n1,
				descestatus_cita_n1,tipo_orden_n1,folio_orden_n1,origen_n1;
			
raise notice 'Paso nu';			
			--NU	
			select tmkt.c2,tmkt.c3,tmkt.c5,tmkt.c7,mtv.descripcion,tmkt.c22,tmkt.c10,tmkt.c8, res.descripcion,
				tmkt.c9,acc.descripcion, medc.c2,
				concat(regexp_replace(tmkt.c11,'\r|\n',' ', 'g'),' ',regexp_replace(tmkt.c12,'\r|\n',' ', 'g'),' ',regexp_replace(tmkt.c13,'\r|\n',' ', 'g')),
				tmkt.c24, tmkt.c15, ctas.c20,
				case when ctas.c20=0 then 'Pendiente' 
					when ctas.c20=10 then 'Confirmada' 
					when ctas.c20=20 then 'Concretada' 
					when ctas.c20=30 then 'Reprogramada'
					when ctas.c20=40 then 'Cancelada'
					when ctas.c20=50 then 'No Show' end,  
				ctas.c21, ctas.c22,tmkt.c25
				into folio_tmkt_n3, asesor_n3, fec_prog_n3, mot_n3, descmot_n3, tipo_n3, fec_contacto_n3,res_n3, descres_n3,
				acc_n3, descacc_n3, m_contacto_n3, obs_n3,
				fec_creacion_n3, folio_cita_n3, estatus_cita_n3, descestatus_cita_n3, tipo_orden_n3, folio_orden_n3, origen_n3
				from keplersc.kdtmktser2 tmkt
				left join keplersc.kdctasser ctas on ctas.c2=tmkt.c15
				inner join keplersc.kdtmktmotivo as mtv on tmkt.c7=mtv.motivo_id
				inner join keplersc.kdtmktresult as res on tmkt.c8=res.resultado_id 
				inner join keplersc.kdtmktaccion as acc on tmkt.c9 = acc.accion_id 
				inner join keplersc.kdmediocontacto as medc on tmkt.c23=medc.c1 
				where  tmkt.c1=sucursal_id and tmkt.c14=rec.c14 and tmkt.c22='NU' and tmkt.c8<>21 /*cancelado*/ and tmkt.c7 <>30/*Confirmacion cita*/ 
				and tmkt.c7<>40/*Seguimiento No show*/ and tmkt.c5 >=fecha_ini::date and tmkt.c5 <=fecha_fin::date 
				and (ctas.c20<> 40 and ctas.c20<> 30 or ctas.c20 is null)
				order by tmkt.c14,tmkt.c10 desc limit 1;
			
raise notice 'vin_8:%,serie:%,cve_cliente:%,fec_vale_ultserv:%,folio_tmkt_nu:%,
				asesor_nu:%,fec_prog_nu:%,mot_nu:%,descmot_nu:%,tipo_nu:%,
				fec_contacto_nu:%,res_nu:%,descres_nu:%,acc_nu:%,descacc_nu:%,
				m_contacto_nu:%,obs_nu:%,fec_creacion_nu:%,folio_cita_nu:%,estatus_cita_nu:%,
				descestatus_cita_nu:%,tipo_orden_nu:%,folio_orden_nu:%,origen_nu:%'
				,vin_8,serie,cve_cliente,fec_vale_ultserv,folio_tmkt_nu,
				asesor_nu,fec_prog_nu,mot_nu,descmot_nu,tipo_nu,
				fec_contacto_nu,res_nu,descres_nu,acc_nu,descacc_nu,
				m_contacto_nu,obs_nu,fec_creacion_nu,folio_cita_nu,estatus_cita_nu,
				descestatus_cita_nu,tipo_orden_nu,folio_orden_nu,origen_nu;			
			
			
			insert into tmpContactos (
				vin_8,serie,cve_cliente,fec_vale_ultserv,folio_tmkt_n30,
				asesor_n30,fec_prog_n30,mot_n30,descmot_n30,tipo_n30,
				fec_contacto_n30,res_n30,descres_n30,acc_n30,descacc_n30,
				m_contacto_n30,obs_n30,fec_creacion_n30,folio_cita_n30,estatus_cita_n30,
				descestatus_cita_n30,tipo_orden_n30,folio_orden_n30,origen_n30,folio_tmkt_n15,
				asesor_n15,fec_prog_n15,mot_n15,descmot_n15,tipo_n15,
				fec_contacto_n15,res_n15,descres_n15,acc_n15,descacc_n15,
				m_contacto_n15,obs_n15,fec_creacion_n15,folio_cita_n15,estatus_cita_n15,
				descestatus_cita_n15,tipo_orden_n15,folio_orden_n15,origen_n15,folio_tmkt_n7,
				asesor_n7,fec_prog_n7,mot_n7,descmot_n7,tipo_n7,
				fec_contacto_n7,res_n7,descres_n7,acc_n7,descacc_n7,
				m_contacto_n7,obs_n7,fec_creacion_n7,folio_cita_n7,estatus_cita_n7,
				descestatus_cita_n7,tipo_orden_n7,folio_orden_n7,origen_n7,folio_tmkt_n3,
				asesor_n3,fec_prog_n3,mot_n3,descmot_n3,tipo_n3,
				fec_contacto_n3,res_n3,descres_n3,acc_n3,descacc_n3,
				m_contacto_n3,obs_n3,fec_creacion_n3,folio_cita_n3,estatus_cita_n3,
				descestatus_cita_n3,tipo_orden_n3,folio_orden_n3,origen_n3,folio_tmkt_n1,
				asesor_n1,fec_prog_n1,mot_n1,descmot_n1,tipo_n1,
				fec_contacto_n1,res_n1,descres_n1,acc_n1,descacc_n1,
				m_contacto_n1,obs_n1,fec_creacion_n1,folio_cita_n1,estatus_cita_n1,
				descestatus_cita_n1,tipo_orden_n1,folio_orden_n1,origen_n1,folio_tmkt_nu,
				asesor_nu,fec_prog_nu,mot_nu,descmot_nu,tipo_nu,
				fec_contacto_nu,res_nu,descres_nu,acc_nu,descacc_nu,
				m_contacto_nu,obs_nu,fec_creacion_nu,folio_cita_nu,estatus_cita_nu,
				descestatus_cita_nu,tipo_orden_nu,folio_orden_nu,origen_nu)
			values(
				vin_8,serie,coalesce(cve_cliente,'--'),coalesce(fec_vale_ultserv,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(folio_tmkt_n30,'--'),
				coalesce(asesor_n30,'--'),coalesce(fec_prog_n30,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(mot_n30,-1),coalesce(descmot_n30,'--'),coalesce(tipo_n30,'--'),
				coalesce(fec_contacto_n30,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(res_n30,-1),coalesce(descres_n30,'--'),coalesce(acc_n30,-1),coalesce(descacc_n30,'--'),
				coalesce(m_contacto_n30,'--'),coalesce(obs_n30,'--'),coalesce(fec_creacion_n30,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(folio_cita_n30,'--'),coalesce(estatus_cita_n30,-1),
				coalesce(descestatus_cita_n30,'--'),coalesce(tipo_orden_n30,'--'),coalesce(folio_orden_n30,'--'),coalesce(origen_n30,'--'),coalesce(folio_tmkt_n15,'--'),
				coalesce(asesor_n15,'--'),coalesce(fec_prog_n15,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(mot_n15,-1),coalesce(descmot_n15,'--'),coalesce(tipo_n15,'--'),
				coalesce(fec_contacto_n15,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(res_n15,-1),coalesce(descres_n15,'--'),coalesce(acc_n15,-1),coalesce(descacc_n15,'--'),
				coalesce(m_contacto_n15,'--'),coalesce(obs_n15,'--'),coalesce(fec_creacion_n15,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(folio_cita_n15,'--'),coalesce(estatus_cita_n15,-1),
				coalesce(descestatus_cita_n15,'--'),coalesce(tipo_orden_n15,'--'),coalesce(folio_orden_n15,'--'),coalesce(origen_n15,'--'),coalesce(folio_tmkt_n7,'--'),
				coalesce(asesor_n7,'--'),coalesce(fec_prog_n7,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(mot_n7,-1),coalesce(descmot_n7,'--'),coalesce(tipo_n7,'--'),
				coalesce(fec_contacto_n7,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(res_n7,-1),coalesce(descres_n7,'--'),coalesce(acc_n7,-1),coalesce(descacc_n7,'--'),
				coalesce(m_contacto_n7,'--'),coalesce(obs_n7,'--'),coalesce(fec_creacion_n7,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(folio_cita_n7,'--'),coalesce(estatus_cita_n7,-1),
				coalesce(descestatus_cita_n7,'--'),coalesce(tipo_orden_n7,'--'),coalesce(folio_orden_n7,'--'),coalesce(origen_n7,'--'),coalesce(folio_tmkt_n3,'--'),
				coalesce(asesor_n3,'--'),coalesce(fec_prog_n3,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(mot_n3,-1),coalesce(descmot_n3,'--'),coalesce(tipo_n3,'--'),
				coalesce(fec_contacto_n3,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(res_n3,-1),coalesce(descres_n3,'--'),coalesce(acc_n3,-1),coalesce(descacc_n3,'--'),
				coalesce(m_contacto_n3,'--'),coalesce(obs_n3,'--'),coalesce(fec_creacion_n3,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(folio_cita_n3,'--'),coalesce(estatus_cita_n3,-1),
				coalesce(descestatus_cita_n3,'--'),coalesce(tipo_orden_n3,'--'),coalesce(folio_orden_n3,'--'),coalesce(origen_n3,'--'),coalesce(folio_tmkt_n1,'--'),
				coalesce(asesor_n1,'--'),coalesce(fec_prog_n1,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(mot_n1,-1),coalesce(descmot_n1,'--'),coalesce(tipo_n1,'--'),
				coalesce(fec_contacto_n1,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(res_n1,-1),coalesce(descres_n1,'--'),coalesce(acc_n1,-1),coalesce(descacc_n1,'--'),
				coalesce(m_contacto_n1,'--'),coalesce(obs_n1,'--'),coalesce(fec_creacion_n1,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(folio_cita_n1,'--'),coalesce(estatus_cita_n1,-1),
				coalesce(descestatus_cita_n1,'--'),coalesce(tipo_orden_n1,'--'),coalesce(folio_orden_n1,'--'),coalesce(origen_n1,'--'),coalesce(folio_tmkt_nu,'--'),
				coalesce(asesor_nu,'--'),coalesce(fec_prog_nu,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(mot_nu,-1),coalesce(descmot_nu,'--'),coalesce(tipo_nu,'--'),
				coalesce(fec_contacto_nu,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(res_nu,-1),coalesce(descres_nu,'--'),coalesce(acc_nu,-1),coalesce(descacc_nu,'--'),
				coalesce(m_contacto_nu,'--'),coalesce(obs_nu,'--'),coalesce(fec_creacion_nu,'1800-01-01 00:00:00'::timestamp without time zone),coalesce(folio_cita_nu,'--'),coalesce(estatus_cita_nu,-1),
				coalesce(descestatus_cita_nu,'--'),coalesce(tipo_orden_nu,'--'),coalesce(folio_orden_nu,'--'),coalesce(origen_nu,'--')
			);
raise notice 'vin_8:%,serie:%,cve_cliente:%,fec_vale_ultserv:%,folio_tmkt_n30:%,
				asesor_n30:%,fec_prog_n30:%,mot_n30:%,descmot_n30:%,tipo_n30:%,
				fec_contacto_n30:%,res_n30:%,descres_n30:%,acc_n30:%,descacc_n30:%,
				m_contacto_n30:%,obs_n30:%,fec_creacion_n30:%,folio_cita_n30:%,estatus_cita_n30:%,
				descestatus_cita_n30:%,tipo_orden_n30:%,folio_orden_n30:%,origen_n30:%,folio_tmkt_n15:%,
				asesor_n15:%,fec_prog_n15:%,mot_n15:%,descmot_n15:%,tipo_n15:%,
				fec_contacto_n15:%,res_n15:%,descres_n15:%,acc_n15:%,descacc_n15:%,
				m_contacto_n15:%,obs_n15:%,fec_creacion_n15:%,folio_cita_n15:%,estatus_cita_n15:%,
				descestatus_cita_n15:%,tipo_orden_n15:%,folio_orden_n15:%,origen_n15:%,folio_tmkt_n7:%,
				asesor_n7:%,fec_prog_n7:%,mot_n7:%,descmot_n7:%,tipo_n7:%,
				fec_contacto_n7:%,res_n7:%,descres_n7:%,acc_n7:%,descacc_n7:%,
				m_contacto_n7:%,obs_n7:%,fec_creacion_n7:%,folio_cita_n7:%,estatus_cita_n7:%,
				descestatus_cita_n7:%,tipo_orden_n7:%,folio_orden_n7:%,origen_n7:%,folio_tmkt_n3:%,
				asesor_n3:%,fec_prog_n3:%,mot_n3:%,descmot_n3:%,tipo_n3:%,
				fec_contacto_n3:%,res_n3:%,descres_n3:%,acc_n3:%,descacc_n3:%,
				m_contacto_n3:%,obs_n3:%,fec_creacion_n3:%,folio_cita_n3:%,estatus_cita_n3:%,
				descestatus_cita_n3:%,tipo_orden_n3:%,folio_orden_n3:%,origen_n3:%,folio_tmkt_n1:%,
				asesor_n1:%,fec_prog_n1:%,mot_n1:%,descmot_n1:%,tipo_n1:%,
				fec_contacto_n1:%,res_n1:%,descres_n1:%,acc_n1:%,descacc_n1:%,
				m_contacto_n1:%,obs_n1:%,fec_creacion_n1:%,folio_cita_n1:%,estatus_cita_n1:%,
				descestatus_cita_n1:%,tipo_orden_n1:%,folio_orden_n1:%,origen_n1:%,folio_tmkt_nu:%,
				asesor_nu:%,fec_prog_nu:%,mot_nu:%,descmot_nu:%,tipo_nu:%,
				fec_contacto_nu:%,res_nu:%,descres_nu:%,acc_nu:%,descacc_nu:%,
				m_contacto_nu:%,obs_nu:%,fec_creacion_nu:%,folio_cita_nu:%,estatus_cita_nu:%,
				descestatus_cita_nu:%,tipo_orden_nu:%,folio_orden_nu:%,origen_nu:%'
				,vin_8,serie,cve_cliente,fec_vale_ultserv,folio_tmkt_n30,
				asesor_n30,fec_prog_n30,mot_n30,descmot_n30,tipo_n30,
				fec_contacto_n30,res_n30,descres_n30,acc_n30,descacc_n30,
				m_contacto_n30,obs_n30,fec_creacion_n30,folio_cita_n30,estatus_cita_n30,
				descestatus_cita_n15,tipo_orden_n30,folio_orden_n30,origen_n30,folio_tmkt_n15,
				asesor_n15,fec_prog_n15,mot_n15,descmot_n15,tipo_n15,
				fec_contacto_n15,res_n15,descres_n15,acc_n15,descacc_n15,
				m_contacto_n15,obs_n15,fec_creacion_n15,folio_cita_n15,estatus_cita_n15,
				descestatus_cita_n30,tipo_orden_n15,folio_orden_n15,origen_n15,folio_tmkt_n7,
				asesor_n7,fec_prog_n7,mot_n7,descmot_n7,tipo_n7,
				fec_contacto_n7,res_n7,descres_n7,acc_n7,descacc_n7,
				m_contacto_n7,obs_n7,fec_creacion_n7,folio_cita_n7,estatus_cita_n7,
				descestatus_cita_n7,tipo_orden_n7,folio_orden_n7,origen_n7,folio_tmkt_n3,
				asesor_n3,fec_prog_n3,mot_n3,descmot_n3,tipo_n3,
				fec_contacto_n3,res_n3,descres_n3,acc_n3,descacc_n3,
				m_contacto_n3,obs_n3,fec_creacion_n3,folio_cita_n3,estatus_cita_n3,
				descestatus_cita_n3,tipo_orden_n3,folio_orden_n3,origen_n3,folio_tmkt_n1,
				asesor_n1,fec_prog_n1,mot_n1,descmot_n1,tipo_n1,
				fec_contacto_n1,res_n1,descres_n1,acc_n1,descacc_n1,
				m_contacto_n1,obs_n1,fec_creacion_n1,folio_cita_n1,estatus_cita_n1,
				descestatus_cita_n1,tipo_orden_n1,folio_orden_n1,origen_n1,folio_tmkt_nu,
				asesor_nu,fec_prog_nu,mot_nu,descmot_nu,tipo_nu,
				fec_contacto_nu,res_nu,descres_nu,acc_nu,descacc_nu,
				m_contacto_nu,obs_nu,fec_creacion_nu,folio_cita_nu,estatus_cita_nu,
				descestatus_cita_nu,tipo_orden_nu,folio_orden_nu,origen_nu;			
		
			
--		raise notice 'Vin:% Folio_tmkt:% tipo_n:% resultado:%',rec.c14,rec.c2,rec.c22,rec.c8;

		end loop;
--raise exception 'Alto manual';	

sqlExp = 'select * from tmpContactos';
select query_to_xml(sqlExp,false,true,'') into xmlResultado;
	return xmlResultado;

exception
	when others then
		raise exception '%', sqlerrm;	

end;
$function$
