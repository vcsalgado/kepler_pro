CREATE OR REPLACE FUNCTION keplersc.tmp_cont_saldos_finales_sel(cuenta_inicial text, cuenta_final text, anio text, nivel text, id_job uuid)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
declare 
--Descripcion: Genera informacion para reporte Contabilidad- Saldos Mensuales OCRNF 
--Autor: Miriam Santana
--Fecha: 03/29/2023
	--Variables de definicion de documento
	cuenta_ini text = '';
	cuenta_fin text = '';
	nivel_reporte text = '9';
	intNivel int = 0;
	v_anio text;
	
	--Variables de proceso
	error text = '';
	expSql text = '';
	cont int = 0;
	totReg int =0 ;
	curTabla text = '';
	tablakdc1 text = '';
	strValor text = '';

	--Variables proceso nivel cuenta
	strCadenaCuentas text = '';
	strTmpCadena text = '';
	tmpCuenta text = '';
	ultima_cuenta text = '';
	cuenta_base text = '';
	nivel_cuenta int = 0;
	cont_orden int =0;
	cont_cuentas int =0;
	niveles_totales int =0;
	es_subcuenta text = '';

begin	
	cuenta_ini := cuenta_inicial;
	cuenta_fin := cuenta_final;
	nivel_reporte := nivel;
	intNivel := nivel_reporte::int;
	v_anio := anio;

	--Obtener la tabla kdc1 con las cuentas a consultar dependiendo del anio
	tablakdc1 := 'kdc1_view';
	select count(*) into totReg from keplersc.kdc1_view kdc1
	where kdc1.anio = v_anio;
	if totReg = 0 then
		raise exception 'No se tiene información contable para el año %', v_anio;
	end if;

	delete from keplersc.tmp_cont_saldos_finales
		where fecha_ejecucion < current_date;

	--Obtener el nivel mas alto de la cuenta inicial
	tmpCuenta := concat(cuenta_ini,'%');
	expSql:=format('select coalesce(min(c1),%3$L) from keplersc.%1$s where position(c1 in %2$L)=1 and c1<>%3$L and anio=%4$L',tablakdc1,tmpCuenta,'',v_anio);

	execute expSql into strValor;

	if strValor <> '' then
		cuenta_ini = strValor;
	end if;

	--Obtener el ultimo nivel de la cuenta final
	tmpCuenta := concat(cuenta_fin,'%');
	expSql:=format('select coalesce(max(c1),%3$L) from keplersc.%1$s where c1 like %2$L and anio=%4$L',tablakdc1,tmpCuenta,'',v_anio);

	execute expSql into strValor;

	if strValor <> '' then
		cuenta_fin = strValor;
	end if;

	drop table if exists tmpkdc1;
	create temp table tmpkdc1 (
		cuenta text,
		desc_cuenta text,
		nivel numeric(2,0),
		saldo_inicial numeric(15,2),
		saldo_ene numeric(15,2),
		saldo_feb numeric(15,2),
		saldo_mar numeric(15,2),
		saldo_abr numeric(15,2),
		saldo_may numeric(15,2),
		saldo_jun numeric(15,2),
		saldo_jul numeric(15,2),
		saldo_ago numeric(15,2),
		saldo_sep numeric(15,2),
		saldo_oct numeric(15,2),
		saldo_nov numeric(15,2),
		saldo_dic numeric(15,2),
		orden serial
	);


