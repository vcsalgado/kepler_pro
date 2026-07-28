CREATE OR REPLACE FUNCTION keplersc.prspto_cc_maneja(psuc text, pcta text, pfecha text)
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

	--Added by JMM 20240820
	vyear4 text;
	vsuc text;

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

	--Added by JMM 20240820
	if length(trim(psuc)) = 0 then
		verr := 'Error Sucursal Vacia';
		raise exception '%', verr;
	else
		vsuc := trim(psuc);
	end if;
	
	vyear := right(extract(year from fecha)::text,2);

	vmonth := lpad(extract(month from fecha)::text,2,'0');

	--Added by JMM 20240820
	vyear4 := extract(year from fecha)::text;

	if extract(year from fecha) > extract(year from current_date) then 
		verr := 'A�o del Periodo No es Valido ... No puede ser mayor al Periodo Actual';
		raise exception '%', verr;
	end if;
	
	tablakdc1 := tablakdc1 || vyear;

	--UPD by JMM 20240816 ... field c99 wont be used for validation anymore
	sqlStr := 'select /*c99*/ c1 from ' || tablakdc1 || ' ' || 
		' where c1 = '  || E'\'' || vcta || E'\'' || ' ';

	execute sqlStr into valor;
	
	--select sqlStr into resp;

	if valor is null then
		verr := 'Cuenta Contable No Existe ...';
		raise exception '%', verr;
	else
	
		--Adapted by JMM 20240816 ... New TBL for Validation of Budget
	
		--resp := upper(valor);
	
		resp := '';
		select count(*) into regs from keplersc.cat_ctas_ppto ccp where vcta between ccp.rango_ini and ccp.rango_fin
			/*Added by JMM 20240820*/ and sucursal = vsuc and anio = vyear4;
		regs := coalesce(regs, 0);
		if regs > 0 then
			resp := upper('S');
		end if;
	
	end if;
	
	return resp;


exception
	when others then
		verr := resp || 'prspto_cc_maneja() ' || '['|| sqlstate || '] ' || sqlerrm;
		--raise exception '%', verr;
		return verr;

end;
$function$
