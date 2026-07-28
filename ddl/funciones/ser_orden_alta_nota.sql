CREATE OR REPLACE FUNCTION keplersc.ser_orden_alta_nota(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Realiza inserciÃ³n en KDVALNTCR
--			   Resuelve ORDEN_ALTA_NOTA
--Autor: Miriam Santana
--Fecha: 16/12/2022

declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	natdocto_anx text;
	gpodocto_anx text;
	tipodocto_anx text;
	foliodocto_anx text;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	--Tipo de documento
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
		
	natdocto_anx := (xpath('//document/k_natdocto/text()', dataxml))[1];
	gpodocto_anx := (xpath('//document/k_gpodocto/text()', dataxml))[1];
	tipodocto_anx := (xpath('//document/k_tipodocto/text()', dataxml))[1];
	foliodocto_anx := (xpath('//document/k_foliodocto/text()', dataxml))[1];	

	if (xpath('//row/c11/text()', xmlKDMM))[1]::text = 'S' and genero='U' and naturaleza='A' then	
		insert into keplersc.kdvalntcr 
			 (c1, c2, c3, c4, c5, 
			 c6, c7, c8, c9, c10)
		values 
			(sucursal_id, genero, naturaleza, grupo::integer, tipo::integer, folio_operacion,
		 	natdocto_anx, gpodocto_anx::integer, tipodocto_anx::integer, foliodocto_anx);
	end if;		
		resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_orden_alta_nota() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
