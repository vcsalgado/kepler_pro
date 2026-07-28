CREATE OR REPLACE FUNCTION keplersc.prspto_ejercido_periodo(psuc text, pconcept text, pfecha text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
--Descripcion: Verificacion del Monto Ejercido del Presupuesto para el Concepto
--Autor: Jose Mendoza
--Fecha: 2024-07-16
--Bitacora de cambios
declare

	vyear text;
	vmonth text;
	vsuc text;
	vconcept text;

	resp text;
	fecha date;

	cmd text;
	sqlStr text;
	valor text;

	regs int;
	verr text;

begin
	
	resp := 'ERR - ';

	if length(trim(pfecha)) = 0 then
		verr := 'Error Fecha Vacia';
		raise exception '%', verr;
	else
		fecha := pfecha::date;
	end if;

	if length(trim(psuc)) = 0 then
		verr := 'Error Sucursal Vacia';
		raise exception '%', verr;
	else
		vsuc := trim(psuc);
	end if;

	if length(trim(pconcept)) = 0 then
		verr := 'Error Concepto Vacio';
		raise exception '%', verr;
	else
		vconcept := trim(pconcept);
	end if;
	
	vyear := /*right(*/extract(year from fecha)::text/*,2)*/;

	vmonth := lpad(extract(month from fecha)::text,2,'0');

	if length(vyear) <> 4 then
		verr := 'Error A�o del Periodo Invalido';
		raise exception '%', verr;
	end if;

	if extract(year from fecha) > extract(year from current_date) then 
		verr := 'A�o del Periodo No es Valido ... No puede ser mayor al Periodo Actual';
		raise exception '%', verr;
	end if;
	
	/*
	sqlStr := 'select importe from keplersc.kdpresupuestos ' || 
		'where sucursal = '  || E'\'' || vsuc || E'\'' || ' and cve_concepto = ' || E'\'' || vconcept || E'\'' || 
		' and anio = ' || E'\'' || vyear || E'\'' || ' and mes = ' || E'\'' || vmonth || E'\'';
	*/
	
	cmd = 'select sum(importe) importe from ( select * from ( ';

		cmd = cmd || 'select coalesce( ' || 
				'( ' || 
				'select sum( case when upper(k6.c10) = ' || E'\'' || 'C' || E'\'' || ' then k6.c11 else case when upper(k6.c10) = ' || E'\'' || 'A' || E'\'' || ' then k6.c11 * -1 else 0 end end ) importe ' || 
				'from keplersc.kdm6 k6 ' ||
				'inner join keplersc.kdm1 k1 on k6.c1 = k1.c1 and k6.c2 = k1.c2 and k6.c3 = k1.c3 and k6.c4 = k1.c4 and k6.c5 = k1.c5 and k6.c6 = k1.c6 ' ||
				'where k6.c1 = ' || E'\'' || vsuc || E'\'' || ' and k6.c2 = ' || E'\'' || 'X' || E'\'' || ' and k6.c3 = ' || E'\'' || 'A' || E'\'' || ' and k6.c4 = 12 and k6.c5 = 1 and k6.ctopto = ' || E'\'' || vconcept || E'\'' || ' ' || 
				'and upper(k1.c43) <> ' || E'\'' || 'C' || E'\'' || ' and extract(year from k1.c9)::text = ' || E'\'' || vyear || E'\'' || ' and lpad(extract(month from k1.c9)::text,2,' || E'\'' || '0' || E'\'' || ') = ' || E'\'' || vmonth || E'\'' || ' ' ||
				') ' ||  
			', 0) as importe ';

		cmd = cmd || 'union all ';

		cmd = cmd ||	'select coalesce( ' ||
				'( ' ||
				'select sum( case when upper(kd.c10) = ' || E'\'' || 'C' || E'\'' || ' then kd.c11 else case when upper(kd.c10) = ' || E'\'' || 'A' || E'\'' || ' then kd.c11 * -1 else 0 end end ) importe ' ||
				'from keplersc.kdmdocscompr kd ' || 
				'inner join keplersc.kdm1 k1 on kd.c1 = k1.c1 and kd.c2 = k1.c2 and kd.c3 = k1.c3 and kd.c4 = k1.c4 and kd.c5 = k1.c5 and kd.c6 = k1.c6 ' || 
				'where kd.c1 = ' || E'\'' || vsuc || E'\'' || ' and kd.c2 = ' || E'\'' || 'X' || E'\'' || ' and kd.c3 = ' || E'\'' || 'A' || E'\'' || ' and kd.c4 = 12 and kd.c5 = 1 and kd.ctopto = ' || E'\'' || vconcept || E'\'' || ' ' ||
				'and upper(k1.c43) <> ' || E'\'' || 'C' || E'\'' || ' and extract(year from k1.c9)::text = ' || E'\'' || vyear || E'\'' || ' and lpad(extract(month from k1.c9)::text,2,' || E'\'' || '0' || E'\'' || ') = ' || E'\'' || vmonth || E'\'' || ' ' ||
				') ' ||
			', 0) as importe ';

		cmd = cmd || ') rf ) t_sum ';

	
	sqlStr := cmd;
	
	execute sqlStr into valor;
	
	--select sqlStr into resp;

	if valor is null then
		verr := 'No se pudo determinar el Presupuesto Ejercido para el Concepto ...';
		raise exception '%', verr;
	else
		resp := upper(valor);
	end if;
	
	return resp;


exception
	when others then
		verr := resp || 'prspto_ejercido_periodo() ' || '['|| sqlstate || '] ' || sqlerrm;
		--raise exception '%', verr;
		return verr;

end;
$function$
