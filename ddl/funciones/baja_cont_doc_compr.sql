CREATE OR REPLACE FUNCTION keplersc.baja_cont_doc_compr(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserci�n de movimientos contables en KDMDOCSCOMPR
---- para uso exclusivo de las Operaciones de Nvo Esquema de CxP - Contrarecibo Convert (Comprobacion de C x P)
--Autor: Jose Mendoza
--Fecha: 2024-05-14

declare
	--Variables de definicion de documento
	sucursal_desc text;
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text; 
	tipo_clave text;


	--Variables Loop
	no_partidas int;
	numero_partida int;
	clave_cuenta text;
	descr_cuenta text;
	cargo text;
	abono text;	
	monto numeric = 0;
	cargo_abono text;
	inventario text;

	--Variables de uso general 
	strValor text;

	--Added by JMM 20240308
	flag_contrarec text = '';
	afecta_inventario text = '';

	--Added by JMM 20240514
	totalReg numeric = 0;
	mensajeError text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;


begin
	sucursal_desc := (xpath('//document/k_sucn/r0/text()', dataxml))[1];
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];

	--Tipo de documento
	tipo_desc := (xpath('//document/k_tipon/r0/text()', dataxml))[1]; 
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	--Added by JMM 20240308 ... Moved here by JMM 20240404
	flag_contrarec = '';
	if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
		flag_contrarec := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
	end if;

	if upper(flag_contrarec) <> 'CXP_CONTR_REC_CONVERT_ROLLBACK' then 
		raise exception '%', 'Se esta llamando a la funcion [ alta_cont_doc_compr ] desde una Operacion No Valida ...';
	end if;

	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	

	/*numero_partida := 0;*/

	if no_partidas <= 0 then
		mensajeError := 'El Documento No puede Procesarse sino contiene partidas { k_mov } ...';
		raise exception '%',mensajeError;
	end if;

	totalReg := 0;
	select count(*) into totalReg from keplersc.kdmdocscompr  
	where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo_clave::int
		and c6 = folio_operacion;
	if totalReg = 0 then
		mensajeError := 'No se encontraron Registros a Revertir en la Tabla { kdmdocscompr } ...';
		raise exception '%',mensajeError;			
	end if;


	delete from keplersc.kdmdocscompr where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo_clave::int 
		and c6 = folio_operacion;

	totalReg := 0;
	select count(*) into totalReg from keplersc.kdmdocscompr  
	where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo_clave::int
		and c6 = folio_operacion;
	if abs(totalReg) > 0 then
		mensajeError := 'Se encontraron Registros Inconsistentes al Eliminar Registros en la Tabla { kdmdocscompr } ...';
		raise exception '%',mensajeError;			
	end if;


	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'baja_cont_doc_compr() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
