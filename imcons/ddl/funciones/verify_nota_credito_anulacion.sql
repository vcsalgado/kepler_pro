CREATE OR REPLACE FUNCTION keplersc.verify_nota_credito_anulacion(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Valida Notas de Credito y Anulaciones  
--Autor: Jose Mendoza 
--Fecha: 22/10/2022
--Bitacora de cambios
--25/02/2025 Miriam Santana: No realizar validacion de tipos de doctos sean <> para la anulacion por sustitucion, pueden ser diferentes
--17/03/2025 Miriam Santana: Incuir validaciones para Aplicacion de anticipos, no validar
--03/06/2025 Miriam Santana: Validar el registro con el docto de la nota de descuento que esta cancelando

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
m11 text;
m13 text;
uen text;
flag_anulacion text = '';--MSS 25022025 Anulacion por sustitucion

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
	uen := coalesce((xpath('//document/ambiente/uen/text()',dataxml))[1],'');
	flag_anulacion :=coalesce((xpath('//document/ambiente/flag_anulacion/text()',dataxml))[1]::text,'')::text;	--MSS 25022025 Anulacion por sustitucion
	
	select c11,c13 into m11,m13 from keplersc.kdmm where col_sucursal=v_sucursal_id and c1=genero and c2=naturaleza and c3=grupo::numeric and c4=tipo_clave::numeric;	--MSS

	if (genero||naturaleza||grupo = 'UD61') then		--MSS 03062025 validar el registro con el docto de la nota de descuento que esta cancelando
		naturaleza_rel := 'A';
		grupo_rel := 52;
		tipo_clave_rel := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
		folio_rel := (xpath('//document/k_refer/text()', dataxml))[1];		
	end if;

	--si no es G(General) es una N(Nota de Credito) o A(Anulacion)
	if (xpath('//row/c94/text()', xmlkdmm))[1]::text <> 'G' or (xpath('//row/c94/text()', xmlkdmm))[1]::text is null then
		select count(*) into totreg from keplersc.kdvalntcr where c1 = v_sucursal_id and c2 = genero 
			and c7 = naturaleza_rel and c8 = grupo_rel::numeric and c9 = tipo_clave_rel::numeric and c10 = folio_rel; 
	--MSS: No realice la validacion de NC y anulacion para anticipos, se validan en verify cfdi con la tabla KDF3NCANT		
		if totReg > 0 and (genero||naturaleza_rel||grupo_rel<> 'UD79') and (genero||naturaleza_rel||grupo_rel<> 'UA81') then		--MSS 17032025 Aplicacion de anticipos
			strValor := '';
			select c6 into strValor from keplersc.kdvalntcr where c1 = v_sucursal_id and c2 = genero 
			and c7 = naturaleza_rel and c8 = grupo_rel::numeric and c9 = tipo_clave_rel::numeric and c10 = folio_rel;
		
			raise exception '%','El Documento ya tiene asociada una nota de credito o una anulacion [' || strValor || '], imposible continuar ...';
		
		end if;	
	
		if tipo_clave <> tipo_clave_rel and (flag_anulacion='' or flag_anulacion is null) then
			raise exception '%', 'Los tipos de documento no son iguales, verifique por favor';
		end if;
	
	end if;

	resultado ='1';
	mensaje ='';
	adicionales ='';						

	return query select resultado, mensaje, adicionales;


EXCEPTION
	WHEN others then		
		resultado := '0';
		mensaje := 'verify_nota_credito_anulacion() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
END;
$function$
