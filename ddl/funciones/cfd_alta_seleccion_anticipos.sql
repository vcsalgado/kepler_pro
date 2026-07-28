CREATE OR REPLACE FUNCTION keplersc.cfd_alta_seleccion_anticipos(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Realiza alta de la seleccion de anticipos relacionados con una factura en KDF3NCANT
--Autor: Miriam Santana
--Fecha: 05/03/2025
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	inventario text;

	folio_docto text = '';

	--Variables de retorno
	resultado text='';
	mensaje text='';
	adicionales text='';


begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	inventario := (xpath('//document/k_claveinv/text()',dataxml))[1];
	folio_docto := coalesce((xpath('//document/k_foliodocto/text()',dataxml))[1]::text,'')::text;
	
	if naturaleza = 'D' then --ALTA
--raise exception 'suc:%, inv:%, g:%, n:%, gp:%, tp:%, folio:%',sucursal_id, inventario, genero, naturaleza, grupo, tipo, folio_operacion;	
		update keplersc.kdf3ncant set
			tipo_relacion ='07',
			genero_doctorel = genero,
			naturaleza_doctorel = naturaleza,
			grupo_doctorel = grupo::integer,
			tipo_doctorel = tipo::integer,
			folio_relacionado = folio_operacion				
			where c1=sucursal_id and c2='U' and c3='D' and c4=79 and folio_relacionado = inventario;

	else					--BAJA
		update keplersc.kdf3ncant set
			tipo_relacion ='',
			genero_doctorel = '',
			naturaleza_doctorel = '',
			grupo_doctorel = 0,
			tipo_doctorel = 0,
			folio_relacionado = ''				
			where c1=sucursal_id and c2='U' and c3='D' and c4=79 and folio_relacionado = folio_docto;
	
	end if;
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cfd_alta_seleccion_anticipos() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
		
end;
$function$
