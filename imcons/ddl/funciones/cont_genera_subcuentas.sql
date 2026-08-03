CREATE OR REPLACE FUNCTION keplersc.cont_genera_subcuentas(cuenta_inicial text, cuenta_final text, anio text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Genera saldos de subcuentas y llena tabla KDTEMP700, resuelve ORNA 
--Autor: Miriam Santana
--Fecha: 28/12/2022

	--Variables de definicion de documento
	cuenta_ini text = '';
	cuenta_fin text = '';
	v_anio text;
	
	--Variables de uso general
	tmpCuenta text = '';
	tmpSubcuenta text = '';
	tmp3nivel text = '';
	tablakdc1 text = '';
	expSql text;
	totReg int;
	mesValor int;
	anioValor int;
	strCol text;
	strValor text;
	tot700 int;

	rec record;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	res text;
	msg text;
	adic text;

begin
	cuenta_ini := cuenta_inicial;
	cuenta_fin := concat(cuenta_final,'z');
	v_anio := anio;

	--Obtener la tabla kdc1 con las cuentas a consultar dependiendo del anio
	tablakdc1 := 'kdc1_view';
	select count(*) into totReg from keplersc.kdc1_view kdc1
	where kdc1.anio = v_anio;
	if totReg = 0 then
		raise exception 'No se tiene información contable para el año %', v_anio;
	end if;

	delete from keplersc.kdtemp700;
select count(*) into tot700 from keplersc.kdtemp700;
--raise notice 'Regtemp700:%',tot700;
--raise notice 'anio:% cuenta_ini:% cuenta_fin:%',v_anio,cuenta_ini,cuenta_fin;

	for rec in select * from keplersc.kdc1_view kdc
		where kdc.anio=v_anio and kdc.c1>=cuenta_ini and kdc.c1<=cuenta_fin
		order by c1
	loop
--raise notice 'cuenta:%',rec.c1;

/* Solo para cuentas de ultimo nivel*/
		tmpSubcuenta = right(rec.c1,3);		--obtener subcuenta
		--Validar que cuenta sea de ultimo nivel
		select * into res, msg, adic from keplersc.verify_cuenta_ult_nivel(rec.c1,v_anio);
	
		if res='0' then --Cuenta no es de mas bajo nivel
			continue;
		else 
--raise notice 'Subcuenta:%',tmpSubcuenta;
--raise notice 'Saldos ene:% feb:% mar:% abr:% may:% jun:% jul:% ago:% sep:% oct:% nov:% dic:%',
--	(rec.c27-rec.c63),(rec.c28-rec.c64),(rec.c29-rec.c65),(rec.c30-rec.c66),(rec.c31-rec.c67),(rec.c32-rec.c68),(rec.c33-rec.c69),
--	(rec.c34-rec.c70),(rec.c35-rec.c71),(rec.c36-rec.c72),(rec.c37-rec.c73),(rec.c38-rec.c74);

			select count(*) into totReg 
				from keplersc.kdtemp700
				where c1=tmpSubcuenta;
				if totReg>0 then
--raise notice 'Actualiza %',tmpSubcuenta;
					update keplersc.kdtemp700 
					set
						c4=c4+(rec.c27-rec.c63),
						c5=c5+(rec.c28-rec.c64),
						c6=c6+(rec.c29-rec.c65),
						c7=c7+(rec.c30-rec.c66),
						c8=c8+(rec.c31-rec.c67),
						c9=c9+(rec.c32-rec.c68),
						c10=c10+(rec.c33-rec.c69),
						c11=c11+(rec.c34-rec.c70),
						c12=c12+(rec.c35-rec.c71),
						c13=c13+(rec.c36-rec.c72),
						c14=c14+(rec.c37-rec.c73),
						c15=c15+(rec.c38-rec.c74)
					where c1=tmpSubcuenta;
				else
--raise notice 'Inserta % %',tmpSubcuenta,rec.c2;
					insert into keplersc.kdtemp700 
						(c1,c2,c3,c4,c5,
						c6,c7,c8,c9,c10,
						c11,c12,c13,c14,c15)
					values (			
						tmpSubcuenta,rec.c2,0,(rec.c27-rec.c63),(rec.c28-rec.c64),
						(rec.c29-rec.c65),(rec.c30-rec.c66),(rec.c31-rec.c67),(rec.c32-rec.c68),(rec.c33-rec.c69),
						(rec.c34-rec.c70),(rec.c35-rec.c71),(rec.c36-rec.c72),(rec.c37-rec.c73),(rec.c38-rec.c74));
				end if;
		
		end if;
/* Solo para cuentas de ultimo nivel*/		
		
		
/*
/*	Solo considerar cuentas de 2ndo nivel*/
		tmpSubcuenta = split_part(rec.c1, '-', 2);		--obtener segundo nivel de la cuenta
		tmp3nivel = split_part(rec.c1, '-', 3);			--obtener tercer nivel de la cuenta
 	
		if tmp3nivel <> '' then							--Si tiene mas de 2 niveles no considerar
			continue;
		else
			if tmpSubcuenta <> '' then					--Solo considerar cuentas de 2ndo nivel
	raise notice 'Subcuenta:%',tmpSubcuenta;
	raise notice 'Saldos ene:% feb:% mar:% abr:% may:% jun:% jul:% ago:% sep:% oct:% nov:% dic:%',
	(rec.c27-rec.c63),(rec.c28-rec.c64),(rec.c29-rec.c65),(rec.c30-rec.c66),(rec.c31-rec.c67),(rec.c32-rec.c68),(rec.c33-rec.c69),
	(rec.c34-rec.c70),(rec.c35-rec.c71),(rec.c36-rec.c72),(rec.c37-rec.c73),(rec.c38-rec.c74);
				select count(*) into totReg 
					from keplersc.kdtemp700
					where c1=tmpSubcuenta;
				if totReg>0 then
	raise notice 'Actualiza %',split_part(rec.c1, '-', 2);
	
					update keplersc.kdtemp700 
					set
						c4=c4+(rec.c27-rec.c63),
						c5=c5+(rec.c28-rec.c64),
						c6=c6+(rec.c29-rec.c65),
						c7=c7+(rec.c30-rec.c66),
						c8=c8+(rec.c31-rec.c67),
						c9=c9+(rec.c32-rec.c68),
						c10=c10+(rec.c33-rec.c69),
						c11=c11+(rec.c34-rec.c70),
						c12=c12+(rec.c35-rec.c71),
						c13=c13+(rec.c36-rec.c72),
						c14=c14+(rec.c37-rec.c73),
						c15=c15+(rec.c38-rec.c74)
					where c1=tmpSubcuenta;
				else
	raise notice 'Inserta % %',split_part(rec.c1, '-', 2),rec.c2;
				insert into keplersc.kdtemp700 
						(c1,c2,c3,c4,c5,
						c6,c7,c8,c9,c10,
						c11,c12,c13,c14,c15)
					values (			
						split_part(rec.c1, '-', 2),rec.c2,0,(rec.c27-rec.c63),(rec.c28-rec.c64),
						(rec.c29-rec.c65),(rec.c30-rec.c66),(rec.c31-rec.c67),(rec.c32-rec.c68),(rec.c33-rec.c69),
						(rec.c34-rec.c70),(rec.c35-rec.c71),(rec.c36-rec.c72),(rec.c37-rec.c73),(rec.c38-rec.c74));
				end if;
			end if;
		end if;
*/ /*	Solo considerar cuentas de 2ndo nivel*/		
	end loop;
--raise exception '%','Alto Manual';
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cont_genera_subcuentas() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
