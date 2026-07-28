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
	select ftord.c1 as sucursal,
	k_anio as anio,
	k_mes as mes, 
	case when ftord.c5 > fechaPrimCorte then '2' else '1' end as periodo,
	'R' as tipo_trabajo, -- coalesce(gtmkt.c19,'') as tipo_trabajo,
	'' as contacto, --coalesce(gtmkt.c2,'') as contacto,
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
	inner join keplersc.kdctasser dcser on dcser.c1=ftord.c1 and dcser.c22 = ftord.c3
	inner join keplersc.kdmargen mmar on mmar.c1 = ftord.c2
	inner join keplersc.kdctassermov imov on imov.c1=dcser.c1 and imov.c2=dcser.c2
	inner join keplersc.kdpun kpun on kpun.c1=dcser.c1 and kpun.c2=dcser.c21 and kpun.c3=dcser.c22 and kpun.c5=imov.c6 
	left outer join keplersc.kdctascomispaq jpaq on jpaq.c1=imov.c6
--	left outer join keplersc.kdtmktser2 gtmkt on gtmkt.c1=dcser.c1 and gtmkt.c15=dcser.c2 and gtmkt.c3=dcser.c3
	where ftord.c5>=fechaIniMes 
	and ftord.c5<=fechaFinMes
	and (mmar.c2='G' or mmar.c2='N')
	and imov.c4='S'
	and imov.c6<>'';

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
/*	--Calcular proactivas y pasivas
		select count(*) into totPro_1 from keplersc.kdctasser ctas
		left outer join keplersc.kdtmktser2 tmkt on tmkt.c1=ctas.c1 and tmkt.c17=ctas.c2 
			and tmkt.c3=ctas.c3
		where ctas.c1=sucursal_id and ctas.c3=rec_Asesor.asesor 
		and ctas.c12>=fechaIniMes and ctas.c12<=fechaPrimCorte and ctas.c22<>''
		and ctas.c21 not in ('I','G') 
		and tmkt.c3 is not null
		and tmkt.c19='P';

		select count(*) into totPro_2 from keplersc.kdctasser ctas
		left outer join keplersc.kdtmktser2 tmkt on tmkt.c1=ctas.c1 and tmkt.c17=ctas.c2 
			and tmkt.c3=ctas.c3
		where ctas.c1=sucursal_id and ctas.c3=rec_Asesor.asesor 
		and ctas.c12>fechaPrimCorte and ctas.c12<=fechaFinMes and ctas.c22<>''
		and ctas.c21 not in ('I','G') 
		and tmkt.c3 is not null
		and tmkt.c19='P';

		select count(*) into totPas_1 from keplersc.kdctasser ctas
		left outer join keplersc.kdtmktser2 tmkt on tmkt.c1=ctas.c1 and tmkt.c17=ctas.c2 
			and tmkt.c3=ctas.c3
		where ctas.c1=sucursal_id and ctas.c3=rec_Asesor.asesor 
		and ctas.c12>=fechaIniMes and ctas.c12<=fechaPrimCorte and ctas.c22<>''
		and ctas.c21 not in ('I','G') 
		and (tmkt.c3 is null or tmkt.c19<>'P');	
	
		select count(*) into totPas_2 from keplersc.kdctasser ctas
		left outer join keplersc.kdtmktser2 tmkt on tmkt.c1=ctas.c1 and tmkt.c17=ctas.c2 
			and tmkt.c3=ctas.c3
		where ctas.c1=sucursal_id and ctas.c3=rec_Asesor.asesor 
		and ctas.c12>fechaPrimCorte and ctas.c12<=fechaFinMes and ctas.c22<>''
		and ctas.c21 not in ('I','G') 
		and (tmkt.c3 is null or tmkt.c19<>'P');	
		
		select count(*) into totPas_1 from keplersc.kdctasser ctas
		where ctas.c1=sucursal_id and ctas.c3=rec_Asesor.asesor 
		and ctas.c12>=fechaIniMes and ctas.c12<=fechaPrimCorte and ctas.c22<>''
		and ctas.c21 not in ('I','G');
	
		select count(*) into totPas_2 from keplersc.kdctasser ctas
		where ctas.c1=sucursal_id and ctas.c3=rec_Asesor.asesor 
		and ctas.c12>fechaPrimCorte and ctas.c12<=fechaFinMes and ctas.c22<>''
		and ctas.c21 not in ('I','G');		
*/	
		select count(*) into totPas_1 from keplersc.kdord ord
		inner join keplersc.kdctasser ctas on ctas.c1=ord.c1 and ctas.c21=ord.c2 and ctas.c22=ord.c3
		inner join keplersc.kdmargen mmar on mmar.c1 = ord.c2		
		where ord.c1=sucursal_id
		and ctas.c3=rec_Asesor.asesor 
		and ord.c4>=fechaIniMes and ord.c4<=fechaPrimCorte
		and (mmar.c2='G' or mmar.c2='N');
