CREATE OR REPLACE FUNCTION keplersc.tipos_ordenes_editar(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Edita tipos de ordenes , kdmargen
--Autor: Luis Leal
--Fecha: 31/01/2023
--Bitacora de cambios
declare
	tipo_orden text;
	tipo_trabajo text;
	descripcion text;
	costo_hora numeric;
	m_refacciones_y_m_i numeric;
	m_tots numeric;
	m_cargos_varios numeric;
	factor_conversion numeric;
	folio_actual numeric;
	m_refacciones_y_m_e numeric;
	iva numeric;
	imp_vale_salida text;
	preferencia numeric;
	grupo_folio text;
	horas_diagnostico numeric;
	cargos_varios_diagnostico numeric;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	
	tipo_orden := coalesce((xpath('//document/k_mov/r0/tipo_orden/text()',dataxml))[1],'');
	tipo_trabajo := coalesce((xpath('//document/k_mov/r0/tipo_trabajo/text()',dataxml))[1],'');
	descripcion := coalesce((xpath('//document/k_mov/r0/descripcion/text()',dataxml))[1],'');
	costo_hora := coalesce((xpath('//document/k_mov/r0/costo_hora/text()',dataxml))[1],'0');
	m_refacciones_y_m_i := coalesce((xpath('//document/k_mov/r0/m_refacciones_y_m_i/text()',dataxml))[1],'0');
	m_tots := coalesce((xpath('//document/k_mov/r0/m_tots/text()',dataxml))[1],'0');
	m_cargos_varios := coalesce((xpath('//document/k_mov/r0/m_cargos_varios/text()',dataxml))[1],'0');
	factor_conversion := coalesce((xpath('//document/k_mov/r0/factor_conversion/text()',dataxml))[1],'0');
	folio_actual := coalesce((xpath('//document/k_mov/r0/folio_actual/text()',dataxml))[1],'0');
	m_refacciones_y_m_e := coalesce((xpath('//document/k_mov/r0/m_refacciones_y_m_e/text()',dataxml))[1],'0');
	iva := coalesce((xpath('//document/k_mov/r0/iva/text()',dataxml))[1],'0');
	imp_vale_salida := coalesce((xpath('//document/k_mov/r0/imp_vale_salida/text()',dataxml))[1],'N');
	preferencia := coalesce((xpath('//document/k_mov/r0/preferencia/text()',dataxml))[1],'0');
	grupo_folio := coalesce((xpath('//document/k_mov/r0/grupo_folio/text()',dataxml))[1],'');
	horas_diagnostico := coalesce((xpath('//document/k_mov/r0/horas_diagnostico/text()',dataxml))[1],'0');
	cargos_varios_diagnostico := coalesce((xpath('//document/k_mov/r0/cargos_varios_diagnostico/text()',dataxml))[1],'0');

	if imp_vale_salida <> 'S' and imp_vale_salida <> 'N' then 
		raise exception '%', 'En Imprimir vale de salida debes ingresar S o N solamente.';
	end if;
	
	update keplersc.kdmargen set c2=tipo_trabajo, c3=descripcion, c4=costo_hora, c5=m_refacciones_y_m_i,
	c6=m_tots, c7=m_cargos_varios, c8=factor_conversion, c9=folio_actual, c10=m_refacciones_y_m_e, c11=iva,
	c12=imp_vale_salida, c13=preferencia, c14=grupo_folio, c15=horas_diagnostico, c16=cargos_varios_diagnostico
	where c1=tipo_orden ;
	

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'tipos_ordenes_editar() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
