CREATE OR REPLACE FUNCTION keplersc.rep_estatus_sofia(dataxml xml)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
--Descripcion: Reporte de estado de eventos notificados a sofia
--Autor: Victor Salgado
--Fecha: 15/06/2025
--Bitacora de cambios
declare
	--Variables principales
	sucursal_id text = '';
	fecha_inicial text;
	fecha_final text;
	fecha_oper timestamp;
	movto_sofia text;
	notif_estatus text;
	sofia_estatus text;

	--Variables de uso general 
	xmlResultado text = '';
	expSql text = '';
	comilla text = '''';

begin

	sucursal_id := coalesce((xpath('//document/sucursal_id/text()', dataxml))[1]::text,'')::text;
	fecha_inicial := coalesce((xpath('//document/fecha_inicial/text()', dataxml))[1]::text,'')::text;
	fecha_final := coalesce((xpath('//document/fecha_final/text()', dataxml))[1]::text,'')::text;
	movto_sofia := coalesce((xpath('//document/movto_sofia/text()', dataxml))[1]::text,'')::text;
	notif_estatus := coalesce((xpath('//document/notif_estatus/text()', dataxml))[1]::text,'')::text;
	sofia_estatus := coalesce((xpath('//document/sofia_estatus/text()', dataxml))[1]::text,'')::text;
	--Obtener la fecha de inicio de operacion de envio a sofia via bp

	select c6 into fecha_oper from keplersc.kdcfdconfig k where c1=sucursal_id;

	--Validacion de criterios
	if sucursal_id = '' then
		raise exception 'No se ha proporcionado la sucursal'; 
	end if;

	if fecha_oper is null then
		raise exception 'No se ha configurado la fecha de inicion de operacion'; 
	end if;

	--Evaluar rango de fechas del reporte
	if fecha_inicial='' then
		fecha_inicial=fecha_oper::text;
	end if;

	if fecha_final='' then
		fecha_final=now();
	end if;
--raise exception 'PASO 5 movto_sofia % ',movto_sofia;
	--Creacion dinamica de query dependiendo del criterio de seleccion
--case when coalesce(isn.notif_estatus, %12$L) <> %12$L then %9$L else %12$L end as k80_sofia,
--			coalesce(isn.notif_estatus, %12$L) as k80_sofia, 
	if movto_sofia='Todos' or movto_sofia='Invoice Notification' then --Seccion Invoice Notification
		expSql=format('select %1$L as movto_sofia, vtas.c1 as sucursal, inf.c5 as serie, inf.c2 as inventario, 
			vtas.c4 as genero, vtas.c5 as naturaleza, vtas.c6 as grupo, vtas.c7  as tipo, vtas.c8 as folio, vtas.c9 as fecha_movto,
			case when isn.notif_estatus is null then %13$L else %14$L end as k80_sofia,
			coalesce(case when isn.notif_estatus = %2$L then %3$L when isn.notif_estatus = %4$L then %5$L when isn.notif_estatus = %6$L then %7$L else %8$L || isn.notif_estatus end , %9$L) as notif_estatus,
		    coalesce(isn.notif_fecha,%10$L) as notif_fecha, coalesce(isn.notif_mensaje,%11$L) as notif_mensaje '
			,'Invoice Notification','P','No Enviado','R','Error','E','Enviado','Desconocido','No Enviado','1800-01-01','','','Pendiente','Registrado');	
		expSql=format('%1$s from keplersc.kdventas vtas 
			left outer join keplersc.ifz_sofia_notif isn on vtas.c1=isn.sucursal and vtas.c4=isn.genero and vtas.c5=isn.naturaleza and vtas.c6=isn.grupo and vtas.c7=isn.tipo and vtas.c8=isn.folio 
			left outer join keplersc.kdinf inf on inf.c1=vtas.c1 and inf.c2=vtas.c2 ',expSql);
		expSql=format('%1$s where vtas.c10=0 and vtas.c19=%2$L and vtas.c6=6 and vtas.c9 >= %3$L and vtas.c9 >= %4$L and vtas.c9 <= %5$L ',expSql,'NUEVO',fecha_oper,fecha_inicial,fecha_final);
		
		if sofia_estatus = 'PK' then --Pendientes Kepler
			expSql=format('%1$s and vtas.c1 || vtas.c4 || vtas.c5 || vtas.c6::text || vtas.c7::text || vtas.c8 not in 
				(select ifz.sucursal || ifz.genero || ifz.naturaleza || ifz.grupo::text || ifz.tipo::text || ifz.folio from keplersc.ifz_sofia_notif ifz 
				where vtas.c1=ifz.sucursal and vtas.c4=ifz.genero and vtas.c5=ifz.naturaleza and vtas.c6=ifz.grupo and vtas.c7=ifz.tipo and vtas.c8=ifz.folio) ',expSql);
		end if;
		if sofia_estatus = 'PB' then --Pendientes BP
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'P');
		end if;

		if sofia_estatus = 'EK' then --Registrados Kepler
			expSql=format('%1$s and isn.notif_estatus is not null ',expSql);
		end if;

		if sofia_estatus = 'EB' then --Envados BP
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'E');
		end if;

		if sofia_estatus = 'RK' then --Error Kepler, esta condicion no se puede dar
			--expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,sofia_estatus);
		end if;

		if sofia_estatus = 'RB' then --Envados BP
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'R');
		end if;
	end if;
	if movto_sofia='Todos' or movto_sofia='Invoice Cancelled' then --Seccion Invoice Cancelled
		if movto_sofia = 'Todos' then
			expSql=concat(expSql,' union ');
		end if;
		expSql=format('%12$s select %1$L as movto_sofia, vtas.c1 as sucursal, inf.c5 as serie, inf.c2 as inventario, 
			vtas.c4 as genero, vtas.c5 as naturaleza, vtas.c6 as grupo, vtas.c7  as tipo, vtas.c8 as folio, vtas.c9 as fecha_movto,
			case when isn.notif_estatus is null then %13$L else %14$L end as k80_sofia,
			coalesce(case when isn.notif_estatus = %2$L then %3$L when isn.notif_estatus = %4$L then %5$L when isn.notif_estatus = %6$L then %7$L else %8$L || isn.notif_estatus end , %9$L) as notif_estatus,
			coalesce(isn.notif_fecha,%10$L) as notif_fecha, coalesce(isn.notif_mensaje,%11$L) as sofia_mensaje '
			,'Invoice Cancelled','P','No Enviado','R','Error','E','Enviado','Desconocido','No Enviado','1800-01-01','',expSql,'Pendiente','Registrado');	
raise notice '%',expSql;
		expSql=format('%1$s from keplersc.kdventas vtas 
			left outer join keplersc.ifz_sofia_notif isn on vtas.c1=isn.sucursal and vtas.c4=isn.genero and vtas.c5=isn.naturaleza and vtas.c6=isn.grupo and vtas.c7=isn.tipo and vtas.c8=isn.folio 
			left outer join keplersc.kdinf inf on inf.c1=vtas.c1 and inf.c2=vtas.c2 ',expSql);
		expSql=format('%1$s where vtas.c10=10 and vtas.c19=%2$L and vtas.c6 in (60,70) and vtas.c9 >= %3$L and vtas.c9 >= %4$L and vtas.c9 <= %5$L ',expSql,'NUEVO',fecha_oper,fecha_inicial,fecha_final);
		if sofia_estatus = 'PK' then --Pendientes Kepler
			expSql=format('%1$s and vtas.c1 || vtas.c4 || vtas.c5 || vtas.c6::text || vtas.c7::text || vtas.c8 not in 
				(select ifz.sucursal || ifz.genero || ifz.naturaleza || ifz.grupo::text || ifz.tipo::text || ifz.folio from keplersc.ifz_sofia_notif ifz 
				where vtas.c1=ifz.sucursal and vtas.c4=ifz.genero and vtas.c5=ifz.naturaleza and vtas.c6=ifz.grupo and vtas.c7=ifz.tipo and vtas.c8=ifz.folio) ',expSql);
		end if;
		if sofia_estatus = 'PB' then --Pendientes BP
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'P');
		end if;

		if sofia_estatus = 'EK' then --Registrados Kepler
			expSql=format('%1$s and isn.notif_estatus is not null ',expSql);
		end if;

		if sofia_estatus = 'EB' then --Envados BP
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'E');
		end if;

		if sofia_estatus = 'RK' then --Error Kepler, esta condicion no se puede dar
			--expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,sofia_estatus);
		end if;

		if sofia_estatus = 'RB' then --Envados BP
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'R');
		end if;
	end if;
--raise notice '%',expSql;
	if movto_sofia='Todos' or movto_sofia='Delivery Notification' then --Seccion Delivery Notification
		if movto_sofia = 'Todos' then
			expSql=concat(expSql,' union ');
		end if;
		expSql=format(' %12$s select %1$L as movto_sofia, com.c1 as sucursal, inf.c5 as serie, inf.c2 as inventario, 
			com.c2 as genero, com.c3 as naturaleza, com.c4 as grupo, com.c5  as tipo, com.c6 as folio, com.c7 as fecha_movto,
			case when isn.notif_estatus is null then %13$L else %14$L end as k80_sofia,
			coalesce(case when isn.notif_estatus = %2$L then %3$L when isn.notif_estatus = %4$L then %5$L when isn.notif_estatus = %6$L then %7$L else %8$L || isn.notif_estatus end , %9$L) as sofia_estatus,
			coalesce(isn.notif_fecha,%10$L) as notif_fecha, coalesce(isn.notif_mensaje,%11$L) as sofia_mensaje '
			,'Delivery Notification','P','No Enviado','R','Error','E','Enviado','Desconocido','No Enviado','1800-01-01','',expSql,'Pendiente','Registrado');
		expSql=format('%1$s from keplersc.kdcomismov com 
			left outer join keplersc.ifz_sofia_notif isn on com.c1=isn.sucursal and com.c2=isn.genero and com.c3=isn.naturaleza and com.c4=isn.grupo and com.c5=isn.tipo and com.c6=isn.folio 
			left outer join keplersc.kdinf inf on inf.c1=com.c1 and inf.c2=com.c8 ',expSql);
		expSql=format('%1$s where com.c10::int = 0 and com.c14=%2$L and com.c7 >= %3$L and com.c7 >= %4$L and com.c7 <= %5$L ',expSql,'N',fecha_oper,fecha_inicial,fecha_final);		

	end if;

	if movto_sofia='Todos' or movto_sofia='Return Delivery' then --Return Delivery
		if movto_sofia = 'Todos' then
			expSql=concat(expSql,' union ');
		end if;
		expSql=format(' %12$s select %1$L as movto_sofia, com.c1 as sucursal, inf.c5 as serie, inf.c2 as inventario, 
			com.c2 as genero, com.c3 as naturaleza, com.c4 as grupo, com.c5  as tipo, com.c6 as folio, com.c7 as fecha_movto,
			case when isn.notif_estatus is null then %13$L else %14$L end as k80_sofia,
			coalesce(case when isn.notif_estatus = %2$L then %3$L when isn.notif_estatus = %4$L then %5$L when isn.notif_estatus = %6$L then %7$L else %8$L || isn.notif_estatus end , %9$L) as sofia_estatus,
			coalesce(isn.notif_fecha,%10$L) as notif_fecha, coalesce(isn.notif_mensaje,%11$L) as sofia_mensaje '
			,'Return Delivery','P','No Enviado','R','Error','E','Enviado','Desconocido','No Enviado','1800-01-01','',expSql,'Pendiente','Registrado');
		expSql=format('%1$s from keplersc.kdcomismov com 
			left outer join keplersc.ifz_sofia_notif isn on com.c1=isn.sucursal and com.c2=isn.genero and com.c3=isn.naturaleza and com.c4=isn.grupo and com.c5=isn.tipo and com.c6=isn.folio 
			left outer join keplersc.kdinf inf on inf.c1=com.c1 and inf.c2=com.c8 ',expSql);
		expSql=format('%1$s where com.c10::int = 1 and com.c14=%2$L and com.c7 >= %3$L and com.c7 >= %4$L and com.c7 <= %5$L ',expSql,'N',fecha_oper,fecha_inicial,fecha_final);
	end if;

	if movto_sofia='Todos' or movto_sofia='Demo In Ventas' then --Demo In Ventas
		if movto_sofia = 'Todos' then
			expSql=concat(expSql,' union ');
		end if;
		expSql=format(' %12$s select %1$L as movto_sofia, inf.c1 as sucursal, inf.c5 as serie, inf.c2 as inventario, 
			isn.genero as genero, isn.naturaleza as naturaleza, isn.grupo as grupo, isn.tipo as tipo, isn.folio as folio, %10$L as fecha_movto,
			case when isn.notif_estatus is null then %13$L else %14$L end as k80_sofia,
			coalesce(case when isn.notif_estatus = %2$L then %3$L when isn.notif_estatus = %4$L then %5$L when isn.notif_estatus = %6$L then %7$L else %8$L || isn.notif_estatus end , %9$L) as notif_estatus,
			coalesce(isn.notif_fecha,%10$L) as notif_fecha, coalesce(isn.notif_mensaje,%11$L) as sofia_mensaje '
			,'Demo In Ventas','P','Pendiente','R','Error','E','Enviado','Desconocido','No enviado','1800-01-01','',expSql,'Pendiente','Registrado');
		expSql=format('%1$s from keplersc.kdinf inf left outer join keplersc.ifz_sofia_notif isn on isn.sucursal=inf.c1 and isn.serie = inf.c5 and isn.movto_sofia = %2$L',expSql,'Demo In Ventas');
		expSql=format('%1$s where inf.c21=%2$L and inf.c22=%3$L and inf.c27 >= %4$L and inf.c27 >= %5$L and inf.c27 <= %6$L ',expSql,'NUEVO','1',fecha_oper,fecha_inicial,fecha_final);

		if sofia_estatus = 'PK' then --Pendiente kepler
			expSql=format('%1$s and inf.c1 || inf.c5 || %2$L not in 
				(select ifz.sucursal || ifz.serie || %2$L from keplersc.ifz_sofia_notif ifz 
				where ifz.sucursal=inf.c1 and ifz.serie=inf.c5 and ifz.movto_sofia=%2$L) ',expSql,'Demo In Ventas');
		end if;

		if sofia_estatus = 'PB' then --Esttaus BP Sofia
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'P');
		end if;

		if sofia_estatus = 'EK' then --Registrados Kepler
			expSql=format('%1$s and isn.notif_estatus is not null ',expSql);
		end if;

		if sofia_estatus = 'EB' then --Envados BP
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'E');
		end if;

		if sofia_estatus = 'RK' then --Error Kepler, esta condicion no se puede dar
			--expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,sofia_estatus);
		end if;

		if sofia_estatus = 'RB' then --Envados BP
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'R');
		end if;
	end if;


	if movto_sofia='Todos' or movto_sofia='Demo In Servicio' then --Demo In Ventas
		if movto_sofia = 'Todos' then
			expSql=concat(expSql,' union ');
		end if;
		expSql=format(' %12$s select %1$L as movto_sofia, inf.c1 as sucursal, inf.c5 as serie, inf.c2 as inventario, 
			isn.genero as genero, isn.naturaleza as naturaleza, isn.grupo as grupo, isn.tipo as tipo, isn.folio as folio, %10$L as fecha_movto,
			case when isn.notif_estatus is null then %13$L else %14$L end as k80_sofia,
			coalesce(case when isn.notif_estatus = %2$L then %3$L when isn.notif_estatus = %4$L then %5$L when isn.notif_estatus = %6$L then %7$L else %8$L || isn.notif_estatus end , %9$L) as notif_estatus,
			coalesce(isn.notif_fecha,%10$L) as notif_fecha, coalesce(isn.notif_mensaje,%11$L) as sofia_mensaje '
			,'Demo In Servicio','P','Pendiente','R','Error','E','Enviado','Desconocido','No enviado','1800-01-01','',expSql,'Pendiente','Registrado');
		expSql=format('%1$s from keplersc.kdinf inf left outer join keplersc.ifz_sofia_notif isn on isn.sucursal=inf.c1 and isn.serie = inf.c5 and isn.movto_sofia = %2$L',expSql,'Demo In Servicio');
		expSql=format('%1$s where inf.c21=%2$L and inf.c22=%3$L and inf.c27 >= %4$L and inf.c27 >= %5$L and inf.c27 <= %6$L ',expSql,'NUEVO','1',fecha_oper,fecha_inicial,fecha_final);

		if sofia_estatus = 'PK' then --Pendiente kepler
			expSql=format('%1$s and inf.c1 || inf.c5 || %2$L not in 
				(select ifz.sucursal || ifz.serie || %2$L from keplersc.ifz_sofia_notif ifz 
				where ifz.sucursal=inf.c1 and ifz.serie=inf.c5 and ifz.movto_sofia=%2$L) ',expSql,'Demo In Servicio');
		end if;

		if sofia_estatus = 'PB' then --Esttaus BP Sofia
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'P');
		end if;

		if sofia_estatus = 'EK' then --Registrados Kepler
			expSql=format('%1$s and isn.notif_estatus is not null ',expSql);
		end if;

		if sofia_estatus = 'EB' then --Envados BP
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'E');
		end if;

		if sofia_estatus = 'RK' then --Error Kepler, esta condicion no se puede dar
			--expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,sofia_estatus);
		end if;

		if sofia_estatus = 'RB' then --Envados BP
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'R');
		end if;
	end if;

	if movto_sofia='Todos' or movto_sofia='Demo Out' then --Demo In Ventas
		if movto_sofia = 'Todos' then
			expSql=concat(expSql,' union ');
		end if;
		expSql=format(' %12$s select %1$L as movto_sofia, inf.c1 as sucursal, inf.c5 as serie, inf.c2 as inventario, 
			isn.genero as genero, isn.naturaleza as naturaleza, isn.grupo as grupo, isn.tipo as tipo, isn.folio as folio, %10$L as fecha_movto,
			case when isn.notif_estatus is null then %13$L else %14$L end as k80_sofia,
			coalesce(case when isn.notif_estatus = %2$L then %3$L when isn.notif_estatus = %4$L then %5$L when isn.notif_estatus = %6$L then %7$L else %8$L || isn.notif_estatus end , %9$L) as notif_estatus,
			coalesce(isn.notif_fecha,%10$L) as notif_fecha, coalesce(isn.notif_mensaje,%11$L) as sofia_mensaje '
			,'Demo In Out','P','Pendiente','R','Error','E','Enviado','Desconocido','No enviado','1800-01-01','',expSql,'Pendiente','Registrado');
		expSql=format('%1$s from keplersc.kdinf inf left outer join keplersc.ifz_sofia_notif isn on isn.sucursal=inf.c1 and isn.serie = inf.c5 and isn.movto_sofia = %2$L',expSql,'Demo In Out');
		expSql=format('%1$s where inf.c21=%2$L and inf.c22=%3$L and inf.c27 >= %4$L and inf.c27 >= %5$L and inf.c27 <= %6$L ',expSql,'NUEVO','1',fecha_oper,fecha_inicial,fecha_final);

		if sofia_estatus = 'PK' then --Pendiente kepler
			expSql=format('%1$s and inf.c1 || inf.c5 || %2$L not in 
				(select ifz.sucursal || ifz.serie || %2$L from keplersc.ifz_sofia_notif ifz 
				where ifz.sucursal=inf.c1 and ifz.serie=inf.c5 and ifz.movto_sofia=%2$L) ',expSql,'Demo In Out');
		end if;

		if sofia_estatus = 'PB' then --Esttaus BP Sofia
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'P');
		end if;

		if sofia_estatus = 'EK' then --Registrados Kepler
			expSql=format('%1$s and isn.notif_estatus is not null ',expSql);
		end if;

		if sofia_estatus = 'EB' then --Envados BP
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'E');
		end if;

		if sofia_estatus = 'RK' then --Error Kepler, esta condicion no se puede dar
			--expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,sofia_estatus);
		end if;

		if sofia_estatus = 'RB' then --Envados BP
			expSql=format('%1$s and isn.notif_estatus = %2$L ',expSql,'R');
		end if;
	end if;

raise notice 'expSql:% ',expSql;

	select query_to_xml(expSql,false,true,'') into xmlResultado;
	--raise notice '%', xmlFactura

	return xmlResultado;
--exception
--	when others then
		--raise exception '%', 'Sin Resultados';	
--		raise exception '%,%', sqlstate, sqlerrm;	
	
	
end;
$function$
