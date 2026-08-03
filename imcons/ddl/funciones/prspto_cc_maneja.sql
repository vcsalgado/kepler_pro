CREATE OR REPLACE FUNCTION keplersc.prspto_cc_maneja(pcta text, pfecha text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
--Descripcion: Verificacion si Cta Maneja Presupuesto
--Autor: Jose Mendoza
--Fecha: 2024-07-16
--Bitacora de cambios
declare

	vyear text;
	vmonth text;
	vcta text;
	resp text;
	fecha date;
	tablakdc1 text;
	sqlStr text;
	valor text;

	regs int;
	verr text;

begin
	
	resp := 'ERR - ';

	tablakdc1 := 'keplersc.kdc1';

	if length(trim(pfecha)) = 0 then
		verr := 'Error Fecha Vacia';
		raise exception '%', verr;
	else
		fecha := pfecha::date;
	end if;

	if length(trim(pcta)) = 0 then
		verr := 'Error Cuenta Vacia';
		raise exception '%', verr;
	else
		vcta := trim(pcta);
	end if;
	
	vyear := right(extract(year from fecha)::text,2);

	vmonth := lpad(extract(month from fecha)::text,2,'0');

	if extract(year from fecha) > extract(year from current_date) then 
		verr := 'A�o del Periodo No es Valido ... No puede ser mayor al Periodo Actual';
		raise exception '%', verr;
	end if;
	
	tablakdc1 := tablakdc1 || vyear;

	sqlStr := 'select c99 from ' || tablakdc1 || ' ' || 
		' where c1 = '  || E'\'' || vcta || E'\'' || ' ';

	execute sqlStr into valor;
	
	--select sqlStr into resp;

	if valor is null then
		verr := 'Cuenta Contable No Existe ...';
		raise exception '%', verr;
	else
		resp := upper(valor);
	end if;
	
	return resp;


exception
	when others then
		verr := resp || 'prspto_cc_maneja() ' || '['|| sqlstate || '] ' || sqlerrm;
		--raise exception '%', verr;
		return verr;

end;
$function$
