CREATE OR REPLACE FUNCTION keplersc.alta_nota_credito_anulacion(dataxml xml, xmlkdmm xml, p_folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Inserta Notas de Credito y Anulaciones  
--Autor: Jose Mendoza 
--Fecha: 23/10/2022
--Bitacora de cambios
--03/06/2025 Miriam Santana: Generar el registro con el docto de la nota de descuento que esta cancelando

declare
v_sucursal_id text = '';  
genero text;

naturaleza text;
grupo text;
tipo_clave text;

naturaleza_rel text = '';
grupo_rel text = '';
tipo_clave_rel text = '';
folio_rel text = '';

v_rol_usuario text = '';
expSql text = '';
strValor text = '';
totreg int = 0;

resultado text = '';
mensaje text = '0';
adicionales text = '';

begin
	
	v_sucursal_id := upper((xpath('//document/k_sucn/r1/text()', dataxml))[1]::text); 
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];	

	naturaleza_rel := (xpath('//document/k_natdocto/text()', dataxml))[1];
	grupo_rel := (xpath('//document/k_gpodocto/text()', dataxml))[1];
	tipo_clave_rel := (xpath('//document/k_tipodocto/text()', dataxml))[1];
	folio_rel := (xpath('//document/k_foliodocto/text()', dataxml))[1];	

	if (genero||naturaleza||grupo = 'UD61') then		--MSS 03062025 generar el registro con el docto de la nota de descuento que esta cancelando
		naturaleza_rel := 'A';
		grupo_rel := 52;
		tipo_clave_rel := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
		folio_rel := (xpath('//document/k_refer/text()', dataxml))[1];		
	end if;

	--si no es G(General) es una N(Nota de Credito) o A(Anulacion)
	if (xpath('//row/c94/text()', xmlkdmm))[1]::text <> 'G' or (xpath('//row/c94/text()', xmlkdmm))[1]::text is null then
		insert into keplersc.kdvalntcr (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10)
			values (v_sucursal_id, genero, naturaleza, grupo::integer, tipo_clave::integer, p_folio_operacion
				, naturaleza_rel, grupo_rel::numeric, tipo_clave_rel::numeric, folio_rel);
	end if;

	resultado ='1';
	mensaje ='';
	adicionales ='';						

	return query select resultado, mensaje, adicionales;


EXCEPTION
	WHEN others then		
		resultado := '0';
		mensaje := 'alta_nota_credito_anulacion() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
END;
$function$
