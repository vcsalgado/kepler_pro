CREATE OR REPLACE FUNCTION keplersc.invr_actualizar_estadistica()
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	/*
	 * Descripcion: Recalcula las estadisticas de prouctos
	 * Autor: Victor Salgado
	 * Fecha: 25 Agosto 2023
	 */
	rec_KDINM record;
	rec_KDINK record;
	rec_KDINL record;
	anio_actual text = '';
	mes_actual int ;
	fecha_ult_mov timestamp;
	producto_origen text = '';
	sucursal_id text = '';
	producto_ant text = '';
	producto_act text = '';
	totProd int = 0;
	totRows int=0;
	strValor text;
	resultado text = '';
	mensaje text = '';
    adicionales text = '';
begin   
	--Sustituir en kdinm las partes reemplazo por los originales
raise exception 'Funcion deshabilitada';
	for rec_KDINM in select distinct c2 from keplersc.kdinm inm 
		where c2 in (select c1 from keplersc.kdinr nr where nr.c1=inm.c2) 
		order by inm.c2
	loop --Partes reemplazo

		totProd = 1;
		producto_origen:=rec_KDINM.c2;
		while totProd > 0 loop	
			select count(*) into totProd from keplersc.kdinr where c1 = producto_origen;
			if totProd > 0 then
				select c2 into producto_origen from keplersc.kdinr where c1 = producto_origen;
			end if;
		end loop;
raise notice 'Actualizando KDINM Reemplazo:%, Origen:%', rec_KDINM.c2,producto_origen;		
		update keplersc.kdinm set c2=producto_origen where c2=rec_KDINM.c2;
	end loop;

	--Iniciar tablas de estadisticas
	truncate table keplersc.kdink;
	truncate table keplersc.kdinl;
	truncate table keplersc.kdreflastmov;

	--Iniciar tablas de estadisticas con productos
	insert into keplersc.kdink (c1,c2,c3) values('00','0', '0000'); --registro dummy temporal
	insert into keplersc.kdinl (c1,c2) values('00','0'); --registro dummy temporal

	producto_ant = '';
	for sucursal_id, producto_act, anio_actual  in 
		select distinct c1,c2,extract(year from c3 )::text from keplersc.kdinm inm 
		where c2<>'' order by c1,c2 
	loop
raise notice 'Procesando parte:%', rec_KDINM.c2;
raise notice 'PASO 1 en Suc:%, Prod.:%, Fecha:%',sucursal_id,producto_act,anio_actual;	
		--Crear variables registros de tablas de estadisticas, estan en 0 los importes
		select * into rec_KDINK from keplersc.kdink where c1='00';
		if producto_act <> producto_ant then
			if producto_ant <> '' then
				insert into keplersc.kdinl(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20)
				values(rec_KDINL.c1,rec_KDINL.c2,rec_KDINL.c3,rec_KDINL.c4,rec_KDINL.c5,
					rec_KDINL.c6,rec_KDINL.c7,rec_KDINL.c8,rec_KDINL.c9,rec_KDINL.c10,rec_KDINL.c11,
					rec_KDINL.c12,rec_KDINL.c13,rec_KDINL.c14,rec_KDINL.c15,rec_KDINL.c16,
					rec_KDINL.c17,rec_KDINL.c18,rec_KDINL.c19,rec_KDINL.c20);				
			end if;
		
			select * into rec_KDINL from keplersc.kdinl where c1='00';
			producto_ant = producto_act;
		end if;
		rec_KDINK.c1=sucursal_id;
		rec_KDINK.c2=producto_act;
		rec_KDINK.c3=anio_actual;
		rec_KDINL.c1=sucursal_id; 
		rec_KDINL.c2=producto_act;
