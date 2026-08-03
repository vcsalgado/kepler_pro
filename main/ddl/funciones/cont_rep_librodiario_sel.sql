CREATE OR REPLACE FUNCTION keplersc.cont_rep_librodiario_sel(dataxml xml)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
declare 
	--Variables de definicion de documento
	sucursal_id text ='';
	fecha_ini text = ''; 
	fecha_fin text = '';
	tipo_poliza text = '';
	

	--Variables de proceso
	error text = '';
	str_mes_ini text = '';
	str_mes_fin text = '';
	int_mes_ini int = 0;
	int_mes_fin int = 0;
	str_anio text = '';
	expSql text = '';
	cont int = 0;
	totReg int =0 ;
	curTabla text = '';
	tablakdc1 text = '';
	tablakdc2 text ='';
	strValor text = '';
	curFecha timestamp;
	curPoliza int;
	curSucursal text;
	xmlPartidas xml;
	resultadoXml xml;

	--variables de retorno
	xmlLibroDiario xml;
begin
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	fecha_ini := (xpath('//document/fecha_ini/text()', dataxml))[1]; --aaaa-mm-dd
	fecha_fin := (xpath('//document/fecha_fin/text()', dataxml))[1]; --aaaa-mm-dd
	tipo_poliza := (xpath('//document/tipo_poliza/text()', dataxml))[1];

	str_anio := substring(fecha_ini, 3, 2);
	str_mes_ini = substring(fecha_ini, 6, 2);
	str_mes_fin = substring(fecha_fin, 6, 2);
	int_mes_ini = str_mes_ini::int;
	int_mes_fin = str_mes_fin::int;

	--Obtener la tabla kdc1 con las cuentas a consultar dependiendo del anio
	tablakdc1 := concat('kdc1',str_anio);
	select count(*) into totReg from information_schema.tables 
	where table_name = tablakdc1;

	if totReg = 0 then
		raise exception 'No se tiene información contable para el año %, tabla(%)', substring(fecha_ini, 3, 2),tablakdc1;
	end if;

	--Crear tabla temporal del reporte
	drop table if exists tmppolizas;
	create temp table tmppolizas(
		sucursal varchar(2),
		fecha timestamp,
		tipo varchar(1),
		no_poliza numeric(5),
		descripcion varchar(40),
		documento varchar(15),
		partidas xml
	);
	create index tmppolizas_1_idx on tmppolizas (sucursal,fecha,tipo,no_poliza);

	--Crear tabla temporal de polizas
	drop table if exists tmpkdc2;
	create temp table tmpkdc2 as select * from keplersc.kdc2;
	create index tmpKdc2_1_idx on tmpkdc2 (c14,c2,c8,c1);

	select count(*) from tmpkdc2 into totReg;

	--Obtener los cargos y abonos del periodo 
	--Copiar los registros de las kdc2 a la tabla temporal dependiendo de los criterios
	for cont in int_mes_ini .. int_mes_fin loop		
		curTabla := concat('kdc2',str_anio,lpad(cont::text,2,'0'));			
		select count(*) into totReg from information_schema.tables
		where table_name  = curTabla;
		if totReg>0 then
			expSql:=format('insert into tmpkdc2 select * from keplersc.%1$s 
				where c14=c14 and c2>=%3$L and c2<=%4$L and c8=%5$L'
				,curTabla,sucursal_id,fecha_ini,fecha_fin,tipo_poliza);			
			execute expSql;		
		end if;
	end loop;
	insert into tmppolizas 	select kdc2.c14 as sucursal, kdc2.c2 as fecha, kdc2.c8 as tipo,
		kdc2.c1 as no_poliza, kdc2.c7 as referencia,
		concat(kdc2.c15,kdc2.c16,lpad(kdc2.c17::text,2,'0'),lpad(kdc2.c18::text,3,'0'),'-',kdc2.c19) as documento,
		''::xml as partidas
		from tmpkdc2 as kdc2
		group by kdc2.c14,kdc2.c2,kdc2.c1, kdc2.c8,kdc2.c7,
			documento;
		--sucursal,fecha,no_poliza,descripcion,referencia

		--Completar con partidas
	for curFecha,curPoliza,curSucursal in 
		select fecha as curFecha, no_poliza as curPoliza, sucursal as curSucursal from tmppolizas
	loop
		expSql:=format('select kdc1.c1 as cuenta, kdc1.c2 as cuenta_descripcion, kdc2.c6 as descripcion,
		case
			when kdc2.c4=%1$L then kdc2.c5
	  		else 0
		end as movto_cargo,
		case
			when kdc2.c4 = %2$L then kdc2.c5
	  		else 0
		end as movto_abono
		from tmpkdc2 as kdc2 inner join keplersc.%3$s as kdc1 on kdc1.c1=kdc2.c3 
		where kdc2.c1=%4$s and kdc2.c2=%5$L and kdc2.c14=%6$L  
		order by cuenta','C','A',tablakdc1,curPoliza,curFecha,curSucursal);
--raise exception '%',expSql;		
		select query_to_xml(expSql,false,true,'') into xmlPartidas;
		update tmppolizas set partidas=xmlPartidas where fecha=curfecha and no_poliza=curpoliza;

	end loop;
	
	select query_to_xml('select * from tmppolizas order by tipo,no_poliza,fecha,sucursal',false,true,'') into xmlLibroDiario;
	return xmlLibroDiario;
exception
	when others then
		error := 'keplersc.cont_rep_librodiario_sel() ' || '['|| sqlstate || '] ' || sqlerrm ;
		raise exception '%', error;	
end;
$function$
