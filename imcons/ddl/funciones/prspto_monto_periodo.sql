CREATE OR REPLACE FUNCTION keplersc.prspto_monto_periodo(psuc text, pconcept text, pfecha text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
--Descripcion: Verificacion del Monto Presupuestado para el Concepto
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
	

	sqlStr := 'select importe from keplersc.kdpresupuestos ' || 
		'where sucursal = '  || E'\'' || vsuc || E'\'' || ' and cve_concepto = ' || E'\'' || vconcept || E'\'' || 
		' and anio = ' || E'\'' || vyear || E'\'' || ' and mes = ' || E'\'' || vmonth || E'\'';

	execute sqlStr into valor;
	
	--select sqlStr into resp;

	if valor is null then
		verr := 'No se ha Registrado el Presupuesto para el Concepto, dentro del periodo de la Operacion ...';
		raise exception '%', verr;
	else
		resp := upper(valor);
	end if;
	
	return resp;


exception
	when others then
		verr := resp || 'prspto_monto_periodo() ' || '['|| sqlstate || '] ' || sqlerrm;
		--raise exception '%', verr;
		return verr;

end;
$function$