--		and ctas.c21 not in ('I','G');
	
		select count(*) into totPas_2 from keplersc.kdord ord
		inner join keplersc.kdctasser ctas on ctas.c1=ord.c1 and ctas.c21=ord.c2 and ctas.c22=ord.c3
		inner join keplersc.kdmargen mmar on mmar.c1 = ord.c2		
		where ord.c1=sucursal_id
		and ctas.c3=rec_Asesor.asesor 
		and ord.c4>fechaPrimCorte and ord.c4<=fechaFinMes
		and (mmar.c2='G' or mmar.c2='N');	
--		and ctas.c21 not in ('I','G');	

		comisPro_1=0.00;
		comisPro_2=0.00;
		for rec_ComPro in select * from keplersc.kdctascomis order by c1
		loop			
			if totPro_1>=rec_ComPro.c1 then			
				comisPro_1:=comisPro_1+((totPro_1-rec_ComPro.c1) * rec_ComPro.c3);
				insert into keplersc.kdtmktcomis_trabajo(sucursal,anio,mes,periodo,asesor_tmkt,tipo_trabajo,inferior,superior,comision,citas)
					values(sucursal_id,k_anio,k_mes,1,rec_Asesor.asesor,'PROACTIVA',rec_ComPro.c1,rec_ComPro.c2,rec_ComPro.c3,totPro_1-rec_ComPro.c1);
			end if;
			if totPro_2>=rec_ComPro.c1 then				
				comisPro_2:=comisPro_2+((totPro_2-rec_ComPro.c1) * rec_ComPro.c3);
				insert into keplersc.kdtmktcomis_trabajo(sucursal,anio,mes,periodo,asesor_tmkt,tipo_trabajo,inferior,superior,comision,citas)
					values(sucursal_id,k_anio,k_mes,2,rec_Asesor.asesor,'PROACTIVA',rec_ComPro.c1,rec_ComPro.c2,rec_ComPro.c3,totPro_2-rec_ComPro.c1);			
			end if;	
		end loop;
		--Comisiones pasivas
		insert into keplersc.kdtmktcomis_trabajo(sucursal,anio,mes,periodo,asesor_tmkt,tipo_trabajo,inferior,superior,comision,citas)
			values(sucursal_id,k_anio,k_mes,1,rec_Asesor.asesor,'PASIVA',1,1,factorComis,totPas_1);
		insert into keplersc.kdtmktcomis_trabajo(sucursal,anio,mes,periodo,asesor_tmkt,tipo_trabajo,inferior,superior,comision,citas)
			values(sucursal_id,k_anio,k_mes,2,rec_Asesor.asesor,'PASIVA',1,1,factorComis,totPas_2);

		--Agregar resumen paquetes
		for rec_ComPaq in select periodo,clave_paquete,paq_comision,count(*) as totQuincena 
			from keplersc.kdtmktcomis_det det
			where det.sucursal=sucursal_id and det.anio=k_anio and det.mes=k_mes and det.asesor_tmkt = rec_Asesor.asesor
			group by periodo,clave_paquete,paq_comision 
			order by periodo,clave_paquete,paq_comision
		loop
raise notice 'asesor:%; rec_ComPaq:%',rec_Asesor.asesor,rec_ComPaq.clave_paquete;
			insert into keplersc.kdtmktcomis_trabajo(sucursal,anio,mes,periodo,asesor_tmkt,tipo_trabajo,inferior,superior,comision,citas)
				values(sucursal_id,k_anio,k_mes,rec_ComPaq.periodo,rec_Asesor.asesor,'PAQ-'||rec_ComPaq.clave_paquete,1,1,rec_ComPaq.paq_comision,rec_ComPaq.totQuincena);
		end loop;
	end loop;
	--Eliminar registros no comisionables
	delete from keplersc.kdtmktcomis_det where sucursal=sucursal_id and anio=k_anio and mes=k_mes and paq_comision = 0;
	delete from keplersc.kdtmktcomis_trabajo where sucursal=sucursal_id and anio=k_anio and mes=k_mes and comision = 0;

	resultado:='1';
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

end;
$function$
