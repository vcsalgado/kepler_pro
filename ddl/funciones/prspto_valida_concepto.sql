CREATE OR REPLACE FUNCTION keplersc.prspto_valida_concepto(psuc text, pconcept text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
--Descripcion: Verificacion si Concepto del Presupuesto Existe
--Autor: Jose Mendoza
--Fecha: 2024-07-16
--Bitacora de cambios
declare

	vsuc text;
	vconcept text;
	resp text;
	sqlStr text;
	valor text;

	regs int;
	verr text;

begin
	
	resp := 'ERR - ';

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

	sqlStr := 'select descripcion from keplersc.kdcatconpres ' || 
		'where sucursal = '  || E'\'' || vsuc || E'\'' || ' and cve_concepto = ' || E'\'' || vconcept || E'\'';

	execute sqlStr into valor;
	
	--select sqlStr into resp;

	if valor is null then
		verr := 'Concepto de Presupuesto No Existe ...';
		raise exception '%', verr;
	else
		resp := upper(valor);
	end if;
	
	return resp;


exception
	when others then
		verr := resp || 'prspto_valida_concepto() ' || '['|| sqlstate || '] ' || sqlerrm;
		--raise exception '%', verr;
		return verr;

end;
$function$