raise notice 'PASO 2 en Suc:%, Prod.:%, Fecha:%',sucursal_id,producto_act,fecha_ult_mov;	
		--Actualizar estadisticas por cada producto
		for rec_KDINM in select * from keplersc.kdinm inm 
			where inm.c1=sucursal_id and c2=producto_act and extract(year from c3 )::text=anio_actual order by c1,c2,c3 --c11 Cantidad, c12 Monto
		loop
			select extract(month from rec_KDINM.c3) into mes_actual;
			--Sucursal, producto, anio
			if rec_KDINM.c6 = 'A' then --Naturaleza 'A', Entradas
				if mes_actual=1 then
					rec_KDINK.c10=rec_KDINK.c10+rec_KDINM.c11;
					rec_KDINK.c22=rec_KDINK.c22+rec_KDINM.c12;
					rec_KDINL.c5=rec_KDINL.c5+rec_KDINM.c11;
					rec_KDINL.c8=rec_KDINL.c8+rec_KDINM.c12;
				end if;
				if mes_actual=2 then
					rec_KDINK.c11=rec_KDINK.c11+rec_KDINM.c11;
					rec_KDINK.c23=rec_KDINK.c23+rec_KDINM.c12;
					rec_KDINL.c5=rec_KDINL.c5+rec_KDINM.c11;
					rec_KDINL.c8=rec_KDINL.c8+rec_KDINM.c12;
				end if;
				if mes_actual=3 then
					rec_KDINK.c12=rec_KDINK.c12+rec_KDINM.c11;
					rec_KDINK.c24=rec_KDINK.c24+rec_KDINM.c12;
					rec_KDINL.c5=rec_KDINL.c5+rec_KDINM.c11;
					rec_KDINL.c8=rec_KDINL.c8+rec_KDINM.c12;
				end if;
				if mes_actual=4 then
					rec_KDINK.c13=rec_KDINK.c13+rec_KDINM.c11;
					rec_KDINK.c25=rec_KDINK.c25+rec_KDINM.c12;
					rec_KDINL.c5=rec_KDINL.c5+rec_KDINM.c11;
					rec_KDINL.c8=rec_KDINL.c8+rec_KDINM.c12;
				end if;
				if mes_actual=5 then
					rec_KDINK.c14=rec_KDINK.c14+rec_KDINM.c11;
					rec_KDINK.c26=rec_KDINK.c26+rec_KDINM.c12;
					rec_KDINL.c5=rec_KDINL.c5+rec_KDINM.c11;
					rec_KDINL.c8=rec_KDINL.c8+rec_KDINM.c12;
				end if;
				if mes_actual=6 then
					rec_KDINK.c15=rec_KDINK.c15+rec_KDINM.c11;
					rec_KDINK.c27=rec_KDINK.c27+rec_KDINM.c12;
					rec_KDINL.c5=rec_KDINL.c5+rec_KDINM.c11;
					rec_KDINL.c8=rec_KDINL.c8+rec_KDINM.c12;
				end if;
				if mes_actual=7 then
					rec_KDINK.c16=rec_KDINK.c16+rec_KDINM.c11;
					rec_KDINK.c28=rec_KDINK.c28+rec_KDINM.c12;
					rec_KDINL.c5=rec_KDINL.c5+rec_KDINM.c11;
					rec_KDINL.c8=rec_KDINL.c8+rec_KDINM.c12;
				end if;
				if mes_actual=8 then
					rec_KDINK.c17=rec_KDINK.c17+rec_KDINM.c11;
					rec_KDINK.c29=rec_KDINK.c29+rec_KDINM.c12;
					rec_KDINL.c5=rec_KDINL.c5+rec_KDINM.c11;
					rec_KDINL.c8=rec_KDINL.c8+rec_KDINM.c12;
				end if;
				if mes_actual=9 then
					rec_KDINK.c18=rec_KDINK.c18+rec_KDINM.c11;
					rec_KDINK.c30=rec_KDINK.c30+rec_KDINM.c12;
					rec_KDINL.c5=rec_KDINL.c5+rec_KDINM.c11;
					rec_KDINL.c8=rec_KDINL.c8+rec_KDINM.c12;
				end if;
				if mes_actual=10 then
					rec_KDINK.c19=rec_KDINK.c19+rec_KDINM.c11;
					rec_KDINK.c31=rec_KDINK.c31+rec_KDINM.c12;
					rec_KDINL.c5=rec_KDINL.c5+rec_KDINM.c11;
					rec_KDINL.c8=rec_KDINL.c8+rec_KDINM.c12;
				end if;
				if mes_actual=11 then
					rec_KDINK.c20=rec_KDINK.c20+rec_KDINM.c11;
					rec_KDINK.c32=rec_KDINK.c32+rec_KDINM.c12;
					rec_KDINL.c5=rec_KDINL.c5+rec_KDINM.c11;
					rec_KDINL.c8=rec_KDINL.c8+rec_KDINM.c12;
				end if;
				if mes_actual=12 then
					rec_KDINK.c21=rec_KDINK.c21+rec_KDINM.c11;
					rec_KDINK.c33=rec_KDINK.c33+rec_KDINM.c12;
					rec_KDINL.c5=rec_KDINL.c5+rec_KDINM.c11;
					rec_KDINL.c8=rec_KDINL.c8+rec_KDINM.c12;
				end if;
				rec_KDINL.c15=rec_KDINL.c14;
				if rec_KDINM.c11>0 then
					rec_KDINL.c14=rec_KDINM.c12/rec_KDINM.c11;
				else
					rec_KDINL.c14=0;
				end if;
			else --Naturaleza 'D', Salidas
				if mes_actual=1 then
					rec_KDINK.c40=rec_KDINK.c40+rec_KDINM.c11;
					rec_KDINK.c52=rec_KDINK.c52+rec_KDINM.c12;
					rec_KDINL.c6=rec_KDINL.c6+rec_KDINM.c11;
					rec_KDINL.c9=rec_KDINL.c9+rec_KDINM.c12;
				end if;
				if mes_actual=2 then
					rec_KDINK.c41=rec_KDINK.c41+rec_KDINM.c11;
					rec_KDINK.c53=rec_KDINK.c53+rec_KDINM.c12;
					rec_KDINL.c6=rec_KDINL.c6+rec_KDINM.c11;
					rec_KDINL.c9=rec_KDINL.c9+rec_KDINM.c12;
				end if;
				if mes_actual=3 then
					rec_KDINK.c42=rec_KDINK.c42+rec_KDINM.c11;
					rec_KDINK.c54=rec_KDINK.c54+rec_KDINM.c12;
					rec_KDINL.c6=rec_KDINL.c6+rec_KDINM.c11;
					rec_KDINL.c9=rec_KDINL.c9+rec_KDINM.c12;
				end if;
				if mes_actual=4 then
					rec_KDINK.c43=rec_KDINK.c43+rec_KDINM.c11;
					rec_KDINK.c55=rec_KDINK.c55+rec_KDINM.c12;
					rec_KDINL.c6=rec_KDINL.c6+rec_KDINM.c11;
					rec_KDINL.c9=rec_KDINL.c9+rec_KDINM.c12;
				end if;
				if mes_actual=5 then
					rec_KDINK.c44=rec_KDINK.c44+rec_KDINM.c11;
					rec_KDINK.c56=rec_KDINK.c56+rec_KDINM.c12;
					rec_KDINL.c6=rec_KDINL.c6+rec_KDINM.c11;
					rec_KDINL.c9=rec_KDINL.c9+rec_KDINM.c12;
				end if;
				if mes_actual=6 then
					rec_KDINK.c45=rec_KDINK.c45+rec_KDINM.c11;
					rec_KDINK.c57=rec_KDINK.c57+rec_KDINM.c12;
					rec_KDINL.c6=rec_KDINL.c6+rec_KDINM.c11;
					rec_KDINL.c9=rec_KDINL.c9+rec_KDINM.c12;
				end if;
				if mes_actual=7 then
					rec_KDINK.c46=rec_KDINK.c46+rec_KDINM.c11;
					rec_KDINK.c58=rec_KDINK.c58+rec_KDINM.c12;
					rec_KDINL.c6=rec_KDINL.c6+rec_KDINM.c11;
					rec_KDINL.c9=rec_KDINL.c9+rec_KDINM.c12;
				end if;
				if mes_actual=8 then
					rec_KDINK.c47=rec_KDINK.c47+rec_KDINM.c11;
					rec_KDINK.c59=rec_KDINK.c59+rec_KDINM.c12;
					rec_KDINL.c6=rec_KDINL.c6+rec_KDINM.c11;
					rec_KDINL.c9=rec_KDINL.c9+rec_KDINM.c12;
				end if;
				if mes_actual=9 then
					rec_KDINK.c48=rec_KDINK.c48+rec_KDINM.c11;
					rec_KDINK.c60=rec_KDINK.c60+rec_KDINM.c12;
					rec_KDINL.c6=rec_KDINL.c6+rec_KDINM.c11;
					rec_KDINL.c9=rec_KDINL.c9+rec_KDINM.c12;
				end if;
				if mes_actual=10 then
					rec_KDINK.c49=rec_KDINK.c49+rec_KDINM.c11;
					rec_KDINK.c61=rec_KDINK.c61+rec_KDINM.c12;
					rec_KDINL.c6=rec_KDINL.c6+rec_KDINM.c11;
					rec_KDINL.c9=rec_KDINL.c9+rec_KDINM.c12;
				end if;
				if mes_actual=11 then
					rec_KDINK.c50=rec_KDINK.c50+rec_KDINM.c11;
					rec_KDINK.c62=rec_KDINK.c62+rec_KDINM.c12;
					rec_KDINL.c6=rec_KDINL.c6+rec_KDINM.c11;
					rec_KDINL.c9=rec_KDINL.c9+rec_KDINM.c12;
				end if;
				if mes_actual=12 then
					rec_KDINK.c51=rec_KDINK.c51+rec_KDINM.c11;
					rec_KDINK.c63=rec_KDINK.c63+rec_KDINM.c12;
					rec_KDINL.c6=rec_KDINL.c6+rec_KDINM.c11;
					rec_KDINL.c9=rec_KDINL.c9+rec_KDINM.c12;
				end if;
			end if;
			fecha_ult_mov:=rec_KDINM.c3;
		end loop;
	
		if rec_KDINM.c5='U' and rec_KDINM.c6='D' then
			rec_KDINL.c17=rec_KDINL.c11;
			rec_KDINL.c11=rec_KDINM.c3;
		end if;
		if rec_KDINM.c5='X' and rec_KDINM.c6='A' then
			rec_KDINL.c18=rec_KDINL.c12;
			rec_KDINL.c12=rec_KDINM.c3;
		end if;	 
		insert into keplersc.kdink(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,
			c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,c35,c36,c37,c38,c39,c40,c41,c42,c43,c44,
			c45,c46,c47,c48,c49,c50,c51,c52,c53,c54,c55,c56,c57,c58,c59,c60,c61,c62,c63)
		values(rec_KDINK.c1,rec_KDINK.c2,rec_KDINK.c3,rec_KDINK.c4,rec_KDINK.c5,rec_KDINK.c6,rec_KDINK.c7,rec_KDINK.c8,
			rec_KDINK.c9,rec_KDINK.c10,rec_KDINK.c11,rec_KDINK.c12,rec_KDINK.c13,rec_KDINK.c14,rec_KDINK.c15,
			rec_KDINK.c16,rec_KDINK.c17,rec_KDINK.c18,rec_KDINK.c19,rec_KDINK.c20,rec_KDINK.c21,rec_KDINK.c22,
			rec_KDINK.c23,rec_KDINK.c24,rec_KDINK.c25,rec_KDINK.c26,rec_KDINK.c27,rec_KDINK.c28,rec_KDINK.c29,
			rec_KDINK.c30,rec_KDINK.c31,rec_KDINK.c32,rec_KDINK.c33,rec_KDINK.c34,rec_KDINK.c35,rec_KDINK.c36,
			rec_KDINK.c37,rec_KDINK.c38,rec_KDINK.c39,rec_KDINK.c40,rec_KDINK.c41,rec_KDINK.c42,rec_KDINK.c43,
			rec_KDINK.c44,rec_KDINK.c45,rec_KDINK.c46,rec_KDINK.c47,rec_KDINK.c48,rec_KDINK.c49,rec_KDINK.c50,
			rec_KDINK.c51,rec_KDINK.c52,rec_KDINK.c53,rec_KDINK.c54,rec_KDINK.c55,rec_KDINK.c56,rec_KDINK.c57,
			rec_KDINK.c58,rec_KDINK.c59,rec_KDINK.c60,rec_KDINK.c61,rec_KDINK.c62,rec_KDINK.c63);
		
	end loop;
	if producto_act <> '' then
		insert into keplersc.kdinl(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20)
		values(rec_KDINL.c1,rec_KDINL.c2,rec_KDINL.c3,rec_KDINL.c4,rec_KDINL.c5,
			rec_KDINL.c6,rec_KDINL.c7,rec_KDINL.c8,rec_KDINL.c9,rec_KDINL.c10,rec_KDINL.c11,
			rec_KDINL.c12,rec_KDINL.c13,rec_KDINL.c14,rec_KDINL.c15,rec_KDINL.c16,
			rec_KDINL.c17,rec_KDINL.c18,rec_KDINL.c19,rec_KDINL.c20);
		
		insert into keplersc.kdreflastmov(c1,c2,c3) values(sucursal_id,producto_act,fecha_ult_mov);		
	end if;
	delete from keplersc.kdink where c1='00';
	delete from keplersc.kdinl where c1='00';

	resultado='1';
	mensaje='';
	adicionales='';

	return query select resultado, mensaje, adicionales;
exception
	when others then
raise notice 'Error en Suc:%, Prod.:%, Fecha:%',sucursal_id,producto_act,fecha_ult_mov;
		resultado := 0;
		mensaje := 'invr_actualizar_estadistica() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
	return query select resultado, mensaje, adicionales;	
end;
$function$
