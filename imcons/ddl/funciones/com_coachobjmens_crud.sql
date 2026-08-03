CREATE OR REPLACE FUNCTION keplersc.com_coachobjmens_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Descripcion. Función para actualizar la tabla KDOBJGV
	-- relacionada con coaches objetivos mensuales
	--Autor: Gad Miranda 
	--Fecha: 18 Enero 2023
	--Variables de definicion de documento
    k_suc text = '';
    k_coach text = '';
    mes text = '';
    anio text = '';
    k_ent1 numeric(5) = 0;
	k_ent2 numeric(5) = 0;
	k_ub numeric(5,2) = 0.00;
	k_fin1 numeric(5) = 0;
	k_fin2 numeric(5) = 0; 
	k_csi1 numeric(5,2) = 0.00;
	k_csi2 numeric(5,2) = 0.00;
	k_dias1 numeric(5) = 0;
	k_dias2 numeric(5) = 0;
	k_fact numeric(5) = 0;
	k_tomas numeric(5) = 0;
	k_grext numeric(5) = 0;
	k_accesor numeric(10,2) = 0.00;
	k_contado numeric(10,2) = 0.00;
	k_sem_fact numeric(5) = 0;
	k_sem_ent1 numeric(5) = 0;
	k_sem_ent2 numeric(5) = 0;
	k_sem_fin1 numeric(5) = 0;
	k_sem_fin2 numeric(5) = 0;


	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	k_mes_anterior text = '';
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	--Variables de proceso
	k_suc_ text = '';
	k_coach_  text = '';
	mes_  text = '';
	anio_  text = '';
    k_ent1_ numeric(5) = 0;
	k_ent2_ numeric(5) = 0;
	k_ub_ numeric(5,2) = 0.00;
	k_fin1_ numeric(5) = 0;
	k_fin2_ numeric(5) = 0; 
	k_csi1_ numeric(5,2) = 0.00;
	k_csi2_ numeric(5,2) = 0.00;
	k_dias1_ numeric(5) = 0;
	k_dias2_ numeric(5) = 0;
	k_fact_ numeric(5) = 0;
	k_tomas_ numeric(5) = 0;
	k_grext_ numeric(5) = 0;
	k_accesor_ numeric(10,2) = 0.00;
	k_contado_ numeric(10,2) = 0.00;
	k_sem_fact_ numeric(5) = 0;
	k_sem_ent1_ numeric(5) = 0;
	k_sem_ent2_ numeric(5) = 0;
	k_sem_fin1_ numeric(5) = 0;
	k_sem_fin2_ numeric(5) = 0;

	BEGIN
	k_mes_anterior = (xpath('//document/k_mes_anterior/text()', dataxml))[1];
    k_suc = (xpath('//document/k_suc/r1/text()', dataxml))[1];
	k_coach = (xpath('//document/k_coach/r1/text()', dataxml))[1];
	mes = (xpath('//document/k_mes/r0/text()', dataxml))[1];
	anio = (xpath('//document/k_anio/r0/text()', dataxml))[1];
    k_ent1 = (xpath('//document/k_ent1/text()', dataxml))[1];
	k_ent2 = (xpath('//document/k_ent2/text()', dataxml))[1];
	k_ub = (xpath('//document/k_ub/text()', dataxml))[1];
	k_fin1 = (xpath('//document/k_fin1/text()', dataxml))[1];
	k_fin2 = (xpath('//document/k_fin2/text()', dataxml))[1];
	k_csi1 = (xpath('//document/k_csi1/text()', dataxml))[1];
	k_csi2 = (xpath('//document/k_csi2/text()', dataxml))[1];
	k_dias1 = (xpath('//document/k_dias1/text()', dataxml))[1];
	k_dias2 = (xpath('//document/k_dias2/text()', dataxml))[1];
	k_fact = (xpath('//document/k_fact/text()', dataxml))[1];
	k_tomas = (xpath('//document/k_tomas/text()', dataxml))[1];
	k_grext = (xpath('//document/k_grext/text()', dataxml))[1];
	k_accesor = (xpath('//document/k_accesor/text()', dataxml))[1];
	k_contado = (xpath('//document/k_contado/text()', dataxml))[1];
	k_sem_fact = (xpath('//document/k_sem_fact/text()', dataxml))[1];
	k_sem_ent1 = (xpath('//document/k_sem_ent1/text()', dataxml))[1];
	k_sem_ent2 = (xpath('//document/k_sem_ent2/text()', dataxml))[1];
	k_sem_fin1 = (xpath('//document/k_sem_fin1/text()', dataxml))[1];
	k_sem_fin2 = (xpath('//document/k_sem_fin2/text()', dataxml))[1];

	drop table if exists tmpTable;
	create temp table tmpTable (
	    _k_suc text,
    	_k_coach text,
    	_mes text,
    	_anio text,
    	_k_ent1 numeric(5),
		_k_ent2 numeric(5),
		_k_ub numeric(5,2),
		_k_fin1 numeric(5),
		_k_fin2 numeric(5),
		_k_csi1 numeric(5,2),
		_k_csi2 numeric(5,2),
		_k_dias1 numeric(5),
		_k_dias2 numeric(5),
		_k_fact numeric(5),
		_k_tomas numeric(5),
		_k_grext numeric(5),
		_k_accesor numeric(10,2),
		_k_contado numeric(10,2),
		_k_sem_fact numeric(5),
		_k_sem_ent1 numeric(5),
		_k_sem_ent2 numeric(5),
		_k_sem_fin1 numeric(5),
		_k_sem_fin2 numeric(5) 
	);

	if k_mes_anterior = 'Y' then

		delete from keplersc.KDOBJGV 
		where c1=k_suc and c2=k_coach and c3=mes and c4=anio;

		insert into keplersc.KDOBJGV (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10
			,c11, c12, c13, c14, c15, c16, c17, c18, c19, c20, c21, c22, c23, c24)
			values (k_suc,k_coach,mes,anio
			,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');

		INSERT INTO tmpTable (_k_suc, _k_coach, _mes, _anio,
    		_k_ent1, _k_ent2, _k_ub, _k_fin1, _k_fin2,
			_k_csi1, _k_csi2, _k_dias1,	_k_dias2,
			_k_fact, _k_tomas, _k_grext, _k_accesor,
			_k_contado,	_k_sem_fact, _k_sem_ent1,
			_k_sem_ent2, _k_sem_fin1, _k_sem_fin2)
		values (k_suc,k_coach,mes,anio
		,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');

		--- trae registro mes anterior 
		for k_suc_, k_coach_, mes_, anio_, k_ent1_, k_ent2_, k_ub_, k_fin1_, k_fin2_,
			k_csi1_, k_csi2_, k_dias1_, k_dias2_, k_fact_, k_tomas_, k_grext_, k_accesor_,
			k_contado_, k_sem_fact_, k_sem_ent1_, k_sem_ent2_, k_sem_fin1_, k_sem_fin2_
			in select c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c20,c21,c22,c23,c24 
			from keplersc.KDOBJGV where c1= k_suc and c2= k_coach 
			order by c4 desc,c3 desc limit 1
		loop 
			update tmpTable set _k_suc=k_suc_,_k_coach=k_coach_,_mes=mes_,_anio=anio_,_k_ent1=k_ent1_,_k_ent2=k_ent2_
			,_k_ub=k_ub_,_k_fin1=k_fin1_,_k_fin2=k_fin2_,_k_csi1=k_csi1_,_k_csi2=k_csi2_,_k_dias1=k_dias1_
			,_k_dias2=k_dias2_,_k_fact=k_fact_,_k_tomas=k_tomas_,_k_grext=k_grext_,_k_accesor=k_accesor_
			,_k_contado=k_contado_,_k_sem_fact=k_sem_fact_,_k_sem_ent1=k_sem_ent1_,_k_sem_ent2=k_sem_ent2_
			,_k_sem_fin1= k_sem_fin1_,_k_sem_fin2=k_sem_fin2_
			where _k_suc=k_suc_	and _k_coach=k_coach_ and _mes=mes and _anio=anio;

			update keplersc.KDOBJGV
				set c1 = k_suc_
				,c2 = k_coach_
				,c3 = mes
				,c4 = anio
				,c5 = k_ent1_
				,c6 = k_ent2_
				,c7 = k_ub_
				,c8 = k_fin1_
				,c9 = k_fin2_
				,c10 = k_csi1_
				,c11 = k_csi2_
				,c12 = k_dias1_
				,c13 = k_dias2_
				,c14 = k_fact_
				,c15 = k_tomas_
				,c16 = k_grext_
				,c17 = k_accesor_
				,c18 = k_contado_
				,c19 = '0' 
				,c20 = k_sem_fact_
				,c21 = k_sem_ent1_
				,c22 = k_sem_ent2_
				,c23 = k_sem_fin1_
				,c24 = k_sem_fin2_
				where c1 = k_suc and c2= k_coach and c3= mes and c4 = anio;
		end loop;
	elsif k_mes_anterior = 'N' then	
		delete from keplersc.KDOBJGV 
		where c1=k_suc and c2=k_coach and c3=mes and c4=anio;

		insert into keplersc.KDOBJGV (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10
			,c11, c12, c13, c14, c15, c16, c17, c18, c19, c20, c21, c22, c23, c24)
			values (k_suc,k_coach,mes,anio
			,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');
	
	elsif k_mes_anterior = '' then

		delete from keplersc.KDOBJGV 
		where c1=k_suc and c2=k_coach and c3=mes and c4=anio;

		insert into keplersc.KDOBJGV (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10
			,c11, c12, c13, c14, c15, c16, c17, c18, c19, c20, c21, c22, c23, c24)
		    values (k_suc,k_coach,mes,anio
			,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');

		update keplersc.KDOBJGV
						set c5 = k_ent1
						,c6 = k_ent2
						,c7 = k_ub
						,c8 = k_fin1
						,c9 = k_fin2
						,c10 = k_csi1
						,c11 = k_csi2
						,c12 = k_dias1
						,c13 = k_dias2
						,c14 = k_fact
						,c15 = k_tomas
						,c16 = k_grext
						,c17 = k_accesor
						,c18 = k_contado
						,c19 = '0' 
						,c20 = k_sem_fact
						,c21 = k_sem_ent1
						,c22 = k_sem_ent2
						,c23 = k_sem_fin1 
						,c24 = k_sem_fin2
						where c1 = k_suc and c2= k_coach and c3= mes and c4 = anio;

	end if;
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'com_coachobjmens_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	END;
$function$