--Llenar la tabla auxiliar calculando los niveles de las cuentas de kdc1, guaradar saldo inicial al 1 de enero (c14)
	expSql = format('insert into tmpkdc1(cuenta,desc_cuenta,saldo_inicial,saldo_ene,saldo_feb,saldo_mar,
		saldo_abr,saldo_may,saldo_jun,saldo_jul,saldo_ago,saldo_sep,saldo_oct,saldo_nov,saldo_dic) 
		select c1,c2,coalesce(c14, 0),
			 coalesce(c14,0)+(coalesce(c27,0)-coalesce(c63,0)),
			(coalesce(c14,0)+(coalesce(c27,0)-coalesce(c63,0)))+(coalesce(c28,0)-coalesce(c64,0)),
			((coalesce(c14,0)+(coalesce(c27,0)-coalesce(c63,0)))+(coalesce(c28,0)-coalesce(c64,0)))
			+(coalesce(c29,0)-coalesce(c65,0)),
			(((coalesce(c14,0)+(coalesce(c27,0)-coalesce(c63,0)))+(coalesce(c28,0)-coalesce(c64,0)))
			+(coalesce(c29,0)-coalesce(c65,0)))+(coalesce(c30,0)-coalesce(c66,0)),
			((((coalesce(c14,0)+(coalesce(c27,0)-coalesce(c63,0)))+(coalesce(c28,0)-coalesce(c64,0)))
			+(coalesce(c29,0)-coalesce(c65,0)))+(coalesce(c30,0)-coalesce(c66,0)))+(coalesce(c31,0)-coalesce(c67,0)),
			(((((coalesce(c14,0)+(coalesce(c27,0)-coalesce(c63,0)))+(coalesce(c28,0)-coalesce(c64,0)))
			+(coalesce(c29,0)-coalesce(c65,0)))+(coalesce(c30,0)-coalesce(c66,0)))+(coalesce(c31,0)-coalesce(c67,0)))
			+(coalesce(c32,0)-coalesce(c68,0)),
			((((((coalesce(c14,0)+(coalesce(c27,0)-coalesce(c63,0)))+(coalesce(c28,0)-coalesce(c64,0)))
			+(coalesce(c29,0)-coalesce(c65,0)))+(coalesce(c30,0)-coalesce(c66,0)))+(coalesce(c31,0)-coalesce(c67,0)))
			+(coalesce(c32,0)-coalesce(c68,0)))+(coalesce(c33,0)-coalesce(c69,0)),
			(((((((coalesce(c14,0)+(coalesce(c27,0)-coalesce(c63,0)))+(coalesce(c28,0)-coalesce(c64,0)))
			+(coalesce(c29,0)-coalesce(c65,0)))+(coalesce(c30,0)-coalesce(c66,0)))+(coalesce(c31,0)-coalesce(c67,0)))
			+(coalesce(c32,0)-coalesce(c68,0)))+(coalesce(c33,0)-coalesce(c69,0)))+(coalesce(c34,0)-coalesce(c70,0)),
			((((((((coalesce(c14,0)+(coalesce(c27,0)-coalesce(c63,0)))+(coalesce(c28,0)-coalesce(c64,0)))
			+(coalesce(c29,0)-coalesce(c65,0)))+(coalesce(c30,0)-coalesce(c66,0)))+(coalesce(c31,0)-coalesce(c67,0)))
			+(coalesce(c32,0)-coalesce(c68,0)))+(coalesce(c33,0)-coalesce(c69,0)))+(coalesce(c34,0)-coalesce(c70,0)))
			+(coalesce(c35,0)-coalesce(c71,0)),
			(((((((((coalesce(c14,0)+(coalesce(c27,0)-coalesce(c63,0)))+(coalesce(c28,0)-coalesce(c64,0)))
			+(coalesce(c29,0)-coalesce(c65,0)))+(coalesce(c30,0)-coalesce(c66,0)))+(coalesce(c31,0)-coalesce(c67,0)))
			+(coalesce(c32,0)-coalesce(c68,0)))+(coalesce(c33,0)-coalesce(c69,0)))+(coalesce(c34,0)-coalesce(c70,0)))
			+(coalesce(c35,0)-coalesce(c71,0)))+(coalesce(c36,0)-coalesce(c72,0)),
			((((((((((coalesce(c14,0)+(coalesce(c27,0)-coalesce(c63,0)))+(coalesce(c28,0)-coalesce(c64,0)))
			+(coalesce(c29,0)-coalesce(c65,0)))+(coalesce(c30,0)-coalesce(c66,0)))+(coalesce(c31,0)-coalesce(c67,0)))
			+(coalesce(c32,0)-coalesce(c68,0)))+(coalesce(c33,0)-coalesce(c69,0)))+(coalesce(c34,0)-coalesce(c70,0)))
			+(coalesce(c35,0)-coalesce(c71,0)))+(coalesce(c36,0)-coalesce(c72,0)))+(coalesce(c37,0)-coalesce(c73,0)),
			(((((((((((coalesce(c14,0)+(coalesce(c27,0)-coalesce(c63,0)))+(coalesce(c28,0)-coalesce(c64,0)))
			+(coalesce(c29,0)-coalesce(c65,0)))+(coalesce(c30,0)-coalesce(c66,0)))+(coalesce(c31,0)-coalesce(c67,0)))
			+(coalesce(c32,0)-coalesce(c68,0)))+(coalesce(c33,0)-coalesce(c69,0)))+(coalesce(c34,0)-coalesce(c70,0)))
			+(coalesce(c35,0)-coalesce(c71,0)))+(coalesce(c36,0)-coalesce(c72,0)))+(coalesce(c37,0)-coalesce(c73,0)))
			+(coalesce(c38,0)-coalesce(c74,0))
			from keplersc.%1$s where c1 >= %2$L and c1 <= %3$L and anio =%4$L order by c1',tablakdc1,cuenta_ini,cuenta_fin,v_anio); 


	execute expSql;


	--Determinar niveles de cuentas
	ultima_cuenta := '';
	cuenta_base := '';
	niveles_totales:=0;
	strCadenaCuentas := '';
	strTmpCadena := '';
	for ultima_cuenta in 
		select kdc1.cuenta as ultima_cuenta from tmpkdc1 as kdc1 where kdc1.cuenta <> '' order by kdc1.cuenta
	loop
		nivel_cuenta := 0;
		es_subcuenta := 'N';
		if strCadenaCuentas <> '' then
			for cont_cuentas in 1 .. niveles_totales loop
				tmpCuenta := split_part(strCadenaCuentas, '|', cont_cuentas);
				if  position(tmpCuenta in ultima_cuenta) = 1 then
					nivel_cuenta := nivel_cuenta + 1;
					es_subcuenta='S';
				else
					es_subcuenta='N';
				end if;

				if strTmpCadena <> '' then
					strTmpCadena := concat(strTmpCadena,'|');
				end if;
			
				if es_subcuenta = 'S' then 
					strTmpCadena := concat(strTmpCadena,tmpCuenta);
				else
					exit;
				end if;
			end loop;
		
			--Agregar cuenta al final de la cadena
			if strTmpCadena <> ''  then
				if right(strTmpCadena,1) <> '|' then
					strTmpCadena := concat(strTmpCadena,'|');	
				end if;
				nivel_cuenta := nivel_cuenta +1;
				strTmpCadena := concat(strTmpCadena,ultima_cuenta);				
			else 
				nivel_cuenta := 1;
				strTmpCadena := ultima_cuenta;						
			end if;		
		
		else --Inicial
			nivel_cuenta:=1;
			niveles_totales:=1;
			strTmpCadena:=ultima_cuenta;
		end if;
		strCadenaCuentas:=strTmpCadena;
		niveles_totales := nivel_cuenta;
		strTmpCadena:='';
		update tmpkdc1 as aux set nivel = nivel_cuenta where aux.cuenta = ultima_cuenta;
	end loop;	

delete from tmpkdc1 as sf where sf.nivel > intNivel;

insert into keplersc.tmp_cont_saldos_finales(cuenta, desc_cuenta, nivel, saldo_inicial, saldo_ene, saldo_feb, saldo_mar,
		saldo_abr, saldo_may, saldo_jun, saldo_jul, saldo_ago, saldo_sep, saldo_oct, saldo_nov, saldo_dic, id_consulta, fecha_ejecucion, orden) 
	select tmp.cuenta, tmp.desc_cuenta, tmp.nivel, tmp.saldo_inicial, tmp.saldo_ene, tmp.saldo_feb, tmp.saldo_mar,
		tmp.saldo_abr, tmp.saldo_may, tmp.saldo_jun, tmp.saldo_jul, tmp.saldo_ago, tmp.saldo_sep, tmp.saldo_oct, 
		tmp.saldo_nov, tmp.saldo_dic, id_job, current_date, tmp.orden
	from tmpkdc1 tmp;

	return 1;
end;
$function$
