CREATE OR REPLACE FUNCTION keplersc.com_tmkt_generar(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare 

	--variable parametros
	sucursal_id text = '';	
	k_anio text ='';
	k_mes text = '';
	asesor text = '';
	detalle text = '';


	--Variables de uso general 
	strValor text='';
	intValor int=0;
	dateValor timestamp;
	totReg int=0;
	totPro_1 int = 0;
	totPro_2 int = 0;
	totPas_1 int =0;
	totPas_2 int =0;
	totCitas_1 int =0;
	totCitas_2 int =0;
	comisPro_1 numeric(12,2) = 0.00;
	comisPro_2 numeric(12,2) = 0.00;
	rangoIni int =0;
	rangoFin int=0;
	factorComis int =0;
		
	rec_Asesor record;   --Registro comision detalle
	rec_ComPro record; --Registro escala comisiones proactivas
	rec_ComPas record; -- Registro comisiones pasivas
	rec_ComPaq record;
	fechaIniMes timestamp;
	fechaFinMes	timestamp;
	fechaPrimCorte timestamp;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	--Eliminar los registros previos
	
	sucursal_id := (xpath('//document/k_sucn/text()', dataxml))[1];
	k_mes := (xpath('//document/k_mes/text()', dataxml))[1];
	k_anio := (xpath('//document/k_anio/text()', dataxml))[1];
	k_mes:=lpad(k_mes,2,'0');

	strValor:= concat('01','-',k_mes,'-','20',lpad(k_anio,2,'0'), ' 00:00:00');
	fechaIniMes:=to_timestamp(strValor,'dd-mm-yyyy HH24:MI:SS');
	fechaFinMes:=fechaIniMes + interval '1 month';
	fechaFinMes:=fechaFinMes - interval '1 day';
	fechaFinMes:=fechaFinMes + interval '23 hours 59 minutes 59 seconds';
	strValor:= concat('15','-',k_mes,'-','20',lpad(k_anio,2,'0'), ' 23:59:59');
	fechaPrimCorte:=to_timestamp(strValor,'dd-mm-yyyy HH24:MI:SS');
	
	delete from keplersc.kdtmktcomis_det where sucursal=sucursal_id and anio=k_anio and mes=k_mes;
	delete from keplersc.kdtmktcomis_trabajo where sucursal=sucursal_id and anio=k_anio and mes=k_mes;

	--Comisiones detalle
	insert into keplersc.kdtmktcomis_det
	select distinct ftord.c1 as sucursal,
	k_anio as anio,
	k_mes as mes, 
	case when ftord.c5 > fechaPrimCorte then '2' else '1' end as periodo,
	case when dcser.c3=gtmkt.c3 then 'P' else 'R' end as tipo_trabajo,
	coalesce(gtmkt.c3,'') as contacto,
	dcser.c37 as tipo_cita,
	dcser.c2 as folio_cita,
	dcser.c3 as asesor_tmkt,
	ftord.c2 as tipo_orden,
	ftord.c3 as folio_orden,
	ftord.c5 as fecha_ord_ent,
	dcser.c20 as estatus_cita_orden, 
	imov.c3 as punto, 
	imov.c4 as tipo_punto,
	imov.c7 as desc_punto,
	imov.c6 as clave_paquete, 
	coalesce(jpaq.c2,0) as paq_comision	
	from keplersc.kdtord ftord
	inner join keplersc.kdctasser dcser on dcser.c1=ftord.c1 and dcser.c21=ftord.c2 and dcser.c22 = ftord.c3
	inner join keplersc.kdmargen mmar on mmar.c1 = ftord.c2
	inner join keplersc.kdctassermov imov on imov.c1=dcser.c1 and imov.c2=dcser.c2
	inner join keplersc.kdpun kpun on kpun.c1=dcser.c1 and kpun.c2=dcser.c21 and kpun.c3=dcser.c22 and kpun.c5=imov.c6 
	left outer join keplersc.kdctascomispaq jpaq on jpaq.c1=imov.c6
	left outer join keplersc.kdtmktser2 gtmkt on gtmkt.c1=dcser.c1 and gtmkt.c15=dcser.c2 and gtmkt.c3=dcser.c3
	where ftord.c5>=fechaIniMes and ftord.c5<=fechaFinMes
	and (mmar.c2='G' or mmar.c2='N')
	and imov.c4='S'
	and imov.c4<>''
	and dcser.c20=20;
	--Eliminar registros no comisionables
	delete from keplersc.kdtmktcomis_det where sucursal=sucursal_id and anio=k_anio and mes=k_mes and paq_comision = 0;
--	delete from keplersc.kdtmktcomis_det where sucursal=sucursal_id and anio=k_anio and mes=k_mes and paq_comision = 0;
--	delete from keplersc.kdtmktcomis_trabajo where sucursal=sucursal_id and anio=k_anio and mes=k_mes and comision = 0;

--Agregar las que no son paquetes
	insert into keplersc.kdtmktcomis_det
	select distinct ftord.c1 as sucursal,
	k_anio as anio,
	k_mes as mes, 
	case when ftord.c5 > fechaPrimCorte then '2' else '1' end as periodo,
	case when dcser.c3=gtmkt.c3 then 'P' else 'R' end as tipo_trabajo,
	coalesce(gtmkt.c3,'') as contacto,
	dcser.c37 as tipo_cita,
	dcser.c2 as folio_cita,
	dcser.c3 as asesor_tmkt,
	ftord.c2 as tipo_orden,
	ftord.c3 as folio_orden,
	ftord.c5 as fecha_ord_ent,
	dcser.c20 as estatus_cita_orden, 
	0 as punto, 
	'' as tipo_punto,
	'' as desc_punto,
	'' as clave_paquete, 
	0 as paq_comision
	from keplersc.kdtord ftord
	inner join keplersc.kdctasser dcser on dcser.c1=ftord.c1 and dcser.c21=ftord.c2 and dcser.c22 = ftord.c3
	inner join keplersc.kdmargen mmar on mmar.c1 = ftord.c2
	left outer join keplersc.kdtmktser2 gtmkt on gtmkt.c1=dcser.c1 and gtmkt.c15=dcser.c2 --and gtmkt.c3=dcser.c3
	where ftord.c5>=fechaIniMes and ftord.c5<=fechaFinMes
	and (mmar.c2='G' or mmar.c2='N')
	and dcser.c20=20;

	--Factor pasivas
	select c2 into factorComis from keplersc.kdctascomispasivas k where c1=1;

	--Comisiones pro activas
	for rec_Asesor in select distinct asesor_tmkt as asesor from keplersc.kdtmktcomis_det 
		where sucursal=sucursal_id and anio=k_anio and mes=k_mes
		order by asesor_tmkt 
	loop
		totReg=0;
		totPro_1= 0;
		totPro_2= 0;
		totPas_1=0;
		totPas_2=0;
		totCitas_1=0;
		totCitas_2=0;

		select count(*) into totPro_1 from keplersc.kdtmktcomis_det 
			where anio=k_anio and mes=k_mes and periodo='1' and asesor_tmkt=rec_Asesor.asesor 
			and tipo_trabajo ='P' and clave_paquete='';
		select count(*) into totPro_2 from keplersc.kdtmktcomis_det 
			where anio=k_anio and mes=k_mes and periodo='2' and asesor_tmkt=rec_Asesor.asesor 
			and tipo_trabajo ='P' and clave_paquete='';
		select count(*) into totPas_1 from keplersc.kdtmktcomis_det 
			where anio=k_anio and mes=k_mes and periodo='1' and asesor_tmkt=rec_Asesor.asesor 
			and tipo_trabajo ='R' and clave_paquete='';
		select count(*) into totPas_2 from keplersc.kdtmktcomis_det 
			where anio=k_anio and mes=k_mes and periodo='2' and asesor_tmkt=rec_Asesor.asesor 
			and tipo_trabajo ='R' and clave_paquete='';

--raise exception 'k_anio %, k_mes %, asesor %, totPro_1 % ',k_anio,k_mes,rec_Asesor.asesor,totPro_1;


		comisPro_1=0.00;
		comisPro_2=0.00;
		for rec_ComPro in select * from keplersc.kdctascomis order by c1
		loop			
			if totPro_1>=rec_ComPro.c1 then			
				comisPro_1:=comisPro_1+((totPro_1-rec_ComPro.c1) * rec_ComPro.c3);
				insert into keplersc.kdtmktcomis_trabajo(sucursal,anio,mes,periodo,asesor_tmkt,tipo_trabajo,inferior,superior,comision,citas)
					values(sucursal_id,k_anio,k_mes,1,rec_Asesor.asesor,'PROACTIVA',rec_ComPro.c1,rec_ComPro.c2,rec_ComPro.c3,totPro_1);
			end if;
			if totPro_2>=rec_ComPro.c1 then				
				comisPro_2:=comisPro_2+((totPro_2-rec_ComPro.c1) * rec_ComPro.c3);
				insert into keplersc.kdtmktcomis_trabajo(sucursal,anio,mes,periodo,asesor_tmkt,tipo_trabajo,inferior,superior,comision,citas)
					values(sucursal_id,k_anio,k_mes,2,rec_Asesor.asesor,'PROACTIVA',rec_ComPro.c1,rec_ComPro.c2,rec_ComPro.c3,totPro_2);			
			end if;	
		end loop;
		--Comisiones pasivas
		insert into keplersc.kdtmktcomis_trabajo(sucursal,anio,mes,periodo,asesor_tmkt,tipo_trabajo,inferior,superior,comision,citas)
			values(sucursal_id,k_anio,k_mes,1,rec_Asesor.asesor,'PASIVA',1,1,factorComis,totPas_1);
		insert into keplersc.kdtmktcomis_trabajo(sucursal,anio,mes,periodo,asesor_tmkt,tipo_trabajo,inferior,superior,comision,citas)
			values(sucursal_id,k_anio,k_mes,2,rec_Asesor.asesor,'PASIVA',1,1,factorComis,totPas_2);

		--Agregar resumen paquetes
		for rec_ComPaq in select periodo,count(*) as totQuincena, sum(paq_comision) as paq_comision
			from keplersc.kdtmktcomis_det det
			where det.sucursal=sucursal_id and det.anio=k_anio and det.mes=k_mes and det.asesor_tmkt = rec_Asesor.asesor
			and clave_paquete <> ''
			group by periodo 
			order by periodo
		loop
			insert into keplersc.kdtmktcomis_trabajo(sucursal,anio,mes,periodo,asesor_tmkt,tipo_trabajo,inferior,superior,comision,citas)
				values(sucursal_id,k_anio,k_mes,rec_ComPaq.periodo,rec_Asesor.asesor,'PAQUETES',1,1,rec_ComPaq.paq_comision/rec_ComPaq.totQuincena,rec_ComPaq.totQuincena);
		end loop;

	end loop;

	--Eliminar registros no comisionables
--	delete from keplersc.kdtmktcomis_det where sucursal=sucursal_id and anio=k_anio and mes=k_mes and tipo_trabajo='PAQ-' and paq_comision = 0;

	resultado:='1';
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

end;
$function$
