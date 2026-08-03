CREATE OR REPLACE FUNCTION keplersc.cierra_abre_mes(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza cambios a Cerar-Abrir Mes
--Autor: Gad Miranda
--Fecha: 26/10/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	k_anio text = '';
	k_ene text = '';
	k_feb text = '';
	k_mar text = '';
	k_abr text = '';
	k_may text = '';
	k_jun text = '';
	k_jul text = '';
	k_ago text = '';
	k_sep text = '';
	k_oct text = '';
	k_nov text = '';
	k_dic text = '';

	crud text = '';
	totReg numeric(1);
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 

	k_anio  := '20' || (xpath('//document/k_anio/r0/text()', dataxml))[1];
	k_ene  := (xpath('//document/k_ene/text()', dataxml))[1];
	k_feb  := (xpath('//document/k_feb/text()', dataxml))[1];
	k_mar  := (xpath('//document/k_mar/text()', dataxml))[1];
	k_abr  := (xpath('//document/k_abr/text()', dataxml))[1];
	k_may  := (xpath('//document/k_may/text()', dataxml))[1];
	k_jun  := (xpath('//document/k_jun/text()', dataxml))[1];
	k_jul  := (xpath('//document/k_jul/text()', dataxml))[1];
	k_ago  := (xpath('//document/k_ago/text()', dataxml))[1];
	k_sep  := (xpath('//document/k_sep/text()', dataxml))[1];
	k_oct  := (xpath('//document/k_oct/text()', dataxml))[1];
	k_nov  := (xpath('//document/k_nov/text()', dataxml))[1];
	k_dic  := (xpath('//document/k_dic/text()', dataxml))[1];
	
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	select count(*) into totReg from keplersc.kdym where c1=k_anio;
	if totReg > 0 then
		DELETE FROM keplersc.kdym where c1=k_anio;
	end if;

    INSERT INTO keplersc.kdym
        (c1, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20, c21)
    VALUES
        (k_anio, k_ene, k_feb, k_mar, k_abr, k_may, k_jun, k_jul, k_ago, k_sep, k_oct, k_nov, k_dic);

	resultado := 1;
	mensaje := 'Registro agregado: ' || k_anio;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'Cierra-Abre Mes() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
